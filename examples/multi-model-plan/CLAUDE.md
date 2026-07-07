<!--
  EXAMPLE — global ~/.claude/CLAUDE.md filled in for a multi-tier plan.
  Roles are mapped to specific model versions; swap in your own.
  If you do not have Fable access, make Opus 4.8 (or your strongest available model) the top tier.
-->

# Verify Before Recommending (applies to EVERY session)

Before offering next steps, re-check the LIVE repo/PR/prod state (git fetch, gh pr view, actual
files) — do not rely on memory or your own previous messages; they go stale. Give the best option
only after verification, and explicitly label anything unverified. If the best option is a merge,
deploy, or migration: show the evidence first (what was checked, what it showed), then confirm.

# Model Routing (applies to EVERY session)

Default seat = **Opus 4.8**. The seat is the model I sit in; it plans, decides, and reviews. It
delegates the rest.

**Two gates govern all model movement — they are the ONLY interruptions:**
1. **Delegate DOWN = automatic and silent.** Bulk reading / repo surveys / logs → **Haiku 4.5**.
   Mechanical build-from-a-clear-plan (boilerplate, tests, lint/typecheck fixes, simple refactors,
   UI/styling) → **Sonnet 5**. As subagents, scoped: no deploy, no merge, no live-API calls.
2. **Escalate UP to the top-tier model, OR any PRODUCTION ACTION = ALWAYS ask first.**

**Escalate to the top-tier model (Fable 5, if available) ONLY for:** (1) architecture/planning a new
system, (2) hard or production debugging, (3) pre-merge or security review on a production repo,
(4) anything touching DB migrations, credentials, or customer messaging. **UI/styling → Sonnet 5.**
Reserve the top tier for design, danger, or money (~20% of work), never routine coding.

# Model Fallback (applies to EVERY session)

Current versions (roles → models):
`Haiku 4.5 (cheap-reader) / Sonnet 5 (builder) / Opus 4.8 (seat) / Fable 5 if available, otherwise Opus 4.8 (top-tier)`

If a model is unavailable (outage, deprecated, rate-limited):
1. Fall back exactly one tier down (top-tier → seat → builder → cheap-reader) and say so out loud.
2. If the missing model was the top-tier gated behind "ask first" (security, migrations, prod
   debugging): STOP and ask whether to proceed on the fallback tier or wait.
3. Routine delegate-down work (Sonnet/Haiku down): fall back to the seat model, note it, keep going.

# Two Lanes: Fast vs Proper-Flow, Definition of Done, Independent Verify, Merge-Safety Agent,
# Auto Mode Hard Line
# → identical to templates/CLAUDE.global.md; copy those sections in verbatim.
