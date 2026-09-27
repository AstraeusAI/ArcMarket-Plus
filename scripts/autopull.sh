#!/bin/bash
# Runs periodically via systemd --user timer. Fast-forwards this repo from
# origin/main; main.js watches .git/refs/heads/main and relaunches the running
# app when it changes, so pushed commits take effect without manual action.
set -uo pipefail
cd "$(dirname "$0")/.."

# Check if origin remote is configured
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Notice: No origin remote configured for ArcMarket+."
  exit 0
fi

# Fetch origin; if offline or unreachable, log and exit 0 so systemd doesn't treat it as a hard service failure
if ! git fetch origin main --quiet 2>/dev/null; then
  echo "Notice: ArcMarket+ remote fetch failed or repository is unreachable. Skipping update."
  exit 0
fi

LOCAL=$(git rev-parse HEAD 2>/dev/null || echo "")
REMOTE=$(git rev-parse origin/main 2>/dev/null || echo "")

if [ -n "$LOCAL" ] && [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
  if git pull --ff-only origin main; then
    echo "ArcMarket+ updated: $LOCAL -> $REMOTE"
  else
    echo "Notice: Fast-forward merge failed. Manual intervention needed."
  fi
fi
