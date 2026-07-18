# RenLib modular source

`RenLib.lua` and `RenLibBêta.lua` are generated compatibility bundles. Do not
hand-edit those bundles after this migration. Edit the matching feature fragment
under `Modules/`, then run:

```powershell
.\RenLibSource\Build-RenLib.ps1
```

The builder reads `modules.manifest` in order, assembles one executor-friendly
file, validates that it returns `Library`, optionally compiles it with
`luau-compile`, backs up the previous bundles, and only then replaces them.

## Architecture

- `00_runtime`: services, runtime state, capability discovery, constants.
- `05_capabilities`: safe wrappers for optional executor APIs.
- `10_utility`: instance creation, icon loading, animation and responsive helpers.
- `20_theme`: themes, gradients, materials and live color updates.
- `30_scaling`: DPI scaling and safe preview/revert behavior.
- `40_storage`: file-backed or virtual-memory configs and autoload state.
- `50_extensions`: options, addons, icon registry, relaunch helpers.
- `60_rayfield_compat`: the Rayfield compatibility adapter.
- `70_window_shell`: window, navigation, search and notifications.
- `80`–`91`: tabs and individual control families.
- `99_lifecycle`: unload, input binding and startup.

Fragments are intentionally bundled instead of fetched independently at runtime.
This keeps the public API modular for development while requiring only one HTTP
request and one compile operation on weak executors.

## Capability rule

No optional host API may be called directly by UI code. Storage, custom assets,
clipboard and request behavior must go through capability adapters and degrade to
an in-memory/no-op implementation. Host permissions that do not exist cannot be
recreated by Lua; the fallback must preserve the UI and report the limitation.

`RenLibLegacy.lua` is the last-known-working runtime fallback. Do not overwrite it
during normal builds.

## Storage behavior

When the executor provides working folder and file APIs, configs persist in
`RenLib/Configs`. If any required operation is missing or throws, the storage
adapter switches to `Memory` mode. All config controls still work, including
save/load/rename/delete/autoload, but the data lasts only for the current Roblox
client session. Lua cannot provide cross-restart persistence when the host denies
all persistent storage APIs.

The brand mark uses Roblox asset `84928996923191` directly. The source PNG remains
under `Assets/Brand` for future asset uploads; runtime code never downloads that
PNG or calls custom-asset filesystem APIs.
