import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/law.dart';
import '../../domain/repositories/sport_repository.dart';

part 'article_event.dart';
part 'article_state.dart';

/// BLoC for the article list of a Law and the single-article reader
/// (replaces the legacy `RulesBloc`).
class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final SportRepository _sportRepository;

  ArticleBloc(this._sportRepository) : super(const ArticlesInitial()) {
    on<ArticlesLoadRequested>(_onArticlesLoadRequested);
    on<ArticleLoadRequested>(_onArticleLoadRequested);
  }

  Future<void> _onArticlesLoadRequested(
    ArticlesLoadRequested event,
    Emitter<ArticleState> emit,
  ) async {
    emit(const ArticlesLoading());
    final result = await _sportRepository.getArticles(
      event.sportId,
      event.lawId,
    );
    result.fold(
      (failure) => emit(ArticlesError(failure.message)),
      (articles) => emit(ArticlesLoaded(articles)),
    );
  }

  Future<void> _onArticleLoadRequested(
    ArticleLoadRequested event,
    Emitter<ArticleState> emit,
  ) async {
    emit(const ArticleDetailLoading());
    final result = await _sportRepository.getArticle(
      event.sportId,
      event.lawId,
      event.articleId,
    );
    result.fold(
      (failure) => emit(ArticleDetailError(failure.message)),
      (article) => emit(ArticleDetailLoaded(article)),
    );
  }
}
