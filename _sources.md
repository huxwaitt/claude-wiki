# Sources

TODO. This file is built when the wiki is set up. Until it is filled in, no page can cite anything.

Every page cites its sources twice: a `sources:` list in the frontmatter and a matching `## Sources`
section in the body. Both use the same form, and `_tools/validate.ps1` enforces it.

## What to decide

1. **What counts as a source** for this subject — a document, a specification, a recorded session, a
   codebase, a person. Whatever it is, a citation has to identify one specific place inside it, not just
   the thing as a whole.
2. **The citation form.** The default is:

       <Source name> § <exact heading>

   Add one level of prefix if a source has parts a reader would otherwise have to search:
   `<Source> / <Section> § <heading>`. Resist more levels; a citation is a locator, not a path.
3. **Whether the sources are reachable** from here. If they are files beside the wiki, say so and say
   how to resolve a citation to one. If they are not — something hosted elsewhere, a paywalled standard,
   someone's knowledge — say that plainly, so nobody goes looking for a file that does not exist.

## What to write here once decided

- The citation form, with a worked example.
- The catalogue: every source that may be cited, with whatever locator a reader needs to reach it.
- The rule for adding a source later, which is that this file and `$sources` in
  `_tools/validate.ps1` change together. The validator rejects a citation naming anything not in that
  list, so an unlisted source cannot leak into a page unnoticed.

## Sources with no external origin

A claim supplied by a maintainer rather than a source is exceptional and is recorded as:

    Maintainer/<YYYY-MM-DD> § <one line: who supplied it and on what basis>

The date must match a `## Changelog` entry in `_maintenance.md` naming the page. The validator enforces
the pairing, so this cannot be used to slip unsourced content in quietly.
