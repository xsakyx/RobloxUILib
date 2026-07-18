-- Module fragment: runtime, services, constants, root state
-- Generated from the working V7 baseline; edit this feature in isolation.
-- RenLib V8.0.0 modular compatibility bundle
-- Responsive Roblox UI framework with centralized navigation, non-destructive
-- search, mobile-first input, live theming, addons, and deterministic cleanup.

--// SERVICES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")

--// LOCAL SHORTCUTS
local Plr = Players.LocalPlayer
local Mouse = Plr:GetMouse()
local Camera = workspace.CurrentCamera

--// DEVICE DETECTION
local function getViewport()
    Camera = workspace.CurrentCamera or Camera
    return Camera and Camera.ViewportSize or Vector2.new(800, 600)
end

local function getDeviceMode(scale)
    local viewport = getViewport()
    local normalizedScale = math.max(tonumber(scale) or 1, 0.01)
    -- Larger UI scales reduce usable physical space, so responsive mode is
    -- chosen from the canvas people can actually see rather than raw pixels.
    local scalePressure = normalizedScale < 1 and normalizedScale or (1 / normalizedScale)
    local effectiveWidth = viewport.X * scalePressure
    if effectiveWidth <= 620 then
        return "Phone"
    elseif effectiveWidth <= 960 or (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) then
        return "Tablet"
    end
    return "Desktop"
end

local DeviceMode = getDeviceMode(1)
local IsMobile = DeviceMode ~= "Desktop"
local ScreenSize = getViewport()

--// CONSTANTS
local CONFIG_FOLDER = "RenLib/Configs"
local RUNTIME_KEY = "__RENLIB_V8_RUNTIME"
local INFINITE_YIELD_URL = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
local RenCore_LOADER_URL = "https://raw.githubusercontent.com/xsakyx/RobloxUILib/refs/heads/main/Loaders/RenCoreLoader"
local BRAND_ICON_ASSET_ID = "rbxassetid://84928996923191"
local BRAND_ICON_FALLBACK = "rbxassetid://6034316009"
local function resolveRuntimeEnvironment()
    if type(getgenv) == "function" then
        local ok, environment = pcall(getgenv)
        if ok and type(environment) == "table" then
            return environment
        end
        if not ok then
            warn("[RenLib] getgenv failed; using a fallback environment: " .. tostring(environment))
        end
    end
    if type(shared) == "table" then
        return shared
    end
    if type(_G) == "table" then
        return _G
    end
    return {}
end

local RuntimeEnvironment = resolveRuntimeEnvironment()

-- Only one RenLib session may own input and UI at a time.
local PreviousSession = RuntimeEnvironment[RUNTIME_KEY]
if PreviousSession and type(PreviousSession.Unload) == "function" then
    pcall(function()
        PreviousSession:Unload("replaced")
    end)
end

--// EMOJI ICONS
local EMOJIS = {
    Logo = "</>",
    Settings = "⚙️",
    Search = "🔍",
    Close = "❌",
    Minimize = "➖",
    Arrow = "▼",
    Check = "✓",
    Star = "⭐",
    Play = "▶",
    Trash = "🗑️",
    Refresh = "🔄",
    Info = "ℹ️",
    Warning = "⚠️",
    Success = "✅",
    Error = "❌",
    Home = "🏠",
    Code = "</>",
    Terminal = "💻",
    User = "👤",
    Lock = "🔒",
    Unlock = "🔓"
}

-- Material icons hosted on Roblox. These keep core chrome crisp at every UI scale.
local ICONS = {
    Settings = "rbxassetid://6031280882",
    Search = "rbxassetid://6031154871",
    Close = "rbxassetid://6031094678",
    Minimize = "rbxassetid://6026568240",
    ChevronDown = "rbxassetid://6034818372",
    ChevronRight = "rbxassetid://6034818365",
    Home = "rbxassetid://9080449299",
    Profile = "rbxassetid://6022668898",
    Play = "rbxassetid://6026663699",
    Palette = "rbxassetid://6034316009",
    Restore = "rbxassetid://6031260800",
    Dashboard = "rbxassetid://6034287594",
    Layers = "rbxassetid://6034328955",
    Glass = "rbxassetid://6034925618",
    Check = "rbxassetid://6031094667",
    Menu = "rbxassetid://6031091002"
}

