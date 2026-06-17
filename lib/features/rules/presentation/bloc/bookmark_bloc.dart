import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/rule_bookmark.dart';
import '../../domain/usecases/add_bookmark.dart';
import '../../domain/usecases/get_bookmarks.dart';
import '../../domain/usecases/is_bookmarked.dart';
import '../../domain/usecases/remove_bookmark.dart';

part 'bookmark_event.dart';
part 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final GetBookmarks _getBookmarks;
  final AddBookmark _addBookmark;
  final RemoveBookmark _removeBookmark;
  final IsBookmarked _isBookmarked;

  BookmarkBloc({
    required GetBookmarks getBookmarks,
    required AddBookmark addBookmark,
    required RemoveBookmark removeBookmark,
    required IsBookmarked isBookmarked,
  })  : _getBookmarks = getBookmarks,
        _addBookmark = addBookmark,
        _removeBookmark = removeBookmark,
        _isBookmarked = isBookmarked,
        super(const BookmarkInitial()) {
    on<BookmarkListRequested>(_onListRequested);
    on<BookmarkAddRequested>(_onAddRequested);
    on<BookmarkRemoveRequested>(_onRemoveRequested);
    on<BookmarkCheckRequested>(_onCheckRequested);
  }

  Future<void> _onListRequested(
    BookmarkListRequested event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(const BookmarkLoading());
    final result = await _getBookmarks();
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (bookmarks) => emit(BookmarkListLoaded(bookmarks)),
    );
  }

  Future<void> _onAddRequested(
    BookmarkAddRequested event,
    Emitter<BookmarkState> emit,
  ) async {
    final bookmark = RuleBookmark(
      id: '${event.ruleId}_${DateTime.now().millisecondsSinceEpoch}',
      ruleId: event.ruleId,
      chapterId: event.chapterId,
      sportId: event.sportId,
      ruleTitle: event.ruleTitle,
      chapterTitle: event.chapterTitle,
      sportTitle: event.sportTitle,
      createdAt: DateTime.now(),
    );
    final result = await _addBookmark(bookmark);
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (_) => emit(BookmarkOperationSuccess(ruleId: event.ruleId, added: true)),
    );
  }

  Future<void> _onRemoveRequested(
    BookmarkRemoveRequested event,
    Emitter<BookmarkState> emit,
  ) async {
    final result = await _removeBookmark(event.ruleId);
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (_) => emit(BookmarkOperationSuccess(ruleId: event.ruleId, added: false)),
    );
  }

  Future<void> _onCheckRequested(
    BookmarkCheckRequested event,
    Emitter<BookmarkState> emit,
  ) async {
    final result = await _isBookmarked(event.ruleId);
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (isBookmarked) => emit(BookmarkCheckResult(ruleId: event.ruleId, isBookmarked: isBookmarked)),
    );
  }
}
