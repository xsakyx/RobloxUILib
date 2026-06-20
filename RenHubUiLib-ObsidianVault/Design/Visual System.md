# Visual System

## Direction

RenLib uses a dark, layered interface with restrained borders, rounded surfaces, readable hierarchy, and purple-to-blue accent movement. Luna and Starlight are references for finish and density; RenLib keeps an original identity and implementation.

## Surface hierarchy

1. `Main` — window foundation.
2. `Secondary` — sidebar and section cards.
3. `Surface` — controls and profile card.
4. `SurfaceAlt` — tracks, avatar backing, and secondary interactive states.
5. `Hover` and `Click` — transient feedback.

## Accent use

Accent color is reserved for selection, focus, progress, and meaningful state. Gradients use `Accent` to `Accent2`; they should not flood every surface.

## Details that create harmony

- Real image icons instead of inconsistent text symbols where an asset exists.
- One icon slot and one text slot—never overlap them.
- Supporting descriptions only when they clarify consequence or source.
- Small accent rails establish hierarchy without visual noise.
- Avatar, title, subtitle, and navigation use the same spacing rhythm.

## Theme presets

Midnight, Nebula, Starlight, Rose, Aurora, and Ember all provide the complete token set.
