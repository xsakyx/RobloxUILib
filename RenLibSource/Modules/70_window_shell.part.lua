-- Module fragment: window shell, navigation, notifications
-- Generated from the working V7 baseline; edit this feature in isolation.
--// CORE UI: WINDOW
function Library:CreateWindow(options)
    options = options or {}
    local WindowTitle = options.Name or "RenLib"
    local EnableSidebarResize = options.EnableSidebarResize == nil and true or options.EnableSidebarResize
    local EnableGlobalSearch = options.EnableGlobalSearch == nil and true or options.EnableGlobalSearch
    local SidebarCompactMode = options.SidebarCompactMode or false
    local SidebarMode = tostring(options.SidebarMode or (SidebarCompactMode and "Compact" or "Dynamic"))
    if SidebarMode ~= "Dynamic" and SidebarMode ~= "Expanded" and SidebarMode ~= "Compact" then SidebarMode = "Dynamic" end
    local WindowIcon = Utility:NormalizeAssetId(options.Icon or options.Logo)
    local SettingsIcon = Utility:NormalizeAssetId(options.SettingsIcon, ICONS.Settings)
    local ShowUserProfile = options.ShowUserProfile == nil and true or options.ShowUserProfile
    local RequestedMaterialMode = options.MaterialMode or self.MaterialMode or "Solid"

    local brandLoadStarted = false
    local function createWindowMark(parent, textSize, zIndex)
        local mark = Utility:Create("ImageLabel", {
            Parent = parent,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.16, 0.16),
            Size = UDim2.fromScale(0.68, 0.68),
            Image = WindowIcon or Library.BrandIcon,
            ImageColor3 = (WindowIcon or not Library.BrandIconTint) and Color3.new(1, 1, 1) or Library.Theme[Library.BrandIconTint],
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = zIndex
        })
        if not WindowIcon then
            Library.BrandMarks[mark] = true
            if Library.BrandIconTint then Utility:RegisterProperty(mark, "ImageColor3", Library.BrandIconTint) end
            if not brandLoadStarted then
                brandLoadStarted = true
                Utility:LoadBrandIcon()
            end
        end
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
        SidebarWidth = SidebarMode == "Expanded" and 190 or 80
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

    Capabilities:ProtectGui(ScreenGui)
    local guiParent = Capabilities:GetGuiParent()
    assert(guiParent, "[RenLib] No supported UI parent is available")
    ScreenGui.Parent = guiParent
    Library.ScreenGui = ScreenGui

    -- Main Container
    local MainFrame = Utility:Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Library.Theme.Main,
        Position = UDim2.new(0.5, -WinWidth / 2, 0.5, -WinHeight / 2),
        Size = UDim2.new(0, WinWidth, 0, WinHeight),
        ClipsDescendants = true,
        ZIndex = 1,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(MainFrame, "BackgroundColor3", "Main")
    Utility:RegisterMaterial(MainFrame, 0.24, 0)
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = MainFrame})
    local mainGradient = Utility:Create("UIGradient", {Parent = MainFrame, Rotation = 115})
    Utility:RegisterGradient(mainGradient, "Main", "Secondary")
    local glassTint = Utility:Create("ImageLabel", {
        Name = "GlassTint",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://9968344105",
        ImageColor3 = Library.Theme.Accent2,
        ImageTransparency = 0.95,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(128, 128),
        Visible = false,
        ZIndex = 1
    })
    Utility:RegisterProperty(glassTint, "ImageColor3", "Accent2")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = glassTint})
    Library.MaterialDecorations[glassTint] = true
    local glassNoise = Utility:Create("ImageLabel", {
        Name = "GlassNoise",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://9968344227",
        ImageColor3 = Color3.new(1, 1, 1),
        ImageTransparency = 0.93,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(128, 128),
        Visible = false,
        ZIndex = 1
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = glassNoise})
    Library.MaterialDecorations[glassNoise] = true
    local WindowScale = Utility:Create("UIScale", {Parent = MainFrame, Scale = 1})
    local mainStroke = Utility:Create("UIStroke", {Parent = MainFrame, Color = Library.Theme.Stroke, Thickness = 1})
    Utility:RegisterProperty(mainStroke, "Color", "Stroke")
    -- Sidebar
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, SidebarWidth, 1, 0),
        ZIndex = 2,
        BorderSizePixel = 0
    })
    -- The rounded shell and square inner extension are composited once by the
    -- CanvasGroup. Frosted themes therefore keep one uniform tint instead of
    -- revealing a darker double-layer seam behind the sidebar.
    local sidebarSurfaceGroup = Utility:Create("CanvasGroup", {
        Name = "SidebarSurface",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        GroupTransparency = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 1,
        BorderSizePixel = 0
    })
    Utility:RegisterMaterial(sidebarSurfaceGroup, 0.32, 0, "GroupTransparency")
    local sidebarRoundedSurface = Utility:Create("Frame", {
        Name = "RoundedSurface",
        Parent = sidebarSurfaceGroup,
        BackgroundColor3 = Library.Theme.Secondary,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 1,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(sidebarRoundedSurface, "BackgroundColor3", "Secondary")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = sidebarRoundedSurface})
    local sidebarGradient = Utility:Create("UIGradient", {Parent = sidebarRoundedSurface, Rotation = 90})
    Utility:RegisterGradient(sidebarGradient, "Secondary", "Main")
    local sidebarSquareEdge = Utility:Create("Frame", {
        Name = "SidebarSquareInnerEdge",
        Parent = sidebarSurfaceGroup,
        BackgroundColor3 = Library.Theme.Secondary,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -14, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 2
    })
    Utility:RegisterProperty(sidebarSquareEdge, "BackgroundColor3", "Secondary")
    local sidebarSquareGradient = Utility:Create("UIGradient", {Parent = sidebarSquareEdge, Rotation = 90})
    Utility:RegisterGradient(sidebarSquareGradient, "Secondary", "Main")
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

    -- NAVIGATION HEADER
    -- One container owns the logo, wordmark, and sidebar toggle. This avoids
    -- stacked corner treatments and guarantees that compact controls never
    -- occupy the same pixels.
    local NavHeader = Utility:Create("Frame", {
        Name = "NavigationHeader",
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Surface,
        BackgroundTransparency = 0.56,
        Position = UDim2.fromOffset(8, 10),
        Size = UDim2.new(1, -16, 0, 46),
        ClipsDescendants = true,
        ZIndex = 100,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(NavHeader, "BackgroundColor3", "Surface")
    Utility:RegisterMaterial(NavHeader, 0.18, 0.56)
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = NavHeader})
    local navHeaderStroke = Utility:Create("UIStroke", {
        Parent = NavHeader,
        Color = Library.Theme.Stroke,
        Transparency = 0.28,
        Thickness = 1
    })
    Utility:RegisterProperty(navHeaderStroke, "Color", "Stroke")

    -- LOGO
    local logoSize = IsMobile and 28 or (SidebarWidth < 132 and 26 or 36)
    local LogoContainer = Utility:Create("Frame", {
        Name = "LogoContainer",
        Parent = NavHeader,
        BackgroundTransparency = 1,
        Position = IsMobile and UDim2.fromOffset(5, 9)
            or (SidebarWidth < 132 and UDim2.fromOffset(4, 10) or UDim2.fromOffset(7, 5)),
        Size = UDim2.new(0, logoSize, 0, logoSize),
        ZIndex = 100,
        BorderSizePixel = 0
    })
    local Logo = createWindowMark(LogoContainer, IsMobile and 14 or 18, 101)
    Logo.Name = "Logo"

    local BrandLabel = Utility:Create("TextLabel", {
        Parent = NavHeader,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 4),
        Size = UDim2.new(1, -118, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = Library.Title,
        TextColor3 = Library.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Visible = not IsMobile,
        ZIndex = 101
    })
    Utility:RegisterProperty(BrandLabel, "TextColor3", "Text")
    local BrandSubtitle = Utility:Create("TextLabel", {
        Parent = NavHeader,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 24),
        Size = UDim2.new(1, -118, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "Interface Suite",
        TextColor3 = Library.Theme.SubText,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Visible = not IsMobile,
        ZIndex = 101
    })
    Utility:RegisterProperty(BrandSubtitle, "TextColor3", "SubText")

    local SidebarModeButton = Utility:Create("TextButton", {
        Name = "SidebarModeButton",
        Parent = NavHeader,
        BackgroundColor3 = Library.Theme.SurfaceAlt,
        BackgroundTransparency = 0.34,
        Position = SidebarMode == "Expanded" and UDim2.new(1, -62, 0, 9) or UDim2.new(1, -32, 0, 9),
        Size = SidebarMode == "Expanded" and UDim2.fromOffset(58, 28) or UDim2.fromOffset(28, 28),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 104,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(SidebarModeButton, "BackgroundColor3", "SurfaceAlt")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SidebarModeButton})
    local sidebarModeStroke = Utility:Create("UIStroke", {
        Parent = SidebarModeButton,
        Color = Library.Theme.Stroke,
        Transparency = 0.28,
        Thickness = 1
    })
    Utility:RegisterProperty(sidebarModeStroke, "Color", "Stroke")
    local SidebarModeIcon = Utility:Create("ImageLabel", {
        Parent = SidebarModeButton,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(16, 16),
        Image = ICONS.ChevronRight,
        ImageColor3 = Library.Theme.Text,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 105
    })
    Utility:RegisterProperty(SidebarModeIcon, "ImageColor3", "Text")
    local SidebarModeLabel = Utility:Create("TextLabel", {
        Parent = SidebarModeButton,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(27, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = SidebarMode == "Expanded" and "Auto" or "Pin",
        TextColor3 = Library.Theme.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = SidebarMode == "Expanded",
        ZIndex = 105
    })
    Utility:RegisterProperty(SidebarModeLabel, "TextColor3", "Text")

    -- SETTINGS BUTTON
    local settingsBtnSize = IsMobile and 36 or 44
    local SettingsBtn = Utility:Create("TextButton", {
        Name = "SettingsBtn",
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Accent,
        BackgroundTransparency = 0.64,
        Position = IsMobile and UDim2.new(0.5, -settingsBtnSize / 2, 1, -(settingsBtnSize + 12)) or UDim2.new(0, 10, 1, -54),
        Size = IsMobile and UDim2.fromOffset(settingsBtnSize, settingsBtnSize) or UDim2.new(1, -20, 0, 42),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 100,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(SettingsBtn, "BackgroundColor3", "Accent")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SettingsBtn})
    local settingsStroke = Utility:Create("UIStroke", {Parent = SettingsBtn, Color = Library.Theme.Stroke, Thickness = 1})
    Utility:RegisterProperty(settingsStroke, "Color", "Stroke")
    local settingsGradient = Utility:Create("UIGradient", {Parent = SettingsBtn, Rotation = 18})
    Utility:RegisterGradient(settingsGradient, "Accent", "Accent2", "Accent3")

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

    -- NATIVE OVERVIEW BUTTON
    -- Overview is pinned with the profile and settings destinations so user
    -- tabs can scroll independently without hiding the session launcher.
    local OverviewBtn = Utility:Create("TextButton", {
        Name = "OverviewBtn",
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Accent,
        BackgroundTransparency = 0.64,
        Position = IsMobile and UDim2.new(0.5, -settingsBtnSize / 2, 1, -(settingsBtnSize + 62)) or UDim2.new(0, 10, 1, -102),
        Size = IsMobile and UDim2.fromOffset(settingsBtnSize, settingsBtnSize) or UDim2.new(1, -20, 0, 42),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 100,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(OverviewBtn, "BackgroundColor3", "Accent")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = OverviewBtn})
    local overviewStroke = Utility:Create("UIStroke", {Parent = OverviewBtn, Color = Library.Theme.Stroke, Thickness = 1})
    Utility:RegisterProperty(overviewStroke, "Color", "Stroke")
    local overviewGradient = Utility:Create("UIGradient", {Parent = OverviewBtn, Rotation = 18})
    Utility:RegisterGradient(overviewGradient, "Accent", "Accent2", "Accent3")
    local OverviewIcon = Utility:Create("ImageLabel", {
        Parent = OverviewBtn,
        BackgroundTransparency = 1,
        Position = IsMobile and UDim2.fromScale(0.18, 0.18) or UDim2.fromOffset(8, 5),
        Size = IsMobile and UDim2.fromScale(0.64, 0.64) or UDim2.fromOffset(32, 32),
        Image = ICONS.Dashboard,
        ImageColor3 = Library.Theme.SubText,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 101
    })
    Utility:RegisterProperty(OverviewIcon, "ImageColor3", "SubText")
    local OverviewLabel = Utility:Create("TextLabel", {
        Parent = OverviewBtn,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(48, 0),
        Size = UDim2.new(1, -58, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "Overview",
        TextColor3 = Library.Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = not IsMobile,
        ZIndex = 101
    })
    Utility:RegisterProperty(OverviewLabel, "TextColor3", "SubText")
    local OverviewIndicator = Utility:Create("Frame", {
        Parent = OverviewBtn,
        BackgroundColor3 = Library.Theme.Accent,
        Position = UDim2.new(0, 0, 0.5, -10),
        Size = UDim2.new(0, 4, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 102,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(OverviewIndicator, "BackgroundColor3", "Accent")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = OverviewIndicator})

    -- A single selection surface moves between every navigation destination.
    -- Keeping it outside the UIListLayout lets it travel cleanly across
    -- category gaps and down to the pinned Settings destination.
    local NavigationSelection = Utility:Create("Frame", {
        Name = "NavigationSelection",
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Accent,
        BackgroundTransparency = 0.1,
        Position = UDim2.fromOffset(8, 78),
        Size = UDim2.fromOffset(42, 42),
        Visible = false,
        -- Keep the moving surface below the TabContainer sibling group. In
        -- Sibling ZIndex mode, matching the container's ZIndex can place this
        -- later-created frame over every icon and label inside that group.
        ZIndex = 3,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(NavigationSelection, "BackgroundColor3", "Accent")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = NavigationSelection})
    local navigationSelectionStroke = Utility:Create("UIStroke", {
        Parent = NavigationSelection,
        Color = Library.Theme.Accent2,
        Transparency = 0.2,
        Thickness = 1
    })
    Utility:RegisterProperty(navigationSelectionStroke, "Color", "Accent2")
    local navigationSelectionGradient = Utility:Create("UIGradient", {
        Parent = NavigationSelection,
        Rotation = 18
    })
    Utility:RegisterGradient(navigationSelectionGradient, "Accent", "Accent2", "Accent3")
    local NavigationSelectionRail = Utility:Create("Frame", {
        Parent = NavigationSelection,
        BackgroundColor3 = Library.Theme.Text,
        BackgroundTransparency = 0.08,
        Position = UDim2.new(0, 3, 0.5, -9),
        Size = UDim2.fromOffset(3, 18),
        ZIndex = 5,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(NavigationSelectionRail, "BackgroundColor3", "Text")
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = NavigationSelectionRail})

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
            Position = ProfileCompact and UDim2.new(0.5, -19, 1, -(settingsBtnSize + 112)) or UDim2.new(0, 10, 1, -158),
            Size = ProfileCompact and UDim2.fromOffset(38, 38) or UDim2.new(1, -20, 0, 48),
            ClipsDescendants = true,
            ZIndex = 98,
            BorderSizePixel = 0
        })
        Utility:RegisterProperty(ProfileCard, "BackgroundColor3", "Surface")
        Utility:RegisterMaterial(ProfileCard, 0.28, 0)
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 9), Parent = ProfileCard})
        ProfileStroke = Utility:Create("UIStroke", {Parent = ProfileCard, Color = Library.Theme.Stroke, Thickness = 1, Enabled = not ProfileCompact})
        Utility:RegisterProperty(ProfileStroke, "Color", "Stroke")

        ProfileAvatar = Utility:Create("ImageLabel", {
            Parent = ProfileCard,
            BackgroundColor3 = Library.Theme.SurfaceAlt,
            Position = ProfileCompact and UDim2.fromOffset(2, 2) or UDim2.fromOffset(6, 6),
            Size = ProfileCompact and UDim2.new(1, -4, 1, -4) or UDim2.fromOffset(36, 36),
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

    local navigationLabelTokens = setmetatable({}, {__mode = "k"})
    local function applyLayout(instance, properties, animated)
        if animated then
            Utility:TweenLayout(instance, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
        else
            Utility:StopLayoutTween(instance)
            for property, value in pairs(properties) do instance[property] = value end
        end
    end

    local function setNavigationLabel(label, visible, animated)
        if not label then return end
        local token = (navigationLabelTokens[label] or 0) + 1
        navigationLabelTokens[label] = token
        if not animated then
            Utility:StopVisibilityTween(label)
            label.Visible = visible
            label.TextTransparency = visible and 0 or 1
            return
        end
        if visible then
            label.Visible = true
            label.TextTransparency = 1
            Utility:TweenVisibility(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
        else
            Utility:TweenVisibility(label, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}, function()
                if navigationLabelTokens[label] == token then label.Visible = false end
            end)
        end
    end

    local function getNavigationBottomInset(compact, mobile, hideProfile)
        if ShowUserProfile and not hideProfile then return compact and 224 or 234 end
        return 176
    end

    local function applyProfileLayout(compact, hidden, animated)
        ProfileCompact = compact
        if not ProfileCard then return end
        ProfileCard.Visible = not hidden
        applyLayout(ProfileCard, {
            BackgroundTransparency = compact and 1 or Library:ResolveMaterialTransparency(Library.MaterialRegistry[ProfileCard]),
            Position = compact and UDim2.new(0.5, -19, 1, -(settingsBtnSize + 112)) or UDim2.new(0, 10, 1, -158),
            Size = compact and UDim2.fromOffset(38, 38) or UDim2.new(1, -20, 0, 48)
        }, animated)
        applyLayout(ProfileAvatar, {
            Position = compact and UDim2.fromOffset(2, 2) or UDim2.fromOffset(6, 6),
            Size = compact and UDim2.new(1, -4, 1, -4) or UDim2.fromOffset(36, 36)
        }, animated)
        setNavigationLabel(ProfileNameLabel, not compact, animated)
        setNavigationLabel(ProfileSubtitleLabel, not compact, animated)
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
        BackgroundColor3 = Library.Theme.Secondary,
        BackgroundTransparency = 0.08,
        Position = UDim2.new(0, SidebarWidth, 0, 0),
        Size = UDim2.new(1, -SidebarWidth, 0, IsMobile and 88 or 60),
        ZIndex = 100,
        BorderSizePixel = 0
    })
    Utility:RegisterProperty(TopBar, "BackgroundColor3", "Secondary")
    Utility:RegisterMaterial(TopBar, 0.4, 0.08)

    Utility:MakeDraggable(TopBar, MainFrame)

    local TitleLabel = Utility:Create("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, IsMobile and 13 or 16),
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
    local minimizeStroke = Utility:Create("UIStroke", {Parent = MinimizeBtn, Color = Library.Theme.Stroke, Thickness = 1})
    Utility:RegisterProperty(minimizeStroke, "Color", "Stroke")

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
    local closeStroke = Utility:Create("UIStroke", {Parent = CloseBtn, Color = Library.Theme.Stroke, Thickness = 1})
    Utility:RegisterProperty(closeStroke, "Color", "Stroke")

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
            AnchorPoint = IsMobile and Vector2.new(0, 0) or Vector2.new(0.5, 0),
            Position = IsMobile and UDim2.new(0, 8, 0, 50) or UDim2.new(0.5, 0, 0, 15),
            Size = IsMobile and UDim2.new(1, -16, 0, 30) or UDim2.new(0, 250, 0, 30),
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
        Utility:Create("UIPadding", {Parent = SearchBox, PaddingLeft = UDim.new(0, 34), PaddingRight = UDim.new(0, 54)})
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
                Library:RefreshMaterialVisibility()
                MinimizedIcon.Visible = false
                MainFrame.Visible = true
                MobileToggleBtn.Visible = false
            else
                MainFrame.Visible = not MainFrame.Visible
                Library.IsMinimized = not MainFrame.Visible
                if not MainFrame.Visible then
                    MobileToggleBtn.Visible = true
                end
                Library:RefreshMaterialVisibility()
            end
        end)
    end

    -- Window Object (declared early so resizer can reference it)
    local Window = {
        Tabs = {},
        TabCategories = {},
        CurrentTabCategory = nil,
        NextNavOrder = 0,
        ActiveTab = nil,
        Gui = ScreenGui,
        Main = MainFrame,
        SettingsTab = nil,
        SearchBox = SearchBox,
        Sidebar = Sidebar,
        SidebarMode = SidebarMode,
        NavigationListeners = {},
        NavigationRevision = 0,
        SearchResults = {},
        SearchQuery = ""
    }

    function Window:OnTabChanged(callback)
        if type(callback) == "function" then table.insert(self.NavigationListeners, callback) end
        return self
    end

    function Window:SelectTab(tab, selectOptions)
        selectOptions = selectOptions or {}
        if tab ~= nil then
            local known = false
            for _, candidate in ipairs(self.Tabs) do
                if candidate == tab then known = true break end
            end
            if not known then return false, "Unknown tab" end
        end

        local previous = self.ActiveTab
        self.NavigationRevision = self.NavigationRevision + 1
        self.ActiveTab = tab

        for _, candidate in ipairs(self.Tabs) do
            local active = candidate == tab
            candidate.Active = active
            if candidate.Page then candidate.Page.Visible = active end
            if candidate.ApplyActiveVisual then candidate:ApplyActiveVisual(active, selectOptions.Animate ~= false) end
        end

        if tab then
            TitleLabel.Text = tab.Name
            if selectOptions.ResetScroll ~= false and tab.Page then tab.Page.CanvasPosition = Vector2.new(0, 0) end
            task.defer(function()
                if Window.ActiveTab == tab and not Library.Unloaded then
                    Window:MoveNavigationSelection(selectOptions.Animate ~= false)
                end
            end)
        else
            NavigationSelection.Visible = false
        end

        if previous ~= tab then
            for _, callback in ipairs(self.NavigationListeners) do
                Utility:SafeCall(callback, tab, previous, self.NavigationRevision)
            end
        end
        return true
    end

    local navigationSelectionToken = 0
    function Window:MoveNavigationSelection(animate)
        local active = self.ActiveTab
        local button = active and active.TabBtn
        if not button or not button.Parent or not Sidebar.Parent then
            NavigationSelection.Visible = false
            return
        end
        local effectiveScale = math.max(Library.DPIScale * WindowScale.Scale, 0.01)
        local offset = button.AbsolutePosition - Sidebar.AbsolutePosition
        local absoluteSize = button.AbsoluteSize
        if absoluteSize.X < 1 or absoluteSize.Y < 1 then return end
        local target = {
            Position = UDim2.fromOffset(offset.X / effectiveScale, offset.Y / effectiveScale),
            Size = UDim2.fromOffset(absoluteSize.X / effectiveScale, absoluteSize.Y / effectiveScale)
        }
        NavigationSelection.Visible = true
        if animate then
            Utility:Tween(NavigationSelection, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), target)
        else
            Utility:StopTween(NavigationSelection)
            NavigationSelection.Position = target.Position
            NavigationSelection.Size = target.Size
        end
    end

    function Window:TrackNavigationSelection(duration)
        navigationSelectionToken = navigationSelectionToken + 1
        local token = navigationSelectionToken
        task.spawn(function()
            local started = os.clock()
            repeat
                RunService.RenderStepped:Wait()
                if token ~= navigationSelectionToken or Library.Unloaded then return end
                Window:MoveNavigationSelection(false)
            until os.clock() - started >= (duration or 0.32)
            Window:MoveNavigationSelection(false)
        end)
    end

    Library:Connect(TabContainer:GetPropertyChangedSignal("CanvasPosition"), function()
        Window:MoveNavigationSelection(false)
    end)

    function Window:GetLayoutDiagnostics()
        local issues = {}
        local function add(code, message)
            table.insert(issues, {Code = code, Message = message})
        end
        local function overlaps(a, b, padding)
            padding = padding or 0
            local ap, as = a.AbsolutePosition, a.AbsoluteSize
            local bp, bs = b.AbsolutePosition, b.AbsoluteSize
            return ap.X + as.X + padding > bp.X
                and bp.X + bs.X + padding > ap.X
                and ap.Y + as.Y + padding > bp.Y
                and bp.Y + bs.Y + padding > ap.Y
        end
        if Library.DPIScale < 1 then
            add("scale-floor", "UI scale is below the supported 100% minimum")
        end
        if MainFrame.ClipsDescendants ~= true then
            add("shell-clip", "The root shell is not clipping internal chrome to its corner")
        end
        if SidebarModeButton.Visible and overlaps(LogoContainer, SidebarModeButton, 2) then
            add("nav-header-overlap", "The brand mark and sidebar-mode control overlap")
        end
        if BrandLabel.Visible and SidebarModeButton.Visible and overlaps(BrandLabel, SidebarModeButton, 2) then
            add("nav-header-label-overlap", "The sidebar-mode control overlaps the RenLib wordmark")
        end
        if SidebarModeButton.Visible and (SidebarModeButton.AbsoluteSize.X < 28 or SidebarModeButton.AbsoluteSize.Y < 28) then
            add("nav-toggle-hit-area", "The sidebar-mode control is smaller than its safe pointer target")
        end
        if self.SidebarVisualExpanded and self.ActiveTab and self.ActiveTab.TabBtn
            and self.ActiveTab.TabBtn.AbsoluteSize.X < Sidebar.AbsoluteSize.X * 0.6 then
            add("active-tab-state", "The selected tab is still using compact geometry inside an expanded sidebar")
        end
        if self.SidebarVisualExpanded and ProfileCard and ProfileCard.Visible
            and ProfileCard.AbsoluteSize.X < Sidebar.AbsoluteSize.X * 0.6 then
            add("profile-state", "The profile card is still using compact geometry inside an expanded sidebar")
        end
        if OverviewBtn.Visible and overlaps(OverviewBtn, SettingsBtn, 4) then
            add("native-navigation-overlap", "Overview and Settings overlap")
        end
        if ProfileCard and ProfileCard.Visible and overlaps(ProfileCard, OverviewBtn, 4) then
            add("profile-overview-overlap", "The profile card overlaps Overview")
        end
        local seamDistance = math.abs((Sidebar.AbsolutePosition.X + Sidebar.AbsoluteSize.X) - TopBar.AbsolutePosition.X)
        if seamDistance > 2 then
            add("chrome-seam", "The sidebar and top bar no longer share one seam")
        end
        return #issues == 0, issues
    end

    function Window:SetProfile(data)
        SetProfileData(data)
    end

    function Window:RefreshThemeState()
        for _, tab in ipairs(self.Tabs) do
            local textKey = tab.Active and "Text" or "SubText"
            if tab.TabLabel then tab.TabLabel.TextColor3 = Library.Theme[textKey] end
            if tab.TabEmoji then
                if tab.TabEmoji:IsA("TextLabel") then
                    tab.TabEmoji.TextColor3 = Library.Theme[textKey]
                elseif tab.TabEmoji:IsA("ImageLabel") then
                    tab.TabEmoji.ImageColor3 = Library.Theme[textKey]
                end
            end
            if tab.TabBtn then tab.TabBtn.BackgroundTransparency = tab.Active and 1 or 0.64 end
            if tab.TabStroke then
                tab.TabStroke.Color = tab.Active and Library.Theme.Accent or Library.Theme.Stroke
                tab.TabStroke.Transparency = tab.Active and 0.08 or 0.24
            end
        end
        self:MoveNavigationSelection(false)
    end

    -- RESIZABLE SIDEBAR (PC only)
    local sidebarResizer = nil
    local dividerLine = nil
    local currentSidebarWidth = math.clamp(tonumber(options.SidebarWidth) or 190, 132, 240)
    local sidebarHoverExpanded = false
    local isCompact = IsMobile or SidebarMode ~= "Expanded"
    if EnableSidebarResize and not IsMobile then
        dividerLine = Utility:Create("Frame", {
            Parent = MainFrame,
            BackgroundColor3 = Library.Theme.Stroke,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, SidebarWidth, 0, 0),
            Size = UDim2.new(0, 1, 1, 0),
            ZIndex = 5,
            BorderSizePixel = 0
        })
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 and not isCompact then
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
                SidebarMode = "Expanded"
                Window.SidebarMode = SidebarMode
                Window:ApplyResponsiveLayout(false)
            end
        end)
    end

    local lastDeviceMode = DeviceMode

    function Window:ApplyResponsiveLayout(recenter, animateNavigation)
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
        local navigationExpanded = SidebarMode == "Expanded" or (SidebarMode == "Dynamic" and sidebarHoverExpanded)
        local sidebarWidth = mobile and (width < 340 and 54 or 60)
            or (navigationExpanded and math.clamp(currentSidebarWidth, 132, math.min(240, width * 0.32)) or 80)
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
        applyLayout(Sidebar, {Size = UDim2.new(0, sidebarWidth, 1, 0)}, animateNavigation)
        applyLayout(Pages, {
            Position = UDim2.new(0, sidebarWidth, 0, 0),
            Size = UDim2.new(1, -sidebarWidth, 1, 0)
        }, animateNavigation)
        isCompact = mobile or sidebarWidth < 132
        local visibleContentWidth = math.max(1, (width - sidebarWidth) * scale)
        local singleColumn = mobile or visibleContentWidth < 640
        applyLayout(TopBar, {
            Position = UDim2.new(0, sidebarWidth, 0, 0),
            Size = UDim2.new(1, -sidebarWidth, 0, topBarHeight)
        }, animateNavigation)
        applyLayout(TitleLabel, {
            Position = UDim2.new(0, 16, 0, mobile and (hideSearch and 9 or 11) or 16),
            Size = UDim2.new(1, -(mobile and 108 or 430), 0, 30)
        }, animateNavigation)
        TitleLabel.TextSize = mobile and 17 or 19
        applyLayout(TopDivider, {
            Position = UDim2.new(0, sidebarWidth, 0, topBarHeight - 1),
            Size = UDim2.new(1, -sidebarWidth, 0, 1)
        }, animateNavigation)
        MinimizeBtn.Position = UDim2.new(1, -76, 0, mobile and 8 or 15)
        CloseBtn.Position = UDim2.new(1, -40, 0, mobile and 8 or 15)
        local activeLogoSize = mobile and 28 or (isCompact and 26 or 36)
        local showWordmark = not isCompact and sidebarWidth >= 174
        applyLayout(LogoContainer, {
            Size = UDim2.fromOffset(activeLogoSize, activeLogoSize),
            Position = mobile and UDim2.new(0.5, -activeLogoSize / 2, 0, 9)
                or (isCompact and UDim2.fromOffset(4, 10) or UDim2.fromOffset(7, 5))
        }, animateNavigation)
        setNavigationLabel(BrandLabel, showWordmark, animateNavigation)
        setNavigationLabel(BrandSubtitle, showWordmark, animateNavigation)
        SidebarModeButton.Visible = not mobile
        SidebarModeLabel.Text = SidebarMode == "Expanded" and "Auto" or "Pin"
        applyLayout(SidebarModeButton, {
            Position = isCompact and UDim2.new(1, -32, 0, 9) or UDim2.new(1, -62, 0, 9),
            Size = isCompact and UDim2.fromOffset(28, 28) or UDim2.fromOffset(58, 28)
        }, animateNavigation)
        applyLayout(SidebarModeIcon, {
            Position = isCompact and UDim2.fromOffset(6, 6) or UDim2.fromOffset(7, 6),
            Size = UDim2.fromOffset(16, 16),
            Rotation = isCompact and 0 or 180
        }, animateNavigation)
        setNavigationLabel(SidebarModeLabel, not isCompact, animateNavigation)
        applyLayout(TabContainer, {
            Position = UDim2.new(0, isCompact and 0 or 8, 0, mobile and 70 or 68),
            Size = UDim2.new(1, isCompact and 0 or -16, 1, -getNavigationBottomInset(isCompact, mobile, hideProfile))
        }, animateNavigation)
        applyLayout(SettingsBtn, {
            Position = isCompact and UDim2.new(0.5, -settingsBtnSize / 2, 1, -(settingsBtnSize + 12)) or UDim2.new(0, 10, 1, -54),
            Size = isCompact and UDim2.fromOffset(settingsBtnSize, settingsBtnSize) or UDim2.new(1, -20, 0, 42)
        }, animateNavigation)
        applyLayout(SettingsEmoji, {
            Position = isCompact and UDim2.fromScale(0.18, 0.18) or UDim2.fromOffset(8, 5),
            Size = isCompact and UDim2.fromScale(0.64, 0.64) or UDim2.fromOffset(32, 32)
        }, animateNavigation)
        setNavigationLabel(SettingsLabel, not isCompact, animateNavigation)
        applyLayout(OverviewBtn, {
            Position = isCompact and UDim2.new(0.5, -settingsBtnSize / 2, 1, -(settingsBtnSize + 62)) or UDim2.new(0, 10, 1, -102),
            Size = isCompact and UDim2.fromOffset(settingsBtnSize, settingsBtnSize) or UDim2.new(1, -20, 0, 42)
        }, animateNavigation)
        applyLayout(OverviewIcon, {
            Position = isCompact and UDim2.fromScale(0.18, 0.18) or UDim2.fromOffset(8, 5),
            Size = isCompact and UDim2.fromScale(0.64, 0.64) or UDim2.fromOffset(32, 32)
        }, animateNavigation)
        setNavigationLabel(OverviewLabel, not isCompact, animateNavigation)
        applyProfileLayout(isCompact, hideProfile, animateNavigation)
        NotifyArea.Position = UDim2.new(1, mobile and -12 or -20, 1, -20)
        NotifyArea.Size = UDim2.new(0, mobile and math.max(180, math.min(300, layoutViewport.X - 24)) or 300, 1, 0)
        if SearchBox then
            SearchBox.Visible = not hideSearch
            SearchBox.AnchorPoint = mobile and Vector2.new(0, 0) or Vector2.new(0.5, 0)
            SearchBox.Position = mobile and UDim2.new(0, 8, 0, shortViewport and 41 or 50)
                or UDim2.new(0.5, 0, 0, 15)
            SearchBox.Size = mobile and UDim2.new(1, -16, 0, shortViewport and 26 or 30) or UDim2.new(0, 270, 0, 30)
        end
        if dividerLine then
            dividerLine.Visible = not mobile and not isCompact
            dividerLine.Position = UDim2.new(0, sidebarWidth, 0, 0)
        end
        for _, tab in ipairs(Window.Tabs) do
            if tab.ApplyNavigationLayout then tab:ApplyNavigationLayout(mobile, isCompact, animateNavigation) end
            if tab.ApplyResponsiveLayout then
                tab:ApplyResponsiveLayout(singleColumn, topBarHeight)
            end
        end
        for _, category in ipairs(Window.TabCategories) do
            category.Label.Visible = true
            applyLayout(category.Label, {
                Size = UDim2.new(1, -8, 0, isCompact and 0 or 20),
                TextTransparency = isCompact and 1 or 0
            }, animateNavigation)
        end
        if animateNavigation then
            self:TrackNavigationSelection(0.34)
        else
            task.defer(function() if not Library.Unloaded then self:MoveNavigationSelection(false) end end)
        end
        self.SidebarVisualExpanded = not isCompact
        if Library.IsMinimized then
            MobileToggleBtn.Visible = mobile
            MinimizedIcon.Visible = not mobile
        end
        if mode ~= lastDeviceMode then
            lastDeviceMode = mode
            Utility:SafeCall(options.OnDeviceChanged, mode)
        end
        task.delay(animateNavigation and 0.34 or 0, function()
            if not Library.Unloaded then
                local passed, issues = self:GetLayoutDiagnostics()
                self.LastLayoutAudit = {Passed = passed, Issues = issues, CheckedAt = os.clock()}
            end
        end)
        return mode
    end

    function Window:SetSidebarMode(mode)
        mode = tostring(mode or "Dynamic")
        if mode ~= "Dynamic" and mode ~= "Expanded" and mode ~= "Compact" then return false end
        SidebarMode = mode
        self.SidebarMode = mode
        sidebarHoverExpanded = false
        SidebarModeLabel.Text = mode == "Expanded" and "Auto" or "Pin"
        self:ApplyResponsiveLayout(false, true)
        return true
    end

    local sidebarHoverToken = 0
    local function setSidebarHover(expanded)
        if SidebarMode ~= "Dynamic" or IsMobile then return end
        sidebarHoverToken = sidebarHoverToken + 1
        local token = sidebarHoverToken
        if expanded then
            if not sidebarHoverExpanded then
                sidebarHoverExpanded = true
                Window:ApplyResponsiveLayout(false, true)
            end
        else
            task.delay(0.35, function()
                if token == sidebarHoverToken and SidebarMode == "Dynamic" then
                    sidebarHoverExpanded = false
                    Window:ApplyResponsiveLayout(false, true)
                end
            end)
        end
    end

    -- Hover expansion belongs to navigation content, not the mode button.
    -- The compact button therefore stays under the pointer and can be clicked
    -- immediately instead of moving away on the first hover.
    Library:Connect(TabContainer.MouseEnter, function() setSidebarHover(true) end)
    Library:Connect(TabContainer.MouseLeave, function() setSidebarHover(false) end)
    Library:Connect(SettingsBtn.MouseEnter, function() setSidebarHover(true) end)
    Library:Connect(SettingsBtn.MouseLeave, function() setSidebarHover(false) end)
    Library:Connect(OverviewBtn.MouseEnter, function() setSidebarHover(true) end)
    Library:Connect(OverviewBtn.MouseLeave, function() setSidebarHover(false) end)
    if ProfileCard then
        Library:Connect(ProfileCard.MouseEnter, function() setSidebarHover(true) end)
        Library:Connect(ProfileCard.MouseLeave, function() setSidebarHover(false) end)
    end
    Library:Connect(NavHeader.MouseEnter, function()
        if sidebarHoverExpanded then sidebarHoverToken = sidebarHoverToken + 1 end
    end)
    Library:Connect(NavHeader.MouseLeave, function()
        if sidebarHoverExpanded then setSidebarHover(false) end
    end)
    Library:Connect(SidebarModeButton.MouseEnter, function()
        Utility:Tween(SidebarModeButton, TweenInfo.new(0.14), {BackgroundTransparency = 0.12})
        Utility:Tween(sidebarModeStroke, TweenInfo.new(0.14), {Transparency = 0.05})
    end)
    Library:Connect(SidebarModeButton.MouseLeave, function()
        Utility:Tween(SidebarModeButton, TweenInfo.new(0.14), {BackgroundTransparency = 0.34})
        Utility:Tween(sidebarModeStroke, TweenInfo.new(0.14), {Transparency = 0.28})
    end)
    Library:Connect(SidebarModeButton.MouseButton1Click, function()
        Window:SetSidebarMode(SidebarMode == "Expanded" and "Dynamic" or "Expanded")
    end)

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

    local TooltipFrame = Utility:Create("Frame", {
        Name = "Tooltip", Parent = ScreenGui, BackgroundColor3 = Library.Theme.Secondary,
        BackgroundTransparency = 0.04, AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false, ZIndex = 950, BorderSizePixel = 0
    })
    Utility:RegisterProperty(TooltipFrame, "BackgroundColor3", "Secondary")
    Utility:Create("UICorner", {Parent = TooltipFrame, CornerRadius = UDim.new(0, 6)})
    local tooltipStroke = Utility:Create("UIStroke", {Parent = TooltipFrame, Color = Library.Theme.Stroke, Thickness = 1})
    Utility:RegisterProperty(tooltipStroke, "Color", "Stroke")
    Utility:Create("UIPadding", {
        Parent = TooltipFrame, PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9),
        PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7)
    })
    local TooltipText = Utility:Create("TextLabel", {
        Parent = TooltipFrame, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.fromOffset(220, 0), TextWrapped = true, TextColor3 = Library.Theme.Text,
        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 951
    })
    Utility:RegisterProperty(TooltipText, "TextColor3", "Text")
    local activeTooltipTarget = nil

    function Window:ShowTooltip(text, position, target)
        text = tostring(text or "")
        if text == "" then return end
        activeTooltipTarget = target
        TooltipText.Text = text
        TooltipFrame.Visible = true
        task.defer(function()
            if not TooltipFrame.Visible or (target and activeTooltipTarget ~= target) then return end
            local viewport = getViewport()
            local size = TooltipFrame.AbsoluteSize
            local x = math.clamp((position and position.X or 0) + 14, 8, math.max(8, viewport.X - size.X - 8))
            local y = math.clamp((position and position.Y or 0) + 16, 8, math.max(8, viewport.Y - size.Y - 8))
            TooltipFrame.Position = UDim2.fromOffset(x, y)
        end)
    end

    function Window:HideTooltip(target)
        if target and activeTooltipTarget ~= target then return end
        activeTooltipTarget = nil
        TooltipFrame.Visible = false
    end

    function Window:AttachTooltip(target, text)
        if not target or not target:IsA("GuiObject") or text == nil or tostring(text) == "" then return nil end
        local touching = false
        Library:Connect(target.MouseEnter, function()
            local mouse = UserInputService:GetMouseLocation()
            Window:ShowTooltip(text, mouse, target)
        end)
        Library:Connect(target.MouseMoved, function(x, y)
            if activeTooltipTarget == target then Window:ShowTooltip(text, Vector2.new(x, y), target) end
        end)
        Library:Connect(target.MouseLeave, function() Window:HideTooltip(target) end)
        Library:Connect(target.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch then return end
            touching = true
            task.delay(0.45, function()
                if touching and target.Parent and not Library.Unloaded then Window:ShowTooltip(text, input.Position, target) end
            end)
        end)
        Library:Connect(target.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.Touch then touching = false Window:HideTooltip(target) end
        end)
        return {Show = function() Window:ShowTooltip(text, target.AbsolutePosition + target.AbsoluteSize, target) end,
            Hide = function() Window:HideTooltip(target) end,
            Set = function(_, value) text = tostring(value or "") end}
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

    function Window:Prompt(promptOptions)
        promptOptions = promptOptions or {}
        local overlay = Utility:Create("TextButton", {
            Name = "PromptOverlay", Parent = ScreenGui, BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "",
            AutoButtonColor = false, ZIndex = 820
        })
        local layoutWidth = getViewport().X / math.max(Library.DPIScale, 0.01)
        local card = Utility:Create("Frame", {
            Parent = overlay, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(math.max(1, math.min(IsMobile and 320 or 420, layoutWidth - 24)), 0),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Library.Theme.Main,
            BorderSizePixel = 0, ZIndex = 821
        })
        Utility:RegisterProperty(card, "BackgroundColor3", "Main")
        Utility:Create("UICorner", {Parent = card, CornerRadius = UDim.new(0, 10)})
        local stroke = Utility:Create("UIStroke", {Parent = card, Color = Library.Theme.Stroke, Thickness = 1})
        Utility:RegisterProperty(stroke, "Color", "Stroke")
        Utility:Create("UIPadding", {
            Parent = card, PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 16),
            PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)
        })
        Utility:Create("UIListLayout", {Parent = card, Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder})
        local title = Utility:Create("TextLabel", {
            Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24),
            Text = tostring(promptOptions.Title or "Enter a value"), TextColor3 = Library.Theme.Text,
            Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 822
        })
        Utility:RegisterProperty(title, "TextColor3", "Text")
        if promptOptions.Content then
            local content = Utility:Create("TextLabel", {
                Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), AutomaticSize = Enum.AutomaticSize.Y,
                Text = tostring(promptOptions.Content), TextColor3 = Library.Theme.SubText, Font = Enum.Font.Gotham,
                TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 822
            })
            Utility:RegisterProperty(content, "TextColor3", "SubText")
        end
        local input = Utility:Create("TextBox", {
            Parent = card, BackgroundColor3 = Library.Theme.Surface, Size = UDim2.new(1, 0, 0, 38),
            Text = tostring(promptOptions.Default or ""), PlaceholderText = tostring(promptOptions.Placeholder or "Type here..."),
            ClearTextOnFocus = false, TextColor3 = Library.Theme.Text, PlaceholderColor3 = Library.Theme.SubText,
            Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 822, BorderSizePixel = 0
        })
        Utility:RegisterProperty(input, "BackgroundColor3", "Surface")
        Utility:RegisterProperty(input, "TextColor3", "Text")
        Utility:RegisterProperty(input, "PlaceholderColor3", "SubText")
        Utility:Create("UICorner", {Parent = input, CornerRadius = UDim.new(0, 6)})
        Utility:Create("UIPadding", {Parent = input, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
        local errorLabel = Utility:Create("TextLabel", {
            Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Text = "", TextColor3 = Library.Theme.Error, Font = Enum.Font.Gotham, TextSize = 11,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Visible = false, ZIndex = 822
        })
        Utility:RegisterProperty(errorLabel, "TextColor3", "Error")
        local actions = Utility:Create("Frame", {Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), ZIndex = 822})
        Utility:Create("UIListLayout", {Parent = actions, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8)})
        local closed = false
        local function close(cancelled)
            if closed then return end
            closed = true
            if cancelled then Utility:SafeCall(promptOptions.OnCancel) end
            Utility:Tween(overlay, TweenInfo.new(0.18), {BackgroundTransparency = 1}, function()
                if overlay.Parent then overlay:Destroy() end
            end)
            if Library.ReducedMotion and overlay.Parent then overlay:Destroy() end
        end
        local function submit()
            local value = input.Text
            if type(promptOptions.Validate) == "function" then
                local ok, valid, message = pcall(promptOptions.Validate, value)
                if not ok or valid == false then
                    errorLabel.Text = tostring(ok and message or valid)
                    errorLabel.Visible = true
                    return
                end
            end
            Utility:SafeCall(promptOptions.Callback, value)
            close(false)
        end
        local function makeAction(name, primary, callback)
            local button = Utility:Create("TextButton", {
                Parent = actions, BackgroundColor3 = primary and Library.Theme.Accent or Library.Theme.Hover,
                Size = UDim2.fromOffset(96, 32), Text = name, TextColor3 = Library.Theme.Text,
                Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 823
            })
            Utility:Create("UICorner", {Parent = button, CornerRadius = UDim.new(0, 6)})
            Library:Connect(button.MouseButton1Click, callback)
        end
        makeAction(tostring(promptOptions.CancelText or "Cancel"), false, function() close(true) end)
        makeAction(tostring(promptOptions.SubmitText or "Submit"), true, submit)
        Library:Connect(input.FocusLost, function(enterPressed) if enterPressed then submit() end end)
        Library:Connect(overlay.MouseButton1Click, function() if promptOptions.Dismissable ~= false then close(true) end end)
        Utility:Tween(overlay, TweenInfo.new(0.18), {BackgroundTransparency = 0.35})
        task.defer(function() if input.Parent then input:CaptureFocus() end end)
        return {Close = function() close(true) end, Submit = submit, Get = function() return input.Text end,
            Set = function(_, value) input.Text = tostring(value or "") end, Frame = card, Input = input}
    end

    local function ensureBuiltinKeybinds()
    if Library.__BuiltinKeybindsRegistered then
        return
    end

    Library.__BuiltinKeybindsRegistered = true

    local savedToggleKey = Library.Flags.__RenLibToggleUI
    if type(savedToggleKey) == "string" and Enum.KeyCode[savedToggleKey] then
        Library.ToggleKey = Enum.KeyCode[savedToggleKey]
    end

    local entry
    entry = {
        name = "Toggle UI",
        key = Library.ToggleKey.Name,
        default = Library.ToggleKey.Name,
        mode = "Press",
        flag = "__RenLibToggleUI",
        Virtual = true,
    }

    entry.controller = {
        Set = function(_, key)
            local keyName = typeof(key) == "EnumItem" and key.Name or tostring(key)

            if Enum.KeyCode[keyName] then
                Library.ToggleKey = Enum.KeyCode[keyName]
                Library.Flags.__RenLibToggleUI = keyName
                entry.key = keyName
            end
        end,

        Get = function()
            return entry.key
        end,

        GetKey = function()
            return entry.key
        end,
    }

    table.insert(Library.KeybindList, entry)
