import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../../purchases/presentation/bloc/purchases_bloc.dart';
import '../../../purchases/presentation/widgets/paywall_bottom_sheet.dart';
import '../bloc/chapter_bloc.dart';
import '../widgets/chapter_tile.dart';

class ChapterListPage extends StatelessWidget {
  final String sportId;

  const ChapterListPage({super.key, required this.sportId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChapterBloc(getIt())..add(ChaptersLoadRequested(sportId)),
      child: BlocProvider<PurchasesBloc>(
        create: (_) => PurchasesBloc(
          getIt(),
          getIt<SharedPreferencesStorage>(),
        ),
        child: Scaffold(
          appBar: AppBar(title: const Text('Chapters')),
          body: BlocBuilder<ChapterBloc, ChapterState>(
            builder: (context, state) {
              if (state is ChaptersLoading || state is ChaptersInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ChaptersError) {
                return Center(child: Text(state.message));
              } else if (state is ChaptersLoaded) {
                final prefs = getIt<SharedPreferencesStorage>();
                final purchased = prefs.purchasedSports;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = state.chapters[index];
                    final isLocked =
                        !chapter.isFree && !purchased.contains(sportId);
                    return ChapterTile(
                      chapter: chapter,
                      isLocked: isLocked,
                      onTap: isLocked
                          ? () => _showPaywall(
                                context,
                                chapterTitle: chapter.sportTitle,
                                // Price should come from the parent Sport; the
                                // current router only passes sportId, so we
                                // display the unlock message until that
                                // plumbs through.
                                priceCents: 0,
                              )
                          : () => context.push(
                                '/sports/$sportId/chapters/${chapter.id}',
                              ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showPaywall(
    BuildContext context, {
    required String chapterTitle,
    required int priceCents,
  }) {
    PaywallBottomSheet.show(
      context: context,
      sportId: sportId,
      sportTitle: chapterTitle,
      priceCents: priceCents,
      onPurchaseSuccess: (_) {
        // The bloc already updates SharedPreferences; trigger a rebuild
        // by dispatching a fresh load of chapters so the lock icons drop.
        context.read<ChapterBloc>().add(ChaptersLoadRequested(sportId));
      },
    );
  }
}
