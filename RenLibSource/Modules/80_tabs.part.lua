-- Module fragment: tabs and activation
-- Generated from the working V7 baseline; edit this feature in isolation.
    --// TABS
    function Window:CreateTabCategory(name)
        self.NextNavOrder = self.NextNavOrder + 1
        local category = Utility:Create("TextLabel", {
            Name = "Category_" .. tostring(name), Parent = TabContainer,
            BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, isCompact and 0 or 20),
            Text = string.upper(tostring(name or "")), TextColor3 = Library.Theme.SubText,
            Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = isCompact and 1 or 0,
            ZIndex = 5, Visible = true, LayoutOrder = self.NextNavOrder
        })
        Utility:RegisterProperty(category, "TextColor3", "SubText")
        local categoryEntry = {Label = category, Tabs = {}}
        table.insert(self.TabCategories, categoryEntry)
        self.CurrentTabCategory = categoryEntry
        return category
    end

    function Window:CreateTab(options)
        options = options or {}
        local Name = options.Name or "Tab"
        local Emoji = options.Emoji
        local IsSettings = options.IsSettings or false
        local IsOverview = options.IsOverview or false
        local Icon = Utility:NormalizeAssetId(options.Icon)
        self.NextNavOrder = self.NextNavOrder + 1
        if not Icon and Emoji == nil and not IsSettings and not IsOverview then Icon = ICONS.Home end

        local Tab = {
            Name = Name,
            Active = false,
            Sections = {},
            HeaderHeight = 0,
            ResponsiveCallbacks = {},
            IsSettings = IsSettings,
            IsOverview = IsOverview,
            Page = nil,
            TabBtn = nil,
            TabLabel = nil
        }
        if not IsSettings and not IsOverview and self.CurrentTabCategory then
            table.insert(self.CurrentTabCategory.Tabs, Tab)
        end

        local TabBtn, TabEmoji, Indicator, TabGradient
        local tabBtnSize = IsMobile and 38 or 42

        if not IsSettings and not IsOverview then
            TabBtn = Utility:Create("TextButton", {
                Name = Name,
                Parent = TabContainer,
                BackgroundColor3 = Library.Theme.Accent,
                BackgroundTransparency = 0.64,
                Size = (IsMobile or isCompact) and UDim2.fromOffset(tabBtnSize, tabBtnSize) or UDim2.new(1, 0, 0, tabBtnSize),
                AutoButtonColor = false,
                Text = "",
                ZIndex = 5,
                LayoutOrder = self.NextNavOrder,
                BorderSizePixel = 0
            })
            Utility:RegisterProperty(TabBtn, "BackgroundColor3", "Accent")
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})
            local tabStroke = Utility:Create("UIStroke", {Parent = TabBtn, Color = Library.Theme.Stroke, Thickness = 1})
            Utility:RegisterProperty(tabStroke, "Color", "Stroke")
            TabGradient = Utility:Create("UIGradient", {Parent = TabBtn, Rotation = 18})
            Utility:RegisterGradient(TabGradient, "Accent", "Accent2", "Accent3")

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
            Tab.TabStroke = tabStroke
        elseif IsOverview then
            TabBtn = OverviewBtn
            TabEmoji = OverviewIcon
            Indicator = OverviewIndicator
            Tab.TabBtn = OverviewBtn
            Tab.TabLabel = OverviewLabel
            Tab.TabEmoji = TabEmoji
            Tab.Indicator = Indicator
            Tab.TabStroke = overviewStroke
        else
            TabEmoji = SettingsEmoji
            Indicator = SettingsIndicator
            Tab.TabBtn = SettingsBtn
            Tab.TabLabel = SettingsLabel
            Tab.TabEmoji = TabEmoji
            Tab.Indicator = Indicator
            Tab.TabStroke = settingsStroke
        end

        function Tab:ApplyNavigationLayout(mobile, compact, animated)
            if self.IsSettings or self.IsOverview or not self.TabBtn then return end
            local iconOnly = mobile or compact
            applyLayout(self.TabBtn, {
                Size = iconOnly and UDim2.fromOffset(tabBtnSize, tabBtnSize) or UDim2.new(1, 0, 0, tabBtnSize)
            }, animated)
            if self.TabEmoji then
                applyLayout(self.TabEmoji, {
                    Position = iconOnly and UDim2.fromScale(0.18, 0.18) or UDim2.fromOffset(6, 5),
                    Size = iconOnly and UDim2.fromScale(0.64, 0.64) or UDim2.fromOffset(32, 32)
                }, animated)
            end
            setNavigationLabel(self.TabLabel, not iconOnly, animated)
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
            Page.CanvasSize = UDim2.new(0, 0, 0, Tab.HeaderHeight + math.max(LeftH, RightH) + 20)
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
            LeftColumn.Position = UDim2.new(0, 0, 0, Tab.HeaderHeight)
            RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
            RightColumn.Position = UDim2.new(0.5, 6, 0, Tab.HeaderHeight)
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
            for _, callback in ipairs(Tab.ResponsiveCallbacks) do
                Utility:SafeCall(callback, mobile, Page.AbsoluteSize)
            end
        end

        function Tab:OnResponsive(callback)
            table.insert(self.ResponsiveCallbacks, callback)
            return self
        end

        function Tab:SetHeader(frame, height)
            frame.Parent = Page
            frame.LayoutOrder = -1000
            self.HeaderHeight = math.max(0, tonumber(height) or 0)
            LeftColumn.Position = UDim2.new(0, 0, 0, self.HeaderHeight)
            RightColumn.Position = UDim2.new(0.5, 6, 0, self.HeaderHeight)
            UpdateCanvas()
            return frame
        end

        function Tab:ApplyActiveVisual(active, animated)
            local tweenInfo = TweenInfo.new(animated == false and 0 or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            if Tab.TabBtn then
                Utility:Tween(Tab.TabBtn, tweenInfo, {BackgroundTransparency = active and 1 or 0.64})
            end
            if Tab.TabStroke then
                Utility:Tween(Tab.TabStroke, tweenInfo, {
                    Color = active and Library.Theme.Accent or Library.Theme.Stroke,
                    Transparency = active and 0.08 or 0.24
                })
            end
            if Tab.TabLabel then
                Utility:Tween(Tab.TabLabel, tweenInfo, {TextColor3 = active and Library.Theme.Text or Library.Theme.SubText})
            end
            if TabEmoji then
                if TabEmoji:IsA("TextLabel") then
                    Utility:Tween(TabEmoji, tweenInfo, {TextColor3 = active and Library.Theme.Text or Library.Theme.SubText})
                elseif TabEmoji:IsA("ImageLabel") then
                    Utility:Tween(TabEmoji, tweenInfo, {ImageColor3 = active and Library.Theme.Text or Library.Theme.SubText})
                end
            end
            if Indicator then Indicator.BackgroundTransparency = 1 end
        end

        function Tab:Activate(selectOptions)
            selectOptions = selectOptions or {}
            if selectOptions.ResetScroll == nil then selectOptions.ResetScroll = true end
            return Window:SelectTab(Tab, selectOptions)
        end

        function Tab:Deactivate()
            if Window.ActiveTab == Tab then return Window:SelectTab(nil) end
            return true
        end

        if TabBtn then
            Library:Connect(TabBtn.MouseButton1Click, function() Tab:Activate() end)
            Library:Connect(TabBtn.MouseEnter, function()
                if not Tab.Active then Utility:Tween(TabBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}) end
            end)
            Library:Connect(TabBtn.MouseLeave, function()
                if not Tab.Active then Utility:Tween(TabBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.64}) end
            end)
        end

        table.insert(Window.Tabs, Tab)
        Tab:ApplyResponsiveLayout(IsMobile, Window.ContentTopInset)
        if not IsSettings and not IsOverview and not Window.ActiveTab then
            Tab:Activate()
        end

