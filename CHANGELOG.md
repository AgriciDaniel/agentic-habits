# Changelog

All notable changes to this skill are recorded here. Dates are ISO.

## 0.6.4 - 2026-08-30

A habit secretary judged the shipped documents against the twenty habits the
package ships. The verdict was concentrated in one place, and it was the
keystone habit.

### Fixed: the README broke SYS-16

`SYS-16` says compression may drop detail but never a dissent. The README
compresses eight reference files and dropped the calibrating caveat from almost
every one. Measured by grep: the words `unmeasured`, `self-review`, `contested`,
`ceiling` and `AUROC` appeared **zero** times in a document summarising files
where each is load-bearing.

Restored to the README:

- **The ceiling.** `SKILL.md` tells the agent that a written rule roughly halves
  the failure and leaves a quarter to a third standing. The README told the
  human nothing. The file the agent loads was more honest than the file the
  reader gets.
- **What the pack rests on.** Two of twenty are backed by measurement, two by
  documentation, one is `contested`, and fifteen are arguments. The README
  shipped the pack with no grades at all.
- **The package's own largest self-declared defect**, that `evidence.md` carries
  ~30 numeric claims with no source links, which "Honest limits" did not mention.
- **The judged tier is weaker than it sounded.** "After the fact, but real"
  became "after the fact, and weaker than it sounds", and `/habits check`
  regained the same-context self-review label that `judging.md` calls mandatory.
- **Version scope** on the comment-stripping claim, and "patterns, not findings"
  on the anti-habits.

The headline also conflated a durable rule with a reliable one, which `SKILL.md`
explicitly forbids.

### Fixed: SYS-16 broken in the file that defines it

`methodology.md` cited the package's most-quoted figure, the 54% to 9% drop from
giving an agent a sanctioned way to declare a task impossible, without the
caveat that the effect was much less pronounced for the Claude model tested.
`evidence.md` carries that caveat **and records that this file had dropped it
once before**. This package runs only on Claude, so the caveat is the reader's
answer, not a footnote. Restored.

### Fixed: a path that does not exist, and two wrong counts

Three documents named `assets/gates/completion-gate.sh`. At the repository root
`assets/` holds two images and a provenance file; the script is under
`skills/habits/`. A reader wanting to audit the hook before installing it was
sent to the wrong directory.

`SECURITY.md` said "five development scripts. Four of them run in CI." There are
six, and five run in CI. Both numbers wrong, in the document people read before
deciding whether to trust the thing.

### Added: checks for both classes

CI now asserts that every repository path named in prose resolves, and that
`SECURITY.md`'s two script counts match disk and the workflow. Two more negative
tests bring the suite to nineteen, each proving its check fires on the defect it
was written for.

## 0.6.3 - 2026-08-30

Closing the last four anti-slop findings, one of which 0.6.2 created while
fixing another.

- **A grade withdrawn in the reference doc was left on the shipped card.** 0.6.2
  removed `SYS-06` from the `evidence-based` row, because the rate cited there
  measures unrequested actions, which is scope creep, not confirming an
  irreversible action. The card kept `evidence=evidence-based`, so the doc and
  the artifact disagreed. `SYS-06` is now `practitioner`, which is honest: it
  has no published rate of its own.
- **The evidence table still cited a figure removed from `evidence.md`**: the
  untraceable ~42% and ~76% sycophancy pair. Replaced with the half that holds,
  14.66% across 15,345 responses on three models.
- **The wrong package-hallucination denominator survived** in `starter-pack.md`
  after being corrected in `evidence.md`.
- **A third assertion of Anthropic's prompt design as fact** in
  `precedence.md`, after two were labelled as inference in 0.6.2.

Tally after: two grades rest on measurement, two on documentation, one is
contested, fifteen are arguments. CI now asserts that tally against the shipped
cards in two places, and a seventeenth negative test proves it fires when a
grade is withdrawn in prose and left on a card.

## 0.6.2 - 2026-08-30

An anti-slop audit: 36 findings, 11 HIGH, 21 MEDIUM, 4 LOW. It opened by
correcting its own miscount, which is the standard this repository asks for and
rarely gets from a reviewer.

### Fixed: the repository accused itself of a defect that does not exist

0.6.1 recorded, in three files, a "model-family discrepancy nobody has
resolved": `evidence.md` naming Opus 4.5 and 4.6 while `verification.md` named a
Fable 5 system card. Confirmed by two independent routes that all three models
are real, concurrently published, and have their own system cards. The two files
cite different cards for different claims and never disagreed.

A false self-accusation is an unverified claim stated as fact wearing humility
instead of confidence, which makes it harder to spot, not easier. Removed.

