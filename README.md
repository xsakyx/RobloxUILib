# RenLib V7.0 — Reliable UI Framework

RenLib is a responsive Roblox/Luau UI framework for desktop, tablet, and phone. V7 keeps the polished V6.7 interface, but replaces fragile cross-connected state with centralized navigation, non-destructive search, reusable framework controls, addons, tooltips, prompts, loading states, and a complete keybind manager.

```lua
local RenLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xsakyx/RobloxUILib/main/RenLib.lua"
))()

local Window = RenLib:CreateWindow({
    Name = "My Script",
    Icon = "1234567890", -- optional Roblox image ID
    EnableGlobalSearch = true,
})

local Main = Window:CreateTab({Name = "Main", Icon = "9080449299"})
local General = Main:CreateSection({Name = "General", Side = "Left"})

General:CreateToggle({
    Name = "Enabled",
    Flag = "Enabled",
    Default = true,
    Callback = function(value)
        print("Enabled:", value)
    end,
})
```

## What changed in V7.0

- `Window:SelectTab()` is the only authority allowed to select a page. Sidebar buttons, native Overview, Settings, search results, and public tab activation all use the same state transition.
- Search never changes the structural `Visible` state of tabs, pages, sections, or controls. It indexes matches, adds a dedicated accent outline, reports the result count, and cycles through results with Enter.
- Every returned control supports `SetLoading(true, message)` and optional mouse/touch `Tooltip` help.
- `Window:Prompt()` provides validated text input dialogs.
- `CreateGroup()` adds collapsible control groups that can contain normal controls, data controls, and nested groups.
- Added `CreateList`, `CreateTable`, `CreatePlayerList`, `CreateLogConsole`, and `CreateSkeleton`.
- Added a native keybind manager for reviewing, editing, and resetting registered shortcuts.
- Added lifecycle-managed addons through `RegisterAddon`, `EnableAddon`, `DisableAddon`, and `UnregisterAddon`.
- The icon catalog is public through `RenLib.Icons`, `RegisterIcon`, and `GetIcon`.
- `Showcase.lua` demonstrates every V7 framework family in one script.

## V6.7 visual foundations retained

- Every window receives a pinned native Overview below the profile and above UI Settings.
- Overview includes a confirmed **Relaunch RenCore** action that unloads RenLib before starting the official selector loader.
- The frosted sidebar is composited once, removing the dark doubled strip caused by overlapping translucent surfaces.
- The labelled `Pin` / `Auto` surface no longer overlaps the RenLib wordmark.
- Desktop search is centered inside the top bar; mobile search keeps its full-width responsive placement.
- Invalid `Icon = 0` values now fall back to the repository brand icon, including the minimized restore cube.
- Adapter-based scripts respect the autoloaded RenLib theme instead of overwriting it with a legacy hard-coded theme.

## V6.6 reliability foundations retained

- Layout, visibility, and hover/selection animations use independent channels, so one interaction cannot strand a tab, label, or profile card in the wrong sidebar state.
- The compact sidebar toggle stays under the pointer, while its expanded state becomes a labelled `Pin` / `Auto` button with clear hover feedback.
- Compact avatars are inset safely so their circular accent stroke is not clipped into flat lines.
- The shell and sidebar share a deliberate one-sided corner treatment: rounded outside, clean square seam inside.
- Saved configs are discoverable from a dropdown and can be loaded, renamed, deleted, or selected for autoload.
- Autoload values are prepared before controls are created, then applied as each flagged control registers.
- `CreateRayfieldAdapter()` provides a RenLib-owned compatibility bridge for migrating existing scripts without touching their gameplay logic.

## V6.5 motion foundations retained

### V6.5.2 patch

- Corrected the sibling-layer assignment: the tab container renders on layer 4 and the shared selection surface renders on layer 3.
- Active tab buttons no longer add a second translucent accent layer over their own label and icon.

- The brand mark and sidebar-mode icon use semantic text contrast: bright on dark themes and dark on light themes.
- The logo, wordmark, and mode toggle now share one collision-safe header instead of overlapping independent cards.
- Dynamic navigation eases between its 80 px compact rail and expanded state; labels fade with the geometry instead of snapping.
- One shared selection surface slides between tabs and Settings, including across category gaps and pinned navigation items.
- The root window owns the only outer corner treatment. Duplicate sidebar corners, the mismatched top accent rail, and nested glass corners were removed.
- UI scale is safely capped to 100–150%; old or invalid saved values are clamped to the new minimum.

## V6.4 clarity foundations retained

