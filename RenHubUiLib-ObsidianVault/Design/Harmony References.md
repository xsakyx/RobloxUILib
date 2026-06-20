# Harmony References

These references shaped the V6.3 Harmony release. They are evidence for design principles, not templates to copy.

## Prism Frost

![[References/reference-prism-frost-theme.png]]

Learned principles:

- Light themes need dark, confident type rather than washed-out gray.
- Warm and cool accents can coexist when the background remains quiet.
- Sidebar, top bar, cards, and controls need different material depths.

RenLib result: the original **Prism Frost** palette with three-stop blue, warm-light, and ice accents.

## Frosted material

![[References/reference-frosted-material.png]]

Learned principles:

- Blur is useful only when foreground contrast remains stable.
- Material must have a performance fallback and cleanup lifecycle.
- Solid and frosted modes should share the same component hierarchy.

RenLib result: an optional **Frosted** material mode, mobile-capped intensity, live switching, minimize awareness, and deterministic cleanup.

## Dashboard composition

![[References/reference-dashboard-layout.png]]

Learned principles:

- A dashboard needs a strong orientation area before its cards.
- Live identity, time, system health, and quick actions belong at different levels.
- Cards must collapse into one column without losing reading order.

RenLib result: `Window:CreateDashboard()` with a responsive identity hero, live clock, cards, metrics, actions, and avatar customization.

## Nested controls

![[References/reference-nested-controls.png]]

Learned principles:

- Add-ons should look owned by their parent instead of like unrelated rows.
- Nested height must react when a dropdown or color editor expands.
- Multi-select needs visible selections, not only a number.

RenLib result: `control:AddNested(child)`, nested surface recalculation, and `CreateMultiDropdown()` with named selection summaries and check states.

## Moss and velvet directions

![[References/reference-moss-theme.png]]

![[References/reference-velvet-theme.png]]

RenLib translates the forest direction into **Moss Archive** and the pink-coffee direction into **Velvet Latte**. The names, values, three-stop gradients, and component behavior are RenLib's own.

See [[Golden Rule - Transform Inspiration]] and [[Visual System]].
