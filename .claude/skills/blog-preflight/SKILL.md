---
name: blog-preflight
description: >
  Pre-publish review for a Quarto blog post (index.qmd) in this digital
  garden. Runs narrative-flow/heading review, grammar and spelling checks
  (proselint + aspell), and blog front-matter/component checks (title,
  description, date, featured image, categories) in three separate stages,
  pausing for the user's feedback between each. Use when the user asks to
  "review this post before publishing," "run preflight," "check this post
  is ready," or similar.
allowed-tools: Read, Bash, Edit, Grep, AskUserQuestion
metadata:
  version: "1.0"
---

# Blog Preflight Review

Review a Quarto blog post in three sequential, user-gated stages before
publishing. Each stage produces a distinct kind of feedback and ends with a
checkpoint — do not move to the next stage until the user has responded to
the current one. This mirrors how post revisions actually happen: judgment
calls first, mechanical fixes second, boilerplate/metadata last.

## Locating the target post

If the user names a file or a post directory, use that (resolve to its
`index.qmd`). Otherwise, prefer the currently open file in the IDE if it's a
post's `index.qmd`; if ambiguous, ask which post to review.

Read the full post before starting Stage 1 — every stage below assumes
you've already read it once, so don't re-read the whole file at the start of
each stage, only the sections you need to re-check after edits.

## Stage 1 — Discussion: narrative flow & section headings

This stage is judgment, not mechanics. Do not edit anything here unless the
user explicitly asks you to during the discussion.

Assess and report on:

- **Arc**: does the post deliver on what the title and `description` in the
  front matter promise? Is there a clear throughline from intro to
  conclusion?
- **Section structure**: does each heading's content actually match what the
  heading promises? Flag sections that drift into a different register
  (e.g. a definitional section that trails into personal anecdote without a
  new heading) or that duplicate an argument made elsewhere.
- **Headings as a set**: read all headings together. Do they read as a
  coherent sequence (each one a distinct, well-named beat), or do any feel
  like a placeholder, or clash in style/register with the others?
- **Transitions**: are there abrupt jumps between paragraphs or sections
  that would benefit from a bridging sentence?

Present findings grouped by section (or by heading), citing line numbers.
Don't propose line-by-line rewrites yet — flag the issue and, where useful,
sketch the direction a fix could take, but leave the actual wording for the
user to weigh in on.

**Checkpoint**: ask the user whether to discuss further, make specific
narrative/heading changes now, or move on to Stage 2. Only proceed once they
say so.

## Stage 2 — Straightforward corrections: grammar, typos, proselint, aspell

This stage is mechanical: real errors with an unambiguous fix. Style
preferences (e.g. proselint's "preventative" vs "preventive", or the
"Hopefully" skunked-term warning) are not errors — surface them as optional
notes, not fixes, and don't apply them without the user asking.

1. Run the linters:

   ```bash
   ${SKILL_DIR}/scripts/lint.sh <path/to/index.qmd>
   ```

   This runs `proselint check` and `aspell --mode=markdown --lang=en list`
   (deduped) over the file.

2. Triage the aspell output: proper nouns, acronyms, and names (e.g. `CoC`,
   `useR`, contributor names) are expected misses — don't flag these as
   issues. Anything else is a likely typo.

3. Triage the proselint output: separate genuine issues (curly vs straight
   quotes, real redundancy, doubled words) from stylistic preferences the
   tool always flags (skunked terms, cliché detection, spelling variants).
   Do **not** propose changes to text inside direct blockquote citations —
   quoted material should be corrected only if it's clearly a transcription
   error (extra/missing letter), never for style.

4. Do a manual pass for what the tools miss: subject-verb agreement,
   duplicated/missing words, dangling articles ("a the", "on behalf the"),
   incomplete sentences.

5. Present the consolidated list of proposed fixes (typos, grammar, and any
   proselint hits worth acting on), clearly separated from the "optional/
   style preference, not applying unless asked" notes.

**Checkpoint**: ask the user to confirm before applying fixes. Apply only
what they approve, then move to Stage 3.

## Stage 3 — Format & blog components

Check the post's front matter and supporting files against this repo's
conventions, which are set by `posts/_metadata.yml` (defaults: `author`,
`image: featured.png`, `date-modified: last-modified`, `citation: true`) and
by the pattern of existing posts under `posts/*/index.qmd`.

Check:

- **Title**: present, non-generic, matches the post's actual content.
- **Description**: present, reads as a real sentence (not a fragment), and
  accurately previews the post — compare it against what Stage 1 found the
  post actually delivers.
- **Date**: valid, not in the future relative to today, and plausible
  against the file's git history (`git log --follow --format='%ad %s'
  --date=short -- <file>`) — flag if the front-matter `date` looks
  inconsistent with when the post was actually first drafted/committed.
- **date-modified**: should be `last-modified` (the site-wide default) unless
  there's a deliberate reason to override it — flag if missing or hardcoded.
- **Featured image**: if `image:` is set explicitly, confirm the referenced
  file exists in the post's folder and isn't a placeholder/broken asset
  (`file <path>` to sanity-check it's a real image). If unset, note that it
  falls back to the sitewide default (`featured.png`) and confirm that file
  actually exists in this post's folder.
- **Categories / tags**: most posts in `posts/*/index.qmd` set `categories:`
  (check a few siblings with `grep -l '^categories:' posts/*/index.qmd` if
  unsure of current convention). If this post has none, flag it — ask the
  user what categories apply rather than inventing some.
- **Any other front-matter fields** present on sibling posts but missing
  here (e.g. `draft:`) — only flag if their absence looks unintentional.

Present findings as a short checklist (met / missing / worth a look), citing
what convention each check is based on.

**Checkpoint**: ask the user to confirm before editing front matter. Apply
only what they approve.

## Wrap-up

After Stage 3, give a one-paragraph summary of what changed across all three
stages and note that the skill can be re-run before the final publish/commit
if more edits happen afterward.
