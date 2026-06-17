import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../domain/repositories/purchases_repository.dart';

/// What a fake purchase should return for a given call.
enum FakePurchaseOutcome {
  /// Purchase completes and the sport becomes entitled.
  success,

  /// User cancelled the purchase dialog.
  cancelled,

  /// Store rejected the purchase (e.g. declined card).
  failed,

  /// Product ID not configured in the store.
  productNotFound,
}

/// Configurable behaviour for [FakePurchasesRepository].
@immutable
class FakePurchaseConfig {
  /// Outcome returned when no per-sport override matches.
  final FakePurchaseOutcome defaultOutcome;

  /// Per-sport outcome overrides. Key is the [sportId] used at the
  /// call site (not the product id). Example: `{'football':
  /// FakePurchaseOutcome.cancelled}` to test the cancel flow for a
  /// specific sport.
  final Map<String, FakePurchaseOutcome> overrides;

  /// Simulated latency before responding. `Duration.zero` for instant
  /// responses (useful for fast unit tests).
  final Duration latency;

  /// Sports marked as already entitled on construction. Useful to
  /// simulate "this user already owns X from a previous install".
  /// Persisted via [SharedPreferencesStorage] too.
  final Set<String> seedPurchased;

  const FakePurchaseConfig({
    this.defaultOutcome = FakePurchaseOutcome.success,
    this.overrides = const {},
    this.latency = const Duration(milliseconds: 250),
    this.seedPurchased = const {},
  });

  FakePurchaseOutcome outcomeFor(String sportId) =>
      overrides[sportId] ?? defaultOutcome;
}

/// In-memory + SharedPreferences implementation of [PurchasesRepository]
/// for development, testing and CI without real store credentials.
///
/// All calls return the same [Either] shape as [PurchasesRepositoryImpl],
/// so blocs and use cases work unchanged. Purchases are persisted to
/// [SharedPreferencesStorage] (matching the real implementation) so they
/// survive an app restart. Firestore is **not** touched — recording a
/// purchase in fake mode only updates local state.
///
/// Activate at build/run time with:
///   --dart-define=USE_FAKE_PURCHASES=true
class FakePurchasesRepository implements PurchasesRepository {
  final FakePurchaseConfig _config;
  final SharedPreferencesStorage _prefsStorage;
  final Set<String> _purchased;

  FakePurchasesRepository({
    FakePurchaseConfig config = const FakePurchaseConfig(),
    required SharedPreferencesStorage prefsStorage,
  })  : _config = config,
        _prefsStorage = prefsStorage,
        _purchased = <String>{
          ...prefsStorage.purchasedSports,
          ...config.seedPurchased,
        };

  Future<void> _simulateLatency() async {
    if (_config.latency > Duration.zero) {
      await Future.delayed(_config.latency);
    }
  }

  @override
  Future<Either<Failure, void>> purchaseSport(
    String sportId,
    String productId,
  ) async {
    await _simulateLatency();

    final outcome = _config.outcomeFor(sportId);
    switch (outcome) {
      case FakePurchaseOutcome.productNotFound:
        return const Left(PurchaseFailure(
          message: 'Product not found in store.',
          type: PurchaseFailureType.productNotFound,
        ));
      case FakePurchaseOutcome.cancelled:
        return const Left(PurchaseFailure(
          message: 'Purchase was cancelled.',
          type: PurchaseFailureType.purchaseCancelled,
        ));
      case FakePurchaseOutcome.failed:
        return const Left(PurchaseFailure(
          message: 'Purchase failed.',
          type: PurchaseFailureType.purchaseFailed,
        ));
      case FakePurchaseOutcome.success:
        return recordPurchase(sportId);
    }
  }

  @override
  Future<Either<Failure, List<String>>> restorePurchases() async {
    await _simulateLatency();
    final purchased = _purchased.toList()..sort();
    await _prefsStorage.setPurchasedSports(purchased);
    return Right(purchased);
  }

  @override
  Future<Either<Failure, bool>> hasEntitlement(String sportId) async {
    await _simulateLatency();
    return Right(_purchased.contains(sportId));
  }

  @override
  Future<Either<Failure, void>> recordPurchase(String sportId) async {
    final added = _purchased.add(sportId);
    if (added) {
      await _prefsStorage.addPurchasedSport(sportId);
    }
    return const Right(null);
  }
}
