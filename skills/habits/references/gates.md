# Gates: the enforcement tier

A rules file asks. A gate does not ask.

Everything in `habits.md` is advisory. The documentation is explicit that
CLAUDE.md and rules are context the model may or may not act on, while hooks
"are deterministic and guarantee the action happens". So a habit whose failure
you cannot accept does not belong in prose, however firmly the prose is worded.
It belongs here.

This tier is small on purpose. Most habits should stay hints, because a gate
that fires wrongly is worse than a habit that is occasionally missed.

## What ships

`assets/gates/completion-gate.sh`, a `Stop` hook that refuses to let a turn end
claiming a test, build, lint, or type check came back clean when nothing was run
to find out.

It is the enforcement counterpart of `SYS-03 Verify with the real thing`, which
is the habit most worth enforcing: the failure is invisible to the person it
lands on, and the fix costs one command.

**Proven end to end.** In a live session the model wrote "Yes, the test suite
passes now" with nothing run. The gate blocked the turn. The model kept working
and finished with "I was unable to run the test suite because both `npm test`
and `npx jest` require approval." The false claim never reached the user. Full
record in `verification.md`.

## Install

The gate needs `jq`. Copy it somewhere stable and register it.

```bash
mkdir -p ~/.claude/hooks
cp assets/gates/completion-gate.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/completion-gate.sh
```

Then in `~/.claude/settings.json` for every project, or `.claude/settings.json`
for one:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/absolute/path/to/completion-gate.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

**The nesting is not optional and the failure is silent.** A flat form, with
`type` and `command` directly inside the event array, is accepted as valid JSON
and then never fires. This cost an hour of a live debugging session: the hook
appeared installed, the session ran normally, and nothing happened. If a gate
seems inert, check the shape before checking the script.

Verify the install by making the claim yourself. Ask the agent, in a project
with no test runner, to state whether the tests pass. Either it declines to
claim, which is the behavior you wanted anyway, or the gate blocks it.

## How it decides

In order, and it exits 0 the moment any step is uncertain:

1. `stop_hook_active` is true, meaning a gate already blocked this turn. Allow,
   always. This is the loop guard and it comes first.
2. The message discloses that the check was not run. Allow. Honest disclosure is
   the behavior being asked for, so blocking it would train the wrong lesson.
3. The message contains no claim that a runnable check came back clean. Allow.
4. A tool call in this turn looks like a real check and its result came back
   without an error. Allow. "Looks like a real check" means a shell command
   whose text matches a check pattern (`npm test`, `pytest`, `cargo build`,
   `tsc`, `eslint` and friends), or a non-shell tool whose *name* matches one.
   Be clear-eyed about that second case: a name is not an observation, so an
   MCP tool called `check_page` would count. Closing that would mean blocking
   everyone who runs tests through a tool the gate has never heard of, which is
   the expensive failure. The gate is honest about being one learned sentence
   from being defeated; it raises the floor, it is not a wall.
5. Otherwise block with exit 2, and say what to do about it.

Step 3 is per sentence, not per message, because a disclosure about one check
must not launder an unverified claim about a different one. "I have not run the
formatter, and separately all tests pass" still blocks on the second clause.

Step 4 has a subtlety worth stating, because the first version got it wrong and
a live session caught it: **an attempted command is not evidence.** The model
tried to run the suite, permission was denied, the transcript still recorded a
`Bash` tool call, and the gate counted the attempt and allowed a false claim
through. It now matches each call to its result and ignores any whose
`is_error` came back true. Unit tests cover both directions.

## Design rules for any gate you add

- **Fail open.** Any parse failure, missing field, unreadable transcript, or
  ambiguity exits 0. A false block wastes a turn and teaches the user to delete
  the gate, which costs you every future block. A missed block costs one
  unverified claim, which the judge still catches.
- **Never recurse.** Check `stop_hook_active` first. A gate that blocks its own
  correction is a hang.
- **Exit codes are not intuitive.** Only exit 2 blocks. Exit 1 is a non-blocking
  error and the turn proceeds anyway, which looks exactly like a gate that
  works and does nothing. Test the exit code, not the logic.
- **Say what to do.** The stderr text is what the agent reads. "Blocked" teaches
  nothing. Name the two or three ways out.
- **Reward the honest path.** Any gate that punishes disclosure produces
  concealment.
- **Narrow triggers.** Enforce claims that are cheap to actually verify. A gate
  on something expensive to check will be routed around. Narrow means the
  trigger is an unhedged past-tense assertion, not any sentence containing the
  word "pass": an instruction, a question, reported speech, and a hedged future
  are all not claims, and an early version of this gate blocked all four.
- **Know the ceiling.** Claude Code overrides a `Stop` hook and ends the turn
  after eight consecutive blocks. A gate cannot hold a session hostage, which is
  a good property, and it also means a gate that fires constantly stops working
  rather than escalating.

## Between prose and a hook

A hook is not the only mechanism stronger than a rules file. Two others are
documented and worth knowing before you write a script.

- **A check in the prompt.** Ask for the check and the iteration in the same
  message. Weakest, but free, and the official guidance leads with it.
- **A `/goal` condition.** A separate evaluator re-checks the condition after
  every turn and the agent keeps working until it resolves. This sits between a
  prompt and a hook: no script to write, but scoped to one session.
- **An adversarial review subagent.** Officially recommended before treating a
  task as done, because a fresh context is not biased toward the code it just
  wrote. That is the judged tier, and `judging.md` covers it.

Reach for a hook when the check must apply to every session without anyone
remembering to ask for it.

## Other events worth a gate

| Event | Fires | Blocks | Reasonable use |
|---|---|---|---|
| `PreToolUse` | before a tool call executes | yes | forbid a command shape, guard a path |
| `PostToolUse` | after a tool call succeeds | no | format, lint, log |
| `Stop` | when Claude finishes responding | yes | completion gates like this one |
| `SessionStart` | when a session begins or resumes | no | inject state that must always be present |

`PostToolUse` fires only on success, so a habit about handling failure does not
belong there.

## When not to build a gate

- The habit is about judgment, tone, or scope. A shell script cannot see it.
- The check is expensive. A slow gate on every turn is a tax on every turn.
- It has never actually been missed. Enforcement is for a habit that reached
  the third rung of the repair ladder, not for one that sounds important.

## Removing one

Delete the entry from settings. Say so out loud when you do, because a gate that
was quietly removed leaves a habit that everyone still believes is enforced,
which is worse than never having had it.
