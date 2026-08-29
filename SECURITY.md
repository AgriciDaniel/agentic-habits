# Security

## What this repository is

Markdown files. Nothing here executes, there are no dependencies, and installing
the skill copies text into a directory Claude Code reads.

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
