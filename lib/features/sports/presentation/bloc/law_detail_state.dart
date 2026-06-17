part of 'law_detail_bloc.dart';

sealed class LawDetailState extends Equatable {
  const LawDetailState();
  @override
  List<Object?> get props => [];
}

class LawDetailInitial extends LawDetailState {
  const LawDetailInitial();
}

class LawDetailLoading extends LawDetailState {
  const LawDetailLoading();
}

class LawDetailLoaded extends LawDetailState {
  final Law law;
  const LawDetailLoaded({required this.law});
  @override
  List<Object?> get props => [law];
}

class LawDetailError extends LawDetailState {
  final String message;
  const LawDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
