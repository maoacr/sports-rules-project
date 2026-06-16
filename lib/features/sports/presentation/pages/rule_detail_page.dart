import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/deeplink/deeplink_handler.dart';
import '../bloc/rules_bloc.dart';

class RuleDetailPage extends StatelessWidget {
  final String ruleId;
  final String? sportId;
  final String? chapterId;

  const RuleDetailPage({
    super.key,
    required this.ruleId,
    this.sportId,
    this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RulesBloc(getIt())
        ..add(RuleLoadRequested(
          sportId: sportId ?? '',
          chapterId: chapterId ?? '',
          ruleId: ruleId,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rule'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _share(context),
            ),
          ],
        ),
        body: BlocBuilder<RulesBloc, RulesState>(
          builder: (context, state) {
            if (state is RulesLoading || state is RulesInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RulesError) {
              return Center(child: Text(state.message));
            } else if (state is RuleLoaded) {
              final rule = state.rule;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(rule.content),
                    if (rule.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...rule.imageUrls.map((url) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Image.network(url, fit: BoxFit.contain),
                      )),
                    ],
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _share(BuildContext context) {
    final url = DeepLinkHandler.buildRuleUrl(ruleId);
    Share.share(url, subject: 'Sports Rules');
  }
}
