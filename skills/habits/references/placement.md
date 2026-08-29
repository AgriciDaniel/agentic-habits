# Placement

Placement is the whole mechanism. A habit at the wrong scope is not a weak
habit, it is an absent one.

## The five placements

### 1. Session

Held in the conversation, written nowhere. Costs nothing tomorrow because it
does not exist tomorrow. This is the right place for anything experimental,
anything tied to the task at hand, and anything the user says with "for now".

At the end of a session where a session habit clearly earned its keep, offer to
promote it. Do not promote silently.

### 2. System

`~/.claude/rules/habits.md`

Personal rules in `~/.claude/rules/` apply to every project on the machine and
load at the start of every session. This is the strongest placement short of a
hook, and the most expensive: every line is paid for in every session of every
project for as long as it exists. Reserve it for triggers that have no repo in
them, such as how the agent reports a failure or confirms a destructive action.

User-scope rules are files the user wrote themselves, so their imports load
without an approval dialog. User rules load before project rules, which gives
project rules the higher priority on conflict.

### 3. Project

`<repo>/.claude/rules/habits.md`

Loads in every session in that repo, and travels with the repo through source
control, so it is also how a team agrees on agent behavior. `.claude/rules/`
discovers every `.md` file recursively, so a repo can hold several habit files.

Anything naming this codebase's conventions, tools, test commands, or dangerous
areas belongs here rather than at system scope. Default new habits here when the
trigger involves code at all.

Because it travels with the repo, a project habit is a commit. Before writing
one, check whether the repo is shared and whether `.claude/` is gitignored, and
say which it is. Two cases need a decision from the user rather than a default:
a habit that is really a personal preference, which belongs at system scope or
in an ignored file rather than in everyone's context, and a habit phrased as a
correction of how the team works, which is a message to colleagues before it is
an instruction to an agent. Neither is a reason not to write it. Both are a
reason to say out loud where it is about to land.

If `.claude/rules/` does not exist yet at the chosen scope, create it as part of
the write, and name it in the preview so the user sees a new directory coming.

### 4. Path

`<repo>/.claude/rules/habits-<slug>.md` with `paths:` frontmatter.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "db/migrations/**"
---
```

These load only when the agent works with matching files, which makes them the
sharpest instrument available in prose. A rule about migrations that loads when
the agent opens a migration is followed far more reliably than the same rule
sitting in a global file competing with thirty others.

Rules without a `paths` field load unconditionally, at the same priority as the
project CLAUDE.md. Path patterns are globs: `**/*.ts`, `src/**/*`, and brace
expansion such as `src/**/*.{ts,tsx}` all work. Path-scoped rules trigger when
the agent reads a matching file, not on every tool call, so the trigger in the
card should be about working with those files.

Use a path file when a habit made someone ask "why is that loaded when I am not
even in that part of the code".

### 5. Enforced, by hook

A rules file is context. The vendor documentation is explicit that Claude treats
CLAUDE.md and rules as context rather than enforced configuration, and that to
block an action regardless of what Claude decides, the mechanism is a hook.

So a habit that genuinely must not be skipped is not a habits problem. Move it,
or pair it. The habit stays in the file to explain the behavior to a human
reader, with `status=enforced` and the event named in `hook=`.

Events worth knowing, in the documentation's own terms:

| Event | Fires | Blocks | Good for |
|---|---|---|---|
| `PreToolUse` | before a tool call executes | yes | forbidding a command shape, guarding a path |
| `PostToolUse` | after a tool call succeeds | no | formatting, linting, an automatic check |
| `Stop` | when Claude finishes responding | yes | a final gate before "done" |
| `SessionStart` | when a session begins or resumes | no | injecting state the agent should always have |

Two details decide which one a habit belongs on. `PostToolUse` fires only after
a tool call **succeeds**, so a habit about handling failures does not belong
there. `Stop` can block, which is what makes it the right home for a habit that
gates the word "done": on a block it does not stop the turn, it sends the agent
back to keep working.

Escalation rules for this skill:

- Propose, never write. Show the exact settings block and what it will do,
  including what it will block, and get an explicit yes.
- Keep the command a short shell one-liner, or point at a script the user
  already owns. Do not invent a script for them as part of a habit.
- A hook that blocks is a hook that can block the user's own legitimate work.
  Say that out loud before proposing it.
- Settings work has its own tooling in this harness. When the user wants the
  hook actually installed and configured properly, hand off rather than
  hand-editing `settings.json` from here.

## The workbook

Bookkeeping never belongs in a loaded file.

| Path | Contents | Loaded |
|---|---|---|
| `~/.claude/habits/archive.md` | retired system habits, with date and reason | no |
| `~/.claude/habits/log.md` | recorded lapses, reviews, promotions | no |
| `<repo>/.claude/habits/archive.md` | the same, per project | no |
| `<repo>/.claude/habits/log.md` | the same, per project | no |

Archive entries keep the full card plus a retirement note, so a retired habit
can be brought back exactly as it was.

## Load order and precedence

From the vendor documentation, in the order things enter context:

1. Managed policy CLAUDE.md, if the organization deploys one.
2. User CLAUDE.md and user rules, from `~/.claude/`.
3. Project CLAUDE.md and project rules, from the root down to the working
   directory, so the closest file is read last.
4. `CLAUDE.local.md`, after CLAUDE.md at the same level.
5. Path-scoped rules, when a matching file is read.

Later is not automatically stronger, but more specific usually is, and the
project files being read last is why project habits outrank system habits in
practice. Nested files in subdirectories load when the agent reads files there.

## Verifying that a habit actually loaded

Writing the file is not evidence. After any write, tell the user how to check:

- `/context` lists what actually loaded, under memory files. If the habits file
  is not there, the agent cannot see it.
- `/memory` lists and opens the instruction files across scopes.
- Path-scoped rules will not appear until a matching file is read, which is
  correct behavior and worth saying so nobody thinks it failed. This is tested,
  both directions, in `verification.md`.
- The documentation says a project-root CLAUDE.md survives compaction and is
  re-read from disk afterwards, and that nested CLAUDE.md files and path-scoped
  rules reload as the agent reads files they apply to. Whether an unconditional
  rules file is re-injected the same way is not stated there and has not been
  tested here, so do not promise it. If a habit goes quiet after a long session,
  `/context` is the check.
- Anything given only in conversation does not survive compaction, which is
  exactly the case for a session habit. Say so when one is created.

## Troubleshooting

**The habit exists and is ignored.** Check that the file loaded at all. Then
check the trigger: a When that names a topic instead of a moment is the usual
cause. Then check for a contradiction with CLAUDE.md.

**It fires in the wrong situations.** The trigger is too broad. Narrow the
wording, or move the card to a path file.

**It worked for a while and stopped.** Look at what was added since. This is
usually budget, not decay: new rules crowd old ones.

**It cannot be allowed to fail.** Stop tuning the prose. Escalate to a hook.
