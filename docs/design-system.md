# Raha Move Design System

## Purpose

This document defines the initial visual foundation for Raha Move. It covers the approved color direction and typography choices for Arabic and English interfaces.

The system should communicate calm movement, comfort, trust, and gentle motivation. It should not resemble a clinical medical product or an aggressive gym application.

## Visual Direction

The selected direction is **Calm Movement**.

It combines:

- Deep teal for trust, movement, and primary actions
- Soft mint for selected and encouraging states
- Warm ivory and white for calm, spacious surfaces
- Warm sand for natural visual variety
- Amber and coral for limited moments of reward and celebration
- Deep neutral text colors for readability

The same visual system must work in Arabic RTL and English LTR layouts.

## Core Color Palette

| Token | Name | Hex | Primary usage |
|---|---|---:|---|
| `primary` | Deep Teal | `#176B68` | Main buttons, selected navigation, key actions |
| `primaryDark` | Dark Teal | `#0E4F4D` | Pressed states, strong headings, dark accents |
| `primaryLight` | Soft Mint | `#CFE8E2` | Selected cards, progress areas, soft highlights |
| `background` | Warm Ivory | `#FAF8F2` | Main application background |
| `surface` | White | `#FFFFFF` | Cards, sheets, dialogs, elevated areas |
| `secondary` | Warm Sand | `#E9DCC8` | Category cards and gentle visual variety |
| `reward` | Warm Amber | `#E9A23B` | Points, badges, milestones, meaningful progress |
| `celebration` | Soft Coral | `#E67D68` | Occasional achievements and celebratory accents |
| `textPrimary` | Deep Charcoal | `#203332` | Headings and primary body text |
| `textSecondary` | Muted Slate | `#647674` | Supporting text and secondary information |
| `border` | Pale Gray-green | `#DDE5E2` | Dividers, outlines, input borders, disabled controls |

The main brand combination is:

```text
Deep Teal    #176B68
Soft Mint    #CFE8E2
Warm Ivory   #FAF8F2
Warm Amber   #E9A23B
```

Teal, mint, ivory, and white should dominate. Amber and coral are accent colors and should not become general interface colors.

## Suggested Color Proportions

- 60% warm ivory and white
- 25% teal and mint
- 10% neutral text, icons, and borders
- 5% amber or coral accents

If reward colors appear throughout the interface, they will stop feeling meaningful.

## Semantic Colors

Semantic colors communicate system meaning independently from the brand palette.

| Token | Meaning | Hex |
|---|---|---:|
| `success` | Successful completion or confirmation | `#2E7D61` |
| `information` | Neutral informational state | `#3978A8` |
| `warning` | Caution or attention required | `#C78324` |
| `error` | Error, failure, or destructive action | `#B94A48` |

Red should not represent ordinary stiffness or unselected body areas. Doing so would make the experience feel unnecessarily alarming or medical.

## Color Application

### Today screen

- Warm ivory page background
- Deep teal primary check-in button
- White routine cards
- Soft mint weekly-goal area
- Amber only for earned milestones
- Deep charcoal primary text

### Check-in selections

Unselected state:

- White surface
- Pale gray-green border
- Deep charcoal text

Selected state:

- Soft mint background
- Deep teal border
- Dark teal icon and text

### Recommendation screen

- Warm ivory background
- White recommendation card
- Deep teal title and primary action
- Soft mint explanation area
- Muted slate supporting metadata

### Routine player

- Neutral warm background that does not compete with the footage
- Deep charcoal exercise title
- Deep teal timer and progress indicator
- Deep teal primary play or pause control
- Pale neutral secondary controls
- Little or no amber during the routine

The exercise animation remains the visual focus.

### Completion screen

- Soft mint completion background or glow
- Deep teal confirmation message
- Warm amber points and milestone details
- Soft coral used only as a small celebratory accent

If the user reports feeling less comfortable, avoid a heavily celebratory color treatment.

## Accessibility and Validation

The proposed colors are an initial direction rather than a final accessibility certification.

Before implementation is finalized:

