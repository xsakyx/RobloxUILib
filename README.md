# RenLib V6.1

RenLib is a responsive Roblox/Luau interface library for desktop, tablet, and phone. V6.1 combines a darker Starlight-inspired visual system with repaired desktop and touch interactions, deterministic cleanup, and reusable state.

```lua
local RenLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xsakyx/RobloxUILib/main/RenLib.lua"
))()

local Window = RenLib:CreateWindow({
    Name = "My Script",
    EnableGlobalSearch = true,
})

local Main = Window:CreateTab({Name = "Main", Emoji = "M"})
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

## What changed in V6.1

- Repaired free X/Y window dragging without the previous jump toward the top edge.
- Rebuilt dropdown expansion so choices participate in section layout instead of being clipped or drawn behind controls.
- Gave tab icons a fixed icon slot and separate label region, including compact sidebar and mobile modes.
- Added release-only slider callbacks; the built-in UI scale control now waits until the pointer is released.
- Reworked the shell and controls around layered dark surfaces, crisp Roblox-hosted icons, gradient selection states, and roomier navigation.

- Live responsive reflow: two columns become one as the viewport narrows, including rotation and split-screen changes.
- Touch-sized sliders, dropdowns, color controls, draggable windows, and a floating mobile restore button.
- One active RenLib session. Loading RenLib again unloads the old session and disconnects its events.
- Cancellable animation system with reduced-motion and motion-speed controls.
- Four live presets: `Midnight`, `Nebula`, `Starlight`, and `Rose`.
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
Window:Close()
```

## Tabs, sections, and controls

```lua
local PlayerTab = Window:CreateTab({Name = "Player", Emoji = "P"})
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
Movement:CreateButton({Name = "Reset", Callback = function() speed:Set(16) end})
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

RenLib:SetTheme({
    Accent = Color3.fromRGB(255, 110, 180),
    Main = Color3.fromRGB(28, 22, 30),
})
```

Theme changes are applied live; the interface does not need to restart.

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

- `RenLib.lua` is the canonical V6.1 file.
- `RenLibBêta.lua` and `RenLibTesting.lua` remain available for older loadstrings and mirror V6.1.
- Existing V4/V5 calls for windows, tabs, sections, buttons, toggles, sliders, dropdowns, labels, key pickers, warning boxes, images, and notifications remain supported.

## Design references

V6.1 studies interaction ideas from [Luna Interface Suite](https://github.com/Nebula-Softworks/Luna-Interface-Suite) and [Starlight Interface Suite](https://github.com/Nebula-Softworks/Starlight-Interface-Suite). RenLib's implementation is original; no Starlight source code is copied.

See [`Showcase.lua`](./Showcase.lua) for a fuller example.
