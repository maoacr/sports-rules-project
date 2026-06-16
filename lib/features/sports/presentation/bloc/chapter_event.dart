part of 'chapter_bloc.dart';

sealed class ChapterEvent extends Equatable {
  const ChapterEvent();
  @override
  List<Object?> get props => [];
}

class ChaptersLoadRequested extends ChapterEvent {
  final String sportId;
  const ChaptersLoadRequested(this.sportId);
  @override
  List<Object?> get props => [sportId];
}