Four lines away sat a real defect the note had distracted from:
`verification.md` attributed a constitution-adherence result to Fable 5 when the
card states it about Mythos 5. Corrected.

### Fixed: the gate blocked sentences about anything with no errors

`\bno errors?\b` was the only claim pattern with no anchoring noun, so "I read
the deploy log and it contains no errors" was blocked, with stderr insisting the
turn had claimed a test or build passed. Five such sentences measured, five
blocked. Removed, four regression cases added, suite now 50.

### Fixed: a check that suppressed the defect it was written for

`checks.sh` skipped the live gate-test count in its own comparison, so the
moment the count changed the check went quiet. A mutation test proved it: 46 to
47 with two stale documents reported `ok`. Skip list deleted, and on the next
run the check immediately caught two files saying 46 when the suite had 50.

The negative suite had the same disease: its mutation string was hardcoded, so
it would silently stop matching. Mutations now derive the live count, and a
sixteenth probe asserts a mutation that fails to apply is treated as a failure.

### Fixed: two quotations altered inside the quotation marks

The no-em-dash house rule had no exemption for quoted material, so two sentences
quoted from Anthropic engineering writing had their em dashes replaced with
commas. One changes the parse: "Let scripts, a compiler, a diff, a test suite,
be the referee" reads as a four-item list where the original is an appositive.

Both restored. Blockquote lines are now exempt, and the quotations are
blockquotes, so the exemption is visible on the page rather than implicit.

### Fixed: seven sources misstated, five figures named as untraceable

The citation pass checked 34 third-party claims against primary sources: 21
hold, 7 misstate a real source, 6 were not locatable.

Corrected: the package-hallucination denominator (19.7% is of package
references, not code samples); a rule-based checker gap presented as a general
range when it is one agent on two benchmarks; "11 of 12 runs" of inline
reimplementation when the paper says 5 of 12 and calls it not cheating; a
judge-accuracy figure presented as a benchmark property when it is one domain's
column; a "transcript-only" label on what is actually the no-trajectory
condition; a completion-claims category renamed, its scope overstated, and its
published rate described as absent when it exists and cuts against us.

A sycophancy figure of ~42% and ~76% across eight models could not be traced to
anything, and three near-neighbour papers contradict it. Removed, and `SYS-12`'s
grade now rests on the half that holds. The other five untraceable figures are
named individually in `evidence.md` rather than left looking like the rest.

### Fixed: smaller, and there were many

A `$schema` URL that 404s. A documented verification command that exits 1. A
quotation with no locatable source. Five orphaned sentence tails left when the
`Check:` lines were truncated. A third verdict vocabulary in the file that
forbids two. `last_assistant_message` filed as undocumented when it is
documented. A manifest claiming no script makes a network call, next to a
manifest tool list that was the judge's rather than the package's. A live-checks
README contradicting the CI that runs its script. An installer `--help` printing
a line of shell and hiding two flags that relax its guards. `uninstall.sh`
deleting two files it never checked ownership of, which would have destroyed a
hand-written judge or gate at those paths.

### Changed: inference is labelled where it is used, not only where it is filed

Three claims about Anthropic's production prompt design were filed as inference
in `verification.md` and stated as fact at every point of use. They now carry
the label where they are read. The same for "habits from a real incident are
followed better", which appeared as an acceptance criterion in
`CONTRIBUTING.md` while `verification.md` recorded it as unmeasured.

## 0.6.1 - 2026-08-30

Publication readiness. A fresh reviewer sequenced the work and found the worst
defect in the repository sitting in the one document whose job is to prevent it.

### Fixed: the provenance document asserted a falsehood about its own asset

`assets/PROVENANCE.md` said the cover image's origin was "not recorded" and that
"the file carries no metadata chunks that would show it."

The file carries a **23,617-byte C2PA manifest**. Verified here by reading the
PNG chunks: `c2pa.created` with `softwareAgent: gpt-image 2.0`,
`digitalSourceType: trainedAlgorithmicMedia`, `claim_generator_info: OpenAI
Media Service API`, signed under a certificate issued to OpenAI OpCo, LLC.

The sentence was written without opening the file, in the document that exists
so nothing is written without opening the file. An unverified negative, asserted
as fact, on the artifact at the top of the README. Rewritten with the manifest
contents and a command a reader can run to check.

Two related findings in the same pass: the derived `social-preview.png` **lost**
those content credentials when ImageMagick resized it, which is now disclosed;
and the retired SVG banners are still in git history, so a clone contains them,
where the old text claimed they were "not part of the distribution".

