# Feature Completion Checklist

Use this checklist before every commit that adds or changes user-facing behavior.

## Interaction

- [ ] Mouse path works.
- [ ] Touch path works or is explicitly unavailable with a reason.
- [ ] Keyboard path works where relevant.
- [ ] Hover, pressed, selected, disabled, loading, and error feedback are coherent.
- [ ] Repeated use does not duplicate events or stale UI.

## Layout

- [ ] Desktop at default size.
- [ ] Narrow desktop window.
- [ ] Tablet portrait and landscape.
- [ ] Phone portrait and landscape.
- [ ] Minimum and maximum supported UI scale.
- [ ] Long labels, many tabs, and tall settings pages remain navigable.

## Recovery and safety

- [ ] A risky setting has reset/revert behavior.
- [ ] The window cannot become permanently unreachable.
- [ ] Remote integrations identify their source, confirm intent, and report failures.
- [ ] Cleanup cancels temporary state and disconnects owned events.

## API and compatibility

- [ ] Existing calls keep working.
- [ ] New options have sensible defaults.
- [ ] Visible assets support custom IDs where fixed branding is not required.
- [ ] `RenLib.lua`, `RenLibBêta.lua`, and `RenLibTesting.lua` are synchronized.

## Handoff

- [ ] README example updated.
- [ ] Showcase exercises the changed behavior.
- [ ] Release note documents decisions and limitations.
- [ ] Luau syntax validation passes.

See [[../Golden Rule - Feature Completion]].

## V6.3 harmony checks

- [ ] Every preset keeps readable text, icons, strokes, hover states, and gradients in Solid mode.
- [ ] Every preset remains readable in Frosted mode over both bright and dark Roblox scenes.
- [ ] Frost intensity is capped on mobile and the effect disables while minimized.
- [ ] Unload removes the managed blur effect.
- [ ] Dashboard hero and cards collapse into one readable column on phone-sized viewports.
- [ ] Live clock stops updating after cleanup because its managed connection is disconnected.
- [ ] Nested controls expand their parent when dropdowns and color pickers open.
- [ ] Searching for a nested control keeps its parent visible.
- [ ] Multi-select accepts both arrays and keyed selection maps.
- [ ] Multi-select summaries remain useful with zero, one, two, and many selected options.
- [ ] Navigation category labels disappear in compact mode without leaving dead spacing.
- [ ] Reference-led work satisfies [[../Golden Rule - Transform Inspiration]].
