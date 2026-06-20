-- RenLib V6.2
-- Responsive Roblox UI library with mobile-first input, live theming,
-- accessible motion, searchable controls, and deterministic cleanup.

--// SERVICES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

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
    local effectiveWidth = viewport.X / math.max(tonumber(scale) or 1, 0.01)
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
local RUNTIME_KEY = "__RENLIB_V6_RUNTIME"
local INFINITE_YIELD_URL = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
local RuntimeEnvironment = (getgenv and getgenv()) or shared or _G

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
    Restore = "rbxassetid://6031260800"
}

--// ROOT LIBRARY
local Library = {}
Library.Version = "6.2.0"
Library.Title = "RenLib"
Library.Connections = {}
Library.Tasks = {}
Library.Flags = {}
Library.Options = {}
Library.Unloaded = false
Library.Keybinds = {}
Library.ToggleKey = Enum.KeyCode.K
Library.IsMinimized = false
Library.IsMobile = IsMobile
Library.DeviceMode = DeviceMode
Library.DPIScale = 1
Library.ReducedMotion = false
Library.MotionScale = 1
Library.ActiveTweens = setmetatable({}, {__mode = "k"})
Library.GradientRegistry = setmetatable({}, {__mode = "k"})
Library.ActiveTheme = "Starlight"
Library.ScalePreview = nil

-- Theme (can be changed at runtime)
Library.Theme = {
    Main = Color3.fromRGB(15, 16, 22),
    Secondary = Color3.fromRGB(20, 21, 29),
    Surface = Color3.fromRGB(25, 26, 35),
    SurfaceAlt = Color3.fromRGB(31, 32, 43),
    Stroke = Color3.fromRGB(62, 64, 82),
    Divider = Color3.fromRGB(43, 45, 59),
    Text = Color3.fromRGB(245, 245, 249),
    SubText = Color3.fromRGB(158, 160, 178),
    Hover = Color3.fromRGB(32, 33, 44),
    Click = Color3.fromRGB(38, 39, 51),
    Accent = Color3.fromRGB(157, 112, 255),
    Accent2 = Color3.fromRGB(91, 190, 255),
    Success = Color3.fromRGB(75, 215, 155),
    Warn = Color3.fromRGB(247, 190, 78),
    Error = Color3.fromRGB(247, 91, 121)
}

Library.ThemePresets = {
    Midnight = {
        Main = Color3.fromRGB(15, 16, 21), Secondary = Color3.fromRGB(20, 21, 28),
        Surface = Color3.fromRGB(25, 26, 34), SurfaceAlt = Color3.fromRGB(31, 32, 41),
        Stroke = Color3.fromRGB(59, 61, 76), Divider = Color3.fromRGB(42, 44, 56),
        Text = Color3.fromRGB(244, 245, 248), SubText = Color3.fromRGB(158, 160, 176),
        Hover = Color3.fromRGB(31, 32, 42), Click = Color3.fromRGB(37, 38, 49),
        Accent = Color3.fromRGB(96, 164, 255), Accent2 = Color3.fromRGB(120, 220, 226), Success = Color3.fromRGB(60, 220, 120),
        Warn = Color3.fromRGB(240, 200, 60), Error = Color3.fromRGB(240, 60, 60)
    },
    Nebula = {
        Main = Color3.fromRGB(17, 14, 27), Secondary = Color3.fromRGB(23, 19, 35),
        Surface = Color3.fromRGB(29, 24, 44), SurfaceAlt = Color3.fromRGB(36, 29, 54),
        Stroke = Color3.fromRGB(67, 57, 92), Divider = Color3.fromRGB(55, 47, 78),
        Text = Color3.fromRGB(246, 243, 255), SubText = Color3.fromRGB(174, 164, 199),
        Hover = Color3.fromRGB(39, 33, 58), Click = Color3.fromRGB(31, 27, 48),
        Accent = Color3.fromRGB(170, 106, 255), Accent2 = Color3.fromRGB(89, 189, 255), Success = Color3.fromRGB(76, 218, 157),
        Warn = Color3.fromRGB(255, 198, 88), Error = Color3.fromRGB(255, 94, 117)
    },
    Starlight = {
        Main = Color3.fromRGB(15, 16, 22), Secondary = Color3.fromRGB(20, 21, 29),
        Surface = Color3.fromRGB(25, 26, 35), SurfaceAlt = Color3.fromRGB(31, 32, 43),
        Stroke = Color3.fromRGB(62, 64, 82), Divider = Color3.fromRGB(43, 45, 59),
        Text = Color3.fromRGB(245, 245, 249), SubText = Color3.fromRGB(158, 160, 178),
        Hover = Color3.fromRGB(32, 33, 44), Click = Color3.fromRGB(38, 39, 51),
        Accent = Color3.fromRGB(157, 112, 255), Accent2 = Color3.fromRGB(91, 190, 255), Success = Color3.fromRGB(66, 224, 171),
        Warn = Color3.fromRGB(255, 205, 92), Error = Color3.fromRGB(255, 92, 120)
    },
    Rose = {
        Main = Color3.fromRGB(27, 17, 23), Secondary = Color3.fromRGB(34, 21, 29),
        Surface = Color3.fromRGB(43, 27, 37), SurfaceAlt = Color3.fromRGB(52, 32, 44),
        Stroke = Color3.fromRGB(78, 51, 66), Divider = Color3.fromRGB(65, 43, 56),
        Text = Color3.fromRGB(255, 241, 247), SubText = Color3.fromRGB(201, 157, 178),
        Hover = Color3.fromRGB(53, 34, 45), Click = Color3.fromRGB(45, 29, 39),
        Accent = Color3.fromRGB(255, 105, 180), Accent2 = Color3.fromRGB(177, 117, 255), Success = Color3.fromRGB(73, 219, 157),
        Warn = Color3.fromRGB(255, 198, 91), Error = Color3.fromRGB(255, 86, 107)
    },
    Aurora = {
        Main = Color3.fromRGB(9, 18, 23), Secondary = Color3.fromRGB(13, 25, 31),
        Surface = Color3.fromRGB(18, 34, 41), SurfaceAlt = Color3.fromRGB(24, 43, 51),
        Stroke = Color3.fromRGB(53, 84, 91), Divider = Color3.fromRGB(37, 63, 70),
        Text = Color3.fromRGB(238, 253, 252), SubText = Color3.fromRGB(147, 185, 185),
        Hover = Color3.fromRGB(24, 45, 52), Click = Color3.fromRGB(29, 53, 61),
        Accent = Color3.fromRGB(48, 226, 183), Accent2 = Color3.fromRGB(102, 149, 255), Success = Color3.fromRGB(64, 226, 158),
        Warn = Color3.fromRGB(255, 205, 94), Error = Color3.fromRGB(255, 92, 117)
    },
    Ember = {
        Main = Color3.fromRGB(23, 15, 13), Secondary = Color3.fromRGB(31, 20, 17),
        Surface = Color3.fromRGB(41, 27, 22), SurfaceAlt = Color3.fromRGB(51, 34, 27),
        Stroke = Color3.fromRGB(84, 58, 46), Divider = Color3.fromRGB(64, 43, 35),
        Text = Color3.fromRGB(255, 247, 239), SubText = Color3.fromRGB(201, 169, 146),
        Hover = Color3.fromRGB(53, 36, 29), Click = Color3.fromRGB(62, 42, 33),
        Accent = Color3.fromRGB(255, 132, 72), Accent2 = Color3.fromRGB(255, 83, 129), Success = Color3.fromRGB(87, 220, 153),
        Warn = Color3.fromRGB(255, 201, 87), Error = Color3.fromRGB(255, 83, 99)
    }
}

-- Registry for dynamic theming
Library.Registry = setmetatable({}, {__mode = "k"})
Library.Scales = {}

-- Global keybinds list
Library.KeybindManager = nil
Library.KeybindList = {}

--// MODULE: UTILITY (extended)
local Utility = {}

function Library:Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

function Utility:SafeCall(callback, ...)
    if type(callback) ~= "function" then return true end
    local args = table.pack(...)
    local ok, err = xpcall(function()
        callback(table.unpack(args, 1, args.n))
    end, debug.traceback)
    if not ok then
        warn("[RenLib] Callback error:\n" .. tostring(err))
        if Library.Notify and not Library.Unloaded then
            Library:Notify({Title = "Callback error", Content = tostring(err):match("^[^\n]+") or "Unknown error", Duration = 5})
        end
    end
    return ok, err
end

