import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/decision.dart';
import '../../domain/repositories/sport_repository.dart';

part 'decision_event.dart';
part 'decision_state.dart';

/// BLoC for IFAB "Decisions" attached to a law.
class DecisionBloc extends Bloc<DecisionEvent, DecisionState> {
  final SportRepository _sportRepository;

  DecisionBloc(this._sportRepository) : super(const DecisionsInitial()) {
    on<DecisionsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    DecisionsLoadRequested event,
    Emitter<DecisionState> emit,
  ) async {
    emit(const DecisionsLoading());
    final result = await _sportRepository.getDecisions(event.lawId);
    result.fold(
      (failure) => emit(DecisionsError(failure.message)),
      (decisions) => emit(DecisionsLoaded(decisions)),
    );
  }
}
