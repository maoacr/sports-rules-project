#!/usr/bin/env bash
# Start the Firebase emulator suite (Firestore + UI + Auth) for local dev.
# Run the import script in another terminal to seed data, or use
# `node scripts/import_seed.mjs --emulator --dry-run` first to validate.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "[emulator] starting Firestore (8080) + UI (4000) + Auth (9099)…"
echo "[emulator] open http://localhost:4000 to browse the data once seeded."

exec firebase emulators:start --only firestore,auth,ui --project demo-sports-rules
