part of 'purchases_bloc.dart';

sealed class PurchasesEvent extends Equatable {
  const PurchasesEvent();
  @override
  List<Object?> get props => [];
}

class PurchaseRequested extends PurchasesEvent {
  final String sportId;
  final String productId;
  const PurchaseRequested({required this.sportId, required this.productId});
  @override
  List<Object?> get props => [sportId, productId];
}

class RestoreRequested extends PurchasesEvent {
  const RestoreRequested();
}

class EntitlementCheckRequested extends PurchasesEvent {
  final String sportId;
  const EntitlementCheckRequested(this.sportId);
  @override
  List<Object?> get props => [sportId];
}
