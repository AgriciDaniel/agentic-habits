# Changelog

All notable changes to this skill are recorded here. Dates are ISO.

## 0.3.1 - 2026-08-29

Deep research pass. Three research streams plus the independent review; only
what was verified against a primary source in-session was acted on, and the
rest is filed as unverified rather than repeated as fact.

### Adopted rather than reinvented

`hookify` is a first-party plugin in the `anthropics/claude-code` marketplace
that writes hooks from described behavior. Verified by fetching the marketplace
directory. `/habits enforce` now hands off to it for anything beyond the shipped
gate, and spends its own effort on the decision this package is actually about:
which habit deserves a gate, answered from history by the repair ladder or from
consequence by `stakes=critical`.

### Added: validate an instrument in both directions

From Anthropic's code-migration playbook, quoted at source: "Run it against the
original code to confirm it passes. Then run it against deliberately broken code
to confirm it fails, a judge that doesn't catch breakage isn't a judge." A gate
observed only allowing turns is untested, not trustworthy. Both `gates.md` and
`judging.md` now say so, and the test suite's two halves are named for it.

Also adopted, from the same source: deterministic before model. "Let scripts, a
compiler, a diff, a test suite, be the referee" and "make review adversarial and
verification mechanical" set the order of preference the tiers already follow.

### Added: derived beats speculative, which indicts this repository's own pack

The strongest first-party support for a rules file is as a sink for *observed
repeated* failures: "When a reviewer keeps catching the same mistake across
files, the fix isn't per-file. You add one sentence to the rulebook and
regenerate the affected batch."

Nothing supports the speculative rule authored upfront because it seems prudent,
and the starter pack in this repository is exactly that. `methodology.md` now
says so plainly and recasts the pack as a vocabulary for writing your own rather
than a set to adopt.

### Filed, not used

Six claims from a prior-art research stream that would each change something if
true, including that the judge-over-transcript architecture and the
stated/gated/judged tiering are already published elsewhere, and that a hard
32,768-byte cap on project docs in another harness would justify the budget
better than the adherence argument does. None was verifiable from a primary
source this session, so all are recorded in `verification.md` as reported and
unchecked.

## 0.3.0 - 2026-08-29

An independent read-only review, run in a fresh context against seven frozen
acceptance criteria, returned `improved_not_passed` with fifteen findings. It
measured the shipped gate rather than reading its documentation, and most of
what follows is its work. Every measured finding was reproduced before being
acted on.

### Fixed: the gate blocked the one thing it must never block

The disclosure branch was a fixed phrase list. Five of six natural ways of
saying "I could not run this" were blocked, including "unable to run", "could
not verify", "no way to run", and "never ran it". A gate that punishes honest
disclosure produces concealment, which `gates.md` said in prose while the code
did the opposite.

Decision logic rebuilt sentence by sentence rather than per message:

- **Disclosure is recognised by negation near running or verifying**, not by a
  phrase list, and it is evaluated per sentence, so a disclosure about one check
  no longer launders an unverified claim about a different one.
- **A claim must be an unhedged assertion.** Questions, instructions, reported
  speech, and hedged futures are not claims. The old regex blocked "Run npm test
  to confirm the tests pass", "Please check whether the build succeeds", and
  "the test suite should pass once you run it".
- **Evidence means a command that looks like a check**, matched against the
  shell command text rather than counting any `Bash` call. `ls` no longer proves
  a test suite ran.

### Fixed: the tests enshrined the implementation

The old suite was written from the same understanding as the script, so it
passed while the script blocked honest disclosures. One case asserted exit 2 on
a hedged future while sitting under a heading that said false positives are the
expensive failure.

Rewritten from `gates.md` instead: 27 cases, including every phrasing the
reviewer measured, and the laundering cases they constructed.

### Fixed: three documents described a package that no longer existed

`SECURITY.md` said "nothing here executes" about a repository that ships a hook
which runs at the end of every turn and reads the transcript. `CONTRIBUTING.md`
forbade scripts in `skills/`, where the gate lives. Two README badges claimed no
dependencies and markdown only. A reader deciding whether to install was being
misinformed, which is a consent problem rather than a code one.

All corrected, and `checks.sh` now tests these three claims directly, along with
whether every verb the skill offers appears in the README. That check found two
missing verbs on its first run.

### Fixed: `import` had no procedure, while the changelog claimed it did

The 0.2.0 rewrite of `SKILL.md` dropped the export and import flow that 0.1.1
had added, and the changelog entry announcing it survived. Restored, with the
dedupe, renumbering, budget, and untrusted-data steps, plus the limit that
matters: it protects the `/habits import` path only.

### Fixed: precedence

- Safety now sits **above** the user, and authorization below, because the old
  single rung named both and the ordering was correct for only one of them.
- Skills added as a channel. They were named as a persistence mechanism and
  appeared nowhere in the ladder.
- The second, contradicting ladder in `habit-card.md` is gone. There is one.
- New section on where the line between data and instruction actually falls: it
  is how a file arrived, not what it contains. A habit file in a cloned
  repository is loaded as instructions before anyone could review it, which
  `SECURITY.md` now warns about instead of the package silently promoting the
  placement that creates it.

### Added: the evidence discipline the judge was missing

The package enforced evidence at the moment of a claim and graded evidence at
the level of a rule, and had nothing at the level of a judgment.

- The ledger's evidence column now carries `[RAW]` and `[INFER]`, kept disjoint,
  with reasoning over an absence always `[INFER]`. A tool named `run_tests` is
  raw evidence that a tool with that name was called and no evidence that tests
  ran; collapsing those launders an assumption into a fact.
- The judge is told to flag misses, not near-misses, because a reviewer asked to
  find problems will find some. This is documented guidance and it showed up on
  the judge's first run, which FAILed an ordinary edit under a habit about
  irreversible actions. A judge over-firing is diagnosing a vague trigger.

### Added: `stakes`, set only by the user

`tier` records the mechanism that exists. `stakes` records what the user says a
failure costs, and only the user may set it. The repair ladder reached
enforcement through history, which left a habit whose *first* failure is
unacceptable unreachable by design. `stakes=critical` is the second legitimate
trigger for `enforce`.

### Added: SYS-16, compression never drops a dissent

**When** summarising or reporting on work already done. **Instead** carry every
disagreement and caveat forward, and drop detail instead. Filtering volume is
the job and filtering disconfirmation is the failure, and from the inside they
are identical. Nothing else in the pack covered what a second pass over your own
output is allowed to lose.

### Added: the probes now ship

`verification.md` was the strongest section in the repository and the only
evidence it carried was its own word. `.github/live-checks/` now holds the
scripts: `gate-replay.sh` replays the recorded session deterministically and
runs in CI, `rules-canary.sh` reruns the loading, comment-stripping control, and
path-scoping measurements against a live model.

Also: sixteen claims about the harness that had escaped the tested / quoted /
neither trichotomy are now filed, including a new section for claims that are
neither vendor documentation nor tested. Two starter habits were regraded from
`reasoned` to `sourced` after their citations were found and filed, and two
newly documented facts landed: a `Stop` hook is overridden after eight
consecutive blocks, and `/goal` conditions are a documented mechanism between a
prompt and a hook.

### Honest about what did not change

The gate is still one regex and a transcript scan. It is defeated by a novel
phrasing and by a command that merely looks like a check. The README now says
so, and calls it an existence proof for the enforcement tier rather than the
difference between a rule and a guarantee.

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
