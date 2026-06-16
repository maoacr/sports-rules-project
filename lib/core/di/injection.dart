import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar_community/isar.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_in_with_apple.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/sports/domain/repositories/sport_repository.dart';
import '../../features/sports/domain/usecases/get_sports.dart';
import '../../features/sports/domain/usecases/get_chapters.dart';
import '../../features/sports/domain/usecases/get_rules.dart';
import '../../features/sports/domain/usecases/get_rule.dart';
import '../../features/sports/data/repositories/sport_repository_impl.dart';
import '../../features/sports/data/datasources/sport_remote_datasource.dart';
import '../../features/sports/data/datasources/sport_local_datasource.dart';
import '../../features/sports/presentation/bloc/sports_bloc.dart';
import '../../features/sports/presentation/bloc/chapter_bloc.dart';
import '../../features/sports/presentation/bloc/rules_bloc.dart';
import '../../features/purchases/domain/repositories/purchases_repository.dart';
import '../../features/purchases/domain/usecases/purchase_sport.dart';
import '../../features/purchases/domain/usecases/restore_purchases.dart';
import '../../features/purchases/domain/usecases/check_entitlement.dart';
import '../../features/purchases/data/repositories/purchases_repository_impl.dart';
import '../../features/purchases/data/datasources/revenuecat_datasource.dart';
import '../../features/purchases/presentation/bloc/purchases_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../network/firebase_client.dart';
import '../storage/shared_preferences_storage.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies({
  required FirebaseClient firebaseClient,
  required Isar isar,
  required SharedPreferences sharedPreferences,
}) async {
  // External instances
  getIt.registerSingleton<FirebaseClient>(firebaseClient);
  getIt.registerSingleton<Isar>(isar);
  getIt.registerSingleton<SharedPreferencesStorage>(
    SharedPreferencesStorage(sharedPreferences),
  );

  // Firebase services
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  getIt.registerSingleton<FirebaseRemoteConfig>(FirebaseRemoteConfig.instance);

  // Data sources
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<SportRemoteDataSource>(
    () => SportRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<SportLocalDataSource>(
    () => SportLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<RevenueCatDataSource>(
    () => RevenueCatDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SportRepository>(
    () => SportRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<PurchasesRepository>(
    () => PurchasesRepositoryImpl(getIt(), getIt()),
  );

  // BLoCs — Factories
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt()));
  getIt.registerFactory<SportsBloc>(() => SportsBloc(getIt()));
  getIt.registerFactory<ChapterBloc>(() => ChapterBloc(getIt()));
  getIt.registerFactory<RulesBloc>(() => RulesBloc(getIt()));
  getIt.registerFactory<PurchasesBloc>(() => PurchasesBloc(getIt(), getIt()));
  getIt.registerFactory<ProfileBloc>(() => ProfileBloc(getIt(), getIt()));

  // Auth Use Cases
  getIt.registerFactory(() => SignInWithEmailUseCase(getIt()));
  getIt.registerFactory(() => SignInWithGoogleUseCase(getIt()));
  getIt.registerFactory(() => SignInWithAppleUseCase(getIt()));
  getIt.registerFactory(() => SignOutUseCase(getIt()));

  // Sports Use Cases
  getIt.registerFactory(() => GetSportsUseCase(getIt()));
  getIt.registerFactory(() => GetChaptersUseCase(getIt()));
  getIt.registerFactory(() => GetRulesUseCase(getIt()));
  getIt.registerFactory(() => GetRuleUseCase(getIt()));

  // Purchases Use Cases
  getIt.registerFactory(() => PurchaseSportUseCase(getIt()));
  getIt.registerFactory(() => RestorePurchasesUseCase(getIt()));
  getIt.registerFactory(() => CheckEntitlementUseCase(getIt()));
}
