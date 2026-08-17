# Bootstrap — standing this wiki up

`_maintenance.md` covers changing a wiki that already has content. This file covers the part before that:
turning an empty shell into a wiki about something. Delete it once the wiki is populated and the TODOs in
`_schema.md` §5, `_schema.md` §6, `_sources.md` and `_tools\validate.ps1` are gone.

Read `_schema.md` first. It is the contract; nothing here overrides it.

## The order that works

Do these in order. Each one is hard to change after the step below it is done.

1. Name the subject and the audiences (§1 below).
2. Decide the domains (§2). This is the decision everything else hangs off.
3. Decide the `sources` form and fill `_sources.md` (§3).
4. Build the `topics`, `stage` and `depth` vocabularies (§4).
5. Start the canonical-names list (§5) — it grows as you write, but start it now.
6. Write pages. Run the validator constantly.
7. Write `_overview.md` and `_playbook.md` last (§6).

## 1. Subject and audiences

Write one sentence: *this wiki answers questions about X, for people who are doing Y.* If you cannot,
the wiki is not scoped yet and the domains will not divide cleanly.

Then list the audiences. These become `depth`. Two or three levels is normal; one is fine. What makes a
level real is that the *same question* gets a materially different answer at each — not that the readers
have different job titles. If the answer is the same and only the vocabulary differs, that is one level
and a glossary, not two levels.

## 2. Domains

A domain is a folder `NN-slug` holding an `_index.md` and its pages. Getting these right is most of the
work.

**Derive them from the reader's journey, not from your sources' table of contents.** Source material is
organized for teaching or for reference; a wiki is organized for a person mid-task with one question.
The test for a domain is: *can I write a "route here when" line that a reader recognizes as their own
situation, and a "not here" line that catches what would otherwise be misfiled?* A domain that needs
neither is not a domain — it is a topic tag.

Two shapes worth knowing, which can be combined:

- **A spine.** Domains are the stages of a process, in the order work happens. Good when the subject is
  something people *do*, and the answer to "what next" is the wiki's most valuable output.
- **A reference series.** Domains are surfaces, products or components, each answering "how does this
  specific thing work". Good when the subject has parts with their own mechanics.

If you use both, state the placement test in `_schema.md` §5 in one line — for example, *"is this the
how-to for one specific component?" → reference; otherwise spine* — and make the dependency one-way:
spine pages point into reference pages, never the reverse. Without that rule, pages land in both series
and routing degrades as the wiki grows.

One container level is allowed for a reference series: a `NN-container\<leaf>\` where each leaf is itself
a domain with its own `_index.md`. No deeper nesting. The container's `_index.md` is a router table only.

Write every domain into the `## Domains` table in `_index.md` as you create it, and create each domain's
`_index.md` per `_schema.md` §7 at the same time.

## 3. The source form

Do this before writing pages, because retrofitting citations across a populated wiki is expensive.

Work through `_sources.md`, which lists what to decide. Then:

- Put the form in `_schema.md` §3, in the `sources:` comment.
- Put the catalogue of accepted source names in `_sources.md`.
- Mirror that catalogue into `$courses` in `_tools\validate.ps1`.

The variable is named `$courses` because it was inherited from a wiki built on courses; rename it if the
name misleads for your subject. What matters is that it holds every accepted source name and nothing
else, so a typo in a citation is caught rather than silently accepted.

## 4. topics, stage, depth

All three live in `_schema.md` §5 and, in the same form, at the top of `_tools\validate.ps1`. **While a
list is empty the validator skips that check and says so at the end of its run.** That means an
unpopulated wiki validates cleanly — and also that an unfilled vocabulary silently stops protecting you.
Fill them early.

**topics.** A closed list, 1–4 per page. Derive it from questions readers actually ask. The failure mode
is a list that mirrors your domain names, which adds nothing to routing, or a list that grows to 80 tags,
which stops discriminating. If two topics never appear apart, merge them. If a topic tags more than about
a third of the pages, it is not a topic. Aim for something like 20–40 for a substantial subject.

**stage.** Only if the subject has real phases. 1–2 per page. If it does not, delete `stage` from
`_schema.md` §3, from the frontmatter templates, and from the validator's required-key list — an always-
identical field costs the reader budget and tells them nothing.

**depth.** The audience levels from §1, plus a written definition of each so two authors tag the same page
the same way. Set `$depthPattern` in the validator to match. Ranges are allowed; separate pages linked by
`related` beat one page trying to serve two levels.

## 5. Canonical names

One spelling per thing, in `_schema.md` §6. Add a name the first time a page needs it. Every synonym a
reader might type goes in `_glossary.md` under `## Aliases`, pointing at the canonical term — that is how
search still finds the page when the reader uses the other word.

This list is a contract, not a style preference: pages that spell the same thing three ways cannot be
grepped reliably, and `_catalog.yaml` search is how symptom queries get answered.

## 6. Overview and playbook, last

`_overview.md` states counts and per-domain summaries; `_playbook.md` orders every decision page. Both go
stale the moment the domain set shifts, so write them once the shape has stopped moving. The validator
checks the counts in `_overview.md` and `_index.md` against the live files.

## 7. The gate

Before calling the wiki usable:

- [ ] `_schema.md` §5 and §6 contain no `TODO`.
- [ ] `_sources.md` lists every accepted source; `$courses` in the validator matches it exactly.
- [ ] `$stages`, `$topics`, `$depthPattern` are filled, or the field is deliberately deleted from the contract.
- [ ] Every domain has an `_index.md` per `_schema.md` §7 and at least one page.
- [ ] `_tools\validate.ps1 -WriteCatalog` reports `structure issues: 0`, `files with issues: 0`, and no
      skipped vocabularies.
- [ ] `_index.md` domain table has a real *Not here* for every row.
- [ ] `_overview.md` and `_playbook.md` written, counts correct.
- [ ] This file deleted.
