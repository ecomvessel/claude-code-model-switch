<!--
  EXAMPLE — per-repo CLAUDE.md at the root of a production/customer-data repo.
  Sanitized: fake org/repo. This layers on top of the global rules.
-->

# Acme Billing — Claude instructions

This repo is on the **Proper-Flow Lane** (production; auto-deploys on merge to `main`).
Do NOT edit `main` directly; `git push` of a branch is not "live" — merge to `main` is.

- Remote: `acme/billing`
- Target / deploy branch: `main`

## Workflow
1. Start clean: `git switch main && git pull --ff-only origin main`.
2. One fresh branch per task (one branch = one PR). Keep changes scoped.
3. Run the smallest useful tests/build checks; report what changed + verified.
4. Push branch → open PR → the Merge-Safety Agent runs the checks → merge only on an explicit "go".
5. After merge: let Vercel auto-deploy `main` (no manual prod deploy unless asked); verify prod;
   switch back to `main`, `git pull --ff-only`, delete the merged branch.
6. Do NOT touch unrelated untracked/modified files. Never `git clean`.

## Model lane (which model does what in THIS repo)
Default to **Sonnet 5** for features; UI → Sonnet 5. **Escalate to the strongest available top-tier
model (Fable 5 if you have access, otherwise Opus 4.8 or your current best model) for:** the pricing /
proration data-model design, any change to the Stripe webhook or payment flow, security review before
an auth or billing change ships, and any DB migration on the customer database. Ask before any
top-tier or production action.

## Danger zone (repo-specific)
- Customer payment data lives here — never log full card/PII, never run destructive SQL on the live
  DB (no DROP/TRUNCATE/DELETE without WHERE; confirm first).
- Env/secrets are set in Vercel — never commit them; never expose a service key as `NEXT_PUBLIC_*`.
