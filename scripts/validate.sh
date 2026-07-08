#!/usr/bin/env bash
# validate.sh — the same check CI runs, runnable locally.
# 1) required files exist  2) every relative Markdown link resolves to a real file.
# Docs-only repo, so "CI" here is link + structure integrity — deterministic, no network.
set -euo pipefail

cd "$(dirname "$0")/.."
fail=0
LINK_FAIL=$(mktemp)              # fresh each run — no stale-file false failures
trap 'rm -f "$LINK_FAIL"' EXIT

echo "==> Required files"
required=(
  README.md
  SETUP.md
  LICENSE
  MODEL_TIERS.md
  install.sh
  quick-install.sh
  templates/CLAUDE.global.md
  templates/CLAUDE.repo.md
  presets/README.md
  presets/fable-5/CLAUDE.md
  presets/opus-4-8/CLAUDE.md
  presets/sonnet-5/CLAUDE.md
)
for f in "${required[@]}"; do
  if [ -e "$f" ]; then
    echo "  ok  $f"
  else
    echo "  MISSING  $f"; fail=1
  fi
done

echo "==> Presets are fully filled in (no leftover <PLACEHOLDER>s)"
# <TARGET_BRANCH> in shell examples is illustrative, not a config placeholder — allow it.
if grep -rn "PLACEHOLDER\|<YOUR" presets/*/CLAUDE.md 2>/dev/null; then
  echo "  a preset still contains a placeholder — presets must work as installed"; fail=1
else
  echo "  ok  presets contain no placeholders"
fi

echo "==> Relative Markdown links resolve"
while IFS= read -r -d '' md; do
  dir=$(dirname "$md")
  # pull each ](target) target out of the file
  { grep -oE '\]\([^)]+\)' "$md" 2>/dev/null || true; } | sed -E 's/^\]\(//; s/\)$//' | while IFS= read -r link; do
    # skip external / anchors / mailto etc.
    case "$link" in
      http://*|https://*|mailto:*|tel:*|\#*) continue ;;
    esac
    target="${link%%#*}"          # strip #anchor
    [ -z "$target" ] && continue
    resolved="$dir/$target"
    if [ ! -e "$resolved" ]; then
      echo "  BROKEN  $md -> $link"
      echo "broken" >> "$LINK_FAIL"
    fi
  done
done < <(find . -name '*.md' -not -path './.git/*' -print0)

if [ -s "$LINK_FAIL" ]; then
  fail=1
else
  echo "  ok  no broken relative links"
fi

echo "==> install.sh is valid bash"
if bash -n install.sh; then
  echo "  ok  install.sh parses"
else
  echo "  install.sh has a syntax error"; fail=1
fi

echo "==> quick-install.sh is valid bash"
if bash -n quick-install.sh; then
  echo "  ok  quick-install.sh parses"
else
  echo "  quick-install.sh has a syntax error"; fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS"
else
  echo "FAIL"; exit 1
fi
