#!/usr/bin/env bash
# quick-install.sh — one-command installer for people who have not cloned this repo.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/ecomvessel/claude-code-flow/main/quick-install.sh | bash -s -- --repo
#
# Optional for forks/testing:
#   CCF_REPO=your-org/claude-code-flow CCF_REF=your-branch bash quick-install.sh
set -euo pipefail

CCF_REPO="${CCF_REPO:-ecomvessel/claude-code-flow}"
CCF_REF="${CCF_REF:-main}"
caller_dir="$PWD"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required for quick install." >&2
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  echo "tar is required for quick install." >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

archive="$tmpdir/claude-code-flow.tar.gz"
archive_url="https://github.com/${CCF_REPO}/archive/${CCF_REF}.tar.gz"

echo "Claude Code Flow — quick install"
echo "Downloading ${CCF_REPO}@${CCF_REF}..."

curl -fsSL "$archive_url" -o "$archive"
tar -xzf "$archive" -C "$tmpdir"

repo_dir="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | sed -n '1p')"
if [ -z "$repo_dir" ] || [ ! -f "$repo_dir/install.sh" ]; then
  echo "Downloaded archive did not contain install.sh." >&2
  exit 1
fi

cd "$caller_dir"
bash "$repo_dir/install.sh" "$@"
