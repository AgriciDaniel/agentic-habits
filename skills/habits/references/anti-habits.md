# Anti-habits

Twelve failure modes that show up across agents, tasks, and models. They are not
random errors. Each one is a shortcut that looks locally reasonable and is
globally wrong, which is exactly what makes it recur.

You do not remove one by forbidding it. A prohibition with no replacement leaves
the trigger with nowhere to go. Every entry below names the tell, the pull, and
the habit that occupies the same moment.

A note on the pull column: these are descriptions of a pattern and a plausible
pressure, not claims about model internals. Use them as diagnostics, not theory.

---

### 1. Phantom done

**Tell.** "All set", "this now works", "fixed" with no output between the change
and the claim.
**The pull.** The change looks correct, and running the check costs a step. The
claim is about the intention, not the observation.
**Replacement.** `SYS-03 Verify with the real thing`.
**Cost when it lands.** The user finds out instead, later, in a worse context.

### 2. Green-washing

**Tell.** A failing assertion gets relaxed, a case gets skipped, an expected
value gets edited to match the actual.
**The pull.** The goal was stated as "make the tests pass", and the shortest path
to a green suite runs through the test file.
**Replacement.** `PRJ-03 No green-washing`.
**Cost when it lands.** The suite now certifies the bug.

### 3. Guess stacking

**Tell.** A third and fourth variation of the same fix, each described as
probably it.
**The pull.** Each attempt is individually cheap, and stopping feels like
failing.
**Replacement.** `SYS-05 Stop at two`.
**Cost when it lands.** The original error is buried under new ones, and the
context is full of dead ends.

### 4. Drive-by refactor

**Tell.** The diff renames, reformats, or reorganizes code the task never
mentioned.
**The pull.** The surrounding code is genuinely worse than it could be, and
improving it feels like doing a good job.
**Replacement.** `PRJ-01 Smallest diff`.
**Cost when it lands.** Review gets harder, revert gets dangerous, and the real
change hides in the noise.

### 5. Silent assumption

**Tell.** An ambiguous request comes back fully resolved, with no sign that
there was a fork.
**The pull.** Picking is faster than asking, and one reading did seem more
likely.
**Replacement.** `SYS-14 Name the assumption`.
**Cost when it lands.** The wrong branch gets built completely before anyone
notices it was a branch.

### 6. Context amnesia

**Tell.** An edit to a file that was never read this session, often based on how
it looked earlier or how such files usually look.
**The pull.** Reading costs tokens and the shape of the file feels known.
**Replacement.** `SYS-01 Ground before changing`.
**Cost when it lands.** An edit that does not apply, or applies to the wrong
thing, or silently overwrites something that changed.

### 7. Confident invention

**Tell.** A flag, method, config key, package, or citation that is exactly what
should exist.
**The pull.** Fluency. The plausible completion is available and the check is not.
**Replacement.** `SYS-11 No invented interfaces` and `SYS-10 Cite the location`.
**Cost when it lands.** Wrong in the most expensive way, because it reads as
authoritative and fails downstream.

### 8. Sycophantic fold

**Tell.** A correct position abandoned the moment the user pushes back, with no
new evidence in between. Often signposted by an apology.
**The pull.** Agreement is comfortable and disagreement feels unhelpful.
**Replacement.** `SYS-12 Hold the line under pushback`.
**Cost when it lands.** The user loses the only independent check they had, and
does not know they lost it.

### 9. Boil the ocean

**Tell.** Exhaustive search, mass file reading, or several subagents dispatched
before the one obvious cheap check was tried.
**The pull.** Thoroughness is visible and feels like rigor.
**Replacement.** A local habit: when a question has a cheap decisive check, run
that first and stop when it answers.
**Cost when it lands.** Context is spent on breadth, and the answer that was one
grep away arrives late and diluted.

### 10. Narration theatre

**Tell.** Messages that describe upcoming work, restate the plan, or announce
each tool call.
**The pull.** It reads as engagement and fills the silence during long work.
**Replacement.** `SYS-15 No narration`.
**Cost when it lands.** The user reads more and learns less, and real progress
gets harder to find.

### 11. Cleanup by destruction

**Tell.** Reaching for a hard reset, a force push, a recursive delete, or a
checkout that discards changes, in order to get back to a clean state.
**The pull.** It works, immediately, and restores a known-good situation.
**Replacement.** `SYS-07 Protect what I did not write` and `SYS-06 Confirm the
irreversible`.
**Cost when it lands.** Someone else's uncommitted work is gone, with no undo.

### 12. Habit hoarding

**Tell.** The instruction files keep growing. Every incident adds a rule and
nothing is ever removed. Old rules contradict new ones.
**The pull.** Adding a rule feels like preventing a repeat, and deleting one
feels like accepting risk.
**Replacement.** The budget, and `/habits review` on a real cadence.
**Cost when it lands.** Adherence falls across the whole set, so the response to
each incident makes every previous fix slightly weaker. This is the anti-habit
that quietly disables all the others, and it is the one this skill exists to
prevent.

---

## Using this list

**As a diagnostic.** When something went wrong and the cause is not obvious, read
the tells. Most bad sessions are one of these twelve wearing local clothes.

**As a source of habits.** Do not install all twelve replacements. Install the
ones matching failures that actually happened here. A rule written from a real
incident is followed better than one adopted on principle, and it is far easier
to justify keeping when the budget gets tight.

**As a review lens.** During `/habits review`, ask which of these twelve the
current set does not cover, and whether any of them have shown up since the last
review. That question is usually more productive than reading the habit list
line by line.
