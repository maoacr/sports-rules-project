import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Centralized Firebase client providing access to all Firebase services.
///
/// Initialized once in main.dart via Firebase.initializeApp().
/// When the native config is missing (local dev), getters are tolerant
/// and return `null` / throw a `StateError` only when actually consumed
/// — never during DI registration. Consumers must check
/// [isInitialized] or wrap calls in try/catch.
class FirebaseClient {
  /// Set by `main()` after a successful `Firebase.initializeApp()`.
  /// Read this BEFORE calling any Firebase service to decide whether
  /// to use the remote backend or a local/mock fallback.
  static bool firebaseReady = false;

  /// Convenience static check.
  static bool get isInitialized => firebaseReady;

  FirebaseApp? _app;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  FirebaseRemoteConfig? _remoteConfig;

  /// The Firebase app instance. Throws [StateError] if Firebase was
  /// not initialized (no native config present).
  FirebaseApp get app {
    _app ??= Firebase.app();
    return _app!;
  }

  /// True if the underlying Firebase app exists. False when
  /// `initializeApp()` failed and we are running in local-dev mode.
  bool get hasApp => _app != null;

  /// Firebase Authentication instance. Returns null when Firebase is
  /// not initialized — callers must handle that case.
  FirebaseAuth? tryAuth() {
    if (!firebaseReady) return null;
    return _auth ??= FirebaseAuth.instanceFor(app: app);
  }

  /// Cloud Firestore instance. Returns null when Firebase is not
  /// initialized.
  FirebaseFirestore? tryFirestore() {
    if (!firebaseReady) return null;
    return _firestore ??= FirebaseFirestore.instanceFor(app: app);
  }

  /// Firebase Storage instance. Returns null when Firebase is not
  /// initialized.
  FirebaseStorage? tryStorage() {
    if (!firebaseReady) return null;
    return _storage ??= FirebaseStorage.instanceFor(app: app);
  }

  /// Firebase Remote Config instance. Returns null when Firebase is
  /// not initialized.
  FirebaseRemoteConfig? tryRemoteConfig() {
    if (!firebaseReady) return null;
    return _remoteConfig ??= FirebaseRemoteConfig.instanceFor(app: app);
  }

  // --- Non-nullable accessors (kept for call sites already
  // null-safe or wrapped). Prefer the `try*` variants in new code. ---

  /// Firebase Authentication instance.
  FirebaseAuth get auth {
    final a = tryAuth();
    if (a == null) {
      throw StateError('Firebase not initialized. Check FirebaseClient.isInitialized.');
    }
    return a;
  }

  /// Cloud Firestore instance.
  FirebaseFirestore get firestore {
    final f = tryFirestore();
    if (f == null) {
      throw StateError('Firebase not initialized. Check FirebaseClient.isInitialized.');
    }
    return f;
  }

  /// Firebase Storage instance.
  FirebaseStorage get storage {
    final s = tryStorage();
    if (s == null) {
      throw StateError('Firebase not initialized. Check FirebaseClient.isInitialized.');
    }
    return s;
  }

  /// Firebase Remote Config instance.
  FirebaseRemoteConfig get remoteConfig {
    final r = tryRemoteConfig();
    if (r == null) {
      throw StateError('Firebase not initialized. Check FirebaseClient.isInitialized.');
    }
    return r;
  }

  /// Stream of the current authentication state. Emits `null`
  /// immediately if Firebase is not initialized (treats the user as
  /// signed out, which is the safe local-dev default).
  Stream<User?> get authStateChanges {
    final a = tryAuth();
    if (a == null) {
      return Stream<User?>.value(null);
    }
    return a.authStateChanges();
  }

  /// The currently signed-in user, or null if not authenticated or
  /// if Firebase is not initialized.
  User? get currentUser => tryAuth()?.currentUser;

  /// Convenience getter for Firestore settings (enables offline persistence).
  void enableFirestorePersistence() {
    final f = tryFirestore();
    if (f == null) return;
    f.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
