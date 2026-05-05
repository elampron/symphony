#!/usr/bin/env bash
# Shared environment bootstrap for Symphony-launched coding agents.
# This file must never print secret values. It only exports an allowlist of
# service credentials from the operator env file plus a GitHub token from gh.

# Source this file from runner scripts and from workflow codex.command before
# launching Codex so Pixel, Symphony, and spawned Codex sessions see the same
# service auth surface.

if [[ -n "${SYMPHONY_AGENT_ENV_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
export SYMPHONY_AGENT_ENV_LOADED=1

ENV_FILE="${SYMPHONY_AGENT_ENV_FILE:-/home/pixel/.openclaw/.env}"

# Keep this deliberately narrow. Do not export mail/cloud admin secrets to Codex
# unless a workflow explicitly opts into them later.
DEFAULT_ALLOWLIST="LINEAR_API_KEY SMESH_API_KEY SMESH_TOKEN SMESH_API_URL SMESH_MESH_ID OPENAI_API_KEY GH_TOKEN GITHUB_TOKEN"
ALLOWLIST="${SYMPHONY_AGENT_ENV_ALLOWLIST:-$DEFAULT_ALLOWLIST}"

load_env_key() {
  local key="$1"
  [[ -n "${!key:-}" ]] && return 0
  [[ -f "$ENV_FILE" ]] || return 0

  local line value
  line="$(grep -E "^${key}=" "$ENV_FILE" | tail -n 1 || true)"
  [[ -n "$line" ]] || return 0
  value="${line#*=}"

  # Strip one layer of simple shell-style quotes without evaluating content.
  if [[ "$value" == \"*\" && "$value" == *\" ]]; then
    value="${value:1:${#value}-2}"
  elif [[ "$value" == \'*\' && "$value" == *\' ]]; then
    value="${value:1:${#value}-2}"
  fi

  export "$key=$value"
}

for key in $ALLOWLIST; do
  case "$key" in
    LINEAR_API_KEY|SMESH_API_KEY|SMESH_TOKEN|SMESH_API_URL|SMESH_MESH_ID|OPENAI_API_KEY|GH_TOKEN|GITHUB_TOKEN)
      load_env_key "$key"
      ;;
  esac
done

# ScientiaMesh token aliases: current tools often use SMESH_API_KEY, while the
# Rust CLI also accepts SMESH_TOKEN.
if [[ -z "${SMESH_TOKEN:-}" && -n "${SMESH_API_KEY:-}" ]]; then
  export SMESH_TOKEN="$SMESH_API_KEY"
fi

# GitHub token: prefer explicit env, otherwise derive from the authenticated gh
# keychain/config. Never print it. This gives spawned Codex git/gh parity with
# Pixel when gh is logged in on the host.
if [[ -z "${GH_TOKEN:-}" && -z "${GITHUB_TOKEN:-}" ]] && command -v gh >/dev/null 2>&1; then
  if token="$(gh auth token 2>/dev/null)" && [[ -n "$token" ]]; then
    export GH_TOKEN="$token"
    export GITHUB_TOKEN="$token"
  fi
elif [[ -n "${GH_TOKEN:-}" && -z "${GITHUB_TOKEN:-}" ]]; then
  export GITHUB_TOKEN="$GH_TOKEN"
elif [[ -n "${GITHUB_TOKEN:-}" && -z "${GH_TOKEN:-}" ]]; then
  export GH_TOKEN="$GITHUB_TOKEN"
fi

# Make gh-backed HTTPS git operations work in non-interactive Codex sessions.
if command -v gh >/dev/null 2>&1; then
  gh auth setup-git >/dev/null 2>&1 || true
fi
