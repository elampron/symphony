---
tracker:
  kind: linear
  api_key: $LINEAR_API_KEY
  # Linear project: https://linear.app/scientiamesh/project/tendril-5c4005679845
  project_slug: "5c4005679845"
  active_states:
    - Todo
    - In Progress
  terminal_states:
    - Done
    - Canceled
    - Cancelled
    - Duplicate
polling:
  interval_ms: 5000
workspace:
  root: /home/pixel/.openclaw/workspace/Projects/symphony-workspaces/tendril
hooks:
  timeout_ms: 120000
  after_create: |
    git clone https://github.com/elampron/tendril.git .
    cp -R /home/pixel/.openclaw/workspace/Projects/symphony/.codex ./.codex
    git status --short --branch
  before_run: |
    git fetch origin main --quiet
agent:
  max_concurrent_agents: 1
  max_turns: 12
codex:
  command: /home/pixel/.openclaw/workspace/Projects/symphony/bin/symphony-codex-app-server.sh
  approval_policy: never
  # TESTING MODE: full-open Codex. No Codex sandbox constraints.
  # Keep human PR review, no auto-merge/deploy, and isolated workspaces as outer controls.
  thread_sandbox: danger-full-access
  turn_sandbox_policy:
    type: dangerFullAccess
---

You are working on a Linear ticket for Tendril.

Issue:
- Identifier: {{ issue.identifier }}
- Title: {{ issue.title }}
- Current status: {{ issue.state }}
- Labels: {{ issue.labels }}
- URL: {{ issue.url }}

Description:
{% if issue.description %}
{{ issue.description }}
{% else %}
No description provided.
{% endif %}

Repository and scope:
- Work only in this assigned workspace.
- Target repository: elampron/tendril.
- Tendril is a standalone open source, agent-first relationship system for small teams that want CRM outcomes without traditional CRM data-entry pain.
- The product bias is toward an agent-operable CRM kernel: graph-native account memory, source provenance, convenient API/MCP tools, and a minimal human UI for review, correction, audit, search, timelines, and export.
- Read `README.md` and `WORKFLOW.md` before making changes when present.

Workflow:
1. If the issue is `Todo`, move it to `In Progress` before implementation.
2. Create or update one persistent Linear workpad comment headed `## Codex Workpad`.
3. Record the workspace path, branch, current commit, plan, acceptance criteria, and validation plan in that workpad.
4. Create a branch named after the issue, for example `codex/{{ issue.identifier | downcase }}-short-title`.
5. Implement narrowly, preserving the issue's scope and the repo's current conventions.
6. For product/design issues, create durable docs under `docs/` and validate by checking readability, links, and consistency with the README/workflow.
7. For code issues, run the smallest meaningful validation for the change. Prefer targeted tests, typechecks, lint, or focused smoke checks over broad expensive runs unless the issue requires them.
8. Commit and push the branch.
9. Open a GitHub PR against `elampron/tendril` with Summary, Files changed, Validation, Risks, and Follow-ups.
10. Move the Linear issue to `In Review` and attach/link the PR.

Linear access:
- Use Symphony's `linear_graphql` dynamic tool for Linear reads/writes, including state updates, comments, and PR attachments.
- Do not use raw Linear token shell commands; Symphony owns Linear auth and exposes it through `linear_graphql` inside the Codex app-server session.

Safety:
- Do not merge PRs.
- Do not deploy.
- Do not make irreversible external changes.
- Do not touch paths outside the assigned workspace.
- Do not expose secrets, tokens, private personal data, or unrelated confidential information.
- Stop only for true blockers such as missing required auth, impossible repo state, or unclear product scope that cannot be resolved from the issue. If blocked, explain the blocker in the workpad and move the issue to `In Review` for human attention.
