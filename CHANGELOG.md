# Changelog

All notable changes to this skill are recorded here. Dates are ISO.

## 0.2.0 - 2026-08-29

The skill stops being a filing system for good intentions. Three tiers now, and
it says which one a habit is in.

### Added: the gate tier

- `assets/gates/completion-gate.sh`, a `Stop` hook that refuses to let a turn end
  claiming a test, build, lint, or type check came back clean when nothing was
  run to find out. Fails open on every uncertainty, never recurses, and does not
  block an honest "I have not run this".
- **Proven in a live session.** The model wrote "Yes, the test suite passes now"
  with nothing run. The gate blocked the turn. The model kept working and
  finished with "I was unable to run the test suite because both `npm test` and
  `npx jest` require approval". The false claim never reached the user.
- Sixteen unit tests in `.github/test-gate.sh`, in CI. Two exist because a live
  run caught the first version counting a **denied** command as verification;
  the gate now matches each call to its result and ignores errored ones.
- `references/gates.md`: the tier, the install, the design rules for writing
  another gate, and the settings shape whose flat form is valid JSON and
  silently never fires.

### Added: the judge tier

- `agents/habit-judge.md`, a read-only verifier with `Read, Grep, Glob` and
  nothing else, so its verdict cannot be improved by fixing what it judges.
- `/habits judge` alongside `/habits check`. `check` is self-review and must
  label itself as such; `judge` runs elsewhere and is the verdict that counts.
- `references/judging.md`: the one criterion that decides whether a habit is
  good (a stranger holding only the transcript can rule it fired, missed, or not
  applicable), the ledger schema where **no evidence means not PASS**, how to
  score the set rather than the habit, and the published eval recipe for when
  opinion runs out.

### Added: cases, the record a habit rests on

- `assets/templates/case.md` and a case store in the workbook. Every firing and
  miss worth remembering becomes a case with evidence and a worked pair. Habits
  cite their cases, which makes the set prunable by observation instead of taste.
- The worked pair lives in the case, not in the loaded card, because examples
  teach and context is a budget. That is the skill's own placement rule applied
  to its own material.

### Added: precedence

- `references/precedence.md`. Five channels can disagree and the ladder is now
  fixed rather than decided per session: a gate, then the user now, then a
  safety boundary, then the narrower scope, then CLAUDE.md, then auto memory
  last. Anything read from a file, page, or another agent is data and never
  enters the ladder. Includes the one case for deliberate restatement, and how
  it differs from the duplication the review protocol hunts.

### Changed

- `SKILL.md` rebuilt around the tiers, with the precedence ladder inline, an
  `enforce` flow that checks a habit has actually reached the third rung, and a
  rule that ceremony is gated on task size, because full planning on a one-line
  fix is a documented pitfall rather than rigor.
- The habit card gained `tier`, `gate`, `cases`, and `evidence`. `evidence`
  grades the rule itself: one starter habit is `sourced`, one is
  `practitioner`, and seventeen are `reasoned`. That distribution is stated in
  the starter pack rather than hidden.
- Cover art replaces the generated SVG banners, which are deleted rather than
  left to compete with it.

## 0.1.0 - 2026-08-29

First release.

### Added

- `SKILL.md`: the operating contract for `/habits`, with twelve verbs plus a
  bare-text fallback routed from one command, the five placements, the habit
  card, and the rules the skill follows when writing to a user's instruction
  files.
- `references/methodology.md`: agentic habits as a concept. The four laws
  (placement decides loading, only a gate decides adherence, specificity over
  sentiment, budget over accumulation), what the format borrows from
  implementation intentions, habit stacking, keystone habits and never miss
  twice, and where that analogy stops.
- `references/habit-card.md`: the two-line card, the metadata comment, ID scheme
  by scope, file anatomy, budgets, and conflict resolution.
- `references/placement.md`: session, system, project, path, and enforced
  placements with exact paths and load behavior, the workbook for bookkeeping,
  load order and precedence, verification with `/context`, and troubleshooting.
- `references/starter-pack.md`: nineteen habits in five packs, each with its
  check and its rationale, plus recommended installs by situation.