end

function Window:ShowKeybindManager()
    ensureBuiltinKeybinds()

    if self.KeybindManagerOverlay and self.KeybindManagerOverlay.Parent then
        if self.KeybindManagerRebuild then
            self.KeybindManagerRebuild()
        end

        self.KeybindManagerOverlay.Visible = true
        return self.KeybindManagerOverlay
    end
        local overlay = Utility:Create("TextButton", {
            Name = "KeybindManagerOverlay", Parent = ScreenGui, BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.35, Size = UDim2.fromScale(1, 1), Text = "",
            AutoButtonColor = false, ZIndex = 840
        })
        self.KeybindManagerOverlay = overlay
        local card = Utility:Create("Frame", {
            Parent = overlay, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(math.min(IsMobile and 330 or 460, getViewport().X - 24), math.min(430, getViewport().Y - 24)),
            BackgroundColor3 = Library.Theme.Main, BorderSizePixel = 0, ZIndex = 841
        })
        Utility:RegisterProperty(card, "BackgroundColor3", "Main")
        Utility:Create("UICorner", {Parent = card, CornerRadius = UDim.new(0, 10)})
        local stroke = Utility:Create("UIStroke", {Parent = card, Color = Library.Theme.Stroke, Thickness = 1})
        Utility:RegisterProperty(stroke, "Color", "Stroke")
        local title = Utility:Create("TextLabel", {
            Parent = card, BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 12),
            Size = UDim2.new(1, -72, 0, 28), Text = "Keybind manager", TextColor3 = Library.Theme.Text,
            Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 842
        })
        Utility:RegisterProperty(title, "TextColor3", "Text")
        local closeButton = Utility:Create("TextButton", {
            Parent = card, BackgroundColor3 = Library.Theme.Surface, Position = UDim2.new(1, -46, 0, 10),
            Size = UDim2.fromOffset(34, 30), Text = "×", TextColor3 = Library.Theme.Text,
            Font = Enum.Font.GothamBold, TextSize = 18, AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 843
        })
        Utility:RegisterProperty(closeButton, "BackgroundColor3", "Surface")
        Utility:RegisterProperty(closeButton, "TextColor3", "Text")
        Utility:Create("UICorner", {Parent = closeButton, CornerRadius = UDim.new(0, 6)})
        local list = Utility:Create("ScrollingFrame", {
            Parent = card, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 52),
            Size = UDim2.new(1, -24, 1, -104), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent, BorderSizePixel = 0, ZIndex = 842
        })
        Utility:RegisterProperty(list, "ScrollBarImageColor3", "Accent")
        Utility:Create("UIListLayout", {Parent = list, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder})
