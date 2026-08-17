# Maintenance Procedure

How to change this wiki without breaking it. Structural only: it names file roles, invariants, operations, and the completion checklist — never wiki content. The page contract (voice, frontmatter, templates, vocabularies, canonical names, index format) is `_schema.md`; read it, do not paraphrase it from memory. Invoked by the `wiki-maintain` skill; usable by hand.

## 1. File roles and invariants

| File | Role | Authored / generated |
|---|---|---|
| `_index.md` | Router: read protocol · domain table (one row per `NN-slug` folder, backticked) · top-level file table · page-type key. States live counts. | authored |
| `_overview.md` | Process narrative: one `### NN <Title>` section per domain, ending in `<n> pages + <m> pitfalls.`; wiki organisation; counts; scope notes. Written last. | authored |
| `_playbook.md` | Ordered decision spine; every non-pitfall page of the sequenced domains appears once, backticked. If the wiki has a reference series, its pages are not listed page by page — each stage line carries a "Reference:" pointer to the relevant leaf. | authored |
| `_glossary.md` | `\| Term \| Definition \| See \|` table, then `## Aliases` `\| Alias \| Canonical \|`. See = page id in backticks, or `<slug>.*`. | authored |
| `_schema.md` | The page contract (§2 voice · §3 frontmatter · §4 templates · §5 vocabularies · §6 canonical names · §7 domain index · §8 exclusions · §9 generated files). Change only when the contract changes. | authored |
| `_catalog.yaml` | All frontmatter, one file. Grep target. | **generated** by `_tools\validate.ps1 -WriteCatalog` |
| `_maintenance.md` | This file + `## Changelog`. | authored |
| `_tools\validate.ps1` | Enforces `_schema.md` per page, wiki structure, source form, count drift, catalog freshness. Vocabulary lists at its top mirror §5; `$courses` mirrors `_sources.md`. Resolves its own root from the script location, or `-Root`. | authored |
| `NN-slug\` | Domain folder. `NN` two digits, unique, ordered; `slug` lowercase-hyphenated. Contains `_index.md` (§7 format) + pages. Flat within a domain. **One container level is allowed for a reference series**: a `NN-slug\` folder that holds only leaf folders (`slug\`, unnumbered) and its own 4-row router `_index.md`. Leaf pages carry `domain: NN-container/leaf` and ids `leaf.<page>`. No nesting below a leaf. | authored |
| `NN-slug\<page>.md` · `pitfall-<page>.md` | One atomic page. `id: <slug>.<filename-without-.md>` — id and filename are the same fact. | authored |
| `_sources.md` | The source catalogue: every source this wiki may cite, how to reach it, and the citation form. Accepted names: the `$courses` list in `validate.ps1`, which must be kept in step with this file. | authored |
| `_bootstrap.md` | How to stand an empty wiki up: domains, vocabularies, source form, the gate. Present only until the wiki is populated, then deleted. | authored |

Invariants: frontmatter is the routing surface (routing decisions are made from `summary` / `applies_when` / `not_for` / `topics` / `depth` alone) · id = filename · every id reference resolves · every sentence traces to a listed source · domain `_index.md` Pages/Pitfalls tables mirror frontmatter (frontmatter wins) · counts stated in top-level files equal live counts · `_catalog.yaml` equals a fresh regeneration.

## 2. Voice and tagging — the tests (full contract: `_schema.md` §2–§6)

- Answer first: H1 → `**Bottom line:**` (≤2 sentences) → template headings for the type, in order, none added.
- `summary` (≤40 words) states the answer — reading only it, a counselor can give a first-pass reply. Never "This page covers…".
- `applies_when` (2–5) are things a user would actually say; `not_for` (0–3) is `<misrouted intent> → <other page id>`.
- `topics` (1–4) from §5 only; `stage` (1–2) from §5; `depth` by source track (L1 Associate · L2 Developer · L3 Architect, ranges allowed).
- `sources` = `<Course name> § <exact screen heading>`, the course from `_sources.md`; a cert-track module is `<Prep course> / <Module> § <heading>`. Body `## Sources` repeats the list verbatim; a lesson merged from several course variants cites every variant's heading.
- Conditional guidance as `If <observable condition> → <action>. Because <reason>.`; imperative, builder-facing; ≤25 words per bullet.
- Canonical names from §6; source's own term in **bold** on first use; cross-reference only as `` `id` ``.
- Nothing invented: omit what no source says. No pedagogy (exercises, quizzes, "you will learn", navigation).
- Length caps §4; word budget is a reader cost — compress before adding.

