import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sports_rules_app/core/error/failures.dart' hide PurchaseFailure;
import 'package:sports_rules_app/core/storage/shared_preferences_storage.dart';
import 'package:sports_rules_app/features/purchases/domain/repositories/purchases_repository.dart';
import 'package:sports_rules_app/features/purchases/presentation/bloc/purchases_bloc.dart';

class MockPurchasesRepository extends Mock implements PurchasesRepository {}

class MockSharedPreferencesStorage extends Mock implements SharedPreferencesStorage {}

void main() {
  late PurchasesBloc purchasesBloc;
  late MockPurchasesRepository mockPurchasesRepository;
  late MockSharedPreferencesStorage mockPrefsStorage;

  setUp(() {
    mockPurchasesRepository = MockPurchasesRepository();
    mockPrefsStorage = MockSharedPreferencesStorage();
    purchasesBloc = PurchasesBloc(mockPurchasesRepository, mockPrefsStorage);
  });

  tearDown(() {
    purchasesBloc.close();
  });

  const testSportId = 'fifa_football';
  const testProductId = 'fifa_football';
  const testFailure = ServerFailure(message: 'Purchase failed');

  group('PurchasesBloc', () {
    group('PurchaseRequested', () {
      blocTest<PurchasesBloc, PurchasesState>(
        'emits [PurchaseLoading, PurchaseSuccess] on successful purchase',
        build: () {
          when(() => mockPurchasesRepository.purchaseSport(any(), any()))
              .thenAnswer((_) async => const Right<Failure, void>(null));
          return purchasesBloc;
        },
        act: (bloc) => bloc.add(const PurchaseRequested(
          sportId: testSportId,
          productId: testProductId,
        )),
        expect: () => [
          const PurchaseLoading(),
          const PurchaseSuccess(testSportId),
        ],
        verify: (_) {
          verify(() => mockPurchasesRepository.purchaseSport(
            testSportId,
            testProductId,
          )).called(1);
        },
      );

      blocTest<PurchasesBloc, PurchasesState>(
        'emits [PurchaseLoading, PurchaseFailure] on purchase failure',
        build: () {
          when(() => mockPurchasesRepository.purchaseSport(any(), any()))
              .thenAnswer((_) async => const Left<Failure, void>(testFailure));
          return purchasesBloc;
        },
        act: (bloc) => bloc.add(const PurchaseRequested(
          sportId: testSportId,
          productId: testProductId,
        )),
        expect: () => [
          const PurchaseLoading(),
          const PurchaseFailure('Purchase failed'),
        ],
      );
    });

    group('RestoreRequested', () {
      blocTest<PurchasesBloc, PurchasesState>(
        'emits [PurchaseLoading, EntitlementsLoaded] on successful restore',
        build: () {
          when(() => mockPurchasesRepository.restorePurchases())
              .thenAnswer((_) async => const Right<Failure, List<String>>(['fifa_football', 'rugby']));
          when(() => mockPrefsStorage.addPurchasedSport(any()))
              .thenAnswer((_) async {});
          return purchasesBloc;
        },
        act: (bloc) => bloc.add(const RestoreRequested()),
        expect: () => [
          const PurchaseLoading(),
          const EntitlementsLoaded(['fifa_football', 'rugby']),
        ],
        verify: (_) {
          verify(() => mockPurchasesRepository.restorePurchases()).called(1);
          verify(() => mockPrefsStorage.addPurchasedSport('fifa_football')).called(1);
          verify(() => mockPrefsStorage.addPurchasedSport('rugby')).called(1);
        },
      );

      blocTest<PurchasesBloc, PurchasesState>(
        'emits [PurchaseLoading, PurchaseFailure] on restore failure',
        build: () {
          when(() => mockPurchasesRepository.restorePurchases())
              .thenAnswer((_) async => const Left<Failure, List<String>>(testFailure));
          return purchasesBloc;
        },
        act: (bloc) => bloc.add(const RestoreRequested()),
        expect: () => [
          const PurchaseLoading(),
          const PurchaseFailure('Purchase failed'),
        ],
      );
    });

    group('EntitlementCheckRequested', () {
      blocTest<PurchasesBloc, PurchasesState>(
        'emits [PurchaseLoading, EntitlementChecked(isActive: true)] when entitled',
        build: () {
          when(() => mockPurchasesRepository.hasEntitlement(any()))
              .thenAnswer((_) async => const Right<Failure, bool>(true));
          when(() => mockPrefsStorage.addPurchasedSport(any()))
              .thenAnswer((_) async {});
          return purchasesBloc;
        },
        act: (bloc) => bloc.add(EntitlementCheckRequested(testSportId)),
        expect: () => [
          const PurchaseLoading(),
          EntitlementChecked(testSportId, isActive: true),
        ],
        verify: (_) {
          verify(() => mockPurchasesRepository.hasEntitlement(testSportId)).called(1);
          verify(() => mockPrefsStorage.addPurchasedSport(testSportId)).called(1);
        },
      );

      blocTest<PurchasesBloc, PurchasesState>(
        'emits [PurchaseLoading, EntitlementChecked(isActive: false)] when not entitled',
        build: () {
          when(() => mockPurchasesRepository.hasEntitlement(any()))
              .thenAnswer((_) async => const Right<Failure, bool>(false));
          return purchasesBloc;
        },
        act: (bloc) => bloc.add(EntitlementCheckRequested(testSportId)),
        expect: () => [
          const PurchaseLoading(),
          EntitlementChecked(testSportId, isActive: false),
        ],
        verify: (_) {
          verify(() => mockPurchasesRepository.hasEntitlement(testSportId)).called(1);
          verifyNever(() => mockPrefsStorage.addPurchasedSport(any()));
        },
      );

      blocTest<PurchasesBloc, PurchasesState>(
        'emits [PurchaseLoading, PurchaseFailure] on check failure',
        build: () {
          when(() => mockPurchasesRepository.hasEntitlement(any()))
              .thenAnswer((_) async => const Left<Failure, bool>(testFailure));
          return purchasesBloc;
        },
        act: (bloc) => bloc.add(EntitlementCheckRequested(testSportId)),
        expect: () => [
          const PurchaseLoading(),
          const PurchaseFailure('Purchase failed'),
        ],
      );
    });
  });
}
