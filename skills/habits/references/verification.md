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

## Corrected after review

Recorded because the skill shipped with a false premise and the correction is
part of the evidence trail.

**"An agent has no willpower and no memory" was wrong on both halves.** Claude
Code persists instructions at four CLAUDE.md scopes, in `.claude/rules/`, in
skills, in hooks and settings, and in auto memory that Claude writes for itself
and reloads every session. The willpower half fails too: character and
constitution adherence are trained rather than prompted, and Anthropic's Fable 5
system card reports adherence at least as strong as prior models. The corrected
premise is abundant memory and no enforcement.

**Advisory mechanisms are not ranked against each other.** Nothing in the
documentation says a rules file is more binding than CLAUDE.md. What differs
between CLAUDE.md, rules, skills, and auto memory is *when they load*, not how
binding they are. The tests in this file measure loading, which is what they
were designed to measure. Do not read them as evidence about compliance.

**The enforcement line is the documented one.** CLAUDE.md instructions are
advisory; hooks "are deterministic and guarantee the action happens". Permissions,
subagent tool scoping, and plan mode are enforcement for the same reason: the
harness executes them rather than asking the model to.

**Adherence degrades with volume, qualitatively.** The official statement is
that bloated CLAUDE.md files cause Claude to ignore your instructions, with a
target under two hundred lines per file. No threshold, count, or percentage is
published anywhere. The budgets here remain design choices.

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
- **That trigger-shaped wording improves adherence at all.** The When and Do
  format comes from research on people. No published source measures it on a
  model. There is a counter-signal worth knowing: emphatic CRITICAL and MUST
  phrasing is documented to cause tool overtriggering on current models, and
  scaffolding written for weaker models is reported to degrade output on this
  generation. Plain triggers are not emphatic markers, but nobody has drawn the
  line, so treat the format as a legibility choice rather than a performance
  claim.
- **Whether phantom completion is a measured failure mode.** The strongest
  available source is a single practitioner write-up reporting that auditing
  every progress claim against a session tool result nearly eliminated fabricated
  status reports, and that fresh-context verifier subagents outperform
  self-critique. That is one blog, not a vendor measurement. Reward hacking,
  test green-washing, and scope creep have no published measurement at all, which
  is why `anti-habits.md` presents all twelve as patterns rather than findings.
- **Anything about model internals.** The pull described for each anti-habit is
  a pattern and a plausible pressure, not a mechanism claim.

## Rerunning this

Each test is four lines of shell: make a temporary directory, write a rules file
with a canary habit, run `claude -p` in it, delete it. Anyone repeating it on a
newer version should update the version stamp at the top and correct anything
that no longer holds, rather than leaving a stale record in place.
