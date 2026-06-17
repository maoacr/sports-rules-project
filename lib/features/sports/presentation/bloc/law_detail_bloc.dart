import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/law.dart';
import '../../domain/repositories/sport_repository.dart';

part 'law_detail_event.dart';
part 'law_detail_state.dart';

/// BLoC for loading a single Law's metadata (used by the Law detail
/// page header). Replaces the legacy `ChapterDetailBloc`.
class LawDetailBloc extends Bloc<LawDetailEvent, LawDetailState> {
  final SportRepository _sportRepository;

  LawDetailBloc(this._sportRepository) : super(const LawDetailInitial()) {
    on<LawDetailLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    LawDetailLoadRequested event,
    Emitter<LawDetailState> emit,
  ) async {
    emit(const LawDetailLoading());
    final result = await _sportRepository.getLaws(event.sportId);
    result.fold(
      (failure) => emit(LawDetailError(failure.message)),
      (laws) {
        final law = laws.where((l) => l.id == event.lawId).firstOrNull;
        if (law == null) {
          emit(const LawDetailError('Law not found'));
        } else {
          emit(LawDetailLoaded(law: law));
        }
      },
    );
  }
}
