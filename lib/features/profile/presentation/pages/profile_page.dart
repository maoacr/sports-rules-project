import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../../purchases/presentation/bloc/purchases_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<SharedPreferencesStorage>();

    return BlocProvider(
      create: (_) => PurchasesBloc(getIt(), prefs)..add(const RestoreRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        body: BlocBuilder<PurchasesBloc, PurchasesState>(
          builder: (context, state) {
            return ListView(
              children: [
                const SizedBox(height: 24),
                const CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.person, size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sports Rules User',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restore Purchases'),
                  subtitle: const Text('Re-sync your purchases'),
                  onTap: () {
                    context.read<PurchasesBloc>().add(const RestoreRequested());
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Purchased Sports',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                BlocBuilder<PurchasesBloc, PurchasesState>(
                  builder: (context, state) {
                    if (state is EntitlementsLoaded) {
                      if (state.sportIds.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No purchases yet.'),
                        );
                      }
                      return Column(
                        children: state.sportIds
                            .map((id) => ListTile(
                                  leading: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  title: Text(id),
                                ))
                            .toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
