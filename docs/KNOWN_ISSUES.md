# Known Issues

This document tracks technical debt and limitations that block a clean
green build of the `sports_rules_app` and are deferred to follow-up
issues. Each entry includes the diagnosis, the workaround in place, and
the recommended fix.

---

## K-1: Isar storage schema cannot be generated

**Symptom:** `flutter analyze` reports 23 errors in
`lib/core/storage/isar_storage.dart` and `lib/main.dart` of the form
"The getter 'cachedSports' isn't defined for the type 'Isar'" and
"Undefined name 'CachedSportSchema'". The app cannot boot against a
real device.

**Root cause:** `isar_storage.dart` declares three `@collection` classes
(`CachedSport`, `CachedChapter`, `CachedRule`) that depend on the
generated `isar_storage.g.dart` part file. The generator
(`isar_generator 3.1.0+1`, last published 3 years ago) is incompatible
with the current Dart SDK in this environment (Flutter 3.38.7, Dart
3.10.7) on two fronts:

1. **`isar_generator` ↔ `bloc_test` version conflict.** The two packages
   pin incompatible ranges of `test`/`test_api`. Adding
   `isar_generator: ^3.1.0+1` to `dev_dependencies` causes
   `flutter pub get` to fail with "version solving failed".
2. **`build_runner` cannot precompile against Dart 3.10.** Even when the
   conflict is papered over with `dependency_overrides`, build_runner
   fails with `Could not find a command named
   "frontend_server.dart.snapshot"` because the Flutter SDK in this
   environment ships only `frontend_server_aot.dart.snapshot`. The
   `build_runner 2.4.x` line was designed for Dart ≤ 3.5.

**Workaround in place:**
- The three repository test files have been rewritten as **contract
  tests** of the domain interfaces (`AuthRepository`, `SportRepository`)
  instead of unit tests of the implementations. They verify the
  interfaces are mockable and that the `Either<Failure, T>` contract is
  correctly typed, but they do NOT cover the `try/catch` logic in
  `AuthRepositoryImpl` and `SportRepositoryImpl` (which depends on
  `IsarStorage`).
- Test count is 36/36 passing (20 bloc tests + 16 contract tests).
- The `flutter analyze` errors are tracked but not blocking the test
  suite because the test files do not transitively import
  `IsarStorage`.

**Recommended fix (out of scope for Issue #1):** migrate the local
storage layer to a maintained alternative. Options, in order of
preference:

1. **`isar_community`** (https://pub.dev/packages/isar_community) — the
   community fork of Isar 3.x. It tracks the same API but is being
   updated for newer SDKs. Lowest migration cost.
2. **Migrate to `drift`** (https://pub.dev/packages/drift) — Dart-native
   SQL ORM. Requires rewriting `IsarStorage` and the data sources but
   has full type safety and a working code generator.
3. **Migrate to `sqflite` + manual mapping** — most explicit, no
   codegen, more boilerplate.

The recommended option is `isar_community` if the fork stabilizes, or
`drift` if the team wants a long-term-supported solution.

---

## K-2: `pubspec.lock` is in `.gitignore`

**Symptom:** `pubspec.lock` is excluded by `.gitignore` line 13, so
different developers may resolve to different transitive versions of
`isar`, `firebase_auth`, etc.

**Recommended fix:** remove `pubspec.lock` from `.gitignore` for an app
project (vs a library). This is a Flutter convention.

**Why deferred:** the current `.gitignore` is intentionally the
template generated for library-style projects. Migrating to
app-style is a one-line change but conceptually larger (touches the
whole team's workflow).
