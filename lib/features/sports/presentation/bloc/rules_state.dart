part of 'rules_bloc.dart';

sealed class RulesState extends Equatable {
  const RulesState();
  @override
  List<Object?> get props => [];
}

class RulesInitial extends RulesState {
  const RulesInitial();
}

class RulesLoading extends RulesState {
  const RulesLoading();
}

class RulesLoaded extends RulesState {
  final List<Rule> rules;
  const RulesLoaded(this.rules);
  @override
  List<Object?> get props => [rules];
}

class RuleLoaded extends RulesState {
  final Rule rule;
  const RuleLoaded(this.rule);
  @override
  List<Object?> get props => [rule];
}

class RulesError extends RulesState {
  final String message;
  const RulesError(this.message);
  @override
  List<Object?> get props => [message];
}
