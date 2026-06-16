import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/purchases_repository.dart';

/// Use case for restoring previous purchases.
class RestorePurchasesUseCase {
  final PurchasesRepository _repository;

  RestorePurchasesUseCase(this._repository);

  Future<Either<Failure, List<String>>> call() {
    return _repository.restorePurchases();
  }
}
