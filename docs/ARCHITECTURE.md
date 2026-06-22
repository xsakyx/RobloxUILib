# RenLib V7 architecture

RenLib keeps one downloadable `RenLib.lua` runtime artifact so existing `loadstring(game:HttpGet(...))` integrations remain simple. Inside that artifact, stateful systems have explicit owners and public transition methods.

## Navigation invariant

`Window:SelectTab(tab, options)` is the only function that changes which page is visible.

- `Tab:Activate()` delegates to it.
- `Tab:Deactivate()` delegates to it when the tab is active.
- Overview and Settings use the same tab objects as user tabs.
- Search results request a tab change through it.
- Every transition updates active state, page visibility, title text, the shared navigation selection, and listeners together.

Do not add direct `Page.Visible` writes outside `Window:SelectTab`.

## Search invariant

Search is an index and focus layer, not a layout owner.

- It never hides tabs, sections, controls, categories, or pages.
- Matches receive a dedicated `RenSearchHighlight` stroke.
- Clearing search destroys only search-owned strokes.
- Enter cycles results through `Window:FocusSearchResult()`.
- Newly-created controls are indexed when a query is already active.

## Component lifecycle

Every component returned by a section has a shared lifecycle:

- `SetVisible`
- `SetLocked`, `Lock`, and `Unlock`
- `SetLoading`
- `SetTooltip`
- `Destroy`

Feature-specific methods are added on top of that shared controller.

## Addon lifecycle

Registered addons move through `Init -> Start -> Stop -> Unload`. RenLib stops and unloads addons during session cleanup, before UI objects and connections are released.

## Compatibility boundary

`RenLib.lua`, `RenLibBêta.lua`, and `RenLibTesting.lua` are identical distribution artifacts. The Rayfield adapter remains a compatibility facade; new framework work should target the native section APIs.