## 3. Operations → touch-list

| Operation | Must touch | Also check |
|---|---|---|
| **Edit page content** | page body/frontmatter | if `summary`/`applies_when` changed → domain `_index.md` row (verbatim copy); new terms → `_glossary.md`; new refs → both directions; catalog regen |
| **Add page** | new page (§3 + §4) · domain `_index.md` (Pages row · Decisions in order slot · This stage if scope widened) · `_playbook.md` placement · `related` back-links on referenced pages · `_glossary.md` new terms · counts in `_index.md`/`_overview.md` · catalog regen | `not_for` on the nearest neighbour page pointing here |
| **Add pitfall** | `pitfall-<slug>.md` · domain `_index.md` Pitfalls row · `## Pitfalls` bullet on the preventing decision/pattern page · counts · catalog regen | glossary if the story names a term |
| **Split / merge pages** | new page(s) as *Add page*; retired id(s) as *Rename/deprecate* | playbook and index rows reflect the new set exactly once |
| **Rename / deprecate page** | rename file + `id` · grep whole wiki for the old id and rewrite every hit (frontmatter `related`/`not_for`, bodies, domain `_index.md`, `_playbook.md`, `_glossary.md` See, `_overview.md`) · changelog line `renamed a → b` or `removed a (reason)` · counts · catalog regen | no stub file is left behind (§5) |
| **Add domain folder** | `NN-slug\` + `_index.md` per §7 · row in `_index.md` domain table (Route here when / Not here) · `### NN <Title>` section in `_overview.md` · `_playbook.md` placement · `_schema.md` §5 domain list (flag: contract change) · counts · catalog regen | at least one page and a stage checklist before publishing. A new **component leaf** goes under `10-claude-components\` (row in the container `_index.md` and in the root components table; counted line in the `### 10` overview section; no playbook placement; ≥10 pages; no stage checklist required) |
| **Add / modify glossary term** | `_glossary.md` row (§4 rule) | alias rows for synonyms; §6 if it is a canonical product name |
| **Change a top-level file** | the file · anything that quotes it (`_index.md` file table, `_overview.md` organisation text) | if `_schema.md` §4/§5 changes → mirror the list/template in `validate.ps1`; **flag loudly**: contract change |
| **Re-validate only** | nothing · run `_tools\validate.ps1 -WriteCatalog` · report | changelog line only if the catalog changed |
| **Bulk import** (a new source track, or many pages at once) | build plan first: source-section → domain/page-id map, planned ids, pitfall assignments (the initial-build pattern) · confirm the plan · fan out **one agent per affected domain**, each given `_schema.md` + the plan + this file's touch-lists · then one *Add page*/*Add domain* touch-list pass over the whole result · counts · catalog regen | new course name → `_sources.md` row + `validate.ps1` `$courses` (mirror; flag) · new canonical names → `_schema.md` §6 · glossary sweep for new terms · run the checklist once at the end, not per agent |

## 4. Glossary rule

Any technical term a change introduces or renames goes into `_glossary.md` in the stored form: `| <term> | <source's definition, ≤25 words> | `\`<page id>\`` |`, inserted in alphabetical position (sort key: lower-case, ignore a leading "the" and punctuation). Synonyms and abbreviations become `## Aliases` rows pointing at the canonical term. A new canonical product/feature name is also added to `_schema.md` §6 (contract change — flag it). Removing a page that a term's See points at → repoint or delete the row.

