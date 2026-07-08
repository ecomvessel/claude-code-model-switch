#!/usr/bin/env bash
# install.sh — set up Claude Code Flow WITHOUT clobbering your existing config.
#
#   ./install.sh                      # blank template: edit <PLACEHOLDER>s after install
#   ./install.sh --preset fable-5     # pre-filled config, works as installed (see presets/)
#   ./install.sh --repo               # also drop a per-repo template into the current directory
#
# It will NEVER overwrite an existing ~/.claude/CLAUDE.md. If you already have one, it installs the
# global rules to a separate file and prints one line for you to add. You stay in control of merging.
set -euo pipefail

CALLER_DIR="$PWD"                 # where the user ran the command (for --repo)
cd "$(dirname "$0")"             # repo dir, so template paths resolve
CLAUDE_DIR="$HOME/.claude"
GLOBAL_SRC="templates/CLAUDE.global.md"
SIDE_FILE="$CLAUDE_DIR/claude-code-flow.md"
MAIN_FILE="$CLAUDE_DIR/CLAUDE.md"

list_presets() {
  find presets -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort
}

want_repo=0
preset=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) want_repo=1 ;;
    --preset)
      preset="${2:-}"
      if [ -z "$preset" ]; then
        echo "--preset needs a name. Available presets:" >&2
        list_presets >&2
        exit 1
      fi
      shift ;;
    *) echo "Unknown option: $1 (supported: --preset <name>, --repo)" >&2; exit 1 ;;
  esac
  shift
done

if [ -n "$preset" ]; then
  if [ ! -f "presets/$preset/CLAUDE.md" ]; then
    echo "Unknown preset: '$preset'. Available presets:" >&2
    list_presets >&2
    exit 1
  fi
  GLOBAL_SRC="presets/$preset/CLAUDE.md"
fi

echo "Claude Code Flow — installer"
[ -n "$preset" ] && echo "Using preset: $preset (pre-filled — works as installed)"
echo

mkdir -p "$CLAUDE_DIR"

if [ ! -f "$MAIN_FILE" ]; then
  # Fresh machine, no existing global config → safe to make our rules the global file.
  cp "$GLOBAL_SRC" "$MAIN_FILE"
  echo "✓ No existing ~/.claude/CLAUDE.md — installed the global rules there."
  target_to_edit="$MAIN_FILE"
else
  # Existing config present → DO NOT touch it. Install alongside and tell the user how to include it.
  cp "$GLOBAL_SRC" "$SIDE_FILE"
  echo "• You already have ~/.claude/CLAUDE.md — left it untouched."
  echo "  Installed the flow rules alongside it at:"
  echo "      $SIDE_FILE"
  echo
  echo "  To activate, add this line near the top of your ~/.claude/CLAUDE.md:"
  echo "      > See ./claude-code-flow.md for model-routing + safe-shipping rules."
  echo "  (Or copy the sections you want out of that file by hand.)"
  target_to_edit="$SIDE_FILE"
fi

if [ "$want_repo" -eq 1 ]; then
  repo_target="$CALLER_DIR/CLAUDE.md"
  if [ -f "$repo_target" ]; then
    echo
    echo "• A CLAUDE.md already exists in $CALLER_DIR — not overwriting it."
    echo "  Compare against templates/CLAUDE.repo.md if you want the per-repo rules."
  else
    cp templates/CLAUDE.repo.md "$repo_target"
    echo
    echo "✓ Dropped a per-repo template at $repo_target (edit its <PLACEHOLDER>s)."
  fi
fi

echo
if [ -n "$preset" ]; then
  echo "Done — the preset works as installed. Two optional upgrades:"
  echo "  • list your production repos under 'Graduated repos' in the installed file"
  echo "  • add branch protection + CI on production repos (SETUP.md Step 5) — the real enforcement"
else
  echo "Next: open the file(s) above and replace every <PLACEHOLDER>:"
  echo "  • your seat / builder / cheap-reader / top-tier model versions"
  echo "  • your list of production repos (path, remote, target branch)"
  echo "Tip: prefer zero editing? Re-run with --preset <name> (see presets/README.md):"
  list_presets | sed 's/^/  • /'
fi
echo "See MODEL_TIERS.md for how model roles work, and SETUP.md for the rest."
