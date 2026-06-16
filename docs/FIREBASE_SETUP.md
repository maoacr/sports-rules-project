# Firebase Setup

This document explains how a developer must configure their local
environment to run `sports_rules_app` against a real Firebase project.
The Firebase platform config files are **not committed** to the
repository (they contain API keys and project identifiers) and must be
downloaded from the Firebase Console for each developer and each
deployment environment.

## Prerequisites

- A Firebase project at https://console.firebase.google.com
- Flutter SDK installed and on PATH (`flutter --version`)
- Android Studio (Android build) or Xcode (iOS build)

## 1. Download Firebase platform config files

In the Firebase Console, open your project and add an iOS app and an
Android app with the following bundle IDs:

- **iOS bundle ID:** `com.sportsrules.app`
- **Android package name:** `com.sportsrules.app`

After registering each app, Firebase lets you download two files:

| File | Where to put it |
|---|---|
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |
| `google-services.json` | `android/app/google-services.json` |

Both files are listed in `.gitignore` (lines 44–47) and **must never
be committed** to the repository.

## 2. Apply the google-services Gradle plugin

The `com.google.gms.google-services` plugin is already declared in
`android/app/build.gradle` (see commit `494ea74`'s successor) and
the classpath is declared in `android/build.gradle`. Once you drop
`google-services.json` into `android/app/`, the plugin will
auto-initialize Firebase at build time. No further action is needed.

To verify the plugin is wired correctly, run:

```bash
cd android && ./gradlew tasks --all | grep google
```

You should see a `googleServices` task family.

## 3. Configure the iOS Google Sign-In URL scheme

The file `ios/Runner/Info.plist` contains a placeholder for the Google
Sign-In URL scheme. Replace it with the real reversed client ID from
your `GoogleService-Info.plist`:

1. Open `ios/Runner/GoogleService-Info.plist` in a text editor.
2. Find the key `REVERSED_CLIENT_ID` and copy its value.
   Example: `com.googleusercontent.apps.1234567890-abcdef.apps.googleusercontent.com`
3. Open `ios/Runner/Info.plist` and replace the placeholder string
   `com.googleusercontent.apps.YOUR_CLIENT_ID` (under
   `CFBundleURLTypes > CFBundleURLSchemes`) with the value you copied.
4. Save the file. **Do not commit this change** if the real client ID
   is sensitive in your workflow — instead, add the line to a personal
   override or use a build-time script.

## 4. Universal Links (associated domains)

`ios/Runner/Info.plist` no longer declares the
`com.apple.developer.associated-domains` key — it is now declared only
in `ios/Runner/Runner.entitlements`, which is the canonical location
for iOS capabilities. The current value is `applinks:sportsrules.app`.

If you change the associated domain, edit `Runner.entitlements`, not
`Info.plist`.

## 5. Verify the build

Once the config files are in place and the URL scheme is updated, run:

```bash
flutter pub get
flutter analyze
flutter build apk --debug   # Android
flutter build ios --debug   # iOS (requires Xcode + signing)
```

A successful build indicates that Firebase initialization is wired
correctly. To smoke-test auth, run the app and tap the
"Sign in with Google" / "Sign in with Apple" buttons. The auth flow
should round-trip a token through Firebase Auth.

## 6. RevenueCat configuration

This project uses RevenueCat for in-app purchases. See
`docs/REVENUECAT_SETUP.md` (if it exists) for the corresponding
project setup. The `revenuecat.json` file is also `.gitignore`d and
must be downloaded from the RevenueCat dashboard.

## 7. Troubleshooting

- **`No matching client found for package name`** at build time →
  the `package_name` in `google-services.json` does not match the
  `applicationId` in `android/app/build.gradle`. They must be the
  same string.
- **`MissingPluginException(No implementation found for method ...)`**
  at runtime → Firebase native libs not bundled. Run
  `cd ios && pod install` and rebuild.
- **Google Sign-In returns `PlatformException(sign-in-failed,
  ...)`** → the URL scheme in `Info.plist` is still the placeholder.
  See section 3.
