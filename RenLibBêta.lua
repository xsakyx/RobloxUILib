-- Domination UI Library (Titan Build) - EMOJI EDITION
-- NO ASSET IDs NEEDED - EMOJIS ONLY!

--// SERVICES //--
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

--// LOCAL SHORTCUTS //--
local Plr = Players.LocalPlayer
local Mouse = Plr:GetMouse()
local Camera = workspace.CurrentCamera

--// CONSTANTS //--
local HUD_NAME = "RenLib"
local CONFIG_FOLDER = "RenHubConfig"

--// EMOJI ICONS - CHANGE THESE TO WHATEVER YOU WANT
local EMOJIS = {
    Logo = "⚡", -- MAIN LOGO
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
    Code = "</>", -- CODING LOGO
    Terminal = "💻",
    User = "👤",
    Lock = "🔒",
    Unlock = "🔓"
}

--// ROOT LIBRARY //--
local Library = {}
Library.Version = "3.3.0"
Library.Title = "RenLib"
Library.Process = {}
Library.Connections = {}
Library.Flags = {}
Library.Unloaded = false
Library.Keybinds = {}

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
        ClipsDescendants = false,
        ZIndex = 1,
        BorderSizePixel = 0
    })
    
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
    Utility:Create("UIStroke", {
        Parent = MainFrame,
        Color = Library.Theme.Stroke,
        Thickness = 1,
        Transparency = 0
    })

    -- Shadow Effect
    local Shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -25, 0, -25),
        Size = UDim2.new(1, 50, 1, 50),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0
    })

    -- Sidebar
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Secondary,
        Size = UDim2.new(0, 70, 1, 0),
        ZIndex = 2,
        BorderSizePixel = 0
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
        ZIndex = 4,
        BorderSizePixel = 0
    })
    
    local TabLayout = Utility:Create("UIListLayout", {
        Parent = TabContainer,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12)
    })
    
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
    end)

    -- EMOJI LOGO - WORKS 100%
    local LogoContainer = Utility:Create("Frame", {
        Name = "LogoContainer",
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Main,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(0, 40, 0, 40),
        ZIndex = 100,
        BorderSizePixel = 0
    })
    
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = LogoContainer})
    Utility:Create("UIStroke", {
        Parent = LogoContainer,
        Color = Library.Theme.Accent,
        Thickness = 2
    })
    
    local Logo = Utility:Create("TextLabel", {
        Name = "Logo",
        Parent = LogoContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = EMOJIS.Logo, -- EMOJI LOGO HERE
        TextColor3 = Library.Theme.Accent,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 101
    })
    
    print("[RenLib] Emoji Logo Created: " .. EMOJIS.Logo)
    
    -- Content Area
    local Pages = Utility:Create("Frame", {
        Name = "Pages",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        ClipsDescendants = true,
        ZIndex = 1,
        BorderSizePixel = 0
    })

    -- Draggable Topbar
    local DragFrame = Utility:Create("Frame", {
        Name = "DragFrame",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 100,
        BorderSizePixel = 0
    })
    Utility:MakeDraggable(DragFrame, MainFrame)
    
    local TitleLabel = Utility:Create("TextLabel", {
        Parent = Pages,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 20),
        Size = UDim2.new(1, -48, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = WindowTitle,
        TextColor3 = Library.Theme.Text,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })
    
    -- Notification Container
    local NotifyArea = Utility:Create("Frame", {
        Name = "Notifications",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 300, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        ZIndex = 200
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
        Main = MainFrame
    }
    
    --// NOTIFICATION SYSTEM (WITH EMOJIS)
    function Library:Notify(notifyOpts)
        notifyOpts = notifyOpts or {}
        local Title = notifyOpts.Title or "Notification"
        local Content = notifyOpts.Content or ""
        local Duration = notifyOpts.Duration or 3
        local Emoji = notifyOpts.Emoji or EMOJIS.Info
        
        local NotifyFrame = Utility:Create("Frame", {
            Name = "Notify",
            Parent = NotifyArea,
            BackgroundColor3 = Library.Theme.Main,
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(2, 0, 0, 0),
            ClipsDescendants = true,
            ZIndex = 201,
            BorderSizePixel = 0
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = NotifyFrame})
        Utility:Create("UIStroke", {
            Parent = NotifyFrame,
            Color = Library.Theme.Stroke,
            Thickness = 1
        })
        
        -- EMOJI ICON
        Utility:Create("TextLabel", {
            Parent = NotifyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 12),
            Size = UDim2.new(0, 36, 0, 36),
            Font = Enum.Font.GothamBold,
            Text = Emoji,
            TextColor3 = Library.Theme.Accent,
            TextSize = 24,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 202
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
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 202
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
            TextWrapped = true,
            ZIndex = 202
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
    
    --// COMPONENT: TAB (WITH EMOJI SUPPORT)
    function Window:CreateTab(options)
        options = options or {}
        local Name = options.Name or "Tab"
        local Emoji = options.Emoji or EMOJIS.Home -- EMOJI INSTEAD OF ICON
        
        local Tab = {
            Name = Name,
            Active = false,
            Sections = {}
        }
        
        -- Tab Button with EMOJI
        local TabBtn = Utility:Create("TextButton", {
            Name = Name,
            Parent = TabContainer,
            BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 44, 0, 44),
            AutoButtonColor = false,
            Text = "",
            ZIndex = 5,
            BorderSizePixel = 0
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TabBtn})
        
        local TabEmoji = Utility:Create("TextLabel", {
            Parent = TabBtn,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = Emoji,
            TextColor3 = Library.Theme.SubText,
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 6
        })
        
        local Indicator = Utility:Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Library.Theme.Accent,
            Position = UDim2.new(0, 0, 0.5, -10),
            Size = UDim2.new(0, 4, 0, 20),
            Transparency = 1,
            ZIndex = 7,
            BorderSizePixel = 0
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
            Visible = false,
            ZIndex = 2,
            BorderSizePixel = 0
        })
        
        local LeftColumn = Utility:Create("Frame", {
            Name = "Left",
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 1, 0),
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
            ZIndex = 2,
            BorderSizePixel = 0
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
            
            Utility:Tween(TabEmoji, TweenInfo.new(0.3), {TextColor3 = Library.Theme.Accent})
            Utility:Tween(Indicator, TweenInfo.new(0.3), {Transparency = 0, Position = UDim2.new(0, -12, 0.5, -10)})
            Page.Visible = true
            Page.CanvasPosition = Vector2.new(0,0)
        end
        
        function Tab:Deactivate()
            Tab.Active = false
            Utility:Tween(TabEmoji, TweenInfo.new(0.3), {TextColor3 = Library.Theme.SubText})
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
                ClipsDescendants = true,
                ZIndex = 3,
                BorderSizePixel = 0
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
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 4
            })
            
            local ContentContainer = Utility:Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 0, 0),
                ZIndex = 4,
                BorderSizePixel = 0
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
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
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
                    AutoButtonColor = false,
                    ZIndex = 6,
                    BorderSizePixel = 0
                })
                
                Btn.MouseEnter:Connect(function()
                    Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Accent})
                    Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover})
                end)
                
                Btn.MouseLeave:Connect(function()
                    Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Stroke})
                    Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Main})
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Callback()
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
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
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
                    AutoButtonColor = false,
                    ZIndex = 6,
                    BorderSizePixel = 0
                })
                Utility:Create("UIPadding", {Parent = ToggleBtn, PaddingLeft = UDim.new(0, 12)})
                
                local SwitchBg = Utility:Create("Frame", {
                    Parent = ToggleBtn,
                    BackgroundColor3 = CurrentValue and Library.Theme.Accent or Color3.fromRGB(50, 50, 55),
                    Position = UDim2.new(1, -45, 0.5, -10),
                    Size = UDim2.new(0, 35, 0, 20),
                    BorderSizePixel = 0,
                    ZIndex = 6
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwitchBg})
                
                local SwitchDot = Utility:Create("Frame", {
                    Parent = SwitchBg,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 7,
                    BorderSizePixel = 0
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
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
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
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6
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
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 6
                })
                
                local Track = Utility:Create("TextButton", {
                    Parent = SliderContainer,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                    Position = UDim2.new(0, 12, 0, 34),
                    Size = UDim2.new(1, -24, 0, 6),
                    AutoButtonColor = false,
                    Text = "",
                    ZIndex = 6,
                    BorderSizePixel = 0
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})
                
                local Fill = Utility:Create("Frame", {
                    Parent = Track,
                    BackgroundColor3 = Library.Theme.Accent,
                    Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
                    BorderSizePixel = 0,
                    ZIndex = 7
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
                    ZIndex = 5,
                    BorderSizePixel = 0
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
                    Text = "",
                    ZIndex = 6,
                    BorderSizePixel = 0
                })
                
                local Title = Utility:Create("TextLabel", {
                    Parent = Header,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 12),
                    Size = UDim2.new(0.5, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7
                })
                
                local Status = Utility:Create("TextLabel", {
                    Parent = Header,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, 12),
                    Size = UDim2.new(0.5, -30, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = (Multi and "..." or tostring(CurrentValue)),
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 7
                })
                
                -- EMOJI ARROW
                local Arrow = Utility:Create("TextLabel", {
                    Parent = Header,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -28, 0.5, -10),
                    Size = UDim2.new(0, 16, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = EMOJIS.Arrow,
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 7
                })
                
                local ListFrame = Utility:Create("ScrollingFrame", {
                    Parent = DropdownContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 44),
                    Size = UDim2.new(1, 0, 1, -44),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Library.Theme.Accent,
                    ZIndex = 6,
                    BorderSizePixel = 0
                })
                Utility:Create("UIListLayout", {
                    Parent = ListFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                })
                Utility:Create("UIPadding", {Parent = ListFrame, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4)})

                local function Refresh()
                    if Multi then
                        local Count = 0
                        for k, v in pairs(CurrentValue) do if v then Count = Count + 1 end end
                        Status.Text = Count .. " Selected"
                    else
                        Status.Text = tostring(CurrentValue)
                    end
                    
                    Library.Flags[Flag] = CurrentValue
                    Callback(CurrentValue)
                end

                local function BuildList()
                    ListFrame:ClearAllChildren()
                    Utility:Create("UIListLayout", {
                        Parent = ListFrame,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 4)
                    })
                    Utility:Create("UIPadding", {Parent = ListFrame, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4)})
                    
                    for _, val in pairs(Values) do
                        local Item = Utility:Create("TextButton", {
                            Parent = ListFrame,
                            BackgroundColor3 = Library.Theme.Secondary,
                            Size = UDim2.new(1, 0, 0, 26),
                            AutoButtonColor = false,
                            Font = Enum.Font.Gotham,
                            Text = tostring(val),
                            TextColor3 = Library.Theme.SubText,
                            TextSize = 13,
                            ZIndex = 7,
                            BorderSizePixel = 0
                        })
                        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Item})
                        
                        local IsSelected = Multi and CurrentValue[val] or (not Multi and CurrentValue == val)
                        if IsSelected then
                            Item.TextColor3 = Library.Theme.Accent
                            Item.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                        end
                        
                        Item.MouseButton1Click:Connect(function()
                            if Multi then
                                CurrentValue[val] = not CurrentValue[val]
                                BuildList()
                            else
                                CurrentValue = val
                                Expanded = false
                                Utility:Tween(DropdownContainer, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 44)})
                                Utility:Tween(Arrow, TweenInfo.new(0.2), {Rotation = 0})
                                BuildList()
                            end
                            Refresh()
                        end)
                    end
                    
                    ListFrame.CanvasSize = UDim2.new(0, 0, 0, #Values * 30 + 10)
                end
                
                Header.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    Utility:Tween(Arrow, TweenInfo.new(0.2), {Rotation = Expanded and 180 or 0})
                    
                    local ListHeight = math.min(#Values * 30 + 10, 150)
                    Utility:Tween(DropdownContainer, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, Expanded and (44 + ListHeight) or 44)
                    })
                end)
                
                BuildList()
                
                return {
                    Set = function(self, val)
                        CurrentValue = val
                        Refresh()
                        BuildList()
                    end,
                    Refresh = function(self, newVals)
                        Values = newVals
                        BuildList()
                    end
                }
            end

            --// COMPONENT: LABEL
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
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    ZIndex = 6
                })
                
                Lab:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    Container.Size = UDim2.new(1, 0, 0, Lab.TextBounds.Y + 4)
                end)
                
                return {
                    SetText = function(self, t)
                        Lab.Text = t
                    end
                }
            end

            return Section
        end
        
        return Tab
    end
    
    return Window
