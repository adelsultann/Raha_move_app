# RAHA-072 — Achievements and reward summary policy

**Decision owner:** Adel (product-planner)
**Decision date:** 2026-09-12
**Status:** Approved for MVP implementation.

## Initial achievement catalog

| Stable key | Title (EN) | Title (AR) | Versioned criterion | Icon key |
|---|---|---|---|---|
| `first_step` | First Step | خطوتك الأولى | One server-accepted completed routine | `first_step` |
| `gentle_habit_7` | A Gentle Habit | عادة لطيفة | Seven server-accepted completed routines | `gentle_habit` |

Both use `achievement_sessions_v1`, are server-owned, carry zero points, and
are awarded once per user. They never depend on feedback, pain tolerance,
range of motion, routine provider, competition, or public ranking.

## Completion summary

After feedback, the app presents one combined, calm summary of confirmed or
pending points, weekly-goal progress, current streak, and badges newly earned
by that session. It does not stack dialogs or repeat celebrations. When the
user reports `less_comfortable`, the completion flow retains the verified active
minutes and safety-approved acknowledgement, but suppresses reward celebration
and badge fanfare.

Locked badges use supportive invitation copy without suggesting the user is
behind. The server projection includes both Arabic and English content and
app-owned icon keys; no provider assets, private URLs, or raw service payloads
are sent to the client.
