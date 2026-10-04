# Raha Move Design System

## Purpose

This document defines the initial visual foundation for Raha Move. It covers the approved color direction and typography choices for Arabic and English interfaces.

The system should communicate calm movement, comfort, trust, and gentle motivation. It should not resemble a clinical medical product or an aggressive gym application.

## Visual Direction

The selected direction is **Calm Movement**.

It combines:

- Bright mint for movement, progress, and primary actions
- Deep mint for selected and encouraging states
- Dark navy for a calm, focused application background
- Layered navy surfaces for clear hierarchy without visual noise
- Cool white and muted blue-gray text for readability

The same visual system must work in Arabic RTL and English LTR layouts.

## Core Color Palette

| Token | Name | Hex | Primary usage |
|---|---|---:|---|
| `primary` | Bright Mint | `#28BD91` | Main buttons, selected navigation, key actions |
| `onPrimary` | Deep Navy | `#080F20` | Text and icons on bright mint controls |
| `primaryContainer` | Deep Mint | `#123D3B` | Selected cards, icon containers, soft highlights |
| `onPrimaryContainer` | Light Mint | `#86E5C7` | Text and icons on deep mint containers |
| `background` | Deep Navy | `#080F20` | Main application background |
| `surface` | Navy Surface | `#11192C` | Cards, sheets, dialogs, navigation |
| `surfaceRaised` | Raised Navy | `#1A263A` | Snackbars and raised surface hierarchy |
| `surfaceArtwork` | Artwork Navy | `#24374A` | Illustration and media placeholders |
| `textPrimary` | Cool White | `#F5F7FC` | Headings and primary body text |
| `textSecondary` | Blue Gray | `#A5B2C8` | Supporting text and secondary information |
| `outline` | Slate Outline | `#4E607A` | Input borders and prominent outlines |
| `outlineSubtle` | Subtle Navy | `#2D3B50` | Dividers, inactive indicators, disabled controls |
| `error` | Soft Error | `#FFB4AB` | Error text and destructive actions |

The main brand combination is:

```text
Bright Mint  #28BD91
Deep Mint    #123D3B
Deep Navy    #080F20
Navy Surface #11192C
```

Navy surfaces should dominate. Mint identifies actions, selection, and progress; cool white and blue gray carry the content hierarchy.

## Suggested Color Proportions

- 60% deep navy background
- 25% layered navy surfaces
- 10% cool white, blue-gray text, icons, and borders
- 5% mint actions and selected states

If mint appears throughout the interface, selected states and primary actions lose emphasis.

## Semantic Colors

Semantic colors communicate system meaning independently from the brand palette.

| Token | Meaning | Hex |
|---|---|---:|
| `success` | Successful completion or confirmation | `#28BD91` |
| `information` | Neutral informational state | `#3978A8` |
| `warning` | Caution or attention required | `#C78324` |
| `error` | Error, failure, or destructive action | `#FFB4AB` |

Red should not represent ordinary stiffness or unselected body areas. Doing so would make the experience feel unnecessarily alarming or medical.

## Color Application

### Today screen

- Deep navy page background
- Bright mint primary check-in button
- Navy routine cards
- Deep mint weekly-goal area
- Cool white primary text

### Check-in selections

Unselected state:

- Navy surface
- Slate outline
- Cool white text

Selected state:

- Deep mint background
- Bright mint border
- Light mint icon and text

### Recommendation screen

- Deep navy background
- Navy recommendation card
- Cool white title and bright mint primary action
- Deep mint explanation area
- Blue-gray supporting metadata

### Routine player

- Deep navy background that does not compete with the footage
- Cool white exercise title
- Bright mint timer and progress indicator
- Bright mint primary play or pause control
- Slate secondary controls

The exercise animation remains the visual focus.

### Completion screen

- Deep mint completion background or glow
- Light mint confirmation message
- Bright mint points and milestone details

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

The selected Arabic typeface is **Noto Sans Arabic**.

It is designed for digital screens, provides broad Arabic-script coverage, and remains readable at the application’s supported text scales.

Use Noto Sans Arabic for:

- Navigation labels
- Buttons
- Screen titles
- Check-in questions
- Routine and exercise names
- Timers
- Progress information
- Settings
- Body text

### English

The selected English typeface is **Manrope**. It pairs with Noto Sans Arabic in weight, density, and overall tone. Locale-aware theme construction applies Noto Sans Arabic to Arabic interfaces and Manrope to English interfaces, with the other family registered as fallback for mixed-language text.

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

Both font families are bundled so typography remains available offline. Preserve the upstream filenames and Open Font License files.

Asset location:

```text
assets/
└── fonts/
    ├── manrope/
    │   ├── Manrope[wght].ttf
    │   └── OFL.txt
    └── noto_sans_arabic/
        ├── NotoSansArabic[wdth,wght].ttf
        └── OFL.txt
```

Flutter registration:

```yaml
flutter:
  fonts:
    - family: Manrope
      fonts:
        - asset: assets/fonts/manrope/Manrope[wght].ttf
    - family: NotoSansArabic
      fonts:
        - asset: assets/fonts/noto_sans_arabic/NotoSansArabic[wdth,wght].ttf
```

## Font License Notes

Manrope and Noto Sans Arabic are distributed under the SIL Open Font License 1.1. Their license files are stored beside the bundled font binaries.

Project requirements:

- Preserve each original license in the application repository.
- Do not modify the font files.
- Do not rename the font files.
- Review the bundled OFL files before redistributing modified font software.

## Flutter Theme Organization

Semantic tokens are defined centrally rather than placing raw hex values throughout widgets.

Suggested organization:

```text
lib/app/theme/
├── app_colors.dart
├── app_typography.dart
└── app_theme.dart
```

Widgets use `Theme.of(context).colorScheme` and `textTheme` roles. `app_colors.dart` remains private to theme construction so future palette adjustments stay centralized.

The product offers Light, Dark, and Night appearances. All three use the same
semantic color roles and localized typography. Light uses a warm off-white
background, white surfaces, dark teal text, and a deeper green primary action.
Dark retains the approved navy and mint palette; Night uses darker navy surfaces.
The palette definitions live in `app_colors.dart`, and `app_theme.dart` applies
the selected palette to controls and surfaces.

## Related Documentation

- Product and brand direction: [product-brief.md](product-brief.md)
- Screen specifications: [design-and-screens.md](design-and-screens.md)
- Flutter architecture: [project-structure.md](project-structure.md)
