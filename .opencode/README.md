# Raha Move OpenCode Agents

This project uses two OpenCode agents to minimize prompt and handoff overhead while retaining independent verification.

OpenCode discovers each Markdown file in `.opencode/agents/` automatically. `product-planner` is the default primary agent and sole implementation owner. It may invoke `security-release-reviewer` for independent verification.

Before responding to or working on any task, every agent must read the root [AGENT.md](../AGENT.md). This requirement is repeated in every agent definition and is the project’s shared operating contract.

## Agent Roster

| Agent | Primary responsibility | Backlog focus | Model |
|---|---|---|---|
| `product-planner` | Product decisions and implementation across Flutter, data, content, recommendations, tests, and delivery | All implementation tasks | `openai/gpt-5.6-terra` |
| `security-release-reviewer` | Read-only acceptance, accessibility, security, privacy, licensing, and release verification | Risk-based review and release gates | `openai/gpt-5.6-terra` |

## Coordination Rules

- `product-planner` owns every implementation task and all file changes.
- Use `security-release-reviewer` only when independent verification is useful or required by risk.
- Every implementation task must trace back to `docs/tasks-and-acceptance-criteria.md`.
- Consult `security-release-reviewer` before changing authentication, RLS, storage authorization, analytics data, account deletion, or release secrets.
- The reviewer may inspect and run non-destructive checks but never modifies files or creates commits.

## Autopilot Delivery

Run one bounded task with:

```text
/autopilot RAHA-015
```

The command accepts exactly one `RAHA-###` task. The primary agent verifies a clean worktree, checks readiness and dependencies, implements the task, requests risk-based independent review, runs the applicable quality gates, and creates one local atomic commit only when the task is accepted.

Autopilot deliberately stops instead of committing when the worktree was already dirty, a material human decision is missing, a required check fails, or a blocking finding remains. It never pushes. The reviewer cannot stage or commit; only the primary agent owns the final task commit.

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

When documents disagree, do not silently choose one. `product-planner` records and resolves product or architecture conflicts; material security, privacy, or release conflicts also require `security-release-reviewer`.
