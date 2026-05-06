---
tracker:
  kind: linear
  api_key: $LINEAR_API_KEY
  # Linear project: https://linear.app/scientiamesh/project/scientiamesh-dev-be27bc017893
  project_slug: "be27bc017893"
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
  root: /home/pixel/.openclaw/workspace/Projects/symphony-workspaces/scientiamesh-dev
hooks:
  timeout_ms: 120000
  after_create: |
    git clone https://github.com/ScientiaMesh/scientiamesh.git .
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
  thread_sandbox: workspace-write
  turn_sandbox_policy:
    type: workspaceWrite
    networkAccess: true
---

You are working on a Linear ticket for the general ScientiaMesh development project.

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
- Target repository: ScientiaMesh/scientiamesh.
- This project is the normal development intake for ScientiaMesh bugs, features, refactors, UX polish, backend/API work, docs, and platform improvements.
- Let Linear labels guide scope and priority: `Bug`, `Feature`, `Improvement`, `urgent`, `ui`, `backend`, `database`, `deployment`, etc.
- Read `AGENTS.md`, `README.md`, and any path-local docs before editing when present.

Workflow:
1. If the issue is `Todo`, move it to `In Progress` before implementation.
2. Create or update one persistent Linear workpad comment headed `## Codex Workpad`.
3. Record the workspace path, branch, current commit, plan, acceptance criteria, and validation plan in that workpad.
4. Create a branch named after the issue, for example `codex/{{ issue.identifier | downcase }}-short-title`.
5. Implement narrowly, preserving existing architecture and project conventions.
6. Run the smallest meaningful validation for the change. Prefer targeted tests, typechecks, lint, or focused smoke checks over broad expensive runs unless the issue requires them.
7. Commit and push the branch.
8. Open a GitHub PR against `ScientiaMesh/scientiamesh` with Summary, Files changed, Tests run, Risks, and Follow-ups.
9. Move the Linear issue to `In Review` and attach/link the PR.

Linear access:
- Use Symphony's `linear_graphql` dynamic tool for Linear reads/writes, including state updates, comments, and PR attachments.
- Do not use raw Linear token shell commands; Symphony owns Linear auth and exposes it through `linear_graphql` inside the Codex app-server session.

Safety:
- Do not merge PRs.
- Do not deploy.
- Do not make irreversible external changes.
- Do not touch paths outside the assigned workspace.
- Do not expose secrets, tokens, private personal data, or unrelated confidential information.
- Stop only for true blockers such as missing required auth, missing secrets, or impossible repo state. If blocked, explain the blocker in the workpad and move the issue to `In Review` for human attention.
