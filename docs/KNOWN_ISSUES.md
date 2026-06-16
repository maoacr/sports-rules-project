# Known Issues

This document tracks technical debt and limitations that block a clean
green build of the `sports_rules_app` and are deferred to follow-up
issues. Each entry includes the diagnosis, the workaround in place, and
the recommended fix.

---

## K-1: ~~Isar storage schema cannot be generated~~ (RESOLVED)

**Resolution:** migrated to [`isar_community`](https://pub.dev/packages/isar_community)
v3.3.2, the community fork of Isar. Resolved in commit `8b0a5b1` (PR #3).

**What was done:**
- `pubspec.yaml`: `isar: ^3.1.0+1` → `isar_community: ^3.3.2`,
  `isar_flutter_libs` → `isar_community_flutter_libs`,
  added `isar_community_generator: ^3.3.2`
- `build_runner` upgraded from `^2.4.12` to `^2.15.0` (the old line
  predates Dart 3.7 and cannot generate the new frontend_server snapshot)
- All `package:isar/isar.dart` imports updated to
  `package:isar_community/isar.dart`
- `Isar.instance` (removed in 3.3) replaced with the value returned by
  `await Isar.open(...)` in `main.dart`
- Build workflow uses `dart run build_runner build --force-jit` because
  the SDK's AOT snapshot path on Flutter 3.38 is not what the generator
  expects. The generated `.g.dart` is committed to the repo so this is
  a one-time manual step.

**Remaining concern → tracked as K-3 below.**

---

## K-2: `pubspec.lock` is in `.gitignore`

**Symptom:** `pubspec.lock` is excluded by `.gitignore` line 13, so
different developers may resolve to different transitive versions of
`isar`, `firebase_auth`, etc.

**Recommended fix:** remove `pubspec.lock` from `.gitignore` for an app
project (vs a library). This is a Flutter convention.

**Why deferred:** the current `.gitignore` is intentionally the template
generated for library-style projects. Migrating to app-style is a
one-line change but conceptually larger (touches the whole team's
workflow).

---

## K-3: `isar_community` is archived — plan to migrate to `drift`

**Context:** The `isar-community/isar` GitHub repo was archived on
Aug 18, 2025 and is now read-only. The 3.x line of releases (the one we
use) is the last branch that received maintenance. Open issues in that
repo (e.g. #115 conflicts with `json_serializable`, #120 16KB Android
pages, #126 generator null-check bug) are unlikely to be fixed.

**Impact:** `isar_community 3.3.2` works for us today, but is a frozen
snapshot. When the Dart SDK moves further ahead (Dart 3.11+, Flutter
3.40+) or a new platform requirement lands (e.g. Android 16KB pages on
all targets), this fork may stop compiling.

**Recommended fix:** migrate the local cache layer to
[`drift`](https://pub.dev/packages/drift) (formerly `moor`). Drift is
actively maintained, has first-class Flutter support, a working
code generator on modern SDKs, and is the de-facto standard for
type-safe SQL in Flutter.

**Estimated cost:** 1-2 weeks. The migration is mechanical because the
abstraction already lives behind the `SportLocalDataSource` interface —
only the implementation needs to change.

**Trigger conditions to schedule the migration:**
1. `isar_community` becomes incompatible with a Flutter minor version
2. The mobile team grows beyond a single dev
3. We need cross-platform sync (drift supports desktop + web natively)

Until any of those triggers fire, `isar_community` is the right call.
