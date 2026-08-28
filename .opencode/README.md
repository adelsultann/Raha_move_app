# Raha Move OpenCode Agents

This project uses six focused OpenCode subagents. Six is enough specialization for the MVP without creating excessive coordination overhead or unclear ownership.

OpenCode discovers each Markdown file in `.opencode/agents/` automatically. Invoke an agent with its filename, for example `@flutter-engineer`.

Before responding to or working on any task, every agent must read the root [AGENT.md](../AGENT.md). This requirement is repeated in every agent definition and is the project’s shared operating contract.

## Agent Roster

| Agent | Primary responsibility | Backlog focus | Model |
|---|---|---|---|
| `product-planner` | Scope, requirements, UX behavior, and acceptance readiness | RAHA-001–002 and cross-feature product decisions | `openai/gpt-5.6-terra` |
| `flutter-engineer` | Flutter application, UI, state, routing, localization, and player | RAHA-010–014, 030–065 | `deepseek/deepseek-v4-pro` |
| `backend-data-engineer` | Supabase, Drift, schema, RLS, synchronization, and media delivery | RAHA-020–026 and backend parts of 070–072 | `openai/gpt-5.6-sol` |
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
