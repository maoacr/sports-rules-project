import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/law.dart';
import '../../domain/repositories/sport_repository.dart';

part 'law_event.dart';
part 'law_state.dart';

/// BLoC for the list of Laws within a sport (replaces the legacy
/// `ChapterBloc` — the IFAB calls them Laws, not chapters).
class LawBloc extends Bloc<LawEvent, LawState> {
  final SportRepository _sportRepository;

  LawBloc(this._sportRepository) : super(const LawsInitial()) {
    on<LawsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    LawsLoadRequested event,
    Emitter<LawState> emit,
  ) async {
    emit(const LawsLoading());
    final result = await _sportRepository.getLaws(event.sportId);
    result.fold(
      (failure) => emit(LawsError(failure.message)),
      (laws) => emit(LawsLoaded(laws)),
    );
  }
}
