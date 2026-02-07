-- Domination UI Library (RenLib) - MOBILE + PC VERSION
-- Works on both Desktop and Mobile devices

--// SERVICES //--
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

--// LOCAL SHORTCUTS //--
local Plr = Players.LocalPlayer
local Mouse = Plr:GetMouse()
local Camera = workspace.CurrentCamera

--// DEVICE DETECTION //--
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ScreenSize = Camera.ViewportSize

--// CONSTANTS //--
local CONFIG_FOLDER = "RenHubConfig"

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

--// ROOT LIBRARY //--
local Library = {}
Library.Version = "4.1.0-mobile"
Library.Title = "RenLib"
Library.Connections = {}
Library.Flags = {}
Library.Unloaded = false
Library.Keybinds = {}
Library.ToggleKey = Enum.KeyCode.K
Library.IsMinimized = false
Library.IsMobile = IsMobile

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

function Utility:MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
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

            Utility:Tween(object, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {Position = newPos})
        end
    end)
end

--------------------------------------------------------------------------------
--// CORE UI: WINDOW
--------------------------------------------------------------------------------
function Library:CreateWindow(options)
    options = options or {}
    local WindowTitle = options.Name or "RenHub"

    -- Calculate sizes based on device
    local WinWidth, WinHeight, SidebarWidth, FontScale
    if IsMobile then
        local vpX = Camera.ViewportSize.X
        local vpY = Camera.ViewportSize.Y
        WinWidth = math.clamp(vpX - 40, 300, 600)
        WinHeight = math.clamp(vpY - 80, 280, 450)
        SidebarWidth = 55
        FontScale = 0.9
    else
        WinWidth = 800
        WinHeight = 550
        SidebarWidth = 70
        FontScale = 1
    end

    -- Main ScreenGui
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = Utility:RandomString(10),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })

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

    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
    Utility:Create("UIStroke", {
        Parent = MainFrame,
        Color = Library.Theme.Stroke,
        Thickness = 1
    })

    -- Shadow
    local Shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -25, 0, -25),
        Size = UDim2.new(1, 50, 1, 50),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
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
        Size = UDim2.new(0, SidebarWidth, 1, 0),
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

    Utility:Create("Frame", {
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
        Position = UDim2.new(0, 0, 0, IsMobile and 65 or 80),
        Size = UDim2.new(1, 0, 1, IsMobile and -110 or -140),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 4,
        BorderSizePixel = 0
    })

    local TabLayout = Utility:Create("UIListLayout", {
        Parent = TabContainer,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, IsMobile and 8 or 12)
    })

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
    end)

    -- LOGO
    local logoSize = IsMobile and 32 or 40
    local LogoContainer = Utility:Create("Frame", {
        Name = "LogoContainer",
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Main,
        Position = UDim2.new(0.5, -logoSize / 2, 0, IsMobile and 10 or 15),
        Size = UDim2.new(0, logoSize, 0, logoSize),
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
        Text = EMOJIS.Code,
        TextColor3 = Library.Theme.Accent,
        TextSize = IsMobile and 14 or 18,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 101
    })

    -- SETTINGS BUTTON
    local settingsBtnSize = IsMobile and 36 or 44
    local SettingsBtn = Utility:Create("TextButton", {
        Name = "SettingsBtn",
        Parent = Sidebar,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -settingsBtnSize / 2, 1, -(settingsBtnSize + 10)),
        Size = UDim2.new(0, settingsBtnSize, 0, settingsBtnSize),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 100,
        BorderSizePixel = 0
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = SettingsBtn})

    local SettingsEmoji = Utility:Create("TextLabel", {
        Parent = SettingsBtn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = EMOJIS.Settings,
        TextColor3 = Library.Theme.SubText,
        TextSize = IsMobile and 16 or 20,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 101
    })

    local SettingsIndicator = Utility:Create("Frame", {
        Parent = SettingsBtn,
        BackgroundColor3 = Library.Theme.Accent,
        Position = UDim2.new(0, 0, 0.5, -10),
        Size = UDim2.new(0, 4, 0, 20),
        Transparency = 1,
        ZIndex = 102,
        BorderSizePixel = 0
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = SettingsIndicator})

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
        Size = UDim2.new(1, 0, 0, IsMobile and 48 or 60),
        ZIndex = 100,
        BorderSizePixel = 0
    })

    Utility:MakeDraggable(TopBar, MainFrame)

    local TitleLabel = Utility:Create("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, SidebarWidth + 16, 0, IsMobile and 14 or 20),
        Size = UDim2.new(0, 200, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = WindowTitle,
        TextColor3 = Library.Theme.Text,
        TextSize = IsMobile and 18 or 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101
    })

    -- MINIMIZE BUTTON
    local MinimizeBtn = Utility:Create("TextButton", {
        Name = "MinimizeBtn",
        Parent = TopBar,
        BackgroundColor3 = Library.Theme.Warn,
        Position = UDim2.new(1, -80, 0, IsMobile and 10 or 15),
        Size = UDim2.new(0, IsMobile and 26 or 30, 0, IsMobile and 26 or 30),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 101,
        BorderSizePixel = 0
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = MinimizeBtn})

    Utility:Create("TextLabel", {
        Parent = MinimizeBtn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = EMOJIS.Minimize,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = IsMobile and 12 or 16,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 102
    })

    -- CLOSE BUTTON
    local CloseBtn = Utility:Create("TextButton", {
        Name = "CloseBtn",
        Parent = TopBar,
        BackgroundColor3 = Library.Theme.Error,
        Position = UDim2.new(1, -40, 0, IsMobile and 10 or 15),
        Size = UDim2.new(0, IsMobile and 26 or 30, 0, IsMobile and 26 or 30),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 101,
        BorderSizePixel = 0
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = CloseBtn})

    Utility:Create("TextLabel", {
        Parent = CloseBtn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = EMOJIS.Close,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = IsMobile and 12 or 16,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 102
    })

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

    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MinimizedIcon})
    Utility:Create("UIStroke", {
        Parent = MinimizedIcon,
        Color = Library.Theme.Accent,
        Thickness = 2
    })

    local MinimizedLogo = Utility:Create("TextLabel", {
        Parent = MinimizedIcon,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = EMOJIS.Code,
        TextColor3 = Library.Theme.Accent,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 301
    })

    local MinIconBtn = Utility:Create("TextButton", {
        Parent = MinimizedIcon,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 302
    })

    -- Mobile Toggle Button (floating button for mobile users)
    local MobileToggleBtn
    if IsMobile then
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

        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = MobileToggleBtn})
        Utility:Create("UIStroke", {
            Parent = MobileToggleBtn,
            Color = Library.Theme.Accent,
            Thickness = 2
        })

        local MobileToggleLogo = Utility:Create("TextLabel", {
            Parent = MobileToggleBtn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = EMOJIS.Code,
            TextColor3 = Library.Theme.Accent,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 401
        })

        local MobileToggleTapBtn = Utility:Create("TextButton", {
            Parent = MobileToggleBtn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 402
        })

        -- Make mobile toggle draggable so user can reposition it
        Utility:MakeDraggable(MobileToggleTapBtn, MobileToggleBtn)

        MobileToggleTapBtn.MouseButton1Click:Connect(function()
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

    -- Window Object
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Gui = ScreenGui,
        Main = MainFrame,
        SettingsTab = nil
    }

    -- MINIMIZE/RESTORE/CLOSE
    function Window:Minimize()
        Library.IsMinimized = true
        MainFrame.Visible = false
        if IsMobile then
            if MobileToggleBtn then
                MobileToggleBtn.Visible = true
            end
        else
            MinimizedIcon.Visible = true
        end
    end

    function Window:Restore()
        Library.IsMinimized = false
        MinimizedIcon.Visible = false
        MainFrame.Visible = true
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

    MinimizeBtn.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)

    MinIconBtn.MouseButton1Click:Connect(function()
        Window:Restore()
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Window:Close()
    end)

    -- NOTIFICATION SYSTEM
    function Library:Notify(notifyOpts)
        notifyOpts = notifyOpts or {}
        local Title = notifyOpts.Title or "Notification"
        local Content = notifyOpts.Content or ""
        local Duration = notifyOpts.Duration or 3
        local Emoji = notifyOpts.Emoji or EMOJIS.Info

        local notifHeight = IsMobile and 50 or 60

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
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = NotifyFrame})
        Utility:Create("UIStroke", {
            Parent = NotifyFrame,
            Color = Library.Theme.Stroke,
            Thickness = 1
        })

        Utility:Create("TextLabel", {
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
            Size = UDim2.new(1, IsMobile and -52 or -68, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = Title,
            TextColor3 = Library.Theme.Text,
            TextSize = IsMobile and 12 or 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 202
        })

        Utility:Create("TextLabel", {
            Parent = NotifyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, IsMobile and 44 or 58, 0, IsMobile and 24 or 30),
            Size = UDim2.new(1, IsMobile and -52 or -68, 0, 20),
            Font = Enum.Font.Gotham,
            Text = Content,
            TextColor3 = Library.Theme.SubText,
            TextSize = IsMobile and 11 or 13,
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

    --// CREATE TAB FUNCTION
    function Window:CreateTab(options)
        options = options or {}
        local Name = options.Name or "Tab"
        local Emoji = options.Emoji or EMOJIS.Home
        local IsSettings = options.IsSettings or false

        local Tab = {
            Name = Name,
            Active = false,
            Sections = {},
            IsSettings = IsSettings
        }

        local TabBtn, TabEmoji, Indicator

        local tabBtnSize = IsMobile and 36 or 44

        if not IsSettings then
            TabBtn = Utility:Create("TextButton", {
                Name = Name,
                Parent = TabContainer,
                BackgroundColor3 = Color3.new(0, 0, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, tabBtnSize, 0, tabBtnSize),
                AutoButtonColor = false,
                Text = "",
                ZIndex = 5,
                BorderSizePixel = 0
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TabBtn})

            TabEmoji = Utility:Create("TextLabel", {
                Parent = TabBtn,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = Emoji,
                TextColor3 = Library.Theme.SubText,
                TextSize = IsMobile and 16 or 20,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 6
            })

            Indicator = Utility:Create("Frame", {
                Parent = TabBtn,
                BackgroundColor3 = Library.Theme.Accent,
                Position = UDim2.new(0, 0, 0.5, -10),
                Size = UDim2.new(0, 4, 0, 20),
                Transparency = 1,
                ZIndex = 7,
                BorderSizePixel = 0
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Indicator})
        else
            TabEmoji = SettingsEmoji
            Indicator = SettingsIndicator
        end

        -- Determine if single column mode (mobile)
        local useSingleColumn = IsMobile

        local Page = Utility:Create("ScrollingFrame", {
            Name = Name,
            Parent = Pages,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, IsMobile and 10 or 20, 0, IsMobile and 52 or 70),
            Size = UDim2.new(1, IsMobile and -20 or -40, 1, IsMobile and -62 or -90),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            ZIndex = 2,
            BorderSizePixel = 0
        })

        local LeftColumn, RightColumn, LeftLayout, RightLayout

        if useSingleColumn then
            -- Single column for mobile
            LeftColumn = Utility:Create("Frame", {
                Name = "Left",
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = 2,
                BorderSizePixel = 0
            })
            RightColumn = LeftColumn -- Both point to same column on mobile

            LeftLayout = Utility:Create("UIListLayout", {
                Parent = LeftColumn,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })
            RightLayout = LeftLayout
        else
            -- Two columns for PC
            LeftColumn = Utility:Create("Frame", {
                Name = "Left",
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -6, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = 2,
                BorderSizePixel = 0
            })
            RightColumn = Utility:Create("Frame", {
                Name = "Right",
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -6, 1, 0),
                Position = UDim2.new(0.5, 6, 0, 0),
                ZIndex = 2,
                BorderSizePixel = 0
            })

            LeftLayout = Utility:Create("UIListLayout", {
                Parent = LeftColumn,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12)
            })
            RightLayout = Utility:Create("UIListLayout", {
                Parent = RightColumn,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12)
            })
        end

        local function UpdateCanvas()
            local LeftH = LeftLayout.AbsoluteContentSize.Y
            local RightH = useSingleColumn and 0 or RightLayout.AbsoluteContentSize.Y
            Page.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftH, RightH) + 20)
        end
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        if not useSingleColumn then
            RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        end

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
            Page.CanvasPosition = Vector2.new(0, 0)
        end

        function Tab:Deactivate()
            Tab.Active = false
            Utility:Tween(TabEmoji, TweenInfo.new(0.3), {TextColor3 = Library.Theme.SubText})
            Utility:Tween(Indicator, TweenInfo.new(0.3), {Transparency = 1, Position = UDim2.new(0, 0, 0.5, -10)})
            Page.Visible = false
        end

        if TabBtn then
            TabBtn.MouseButton1Click:Connect(function() Tab:Activate() end)
        end

        table.insert(Window.Tabs, Tab)

        if not IsSettings and #Window.Tabs == 1 then
            Tab:Activate()
        end

        --// CREATE SECTION
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
                Position = UDim2.new(0, 12, 0, IsMobile and 8 or 10),
                Size = UDim2.new(1, -24, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = SectionName,
                TextColor3 = Library.Theme.Text,
                TextSize = IsMobile and 12 or 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 4
            })

            local ContentContainer = Utility:Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, IsMobile and 30 or 35),
                Size = UDim2.new(1, -20, 0, 0),
                ZIndex = 4,
                BorderSizePixel = 0
            })

            local ContentLayout = Utility:Create("UIListLayout", {
                Parent = ContentContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, IsMobile and 6 or 8)
            })

            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ContentContainer.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y)
                Utility:Tween(SectionFrame, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + (IsMobile and 38 or 45))
                })
            end)

            --// BUTTON
            function Section:CreateButton(options)
                options = options or {}
                local Name = options.Name or "Button"
                local Callback = options.Callback or function() end

                local btnHeight = IsMobile and 32 or 36

                local ButtonContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, btnHeight),
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
                    TextSize = IsMobile and 12 or 13,
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
                    -- Brief tap feedback for mobile
                    if IsMobile then
                        Utility:Tween(Stroke, TweenInfo.new(0.1), {Color = Library.Theme.Accent})
                        Utility:Tween(ButtonContainer, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Hover})
                        task.delay(0.15, function()
                            Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Stroke})
                            Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Main})
                        end)
                    end
                    Callback()
                end)

                return {
                    SetText = function(self, text)
                        Btn.Text = text
                    end
                }
            end

            --// TOGGLE
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

                local toggleHeight = IsMobile and 32 or 36

                local ToggleContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, toggleHeight),
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })

                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ToggleContainer})
                Utility:Create("UIStroke", {
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
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 6,
                    BorderSizePixel = 0
                })
                Utility:Create("UIPadding", {Parent = ToggleBtn, PaddingLeft = UDim.new(0, 12)})

                local switchWidth = IsMobile and 30 or 35
                local switchHeight = IsMobile and 17 or 20
                local dotSize = IsMobile and 13 or 16

                local SwitchBg = Utility:Create("Frame", {
                    Parent = ToggleBtn,
                    BackgroundColor3 = CurrentValue and Library.Theme.Accent or Color3.fromRGB(50, 50, 55),
                    Position = UDim2.new(1, -(switchWidth + 10), 0.5, -math.floor(switchHeight / 2)),
                    Size = UDim2.new(0, switchWidth, 0, switchHeight),
                    BorderSizePixel = 0,
                    ZIndex = 6
                })
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

                local function Update()
                    Library.Flags[Flag] = CurrentValue
                    Callback(CurrentValue)

                    if CurrentValue then
                        Utility:Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Accent})
                        Utility:Tween(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -(dotSize + 2), 0.5, -math.floor(dotSize / 2))})
                    else
                        Utility:Tween(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)})
                        Utility:Tween(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -math.floor(dotSize / 2))})
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

            --// SLIDER
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

                local sliderHeight = IsMobile and 44 or 50

                local SliderContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, sliderHeight),
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
                    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                    Position = UDim2.new(0, 12, 0, IsMobile and 28 or 34),
                    Size = UDim2.new(1, -24, 0, trackHeight),
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

                local function UpdateSlider(input)
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
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

            --// DROPDOWN
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

                local headerHeight = IsMobile and 38 or 44

                local Expanded = false
                local DropdownContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, headerHeight),
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
                    Position = UDim2.new(0, 0, 0, headerHeight),
                    Size = UDim2.new(1, 0, 1, -headerHeight),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Library.Theme.Accent,
                    ZIndex = 6,
                    BorderSizePixel = 0
                })

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

                local itemHeight = IsMobile and 30 or 26

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
                            Size = UDim2.new(1, 0, 0, itemHeight),
                            AutoButtonColor = false,
                            Font = Enum.Font.Gotham,
                            Text = tostring(val),
                            TextColor3 = Library.Theme.SubText,
                            TextSize = IsMobile and 12 or 13,
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
                                Utility:Tween(DropdownContainer, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, headerHeight)})
                                Utility:Tween(Arrow, TweenInfo.new(0.2), {Rotation = 0})
                                BuildList()
                            end
                            Refresh()
                        end)
                    end

                    ListFrame.CanvasSize = UDim2.new(0, 0, 0, #Values * (itemHeight + 4) + 10)
                end

                Header.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    Utility:Tween(Arrow, TweenInfo.new(0.2), {Rotation = Expanded and 180 or 0})

                    local ListHeight = math.min(#Values * (itemHeight + 4) + 10, IsMobile and 120 or 150)
                    Utility:Tween(DropdownContainer, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, Expanded and (headerHeight + ListHeight) or headerHeight)
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

            --// LABEL
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

    -- NOW CREATE SETTINGS TAB AFTER CreateTab FUNCTION IS DEFINED
    local SettingsTab = Window:CreateTab({
        Name = "UI Settings",
        Emoji = EMOJIS.Settings,
        IsSettings = true
    })

    Window.SettingsTab = SettingsTab

    local UISection = SettingsTab:CreateSection({
        Name = "UI Controls",
        Side = "Left"
    })

    if not IsMobile then
        UISection:CreateLabel("Toggle UI Key: " .. Library.ToggleKey.Name)

        UISection:CreateButton({
            Name = "Change Toggle Key",
            Callback = function()
                Library:Notify({
                    Title = "Press Any Key",
                    Content = "Press a key to set as toggle...",
                    Emoji = "⌨️",
                    Duration = 5
                })

                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Library.ToggleKey = input.KeyCode
                        Library:Notify({
                            Title = "Success",
                            Content = "Toggle key set to: " .. input.KeyCode.Name,
                            Emoji = EMOJIS.Success
                        })
                        conn:Disconnect()
                    end
                end)
            end
        })
    else
        UISection:CreateLabel("Tap the floating </> button to toggle UI")
    end

    UISection:CreateButton({
        Name = "Minimize UI",
        Callback = function()
            Window:Minimize()
        end
    })

    UISection:CreateButton({
        Name = "Close UI",
        Callback = function()
            Window:Close()
        end
    })

    local UtilitySection = SettingsTab:CreateSection({
        Name = "Utilities",
        Side = "Right"
    })

    UtilitySection:CreateButton({
        Name = "💻 Execute Infinity Yield",
        Callback = function()
            Library:Notify({
                Title = "Loading",
                Content = "Executing Infinity Yield...",
                Emoji = "⚡"
            })
            task.spawn(function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/xsakyx/InfiniteYield-MyOwneUpload/refs/heads/main/infiniteyield.lua"))()
                end)
                if success then
                    Library:Notify({
                        Title = "Success",
                        Content = "Infinity Yield loaded!",
                        Emoji = EMOJIS.Success
                    })
                else
                    Library:Notify({
                        Title = "Error",
                        Content = "Failed to load Infinity Yield",
                        Emoji = EMOJIS.Error
                    })
                end
            end)
        end
    })

    UtilitySection:CreateButton({
        Name = "🔓 Execute Dark Dex",
        Callback = function()
            Library:Notify({
                Title = "Loading",
                Content = "Executing Dark Dex...",
                Emoji = "⚡"
            })
            task.spawn(function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/xsakyx/DarkDex-MyOwnUpload/refs/heads/main/Dex.lua"))()
                end)
                if success then
                    Library:Notify({
                        Title = "Success",
                        Content = "Dark Dex loaded!",
                        Emoji = EMOJIS.Success
                    })
                else
                    Library:Notify({
                        Title = "Error",
                        Content = "Failed to load Dark Dex",
                        Emoji = EMOJIS.Error
                    })
                end
            end)
        end
    })

    -- Settings button click
    SettingsBtn.MouseButton1Click:Connect(function()
        if SettingsTab then
            SettingsTab:Activate()
        end
    end)

    return Window
