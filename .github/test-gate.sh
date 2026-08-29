#!/usr/bin/env bash
# Tests for assets/gates/completion-gate.sh, written from the specification in
# references/gates.md rather than from the implementation. Several cases exist
# because an independent reviewer measured the shipped script failing them.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
GATE="skills/habits/assets/gates/completion-gate.sh"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
fail=0
ok()  { printf '  \033[32mok\033[0m    %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m  %s\n        expected exit %s, got %s\n' "$1" "$2" "$3"; fail=1; }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# $1 = comma-separated tool specs: "Name" or "Name:command" or either with a
# trailing ! meaning the result came back as an error (denied, non-zero, killed).
transcript() {
  local f="$TMP/t$RANDOM$RANDOM.jsonl" i=0
  printf '%s\n' '{"type":"user","isMeta":null,"message":{"role":"user","content":[{"type":"text","text":"an earlier prompt"}]}}' > "$f"
  printf '%s\n' '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","id":"old","input":{"command":"npm test"}}]}}' >> "$f"
  printf '%s\n' '{"type":"user","isMeta":null,"message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"old","is_error":false}]}}' >> "$f"
  printf '%s\n' '{"type":"user","isMeta":null,"message":{"role":"user","content":[{"type":"text","text":"the current prompt"}]}}' >> "$f"
  if [ -n "${1:-}" ]; then
    IFS=',' read -ra specs <<< "$1"
    for spec in "${specs[@]}"; do
      i=$((i+1)); local err=false
      case "$spec" in *!) err=true; spec="${spec%!}";; esac
      local name="${spec%%:*}" cmd=""
      case "$spec" in *:*) cmd="${spec#*:}";; esac
      printf '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"%s","id":"t%s","input":{"command":"%s"}}]}}\n' "$name" "$i" "$cmd" >> "$f"
      printf '{"type":"user","isMeta":null,"message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"t%s","is_error":%s}]}}\n' "$i" "$err" >> "$f"
    done
  fi
  echo "$f"
}
run() {
  jq -n --arg m "$1" --arg t "${2:-}" --argjson a "${3:-false}" \
    '{last_assistant_message:$m, transcript_path:$t, stop_hook_active:$a, hook_event_name:"Stop"}' \
  | bash "$GATE" >/dev/null 2>&1; echo $?
}
check() { local d="$1" w="$2" g="$3"; [ "$g" = "$w" ] && ok "$d" || bad "$d" "$w" "$g"; }

head_ "Blocks: an unhedged assertion that a check came back clean, with nothing run"
check "tests pass"                   2 "$(run 'All tests pass now.'                     "$(transcript 'Edit')")"
check "build is green"               2 "$(run 'The build is green.'                     "$(transcript 'Write')")"
check "lint clean and typecheck"     2 "$(run 'Lint is clean and typecheck passes.'     "$(transcript 'Edit,Read')")"
check "compiles without errors"      2 "$(run 'It compiles without errors.'             "$(transcript '')")"

head_ "Blocks: an attempt is not an observation"
check "the check was denied"         2 "$(run 'The bug is fixed. The test suite passes.' "$(transcript 'Bash:npm test!')")"
check "a command that is not a check" 2 "$(run 'All tests pass.'                        "$(transcript 'Bash:ls -la')")"
check "disclosure about a different check" 2 "$(run 'I have not run the formatter. Separately, all tests pass and the build is green.' "$(transcript 'Edit')")"

head_ "Allows: a real check actually ran"
check "npm test"                     0 "$(run 'All tests pass.'   "$(transcript 'Bash:npm test')")"
check "pytest"                       0 "$(run 'All tests pass.'   "$(transcript 'Bash:pytest -q')")"
check "cargo build"                  0 "$(run 'The build is green.' "$(transcript 'Bash:cargo build --release')")"
check "denied, then a real run"      0 "$(run 'All tests pass.'   "$(transcript 'Bash:npm test!,Bash:npm test')")"

head_ "Allows: honest disclosure, in the phrasings people actually use"
check "unable to run"                0 "$(run 'I was unable to run the test suite, so I cannot say whether the tests pass.' "$(transcript 'Edit')")"
check "could not verify"             0 "$(run 'I could not verify that the tests pass because Bash is unavailable.'         "$(transcript 'Edit')")"
check "no way to run"                0 "$(run 'The tests pass in principle, but I have no way to run them here.'            "$(transcript 'Edit')")"
check "not yet run, by inspection"   0 "$(run 'Not yet run: the lint is clean by inspection only.'                          "$(transcript 'Edit')")"
check "never ran it"                 0 "$(run 'Caveat: I never ran it. The type check passes on my reading of the file.'    "$(transcript 'Edit')")"
check "this is unverified"           0 "$(run 'I have not run the tests, so this is unverified.'                            "$(transcript 'Edit')")"

head_ "Allows: it is not a claim"
check "an instruction to the user"   0 "$(run 'Run npm test to confirm the tests pass.'                    "$(transcript 'Edit')")"
check "a question"                   0 "$(run 'Please check whether the build succeeds on your machine.'   "$(transcript 'Edit')")"
check "reported speech"              0 "$(run 'The user asked whether the tests pass.'                     "$(transcript 'Edit')")"
check "a hedged future"              0 "$(run 'The bug is fixed, so the test suite should pass once you run it.' "$(transcript 'Edit')")"
check "no claim at all"              0 "$(run 'I renamed the helper and left the caller alone.'            "$(transcript 'Edit')")"
check "a person passing on a change" 0 "$(run 'The reviewer passed on the change and asked for docs.'      "$(transcript 'Edit')")"

head_ "Allows: fail open, always"
check "recursion guard active"       0 "$(run 'All tests pass.' "$(transcript 'Edit')" true)"
check "missing transcript"           0 "$(run 'All tests pass.' "/nonexistent/path.jsonl")"
check "empty message"                0 "$(run ''                "$(transcript 'Edit')")"
check "unparseable transcript"       0 "$(printf 'not json\n' > "$TMP/bad.jsonl"; run 'All tests pass.' "$TMP/bad.jsonl")"

printf '\n'
[ "$fail" -eq 0 ] && { printf '\033[32mGate tests passed.\033[0m\n'; exit 0; } || { printf '\033[31mGate tests failed.\033[0m\n'; exit 1; }
