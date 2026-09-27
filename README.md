# Claude-Wiki

An empty instance of a retrieval wiki. The contract, the tooling and the top-level file skeletons are
here; there is no content and there are no domains yet. Point it at a subject and fill it.

The format exists to be **read by a model at run time**, not by a person cover to cover. Pages are small,
atomic and answer-first, each carrying enough routing metadata that a reader can pick three or four of
them out of hundreds and answer from those alone, for 6-9k tokens.

## Contents

No domain folders exist yet. `_catalog.yaml` is present but empty; the validator regenerates it on every
`-WriteCatalog` run.

| File | Use |
|---|---|
| `_bootstrap.md` | How to turn this shell into a wiki: domains, vocabularies, source form, and the gate that says you are done. **Start here.** Delete it once the wiki is populated. |
| `_schema.md` | The page contract and writing standard. Complete, except §5 and §6, which are the subject's own vocabularies and are marked TODO. |
| `_sources.md` | What a citation looks like and what may be cited. A placeholder: it gets built when you set the wiki up, and no page can cite anything until it is. |
| `_index.md` | The router: domain table with *route here when* / *not here*, plus the read protocol. Protocol is written; the domain table is empty. |
| `_playbook.md` | The decisions in the order they get made. Skeleton — write it once the domains have settled. |
| `_overview.md` | The subject end to end: stages, artifacts, exit criteria, how the wiki is organized. Skeleton, written last. |
| `_glossary.md` | Term, definition, and the page id where the term is treated. Headers and rules only, no rows. |
| `_maintenance.md` | How to change a populated wiki: file roles, operation touch-lists, completion checklist, changelog. Complete; the changelog is empty. |
| `_tools/validate.ps1` | Checks every page and the structure against `_schema.md`. `-WriteCatalog` writes `_catalog.yaml`. Complete, with the subject vocabularies empty. |
| `skills/` | The two skills that drive a wiki in this format. See *Skills* below. |
| `.claude-plugin/` | `plugin.json` and `marketplace.json`, which make this repository installable as a Claude Code plugin. Not part of the wiki contract; irrelevant once cloned as a shell. |

## The contract in brief

`_schema.md` is authoritative; this is the shape of it.

A **domain** is a folder named `NN-slug` holding an `_index.md` and its pages. Its index states the
stage's purpose, inputs, outputs and exit criteria, lists its decisions in order, and carries generated
tables of its pages and pitfalls. One level of containment is allowed: a `NN-container/<leaf>/` where each
leaf is itself a domain.

A **page** is `<slug>.md`, or `pitfall-<slug>.md` for a named failure case. Its id is
`<domain-slug>.<filename>`. Frontmatter carries, in fixed order: `id`, `type`, `title`, `summary`,
`domain`, `stage`, `topics`, `depth`, `applies_when`, `not_for`, `sources`, `related`. The body opens with
`**Bottom line:**` and then uses the mandatory headings for its type, in order, with none added.

Six page types: `concept` · `decision` · `pattern` · `pitfall` · `checklist` · `procedure`.

Two fields carry the retrieval load and are read far more often than any body: `summary` must state the
answer in 40 words or fewer, never the topic; `applies_when` must be phrased as intents a user would
actually say, not keywords.

Length caps on body words: 300-900 for concept, decision, pattern and procedure; 350 for a pitfall; 400
for a checklist. The validator enforces them.

## Starting a new subject

`_bootstrap.md` is the real guide, in the order that works. In outline:

1. Name the subject in one sentence and list the audiences it serves. The audiences become `depth`.
2. Decide the domains and write each one into the `## Domains` table in `_index.md`. Every row needs a
   real *not here* — that column is what makes routing work.
3. Decide what a citation looks like and fill in `_sources.md`. Do this before writing pages;
   retrofitting citations across a populated wiki is expensive.
4. Fill the `topics`, `stage` and `depth` vocabularies in `_schema.md` §5, and the canonical names in §6.
   Each has a matching list at the top of `_tools/validate.ps1`; change them together.
5. Write pages with `/wiki-maintain`, which plans each change and waits for your approval before writing.
6. Write `_overview.md` and `_playbook.md` last, then run `_tools/validate.ps1 -WriteCatalog` and require
   `structure issues: 0` with no vocabularies reported as skipped.

The validator's subject vocabularies all start empty, and **an empty list means that check does not
run** — it reports which ones at the end of each run rather than failing every page over a vocabulary
that does not exist yet. That is what lets an unfilled wiki validate cleanly, and it is also why an
unfilled vocabulary quietly stops protecting you. Fill them early.

## Skills

Two skills drive a wiki in this format, kept in `skills/` here so the folder travels intact:

- **`wiki-navigate`** — read-only lookup. Route, select, read, answer.
- **`wiki-maintain`** — changes. Plan, confirm, write, verify. It reads `_bootstrap.md` when the request
  touches domains, vocabularies or the source form, or whenever `_schema.md` still says TODO.

Neither hardcodes a path. Each locates a wiki at run time by looking for a folder containing both
`_index.md` and `_schema.md` — the working directory first, then its children, then its ancestors — and
asks you when the answer is ambiguous. So one installation of the skills drives every wiki you own.

## Install

### The skills, as a plugin (recommended)

The repository is also a single-plugin marketplace, so the skills install and update in place:

```
/plugin marketplace add huxwaitt/claude-wiki
/plugin install claude-wiki@claude-wiki
```

Both skills are then available in every session, and `/plugin update` picks up later changes. Claude Code
namespaces a plugin's components under the plugin name, so invoked explicitly they are
`claude-wiki:wiki-navigate` and `claude-wiki:wiki-maintain`. The natural-language triggers are unaffected
— "consult the wiki", "update the wiki" and the rest route the same way, which is how they are normally
reached.

Prefer the plugin over copying folders: a hand-copied skill silently drifts from this repository, and
nothing tells you when it has. If you want the bare `/wiki-navigate` and `/wiki-maintain` spellings,
install by hand instead.

To install by hand instead, copy the two folders in `skills/` into `~/.claude/skills/`
(`%USERPROFILE%\.claude\skills\` on Windows).

### The wiki shell, for a new subject

Use the green **Use this template** button, or clone:

```
git clone https://github.com/huxwaitt/claude-wiki.git <your-wiki>
cd <your-wiki> && rm -rf .git && git init
```

Then follow `_bootstrap.md`. Installing the plugin does not give you a wiki shell, and cloning the shell
does not give you the skills — a full setup is both, once each.

### Requirements

PowerShell 7 (`pwsh`) for `_tools/validate.ps1`. The validator builds every path with `Join-Path` and
resolves its own root, so it runs on Windows, macOS and Linux, from any working directory.

## Where this came from

The format, the contract and the tooling were lifted from a populated wiki of the same design and
stripped of its content on 2026-08-17. What remains is the reusable part: the page contract, the
validator, the maintenance procedure and the file skeletons. Nothing of the original subject is left.
