# RenLib – Complete UI Library Documentation  
**Version 4.1.0-mobile** | **Mobile + PC Support** | **For Roblox Executors**

RenLib is a powerful, modern UI library designed for both **PC** and **mobile** exploiters. It features a sleek, responsive interface, smooth animations, and a complete set of UI elements – all wrapped in an easy-to-use API. This library is the core of **RenHub**, but can be used in any script.

---

## 📦 Loadstring (for RenHub project)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/xsakyx/RobloxUILib/refs/heads/main/Loaders/Loader"))()
```

> **Note:** The above loads RenHub with its UI.  
> To use only the library itself in your own script:  
> ```lua
> local RenLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xsakyx/RobloxUILib/refs/heads/main/RenLibBêta.lua"))()
> ```

---

## 🚀 Features at a Glance

- ✅ **Fully responsive** – adapts to screen size and device (mobile / tablet / PC)
- ✅ **Draggable window** with smooth tweening
- ✅ **Tab system** with emoji icons and active indicators
- ✅ **Multiple UI elements**:
  - Buttons
  - Toggles (with animated switch)
  - Sliders (numeric, with live value display)
  - Dropdowns (single or multi‑select)
  - Labels (auto‑wrapping text)
- ✅ **Notification system** (toast messages with icons)
- ✅ **Minimize & Restore** – compact icon or floating toggle for mobile
- ✅ **Customizable theme** (colors, accents, strokes)
- ✅ **Global toggle key** (default `K`) to hide/show UI (PC only)
- ✅ **Settings tab** built‑in: change toggle key, minimize, close, load external scripts (Infinity Yield, Dark Dex)
- ✅ **Config folder support** – `RenLib/Configs` created automatically for future save/load
- ✅ **Works on every executor** that supports `CoreGui` or `gethui()`

---

## 🧩 API Reference

### 1. `Library:CreateWindow(options)`
Creates the main window and returns a `Window` object.

| Option      | Type     | Default  | Description                     |
|-------------|----------|----------|---------------------------------|
| `Name`      | `string` | `"RenHub"` | Title displayed in top bar    |

**Returns:** `Window`

---

### 2. `Window:CreateTab(options)`
Adds a new tab to the sidebar.

| Option      | Type      | Default     | Description                           |
|-------------|-----------|-------------|---------------------------------------|
| `Name`      | `string`  | `"Tab"`     | Tab name (displayed as tooltip)       |
| `Emoji`     | `string`  | `"🏠"`       | Emoji shown on the tab button         |
| `IsSettings`| `boolean` | `false`     | Reserved for the internal settings tab |

**Returns:** `Tab`

---

### 3. `Tab:CreateSection(options)`
Creates a collapsible section inside a tab.

| Option | Type     | Default  | Description                              |
|--------|----------|----------|------------------------------------------|
| `Name` | `string` | `"Section"` | Section title displayed at the top     |
| `Side` | `string` | `"Auto"` | `"Left"`, `"Right"`, or `"Auto"` (PC only) – on mobile all sections are full width |

**Returns:** `Section`

---

### 4. Section Elements

All elements are created inside a section. They automatically arrange themselves vertically and resize the section container.

#### `Section:CreateButton(options)`
| Option     | Type       | Default      | Description                      |
|------------|------------|--------------|----------------------------------|
| `Name`     | `string`   | `"Button"`   | Text on the button               |
| `Callback` | `function` | `function() end` | Called when clicked            |

**Returns:** `{ SetText(newText) }`

---

#### `Section:CreateToggle(options)`
| Option     | Type       | Default       | Description                           |
|------------|------------|---------------|---------------------------------------|
| `Name`     | `string`   | `"Toggle"`    | Label next to the switch              |
| `Default`  | `boolean`  | `false`       | Initial state                         |
| `Callback` | `function` | `function(val) end` | Receives current state (`true`/`false`) |
| `Flag`     | `string`   | `Name`        | Key used in `Library.Flags`           |

**Returns:** `{ Set(newState) }`

---

#### `Section:CreateSlider(options)`
| Option     | Type       | Default        | Description                           |
|------------|------------|----------------|---------------------------------------|
| `Name`     | `string`   | `"Slider"`     | Label above the slider                |
| `Min`      | `number`   | `0`            | Minimum value                         |
| `Max`      | `number`   | `100`          | Maximum value                         |
| `Default`  | `number`   | `Min`          | Starting value                        |
| `Callback` | `function` | `function(val) end` | Called when value changes           |
| `Flag`     | `string`   | `Name`         | Key in `Library.Flags`                |

**Returns:** `{ Set(newValue) }`

---

#### `Section:CreateDropdown(options)`
| Option     | Type                     | Default        | Description                                 |
|------------|--------------------------|----------------|---------------------------------------------|
| `Name`     | `string`                 | `"Dropdown"`   | Header label                                |
| `Values`   | `table` (list of strings)| `{}`           | Available options                           |
| `Multi`    | `boolean`                | `false`        | Allow multiple selections                   |
| `Default`  | `string` or `table`      | first value / `{}` | Selected value(s)                         |
| `Callback` | `function`               | `function(val) end` | Called when selection changes              |
| `Flag`     | `string`                 | `Name`         | Key in `Library.Flags`                      |

**Returns:**  
`{ Set(newValueOrTable), Refresh(newValuesList) }`

---

#### `Section:CreateLabel(text)`
Creates a simple read‑only text label that automatically wraps.

| Parameter | Type     | Description                |
|-----------|----------|----------------------------|
| `text`    | `string` | Content of the label       |

**Returns:** `{ SetText(newText) }`

---

### 5. Global `Library:Notify(options)`
Shows a temporary toast notification.

| Option     | Type     | Default           | Description                          |
|------------|----------|-------------------|--------------------------------------|
| `Title`    | `string` | `"Notification"`  | Bold title line                      |
| `Content`  | `string` | `""`              | Smaller description text             |
| `Duration` | `number` | `3`               | Seconds until auto‑close             |
| `Emoji`    | `string` | `"ℹ️"`            | Icon shown left of the title         |

---

### 6. Window Control Methods

| Method                | Description                               |
|-----------------------|-------------------------------------------|
| `Window:Minimize()`   | Hides the main window, shows minimized icon (or floating toggle on mobile). |
| `Window:Restore()`    | Brings back the full window.              |
| `Window:Toggle()`     | Switches between minimized and restored.  |
| `Window:Close()`      | Destroys the entire UI and disconnects events. |

---

### 7. Global `Library:Unload()`
Manually unload the UI, disconnect all connections, and clean up.

---

### 8. Theme Customization
You can modify the `Library.Theme` table **before creating the window**:

```lua
Library.Theme.Main = Color3.fromRGB(20, 20, 25)
Library.Theme.Accent = Color3.fromRGB(255, 85, 85)
Library.Theme.Text = Color3.fromRGB(255, 255, 255)
-- etc.
```

Available theme keys:
- `Main` – main background
- `Secondary` – sidebar, section background
- `Stroke` – border colour
- `Divider` – line between sidebar and content
- `Text`, `SubText` – label colours
- `Hover`, `Click` – button feedback colours
- `Accent`, `Success`, `Warn`, `Error`

---

### 9. Global `Library.Flags`
A table that automatically stores the current value of every toggle, slider, and dropdown (using the `Flag` option). You can read/write them directly:

```lua
print(Library.Flags["MyToggle"])   -- true/false
Library.Flags["MySlider"] = 50
```

---

## 🖥️ Mobile vs. PC Behaviour

| Feature                | PC                                          | Mobile                                      |
|------------------------|---------------------------------------------|---------------------------------------------|
| Window size           | Fixed 800×550                               | Scales to screen (clamped 300–600 wide)     |
| Columns               | Two (left / right)                          | Single column, full width                   |
| Sidebar               | 70px wide, emoji buttons                    | 55px wide, emoji buttons                    |
| Minimized mode        | Small square icon (draggable)               | Floating circle toggle button (draggable)   |
| Toggle key            | Global hotkey (default `K`)                 | Not available (use floating toggle)         |
| Touch dragging        | Yes (mouse)                                 | Yes (finger drag)                           |
| Button feedback       | Hover effect                                | Quick flash on tap                          |

---

## 📂 Configuration & Persistence

The library automatically creates a folder `RenLib/Configs` in the exploit’s workspace.  
**Built‑in save/load is not yet implemented** – but you can easily add it using `writefile` / `readfile` and `Library.Flags`. Example:

```lua
-- Save all flags
local data = HttpService:JSONEncode(Library.Flags)
writefile("RenLib/Configs/myconfig.json", data)

