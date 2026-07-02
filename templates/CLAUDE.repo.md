<!--
  PER-REPO CLAUDE.md TEMPLATE  →  install at <your-repo>/CLAUDE.md
  One of these lives at the root of each PRODUCTION repo. It layers on top of the global rules.
  Replace every <PLACEHOLDER>, delete this comment block.
-->

# <REPO NAME> — Claude instructions

This repo is on the **Proper-Flow Lane** (production; auto-deploys on merge to `<TARGET_BRANCH>`).
Do NOT edit `<TARGET_BRANCH>` directly; `git push` of a branch is not "live" — merge to
`<TARGET_BRANCH>` is.

- Remote: `<org>/<repo>`
- Target / deploy branch: `<main | production>`

## Workflow
1. Start clean: `git switch <TARGET_BRANCH> && git pull --ff-only origin <TARGET_BRANCH>`.
2. One fresh branch per task (one branch = one PR). Keep changes scoped.
3. Run the smallest useful tests/build checks; report what changed + verified.
4. Push branch → open PR → the Merge-Safety Agent runs the checks → merge only on an explicit "go".
5. After merge: let the configured deploy run (no manual prod deploy unless asked); verify prod;
   switch back to `<TARGET_BRANCH>`, `git pull --ff-only`, delete the merged branch.
6. Do NOT touch unrelated untracked/modified files. Never `git clean`.

## Model lane (which model does what in THIS repo)
Default to the "builder" model for features; UI → builder model. **Escalate to the top-tier model
for:** <the specific high-stakes work in this repo, e.g. "the data-model design", "security review
before any customer-facing login goes live", "migration planning">. Ask before any top-tier or
production action.
