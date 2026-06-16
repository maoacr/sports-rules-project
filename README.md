# Sports Rules App

A Flutter + Firebase platform that centralizes the official rulebooks for the world's most popular sports with a premium reading experience. Users get the first chapter of any sport for free; unlocking the rest of the rulebook is a single one-time purchase per sport.

## Status

**Initial architecture complete** — see the [verify report](docs/verify-report.md) for full status. Implementation is `PASS WITH WARNINGS`.

## Tech stack

- **Flutter** 3.16+ (iOS + Android)
- **Firebase** — Auth, Firestore, Storage, Remote Config
- **RevenueCat** — In-App Purchase handling
- **Isar** — Offline premium content cache
- **go_router** — Navigation + deep links
- **flutter_bloc** — State management
- **get_it** — Dependency injection

## Architecture

Feature-based with Clean Architecture layers (Presentation / Domain / Data) per feature:

```
lib/
├── core/              # cross-cutting: DI, theme, errors, network, storage, deeplink
└── features/
    ├── auth/          # email + Google + Apple sign-in
    ├── sports/        # sport / chapter / rule hierarchy + browsing
    ├── purchases/     # RevenueCat integration + paywall
    └── profile/       # user profile + settings
```

## Project layout

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App bootstrap (Firebase, Isar, DI) |
| `lib/app.dart` | MaterialApp + GoRouter |
| `lib/app_router.dart` | All routes + auth redirect logic |
| `lib/core/` | Cross-cutting infrastructure |
| `lib/features/` | Per-feature Clean Architecture |
| `android/` | Android native config + Gradle |
| `ios/` | iOS native config + entitlements |
| `docs/` | SDD artifacts (proposal, spec, design, tasks, verify) |

## Setup

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Fill in your real keys (see .env.example for the full list)
   ```

3. **Add Firebase platform configs** (not committed for security)
   - `ios/Runner/GoogleService-Info.plist` from Firebase Console
   - `android/app/google-services.json` from Firebase Console
   - Apply the `com.google.gms.google-services` plugin in `android/app/build.gradle`

4. **Configure RevenueCat**
   - Create products in App Store Connect / Google Play Console (one per sport)
   - Add the SDK API keys to `.env` (`REVENUECAT_API_KEY_IOS` / `_ANDROID`)

5. **Run**
   ```bash
   flutter run
   ```

## Free vs paid

Each sport has the following pricing model:

- **Chapter 1** — always free, no account required
- **Chapters 2-N** — single one-time purchase per sport unlocks all remaining chapters
- Purchases are **permanent** for the user account
- Paid content is **cached for offline reading** after purchase

## See also

- [docs/proposal.md](docs/proposal.md) — change intent and scope
- [docs/spec.md](docs/spec.md) — user flows and acceptance criteria
- [docs/design.md](docs/design.md) — technical design
- [docs/tasks.md](docs/tasks.md) — task breakdown
- [docs/verify-report.md](docs/verify-report.md) — verification status

## License

TBD.
