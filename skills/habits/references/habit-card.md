# The habit card

## Anatomy

One habit is one card. Two visible lines, one hidden line.

```markdown
### SYS-03 · Verify with the real thing
**When** I am about to say something works.
**Do** Run the closest real check and show its actual output.
<!-- habit: id=SYS-03 added=2026-08-29 source=starter/core lapses=0 status=active
     check="the message that claims success contains real output from a real run" -->
```

**Heading.** `### <ID> · <name>`. The name is a handle a person can say out
loud. Four words or fewer.

**When.** One sentence naming the moment. Written from the agent's side, in
first person, because that is who reads it. Present or about-to-happen tense:
"I am about to", "a test fails", "the user asks for". Never a topic.

**Do.** One sentence naming one action. Imperative, concrete, no conditions. If
you need "and then", you have two habits.

**Instead.** Replaces **Do** for substitution habits, the ones that redirect a
bad reflex. Same rules. Use it when the natural phrasing would have been "do not":

```markdown
### SYS-08 · No green-washing
**When** a test fails and the fastest fix is to change the test.
**Instead** Fix the code, or report the failure verbatim and stop.
```

A card may add one **Why** line, but only when the reason changes how the habit
is applied. A reason that is only motivational belongs in the archive note, not
in every session's context.

## The metadata comment

Everything that is bookkeeping rather than instruction goes in the HTML comment.
Claude Code strips block-level HTML comments from CLAUDE.md before injecting it,
and a controlled test in `verification.md` confirms the same for a rules file:
the agent reproduced a habit card verbatim and the comment was not there, while
the same marker in plain text was. So the bookkeeping costs the file's readers
nothing, on the version tested. Keep the comment to one wrapped line anyway, and
never put anything in it that the agent would need in order to follow the habit.

| Field | Meaning |
|---|---|
| `id` | Scope prefix plus number. Stable for the life of the habit |
| `added` | ISO date the card was written |
| `source` | `starter/<pack>`, `user`, `import/<name>`, or `promoted/<old-id>` |
| `lapses` | Count of recorded misses. Only ever incremented from evidence |
| `last_lapse` | ISO date of the most recent recorded miss, omitted if none |
| `status` | `active`, `probation`, `enforced`, or `retired` |
| `check` | Quoted. What is observably different when this fired |
| `tier` | `stated`, `gated`, or `judged`. Absent means stated |
| `gate` | Event and script when a gate enforces it, such as `Stop/completion-gate` |
| `cases` | Comma-separated case IDs from the workbook that this habit rests on |
| `evidence` | `sourced`, `practitioner`, or `reasoned`. How well the habit itself is supported |
| `stakes` | `normal` or `critical`. What a failure costs. **The user sets this, never the agent** |

`probation` marks a habit on its second miss, currently placed differently and
being watched. `enforced` marks a habit that also has a gate, kept in the file
so a reader knows why the agent behaves that way.

`stakes` and `tier` are deliberately separate and must not be collapsed. `tier`
records the mechanism that happens to exist: a habit is `gated` because someone
wrote a hook. `stakes` records what the user says a failure costs, and only the
user may set it. The agent may nominate a habit as critical and must not
designate one, for the same reason a firmly worded rule is not a more important
rule: priority asserted by the thing being governed is an input, never a
determinant.

The pair gives `enforce` its second legitimate trigger. The repair ladder reaches
enforcement through history, after a habit has been missed twice, which leaves
a habit whose *first* failure is unacceptable unreachable. `stakes=critical` is
how the user says "gate this before it ever fails".

`tier` is the honesty field. A `stated` habit is a hint and the skill says so.
`gated` means a hook enforces it and the `gate` field names which. `evidence`
records how well the rule itself is supported, which is separate from whether it
was followed: `sourced` means official documentation backs it, `practitioner`
means a single outside report, `reasoned` means it is an argument. Most habits
are `reasoned`, and there is nothing wrong with that as long as nobody calls
them findings.

## IDs

| Prefix | Scope |
|---|---|
| `SYS-nn` | `~/.claude/rules/habits.md` |
| `PRJ-nn` | `<repo>/.claude/rules/habits.md` |
| `PTH-<slug>-nn` | `<repo>/.claude/rules/habits-<slug>.md` |
| `SES-nn` | this session only, never written to disk |

Numbers are assigned in order and never reused, including after a retirement. A
promoted habit gets a new ID at the new scope and records the old one in
`source`, so the archive still lines up.

## File anatomy

A live habit file is a rules file that a human can also read.

```markdown
# Habits

Standing habits for this <system|project|area>. Each one is a trigger and an
action. Follow them in every session. When one conflicts with a direct
instruction from the user, the user wins and the conflict is worth reporting.

## Active

### SYS-01 · ...
...

## Paused

### SYS-06 · ...
```

Sections in order: `Active`, then `Paused` if anything is paused. Retired habits
leave the file entirely and go to the workbook archive. A paused habit is still
loaded and still costs context, so pausing is for a week, not a quarter. If it
is longer than that, retire it and re-add it later from the archive.

Path-scoped files carry frontmatter and nothing else changes:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "**/migrations/**"
---

# Habits: API and migrations
```

## Budgets

| Scope | Cap | Why |
|---|---|---|
| System | 12 | Loads in every session of every project, forever |
| Project | 10 | Loads in every session of one repo |
| Path file | 6 | Narrow by construction, so it should stay narrow |
| Session | no cap | Costs nothing tomorrow |

The cap is a real gate, not advice. At the cap, adding requires naming which
habit is being retired and why. When the user declines to retire anything, say
plainly that the set is over budget, add it anyway if they insist, and note the
expected effect: the newest habits are followed most, the oldest blur first.

Total loaded habit text should stay well under the two hundred line guidance for
instruction files, counted together with CLAUDE.md, not on its own.

## Conflicts

Two rules that disagree are worse than either rule alone, because the resolution
is arbitrary and silent. Before writing any card, check the live files and both
CLAUDE.md files at the relevant scopes for:

- **Direct contradiction.** Two cards telling the agent to do opposite things at
  the same moment. Resolve by editing, never by adding a third card that
  arbitrates.
- **Overlapping triggers.** Two Whens that fire together with different Dos.
  Merge them or narrow one.
- **Restatement.** The same idea already in CLAUDE.md without a trigger. Sharpen
  the existing line in place instead of duplicating it here.

Precedence when a conflict cannot be avoided is not decided here. There is one
ladder, in `precedence.md`, and it is the only one. Say which rule you followed
and why when it matters.

## Writing style inside a card

- First person, because the agent is the reader.
- Present tense in the When, imperative in the Do.
- No hedging words. "Consider", "try to", and "where possible" turn a habit back
  into a mood.
- Name real things: file types, command names, tool names, lifecycle moments.
- One sentence per line. A card that wraps to five lines is a card that is doing
  too much.
