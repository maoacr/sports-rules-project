part of 'law_detail_bloc.dart';

sealed class LawDetailEvent extends Equatable {
  const LawDetailEvent();
  @override
  List<Object?> get props => [];
}

class LawDetailLoadRequested extends LawDetailEvent {
  final String sportId;
  final String lawId;
  const LawDetailLoadRequested({
    required this.sportId,
    required this.lawId,
  });
  @override
  List<Object?> get props => [sportId, lawId];
}
