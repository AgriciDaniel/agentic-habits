#!/usr/bin/env bash
# Structural checks for the agentic-habits repository.
# Shell only, no dependencies beyond coreutils and jq. Run: bash .github/checks.sh
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0
pass() { printf '  \033[32mok\033[0m    %s\n' "$1"; }
bad()  { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fail=1; }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

SKILL="skills/habits/SKILL.md"
REFS="skills/habits/references"
STARTER="skills/habits/assets/starter"

head_ "House style"
# Build the characters at runtime so this file does not contain the thing it forbids.
EMDASH=$(printf '\u2014')
ENDASH=$(printf '\u2013')
hits=$(grep -rn --exclude-dir=.git --binary-files=without-match -e "$EMDASH" -e "$ENDASH" . || true)
if [ -n "$hits" ]; then
  bad "em dash or en dash found:"; printf '%s\n' "$hits" | head -5
else
  pass "no em dashes or en dashes"
fi

head_ "Skill contract"
[ -f "$SKILL" ] && pass "SKILL.md present" || bad "SKILL.md missing"
grep -q '^name: habits$' "$SKILL" && pass "frontmatter name is habits" || bad "frontmatter name wrong or missing"
grep -q '^description: ' "$SKILL" && pass "frontmatter description present" || bad "frontmatter description missing"
lines=$(wc -l < "$SKILL")
[ "$lines" -lt 500 ] && pass "SKILL.md is $lines lines, under the 500 ceiling" || bad "SKILL.md is $lines lines, over the 500 ceiling"
desc=$(grep '^description: ' "$SKILL" | cut -c14- | wc -c)
[ "$desc" -lt 1536 ] && pass "description is $desc chars, under the 1536 listing cap" || bad "description is $desc chars, over the cap"

head_ "Reference integrity"
for f in "$REFS"/*.md; do
  b=$(basename "$f")
  grep -q "references/$b" "$SKILL" && pass "$b is linked from SKILL.md" || bad "$b exists but SKILL.md never names it"
done
for b in $(grep -o 'references/[a-z-]*\.md' "$SKILL" | sort -u); do
  [ -f "skills/habits/$b" ] && pass "$b resolves" || bad "SKILL.md links $b, which does not exist"
done

head_ "Starter card parity"
extract() { grep -A2 '^### ' "$1" | grep -E '^(### |\*\*When\*\*|\*\*Do\*\*|\*\*Instead\*\*)' | sed 's/ *$//'; }
if diff <(extract "$REFS/starter-pack.md" | sort) \
        <(cat <(extract "$STARTER/system-habits.md") <(extract "$STARTER/project-habits.md") | sort) >/dev/null; then
  pass "every card matches between the rationale doc and the installable file"
else
  bad "starter-pack.md and assets/starter/ have drifted:"
  diff <(extract "$REFS/starter-pack.md" | sort) \
       <(cat <(extract "$STARTER/system-habits.md") <(extract "$STARTER/project-habits.md") | sort) | head -12
fi

head_ "Habit IDs"
dupes=$(grep -oh '^### \(SYS\|PRJ\)-[0-9]*' "$STARTER"/*.md | sort | uniq -d)
[ -z "$dupes" ] && pass "no duplicate IDs" || bad "duplicate IDs: $dupes"
dangling=0
for id in $(grep -rho '\(SYS\|PRJ\)-[0-9][0-9]' "$REFS" "$SKILL" | sort -u); do
  grep -q "^### $id " "$STARTER"/*.md || { bad "$id is cited but has no card"; dangling=1; }
done
[ "$dangling" -eq 0 ] && pass "every cited habit ID has a card"

head_ "Package manifests"
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  jq empty "$j" 2>/dev/null && pass "$j is valid JSON" || bad "$j is not valid JSON"
done
[ "$(jq -r .name .claude-plugin/plugin.json)" = "habits" ] && pass "plugin name is habits" || bad "plugin name is wrong"

head_ "Assets"
for a in assets/banner-light.svg assets/banner-dark.svg; do
  [ -f "$a" ] && grep -q "$a" README.md && pass "$a exists and is used in the README" || bad "$a missing or unreferenced"
done

printf '\n'
if [ "$fail" -eq 0 ]; then printf '\033[32mAll checks passed.\033[0m\n'; else printf '\033[31mChecks failed.\033[0m\n'; fi
exit "$fail"
