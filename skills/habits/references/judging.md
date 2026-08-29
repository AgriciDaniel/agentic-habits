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

This is `/habits check`, and it runs as a verdict, not an opinion.

**Fresh context.** The reviewer that never wrote the work spots what the writer
who just finished cannot. Use the `habit-judge` agent, which has read-only
tools, so its verdict cannot be quietly improved by fixing the thing it is
judging. Same-context self-review is allowed but must be labelled as such, and
it never counts as independent.

**The ledger.** One row per habit, and the schema is deliberately the same shape
as a claim ledger:

| habit | fired | evidence | verdict |
|---|---|---|---|
| SYS-01 | yes | 3 edits, each preceded by a Read of that file | PASS |
| SYS-03 | yes | "build is fixed" with no command run in the turn | FAIL |
| SYS-06 | no | no irreversible action this session | N/A |
| SYS-13 | unknown | not visible from a diff alone | UNKNOWN |

**The gate on the gate.** PASS requires a quotation, a line reference, or a
command result. **No evidence means not PASS.** UNKNOWN is a legitimate and
common verdict, and reporting it honestly is the entire value of the exercise. A
judge that returns mostly PASS on thin evidence is worse than no judge, because
it manufactures confidence.

**A FAIL is an offer, not a write.** Ask before recording a lapse. The user may
know the miss was correct in context, and a lapse count that includes justified
misses will retire the wrong habits.

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
