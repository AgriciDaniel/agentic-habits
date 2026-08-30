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

# The two loose files carry no marker, so compare them to what this repository
# ships and refuse to delete anything that differs. An earlier version removed
# them unconditionally, which would silently destroy a hand-written judge or
# gate at those paths.
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sha() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
        else shasum -a 256 "$1" | cut -d' ' -f1; fi; }
remove_if_ours() { # $1 = installed path, $2 = the shipped original
  [ -e "$1" ] || return 0
  [ -L "$1" ] && { printf '%s\n' "Left $1 alone: it is a symlink." >&2; return 0; }
  if [ -f "$2" ] && [ "$(sha "$1")" = "$(sha "$2")" ]; then rm -f "$1"
  else printf '%s\n' "Left $1 alone: it differs from the version this repository ships, so it is not ours to delete." >&2; fi
}
remove_if_ours "$CLAUDE_DIR/agents/habit-judge.md" "$SRC/agents/habit-judge.md"
remove_if_ours "$CLAUDE_DIR/hooks/completion-gate.sh" "$SRC/skills/habits/assets/gates/completion-gate.sh"
printf '%s\n' "Removed the skill, and any judge agent or gate script matching what this repository ships."

printf '%s\n' "
Left in place, deliberately:
  $CLAUDE_DIR/rules/habits.md and habits-*.md   your habits
  $CLAUDE_DIR/habits/                           your cases, archive and log
Those are yours, not the package's. Delete them yourself if you want them gone.

Not touched: settings.json. If you enabled the gate with --apply, undo it with
./install.sh --revert, which restores the backup it took. Otherwise remove the
entry from .hooks.Stop by hand. Say out loud that you removed it: a gate quietly removed
leaves a habit everyone still believes is enforced."
