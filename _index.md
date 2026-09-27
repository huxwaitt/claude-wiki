# Router

TODO: one paragraph saying what this wiki covers and who it is for. State the live counts — pages,
domains — and keep them current; the validator checks them against reality once pages exist.

## Read protocol (keep the budget small)

1. **Route.** Match the question to 1–2 domains below using *Route here when* / *Not here*. If the reader
   is starting from zero or asks "what next", go to `_playbook.md` instead.
2. **Select.** Open that domain's `_index.md`; pick ≤4 pages by `summary` and `applies_when`. Match
   `depth` to the asker.
3. **Read.** Load the pages. `**Bottom line:**` is the answer; the body is the justification. Follow
   `related` only if a gap remains.
4. **Answer** citing page ids. Quote a source itself only when asked; `_sources.md` says what the sources
   are and where to reach them.

Alternative to steps 1–2 for symptom or keyword queries: grep `_catalog.yaml` (all frontmatter, one file
— grep it, do not load it whole) on `applies_when`, `topics`, `summary`, or `type: pitfall`.

Typical cost: router + one domain index + 3 pages.

## Domains

TODO: one row per `NN-slug` folder. *Route here when* is what the reader is trying to do; *Not here* is
what gets misrouted here and where it belongs instead. The second column is what makes routing work —
a table without it sends every question to every domain.

| Domain | Route here when the reader… | Not here |
|---|---|---|
| | | |

## Top-level files

| File | Use |
|---|---|
| `_playbook.md` | The decisions in the order they get made. Read for "where do I start / what next". |
| `_overview.md` | The subject end to end: stages, artifacts, exit criteria, how the wiki is organized. |
| `_glossary.md` | Term → definition → page id. |
| `_sources.md` | What the sources are, how a citation is formed, where to reach them. |
| `_catalog.yaml` | Generated: every page's frontmatter. Grep target. |
| `_schema.md` | Page contract and writing standard. Read when authoring or auditing pages. |
| `_bootstrap.md` | How to stand this wiki up: domains, vocabularies, source form. Delete once filled in. |
| `_maintenance.md` | How to change the wiki: file roles, operations, completion checklist, changelog. |
| `_tools/validate.ps1` | Validates pages and structure against `_schema.md`; `-WriteCatalog` regenerates `_catalog.yaml`. |
| `<domain>/_index.md` | Stage purpose/inputs/outputs/exit criteria · decisions in order · page table · pitfall table. |

## Page types (what to expect when a page opens)

`decision` options → criteria → recommendation by scenario · `concept` what/how/implications ·
`pattern` use-when/structure/failure modes · `procedure` preconditions/steps/verification ·
`checklist` verifiable items · `pitfall` symptom → root cause → prevention → the story.
