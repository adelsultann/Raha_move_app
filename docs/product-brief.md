# Raha Move Product Brief

## Product Summary

Raha Move is a beginner-friendly stretching and mobility app that removes the effort of deciding which routine to follow.

Users tell the app:

- How their body feels today
- What they need today
- Which body areas they want to address
- How much time they have
- Whether they prefer seated, standing, floor-based, or unrestricted movement

The app recommends a short routine and explains why it was selected.

> Raha Move helps users choose the right short mobility routine for how their body feels today, without requiring fitness knowledge or planning.

## Core Problem

Many people want to stretch or move more, but they face three common barriers:

- They do not know which stretches to choose.
- They feel they do not have enough time.
- They are unsure whether a routine is suitable for them.

Raha Move addresses these barriers through short, personalized, clearly explained recommendations.

The product is not primarily an exercise-video library. Its main value is deciding what the user should do today, organizing the routine, guiding the session, and encouraging a consistent habit.

## Initial Audience

The initial audience includes:

- Desk workers
- Mobility beginners
- Adults experiencing common stiffness
- People who want short and approachable movement sessions

The initial body-area focus includes:

- Neck
- Shoulders
- Upper and lower back
- Hips
- Knees
- Full body

The sharpest initial positioning is:

> Desk workers and mobility beginners who regularly feel stiff after sitting.

This creates clear moments in which the app is useful:

- Before starting work
- During a desk break
- After a long workday
- After driving
- After a flight
- Before bed

## Market and Language

Raha Move will initially focus on Saudi Arabia and the wider MENA region.

Arabic is a first-class product language rather than a secondary translation. English may be offered alongside Arabic as part of a bilingual experience.

An Arabic-first experience includes:

- Natural Arabic copy and guidance
- Proper right-to-left interface design
- Familiar, non-technical movement language
- Culturally appropriate visual demonstrations
- Desk and driving routines relevant to local daily life
- Potential Ramadan-aware timing, intensity, and reminders

A possible Arabic product promise is:

> روتين مناسب لجسمك ووقتك اليوم

Meaning: a routine suited to your body and your time today.

## Brand Direction

The name Raha naturally communicates comfort, ease, and relief.

Raha Move should feel:

- Calm
- Warm
- Reassuring
- Beginner-friendly
- Credible without being clinical
- Encouraging without pressure or guilt
- Focused on feeling better rather than achieving extreme flexibility

The brand should sit between clinical physiotherapy and intense fitness.

> Movement should feel approachable, not intimidating.

## Core Daily Experience

The daily experience follows a simple sequence:

1. Ask how the user's body feels.
2. Ask what outcome they want today.
3. Ask which areas need attention.
4. Ask how much time is available.
5. Ask which movement positions are suitable.
6. Recommend a short routine.
7. Explain why the routine was selected.
8. Guide the user through the routine.
9. Ask how the user feels afterward.
10. Record progress and provide gentle encouragement.

Example recommendation explanation:

> We chose this seven-minute routine because you have been sitting, your neck and shoulders feel stiff, and you want something gentle without using the floor.

The explanation is an important trust-building feature and product differentiator.

## Initial Recommendation Inputs

The initial recommendation engine may combine:

```text
Body state
+ desired outcome
+ target areas
+ available time
+ movement position
+ difficulty and preferences
= recommended routine
```

Examples:

- Stiff, neck and shoulders, five minutes, seated: gentle desk reset
- Low energy, full body, ten minutes, standing: energizing mobility flow
- Tense, hips and lower back, ten minutes, floor available: slow evening release
- Knee sensitivity, standing only: a suitable low-impact option

Users should be able to reject or refine a recommendation:

- Too easy
- Too difficult
- I cannot use this position
- This area feels uncomfortable
- Show me something else

These responses can improve later recommendations.

## MVP Product Scope

The focused first version may include:

- Arabic and English setup
- Guest access or simple authentication
- A daily body check-in
- Personalized routine recommendations
- A clear explanation of why a routine was chosen
- Neck, shoulder, back, hip, knee, and full-body routines
- Three-, five-, ten-, and fifteen-minute options
- Seated, standing, and floor-based options
- Clear movement demonstrations
- A focused routine player with timers
- Before-and-after feeling feedback
- Completion history
- Basic points, streaks, weekly goals, and badges
- Contextual benefit messages
- Saved and repeatable routines
- Gentle reminders
- Local caching for reliable playback

The first release should avoid unnecessary complexity such as social feeds, competitive leaderboards, advanced assessments, or an overly large set of programs.

## Gamification

Gamification should encourage consistency, body awareness, and safe participation. It should not reward pain tolerance, extreme range of motion, or competition over flexibility.

### Progress dimensions

Raha Move may track:

- Consistency: how regularly the user moves
- Variety: which body areas receive attention
- Well-being: how the user feels before and after routines

### Reward system

Potential mechanics include:

- Movement streaks
- Flexible streak protection or recovery days
- Weekly movement goals
- Total minutes moved
- Routines completed
- Body-area milestones
- Achievement badges
- Gentle challenges
- Personalized weekly recaps

Example badges:

- First Step: complete the first routine
- Desk Reset: complete five desk routines
- Full-Body Explorer: move all major body areas
- Consistency Builder: move three times per week for a month
- Morning Mover: complete five morning routines
- Recovery Week: complete three gentle recovery sessions

