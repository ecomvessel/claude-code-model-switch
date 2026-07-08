# Claude Code Flow — one seat, auto-delegating agents, safe shipping

A drop-in **operating layer for [Claude Code](https://claude.com/claude-code)**: you sit in one
model, it **delegates cheap work down automatically**, **asks before using the expensive model or
shipping to production**, and runs every change through a safe **branch → PR → merge** flow with a
plain-English safety check.

> **This is not a plugin.** It's a portable **instruction pack** (Markdown rule files the agent
> reads and follows) **plus recommended GitHub enforcement.** The rules make the agent fast and
> disciplined; the enforcement — **branch protection + CI** on your production repos — makes the
> discipline unskippable. An LLM following prose can still misfire, so run both layers: the policy is
> the habit, branch protection is the wall.

## Quickstart

**Fastest: pick a preset** — model roles pre-filled for your plan, zero editing, works as installed:
```bash
curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh | bash -s -- --preset fable-5
```
| Preset | Pick this if… |
|--------|---------------|
| `fable-5` | you have **Fable 5** access (e.g. Max) — Haiku 4.5 reads / Sonnet 5 builds / Opus 4.8 seat / Fable 5 top tier |
| `opus-4-8` | no Fable — **Opus 4.8** is your best model |
| `sonnet-5` | you sit in **Sonnet 5** (e.g. Pro), Opus 4.8 for the hard stuff |

What each preset routes where, and when to switch: [`presets/`](./presets/README.md).

**Or install the blank template** and fill in your own model names:
```bash
curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh | bash
```
Then open the installed file and replace the `<PLACEHOLDER>`s (your model tiers + production repos).

Review first, then run (works with `--preset` too):
```bash
curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh -o quick-install.sh
less quick-install.sh
bash quick-install.sh
```

Or clone it first:
```bash
git clone https://github.com/ecomvessel/claude-code-flow   # or your fork
cd claude-code-flow
./install.sh            # safe: never overwrites an existing ~/.claude/CLAUDE.md
```
To also drop a per-repo `CLAUDE.md` template into the current directory:
```bash
curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh | bash -s -- --repo
```
To pin a fork, branch, or release tag:
```bash
CCF_REPO=ecomvessel/claude-code-flow CCF_REF=main bash quick-install.sh
```
- **New to this?** See filled-in [`examples/`](./examples) before writing your own.
- **Setting model roles?** See [`MODEL_TIERS.md`](./MODEL_TIERS.md).
- **Full walkthrough + the enforcement step?** See [`SETUP.md`](./SETUP.md).

---

## The flow

### 1. Rules load as files, not memory
```
~/.claude/CLAUDE.md      → global rules, every session, every repo
<repo>/CLAUDE.md         → this repo's workflow + its model lane
```
Rules live in version-controllable files, so every session already knows the flow, the gates, and
which model to use where. The "intelligence" is portable text — not magic, not memory.

### 2. Work routes to the right model automatically
```
        ┌─ DELEGATE DOWN  → builder model writes code, cheap model reads   [silent, automatic]
SEAT ───┼─ STAY ON SEAT   → planning, judgment, review                     [default]
        └─ ESCALATE UP    → top-tier model                                 [ALWAYS asks first]
```
**Down is silent. Up asks.** The only two interruptions in the entire system:
1. "Use the expensive top-tier model?"
2. "Ship this to production?"

Everything cheaper than that just runs.

### 3. When it escalates to the top-tier model (design, danger, or money)
```
  1. Architecture / planning a new system
  2. Hard or production debugging
  3. Pre-merge or security review on a production repo
  4. Anything touching migrations, credentials, or customer messaging
```
Never for routine coding. ~20% of work, tops.

### 4. Nothing is "done" until it's proven
Before any build is called done, it self-verifies against a **Definition of Done** (build/lint/tests
pass, DB queried to confirm data, APIs/crons exercised, UI checked as a user *and* matched against the
DB). Then a **fresh independent subagent** — one that didn't write the code — adversarially tries to
break it, and fixes loop until it comes back clean. The independence comes from the fresh context, so
it's automatic (no second vendor required).

### 5. Safety rails on every change
```
PROPER-FLOW (production repos):  branch → PR → merge → auto-deploy → verify
FAST LANE  (marketing/staging):  smaller, quicker, lower stakes
```
**Merge-Safety Agent** — no git-speak reaches you:
```
A subagent runs the merge checks → 🟢 safe / 🟡 needs you / 🔴 stop
   🟢 production: plain-English summary READ FROM THE ACTUAL DIFF + changed-file list
                  → you reply "go" (the agent can never merge on its own)
   🟢 low-stakes: auto-merge + report after — ONLY if CI or a local build/test
                  actually ran and passed; no automated check = no auto-merge
```
You answer one question: **"ship it or not?"** — with the evidence attached.

---

## Honest limits (read before you rely on it)
- These files are **conventions the model follows reliably — not hard enforcement.** The real
  backstop is **GitHub branch protection + CI** ([SETUP.md](./SETUP.md) Step 5). Add it on production repos.
- **This repo demonstrates the pattern, it doesn't do it for you.** The `validate` workflow here just
  checks these docs; *your* production repos need their own branch protection + CI running *your*
  tests. Copy the habit, not this repo's checks.
- Auto-merge exists only on low-stakes repos AND only behind a passed automated check (CI or local
  build/test). No check = no auto-merge. Production always needs an explicit human `go`, given
  against a diff-derived summary and file list — not the model's unverified opinion.
- Multi-tier routing only helps if your Claude plan has more than one model. With one model it still
  enforces the safe flow; it just won't switch.

## License
MIT — take it, fork it, make it yours.
