import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show PlatformException;
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_mappers.dart';
import '../../../../core/storage/shared_preferences_storage.dart';
import '../../domain/repositories/purchases_repository.dart';
import '../datasources/revenuecat_datasource.dart';

class PurchasesRepositoryImpl implements PurchasesRepository {
  final RevenueCatDataSource _revenueCatDataSource;
  final SharedPreferencesStorage _prefsStorage;

  PurchasesRepositoryImpl(this._revenueCatDataSource, this._prefsStorage);

  @override
  Future<Either<Failure, void>> purchaseSport(
    String sportId,
    String productId,
  ) async {
    try {
      // Resolve the StoreProduct for the requested productId.
      final List<StoreProduct> products = await _revenueCatDataSource
          .getProducts([productId]);
      if (products.isEmpty) {
        return const Left(PurchaseFailure(
          message: 'Product not found in store.',
          type: PurchaseFailureType.productNotFound,
        ));
      }

      // Perform the purchase. Throws PlatformException on failure.
      // Use PurchasesErrorHelper.getErrorCode to detect cancellation.
      try {
        await _revenueCatDataSource.purchaseStoreProduct(products.first);
      } on PlatformException catch (e) {
        final errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          return const Left(PurchaseFailure(
            message: 'Purchase was cancelled.',
            type: PurchaseFailureType.purchaseCancelled,
          ));
        }
        return Left(PurchaseFailure(
          message: e.message ?? 'Purchase failed.',
          type: PurchaseFailureType.purchaseFailed,
        ));
      }

      // Persist purchase locally and remotely.
      await recordPurchase(sportId);
      return const Right(null);
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, List<String>>> restorePurchases() async {
    try {
      await _revenueCatDataSource.restorePurchases();
      final entitlements = await _revenueCatDataSource.getEntitlements();
      final purchased = entitlements
          .where((e) => e.isActive)
          .map((e) => e.identifier)
          .toList();
      // Cache locally for fast checks.
      await _prefsStorage.setPurchasedSports(purchased);
      return Right(purchased);
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> hasEntitlement(String sportId) async {
    try {
      final isActive = await _revenueCatDataSource.isActive(sportId);
      return Right(isActive);
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }

  @override
  Future<Either<Failure, void>> recordPurchase(String sportId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left(AuthFailure(
          message: 'Not authenticated',
          type: AuthFailureType.unknown,
        ));
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'purchases': FieldValue.arrayUnion([sportId]),
      });
      await _prefsStorage.addPurchasedSport(sportId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(mapFirestoreException(e));
    } catch (e) {
      return Left(mapGenericException(e));
    }
  }
}
