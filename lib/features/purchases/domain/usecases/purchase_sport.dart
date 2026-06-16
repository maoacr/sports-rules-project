import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/purchases_repository.dart';

/// Use case for purchasing a sport.
class PurchaseSportUseCase {
  final PurchasesRepository _repository;

  PurchaseSportUseCase(this._repository);

  Future<Either<Failure, void>> call(String sportId, String productId) {
    return _repository.purchaseSport(sportId, productId);
  }
}
