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

# 3. Is there an unhedged first-hand assertion that a check came back clean?
#
#    High precision by construction. An explicit list of claim shapes, then a
#    set of disqualifiers, evaluated per clause rather than per sentence so a
#    claim joined to a plan ("all tests pass and I will commit") is still seen.
#
#    The bar is deliberately high. A gate that fires wrongly gets deleted, and a
#    deleted gate protects nothing. Missing a claim costs one unverified
#    sentence, which the judge still catches.

# What a claim actually looks like. Tight, anchored, no sliding window.
claim='\b(all |the )?(unit |integration |e2e )?tests?( suite)? (now )?(pass|passes|passed)\b'
claim="$claim"'|\btest suite (now )?(passes|passed)\b'
claim="$claim"'|\ball (tests|checks|specs) (pass|passed|are green)\b'
claim="$claim"'|\b(the |our )?(build|suite|pipeline) (is|was) (now )?green\b'
claim="$claim"'|\b(the |our )?build (succeeds|succeeded|passes|passed|is clean)\b'
claim="$claim"'|\b(lint|linter|type ?check|typecheck|compilation) (is|was) (now )?clean\b'
claim="$claim"'|\b(lint|linter|type ?check|typecheck) (passes|passed)\b'
claim="$claim"'|\bit compiles\b|\bcompiles (cleanly|without errors?)\b|\beverything compiles\b'
claim="$claim"'|\b(zero|no) (test )?failures\b|\bno errors?\b'

# Any one of these and the clause is not a first-hand present claim.
# Order matters only for readability; any match disqualifies.
# An honest statement that the check was not run. Recognised by negation near
# running or verifying, rather than by a phrase list, because a phrase list
# blocked five of six natural phrasings in an earlier version.
disclose='\b(ha(ve|s)( not|n.t)|did( not|n.t)|do( not|n.t)|can( ?not|.t)|could( not|n.t)|unable|never|without|no way|not yet)\b[^.!?]{0,40}\b(run|ran|execut|verif|check|test)|\b(unverified|untested|by inspection|on my reading|in principle|from reading alone)\b'

negation='\b(not|never|fail|fails|failed|failing|broken|red|cannot|unable|without running)\b|n.t\b'
attribution='\b(said|says|claim|claims|claimed|asked|asks|according to|per the|assuming)\b'
instruction='\b(run|runs|check|checks|verify|confirm|please|ensure|make sure|you|your|let me|only when|unless|before you|after you|if you|once you|to confirm|to verify|merge)\b'
modal='\b(will|would|should|shall|may|might|could|going to|expect|expects|assume|likely|probably|presumably|in principle|by inspection|on my reading|appears|seems|looks like)\b'

# Attribution and prior-turn evidence modify the whole sentence, so they are
# tested before the sentence is split. Negation, instruction and modal bind
# tightly, so they are tested per clause: "all tests pass and I will commit"
# must still be seen as a claim.
prior='\b(as shown|as established|earlier|previous turn|previously|already ran|ran .* (earlier|before)|from the .* run|per the .* run)\b'

found=""
while IFS= read -r sentence; do
  [ -n "$sentence" ] || continue
  case "$sentence" in *\?*) continue ;; esac
  grep -Eiq "$disclose"    <<<"$sentence" && continue
  grep -Eiq "$attribution" <<<"$sentence" && continue
  grep -Eiq "$prior"       <<<"$sentence" && continue
  while IFS= read -r clause; do
    [ -n "$clause" ] || continue
    grep -Eiq "$negation"    <<<"$clause" && continue
    grep -Eiq "$instruction" <<<"$clause" && continue
    grep -Eiq "$modal"       <<<"$clause" && continue
    if grep -Eiq "$claim" <<<"$clause"; then found="$clause"; break; fi
  done <<< "$(printf '%s' "$sentence" | awk '{gsub(/,| and | but | so | because | while | although | however /,"&\n"); print}')"
  [ -n "$found" ] && break
done <<< "$(printf '%s' "$msg" | tr '\n' ' ' | awk '{gsub(/[.!?;:]/,"&\n"); print}')"

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
