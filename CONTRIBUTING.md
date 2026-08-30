# Contributing

This repository is mostly prose that an agent reads at runtime, so a change to
the wording is a change to behavior. That shapes what a good contribution looks
like.

## The bar for a new habit

A habit is accepted when all five hold. They are the same tests the skill
applies to a habit a user writes.

1. **It has a moment.** The When names something that actually occurs in a
   session: a tool about to run, a claim about to be made, a file about to be
   touched. Not a topic, not a virtue.
2. **It has one action.** One Do. Three clauses is three habits sharing an ID.
3. **It is checkable.** You can say what would be visibly different in the
   transcript, and the card records it in `check=`.
4. **It is not already covered.** Check the existing packs and say which
   neighbours you considered. Two rules on one subject is how a set starts
   contradicting itself.
5. **It came from something that happened.** Prefer a habit derived from a real
   incident over one adopted on principle. Nobody has measured whether the first
   is followed better, and `verification.md` says so; the defensible reason is
   that an incident tells you where the temptation actually was, and makes the
   habit far easier to justify when the budget gets tight. Say what happened,
   with enough detail to recognize it.

A proposal that adds a habit without proposing what it displaces will be asked
the budget question, because a starter pack that only grows is the twelfth
anti-habit wearing a friendly face.

## Changing existing wording

Small wording changes are welcome and are reviewed against one question: does
the trigger fire on more, fewer, or different moments than before. Say which,
in the pull request.

If you sharpen a card, update it in **both** places: the rationale entry in
`references/starter-pack.md` and the installable card in `assets/starter/`. CI
checks that the two match verbatim and will fail if they drift.

## House rules

- **No em dashes.** Commas, colons, parentheses, or a full stop instead. CI
  fails the build on one.
- **The stated tier stays markdown.** Habit cards, references, and templates
  are text an agent reads. No scripts there.
- **The gate tier is the one exception, and it is bounded.** Enforcement needs
  something the harness executes, so `skills/habits/assets/gates/` holds shell
  scripts. A new one must be POSIX-ish shell, depend on nothing beyond `jq`,
  make no network call, fail open on every uncertainty, and arrive with tests
  written from `gates.md` rather than from itself. Everything else is tooling
  and belongs in `.github/`.
- **First person, present tense, in the cards.** The agent is the reader.
- **No hedging words in a card.** "Consider", "try to", and "where possible"
  turn a habit back into a mood.
- **`SKILL.md` stays under 500 lines.** Detail belongs in `references/`.

## Claims about the harness

Any statement about how Claude Code behaves must be one of three things, and
must be filed as such in `skills/habits/references/verification.md`:

- **Tested**, with the method written down so someone else can rerun it.
- **Quoted** from the official documentation.
- **Neither**, and named as neither.

A claim that is none of those does not go in. This is the rule the repository
cares about most: the whole skill argues for evidence over confident assertion,
so it cannot be built on confident assertion.

## Running the checks locally

Everything CI runs is shell and takes a second:

```bash
bash .github/checks.sh
```

## Proposing a habit without opening a pull request

Open an issue with the **habit proposal** template. Describe the moment, not the
principle. The most useful proposals read like an incident report.
