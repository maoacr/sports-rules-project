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

## K-2: ~~`pubspec.lock` is in `.gitignore`~~ (PARTIALLY RESOLVED)

**Resolution (this part — done):** `pubspec.lock` is now committed
(PR #7, commit `20ade86`). The `.gitignore` template that came with
the Flutter scaffold was the library-style one; for an app project
the lockfile belongs in the repo so every developer and CI run gets
the exact same dependency tree.

**Remaining part — the CI workflow itself is BLOCKED.**

The CI workflow file is ready and tested locally on the
`ci/add-github-actions` branch (commit `6f46ad3`), but pushing it
directly fails because the GitHub OAuth token used by the `gh` CLI
in this environment does not have the `workflow` scope:

```
! [remote rejected] (refusing to allow an OAuth App to create or
update workflow `.github/workflows/flutter.yml` without `workflow`
scope)
```

Tracked as **issue #6**. Workaround: a maintainer with the `workflow`
scope pushes the branch, or the file is uploaded through the GitHub
web UI directly. Once on the repo, the workflow runs automatically
on every PR.

**Once unblocked, the CI job will:**
1. Set up Java 17 + Flutter 3.38.7
2. Run `flutter pub get`
3. Verify the Isar generated schema is up to date (fails if
   `isar_storage.g.dart` has any diff — surfaces a forgotten regen)
4. Run `flutter analyze`
5. Run `flutter test --reporter compact`

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