end

--// UNLOAD
function Library:Unload()
    for _, conn in pairs(Library.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end
    Library.Unloaded = true
    print("[RenLib] Unloaded successfully")
end

--// TOGGLE KEY (PC only)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Library.ToggleKey then
        if Library.ScreenGui and Library.ScreenGui.Parent then
            for _, obj in pairs(Library.ScreenGui:GetChildren()) do
                if obj:IsA("Frame") and obj.Name == "Main" then
                    if obj.Visible or Library.IsMinimized then
                        if Library.IsMinimized then
                            for _, minimized in pairs(Library.ScreenGui:GetChildren()) do
                                if minimized.Name == "MinimizedIcon" and minimized.Visible then
                                    minimized.Visible = false
                                    obj.Visible = true
                                    Library.IsMinimized = false
                                    break
                                end
                            end
                            -- Also hide mobile toggle if visible
                            for _, child in pairs(Library.ScreenGui:GetChildren()) do
                                if child.Name == "MobileToggle" then
                                    child.Visible = false
                                    break
                                end
                            end
                        else
                            obj.Visible = false
                            if Library.IsMobile then
                                for _, child in pairs(Library.ScreenGui:GetChildren()) do
                                    if child.Name == "MobileToggle" then
                                        child.Visible = true
                                        Library.IsMinimized = true
                                        break
                                    end
                                end
                            else
                                for _, minimized in pairs(Library.ScreenGui:GetChildren()) do
                                    if minimized.Name == "MinimizedIcon" then
                                        minimized.Visible = true
                                        Library.IsMinimized = true
                                        break
                                    end
                                end
                            end
                        end
                    else
                        obj.Visible = true
                    end
                    break
                end
            end
        end
    end
end)

if not isfolder("RenLib") then makefolder("RenLib") end
if not isfolder("RenLib/Configs") then makefolder("RenLib/Configs") end

print("[RenLib] Loaded - Version " .. Library.Version .. (IsMobile and " (Mobile)" or " (PC)"))

return Library
