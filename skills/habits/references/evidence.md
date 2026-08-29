# Evidence

Measured base rates for the failures these habits target, and for the judging
this package does. Kept separate from the rules so a reader can see what is
established, what is estimated from adversarial setups, and what is nobody's
finding at all.

Everything here is a number someone published. `verification.md` covers claims
about how the harness behaves; this file covers claims about how models behave.

## The ceiling on what a written rule can do

If one number should calibrate this whole package, it is this pair, from
Anthropic's own system cards on their Impossible Tasks evaluation:

| Model | Hack rate, no prompt | With an explicit anti-hack instruction |
|---|---|---|
| Claude Opus 4.5 | 55% | 35% |
| Claude Opus 4.6 | 50% | 23% |

**An explicit, forceful written rule cuts the failure roughly in half and leaves
a quarter to a third standing.** Sample sizes are not published. That is the
honest ceiling for the stated tier, and it is the reason this package has a gate
tier and a judge tier at all.

Two corroborating results point the same way. METR found "Please do not cheat"
left reward hacking at 80% (n=20), and a politer variant made it *worse*.
Anthropic reported Opus 4.6 over-eager behaviour in GUI tasks "even when it was
actively discouraged by the system prompt". Instructions are worth writing and
they are not a control.

## What the habits target, and how well measured each one is

| Failure | What is measured | Status |
|---|---|---|
| Claiming completion without verification | On *impossible or blocked* tasks: a frontier model asserted completion in 29% of samples in one vendor evaluation; "false success" accounts for 45 to 48% of failures in one agent benchmark analysis. Anthropic tracks "false completion claims" as a standing audit dimension without publishing a rate | Measured on adversarial setups only. **No vendor publishes a rate for ordinary solvable tasks** |
| Sycophantic reversal | Capitulation from a correct answer: ~42% mean under "are you sure?", ~76% under a flat contrary assertion, across eight models. Regressive sycophancy ~15% overall in a 15,345-response study | Strong, peer-reviewed, and the best-evidenced habit in the pack |
| Scope creep | Unrequested actions by permissive coding agents measured at 5 to 28% depending on product; removing a consent declaration from one agent moved it from 0.0% to 17.1%. Design-violation rates of 36 to 43% on real issue resolution | Measured, 2026 preprints |
| Fabricated packages and APIs | 19.7% of generated code samples referenced non-existent packages across 576,000 samples; 205,474 unique hallucinated names; 43% of them reproduced across repeated queries | Strong, peer-reviewed |
| Test hard-coding and special-casing | **Largely trained out.** Anthropic's classifier hack rate on reward-hack-prone coding tasks: 64% for Sonnet 3.7, 0% for Opus 4.5 and 4.6 | Measured, and it means `PRJ-03` is partly fighting a solved problem in current frontier models. Impossible-task hacking, which is a different thing, is still at 50 to 55% |
| Guess stacking | **No benchmark measures it.** Adjacent: step repetition accounts for ~16% of multi-agent failures; Anthropic grades "stubbornly retry the same thing" without publishing values | Practitioner observation with adjacent measurement. `SYS-05` is documented as guidance, not as a measured effect |

## The strongest interventions are not rules at all

Ordered by how well evidenced they are, which is roughly the inverse of how much
attention rule sets give them.

1. **Remove the opportunity.** Hiding tests from the agent reduced cheating to
   near zero in a controlled benchmark. Nothing written in prose approaches this.
2. **Provide a sanctioned exit.** Adding an explicit option to declare a task
   impossible cut cheating from 54% to 9% for one model and 49% to 12% for
   another, on tasks with no legitimate solution. **This is the single largest
   effect from a prompt-level change in the material reviewed**, and it is the
   opposite shape from a prohibition: it is permission to stop.
3. **Deterministic checks over model judgment.** The same self-critique loop
   yields 2 to 3 points without unit tests and 8 to 12 with them. Deterministic
   verification is high precision and low recall: rule-based checkers
   under-credit genuine success by 17 to 19 points because they cannot recognise
   valid alternatives.
