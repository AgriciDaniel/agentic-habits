# Agentic habits

## The problem this solves

It is tempting to say the agent forgets. That is false, and the falsehood
matters, because it points the fix in the wrong direction. Claude Code persists
instructions at four CLAUDE.md scopes, in `.claude/rules/`, in skills, in hooks
and settings, and in auto memory that Claude writes for itself and reloads every
session. Delivery is a solved problem, five times over.

The real gap is between an instruction arriving in the context window and the
model's next tokens actually bending to it. The first is deterministic. The
second is probabilistic, degrades as the file grows, and is the only thing
anyone actually wants.

The usual answers both fail in a specific way.

Telling the agent again works, and lasts exactly as long as the chat. Writing
everything into a permanent instructions file works until the file gets long,
and then it stops working, because a long file of general advice produces
general behavior. Anthropic's own guidance is blunt about it: target under two
hundred lines, because longer files consume more context and reduce adherence,
and contradictory instructions get resolved arbitrarily.

So the question is not "how do I tell the agent to be better". It is "what
exactly is loaded at the moment the agent is about to get it wrong".

## Four laws

**1. Placement decides loading.** A person forms a habit by doing the thing
until the doing gets cheap. An agent has no such continuity. Its version of
repetition is the file that reloads. A rule is in context when its trigger
fires, or it may as well not exist, and the file it lives in is the only thing
that decides that. This is a claim about loading, and it is tested in
`verification.md`, both directions.

It is not a claim about compliance, and the two must not be blurred. Nothing in
the official documentation ranks a rules file above CLAUDE.md for adherence.
What differs between the advisory mechanisms is *when they load*, not how
binding they are. Placement is necessary. It is not sufficient, and a skill that
implies otherwise is selling the same hint in a better filing system.

**2. Only a gate decides adherence.** The documentation draws the line for you:
CLAUDE.md instructions are advisory, hooks "are deterministic and guarantee the
action happens". Permissions, tool scoping on a subagent, and plan mode are
enforcement too, because the harness executes them rather than asking the model
to. Everything else on the list is a hint, however firmly it is worded. That is
not an argument against hints. It is an argument for knowing which is which, and
for escalating the few habits whose failure you cannot accept.

**Context beats procedure, and this is the caution to sit with.** One controlled
study gave agents the dependency map so they knew which tests to check, and
regressions fell from 6.08% to 1.82%. The same study gave another group the
procedural instruction *without* that context, and regressions rose to 9.94%,
worse than no intervention at all. Small study, smaller models, so read it as a
caution rather than a finding. But it points straight at this package: a
procedural rule with no context attached can be worse than nothing. That is why
a habit naming the user's actual test command beats a generic one, and why a
trigger that names no real moment should not be written at all.

**3. Specificity over sentiment.** "Be rigorous" is a feeling. "When a test
fails, never change the assertion to make it pass" is a decision procedure. The
test for a habit is whether an observer could tell, from the transcript alone,
whether it fired. If nothing observable differs, the habit is decoration, and
decoration is not free: it takes context from the habits that work.

**4. Budget over accumulation.** Adherence behaves like a shared resource. The
twentieth rule does not simply get followed slightly less often, it makes the
other nineteen slightly blurrier. The specific caps in this skill are design
choices anchored to the documented guidance that instruction files past roughly
two hundred lines reduce adherence, not measured thresholds. See
`verification.md`. This is the opposite of how people collect
rules, which is by adding. A habit set improves mostly by subtraction: each new
habit is an argument for retiring an old one, and a set that never loses a
member is a set that is quietly losing force.

## What this borrows from human habit research, and where it stops

The shape of the format is not invented. It comes from work on how people
actually change behavior, which converged long ago on the same answer: make the
cue explicit.

- **Implementation intentions.** Peter Gollwitzer's work found that goals stated
  as "when situation X arises, I will do Y" are acted on far more reliably than
  the same goal stated as an intention. That is exactly the When and Do card.
  The cue does the work, not the resolve.