- Every semantic color is registered automatically, so theme changes cannot leave dark labels on dark surfaces or light icons on light surfaces.
- Frosted mode now uses window-local transparency, tint, grain, and edge treatment. It never creates a global Lighting blur or changes the game screen.
- Visible-width breakpoints force a safe one-column layout before controls can overlap.
- Navigation defaults to `Dynamic`; the header button pins or releases the full sidebar.
- Inactive tabs and chrome controls keep visible boundaries in both light and dark themes.
- Section depth no longer uses oversized shadow sprites, eliminating the gray title plates visible in Prism Frost.
- The dashboard hero keeps identity and context without copying a live time/date display.
- Each dark preset now has its own recognizable background family instead of sharing near-black chrome.
- The default brand mark is fetched from [`Assets/Brand/icon.txt`](./Assets/Brand/icon.txt), so the repository owner can replace it without editing RenLib.

## V6.2 foundations retained

- Color previews now live below the H/S/V tracks instead of drifting over them.
- Responsive sizing uses the physical visible width after UI scale, with scrollable compact pages and dense-height fallbacks.
- Scale changes use a ten-second preview with **Keep**, **Revert**, timeout recovery, and a 100% reset action.
- Window dragging preserves a recoverable edge so the interface cannot be permanently lost off-screen.
- Window, settings, tab, and button icons accept custom Roblox image IDs.
- The sidebar includes the local Roblox avatar/profile and supports custom profile images and text.
- Buttons support optional icons and descriptions.
- Settings include an optional confirmed launcher for the current official Infinite Yield source.
- Added `Aurora` and `Ember` alongside the existing theme presets.

- Live responsive reflow: two columns become one as the viewport narrows, including rotation and split-screen changes.
- Touch-sized sliders, dropdowns, color controls, draggable windows, and a floating mobile restore button.
- One active RenLib session. Loading RenLib again unloads the old session and disconnects its events.
- Cancellable animation system with reduced-motion and motion-speed controls.
- Nine live presets: `Midnight`, `Nebula`, `Celestial`, `Rose`, `Aurora`, `Ember`, `Prism Frost`, `Moss Archive`, and `Velvet Latte`.
- Search on desktop and mobile.
- Real JSON config save/load/rename/delete/autoload when filesystem APIs are available.
- Safe callbacks: an error in user code is reported without breaking the entire UI.
- Notifications with actions, progress, live updates, manual close, and timed close.
- Modal dialogs, maximize support, DPI scaling, and richer window controls.
- Shared component methods: `Lock`, `Unlock`, `SetLocked`, `SetVisible`, and `Destroy`.
- New controls: input, multiline input, paragraph, divider, key picker, image, warning box, dependency box, tabbox, and a functional HSV color picker.
- External launch actions remain confirmation-gated and unload the current RenLib session before relaunching RenCore.

## Window API

```lua
local Window = RenLib:CreateWindow({
    Name = "Control Center",
    Width = 860,
    Height = 580,
    DisplayOrder = 1000,
    Icon = "1234567890",
    SettingsIcon = "9876543210",
    ShowUserProfile = true,
    ProfileUserId = game.Players.LocalPlayer.UserId,
    ProfileSubtitle = "Ready",
    ShowInfiniteYield = true,
    EnableGlobalSearch = true,
    EnableSidebarResize = true,
    SidebarMode = "Dynamic", -- "Dynamic", "Expanded", or "Compact"
    MaterialMode = "Frosted", -- or "Solid"
    MaterialIntensity = 18, -- local glass transparency; never a screen blur
    BeforeRelaunch = function()
        -- Optional: stop script-owned loops/connections before RenCore restarts.
    end,
    OnDeviceChanged = function(mode)
        print(mode) -- "Desktop", "Tablet", or "Phone"
    end,
})

Window:SetTitle("New title")
Window:SetSearch("movement")
Window:FocusSearchResult(1)
Window:ClearSearch()
Window:SelectTab(Window.Tabs[1])
Window:OnTabChanged(function(current, previous, revision)
    print(current and current.Name, previous and previous.Name, revision)
end)
Window:SetMaximized(true)
Window:Minimize()
Window:Restore()
Window:Toggle()
Window:SetProfile({Title = "New name", Subtitle = "Online", Avatar = "1234567890"})
Window:SetSidebarMode("Expanded")
local layoutPassed, layoutIssues = Window:GetLayoutDiagnostics()
Window:Close()
```

## Tabs, sections, and controls

