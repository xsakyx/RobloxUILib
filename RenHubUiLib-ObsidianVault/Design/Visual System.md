# Visual System

## Direction

RenLib uses a layered interface with restrained borders, rounded surfaces, readable hierarchy, and controlled accent movement. It supports both light and dark palettes without changing the component contract. Luna and Starlight remain references for finish and density; RenLib keeps an original identity and implementation.

## Surface hierarchy

1. `Main` — window foundation.
2. `Secondary` — sidebar and section cards.
3. `Surface` — controls and profile card.
4. `SurfaceAlt` — tracks, avatar backing, and secondary interactive states.
5. `Hover` and `Click` — transient feedback.

## Accent use

Accent color is reserved for selection, focus, progress, and meaningful state. Gradients can use `Accent`, `Accent2`, and `Accent3`; they should not flood every surface.

## Details that create harmony

- Real image icons instead of inconsistent text symbols where an asset exists.
- One icon slot and one text slot—never overlap them.
- Supporting descriptions only when they clarify consequence or source.
- Small accent rails establish hierarchy without visual noise.
- Avatar, title, subtitle, and navigation use the same spacing rhythm.

## Theme presets

Midnight, Nebula, Celestial, Rose, Aurora, Ember, Prism Frost, Moss Archive, and Velvet Latte provide the complete token set. `Starlight` remains only as a hidden V6.2 compatibility alias for `Celestial`.

## Harmony hierarchy

V6.3 uses five intentional depths:

1. World — the Roblox scene behind the interface.
2. Window — the main shell and sidebar.
3. Section — a titled organizational card.
4. Inner surface — the recessed area that owns related controls.
5. Control — an interactive row with its own hover, focus, active, and nested states.

Do not flatten these into one background plus divider lines. Each depth should remain legible in every preset and both material modes.

## Materials

- **Solid** is the dependable default with opaque surfaces.
- **Frosted** increases surface transparency and applies a managed world blur.
- Mobile intensity is capped to reduce visual and performance cost.
- Minimize disables the blur; unload destroys it.
- Material is behavior, not a theme. Every palette must work in both modes.

## Accent gradients

Accent gradients may use three coordinated colors. They belong on small rails, active navigation, fills, and primary actions—not every surface. The gradient should communicate emphasis, not compensate for weak hierarchy.

## V6.3 palettes

- **Prism Frost** — light ice surfaces with blue, warm light, and pale sky accents.
- **Moss Archive** — charcoal forest surfaces with sage and parchment.
- **Velvet Latte** — deep indigo with rose, lilac, and blue light.

Their reference reasoning is recorded in [[Harmony References]].
