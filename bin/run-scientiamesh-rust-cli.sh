#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$HOME/.local/bin:$PATH"
ENV_FILE="/home/pixel/.openclaw/.env"
WORKFLOW="$ROOT/workflows/scientiamesh-rust-cli.WORKFLOW.md"

if [[ -z "${LINEAR_API_KEY:-}" && -f "$ENV_FILE" ]]; then
  LINEAR_API_KEY="$(awk -F= '$1 == "LINEAR_API_KEY" {print substr($0, index($0, "=") + 1)}' "$ENV_FILE")"
  export LINEAR_API_KEY
fi

cd "$ROOT/elixir"
exec mise exec -- ./bin/symphony "$WORKFLOW" --logs-root "$ROOT/log/scientiamesh-rust-cli" --port "${SYMPHONY_PORT:-4000}"
