#!/usr/bin/env node
/**
 * Imports the seed data from `assets/seed/` into Firestore.
 *
 * Source layout (v2 — Law/Article/Decision):
 *   assets/seed/<sport>/sport.json
 *   assets/seed/<sport>/laws/<law-id>.json
 *
 * Each law JSON contains:
 *   - law metadata (title, shortName, number, isFree, summary, ...)
 *   - `articles[]`: each with number, title, content, crossRefs, tags, order
 *   - `decisions[]`: each with number, title, text, relatedArticleId, order
 *
 * Firestore write plan:
 *   sports/{sportId}                                       ← sport.json
 *   sports/{sportId}/laws/{lawId}                         ← one per law
 *   sports/{sportId}/laws/{lawId}/articles/{articleId}    ← one per article
 *   sports/{sportId}/laws/{lawId}/decisions/{decisionId}  ← one per decision
 *
 * The script DERIVES the following fields and writes them with the
 * document (Firestore never recomputes them):
 *   - sport.lawCount            = number of law files in laws/
 *   - law.articlesCount         = articles.length
 *   - law.decisionsCount        = decisions.length
 *   - article.searchText        = lowercased `${number} ${title} ${content} ${tags.join(' ')}`
 *
 * Usage:
 *   node import_seed.mjs                       # real import
 *   node import_seed.mjs --dry-run             # validate JSON, no writes
 *   node import_seed.mjs --project=my-id       # override project
 *   node import_seed.mjs --seed=./other/path   # override seed folder
 *   node import_seed.mjs --emulator            # point at local emulator
 *   node import_seed.mjs --emulator --dry-run  # validate against emulator
 *
 * Auth: relies on GOOGLE_APPLICATION_CREDENTIALS pointing to a service
 * account JSON. Generate one in Firebase Console → Project Settings →
 * Service Accounts → "Generate new private key".
 */

import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DEFAULT_SEED = join(__dirname, '..', 'assets', 'seed');

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const useEmulator = args.includes('--emulator');
const projectArg = args.find((a) => a.startsWith('--project='));
const seedArg = args.find((a) => a.startsWith('--seed='));
const projectId = projectArg ? projectArg.split('=')[1] : 'demo-sports-rules';
const seedDir = seedArg ? seedArg.split('=')[1] : DEFAULT_SEED;

function readJson(path) {
  return JSON.parse(readFileSync(path, 'utf8'));
}

function listDirs(path) {
  return readdirSync(path).filter((name) =>
    statSync(join(path, name)).isDirectory(),
  );
}

function listJsonFiles(path) {
  return readdirSync(path)
    .filter((f) => f.endsWith('.json'))
    .sort();
}

function normaliseSearchText(article) {
  const parts = [
    article.number ?? '',
    article.title ?? '',
    article.content ?? '',
    (article.tags ?? []).join(' '),
  ];
  return parts.join(' ').toLowerCase().replace(/\s+/g, ' ').trim();
}

function loadSeed() {
  const sports = [];
  const sportIds = listDirs(seedDir).sort();
  for (const sportId of sportIds) {
    const sportPath = join(seedDir, sportId);
    const sport = readJson(join(sportPath, 'sport.json'));

    if (sport.id !== sportId) {
      throw new Error(
        `Sport folder "${sportId}" disagrees with sport.json id "${sport.id}"`,
      );
    }

    const lawsDir = join(sportPath, 'laws');
    const lawFiles = listJsonFiles(lawsDir);
    const laws = lawFiles.map((file) => {
      const law = readJson(join(lawsDir, file));
      if (!law.id || !law.id.startsWith('law-')) {
        throw new Error(
          `Law file "${file}" has invalid id "${law.id}" (expected "law-NN" or "law-NN-...")`,
        );
      }
      return law;
    });

    sports.push({ sport, laws });
  }
  return sports;
}

function buildDocs(sports) {
  const out = [];
  for (const { sport, laws } of sports) {
    const lawCount = laws.length;
    out.push({
      ref: ['sports', sport.id],
      data: { ...sport, lawCount },
    });

    for (const law of laws) {
      const { articles = [], decisions = [], ...lawMeta } = law;
      const articlesCount = articles.length;
      const decisionsCount = decisions.length;
      out.push({
        ref: ['sports', sport.id, 'laws', law.id],
        data: { ...lawMeta, articlesCount, decisionsCount },
      });

      for (const article of articles) {
        const { id: _articleId, searchText: _ignored, ...articleData } = article;
        // Document IDs cannot contain '/'. Strip any "law-XX/" prefix.
        const articleDocId = String(article.number).padStart(2, '0');
        out.push({
          ref: [
            'sports',
            sport.id,
            'laws',
            law.id,
            'articles',
            `art-${articleDocId}`,
          ],
          data: {
            ...articleData,
            id: `art-${articleDocId}`,
            searchText: normaliseSearchText(article),
          },
        });
      }

      for (const decision of decisions) {
        const { id: _decisionId, ...decisionData } = decision;
        const decisionDocId = String(decision.number).padStart(2, '0');
        out.push({
          ref: [
            'sports',
            sport.id,
            'laws',
            law.id,
            'decisions',
            `dec-${decisionDocId}`,
          ],
          data: {
            ...decisionData,
            id: `dec-${decisionDocId}`,
          },
        });
      }
    }
  }
  return out;
}

async function main() {
  console.log(`[seed] reading from ${seedDir}`);
  const sports = loadSeed();
  const docs = buildDocs(sports);

  let sportCount = 0;
  let lawCount = 0;
  let articleCount = 0;
  let decisionCount = 0;
  for (const d of docs) {
    if (d.ref.length === 2) sportCount++;
    else if (d.ref.length === 4) lawCount++;
    else if (d.ref.length === 6) {
      if (d.ref[5 - 1] === 'articles') articleCount++;
      else decisionCount++;
    }
  }
  console.log(
    `[seed] loaded ${sportCount} sport(s), ${lawCount} law(s), ` +
      `${articleCount} article(s), ${decisionCount} decision(s) ` +
      `→ ${docs.length} document(s) total`,
  );
  for (const { ref, data } of docs) {
    console.log(`  - ${ref.join('/')}`);
  }

  if (dryRun) {
    console.log('[seed] dry-run: not writing to Firestore');
    return;
  }

  if (!useEmulator && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    throw new Error(
      'GOOGLE_APPLICATION_CREDENTIALS is not set. Generate a service ' +
        'account key in Firebase Console → Project Settings → Service ' +
        'Accounts, then export the env var pointing to the JSON file. ' +
        'Or use --emulator to point at the local Firestore emulator.',
    );
  }

  if (useEmulator) {
    // The Firestore emulator accepts any credentials — no real service
    // account needed. Point the admin SDK at localhost:8080.
    process.env.FIRESTORE_EMULATOR_HOST =
      process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
    console.log(
      `[seed] using emulator at ${process.env.FIRESTORE_EMULATOR_HOST}`,
    );
  }

  if (getApps().length === 0) {
    initializeApp({ projectId });
  }
  const db = getFirestore();

  let written = 0;
  for (const { ref, data } of docs) {
    await db.doc(ref.join('/')).set(data, { merge: false });
    written += 1;
  }
  console.log(`[seed] wrote ${written} document(s) to Firestore`);
}

main().catch((err) => {
  console.error(`[seed] FAILED: ${err.message}`);
  process.exit(1);
});
