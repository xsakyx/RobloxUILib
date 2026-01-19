-- Domination UI Library (Titan Build) - ENHANCED VERSION v3.5

--// SERVICES //--
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

--// LOCAL SHORTCUTS //--
local Plr = Players.LocalPlayer
local Mouse = Plr:GetMouse()
local Camera = workspace.CurrentCamera

--// CONSTANTS //--
local HUD_NAME = "DominationLibrary"
local CONFIG_FOLDER = "DominationConfig"
local ASSETS = {
    Shadow = "rbxassetid://6014261993",
    Blur = "rbxassetid://6014261993",
    Icons = {
        Settings = "rbxassetid://6031280882",
        Search = "rbxassetid://6031154871",
        Close = "rbxassetid://6031094678",
        Minimize = "rbxassetid://6031094679",
        Arrow = "rbxassetid://6031091004",
        Check = "rbxassetid://6031094667",
        Info = "rbxassetid://6031763426"
    }
}

--// ROOT LIBRARY //--
local Library = {}
Library.Version = "3.5.0"
Library.Title = "Domination"
Library.Process = {}
Library.Connections = {}
Library.Flags = {}
Library.Unloaded = false
Library.Keybinds = {}
Library.UIToggleKey = Enum.KeyCode.K
Library.IsMinimized = false

Library.Theme = {
    Main = Color3.fromRGB(25, 25, 30),
    Secondary = Color3.fromRGB(15, 15, 20),
    Stroke = Color3.fromRGB(45, 45, 50),
    Divider = Color3.fromRGB(50, 50, 55),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(160, 160, 160),
    Hover = Color3.fromRGB(35, 35, 40),
    Click = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(0, 150, 255),
    Success = Color3.fromRGB(60, 220, 120),
    Warn = Color3.fromRGB(240, 200, 60),
    Error = Color3.fromRGB(240, 60, 60)
}

--// THEME PRESETS
Library.ThemePresets = {
    ["Default"] = {
        Main = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(15, 15, 20),
        Stroke = Color3.fromRGB(45, 45, 50),
        Divider = Color3.fromRGB(50, 50, 55),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Hover = Color3.fromRGB(35, 35, 40),
        Click = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(0, 150, 255)
    },
    ["Dark Red"] = {
        Main = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(15, 15, 20),
        Stroke = Color3.fromRGB(60, 30, 30),
        Divider = Color3.fromRGB(70, 35, 35),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Hover = Color3.fromRGB(30, 25, 25),
        Click = Color3.fromRGB(25, 20, 20),
        Accent = Color3.fromRGB(220, 50, 50)
    },
    ["Purple Dream"] = {
        Main = Color3.fromRGB(25, 20, 35),
        Secondary = Color3.fromRGB(20, 15, 30),
        Stroke = Color3.fromRGB(60, 45, 80),
        Divider = Color3.fromRGB(70, 55, 90),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Hover = Color3.fromRGB(35, 30, 45),
        Click = Color3.fromRGB(30, 25, 40),
        Accent = Color3.fromRGB(160, 80, 255)
    },
    ["Green Matrix"] = {
        Main = Color3.fromRGB(15, 25, 20),
        Secondary = Color3.fromRGB(10, 20, 15),
        Stroke = Color3.fromRGB(30, 60, 40),
        Divider = Color3.fromRGB(35, 70, 45),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Hover = Color3.fromRGB(25, 35, 30),
        Click = Color3.fromRGB(20, 30, 25),
        Accent = Color3.fromRGB(50, 220, 100)
    },
    ["Ocean Blue"] = {
        Main = Color3.fromRGB(15, 20, 30),
        Secondary = Color3.fromRGB(10, 15, 25),
        Stroke = Color3.fromRGB(30, 45, 70),
        Divider = Color3.fromRGB(35, 55, 80),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Hover = Color3.fromRGB(25, 30, 40),
        Click = Color3.fromRGB(20, 25, 35),
        Accent = Color3.fromRGB(50, 150, 255)
    },
    ["Sunset Orange"] = {
        Main = Color3.fromRGB(30, 20, 15),
        Secondary = Color3.fromRGB(25, 15, 10),
        Stroke = Color3.fromRGB(70, 45, 30),
        Divider = Color3.fromRGB(80, 55, 35),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Hover = Color3.fromRGB(40, 30, 25),
        Click = Color3.fromRGB(35, 25, 20),
        Accent = Color3.fromRGB(255, 140, 50)
    }
}

--------------------------------------------------------------------------------
--// MODULE: SIGNAL
--------------------------------------------------------------------------------
local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

function Signal.new()
    local self = setmetatable({}, Signal)
    self._bindableEvent = Instance.new("BindableEvent")
    self._argData = nil
    self._argCount = nil
    return self
end

function Signal:Fire(...)
    self._argData = {...}
    self._argCount = select("#", ...)
    self._bindableEvent:Fire()
end

function Signal:Connect(handler)
    if not (type(handler) == "function") then
        error(("Signal:Connect(%s)"):format(typeof(handler)), 2)
    end
    return self._bindableEvent.Event:Connect(function()
        handler(unpack(self._argData, 1, self._argCount))
    end)
end

function Signal:Wait()
    self._bindableEvent.Event:Wait()
    assert(self._argData, "Missing arg data")
    return unpack(self._argData, 1, self._argCount)
end

function Signal:Destroy()
    if self._bindableEvent then
        self._bindableEvent:Destroy()
        self._bindableEvent = nil
    end
    self._argData = nil
    self._argCount = nil
end

--------------------------------------------------------------------------------
--// MODULE: JANITOR
--------------------------------------------------------------------------------
local Janitor = {}
Janitor.__index = Janitor
Janitor.ClassName = "Janitor"

function Janitor.new()
    return setmetatable({_objects = {}}, Janitor)
end

function Janitor:Add(object, methodName, index)
    if index then self:Remove(index) end
    
    local node = {
        Object = object,
        MethodName = methodName or "Destroy"
    }
    
    if index then
        self._objects[index] = node
    else
        table.insert(self._objects, node)
    end
    
    return object
end

