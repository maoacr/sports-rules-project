import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/network/firebase_client.dart';
import 'core/storage/isar_storage.dart';

/// Compile-time flag. Set `--dart-define=USE_FIRESTORE_EMULATOR=true` at
/// build/run time to point the app at the local Firestore emulator
/// (default `localhost:8080`).
const bool kUseFirestoreEmulator = bool.fromEnvironment(
  'USE_FIRESTORE_EMULATOR',
  defaultValue: false,
);

const String kFirestoreEmulatorHost = String.fromEnvironment(
  'FIRESTORE_EMULATOR_HOST',
  defaultValue: 'localhost',
);

const int kFirestoreEmulatorPort = int.fromEnvironment(
  'FIRESTORE_EMULATOR_PORT',
  defaultValue: 8080,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Point Firestore at the local emulator when the flag is set.
  // The emulator must be running on the configured host/port
  // (run `scripts/start-emulator.sh`).
  if (kUseFirestoreEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator(
      kFirestoreEmulatorHost,
      kFirestoreEmulatorPort,
    );
  }

  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [CachedSportSchema, CachedChapterSchema, CachedRuleSchema, CachedBookmarkSchema],
    directory: dir.path,
  );

  // Initialize SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();

  // Setup dependency injection
  await setupDependencies(
    firebaseClient: FirebaseClient(),
    isar: isar,
    sharedPreferences: sharedPrefs,
  );

  runApp(const SportsRulesApp());
}
