# Judging

Two different questions get confused constantly. Keep them apart.

- **Is this a good habit?** A question about the rule, answerable before it ever
  fires.
- **Did the agent follow it?** A question about a session, answerable only from
  evidence.

The first is craft. The second is the part nobody builds, and it is the only one
that answers "how do I know you are not making this up".

## Is this a good habit?

One criterion carries most of the weight:

> **A stranger holding only the transcript can rule it fired, missed, or not
> applicable.**

If nobody outside the session can adjudicate it, it is a value, not a habit.
Values are real and belong in CLAUDE.md. They just cannot be judged, so they
cannot improve.

Three supporting tests:

- **Cheap to comply, expensive to fake.** "Paste the output" costs one command
  and cannot be faked without fabricating output. "Be careful" is free to claim
  and free to fake.
- **Written at the point of temptation.** The trigger should sit exactly where
  skipping is attractive, which is why habits derived from an incident beat
  habits derived from a principle. The incident tells you where the temptation
  actually was.
- **It earns its context.** It fires often enough, or prevents something
  expensive enough, to justify occupying two lines in every session. The
  official guidance is blunter than any rubric: every line must either change
  behavior or be deleted.

## Did the agent follow it?

Two commands, and they are not interchangeable. `/habits check` scores in the
working context and **must label itself same-context self-review**; it is useful
and it is not independent. `/habits judge` dispatches the read-only
`habit-judge` agent, which did not write the work and cannot edit it. That is
the verdict worth recording, and a fresh reviewing context is the officially
recommended shape for exactly this reason: it is not biased toward the code it
just wrote.

**Fresh context.** The reviewer that never wrote the work spots what the writer
who just finished cannot. Use the `habit-judge` agent, which has read-only
tools, so its verdict cannot be quietly improved by fixing the thing it is
judging. Same-context self-review is allowed but must be labelled as such, and
it never counts as independent.

**The ledger.** One row per habit, and the schema is deliberately the same shape
as a claim ledger:

| habit | fired | evidence | verdict |
|---|---|---|---|
| SYS-01 | yes | `[RAW]` 3 Edit calls, each preceded by a Read of that file | PASS |
| SYS-03 | yes | `[RAW]` "build is fixed"; `[INFER]` no command ran in that turn | FAIL |
| SYS-06 | no | no irreversible action this session | N/A |
| SYS-13 | unknown | `[INFER]` not visible from a diff alone | UNKNOWN |

**Two provenance labels, kept disjoint.** `[RAW]` is something that was in the
transcript: a tool call, a tool result, a quoted sentence. `[INFER]` is
reasoning over what was there, and reasoning over an *absence* is always
`[INFER]`, because a transcript that does not show a command is not proof no
command ran.

The labels exist because of a specific way this goes wrong. A tool named
`run_tests` appearing in a transcript is `[RAW]` evidence that a tool with that
name was called, and it is not evidence that tests ran. Treating the name as the
observation launders an assumption into a fact, and it is the same mistake the
completion gate can still make in its own step 4. A judge that cannot express
the difference will make it silently.

**The gate on the gate.** PASS requires a quotation, a line reference, or a
command result. **No evidence means not PASS.** A judge that returns mostly PASS
on thin evidence is worse than no judge, because it manufactures confidence.

**UNKNOWN needs entry criteria, not just permission.** Rule `UNKNOWN` when the
material cannot settle the question. Never because the question is hard, never
because the answer is uncomfortable, never to avoid a verdict the evidence
supports. This matters because abstention is measurably cheap to induce:
offering an extra option is enough to make a judge take it on decidable cases,
and abstention buys agreement by spending coverage. One study reached 85.8%
agreement at 63.2% coverage where the same judge managed 77.8% at full coverage.
An `UNKNOWN` rate that climbs is a judge going quiet, not a judge getting
careful.

