import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'core/di/injection.dart';
import 'core/network/firebase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class SportsRulesApp extends StatefulWidget {
  const SportsRulesApp({super.key});

  @override
  State<SportsRulesApp> createState() => _SportsRulesAppState();
}

class _SportsRulesAppState extends State<SportsRulesApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(AuthCheckRequested());
    _router = createAppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showOfflineBanner = !FirebaseClient.firebaseReady;
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'Sports Rules',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        // TEMP (B): overlay a persistent banner when Firebase is not
        // configured, so the dev never forgets the app is running in
        // local-only mode. Remove once GoogleService-Info.plist /
        // google-services.json is wired up.
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();
          if (!showOfflineBanner) return child;
          return _OfflineBanner(child: child);
        },
      ),
    );
  }
}

/// TEMP (B): yellow top banner shown when Firebase is not configured.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Stack + Positioned so we don't fight the inner Scaffold layout.
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.amber.shade300,
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: Colors.black87),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Firebase not configured — running in local-only mode',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
