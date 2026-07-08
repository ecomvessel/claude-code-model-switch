# Presets — pick your plan, install, done

Each preset is a **ready-to-use global `CLAUDE.md`** with the model roles already filled in — no
`<PLACEHOLDER>` editing required. Pick the one matching the models your Claude plan gives you:

| Preset | Pick this if… | Seat (you sit in) | Builder | Reader | Top tier (asks first) |
|--------|---------------|-------------------|---------|--------|-----------------------|
| [`fable-5`](./fable-5) | You have **Fable 5** access (e.g. Max) | Opus 4.8 | Sonnet 5 | Haiku 4.5 | **Fable 5** |
| [`opus-4-8`](./opus-4-8) | No Fable — **Opus 4.8** is your best | Opus 4.8 | Sonnet 5 | Haiku 4.5 | Opus 4.8 |
| [`sonnet-5`](./sonnet-5) | You sit in **Sonnet 5** (e.g. Pro) | Sonnet 5 | Sonnet 5 | Haiku 4.5 | Opus 4.8 (if available) |

Install one directly:

```bash
curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh | bash -s -- --preset fable-5
```

Or from a clone: `./install.sh --preset fable-5` (add `--repo` to also drop a per-repo template).

**Every preset keeps the same token economics:** cheap model reads, mid model builds, your seat
plans/reviews, and the expensive tier only runs when you approve it. The names change per preset;
the routing (and the savings) don't.

Two things every preset leaves to you:
1. **Production repos** — optional but recommended: list yours under "Graduated repos" in the
   installed file, so they get the strict branch → PR → `go` flow. Unlisted repos default to Fast Lane.
2. **Enforcement** — add GitHub branch protection + CI on production repos ([SETUP.md](../SETUP.md)
   Step 5). The preset is the habit; branch protection is the wall.

**When models change** (new release, Fable access ends, plan upgrade): switch presets or edit the
single version line in the installed file's **Model Fallback** section — see
[MODEL_TIERS.md](../MODEL_TIERS.md). Roles are permanent; names are one line.

Prefer to hand-tune everything? Use the blank [`templates/`](../templates) instead — presets and
templates are the same rules, presets just arrive pre-filled.
