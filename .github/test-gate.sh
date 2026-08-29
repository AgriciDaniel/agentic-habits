#!/usr/bin/env bash
# Unit tests for assets/gates/completion-gate.sh. No model, no network.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
GATE="skills/habits/assets/gates/completion-gate.sh"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
fail=0
ok()  { printf '  \033[32mok\033[0m    %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m  %s (expected exit %s, got %s)\n' "$1" "$2" "$3"; fail=1; }

# Build a transcript. $1 = comma-separated tool specs, each "Name" or "Name!" 
# where the trailing ! marks a call whose result came back as an error (denied).
transcript() {
  local f="$TMP/t$RANDOM$RANDOM.jsonl" i=0
  printf '%s\n' '{"type":"user","isMeta":null,"message":{"role":"user","content":[{"type":"text","text":"earlier prompt"}]}}' > "$f"
  printf '%s\n' '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","id":"old1"}]}}' >> "$f"
  printf '%s\n' '{"type":"user","isMeta":null,"message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"old1","is_error":false}]}}' >> "$f"
  printf '%s\n' '{"type":"user","isMeta":null,"message":{"role":"user","content":[{"type":"text","text":"the current prompt"}]}}' >> "$f"
  if [ -n "${1:-}" ]; then
    IFS=',' read -ra tools <<< "$1"
    for spec in "${tools[@]}"; do
      i=$((i+1)); local name="${spec%!}" err=false
      [ "$spec" != "$name" ] && err=true
      printf '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"%s","id":"t%s"}]}}\n' "$name" "$i" >> "$f"
      printf '{"type":"user","isMeta":null,"message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"t%s","is_error":%s}]}}\n' "$i" "$err" >> "$f"
    done
  fi
  echo "$f"
}
run() { # $1 message, $2 transcript path, $3 stop_hook_active
  jq -n --arg m "$1" --arg t "${2:-}" --argjson a "${3:-false}" \
    '{last_assistant_message:$m, transcript_path:$t, stop_hook_active:$a, hook_event_name:"Stop"}' \
  | bash "$GATE" >/dev/null 2>&1; echo $?
}
check() { local desc="$1" want="$2" got="$3"; [ "$got" = "$want" ] && ok "$desc" || bad "$desc" "$want" "$got"; }

printf '\n\033[1mBlocks (the point of the gate)\033[0m\n'
check "claims tests pass, ran nothing"        2 "$(run 'All tests pass now.'            "$(transcript "Edit")")"
check "claims the build is green, ran nothing" 2 "$(run 'The build is green.'            "$(transcript "Write")")"
check "claims lint is clean, ran nothing"      2 "$(run 'Lint is clean and typecheck passes.' "$(transcript "Edit,Read")")"
check "claims it compiles, ran nothing"        2 "$(run 'It compiles without errors.'    "$(transcript "")")"

printf '\n\033[1mAllows (false positives are the expensive failure)\033[0m\n'
check "claim backed by a real Bash run"        0 "$(run 'All tests pass.'                "$(transcript "Edit,Bash")")"
check "claim after a DENIED Bash call"         2 "$(run 'The bug is fixed, so the test suite should pass.' "$(transcript "Edit,Bash!")")"
check "claim after a denied then real run"     0 "$(run 'All tests pass.'                "$(transcript "Bash!,Bash")")"
check "no success claim at all"                0 "$(run 'I renamed the helper and left the caller alone.' "$(transcript "Edit")")"
check "honest disclosure, not run"             0 "$(run 'I have not run the tests, so this is unverified.' "$(transcript "Edit")")"
check "honest disclosure, could not run"       0 "$(run 'The suite passes locally but I could not run it here.' "$(transcript "Edit")")"
check "recursion guard"                        2 "$(run 'All tests pass.'                "$(transcript "Edit")" false)"
check "recursion guard active"                 0 "$(run 'All tests pass.'                "$(transcript "Edit")" true)"
check "missing transcript fails open"          0 "$(run 'All tests pass.'                "/nonexistent/path.jsonl")"
check "empty message fails open"               0 "$(run ''                               "$(transcript "Edit")")"
check "unparseable transcript fails open"      0 "$(printf 'not json\n' > "$TMP/bad.jsonl"; run 'All tests pass.' "$TMP/bad.jsonl")"
check "prose about a person passing"           0 "$(run 'The reviewer passed on the change and asked for docs.' "$(transcript "Edit")")"

printf '\n'
[ "$fail" -eq 0 ] && { printf '\033[32mGate tests passed.\033[0m\n'; exit 0; } || { printf '\033[31mGate tests failed.\033[0m\n'; exit 1; }