Missing a day should not feel like failure. A recovery token or Raha Day could preserve a streak while respecting rest.

### Before-and-after feedback

After a routine, the user may answer:

- Much better
- A little better
- About the same
- Less comfortable

This makes progress visible even when physical flexibility changes slowly.

### Benefit messages

The app may show encouraging, carefully worded benefits as users build a habit.

Examples:

> You moved for 25 minutes this week. Short, regular movement breaks can help reduce the stiffness associated with prolonged sitting.

> You completed three shoulder routines this week. Consistent mobility practice can make everyday reaching and upper-body movement feel more comfortable.

> You moved your hips on four different days. Regular practice is often more useful than doing one long session occasionally.

Messages should use language such as "may help," "can support," and "many people notice." They should not promise medical outcomes or claim the app has fixed a condition.

The app should distinguish:

- Immediate feedback: how the user reports feeling after a routine
- Habit progress: how consistently the user has moved over time

### Body-area visualization

A friendly body map may become more active or colorful as users complete routines for different areas. It represents attention and movement rather than diagnosis or health status.

## Exercise Footage and Content

Raha Move plans to use licensed exercise footage from Vital Animations and may add content from other providers later.

Vital Animations supplies:

- High-resolution exercise animations
- Structured JSON metadata
- Exercise identifiers
- Names and classifications
- Body-part and muscle information
- Equipment and difficulty information
- Descriptions and instructions

The provider's movement demonstrations are treated as the approved source content. Raha Move does not need to overload the exercise player with detailed written instructions when the animation already demonstrates the movement clearly.

A typical player may show only:

- Exercise name
- Animation
- Timer or repetition count
- A short cue, when useful
- Pause, skip, previous, and next controls

A simple routine-level message may remind users to move within a comfortable range and stop if they feel sharp pain.

### Free50 test package

The downloaded Free50 test package contains:

- 50 MP4 files
- 50 matching JSON records
- Correct one-to-one matching between JSON identifiers and video filenames
- Approximately 194 MB of video
- H.264 video at 30 frames per second
- Primarily square 1080p footage, with a small number of other square resolutions
- An average clip duration of approximately 5.6 seconds

The sample is primarily gym content:

- 40 strength exercises
- 9 cardio exercises
- 1 plyometric exercise
- 28 beginner exercises
- 20 intermediate exercises
- 2 advanced exercises

This limitation is expected because the free package is only being used to test importing, playback, metadata, caching, and the application experience. The relevant mobility and stretching content can be purchased later.

### Source-independent content model

Raha Move must not use a footage provider's ID or filename as its permanent exercise identity.

The normalized content model separates:

- Raha Move's internal exercise ID
- The source provider's exercise ID
- Provider and license information
- Exercise content and classification
- One or more media assets
- Raha-specific recommendation and gamification metadata

This enables Raha Move to:

- Use content from multiple websites
- Replace footage without breaking saved routines
- Preserve progress and analytics if media changes
- Support different characters or demonstrations
- Track the origin of every asset
- Keep provider license information organized

Provider JSON remains import data. The mobile app consumes normalized Raha Move records.

## Future Warm-Up Expansion

Warm-ups are a natural future product category that can reuse the recommendation engine, exercise library, routine player, progress tracking, and gamification system.

Potential warm-up categories include:

- Chest workouts
- Back workouts
- Shoulder workouts
- Leg workouts
- Full-body gym sessions
- Football
- Running
- Padel
- Tennis
- Cycling
- Long walks

Warm-up selection may combine:

```text
Activity
+ body area
+ intensity
+ available time
+ available equipment
= recommended warm-up
```

Warm-ups should be clearly separated from general stretching because they have a different purpose. Pre-activity routines will generally emphasize controlled, dynamic movement.

## Roadmap

### Phase 1: Everyday mobility

- Daily check-in and recommendation
- Short routines for common stiffness
- Arabic and English guidance
- Routine player
- Before-and-after feedback
- Completion tracking
- Basic points, goals, streaks, and badges
- Contextual benefit messages

### Phase 2: Deeper motivation

- Body-area journey
- Weekly recaps
- Personalized challenges
- Adaptive difficulty
- Recommendations informed by user feedback
- Optional social or family challenges if research supports them

### Phase 3: Activity preparation

- Gym warm-ups by workout type
- Football, running, padel, and cycling warm-ups
- Pre-activity and post-activity guidance
- Broader exercise and media-provider support

## Product Hypothesis

The primary product hypothesis is:

> When people feel stiff, they will complete movement routines more consistently if the app chooses a short, relevant routine and clearly explains the choice.

The initial product should measure:

- Check-in completion
- Recommendation acceptance
- Routine starts
- Routine completion
- Requests for alternatives
- Before-and-after feedback
- Repeat usage
- Weekly movement consistency

## Technical Direction

Flutter is the recommended mobile framework because it supports a shared iOS and Android codebase, Arabic and RTL design, smooth interactive experiences, video playback, and the developer's existing expertise.

The detailed technical architecture, generated-code strategy, directory structure, offline behavior, and normalized JSON model are documented in [project-structure.md](project-structure.md).

