# <YYYY-MM-DD> <short title>

<!-- case: id=<YYYY-MM-DD-slug> habit=<ID|none> verdict=<PASS|FAIL|N/A|UNKNOWN>
     source=<observed|reported|judge> -->

**What happened.** Two or three sentences. What the agent did, at what moment,
and what it cost. Written so someone who was not there can recognize the shape
when it happens again.

**Evidence.** The quote, the line reference, the command output, or the diff
hunk. If there is none, say so and mark the verdict UNKNOWN rather than writing
a verdict the evidence cannot carry.

**Habit.** The ID this bears on, or `none` if it is a candidate for a habit that
does not exist yet.

**Worked pair.** What was done, beside what the habit asks for. This is the part
that teaches, and it is why cases are worth keeping.

> Instead of: "Fixed. The build is green."
>
> The habit asks for: "Fixed. `npm run build` exits 0, output below."

**Outcome.** What changed because of this case: habit sharpened, placement
moved, gate proposed, habit retired, or nothing yet.