function Utility:RandomString(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

function Utility:NormalizeAssetId(asset, fallback)
    if asset == nil or asset == "" then return fallback end
    local value = tostring(asset)
    if value:match("^%d+$") then
        return "rbxassetid://" .. value
    end
    if value:match("^rbxassetid://%d+$") or value:match("^https?://") then
        return value
    end
    return fallback
end

function Utility:Create(class, properties)
    local instance = Instance.new(class)
    if class == "UIStroke" and properties.Transparency == nil then
        instance.Transparency = 0.42
    end
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            instance[k] = v
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility:Tween(instance, info, properties, callback)
    if not instance or not instance.Parent then return nil end
    local previous = Library.ActiveTweens[instance]
    if previous then
        pcall(function() previous:Cancel() end)
    end

    local duration = Library.ReducedMotion and 0 or math.max(0, info.Time * Library.MotionScale)
    if duration == 0 then
        for property, value in pairs(properties) do
            instance[property] = value
        end
        if callback then task.defer(callback) end
        return nil
    end

    local tweenInfo = TweenInfo.new(duration, info.EasingStyle, info.EasingDirection, info.RepeatCount, info.Reverses, info.DelayTime)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    Library.ActiveTweens[instance] = tween
    tween:Play()
    if callback then
        Library:Connect(tween.Completed, function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then callback() end
        end)
    end
    return tween
end

function Utility:MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    local dragState = {Moved = false}

    function dragState:ConsumeDrag()
        local moved = self.Moved
        self.Moved = false
        return moved
    end

    local function keepRecoverable()
        if not object or not object.Parent then return end
        local viewport = getViewport()
        local position = object.AbsolutePosition
        local size = object.AbsoluteSize
        local minimumVisible = math.min(52, math.max(28, viewport.X * 0.12))
        local deltaX, deltaY = 0, 0
        if position.X + size.X < minimumVisible then
            deltaX = minimumVisible - (position.X + size.X)
        elseif position.X > viewport.X - minimumVisible then
            deltaX = (viewport.X - minimumVisible) - position.X
        end
        if position.Y + 40 < 0 then
            deltaY = -(position.Y + 40)
        elseif position.Y > viewport.Y - minimumVisible then
            deltaY = (viewport.Y - minimumVisible) - position.Y
        end
        if deltaX ~= 0 or deltaY ~= 0 then
            local scale = math.max(0.01, Library.DPIScale)
            object.Position = UDim2.new(
                object.Position.X.Scale,
                object.Position.X.Offset + deltaX / scale,
                object.Position.Y.Scale,
                object.Position.Y.Offset + deltaY / scale
            )
        end
    end

    Library:Connect(topbar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragState.Moved = false
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = object.Position
            dragInput = input.UserInputType == Enum.UserInputType.Touch and input or nil

            Library:Connect(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    task.defer(keepRecoverable)
                end
            end)
        end
    end)

    Library:Connect(topbar.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    Library:Connect(UserInputService.InputChanged, function(input)
        local isPointerMove = input.UserInputType == Enum.UserInputType.MouseMovement
            or (input.UserInputType == Enum.UserInputType.Touch and input == dragInput)
        if dragging and isPointerMove then
            local pointer = Vector2.new(input.Position.X, input.Position.Y)
            local delta = (pointer - dragStart) / math.max(0.01, Library.DPIScale)
            if delta.Magnitude >= 4 then dragState.Moved = true end
            object.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    return dragState
end

function Utility:GetColor(colorKey)
    if type(colorKey) == "string" then
        return Library.Theme[colorKey] or Color3.new(1,1,1)
    end
    return colorKey
end

function Utility:RegisterProperty(instance, property, colorKey)
    if not Library.Registry[instance] then
        Library.Registry[instance] = {}
    end
    Library.Registry[instance][property] = colorKey
    instance[property] = Utility:GetColor(colorKey)
end

function Utility:RegisterGradient(instance, firstKey, secondKey)
    Library.GradientRegistry[instance] = {firstKey, secondKey}
    instance.Color = ColorSequence.new(Utility:GetColor(firstKey), Utility:GetColor(secondKey))
end

--// DYNAMIC THEME UPDATE
function Library:UpdateColors()
    for instance, props in pairs(self.Registry) do
        for prop, colorKey in pairs(props) do
            pcall(function()
                instance[prop] = Utility:GetColor(colorKey)
            end)
        end
    end
    for gradient, keys in pairs(self.GradientRegistry) do
        pcall(function()
            gradient.Color = ColorSequence.new(Utility:GetColor(keys[1]), Utility:GetColor(keys[2]))
        end)
    end
end

function Library:SetTheme(newTheme)
    for k, v in pairs(newTheme) do
        self.Theme[k] = v
    end
    self:UpdateColors()
end

function Library:ApplyThemePreset(name)
    local preset = self.ThemePresets[name]
    if not preset then
        return false, "Unknown theme preset: " .. tostring(name)
    end
    self:SetTheme(preset)
    self.ActiveTheme = name
    return true
end

function Library:SetReducedMotion(enabled)
    self.ReducedMotion = enabled == true
end

function Library:SetMotionScale(scale)
    self.MotionScale = math.clamp(tonumber(scale) or 1, 0, 2)
end

--// DPI SCALING
function Library:SetDPIScale(percent)
    percent = math.clamp(tonumber(percent) or 100, 60, 150)
    local scale = percent / 100
    for _, uiScale in ipairs(self.Scales) do
        uiScale.Scale = scale
    end
    self.DPIScale = scale
    if self.Window and self.Window.ApplyResponsiveLayout then
        task.defer(function()
            if self.Window and not self.Unloaded then self.Window:ApplyResponsiveLayout(true) end
        end)
    end
    return percent
end

function Library:KeepDPIScale(token)
    local preview = self.ScalePreview
    if not preview or (token and preview.Token ~= token) then return false end
    preview.Kept = true
    self.ScalePreview = nil
    return true
end

function Library:RevertDPIScale(token)
    local preview = self.ScalePreview
    if not preview or (token and preview.Token ~= token) then return false end
    self.ScalePreview = nil
    self:SetDPIScale(preview.OriginalPercent)
    self.Flags.__RenLibScale = preview.OriginalPercent
    local scaleOption = self.Options.__RenLibScale
    if scaleOption and scaleOption.SetSilent then scaleOption:SetSilent(preview.OriginalPercent) end
    return true
end

function Library:PreviewDPIScale(percent, timeout)
    timeout = math.clamp(tonumber(timeout) or 10, 5, 30)
    local activePreview = self.ScalePreview
    local originalPercent = activePreview and activePreview.OriginalPercent or math.floor(self.DPIScale * 100 + 0.5)
    local token = Utility:RandomString(12)
    local candidate = self:SetDPIScale(percent)
    self.Flags.__RenLibScale = candidate
    self.ScalePreview = {
        Token = token,
        OriginalPercent = originalPercent,
        CandidatePercent = candidate,
        Kept = false
    }

    if self.Notify then
        self:Notify({
            Title = "Keep this UI size?",
            Content = tostring(candidate) .. "% preview. It will reset in " .. tostring(timeout) .. " seconds unless you keep it.",
            Duration = timeout,
            Actions = {
                {Name = "Keep", Callback = function()
                    if self:KeepDPIScale(token) and self.Notify then
                        self:Notify({Title = "UI size kept", Content = tostring(candidate) .. "%", Duration = 2})
                    end
                end},
                {Name = "Revert", Callback = function()
                    if self:RevertDPIScale(token) and self.Notify then
                        self:Notify({Title = "UI size restored", Content = tostring(originalPercent) .. "%", Duration = 2})
                    end
                end}
            }
        })
    end

    task.delay(timeout, function()
        local preview = self.ScalePreview
        if preview and preview.Token == token and not preview.Kept then
            self:RevertDPIScale(token)
            if self.Notify and not self.Unloaded then
                self:Notify({Title = "UI size restored", Content = "The preview timed out safely.", Duration = 3})
            end
        end
    end)
    return token
end

local function hasFileSystem()
    return type(isfolder) == "function" and type(makefolder) == "function"
        and type(isfile) == "function" and type(readfile) == "function"
        and type(writefile) == "function"
end

local function ensureConfigFolders()
    if not hasFileSystem() then return false end
    if not isfolder("RenLib") then makefolder("RenLib") end
    if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    return true
end

local function cleanConfigName(name)
    return tostring(name or "default"):gsub("[^%w_%-%s]", ""):sub(1, 64)
end

local function encodeValue(value)
    if typeof(value) == "Color3" then
        return {__type = "Color3", r = value.R, g = value.G, b = value.B}
    elseif type(value) == "table" then
        local encoded = {}
        for key, item in pairs(value) do encoded[key] = encodeValue(item) end
        return encoded
    end
    return value
end

local function decodeValue(value)
    if type(value) == "table" and value.__type == "Color3" then
        return Color3.new(value.r or 1, value.g or 1, value.b or 1)
    elseif type(value) == "table" then
        local decoded = {}
        for key, item in pairs(value) do decoded[key] = decodeValue(item) end
        return decoded
    end
    return value
end

function Library:SaveConfig(name)
    if not ensureConfigFolders() then return false, "Filesystem APIs are unavailable" end
    local payload = {version = self.Version, flags = {}}
    for flag, value in pairs(self.Flags) do payload.flags[flag] = encodeValue(value) end
    local ok, result = pcall(function()
        writefile(CONFIG_FOLDER .. "/" .. cleanConfigName(name) .. ".json", HttpService:JSONEncode(payload))
    end)
    return ok, ok and nil or result
end

function Library:LoadConfig(name)
    if not ensureConfigFolders() then return false, "Filesystem APIs are unavailable" end
    local path = CONFIG_FOLDER .. "/" .. cleanConfigName(name) .. ".json"
    if not isfile(path) then return false, "Config does not exist" end
    local ok, payload = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or type(payload) ~= "table" then return false, payload end
    for flag, rawValue in pairs(payload.flags or {}) do
        local value = decodeValue(rawValue)
        self.Flags[flag] = value
        local option = self.Options[flag]
        if option and option.Set then Utility:SafeCall(function() option:Set(value) end) end
    end
    return true
end

function Library:DeleteConfig(name)
    if not ensureConfigFolders() or type(delfile) ~= "function" then return false, "Delete API is unavailable" end
    local path = CONFIG_FOLDER .. "/" .. cleanConfigName(name) .. ".json"
    if isfile(path) then delfile(path) end
    return true
end

function Library:SetAutoloadConfig(name)
    if not ensureConfigFolders() then return false, "Filesystem APIs are unavailable" end
    writefile("RenLib/autoload.txt", cleanConfigName(name))
    return true
end

function Library:LoadAutoloadConfig()
    if not ensureConfigFolders() or not isfile("RenLib/autoload.txt") then return false, "No autoload config" end
    return self:LoadConfig(readfile("RenLib/autoload.txt"))
end

function Library:LaunchInfiniteYield()
    if type(loadstring) ~= "function" then
        if self.Notify then self:Notify({Title = "Infinite Yield unavailable", Content = "This environment does not expose loadstring.", Duration = 4}) end
        return false, "loadstring is unavailable"
    end

    local ok, source = pcall(function()
        return game:HttpGet(INFINITE_YIELD_URL)
    end)
    if not ok or type(source) ~= "string" or source == "" then
        if self.Notify then self:Notify({Title = "Infinite Yield failed", Content = tostring(source), Duration = 5}) end
        return false, source
    end

    local chunk, compileError = loadstring(source)
    if not chunk then
        if self.Notify then self:Notify({Title = "Infinite Yield failed", Content = tostring(compileError), Duration = 5}) end
        return false, compileError
    end

    task.spawn(function()
        local ran, runtimeError = pcall(chunk)
        if not ran and self.Notify and not self.Unloaded then
            self:Notify({Title = "Infinite Yield error", Content = tostring(runtimeError), Duration = 5})
        end
    end)
    if self.Notify then self:Notify({Title = "Infinite Yield launched", Content = "Loaded from the official EdgeIY source.", Duration = 3}) end
    return true
end

--// CORE UI: WINDOW
function Library:CreateWindow(options)
    options = options or {}
    local WindowTitle = options.Name or "RenLib"
    local EnableSidebarResize = options.EnableSidebarResize == nil and true or options.EnableSidebarResize
    local EnableGlobalSearch = options.EnableGlobalSearch == nil and true or options.EnableGlobalSearch
    local SidebarCompactMode = options.SidebarCompactMode or false
    local WindowIcon = Utility:NormalizeAssetId(options.Icon or options.Logo)
    local SettingsIcon = Utility:NormalizeAssetId(options.SettingsIcon, ICONS.Settings)
    local ShowUserProfile = options.ShowUserProfile == nil and true or options.ShowUserProfile

    local function createWindowMark(parent, textSize, zIndex)
        if WindowIcon then
            local mark = Utility:Create("ImageLabel", {
                Parent = parent,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.18, 0.18),
                Size = UDim2.fromScale(0.64, 0.64),
                Image = WindowIcon,
                ImageColor3 = Library.Theme.Text,
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = zIndex
            })
            Utility:RegisterProperty(mark, "ImageColor3", "Text")
            return mark
        end
        local mark = Utility:Create("TextLabel", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Font = Enum.Font.GothamBold,
            Text = EMOJIS.Code,
            TextColor3 = Library.Theme.Accent,
            TextSize = textSize,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = zIndex
        })
        Utility:RegisterProperty(mark, "TextColor3", "Accent")
        return mark
    end

    if self.ScreenGui then
        pcall(function() self.ScreenGui:Destroy() end)
        self.ScreenGui = nil
    end
    self.Unloaded = false
    DeviceMode = getDeviceMode(self.DPIScale)
    IsMobile = DeviceMode ~= "Desktop"
    self.DeviceMode = DeviceMode
    self.IsMobile = IsMobile

    -- Calculate sizes based on device
    local initialViewport = getViewport()
    local initialLayoutWidth = initialViewport.X / math.max(self.DPIScale, 0.01)
    local initialLayoutHeight = initialViewport.Y / math.max(self.DPIScale, 0.01)
    local WinWidth, WinHeight, SidebarWidth, FontScale
    if IsMobile then
        WinWidth = math.min(720, math.max(1, initialLayoutWidth - 12))
        WinHeight = math.min(680, math.max(1, initialLayoutHeight - 12))
        SidebarWidth = WinWidth < 340 and 54 or 60
        FontScale = 0.9
        EnableSidebarResize = false
    else
        WinWidth = math.min(options.Width or 880, math.max(1, initialLayoutWidth - 32))
        WinHeight = math.min(options.Height or 580, math.max(1, initialLayoutHeight - 32))
        SidebarWidth = 190
        FontScale = 1
    end

    -- Main ScreenGui with UIScale for DPI
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "RenLibV6_" .. Utility:RandomString(8),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = options.DisplayOrder or 1000
    })
    ScreenGui:SetAttribute("RenLibVersion", Library.Version)
    local uiScale = Utility:Create("UIScale", {Parent = ScreenGui})
    table.insert(Library.Scales, uiScale)

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
    Library.ScreenGui = ScreenGui

    -- Main Container
    local MainFrame = Utility:Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Library.Theme.Main,
        Position = UDim2.new(0.5, -WinWidth / 2, 0.5, -WinHeight / 2),
        Size = UDim2.new(0, WinWidth, 0, WinHeight),
        ClipsDescendants = false,
        ZIndex = 1,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(MainFrame, "BackgroundColor3", "Main")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = MainFrame})
    local mainGradient = Utility:Create("UIGradient", {Parent = MainFrame, Rotation = 115})
    Utility:RegisterGradient(mainGradient, "Main", "Secondary")
    local WindowScale = Utility:Create("UIScale", {Parent = MainFrame, Scale = 1})
    local mainStroke = Utility:Create("UIStroke", {Parent = MainFrame, Color = Library.Theme.Stroke, Thickness = 1})
    Utility:RegisterProperty(mainStroke, "Color", "Stroke")
    local ambientRail = Utility:Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Accent,
        BackgroundTransparency = 0.18,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -28, 0, 2),
        BorderSizePixel = 0,
        ZIndex = 92
    })
    Utility:RegisterProperty(ambientRail, "BackgroundColor3", "Accent")
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ambientRail})
    local ambientGradient = Utility:Create("UIGradient", {Parent = ambientRail})
    Utility:RegisterGradient(ambientGradient, "Accent", "Accent2")

    -- Shadow
    local Shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -25, 0, -25),
        Size = UDim2.new(1, 50, 1, 50),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.22,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0
    })

    -- Sidebar
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Secondary,
        Size = UDim2.new(0, SidebarWidth, 1, 0),
        ZIndex = 2,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(Sidebar, "BackgroundColor3", "Secondary")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = Sidebar})
    local sidebarGradient = Utility:Create("UIGradient", {Parent = Sidebar, Rotation = 90})
    Utility:RegisterGradient(sidebarGradient, "Secondary", "Main")
    local sidebarDivider = Utility:Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Divider,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        ZIndex = 3
    })
    Utility:RegisterProperty(sidebarDivider, "BackgroundColor3", "Divider")

    local TabContainer = Utility:Create("ScrollingFrame", {
        Name = "Tabs",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, IsMobile and 0 or 8, 0, IsMobile and 70 or 78),
        Size = UDim2.new(1, IsMobile and 0 or -16, 1, IsMobile and -122 or -142),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
        Active = true,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 4,
        BorderSizePixel = 0
    })

    local TabLayout = Utility:Create("UIListLayout", {
        Parent = TabContainer,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, IsMobile and 8 or 6)
    })

    Library:Connect(TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
    end)

    -- LOGO
    local logoSize = IsMobile and 32 or 40
    local LogoContainer = Utility:Create("Frame", {
        Name = "LogoContainer",
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Main,
        Position = IsMobile and UDim2.new(0.5, -logoSize / 2, 0, 14) or UDim2.fromOffset(14, 16),
        Size = UDim2.new(0, logoSize, 0, logoSize),
        ZIndex = 100,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(LogoContainer, "BackgroundColor3", "Main")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = LogoContainer})
    local logoStroke = Utility:Create("UIStroke", {Parent = LogoContainer, Color = Library.Theme.Accent, Thickness = 2})
    Utility:RegisterProperty(logoStroke, "Color", "Accent")

    local Logo = createWindowMark(LogoContainer, IsMobile and 14 or 18, 101)
    Logo.Name = "Logo"

    local BrandLabel = Utility:Create("TextLabel", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(64, 15),
        Size = UDim2.new(1, -76, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = Library.Title,
        TextColor3 = Library.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = not IsMobile,
        ZIndex = 101
    })
    Utility:RegisterProperty(BrandLabel, "TextColor3", "Text")
    local BrandSubtitle = Utility:Create("TextLabel", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(64, 36),
        Size = UDim2.new(1, -76, 0, 18),
        Font = Enum.Font.Gotham,
        Text = "Interface Suite",
        TextColor3 = Library.Theme.SubText,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = not IsMobile,
        ZIndex = 101
    })
    Utility:RegisterProperty(BrandSubtitle, "TextColor3", "SubText")

    -- SETTINGS BUTTON
    local settingsBtnSize = IsMobile and 36 or 44
    local SettingsBtn = Utility:Create("TextButton", {
        Name = "SettingsBtn",
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Accent,
        BackgroundTransparency = 1,
        Position = IsMobile and UDim2.new(0.5, -settingsBtnSize / 2, 1, -(settingsBtnSize + 12)) or UDim2.new(0, 10, 1, -54),
        Size = IsMobile and UDim2.fromOffset(settingsBtnSize, settingsBtnSize) or UDim2.new(1, -20, 0, 42),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 100,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(SettingsBtn, "BackgroundColor3", "Accent")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SettingsBtn})
    local settingsGradient = Utility:Create("UIGradient", {Parent = SettingsBtn, Rotation = 18})
    Utility:RegisterGradient(settingsGradient, "Accent", "Accent2")

    local SettingsEmoji = Utility:Create("ImageLabel", {
        Parent = SettingsBtn,
        BackgroundTransparency = 1,
        Position = IsMobile and UDim2.fromScale(0.18, 0.18) or UDim2.fromOffset(8, 5),
        Size = IsMobile and UDim2.fromScale(0.64, 0.64) or UDim2.fromOffset(32, 32),
        Image = SettingsIcon,
        ImageColor3 = Library.Theme.SubText,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 101
    })
    Utility:RegisterProperty(SettingsEmoji, "ImageColor3", "SubText")

    local SettingsLabel = Utility:Create("TextLabel", {
        Parent = SettingsBtn, BackgroundTransparency = 1,
        Position = UDim2.fromOffset(48, 0), Size = UDim2.new(1, -58, 1, 0),
        Font = Enum.Font.Gotham, Text = "Settings", TextColor3 = Library.Theme.SubText,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        Visible = not IsMobile, ZIndex = 101
    })
    Utility:RegisterProperty(SettingsLabel, "TextColor3", "SubText")

    local SettingsIndicator = Utility:Create("Frame", {
        Parent = SettingsBtn,
        BackgroundColor3 = Library.Theme.Accent,
        Position = UDim2.new(0, 0, 0.5, -10),
        Size = UDim2.new(0, 4, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 102,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(SettingsIndicator, "BackgroundColor3", "Accent")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = SettingsIndicator})

    -- USER PROFILE
    local ProfileCard, ProfileAvatar, ProfileNameLabel, ProfileSubtitleLabel, ProfileStroke
    local ProfileCompact = IsMobile
    local SetProfileData = function() end
    if ShowUserProfile then
        ProfileCard = Utility:Create("Frame", {
            Name = "UserProfile",
            Parent = Sidebar,
            BackgroundColor3 = Library.Theme.Surface,
            BackgroundTransparency = ProfileCompact and 1 or 0,
            Position = ProfileCompact and UDim2.new(0.5, -19, 1, -(settingsBtnSize + 62)) or UDim2.new(0, 10, 1, -110),
            Size = ProfileCompact and UDim2.fromOffset(38, 38) or UDim2.new(1, -20, 0, 48),
            ClipsDescendants = true,
            ZIndex = 98,
            BorderSizePixel = 0
        })
        Utility:RegisterProperty(ProfileCard, "BackgroundColor3", "Surface")
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 9), Parent = ProfileCard})
        ProfileStroke = Utility:Create("UIStroke", {Parent = ProfileCard, Color = Library.Theme.Stroke, Thickness = 1, Enabled = not ProfileCompact})
        Utility:RegisterProperty(ProfileStroke, "Color", "Stroke")

        ProfileAvatar = Utility:Create("ImageLabel", {
            Parent = ProfileCard,
            BackgroundColor3 = Library.Theme.SurfaceAlt,
            Position = ProfileCompact and UDim2.fromScale(0, 0) or UDim2.fromOffset(6, 6),
            Size = ProfileCompact and UDim2.fromScale(1, 1) or UDim2.fromOffset(36, 36),
            Image = Utility:NormalizeAssetId(options.ProfileAvatar, ICONS.Profile),
            ImageColor3 = Color3.new(1, 1, 1),
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 99
        })
        Utility:RegisterProperty(ProfileAvatar, "BackgroundColor3", "SurfaceAlt")
        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ProfileAvatar})
        local avatarStroke = Utility:Create("UIStroke", {Parent = ProfileAvatar, Color = Library.Theme.Accent, Thickness = 1})
        Utility:RegisterProperty(avatarStroke, "Color", "Accent")

        ProfileNameLabel = Utility:Create("TextLabel", {
            Parent = ProfileCard,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(50, 7),
            Size = UDim2.new(1, -58, 0, 18),
            Font = Enum.Font.GothamMedium,
            Text = tostring(options.ProfileTitle or Plr.DisplayName or Plr.Name),
            TextColor3 = Library.Theme.Text,
            TextSize = 11,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not ProfileCompact,
            ZIndex = 99
        })
        Utility:RegisterProperty(ProfileNameLabel, "TextColor3", "Text")
        ProfileSubtitleLabel = Utility:Create("TextLabel", {
            Parent = ProfileCard,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(50, 24),
            Size = UDim2.new(1, -58, 0, 16),
            Font = Enum.Font.Gotham,
            Text = tostring(options.ProfileSubtitle or ("@" .. Plr.Name)),
            TextColor3 = Library.Theme.SubText,
            TextSize = 9,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not ProfileCompact,
            ZIndex = 99
        })
        Utility:RegisterProperty(ProfileSubtitleLabel, "TextColor3", "SubText")

        local ProfileButton = Utility:Create("TextButton", {
            Parent = ProfileCard,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 100
        })
        Library:Connect(ProfileButton.MouseEnter, function()
            if not ProfileCompact then Utility:Tween(ProfileCard, TweenInfo.new(0.15), {BackgroundColor3 = Library.Theme.Hover}) end
        end)
        Library:Connect(ProfileButton.MouseLeave, function()
            Utility:Tween(ProfileCard, TweenInfo.new(0.15), {BackgroundColor3 = Library.Theme.Surface})
        end)
        Library:Connect(ProfileButton.MouseButton1Click, function()
            Utility:SafeCall(options.OnProfileClick, Plr)
        end)

        SetProfileData = function(data)
            data = data or {}
            if data.Title ~= nil then ProfileNameLabel.Text = tostring(data.Title) end
            if data.Subtitle ~= nil then ProfileSubtitleLabel.Text = tostring(data.Subtitle) end
            local customAvatar = Utility:NormalizeAssetId(data.Avatar)
            if customAvatar then ProfileAvatar.Image = customAvatar end
        end

        if not Utility:NormalizeAssetId(options.ProfileAvatar) then
            local profileUserId = tonumber(options.ProfileUserId) or Plr.UserId
            task.spawn(function()
                local ok, thumbnail = pcall(function()
                    return Players:GetUserThumbnailAsync(profileUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                end)
                if ok and ProfileAvatar and ProfileAvatar.Parent then ProfileAvatar.Image = thumbnail end
            end)
        end
    end

    local function getNavigationBottomInset(compact, mobile, hideProfile)
        if ShowUserProfile and not hideProfile then return compact and 170 or 202 end
        return mobile and 122 or 142
    end

    local function applyProfileLayout(compact, hidden)
        ProfileCompact = compact
        if not ProfileCard then return end
        ProfileCard.Visible = not hidden
        ProfileCard.BackgroundTransparency = compact and 1 or 0
        ProfileCard.Position = compact and UDim2.new(0.5, -19, 1, -(settingsBtnSize + 62)) or UDim2.new(0, 10, 1, -110)
        ProfileCard.Size = compact and UDim2.fromOffset(38, 38) or UDim2.new(1, -20, 0, 48)
        ProfileAvatar.Position = compact and UDim2.fromScale(0, 0) or UDim2.fromOffset(6, 6)
        ProfileAvatar.Size = compact and UDim2.fromScale(1, 1) or UDim2.fromOffset(36, 36)
        ProfileNameLabel.Visible = not compact
        ProfileSubtitleLabel.Visible = not compact
        ProfileStroke.Enabled = not compact
    end

    applyProfileLayout(IsMobile)
    TabContainer.Size = UDim2.new(1, IsMobile and 0 or -16, 1, -getNavigationBottomInset(IsMobile, IsMobile))

    -- Content Area
    local Pages = Utility:Create("Frame", {
        Name = "Pages",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, SidebarWidth, 0, 0),
        Size = UDim2.new(1, -SidebarWidth, 1, 0),
        ClipsDescendants = true,
        ZIndex = 1,
        BorderSizePixel = 0
    })

    -- TOP BAR
    local TopBar = Utility:Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, IsMobile and 88 or 60),
        ZIndex = 100,
        BorderSizePixel = 0
    })

    Utility:MakeDraggable(TopBar, MainFrame)

    local TitleLabel = Utility:Create("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, SidebarWidth + 20, 0, IsMobile and 13 or 16),
        Size = UDim2.new(0, 200, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = WindowTitle,
        TextColor3 = Library.Theme.Text,
        TextSize = IsMobile and 17 or 19,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101
    })
    Utility:RegisterProperty(TitleLabel, "TextColor3", "Text")

    local TopDivider = Utility:Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Divider,
        Position = UDim2.new(0, SidebarWidth, 0, IsMobile and 87 or 59),
        Size = UDim2.new(1, -SidebarWidth, 0, 1),
        BorderSizePixel = 0,
        ZIndex = 90
    })
    Utility:RegisterProperty(TopDivider, "BackgroundColor3", "Divider")

    -- MINIMIZE BUTTON
    local MinimizeBtn = Utility:Create("TextButton", {
        Name = "MinimizeBtn",
        Parent = TopBar,
        BackgroundColor3 = Library.Theme.Surface,
        Position = UDim2.new(1, -80, 0, IsMobile and 10 or 15),
        Size = UDim2.new(0, IsMobile and 26 or 28, 0, IsMobile and 26 or 28),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 101,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(MinimizeBtn, "BackgroundColor3", "Surface")
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = MinimizeBtn})

    local MinimizeIcon = Utility:Create("ImageLabel", {
        Parent = MinimizeBtn,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.22, 0.22),
        Size = UDim2.fromScale(0.56, 0.56),
        Image = ICONS.Minimize,
        ImageColor3 = Library.Theme.SubText,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 102
    })
    Utility:RegisterProperty(MinimizeIcon, "ImageColor3", "SubText")

    -- CLOSE BUTTON
    local CloseBtn = Utility:Create("TextButton", {
        Name = "CloseBtn",
        Parent = TopBar,
        BackgroundColor3 = Library.Theme.Surface,
        Position = UDim2.new(1, -40, 0, IsMobile and 10 or 15),
        Size = UDim2.new(0, IsMobile and 26 or 28, 0, IsMobile and 26 or 28),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 101,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(CloseBtn, "BackgroundColor3", "Surface")
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = CloseBtn})

    local CloseIcon = Utility:Create("ImageLabel", {
        Parent = CloseBtn,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.22, 0.22),
        Size = UDim2.fromScale(0.56, 0.56),
        Image = ICONS.Close,
        ImageColor3 = Library.Theme.SubText,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 102
    })
    Utility:RegisterProperty(CloseIcon, "ImageColor3", "SubText")

    -- SEARCH BOX (Global Search)
    local SearchBox = nil
    if EnableGlobalSearch then
        SearchBox = Utility:Create("TextBox", {
            Parent = TopBar,
            BackgroundColor3 = Library.Theme.Surface,
            Position = IsMobile and UDim2.new(0, SidebarWidth + 12, 0, 50) or UDim2.new(1, -360, 0, 15),
            Size = IsMobile and UDim2.new(1, -(SidebarWidth + 24), 0, 30) or UDim2.new(0, 250, 0, 30),
            PlaceholderText = "Search controls...",
            Text = "",
            TextColor3 = Library.Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = IsMobile and 12 or 14,
            ClearTextOnFocus = false,
            ZIndex = 101,
            BorderSizePixel = 0
        })
        Utility:RegisterProperty(SearchBox, "BackgroundColor3", "Surface")
        Utility:RegisterProperty(SearchBox, "TextColor3", "Text")
        Utility:RegisterProperty(SearchBox, "PlaceholderColor3", "SubText")
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SearchBox})
        Utility:Create("UIPadding", {Parent = SearchBox, PaddingLeft = UDim.new(0, 34), PaddingRight = UDim.new(0, 10)})
        local SearchIcon = Utility:Create("ImageLabel", {
            Parent = SearchBox,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, -25, 0.5, -8),
            Size = UDim2.fromOffset(16, 16),
            Image = ICONS.Search,
            ImageColor3 = Library.Theme.SubText,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 102
        })
        Utility:RegisterProperty(SearchIcon, "ImageColor3", "SubText")
        local searchStroke = Utility:Create("UIStroke", {Parent = SearchBox, Color = Library.Theme.Stroke, Thickness = 1})
        Utility:RegisterProperty(searchStroke, "Color", "Stroke")
    end

    -- Notification Container
    local NotifyArea = Utility:Create("Frame", {
        Name = "Notifications",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, IsMobile and -220 or -320, 1, -20),
        Size = UDim2.new(0, IsMobile and 200 or 300, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        ZIndex = 200
    })
    Utility:Create("UIListLayout", {
        Parent = NotifyArea,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })

    -- Minimized Icon
    local MinimizedIcon = Utility:Create("Frame", {
        Name = "MinimizedIcon",
        Parent = ScreenGui,
        BackgroundColor3 = Library.Theme.Main,
        Position = UDim2.new(1, -70, 0, 20),
        Size = UDim2.new(0, 50, 0, 50),
        Visible = false,
        ZIndex = 300,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(MinimizedIcon, "BackgroundColor3", "Main")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MinimizedIcon})
    local minIconStroke = Utility:Create("UIStroke", {Parent = MinimizedIcon, Color = Library.Theme.Accent, Thickness = 2})
    Utility:RegisterProperty(minIconStroke, "Color", "Accent")
    local MinimizedLogo = createWindowMark(MinimizedIcon, 20, 301)
    local MinIconBtn = Utility:Create("TextButton", {
        Parent = MinimizedIcon,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 302
    })

    -- Mobile Toggle Button
    local MobileToggleBtn
    do
        MobileToggleBtn = Utility:Create("Frame", {
            Name = "MobileToggle",
            Parent = ScreenGui,
            BackgroundColor3 = Library.Theme.Main,
            Position = UDim2.new(0, 10, 0.5, -25),
            Size = UDim2.new(0, 40, 0, 40),
            Visible = false,
            ZIndex = 400,
            BorderSizePixel = 0
        })
        Utility:RegisterProperty(MobileToggleBtn, "BackgroundColor3", "Main")
        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = MobileToggleBtn})
        local mobileStroke = Utility:Create("UIStroke", {Parent = MobileToggleBtn, Color = Library.Theme.Accent, Thickness = 2})
        Utility:RegisterProperty(mobileStroke, "Color", "Accent")
        local MobileToggleLogo = createWindowMark(MobileToggleBtn, 16, 401)
        local MobileToggleTapBtn = Utility:Create("TextButton", {
            Parent = MobileToggleBtn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 402
        })
        local mobileToggleDrag = Utility:MakeDraggable(MobileToggleTapBtn, MobileToggleBtn)
        Library:Connect(MobileToggleTapBtn.MouseButton1Click, function()
            if mobileToggleDrag:ConsumeDrag() then return end
            if Library.IsMinimized then
                Library.IsMinimized = false
                MinimizedIcon.Visible = false
                MainFrame.Visible = true
                MobileToggleBtn.Visible = false
            else
                MainFrame.Visible = not MainFrame.Visible
                if not MainFrame.Visible then
                    MobileToggleBtn.Visible = true
                end
            end
        end)
    end

    -- Window Object (declared early so resizer can reference it)
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Gui = ScreenGui,
        Main = MainFrame,
        SettingsTab = nil,
        SearchBox = SearchBox
    }

    function Window:SetProfile(data)
        SetProfileData(data)
    end

    -- RESIZABLE SIDEBAR (PC only)
    local sidebarResizer = nil
    local dividerLine = nil
    local currentSidebarWidth = SidebarWidth
    local isCompact = SidebarCompactMode
    if EnableSidebarResize and not IsMobile then
        dividerLine = Utility:Create("Frame", {
            Parent = MainFrame,
            BackgroundColor3 = Library.Theme.Stroke,
            Position = UDim2.new(0, SidebarWidth, 0, 0),
            Size = UDim2.new(0, 1, 1, 0),
            ZIndex = 5,
            BorderSizePixel = 0
        })
        Utility:RegisterProperty(dividerLine, "BackgroundColor3", "Stroke")
        sidebarResizer = Utility:Create("TextButton", {
            Parent = dividerLine,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 4, 1, 0),
            Position = UDim2.new(1, -2, 0, 0),
            Text = "",
            ZIndex = 6,
            AutoButtonColor = false
        })
        local dragging = false
        local startX, startWidth
        Library:Connect(sidebarResizer.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                startX = input.Position.X
                startWidth = currentSidebarWidth
                Library:Connect(input.Changed, function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        Library:Connect(UserInputService.InputChanged, function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position.X - startX
                local newWidth = math.clamp(startWidth + delta, 62, 240)
                currentSidebarWidth = newWidth
                Sidebar.Size = UDim2.new(0, newWidth, 1, 0)
                dividerLine.Position = UDim2.new(0, newWidth, 0, 0)
                Pages.Position = UDim2.new(0, newWidth, 0, 0)
                Pages.Size = UDim2.new(1, -newWidth, 1, 0)
                TitleLabel.Position = UDim2.new(0, newWidth + 16, 0, IsMobile and 14 or 20)
                isCompact = newWidth < 132
                LogoContainer.Position = isCompact and UDim2.new(0.5, -logoSize / 2, 0, 16) or UDim2.fromOffset(14, 16)
                BrandLabel.Visible = not isCompact
                BrandSubtitle.Visible = not isCompact
                TabContainer.Position = UDim2.new(0, isCompact and 0 or 8, 0, 78)
                TabContainer.Size = UDim2.new(1, isCompact and 0 or -16, 1, -getNavigationBottomInset(isCompact, false))
                SettingsBtn.Position = isCompact and UDim2.new(0.5, -settingsBtnSize / 2, 1, -(settingsBtnSize + 12)) or UDim2.new(0, 10, 1, -54)
                SettingsBtn.Size = isCompact and UDim2.fromOffset(settingsBtnSize, settingsBtnSize) or UDim2.new(1, -20, 0, 42)
                SettingsEmoji.Position = isCompact and UDim2.fromScale(0.18, 0.18) or UDim2.fromOffset(8, 5)
                SettingsEmoji.Size = isCompact and UDim2.fromScale(0.64, 0.64) or UDim2.fromOffset(32, 32)
                SettingsLabel.Visible = not isCompact
                applyProfileLayout(isCompact)
                for _, tab in ipairs(Window.Tabs) do
                    if tab.ApplyNavigationLayout then tab:ApplyNavigationLayout(false, isCompact) end
                end
            end
        end)
    end

    local lastDeviceMode = DeviceMode
    function Window:ApplyResponsiveLayout(recenter)
        local viewport = getViewport()
        local scale = math.max(Library.DPIScale, 0.01)
        local layoutViewport = Vector2.new(viewport.X / scale, viewport.Y / scale)
        local mode = getDeviceMode(scale)
        local mobile = mode ~= "Desktop"
        local horizontalMargin = mobile and 6 or 16
        local verticalMargin = mobile and 6 or 16
        local maximumWidth = math.max(1, layoutViewport.X - horizontalMargin * 2)
        local maximumHeight = math.max(1, layoutViewport.Y - verticalMargin * 2)
        local width = math.min(mobile and 720 or (options.Width or 880), maximumWidth)
        local height = math.min(mobile and 680 or (options.Height or 580), maximumHeight)
        if self.Maximized then
            width = maximumWidth
            height = maximumHeight
        end
        local sidebarWidth = mobile and (width < 340 and 54 or 60) or math.clamp(currentSidebarWidth, 62, math.min(240, width * 0.32))
        local shortViewport = mobile and height < 420
        local hideSearch = mobile and height < 300
        local hideProfile = height < 380
        local topBarHeight = mobile and (hideSearch and 48 or (shortViewport and 74 or 88)) or 60
        Window.ContentTopInset = topBarHeight

        DeviceMode = mode
        IsMobile = mobile
        Library.DeviceMode = mode
        Library.IsMobile = mobile
        MainFrame.Size = UDim2.fromOffset(width, height)
        local absolutePosition = MainFrame.AbsolutePosition
        local absoluteSize = MainFrame.AbsoluteSize
        local unreachable = absolutePosition.X + absoluteSize.X < 40
            or absolutePosition.Y + 40 < 0
            or absolutePosition.X > viewport.X - 40
            or absolutePosition.Y > viewport.Y - 40
        if recenter or unreachable then
            MainFrame.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
        end
        Sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
        Pages.Position = UDim2.new(0, sidebarWidth, 0, 0)
        Pages.Size = UDim2.new(1, -sidebarWidth, 1, 0)
        isCompact = mobile or sidebarWidth < 132
        TitleLabel.Position = UDim2.new(0, sidebarWidth + 16, 0, mobile and (hideSearch and 9 or 11) or 16)
        TitleLabel.Size = UDim2.new(1, -(sidebarWidth + (mobile and 108 or 430)), 0, 30)
        TitleLabel.TextSize = mobile and 17 or 19
        TopBar.Size = UDim2.new(1, 0, 0, topBarHeight)
        TopDivider.Position = UDim2.new(0, sidebarWidth, 0, topBarHeight - 1)
        TopDivider.Size = UDim2.new(1, -sidebarWidth, 0, 1)
        MinimizeBtn.Position = UDim2.new(1, -76, 0, mobile and 8 or 15)
        CloseBtn.Position = UDim2.new(1, -40, 0, mobile and 8 or 15)
        LogoContainer.Position = isCompact and UDim2.new(0.5, -logoSize / 2, 0, mobile and 14 or 16) or UDim2.fromOffset(14, 16)
        BrandLabel.Visible = not isCompact
        BrandSubtitle.Visible = not isCompact
        TabContainer.Position = UDim2.new(0, isCompact and 0 or 8, 0, mobile and 70 or 78)
        TabContainer.Size = UDim2.new(1, isCompact and 0 or -16, 1, -getNavigationBottomInset(isCompact, mobile, hideProfile))
        SettingsBtn.Position = isCompact and UDim2.new(0.5, -settingsBtnSize / 2, 1, -(settingsBtnSize + 12)) or UDim2.new(0, 10, 1, -54)
        SettingsBtn.Size = isCompact and UDim2.fromOffset(settingsBtnSize, settingsBtnSize) or UDim2.new(1, -20, 0, 42)
        SettingsEmoji.Position = isCompact and UDim2.fromScale(0.18, 0.18) or UDim2.fromOffset(8, 5)
        SettingsEmoji.Size = isCompact and UDim2.fromScale(0.64, 0.64) or UDim2.fromOffset(32, 32)
        SettingsLabel.Visible = not isCompact
        applyProfileLayout(isCompact, hideProfile)
        NotifyArea.Position = UDim2.new(1, mobile and -12 or -20, 1, -20)
        NotifyArea.Size = UDim2.new(0, mobile and math.max(180, math.min(300, layoutViewport.X - 24)) or 300, 1, 0)
        if SearchBox then
            SearchBox.Visible = not hideSearch
            SearchBox.Position = mobile and UDim2.new(0, sidebarWidth + 8, 0, shortViewport and 41 or 50) or UDim2.new(1, -390, 0, 15)
            SearchBox.Size = mobile and UDim2.new(1, -(sidebarWidth + 16), 0, shortViewport and 26 or 30) or UDim2.new(0, 270, 0, 30)
        end
        if dividerLine then dividerLine.Visible = not mobile end
        for _, tab in ipairs(Window.Tabs) do
            if tab.ApplyNavigationLayout then tab:ApplyNavigationLayout(mobile, isCompact) end
            if tab.ApplyResponsiveLayout then
                tab:ApplyResponsiveLayout(mobile, topBarHeight)
            end
        end
        if Library.IsMinimized then
            MobileToggleBtn.Visible = mobile
            MinimizedIcon.Visible = not mobile
        end
        if mode ~= lastDeviceMode then
            lastDeviceMode = mode
            Utility:SafeCall(options.OnDeviceChanged, mode)
        end
        return mode
    end

    function Window:SetTitle(title)
        WindowTitle = tostring(title)
        TitleLabel.Text = WindowTitle
    end

    function Window:SetVisible(visible)
        if visible then Window:Restore() else Window:Minimize() end
    end

    function Window:SetSearch(query)
        if SearchBox then SearchBox.Text = tostring(query or "") end
    end

    local normalPosition = MainFrame.Position
    local normalSize = MainFrame.Size
    function Window:SetMaximized(maximized)
        if maximized and not self.Maximized then
            normalPosition = MainFrame.Position
            normalSize = MainFrame.Size
        end
        self.Maximized = maximized == true
        local viewport = getViewport()
        local scale = math.max(Library.DPIScale, 0.01)
        local margin = 8 / scale
        Utility:Tween(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = self.Maximized and UDim2.fromOffset(margin, margin) or normalPosition,
            Size = self.Maximized and UDim2.fromOffset(viewport.X / scale - margin * 2, viewport.Y / scale - margin * 2) or normalSize
        })
    end

    function Window:Dialog(dialogOptions)
        dialogOptions = dialogOptions or {}
        local overlay = Utility:Create("TextButton", {
            Name = "DialogOverlay", Parent = ScreenGui, BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Text = "",
            AutoButtonColor = false, ZIndex = 800
        })
        local dialogLayoutWidth = getViewport().X / math.max(Library.DPIScale, 0.01)
        local card = Utility:Create("Frame", {
            Parent = overlay, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
            Size = UDim2.fromOffset(math.max(1, math.min(IsMobile and 320 or 400, dialogLayoutWidth - 24)), 0),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Library.Theme.Main,
            BorderSizePixel = 0, ZIndex = 801
        })
        Utility:RegisterProperty(card, "BackgroundColor3", "Main")
        Utility:Create("UICorner", {Parent = card, CornerRadius = UDim.new(0,10)})
        local cardStroke = Utility:Create("UIStroke", {Parent = card, Color = Library.Theme.Stroke, Thickness = 1})
        Utility:RegisterProperty(cardStroke, "Color", "Stroke")
        Utility:Create("UIPadding", {
            Parent = card, PaddingTop = UDim.new(0,16), PaddingBottom = UDim.new(0,16),
            PaddingLeft = UDim.new(0,16), PaddingRight = UDim.new(0,16)
        })
        Utility:Create("UIListLayout", {Parent = card, Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder})
        local dialogTitle = Utility:Create("TextLabel", {
            Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,24),
            Text = tostring(dialogOptions.Title or "Confirm"), TextColor3 = Library.Theme.Text,
            Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 802
        })
        Utility:RegisterProperty(dialogTitle, "TextColor3", "Text")
        local dialogContent = Utility:Create("TextLabel", {
            Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), AutomaticSize = Enum.AutomaticSize.Y,
            Text = tostring(dialogOptions.Content or ""), TextColor3 = Library.Theme.SubText, Font = Enum.Font.Gotham,
            TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 802
        })
        Utility:RegisterProperty(dialogContent, "TextColor3", "SubText")
        local actionBar = Utility:Create("Frame", {Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,34), ZIndex = 802})
        Utility:Create("UIListLayout", {Parent = actionBar, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0,8)})
        local closed = false
        local function close()
            if closed then return end
            closed = true
            Utility:Tween(overlay, TweenInfo.new(0.18), {BackgroundTransparency = 1}, function() if overlay.Parent then overlay:Destroy() end end)
            if Library.ReducedMotion and overlay.Parent then overlay:Destroy() end
        end
        local actions = dialogOptions.Actions or {{Name = "Okay"}}
        for _, action in ipairs(actions) do
            local actionButton = Utility:Create("TextButton", {
                Parent = actionBar, BackgroundColor3 = action.Primary and Library.Theme.Accent or Library.Theme.Hover,
                Size = UDim2.fromOffset(90,32), Text = tostring(action.Name or "Okay"), TextColor3 = Library.Theme.Text,
                Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 803
            })
            Utility:Create("UICorner", {Parent = actionButton, CornerRadius = UDim.new(0,6)})
            Library:Connect(actionButton.MouseButton1Click, function()
                Utility:SafeCall(action.Callback)
                if action.Close ~= false then close() end
            end)
        end
        Library:Connect(overlay.MouseButton1Click, function() if dialogOptions.Dismissable ~= false then close() end end)
        Utility:Tween(overlay, TweenInfo.new(0.18), {BackgroundTransparency = 0.35})
        return {Close = close, Frame = card}
    end

    Window:ApplyResponsiveLayout(true)
    if Camera then
        Library:Connect(Camera:GetPropertyChangedSignal("ViewportSize"), function()
            Window:ApplyResponsiveLayout(false)
        end)
    end

    -- MINIMIZE/RESTORE/CLOSE
    local visibilityToken = 0
    function Window:Minimize()
        if Library.IsMinimized then return end
        visibilityToken = visibilityToken + 1
        local token = visibilityToken
        Library.IsMinimized = true
        if IsMobile then
            if MobileToggleBtn then
                MobileToggleBtn.Visible = true
            end
        else
            MinimizedIcon.Visible = true
        end
        Utility:Tween(WindowScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.96})
        Utility:Tween(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}, function()
            if token == visibilityToken and Library.IsMinimized then MainFrame.Visible = false end
        end)
        if Library.ReducedMotion then MainFrame.Visible = false end
    end

    function Window:Restore()
        visibilityToken = visibilityToken + 1
        Library.IsMinimized = false
        MinimizedIcon.Visible = false
        MainFrame.Visible = true
        MainFrame.BackgroundTransparency = 1
        WindowScale.Scale = 0.96
        Utility:Tween(WindowScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
        Utility:Tween(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
        if IsMobile and MobileToggleBtn then
            MobileToggleBtn.Visible = false
        end
    end

    function Window:Toggle()
        if Library.IsMinimized then
            Window:Restore()
        else
            Window:Minimize()
        end
    end

    function Window:Close()
        Library:Unload()
    end

    Library:Connect(MinimizeBtn.MouseButton1Click, function() Window:Minimize() end)
    Library:Connect(MinimizeBtn.MouseEnter, function()
        Utility:Tween(MinimizeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Library.Theme.Hover})
    end)
    Library:Connect(MinimizeBtn.MouseLeave, function()
        Utility:Tween(MinimizeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Library.Theme.Surface})
    end)
    local minimizedIconDrag = Utility:MakeDraggable(MinIconBtn, MinimizedIcon)
    Library:Connect(MinIconBtn.MouseButton1Click, function()
        if minimizedIconDrag:ConsumeDrag() then return end
        Window:Restore()
    end)
    Library:Connect(CloseBtn.MouseButton1Click, function() Window:Close() end)
    Library:Connect(CloseBtn.MouseEnter, function()
        Utility:Tween(CloseBtn, TweenInfo.new(0.12), {BackgroundColor3 = Library.Theme.Error})
    end)
    Library:Connect(CloseBtn.MouseLeave, function()
        Utility:Tween(CloseBtn, TweenInfo.new(0.12), {BackgroundColor3 = Library.Theme.Surface})
    end)

    -- GLOBAL SEARCH FUNCTIONALITY
    if SearchBox then
        local function searchInSection(section, searchText)
            local anyVisible = false
            for _, element in ipairs(section.Elements or {}) do
                if element.Holder then
                    local text = element.Text or element.Name or ""
                    local matches = searchText == "" or text:lower():find(searchText)
                    element.Holder.Visible = matches
                    if matches then anyVisible = true end
                end
            end
            if section.SectionFrame then
                section.SectionFrame.Visible = anyVisible
            end
            return anyVisible
        end

        local function searchInTab(tab, searchText)
            local anyVisible = false
            for _, section in pairs(tab.Sections) do
                if searchInSection(section, searchText) then
                    anyVisible = true
                end
            end
            if tab.Page then
                tab.Page.Visible = anyVisible
            end
            return anyVisible
        end

        Library:Connect(SearchBox:GetPropertyChangedSignal("Text"), function()
            local searchText = SearchBox.Text:lower()
            for _, tab in ipairs(Window.Tabs) do
                if tab.IsSettings then
                    searchInTab(tab, searchText)
                else
                    local visible = searchInTab(tab, searchText)
                    if tab.TabBtn then
                        tab.TabBtn.Visible = visible
                    end
                end
            end
            if Window.ActiveTab and not Window.ActiveTab.Page.Visible then
                for _, tab in ipairs(Window.Tabs) do
                    if tab.Page and tab.Page.Visible then
                        tab:Activate()
                        break
                    end
                end
            end
        end)
    end

    -- NOTIFICATIONS
    function Library:Notify(notifyOpts)
        notifyOpts = notifyOpts or {}
        local Title = notifyOpts.Title or "Notification"
        local Content = notifyOpts.Content or ""
        local Duration = notifyOpts.Duration or 3
        local Emoji = notifyOpts.Emoji or EMOJIS.Info
        local Progress = notifyOpts.Progress
        local Actions = notifyOpts.Actions or {}

        local notifHeight = (IsMobile and 58 or 66) + (#Actions > 0 and 34 or 0)
        local NotifyFrame = Utility:Create("Frame", {
            Name = "Notify",
            Parent = NotifyArea,
            BackgroundColor3 = Library.Theme.Main,
            Size = UDim2.new(1, 0, 0, notifHeight),
            Position = UDim2.new(2, 0, 0, 0),
            ClipsDescendants = true,
            ZIndex = 201,
            BorderSizePixel = 0
        })
        Utility:RegisterProperty(NotifyFrame, "BackgroundColor3", "Main")
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = NotifyFrame})
        local stroke = Utility:Create("UIStroke", {Parent = NotifyFrame, Color = Library.Theme.Stroke, Thickness = 1})
        Utility:RegisterProperty(stroke, "Color", "Stroke")

        local titleText = Utility:Create("TextLabel", {
            Parent = NotifyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(0, IsMobile and 28 or 36, 0, IsMobile and 28 or 36),
            Font = Enum.Font.GothamBold,
            Text = Emoji,
            TextColor3 = Library.Theme.Accent,
            TextSize = IsMobile and 18 or 24,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 202
        })
        Utility:Create("TextLabel", {
            Parent = NotifyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, IsMobile and 44 or 58, 0, IsMobile and 8 or 12),
            Size = UDim2.new(1, IsMobile and -76 or -92, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = Title,
            TextColor3 = Library.Theme.Text,
            TextSize = IsMobile and 12 or 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 202
        })
        local contentText = Utility:Create("TextLabel", {
            Parent = NotifyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, IsMobile and 44 or 58, 0, IsMobile and 24 or 30),
            Size = UDim2.new(1, IsMobile and -76 or -92, 0, #Actions > 0 and 26 or 28),
            Font = Enum.Font.Gotham,
            Text = Content,
            TextColor3 = Library.Theme.SubText,
            TextSize = IsMobile and 11 or 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 202
        })

        local closeButton = Utility:Create("TextButton", {
            Parent = NotifyFrame, BackgroundTransparency = 1,
            Position = UDim2.new(1, -30, 0, 6), Size = UDim2.fromOffset(24, 24),
            Text = "×", TextColor3 = Library.Theme.SubText, Font = Enum.Font.GothamBold,
            TextSize = 18, AutoButtonColor = false, ZIndex = 204
        })
        Utility:RegisterProperty(closeButton, "TextColor3", "SubText")

        -- Progress bar
        local progressBar = nil
        if Progress ~= nil then
            progressBar = Utility:Create("Frame", {
                Parent = NotifyFrame,
                BackgroundColor3 = Library.Theme.Accent,
                Position = UDim2.new(0, 0, 1, -4),
                Size = UDim2.new(Progress, 0, 0, 4),
                ZIndex = 203,
                BorderSizePixel = 0
            })
            Utility:RegisterProperty(progressBar, "BackgroundColor3", "Accent")
        end


        local Closed = false
        local function Close()
            if Closed then return end
            Closed = true
            Utility:Tween(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 300, 0, 0),
                BackgroundTransparency = 1
            }, function()
                if NotifyFrame.Parent then NotifyFrame:Destroy() end
            end)
            if Library.ReducedMotion and NotifyFrame.Parent then NotifyFrame:Destroy() end
        end

        Library:Connect(closeButton.MouseButton1Click, Close)

        if #Actions > 0 then
            local actionBar = Utility:Create("Frame", {
                Parent = NotifyFrame, BackgroundTransparency = 1,
                Position = UDim2.new(0, IsMobile and 44 or 58, 1, -38),
                Size = UDim2.new(1, IsMobile and -52 or -68, 0, 28), ZIndex = 203
            })
            Utility:Create("UIListLayout", {
                Parent = actionBar, FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 6)
            })
            for _, action in ipairs(Actions) do
                local actionButton = Utility:Create("TextButton", {
                    Parent = actionBar, BackgroundColor3 = Library.Theme.Hover,
                    Size = UDim2.fromOffset(math.max(64, TextService:GetTextSize(tostring(action.Name or "Action"), 11, Enum.Font.GothamBold, Vector2.new(160, 24)).X + 20), 26),
                    Text = tostring(action.Name or "Action"), TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false,
                    BorderSizePixel = 0, ZIndex = 204
                })
                Utility:RegisterProperty(actionButton, "BackgroundColor3", "Hover")
                Utility:RegisterProperty(actionButton, "TextColor3", "Text")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = actionButton})
                Library:Connect(actionButton.MouseButton1Click, function()
                    Utility:SafeCall(action.Callback)
                    if action.Close ~= false then Close() end
                end)
            end
        end

        NotifyFrame.Position = UDim2.new(1, 300, 0, 0)
        Utility:Tween(NotifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        })

        if Duration and Duration > 0 then
            if not progressBar then
                progressBar = Utility:Create("Frame", {
                    Parent = NotifyFrame, BackgroundColor3 = Library.Theme.Accent,
                    Position = UDim2.new(0, 0, 1, -3), Size = UDim2.new(1, 0, 0, 3),
                    BorderSizePixel = 0, ZIndex = 203
                })
                Utility:RegisterProperty(progressBar, "BackgroundColor3", "Accent")
                Utility:Tween(progressBar, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)})
            end
            task.delay(Duration, Close)
        end
        return {
            Close = Close,
            SetProgress = function(self, amount)
                if progressBar then progressBar.Size = UDim2.new(math.clamp(amount, 0, 1), 0, 0, 4) end
            end,
            SetContent = function(self, text) contentText.Text = tostring(text) end,
            SetTitle = function(self, text) titleText.Text = tostring(text) end
        }
    end

    --// TABS
    function Window:CreateTab(options)
        options = options or {}
        local Name = options.Name or "Tab"
        local Emoji = options.Emoji
        local IsSettings = options.IsSettings or false
        local Icon = Utility:NormalizeAssetId(options.Icon)
        if not Icon and Emoji == nil and not IsSettings then Icon = ICONS.Home end

        local Tab = {
            Name = Name,
            Active = false,
            Sections = {},
            IsSettings = IsSettings,
            Page = nil,
            TabBtn = nil,
            TabLabel = nil
        }

        local TabBtn, TabEmoji, Indicator, TabGradient
        local tabBtnSize = IsMobile and 38 or 42

        if not IsSettings then
            TabBtn = Utility:Create("TextButton", {
                Name = Name,
                Parent = TabContainer,
                BackgroundColor3 = Library.Theme.Accent,
                BackgroundTransparency = 1,
                Size = (IsMobile or isCompact) and UDim2.fromOffset(tabBtnSize, tabBtnSize) or UDim2.new(1, 0, 0, tabBtnSize),
                AutoButtonColor = false,
                Text = "",
                ZIndex = 5,
                BorderSizePixel = 0
            })
            Utility:RegisterProperty(TabBtn, "BackgroundColor3", "Accent")
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})
            TabGradient = Utility:Create("UIGradient", {Parent = TabBtn, Rotation = 18})
            Utility:RegisterGradient(TabGradient, "Accent", "Accent2")

            if Icon then
                TabEmoji = Utility:Create("ImageLabel", {
                    Parent = TabBtn,
                    BackgroundTransparency = 1,
                    Position = (IsMobile or isCompact) and UDim2.fromScale(0.18, 0.18) or UDim2.fromOffset(6, 5),
                    Size = (IsMobile or isCompact) and UDim2.fromScale(0.64, 0.64) or UDim2.fromOffset(32, 32),
                    Image = Icon,
                    ImageColor3 = Library.Theme.SubText,
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 6
                })
                Utility:RegisterProperty(TabEmoji, "ImageColor3", "SubText")
            else
                TabEmoji = Utility:Create("TextLabel", {
                    Parent = TabBtn,
                    BackgroundTransparency = 1,
                    Position = (IsMobile or isCompact) and UDim2.fromScale(0.18, 0.18) or UDim2.fromOffset(6, 5),
                    Size = (IsMobile or isCompact) and UDim2.fromScale(0.64, 0.64) or UDim2.fromOffset(32, 32),
                    Font = Enum.Font.GothamBold,
                    Text = Emoji or "",
                    TextColor3 = Library.Theme.SubText,
                    TextSize = IsMobile and 16 or 20,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = 6
                })
                Utility:RegisterProperty(TabEmoji, "TextColor3", "SubText")
            end

            Indicator = Utility:Create("Frame", {
                Parent = TabBtn,
                BackgroundColor3 = Library.Theme.Accent,
                Position = UDim2.new(0, 3, 0.5, -9),
                Size = UDim2.new(0, 3, 0, 18),
                BackgroundTransparency = 1,
                ZIndex = 7,
                BorderSizePixel = 0
            })
            Utility:RegisterProperty(Indicator, "BackgroundColor3", "Accent")
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Indicator})

            local TabLabel = Utility:Create("TextLabel", {
                Parent = TabBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 48, 0, 0),
                Size = UDim2.new(1, -58, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Name,
                TextColor3 = Library.Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not (IsMobile or isCompact),
                ZIndex = 6
            })
            Utility:RegisterProperty(TabLabel, "TextColor3", "SubText")

            Tab.TabBtn = TabBtn
            Tab.TabEmoji = TabEmoji
            Tab.Indicator = Indicator
            Tab.TabLabel = TabLabel
            Tab.TabGradient = TabGradient
        else
            TabEmoji = SettingsEmoji
            Indicator = SettingsIndicator
            Tab.TabBtn = SettingsBtn
            Tab.TabLabel = SettingsLabel
            Tab.TabEmoji = TabEmoji
            Tab.Indicator = Indicator
        end

        function Tab:ApplyNavigationLayout(mobile, compact)
            if self.IsSettings or not self.TabBtn then return end
            local iconOnly = mobile or compact
            self.TabBtn.Size = iconOnly and UDim2.fromOffset(tabBtnSize, tabBtnSize) or UDim2.new(1, 0, 0, tabBtnSize)
            if self.TabEmoji then
                self.TabEmoji.Position = iconOnly and UDim2.fromScale(0.18, 0.18) or UDim2.fromOffset(6, 5)
                self.TabEmoji.Size = iconOnly and UDim2.fromScale(0.64, 0.64) or UDim2.fromOffset(32, 32)
            end
            if self.TabLabel then self.TabLabel.Visible = not iconOnly end
        end

        local useSingleColumn = IsMobile
        local Page = Utility:Create("ScrollingFrame", {
            Name = Name,
            Parent = Pages,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, IsMobile and 10 or 20, 0, IsMobile and 92 or 70),
            Size = UDim2.new(1, IsMobile and -20 or -40, 1, IsMobile and -102 or -90),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            Active = true,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            ZIndex = 2,
            BorderSizePixel = 0
        })
        Utility:RegisterProperty(Page, "ScrollBarImageColor3", "Accent")
        Tab.Page = Page

        local LeftColumn = Utility:Create("Frame", {
            Name = "Left",
            Parent = Page,
            BackgroundTransparency = 1,
            Size = useSingleColumn and UDim2.new(1, 0, 1, 0) or UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0
        })
        local RightColumn = Utility:Create("Frame", {
            Name = "Right",
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0.5, 6, 0, 0),
            Visible = not useSingleColumn,
            ZIndex = 2,
            BorderSizePixel = 0
        })
        local LeftLayout = Utility:Create("UIListLayout", {
            Parent = LeftColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, useSingleColumn and 10 or 12)
        })
        local RightLayout = Utility:Create("UIListLayout", {
            Parent = RightColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })

        local function UpdateCanvas()
            local LeftH = LeftLayout.AbsoluteContentSize.Y
            local RightH = useSingleColumn and 0 or RightLayout.AbsoluteContentSize.Y
            Page.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftH, RightH) + 20)
        end
        Library:Connect(LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"), UpdateCanvas)
        Library:Connect(RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"), UpdateCanvas)

        function Tab:ApplyResponsiveLayout(mobile, topInset)
            useSingleColumn = mobile
            local pageTop = mobile and ((topInset or 88) + 4) or 70
            Page.Position = UDim2.new(0, mobile and 8 or 20, 0, pageTop)
            Page.Size = UDim2.new(1, mobile and -16 or -40, 1, -(pageTop + 10))
            Page.ScrollBarThickness = mobile and 3 or 2
            LeftColumn.Size = mobile and UDim2.new(1, 0, 1, 0) or UDim2.new(0.5, -6, 1, 0)
            RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
            RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
            RightColumn.Visible = not mobile
            LeftLayout.Padding = UDim.new(0, mobile and 10 or 12)
            for _, section in ipairs(Tab.Sections) do
                if mobile then
                    section.SectionFrame.Parent = LeftColumn
                elseif section.RequestedSide == "Right" then
                    section.SectionFrame.Parent = RightColumn
                elseif section.RequestedSide == "Auto" and LeftLayout.AbsoluteContentSize.Y > RightLayout.AbsoluteContentSize.Y then
                    section.SectionFrame.Parent = RightColumn
                else
                    section.SectionFrame.Parent = LeftColumn
                end
            end
            UpdateCanvas()
            task.defer(UpdateCanvas)
        end

        function Tab:Activate()
            if Window.ActiveTab == Tab then return end
            if Window.ActiveTab then
                Window.ActiveTab:Deactivate()
            end
            Tab.Active = true
            Window.ActiveTab = Tab
            if Tab.TabBtn then
                Utility:Tween(Tab.TabBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.12})
            end
            if Tab.TabLabel then
                Utility:Tween(Tab.TabLabel, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text})
            end
            if TabEmoji then
                if TabEmoji:IsA("TextLabel") then
                    Utility:Tween(TabEmoji, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text})
                elseif TabEmoji:IsA("ImageLabel") then
                    Utility:Tween(TabEmoji, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.Text})
                end
            end
            if Indicator then
                Utility:Tween(Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0, Position = UDim2.new(0, 3, 0.5, -9)})
            end
            TitleLabel.Text = Name
            Page.Visible = true
            Page.CanvasPosition = Vector2.new(0, 0)
        end

        function Tab:Deactivate()
            Tab.Active = false
            if Tab.TabBtn then
                Utility:Tween(Tab.TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            end
            if Tab.TabLabel then
                Utility:Tween(Tab.TabLabel, TweenInfo.new(0.2), {TextColor3 = Library.Theme.SubText})
            end
            if TabEmoji then
                if TabEmoji:IsA("TextLabel") then
                    Utility:Tween(TabEmoji, TweenInfo.new(0.3), {TextColor3 = Library.Theme.SubText})
                elseif TabEmoji:IsA("ImageLabel") then
                    Utility:Tween(TabEmoji, TweenInfo.new(0.3), {ImageColor3 = Library.Theme.SubText})
                end
            end
            if Indicator then
                Utility:Tween(Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.new(0, 3, 0.5, -9)})
            end
            Page.Visible = false
        end

        if TabBtn then
            Library:Connect(TabBtn.MouseButton1Click, function() Tab:Activate() end)
            Library:Connect(TabBtn.MouseEnter, function()
                if not Tab.Active then Utility:Tween(TabBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.78}) end
            end)
            Library:Connect(TabBtn.MouseLeave, function()
                if not Tab.Active then Utility:Tween(TabBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}) end
            end)
        end

        table.insert(Window.Tabs, Tab)
        Tab:ApplyResponsiveLayout(IsMobile, Window.ContentTopInset)
        if not IsSettings and not Window.ActiveTab then
            Tab:Activate()
        end

        --// SECTIONS
        function Tab:CreateSection(options)
            options = options or {}
            local SectionName = options.Name or "Section"
            local Side = options.Side or "Auto"

            local ParentCol = LeftColumn
            if not useSingleColumn then
                if Side == "Right" then
                    ParentCol = RightColumn
                elseif Side == "Auto" then
                    if LeftLayout.AbsoluteContentSize.Y > RightLayout.AbsoluteContentSize.Y then
                        ParentCol = RightColumn
                    end
                end
            end

            local Section = { Name = SectionName, RequestedSide = Side, Elements = {}, SectionFrame = nil, ContentContainer = nil }
            table.insert(Tab.Sections, Section)

            local SectionFrame = Utility:Create("Frame", {
                Name = SectionName,
                Parent = ParentCol,
                BackgroundColor3 = Library.Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 50),
                -- Allow expanded controls to render above the section frame.
                ClipsDescendants = false,
                ZIndex = 3,
                BorderSizePixel = 0
            })
            Utility:RegisterProperty(SectionFrame, "BackgroundColor3", "Secondary")
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = SectionFrame})
            local sectionStroke = Utility:Create("UIStroke", {
                Parent = SectionFrame,
                Color = Library.Theme.Stroke,
                Thickness = 1
            })
            Utility:RegisterProperty(sectionStroke, "Color", "Stroke")
            local sectionGradient = Utility:Create("UIGradient", {Parent = SectionFrame, Rotation = 105})
            Utility:RegisterGradient(sectionGradient, "Secondary", "Main")
            local sectionAccent = Utility:Create("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = Library.Theme.Accent,
                Position = UDim2.fromOffset(12, 7),
                Size = UDim2.fromOffset(26, 2),
                BorderSizePixel = 0,
                ZIndex = 5
            })
            Utility:RegisterProperty(sectionAccent, "BackgroundColor3", "Accent")
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sectionAccent})
            Section.SectionFrame = SectionFrame

            local Head = Utility:Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, IsMobile and 10 or 12),
                Size = UDim2.new(1, -24, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = SectionName,
                TextColor3 = Library.Theme.Text,
                TextSize = IsMobile and 12 or 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 4
            })
            Utility:RegisterProperty(Head, "TextColor3", "Text")

            local ContentContainer = Utility:Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, IsMobile and 30 or 35),
                Size = UDim2.new(1, -20, 0, 0),
                ZIndex = 4,
                BorderSizePixel = 0
            })
            Section.ContentContainer = ContentContainer

            local ContentLayout = Utility:Create("UIListLayout", {
                Parent = ContentContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, IsMobile and 6 or 8)
            })

            local function RefreshLayout()
                ContentContainer.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + (IsMobile and 38 or 45))
            end

            Library:Connect(ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                ContentContainer.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y)
                Utility:Tween(SectionFrame, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + (IsMobile and 38 or 45))
                })
            end)

            local function addElement(element)
                table.insert(Section.Elements, element)
                -- Only re-parent if the holder isn't already in ContentContainer
                if element.Holder and element.Holder.Parent ~= ContentContainer then
                    element.Holder.Parent = ContentContainer
                end
            end

            local function finishController(controller, holder, name)
                controller = controller or {}
                controller.Holder = holder
                controller.Name = name
                controller.Locked = false
                local blocker
                function controller:SetVisible(visible)
                    holder.Visible = visible == true
                    RefreshLayout()
                end
                function controller:Destroy()
                    holder:Destroy()
                    RefreshLayout()
                end
                function controller:SetLocked(locked)
                    self.Locked = locked == true
                    if self.Locked and not blocker then
                        blocker = Utility:Create("TextButton", {
                            Name = "RenLibLock",
                            Parent = holder,
                            BackgroundColor3 = Library.Theme.Main,
                            BackgroundTransparency = 0.35,
                            Size = UDim2.fromScale(1, 1),
                            Text = EMOJIS.Lock,
                            TextColor3 = Library.Theme.SubText,
                            TextSize = 14,
                            AutoButtonColor = false,
                            ZIndex = 100
                        })
                        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = blocker})
                    elseif blocker then
                        blocker:Destroy()
                        blocker = nil
                    end
                end
                function controller:Lock() self:SetLocked(true) end
                function controller:Unlock() self:SetLocked(false) end
                return controller
            end

            -- TEXT INPUT
            function Section:CreateInput(options)
                options = options or {}
                local name = options.Name or "Input"
                local flag = options.Flag or name
                local value = tostring(Library.Flags[flag] ~= nil and Library.Flags[flag] or options.Default or "")
                local listeners = {}
                local multiline = options.MultiLine == true
                local container = Utility:Create("Frame", {
                    Name = name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, multiline and 82 or 44),
                    BorderSizePixel = 0,
                    ZIndex = 5
                })
                Utility:RegisterProperty(container, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = container})
                local inputStroke = Utility:Create("UIStroke", {Parent = container, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(inputStroke, "Color", "Stroke")
                local box = Utility:Create("TextBox", {
                    Parent = container,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, multiline and 8 or 0),
                    Size = UDim2.new(1, -24, 1, multiline and -16 or 0),
                    ClearTextOnFocus = false,
                    MultiLine = multiline,
                    PlaceholderText = options.Placeholder or name,
                    Text = value,
                    TextColor3 = Library.Theme.Text,
                    PlaceholderColor3 = Library.Theme.SubText,
                    Font = Enum.Font.Gotham,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
                    TextWrapped = multiline,
                    ZIndex = 6
                })
                Utility:RegisterProperty(box, "TextColor3", "Text")
                Utility:RegisterProperty(box, "PlaceholderColor3", "SubText")

                local function setValue(nextValue, fire)
                    value = tostring(nextValue or "")
                    if options.Numeric then
                        value = value:gsub("[^%d%.%-]", "")
                    end
                    box.Text = value
                    Library.Flags[flag] = options.Numeric and tonumber(value) or value
                    if fire ~= false then
                        Utility:SafeCall(options.Callback, Library.Flags[flag])
                        for _, listener in ipairs(listeners) do Utility:SafeCall(listener, Library.Flags[flag]) end
                    end
                end
                Library.Flags[flag] = options.Numeric and tonumber(value) or value
                Library:Connect(box.Focused, function()
                    Utility:Tween(inputStroke, TweenInfo.new(0.18), {Color = Library.Theme.Accent})
                end)
                Library:Connect(box.FocusLost, function(enterPressed)
                    setValue(box.Text, true)
                    Utility:Tween(inputStroke, TweenInfo.new(0.18), {Color = Library.Theme.Stroke})
                    if options.Finished then Utility:SafeCall(options.Finished, Library.Flags[flag], enterPressed) end
                end)
                local controller = finishController({
                    Type = "Input",
                    Set = function(self, nextValue) setValue(nextValue, true) end,
                    Get = function() return Library.Flags[flag] end,
                    OnChanged = function(self, fn) table.insert(listeners, fn) end
                }, container, name)
                Library.Options[flag] = controller
                addElement({Holder = container, Text = name})
                return controller
            end

            function Section:CreateParagraph(options)
                if type(options) == "string" then options = {Content = options} end
                options = options or {}
                local title = options.Title or ""
                local content = options.Content or options.Text or ""
                local container = Utility:Create("Frame", {
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, 56),
                    BorderSizePixel = 0,
                    ZIndex = 5
                })
                Utility:RegisterProperty(container, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = container})
                local titleLabel = Utility:Create("TextLabel", {
                    Parent = container, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8),
                    Size = UDim2.new(1, -24, 0, title == "" and 0 or 18), Font = Enum.Font.GothamBold,
                    Text = title, TextColor3 = Library.Theme.Text, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6
                })
                local contentLabel = Utility:Create("TextLabel", {
                    Parent = container, BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, title == "" and 8 or 29), Size = UDim2.new(1, -24, 0, 20),
                    Font = Enum.Font.Gotham, Text = content, TextColor3 = Library.Theme.SubText,
                    TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 6
                })
                Utility:RegisterProperty(titleLabel, "TextColor3", "Text")
                Utility:RegisterProperty(contentLabel, "TextColor3", "SubText")
                local function resize()
                    container.Size = UDim2.new(1, 0, 0, (title == "" and 16 or 37) + math.max(20, contentLabel.TextBounds.Y))
                    RefreshLayout()
                end
                Library:Connect(contentLabel:GetPropertyChangedSignal("TextBounds"), resize)
                local controller = finishController({
                    SetTitle = function(self, text) title = tostring(text); titleLabel.Text = title; resize() end,
                    SetContent = function(self, text) contentLabel.Text = tostring(text); resize() end
                }, container, title)
                addElement({Holder = container, Text = title .. " " .. content})
                task.defer(resize)
                return controller
            end

            function Section:CreateDivider(text)
                local container = Utility:Create("Frame", {
                    Parent = ContentContainer, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, text and 24 or 12), ZIndex = 5
                })
                local line = Utility:Create("Frame", {
                    Parent = container, BackgroundColor3 = Library.Theme.Divider,
                    Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, ZIndex = 5
                })
                Utility:RegisterProperty(line, "BackgroundColor3", "Divider")
                if text then
                    local label = Utility:Create("TextLabel", {
                        Parent = container, BackgroundColor3 = Library.Theme.Secondary,
                        Position = UDim2.new(0.5, -50, 0.5, -10), Size = UDim2.fromOffset(100, 20),
                        Text = tostring(text), TextColor3 = Library.Theme.SubText, Font = Enum.Font.Gotham,
                        TextSize = 11, ZIndex = 6
                    })
                    Utility:RegisterProperty(label, "BackgroundColor3", "Secondary")
                    Utility:RegisterProperty(label, "TextColor3", "SubText")
                end
                addElement({Holder = container, Text = text or ""})
                return finishController({}, container, text or "Divider")
            end

            -- BUTTON
            function Section:CreateButton(options)
                options = options or {}
                local Name = options.Name or "Button"
                local Callback = options.Callback or function() end
                local Description = tostring(options.Description or "")
                local ButtonIconAsset = Utility:NormalizeAssetId(options.Icon)

                local btnHeight = Description ~= "" and (IsMobile and 56 or 54) or (IsMobile and 44 or 42)
                local ButtonContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, btnHeight),
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                Utility:RegisterProperty(ButtonContainer, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ButtonContainer})
                local Stroke = Utility:Create("UIStroke", {
                    Parent = ButtonContainer,
                    Color = Library.Theme.Stroke,
                    Thickness = 1
                })
                Utility:RegisterProperty(Stroke, "Color", "Stroke")

                local Btn = Utility:Create("TextButton", {
                    Parent = ButtonContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 9,
                    BorderSizePixel = 0
                })

                local textInset = ButtonIconAsset and 44 or 12
                if ButtonIconAsset then
                    local ButtonIcon = Utility:Create("ImageLabel", {
                        Parent = ButtonContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0.5, -10),
                        Size = UDim2.fromOffset(20, 20),
                        Image = ButtonIconAsset,
                        ImageColor3 = Library.Theme.SubText,
                        ScaleType = Enum.ScaleType.Fit,
                        ZIndex = 7
                    })
                    Utility:RegisterProperty(ButtonIcon, "ImageColor3", "SubText")
                end
                local ButtonTitle = Utility:Create("TextLabel", {
                    Parent = ButtonContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, textInset, 0, Description ~= "" and 7 or 0),
                    Size = UDim2.new(1, -(textInset + 32), 0, Description ~= "" and 20 or btnHeight),
                    Font = Enum.Font.GothamMedium,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7
                })
                Utility:RegisterProperty(ButtonTitle, "TextColor3", "Text")
                local ButtonDescription
                if Description ~= "" then
                    ButtonDescription = Utility:Create("TextLabel", {
                        Parent = ButtonContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, textInset, 0, 27),
                        Size = UDim2.new(1, -(textInset + 32), 0, 17),
                        Font = Enum.Font.Gotham,
                        Text = Description,
                        TextColor3 = Library.Theme.SubText,
                        TextSize = IsMobile and 10 or 11,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 7
                    })
                    Utility:RegisterProperty(ButtonDescription, "TextColor3", "SubText")
                end
                local ButtonArrow = Utility:Create("ImageLabel", {
                    Parent = ButtonContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -24, 0.5, -8),
                    Size = UDim2.fromOffset(16, 16),
                    Image = ICONS.ChevronRight,
                    ImageColor3 = Library.Theme.SubText,
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 7
                })
                Utility:RegisterProperty(ButtonArrow, "ImageColor3", "SubText")

                Library:Connect(Btn.MouseEnter, function()
                    Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Accent})
                    Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover})
                end)
                Library:Connect(Btn.MouseLeave, function()
                    Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Stroke})
                    Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Surface})
                end)
                Library:Connect(Btn.MouseButton1Click, function()
                    if IsMobile then
                        Utility:Tween(Stroke, TweenInfo.new(0.1), {Color = Library.Theme.Accent})
                        Utility:Tween(ButtonContainer, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Hover})
                        task.delay(0.15, function()
                            Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Stroke})
                            Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Surface})
                        end)
                    end
                    Utility:SafeCall(Callback)
                end)
                addElement({Holder = ButtonContainer, Text = Name .. " " .. Description})
                return finishController({
                    SetText = function(self, text) ButtonTitle.Text = tostring(text) end,
                    SetDescription = function(self, text)
                        if ButtonDescription then ButtonDescription.Text = tostring(text) end
                    end
                }, ButtonContainer, Name)
            end

            -- TOGGLE
            function Section:CreateToggle(options)
                options = options or {}
                local Name = options.Name or "Toggle"
                local Default = options.Default or false
                local Callback = options.Callback or function() end
                local Flag = options.Flag or Name

                local CurrentValue = Default
                if Library.Flags[Flag] ~= nil then
                    CurrentValue = Library.Flags[Flag]
                end
                Library.Flags[Flag] = CurrentValue

                local toggleHeight = IsMobile and 40 or 40
                local ToggleContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, toggleHeight),
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                Utility:RegisterProperty(ToggleContainer, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ToggleContainer})
                local stroke = Utility:Create("UIStroke", {Parent = ToggleContainer, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(stroke, "Color", "Stroke")

                local ToggleBtn = Utility:Create("TextButton", {
                    Parent = ToggleContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 6,
                    BorderSizePixel = 0
                })
                Utility:RegisterProperty(ToggleBtn, "TextColor3", "Text")
                Utility:Create("UIPadding", {Parent = ToggleBtn, PaddingLeft = UDim.new(0, 12)})

                local switchWidth = IsMobile and 30 or 35
                local switchHeight = IsMobile and 17 or 20
                local dotSize = IsMobile and 13 or 16

                local SwitchBg = Utility:Create("Frame", {
                    Parent = ToggleBtn,
                    BackgroundColor3 = CurrentValue and Library.Theme.Accent or Library.Theme.SurfaceAlt,
                    Position = UDim2.new(1, -(switchWidth + 10), 0.5, -math.floor(switchHeight / 2)),
                    Size = UDim2.new(0, switchWidth, 0, switchHeight),
                    BorderSizePixel = 0,
                    ZIndex = 6
                })
                Utility:RegisterProperty(SwitchBg, "BackgroundColor3", CurrentValue and "Accent" or "SurfaceAlt")
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwitchBg})
                local SwitchDot = Utility:Create("Frame", {
                    Parent = SwitchBg,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = CurrentValue and UDim2.new(1, -(dotSize + 2), 0.5, -math.floor(dotSize / 2)) or UDim2.new(0, 2, 0.5, -math.floor(dotSize / 2)),
                    Size = UDim2.new(0, dotSize, 0, dotSize),
                    ZIndex = 7,
                    BorderSizePixel = 0
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwitchDot})

                local changeListeners = {}

                local function Update()
                    Library.Flags[Flag] = CurrentValue
                    Utility:SafeCall(Callback, CurrentValue)
                    if CurrentValue then
                        Library.Registry[SwitchBg]["BackgroundColor3"] = "Accent"
                        Utility:Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Accent})
                        Utility:Tween(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -(dotSize + 2), 0.5, -math.floor(dotSize / 2))})
                    else
                        Library.Registry[SwitchBg]["BackgroundColor3"] = "SurfaceAlt"
                        Utility:Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.SurfaceAlt})
                        Utility:Tween(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -math.floor(dotSize / 2))})
                    end
                    for _, listener in ipairs(changeListeners) do
                        pcall(listener, CurrentValue)
                    end
                end

                Library:Connect(ToggleBtn.MouseButton1Click, function()
                    CurrentValue = not CurrentValue
                    Update()
                end)
                Library:Connect(ToggleBtn.MouseEnter, function()
                    Utility:Tween(ToggleContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover})
                end)
                Library:Connect(ToggleBtn.MouseLeave, function()
                    Utility:Tween(ToggleContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Surface})
                end)

                addElement({Holder = ToggleContainer, Text = Name})

                local toggleObj = {
                    Type = "Toggle",
                    Set = function(self, val)
                        CurrentValue = val
                        Update()
                    end,
                    Get = function() return CurrentValue end,
                    OnChanged = function(self, fn)
                        table.insert(changeListeners, fn)
                    end
                }
                finishController(toggleObj, ToggleContainer, Name)
                Library.Options[Flag] = toggleObj
                return toggleObj
            end

            -- SLIDER
            function Section:CreateSlider(options)
                options = options or {}
                local Name = options.Name or "Slider"
                local Min = options.Min or 0
                local Max = options.Max or 100
                local Default = options.Default or Min
                local Callback = options.Callback or function() end
                local Flag = options.Flag or Name
                local Step = math.max(tonumber(options.Step) or 1, 0.000001)
                local CallbackMode = options.CallbackMode or (options.CallbackOnRelease and "Release" or "Changed")

                local Value = Default
                if Library.Flags[Flag] ~= nil then Value = Library.Flags[Flag] end
                Library.Flags[Flag] = Value

                local sliderHeight = IsMobile and 44 or 50
                local SliderContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, sliderHeight),
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                Utility:RegisterProperty(SliderContainer, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SliderContainer})
                local stroke = Utility:Create("UIStroke", {Parent = SliderContainer, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(stroke, "Color", "Stroke")

                Utility:Create("TextLabel", {
                    Parent = SliderContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, IsMobile and 6 or 8),
                    Size = UDim2.new(1, -24, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6
                })
                local ValueLabel = Utility:Create("TextLabel", {
                    Parent = SliderContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, IsMobile and 6 or 8),
                    Size = UDim2.new(1, -24, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(Value),
                    TextColor3 = Library.Theme.SubText,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 6
                })
                local trackHeight = IsMobile and 10 or 6
                local Track = Utility:Create("TextButton", {
                    Parent = SliderContainer,
                    BackgroundColor3 = Library.Theme.SurfaceAlt,
                    Position = UDim2.new(0, 12, 0, IsMobile and 28 or 34),
                    Size = UDim2.new(1, -24, 0, trackHeight),
                    AutoButtonColor = false,
                    Text = "",
                    ZIndex = 6,
                    BorderSizePixel = 0
                })
                Utility:RegisterProperty(Track, "BackgroundColor3", "SurfaceAlt")
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})
                local Fill = Utility:Create("Frame", {
                    Parent = Track,
                    BackgroundColor3 = Library.Theme.Accent,
                    Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
                    BorderSizePixel = 0,
                    ZIndex = 7
                })
                Utility:RegisterProperty(Fill, "BackgroundColor3", "Accent")
                local fillGradient = Utility:Create("UIGradient", {Parent = Fill})
                Utility:RegisterGradient(fillGradient, "Accent", "Accent2")
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})
                local Dragging = false
                local DragInput = nil
                local pendingCallback = false

                local function EmitValue()
                    pendingCallback = false
                    Utility:SafeCall(Callback, Value)
                end

                local function UpdateSlider(input)
                    local SizeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / math.max(1, Track.AbsoluteSize.X), 0, 1)
                    local NewValue = Min + ((Max - Min) * SizeX)
                    NewValue = math.clamp(Min + math.floor(((NewValue - Min) / Step) + 0.5) * Step, Min, Max)
                    Value = NewValue
                    ValueLabel.Text = tostring(Value)
                    Library.Flags[Flag] = Value
                    pendingCallback = true
                    if CallbackMode ~= "Release" then EmitValue() end
                    Utility:Tween(Fill, TweenInfo.new(0.05), {Size = UDim2.new((Value - Min) / math.max(0.000001, Max - Min), 0, 1, 0)})
                end

                Library:Connect(Track.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        DragInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
                        UpdateSlider(input)
                    end
                end)
                Library:Connect(UserInputService.InputChanged, function(input)
                    local pointerMove = input.UserInputType == Enum.UserInputType.MouseMovement
                        or (input.UserInputType == Enum.UserInputType.Touch and input == DragInput)
                    if Dragging and pointerMove then
                        UpdateSlider(input)
                    end
                end)
                Library:Connect(UserInputService.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local wasDragging = Dragging
                        Dragging = false
                        if wasDragging and pendingCallback then task.defer(EmitValue) end
                        if wasDragging and options.Finished then task.defer(function() Utility:SafeCall(options.Finished, Value) end) end
                    end
                end)

                addElement({Holder = SliderContainer, Text = Name})
                local function SetValue(val, fire)
                    Value = math.clamp(tonumber(val) or Min, Min, Max)
                    ValueLabel.Text = tostring(Value)
                    Library.Flags[Flag] = Value
                    Utility:Tween(Fill, TweenInfo.new(0.1), {Size = UDim2.new((Value - Min) / math.max(0.000001, Max - Min), 0, 1, 0)})
                    pendingCallback = false
                    if fire ~= false then EmitValue() end
                end
                local sliderObj = {
                    Type = "Slider",
                    Set = function(self, val)
                        SetValue(val, true)
                    end,
                    SetSilent = function(self, val) SetValue(val, false) end,
                    Get = function() return Value end
                }
                finishController(sliderObj, SliderContainer, Name)
                Library.Options[Flag] = sliderObj
                return sliderObj
            end

            -- DROPDOWN
            function Section:CreateDropdown(options)
                options = options or {}
                local Name = options.Name or "Dropdown"
                local Values = options.Values or {}
                local Multi = options.Multi or false
                local Default = options.Default or (Multi and {} or Values[1])
                local Callback = options.Callback or function() end
                local Flag = options.Flag or Name

                local CurrentValue = Default
                if Library.Flags[Flag] ~= nil then CurrentValue = Library.Flags[Flag] end
                Library.Flags[Flag] = CurrentValue

                local headerHeight = IsMobile and 38 or 44
                local Expanded = false
                local listHeight = 0

                local changeListeners = {}

                local DropdownContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, headerHeight),
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                Utility:RegisterProperty(DropdownContainer, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownContainer})
                local stroke = Utility:Create("UIStroke", {Parent = DropdownContainer, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(stroke, "Color", "Stroke")

                -- Header clip frame to prevent button overflow
                local HeaderClip = Utility:Create("Frame", {
                    Parent = DropdownContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, headerHeight),
                    ClipsDescendants = true,
                    ZIndex = 5
                })

                local Header = Utility:Create("TextButton", {
                    Parent = HeaderClip,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, headerHeight),
                    AutoButtonColor = false,
                    Text = "",
                    ZIndex = 6,
                    BorderSizePixel = 0
                })
                Utility:Create("TextLabel", {
                    Parent = Header,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, IsMobile and 10 or 12),
                    Size = UDim2.new(0.5, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7
                })
                local Status = Utility:Create("TextLabel", {
                    Parent = Header,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, IsMobile and 10 or 12),
                    Size = UDim2.new(0.5, -30, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = (Multi and "..." or tostring(CurrentValue)),
                    TextColor3 = Library.Theme.SubText,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 7
                })
                local Arrow = Utility:Create("ImageLabel", {
                    Parent = Header,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -28, 0.5, -8),
                    Size = UDim2.fromOffset(16, 16),
                    Image = ICONS.ChevronDown,
                    ImageColor3 = Library.Theme.SubText,
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 7
                })
                Utility:RegisterProperty(Arrow, "ImageColor3", "SubText")

                -- List rendered outside HeaderClip so it can overflow
                local ListFrame = Utility:Create("ScrollingFrame", {
                    Parent = DropdownContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Position = UDim2.new(0, 8, 0, headerHeight),
                    Size = UDim2.new(1, -16, 0, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Library.Theme.Accent,
                    ZIndex = 20,
                    BorderSizePixel = 0,
                    Visible = false
                })
                Utility:RegisterProperty(ListFrame, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ListFrame})
                local listStroke = Utility:Create("UIStroke", {Parent = ListFrame, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(listStroke, "Color", "Stroke")

                local itemHeight = IsMobile and 30 or 26

                local function SetExpanded(open)
                    Expanded = open == true
                    if Expanded then ListFrame.Visible = true end
                    Utility:Tween(Arrow, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = Expanded and 180 or 0})
                    Utility:Tween(DropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, Expanded and (headerHeight + listHeight + 8) or headerHeight)
                    }, function()
                        if not Expanded then ListFrame.Visible = false end
                    end)
                    if Library.ReducedMotion and not Expanded then ListFrame.Visible = false end
                end

                local function Refresh()
                    if Multi then
                        local Count = 0
                        for k, v in pairs(CurrentValue) do if v then Count = Count + 1 end end
                        Status.Text = Count .. " Selected"
                    else
                        Status.Text = tostring(CurrentValue)
                    end
                    Library.Flags[Flag] = CurrentValue
                    Utility:SafeCall(Callback, CurrentValue)
                    for _, listener in ipairs(changeListeners) do
                        pcall(listener, CurrentValue)
                    end
                end

                local function BuildList()
                    ListFrame:ClearAllChildren()
                    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = ListFrame})
                    local rebuiltStroke = Utility:Create("UIStroke", {Parent = ListFrame, Color = Library.Theme.Stroke, Thickness = 1})
                    Utility:RegisterProperty(rebuiltStroke, "Color", "Stroke")
                    Utility:Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
                    Utility:Create("UIPadding", {Parent = ListFrame, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4)})
                    for _, val in pairs(Values) do
                        local Item = Utility:Create("TextButton", {
                            Parent = ListFrame,
                            BackgroundColor3 = Library.Theme.SurfaceAlt,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, itemHeight),
                            AutoButtonColor = false,
                            Font = Enum.Font.Gotham,
                            Text = tostring(val),
                            TextColor3 = Library.Theme.SubText,
                            TextSize = IsMobile and 12 or 13,
                            ZIndex = 21,
                            BorderSizePixel = 0
                        })
                        Utility:RegisterProperty(Item, "BackgroundColor3", "SurfaceAlt")
                        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Item})
                        local IsSelected = Multi and CurrentValue[val] or (not Multi and CurrentValue == val)
                        if IsSelected then
                            Item.TextColor3 = Library.Theme.Text
                            Item.BackgroundTransparency = 0
                        end
                        Library:Connect(Item.MouseButton1Click, function()
                            if Multi then
                                CurrentValue[val] = not CurrentValue[val]
                                BuildList()
                            else
                                CurrentValue = val
                                SetExpanded(false)
                                BuildList()
                            end
                            Refresh()
                        end)
                    end
                    listHeight = math.min(#Values * (itemHeight + 4) + 10, IsMobile and 132 or 156)
                    ListFrame.CanvasSize = UDim2.new(0, 0, 0, #Values * (itemHeight + 4) + 10)
                    ListFrame.Size = UDim2.new(1, -16, 0, listHeight)
                    if Expanded then DropdownContainer.Size = UDim2.new(1, 0, 0, headerHeight + listHeight + 8) end
                end

                Library:Connect(Header.MouseButton1Click, function()
                    SetExpanded(not Expanded)
                end)
                BuildList()
                addElement({Holder = DropdownContainer, Text = Name})

                local dropObj = {
                    Type = "Dropdown",
                    Set = function(self, val)
                        CurrentValue = val
                        Refresh()
                        BuildList()
                    end,
                    Refresh = function(self, newVals)
                        Values = newVals
                        BuildList()
                    end,
                    Get = function() return CurrentValue end,
                    OnChanged = function(self, fn)
                        table.insert(changeListeners, fn)
                    end,
                    SetExpanded = function(self, open) SetExpanded(open) end
                }
                finishController(dropObj, DropdownContainer, Name)
                Library.Options[Flag] = dropObj
                return dropObj
            end

            -- LABEL
            function Section:CreateLabel(Text)
                local Container = Utility:Create("Frame", {
                    Name = "Label",
                    Parent = ContentContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                local Lab = Utility:Create("TextLabel", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = Text,
                    TextColor3 = Library.Theme.Text,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    ZIndex = 6
                })
                Utility:RegisterProperty(Lab, "TextColor3", "Text")
                Library:Connect(Lab:GetPropertyChangedSignal("TextBounds"), function()
                    Container.Size = UDim2.new(1, 0, 0, Lab.TextBounds.Y + 4)
                end)
                addElement({Holder = Container, Text = Text})
                return finishController({
                    SetText = function(self, t)
                        Lab.Text = t
                    end
                }, Container, Text)
            end

            -- DEPENDENCY BOX
            function Section:CreateDependencyBox(dependencies)
                local depContainer = Utility:Create("Frame", {
                    Parent = ContentContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                local layout = Utility:Create("UIListLayout", {
                    Parent = depContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, IsMobile and 6 or 8)
                })

                local function updateVisibility()
                    local allMatch = true
                    for _, dep in ipairs(dependencies) do
                        local element, expected = dep[1], dep[2]
                        local val = element.Get and element.Get() or nil
                        if val == nil then
                            allMatch = false; break
                        end
                        if element.Type == "Toggle" then
                            if val ~= expected then allMatch = false; break end
                        elseif element.Type == "Dropdown" then
                            if type(val) == "table" then
                                if not val[expected] then allMatch = false; break end
                            elseif val ~= expected then
                                allMatch = false; break
                            end
                        end
                    end
                    depContainer.Visible = allMatch
                    -- Manually update canvas size
                    if allMatch then
                        depContainer.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
                    else
                        depContainer.Size = UDim2.new(1, 0, 0, 0)
                    end
                    RefreshLayout()
                end

                for _, dep in ipairs(dependencies) do
                    local element = dep[1]
                    if element.OnChanged then
                        element:OnChanged(updateVisibility)
                    end
                end
                updateVisibility()
                addElement({Holder = depContainer})
                return depContainer
            end

            -- WARNING BOX
            function Section:CreateWarningBox(options)
                options = options or {}
                local title = options.Title or "Warning"
                local text = options.Text or ""
                local color = options.Color or "Warn"
                local closable = options.Closable or false

                local bgColor = Library.Theme[color] or Library.Theme.Warn
                local container = Utility:Create("Frame", {
                    Parent = ContentContainer,
                    BackgroundColor3 = bgColor,
                    Size = UDim2.new(1, 0, 0, 40),
                    ClipsDescendants = false,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = container})

                local titleLabel = Utility:Create("TextLabel", {
                    Parent = container,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 8),
                    Size = UDim2.new(1, closable and -30 or -20, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6
                })

                local textLabel = Utility:Create("TextLabel", {
                    Parent = container,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    ZIndex = 6
                })

                Library:Connect(textLabel:GetPropertyChangedSignal("TextBounds"), function()
                    local textH = textLabel.TextBounds.Y + 4
                    textLabel.Size = UDim2.new(1, -20, 0, textH)
                    local totalHeight = 30 + textH + 10
                    container.Size = UDim2.new(1, 0, 0, totalHeight)
                    RefreshLayout()
                end)

                if closable then
                    local closeBtn = Utility:Create("TextButton", {
                        Parent = container,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -24, 0, 4),
                        Size = UDim2.new(0, 20, 0, 20),
                        Text = "✖",
                        TextColor3 = Library.Theme.Text,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        ZIndex = 7
                    })
                    Library:Connect(closeBtn.MouseButton1Click, function()
                        container:Destroy()
                        RefreshLayout()
                    end)
                end
                addElement({Holder = container})
                return container
            end

            -- IMAGE
            function Section:CreateImage(options)
                options = options or {}
                local image = options.Image or ""
                local width = options.Width or 200
                local height = options.Height or 200
                local scaleType = options.ScaleType or Enum.ScaleType.Fit

                local container = Utility:Create("Frame", {
                    Parent = ContentContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, width, 0, height),
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                local img = Utility:Create("ImageLabel", {
                    Parent = container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Image = image,
                    ScaleType = scaleType,
                    ZIndex = 6
                })
                addElement({Holder = container})
                return finishController({
                    SetImage = function(self, newImage) img.Image = newImage end,
                    SetSize = function(self, w, h) container.Size = UDim2.new(0, w, 0, h) end
                }, container, "Image")
            end

            -- KEYBIND PICKER
            function Section:CreateKeyPicker(options)
                options = options or {}
                local name = options.Name or "Keybind"
                local defaultKey = options.Default or "None"
                local mode = options.Mode or "Toggle"
                local callback = options.Callback or function() end
                local flag = options.Flag or name

                local currentKey = Library.Flags[flag] or defaultKey
                local toggled = false
                local listening = false

                local container = Utility:Create("Frame", {
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, IsMobile and 32 or 36),
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = container})
                local stroke = Utility:Create("UIStroke", {Parent = container, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(container, "BackgroundColor3", "Surface")
                Utility:RegisterProperty(stroke, "Color", "Stroke")

                local label = Utility:Create("TextLabel", {
                    Parent = container,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0.5, -10),
                    Size = UDim2.new(0.6, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6
                })
                Utility:RegisterProperty(label, "TextColor3", "Text")

                local keyBtn = Utility:Create("TextButton", {
                    Parent = container,
                    BackgroundColor3 = Library.Theme.Secondary,
                    Position = UDim2.new(0.7, 0, 0.5, -12),
                    Size = UDim2.new(0.25, 0, 0, 24),
                    Text = currentKey,
                    TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    AutoButtonColor = false,
                    ZIndex = 6
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = keyBtn})
                Utility:RegisterProperty(keyBtn, "BackgroundColor3", "Secondary")
                Utility:RegisterProperty(keyBtn, "TextColor3", "Text")

                local stateIndicator = Utility:Create("Frame", {
                    Parent = container,
                    BackgroundColor3 = Library.Theme.Accent,
                    Position = UDim2.new(0.96, 0, 0.5, -4),
                    Size = UDim2.new(0, 8, 0, 8),
                    Visible = false,
                    ZIndex = 7
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = stateIndicator})
                Utility:RegisterProperty(stateIndicator, "BackgroundColor3", "Accent")

                local listenBtn = Utility:Create("TextButton", {
                    Parent = container,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.96, 0, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Text = "✎",
                    TextColor3 = Library.Theme.SubText,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    ZIndex = 7
                })
                Utility:RegisterProperty(listenBtn, "TextColor3", "SubText")

                Library:Connect(listenBtn.MouseButton1Click, function()
                    if listening then return end
                    listening = true
                    keyBtn.Text = "..."
                    local conn
                    conn = Library:Connect(UserInputService.InputBegan, function(input, gpe)
                        if gpe then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode.Name
                            Library.Flags[flag] = currentKey
                            keyBtn.Text = currentKey
                            listening = false
                            conn:Disconnect()
                            -- Update keybind list entry
                            local found = false
                            for _, kb in ipairs(Library.KeybindList) do
                                if kb.name == name then
                                    kb.key = currentKey
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                table.insert(Library.KeybindList, {name = name, key = currentKey, mode = mode, callback = callback})
                            end
                        end
                    end)
                end)

                if mode == "Hold" then
                    local holding = false
                    local holdConn
                    Library:Connect(keyBtn.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            if listening then return end
                            holding = true
                            stateIndicator.Visible = true
                            Utility:SafeCall(callback, currentKey, true)
                            holdConn = Library:Connect(RunService.Heartbeat, function()
                                if holding then
                                    Utility:SafeCall(callback, currentKey, true)
                                end
                            end)
                        end
                    end)
                    Library:Connect(keyBtn.InputEnded, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            if holding then
                                holding = false
                                stateIndicator.Visible = false
                                if holdConn then holdConn:Disconnect() end
                                Utility:SafeCall(callback, currentKey, false)
                            end
                        end
                    end)
                elseif mode == "Toggle" then
                    Library:Connect(keyBtn.MouseButton1Click, function()
                        if listening then return end
                        toggled = not toggled
                        stateIndicator.Visible = toggled
                        Utility:SafeCall(callback, currentKey, toggled)
                    end)
                end

                addElement({Holder = container, Text = name})
                local controller = finishController({
                    Type = "KeyPicker",
                    Set = function(self, key) currentKey = tostring(key); keyBtn.Text = currentKey; Library.Flags[flag] = currentKey end,
                    Get = function() return currentKey end,
                    GetKey = function() return currentKey end,
                    GetState = function() return toggled end
                }, container, name)
                Library.Flags[flag] = currentKey
                Library.Options[flag] = controller
                return controller
            end

            -- COLOR PICKER (touch-friendly HSV editor)
            function Section:CreateColorPicker(options)
                options = options or {}
                local name = options.Name or "Color"
                local defaultColor = options.Default or Color3.new(1,1,1)
                local callback = options.Callback or function() end
                local flag = options.Flag or name
                local currentColor = Library.Flags[flag] or defaultColor
                local hue, saturation, value = Color3.toHSV(currentColor)
                local expanded = false
                local listeners = {}
                local headerHeight = IsMobile and 40 or 38

                local container = Utility:Create("Frame", {
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, headerHeight),
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = container})
                local stroke = Utility:Create("UIStroke", {Parent = container, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(container, "BackgroundColor3", "Surface")
                Utility:RegisterProperty(stroke, "Color", "Stroke")

                local headerButton = Utility:Create("TextButton", {
                    Parent = container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, headerHeight),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 7
                })

                local label = Utility:Create("TextLabel", {
                    Parent = headerButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -92, 0, headerHeight),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6
                })
                Utility:RegisterProperty(label, "TextColor3", "Text")

                local headerSwatch = Utility:Create("Frame", {
                    Parent = headerButton,
                    BackgroundColor3 = currentColor,
                    Position = UDim2.new(1, -58, 0.5, -10),
                    Size = UDim2.fromOffset(20, 20),
                    BorderSizePixel = 0,
                    ZIndex = 8
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = headerSwatch})
                local colorStroke = Utility:Create("UIStroke", {Parent = headerSwatch, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(colorStroke, "Color", "Stroke")

                local headerArrow = Utility:Create("ImageLabel", {
                    Parent = headerButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -28, 0.5, -8),
                    Size = UDim2.fromOffset(16, 16),
                    Image = ICONS.ChevronDown,
                    ImageColor3 = Library.Theme.SubText,
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 8
                })
                Utility:RegisterProperty(headerArrow, "ImageColor3", "SubText")

                local editor = Utility:Create("Frame", {
                    Parent = container, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, headerHeight + 4),
                    Size = UDim2.new(1, -24, 0, 132), ZIndex = 6
                })

                local hueGradient = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                })

                local function createColorTrack(title, y, gradient)
                    local trackLabel = Utility:Create("TextLabel", {
                        Parent = editor, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, y),
                        Size = UDim2.fromOffset(18, 22), Text = title, TextColor3 = Library.Theme.SubText,
                        Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 7
                    })
                    Utility:RegisterProperty(trackLabel, "TextColor3", "SubText")
                    local track = Utility:Create("TextButton", {
                        Parent = editor, BackgroundColor3 = Color3.new(1, 1, 1),
                        Position = UDim2.new(0, 24, 0, y + 5), Size = UDim2.new(1, -24, 0, 12),
                        Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 7
                    })
                    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
                    local uiGradient = Utility:Create("UIGradient", {Parent = track, Color = gradient})
                    local marker = Utility:Create("Frame", {
                        Parent = track, BackgroundColor3 = Color3.new(1, 1, 1),
                        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.fromOffset(4, 18), BorderSizePixel = 0, ZIndex = 8
                    })
                    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = marker})
                    Utility:Create("UIStroke", {Parent = marker, Color = Color3.new(0, 0, 0), Transparency = 0.35, Thickness = 1})
                    return track, marker, uiGradient
                end

                local hueTrack, hueMarker = createColorTrack("H", 0, hueGradient)
                local satTrack, satMarker, satGradient = createColorTrack("S", 30, ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(hue,1,1)))
                local valTrack, valMarker, valGradient = createColorTrack("V", 60, ColorSequence.new(Color3.new(0,0,0), Color3.fromHSV(hue,saturation,1)))

                local colorDisplay = Utility:Create("TextButton", {
                    Parent = editor,
                    BackgroundColor3 = currentColor,
                    Position = UDim2.new(0, 24, 0, 94),
                    Size = UDim2.new(1, -24, 0, 30),
                    Text = "",
                    TextColor3 = Color3.new(1, 1, 1),
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    AutoButtonColor = false,
                    ZIndex = 7
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = colorDisplay})
                local previewStroke = Utility:Create("UIStroke", {Parent = colorDisplay, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(previewStroke, "Color", "Stroke")

                local function refreshColor(fire)
                    currentColor = Color3.fromHSV(hue, saturation, value)
                    Library.Flags[flag] = currentColor
                    headerSwatch.BackgroundColor3 = currentColor
                    colorDisplay.BackgroundColor3 = currentColor
                    colorDisplay.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R * 255 + 0.5), math.floor(currentColor.G * 255 + 0.5), math.floor(currentColor.B * 255 + 0.5))
                    local luminance = currentColor.R * 0.299 + currentColor.G * 0.587 + currentColor.B * 0.114
                    colorDisplay.TextColor3 = luminance > 0.62 and Color3.fromRGB(18, 18, 24) or Color3.new(1, 1, 1)
                    hueMarker.Position = UDim2.new(hue, 0, 0.5, 0)
                    satMarker.Position = UDim2.new(saturation, 0, 0.5, 0)
                    valMarker.Position = UDim2.new(value, 0, 0.5, 0)
                    satGradient.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(hue,1,1))
                    valGradient.Color = ColorSequence.new(Color3.new(0,0,0), Color3.fromHSV(hue,saturation,1))
                    if fire ~= false then
                        Utility:SafeCall(callback, currentColor)
                        for _, listener in ipairs(listeners) do Utility:SafeCall(listener, currentColor) end
                    end
                end

                local function bindTrack(track, setter)
                    local dragging = false
                    local dragInput = nil
                    local function update(input)
                        setter(math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1))
                        refreshColor(true)
                    end
                    Library:Connect(track.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            dragInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
                            update(input)
                        end
                    end)
                    Library:Connect(UserInputService.InputChanged, function(input)
                        local pointerMove = input.UserInputType == Enum.UserInputType.MouseMovement
                            or (input.UserInputType == Enum.UserInputType.Touch and input == dragInput)
                        if dragging and pointerMove then update(input) end
                    end)
                    Library:Connect(UserInputService.InputEnded, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
                    end)
                end
                bindTrack(hueTrack, function(x) hue = x end)
                bindTrack(satTrack, function(x) saturation = x end)
                bindTrack(valTrack, function(x) value = x end)

                local function setExpanded(open)
                    expanded = open == true
                    Utility:Tween(headerArrow, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = expanded and 180 or 0})
                    Utility:Tween(container, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, expanded and (headerHeight + 142) or headerHeight)
                    })
                    task.delay(Library.ReducedMotion and 0 or 0.23, RefreshLayout)
                end
                Library:Connect(headerButton.MouseButton1Click, function()
                    setExpanded(not expanded)
                end)
                Library:Connect(colorDisplay.MouseButton1Click, function()
                    if type(setclipboard) == "function" then
                        setclipboard(colorDisplay.Text)
                        Library:Notify({Title = "Color copied", Content = colorDisplay.Text, Duration = 2})
                    end
                end)
                refreshColor(false)
                addElement({Holder = container, Text = name})
                local controller = finishController({
                    Type = "ColorPicker",
                    Set = function(self, color) hue, saturation, value = Color3.toHSV(color); refreshColor(true) end,
                    SetColor = function(self, color) self:Set(color) end,
                    Get = function() return currentColor end,
                    OnChanged = function(self, fn) table.insert(listeners, fn) end,
                    SetExpanded = function(self, open) if expanded ~= (open == true) then setExpanded(open) end end
                }, container, name)
                Library.Options[flag] = controller
                return controller
            end

            -- TABBOX (minitabs)
            function Section:CreateTabbox()
                local tabboxContainer = Utility:Create("Frame", {
                    Parent = ContentContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                local buttonBar = Utility:Create("Frame", {
                    Parent = tabboxContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    ZIndex = 6
                })
                local buttonLayout = Utility:Create("UIListLayout", {
                    Parent = buttonBar,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    Padding = UDim.new(0, 4)
                })
                local contentArea = Utility:Create("Frame", {
                    Parent = tabboxContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 34),
                    Size = UDim2.new(1, 0, 1, -34),
                    ZIndex = 6,
                    ClipsDescendants = true
                })
                local tabs = {}
                local activeTab = nil

                local function resize()
                    local totalHeight = 34 + (activeTab and activeTab.ContentSize or 0)
                    tabboxContainer.Size = UDim2.new(1, 0, 0, totalHeight)
                    RefreshLayout()
                end

                local tabbox = {
                    AddTab = function(self, tabName, contentBuilder)
                        local btn = Utility:Create("TextButton", {
                            Parent = buttonBar,
                            BackgroundColor3 = Library.Theme.Surface,
                            Size = UDim2.new(0, 80, 1, 0),
                            Text = tabName,
                            TextColor3 = Library.Theme.Text,
                            Font = Enum.Font.GothamBold,
                            TextSize = 12,
                            AutoButtonColor = false,
                            ZIndex = 7
                        })
                        Utility:RegisterProperty(btn, "BackgroundColor3", "Surface")
                        Utility:RegisterProperty(btn, "TextColor3", "Text")
                        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = btn})
                        local content = Utility:Create("Frame", {
                            Parent = contentArea,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Visible = false,
                            ZIndex = 7
                        })
                        local tab = { Button = btn, Content = content, ContentSize = 0, Built = false }
                        table.insert(tabs, tab)
                        local function activate()
                            for _, t in ipairs(tabs) do
                                t.Content.Visible = false
                                t.Button.BackgroundColor3 = Library.Theme.Surface
                                t.Button.TextColor3 = Library.Theme.Text
                            end
                            content.Visible = true
                            btn.BackgroundColor3 = Library.Theme.Accent
                            btn.TextColor3 = Color3.new(1, 1, 1)
                            activeTab = tab
                            if contentBuilder and not tab.Built then
                                tab.Built = true
                                Utility:SafeCall(contentBuilder, content)
                            end
                            local list = content:FindFirstChildWhichIsA("UIListLayout")
                            if list then
                                tab.ContentSize = list.AbsoluteContentSize.Y
                            else
                                tab.ContentSize = content.AbsoluteSize.Y
                            end
                            resize()
                        end
                        Library:Connect(btn.MouseButton1Click, activate)
                        if #tabs == 1 then task.defer(activate) end
                        return content
                    end
                }
                addElement({Holder = tabboxContainer})
                return tabbox
            end

            return Section
        end

        return Tab
    end

    -- Create Settings Tab
    local SettingsTab = Window:CreateTab({
        Name = "UI Settings",
        Emoji = EMOJIS.Settings,
        IsSettings = true
    })
    Window.SettingsTab = SettingsTab

    local UISection = SettingsTab:CreateSection({ Name = "UI Controls", Side = "Left" })
    if not IsMobile then
        UISection:CreateLabel("Toggle UI Key: " .. Library.ToggleKey.Name)
        UISection:CreateButton({
            Name = "Change Toggle Key",
            Callback = function()
                Library:Notify({ Title = "Press Any Key", Content = "Press a key to set as toggle...", Emoji = "⌨️", Duration = 5 })
                local conn
                conn = Library:Connect(UserInputService.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Library.ToggleKey = input.KeyCode
                        Library:Notify({ Title = "Success", Content = "Toggle key set to: " .. input.KeyCode.Name, Emoji = EMOJIS.Success })
                        conn:Disconnect()
                    end
                end)
            end
        })
    else
        UISection:CreateLabel("Tap the floating </> button to toggle UI")
    end
    UISection:CreateButton({ Name = "Minimize UI", Icon = ICONS.Minimize, Callback = function() Window:Minimize() end })
    UISection:CreateButton({ Name = "Close UI", Icon = ICONS.Close, Callback = function() Window:Close() end })

    local AppearanceSection = SettingsTab:CreateSection({ Name = "Appearance & motion", Side = "Right" })
    AppearanceSection:CreateDropdown({
        Name = "Theme preset",
        Values = {"Midnight", "Nebula", "Starlight", "Rose", "Aurora", "Ember"},
        Default = Library.ActiveTheme or "Midnight",
        Flag = "__RenLibTheme",
        Callback = function(theme)
            Library:ApplyThemePreset(theme)
        end
    })
    local ScaleSlider = AppearanceSection:CreateSlider({
        Name = "UI scale",
        Min = 60,
        Max = 150,
        Step = 5,
        Default = math.floor(Library.DPIScale * 100),
        Flag = "__RenLibScale",
        CallbackMode = "Release",
        Callback = function(scale)
            task.defer(function() Library:PreviewDPIScale(scale, 10) end)
        end
    })
    AppearanceSection:CreateButton({
        Name = "Reset UI size",
        Description = "Preview the safe 100% size with the same 10-second recovery.",
        Icon = ICONS.Restore,
        Callback = function()
            ScaleSlider:SetSilent(100)
            Library:PreviewDPIScale(100, 10)
        end
    })
    AppearanceSection:CreateToggle({
        Name = "Reduced motion",
        Default = Library.ReducedMotion,
        Flag = "__RenLibReducedMotion",
        Callback = function(enabled) Library:SetReducedMotion(enabled) end
    })
    AppearanceSection:CreateParagraph({
        Title = "Responsive by default",
        Content = "RenLib reflows for phones, tablets, rotation, narrow windows, and the selected UI scale. Scale changes must be kept within 10 seconds or they safely revert."
    })

    if options.ShowInfiniteYield == nil or options.ShowInfiniteYield then
        local UtilitySection = SettingsTab:CreateSection({ Name = "Utilities", Side = "Right" })
        UtilitySection:CreateButton({
            Name = "Launch Infinite Yield",
            Description = "Fetch the current official EdgeIY source after confirmation.",
            Icon = ICONS.Play,
            Callback = function()
                Window:Dialog({
                    Title = "Launch Infinite Yield?",
                    Content = "This downloads and runs the current script directly from the official EdgeIY/infiniteyield repository.",
                    Actions = {
                        {Name = "Cancel"},
                        {Name = "Launch", Primary = true, Callback = function() Library:LaunchInfiniteYield() end}
                    }
                })
            end
        })
    end

    local ConfigSection = SettingsTab:CreateSection({ Name = "Configuration", Side = "Left" })
    local configName = "default"
    ConfigSection:CreateInput({
        Name = "Config name",
        Default = configName,
        Placeholder = "default",
        Flag = "__RenLibConfigName",
        Callback = function(value) configName = value ~= "" and value or "default" end
    })
    ConfigSection:CreateButton({Name = "Save config", Callback = function()
        local ok, err = Library:SaveConfig(configName)
        Library:Notify({Title = ok and "Config saved" or "Save unavailable", Content = ok and configName or tostring(err), Duration = 3})
    end})
    ConfigSection:CreateButton({Name = "Load config", Callback = function()
        local ok, err = Library:LoadConfig(configName)
        Library:Notify({Title = ok and "Config loaded" or "Load failed", Content = ok and configName or tostring(err), Duration = 3})
    end})
    ConfigSection:CreateButton({Name = "Set as autoload", Callback = function()
        local ok, err = Library:SetAutoloadConfig(configName)
        Library:Notify({Title = ok and "Autoload set" or "Autoload unavailable", Content = ok and configName or tostring(err), Duration = 3})
    end})

    Library:Connect(SettingsBtn.MouseButton1Click, function()
        if SettingsTab then
            SettingsTab:Activate()
        end
    end)

    Library.Window = Window
    return Window
end

--// UNLOAD
function Library:Unload(reason)
    if self.Unloaded then return end
    self.Unloaded = true
    self.ScalePreview = nil
    for _, tween in pairs(self.ActiveTweens) do
        pcall(function() tween:Cancel() end)
    end
    for _, conn in pairs(Library.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end
    table.clear(self.Connections)
    table.clear(self.Registry)
    table.clear(self.GradientRegistry)
    table.clear(self.Scales)
    table.clear(self.Options)
    self.Window = nil
    self.ScreenGui = nil
    if RuntimeEnvironment[RUNTIME_KEY] == self then RuntimeEnvironment[RUNTIME_KEY] = nil end
    print("[RenLib] Unloaded" .. (reason and (" (" .. tostring(reason) .. ")") or ""))
end

--// TOGGLE KEY (PC only)
Library:Connect(UserInputService.InputBegan, function(input, gpe)
    if gpe then return end
    if input.KeyCode == Library.ToggleKey then
        if Library.Window then Library.Window:Toggle() end
    end
end)

RuntimeEnvironment[RUNTIME_KEY] = Library
ensureConfigFolders()

print("[RenLib] Loaded - Version " .. Library.Version .. " (" .. Library.DeviceMode .. ")")

return Library
