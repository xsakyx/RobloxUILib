# Responsive Design

## Core rule

Layout decisions use the **effective viewport**: physical viewport divided by the selected UI scale. This prevents a visually scaled interface from overflowing even when its raw dimensions appear valid.

## Modes

- **Desktop** — two content columns and labeled sidebar navigation.
- **Tablet** — single content column, compact sidebar, touch-sized controls.
- **Phone** — viewport-fitting shell, compact navigation, visible active-tab title, and persistent vertical page scrolling.

## Degradation order

When vertical space becomes scarce:

1. The profile card hides before navigation is sacrificed.
2. The search row becomes denser, then hides at extreme heights.
3. Content keeps a scrollable page instead of being clipped.
4. The window retains a recoverable edge after dragging.

## Scale safety

The built-in scale control previews changes for ten seconds. **Keep** commits the size; **Revert** restores it immediately; timeout also restores it. Layout is recalculated and recentered for every preview and recovery.

## QA matrix

Test 60%, 100%, and 150% scale at widths around 360, 620, 900, and desktop size. Repeat with a tall settings page and an expanded dropdown/color picker.