- **Habit stacking.** Attaching a new behavior to an existing reliable moment
  beats scheduling it in the abstract. For an agent the reliable moments are
  concrete: before an edit, after a test run, before a commit, when a command
  fails. Anchor there.
- **Keystone habits.** A small number of behaviors make many others unnecessary.
  "Read before you write" prevents a whole family of downstream mistakes that
  would otherwise each need their own rule.
- **Never miss twice.** The recovery matters more than the streak. Here the
  recovery is not willpower, it is a placement change. See the repair ladder.
- **Friction design.** Make the good path easy and the bad path hard. For an
  agent the hard version is a hook, which does not care what the agent decided.

Where the analogy stops, and it matters: none of this research is evidence that
a language model forms habits. It is not doing reinforcement, and nothing here
strengthens over time through use. Two lines in a rules file are as strong on
day one as on day ninety. What is actually being engineered is context, and the
human research is being used for its format, not as proof of a mechanism. Any
claim in this skill about what improves adherence should be read as a design
argument plus the vendor's documented behavior, not as a measured result.

## What a good habit looks like

Five tests. A habit that fails one is worth rewriting. A habit that fails two
is worth dropping.

1. **It has a moment.** The When names something that actually occurs in a
   session: a tool about to run, a claim about to be made, a file about to be
   touched. Not a topic, not a virtue.
2. **It has one action.** One Do. A habit with three clauses is three habits
   sharing an ID, and it will be followed one clause at a time.
3. **It is checkable.** You can say what would be visibly different in the
   transcript. Write that down as the check, even if nobody ever runs it.
4. **It is not already said elsewhere.** If CLAUDE.md covers it, sharpen the
   CLAUDE.md line into a trigger instead of adding a second copy that can drift.
5. **It is worth its context.** It fires often enough, or the failure it
   prevents is expensive enough, to earn two lines in every session.

## What a bad habit looks like

- **The mood.** "Be thorough." Nothing to fire on.
- **The essay.** A paragraph with conditions and exceptions, which the agent
  will average out into a vibe.
- **The duplicate.** The same idea in three files, worded differently, so the
  agent picks one arbitrarily.
- **The always.** "Always ask before doing anything." A trigger that matches
  everything is a trigger that selects nothing, and it will be dropped first
  under pressure.
- **The one-off.** A rule written after a single bad session that describes that
  session and never fires again. Log it, do not enshrine it.
- **The mandate.** A rule that must never fail, written as prose. If it must
  never fail, it belongs in a hook. Prose is guidance, not enforcement, and
  saying it more firmly does not change that.

## Three tiers, and the honesty they force

Once you accept that loading and following are different, the design falls out.

**Stated** is a rule in a file that loads when its trigger fires. It is a hint.
A well-placed, well-worded, well-timed hint, which is worth a great deal and
guarantees nothing.

**Gated** is a hook. The harness executes it whether the model agrees or not,
which is the only guarantee available. It costs more to build, it can fire
wrongly, and it can only see what a script can see. Reserve it for the few
habits whose failure you actually cannot accept.

**Judged** is a verdict after the fact, from evidence, in a context that did not
produce the work. It cannot prevent anything. What it does is make adherence
observable, and a habit set that cannot be observed cannot improve, which is how
rule sets quietly become decoration.

Most published rule sets are tier one presented as if they were tier two. The
tell is a document full of MUST and ALWAYS with no mechanism anywhere in it. The
correction is not to write softer rules. It is to say which tier you are in.

## Case law

A habit that never accumulates evidence is an opinion that got filed.

So every firing and every miss worth remembering becomes a case: what happened,
the evidence, and the worked pair showing what was done beside what the habit
asks for. Habits cite their cases. The cases are the reason the habit exists,
and they are what makes it possible to retire one without arguing.

This is also where the format earns itself. Anthropic's own production prompts
spend their largest line budget on worked good and bad pairs with rationales,
because a rule stated abstractly does not generalize while a worked pair does.
The same logic applies here, with one constraint: the pair is expensive and the
loaded file has a budget. So the two-line card stays in context and the worked
pair lives in the case file, loaded when someone is judging, reviewing, or
learning the habit rather than in every session forever.

