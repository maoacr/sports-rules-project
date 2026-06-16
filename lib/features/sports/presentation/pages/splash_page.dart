import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/deeplink/deeplink_handler.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Splash page that checks auth state and handles deep links.
///
/// On init:
/// 1. Listens to AuthBloc for auth state
/// 2. Resolves deep links if app was opened via URL
/// 3. Navigates based on auth state after check completes
class SplashPage extends StatefulWidget {
  final Uri? initialDeepLink;

  const SplashPage({super.key, this.initialDeepLink});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _handleDeepLinkIfPresent();
  }

  void _handleDeepLinkIfPresent() {
    if (widget.initialDeepLink != null) {
      final result = _deepLinkHandler.parseUri(widget.initialDeepLink!);
      _deepLinkHandler.handleDeepLinkResult(result, context);
    }
  }

  void _navigate(AuthState authState) {
    if (_hasNavigated) return;
    _hasNavigated = true;

    final prefs = getIt<SharedPreferencesStorage>();

    // Handle authenticated user
    if (authState is AuthAuthenticated) {
      if (widget.initialDeepLink != null) {
        // Handle deep link navigation
        final result = _deepLinkHandler.parseUri(widget.initialDeepLink!);
        _deepLinkHandler.handleDeepLinkResult(result, context);
      } else {
        context.go('/home');
      }
      return;
    }

    // Handle unauthenticated user
    if (authState is AuthUnauthenticated || authState is AuthFailure) {
      if (widget.initialDeepLink != null) {
        // Deep links require auth, redirect to auth
        context.go('/auth');
        return;
      }

      if (prefs.hasSeenOnboarding) {
        context.go('/auth');
      } else {
        context.go('/onboarding');
      }
      return;
    }

    // Loading state - stay on splash
    if (authState is AuthLoading || authState is AuthInitial) {
      // Stay on splash, will navigate when state changes
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _navigate(state);
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_soccer,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Sports Rules',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
