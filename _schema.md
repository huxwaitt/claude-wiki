# Page Contract and Writing Standard

This file is the single source of truth for how every page in this wiki is written. Writers (human or
agent) follow it exactly. Readers (the navigate skill) can rely on it.

Sections §1–§4 and §7–§9 are the format and hold for any subject. **§5 and §6 are subject-specific and
start empty.** Fill them before writing page one; `_bootstrap.md` explains how to derive them, and
`_tools\validate.ps1` holds the same lists and must be changed with them.

## 1. How this wiki is read at runtime — write for this

The navigate skill loads pages **cold, in isolation, with a small token budget**, in this order:

1. `_index.md` (router) → picks 1–2 domains.
2. `<domain>/_index.md` → picks ≤4 pages by `summary` + `applies_when`.
3. The pages themselves. `related` links only if a gap remains.
4. The original source, only when exact wording is requested. `_sources.md` says what the sources are and
   where they live.

Consequences for writing:

- The `summary` field and the `**Bottom line:**` line are read far more often than the body. They must
  carry the answer.
- A page is never read after another page. Nothing may depend on prior context.
- Headings are navigation. Same headings, same order, every page of the same type.
- Every extra word costs the reader budget. Compress.

## 2. Voice — "written to be retrieved, not read"

| Rule | Do | Don't |
|---|---|---|
| Answer first | H1, then `**Bottom line:**` stating the recommendation/definition in ≤2 sentences | Build up to a conclusion |
| Self-contained | Restate the one sentence of context the page needs | "As above", "earlier", "in this module", "next lesson", unexplained pronouns |
| Conditional guidance | `If <observable condition> → <action>. Because <reason>.` — one per bullet | "It depends", "consider", "may want to" |
| Imperative, reader-facing | "Choose…", "Place the check…", "Log…" | "You will learn…", "Let's…", "In this course…" |
| Compressed | Bullets; tables for comparisons; ≤25 words per bullet | Paragraph prose for lists; throat-clearing ("It is important to note") |
| Canonical terms | The names in §6 exactly | Synonyms, coined terms, abbreviations not in §6 |
| Cross-reference by id | `→ \`domain.page-slug\`` | "See the page on X", titles, relative paths |
| Faithful to source | Numbers, thresholds, examples exactly as in the source | Invented facts, external knowledge, rounding, "typically" |
| Silence over padding | Omit what the source does not say | Filling gaps with general knowledge |
| Verbatim anchors | ≤2 blockquotes per page, ≤40 words each, exact, with inline source tag | Long quotes, paraphrase in quotes |
| No pedagogy | — | Exercises, quizzes, checkpoints, reflection prompts, congratulations, "what you'll be able to do", module navigation, time estimates |

Observable conditions are things a reader can check: a measurable threshold, a state of the system, a
property of the team or the data, whether a deterministic alternative exists, whether a human is in the
loop. Not "if appropriate".

Three fidelity conventions, if your sources are transcripts, recordings, or anything else where the
literal text was not captured exactly:

- **Identifiers.** Normalize a spoken identifier to its code form only when the source is unambiguous.
  Where the literal is not captured, say so and name where to confirm it. Never invent a literal.
- **Volatile claims.** Anything that can change without notice — availability, pricing, limits, "as of
  today" — keeps the source's wording verbatim and carries the capture date in parentheses.
- **Attributed conflicts.** When two sources disagree, state both, each attributed to its source. Never
  silently pick one; drop a statement only when current evidence shows it false today.

## 3. Frontmatter — the routing surface

Every page starts with exactly this frontmatter. Field order fixed. YAML lists always in bracket or dash
form as shown.

```yaml
---
id: <domain-slug>.<page-slug>               # equals filename minus .md (pitfalls: pitfall-<slug>); slug = the page's own folder (a container child uses its leaf name)
type: decision                              # concept | decision | pattern | pitfall | checklist | procedure
title: <the page's title>                   # ≤ 12 words, noun phrase or gerund
summary: >-                                 # ≤ 40 words. STATES THE ANSWER, not the topic. Never "This page covers…"
  <the answer, compressed>
domain: <NN-slug>                           # folder name; a container child writes container/leaf
stage: [<stage>]                            # 1–2 from the controlled list in §5
topics: [<topic>, <topic>]                  # 1–4 from the controlled list in §5
depth: <level>                              # from the controlled list in §5; a range if the page serves two levels
applies_when:                               # 2–5 reader intents, phrased as they would be said out loud
  - <intent>
  - <intent>
not_for:                                    # 0–3 disambiguators: "<misrouted intent> → <other page id>"
  - <misrouted intent> → <other page id>
sources:                                    # ≥1, in the form defined in _sources.md
  - <source> § <exact heading>
related: [<page id>, <page id>]
---
```

`summary` test: read only the summary — can the reader give a first-pass answer? If not, rewrite it.
`applies_when` test: would someone actually say this? Write intents, not keywords.

## 4. Body templates — one per type, headings mandatory in this order

Omit a heading only where marked *(optional)*. Never add headings. H1 = `title`.

### concept — what something is and how it works
```
# <title>
**Bottom line:** <definition + why it matters, ≤2 sentences>
## What it is
## How it works
## Implications                          (what this forces or enables downstream)
## Related decisions                     (bullets: → `id` — when to go there)
## Sources
```

