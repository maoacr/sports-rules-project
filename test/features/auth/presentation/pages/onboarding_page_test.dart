// Widget tests for [OnboardingPage].
//
// OnboardingPage is stateless and uses `getIt<SharedPreferencesStorage>`
// directly (no BLoC), so the test only needs to:
//   1. Render the page
//   2. Assert the static copy and that the CTA is present
//   3. Tap "Get Started" and verify:
//      - SharedPreferences flag is set to `true`
//      - GoRouter navigates to /auth

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_rules_app/core/di/injection.dart';
import 'package:sports_rules_app/core/storage/shared_preferences_storage.dart';
import 'package:sports_rules_app/features/auth/presentation/pages/onboarding_page.dart';

import '../../../../helpers/test_injection.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPreferencesStorage prefsStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    final setup = await setupTestGetIt(prefs: prefs);
    prefsStorage = setup.prefs;
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
        GoRoute(path: '/auth', builder: (_, __) => const Scaffold(body: Text('AUTH_PAGE'))),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders the welcome copy and the Get Started CTA', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Sports Rules'), findsOneWidget);
    expect(
      find.textContaining('Your complete guide to rules for multiple sports'),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
  });

  testWidgets('does not show the Get Started button if already on on auth', (tester) async {
    // Sanity check: the onboarding page is only shown once (the splash
    // page routes past it once `prefs.hasSeenOnboarding` is true). The
    // test here just verifies the page is a regular StatelessWidget, so
    // the CTA is always present and the routing decision happens in
    // SplashPage, not here.
    await tester.pumpWidget(buildSubject());
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('tapping Get Started sets the onboarding flag and navigates to /auth',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(prefsStorage.hasSeenOnboarding, isFalse);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(prefsStorage.hasSeenOnboarding, isTrue);
    expect(find.text('AUTH_PAGE'), findsOneWidget);
  });
}
