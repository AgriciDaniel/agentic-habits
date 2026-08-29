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
[ -f assets/cover.png ] && grep -q "assets/cover.png" README.md && pass "cover image exists and is the README hero" || bad "assets/cover.png missing or unreferenced"
[ -f assets/social-preview.png ] && pass "social preview image present" || bad "assets/social-preview.png missing"

head_ "Prose and package agree"
# These exist because three documents once described a package that no longer
# existed, and structural checks could not see it. Each is a claim the prose
# makes about the repository, checked against the repository.
if grep -rq "\.sh$" /dev/null 2>&1 || ls skills/habits/assets/gates/*.sh >/dev/null 2>&1; then
  grep -qi "nothing here executes" SECURITY.md \
    && bad "SECURITY.md says nothing executes, but skills/ ships a shell script" \
    || pass "SECURITY.md does not claim the package is inert"
  grep -q "No scripts in the skill" CONTRIBUTING.md \
    && bad "CONTRIBUTING.md forbids scripts in skills/, which is where the gate lives" \
    || pass "CONTRIBUTING.md's script rule matches what ships"
  grep -q "dependencies-none\|markdown-only" README.md \
    && bad "README badges claim no dependencies or markdown only, but the gate needs jq" \
    || pass "README badges match what ships"
fi
# Every verb the skill offers should be discoverable from the README.
missing=""
for v in $(grep -o '^| `/habits [a-z]*' skills/habits/SKILL.md | awk '{print $3}' | tr -d '`' | sort -u); do
  [ -z "$v" ] && continue
  grep -q "/habits $v" README.md || missing="$missing $v"
done
[ -z "$missing" ] && pass "every /habits verb appears in the README" || bad "verbs missing from README:$missing"

head_ "Gate"
GATE="skills/habits/assets/gates/completion-gate.sh"
[ -x "$GATE" ] && pass "completion-gate.sh is present and executable" || bad "completion-gate.sh missing or not executable"
bash -n "$GATE" 2>/dev/null && pass "completion-gate.sh parses" || bad "completion-gate.sh has a syntax error"
grep -q "stop_hook_active" "$GATE" && pass "gate has a recursion guard" || bad "gate is missing its recursion guard"
grep -q "exit 2" "$GATE" && pass "gate can actually block (exit 2)" || bad "gate never exits 2, so it can never block"
[ -f agents/habit-judge.md ] && grep -q "^tools: Read, Grep, Glob$" agents/habit-judge.md && pass "habit-judge is read-only" || bad "habit-judge missing or not read-only"

printf '\n'
if [ "$fail" -eq 0 ]; then printf '\033[32mAll checks passed.\033[0m\n'; else printf '\033[31mChecks failed.\033[0m\n'; fi
exit "$fail"