local function rebuild()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end

    local rendered = 0

    for _, entry in ipairs(Library.KeybindList) do
        local isVisibleEntry =
            entry.Virtual == true
            or (entry.controller and entry.controller.Holder and entry.controller.Holder.Parent)

        if isVisibleEntry then
            rendered += 1

            local row = Utility:Create("Frame", {
                Parent = list,
                BackgroundColor3 = Library.Theme.Surface,
                Size = UDim2.new(1, -4, 0, 42),
                BorderSizePixel = 0,
                ZIndex = 843
            })

            Utility:RegisterProperty(row, "BackgroundColor3", "Surface")
            Utility:Create("UICorner", {Parent = row, CornerRadius = UDim.new(0, 6)})

            local label = Utility:Create("TextLabel", {
                Parent = row,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(1, -160, 1, 0),
                Text = entry.name .. "  ·  " .. entry.mode,
                TextColor3 = Library.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 844
            })

            Utility:RegisterProperty(label, "TextColor3", "Text")

            local keyButton = Utility:Create("TextButton", {
                Parent = row,
                BackgroundColor3 = Library.Theme.Secondary,
                Position = UDim2.new(1, -142, 0.5, -14),
                Size = UDim2.fromOffset(76, 28),
                Text = tostring(entry.key),
                TextColor3 = Library.Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                ZIndex = 844
            })

            Utility:RegisterProperty(keyButton, "BackgroundColor3", "Secondary")
            Utility:RegisterProperty(keyButton, "TextColor3", "Text")
            Utility:Create("UICorner", {Parent = keyButton, CornerRadius = UDim.new(0, 5)})

            local resetButton = Utility:Create("TextButton", {
                Parent = row,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -60, 0.5, -14),
                Size = UDim2.fromOffset(52, 28),
                Text = "Reset",
                TextColor3 = Library.Theme.SubText,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                AutoButtonColor = false,
                ZIndex = 844
            })

            Utility:RegisterProperty(resetButton, "TextColor3", "SubText")

            Library:Connect(keyButton.MouseButton1Click, function()
                keyButton.Text = "Press…"

                local connection
                connection = UserInputService.InputBegan:Connect(function(input, processed)
                    if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end

                    connection:Disconnect()

                    if entry.controller and entry.controller.Set then
                        entry.controller:Set(input.KeyCode.Name)
                    end

                    entry.key = input.KeyCode.Name
                    keyButton.Text = input.KeyCode.Name
                end)
            end)

            Library:Connect(resetButton.MouseButton1Click, function()
                if entry.controller and entry.controller.Set then
                    entry.controller:Set(entry.default)
                end

                entry.key = entry.default
                keyButton.Text = tostring(entry.default)
            end)
        end
    end

    if rendered == 0 then
        local empty = Utility:Create("TextLabel", {
            Parent = list,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -8, 0, 90),
            Text = "No keybinds registered yet.\nUse CreateKeyPicker(...) to add shortcuts here.",
            TextColor3 = Library.Theme.SubText,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 843
        })

        Utility:RegisterProperty(empty, "TextColor3", "SubText")
    end
