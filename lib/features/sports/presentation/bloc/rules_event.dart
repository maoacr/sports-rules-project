part of 'rules_bloc.dart';

sealed class RulesEvent extends Equatable {
  const RulesEvent();
  @override
  List<Object?> get props => [];
}

class RulesLoadRequested extends RulesEvent {
  final String chapterId;
  const RulesLoadRequested(this.chapterId);
  @override
  List<Object?> get props => [chapterId];
}

class RuleLoadRequested extends RulesEvent {
  final String sportId;
  final String chapterId;
  final String ruleId;

  const RuleLoadRequested({
    required this.sportId,
    required this.chapterId,
    required this.ruleId,
  });

  @override
  List<Object?> get props => [sportId, chapterId, ruleId];
}
