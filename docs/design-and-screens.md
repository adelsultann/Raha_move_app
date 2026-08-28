# Raha Move Design and Screens

Related visual foundations:

- [design-system.md](design-system.md) defines the approved Calm Movement palette and Thmanyah typography direction.

## Design Objective

Raha Move should make daily movement feel calm, easy, personal, and approachable.

The main interface should quickly answer:

> What movement is right for me today?

The experience should not resemble a crowded workout library or an intense gym application. The recommendation journey is the heart of the design.

## Design Principles

1. Keep the main decision simple.
2. Show one clear primary action per screen.
3. Use reassuring and non-technical language.
4. Explain recommendations without overwhelming the user.
5. Keep routine playback focused and distraction-free.
6. Make progress encouraging rather than competitive.
7. Treat Arabic RTL and English LTR as equal design modes.
8. Let exercise footage carry most of the movement demonstration.
9. Use animation gently and purposefully.
10. Avoid visual or written claims that imply medical diagnosis.

## Visual Personality

Raha Move should feel:

- Warm and reassuring
- Spacious and uncluttered
- Beginner-friendly
- Credible without looking clinical
- Motivating without pressure
- Modern without using an aggressive fitness aesthetic

### Initial visual direction

- Soft warm backgrounds instead of harsh pure white
- Deep green or teal as the primary brand color
- Mint or sage for progress and selected states
- Warm sand as a supporting neutral
- Coral or amber used sparingly for rewards and highlights
- Rounded cards and controls
- Large, readable typography
- High contrast for primary text and actions
- Gentle transitions and completion animations

Avoid the common black-and-neon gym appearance.

Exact color tokens, typography, usage guidance, accessibility validation, and font-license notes are maintained in [design-system.md](design-system.md).

## Primary Navigation

The proposed bottom navigation has four destinations:

1. Today
2. Explore
3. Progress
4. Profile

Possible Arabic labels:

1. اليوم
2. استكشف
3. تقدّمك
4. حسابي

The precise Arabic voice and wording will be refined when the brand tone is finalized.

The routine player opens as a focused full-screen experience above the normal bottom navigation.

## Core Daily Flow

```text
Open app
  -> Today
  -> Daily check-in
  -> Recommended routine
  -> Routine player
  -> Post-routine feedback
  -> Points and progress
  -> Today
```

Users may also repeat a recent routine or explore routines manually.

## Essential First Prototype

The first clickable prototype will focus on one complete experience:

1. Language selection
2. Today screen
3. Five-step daily check-in
4. Recommendation screen
5. Routine player
6. Completion and feedback
7. Updated progress

This prototype validates whether the central journey feels effortless, clear, reassuring, and useful before designing subscriptions, a large content library, or future warm-ups.

## Screen Specifications

### 1. Splash and initialization

Purpose:

- Display the Raha Move identity
- Load the saved language
- Restore session state
- Prepare locally cached content
- Determine whether onboarding is needed

The splash screen should be brief and should not become a long promotional experience.

### 2. Language selection

The first meaningful screen presents Arabic and English with equal visual importance.

```text
Welcome to Raha Move
مرحباً بك في راحة موف

[ العربية ]
[ English ]
```

Selecting Arabic immediately switches the full layout into RTL mode.

### 3. Introductory onboarding

Use no more than three concise pages.

#### Page 1: A routine chosen for you

> Tell us how your body feels, and we'll suggest a suitable short routine.

#### Page 2: Move on your schedule

> Choose how much time you have, from a quick desk break to a longer mobility session.

#### Page 3: Build a comfortable habit

> Track your consistency, notice how you feel, and celebrate every movement.

Primary actions:

```text
[ Get started ]
[ I already have an account ]
```

Guest access should be considered to minimize initial friction.

### 4. Basic preferences

Collect only information that immediately improves the experience:

- General movement experience
- Preferred positions
- Reminder interest
- Optional movement limitations or preferences

Do not request height, weight, age, or extensive personal information unless the product genuinely uses it.

### 5. Today screen

The Today screen is the product's home and should emphasize the daily check-in.

Suggested hierarchy:

```text
Good morning, Adel

How does your body feel today?

[ Start today's check-in ]

Your weekly goal
● ● ● ○ ○
3 of 5 movement days

Continue
5-minute desk reset
[ Start again ]

A small benefit
Regular movement breaks can help you feel
less stiff after extended sitting.
```

Potential sections:

- Personalized greeting
- Primary daily check-in action
- Weekly goal progress
- Recommended, recent, or resumable routine
- Contextual benefit message
- Gentle streak or consistency message

The check-in action remains visually dominant.

### 6. Daily check-in

The preferred pattern is one question per screen, with a visible progress indicator such as `3 of 5`.

#### Question 1: How does your body feel?

Initial options:

- Comfortable
- A little stiff
- Very stiff
- Tired
- Tense

#### Question 2: What do you need today?

Initial options:

- Ease stiffness
- Move more freely
- Feel energized
- Relax
- Take a desk break

#### Question 3: Which areas need attention?

Use a selectable body illustration together with text labels:

- Neck
- Shoulders
- Upper back
- Lower back
- Hips
- Knees
- Full body

Multiple selection is allowed. The design may limit or guide selection if too many areas weaken the recommendation.

#### Question 4: How much time do you have?

- 3 minutes
- 5 minutes
- 10 minutes
- 15 minutes

#### Question 5: What works for you now?

