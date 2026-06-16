// Widget tests for [ChapterDetailPage].
//
// ChapterDetailPage creates its own RulesBloc from getIt, fetches
// the rules for the given chapter, and renders the list (or an
// error message).

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_rules_app/core/di/injection.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/sports/domain/entities/sport.dart';
import 'package:sports_rules_app/features/sports/domain/repositories/sport_repository.dart';
import 'package:sports_rules_app/features/sports/presentation/pages/chapter_detail_page.dart';

import '../../../../helpers/test_injection.dart';

void main() {
  late SportRepository mockSportRepo;

  const testRule = Rule(
    id: 'rule_1_1',
    chapterId: 'chapter_1',
    sportId: 'fifa_football',
    title: 'Field surface',
    content: 'The field of play must be natural or, if competition rules permit, artificial.',
    imageUrls: [],
    order: 1,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final setup = await setupTestGetIt();
    mockSportRepo = setup.sport;
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows a loading spinner while rules are loading', (tester) async {
    // Use a Completer so the bloc stays in loading state until the
    // test completes the future manually.
    final completer = Completer<Either<Failure, List<Rule>>>();
    when(() => mockSportRepo.getRules(any())).thenAnswer((_) => completer.future);

    await tester.pumpWidget(MaterialApp(
      home: ChapterDetailPage(
        sportId: 'fifa_football',
        chapterId: 'chapter_1',
      ),
    ));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Clean up: complete the future so the bloc can finish.
    completer.complete(const Right<Failure, List<Rule>>([]));
    await tester.pump();
  });

  testWidgets('renders the rules list on success', (tester) async {
    when(() => mockSportRepo.getRules(any()))
        .thenAnswer((_) async => const Right<Failure, List<Rule>>([testRule]));

    await tester.pumpWidget(MaterialApp(
      home: ChapterDetailPage(
        sportId: 'fifa_football',
        chapterId: 'chapter_1',
      ),
    ));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Field surface'), findsOneWidget);
    // The content is truncated at 80 chars with an ellipsis.
    expect(find.textContaining('The field of play must be natural'), findsOneWidget);
  });

  testWidgets('shows the error message on failure', (tester) async {
    when(() => mockSportRepo.getRules(any())).thenAnswer(
      (_) async => const Left<Failure, List<Rule>>(
        ServerFailure(message: 'Could not load rules'),
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: ChapterDetailPage(
        sportId: 'fifa_football',
        chapterId: 'chapter_1',
      ),
    ));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Could not load rules'), findsOneWidget);
  });
}
