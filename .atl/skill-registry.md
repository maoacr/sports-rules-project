# Skill Registry

**Delegator use only.** Any agent that launches sub-agents reads this registry to resolve compact rules, then injects them directly into sub-agent prompts. Sub-agents do NOT read this registry or individual SKILL.md files.

See `_shared/skill-resolver.md` for the full resolution protocol.

## User Skills

| Trigger | Skill | Path |
|---------|-------|------|
| Go tests, go test coverage, Bubbletea teatest, golden files | go-testing | /Users/mao/.config/opencode/skills/go-testing/SKILL.md |
| PRs over 400 lines, stacked PRs, review slices | chained-pr | /Users/mao/.config/opencode/skills/chained-pr/SKILL.md |
| judgment day, dual review, adversarial review, juzgar | judgment-day | /Users/mao/.config/opencode/skills/judgment-day/SKILL.md |
| new skills, agent instructions, documenting AI usage patterns | skill-creator | /Users/mao/.config/opencode/skills/skill-creator/SKILL.md |
| PR feedback, issue replies, reviews, Slack messages, or GitHub comments | comment-writer | /Users/mao/.config/opencode/skills/comment-writer/SKILL.md |
| writing guides, READMEs, RFCs, onboarding, architecture, or review-facing docs | cognitive-doc-design | /Users/mao/.config/opencode/skills/cognitive-doc-design/SKILL.md |
| creating GitHub issues, bug reports, or feature requests | issue-creation | /Users/mao/.config/opencode/skills/issue-creation/SKILL.md |
| creating, opening, or preparing PRs for review | branch-pr | /Users/mao/.config/opencode/skills/branch-pr/SKILL.md |
| implementation, commit splitting, chained PRs, or keeping tests and docs with code | work-unit-commits | /Users/mao/.claude/skills/work-unit-commits/SKILL.md |

## Compact Rules

### go-testing
- Prefer table-driven tests for multiple cases; use `t.Run(tt.name, ...)`
- Test behavior and state transitions, not implementation trivia
- Use `t.TempDir()` for filesystem tests; never rely on a real home directory
- Keep integration tests skippable with `testing.Short()` when they run external commands or slow flows
- For Bubbletea, test `Model.Update()` directly for state changes; use `teatest` only for interactive flows
- Golden files must be deterministic; update only through the repo's `-update` path and rerun tests without `-update`
- Use small mocks/interfaces around system or command execution boundaries

### chained-pr
- Split PRs over **400 changed lines** unless a maintainer explicitly accepts `size:exception`
- Keep each PR reviewable in about **≤60 minutes**
- Use one deliverable work unit per PR; keep tests/docs with the unit they verify
- State start, end, prior dependencies, follow-up work, and out-of-scope items in every chained PR
- Every child PR must include a dependency diagram marking the current PR with `📍`
- In Feature Branch Chain, create a draft/no-merge tracker PR; child PR #1 targets the tracker branch, later children target the immediate parent branch
- Treat polluted diffs as base bugs: retarget or rebase until only the current work unit appears
- Do not mix chain strategies after the user chooses one

### judgment-day
- Resolve project skills before launching agents: read skill registry, match compact rules by target files/task, and inject the same `Project Standards` block into both judge prompts and fix prompts
- Launch **two blind judges in parallel** with identical target and criteria; never review the code yourself
- Wait for both judges before synthesis; never accept a partial verdict
- Classify warnings as `WARNING (real)` only if normal intended use can trigger them; otherwise downgrade to INFO as `WARNING (theoretical)`
- Ask before fixing Round 1 confirmed issues
- After any fix agent runs, immediately re-launch both judges in parallel before commit/push/done/session summary
- Terminal states are only `JUDGMENT: APPROVED` or `JUDGMENT: ESCALATED`
- After 2 fix iterations with remaining issues, ask the user whether to continue

### skill-creator
- When working in this repo, first follow `docs/skill-style-guide.md` as the normative source before creating or updating skills
- If that guide is unavailable, use the compact inline rules below
- A skill is a runtime instruction contract for an LLM, not human documentation
- Do not add a `Keywords` section; preserve essential trigger words in `description`
- References must point to local files
- Keep the skill body concise: target 180–450 tokens, recommended max 700, hard max 1000

### comment-writer
- Be useful fast: start with the actionable point, do not recap the whole PR before feedback
- Be warm and direct: sound like a thoughtful teammate, not a corporate bot
- Keep it short: prefer 1 to 3 short paragraphs or a tight bullet list
- Explain why: give the technical reason when asking for a change
- Avoid pile-ons: comment on the highest-value issue, not every tiny preference
- Match thread language: write in the thread/user language
- No em dashes: use commas, periods, or parentheses instead

### cognitive-doc-design
- Lead with the answer: put the decision, action, or outcome first
- Progressive disclosure: start with the happy path, then add details, edge cases, and references
- Chunking: group related information into small sections
- Signposting: use headings, labels, callouts, and summaries so readers know where they are
- Recognition over recall: prefer tables, checklists, examples, and templates over prose
- Review empathy: design docs so reviewers can verify intent without reconstructing the whole story

### issue-creation
- **Blank issues are disabled** — MUST use a template (bug report or feature request)
- **Every issue gets `status:needs-review` automatically** on creation
- **A maintainer MUST add `status:approved`** before any PR can be opened
- **Questions go to Discussions**, not issues
- Search existing issues for duplicates before creating

### branch-pr
- **Every PR MUST link an approved issue** — no exceptions
- **Every PR MUST have exactly one `type:*` label**
- **Automated checks must pass** before merge is possible
- Branch naming: `type/description` — lowercase, no spaces
- Conventional commits: `type(scope): description`

### work-unit-commits
- Commit by work unit: a commit represents a deliverable behavior, fix, migration, or docs unit
- Do not commit by file type: avoid `models`, then `services`, then `tests` if none works alone
- Keep tests with code: tests belong in the same commit as the behavior they verify
- Keep docs with the user-visible change
- Tell a story: a reviewer should understand why each commit exists from its diff and message
- Future PR-ready: each commit should be a candidate chained PR when the change grows
- SDD workload guard: if SDD tasks forecast a >400-line change, group commits into chained PR slices

## Project Conventions

No project conventions detected — empty project directory.

Read the convention files listed above for project-specific patterns and rules. All referenced paths have been extracted — no need to read index files to discover more.