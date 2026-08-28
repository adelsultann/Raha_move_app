# Raha Move OpenCode Agents

This project uses one primary delivery coordinator and five focused OpenCode subagents. This provides enough specialization for the MVP without creating excessive coordination overhead or unclear ownership.

OpenCode discovers each Markdown file in `.opencode/agents/` automatically. `product-planner` is the default primary agent; the remaining agents are specialists it can invoke through the task tool or that a user can invoke explicitly with their filename, for example `@flutter-engineer`.

Before responding to or working on any task, every agent must read the root [AGENT.md](../AGENT.md). This requirement is repeated in every agent definition and is the project’s shared operating contract.

## Agent Roster

| Agent | Primary responsibility | Backlog focus | Model |
|---|---|---|---|
| `product-planner` | Primary coordinator for scope, requirements, delegation, acceptance, and atomic feature commits | RAHA-001–002 and cross-feature delivery | `openai/gpt-5.6-terra` |
| `flutter-engineer` | Flutter application, UI, state, routing, localization, and player | RAHA-010–014, 030–065 | `deepseek/deepseek-v4-pro` |
| `backend-data-engineer` | Supabase, Drift, schema, RLS, synchronization, and media delivery | RAHA-020–026 and backend parts of 070–072 | `openai/gpt-5.3-codex` |
| `recommendation-content-engineer` | Content normalization, importer, recommendation rules, explanations, and safety metadata | RAHA-002, 020–021, 041–043 | `openai/gpt-5.6-terra` |
| `qa-engineer` | Automated tests, accessibility, bilingual/offline regression, and release acceptance | RAHA-011 and 080–084 | `openai/gpt-5.6-terra` |
| `security-release-reviewer` | Read-only security, privacy, licensing, and release-risk review | RAHA-082 and release gates | `openai/gpt-5.6-sol` |

## Coordination Rules

- Use one lead agent for each task. Ask another agent to review only where its specialty is material.
- Do not have multiple agents edit the same file at the same time.
- Every implementation task must trace back to `docs/tasks-and-acceptance-criteria.md`.
- Resolve unclear requirements with `product-planner` before builders create incompatible behavior.
- Consult `recommendation-content-engineer` for recommendation scoring, exercise metadata, safety wording, or licensed content.
- Consult `security-release-reviewer` before changing authentication, RLS, storage authorization, analytics data, account deletion, or release secrets.
- Use `qa-engineer` after a vertical slice is runnable, not only at the end of the project.

## Autopilot Delivery

Run one bounded task with:

```text
/autopilot RAHA-015
```

The command accepts exactly one `RAHA-###` task. The coordinator verifies a clean worktree, checks readiness and dependencies, assigns non-overlapping implementation ownership, requests QA and any required security review, runs the applicable quality gates, and creates one local atomic commit only when the task is accepted.

Autopilot deliberately stops instead of committing when the worktree was already dirty, a material human decision is missing, a required check fails, or a blocking security finding remains. It never pushes. Specialist agents cannot stage or commit; only the primary coordinator owns the final task commit.

Before starting an autopilot run, commit or otherwise resolve intentional local work so that `git status --short` is empty.

## Shared Source of Truth

All agents must read the relevant parts of these documents before changing behavior:

- `docs/tasks-and-acceptance-criteria.md`
- `docs/product-brief.md`
- `docs/design-and-screens.md`
- `docs/design-system.md`
- `docs/project-structure.md`
- `docs/database.md`
- `docs/assets_strcture.md`

When documents disagree, do not silently choose one. Record the conflict and route it to `product-planner`; architecture or security conflicts must also be reviewed by the relevant specialist.
