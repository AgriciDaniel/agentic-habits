#!/usr/bin/env bash
# Install agentic-habits. Machinery only: this never installs a habit.
# Habits are chosen and written by /habits setup, after showing you the file.
#
#   ./install.sh                 skill + judge agent
#   ./install.sh --with-gate     also stage the Stop gate and print how to enable it
#   ./install.sh --with-gate --apply   also write the hook into settings.json
#   ./install.sh --revert        undo the last settings.json change this made
#   ./install.sh --help
#
# Two flags relax a guard, so they are documented rather than hidden:
#   --force   replace an install this script does not own. It refuses otherwise.
#   --yes     permit an unattended settings.json write, which is refused without
#             a terminal. Ignored against a real home in CI.
#
# HABITS_INSTALL_HOME overrides the install root, for testing.
set -uo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HABITS_INSTALL_HOME:-$HOME}"
CLAUDE_DIR="$HOME_DIR/.claude"
MARKER="agentic-habits-owned:v1"
with_gate=0; apply=0; revert=0; force=0; assume_yes=0

die()  { printf '%s\n' "$*" >&2; exit 1; }
note() { printf '%s\n' "$*"; }
sha()  { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
         else shasum -a 256 "$1" | cut -d' ' -f1; fi; }

while [ $# -gt 0 ]; do
  case "$1" in
    --with-gate) with_gate=1 ;;
    --apply)     apply=1 ;;
    --revert)    revert=1 ;;
    --force)     force=1 ;;
    --yes)       assume_yes=1 ;;
    --help|-h)   sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)           printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

[ "$(id -u)" = "0" ] && [ -z "${HABITS_INSTALL_HOME:-}" ] && die "Refusing to install as root."

settings="$CLAUDE_DIR/settings.json"
gate_dest="$CLAUDE_DIR/hooks/completion-gate.sh"

# ---------------------------------------------------------------- revert
if [ "$revert" = 1 ]; then
  last=$(ls -1t "$CLAUDE_DIR/backups"/habits-settings-*.json 2>/dev/null | head -1) \
    || die "No backup found."
  [ -n "$last" ] || die "No backup found in $CLAUDE_DIR/backups."
  meta="${last%.json}.meta"
  if [ -f "$meta" ] && [ -f "$settings" ]; then
    want=$(cat "$meta"); have=$(sha "$settings")
    [ "$want" = "$have" ] || die "settings.json changed after installation. Refusing to revert. Backup kept at: $last"
  fi
  cp "$last" "$settings" || die "Could not restore."
  note "Restored $settings from $last"
  exit 0
fi

# ---------------------------------------------------------------- install
install_dir() { # $1 = source dir, $2 = destination dir
  local src="$1" dest="$2" stage
  [ -L "$dest" ] && die "$dest is a symlink. Refusing to replace it."
  if [ -e "$dest" ]; then
    if [ ! -f "$dest/.habits-owned" ] || ! grep -q "$MARKER" "$dest/.habits-owned" 2>/dev/null; then
      [ "$force" = 1 ] || die "$dest exists and was not installed by this script. Move it, or re-run with --force."
    fi
  fi
  stage="$(dirname "$dest")/.habits-stage.$$"
  rm -rf "$stage"; mkdir -p "$stage" && chmod 700 "$stage" || die "Could not stage."
  # tar rather than cp: `cp -R src/. dest/` is not portable between GNU and BSD,
  # and on macOS it left a second copy of the tree behind on reinstall.
  ( cd "$src" && tar cf - . ) | ( cd "$stage" && tar xf - ) \
    || { rm -rf "$stage"; die "Copy failed."; }
  printf '%s\n' "$MARKER" > "$stage/.habits-owned"
  if [ -e "$dest" ]; then mv "$dest" "$dest.old.$$" || { rm -rf "$stage"; die "Could not move existing install aside."; }; fi
  if mv "$stage" "$dest"; then rm -rf "$dest.old.$$" "$stage"
  else rm -rf "$stage"; [ -e "$dest.old.$$" ] && mv "$dest.old.$$" "$dest"; die "Install failed, previous state restored."; fi
}

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" || die "Could not create $CLAUDE_DIR."
install_dir "$SRC/skills/habits" "$CLAUDE_DIR/skills/habits"
cp "$SRC/agents/habit-judge.md" "$CLAUDE_DIR/agents/habit-judge.md" || die "Could not install the judge agent."

