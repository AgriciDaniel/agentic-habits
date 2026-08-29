---
type: decision
title: "<what was decided>"
status: current
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
tags: ["#type/decision"]
related: ["<HABIT-ID>", "<case ids this bears on>"]
---

# <what was decided>

## Decision

One sentence. What changed, at what scope, from when.

## Why, without reference to the failure it produced

If this is a change to a habit's `check`, the reason must stand on its own. "The
check was wrong because it counted an attempted command as a completed one" is a
reason. "The check kept failing" is not, and a decision record that gives the
second one is a record of grader tampering with better formatting.

## What this invalidates

- Lapse history measured against the old version: reset to a dash, and say so.
- Cases that cited the old wording: they stay, unedited. A case is evidence and
  evidence is not revised to match a later decision.
- Any gate whose script encoded the old check.

## Re-baseline

State the new starting point: which habit, which check, which date, and what the
next judged run will be measured against.
