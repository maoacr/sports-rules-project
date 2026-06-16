import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

/// Abstract repository for RevenueCat purchases.
abstract class PurchasesRepository {
  /// Purchases a sport with the given product ID.
  Future<Either<Failure, void>> purchaseSport(String sportId, String productId);

  /// Restores previous purchases.
  Future<Either<Failure, List<String>>> restorePurchases();

  /// Checks if the user has entitlement for a sport.
  Future<Either<Failure, bool>> hasEntitlement(String sportId);

  /// Records a purchase in Firestore.
  Future<Either<Failure, void>> recordPurchase(String sportId);
}
