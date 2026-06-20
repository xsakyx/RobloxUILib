# Architecture

## Runtime model

RenLib is currently a single-file Luau library so executor users can load it from one raw GitHub URL. The single-file delivery format is intentional; organization comes from clear subsystems, APIs, documentation, and testable contracts rather than artificial line-count growth.

## Subsystems

- **Runtime ownership** — a new RenLib session unloads the previous session.
- **Utility layer** — instance construction, protected callbacks, animation, asset normalization, drag recovery, and theme registration.
- **Theme system** — live token registry plus gradient registry and six presets.
- **Window shell** — responsive sizing, navigation, search, profile surface, minimize/restore, and dialogs.
- **Components** — sections, inputs, buttons, toggles, sliders, dropdowns, key pickers, color controls, tabboxes, and informational blocks.
- **Persistence** — JSON configs and optional autoload when executor filesystem APIs exist.
- **Integrations** — explicit, confirmed third-party launch actions such as Infinite Yield.

## Source contract

`RenLib.lua` is canonical. `RenLibBêta.lua` and `RenLibTesting.lua` must be byte-identical before publishing. `Showcase.lua` is the interaction smoke test and public example.

## Reference policy

Luna and Starlight are visual and interaction references. RenLib uses an original implementation and keeps its public API stable. Reference repositories are studied for system-level lessons—density, navigation hierarchy, feedback, device behavior—not copied to inflate the codebase.

Related: [[../Golden Rule - Feature Completion]], [[Feature Completion Checklist]], [[../Design/Visual System]].
## V6.3 composition layers

- `ThemePresets` provides semantic color tokens including a third accent stop.
- `GradientRegistry` accepts any number of theme keys and rebuilds color sequences live.
- `MaterialRegistry` owns solid and frosted transparency for each registered surface.
- `SetMaterialMode` owns the Lighting blur lifecycle and synchronizes every registered surface.
- Tabs expose a responsive header offset used by the dashboard hero.
- Controllers can own a nested surface and reparent other controllers into it.
- Section and page layout updates remain the single source of truth for expanded heights.

The material registry and blur effect must always be cleared by `Unload()`.
