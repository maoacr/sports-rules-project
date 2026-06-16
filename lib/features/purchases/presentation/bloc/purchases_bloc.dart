import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../domain/repositories/purchases_repository.dart';

part 'purchases_event.dart';
part 'purchases_state.dart';

/// BLoC for handling RevenueCat purchases.
class PurchasesBloc extends Bloc<PurchasesEvent, PurchasesState> {
  final PurchasesRepository _purchasesRepository;
  final SharedPreferencesStorage _prefsStorage;

  PurchasesBloc(this._purchasesRepository, this._prefsStorage)
      : super(const PurchasesInitial()) {
    on<PurchaseRequested>(_onPurchaseRequested);
    on<RestoreRequested>(_onRestoreRequested);
    on<EntitlementCheckRequested>(_onEntitlementCheckRequested);
  }

  Future<void> _onPurchaseRequested(
    PurchaseRequested event,
    Emitter<PurchasesState> emit,
  ) async {
    emit(const PurchaseLoading());
    final result = await _purchasesRepository.purchaseSport(
      event.sportId,
      event.productId,
    );
    result.fold(
      (failure) => emit(PurchaseFailure(failure.message)),
      (_) => emit(PurchaseSuccess(event.sportId)),
    );
  }

  Future<void> _onRestoreRequested(
    RestoreRequested event,
    Emitter<PurchasesState> emit,
  ) async {
    emit(const PurchaseLoading());
    final result = await _purchasesRepository.restorePurchases();
    result.fold(
      (failure) => emit(PurchaseFailure(failure.message)),
      (purchased) {
        for (final sportId in purchased) {
          _prefsStorage.addPurchasedSport(sportId);
        }
        emit(EntitlementsLoaded(purchased));
      },
    );
  }

  Future<void> _onEntitlementCheckRequested(
    EntitlementCheckRequested event,
    Emitter<PurchasesState> emit,
  ) async {
    emit(const PurchaseLoading());
    final result = await _purchasesRepository.hasEntitlement(event.sportId);
    result.fold(
      (failure) => emit(PurchaseFailure(failure.message)),
      (hasAccess) {
        if (hasAccess) {
          // Keep local cache in sync with the server-side entitlement.
          _prefsStorage.addPurchasedSport(event.sportId);
          emit(EntitlementChecked(event.sportId, isActive: true));
        } else {
          emit(EntitlementChecked(event.sportId, isActive: false));
        }
      },
    );
  }
}