The README now discloses that the cover is AI-generated, which it never did.

### Fixed: a check that could not detect the defect it was written for

The gate-test-count assertion grepped three files with `grep -q`, which passes if
**any one** carries the right number. So it reported `ok` on a repository where
`gates.md` said 27 and the suite had 46. Its own pass message admitted it:
"stated somewhere current."

Rewritten per file. And `.github/test-checks.sh` now reintroduces fifteen
defects into a copy of the repository, one at a time, and requires `checks.sh` to
fail on each. This is the package's own rule about judges and gates, applied to
the checks themselves: an instrument only ever observed passing is untested.

It found two more bugs on its first run. The new count check called
`git ls-files`, which returns nothing in a copied tree, so it passed vacuously.
That is the same class as the disjunction it replaced.

### Fixed: three stale counts and a duplicate vocabulary

`gates.md` said 27 gate tests (46). `SECURITY.md` said the gate is 119 lines
(150), in the paragraph telling readers to audit it. `CHANGELOG` said 17
installer tests (19). `habit-card.md` defined `evidence` twice, thirty lines
apart, with two incompatible vocabularies, one of which no shipped card uses.
`methodology.md` described the pack's grades as "two documented, the rest
arguments" when three rest on published measurements. CI now catches all of it.

### Changed: evidence.md is demoted rather than dressed up

The file carries roughly thirty specific numeric claims about third-party
research with **zero source links**. It now says so at the top, in full: treat
every number as `[SEARCH]`-grade, this is a defect and not a style, and the
right fix is a citation pass rather than a disclaimer. Filed under "Known and
unfixed". A "model-family discrepancy" recorded here in 0.6.1 turned out not to
exist: Opus 4.5, Opus 4.6 and Fable 5 are three real, concurrently published
models with their own system cards, and the two files cite different cards for
different claims. That note was a false self-accusation, which is an unverified
claim stated as fact wearing humility instead of confidence. Removed in 0.6.2.

`NOTICE` no longer points at a disclosure that did not exist.

### Added: citations, and a hedge where a claim was untested

The quoted-documentation list in `verification.md` now carries its sources: six
documentation URLs plus the plugin marketplace. The README's claim about the
plugin invocation name is hedged to match `verification.md`, which says it was
never tested.

### Changed: commit history rewritten to a noreply address

Before publication, while it was still cheap.

## 0.6.0 - 2026-08-30

Two adversarial reviewers in separate contexts, per the doctrine this package
adopted in 0.5.0. One audited the artefact against frozen criteria; one audited
packaging and portability. Both returned `improved_not_passed`. Every measured
finding was reproduced here before being acted on.

### Fixed: the gate blocked honest reports of failure

The worst defect in this project's history.

```
exit 2  The tests do not pass yet.
exit 2  The build is not clean.
exit 2  CI is red: the tests do not pass.
```

The claim pattern matched a noun and a success verb inside a sliding window and
could not see the negation between them. Installed, that gate would have taught
an agent that reporting failure is punished and saying nothing is safe: the
concealment outcome `gates.md` names, produced by the artefact meant to prevent
it, against the exact behaviour `SYS-04` requires.

Three more measured defects in the same pass. The printed remedy "if the
evidence came from an earlier turn, say so" was unreachable by construction. One
common word (`will`, `should`) let a real false claim through. And 21 of 35
non-claiming sentences were blocked, including "I added a test that works around
the flaky timer".

Rebuilt as high-precision matching: an explicit list of claim shapes, then
disqualifiers for negation, attribution, instruction and modality, with
attribution at sentence scope and the rest per clause so "all tests pass and I
will commit" is still caught. 46 tests, carrying every phrasing both reviewers
measured.

### Fixed: the gate failed open on macOS

Sentence splitting used `sed 's/x/\n/'`, which yields a newline on GNU and a
literal `n` on BSD. On macOS the message collapsed to one line and the laundering
case the docs claim to defeat was allowed. It is `awk` now, and macOS is in CI.

### Fixed: the install command had never been run

`cp -r ... ~/.claude/skills/habits` failed outright on a machine with no
`~/.claude/skills`, and on a second run produced `skills/habits/habits/`, a
complete nested duplicate with a stale `SKILL.md` above it. A repository whose
flagship habit is verify with the real thing shipped an install command nobody
executed.

Replaced by `install.sh` and `uninstall.sh`, with 19 assertions in CI on Linux and
macOS: fresh install, reinstall with no nested duplicate, ownership marker,
atomic staging, gate staged but never enabled without `--apply`, `--apply`
appending rather than replacing and being idempotent by resolved command path,
refusal on invalid JSON, backup with a hash guard and `--revert`, and an
uninstall that deliberately keeps your habits and cases.

