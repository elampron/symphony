#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/bin/symphony-agent-env.sh"

exec codex \
  --config shell_environment_policy.inherit=all \
  --config 'model="gpt-5.5"' \
  --config model_reasoning_effort=xhigh \
  --config 'approval_policy="never"' \
  --config apps._default.destructive_enabled=true \
  --config apps._default.open_world_enabled=true \
  app-server
