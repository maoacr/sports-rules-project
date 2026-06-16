import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/sport.dart';
import '../../domain/repositories/sport_repository.dart';

part 'sports_event.dart';
part 'sports_state.dart';

/// BLoC for the sport list on HomePage.
class SportsBloc extends Bloc<SportsEvent, SportsState> {
  final SportRepository _sportRepository;

  SportsBloc(this._sportRepository) : super(const SportsInitial()) {
    on<SportsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    SportsLoadRequested event,
    Emitter<SportsState> emit,
  ) async {
    emit(const SportsLoading());
    final result = await _sportRepository.getSports();
    result.fold(
      (failure) => emit(SportsError(failure.message)),
      (sports) => emit(SportsLoaded(sports)),
    );
  }
}
