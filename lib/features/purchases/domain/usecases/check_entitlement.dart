import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/purchases_repository.dart';

/// Use case for checking if user has entitlement for a sport.
class CheckEntitlementUseCase {
  final PurchasesRepository _repository;

  CheckEntitlementUseCase(this._repository);

  Future<Either<Failure, bool>> call(String sportId) {
    return _repository.hasEntitlement(sportId);
  }
}