## 5. Sources, provenance and deprecation

- Default: every sentence traces to `<Course name> § <heading>`. Merging across courses is fine; adding is not. A new claim needs a course already listed in `_sources.md`, or that file and `validate.ps1`'s `$courses` list are extended in the same change.
- User-supplied knowledge (no course source) is exceptional and must be approved as such in the plan. Record it as `Maintainer/<YYYY-MM-DD> § <who supplied it: one-line provenance>` in `sources` and `## Sources`; the date must match a `## Changelog` entry that names the page. The validator enforces the pairing.
- Deprecation: no stubs, no redirect files. Rename/remove = rewrite every reference (grep the whole wiki for the id, including `_glossary.md` and `_overview.md`), regenerate the catalog, and record `renamed old → new` / `removed id (reason)` in the changelog — the changelog is the redirect table.

## 6. Change plan (present before any write; wait for explicit approval)

```
Operation: <from §3>            Trigger: <one line: what the user asked>
Create: <paths>                 Modify: <paths>          Delete/rename: <old → new>
Page ids affected: <ids>        Frontmatter deltas: <field: old → new, per page>
Domain _index.md: <rows / Decisions-in-order line / This stage text>
_playbook.md: <line to add/move/remove>     _overview.md / _index.md: <count or structure text>
Glossary: | term | definition | `see-id` |  (+ aliases)      Schema/validator change: <none | describe — flag>
Sources: <Course name § heading> per new claim (or Maintainer/<date> § … — flag)   New course added to _sources.md + $courses: <none | name>

Catalog regen: yes/no           Changelog line: <draft>
```
Nothing is written until the user approves this plan. If execution reveals a needed change outside the plan, stop and re-confirm that delta.

## 7. Completion checklist — every item verified, or the task is not complete

- [ ] Frontmatter: fields present, fixed order (§3), controlled values (§5), `id` = `<slug>.<filename>`, `domain` = folder.
- [ ] Body: H1 = title, `**Bottom line:**`, headings exactly the type template in order (§4), length inside caps.
- [ ] `summary` states the answer (≤40 words); `applies_when` are user intents; `not_for` targets resolve.
- [ ] Every `sources` entry: heading found in the raw file by grep (validator checks); body `## Sources` identical.
- [ ] `related` resolves; back-link added on the target where the relation is symmetric.
- [ ] Domain `_index.md`: Pages/Pitfalls row (verbatim summary + applies_when joined by " · "), Decisions-in-order line, This stage text if scope changed.
- [ ] `_index.md` domain table (new/renamed domain) · `_playbook.md` (new/removed non-pitfall page) · `_overview.md` (section, structure text, counts) · `_glossary.md` (new terms, aliases, dangling See).
- [ ] `_schema.md` touched only if the contract changed — said so in the report; `validate.ps1` lists mirrored.
- [ ] Old ids: grep of the whole wiki returns zero hits for a renamed/removed id.
- [ ] No invented content: each new sentence maps to a listed source, or the source is `Maintainer/<date> § …` and was approved.
- [ ] `_tools\validate.ps1 -WriteCatalog` run last; per-page issues not larger than before the change and none on files touched (or each remaining one accepted with reason in the report); `structure issues: 0`.
- [ ] `## Changelog` entry appended (§8). Report: files changed, ids affected, validator tail, accepted issues.

## 8. Changelog

One line per change, newest last: `- <YYYY-MM-DD> · <operation> · <what changed> · validator: pages <n>, issues <n>, structure <n>`. The changelog is also the redirect table for renamed and removed ids (§5), so it is never rewritten or pruned.

- (no changes yet - this wiki has not been populated. See `_bootstrap.md`.)