end

self.KeybindManagerRebuild = rebuild
        local footer = Utility:Create("TextButton", {
            Parent = card, BackgroundColor3 = Library.Theme.Surface, Position = UDim2.new(0, 12, 1, -42),
            Size = UDim2.new(1, -24, 0, 30), Text = "Reset all keybinds", TextColor3 = Library.Theme.Text,
            Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 843
        })
        Utility:RegisterProperty(footer, "BackgroundColor3", "Surface")
        Utility:RegisterProperty(footer, "TextColor3", "Text")
        Utility:Create("UICorner", {Parent = footer, CornerRadius = UDim.new(0, 6)})
        Library:Connect(footer.MouseButton1Click, function()
            for _, entry in ipairs(Library.KeybindList) do
                if entry.controller then entry.controller:Set(entry.default) end
            end
            rebuild()
        end)
        local function hide() overlay.Visible = false end
        Library:Connect(closeButton.MouseButton1Click, hide)
        Library:Connect(overlay.MouseButton1Click, hide)
        rebuild()
        return overlay
    end

    Library.KeybindManager = {Show = function() return Window:ShowKeybindManager() end,
        Hide = function() if Window.KeybindManagerOverlay then Window.KeybindManagerOverlay.Visible = false end end}

    Window:ApplyResponsiveLayout(true)
    Library:SetMaterialIntensity(options.MaterialIntensity or Library.MaterialIntensity)
    Library:SetMaterialMode(RequestedMaterialMode)
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
        Library:RefreshMaterialVisibility()
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
        Library:RefreshMaterialVisibility()
        MinimizedIcon.Visible = false
        MainFrame.Visible = true
        MainFrame.BackgroundTransparency = 1
        WindowScale.Scale = 0.96
        Utility:Tween(WindowScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
        local mainMaterial = Library.MaterialRegistry[MainFrame]
        local restoredTransparency = mainMaterial and (Library.MaterialMode == "Frosted" and mainMaterial.Frosted or mainMaterial.Solid) or 0
        Utility:Tween(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = restoredTransparency})
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

