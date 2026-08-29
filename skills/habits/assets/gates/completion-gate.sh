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

# 3. Sentence by sentence, is there an unhedged assertion that a runnable check
#    came back clean? Questions, instructions, hedged futures, and sentences
#    that disclose the check was not run are all not claims.
#
#    Per sentence rather than per message: a disclosure about one check must not
#    launder an unverified claim about a different one.

disclose='\b(ha(ve|s)( not|n.t)|did( not|n.t)|do( not|n.t)|can( ?not|.t)|could( not|n.t)|unable|never|without|no way|not yet)\b[^.!?]{0,40}\b(run|ran|execut|verif|check|test)|\b(unverified|untested|by inspection|on my reading|in principle|from reading alone)\b'

hedge='\b(should|would|will|might|may|could|expect|assume|presumably|likely|probably|once you|after you|if you|please|whether|to confirm|to verify|let me|i.ll|going to|need to|make sure|try|suppose)\b|\b(on my reading|by inspection|in principle|appears|looks like|seems)\b'

claim='\b(tests?|test suite|specs?|build|builds|lint|linter|type ?check|typecheck|compilation|compiles?|compiled|ci)\b[^.!?]{0,60}\b(pass(es|ed|ing)?|green|clean|succeed(s|ed)?|work(s|ed|ing)?|no errors?|without errors?)\b'
claim_alt='\b(all|every) (tests?|checks?|specs?)\b[^.!?]{0,30}\b(pass(es|ed|ing)?|green|clean)\b'

found=""
while IFS= read -r sentence; do
  [ -n "$sentence" ] || continue
  case "$sentence" in *\?*) continue ;; esac              # a question is not a claim
  grep -Eiq "$hedge"    <<<"$sentence" && continue         # hedged or imperative
  grep -Eiq "$disclose" <<<"$sentence" && continue         # discloses it was not run
  if grep -Eiq "$claim" <<<"$sentence" || grep -Eiq "$claim_alt" <<<"$sentence"; then
    found="$sentence"; break
  fi
done <<< "$(printf '%s' "$msg" | tr '\n' ' ' | sed 's/\([.!?]\)/\1\n/g')"

[ -n "$found" ] || exit 0

# 4. Did a real check actually run this turn? Fail open if we cannot tell.
transcript=$(jq -r '.transcript_path // ""' <<<"$input" 2>/dev/null)
[ -n "$transcript" ] && [ -r "$transcript" ] || exit 0

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
case "$start" in ''|*[!0-9-]*) exit 0 ;; esac
[ "$start" -ge 0 ] || exit 0

# A tool call is evidence only when all three hold:
#   it was a shell command whose text actually looks like a check, or a tool
#   whose name is a check runner; its result came back; and that result was not
#   an error. A denied or failed call is an attempt, not an observation.
ran=$(jq -n --slurpfile t <(cat "$transcript" 2>/dev/null) --argjson start "$start" '
  def checkish: test("(^|[^a-z])(test|spec|lint|build|tsc|typecheck|type-check|pytest|jest|vitest|mocha|rspec|cargo|go +test|make|gradle|mvn|ruff|eslint|mypy|check|ci)([^a-z]|$)"; "i");
  [ $t[] | select(type == "object") ] as $rows
  | ($rows[($start + 1):]) as $turn
  | [ $turn[] | select(.type == "user")
      | ((.message.content // []) | if type == "array" then .[] else empty end)
      | select(.type == "tool_result")
      | {id: .tool_use_id, err: (.is_error == true)} ] as $results
  | [ $turn[] | select(.type == "assistant")
      | ((.message.content // []) | if type == "array" then .[] else empty end)
      | select(.type == "tool_use")
      | select(
          ((.name == "Bash" or .name == "BashOutput")
            and ((.input.command // "") | checkish))
          or ((.name != "Bash") and (.name | checkish))
        )
      | .id ] as $checks
  | [ $checks[] | select(. as $id | ($results | map(select(.id == $id and .err == false)) | length) > 0) ]
  | length' 2>/dev/null) || exit 0
case "$ran" in ''|*[!0-9]*) exit 0 ;; esac
[ "$ran" -gt 0 ] && exit 0

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
