import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/sport.dart';
import '../../domain/repositories/sport_repository.dart';

part 'chapter_event.dart';
part 'chapter_state.dart';

/// BLoC for chapter list per sport.
class ChapterBloc extends Bloc<ChapterEvent, ChapterState> {
  final SportRepository _sportRepository;

  ChapterBloc(this._sportRepository) : super(const ChaptersInitial()) {
    on<ChaptersLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ChaptersLoadRequested event,
    Emitter<ChapterState> emit,
  ) async {
    emit(const ChaptersLoading());
    final result = await _sportRepository.getChapters(event.sportId);
    result.fold(
      (failure) => emit(ChaptersError(failure.message)),
      (chapters) => emit(ChaptersLoaded(chapters)),
    );
  }
}