function Janitor:Remove(index)
    local node = self._objects[index]
    if node then
        local object = node.Object
        local methodName = node.MethodName
        
        if type(object) == "function" then
            object()
        elseif typeof(object) == "RBXScriptConnection" then
            object:Disconnect()
        elseif type(object) == "table" and object.Destroy then
            object:Destroy()
        elseif object[methodName] then
            object[methodName](object)
        end
        
        self._objects[index] = nil
    end
end

function Janitor:Cleanup()
    for index, _ in pairs(self._objects) do
        self:Remove(index)
    end
end

function Janitor:Destroy()
    self:Cleanup()
end

--------------------------------------------------------------------------------
--// MODULE: SPRING
--------------------------------------------------------------------------------
local Spring = {}
Spring.__index = Spring

function Spring.new(mass, force, damping, speed)
    return setmetatable({
        Target = 0,
        Position = 0,
        Velocity = 0,
        Mass = mass or 1,
        Force = force or 50,
        Damping = damping or 4,
        Speed = speed or 4
    }, Spring)
end

function Spring:Update(dt)
    local scaledDelta = dt * self.Speed
    local force = self.Target - self.Position
    local acceleration = (force * self.Force) / self.Mass
    
    self.Velocity = self.Velocity + acceleration * scaledDelta
    self.Velocity = self.Velocity * (1 - self.Damping * dt)
    self.Position = self.Position + self.Velocity * scaledDelta
    
    return self.Position
end

function Spring:Shove(force)
    self.Velocity = self.Velocity + force
end

function Spring:SetTarget(target)
    self.Target = target
end

--------------------------------------------------------------------------------
--// MODULE: UTILITY
--------------------------------------------------------------------------------
local Utility = {}

function Utility:RandomString(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

function Utility:Create(class, properties)
    local instance = Instance.new(class)
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
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    if callback then
        tween.Completed:Connect(callback)
    end
    return tween
end

function Utility:GetTextSize(text, font, size, width)
    if not text or not font or not size then return Vector2.new(0, 0) end
    return TextService:GetTextSize(text, size, font, Vector2.new(width or 10000, 10000))
end

function Utility:MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
            
            local ts = TweenService:Create(object, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {Position = newPos})
            ts:Play()
        end
    end)
end

function Utility:ReadFile(path)
    local success, result = pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        return readfile(CONFIG_FOLDER .. "/" .. path)
    end)
    return success and result or nil
end

function Utility:WriteFile(path, content)
    local success, err = pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        writefile(CONFIG_FOLDER .. "/" .. path, content)
    end)
    if not success then warn("Failed to write config: " .. tostring(err)) end
end

