import 'package:flutter/foundation.dart';

import '../../../../core/storage/shared_preferences_storage.dart';
import '../../domain/repositories/purchases_repository.dart';
import '../datasources/revenuecat_datasource.dart';
import 'fake_purchases_repository.dart';
import 'purchases_repository_impl.dart';

/// Compile-time flag. Set `--dart-define=USE_FAKE_PURCHASES=true` at
/// build/run time to swap the real RevenueCat implementation for the
/// in-memory fake. Default `false`.
const bool kUseFakePurchases = bool.fromEnvironment(
  'USE_FAKE_PURCHASES',
  defaultValue: false,
);

/// Build the [PurchasesRepository] for the current build configuration.
///
/// In fake mode, the [RevenueCatDataSource] is **not** used, so the SDK
/// does not need to be configured and App Store / Play Console accounts
/// are not required. This is what enables the "develop and test the
/// full paywall flow without paid developer accounts" workflow.
PurchasesRepository buildPurchasesRepository({
  required SharedPreferencesStorage prefsStorage,
  required RevenueCatDataSource dataSource,
  FakePurchaseConfig fakeConfig = const FakePurchaseConfig(),
}) {
  if (kUseFakePurchases) {
    debugPrint('[purchases] using FakePurchasesRepository (in-memory)');
    return FakePurchasesRepository(
      prefsStorage: prefsStorage,
      config: fakeConfig,
    );
  }
  debugPrint('[purchases] using PurchasesRepositoryImpl (RevenueCat)');
  return PurchasesRepositoryImpl(dataSource, prefsStorage);
}