end

--// MANAGERS
function Library:SaveConfig(name)
    local json = HttpService:JSONEncode(Library.Flags)
    writefile("RenLib/Configs/" .. name .. ".json", json)
    Library:Notify({Title = "Config Saved", Content = "Saved config: " .. name, Emoji = EMOJIS.Success})
end

function Library:LoadConfig(name)
    if isfile("RenLib/Configs/" .. name .. ".json") then
        local json = readfile("RenLib/Configs/" .. name .. ".json")
        local data = HttpService:JSONDecode(json)
        for i, v in pairs(data) do
            Library.Flags[i] = v
        end
        Library:Notify({Title = "Config Loaded", Content = "Loaded config: " .. name, Emoji = EMOJIS.Success})
    else
        Library:Notify({Title = "Error", Content = "Config not found: " .. name, Emoji = EMOJIS.Error})
    end
end

function Library:Unload()
    for _, conn in pairs(Library.Connections) do conn:Disconnect() end
    if Library.ScreenGui then Library.ScreenGui:Destroy() end
end

--// GLOBAL INPUT HANDLER
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    for flag, bind in pairs(Library.Keybinds) do
        if bind.Key == input.KeyCode or bind.Key == input.UserInputType then
            if bind.Mode == "Toggle" then
                bind.Active = not bind.Active
                bind.Callback(bind.Active)
            elseif bind.Mode == "Held" then
                bind.Active = true
                bind.Callback(true)
            elseif bind.Mode == "Press" then
                bind.Callback()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    for flag, bind in pairs(Library.Keybinds) do
        if bind.Mode == "Held" and (bind.Key == input.KeyCode or bind.Key == input.UserInputType) then
            bind.Active = false
            bind.Callback(false)
        end
    end
end)

if not isfolder("RenLib") then makefolder("RenLib") end
if not isfolder("RenLib/Configs") then makefolder("RenLib/Configs") end

return Library
