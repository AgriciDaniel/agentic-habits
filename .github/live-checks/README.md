# Live checks

The claims in `skills/habits/references/verification.md` were measured, not
reasoned. These scripts are how they were measured, so the record is an artefact
you can rerun rather than testimony you have to take on trust.

`rules-canary.sh` needs the `claude` CLI, a working login, and a small amount of
model quota, so it never runs in CI. `gate-replay.sh` needs neither and **does**
run in CI, alongside `.github/checks.sh`, `.github/test-checks.sh`,
`.github/test-gate.sh` and `.github/test-install.sh`.

```bash
bash .github/live-checks/rules-canary.sh      # do rules files load, are comments stripped, is path scoping real
bash .github/live-checks/gate-replay.sh       # replay the recorded gate session against the shipped script
```

Each writes to a temporary directory and deletes it afterwards. Neither touches
`~/.claude`. If a result here contradicts `verification.md`, the record is
wrong and should be corrected rather than defended: it was written against
Claude Code 2.1.251 and the harness ships weekly.
