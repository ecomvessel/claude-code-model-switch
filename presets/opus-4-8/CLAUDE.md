<!--
  PRESET: opus-4-8 — for plans WITHOUT Fable access, where Opus 4.8 is the strongest model.
  Roles: Haiku 4.5 (cheap-reader) / Sonnet 5 (builder) / Opus 4.8 (seat AND top-tier).
  Works as installed. Optional: list your production repos under "Graduated repos" below.
  Model names current as of mid-2026 — see MODEL_TIERS.md when a new model ships.
-->

# Verify Before Recommending (applies to EVERY session)

Before offering next steps, re-check the LIVE repo/PR/prod state (git fetch, gh pr view, actual
files) — do not rely on memory or your own previous messages; they go stale. Give the best option
only after verification, and explicitly label anything unverified. If the best option is a merge,
deploy, or migration: show the evidence first (what was checked, what it showed), then confirm.

# Model Routing (applies to EVERY session)

Default seat = **Opus 4.8**. The seat is the model YOU sit in; it plans, decides, and reviews. It
delegates the rest. In this setup Opus 4.8 is ALSO the top tier — there is no stronger model to
escalate to, so high-stakes work stays on the seat; the ask-first gates below still apply in full.

**Two gates govern all model movement — they are the ONLY interruptions:**
1. **Delegate DOWN = automatic and silent, no asking.** Bulk reading / repo surveys / logs / docs →
   **Haiku 4.5** subagents. Mechanical build-from-a-clear-plan (boilerplate, tests,
   lint/typecheck-fix loops, simple refactors, UI/styling) → **Sonnet 5** subagents. Bound the
   scope: no scope expansion, no deploy, no merge, no live-API calls, stop after report.
2. **High-stakes work, OR any PRODUCTION ACTION = ALWAYS ask first.** High-stakes work = (1)
   architecture/planning a new system, (2) hard or production debugging, (3) pre-merge or security
   review on a production repo, (4) anything touching DB migrations, credentials, or customer
   messaging. "Production action" means the live target branch, a deploy, a prod DB/migration, or
   prod env/secrets — NOT ordinary branch work inside a production repo. Creating a branch, editing
   files on it, and running local tests are normal and need no ask; merging/deploying/migrating do.

**UI/styling work → Sonnet 5.** Keep the seat for planning, judgment, review, and the high-stakes
categories above (~20% of work) — delegate the rest down.

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
List your production repos here with verified path, remote, and target branch — until a repo is
listed (or is clearly production/customer-data), it is treated as Fast Lane. Example format:
- **my-app** — `~/Projects/my-app`, remote `my-org/my-app`, target `main`.

# Definition of Done (EVERY build clears this before it's called "done")

"It compiles" is not done. Before any builder/subagent declares work complete, it must self-verify:
- Build + typecheck + lint pass (the repo's real commands).
- Tests pass; add/adjust tests for the changed behavior.
- Touches the DB? Run the actual query/SQL to confirm the data is what's expected — don't assume.
- Touches an API route / cron / webhook? Exercise it and confirm it responds / runs.
- Changes the UI? Check it as a user would (drive the real UI, e.g. Playwright) AND confirm the data
  shown actually matches the DB / source of truth — the #1 silent bug.
- Report what was tested and the result. "Should work" ≠ done. "Ran it, here's the output" = done.

# Independent Verify (non-trivial changes, before the merge gate)

After the builder self-verifies, hand the change to an INDEPENDENT reviewer that did NOT write it —
a fresh subagent (or an external model/tool if you have one) — with an adversarial prompt: "find what's
broken, wrong, or missing." Fresh context catches what the author's misses.
- Pass findings back, fix, re-check. Loop up to 3× (usually 1–2) until it comes back clean.
- Only then does it enter the Merge-Safety gate.
Independence comes from the FRESH CONTEXT, not a different vendor — so a subagent is enough and it's
automatic. Paste into an external tool manually only if you want an extra opinion.

# Merge-Safety Agent — TIERED policy (applies to EVERY session)

Whenever a PR merge comes up, do NOT dump a technical report on the human. Instead:
1. **Auto-spawn a merge-safety subagent** that silently runs all the merge checks (right target
   branch? tests/CI pass? no DB migration/schema/data change? not behind target? no conflicts? no
   unrelated files? deploy path understood? rollback = simple revert?) and returns a verdict:
   🟢 safe / 🟡 needs-a-human-call / 🔴 do-not-merge.
2. **Act by repo tier:**
   - **Fast-lane / low-stakes:** on 🟢, merge and report after in one plain sentence — but ONLY if
     an objective automated check actually ran and passed (CI on the PR, or at minimum the repo's
     local build/test command executed by the agent). A 🟢 with no automated check behind it is a
     self-assessment, not a verification — in that case do NOT auto-merge; post the one-sentence
     summary and ask. ("Low-stakes" = marketing/staging/no customer data, ever.)
   - **Production / customer-data:** on 🟢, the agent posts one plain-English sentence describing
     what the PR does — derived from reading the ACTUAL DIFF, never from the PR title/description —
     plus the exact list of changed files, and asks the human to confirm by replying `go`. The agent
     merges ONLY after the human replies `go` — it must NEVER issue the merge on its own. (The word
     "go" comes from the human, not the agent.) The full diff is available on request.
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

Current tier versions (update this line whenever a tier upgrades — always name the SPECIFIC version;
unversioned names silently go stale):
`Haiku 4.5 (cheap-reader) / Sonnet 5 (builder) / Opus 4.8 (seat + top-tier)`.

If the model this policy calls for is unavailable (outage, deprecated, rate-limited):
1. Fall back exactly one tier down (seat → builder → cheap-reader) and explicitly flag that the work
   is running WITHOUT its normal tier — do not silently proceed as if nothing changed.
2. If Opus 4.8 (the seat/top tier) is unavailable and the task is high-stakes (security, migrations,
   prod debugging): STOP and tell the human — do not quietly make that call on a weaker model. Ask
   whether to proceed on Sonnet 5 or wait.
3. For routine delegate-down work (Sonnet 5 / Haiku 4.5 unavailable): fall back to the seat model
   and keep going — no need to ask, just note it happened.

If you later get Fable 5 access: switch to the `fable-5` preset — same flow, plus a dedicated top
tier for the high-stakes ~20%.

# Honest limits (know this)
These files are CONVENTIONS the model follows reliably — not hard enforcement. The real backstop is
GitHub branch protection + CI. Add those under the production repos as the enforcement layer.
