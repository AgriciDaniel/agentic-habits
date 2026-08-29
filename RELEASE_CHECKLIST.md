# Release checklist

## Evidence, first, because everything else rests on it

- [ ] Refresh cadence in `skills/habits/references/verification.md` honored. Its
      own rule for a release is "every time".
- [ ] `bash .github/live-checks/rules-canary.sh` rerun on the current Claude Code
      version. Version stamp at the top of `verification.md` updated to that
      version and today's date.
- [ ] `claude --version` recorded, and any "Tested" entry that no longer holds
      corrected rather than left standing.
- [ ] Every claim in the repository that `verification.md` files as neither
      tested nor documented is still hedged wherever it appears.
- [ ] `verification.md` and `evidence.md` do not contradict each other.

## Counts, because prose drifts from the package

- [ ] `bash .github/checks.sh` passes, including its count and check-parity
      assertions.
- [ ] Starter habit total matches every place that states it: README, SKILL.md,
      starter-pack.md, both manifests, CHANGELOG.
- [ ] The README pack table lists every shipped card and its per-pack counts sum
      to the total.
- [ ] Gate test count in README and gates.md matches the suite.

## Package

- [ ] `bash .github/checks.sh`
- [ ] `bash .github/test-gate.sh`
- [ ] `bash .github/test-install.sh`
- [ ] `bash .github/live-checks/gate-replay.sh`
- [ ] `claude plugin validate . --strict`
- [ ] `claude plugin validate .claude-plugin/plugin.json --strict`
- [ ] `shellcheck` clean on every shipped shell script
- [ ] `./install.sh` and `./uninstall.sh` run clean against a scratch
      `HABITS_INSTALL_HOME`, twice, with and without `--with-gate`
- [ ] The plugin route tested end to end on a clean profile, and the resulting
      invocation name recorded in `verification.md`
- [ ] README states what the plugin route does and does not install

## Product and legal

- [ ] README states the requirements: Claude Code version tested, bash, jq for
      the gate, supported platforms
- [ ] SKILL.md's verb table and README's verb table agree
- [ ] LICENSE, NOTICE and assets/PROVENANCE.md are current and consistent, and
      no row in PROVENANCE.md is still "not established"
- [ ] `git grep -nE '/home/|@gmail|/var/home'` finds nothing in tracked files
- [ ] SECURITY.md's advisory URL matches the configured remote

## Tag and publish

- [ ] Version bumped in `.claude-plugin/plugin.json` and in the marketplace
      entry and metadata block, and the two agree
- [ ] CHANGELOG entry dated with the real release date
- [ ] Worktree clean, CI green on the exact commit being tagged
- [ ] `git tag habits--v<version> && git push origin habits--v<version>`
- [ ] GitHub release created, body pointing at the CHANGELOG section
- [ ] Social preview uploaded in repository settings. A file in `assets/` is not
      the setting