- Test all text and interactive-state combinations for WCAG contrast.
- Do not communicate state through color alone.
- Pair selected, warning, error, and completion states with icons or labels.
- Test the palette on common iOS and Android displays.
- Test video visibility against the routine-player background.
- Validate disabled controls separately from secondary controls.
- Recheck contrast after selecting final font weights and sizes.

## Typography Direction

### Arabic

The selected Arabic typeface is **Thmanyah Sans**.

It is the recommended family for the application interface because it is designed for digital screens and supports a contemporary Arabic-first identity.

Use Thmanyah Sans for:

- Navigation labels
- Buttons
- Screen titles
- Check-in questions
- Routine and exercise names
- Timers
- Progress information
- Settings
- Body text

Thmanyah also provides Serif Display and Serif Text families. Serif Display may be explored sparingly in marketing or large promotional statements, but the initial application should use Thmanyah Sans consistently.

### English

First test the Latin glyphs included with the downloaded Thmanyah digital family.

If the Latin typography does not provide the desired quality or personality, pair Thmanyah Sans with one of:

- Manrope
- Inter

The final English choice should visually match the Arabic family in weight, density, line height, and overall tone.

## Suggested Type Scale

The following values are starting points and should be validated in the prototype.

| Style | Suggested weight | Suggested size |
|---|---:|---:|
| Display or welcome heading | Bold | 30–34 |
| Screen title | Bold | 24–28 |
| Check-in question | Semibold | 22–24 |
| Section title | Semibold | 18–20 |
| Button label | Semibold | 16 |
| Body | Regular | 15–17 |
| Supporting text | Regular | 13–14 |
| Routine timer | Bold | 40–52 |

Arabic text may need slightly more line height than English, particularly for multi-line check-in questions and recommendation explanations.

## Font Assets

Download Thmanyah directly from the official source and preserve the filenames provided in the package.

Proposed asset location:

```text
assets/
└── fonts/
    └── thmanyah/
        ├── [official regular font filename]
        ├── [official medium font filename]
        ├── [official semibold font filename]
        └── [official bold font filename]
```

The exact files and supported weights will be recorded after the official package is downloaded and inspected.

Example Flutter registration, using placeholders until the actual filenames are known:

```yaml
flutter:
  fonts:
    - family: ThmanyahSans
      fonts:
        - asset: assets/fonts/thmanyah/[official-regular-file]
          weight: 400
        - asset: assets/fonts/thmanyah/[official-medium-file]
          weight: 500
        - asset: assets/fonts/thmanyah/[official-semibold-file]
          weight: 600
        - asset: assets/fonts/thmanyah/[official-bold-file]
          weight: 700
```

## Thmanyah License Notes

Thmanyah permits personal and commercial use in applications, websites, branding, print, and other design work, subject to its license.

Project requirements:

- Download the font from the official source.
- Preserve the original license with internal project records.
- Do not modify the font files.
- Do not rename the font files.
- Do not create a derivative font.
- Do not republish or offer the raw files for standalone download.
- Avoid committing the raw font files to a public repository.
- Do not suggest endorsement, sponsorship, or partnership by Thmanyah.

Official references:

- [Thmanyah font page](https://font.thmanyah.com/)
- [Thmanyah font usage and license guidance](https://ask.thmanyah.com/hc/en-001/articles/45993930027281-Thmanyah-Font-for-Everyone)

## Flutter Theme Organization

When implementation begins, define semantic tokens rather than placing raw hex values throughout widgets.

Suggested organization:

```text
lib/app/theme/
├── app_colors.dart
├── app_text_styles.dart
├── app_theme.dart
├── app_spacing.dart
├── app_radius.dart
└── app_motion.dart
```

Widgets should use theme roles such as `primary`, `surface`, and `textPrimary`. This keeps future palette adjustments manageable.

Dark mode is not yet defined. It should be designed as a separate semantic theme rather than mechanically inverting the light palette.

## Related Documentation

- Product and brand direction: [product-brief.md](product-brief.md)
- Screen specifications: [design-and-screens.md](design-and-screens.md)
- Flutter architecture: [project-structure.md](project-structure.md)

