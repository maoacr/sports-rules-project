part of 'law_bloc.dart';

sealed class LawState extends Equatable {
  const LawState();
  @override
  List<Object?> get props => [];
}

class LawsInitial extends LawState {
  const LawsInitial();
}

class LawsLoading extends LawState {
  const LawsLoading();
}

class LawsLoaded extends LawState {
  final List<Law> laws;
  const LawsLoaded(this.laws);
  @override
  List<Object?> get props => [laws];
}

class LawsError extends LawState {
  final String message;
  const LawsError(this.message);
  @override
  List<Object?> get props => [message];
}
