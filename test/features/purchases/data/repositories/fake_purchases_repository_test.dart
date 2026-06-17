import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_rules_app/core/error/failures.dart';
import 'package:sports_rules_app/core/storage/shared_preferences_storage.dart';
import 'package:sports_rules_app/features/purchases/data/repositories/fake_purchases_repository.dart';

void main() {
  late SharedPreferencesStorage prefsStorage;
  late FakePurchasesRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    prefsStorage = SharedPreferencesStorage(prefs);
    repo = FakePurchasesRepository(
      prefsStorage: prefsStorage,
      config: const FakePurchaseConfig(latency: Duration.zero),
    );
  });

  const sport = 'football';
  const product = 'football_product';

  group('FakePurchasesRepository', () {
    group('purchaseSport', () {
      test('returns Right(null) on default success', () async {
        final result = await repo.purchaseSport(sport, product);
        expect(result, const Right<Failure, void>(null));
      });

      test('marks the sport as entitled after success', () async {
        await repo.purchaseSport(sport, product);
        final check = await repo.hasEntitlement(sport);
        expect(check, const Right<Failure, bool>(true));
      });

      test('persists the purchase to SharedPreferences', () async {
        await repo.purchaseSport(sport, product);
        // A fresh fake instance reading the same prefs should see the
        // purchase (proves the fake is persisted, not in-memory only).
        final fresh = FakePurchasesRepository(
          prefsStorage: prefsStorage,
          config: const FakePurchaseConfig(latency: Duration.zero),
        );
        final check = await fresh.hasEntitlement(sport);
        expect(check, const Right<Failure, bool>(true));
      });

      test('returns purchaseCancelled when outcome is cancelled', () async {
        repo = FakePurchasesRepository(
          prefsStorage: prefsStorage,
          config: const FakePurchaseConfig(
            defaultOutcome: FakePurchaseOutcome.cancelled,
            latency: Duration.zero,
          ),
        );
        final result = await repo.purchaseSport(sport, product);
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<PurchaseFailure>());
            expect(
              (failure as PurchaseFailure).type,
              PurchaseFailureType.purchaseCancelled,
            );
          },
          (_) => fail('expected Left'),
        );
      });

      test('returns purchaseFailed when outcome is failed', () async {
        repo = FakePurchasesRepository(
          prefsStorage: prefsStorage,
          config: const FakePurchaseConfig(
            defaultOutcome: FakePurchaseOutcome.failed,
            latency: Duration.zero,
          ),
        );
        final result = await repo.purchaseSport(sport, product);
        result.fold(
          (failure) {
            expect(
              (failure as PurchaseFailure).type,
              PurchaseFailureType.purchaseFailed,
            );
          },
          (_) => fail('expected Left'),
        );
      });

      test('returns productNotFound when outcome is productNotFound',
          () async {
        repo = FakePurchasesRepository(
          prefsStorage: prefsStorage,
          config: const FakePurchaseConfig(
            defaultOutcome: FakePurchaseOutcome.productNotFound,
            latency: Duration.zero,
          ),
        );
        final result = await repo.purchaseSport(sport, product);
        result.fold(
          (failure) {
            expect(
              (failure as PurchaseFailure).type,
              PurchaseFailureType.productNotFound,
            );
          },
          (_) => fail('expected Left'),
        );
      });

      test('does NOT mark entitled when purchase fails', () async {
        repo = FakePurchasesRepository(
          prefsStorage: prefsStorage,
          config: const FakePurchaseConfig(
            defaultOutcome: FakePurchaseOutcome.failed,
            latency: Duration.zero,
          ),
        );
        await repo.purchaseSport(sport, product);
        final check = await repo.hasEntitlement(sport);
        expect(check, const Right<Failure, bool>(false));
      });

      test('honours per-sport outcome override', () async {
        repo = FakePurchasesRepository(
          prefsStorage: prefsStorage,
          config: const FakePurchaseConfig(
            defaultOutcome: FakePurchaseOutcome.success,
            overrides: {
              'basketball': FakePurchaseOutcome.cancelled,
            },
            latency: Duration.zero,
          ),
        );
        final okResult = await repo.purchaseSport('football', product);
        final cancelResult = await repo.purchaseSport('basketball', product);
        expect(okResult.isRight(), isTrue);
        expect(cancelResult.isLeft(), isTrue);
        expect(
          (cancelResult.fold((f) => f, (_) => null) as PurchaseFailure).type,
          PurchaseFailureType.purchaseCancelled,
        );
      });
    });

    group('hasEntitlement', () {
      test('returns false for an unknown sport', () async {
        final result = await repo.hasEntitlement('tennis');
        expect(result, const Right<Failure, bool>(false));
      });

      test('returns true for a sport in seedPurchased', () async {
        repo = FakePurchasesRepository(
          prefsStorage: prefsStorage,
          config: const FakePurchaseConfig(
            seedPurchased: {'football'},
            latency: Duration.zero,
          ),
        );
        final result = await repo.hasEntitlement('football');
        expect(result, const Right<Failure, bool>(true));
      });
    });

    group('recordPurchase', () {
      test('marks the sport as entitled', () async {
        final result = await repo.recordPurchase(sport);
        expect(result, const Right<Failure, void>(null));
        final check = await repo.hasEntitlement(sport);
        expect(check, const Right<Failure, bool>(true));
      });

      test('is idempotent (no duplicate writes)', () async {
        await repo.recordPurchase(sport);
        await repo.recordPurchase(sport);
        // restorePurchases should still return a single entry.
        final restored = await repo.restorePurchases();
        restored.fold(
          (_) => fail('expected Right'),
          (list) => expect(list, ['football']),
        );
      });
    });

    group('restorePurchases', () {
      test('returns an empty list when nothing was purchased', () async {
        final result = await repo.restorePurchases();
        result.fold(
          (_) => fail('expected Right'),
          (list) => expect(list, isEmpty),
        );
      });

      test('returns all purchased sports sorted', () async {
        await repo.purchaseSport('zulu', 'zulu_product');
        await repo.purchaseSport('alpha', 'alpha_product');
        final result = await repo.restorePurchases();
        result.fold(
          (_) => fail('expected Right'),
          (list) => expect(list, ['alpha', 'zulu']),
        );
      });

      test('writes the current set back to SharedPreferences', () async {
        await repo.purchaseSport('football', product);
        // Wipe prefs to prove restorePurchases re-populates them.
        await prefsStorage.clear();
        expect(prefsStorage.purchasedSports, isEmpty);
        await repo.restorePurchases();
        expect(prefsStorage.purchasedSports, ['football']);
      });
    });
  });
}
