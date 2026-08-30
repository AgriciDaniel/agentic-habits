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
# A blockquote line is exempt. Without this the house rule and the
# verbatim-quotation rule are in conflict, and a mutation test showed the repo
# resolving it silently in favour of the house rule, inside quotation marks, in
# the two files whose job is to separate what is quoted from what is asserted.
# If a quotation needs an em dash, it must be a blockquote so the exemption is
# visible on the page rather than implicit.
hits=$(grep -rn --exclude-dir=.git --binary-files=without-match -e "$EMDASH" -e "$ENDASH" . \
       | grep -v ':[0-9]*:[[:space:]]*>' || true)
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
if ls skills/habits/assets/gates/*.sh >/dev/null 2>&1; then
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

head_ "Counts, because prose drifts from the package"
shipped=$(grep -hc '^### \(SYS\|PRJ\)-' "$STARTER"/*.md | paste -sd+ | bc)
doc=$(grep -c '^### \(SYS\|PRJ\)-' "$REFS/starter-pack.md")
[ "$shipped" = "$doc" ] && pass "$shipped cards ship and $doc are documented" || bad "$shipped cards ship but starter-pack.md documents $doc"
# CHANGELOG records history and must keep its old numbers; this script holds the patterns.
stale=$(grep -rln "nineteen habits\|19 starter habits\|19 habits with\|all nineteen" \
        --exclude-dir=.git --exclude=CHANGELOG.md --exclude=checks.sh \
        --exclude=test-checks.sh . || true)
[ -z "$stale" ] && pass "no stale habit count in prose" || { bad "files still claiming the old count:"; printf '%s\n' "$stale" | sed 's/^/        /'; }
# Per file, not a disjunction. The previous version grepped three files with
# grep -q and passed if ANY one carried the right number, so it reported ok on a
# repository where gates.md said 27 and the suite had 46. A check that cannot
# fail on the defect it was written for is not a check.
gt=$(grep -c 'check "' .github/test-gate.sh)
it=$(grep -c 'ok "\|bad "' .github/test-install.sh)
gl=$(wc -l < skills/habits/assets/gates/completion-gate.sh | tr -d ' ')
badnum=0
while IFS= read -r f; do
  case "$f" in ./CHANGELOG.md|./.github/checks.sh|./.github/test-checks.sh) continue ;; esac
  # any "<n> tests" or "<n> cases" that names a gate-test count other than the live one
  while IFS= read -r n; do
    [ -z "$n" ] && continue
    [ "$n" = "$gt" ] && continue
    # No skip list. An earlier version skipped the live count itself, which
    # suppressed the exact defect this check exists for the moment it changed.
    # A mutation test proved it: 46 -> 47 with two stale documents reported ok.
    bad "$f claims $n gate tests; the suite has $gt"; badnum=1
  done < <(grep -oE '\b[0-9]+ (gate )?tests\b' "$f" 2>/dev/null | grep -oE '^[0-9]+')
done < <(find . -name '*.md' -not -path './.git/*' | sort)
[ "$badnum" -eq 0 ] && pass "no file states a stale gate-test count (live: $gt)"
badinst=0
while IFS= read -r f; do
  case "$f" in ./CHANGELOG.md|./.github/checks.sh|./.github/test-checks.sh) continue ;; esac
  while IFS= read -r n; do
    [ -z "$n" ] && continue; [ "$n" = "$it" ] && continue
    bad "$f claims $n installer tests; the suite has $it"; badinst=1
  done < <(grep -oE '\b[0-9]+ (installer|install) (tests|assertions)\b' "$f" 2>/dev/null | grep -oE '^[0-9]+')
done < <(find . -name '*.md' -not -path './.git/*' | sort)
[ "$badinst" -eq 0 ] && pass "no file states a stale installer-test count (live: $it)"

if grep -q "It is $gl lines" SECURITY.md; then pass "SECURITY.md states the real gate line count ($gl)"
else bad "SECURITY.md's stated gate line count does not match wc -l ($gl)"; fi

grep -q "Not established" assets/PROVENANCE.md \
  && bad "assets/PROVENANCE.md still has an unresolved provenance row" \
  || pass "every asset has an established provenance"

vocab=$(grep -c '^| `evidence-based` \|^| `institutional` \|^| `practitioner` \|^| `contested` \|^| `folklore` ' "$REFS/habit-card.md")
[ "$vocab" -ge 5 ] && pass "the evidence vocabulary table is present" || bad "the evidence vocabulary table is missing or incomplete"
grep -q '`sourced` means official documentation\|`reasoned` means it is an argument' "$REFS/habit-card.md" \
  && bad "habit-card.md carries a second, retired evidence vocabulary" \
  || pass "exactly one evidence vocabulary is defined"
ungraded=$(for f in "$STARTER"/*.md; do grep -o 'evidence=[a-z-]*' "$f"; done | sort -u \
  | grep -vE 'evidence=(evidence-based|institutional|practitioner|contested|folklore)$' || true)
[ -z "$ungraded" ] && pass "every shipped evidence grade is in the vocabulary" \
  || { bad "grades outside the vocabulary:"; printf '%s\n' "$ungraded" | sed 's/^/        /'; }

head_ "Grader integrity"
# Every shipped check= must appear verbatim as the Check: line in starter-pack.md.
drift=0
while IFS=$'\t' read -r id chk; do
  [ -n "$id" ] || continue
  doc_chk=$(awk -v id="$id" '
    $0 ~ "^### " id " " {f=1} f && /^Check: /{sub(/^Check: /,""); print; exit}' "$REFS/starter-pack.md")
  if [ "$doc_chk" != "$chk" ]; then bad "check drift for $id"; drift=1; fi
done < <(grep -ho 'id=[A-Z]*-[0-9]* .*check="[^"]*"' "$STARTER"/*.md \
         | sed 's/id=\([A-Z]*-[0-9]*\).*check="\([^"]*\)".*/\1\t\2/')
[ "$drift" -eq 0 ] && pass "every shipped check matches its documented Check line"
grep -q 'lapses=0' "$STARTER"/*.md && bad "a shipped card carries a fabricated lapses=0" || pass "no fabricated lapse counts on shipped cards"
missing=$(for f in "$STARTER"/*.md; do grep -o 'id=[A-Z]*-[0-9]*[^>]*' "$f" | grep -v 'evidence=' | sed 's/ .*//'; done)
[ -z "$missing" ] && pass "every shipped card carries an evidence grade" || { bad "cards with no evidence grade:"; printf '%s\n' "$missing" | sed 's/^/        /'; }

head_ "Manifests carry what a marketplace needs"
jq -e '.description and (.description | length > 20)' .claude-plugin/marketplace.json >/dev/null 2>&1 \
  && pass "marketplace has a description (its absence fails plugin validate --strict)" \
  || bad "marketplace.json has no description, so --strict fails"
mv=$(jq -r '.plugins[0].version' .claude-plugin/marketplace.json); pv=$(jq -r '.version' .claude-plugin/plugin.json)
[ "$mv" = "$pv" ] && pass "marketplace entry version matches plugin.json ($pv)" || bad "version mismatch: marketplace $mv, plugin $pv"

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
