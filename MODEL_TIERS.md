# Model Tiers — how to slot any model into a role (and what happens when one drops)

The whole system is built on **roles, not model names.** You never hardcode "Opus" or "Gemini" into
behavior — you hardcode four *roles*, and drop whatever model is best today into each one. When a new
model launches, you don't rewrite the rules; you swap one line.

## The four roles

| Role | What it does | Reach for the… |
|------|--------------|----------------|
| **cheap-reader** | bulk reading, repo surveys, logs, docs — returns a summary | cheapest fast model |
| **builder** | mechanical build-from-a-clear-plan: boilerplate, tests, lint/typecheck fixes, simple refactors, UI/styling | solid mid-tier model |
| **seat** | the model YOU sit in — plans, decides, reviews, delegates the rest | strong general model |
| **top-tier** | architecture, hard/prod debugging, security/pre-merge review, migrations/creds/customer messaging | most capable model (reserve it — ~20% of work) |

Down is silent and automatic. **Up (to top-tier) always asks first.** So do production actions.

## Mapping a brand-new model

When a new model drops, ask one question: *"which role does this belong in?"*

1. Cheaper + faster than your current cheap-reader → it's the new **cheap-reader**.
2. Good at mechanical coding, mid-cost → new **builder**.
3. Strong all-round reasoning at a price you'll pay all day → candidate **seat**.
4. Most capable, expensive, worth it only for design/danger/money → new **top-tier**.

Then update the single version line in `~/.claude/CLAUDE.md` (the **Model Fallback** section):

```
<cheap-reader-vX> / <builder-vX> / <seat-vX> / <top-tier-vX>
```

That one line is the only place model *names* live. Everything else refers to roles, so it keeps
working across model generations untouched.

> **Always name the specific version** ("Opus 4.8", not "Opus"). Unversioned names silently go stale
> when a tier upgrades.

## When a model is unavailable (outage, deprecated, rate-limited)

This is the "backup" — the agent already knows how to keep going without the normal model:

1. **Fall back exactly one tier down** (top-tier → seat → builder → cheap-reader) and **say so out
   loud** — never silently pretend nothing changed.
2. **If the missing model was gated behind "ask first"** (top-tier work: security, migrations, prod
   debugging) — **STOP and ask.** Do not auto-substitute a weaker model for a high-stakes decision.
   The human chooses: proceed on the fallback tier, or wait.
3. **If it's routine delegate-down work** (builder/cheap-reader is down) — fall back to the seat model
   and keep going. No need to ask; just note it happened.

The rule in one line: **degrade gracefully, flag it every time, and never let a fallback quietly make
a security or production call the missing top-tier model was supposed to make.**

## If you do not have Fable access

Nothing in this pack requires Fable specifically. Use the best model you can actually select as your
**top-tier** role. If Fable is unavailable, paid-only, API-only for your account, or later retired,
map top-tier to Opus, Sonnet, or whatever your strongest available model is. The safety flow still
works; you just lose the extra capability of that missing tier.
