#!/usr/bin/env bash
# Remove agentic-habits machinery. Never removes your habits or your cases.
set -uo pipefail
HOME_DIR="${HABITS_INSTALL_HOME:-$HOME}"
CLAUDE_DIR="$HOME_DIR/.claude"
MARKER="agentic-habits-owned:v1"
die() { printf '%s\n' "$*" >&2; exit 1; }

skill="$CLAUDE_DIR/skills/habits"
if [ -e "$skill" ]; then
  [ -L "$skill" ] && die "$skill is a symlink. Refusing."
  grep -q "$MARKER" "$skill/.habits-owned" 2>/dev/null \
    || die "$skill was not installed by this script. Refusing to remove it."
fi

rm -rf "$skill"
rm -f "$CLAUDE_DIR/agents/habit-judge.md" "$CLAUDE_DIR/hooks/completion-gate.sh"
printf '%s\n' "Removed the skill, the judge agent, and the gate script."

printf '%s\n' "
Left in place, deliberately:
  $CLAUDE_DIR/rules/habits.md and habits-*.md   your habits
  $CLAUDE_DIR/habits/                           your cases, archive and log
Those are yours, not the package's. Delete them yourself if you want them gone.

Not touched: settings.json. If you enabled the gate, remove its entry from
.hooks.Stop by hand. Say out loud that you removed it: a gate quietly removed
leaves a habit everyone still believes is enforced."
