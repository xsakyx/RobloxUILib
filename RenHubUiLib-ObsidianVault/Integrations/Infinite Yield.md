# Infinite Yield Integration

RenLib’s settings page can launch Infinite Yield from the official EdgeIY repository.

- Repository: https://github.com/EdgeIY/infiniteyield
- Official source URL: `https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source`
- Official loader: `loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()`

## Completion behavior

- The launcher is enabled by default and can be disabled with `ShowInfiniteYield = false`.
- A confirmation dialog explains that current remote code will run.
- Missing `loadstring`, download errors, compile errors, and runtime errors produce visible feedback.
- The source is fetched only after confirmation.

This integration must always track the official URL rather than a copied repository version.
