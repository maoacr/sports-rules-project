part of 'purchases_bloc.dart';

sealed class PurchasesState extends Equatable {
  const PurchasesState();
  @override
  List<Object?> get props => [];
}

class PurchasesInitial extends PurchasesState {
  const PurchasesInitial();
}

class PurchaseLoading extends PurchasesState {
  const PurchaseLoading();
}

class PurchaseSuccess extends PurchasesState {
  final String sportId;
  const PurchaseSuccess(this.sportId);
  @override
  List<Object?> get props => [sportId];
}

class PurchaseFailure extends PurchasesState {
  final String message;
  const PurchaseFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class EntitlementsLoaded extends PurchasesState {
  final List<String> sportIds;
  const EntitlementsLoaded(this.sportIds);
  @override
  List<Object?> get props => [sportIds];
}

class EntitlementChecked extends PurchasesState {
  final String sportId;
  final bool isActive;
  const EntitlementChecked(this.sportId, {required this.isActive});
  @override
  List<Object?> get props => [sportId, isActive];
}
