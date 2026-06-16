import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/sport.dart';
import '../../domain/repositories/sport_repository.dart';

part 'rules_event.dart';
part 'rules_state.dart';

/// BLoC for rules list and single rule loading.
class RulesBloc extends Bloc<RulesEvent, RulesState> {
  final SportRepository _sportRepository;

  RulesBloc(this._sportRepository) : super(const RulesInitial()) {
    on<RulesLoadRequested>(_onRulesLoadRequested);
    on<RuleLoadRequested>(_onRuleLoadRequested);
  }

  Future<void> _onRulesLoadRequested(
    RulesLoadRequested event,
    Emitter<RulesState> emit,
  ) async {
    emit(const RulesLoading());
    final result = await _sportRepository.getRules(event.chapterId);
    result.fold(
      (failure) => emit(RulesError(failure.message)),
      (rules) => emit(RulesLoaded(rules)),
    );
  }

  Future<void> _onRuleLoadRequested(
    RuleLoadRequested event,
    Emitter<RulesState> emit,
  ) async {
    emit(const RulesLoading());
    final result = await _sportRepository.getRule(
      event.sportId,
      event.chapterId,
      event.ruleId,
    );
    result.fold(
      (failure) => emit(RulesError(failure.message)),
      (rule) => emit(RuleLoaded(rule)),
    );
  }
}
