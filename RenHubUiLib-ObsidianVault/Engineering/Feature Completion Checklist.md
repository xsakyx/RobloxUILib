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
