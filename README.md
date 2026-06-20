# RenLib V6.2

RenLib is a responsive Roblox/Luau interface library for desktop, tablet, and phone. V6.2 completes the darker Starlight-inspired visual system with scale-aware layouts, recovery paths, custom image icons, a Roblox avatar surface, and documented interaction contracts.

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

## What changed in V6.2

- Color previews now live below the H/S/V tracks instead of drifting over them.
- Responsive sizing uses the effective viewport after UI scale, with scrollable compact pages and dense-height fallbacks.
- Scale changes use a ten-second preview with **Keep**, **Revert**, timeout recovery, and a 100% reset action.
- Window dragging preserves a recoverable edge so the interface cannot be permanently lost off-screen.
- Window, settings, tab, and button icons accept custom Roblox image IDs.
- The sidebar includes the local Roblox avatar/profile and supports custom profile images and text.
- Buttons support optional icons and descriptions.
- Settings include an optional confirmed launcher for the current official Infinite Yield source.
- Added `Aurora` and `Ember` alongside the existing theme presets.
- Added an Obsidian-ready project vault and the Golden Rule feature-completion gate.

- Live responsive reflow: two columns become one as the viewport narrows, including rotation and split-screen changes.
- Touch-sized sliders, dropdowns, color controls, draggable windows, and a floating mobile restore button.
- One active RenLib session. Loading RenLib again unloads the old session and disconnects its events.
- Cancellable animation system with reduced-motion and motion-speed controls.
- Six live presets: `Midnight`, `Nebula`, `Starlight`, `Rose`, `Aurora`, and `Ember`.
- Search on desktop and mobile.
- Real JSON config save/load/autoload when filesystem APIs are available.
- Safe callbacks: an error in user code is reported without breaking the entire UI.
- Notifications with actions, progress, live updates, manual close, and timed close.
- Modal dialogs, maximize support, DPI scaling, and richer window controls.
- Shared component methods: `Lock`, `Unlock`, `SetLocked`, `SetVisible`, and `Destroy`.
- New controls: input, multiline input, paragraph, divider, key picker, image, warning box, dependency box, tabbox, and a functional HSV color picker.
- Removed RenHub-specific external script buttons from the UI library core.

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
    OnDeviceChanged = function(mode)
        print(mode) -- "Desktop", "Tablet", or "Phone"
    end,
})

Window:SetTitle("New title")
Window:SetSearch("movement")
Window:SetMaximized(true)
Window:Minimize()
Window:Restore()
Window:Toggle()
Window:SetProfile({Title = "New name", Subtitle = "Online", Avatar = "1234567890"})
Window:Close()
```

## Tabs, sections, and controls

```lua
local PlayerTab = Window:CreateTab({Name = "Player", Icon = "6034287594"})
local Movement = PlayerTab:CreateSection({Name = "Movement", Side = "Auto"})

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
```

Stateful controls support `Set`, `Get`, and usually `OnChanged`. Every returned control also supports:

```lua
speed:Lock()
speed:Unlock()
speed:SetVisible(false)
speed:Destroy()
```

## Themes and motion

```lua
RenLib:ApplyThemePreset("Nebula")
RenLib:SetReducedMotion(true)
RenLib:SetMotionScale(0.75)
RenLib:SetDPIScale(110)
RenLib:PreviewDPIScale(125, 10) -- built-in settings uses this safer path

RenLib:SetTheme({
    Accent = Color3.fromRGB(255, 110, 180),
    Main = Color3.fromRGB(28, 22, 30),
})
```

Theme changes are applied live; the interface does not need to restart.

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

All RenLib-managed connections, active tweens, registered theme objects, and the ScreenGui are cleaned up. Loading a second RenLib session automatically unloads the first.

## Compatibility

- `RenLib.lua` is the canonical V6.2 file.
- `RenLibBêta.lua` and `RenLibTesting.lua` remain available for older loadstrings and mirror V6.2.
- Existing V4/V5 calls for windows, tabs, sections, buttons, toggles, sliders, dropdowns, labels, key pickers, warning boxes, images, and notifications remain supported.

## Design references

V6.2 studies interaction ideas from [Luna Interface Suite](https://github.com/Nebula-Softworks/Luna-Interface-Suite) and [Starlight Interface Suite](https://github.com/Nebula-Softworks/Starlight-Interface-Suite). RenLib's implementation is original; no Starlight source code is copied.

The Obsidian-ready project memory is in [`RenHubUiLib-ObsidianVault`](./RenHubUiLib-ObsidianVault/Welcome.md), including the Golden Rule and release checklist.

See [`Showcase.lua`](./Showcase.lua) for a fuller example.
