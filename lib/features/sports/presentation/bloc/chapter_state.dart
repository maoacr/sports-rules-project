part of 'chapter_bloc.dart';

sealed class ChapterState extends Equatable {
  const ChapterState();
  @override
  List<Object?> get props => [];
}

class ChaptersInitial extends ChapterState {
  const ChaptersInitial();
}

class ChaptersLoading extends ChapterState {
  const ChaptersLoading();
}

class ChaptersLoaded extends ChapterState {
  final List<Chapter> chapters;
  const ChaptersLoaded(this.chapters);
  @override
  List<Object?> get props => [chapters];
}

class ChaptersError extends ChapterState {
  final String message;
  const ChaptersError(this.message);
  @override
  List<Object?> get props => [message];
}
