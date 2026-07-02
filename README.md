# Claude Code Flow — one seat, auto-delegating agents, safe shipping

A portable set of instruction files that turn [Claude Code](https://claude.com/claude-code) into a
disciplined team: you sit in one model, it **delegates cheap work down automatically**, **asks before
using the expensive model or shipping to production**, and runs every change through a safe
**branch → PR → merge** flow with a plain-English safety check.

> **Read this first — what this is and isn't.** These files are a *policy the model follows
> reliably* — not a technical control. An LLM reading rules can still misfire or be prompted around
> them. This isn't automation replacing judgment; it's automation that never gets to skip the
> judgment step — and the hard enforcement underneath it is **GitHub branch protection + CI**
> ([SETUP.md](./SETUP.md) Step 5). Run both layers: the policy makes the agent fast and disciplined;
> branch protection makes the discipline unskippable.

**→ [SETUP.md](./SETUP.md) for install steps.** Templates live in [`templates/`](./templates).

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

### 4. Safety rails on every change
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
- Auto-merge exists only on low-stakes repos AND only behind a passed automated check (CI or local
  build/test). No check = no auto-merge. Production always needs an explicit human `go`, given
  against a diff-derived summary and file list — not the model's unverified opinion.
- Multi-tier routing only helps if your Claude plan has more than one model. With one model it still
  enforces the safe flow; it just won't switch.

## License
MIT — take it, fork it, make it yours.