--// ROOT LIBRARY
local Library = {}
Library.Version = "8.0.0"
Library.Architecture = "modular-bundle"
Library.Title = "RenLib"
Library.Connections = {}
Library.Tasks = {}
Library.Flags = {}
Library.Options = {}
Library.PendingAutoloadFlags = {}
Library.AutoloadConfigName = nil
Library.AutoloadThemeName = nil
Library.KnownConfigs = {}
Library.Unloaded = false
Library.Keybinds = {}
Library.KeybindDefaults = {}
Library.Addons = {}
Library.AddonOrder = {}
Library.ToggleKey = Enum.KeyCode.K
Library.IsMinimized = false
Library.IsMobile = IsMobile
Library.DeviceMode = DeviceMode
Library.DPIScale = 1
Library.ReducedMotion = false
Library.MotionScale = 1
-- Strong registries are intentional. Some injected Instance wrappers are not
-- stable as weak-table keys, which can make theme entries disappear mid-session.
-- Every registry is explicitly cleared by Unload, so this does not leak state.
Library.ActiveTweens = {}
Library.LayoutTweens = {}
Library.VisibilityTweens = {}
Library.GradientRegistry = {}
Library.ActiveTheme = "Celestial"
Library.ScalePreview = nil
Library.MaterialMode = "Solid"
Library.MaterialIntensity = 18
Library.MaterialRegistry = {}
Library.MaterialDecorations = {}
Library.BrandIcon = BRAND_ICON_ASSET_ID
-- Brand marks use semantic text contrast. A dark theme therefore receives a
-- bright mark while a light theme receives a dark mark, without hard-coded
-- per-theme exceptions.
Library.BrandIconTint = nil
Library.BrandMarks = {}
Library.Icons = ICONS

-- Theme (can be changed at runtime)
Library.Theme = {
    Main = Color3.fromRGB(24, 26, 37),
    Secondary = Color3.fromRGB(29, 32, 44),
    Surface = Color3.fromRGB(36, 39, 53),
    SurfaceAlt = Color3.fromRGB(44, 47, 63),
    Stroke = Color3.fromRGB(82, 86, 111),
    Divider = Color3.fromRGB(57, 60, 79),
    Text = Color3.fromRGB(245, 245, 249),
    SubText = Color3.fromRGB(158, 160, 178),
    Hover = Color3.fromRGB(48, 51, 68),
    Click = Color3.fromRGB(55, 59, 77),
    Accent = Color3.fromRGB(157, 112, 255),
    Accent2 = Color3.fromRGB(91, 190, 255),
    Accent3 = Color3.fromRGB(255, 142, 216),
    Success = Color3.fromRGB(75, 215, 155),
    Warn = Color3.fromRGB(247, 190, 78),
    Error = Color3.fromRGB(247, 91, 121)
}

