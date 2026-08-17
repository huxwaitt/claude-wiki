---
name: wiki-maintain
description: Change a retrieval wiki built to this contract (a `_index.md` router plus a `_schema.md` page contract), such as the Advisory-Wiki, without breaking its structure — edit a page, add a page/pitfall/domain, rename or retire a page, add glossary terms, set up an empty wiki, or re-validate. Use when the user says "/wiki-maintain", "update the wiki", "add a page/domain/pitfall to the wiki", "change what the wiki says about…", "the wiki is wrong about…", "add a term to the glossary", "set up the wiki", or "re-validate the wiki". Read-only lookups belong to /wiki-navigate.
version: 2.0.0
---

# wiki-maintain

This skill hardcodes no path. A wiki is any folder holding both `_index.md` and `_schema.md`.

Plan → confirm → write → verify. **No file is created, modified, renamed, or deleted until the user has
seen the exact change and explicitly approved it. This is absolute — it holds for one-line edits, typo
fixes, formatting, and changes the user already described in their own request. A request to make a
change is not approval of the change.**

## 1. Load the contract (every invocation; never from memory)
0. Resolve `<WIKI_ROOT>` the way `/wiki-navigate` §0 does: a path in the request wins; else a saved
   memory entry, verified; else search the working directory, its children, then its ancestors and their
   children, for a folder holding `_index.md` + `_schema.md`; several hits → ask; none → stop.
1. Read `<WIKI_ROOT>\_maintenance.md` (procedure, touch-lists, checklist, changelog).
2. Read `<WIKI_ROOT>\_schema.md` (voice, frontmatter, templates, vocabularies, canonical names, index
   format).
3. **If `<WIKI_ROOT>\_bootstrap.md` exists, read it too** whenever the request touches domains, the
   controlled vocabularies (`topics`, `stage`, `depth`), canonical names, or the source form — and
   whenever `_schema.md` §5 or §6 still contains `TODO`, whatever the request. An unpopulated wiki is set
   up by following `_bootstrap.md`, not by improvising a schema.
4. Discover structure at runtime: list `<WIKI_ROOT>\NN-*` folders and, for a container (a `NN-*` folder
   holding only leaf folders), its leaves; read the target domain's or leaf's `_index.md`; grep
   `_catalog.yaml` (never load it whole) for ids/terms the request mentions.
5. Run `<WIKI_ROOT>\_tools\validate.ps1` once to capture the pre-change baseline (issue list, counts, and
   any vocabularies it reports as not yet defined).

## 2. Classify
Map the request to one operation in `_maintenance.md` §3 (edit page content · add page · add pitfall ·
split/merge · rename/deprecate · add domain · glossary term · top-level file · re-validate only · bulk
import). Take that row's touch-list as the minimum change set. Compound requests compose (split = add +
rename/deprecate). Only *bulk import* fans out to sub-agents; everything else is one sequential edit.

If the request needs new facts, locate the exact source and heading now, in the form `_sources.md`
defines. If no source covers it, the change is user-supplied knowledge — say so, and record it as
`Maintainer/<date>`. If it needs a source not yet in `_sources.md`, that file and the `$courses` list in
`validate.ps1` are part of the change set.

Setting up an empty wiki is its own path: follow `_bootstrap.md` in its stated order, and treat each of
its steps as a separate confirm-then-write cycle rather than one bulk approval.

## 3. Confirm (blocking, absolute)
Fill the change plan in `_maintenance.md` §6 — paths to create/modify/rename, page ids, frontmatter
deltas, domain index rows and decisions-in-order line, playbook line, glossary rows in stored form
(`| term | ≤25-word definition | \`see-id\` |`), overview/root count or structure text, schema/validator
changes (flag), sources per claim (flag `Maintainer/<date>`), any new source added to `_sources.md` and
`$courses`, catalog regen, draft changelog line. Present it and stop. Proceed only on explicit approval
given after seeing the plan. For any edit small enough that a plan feels excessive, show the exact
before/after text instead — but still stop and wait. A scope change during execution → re-confirm the
delta before continuing.

## 4. Execute
Write exactly the approved plan, per `_schema.md`: fixed frontmatter order, type template headings,
canonical names, `If … → … . Because …` guidance, sources in the wiki's own form, nothing invented. Copy
`summary`/`applies_when` verbatim into the domain index row. Rename/remove: grep the whole wiki for the
old id and rewrite every hit; no stubs.

## 5. Verify and report
1. Walk `_maintenance.md` §7 item by item; fix until each is true.
2. Run `<WIKI_ROOT>\_tools\validate.ps1 -WriteCatalog`. Required: `structure issues: 0`; per-page issues
   no larger than baseline and none on touched files — otherwise fix, or list each remaining one with the
   reason accepted. If the validator reports vocabularies not yet defined, repeat that in your report.
3. Append the `## Changelog` line (§8) with the validator tail.
4. Report: files created/modified/renamed, ids affected, glossary rows added, validator result, accepted
   issues. Do not report complete with an open checklist item.

## Rules
- Never edit `_catalog.yaml` by hand, or any source material the wiki cites.
- Do not hardcode domain names, ids, or counts from memory — read them from the files each time.
- `_schema.md` changes are contract changes: call them out in the plan and the report. A change to §5 or
  §6 must be mirrored in `_tools\validate.ps1`, and a change to the source form must be mirrored in
  `_sources.md`.