### decision — a choice with options and a recommendation
```
# <title>
**Bottom line:** <default recommendation + the condition under which it does not hold>
## Decide this when                      (observable triggers)
## Options                               (table: Option | Best when | Avoid when | Cost / complexity)
## Decision criteria                     (ordered by weight)
## Recommendation by scenario            (bullets: If … → choose … . Because … .)
## Tradeoffs and consequences            (what each choice commits you to downstream)
## Pitfalls                              (optional; bullets: → `pitfall-id` — symptom)
## Sources
```

### pattern — a reference architecture or recipe
```
# <title>
**Bottom line:** <what it is for, in one sentence>
## Use when
## Structure                             (components, flow, who or what sits where)
## Variations                            (optional)
## Failure modes                         (bullets; link pitfalls where they exist)
## Sources
```

### pitfall — a named failure case
```
# <title>                                (keep the source's name for it)
**Bottom line:** <the lesson, one sentence>
## Symptom                               (what the reader observes)
## Root cause
## Prevention or fix                     (bullets: → `decision/pattern id` — what to do)
## The story                             (≤150 words, compressed, no dialogue)
## Sources
```

### checklist — a verifiable readiness list
```
# <title>
**Bottom line:** <what "done" means for this list>
## Checklist                             (- [ ] items; each independently verifiable; ≤20 items)
## Sources
```

### procedure — steps to configure or set up something
```
# <title>
**Bottom line:** <outcome of the procedure>
## Preconditions
## Steps                                 (numbered; each step one action)
## Verification                          (how to confirm it worked)
## Sources
```

`## Sources` body format: bullets in the same form as frontmatter `sources`, verbatim. An inline
blockquote attribution in the body may use a shortened form; the full form still appears in `## Sources`.

Length caps (body words, excluding frontmatter and the `## Sources` block): concept/decision/pattern/
procedure 300–900 · pitfall ≤350 · checklist ≤400. A table-heavy page (≥15% of its body words inside
tables) may exceed its cap by 10% — tables are the densest information on a page and are not cut to
satisfy the cap. `_tools\validate.ps1` enforces exactly this rule.

## 5. Controlled vocabularies — TODO: define for this subject

Nothing here is filled in. Every list below is empty, `_tools\validate.ps1` has the matching lists empty,
and while they are empty the validator does not check the corresponding field. Fill both together.
`_bootstrap.md` covers how to derive each one.

**Domains / slugs** — TODO. A domain is a folder `NN-slug`. List every domain here with its slug, in
order. If the subject splits into a sequence plus a reference series, say which domains are which, and
state the placement test that decides where a new page goes. One container level is allowed: a
`NN-container\<leaf>\` whose leaves are themselves domains. No deeper nesting.

**stage** — TODO. The phases a reader moves through, if the subject has any. 1–2 per page. Delete this
field from §3, `validate.ps1` and the templates if the subject has no meaningful phases.

**topics** — TODO. A closed list, 1–4 per page. Derive it from questions readers actually ask, not from
the table of contents of your sources.

**depth** — TODO. The audience levels the wiki serves, and what each one means. Ranges allowed. If the
same subject needs materially different guidance at two levels, write separate pages linked by `related`,
not one tiered page.

## 6. Canonical names — TODO: define for this subject

TODO. The exact spelling of every proper noun, product, feature and term of art in the subject. One
spelling per thing; a page uses it and no synonym. Add a name here the first time a page needs it, and
add the synonyms readers might use to `_glossary.md` as aliases so search still finds the page.

Use the source's own term when it names something specific; on first use in a page put it in **bold**
once.

## 7. Domain index — `<domain>/_index.md`

```
# <NN> <Domain title>

## This stage
- Purpose:
- Inputs:
- Outputs / artifacts:
- Exit criteria:
(≤8 lines total; a domain that is not a stage may use "This section" and omit inputs/exit criteria)

## Decisions in order
1. `id` — one line: what is decided
(ordered as a reader would encounter them; concept/pattern pages that gate a decision may be interleaved)

## Pages
| id | type | depth | summary | applies_when |
(all non-pitfall pages; summary and applies_when copied verbatim from frontmatter, applies_when joined with " · ")

## Pitfalls
| id | symptom |
```

A reference (non-stage) leaf domain uses the same format with "This surface" in place of "This stage"
(Purpose · Covers · Not here) and "Pages in order" in place of "Decisions in order". A container's own
`_index.md` is a router table only: `| domain (backticked container/leaf) | route here when | not here |`.

## 8. Exclusions and fidelity

Excluded from every page: exercises, checkpoints, quizzes, cumulative tasks, "predict the behavior",
sort/match/place/critique activities, calculators/builders, completion or congratulations screens,
navigation lists, "what you will be able to do" orientation, time estimates, disclaimers.

Kept and converted: explanatory prose → concept/decision/pattern/procedure; named failure narratives →
pitfall; glossaries → `_glossary.md`; takeaways and recaps → folded into bottom lines and the domain's
checklist page.

A screen whose teaching content *is* the structure of a reusable artifact is content, even when it is
wrapped in "now draft yours" steps. Instructions that apply only to the learner's own project are not.

Every sentence in a page must be traceable to a listed source. Merging and normalizing across sources is
expected; adding is not.

## 9. Files that are generated, not authored

`_catalog.yaml` (all frontmatter, one file) · the `## Pages` and `## Pitfalls` tables in each domain
index (regenerable from frontmatter). If frontmatter and index disagree, frontmatter wins.