-- Load later
local data = readfile("RenLib/Configs/myconfig.json")
local loaded = HttpService:JSONDecode(data)
for k, v in pairs(loaded) do
    Library.Flags[k] = v
    -- Also update UI elements if needed (store their setter functions)
end
```

---

## 🧪 Example Usage

```lua
local RenLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xsakyx/RobloxUILib/refs/heads/main/RenLibBêta.lua"))()

local Window = RenLib:CreateWindow({ Name = "My Awesome Script" })
local CombatTab = Window:CreateTab({ Name = "Combat", Emoji = "⚔️" })
local CombatSection = CombatTab:CreateSection({ Name = "Settings" })

CombatSection:CreateToggle({
    Name = "Auto Attack",
    Default = true,
    Flag = "AutoAttack",
    Callback = function(state)
        print("Auto attack is now", state)
    end
})

CombatSection:CreateSlider({
    Name = "Damage Multiplier",
    Min = 1,
    Max = 10,
    Default = 5,
    Flag = "DamageMult",
    Callback = function(val)
        print("Damage set to", val)
    end
})

CombatSection:CreateButton({
    Name = "Heal",
    Callback = function()
        RenLib:Notify({ Title = "Healed", Content = "You healed 50 HP", Emoji = "💚" })
    end
})

local VisualTab = Window:CreateTab({ Name = "Visuals", Emoji = "🎨" })
local VisualSection = VisualTab:CreateSection({ Name = "ESP" })