It never installs a habit. `/habits setup` does that, after showing you the file.

### Fixed: twenty habits ship and seven files said nineteen

`SYS-16` was added in 0.3.0 and no count followed it, including both manifests
and the marketplace description a stranger reads. The README pack table omitted
it entirely. `.github/checks.sh` now asserts the count, so it cannot drift again.

### Fixed: the grader existed in two divergent copies

The 0.5.0 rule says a `check` may not be changed in response to a failure it
produced. The package then shipped every check twice, seven of twenty differed
substantively, no copy was canonical, and `CONTRIBUTING.md` claimed CI compared
them when it compared only the card text. All twenty are now identical, the
shipped card is canonical, and CI compares them verbatim.

### Fixed: two precedence ladders, again

The 0.5.0 fix moved the contradiction rather than removing it: `SKILL.md` still
carried the old six-rung ladder with safety below the user and no skills channel,
while `precedence.md` carried the corrected eight. `SKILL.md` is the file the
agent loads. They now match.

### Fixed, smaller

- `habit-card.md` contradicted its own new evidence vocabulary twenty lines
  later, still describing `sourced` and `reasoned` and saying the grade
  describes the rule, which is the inversion of the 0.5.0 rule.
- Every shipped card now carries an `evidence` grade. The 0.5.0 regrade was
  announced in the changelog and absent from the artefact.
- Shipped cards no longer carry `lapses=0`. The package forbids exactly that
  fabricated zero and stamped it on twenty un-judged cards.
- `verification.md` said reward hacking, green-washing and scope creep had no
  published measurement, one release after `evidence.md` published rates for all
  three; and said sixteen gate tests when there were 27, now 46.
- `review.md` carried a third verdict vocabulary in the release that forbade
  mixing two, omitted the `stakes=critical` route to enforcement, and pointed at
  the wrong reference for hooks.
- `SECURITY.md` said all the live checks run in CI; one spends model quota and
  never runs there.
- A worked example cited `SYS-08` for green-washing, which is `PRJ-03`.

### Added: packaging

`AGENTS.md` with a portability table that says plainly which three of the four
mechanisms do not travel; thin `CLAUDE.md` and `GEMINI.md` pointers rather than
duplicated copies, since a repo about not duplicating rules cannot duplicate its
own. `NOTICE` carving quoted Anthropic documentation out of the MIT grant, with
a trademark and non-affiliation statement. `assets/PROVENANCE.md`, which records
honestly that the cover image's origin is **not established** and must be before
publication. `RELEASE_CHECKLIST.md`, `SUPPORT.md`, `.gitattributes`,
`dependabot.yml`, and a `.shellcheckrc` whose exclusions carry their reasons.

Manifests gained the marketplace description whose absence was failing
`claude plugin validate --strict`, matching versions, and a `metadata` block
declaring the package's tools and permissions. A reviewer suggested top-level
`allowed-tools` and `permissions` keys, copied from a sibling repository; that
was verified and rejected, because the validator warns on both as unknown fields
and `--strict` fails.

CI now runs structure, 46 gate tests, 19 installer assertions, shellcheck at warning
severity, and manifest validation, on Linux and macOS.

## 0.5.0 - 2026-08-29

Read `AgriciDaniel/secretary`, `AgriciDaniel/sync`, and
`AgriciDaniel/gauntlet-loop-brain` and applied what transferred. All three keep
their evidence in a separate, dated, refreshable place from their rules, which
is what this package was already trying to do without the discipline to name it.
`methodology.md` now credits each borrowing to its source.

### Added: the rule that closes the largest hole

**A `check` may not be changed in response to a failure it produced.** Nothing
prevented that before, and it is the same move as editing a test to make a suite
green, except worse, because nobody is watching a metadata comment. A check may
change only through a recorded decision that stands without reference to the
failure, and the lapse history re-baselines because it was measured against a
grader that no longer exists.

Sharpening a *trigger* after a miss is the repair ladder. Sharpening a *check*
after a miss is grader tampering. `assets/templates/decision.md` exists to make
the difference visible.

### Changed: the evidence vocabulary, and one rule that reframes it

`evidence` now takes `evidence-based`, `institutional`, `practitioner`,
`contested`, or `folklore`, and it grades **the fact underneath the habit, not
the habit**. The rule that makes it work:

> A local operating rule is synthesis even when every input is official.

Two habits previously graded `sourced` are regraded `institutional`, and the
grade no longer implies anyone authoritative endorsed the rule. `PRJ-03` is now
`contested` rather than carrying a footnote. When a habit mixes levels, take the
least certain material that affects what it does.

