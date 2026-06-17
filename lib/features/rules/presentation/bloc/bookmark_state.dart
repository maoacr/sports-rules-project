part of 'bookmark_bloc.dart';

sealed class BookmarkState extends Equatable {
  const BookmarkState();
  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {
  const BookmarkInitial();
}

class BookmarkLoading extends BookmarkState {
  const BookmarkLoading();
}

class BookmarkListLoaded extends BookmarkState {
  final List<RuleBookmark> bookmarks;
  const BookmarkListLoaded(this.bookmarks);
  @override
  List<Object?> get props => [bookmarks];
}

class BookmarkCheckResult extends BookmarkState {
  final String ruleId;
  final bool isBookmarked;
  const BookmarkCheckResult({required this.ruleId, required this.isBookmarked});
  @override
  List<Object?> get props => [ruleId, isBookmarked];
}

class BookmarkError extends BookmarkState {
  final String message;
  const BookmarkError(this.message);
  @override
  List<Object?> get props => [message];
}

class BookmarkOperationSuccess extends BookmarkState {
  final String ruleId;
  final bool added;
  const BookmarkOperationSuccess({required this.ruleId, required this.added});
  @override
  List<Object?> get props => [ruleId, added];
}
