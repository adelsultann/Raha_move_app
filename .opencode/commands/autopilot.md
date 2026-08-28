---
description: Complete one RAHA task through specialist implementation, review, verification, and one local commit
agent: product-planner
---

Run the bounded Raha Move autopilot delivery workflow for `$ARGUMENTS`.

The argument must be exactly one task ID in the form `RAHA-###`. If it is missing, malformed, or contains more than one task, stop without modifying the repository.

Follow the autopilot delivery contract in the `product-planner` agent instructions. Begin with the clean-worktree preflight and check whether the task is already accepted. Otherwise, take it through readiness, explicit file ownership, specialist implementation, QA, required security review, final quality checks, scoped staging, and exactly one local atomic commit for the new work.

Do not create empty or duplicate commits. Do not push or perform destructive Git operations. Do not commit if any acceptance criterion, required check, privacy/security gate, or material product decision remains unresolved.