Library.ThemePresets = {
    Midnight = {
        Main = Color3.fromRGB(23, 26, 36), Secondary = Color3.fromRGB(29, 32, 44),
        Surface = Color3.fromRGB(36, 40, 53), SurfaceAlt = Color3.fromRGB(44, 48, 63),
        Stroke = Color3.fromRGB(82, 87, 108), Divider = Color3.fromRGB(58, 62, 79),
        Text = Color3.fromRGB(244, 245, 248), SubText = Color3.fromRGB(158, 160, 176),
        Hover = Color3.fromRGB(49, 53, 68), Click = Color3.fromRGB(57, 61, 78),
        Accent = Color3.fromRGB(96, 164, 255), Accent2 = Color3.fromRGB(120, 220, 226), Success = Color3.fromRGB(60, 220, 120),
        Warn = Color3.fromRGB(240, 200, 60), Error = Color3.fromRGB(240, 60, 60)
    },
    Nebula = {
        Main = Color3.fromRGB(29, 23, 43), Secondary = Color3.fromRGB(36, 29, 52),
        Surface = Color3.fromRGB(44, 35, 63), SurfaceAlt = Color3.fromRGB(53, 42, 75),
        Stroke = Color3.fromRGB(91, 75, 122), Divider = Color3.fromRGB(70, 59, 95),
        Text = Color3.fromRGB(246, 243, 255), SubText = Color3.fromRGB(174, 164, 199),
        Hover = Color3.fromRGB(58, 47, 80), Click = Color3.fromRGB(66, 53, 90),
        Accent = Color3.fromRGB(170, 106, 255), Accent2 = Color3.fromRGB(89, 189, 255), Success = Color3.fromRGB(76, 218, 157),
        Warn = Color3.fromRGB(255, 198, 88), Error = Color3.fromRGB(255, 94, 117)
    },
    Celestial = {
        Main = Color3.fromRGB(24, 26, 37), Secondary = Color3.fromRGB(29, 32, 44),
        Surface = Color3.fromRGB(36, 39, 53), SurfaceAlt = Color3.fromRGB(44, 47, 63),
        Stroke = Color3.fromRGB(82, 86, 111), Divider = Color3.fromRGB(57, 60, 79),
        Text = Color3.fromRGB(245, 245, 249), SubText = Color3.fromRGB(158, 160, 178),
        Hover = Color3.fromRGB(48, 51, 68), Click = Color3.fromRGB(55, 59, 77),
        Accent = Color3.fromRGB(157, 112, 255), Accent2 = Color3.fromRGB(91, 190, 255), Success = Color3.fromRGB(66, 224, 171),
        Warn = Color3.fromRGB(255, 205, 92), Error = Color3.fromRGB(255, 92, 120)
    },
    Rose = {
        Main = Color3.fromRGB(42, 27, 36), Secondary = Color3.fromRGB(50, 32, 43),
        Surface = Color3.fromRGB(61, 38, 52), SurfaceAlt = Color3.fromRGB(72, 44, 61),
        Stroke = Color3.fromRGB(111, 70, 91), Divider = Color3.fromRGB(86, 55, 73),
        Text = Color3.fromRGB(255, 241, 247), SubText = Color3.fromRGB(201, 157, 178),
        Hover = Color3.fromRGB(77, 48, 65), Click = Color3.fromRGB(86, 53, 73),
        Accent = Color3.fromRGB(255, 105, 180), Accent2 = Color3.fromRGB(177, 117, 255), Success = Color3.fromRGB(73, 219, 157),
        Warn = Color3.fromRGB(255, 198, 91), Error = Color3.fromRGB(255, 86, 107)
    },
    Aurora = {
        Main = Color3.fromRGB(18, 32, 38), Secondary = Color3.fromRGB(23, 40, 47),
        Surface = Color3.fromRGB(29, 49, 57), SurfaceAlt = Color3.fromRGB(36, 59, 67),
        Stroke = Color3.fromRGB(71, 110, 118), Divider = Color3.fromRGB(50, 81, 88),
        Text = Color3.fromRGB(238, 253, 252), SubText = Color3.fromRGB(147, 185, 185),
        Hover = Color3.fromRGB(41, 65, 73), Click = Color3.fromRGB(47, 74, 82),
        Accent = Color3.fromRGB(48, 226, 183), Accent2 = Color3.fromRGB(102, 149, 255), Success = Color3.fromRGB(64, 226, 158),
        Warn = Color3.fromRGB(255, 205, 94), Error = Color3.fromRGB(255, 92, 117)
    },
    Ember = {
        Main = Color3.fromRGB(42, 28, 23), Secondary = Color3.fromRGB(51, 34, 28),
        Surface = Color3.fromRGB(62, 41, 33), SurfaceAlt = Color3.fromRGB(74, 48, 38),
        Stroke = Color3.fromRGB(118, 79, 62), Divider = Color3.fromRGB(90, 59, 48),
        Text = Color3.fromRGB(255, 247, 239), SubText = Color3.fromRGB(201, 169, 146),
        Hover = Color3.fromRGB(80, 52, 41), Click = Color3.fromRGB(91, 59, 46),
        Accent = Color3.fromRGB(255, 132, 72), Accent2 = Color3.fromRGB(255, 83, 129), Accent3 = Color3.fromRGB(255, 202, 102), Success = Color3.fromRGB(87, 220, 153),
        Warn = Color3.fromRGB(255, 201, 87), Error = Color3.fromRGB(255, 83, 99)
    },
    ["Prism Frost"] = {
        Main = Color3.fromRGB(218, 228, 232), Secondary = Color3.fromRGB(230, 238, 241),
        Surface = Color3.fromRGB(242, 246, 248), SurfaceAlt = Color3.fromRGB(250, 252, 253),
        Stroke = Color3.fromRGB(123, 145, 155), Divider = Color3.fromRGB(168, 184, 191),
        Text = Color3.fromRGB(31, 39, 43), SubText = Color3.fromRGB(100, 111, 117),
        Hover = Color3.fromRGB(224, 234, 239), Click = Color3.fromRGB(211, 224, 230),
        Accent = Color3.fromRGB(168, 208, 255), Accent2 = Color3.fromRGB(255, 222, 166), Accent3 = Color3.fromRGB(186, 222, 255),
        Success = Color3.fromRGB(67, 171, 127), Warn = Color3.fromRGB(218, 150, 51), Error = Color3.fromRGB(211, 75, 102)
    },
    ["Moss Archive"] = {
        Main = Color3.fromRGB(31, 40, 42), Secondary = Color3.fromRGB(38, 48, 50),
        Surface = Color3.fromRGB(45, 56, 57), SurfaceAlt = Color3.fromRGB(52, 65, 64),
        Stroke = Color3.fromRGB(96, 111, 96), Divider = Color3.fromRGB(117, 119, 91),
        Text = Color3.fromRGB(236, 235, 222), SubText = Color3.fromRGB(190, 181, 151),
        Hover = Color3.fromRGB(52, 64, 63), Click = Color3.fromRGB(59, 72, 69),
        Accent = Color3.fromRGB(156, 186, 105), Accent2 = Color3.fromRGB(196, 207, 148), Accent3 = Color3.fromRGB(126, 160, 89),
        Success = Color3.fromRGB(113, 196, 128), Warn = Color3.fromRGB(223, 180, 88), Error = Color3.fromRGB(225, 104, 105)
    },
    ["Velvet Latte"] = {
        Main = Color3.fromRGB(27, 28, 45), Secondary = Color3.fromRGB(35, 36, 56),
        Surface = Color3.fromRGB(43, 44, 66), SurfaceAlt = Color3.fromRGB(52, 53, 78),
        Stroke = Color3.fromRGB(101, 105, 143), Divider = Color3.fromRGB(76, 80, 113),
        Text = Color3.fromRGB(232, 236, 255), SubText = Color3.fromRGB(175, 181, 215),
        Hover = Color3.fromRGB(51, 52, 77), Click = Color3.fromRGB(59, 60, 87),
        Accent = Color3.fromRGB(232, 164, 207), Accent2 = Color3.fromRGB(181, 148, 238), Accent3 = Color3.fromRGB(120, 174, 239),
        Success = Color3.fromRGB(120, 207, 157), Warn = Color3.fromRGB(238, 190, 104), Error = Color3.fromRGB(239, 117, 144)
    }
}

-- Registry for dynamic theming
Library.Registry = {}
Library.Scales = {}

-- Global keybinds list
Library.KeybindManager = nil
Library.KeybindList = {}

