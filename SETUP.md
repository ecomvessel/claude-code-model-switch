# Setup — get this running in ~5 minutes

This is a set of **instruction files for [Claude Code](https://claude.com/claude-code)** (Anthropic's
CLI coding agent). It teaches the agent to: sit in one model, delegate cheap work down automatically,
ask before using the expensive model or shipping to production, and run every change through a safe
branch → PR → merge flow.

> **What this is / isn't.** These are Markdown rule files the agent reads and follows — not a plugin,
> script, or hard automation. Claude Code auto-loads `CLAUDE.md` files; the routing and safety
> behavior comes from the agent following the prose. It works reliably in practice, but it's
> conventions, not enforcement. The real enforcement layer is GitHub branch protection + CI (Step 5).

## Fast path
Fastest: install a **preset** — model roles pre-filled for your plan, no editing needed
(see [`presets/`](./presets/README.md) to pick: `fable-5`, `opus-4-8`, `sonnet-5`):
```bash
curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh | bash -s -- --preset fable-5
```

Or just the blank global rules (you fill in the `<PLACEHOLDER>`s after):
```bash
curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh | bash
```

Security-conscious install: download, inspect, then run:
```bash
curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh -o quick-install.sh
less quick-install.sh
bash quick-install.sh
```

If you are already inside a production repo and also want a per-repo `CLAUDE.md` template dropped
there:
```bash
curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh | bash -s -- --repo
```

To pin a fork, branch, or release tag after downloading the script:
```bash
CCF_REPO=ecomvessel/claude-code-flow CCF_REF=main bash quick-install.sh
```

The quick installer downloads this repo to a temp directory and runs `./install.sh`, which automates
Steps 1 and 3 below (safely — it never overwrites an existing `~/.claude/CLAUDE.md`; if you have one,
it installs alongside and prints the line to add). Prefer doing it by hand? Follow the steps. Either
way you still add enforcement (Step 5); the blank template additionally needs its placeholders filled
(presets don't).

## Prerequisites
- Claude Code installed and working (`claude` runs in your terminal).
- A Claude plan that gives you more than one model tier (so "delegate down / escalate up" is real).
  If you only have one model, the flow still works — it just won't switch models.

## Step 1 — Install the global rules
Copy the global template to your Claude Code config:
```bash
mkdir -p ~/.claude
# back up any existing file first:
[ -f ~/.claude/CLAUDE.md ] && cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak
cp templates/CLAUDE.global.md ~/.claude/CLAUDE.md
```
Then open `~/.claude/CLAUDE.md` and replace every `<PLACEHOLDER>`:
- your default/seat model, and the names of your "builder" and "top-tier" models
- your list of production repos (path, remote, target branch)

## Step 2 — Set your model seat
Pick the model you want to "sit in" by default:
```
/model            # inside Claude Code, choose your planner/seat model
```
Optional: if your plan has an auto-plan alias (plans on the strong model, builds on a cheaper one),
use that as your seat instead.

## Step 3 — Add a per-repo rule file to each production repo
For every repo you consider "production / customer-data":
```bash
cp templates/CLAUDE.repo.md /path/to/your-repo/CLAUDE.md
```
Edit it: set the target branch, remote, and the repo's "model lane" (what the expensive model is
reserved for here). Leave low-stakes repos (marketing sites, staging) without one — they stay Fast Lane.

## Step 4 — Try it
Open Claude Code inside a production repo and give it a real task:
```
cd /path/to/your-repo && claude
> "add <small feature> and open a PR"
```
You should see it: start on a fresh branch (not the target branch), do the work, and — when it's time
to merge — give you a plain-English "safe to merge, say go" instead of git jargon.

## Step 5 — Add the REAL enforcement (recommended)
The files above are conventions. Make them a hard wall on production repos:
- GitHub → repo → Settings → Branches → add a **branch protection rule** on your target branch:
  require a pull request, require status checks (CI) to pass, block direct pushes.
- Add a CI workflow that runs your tests on every PR.

Now the agent's flow AND the platform both enforce "no direct-to-main, tests must pass."

Note: the fast-lane auto-merge in these rules only fires when an automated check (CI or a local
build/test) actually passed — so until you add CI to a repo, the agent will ask instead of
auto-merging. That's intentional: speed comes from automated checks, not from skipping them.

## Customize
Everything is prose — edit the rules to fit how you work. The two ideas that matter most:
1. **Down is silent, up asks** (only two interruptions: use the expensive model? ship to prod?).
2. **Every production change goes branch → PR → safety check → merge → verify.**
