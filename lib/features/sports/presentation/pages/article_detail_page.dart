import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/deeplink/deeplink_handler.dart';
import '../../../rules/presentation/bloc/bookmark_bloc.dart';
import '../bloc/article_bloc.dart';
import '../bloc/decision_bloc.dart';
import '../bloc/law_detail_bloc.dart';

class ArticleDetailPage extends StatefulWidget {
  final String articleId;
  final String? sportId;
  final String? lawId;

  const ArticleDetailPage({
    super.key,
    required this.articleId,
    this.sportId,
    this.lawId,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final sportId = widget.sportId ?? '';
    final lawId = widget.lawId ?? '';
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LawDetailBloc(getIt())
            ..add(LawDetailLoadRequested(sportId: sportId, lawId: lawId)),
        ),
        BlocProvider(
          create: (_) => ArticleBloc(getIt())
            ..add(ArticleLoadRequested(
              sportId: sportId,
              lawId: lawId,
              articleId: widget.articleId,
            )),
        ),
        BlocProvider(
          create: (_) => DecisionBloc(getIt())
            ..add(DecisionsLoadRequested(lawId)),
        ),
        BlocProvider(
          create: (_) => BookmarkBloc(
            getBookmarks: getIt(),
            addBookmark: getIt(),
            removeBookmark: getIt(),
            isBookmarked: getIt(),
          )..add(BookmarkCheckRequested(widget.articleId)),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Article'),
          actions: [
            BlocBuilder<BookmarkBloc, BookmarkState>(
              builder: (context, bookmarkState) {
                final isMarked = bookmarkState is BookmarkCheckResult
                    ? bookmarkState.isBookmarked
                    : _isBookmarked;
                return IconButton(
                  icon: Icon(
                      isMarked ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: () => _toggleBookmark(context, isMarked),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _share(context),
            ),
          ],
        ),
        body: BlocListener<BookmarkBloc, BookmarkState>(
          listener: (context, state) {
            if (state is BookmarkCheckResult) {
              setState(() => _isBookmarked = state.isBookmarked);
            }
            if (state is BookmarkOperationSuccess) {
              setState(() => _isBookmarked = state.added);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.added ? 'Article bookmarked' : 'Bookmark removed',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: BlocBuilder<ArticleBloc, ArticleState>(
            builder: (context, state) {
              if (state is ArticleDetailLoading || state is ArticlesInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ArticleDetailError) {
                return Center(child: Text(state.message));
              } else if (state is ArticleDetailLoaded) {
                final article = state.article;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title.isNotEmpty
                            ? 'Art. ${article.number} — ${article.title}'
                            : 'Art. ${article.number}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(article.content),
                      if (article.crossRefs.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Ver también: ${article.crossRefs.join(", ")}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 24),
                      BlocBuilder<DecisionBloc, DecisionState>(
                        builder: (context, decisionState) {
                          if (decisionState is DecisionsLoaded &&
                              decisionState.decisions.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Decisiones IFAB',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 8),
                                ...decisionState.decisions.map(
                                  (d) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      '${d.number}. ${d.text}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _toggleBookmark(BuildContext context, bool currentlyBookmarked) {
    final lawState = context.read<LawDetailBloc>().state;
    final sportTitle = lawState is LawDetailLoaded
        ? lawState.law.sportTitle
        : widget.sportId ?? '';
    final lawTitle = lawState is LawDetailLoaded
        ? lawState.law.title
        : widget.lawId ?? '';

    if (currentlyBookmarked) {
      context.read<BookmarkBloc>().add(BookmarkRemoveRequested(widget.articleId));
    } else {
      context.read<BookmarkBloc>().add(
            BookmarkAddRequested(
              ruleId: widget.articleId,
              chapterId: widget.lawId ?? '',
              sportId: widget.sportId ?? '',
              ruleTitle: widget.articleId,
              chapterTitle: lawTitle,
              sportTitle: sportTitle,
            ),
          );
    }
  }

  void _share(BuildContext context) {
    final url = DeepLinkHandler.buildArticleUrl(
      widget.articleId,
      sportId: widget.sportId,
      lawId: widget.lawId,
    );
    Share.share(url, subject: 'Sports Rules');
  }
}
