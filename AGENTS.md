# Agentic habits: agent instructions

The canonical entrypoint for the package is `skills/habits/SKILL.md`. This file
exists for runtimes that load a project-level `AGENTS.md`, and it governs work
**on this repository**, not the behavior the package installs.

## What ports to another harness, and what does not

This is a Claude Code package. Three of its four mechanisms are Claude Code
only. Do not describe them as portable, here or in anything you write.

| Part | Ports | Detail |
|---|---|---|
| The card format: When, Do, Check | yes | Plain markdown. Paste into `AGENTS.md`, `GEMINI.md`, `.cursor/rules/*.mdc`, or `.github/copilot-instructions.md`. |
| Three tiers, the repair ladder, budgets, the 12 anti-habits, the judging method | yes | Prose discipline. Nothing harness-specific. |
| The `<!-- habit: ... -->` bookkeeping | no | Stripping is a measured Claude Code behavior, tested against a control on 2.1.251. Elsewhere assume the comment is in the prompt, visible to the model and paid for in tokens. Strip it before porting. |
| `.claude/rules/` and `paths:` scoping | no | Codex and Gemini load their instruction file whole, every session. Cursor's `globs:` is the nearest analogue and is untested here. Porting collapses four scopes into one, which removes the instrument this package calls the whole mechanism. |
| `assets/gates/completion-gate.sh` | no | Reads a Claude Code `Stop` payload and a Claude Code JSONL transcript, and blocks with exit 2. Every one of those is Claude Code specific. The gated tier does not exist elsewhere. |
| `agents/habit-judge.md` | partly | The method ports. `tools: Read, Grep, Glob` does not, and that restriction is why the verdict means anything. Elsewhere the judge is a prompt asking not to edit, which is a hint. That distinction is what this package exists to make. |
| `/habits` | no | A Claude Code skill invocation. |

Every measurement in `skills/habits/references/verification.md` was made on
Claude Code 2.1.251. None of it is evidence about another harness. The budget
rule carries elsewhere; its justification may not, and the alternative
justification, a hard document-size cap in another harness, is filed as
unverified.

## Read order

1. `skills/habits/SKILL.md`
2. `skills/habits/references/verification.md`
3. `skills/habits/references/methodology.md`
4. `CONTRIBUTING.md`
5. `SECURITY.md`

## Operating rules for work on this repository

- Every claim about how Claude Code behaves, or about measured model behavior,
  is tested with a recorded method, quoted with its source, or named as neither,
  and filed in `verification.md` or `evidence.md`. Nothing else goes in.
- Never edit a `check=` to make a failure disappear. Sharpening a trigger after a
  miss is the repair ladder. Sharpening the grader is tampering.
- A card changes in both places or neither: `references/starter-pack.md` and
  `assets/starter/`. CI compares the cards and the checks verbatim.
- Counts stated in prose are claims about this repository. Recount before
  changing one. Never copy a count forward from an older file. CI asserts them.
- No em dashes, no en dashes. CI fails on one.
- Never write to a real `~/.claude` while working here. Test installs with
  `HABITS_INSTALL_HOME="$(mktemp -d)"`.
- The stated tier stays markdown. Shell lives in `skills/habits/assets/gates/`
  and `.github/`, nowhere else.
- List the exact commands and outcomes. Do not describe skipped, offline-only,
  or blocked checks as passes.

## Verification

```bash
bash .github/checks.sh
bash .github/test-gate.sh
bash .github/test-install.sh
bash .github/live-checks/gate-replay.sh
claude plugin validate . --strict
claude plugin validate .claude-plugin/plugin.json --strict
```

`bash .github/live-checks/rules-canary.sh` needs the `claude` CLI and spends
model quota. Run it before a release and re-stamp the version at the top of
`verification.md`.
