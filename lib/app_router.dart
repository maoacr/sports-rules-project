import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/sports/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/sports/presentation/pages/home_page.dart';
import 'features/sports/presentation/pages/law_list_page.dart';
import 'features/sports/presentation/pages/law_detail_page.dart';
import 'features/sports/presentation/pages/article_detail_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/settings_page.dart';
import 'features/rules/presentation/pages/bookmark_list_page.dart';
import 'features/purchases/presentation/pages/purchases_page.dart';

/// Route paths matching spec (v2: chapters/rules → laws/articles).
class AppRoutePaths {
  AppRoutePaths._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String sports = '/sports/:sportId';
  static const String law = '/sports/:sportId/laws/:lawId';
  static const String article =
      '/sports/:sportId/laws/:lawId/articles/:articleId';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String bookmarks = '/bookmarks';
  static const String purchases = '/purchases';
}

/// Route names for GoRouter.
class AppRouteNames {
  AppRouteNames._();

  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String auth = 'auth';
  static const String home = 'home';
  static const String sports = 'sports';
  static const String law = 'law';
  static const String article = 'article';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String bookmarks = 'bookmarks';
  static const String purchases = 'purchases';
}

/// Deep link route information parser using AppLinks.
class AppLinksRouteInformationParser
    extends RouteInformationParser<Uri> {
  const AppLinksRouteInformationParser();

  @override
  Future<Uri> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    return uri;
  }

  @override
  RouteInformation? restoreRouteInformation(Uri configuration) {
    return RouteInformation(uri: configuration);
  }
}

/// ChangeNotifier that wraps AuthBloc state for GoRouter refreshListenable.
class AuthRouterDelegate extends ChangeNotifier {
  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _subscription;

  AuthRouterDelegate(this._authBloc) {
    _subscription = _authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  AuthState get currentState => _authBloc.state;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Public routes that don't require authentication.
const _publicRoutes = {'/', '/onboarding', '/auth'};

/// Determines redirect based on auth state.
String? _getRedirect(AuthState authState, String currentLocation) {
  // Stay on splash while loading
  if (authState is AuthLoading || authState is AuthInitial) {
    if (currentLocation != '/') {
      return '/';
    }
    return null;
  }

  // Authenticated user
  if (authState is AuthAuthenticated) {
    if (currentLocation == '/auth' || currentLocation == '/onboarding') {
      return '/home';
    }
    return null;
  }

  // Unauthenticated
  if (authState is AuthUnauthenticated || authState is AuthFailure) {
    if (!_publicRoutes.contains(currentLocation)) {
      return '/auth';
    }
    return null;
  }

  return null;
}

/// Creates the app router with auth-aware redirect logic.
GoRouter createAppRouter(AuthBloc authBloc) {
  final authDelegate = AuthRouterDelegate(authBloc);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authDelegate,
    routes: [
      GoRoute(
        path: '/',
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth',
        name: AppRouteNames.auth,
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/home',
        name: AppRouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/sports/:sportId',
        name: AppRouteNames.sports,
        builder: (context, state) {
          final sportId = state.pathParameters['sportId']!;
          return LawListPage(sportId: sportId);
        },
        routes: [
          GoRoute(
            path: 'laws/:lawId',
            name: AppRouteNames.law,
            builder: (context, state) {
              final sportId = state.pathParameters['sportId']!;
              final lawId = state.pathParameters['lawId']!;
              return LawDetailPage(sportId: sportId, lawId: lawId);
            },
            routes: [
              GoRoute(
                path: 'articles/:articleId',
                name: AppRouteNames.article,
                builder: (context, state) {
                  final articleId = state.pathParameters['articleId']!;
                  final sportId = state.pathParameters['sportId']!;
                  final lawId = state.pathParameters['lawId']!;
                  return ArticleDetailPage(
                    articleId: articleId,
                    sportId: sportId,
                    lawId: lawId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        name: AppRouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        name: AppRouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/bookmarks',
        name: AppRouteNames.bookmarks,
        builder: (context, state) => const BookmarkListPage(),
      ),
      GoRoute(
        path: '/purchases',
        name: AppRouteNames.purchases,
        builder: (context, state) => const PurchasesPage(),
      ),
    ],
    redirect: (context, state) {
      final authState = authDelegate.currentState;
      final currentLocation = state.uri.path;
      return _getRedirect(authState, currentLocation);
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.path}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
