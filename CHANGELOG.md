# Changelog

All notable changes to this skill are recorded here. Dates are ISO.

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
