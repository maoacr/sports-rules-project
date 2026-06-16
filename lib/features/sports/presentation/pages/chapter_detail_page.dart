import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../bloc/rules_bloc.dart';

class ChapterDetailPage extends StatelessWidget {
  final String sportId;
  final String chapterId;

  const ChapterDetailPage({
    super.key,
    required this.sportId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RulesBloc(getIt())..add(RulesLoadRequested(chapterId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Chapter')),
        body: BlocBuilder<RulesBloc, RulesState>(
          builder: (context, state) {
            if (state is RulesLoading || state is RulesInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RulesError) {
              return Center(child: Text(state.message));
            } else if (state is RulesLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.rules.length,
                itemBuilder: (context, index) {
                  final rule = state.rules[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(rule.title),
                      subtitle: Text(
                        rule.content.length > 80
                            ? '${rule.content.substring(0, 80)}...'
                            : rule.content,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/sports/$sportId/chapters/$chapterId/rules/${rule.id}'),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
