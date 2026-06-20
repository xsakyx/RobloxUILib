# RenLib V6.4 — Clarity

RenLib is a responsive Roblox/Luau interface library for desktop, tablet, and phone. V6.4 repairs live theme contrast, makes Frosted material local to the window, keeps controls readable at every supported scale, and introduces a compact navigation rail that expands on hover.

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

## What changed in V6.4

- Every semantic color is registered automatically, so theme changes cannot leave dark labels on dark surfaces or light icons on light surfaces.
- Frosted mode now uses window-local transparency, tint, grain, and edge treatment. It never creates a global Lighting blur or changes the game screen.
- The supported scale range is 75–150%; visible-width breakpoints force a safe one-column layout before controls can overlap.
- Navigation defaults to `Dynamic`: a 68 px icon rail expands while hovered, and the header button pins or releases the full sidebar.
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
    SidebarMode = "Dynamic", -- "Dynamic", "Expanded", or "Compact"
    MaterialMode = "Frosted", -- or "Solid"
    MaterialIntensity = 18, -- local glass transparency; never a screen blur
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
Window:SetSidebarMode("Expanded")
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
speed:Destroy()
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

- `RenLib.lua` is the canonical V6.4 file.
- `RenLibBêta.lua` and `RenLibTesting.lua` remain available for older loadstrings and mirror V6.4.
- Existing V4/V5 calls for windows, tabs, sections, buttons, toggles, sliders, dropdowns, labels, key pickers, warning boxes, images, and notifications remain supported.

## Design references

V6.4 studies hierarchy and interaction principles from [Luna Interface Suite](https://github.com/Nebula-Softworks/Luna-Interface-Suite) and [Starlight Interface Suite](https://github.com/Nebula-Softworks/Starlight-Interface-Suite). RenLib's names, palette values, APIs, architecture, and implementation are original; no Starlight source code is copied.

The project Obsidian vault is intentionally local-only and excluded from this repository.

See [`Showcase.lua`](./Showcase.lua) for a fuller example.
