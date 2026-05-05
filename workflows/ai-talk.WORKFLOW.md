---
tracker:
  kind: linear
  api_key: $LINEAR_API_KEY
  # Linear project: https://linear.app/scientiamesh/project/ai-talk-3cdf034f3cee
  project_slug: "3cdf034f3cee"
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
  root: /home/pixel/.openclaw/workspace/Projects/symphony-workspaces/ai-talk
hooks:
  timeout_ms: 120000
  after_create: |
    git clone https://github.com/elampron/ai-talk.git .
    cp -R /home/pixel/.openclaw/workspace/Projects/symphony/.codex ./.codex
    git status --short --branch
  before_run: |
    git fetch origin main --quiet
agent:
  max_concurrent_agents: 1
  max_turns: 10
codex:
  command: /home/pixel/.openclaw/workspace/Projects/symphony/bin/symphony-codex-app-server.sh
  approval_policy: never
  thread_sandbox: workspace-write
  turn_sandbox_policy:
    type: workspaceWrite
    networkAccess: true
---

You are working on a Linear ticket for the private AI Talk operating repo.

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
- Target repository: elampron/ai-talk.
- This repo is for AI Talk research, drafts, briefs, diagrams, meeting prep, follow-ups, decisions, and operating artifacts.
- Read `README.md` and `WORKFLOW.md` before making changes.

Workflow:
1. If the issue is `Todo`, move it to `In Progress` before implementation.
2. Create or update one persistent Linear workpad comment headed `## Codex Workpad`.
3. Record the workspace path, branch, current commit, plan, acceptance criteria, and validation plan in that workpad.
4. Create a branch named after the issue, for example `codex/{{ issue.identifier | downcase }}-short-title`.
5. Implement narrowly by creating or editing markdown/artifact files in the appropriate folders.
6. Validate the work. For markdown, check links where practical and run a lightweight formatting/spell/readability pass. For generated artifacts, make sure source files are committed.
7. Commit and push the branch.
8. Open a GitHub PR against `elampron/ai-talk` with Summary, Files changed, Validation, Risks, and Follow-ups.
9. Move the Linear issue to `In Review` and attach/link the PR.

Safety:
- Do not send emails or messages.
- Do not post to Teams, social media, GitHub issues outside this repo, or any external channel.
- Do not make irreversible external changes.
- Draft external communications only as repo artifacts for Eric/Pixel review.
- Do not expose secrets, tokens, private personal data, or unrelated confidential information.
- Stop only for true blockers such as missing required auth, missing source material, or unclear external-action approval. If blocked, explain the blocker in the workpad and move the issue to `In Review` for human attention.
