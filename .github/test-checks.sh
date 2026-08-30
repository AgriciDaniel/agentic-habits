#!/usr/bin/env bash
# Negative tests for .github/checks.sh.
#
# checks.sh had a bug for two releases: its gate-test-count assertion grepped
# three files with grep -q, which passes if ANY one carries the right number, so
# it reported ok on a repository where gates.md said 27 and the suite had 46. It
# had only ever been observed passing.
#
# So: reintroduce each defect into a copy of the repository, one at a time, and
# require checks.sh to FAIL. Same rule this package applies to a judge and a
# gate, applied to the checks themselves.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
SRC="$PWD"
fail=0
ok()  { printf '  \033[32mok\033[0m    catches: %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m  MISSES:  %s\n' "$1"; fail=1; }

probe() { # $1 = description, $2 = mutation command run inside the copy
  local desc="$1" mutate="$2" d
  d=$(mktemp -d)
  ( cd "$SRC" && git ls-files -z | tar -cf - --null -T - ) | ( cd "$d" && tar -xf - )
  ( cd "$d" && eval "$mutate" ) >/dev/null 2>&1
  if ( cd "$d" && bash .github/checks.sh ) >/dev/null 2>&1; then bad "$desc"; else ok "$desc"; fi
  rm -rf "$d"
}

printf '\n\033[1mEach defect below must make checks.sh exit non-zero\033[0m\n'

# Derive the live count rather than hardcoding it: a hardcoded mutation string
# silently stops matching when the count changes, and the probe then passes for
# the wrong reason. That happened once already.
GT=$(grep -c 'check "' .github/test-gate.sh)
probe "a stale gate-test count in one file" \
  "sed -i.bak 's/with $GT tests and a recorded live/with 27 tests and a recorded live/' skills/habits/references/gates.md"
probe "a mutation that no longer matches (the probe must not pass vacuously)" \
  "sed -i.bak 's/with $GT tests and a recorded live/with 27 tests and a recorded live/' skills/habits/references/gates.md; grep -q 'with 27 tests' skills/habits/references/gates.md || echo MUTATION_DID_NOT_APPLY >&2"
probe "a wrong gate line count in SECURITY.md" \
  "sed -i.bak 's/It is 150 lines/It is 119 lines/' SECURITY.md"
probe "an unresolved provenance row" \
  "sed -i.bak '0,/| Maintainer asserts/s//| **Not established** |/' assets/PROVENANCE.md"
probe "a second, retired evidence vocabulary" \
  "printf '\n\`sourced\` means official documentation backs it.\n' >> skills/habits/references/habit-card.md"
probe "an evidence grade outside the vocabulary" \
  "sed -i.bak '0,/evidence=practitioner/s//evidence=vibes/' skills/habits/assets/starter/system-habits.md"
probe "a card with no evidence grade" \
  "perl -0pi -e 's/ evidence=practitioner//' skills/habits/assets/starter/system-habits.md"
probe "a fabricated lapses=0 on a shipped card" \
  "sed -i.bak '0,/status=active/s//lapses=0 status=active/' skills/habits/assets/starter/system-habits.md"
probe "a grader drifting from its documented check" \
  "sed -i.bak '0,/^Check: /s//Check: something else entirely /' skills/habits/references/starter-pack.md"
probe "a stale habit count in prose" \
  "sed -i.bak 's/20 starter habits/19 starter habits/' README.md"
probe "the marketplace description going missing" \
  "jq 'del(.description)' .claude-plugin/marketplace.json > m && mv m .claude-plugin/marketplace.json"
probe "manifest versions drifting apart" \
  "jq '.version = \"9.9.9\"' .claude-plugin/plugin.json > p && mv p .claude-plugin/plugin.json"
probe "an em dash" \
  "printf '\nsomething \\u2014 like this\n' >> README.md"
probe "a reference file SKILL.md never links" \
  "cp skills/habits/references/gates.md skills/habits/references/orphan.md"
probe "the gate losing its recursion guard" \
  "sed -i.bak 's/stop_hook_active/stop_hook_inactive/g' skills/habits/assets/gates/completion-gate.sh"
probe "a grade withdrawn in the doc but left on the card" \
  "sed -i.bak '0,/evidence=practitioner/s//evidence=evidence-based/' skills/habits/assets/starter/system-habits.md"
probe "the judge gaining write tools" \
  "sed -i.bak 's/^tools: Read, Grep, Glob$/tools: Read, Grep, Glob, Write/' agents/habit-judge.md"

printf '\n'
[ "$fail" -eq 0 ] && { printf '\033[32mEvery check fires on its defect.\033[0m\n'; exit 0; } \
                  || { printf '\033[31mSome checks cannot detect what they were written for.\033[0m\n'; exit 1; }
