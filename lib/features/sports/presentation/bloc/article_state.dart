part of 'article_bloc.dart';

sealed class ArticleState extends Equatable {
  const ArticleState();
  @override
  List<Object?> get props => [];
}

class ArticlesInitial extends ArticleState {
  const ArticlesInitial();
}

class ArticlesLoading extends ArticleState {
  const ArticlesLoading();
}

class ArticlesLoaded extends ArticleState {
  final List<Article> articles;
  const ArticlesLoaded(this.articles);
  @override
  List<Object?> get props => [articles];
}

class ArticleDetailLoading extends ArticleState {
  const ArticleDetailLoading();
}

class ArticleDetailLoaded extends ArticleState {
  final Article article;
  const ArticleDetailLoaded(this.article);
  @override
  List<Object?> get props => [article];
}

class ArticleDetailError extends ArticleState {
  final String message;
  const ArticleDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class ArticlesError extends ArticleState {
  final String message;
  const ArticlesError(this.message);
  @override
  List<Object?> get props => [message];
}
