#!/usr/bin/env bash
# completion-gate.sh
#
# A Stop hook that refuses to let a turn end claiming a test, build, lint, or
# type check passed when nothing was run to find out.
#
# This is the enforcement rung of the habits skill. A rules file asks. This
# does not ask.
#
# Install: see references/gates.md. Requires jq.
#
# Design rules, in order of importance:
#   1. Fail open. Any uncertainty, any parse failure, any missing input exits 0.
#      A false block wastes a turn and teaches the user to delete the gate.
#      A missed block costs one unverified claim, which the judge still catches.
#   2. Never recurse. stop_hook_active short-circuits immediately.
#   3. Reward disclosure. An honest "I have not run this" is not blocked.
#   4. Narrow triggers. Only claims about a check that is cheap to actually run.

set -uo pipefail

input=$(cat 2>/dev/null) || exit 0
[ -n "$input" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# 2. Never recurse.
[ "$(jq -r '.stop_hook_active // false' <<<"$input" 2>/dev/null)" = "true" ] && exit 0

msg=$(jq -r '.last_assistant_message // ""' <<<"$input" 2>/dev/null)
[ -n "$msg" ] || exit 0

# 3. Reward disclosure. If the turn already admits the check was not run, allow.
if grep -Eiq 'have not (yet )?(run|executed|verified)|did not run|not (yet )?verified|unverified|without running|could not run|untested' <<<"$msg"; then
  exit 0
fi

# 4. Narrow trigger: a claim that a runnable check came back clean.
claim='\b(tests?|test suite|specs?|build|builds|lint|linter|type ?check|typecheck|compilation|compiles?|compiled|ci)\b[^.!?]{0,60}\b(pass(es|ed|ing)?|green|clean|succeed(s|ed)?|work(s|ed|ing)?|no errors?|without errors?)\b'
claim_alt='\b(all|every) (tests?|checks?|specs?)\b[^.!?]{0,30}\b(pass(es|ed|ing)?|green|clean)\b'
grep -Eiq "$claim" <<<"$msg" || grep -Eiq "$claim_alt" <<<"$msg" || exit 0

# 5. Did anything actually run this turn? Fail open if we cannot tell.
transcript=$(jq -r '.transcript_path // ""' <<<"$input" 2>/dev/null)
[ -n "$transcript" ] && [ -r "$transcript" ] || exit 0

# Line number of the last real user prompt: type user, not meta, and carrying
# text rather than a tool result. Everything after it belongs to this turn.
start=$(jq -n --slurpfile t <(cat "$transcript" 2>/dev/null) '
  [ $t[] | select(type == "object") ] as $rows
  | [ range(0; $rows | length) as $i
      | select(
          $rows[$i].type == "user"
          and ($rows[$i].isMeta != true)
          and (
            ($rows[$i].message.content | type) == "string"
            or (($rows[$i].message.content // []) | map(.type) | index("text") != null)
          )
          and ((($rows[$i].message.content // []) | type) != "array"
               or (($rows[$i].message.content // []) | map(.type) | index("tool_result") == null))
        )
      | $i ]
  | last // -1' 2>/dev/null) || exit 0
[ -n "$start" ] && [ "$start" != "null" ] && [ "$start" -ge 0 ] 2>/dev/null || exit 0

# A tool call that was denied, errored, or never returned is not evidence.
# Count only verification calls whose result came back without is_error.
ran=$(jq -n --slurpfile t <(cat "$transcript" 2>/dev/null) --argjson start "$start" '
  [ $t[] | select(type == "object") ] as $rows
  | ($rows[($start + 1):]) as $turn
  | [ $turn[]
      | select(.type == "user")
      | ((.message.content // []) | if type == "array" then .[] else empty end)
      | select(.type == "tool_result" and .is_error == true)
      | .tool_use_id ] as $failed
  | [ $turn[]
      | select(.type == "assistant")
      | ((.message.content // []) | if type == "array" then .[] else empty end)
      | select(.type == "tool_use")
      | select(.name == "Bash" or .name == "BashOutput"
               or (.name | test("test|lint|build|check"; "i")))
      | select(([.id] | inside($failed)) | not) ]
  | length' 2>/dev/null) || exit 0
[ -n "$ran" ] && [ "$ran" != "null" ] 2>/dev/null || exit 0
[ "$ran" -gt 0 ] 2>/dev/null && exit 0

# 6. Claimed a clean check, ran nothing. Block, and say exactly what to do.
cat >&2 <<'MSG'
COMPLETION GATE: this turn claims a test, build, lint, or type check came back
clean, and no command was run in this turn to find out.

Do one of these, then finish:
  1. Run the check and show its actual output.
  2. If the evidence came from an earlier turn, say so explicitly and name it.
  3. If it was not run, say that plainly instead of claiming it passed.

This gate blocks once per turn and never repeats.
MSG
exit 2