```lua
Window:CreateTabCategory("Player tools")
local PlayerTab = Window:CreateTab({Name = "Player", Icon = "6034287594"})
local Movement = PlayerTab:CreateSection({Name = "Movement", Side = "Auto", Icon = "6034287594"})

local speed = Movement:CreateSlider({
    Name = "Walk speed",
    Min = 8,
    Max = 80,
    Step = 0.5,
    Default = 16,
    Flag = "WalkSpeed",
    CallbackMode = "Release", -- optional: fire once when dragging ends
    Callback = function(value) print(value) end,
})

local mode = Movement:CreateDropdown({
    Name = "Movement mode",
    Values = {"Normal", "Sprint", "Glide"},
    Default = "Normal",
    Flag = "MovementMode",
})

Movement:CreateInput({
    Name = "Nickname",
    Placeholder = "Type here...",
    Flag = "Nickname",
})

Movement:CreateInput({
    Name = "Notes",
    MultiLine = true,
    Flag = "Notes",
})

Movement:CreateColorPicker({
    Name = "Accent override",
    Default = Color3.fromRGB(80, 170, 255),
    Flag = "AccentOverride",
})

Movement:CreateParagraph({
    Title = "Responsive controls",
    Content = "This section automatically becomes full-width on smaller screens.",
})

Movement:CreateDivider("Actions")
Movement:CreateButton({
    Name = "Reset",
    Description = "Restore the default movement value.",
    Icon = "6031260800",
    Callback = function() speed:Set(16) end,
})

local advanced = Movement:CreateToggle({Name = "Advanced", Default = true})
local nestedMode = Movement:CreateDropdown({Name = "Nested mode", Values = {"Safe", "Fast"}})
local nestedColor = Movement:CreateColorPicker({Name = "Nested color"})
advanced:AddNested(nestedMode):AddNested(nestedColor)

local roles = Movement:CreateMultiDropdown({
    Name = "Roles",
    Values = {"Builder", "Scout", "Tester"},
    Default = {"Builder", "Tester"},
})
print(table.concat(roles:GetList(), ", "))
```

Stateful controls support `Set`, `Get`, and usually `OnChanged`. Every returned control also supports:

```lua
speed:Lock()
speed:Unlock()
speed:SetVisible(false)
speed:SetLoading(true, "Applying...")
speed:SetTooltip("Applied after the drag is released.")
speed:Destroy()
```

## Groups and data controls

```lua
local Group = Movement:CreateGroup({Name = "Advanced movement", Expanded = true})
Group:CreateToggle({Name = "Air control", Default = true})
Group:CreateSlider({Name = "Boost", Min = 0, Max = 100, Default = 25})

local Targets = Movement:CreateList({
    Name = "Targets",
    Items = {
        {Label = "Nearest", Description = "Lowest distance", Value = "nearest"},
        {Label = "Lowest health", Value = "health"},
    },
    Callback = function(value) print(value) end,
})
Targets:Add({Label = "Manual", Value = "manual"})

local Stats = Movement:CreateTable({
    Name = "Stats",
    Columns = {{Key = "name", Name = "Name"}, {Key = "value", Name = "Value"}},
    Rows = {{name = "FPS", value = 60}, {name = "Ping", value = "48 ms"}},
})

local Players = Movement:CreatePlayerList({Name = "Players in server"})
local Console = Movement:CreateLogConsole({Name = "Runtime log", MaxLines = 100})
Console:Log("Ready")
Console:Warn("Example warning")
Console:Error("Example error")
Movement:CreateSkeleton({Lines = 3})
```

## Themes and motion

```lua
RenLib:ApplyThemePreset("Nebula")
RenLib:ApplyThemePreset("Prism Frost")
RenLib:SetMaterialMode("Frosted")
RenLib:SetMaterialIntensity(18)
RenLib:SetReducedMotion(true)
RenLib:SetMotionScale(0.75)
RenLib:SetDPIScale(110)
RenLib:PreviewDPIScale(125, 10) -- built-in settings uses this safer path

RenLib:SetTheme({
    Accent = Color3.fromRGB(255, 110, 180),
    Main = Color3.fromRGB(28, 22, 30),
})
```

## Existing-script migration

For scripts originally built around Rayfield's tab-level control calls, use the RenLib-owned facade while leaving gameplay logic untouched:

```lua
local RenLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xsakyx/RobloxUILib/main/RenLib.lua"
))()
local RenUI = RenLib:CreateRayfieldAdapter()

local Window = RenUI:CreateWindow({Name = "Migrated Script"})
local Main = Window:CreateTab("Main", "9080449299")
Main:CreateToggle({Name = "Enabled", CurrentValue = false, Callback = function(value)
    print(value)
end})
```

The facade maps windows, tabs, sections, buttons, toggles, sliders, dropdowns, inputs, color pickers, labels, paragraphs, keybinds, notifications, configuration loading, and cleanup onto RenLib.

