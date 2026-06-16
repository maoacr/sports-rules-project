import 'package:firebase_core/firebase_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Centralized Firebase client providing access to all Firebase services.
/// Initialized once in main.dart via Firebase.initializeApp().
class FirebaseClient {
  FirebaseApp? _app;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  FirebaseRemoteConfig? _remoteConfig;

  /// The Firebase app instance.
  FirebaseApp get app {
    _app ??= Firebase.app();
    return _app!;
  }

  /// Firebase Authentication instance.
  FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instanceFor(app: app);
    return _auth!;
  }

  /// Cloud Firestore instance.
  FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instanceFor(app: app);
    return _firestore!;
  }

  /// Firebase Storage instance.
  FirebaseStorage get storage {
    _storage ??= FirebaseStorage.instanceFor(app: app);
    return _storage!;
  }

  /// Firebase Remote Config instance.
  FirebaseRemoteConfig get remoteConfig {
    _remoteConfig ??= FirebaseRemoteConfig.instanceFor(app: app);
    return _remoteConfig!;
  }

  /// Stream of the current authentication state.
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// The currently signed-in user, or null if not authenticated.
  User? get currentUser => auth.currentUser;

  /// Convenience getter for Firestore settings (enables offline persistence).
  void enableFirestorePersistence() {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