### Added: a check should be a command, not an adjective

Three strengths, in order: a command and its exit code, a transcript predicate a
stranger could apply, an adjective. Only the first is mechanically gateable, and
the third is not a check at all. Most habits will sit in the middle, which is
fine, but the ranking tells you which ones have a path to the gate tier.

### Added: evaluator authority, and no averaging

Five rules for when the tiers disagree. Deterministic outcome evidence outranks
prose judgment; a model judge may grade what a script cannot and may not override
a failed hard gate; and unresolved disagreement is recorded and escalated, never
averaged into a convenient pass. That last one decays quietly, because averaging
feels like fairness and is the disappearance of a dissent.

### Added: run outcomes and a stop contract, reconciling the two reviews

The independent review called the six-value outcome vocabulary cargo cult, and it
was right about the ledger row: `PASS`, `FAIL`, `N/A`, `UNKNOWN` carry that
weight and mixing vocabularies blurs the distinction the ledger is built on. It
also named the real gap, that `/habits review` could run three of eight steps
with no way to say so.

So the vocabulary is adopted at the **run** level only. Every run fixes a budget
before starting, and a run that hits it reports `budget_stopped` with the steps
that ran.

### Added: two operating rules, and a refresh cadence

Classification is the skill's job; enforcement and evidence belong to the
mechanism; neither does the other's work. And an escalation trigger is evaluated
before starting, never mid-task, because a trigger checked under sunk cost bends.

`verification.md` gained three refresh clocks: monthly for harness behavior,
quarterly for research, every time before publishing. A record with no expiry
becomes a confident account of how things used to work, which has already
happened once to a source pack this project consulted.

## 0.4.0 - 2026-08-29

The evidence pass. A research stream returned measured base rates for the
failures these habits target and for the judging this package does. Several
constrain what it may claim, one indicts a habit in its own starter pack, and
one changes how habits should be written.

### Added: `references/evidence.md`

Measured base rates, kept separate from the rules so a reader can see what is
established and what is not.

**The ceiling, and it is now stated on the skill's front page.** On Anthropic's
Impossible Tasks evaluation an explicit forceful written instruction moved the
failure rate from 55% to 35% for Opus 4.5, and 50% to 23% for Opus 4.6. A
written rule roughly halves the failure and leaves a quarter to a third
standing. That is what the stated tier buys, and it is why the other two tiers
exist.

### Added: permission beats prohibition

The largest prompt-level effect in the material is not a rule against anything.
Giving an agent a sanctioned way to declare a task impossible cut cheating from
54% to 9% and 49% to 12% on unsolvable tasks, where forceful prohibitions move
the number by about half and one polite prohibition made it worse. A model with
no acceptable way to fail will find an unacceptable one, and much of what looks
like dishonesty is a missing exit.

`methodology.md` now says to write what the agent should do *instead* at the
moment of temptation, which is what the `Instead` form was already for, and it
is the reason the completion gate must never block an honest "I could not run
this".

### Added: context beats procedure, which is a caution about this package

One controlled study gave agents the dependency map so they knew which tests to
check: regressions fell from 6.08% to 1.82%. The same study gave the procedural
instruction *without* that context: regressions rose to 9.94%, worse than no
intervention at all. A procedural rule with no context attached can be worse
than nothing.

### Changed: what a judge verdict is worth

A transcript-only judge detects rule violations somewhat better than chance and
well below reliably: around 0.65 AUROC on false-success detection, and
conversation-level accuracy in the forties for the strongest frontier judges on
one benchmark. Giving a judge the artifacts moved alignment with human
evaluation from roughly 60% to the mid-80s.

`judging.md` now says so, a `FAIL` is framed as a flag worth checking rather
than a finding, and `UNKNOWN` gained entry criteria because abstention is cheap
to induce and buys agreement by spending coverage.

Two claims were also demoted to reasoning: that requiring a judge to quote
evidence improves reliability, which has no isolated ablation behind it, and
that a fresh context captures the benefit measured for cross-model critique,
which nobody has tested.

### Changed: evidence grades, including one demotion

`SYS-06`, `SYS-11`, and `SYS-12` are regraded `measured`: the failures they
target have published rates, and sycophantic reversal from a correct answer is
now the best-evidenced habit in the pack.

And the demotion. **`PRJ-03 No green-washing` is partly fighting a solved
problem.** Test hard-coding on Anthropic's reward-hack-prone coding suite fell
from 64% for Sonnet 3.7 to 0% for Opus 4.5 and 4.6. What has not been trained
out is what a model does when a task cannot be done at all.

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
