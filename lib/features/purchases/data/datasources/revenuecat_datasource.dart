import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/entities/entitlement.dart';

/// Data source for RevenueCat SDK operations.
abstract class RevenueCatDataSource {
  Future<void> configure(String apiKey);
  Future<List<Entitlement>> getEntitlements();
  Future<bool> isActive(String entitlementId);

  /// Fetches [StoreProduct]s for the given [productIds]. Use this before
  /// [purchaseStoreProduct] to obtain the object RevenueCat requires.
  Future<List<StoreProduct>> getProducts(List<String> productIds);

  /// Performs a purchase for the given [StoreProduct].
  /// Returns the updated [CustomerInfo] on success.
  Future<CustomerInfo> purchaseStoreProduct(StoreProduct storeProduct);

  /// Restores previous purchases.
  Future<CustomerInfo> restorePurchases();
}

class RevenueCatDataSourceImpl implements RevenueCatDataSource {
  @override
  Future<void> configure(String apiKey) async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  @override
  Future<List<Entitlement>> getEntitlements() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all.entries.map((e) => Entitlement(
        identifier: e.key,
        isActive: e.value.isActive,
        productId: e.value.productIdentifier,
        expiresDate: e.value.expirationDate,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> isActive(String entitlementId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];
      return entitlement?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<StoreProduct>> getProducts(List<String> productIds) async {
    return Purchases.getProducts(productIds);
  }

  @override
  Future<CustomerInfo> purchaseStoreProduct(StoreProduct storeProduct) async {
    return Purchases.purchaseStoreProduct(storeProduct);
  }

  @override
  Future<CustomerInfo> restorePurchases() async {
    return Purchases.restorePurchases();
  }
}