--------------------------------------------------------------------------------
--// CORE UI: WINDOW
--------------------------------------------------------------------------------
function Library:CreateWindow(options)
    options = options or {}
    local WindowTitle = options.Name or "Domination UI"
    local WindowSubTitle = options.LoadingTitle or "Initializing..."
    local ConfigName = options.ConfigurationSaving and options.ConfigurationSaving.FileName or "DominationConfig"
    
    -- Main ScreenGui
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = Utility:RandomString(10),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    -- Protect Gui
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
        Position = UDim2.new(0.5, -400, 0.5, -275),
        Size = UDim2.new(0, 800, 0, 550),
        ClipsDescendants = false
    })
    
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
    local MainStroke = Utility:Create("UIStroke", {
        Parent = MainFrame,
        Color = Library.Theme.Stroke,
        Thickness = 1,
        Transparency = 0
    })

    -- Shadow
    local Shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -25, 0, -25),
        Size = UDim2.new(1, 50, 1, 50),
        Image = ASSETS.Shadow,
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1
    })

    -- Top Control Bar (Close, Minimize, Settings)
    local ControlBar = Utility:Create("Frame", {
        Name = "ControlBar",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -150, 0, 10),
        Size = UDim2.new(0, 140, 0, 30),
        ZIndex = 100
    })

    local function CreateControlButton(icon, position, callback)
        local btn = Utility:Create("TextButton", {
            Parent = ControlBar,
            BackgroundColor3 = Library.Theme.Secondary,
            Position = position,
            Size = UDim2.new(0, 30, 0, 30),
            AutoButtonColor = false,
            Text = ""
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        Utility:Create("UIStroke", {Parent = btn, Color = Library.Theme.Stroke, Thickness = 1})
        
        local ico = Utility:Create("ImageLabel", {
            Parent = btn,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            Image = icon,
            ImageColor3 = Library.Theme.SubText
        })
        
        btn.MouseEnter:Connect(function()
            Utility:Tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover})
            Utility:Tween(ico, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.Accent})
        end)
        
        btn.MouseLeave:Connect(function()
            Utility:Tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Secondary})
            Utility:Tween(ico, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.SubText})
        end)
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Close Button
    CreateControlButton(ASSETS.Icons.Close, UDim2.new(0, 0, 0, 0), function()
        Library:Unload()
    end)

    -- Minimize Button
    CreateControlButton(ASSETS.Icons.Minimize, UDim2.new(0, 38, 0, 0), function()
        Library.IsMinimized = not Library.IsMinimized
        if Library.IsMinimized then
            Utility:Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
        else
            Utility:Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 800, 0, 550),
                Position = UDim2.new(0.5, -400, 0.5, -275)
            })
        end
    end)

    -- Settings Button (UI Settings)
    local SettingsBtn = CreateControlButton(ASSETS.Icons.Settings, UDim2.new(0, 76, 0, 0), function()
        -- Will open settings panel
    end)

    -- Info/Readme Button
    local InfoBtn = CreateControlButton(ASSETS.Icons.Info, UDim2.new(0, 114, 0, 0), function()
        -- Will open readme tab
    end)

    -- Sidebar
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Secondary,
        Size = UDim2.new(0, 70, 1, 0),
        ZIndex = 2
    })
    
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Sidebar})
    Utility:Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        ZIndex = 2
    })
    
    local SidebarDivider = Utility:Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Divider,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        ZIndex = 3
    })
    
    local TabContainer = Utility:Create("ScrollingFrame", {
        Name = "Tabs",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 80),
        Size = UDim2.new(1, 0, 1, -120),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 4
    })
    
    Utility:Create("UIListLayout", {
        Parent = TabContainer,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12)
    })

    -- Logo Area
    local Logo = Utility:Create("ImageLabel", {
        Name = "Logo",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 20),
        Size = UDim2.new(0, 40, 0, 40),
        Image = "rbxassetid://4483345998",
        ZIndex = 5
    })
    
    -- Content Area
    local Pages = Utility:Create("Frame", {
        Name = "Pages",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        ClipsDescendants = true
    })

    -- Draggable Topbar
    local DragFrame = Utility:Create("Frame", {
        Name = "DragFrame",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 10
    })
    Utility:MakeDraggable(DragFrame, MainFrame)
    
    local TitleLabel = Utility:Create("TextLabel", {
        Parent = Pages,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 20),
        Size = UDim2.new(1, -200, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = WindowTitle,
        TextColor3 = Library.Theme.Text,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Notification Container
    local NotifyArea = Utility:Create("Frame", {
        Name = "Notifications",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 300, 1, 0),
        AnchorPoint = Vector2.new(1, 1)
    })
    
    Utility:Create("UIListLayout", {
        Parent = NotifyArea,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })
    
    -- Window Object
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Gui = ScreenGui,
        Main = MainFrame,
        SettingsTab = nil,
        ReadmeTab = nil
    }

    --// UPDATE THEME FUNCTION
    function Library:UpdateTheme(newTheme)
        for key, value in pairs(newTheme) do
            Library.Theme[key] = value
        end
        
        -- Update all UI elements
        MainFrame.BackgroundColor3 = Library.Theme.Main
        MainStroke.Color = Library.Theme.Stroke
        Sidebar.BackgroundColor3 = Library.Theme.Secondary
        SidebarDivider.BackgroundColor3 = Library.Theme.Divider
        TitleLabel.TextColor3 = Library.Theme.Text
        
        Library:Notify({
            Title = "Theme Updated",
            Content = "UI theme has been refreshed!",
            Duration = 2
        })
    end
    
    --// NOTIFICATION SYSTEM
    function Library:Notify(notifyOpts)
        notifyOpts = notifyOpts or {}
        local Title = notifyOpts.Title or "Notification"
        local Content = notifyOpts.Content or ""
        local Duration = notifyOpts.Duration or 3
        local Image = notifyOpts.Image or ASSETS.Icons.Settings
        
        local NotifyFrame = Utility:Create("Frame", {
            Name = "Notify",
            Parent = NotifyArea,
            BackgroundColor3 = Library.Theme.Main,
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(2, 0, 0, 0),
            ClipsDescendants = true
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = NotifyFrame})
        Utility:Create("UIStroke", {
            Parent = NotifyFrame,
            Color = Library.Theme.Stroke,
            Thickness = 1
        })
        
        Utility:Create("ImageLabel", {
            Parent = NotifyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 12),
            Size = UDim2.new(0, 36, 0, 36),
            Image = Image,
            ImageColor3 = Library.Theme.Accent 
        })
        
        Utility:Create("TextLabel", {
            Parent = NotifyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 58, 0, 12),
            Size = UDim2.new(1, -68, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = Title,
            TextColor3 = Library.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        Utility:Create("TextLabel", {
            Parent = NotifyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 58, 0, 30),
            Size = UDim2.new(1, -68, 0, 20),
            Font = Enum.Font.Gotham,
            Text = Content,
            TextColor3 = Library.Theme.SubText,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })
        
        NotifyFrame.Position = UDim2.new(1, 300, 0, 0)
        Utility:Tween(NotifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        })
        
        local Closed = false
        local function Close()
            if Closed then return end
            Closed = true
            
            local t = Utility:Tween(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 300, 0, 0),
                BackgroundTransparency = 1
            })
            t.Completed:Wait()
            NotifyFrame:Destroy()
        end
        
        task.delay(Duration, Close)
    end

    --// CREATE SETTINGS TAB (Special internal tab)
    local function CreateSettingsTab()
        local SettingsTab = Window:CreateTab({
            Name = "UI Settings",
            Icon = ASSETS.Icons.Settings
        })
        
        Window.SettingsTab = SettingsTab
        
        local GeneralSection = SettingsTab:CreateSection({Name = "General Settings", Side = "Left"})
        
        -- Toggle Key Setting
        GeneralSection:CreateLabel("UI Toggle Keybind")
        local toggleKeyDisplay = GeneralSection:CreateTextbox({
            Name = "Toggle Key",
            Default = Library.UIToggleKey.Name,
            Placeholder = "Press a key...",
            Callback = function() end
        })
        
        local listeningForKey = false
        local keyConn
        
        local listenBtn = GeneralSection:CreateButton({
            Name = "Click to Set Keybind",
            Callback = function()
                if listeningForKey then return end
                listeningForKey = true
                listenBtn:SetText("Press any key...")
                
                keyConn = UserInputService.InputBegan:Connect(function(input, gpe)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Library.UIToggleKey = input.KeyCode
                        toggleKeyDisplay:Set(input.KeyCode.Name)
                        listenBtn:SetText("Click to Set Keybind")
                        listeningForKey = false
                        keyConn:Disconnect()
                        Library:Notify({
                            Title = "Keybind Updated",
                            Content = "UI Toggle: " .. input.KeyCode.Name,
                            Duration = 2
                        })
                    end
                end)
            end
        })
        
        -- Theme Section
        local ThemeSection = SettingsTab:CreateSection({Name = "Theme Settings", Side = "Right"})
        
        ThemeSection:CreateLabel("Preset Themes")
        local themeNames = {}
        for name, _ in pairs(Library.ThemePresets) do
            table.insert(themeNames, name)
        end
        
        ThemeSection:CreateDropdown({
            Name = "Theme Preset",
            Values = themeNames,
            Default = "Default",
            Callback = function(selected)
                if Library.ThemePresets[selected] then
                    Library:UpdateTheme(Library.ThemePresets[selected])
                end
            end
        })
        
        ThemeSection:CreateLabel("Custom Accent Color")
        ThemeSection:CreateColorPicker({
            Name = "Accent Color",
            Default = Library.Theme.Accent,
            Callback = function(color)
                Library.Theme.Accent = color
                Library:UpdateTheme(Library.Theme)
            end
        })
        
        -- Advanced Section
        local AdvancedSection = SettingsTab:CreateSection({Name = "Advanced", Side = "Left"})
        
        AdvancedSection:CreateToggle({
            Name = "Silent Mode (Beta)",
            Default = false,
            Callback = function(enabled)
                if enabled then
                    Library:Notify({
                        Title = "Silent Mode",
                        Content = "This feature is in beta!",
                        Duration = 3
                    })
                end
            end
        })
        
        AdvancedSection:CreateLabel("Silent mode will suppress all script prints")
    end
    
    --// CREATE README TAB
    local function CreateReadmeTab()
        local ReadmeTab = Window:CreateTab({
            Name = "UI Readme",
            Icon = ASSETS.Icons.Info
        })
        
        Window.ReadmeTab = ReadmeTab
        
        local IntroSection = ReadmeTab:CreateSection({Name = "Introduction", Side = "Left"})
        IntroSection:CreateLabel("Welcome to Domination UI Library v" .. Library.Version)
        IntroSection:CreateLabel("This guide will help you create your own UI")
        
        local BasicSection = ReadmeTab:CreateSection({Name = "Basic Usage", Side = "Left"})
        BasicSection:CreateLabel("-- Load the library:")
        BasicSection:CreateLabel('local Library = loadstring(game:HttpGet("..."))()')
        BasicSection:CreateLabel("")
        BasicSection:CreateLabel("-- Create a window:")
        BasicSection:CreateLabel('local Window = Library:CreateWindow({')
        BasicSection:CreateLabel('    Name = "My Script"')
        BasicSection:CreateLabel('})')
        
        local TabSection = ReadmeTab:CreateSection({Name = "Creating Tabs", Side = "Right"})
        TabSection:CreateLabel("-- Create a tab:")
        TabSection:CreateLabel('local Tab = Window:CreateTab({')
        TabSection:CreateLabel('    Name = "Main",')
        TabSection:CreateLabel('    Icon = "rbxassetid://..."')
        TabSection:CreateLabel('})')
        TabSection:CreateLabel("")
        TabSection:CreateLabel("-- Create a section:")
        TabSection:CreateLabel('local Section = Tab:CreateSection({')
        TabSection:CreateLabel('    Name = "Features",')
        TabSection:CreateLabel('    Side = "Left" -- or "Right"')
        TabSection:CreateLabel('})')
        
        local ComponentsSection = ReadmeTab:CreateSection({Name = "Components", Side = "Left"})
        ComponentsSection:CreateLabel("Available components:")
        ComponentsSection:CreateLabel("• Button - Simple clickable button")
        ComponentsSection:CreateLabel("• Toggle - On/Off switch")
        ComponentsSection:CreateLabel("• Slider - Range selector")
        ComponentsSection:CreateLabel("• Dropdown - Multi-choice selector")
        ComponentsSection:CreateLabel("• Textbox - Text input field")
        ComponentsSection:CreateLabel("• Keybind - Keyboard key selector")
        ComponentsSection:CreateLabel("• ColorPicker - Color selector")
        ComponentsSection:CreateLabel("• Label - Static text display")
        
        local ExampleSection = ReadmeTab:CreateSection({Name = "Button Example", Side = "Right"})
        ExampleSection:CreateLabel("-- Create a button:")
        ExampleSection:CreateLabel('Section:CreateButton({')
        ExampleSection:CreateLabel('    Name = "Click Me",')
        ExampleSection:CreateLabel('    Callback = function()')
        ExampleSection:CreateLabel('        print("Button clicked!")')
        ExampleSection:CreateLabel('    end')
        ExampleSection:CreateLabel('})')
        
        local ToggleExample = ReadmeTab:CreateSection({Name = "Toggle Example", Side = "Left"})
        ToggleExample:CreateLabel("-- Create a toggle:")
        ToggleExample:CreateLabel('Section:CreateToggle({')
        ToggleExample:CreateLabel('    Name = "Enable Feature",')
        ToggleExample:CreateLabel('    Default = false,')
        ToggleExample:CreateLabel('    Flag = "MyToggle",')
        ToggleExample:CreateLabel('    Callback = function(value)')
        ToggleExample:CreateLabel('        print("Toggle:", value)')
        ToggleExample:CreateLabel('    end')
        ToggleExample:CreateLabel('})')
        
        local SliderExample = ReadmeTab:CreateSection({Name = "Slider Example", Side = "Right"})
        SliderExample:CreateLabel("-- Create a slider:")
        SliderExample:CreateLabel('Section:CreateSlider({')
        SliderExample:CreateLabel('    Name = "Speed",')
        SliderExample:CreateLabel('    Min = 0,')
        SliderExample:CreateLabel('    Max = 100,')
        SliderExample:CreateLabel('    Default = 50,')
        SliderExample:CreateLabel('    Callback = function(value)')
        SliderExample:CreateLabel('        print("Speed:", value)')
        SliderExample:CreateLabel('    end')
        SliderExample:CreateLabel('})')
        
        local NotifySection = ReadmeTab:CreateSection({Name = "Notifications", Side = "Left"})
        NotifySection:CreateLabel("-- Send a notification:")
        NotifySection:CreateLabel('Library:Notify({')
        NotifySection:CreateLabel('    Title = "Success",')
        NotifySection:CreateLabel('    Content = "Script loaded!",')
        NotifySection:CreateLabel('    Duration = 3')
        NotifySection:CreateLabel('})')
        
        local ConfigSection = ReadmeTab:CreateSection({Name = "Config System", Side = "Right"})
        ConfigSection:CreateLabel("-- Save configuration:")
        ConfigSection:CreateLabel('Library:SaveConfig("myconfig")')
        ConfigSection:CreateLabel("")
        ConfigSection:CreateLabel("-- Load configuration:")
        ConfigSection:CreateLabel('Library:LoadConfig("myconfig")')
        ConfigSection:CreateLabel("")
        ConfigSection:CreateLabel("-- Access flags:")
        ConfigSection:CreateLabel('local toggleValue = Library.Flags["MyToggle"]')
    end
    
    -- Settings button callback
    SettingsBtn.MouseButton1Click:Connect(function()
        if not Window.SettingsTab then
            CreateSettingsTab()
        end
        Window.SettingsTab:Activate()
    end)
    
    -- Info button callback
    InfoBtn.MouseButton1Click:Connect(function()
        if not Window.ReadmeTab then
            CreateReadmeTab()
        end
        Window.ReadmeTab:Activate()
    end)
    
    --// COMPONENT: TAB
    function Window:CreateTab(options)
        options = options or {}
        local Name = options.Name or "Tab"
        local Icon = options.Icon or "rbxassetid://4483345998"
        
        local Tab = {
            Name = Name,
            Active = false,
            Sections = {}
        }
        
        -- Tab Button
        local TabBtn = Utility:Create("TextButton", {
            Name = Name,
            Parent = TabContainer,
            BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 44, 0, 44),
            AutoButtonColor = false,
            Text = "",
            ZIndex = 5
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TabBtn})
        
        local TabIcon = Utility:Create("ImageLabel", {
            Parent = TabBtn,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 24, 0, 24),
            BackgroundTransparency = 1,
            Image = Icon,
            ImageColor3 = Library.Theme.SubText,
            ZIndex = 6
        })
        
        local Indicator = Utility:Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Library.Theme.Accent,
            Position = UDim2.new(0, 0, 0.5, -10),
            Size = UDim2.new(0, 4, 0, 20),
            Transparency = 1
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Indicator})

        -- Page Container
        local Page = Utility:Create("ScrollingFrame", {
            Name = Name,
            Parent = Pages,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 70),
            Size = UDim2.new(1, -40, 1, -90),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        })
        
        local LeftColumn = Utility:Create("Frame", {
            Name = "Left",
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0, 0, 0, 0)
        })
        local RightColumn = Utility:Create("Frame", {
            Name = "Right",
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0.5, 6, 0, 0)
        })
        
        local LeftLayout = Utility:Create("UIListLayout", {
            Parent = LeftColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })
        local RightLayout = Utility:Create("UIListLayout", {
            Parent = RightColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })

        local function UpdateCanvas()
            local LeftH = LeftLayout.AbsoluteContentSize.Y
            local RightH = RightLayout.AbsoluteContentSize.Y
            Page.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftH, RightH) + 20)
        end
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        function Tab:Activate()
            if Window.ActiveTab == Tab then return end
            if Window.ActiveTab then
                Window.ActiveTab:Deactivate()
            end
            
            Tab.Active = true
            Window.ActiveTab = Tab
            
            Utility:Tween(TabIcon, TweenInfo.new(0.3), {ImageColor3 = Library.Theme.Accent})
            Utility:Tween(Indicator, TweenInfo.new(0.3), {Transparency = 0, Position = UDim2.new(0, -12, 0.5, -10)})
            Page.Visible = true
            Page.CanvasPosition = Vector2.new(0,0)
        end
        
        function Tab:Deactivate()
            Tab.Active = false
            Utility:Tween(TabIcon, TweenInfo.new(0.3), {ImageColor3 = Library.Theme.SubText})
            Utility:Tween(Indicator, TweenInfo.new(0.3), {Transparency = 1, Position = UDim2.new(0, 0, 0.5, -10)})
            Page.Visible = false
        end
        
        TabBtn.MouseButton1Click:Connect(function() Tab:Activate() end)
        
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Tab:Activate() end
        
        --// COMPONENT: SECTION
        function Tab:CreateSection(options)
            options = options or {}
            local SectionName = options.Name or "Section"
            local Side = options.Side or "Auto"
            
            local ParentCol = LeftColumn
            if Side == "Right" then 
                ParentCol = RightColumn
            elseif Side == "Auto" then
                if LeftLayout.AbsoluteContentSize.Y > RightLayout.AbsoluteContentSize.Y then
                    ParentCol = RightColumn
                end
            end
            
            local Section = { Name = SectionName }
            
            local SectionFrame = Utility:Create("Frame", {
                Name = SectionName,
                Parent = ParentCol,
                BackgroundColor3 = Library.Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 50),
                ClipsDescendants = true
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SectionFrame})
            Utility:Create("UIStroke", {
                Parent = SectionFrame,
                Color = Library.Theme.Stroke, 
                Thickness = 1
            })
            
            local Head = Utility:Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 10),
                Size = UDim2.new(1, -24, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = SectionName,
                TextColor3 = Library.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ContentContainer = Utility:Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 0, 0)
            })
            
            local ContentLayout = Utility:Create("UIListLayout", {
                Parent = ContentContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ContentContainer.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y)
                Utility:Tween(SectionFrame, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 45)
                })
            end)

            function Section:Add(object)
                object.Parent = ContentContainer
            end
            
            --// COMPONENT: BUTTON
            function Section:CreateButton(options)
                options = options or {}
                local Name = options.Name or "Button"
                local Callback = options.Callback or function() end
                
                local ButtonContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true
                })
                
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ButtonContainer})
                local Stroke = Utility:Create("UIStroke", {
                    Parent = ButtonContainer,
                    Color = Library.Theme.Stroke,
                    Thickness = 1
                })
                
                local Btn = Utility:Create("TextButton", {
                    Parent = ButtonContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    AutoButtonColor = false
                })
                
                local Hovering = false
                Btn.MouseEnter:Connect(function()
                    Hovering = true
                    Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Accent})
                    Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover})
                end)
                
                Btn.MouseLeave:Connect(function()
                    Hovering = false
                    Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Stroke})
                    Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Main})
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Callback()
                    task.spawn(function()
                        local Ripple = Utility:Create("Frame", {
                            Parent = ButtonContainer,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 0.8,
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            Size = UDim2.new(0, 0, 0, 0),
                            AnchorPoint = Vector2.new(0.5, 0.5)
                        })
                        
                        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Ripple})
                        
                        local t = Utility:Tween(Ripple, TweenInfo.new(0.4), {
                            Size = UDim2.new(0, 200, 0, 200),
                            BackgroundTransparency = 1
                        })
                        t.Completed:Wait()
                        Ripple:Destroy()
                    end)
                end)
                
                return {
                    SetText = function(self, text)
                        Btn.Text = text
                    end
                }
            end

            --// COMPONENT: TOGGLE
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
                
                local ToggleContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true
                })
                
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ToggleContainer})
                local Stroke = Utility:Create("UIStroke", {
                    Parent = ToggleContainer,
                    Color = Library.Theme.Stroke,
                    Thickness = 1
                })
                
                local ToggleBtn = Utility:Create("TextButton", {
                    Parent = ToggleContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                Utility:Create("UIPadding", {Parent = ToggleBtn, PaddingLeft = UDim.new(0, 12)})
                
                local SwitchBg = Utility:Create("Frame", {
                    Parent = ToggleBtn,
                    BackgroundColor3 = CurrentValue and Library.Theme.Accent or Color3.fromRGB(50, 50, 55),
                    Position = UDim2.new(1, -45, 0.5, -10),
                    Size = UDim2.new(0, 35, 0, 20),
                    BorderSizePixel = 0
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwitchBg})
                
                local SwitchDot = Utility:Create("Frame", {
                    Parent = SwitchBg,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwitchDot})
                
                local function Update()
                    Library.Flags[Flag] = CurrentValue
                    Callback(CurrentValue)
                    
                    if CurrentValue then
                        Utility:Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Accent})
                        Utility:Tween(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)})
                    else
                        Utility:Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)})
                        Utility:Tween(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)})
                    end
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    CurrentValue = not CurrentValue
                    Update()
                end)
                
                ToggleBtn.MouseEnter:Connect(function()
                    Utility:Tween(ToggleContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover})
                end)
                ToggleBtn.MouseLeave:Connect(function()
                    Utility:Tween(ToggleContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Main})
                end)

                return {
                    Set = function(self, val)
                        CurrentValue = val
                        Update()
                    end
                }
            end
            
            --// COMPONENT: SLIDER
            function Section:CreateSlider(options)
                options = options or {}
                local Name = options.Name or "Slider"
                local Min = options.Min or 0
                local Max = options.Max or 100
                local Default = options.Default or Min
                local Callback = options.Callback or function() end
                local Flag = options.Flag or Name
                
                local Value = Default
                if Library.Flags[Flag] ~= nil then Value = Library.Flags[Flag] end
                
                local SliderContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, 50),
                    ClipsDescendants = true
                })
                
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SliderContainer})
                Utility:Create("UIStroke", {
                    Parent = SliderContainer,
                    Color = Library.Theme.Stroke,
                    Thickness = 1
                })
                
                local Title = Utility:Create("TextLabel", {
                    Parent = SliderContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8),
                    Size = UDim2.new(1, -24, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Utility:Create("TextLabel", {
                    Parent = SliderContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8),
                    Size = UDim2.new(1, -24, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(Value),
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local Track = Utility:Create("TextButton", {
                    Parent = SliderContainer,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                    Position = UDim2.new(0, 12, 0, 34),
                    Size = UDim2.new(1, -24, 0, 6),
                    AutoButtonColor = false,
                    Text = ""
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})
                
                local Fill = Utility:Create("Frame", {
                    Parent = Track,
                    BackgroundColor3 = Library.Theme.Accent,
                    Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
                    BorderSizePixel = 0
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})
                
                local Dragging = false
                
                local function Update(input)
                    local SizeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local NewValue = Min + ((Max - Min) * SizeX)
                    
                    NewValue = math.floor(NewValue + 0.5)
                    
                    Value = NewValue
                    ValueLabel.Text = tostring(Value)
                    Library.Flags[Flag] = Value
                    Callback(Value)
                    
                    Utility:Tween(Fill, TweenInfo.new(0.05), {Size = UDim2.new(SizeX, 0, 1, 0)})
                end
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        Update(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                
                return {
                    Set = function(self, val)
                        Value = math.clamp(val, Min, Max)
                        ValueLabel.Text = tostring(Value)
                        Library.Flags[Flag] = Value
                        Utility:Tween(Fill, TweenInfo.new(0.1), {Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)})
                        Callback(Value)
                    end
                }
            end

            --// COMPONENT: DROPDOWN
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
                
                local Expanded = false
                local DropdownContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, 44),
                    ClipsDescendants = true,
                    ZIndex = 5
                })
                
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownContainer})
                Utility:Create("UIStroke", {
                    Parent = DropdownContainer,
                    Color = Library.Theme.Stroke,
                    Thickness = 1
                })
                
                local Header = Utility:Create("TextButton", {
                    Parent = DropdownContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 44),
                    AutoButtonColor = false,
                    Text = ""
                })
                
                local Title = Utility:Create("TextLabel", {
                    Parent = Header,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueText = Utility:Create("TextLabel", {
                    Parent = Header,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -48, 0, 0),
                    Size = UDim2.new(0, 100, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = Multi and "..." or tostring(CurrentValue),
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local Arrow = Utility:Create("ImageLabel", {
                    Parent = Header,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    Image = ASSETS.Icons.Arrow,
                    ImageColor3 = Library.Theme.SubText,
                    Rotation = 0
                })
                
                local ListFrame = Utility:Create("ScrollingFrame", {
                    Parent = DropdownContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 44),
                    Size = UDim2.new(1, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Library.Theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0
                })
                
                local ListLayout = Utility:Create("UIListLayout", {
                    Parent = ListFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                })
                
                ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
                end)
                
                local function Toggle()
                    Expanded = not Expanded
                    if Expanded then
                        Utility:Tween(Arrow, TweenInfo.new(0.2), {Rotation = 180})
                        Utility:Tween(DropdownContainer, TweenInfo.new(0.3), {
                            Size = UDim2.new(1, 0, 0, math.min(44 + ListLayout.AbsoluteContentSize.Y + 12, 200))
                        })
                        Utility:Tween(ListFrame, TweenInfo.new(0.3), {
                            Size = UDim2.new(1, 0, 0, math.min(ListLayout.AbsoluteContentSize.Y + 8, 150))
                        })
                    else
                        Utility:Tween(Arrow, TweenInfo.new(0.2), {Rotation = 0})
                        Utility:Tween(DropdownContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 44)})
                        Utility:Tween(ListFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)})
                    end
                end
                
                Header.MouseButton1Click:Connect(Toggle)
                
                for i, value in ipairs(Values) do
                    local Option = Utility:Create("TextButton", {
                        Parent = ListFrame,
                        BackgroundColor3 = Library.Theme.Secondary,
                        Size = UDim2.new(1, -8, 0, 30),
                        AutoButtonColor = false,
                        Text = value,
                        Font = Enum.Font.Gotham,
                        TextColor3 = Library.Theme.Text,
                        TextSize = 12
                    })
                    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Option})
                    
                    Option.MouseEnter:Connect(function()
                        Utility:Tween(Option, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover})
                    end)
                    Option.MouseLeave:Connect(function()
                        Utility:Tween(Option, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Secondary})
                    end)
                    
                    Option.MouseButton1Click:Connect(function()
                        if Multi then
                            if not CurrentValue then CurrentValue = {} end
                            local found = false
                            for k, v in pairs(CurrentValue) do
                                if v == value then
                                    table.remove(CurrentValue, k)
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                table.insert(CurrentValue, value)
                            end
                            ValueText.Text = #CurrentValue > 0 and table.concat(CurrentValue, ", ") or "..."
                        else
                            CurrentValue = value
                            ValueText.Text = tostring(value)
                            Toggle()
                        end
                        Library.Flags[Flag] = CurrentValue
                        Callback(CurrentValue)
                    end)
                end
                
                return {
                    Set = function(self, val)
                        CurrentValue = val
                        ValueText.Text = Multi and (type(val) == "table" and table.concat(val, ", ") or "...") or tostring(val)
                        Library.Flags[Flag] = CurrentValue
                        Callback(CurrentValue)
                    end,
                    Refresh = function(self, values)
                        Values = values
                        for _, child in pairs(ListFrame:GetChildren()) do
                            if child:IsA("TextButton") then child:Destroy() end
                        end
                        -- Recreate options (omitted for brevity, same as above)
                    end
                }
            end
            
            --// COMPONENT: TEXTBOX
            function Section:CreateTextbox(options)
                options = options or {}
                local Name = options.Name or "Textbox"
                local Default = options.Default or ""
                local Placeholder = options.Placeholder or "Enter text..."
                local Callback = options.Callback or function() end
                local Flag = options.Flag or Name
                
                local CurrentValue = Default
                if Library.Flags[Flag] ~= nil then CurrentValue = Library.Flags[Flag] end
                
                local TextboxContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, 70),
                    ClipsDescendants = true
                })
                
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TextboxContainer})
                Utility:Create("UIStroke", {
                    Parent = TextboxContainer,
                    Color = Library.Theme.Stroke,
                    Thickness = 1
                })
                
                local Title = Utility:Create("TextLabel", {
                    Parent = TextboxContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8),
                    Size = UDim2.new(1, -24, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local InputBox = Utility:Create("TextBox", {
                    Parent = TextboxContainer,
                    BackgroundColor3 = Library.Theme.Secondary,
                    Position = UDim2.new(0, 12, 0, 36),
                    Size = UDim2.new(1, -24, 0, 26),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = Placeholder,
                    PlaceholderColor3 = Library.Theme.SubText,
                    Text = CurrentValue,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = InputBox})
                Utility:Create("UIPadding", {Parent = InputBox, PaddingLeft = UDim.new(0, 8)})
                
                InputBox.FocusLost:Connect(function()
                    CurrentValue = InputBox.Text
                    Library.Flags[Flag] = CurrentValue
                    Callback(CurrentValue)
                end)
                
                return {
                    Set = function(self, text)
                        InputBox.Text = text
                        CurrentValue = text
                        Library.Flags[Flag] = CurrentValue
                        Callback(CurrentValue)
                    end
                }
            end
            
            --// COMPONENT: KEYBIND
            function Section:CreateKeybind(options)
                options = options or {}
                local Name = options.Name or "Keybind"
                local Default = options.Default or Enum.KeyCode.E
                local Callback = options.Callback or function() end
                local Flag = options.Flag or Name
                
                local CurrentKey = Default
                if Library.Flags[Flag] ~= nil then CurrentKey = Library.Flags[Flag] end
                Library.Flags[Flag] = CurrentKey
                
                local Listening = false
                local Connection
                
                local KeybindContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true
                })
                
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeybindContainer})
                local Stroke = Utility:Create("UIStroke", {
                    Parent = KeybindContainer,
                    Color = Library.Theme.Stroke,
                    Thickness = 1
                })
                
                local Title = Utility:Create("TextLabel", {
                    Parent = KeybindContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local KeyButton = Utility:Create("TextButton", {
                    Parent = KeybindContainer,
                    BackgroundColor3 = Library.Theme.Secondary,
                    Position = UDim2.new(1, -90, 0.5, -13),
                    Size = UDim2.new(0, 80, 0, 26),
                    Font = Enum.Font.GothamBold,
                    Text = CurrentKey.Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 12,
                    AutoButtonColor = false
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = KeyButton})
                
                KeyButton.MouseButton1Click:Connect(function()
                    if Listening then return end
                    Listening = true
                    KeyButton.Text = "..."
                    Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Accent})
                    
                    Connection = UserInputService.InputBegan:Connect(function(input, gpe)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            CurrentKey = input.KeyCode
                            KeyButton.Text = CurrentKey.Name
                            Library.Flags[Flag] = CurrentKey
                            Callback(CurrentKey)
                            Listening = false
                            Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Stroke})
                            Connection:Disconnect()
                        end
                    end)
                end)
                
                KeyButton.MouseEnter:Connect(function()
                    if not Listening then
                        Utility:Tween(KeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover})
                    end
                end)
                KeyButton.MouseLeave:Connect(function()
                    if not Listening then
                        Utility:Tween(KeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Secondary})
                    end
                end)
                
                return {
                    Set = function(self, key)
                        CurrentKey = key
                        KeyButton.Text = key.Name
                        Library.Flags[Flag] = CurrentKey
                        Callback(CurrentKey)
                    end
                }
            end
            
            --// COMPONENT: COLORPICKER
            function Section:CreateColorPicker(options)
                options = options or {}
                local Name = options.Name or "Color"
                local Default = options.Default or Color3.fromRGB(255, 255, 255)
                local Callback = options.Callback or function() end
                local Flag = options.Flag or Name
                
                local CurrentColor = Default
                if Library.Flags[Flag] ~= nil then CurrentColor = Library.Flags[Flag] end
                Library.Flags[Flag] = CurrentColor
                
                local Expanded = false
                
                local ColorContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true
                })
                
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ColorContainer})
                Utility:Create("UIStroke", {
                    Parent = ColorContainer,
                    Color = Library.Theme.Stroke,
                    Thickness = 1
                })
                
                local Title = Utility:Create("TextLabel", {
                    Parent = ColorContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ColorDisplay = Utility:Create("TextButton", {
                    Parent = ColorContainer,
                    BackgroundColor3 = CurrentColor,
                    Position = UDim2.new(1, -42, 0.5, -13),
                    Size = UDim2.new(0, 32, 0, 26),
                    AutoButtonColor = false,
                    Text = ""
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ColorDisplay})
                Utility:Create("UIStroke", {
                    Parent = ColorDisplay,
                    Color = Library.Theme.Stroke,
                    Thickness = 1
                })
                
                -- Color Picker Panel
                local PickerFrame = Utility:Create("Frame", {
                    Parent = ColorContainer,
                    BackgroundColor3 = Library.Theme.Secondary,
                    Position = UDim2.new(0, 8, 0, 44),
                    Size = UDim2.new(1, -16, 0, 0),
                    ClipsDescendants = true
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = PickerFrame})
                
                local Saturation = Utility:Create("ImageButton", {
                    Parent = PickerFrame,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0, 8, 0, 8),
                    Size = UDim2.new(1, -46, 0, 100),
                    AutoButtonColor = false,
                    Image = "rbxassetid://4155801252"
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Saturation})
                
                local Hue = Utility:Create("ImageButton", {
                    Parent = PickerFrame,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(1, -28, 0, 8),
                    Size = UDim2.new(0, 20, 0, 100),
                    AutoButtonColor = false,
                    Image = "rbxassetid://4155830825"
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Hue})
                
                local h, s, v = CurrentColor:ToHSV()
                
                local function UpdateColor()
                    local color = Color3.fromHSV(h, s, v)
                    CurrentColor = color
                    ColorDisplay.BackgroundColor3 = color
                    Saturation.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    Library.Flags[Flag] = color
                    Callback(color)
                end
                
                local draggingSat = false
                local draggingHue = false
                
                Saturation.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSat = true
                    end
                end)
                
                Hue.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSat = false
                        draggingHue = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingSat then
                            local sizeX = math.clamp((input.Position.X - Saturation.AbsolutePosition.X) / Saturation.AbsoluteSize.X, 0, 1)
                            local sizeY = math.clamp((input.Position.Y - Saturation.AbsolutePosition.Y) / Saturation.AbsoluteSize.Y, 0, 1)
                            s = sizeX
                            v = 1 - sizeY
                            UpdateColor()
                        elseif draggingHue then
                            local sizeY = math.clamp((input.Position.Y - Hue.AbsolutePosition.Y) / Hue.AbsoluteSize.Y, 0, 1)
                            h = sizeY
                            UpdateColor()
                        end
                    end
                end)
                
                ColorDisplay.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    if Expanded then
                        Utility:Tween(ColorContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 160)})
                        Utility:Tween(PickerFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -16, 0, 116)})
                    else
                        Utility:Tween(ColorContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 36)})
                        Utility:Tween(PickerFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -16, 0, 0)})
                    end
                end)
                
                return {
                    Set = function(self, color)
                        CurrentColor = color
                        h, s, v = color:ToHSV()
                        UpdateColor()
                    end
                }
            end
            
            --// COMPONENT: LABEL
            function Section:CreateLabel(text)
                local Label = Utility:Create("TextLabel", {
                    Name = "Label",
                    Parent = ContentContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text or "Label",
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                return {
                    Set = function(self, newText)
                        Label.Text = newText
                    end
                }
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        return Tab
    end
    
    -- UI Toggle Keybind Listener
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Library.UIToggleKey then
            Library.IsMinimized = not Library.IsMinimized
            if Library.IsMinimized then
                Utility:Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                })
            else
                Utility:Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                    Size = UDim2.new(0, 800, 0, 550),
                    Position = UDim2.new(0.5, -400, 0.5, -275)
                })
            end
        end
    end)
    
    return Window
