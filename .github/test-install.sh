#!/usr/bin/env bash
# Tests install.sh and uninstall.sh against a scratch HOME. No model, no network.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
fail=0
ok()  { printf '  \033[32mok\033[0m    %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fail=1; }
H=$(mktemp -d); trap 'rm -rf "$H"' EXIT
export HABITS_INSTALL_HOME="$H"

printf '\n\033[1mFresh install\033[0m\n'
./install.sh >/dev/null 2>&1 && ok "runs on a machine with no ~/.claude" || bad "failed on a fresh HOME"
[ -f "$H/.claude/skills/habits/SKILL.md" ] && ok "skill installed" || bad "skill missing"
[ -f "$H/.claude/agents/habit-judge.md" ] && ok "judge installed" || bad "judge missing"
[ -f "$H/.claude/skills/habits/.habits-owned" ] && ok "ownership marker written" || bad "no ownership marker"
[ -e "$H/.claude/rules/habits.md" ] && bad "installed a habit, which it must never do" || ok "installed no habits"

printf '\n\033[1mReinstall, the upgrade path the README used to break on\033[0m\n'
./install.sh >/dev/null 2>&1 && ok "second run succeeds" || bad "second run failed"
[ -d "$H/.claude/skills/habits/habits" ] && bad "created a nested duplicate habits/habits/" || ok "no nested duplicate"
n=$(find "$H/.claude/skills" -name SKILL.md | wc -l | tr -d ' ')
[ "$n" = "1" ] && ok "exactly one SKILL.md" || { bad "expected 1 SKILL.md, found $n:"; find "$H/.claude/skills" -name SKILL.md | sed "s|$H|~|;s/^/        /"; }
leftovers=$(find "$H/.claude/skills" -maxdepth 1 \( -name '.habits-stage.*' -o -name '*.old.*' \) 2>/dev/null)
[ -z "$leftovers" ] && ok "no staging or backup directories left behind" || { bad "leftovers:"; printf '%s\n' "$leftovers" | sed "s|$H|~|;s/^/        /"; }

printf '\n\033[1mGate: staged but never enabled without --apply\033[0m\n'
./install.sh --with-gate >/dev/null 2>&1
[ -x "$H/.claude/hooks/completion-gate.sh" ] && ok "gate staged and executable" || bad "gate not staged"
[ -e "$H/.claude/settings.json" ] && bad "wrote settings.json without --apply" || ok "settings.json untouched without --apply"

printf '\n\033[1mGate: --apply appends and is idempotent\033[0m\n'
cat > "$H/.claude/settings.json" <<'JSON'
{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"/usr/bin/true"}]}],"PreToolUse":[]},"model":"opus"}
JSON
./install.sh --with-gate --apply --yes >/dev/null 2>&1
n=$(jq '[.hooks.Stop[]] | length' "$H/.claude/settings.json" 2>/dev/null)
[ "$n" = "2" ] && ok "appended, pre-existing Stop hook kept" || bad "expected 2 Stop hooks, got ${n:-none}"
jq -e '.model == "opus" and (.hooks | has("PreToolUse"))' "$H/.claude/settings.json" >/dev/null 2>&1 \
  && ok "left unrelated settings untouched" || bad "clobbered unrelated settings"
./install.sh --with-gate --apply --yes >/dev/null 2>&1
n=$(jq '[.hooks.Stop[]] | length' "$H/.claude/settings.json" 2>/dev/null)
[ "$n" = "2" ] && ok "second --apply is a no-op" || bad "duplicated the hook entry, got ${n:-none}"

printf '\n\033[1mGate: refuses invalid JSON\033[0m\n'
printf 'not json\n' > "$H/.claude/settings.json"
./install.sh --with-gate --apply --yes >/dev/null 2>&1 && bad "wrote over invalid JSON" || ok "refused invalid settings.json"
grep -q "not json" "$H/.claude/settings.json" && ok "left the broken file alone" || bad "modified the broken file"

printf '\n\033[1mUninstall keeps the user\x27s own habits\033[0m\n'
mkdir -p "$H/.claude/rules" "$H/.claude/habits"
echo "### SYS-01 mine" > "$H/.claude/rules/habits.md"
echo "a case" > "$H/.claude/habits/case.md"
./uninstall.sh >/dev/null 2>&1
[ -e "$H/.claude/skills/habits" ] && bad "skill not removed" || ok "skill removed"
[ -f "$H/.claude/rules/habits.md" ] && ok "kept the user's habits" || bad "deleted the user's habits"
[ -f "$H/.claude/habits/case.md" ] && ok "kept the user's cases" || bad "deleted the user's cases"

printf '\n'
[ "$fail" -eq 0 ] && { printf '\033[32mInstall tests passed.\033[0m\n'; exit 0; } || { printf '\033[31mInstall tests failed.\033[0m\n'; exit 1; }
