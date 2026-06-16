import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/sports_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: BlocBuilder<SportsBloc, SportsState>(
        builder: (context, state) {
          if (state is SportsLoading || state is SportsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SportsBloc>().add(const SportsLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is SportsLoaded) {
            if (state.sports.isEmpty) {
              return const Center(child: Text('No sports available yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.sports.length,
              itemBuilder: (context, index) {
                final sport = state.sports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        sport.thumbnailUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.sports),
                      ),
                    ),
                    title: Text(sport.title),
                    subtitle: Text(
                      '${sport.chapterCount} chapters${sport.price > 0 ? ' • \$${(sport.price / 100).toStringAsFixed(2)}' : ' • Free'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/sport/${sport.id}'),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