end

--// UNLOAD FUNCTION
function Library:Unload()
    if Library.Unloaded then return end
    Library.Unloaded = true
    
    for _, connection in pairs(Library.Connections) do
        connection:Disconnect()
    end
    
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end
    
    Library:Notify({
        Title = "Unloaded",
        Content = "UI Library has been unloaded",
        Duration = 2
    })
end

--// CONFIG SYSTEM
function Library:SaveConfig(name)
    name = name or "default"
    local config = {}
    for flag, value in pairs(Library.Flags) do
        if typeof(value) == "Color3" then
            config[flag] = {value.R, value.G, value.B}
        elseif typeof(value) == "EnumItem" then
            config[flag] = tostring(value)
        else
            config[flag] = value
        end
    end
    Utility:WriteFile(name .. ".json", HttpService:JSONEncode(config))
    Library:Notify({
        Title = "Config Saved",
        Content = "Configuration: " .. name,
        Duration = 2
    })
end

function Library:LoadConfig(name)
    name = name or "default"
    local data = Utility:ReadFile(name .. ".json")
    if data then
        local success, config = pcall(function() return HttpService:JSONDecode(data) end)
        if success then
            for flag, value in pairs(config) do
                if type(value) == "table" and #value == 3 then
                    Library.Flags[flag] = Color3.new(value[1], value[2], value[3])
                else
                    Library.Flags[flag] = value
                end
            end
            Library:Notify({
                Title = "Config Loaded",
                Content = "Configuration: " .. name,
                Duration = 2
            })
        end
    end
end

return Library