note "Installed:"
note "  $CLAUDE_DIR/skills/habits      the skill, invoked as /habits"
note "  $CLAUDE_DIR/agents/habit-judge.md   the read-only judge, used by /habits judge"
note ""
note "No habits were installed. Run /habits setup: it reads your existing CLAUDE.md"
note "files first and shows you the exact file before writing anything."

# ---------------------------------------------------------------- gate
[ "$with_gate" = 1 ] || exit 0

command -v jq >/dev/null 2>&1 || die "
The gate needs jq and jq was not found. Without it the gate exits 0 on every
turn: it would look installed and never block anything. Install jq first."

mkdir -p "$CLAUDE_DIR/hooks"
cp "$SRC/skills/habits/assets/gates/completion-gate.sh" "$gate_dest" || die "Could not stage the gate."
chmod +x "$gate_dest"

note ""
note "The gate script is staged at:"
note "  $gate_dest"
note ""
note "It is NOT active. Add this to $settings, or re-run with --apply:"
note ""
cat <<JSON
{
  "hooks": {
    "Stop": [
      { "hooks": [ { "type": "command",
                     "command": "$gate_dest",
                     "timeout": 10 } ] }
    ]
  }
}
JSON
note ""
note "The nested \"hooks\" array is not optional. The flat form is valid JSON,"
note "loads without complaint, and never fires."
note ""
note "What it does: blocks a turn that asserts a test, build, lint or type check"
note "came back clean when no successful check ran in that turn. It fails open on"
note "every uncertainty, so it misses claims. It counts a shell command whose text"
note "looks like a check, so a command that merely looks like one would count. It"
note "blocks once per turn and never twice, so a repeated claim clears."

[ "$apply" = 1 ] || exit 0
if [ "$assume_yes" != 1 ] && [ ! -t 0 ]; then
  die "--apply without a terminal needs --yes. Refusing."
fi
# Refuse an unattended settings write against a real home. A caller that has
# redirected the install root with HABITS_INSTALL_HOME is sandboxed by
# definition, which is how the installer's own tests exercise this path.
if [ -n "${CI:-}" ] && [ -z "${HABITS_INSTALL_HOME:-}" ]; then
  die "--apply refuses to write to a real settings.json in CI."
fi

if [ -f "$settings" ]; then
  jq empty "$settings" 2>/dev/null || die "$settings is not valid JSON. Refusing to touch it. Fix the file first."
else
  printf '{}\n' > "$settings"
fi

existing=$(jq -r --arg c "$gate_dest" '
  [ (.hooks.Stop // [])[] | (.hooks // [])[] | .command // empty ]
  | map(split(" ")[0]) | index($c) // -1' "$settings")
if [ "$existing" != "-1" ] && [ -n "$existing" ]; then
  note ""; note "Already installed in $settings. Nothing changed."; exit 0
fi

mkdir -p "$CLAUDE_DIR/backups"
backup="$CLAUDE_DIR/backups/habits-settings-$(date +%Y%m%d-%H%M%S).json"
cp "$settings" "$backup" || die "Could not back up settings."

tmp="$settings.habits.$$"
jq --arg c "$gate_dest" '
  .hooks //= {} | .hooks.Stop //= []
  | .hooks.Stop += [ { "hooks": [ { "type":"command", "command":$c, "timeout":10 } ] } ]
' "$settings" > "$tmp" || { rm -f "$tmp"; die "Edit failed. $settings untouched. Backup: $backup"; }
jq empty "$tmp" 2>/dev/null || { rm -f "$tmp"; die "Result did not parse. $settings untouched."; }
mv "$tmp" "$settings"
sha "$settings" > "${backup%.json}.meta"

kept=$(jq '[ (.hooks.Stop // [])[] ] | length - 1' "$settings")
others=$(jq -r '[ (.hooks // {}) | keys[] | select(. != "Stop") ] | join(", ")' "$settings")
note ""
note "Wrote the Stop hook into $settings (appended, $kept existing Stop hook(s) kept)."
note "Left untouched: ${others:-no other hook events}, permissions, model, and every other setting."
note "Backup: $backup"
note "Undo with: ./install.sh --revert"