-- GLOBAL SEARCH: indexes controls and highlights matches without changing the
-- structural visibility of tabs, pages, sections, or controls. Navigation is
-- still owned exclusively by Window:SelectTab.
if SearchBox then
    local highlights = setmetatable({}, {__mode = "k"})
    local SearchStatus = Utility:Create("TextLabel", {
        Name = "SearchStatus", Parent = SearchBox, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(42, 18),
        BackgroundTransparency = 1, Text = "", TextColor3 = Library.Theme.SubText,
        Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = SearchBox.ZIndex + 1
    })
    Utility:RegisterProperty(SearchStatus, "TextColor3", "SubText")

    local function clearHighlights()
        for holder, stroke in pairs(highlights) do
            if stroke and stroke.Parent then stroke:Destroy() end
            highlights[holder] = nil
        end
    end

    local function highlight(holder)
        if not holder or not holder:IsA("GuiObject") or highlights[holder] then return end
        local stroke = Utility:Create("UIStroke", {
            Name = "RenSearchHighlight", Parent = holder, Color = Library.Theme.Accent,
            Thickness = 2, Transparency = 0.05, ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        Utility:RegisterProperty(stroke, "Color", "Accent")
        highlights[holder] = stroke
    end

    function Window:FocusSearchResult(index)
        local count = #self.SearchResults
        if count == 0 then return false end
        index = ((tonumber(index) or self.SearchIndex or 0) - 1) % count + 1
        self.SearchIndex = index
        local result = self.SearchResults[index]
        self:SelectTab(result.Tab, {ResetScroll = false, Animate = true})
        SearchStatus.Text = tostring(index) .. "/" .. tostring(count)
        task.defer(function()
            local holder, page = result.Holder, result.Tab.Page
            if not holder or not holder.Parent or not page or not page.Parent then return end
            local localY = holder.AbsolutePosition.Y - page.AbsolutePosition.Y + page.CanvasPosition.Y
            page.CanvasPosition = Vector2.new(0, math.max(0, localY - 12))
            local stroke = highlights[holder]
            if stroke then
                stroke.Transparency = 0
                Utility:Tween(stroke, TweenInfo.new(0.45), {Transparency = 0.18})
            end
        end)
        return true
    end

    function Window:RefreshSearch(query)
        query = tostring(query or ""):lower():match("^%s*(.-)%s*$") or ""
        self.SearchQuery = query
        self.SearchIndex = 0
        self.SearchResults = {}
        clearHighlights()

        if query == "" then
            SearchStatus.Text = ""
            return self.SearchResults
        end

        local seen = {}
        for _, tab in ipairs(self.Tabs) do
            for _, section in ipairs(tab.Sections or {}) do
                for _, element in ipairs(section.Elements or {}) do
                    local holder = element.Holder
                    local haystack = table.concat({tab.Name or "", section.Name or "", element.Text or element.Name or ""}, " "):lower()
                    if holder and holder.Parent and haystack:find(query, 1, true) and not seen[holder] then
                        seen[holder] = true
                        table.insert(self.SearchResults, {Tab = tab, Section = section, Element = element, Holder = holder})
                        highlight(holder)
                        if element.NestedParentHolder then highlight(element.NestedParentHolder) end
                    end
                end
            end
        end

        SearchStatus.Text = #self.SearchResults == 0 and "0" or tostring(#self.SearchResults)
        return self.SearchResults
    end

    function Window:ClearSearch()
        SearchBox.Text = ""
        self:RefreshSearch("")
        return self
    end

    Library:Connect(SearchBox:GetPropertyChangedSignal("Text"), function()
        Window:RefreshSearch(SearchBox.Text)
    end)
    Library:Connect(SearchBox.FocusLost, function(enterPressed)
        if enterPressed and Window.SearchQuery ~= "" then
            Window:FocusSearchResult((Window.SearchIndex or 0) + 1)
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

