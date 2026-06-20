# Golden Rule — Feature Completion

> A feature is not done because its happy path exists. It is done when the related states, recovery paths, device modes, customization points, documentation, and failure behavior make it genuinely useful without creating frustration.

Before calling anything complete, ask:

1. What happens on a small screen, touch device, resized window, or unusual UI scale?
2. Can the user recover if this choice hides, moves, or breaks the interface?
3. Does it cooperate with themes, animation settings, cleanup, config loading, and older API calls?
4. Can library users customize the visible asset or behavior when a fixed default would be limiting?
5. Are loading, empty, unavailable, error, cancel, timeout, and success states handled?
6. Is the feature documented with a working example and an explicit limitation if one remains?
7. Did we test the feature together with the features it affects—not only by itself?

## Definition of truly done

- The interaction works with mouse and touch where applicable.
- The layout remains navigable at supported viewport sizes and scales.
- Risky visual changes have a recovery path.
- Third-party actions explain their source and require confirmation when appropriate.
- Runtime connections and temporary state are cleaned up.
- Compatibility entrypoints stay synchronized.
- The implementation passes syntax checks and the release test matrix.

This rule is the gate for every release. Never label a feature “done” merely because code for it exists.
