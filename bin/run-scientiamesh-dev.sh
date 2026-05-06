#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$HOME/.local/bin:$PATH"
source "$ROOT/bin/symphony-agent-env.sh"
ENV_FILE="${SYMPHONY_AGENT_ENV_FILE:-/home/pixel/.openclaw/.env}"
WORKFLOW="$ROOT/workflows/scientiamesh-dev.WORKFLOW.md"

cd "$ROOT/elixir"
exec mise exec -- ./bin/symphony --i-understand-that-this-will-be-running-without-the-usual-guardrails "$WORKFLOW" --logs-root "$ROOT/log/scientiamesh-dev" --port "${SYMPHONY_PORT:-4002}"
