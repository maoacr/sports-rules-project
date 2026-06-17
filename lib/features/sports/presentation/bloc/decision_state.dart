part of 'decision_bloc.dart';

sealed class DecisionState extends Equatable {
  const DecisionState();
  @override
  List<Object?> get props => [];
}

class DecisionsInitial extends DecisionState {
  const DecisionsInitial();
}

class DecisionsLoading extends DecisionState {
  const DecisionsLoading();
}

class DecisionsLoaded extends DecisionState {
  final List<Decision> decisions;
  const DecisionsLoaded(this.decisions);
  @override
  List<Object?> get props => [decisions];
}

class DecisionsError extends DecisionState {
  final String message;
  const DecisionsError(this.message);
  @override
  List<Object?> get props => [message];
}
