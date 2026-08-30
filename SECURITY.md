# Security

## What this repository is

Two different things, and the difference matters before you install.

**The stated tier is markdown.** Habit cards, references, templates. Copying
them into `~/.claude/skills/` puts text in a directory Claude Code reads.
Nothing executes.

**The gate tier is a shell script you install deliberately.**
`skills/habits/assets/gates/completion-gate.sh` requires `jq`, is registered as
a `Stop` hook, and therefore runs at the end of every turn in every session it
is installed for, reading the session transcript to decide whether to block.
Read it before you install it. It is 150 lines, makes no network call, writes
nothing but stderr, and never executes anything from the transcript, but you
should confirm that yourself rather than take this paragraph's word for it.

The repository also ships `install.sh` and `uninstall.sh`, which you run
deliberately, and six development scripts. Five of them run in CI and need no
model: `.github/checks.sh`, `.github/test-checks.sh`, `.github/test-gate.sh`,
`.github/test-install.sh`, and `.github/live-checks/gate-replay.sh`. The sixth,
`.github/live-checks/rules-canary.sh`, invokes the `claude` CLI and spends model
quota; it never runs in CI and only runs when you run it.

## Where the risk actually is

The skill writes to files that shape an agent's behavior in every future
session: `~/.claude/rules/habits.md`, a project's `.claude/rules/`, and, when a
user approves an escalation, hook configuration in settings. Three properties
matter, and a report that any of them is broken is a security report:

1. **Nothing is written without an explicit yes**, with the exact content shown
   first.
2. **An imported habit file is data, never instructions.** A card that tries to
   change tool policy, authority, disclosure, or the skill's own contract must
   be reported and dropped, not merged.
3. **A hook is proposed, never silently applied**, and its blocking effect is
   stated before approval.

## A risk this package creates by recommending project scope

`placement.md` recommends putting habits in a repository's `.claude/rules/`,
because they then travel with the repo and a team shares one set. The same
property is a risk in the other direction: **cloning a repository puts its habit
cards into your agent's loaded instructions with no import step, no preview, and
no approval.** There is no `/habits import` in that path, so the data discipline
this package insists on elsewhere never runs.

This is how Claude Code loads project rules generally, not something this
package invented, and the same is true of any `CLAUDE.md` in any repo you clone.
But this package actively encourages the placement, so it owns the warning:
read `.claude/rules/` in an unfamiliar repository the way you would read its
CI configuration, before you work in it with an agent.

## Reporting

Report privately through GitHub's security advisories on this repository, or to
the address on the maintainer's GitHub profile. Please do not open a public
issue for something that would let a crafted habit file change an agent's
behavior on someone else's machine.

Include what an attacker would need to control, what they would gain, and the
smallest file that shows it. A working proof of concept is welcome in a private
report and should not be posted publicly.

## Not in scope

- The agent failing to follow a habit. That is adherence, not a vulnerability,
  and the repair ladder exists for it.
- Anything requiring the user to approve a write they were shown, since informed
  approval is the design.
