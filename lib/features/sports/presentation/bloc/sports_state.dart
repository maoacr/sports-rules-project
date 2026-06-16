part of 'sports_bloc.dart';

sealed class SportsState extends Equatable {
  const SportsState();
  @override
  List<Object?> get props => [];
}

class SportsInitial extends SportsState {
  const SportsInitial();
}

class SportsLoading extends SportsState {
  const SportsLoading();
}

class SportsLoaded extends SportsState {
  final List<Sport> sports;
  const SportsLoaded(this.sports);
  @override
  List<Object?> get props => [sports];
}

class SportsError extends SportsState {
  final String message;
  const SportsError(this.message);
  @override
  List<Object?> get props => [message];
}
