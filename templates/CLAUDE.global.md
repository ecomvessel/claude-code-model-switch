<!--
  GLOBAL CLAUDE.md TEMPLATE  →  install at ~/.claude/CLAUDE.md
  This is the "brain rules" every Claude Code session loads, in every repo.
  Replace every <PLACEHOLDER> with your own values, then delete this comment block.
-->

# Verify Before Recommending (applies to EVERY session)

Before offering next steps, re-check the LIVE repo/PR/prod state (git fetch, gh pr view, actual
files) — do not rely on memory or your own previous messages; they go stale. Give the best option
only after verification, and explicitly label anything unverified. If the best option is a merge,
deploy, or migration: show the evidence first (what was checked, what it showed), then confirm.

# Model Routing (applies to EVERY session)

Default seat = **<YOUR DEFAULT MODEL, e.g. the strongest "planner" model you pay for>**. The seat is
the model YOU sit in; it plans, decides, and reviews. It delegates the rest.

**Two gates govern all model movement — they are the ONLY interruptions:**
1. **Delegate DOWN = automatic and silent, no asking.** Push grunt work (bulk reading, repo surveys,
   logs/docs) to the cheapest model and mechanical build-from-a-clear-plan (boilerplate, tests,
   lint/typecheck-fix loops, simple refactors) to a mid-tier "builder" model — as subagents. Bound
   the scope: no scope expansion, no deploy, no merge, no live-API calls, stop after report.
2. **Escalate UP to the top-tier model, OR any PRODUCTION ACTION = ALWAYS ask first.** "Production
   action" means the live target branch, a deploy, a prod DB/migration, or prod env/secrets — NOT
   ordinary branch work inside a production repo. Creating a branch, editing files on it, and
   running local tests are normal and need no ask; merging/deploying/migrating do.

**Escalate to the top-tier model ONLY for:** (1) architecture/planning a new system, (2) hard or
production debugging, (3) pre-merge or security review on a production repo, (4) anything touching
DB migrations, credentials, or customer messaging. **UI/styling work → the builder model.**
The top tier costs more — reserve it for design, danger, or money (~20% of work), never routine coding.

At session start, pick the lane from what the task actually is. If the session is on the expensive
model but the task is UI / CRUD / go-live mechanics, say "this doesn't need the top model, switch down."

# Two Lanes: Fast vs Proper-Flow (applies to EVERY repo)

Classify each repo into one lane. Default new repos to Fast Lane; graduate production/customer repos
to Proper Flow.

## FAST LANE — low-stakes repos (marketing sites, staging, non-customer data)
```
git pull            # ALWAYS before editing — never edit stale/live code
# ...edit...
git commit -am "msg" && git push
```
Non-negotiables: pull before editing every time; ONE terminal/folder per repo (shared checkouts
cause stale/colliding pushes — use `git worktree` for parallel work); never deploy from a stale state.

## PROPER-FLOW LANE — production / customer-data repos
```
git switch <TARGET_BRANCH> && git pull --ff-only origin <TARGET_BRANCH>   # start clean
# create ONE fresh branch, one branch = one PR
# ...edit (scoped)... run smallest useful tests
# push branch → open PR → merge-safety check → merge → auto-deploy → verify prod
```
Never edit the target branch directly. `git push` of a branch is NOT "live" — live happens only when
a PR merges into the target branch. Never `git clean` (it deletes untracked local work).

### Graduated repos (Proper Flow)
List your production repos here with verified path, remote, and target branch. Example:
- **<REPO NAME>** — `~/Projects/<repo>`, remote `<org>/<repo>`, target `<main | production>`.

# Merge-Safety Agent — TIERED policy (applies to EVERY session)

Whenever a PR merge comes up, do NOT dump a technical report on the human. Instead:
1. **Auto-spawn a merge-safety subagent** that silently runs all the merge checks (right target
   branch? tests/CI pass? no DB migration/schema/data change? not behind target? no conflicts? no
   unrelated files? deploy path understood? rollback = simple revert?) and returns a verdict:
   🟢 safe / 🟡 needs-a-human-call / 🔴 do-not-merge.
2. **Act by repo tier:**
   - **Fast-lane / low-stakes:** on 🟢, merge and report after in one plain sentence.
   - **Production / customer-data:** on 🟢, the agent posts one plain-English sentence describing
     what the PR does and asks the human to confirm by replying `go`. The agent merges ONLY after
     the human replies `go` — it must NEVER issue the merge on its own. (The word "go" comes from
     the human, not the agent.)
   - On 🟡: STOP, explain in plain business terms WHY it matters, wait.
   - On 🔴: do not merge; fix first, then re-run the safety agent.
3. **Translate to business language.** The human answers one question: "ship it or not?"

# Auto Mode Hard Line (applies to EVERY session)

Auto-accept covers read-only checks, local edits, local tests, and local commits on a work branch.
Auto-accept does NOT cover: merging production PRs, pushing to main/production, applying migrations
to any remote/prod DB, changing env vars, or triggering production deploys. Each needs an explicit
one-word confirmation, even with auto-accept on. (Fast-lane 🟢 merges may auto-proceed per the
Merge-Safety policy above.)

# Model Fallback (applies to EVERY session)

Always name the SPECIFIC version when referring to a tier (e.g. "Opus 4.8", not just "Opus") —
model names change over time and an unversioned reference silently goes stale. Fill in your current
versions here and update this line whenever you upgrade a tier:
`<cheap-reader-vX> / <builder-vX> / <seat-vX> / <top-tier-vX>`.

If the model this policy calls for is unavailable (outage, deprecated, rate-limited):
1. Fall back exactly one tier down (top-tier → seat → builder → cheap-reader) and explicitly flag
   that the work is running WITHOUT its normal tier — do not silently proceed as if nothing changed.
2. For anything gated by "escalate up, always ask first": if the top-tier model is unavailable, STOP
   and tell the human — do not auto-substitute a weaker model for a security/migration decision. Ask
   whether to proceed on the fallback tier or wait.
3. For routine delegate-down work (builder/cheap-reader unavailable): fall back to the seat model
   and keep going — no need to ask, just note it happened.

# Honest limits (know this)
These files are CONVENTIONS the model follows reliably — not hard enforcement. The real backstop is
GitHub branch protection + CI. Add those under the production repos as the enforcement layer.