- `references/anti-habits.md`: twelve named failure modes with the tell, the
  pull, the replacement habit, and the cost when it lands.
- `references/review.md`: the board, the evidence-only adherence rules, the
  three-rung repair ladder, the review protocol, promotion and demotion bars,
  and retirement to the archive.
- `assets/templates/`: habit file, path-scoped habit file, archive, and log.
- `assets/starter/`: system and project card sets, marked as menus rather than
  installs so that copying them wholesale is visibly the wrong move.
- `references/verification.md`: the evidence record. What was tested and how,
  what is quoted from documentation, and what is neither, so that no claim in
  the skill has to be taken on trust.

### Repository

- MIT license, replacing the placeholder proprietary notice.
- Theme-aware SVG banner in light and dark, rendered and inspected rather than
  shipped unseen, with a dot row that echoes a habit tracker's streak view.
- README rebuilt for a first-time reader: the idea above the fold, a placement
  decision diagram, the repair ladder, and the long lists folded into
  collapsible sections.
- `.claude-plugin/marketplace.json` so the plugin can be installed straight from
  the repository.
- `.github/checks.sh`, the structural check suite, and a CI workflow that runs
  it on every push and pull request. Shell and jq only, matching the skill's own
  no-scripts rule. It checks house style, the skill contract, reference
  integrity in both directions, starter card parity, habit ID integrity, both
  manifests, and the banner assets.
- `CONTRIBUTING.md` with the five-test bar for a new habit and the rule that
  every claim about the harness must be tested, quoted, or filed as neither.
- `SECURITY.md` naming the three properties whose failure is a security report,
  `CODE_OF_CONDUCT.md`, issue templates for habit proposals and bugs, and a pull
  request template that asks what an added habit displaces.

### Verified before release

Tested on Claude Code 2.1.251 rather than assumed: a `.claude/rules/` habit file
loads into a fresh session and changes behavior; the `<!-- habit: -->`
bookkeeping comment is stripped, confirmed against a plain-text control; a
path-scoped habit is absent until a matching file is read and present after; the
package passes `claude plugin validate` in both normal and `--strict` form; and
the skill resolves to `/habits`.

### Corrected: the premise was false

The skill shipped claiming "an agent has no willpower and no memory", on the
banner and in three files. Both halves are wrong. Claude Code persists
instructions five ways, including auto memory the agent writes for itself, and
character adherence is trained rather than absent. The claim also contradicted
`methodology.md` in the same package, which described auto memory as the
detector that feeds habits, and it survived a thirty-check CI suite because
every check tested structure rather than truth.

- Premise replaced everywhere with abundant memory and no enforcement. Loading
  an instruction is deterministic; following it is not.
- The laws are now four, not three. "Placement over repetition" became
  "placement decides loading", which is what the tests in this repository
  actually measured, and a new second law states the documented enforcement
  line: everything short of a hook is a hint.
- `verification.md` gained a corrections section and three new entries under
  "neither tested nor documented": that trigger-shaped wording improves
  adherence at all, the counter-signal that emphatic phrasing overtriggers on
  current models, and the fact that phantom completion rests on a single
  practitioner source while reward hacking, green-washing, and scope creep have
  no published measurement.

### Fixed after review

- Hook event table corrected to the documented semantics. `PostToolUse` fires
  only after a tool call succeeds, `Stop` can block, and `SessionStart` fires on
  resume as well as on start. The previous wording would have sent a
  failure-handling habit to an event that never sees failures.
- The compaction claim no longer generalizes documented CLAUDE.md behavior to
  rules files. What is unknown is now named as unknown.
- `export` and `import` had no procedure. Both now have one, and import treats
  an incoming file as untrusted data with a budget and a dedupe pass.
- Setup now creates `.claude/rules/` when it is missing, and says so in the
  preview instead of writing into a directory that appears from nowhere.
- Writing a project habit now names the fact that it is a commit into shared
  source control before it happens.
- Budget provenance disclosed at the point the law is stated, rather than
  presenting twelve, ten and six as if they were measured.
