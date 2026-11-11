import 'package:get_it/get_it.dart';
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
import '../../features/sports/domain/usecases/get_laws.dart';
import '../../features/sports/domain/usecases/get_articles.dart';
import '../../features/sports/domain/usecases/get_article.dart';
import '../../features/sports/domain/usecases/get_decisions.dart';
import '../../features/sports/domain/usecases/search_articles.dart';
import '../../features/sports/data/repositories/sport_repository_impl.dart';
import '../../features/sports/data/datasources/sport_remote_datasource.dart';
import '../../features/sports/data/datasources/sport_local_datasource.dart';
import '../../features/sports/presentation/bloc/sports_bloc.dart';
import '../../features/sports/presentation/bloc/law_bloc.dart';
import '../../features/sports/presentation/bloc/law_detail_bloc.dart';
import '../../features/sports/presentation/bloc/article_bloc.dart';
import '../../features/sports/presentation/bloc/decision_bloc.dart';
import '../../features/purchases/domain/repositories/purchases_repository.dart';
import '../../features/purchases/domain/usecases/purchase_sport.dart';
import '../../features/purchases/domain/usecases/restore_purchases.dart';
import '../../features/purchases/domain/usecases/check_entitlement.dart';
import '../../features/purchases/data/repositories/purchase_repository_factory.dart';
import '../../features/purchases/data/datasources/revenuecat_datasource.dart';
import '../../features/purchases/presentation/bloc/purchases_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/rules/domain/repositories/rule_bookmark_repository.dart';
import '../../features/rules/data/repositories/rule_bookmark_repository_impl.dart';
import '../../features/rules/data/datasources/rule_bookmark_local_datasource.dart';
import '../../features/rules/domain/usecases/get_bookmarks.dart';
import '../../features/rules/domain/usecases/add_bookmark.dart';
import '../../features/rules/domain/usecases/remove_bookmark.dart';
import '../../features/rules/domain/usecases/is_bookmarked.dart';
import '../../features/rules/presentation/bloc/bookmark_bloc.dart';
import '../network/firebase_client.dart';
import '../storage/isar_storage.dart';
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
  getIt.registerSingleton<IsarStorage>(IsarStorage(isar));
  getIt.registerSingleton<SharedPreferencesStorage>(
    SharedPreferencesStorage(sharedPreferences),
  );

  // Data sources — TEMP (B): the auth and remote data sources accept
  // a [FirebaseClient] (not raw FirebaseAuth / FirebaseFirestore) so
  // they can run when Firebase is not initialised: every operation
  // checks [FirebaseClient.isInitialized] and returns null / throws a
  // controlled `StateError`/FirebaseException that the repos already
  // map to a `Failure`. Remove the workaround and switch the data
  // sources back to FirebaseAuth / FirebaseFirestore when the native
  // config (GoogleService-Info.plist / google-services.json) is in
  // place.
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(getIt<FirebaseClient>()),
  );
  getIt.registerLazySingleton<SportRemoteDataSource>(
    () => SportRemoteDataSourceImpl(getIt<FirebaseClient>()),
  );
  getIt.registerLazySingleton<SportLocalDataSource>(
    () => SportLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<RevenueCatDataSource>(
    () => RevenueCatDataSourceImpl(),
  );
  getIt.registerLazySingleton<RuleBookmarkLocalDataSource>(
    () => RuleBookmarkLocalDataSourceImpl(getIt<IsarStorage>()),
  );
  getIt.registerLazySingleton<RuleBookmarkRepository>(
    () => RuleBookmarkRepositoryImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SportRepository>(
    () => SportRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<PurchasesRepository>(
    () => buildPurchasesRepository(
      prefsStorage: getIt<SharedPreferencesStorage>(),
      dataSource: getIt<RevenueCatDataSource>(),
    ),
  );

  // BLoCs — Factories
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt()));
  getIt.registerFactory<SportsBloc>(() => SportsBloc(getIt()));
  getIt.registerFactory<LawBloc>(() => LawBloc(getIt()));
  getIt.registerFactory<LawDetailBloc>(() => LawDetailBloc(getIt()));
  getIt.registerFactory<ArticleBloc>(() => ArticleBloc(getIt()));
  getIt.registerFactory<DecisionBloc>(() => DecisionBloc(getIt()));
  getIt.registerFactory<PurchasesBloc>(() => PurchasesBloc(getIt(), getIt()));
  getIt.registerFactory<ProfileBloc>(() => ProfileBloc(getIt(), getIt()));
  getIt.registerFactory<BookmarkBloc>(() => BookmarkBloc(
        getBookmarks: getIt(),
        addBookmark: getIt(),
        removeBookmark: getIt(),
        isBookmarked: getIt(),
      ));

  // Auth Use Cases
  getIt.registerFactory(() => SignInWithEmailUseCase(getIt()));
  getIt.registerFactory(() => SignInWithGoogleUseCase(getIt()));
  getIt.registerFactory(() => SignInWithAppleUseCase(getIt()));
  getIt.registerFactory(() => SignOutUseCase(getIt()));

  // Sports Use Cases
  getIt.registerFactory(() => GetSportsUseCase(getIt()));
  getIt.registerFactory(() => GetLawsUseCase(getIt()));
  getIt.registerFactory(() => GetArticlesUseCase(getIt()));
  getIt.registerFactory(() => GetArticleUseCase(getIt()));
  getIt.registerFactory(() => GetDecisionsUseCase(getIt()));
  getIt.registerFactory(() => SearchArticlesUseCase(getIt()));

  // Purchases Use Cases
  getIt.registerFactory(() => PurchaseSportUseCase(getIt()));
  getIt.registerFactory(() => RestorePurchasesUseCase(getIt()));
  getIt.registerFactory(() => CheckEntitlementUseCase(getIt()));

  // Bookmark Use Cases
  getIt.registerFactory(() => GetBookmarks(getIt()));
  getIt.registerFactory(() => AddBookmark(getIt()));
  getIt.registerFactory(() => RemoveBookmark(getIt()));
  getIt.registerFactory(() => IsBookmarked(getIt()));
}
