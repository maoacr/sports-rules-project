part of 'law_bloc.dart';

sealed class LawEvent extends Equatable {
  const LawEvent();
  @override
  List<Object?> get props => [];
}

class LawsLoadRequested extends LawEvent {
  final String sportId;
  const LawsLoadRequested(this.sportId);
  @override
  List<Object?> get props => [sportId];
}