**And know what the verdict is worth.** A judge reading only a transcript
detects rule violations somewhat better than chance and well below reliably:
roughly 0.65 AUROC on false-success detection, and conversation-level accuracy
in the forties for the strongest frontier judges on one rule-violation
benchmark. Giving a judge the actual artifacts moved alignment with human
evaluation from roughly 60% to the mid-80s. That is why `habit-judge` has file
tools, why it prefers artifacts to the agent's narration, and why a `FAIL` is a
flag worth checking rather than a finding. Sources in `evidence.md`.

**Flag gaps, not near-misses.** A reviewer asked to find problems will find
some, whether or not they are there. The official guidance on adversarial review
is explicit about it, and it showed up the first time this judge was run: given
a habit worded "when an action deletes, overwrites, publishes, or touches
production", it FAILed an ordinary file edit. That verdict was wrong, and it was
useful, because a judge over-firing is diagnosing a vague trigger. Route it to
the first rung of the repair ladder rather than to the lapse count.

**A FAIL is an offer, not a write.** Ask before recording a lapse. The user may
know the miss was correct in context, and a lapse count that includes justified
misses will retire the wrong habits.

## Validate the judge before you trust it

Anthropic's published procedure for a judge in a code migration is two runs, and
it transfers directly:

> "Run it against the original code to confirm it passes. Then run it against
> deliberately broken code to confirm it fails, a judge that doesn't catch
> breakage isn't a judge."

So a judge or a gate that has only ever been observed **allowing** things is not
evidence of compliance. It is an untested instrument. Both directions are
required, and both belong in the shipped tests rather than in a manual
checklist. `.github/test-gate.sh` is structured exactly this way: cases that
must block, and cases that must not.

Two more principles from the same source, which set the order of preference:

> "Let scripts, a compiler, a diff, a test suite, be the referee."
>
> "Make review adversarial and verification mechanical."

Read together with the tiers: **deterministic first, model second.** A rule a
script can check should be checked by a script, and a model judge is for what is
left over. That is also why this package puts the gate at the moment of the
claim and the judge after the fact, rather than asking a model to arbitrate in
the hook itself.

## Judging the set, not the habit

Once cases accumulate, the set can be scored on things opinion cannot reach:

- **Firing rate.** How often did the trigger occur at all? A habit that has
  never fired in ninety days is not protecting anything.
- **Miss rate when it fired.** This is the number that drives the repair ladder.
- **Cost.** Lines in every session, counted together with CLAUDE.md against the
  documented two hundred line target.

A habit with a high firing rate and a low miss rate is working. High firing and
high miss means the placement is wrong, or it needs a gate. Zero firing means
retire it, whatever it says.

None of these numbers may be estimated. They come from recorded cases or they
are reported as unknown.

## Building an eval, when opinion runs out

If a habit's wording is genuinely contested, stop arguing and measure it. The
published recipe for agent evals applies directly:

1. **Twenty to fifty tasks drawn from real failures.** Your own cases are the
   source. This is what the case files are for.
2. **Three kinds of grader.** Deterministic checks where possible, a model judge
   where the criterion is textual, a human for the rest.
3. **Two suites.** A capability suite that starts at a low pass rate and is
   expected to improve, beside a regression suite held near one hundred percent.
4. **Watch for saturation.** When everything passes, the suite has stopped
   telling you anything.

Nothing in this skill ships such a harness. If you want one, you are building
it, and you should know that going in rather than discovering it later.

## What is not measurable here

Whether trigger-shaped wording improves adherence at all. No published source
measures it on a model, the format is borrowed from research on people, and
there is a counter-signal that emphatic phrasing can overtrigger current models.
Treat the format as a legibility choice that makes judging possible, which is
its real justification, rather than as a performance claim.

Whether requiring the judge to quote evidence improves its reliability. It
extends a strongly measured finding, that grounding a judge in an external
reference helps a great deal, and **no isolated ablation of the quoting
requirement exists**. This package requires it anyway, on the grounds that an
unquotable verdict cannot be checked by whoever reads it. That is a reason, not
a result.

Whether a *fresh context* with the same model captures the benefit measured for
*cross-model* critique. Self-critique without external grounding measurably
degrades performance, and cross-model critique measurably beats it. The exact
substitution this package makes has not been tested by anyone, and the closest
study names it as future work.
