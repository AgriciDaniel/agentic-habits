#!/usr/bin/env bash
# Measures three claims in verification.md:
#   1. a .claude/rules/ habit file loads into a fresh session and changes behavior
#   2. the <!-- habit: --> bookkeeping comment is stripped before the agent sees it
#      (with a control: the same marker in plain text must be visible)
#   3. a path-scoped rule is absent until a matching file is read, and present after
set -uo pipefail
command -v claude >/dev/null || { echo "claude CLI not found"; exit 1; }
MODEL="${MODEL:-haiku}"
D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
mkdir -p "$D/.claude/rules" "$D/src"
echo 'export const x = 1' > "$D/src/a.ts"
say() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ask() { (cd "$D" && timeout 180 claude -p "$1" --model "$MODEL" ${2:+--allowedTools "$2"} 2>/dev/null </dev/null); }

say "1. does a project rules file load and change behavior?"
cat > "$D/.claude/rules/habits.md" <<'R'
# Habits
### SYS-99 · Canary
**When** the user says the word canary.
**Do** Reply with the exact token RULES-LOADED-OK and nothing else.
<!-- habit: id=SYS-99 marker=COMMENT-VISIBLE-ZQ7 status=active -->
R
out=$(ask "canary")
case "$out" in *RULES-LOADED-OK*) echo "  PASS  the habit fired: $out" ;;
                *) echo "  FAIL  expected RULES-LOADED-OK, got: $out" ;; esac

say "2. is the metadata comment stripped? (control follows)"
out=$(ask "Do not use any tools. Reply MARKER-SEEN or MARKER-ABSENT: does the string COMMENT-VISIBLE-ZQ7 appear anywhere in your loaded instructions?")
case "$out" in *MARKER-ABSENT*) echo "  PASS  comment not in context: $out" ;;
                *) echo "  FAIL  expected MARKER-ABSENT, got: $out" ;; esac
sed -i 's|<!-- habit: id=SYS-99 marker=COMMENT-VISIBLE-ZQ7 status=active -->|marker=COMMENT-VISIBLE-ZQ7 status=active|' "$D/.claude/rules/habits.md"
out=$(ask "Do not use any tools. Reply MARKER-SEEN or MARKER-ABSENT: does the string COMMENT-VISIBLE-ZQ7 appear anywhere in your loaded instructions?")
case "$out" in *MARKER-SEEN*) echo "  PASS  control: the probe does detect a visible marker: $out" ;;
                *) echo "  FAIL  control failed, so test 2 proves nothing: $out" ;; esac

say "3. is a path-scoped rule absent until a matching file is read?"
cat > "$D/.claude/rules/habits.md" <<'R'
---
paths:
  - "src/**/*.ts"
---
# Habits
### PTH-99 · Canary
**When** the user says the word canary.
**Do** Reply with the exact token PATH-RULE-LOADED and nothing else.
R
out=$(ask "canary. Answer in one short line.")
case "$out" in *PATH-RULE-LOADED*) echo "  FAIL  fired without reading a matching file: $out" ;;
                *) echo "  PASS  absent before any matching file was read" ;; esac
out=$(ask "Read the file src/a.ts. Then respond to this word: canary" "Read")
case "$out" in *PATH-RULE-LOADED*) echo "  PASS  present after reading a matching file" ;;
                *) echo "  FAIL  expected PATH-RULE-LOADED, got: $out" ;; esac
