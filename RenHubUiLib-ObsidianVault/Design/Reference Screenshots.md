# Reference Screenshots

These screenshots record the V6.1 problems that directly shaped the V6.2 work. They are kept beside the design notes so future changes can be checked against real failure cases instead of memory.

## Color preview overlapping the sliders

![[References/v6.1-color-picker-overlap.png]]

### What was wrong

The expanded color preview was positioned relative to the whole picker container, so it occupied the same vertical space as the saturation slider. The controls technically existed, but their hierarchy and hit areas fought each other.

### V6.2 completion

- The compact header keeps a small, always-visible color swatch.
- The expanded editor gives hue, saturation, and value their own uninterrupted rows.
- The full-width preview sits below all three sliders.
- Preview text automatically changes contrast for readability.
- Clicking the preview copies the hex value when clipboard support is available.

This follows the [[Golden Rule - Feature Completion]]: fixing the overlap also required finishing readability, feedback, and interaction behavior.

## Small-window settings becoming unreachable

![[References/v6.1-small-window-settings.png]]

### What was wrong

The layout reacted to the raw Roblox viewport while UI scaling changed the effective space available to the library. At narrow widths or large scales, optional chrome kept its space while the settings content became difficult or impossible to navigate.

### V6.2 completion

- Breakpoints use the effective viewport after UI scale.
- Every page has active vertical scrolling and touch-friendly momentum.
- Compact layouts preserve navigation and content before decorative elements.
- Search and the profile card yield progressively when vertical room is scarce.
- The active tab name remains visible in the top bar when tab labels collapse.
- Window sizing and dragging keep a recoverable edge on-screen.
- Scale changes have a ten-second recovery period unless explicitly kept.

See [[Responsive Design]] for the full behavior contract and test matrix.