- Seated
- Standing
- Floor
- Any position

The user should be able to move backward without losing earlier answers.

### 7. Recommendation screen

This is one of Raha Move's primary differentiating screens.

```text
Recommended for you

7-minute Neck & Shoulder Reset

Gentle • Seated • No equipment

Why this routine?
You mentioned neck and shoulder stiffness,
have 7 minutes, and prefer to stay seated.

[ Start routine ]

[ Choose another ]
```

Supporting information may include:

- Total duration
- Number of movements
- Difficulty
- Required position
- Required equipment
- Optional movement preview

The user should not be forced to inspect every movement before starting.

### 8. Routine preview

The routine preview may be a bottom sheet rather than a separate full page.

```text
Routine movements

1. Neck rotation             40 sec
2. Shoulder circles          40 sec
3. Seated upper-back reach   50 sec
4. Chest opener              40 sec

[ Start ]
```

The preview may allow a user to flag a movement they cannot perform and request an alternative.

### 9. Routine player

The routine player should be focused and distraction-free.

```text
2 of 6                         Pause

          Exercise animation

        Seated shoulder circles

               00:24

Move slowly and breathe comfortably.

[ Previous ]  [ Pause ]  [ Skip ]

Up next: Seated upper-back reach
```

Required behavior:

- Loop the exercise animation
- Display a large timer or repetition count
- Preload the next video
- Allow pause, previous, next, and skip
- Provide optional sound or vibration at transitions
- Pause appropriately when the app is backgrounded
- Keep the screen awake during an active routine
- Allow audio guidance to be muted if audio is later added
- Show routine progress without creating urgency

Do not show advertisements, unrelated navigation, streak pressure, or excessive rewards during a routine.

The footage demonstrates the movement, so surrounding instructions should remain minimal. A short cue can be shown only when useful.

### 10. Completion and feedback

The completion screen should be rewarding but calm.

```text
Nice work — you moved for 7 minutes

How does your body feel now?

[ Much better ]
[ A little better ]
[ About the same ]
[ Less comfortable ]

+20 movement points
3-day consistency streak

[ Done ]
```

If the user selects "Less comfortable," the screen should acknowledge the feedback and avoid an overly celebratory response. That feedback should inform future recommendations.

### 11. Reward moment

Subtle celebration may be used when a user:

- Completes the first routine
- Reaches a weekly goal
- Earns a badge
- Reaches a consistency milestone

Combine rewards into one clear summary instead of showing multiple consecutive pop-ups.

### 12. Explore screen

Explore is for users who want to choose manually.

Potential categories:

- Desk breaks
- Neck and shoulders
- Lower back
- Hips
- Knees
- Full body
- Morning mobility
- Evening relaxation
- Quick three-minute routines
- Future warm-ups

Potential filters:

- Duration
- Body area
- Position
- Difficulty
- Equipment

Use routine cards rather than presenting a large exercise encyclopedia. The product's primary unit is a guided routine.

### 13. Routine details

The details page may include:

- Routine name
- Short intended-benefit description
- Duration
- Difficulty
- Position
- Equipment
- Exercise count
- Movement preview
- Save action
- Start action

Benefit descriptions should not guarantee medical outcomes.

### 14. Progress screen

The Progress screen should emphasize encouraging evidence rather than performance pressure.

```text
Your movement this week

4 movement days
32 minutes
6 routines completed

How you felt afterward
5 of 6 sessions felt better

Areas you moved
Neck • Shoulders • Hips

Latest achievement
Desk Reset — Level 2
```

Potential sections:

- Weekly goal
- Movement days
- Minutes moved
- Sessions completed
- Before-and-after trend
- Body-area visualization
- Badges
- Recent history

Avoid a single body score that could appear medically authoritative.

### 15. Achievements

Badge groups may include:

- Getting started
- Consistency
- Routine exploration
- Desk movement
- Morning and evening habits
- Body-area variety
- Time milestones

Locked achievements should invite exploration without making users feel behind.

### 16. Profile and settings

Potential settings:

- Language
- Weekly goal
- Reminder schedule
- Sound and vibration
- Download and data preferences
- Accessibility
- Saved routines
- Subscription
- Account management
- Privacy and terms
- Help and feedback

## Future Warm-Up Flow

Warm-ups should be visually and conceptually separate from everyday stretching and mobility.

### Activity selection

```text
What are you preparing for?

[ Gym workout ]
[ Football ]
[ Running ]
[ Padel ]
[ Cycling ]
```

### Gym focus

```text
What are you training today?

[ Chest ]
[ Back ]
[ Shoulders ]
[ Legs ]
[ Full body ]
```

Example explanation:

> Selected to prepare your shoulders, upper back, and chest for today's chest workout.

The warm-up experience reuses the existing recommendation, routine-details, playback, completion, and progress components.

## Prototype Success Questions

The essential prototype should help answer:

- Can a new user understand Raha Move's purpose immediately?
- Can the user finish the check-in without confusion or fatigue?
- Does the recommendation feel relevant and trustworthy?
- Is the explanation clear without being too detailed?
- Can a beginner follow the routine player without additional help?
- Does the completion experience encourage another session?
- Does Arabic feel native rather than translated?
- Does the full flow work equally well in RTL and LTR layouts?

## Related Documentation

- Product vision, audience, content, gamification, and roadmap: [product-brief.md](product-brief.md)
- Flutter architecture and technical structure: [project-structure.md](project-structure.md)