That is the same placement decision as everything else here, applied to the
skill's own material.

## The lifecycle

An ever-growing habit set is not one that only grows. It is one that keeps
cycling.

```
notice -> draft -> place -> observe -> sharpen -> promote -> escalate -> retire
```

### Permission beats prohibition

The largest prompt-level effect in the measured material is not a rule against
anything. Giving an agent an explicit, sanctioned way to **declare a task
impossible** cut cheating from 54% to 9% for one model and 49% to 12% for
another, on tasks with no legitimate solution. Forceful prohibitions in the same
setting move the number by about half, and one politely worded prohibition made
it worse.

The reading: a model with no acceptable way to fail will find an unacceptable
one. Much of what looks like dishonesty is a missing exit.

So when a habit is about to be written as a prohibition, ask what the agent
should do *instead* at that exact moment, and write that. It is why the
substitution form here uses **Instead** rather than "do not", why `SYS-04` is
about reporting a miss rather than forbidding a false claim, and why the
completion gate is careful never to block an honest "I could not run this". A
gate that punishes the exit closes the exit.

### Derived, not speculative

This is the sharpest test available for whether a rule belongs in a file at all,
and it cuts against most published rule sets, including parts of this one.

A rules file is well supported as a **sink for observed repeated failures**.
Anthropic's own migration playbook says it plainly: "When a reviewer keeps
catching the same mistake across files, the fix isn't per-file. You add one
sentence to the rulebook and regenerate the affected batch." The same shape
appears as "when Claude makes a mistake twice, the correction goes into
CLAUDE.md".

What is not well supported is the speculative, prohibition-shaped rule written
upfront because it seems prudent. Nothing recommends those, and the documented
cost of a bloated instruction file lands on them first.

So: **a habit harvested from a recurring correction is on solid ground. A habit
authored upfront from what seems wise is not.** That distinction should decide
what survives a review, and it is uncomfortable here for an obvious reason. The
starter pack in this repository is authored upfront. It is a menu of plausible
rules, drafted from known failure patterns rather than harvested from your
sessions, and its own evidence grades say as much: two of twenty are documented,
the rest are arguments.

Treat the pack as a vocabulary for writing your own, not as a set to adopt. The
habits that will actually earn their context are the two or three you write
after something goes wrong, and those are the ones with a case attached.

**Notice.** The signal is repetition: the same correction twice, the same
cleanup after the agent twice, the same explanation typed again. One occurrence
is noise. Auto memory is a useful upstream detector here, since Claude records
corrections as feedback notes on its own. A feedback note that keeps recurring
is a habit waiting to be written. Memory notices, a habit enforces.

**Draft.** Turn it into When and Do. This is where most of the value is, and it
usually takes one question: when would this have changed what you did.

**Place.** Narrowest scope that covers the trigger.

**Observe.** Honestly, and only from evidence. Most habits will sit at unknown,
and that is fine. What matters is catching the ones that visibly miss.

**Sharpen, promote, escalate, retire.** The repair ladder in `review.md`.

## The relationship to everything else

Four mechanisms, four jobs, and confusing them is the most common way an
instruction set rots.

| Mechanism | Job | Loaded |
|---|---|---|
| CLAUDE.md | identity, standards, architecture, what the project is | every session |
| Habits (rules files) | trigger-shaped behavior at a specific moment | every session, or on matching files |
| Skills | procedures that only matter when invoked | on demand |
| Hooks | the thing that must happen regardless of judgment | at the lifecycle event |

If it is a multi-step procedure, it is a skill, not a habit. If it must never be
skipped, it is a hook, not a habit. If it describes what the project is rather
than what to do at a moment, it is CLAUDE.md, not a habit. What is left, the
small set of moments where the agent reliably goes wrong and a single sentence
would fix it, is exactly what habits are for.
