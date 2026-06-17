# seed-import

One-shot script that uploads the JSON files in `../assets/seed/` to Firestore.

## Prerequisites

- Node.js 18+
- A Firebase project (with Firestore enabled)
- A service account key with Firestore write access

## Setup

```bash
cd scripts
npm install firebase-admin
```

## Generate a service account key

1. Open Firebase Console → **Project Settings** → **Service Accounts**
2. Click **"Generate new private key"**
3. Save the JSON somewhere outside the repo (e.g. `~/.config/firebase/<project>.json`)

## Run

```bash
# dry-run first: validate JSON, no writes
GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
  node import_seed.mjs --dry-run

# real import
GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
  node import_seed.mjs

# override project id (defaults to the one in the service account)
node import_seed.mjs --project=sports-rules-app

# override seed folder
node import_seed.mjs --seed=./staging-seed
```

The script is **idempotent** (uses `set`, not `add`) — re-running overwrites
existing documents. It does not delete anything that isn't in the seed.

## What gets written

For each `assets/seed/<sport>/`:

- `sports/{sportId}` ← `sport.json` (with `chapterCount` derived)
- `sports/{sportId}/chapters/{chapterId}` ← each chapter file (with `rulesCount` derived)
- `sports/{sportId}/chapters/{chapterId}/rules/{ruleId}` ← each rule inside the chapter file

The `rules[]` array inside chapter files is **not stored** in Firestore — it
is split into individual rule documents by this script.
