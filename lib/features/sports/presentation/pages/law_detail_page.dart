import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../../rules/presentation/bloc/bookmark_bloc.dart';
import '../bloc/article_bloc.dart';
import '../bloc/law_detail_bloc.dart';
import '../widgets/article_tile.dart';

class LawDetailPage extends StatelessWidget {
  final String sportId;
  final String lawId;

  const LawDetailPage({
    super.key,
    required this.sportId,
    required this.lawId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LawDetailBloc(getIt())
            ..add(LawDetailLoadRequested(sportId: sportId, lawId: lawId)),
        ),
        BlocProvider(
          create: (_) => ArticleBloc(getIt())
            ..add(ArticlesLoadRequested(sportId: sportId, lawId: lawId)),
        ),
        BlocProvider(
          create: (_) => BookmarkBloc(
            getBookmarks: getIt(),
            addBookmark: getIt(),
            removeBookmark: getIt(),
            isBookmarked: getIt(),
          )..add(const BookmarkListRequested()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Law')),
        body: BlocBuilder<LawDetailBloc, LawDetailState>(
          builder: (context, lawState) {
            if (lawState is LawDetailLoading ||
                lawState is LawDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (lawState is LawDetailError) {
              return Center(child: Text(lawState.message));
            }
            if (lawState is LawDetailLoaded) {
              final law = lawState.law;
              final prefs = getIt<SharedPreferencesStorage>();
              final purchased = prefs.purchasedSports;
              final isLocked = !law.isFree && !purchased.contains(sportId);

              if (isLocked) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('This law is locked'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Go back'),
                      ),
                    ],
                  ),
                );
              }

              return BlocBuilder<ArticleBloc, ArticleState>(
                builder: (context, articleState) {
                  if (articleState is ArticlesLoading ||
                      articleState is ArticlesInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (articleState is ArticlesError) {
                    return Center(child: Text(articleState.message));
                  }
                  if (articleState is ArticlesLoaded) {
                    if (articleState.articles.isEmpty) {
                      return const Center(
                          child: Text('No articles in this law.'));
                    }
                    return BlocBuilder<BookmarkBloc, BookmarkState>(
                      builder: (context, bookmarkState) {
                        final bookmarkedIds = bookmarkState
                                is BookmarkListLoaded
                            ? bookmarkState.bookmarks
                                .map((b) => b.ruleId)
                                .toSet()
                            : <String>{};
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: articleState.articles.length,
                          itemBuilder: (context, index) {
                            final article = articleState.articles[index];
                            final isBookmarked =
                                bookmarkedIds.contains(article.id);
                            return ArticleTile(
                              article: article,
                              onTap: () => context.push(
                                '/sports/$sportId/laws/$lawId/articles/${article.id}',
                              ),
                            );
                            // Note: bookmark visualisation lives inside
                            // ArticleTile or in a follow-up; the legacy
                            // `isBookmarked` flag here is reserved for a
                            // future visual cue.
                            // ignore: dead_code
                            if (isBookmarked) {}
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
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
