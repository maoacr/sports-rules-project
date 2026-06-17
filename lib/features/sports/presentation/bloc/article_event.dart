part of 'article_bloc.dart';

sealed class ArticleEvent extends Equatable {
  const ArticleEvent();
  @override
  List<Object?> get props => [];
}

class ArticlesLoadRequested extends ArticleEvent {
  final String sportId;
  final String lawId;
  const ArticlesLoadRequested({required this.sportId, required this.lawId});
  @override
  List<Object?> get props => [sportId, lawId];
}

class ArticleLoadRequested extends ArticleEvent {
  final String sportId;
  final String lawId;
  final String articleId;
  const ArticleLoadRequested({
    required this.sportId,
    required this.lawId,
    required this.articleId,
  });
  @override
  List<Object?> get props => [sportId, lawId, articleId];
}
