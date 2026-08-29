<!--
MENU, NOT AN INSTALL. Four project-scope craft cards, budget is ten per project
file. Adapt every one of them to this codebase: name the real test command, the
real formatter, the real dangerous directory. A habit that names the actual tool
is followed better than a generic one. Write the result to
<repo>/.claude/rules/habits.md and replace every <added> with today's date.
-->

# Habits

Standing habits for this project. Each one is a trigger and an action. Follow
them in every session in this repository. A direct instruction from the user
outranks any habit here.

## Active

### PRJ-01 · Smallest diff
**When** I am changing code to satisfy a request.
**Do** Change only what the request needs, and propose anything else separately.
<!-- habit: id=PRJ-01 added=<added> source=starter/craft lapses=0 status=active check="the diff contains no unrelated renames, reformats, or refactors" -->

### PRJ-02 · Match the neighbours
**When** I write code in an existing file.
**Do** Follow that file's patterns, naming, and comment density instead of my own defaults.
<!-- habit: id=PRJ-02 added=<added> source=starter/craft lapses=0 status=active check="the new code is not identifiable as foreign by style alone" -->

### PRJ-03 · No green-washing
**When** a test fails and the fastest fix is to change the test.
**Instead** Fix the code, or report the failure verbatim and stop.
<!-- habit: id=PRJ-03 evidence=contested added=<added> source=starter/craft lapses=0 status=active check="no assertion was weakened, skipped, or deleted to produce a pass" -->

### PRJ-04 · Clean exit
**When** I am about to report a task as done.
**Do** Remove scratch files, debug output, and stray branches I created, or say what I left and why.
<!-- habit: id=PRJ-04 added=<added> source=starter/craft lapses=0 status=active check="nothing the agent created for its own convenience remains unmentioned" -->
