import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../../../core/di/injection.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              const Icon(
                Icons.sports_soccer,
                size: 80,
                color: Color(0xFF1E88E5),
              ),
              const SizedBox(height: 24),
              Text(
                'Sports Rules',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your complete guide to rules for multiple sports. '
                'Start with free chapters and unlock more with simple one-time purchases.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await getIt<SharedPreferencesStorage>()
                        .setOnboardingSeen(true);
                    if (context.mounted) {
                      context.go('/auth');
                    }
                  },
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
