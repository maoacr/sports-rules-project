part of 'decision_bloc.dart';

sealed class DecisionEvent extends Equatable {
  const DecisionEvent();
  @override
  List<Object?> get props => [];
}

class DecisionsLoadRequested extends DecisionEvent {
  final String lawId;
  const DecisionsLoadRequested(this.lawId);
  @override
  List<Object?> get props => [lawId];
}
