---
name: wiki-navigate
description: Read-only navigation of a retrieval wiki built to this contract (a `_index.md` router plus a `_schema.md` page contract). Use when the user says "/wiki-navigate", "consult the wiki", "what does the wiki say about…", "where do I start with…", or asks how to do something the wiki covers. Also use when another skill needs a wiki lookup. For edits use /wiki-maintain.
version: 2.0.0
---

# Wiki Navigate

Read-only. Never edit wiki files here; hand edits to `/wiki-maintain`.

This skill hardcodes no path. A wiki is any folder holding both `_index.md` and `_schema.md`.

## 0. Locate the wiki (every invocation)

1. A path named in the user's request wins. Verify `_index.md` + `_schema.md` are both there.
2. Else, if your loaded memory names a wiki root, use it — but verify both files still exist before
   trusting it. If they do not, fall through to step 3 and say the saved path is stale.
3. Else search, in this order, stopping at the first level that yields a hit: the working directory; its
   immediate children; then each ancestor and that ancestor's immediate children.
4. Exactly one hit → use it. Several → list them and ask which; do not guess. None → say so and stop.
5. If the root came from step 3 or 4, ask once: "Found a wiki at `<root>`. Save this location for future
   sessions?" On yes, write a `reference` memory (name it for the wiki, description naming the path and
   the `/wiki-navigate` · `/wiki-maintain` skills) and add its line to `MEMORY.md`, per the memory
   conventions in your system prompt. On no, continue and do not ask again this session.

## 1. Discover (every invocation)

1. Read `<root>\_index.md` — the router. It lists the current domains, top-level files, and read
   protocol. Trust it over this skill.
2. Only if the router looks stale (names a folder that does not exist, or a `NN-*` folder is missing from
   its table): list `<root>\NN-*` folders and read each `_index.md` `## This stage` block. Note the
   mismatch for the answer (§5).

Structural invariants (stable across wikis built to this contract):
- Domain = folder `NN-slug`; each has `_index.md` (`## This stage` · `## Decisions in order` · `## Pages`
  table · `## Pitfalls` table) plus pages `<slug>.md` / `pitfall-<slug>.md`. One container level may
  exist: `NN-container\<leaf>\`, each leaf a domain with its own `_index.md` (`## This surface` ·
  `## Pages in order` · tables); the router names leaves as `NN-container/leaf` and links to them.
- Page id = `<slug>.<filename-without-.md>` where slug is the page's own folder. Frontmatter carries
  `summary`, `depth`, `applies_when`, `not_for`, `sources`, `related`; body opens with `**Bottom line:**`.
  Where a wiki has both a process spine and a reference series, process pages point into reference pages
  via `related` — follow that hop when the question is "how does this thing actually work".
- `_catalog.yaml` = generated copy of all frontmatter, one large file. Grep it; never load it whole.
- `_schema.md` = the page contract. Do not read it for navigation.
- `_sources.md` = what the sources are and how to reach them. Read only when the user wants the source.

## 2. Read protocol

1. **Route** — pick ≤2 domains from the router's *Route here when* / *Not here* columns.
2. **Select** — open each chosen `<domain>\_index.md`; pick ≤4 pages by `summary`, `applies_when`, and
   `depth`. Use `not_for` to reroute.
3. **Read** — load the pages. `**Bottom line:**` is the answer; the body is justification. Follow
   `related` only if a gap remains, ≤2 hops.
   - If the user is weighing a consequential decision, also read the `## Pitfalls` table of the routed
     domain's `_index.md` and carry forward any whose symptom matches their situation.
4. **Answer** — per §4.

Shortcuts (use instead of steps 1–2 when they fit):
- "Where do I start / what next / in what order" → `_playbook.md`; read only the step the user is at.
- Term or acronym lookup → `_glossary.md` (`| Term | Definition | See |`; check `## Aliases` if no hit).
  Follow `See` only if the definition is not enough.
- Symptom, keyword, or "what can go wrong" → grep `_catalog.yaml` on `applies_when`, `topics`, `summary`,
  or `type: pitfall`; take the `id`/`file` fields to the page.
- Exact source wording requested → the page's `sources` entry names the source and the exact heading
  inside it. Give the user that citation and, from `_sources.md`, where to reach the source. **The wiki
  does not necessarily hold the source text**; do not go looking for a local file unless `_sources.md`
  says one exists. A `Maintainer/<date> § …` source means the statement was verified against current
  documentation on that date — see the dated changelog line in `_maintenance.md`.

## 3. Depth

`depth` in frontmatter names the audience level, defined in `_schema.md` §5 (commonly L1/L2/L3, ranges
allowed). Prefer pages whose depth covers the asker. Unknown asker: infer from the question's vocabulary;
if still unclear, answer at the middle level and name the pages that exist at the others.

## 4. Answering

- **Default: ≤150 words.** Exceed only when the user asked for several distinct things, or for end-to-end
  mechanics. Never past 400. Count before sending.
- Lead with the answer in one or two sentences. No preamble, no restating the question.
- **Zero tolerance for slop on output:** plain language, no em dashes, no "·". Minimal jargon, analogy, or
  consulting phrasing. You have read the pages, the reader has not. Write from where they stand, not
  where you ended up: name a thing before relying on it, give the premise before the conclusion, and
  unpack a wiki term the first time it appears. Headings, sentences, and claims all have to land for
  someone who knows only their own question. If it only makes sense because you know what you read to get
  there, it is not finished.
- Report what the pages say. Do not steer; the user leads. Cut anything that does not change what they do
  next.
- No table unless it is shorter than the prose it replaces.
- Say so if the wiki is silent or partial. Label anything outside the wiki *(outside the wiki)*. Never
  cite a page you did not open, or attribute a claim a page does not make.
- Restate the bottom line at the end only if the answer ran past 200 words.
- Close with `Wiki pages referenced:` and the ids, comma separated. Raw source quotes only on request,
  cited in the wiki's own source form.

**Before sending, check both and fix what fails:**
1. Read only your headings and labels. Would someone who has read nothing but their own question know
   what each section gives them?
2. Every load bearing claim names its page inline as `id`; everything else is covered by the closing list.

## 5. Failures

- Id or file missing → grep `_catalog.yaml` for the id; if absent, say the page does not exist and answer
  from what does.
- Domain index disagrees with page frontmatter → frontmatter wins; note it and suggest `/wiki-maintain`.
- Catalog stale (id in catalog but no file, or file with no catalog entry) → answer from the file;
  suggest `/wiki-maintain` to regenerate.
- Router stale (§1.2) → say which folders/tables disagree; suggest `/wiki-maintain`.
- Wiki is an empty shell (`_bootstrap.md` present, no `NN-*` folders) → say there is no content yet and
  point at `/wiki-maintain` plus `_bootstrap.md`. Do not answer from general knowledge as if it were the
  wiki.

## 6. Budget

Typical: router + 1 domain index + ≤3 pages ≈ 6–9k tokens. Ceiling: 2 domain indexes + 4 pages + 2
`related` hops ≈ 15k. Never load `_catalog.yaml`, `_overview.md`, or `_schema.md` whole for a query. Stop
reading as soon as a bottom line answers the question.
