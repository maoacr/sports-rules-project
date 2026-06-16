part of 'sports_bloc.dart';

sealed class SportsEvent extends Equatable {
  const SportsEvent();
  @override
  List<Object?> get props => [];
}

class SportsLoadRequested extends SportsEvent {
  const SportsLoadRequested();
}