VisualSection:CreateDropdown({
    Name = "ESP Mode",
    Values = {"Box", "Chams", "Skeleton"},
    Default = "Box",
    Flag = "ESPMode",
    Callback = function(val)
        print("ESP mode:", val)
    end
})
```

---

## ⚠️ Important Notes

- **Executors**: The library uses `syn.protect_gui` (if available) and falls back to `gethui()` or `CoreGui`. Works on most modern executors (Velocity, Volt,
- Script‑Ware, Fluxus, Xeno, Potasium, Retina(Close Testing) etc. ).
- **Mobile**: Some executors on mobile may not support all features (e.g., `UserInputService` touch events). The library has been tested on **Android** with Codex and Hydrogen.
- **Performance**: All tweens and events are cleaned up on unload. No memory leaks.
- **Customisation**: You can freely replace `EMOJIS` table or modify any UI property after creation (though not recommended – use the theme system instead).

---

## 🔗 Repository & Updates

- **Raw library URL:**  
  `https://raw.githubusercontent.com/xsakyx/RobloxUILib/refs/heads/main/RenLibBêta.lua`
- **RenHub project (full hub using this library):**  
  `loadstring(game:HttpGet("https://raw.githubusercontent.com/xsakyx/RobloxUILib/refs/heads/main/Loaders/Loader"))()`

---


    RenLib UI Library v4.1.0
    Copyright (C) 2026 RenHub Team
    
    LICENSE: USE ONLY - NO MODIFICATION
    
    You MAY:
    - Load and use this library as-is in your private/public scripts
    
    You MAY NOT:
    - Modify, edit, or change any code in this file
    - Redistribute modified versions or claim as your own
    
    This license is legally binding. Violations will be reported 
    to GitHub/DMCA for takedown of infringing repositories.
    
    If you want a custom/modified version, CONTACT the author via the official discord server at https://discord.gg/zjuFt8gaMH.


---

**Happy scripting!**  
– *RenLib Team*
