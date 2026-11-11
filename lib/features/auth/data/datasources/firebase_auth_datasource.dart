import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import 'dart:math';

import '../../../../core/network/firebase_client.dart';

/// Data source for Firebase Authentication operations.
abstract class FirebaseAuthDataSource {
  Future<User?> getCurrentUser();
  Future<User> signInWithEmail(String email, String password);
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();
  Future<void> signOut();
  Stream<User?> authStateChanges();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseClient _client;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSourceImpl(this._client, [GoogleSignIn? googleSignIn])
      : _googleSignIn = googleSignIn ?? GoogleSignIn();

  FirebaseAuth? get _auth => _client.tryAuth();

  @override
  Future<User?> getCurrentUser() async => _auth?.currentUser;

  @override
  Future<User> signInWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'firebase-not-initialized',
        message: 'Firebase is not initialised. Add the native config first.',
      );
    }
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  @override
  Future<User> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'firebase-not-initialized',
        message: 'Firebase is not initialised. Add the native config first.',
      );
    }
    // Trigger the Google Sign-In flow.
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User cancelled the sign-in flow.
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign-in was cancelled by the user.',
      );
    }

    // Obtain the auth details from the Google sign-in.
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // idToken is the JWT we send to Firebase.
    final String? idToken = googleAuth.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Google sign-in did not return an idToken.',
      );
    }

    // Create a new credential using the idToken.
    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );

    // Sign in to Firebase with the credential.
    final userCredential = await auth.signInWithCredential(credential);
    return userCredential.user!;
  }

  @override
  Future<User> signInWithApple() async {
    final auth = _auth;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'firebase-not-initialized',
        message: 'Firebase is not initialised. Add the native config first.',
      );
    }
    // SignInWithApple is only available on iOS, macOS, Android (via web),
    // and Web. Calling on other platforms throws SignInWithAppleNotSupportedException.
    if (!Platform.isIOS && !Platform.isMacOS && !Platform.isAndroid) {
      throw FirebaseAuthException(
        code: 'apple-sign-in-unsupported-platform',
        message: 'Sign in with Apple is not supported on this platform.',
      );
    }

    // Generate a cryptographically random nonce and its SHA-256 hash.
    // The raw nonce is sent to Apple and the SHA-256 hash is sent to Firebase
    // so Firebase can validate the token has not been tampered with.
    final String rawNonce = _generateNonce();
    final String hashedNonce = _sha256ofString(rawNonce);

    // Request credential from Apple.
    final AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    // The identityToken is the JWT we send to Firebase.
    final String? identityToken = appleCredential.identityToken;
    if (identityToken == null) {
      throw FirebaseAuthException(
        code: 'missing-identity-token',
        message: 'Apple sign-in did not return an identityToken.',
      );
    }

    // Build an OAuthCredential for the 'apple.com' provider. The raw nonce
    // (NOT the hash) must be passed here — Firebase hashes it server-side and
    // compares against the hash that was embedded in the JWT.
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: identityToken,
      rawNonce: rawNonce,
    );

    final userCredential = await auth.signInWithCredential(oauthCredential);

    // On first sign-in only, Apple provides the user's name. Persist it
    // into the FirebaseUser displayName so subsequent launches still show it.
    final user = userCredential.user;
    if (user != null && (user.displayName == null || user.displayName!.isEmpty)) {
      final givenName = appleCredential.givenName;
      final familyName = appleCredential.familyName;
      if (givenName != null || familyName != null) {
        final fullName = [givenName, familyName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        if (fullName.isNotEmpty) {
          await user.updateDisplayName(fullName);
        }
      }
    }

    return user!;
  }

  @override
  Future<void> signOut() async {
    // Best effort: clear Google session if one is active.
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Ignore: not all platforms support Google sign-in cleanup here.
    }
    await _auth?.signOut();
  }

  @override
  Stream<User?> authStateChanges() {
    final auth = _auth;
    if (auth == null) return Stream<User?>.value(null);
    return auth.authStateChanges();
  }

  // --- Helpers ---

  /// Returns a cryptographically secure random string of [length] chars.
  static String _generateNonce([int length = 32]) {
    const String charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final Random random = Random.secure();
    return List<String>.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the SHA-256 hex digest of [input].
  static String _sha256ofString(String input) {
    final List<int> bytes = utf8.encode(input);
    final digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }
}
