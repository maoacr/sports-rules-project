// Test helpers for widget tests.
//
// Widget tests that exercise pages need access to repositories and
// other dependencies through the `getIt` service locator. This file
// provides a single [setupTestGetIt] entry point that registers a
// configurable mock set, so each test file only has to override the
// mocks it cares about.

import 'package:isar_community/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_rules_app/core/di/injection.dart';
import 'package:sports_rules_app/core/network/firebase_client.dart';
import 'package:sports_rules_app/core/storage/shared_preferences_storage.dart';
import 'package:sports_rules_app/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:sports_rules_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sports_rules_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sports_rules_app/features/sports/data/datasources/sport_local_datasource.dart';
import 'package:sports_rules_app/features/sports/data/datasources/sport_remote_datasource.dart';
import 'package:sports_rules_app/features/sports/domain/repositories/sport_repository.dart';
import 'package:sports_rules_app/features/sports/presentation/bloc/chapter_bloc.dart';
import 'package:sports_rules_app/features/sports/presentation/bloc/rules_bloc.dart';
import 'package:sports_rules_app/features/sports/presentation/bloc/sports_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSportRepository extends Mock implements SportRepository {}

class MockFirebaseAuthDataSource extends Mock implements FirebaseAuthDataSource {}

class MockSportRemoteDataSource extends Mock implements SportRemoteDataSource {}

class MockSportLocalDataSource extends Mock implements SportLocalDataSource {}

class MockIsar extends Mock implements Isar {}

class MockFirebaseClient extends Mock implements FirebaseClient {}

/// Reset the global service locator and register the standard mock set
/// for widget tests. Returns the mocks so the caller can configure
/// stubs. Pass [authRepository] / [sportRepository] to override the
/// default mocks; pass [prefs] to seed shared preferences values
/// before the test starts.
Future<({AuthRepository auth, SportRepository sport, MockFirebaseAuthDataSource authDataSource, MockSportRemoteDataSource sportRemote, MockSportLocalDataSource sportLocal, SharedPreferencesStorage prefs})>
    setupTestGetIt({
  AuthRepository? authRepository,
  SportRepository? sportRepository,
  SharedPreferences? prefs,
}) async {
  await getIt.reset();

  final mockAuth = authRepository ?? MockAuthRepository();
  final mockSport = sportRepository ?? MockSportRepository();
  final mockAuthData = MockFirebaseAuthDataSource();
  final mockSportRemote = MockSportRemoteDataSource();
  final mockSportLocal = MockSportLocalDataSource();
  final mockIsar = MockIsar();
  final mockFirebaseClient = MockFirebaseClient();

  // SharedPreferences (defaults to in-memory if not provided).
  // Caller must call SharedPreferences.setMockInitialValues({}) once
  // at the test level — usually inside a setUpAll.
  final sharedPrefs = prefs ?? await SharedPreferences.getInstance();
  final prefsStorage = SharedPreferencesStorage(sharedPrefs);

  // External singletons
  getIt.registerSingleton<FirebaseClient>(mockFirebaseClient);
  getIt.registerSingleton<Isar>(mockIsar);
  getIt.registerSingleton<SharedPreferencesStorage>(prefsStorage);

  // Data sources — pages and blocs depend on these directly via getIt
  getIt.registerSingleton<FirebaseAuthDataSource>(mockAuthData);
  getIt.registerSingleton<SportRemoteDataSource>(mockSportRemote);
  getIt.registerSingleton<SportLocalDataSource>(mockSportLocal);

  // Repositories
  getIt.registerSingleton<AuthRepository>(mockAuth);
  getIt.registerSingleton<SportRepository>(mockSport);

  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt()));
  getIt.registerFactory<SportsBloc>(() => SportsBloc(getIt()));
  getIt.registerFactory<ChapterBloc>(() => ChapterBloc(getIt()));
  getIt.registerFactory<RulesBloc>(() => RulesBloc(getIt()));

  return (
    auth: mockAuth,
    sport: mockSport,
    authDataSource: mockAuthData,
    sportRemote: mockSportRemote,
    sportLocal: mockSportLocal,
    prefs: prefsStorage,
  );
}
