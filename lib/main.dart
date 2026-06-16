import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/network/firebase_client.dart';
import 'core/storage/isar_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [CachedSportSchema, CachedChapterSchema, CachedRuleSchema],
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