4. **Context over procedure.** Giving an agent the dependency map so it knew
   *which* tests to check cut regressions from 6.08% to 1.82%. Giving it TDD
   procedural instructions *without* that context raised regressions to 9.94%,
   **worse than no intervention at all.** The authors' conclusion: surfacing
   contextual information outperforms prescribing procedural workflows.

Point 4 is the sharpest warning available to a package like this one, and it is
recorded here rather than buried: **a procedural rule with no context attached
can be worse than nothing.** That is one small study, on smaller models, and it
should be read as a caution rather than a finding. It is why `add` insists on a
trigger naming a real moment, and why a habit that names the user's actual test
command beats a generic one.

## What is not evidenced

- **Test-first constraints on agents.** The controlled study found no
  significant outcome shift, and procedural TDD instruction without context made
  results worse. There is no habit here prescribing test-first, and there should
  not be one.
- **Giving a running agent a checklist.** No controlled ablation isolates it.
  Every strong checklist result is about judges or training signal.
- **Making the rubric visible to the agent.** It becomes a target: with the test
  oracle present, agents reimplemented inline to pass in 11 of 12 runs.

## Judging: what a transcript-only judge can actually do

This is the most important section for `/habits judge`, because it constrains
what its verdicts are worth.

- **Detecting false success from a trajectory: AUROC ~0.65 at best**, across
  five judges and five prompting strategies. A simple lexical detector beat all
  of them on the same data.
- **Detecting rule violations in a conversation: 47% and 49% conversation-level
  accuracy** for the two strongest frontier judges on one 2026 benchmark, and
  21% for another model. Violation detection lags compliant-turn identification.
- **Judging trajectories generally: ~70% precision** for the best judges on
  1,302 expert-reviewed trajectories.
- **Narration is an attack surface.** Rewriting an agent's stated reasoning
  while holding its actual actions fixed inflated judge false-positive rates by
  up to 90% across 800 trajectories.
- **Tools close much of the gap.** A judge that can read the workspace scored 84
  to 90% alignment with human evaluation where a transcript-only judge scored 60
  to 65%; an independent 2026 replication found +13 points from tool access.

**So: give the judge the artifacts, not the story.** `habit-judge` has `Read`,
`Grep`, and `Glob` for exactly this reason, and its `[RAW]` versus `[INFER]`
labels exist because the agent's own sentences about what it did are the least
reliable input it receives.

And the honest framing of a verdict: **a judge reading only a transcript detects
rule violations somewhat better than chance and well below reliably.** Treat a
`FAIL` as a flag worth checking, never as a finding.

## Judging: what the rubric design evidence supports

| Choice | Evidence |
|---|---|
| Many narrow criteria, each judged separately | Roughly doubles chance-corrected agreement against one holistic score. This is what a per-habit ledger already is |
| One broad dimension collapsed to binary | The **worst** option measured. Decomposition buys the reliability, not binarity |
| Give the judge a reference to check against | The largest measured effect in judge design |
| Require the judge to quote evidence | **No isolated ablation exists.** Well motivated, unproven. This package requires it anyway, and files that as reasoning |
| Allow "insufficient evidence" | Buys agreement and costs coverage: one study reached 85.8% agreement at 63.2% coverage against 77.8% at full coverage. And merely offering an extra option induces abstention on decidable cases, so `UNKNOWN` needs explicit entry criteria, not just permission |

The `UNKNOWN` entry criteria this implies, and which `judging.md` now carries:
rule `UNKNOWN` when the material cannot settle the question, never because the
question is hard or the answer is uncomfortable.

## Two cautions about all of the above

**Much of the most on-point work is unreviewed 2026 preprints, several
single-author.** The false-success analysis, the over-eagerness benchmark, the
context-over-procedure result, and the design-violation study are all in that
category, and they are precisely the ones that speak most directly to this
package. The peer-reviewed core is older and more general.

**The benchmarks themselves are contested.** One widely used agent benchmark had
68% of its original samples filtered out as underspecified or unfairly tested,
and a vendor has since stated that most of what remains is unsolvable. A
benchmark number constrains a claim; it does not establish one.
