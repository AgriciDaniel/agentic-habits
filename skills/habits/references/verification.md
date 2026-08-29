# Verification record

What in this skill is tested, what is quoted from documentation, and what is
neither. Kept separate from the claims themselves so a reader can check the
evidence without taking the prose on trust.

Environment: Claude Code 2.1.251, Linux, 2026-08-29. Every test ran in a
throwaway project directory, headless, on the cheapest available model, and the
directory was deleted afterwards.

## Tested, with the method

### The rules file loads and changes behavior

A project file at `.claude/rules/habits.md` with no `paths` frontmatter, holding
one habit whose action was to answer a given word with a fixed token. A fresh
`claude -p "canary"` in that directory returned the token and nothing else.

This is the load-bearing claim of the whole skill. A habit in a rules file is
loaded into a new session without being mentioned, and it changes what the agent
does. **Result: confirmed.**

### The metadata comment is stripped

Same file, with `marker=COMMENT-VISIBLE-ZQ7` inside the `<!-- habit: -->`
comment. Asked, with no tools available, to reproduce the section character for
character and then report whether the marker appeared anywhere in its loaded
instructions.

The reproduction stopped exactly at the comment boundary and the answer was
`MARKER-ABSENT`. **Control:** the same marker moved into plain body text
returned `MARKER-SEEN`, so the probe detects a marker when one is present.
**Result: confirmed for a rules file on this version.** The documentation states
this behavior for CLAUDE.md; the test extends it to `.claude/rules/`.

Treat it as version-specific. If bookkeeping ever starts showing up in the
agent's visible reasoning, this test is the one to rerun.

### Path-scoped rules are absent until a matching file is read

A rules file with `paths: ["src/**/*.ts"]` and the same canary habit. Asked the
canary word with no file read: a generic answer, the habit did not fire. Asked
again in a run that first read `src/a.ts`: the token came back.

**Result: confirmed, both directions.** This is what makes a path habit worth
using, and it is also why a path habit will not show in `/context` until
something matching is opened.

### The package validates and the skill resolves to `/habits`

`claude plugin validate .` and `claude plugin validate . --strict` both pass.
Copied to a project `.claude/skills/habits/`, the skill was discovered and
reported its invocation as `/habits`. **Result: confirmed.**

### The skill listing may omit the description

In an installation with a large skill inventory, the listing showed this skill
by bare name with no description. A control skill with a one-line description,
created for the test, was elided the same way, so this is not a property of this
skill's frontmatter.

**Consequence, stated because it affects what to promise:** automatic invocation
from the description is not guaranteed on a machine with many skills. Typing
`/habits` always works, and the habits themselves do not depend on the skill
being loaded at all, since they live in rules files.

## Quoted from documentation, not independently tested

Each of these is stated in the Claude Code documentation and used as the basis
for guidance here.

- Personal rules in `~/.claude/rules/` apply to every project on the machine.
- User rules load before project rules, which gives project rules priority.
- Rules without a `paths` field load at the same priority as `.claude/CLAUDE.md`.
- Instruction files are context, not enforced configuration. To block an action
  regardless of what the agent decides, the mechanism is a hook.
- Hook event semantics: `PreToolUse` before a tool call executes and can block,
  `PostToolUse` after a tool call succeeds, `Stop` when Claude finishes
  responding and can block, `SessionStart` when a session begins or resumes.
- Target under two hundred lines per instruction file; longer files consume more
  context and reduce adherence.
- A project-root CLAUDE.md survives compaction and is re-read afterwards.
- Auto memory records corrections as `feedback` notes.
- `SKILL.md` should stay under five hundred lines, with detail in separate files.
- `description` and `when_to_use` are truncated at 1,536 characters in the
  listing.

## Neither tested nor documented

Named so that nothing here reads as more certain than it is.

- **Whether an unconditional rules file is re-injected after compaction.** The
  documentation covers CLAUDE.md and path-scoped rules. Not tested.
- **The budget numbers.** Twelve, ten, and six are design choices anchored to
  the documented two hundred line guidance. They are not measured thresholds,
  and no experiment here establishes where adherence actually falls off.
- **That placement beats emphasis.** The mechanism is verified: files load, path
  scoping works, comments are stripped. The comparative claim, that moving a
  rule improves adherence more than rewording it, is a design argument built on
  the vendor's own statement about file length and adherence. It has not been
  measured here.
- **Anything about model internals.** The pull described for each anti-habit is
  a pattern and a plausible pressure, not a mechanism claim.

## Rerunning this

Each test is four lines of shell: make a temporary directory, write a rules file
with a canary habit, run `claude -p` in it, delete it. Anyone repeating it on a
newer version should update the version stamp at the top and correct anything
that no longer holds, rather than leaving a stale record in place.
