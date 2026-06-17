part of 'bookmark_bloc.dart';

sealed class BookmarkEvent extends Equatable {
  const BookmarkEvent();
  @override
  List<Object?> get props => [];
}

class BookmarkListRequested extends BookmarkEvent {
  const BookmarkListRequested();
}

class BookmarkAddRequested extends BookmarkEvent {
  final String ruleId;
  final String chapterId;
  final String sportId;
  final String ruleTitle;
  final String chapterTitle;
  final String sportTitle;

  const BookmarkAddRequested({
    required this.ruleId,
    required this.chapterId,
    required this.sportId,
    required this.ruleTitle,
    required this.chapterTitle,
    required this.sportTitle,
  });

  @override
  List<Object?> get props => [ruleId, chapterId, sportId, ruleTitle, chapterTitle, sportTitle];
}

class BookmarkRemoveRequested extends BookmarkEvent {
  final String ruleId;
  const BookmarkRemoveRequested(this.ruleId);
  @override
  List<Object?> get props => [ruleId];
}

class BookmarkCheckRequested extends BookmarkEvent {
  final String ruleId;
  const BookmarkCheckRequested(this.ruleId);
  @override
  List<Object?> get props => [ruleId];
}
