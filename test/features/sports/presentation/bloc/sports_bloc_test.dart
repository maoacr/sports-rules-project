import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/features/sports/domain/entities/sport.dart';
import 'package:sports_rules_app/features/sports/domain/repositories/sport_repository.dart';
import 'package:sports_rules_app/features/sports/presentation/bloc/sports_bloc.dart';

class MockSportRepository extends Mock implements SportRepository {}

void main() {
  late SportsBloc sportsBloc;
  late MockSportRepository mockSportRepository;

  setUp(() {
    mockSportRepository = MockSportRepository();
    sportsBloc = SportsBloc(mockSportRepository);
  });

  tearDown(() {
    sportsBloc.close();
  });

  const testSport = Sport(
    id: 'fifa_football',
    title: 'Football',
    description: 'Official FIFA football rules',
    thumbnailUrl: 'https://example.com/football.png',
    lawCount: 17,
    price: 499,
    isPublished: true,
  );

  const testSports = [testSport];

  const testFailure = ServerFailure(message: 'Server error');

  group('SportsBloc', () {
    group('SportsLoadRequested', () {
      blocTest<SportsBloc, SportsState>(
        'emits [SportsLoading, SportsLoaded] with list of sports on success',
        build: () {
          when(() => mockSportRepository.getSports())
              .thenAnswer((_) async => const Right<Failure, List<Sport>>(testSports));
          return sportsBloc;
        },
        act: (bloc) => bloc.add(const SportsLoadRequested()),
        expect: () => [
          const SportsLoading(),
          const SportsLoaded(testSports),
        ],
        verify: (_) {
          verify(() => mockSportRepository.getSports()).called(1);
        },
      );

      blocTest<SportsBloc, SportsState>(
        'emits [SportsLoading, SportsLoaded] with empty list when no sports',
        build: () {
          when(() => mockSportRepository.getSports())
              .thenAnswer((_) async => const Right<Failure, List<Sport>>([]));
          return sportsBloc;
        },
        act: (bloc) => bloc.add(const SportsLoadRequested()),
        expect: () => [
          const SportsLoading(),
          const SportsLoaded([]),
        ],
      );

      blocTest<SportsBloc, SportsState>(
        'emits [SportsLoading, SportsError] on failure',
        build: () {
          when(() => mockSportRepository.getSports())
              .thenAnswer((_) async => const Left<Failure, List<Sport>>(testFailure));
          return sportsBloc;
        },
        act: (bloc) => bloc.add(const SportsLoadRequested()),
        expect: () => [
          const SportsLoading(),
          const SportsError('Server error'),
        ],
      );
    });
  });
}