Theme changes are applied live; the interface does not need to restart.

## Dashboard

```lua
local Dashboard = Window:CreateDashboard({
    Name = "Overview",
    Greeting = "Welcome back",
    Subtitle = "Everything useful in one glance",
    Cards = {
        {
            Name = "Session",
            Side = "Left",
            Metrics = {
                {Name = "Players", Value = "12", Detail = "Currently connected"},
                {Name = "Latency", Value = "48 ms", Detail = "Healthy"},
            },
        },
    },
})

Dashboard:AddCard({Name = "Quick actions", Side = "Right"})
Dashboard:SetGreeting("Good evening")
```

## Built-in Infinite Yield action

The settings page can launch Infinite Yield from the [official EdgeIY repository](https://github.com/EdgeIY/infiniteyield) after a confirmation dialog. Set `ShowInfiniteYield = false` on the window to hide this integration. Download, compile, and runtime failures are reported through RenLib notifications.

## Notifications and dialogs

```lua
local Toast = RenLib:Notify({
    Title = "Update ready",
    Content = "The new settings are ready to apply.",
    Duration = 8,
    Actions = {
        {Name = "Apply", Callback = function() print("Applied") end},
        {Name = "Later"},
    },
})

Toast:SetProgress(0.7)
Toast:SetContent("Almost finished...")

Window:Dialog({
    Title = "Reset settings?",
    Content = "This cannot be undone.",
    Actions = {
        {Name = "Cancel"},
        {Name = "Reset", Primary = true, Callback = function() print("Reset") end},
    },
})

Window:Prompt({
    Title = "Rename config",
    Placeholder = "New name",
    Validate = function(value)
        return #value >= 3, "Use at least three characters."
    end,
    Callback = function(value) print("New name:", value) end,
})
```

## Tooltips, keybinds, icons, and addons

```lua
local Action = Movement:CreateButton({
    Name = "Protected action",
    Tooltip = "Mouse over, or touch and hold, to read this help.",
    Callback = function() end,
})

Movement:CreateKeyPicker({
    Name = "Toggle action",
    Flag = "ToggleActionKey",
    Default = "P",
    Mode = "Toggle", -- "Toggle", "Hold", or "Press"
    Callback = function(key, active) print(key, active) end,
})
RenLib.KeybindManager:Show()

print(RenLib.Icons.Home)
RenLib:RegisterIcon("MyLogo", "1234567890")
local CustomIcon = RenLib:GetIcon("MyLogo")

RenLib:RegisterAddon("Telemetry", {
    Start = function(self, library) print("Started with", library.Version) end,
    Stop = function() print("Stopped") end,
    Unload = function() print("Released") end,
})
RenLib:DisableAddon("Telemetry")
RenLib:EnableAddon("Telemetry")
RenLib:UnregisterAddon("Telemetry")
```

## Configs

```lua
RenLib:SaveConfig("legit")
RenLib:LoadConfig("legit")
RenLib:SetAutoloadConfig("legit")
RenLib:LoadAutoloadConfig()
RenLib:DeleteConfig("legit")
```

Configs are stored in `RenLib/Configs`. These methods return `false, reason` when the runtime does not expose filesystem APIs, so ordinary LocalScripts can still use the rest of the library.

## Cleanup

```lua
RenLib:Unload()
```

All RenLib-managed connections, active tweens, registered theme/material objects, local glass decorations, and the ScreenGui are cleaned up. Loading a second RenLib session automatically unloads the first.

## Compatibility

- `RenLib.lua` is the canonical V7.0 file.
- `RenLibBêta.lua` and `RenLibTesting.lua` remain available for older loadstrings and mirror V7.0 exactly.
- Existing V4/V5 calls for windows, tabs, sections, buttons, toggles, sliders, dropdowns, labels, key pickers, warning boxes, images, and notifications remain supported.

## Design references

V6.5 studies hierarchy and interaction principles from [Luna Interface Suite](https://github.com/Nebula-Softworks/Luna-Interface-Suite) and [Starlight Interface Suite](https://github.com/Nebula-Softworks/Starlight-Interface-Suite). RenLib's names, palette values, APIs, architecture, and implementation are original; no Starlight source code is copied.

The project Obsidian vault is intentionally local-only and excluded from this repository.

See [`Showcase.lua`](./Showcase.lua) for a complete runnable example, [`docs/API.md`](./docs/API.md) for the API map, [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) for state invariants, and [`docs/QA-CHECKLIST.md`](./docs/QA-CHECKLIST.md) before publishing.
