# Seed Data Schema (v2 — Law / Article / Decision)

This directory contains **the official IFAB Laws of the Game 2026/27 in Spanish**,
structured for import into Firestore once the Firebase project is created. The
shape of every JSON file here MUST match the field names read by
`lib/features/sports/data/datasources/sport_remote_datasource.dart`.

## Layout

```
assets/seed/
├── SCHEMA.md                              # this file
└── <sport-id>/
    ├── sport.json                         # sport document
    └── laws/
        ├── <law-id>-<slug>.json           # one file per law
        └── ...
```

Each law JSON carries three embedded arrays: the law's own metadata, its
articles, and (in older IFAB editions) a list of "Decisions" notes. The
import script **splits** the articles into individual Firestore documents and
derives `articlesCount` and `decisionsCount` from the array lengths. The
`searchText` field per article is also derived (lowercased concatenation of
number + title + content + tags) for the global search index.

## Firestore mapping

| Seed source | Firestore path |
|---|---|
| `<sport>/sport.json` | `sports/{sportId}` |
| `<sport>/laws/<law>.json` (meta) | `sports/{sportId}/laws/{lawId}` |
| `articles[]` inside law file | `sports/{sportId}/laws/{lawId}/articles/{articleId}` |
| `decisions[]` inside law file | `sports/{sportId}/laws/{lawId}/decisions/{decisionId}` |

## Field contracts

### `Sport` → `sports/{id}`

| Field | Type | Notes |
|---|---|---|
| `id` | string | Document id (also folder name) |
| `title` | string | Display name |
| `description` | string | Short blurb (1–2 sentences) |
| `thumbnailUrl` | string | Public Storage URL. Empty for pilot. |
| `lawCount` | int | **Derived** by import script. |
| `price` | int | Cents. `0` = free sport. |
| `isPublished` | bool | Pilot data is always `true`. |

### `Law` → `sports/{sportId}/laws/{id}`

| Field | Type | Notes |
|---|---|---|
| `id` | string | `law-NN` (zero-padded), e.g. `law-01` |
| `sportId` | string | Parent sport id |
| `title` | string | Display name, IFAB style: "The Field of Play" |
| `shortName` | string | Compact label, e.g. "Field" |
| `number` | int | 1–17, sorts the law list |
| `isFree` | bool | Law 1 is always `true` (free preview per the business model). |
| `articlesCount` | int | **Derived** |
| `decisionsCount` | int | **Derived**. Always `0` for 2026/27 IFAB. |
| `sportTitle` | string | Denormalised |
| `summary` | string | One- or two-line intro shown on header. Optional. |
| `sourceAttribution` | string | Required. E.g. "Texto oficial de IFAB, Laws of the Game 2026/27 (español). https://www.theifab.com/es/" |

### `Article` (inside `Law.articles[]`)

| Field | Type | Notes |
|---|---|---|
| `id` | string | `law-NN/art-NN` |
| `lawId` | string | Parent law id |
| `sportId` | string | Denormalised |
| `number` | string | IFAB style: "1", "2", "3.1" |
| `title` | string | May be empty when IFAB uses only a number |
| `content` | string | Official IFAB text (Spanish translation), 1:1, no paraphrasing |
| `parentArticleId` | string? | For sub-articles like "3.1" |
| `crossRefs` | string[] | Other article ids, e.g. `["law-10/art-02"]`. Empty for 2026/27. |
| `tags` | string[] | Lowercased, e.g. `["porteria", "area"]` |
| `searchText` | string | **Derived** by import script. Not in JSON. |
| `order` | int | 1-indexed within the law |

### `Decision` (inside `Law.decisions[]`)

| Field | Type | Notes |
|---|---|---|
| `id` | string | `law-NN/dec-NN` |
| `lawId` | string | Parent law id |
| `sportId` | string | Denormalised |
| `relatedArticleId` | string? | Optional pointer to a specific article |
| `number` | string | 1-indexed within the law, e.g. "1", "2" |
| `title` | string | Short title, often empty |
| `text` | string | IFAB clarification text |
| `order` | int | 1-indexed within the law |

## Pilot content

`football/` contains **all 17 IFAB Laws of the Game 2026/27** in Spanish, with
the official text transcribed verbatim from the IFAB Spanish PDF
(2026/27, páginas dobles).

| Law | Articles | Notes |
|---|---|---|
| 1 — The Field of Play | 14 | Includes 1.14 "Árbitros asistentes de vídeo (VARs)" (moved from Law 5 in 2026/27) |
| 2 — The Ball | 3 | |
| 3 — The Players | 10 | |
| 4 — The Players' Equipment | 6 | |
| 5 — The Referee | 7 | |
| 6 — The Other Match Officials | 7 | |
| 7 — The Duration of the Match | 5 | |
| 8 — The Start and Restart of Play | 2 | |
| 9 — The Ball In and Out of Play | 2 | |
| 10 — Determining the Outcome of a Match | 3 | |
| 11 — Offside | 4 | |
| 12 — Fouls and Misconduct | 5 | Largest law by far; 12.4 (medidas disciplinarias) is the longest article. |
| 13 — Free Kicks | 3 | |
| 14 — The Penalty Kick | 3 | Includes 14.3 "Resumen" (table) |
| 15 — The Throw-in | 2 | |
| 16 — The Goal Kick | 2 | |
| 17 — The Corner Kick | 2 | |
| **Total** | **80** | |

### 2026/27 IFAB structural changes worth knowing

- The "Decisions" section at the end of each law no longer exists as a
  separate block. Clarifications are integrated into the article content as
  additional paragraphs. The `decisions: []` array is always empty in 2026/27.
- Law 1 has a new article 1.14 "Árbitros asistentes de vídeo (VARs)" that
  used to live in Law 5 in 2025/26.
- Law 12 was heavily restructured: the cautions/expulsions lists are
  reorganised, and several specific cases were added (e.g. entering the
  review area is now a cautionable offence).

## Images

Each law JSON has an `imageUrls` array (empty) and an `imageNote` field that
explains where the official IFAB diagrams are (page references in the
2026/27 PDF) and how to add them. Diagrams include field layouts (Law 1),
goal dimensions (Law 1), penalty arc (Law 1), VAR room and review area
(Law 1), handball diagrams (Law 12), offside positions (Law 11), referee
signals (Laws 5 and 6), and the penalty summary table (Law 14).

**To add images:** extract from the IFAB PDF, upload to Firebase Storage,
then update `imageUrls` per article with the public Storage URLs. Do NOT
hotlink IFAB pages — the diagrams are IFAB's IP.

## Importing

When the Firebase project is ready:

```bash
cd scripts
npm install
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
  node import_seed.mjs --dry-run   # validate first

GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
  node import_seed.mjs             # real import
```

See `scripts/README.md` for full instructions.

## IFAB licensing

The Laws of the Game text in this directory is the official Spanish
translation published by IFAB. IFAB permits reproduction of the Laws for
use in connection with the game of association football. Every law JSON
carries a `sourceAttribution` field crediting IFAB and linking to
https://www.theifab.com/es/. Reach out to IFAB before launching a
commercial product to confirm the licensing terms.
