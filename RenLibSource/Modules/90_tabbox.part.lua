-- Module fragment: tabbox and advanced controls
-- Generated from the working V7 baseline; edit this feature in isolation.
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

    function Window:CreateDashboard(options)
        options = options or {}
        local dashboardTab = Window:CreateTab({
            Name = options.Name or "Overview",
            Icon = options.Icon or ICONS.Dashboard,
            IsOverview = options.IsNative == true
        })
        local heroHeight = IsMobile and 118 or 132
        local hero = Utility:Create("Frame", {
            Name = "DashboardHero", Parent = dashboardTab.Page,
            BackgroundColor3 = Library.Theme.Surface, BackgroundTransparency = 0,
            Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -4, 0, heroHeight),
            BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 3
        })
        Utility:RegisterProperty(hero, "BackgroundColor3", "Surface")
        Utility:RegisterMaterial(hero, 0.28, 0)
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 13), Parent = hero})
        local heroStroke = Utility:Create("UIStroke", {Parent = hero, Color = Library.Theme.Stroke, Thickness = 1})
        Utility:RegisterProperty(heroStroke, "Color", "Stroke")
        local heroGradient = Utility:Create("UIGradient", {Parent = hero, Rotation = 12})
        Utility:RegisterGradient(heroGradient, "SurfaceAlt", "Surface", "Main")
        local heroRail = Utility:Create("Frame", {
            Parent = hero, BackgroundColor3 = Library.Theme.Accent,
            Size = UDim2.new(1, 0, 0, 3), BorderSizePixel = 0, ZIndex = 4
        })
        Utility:RegisterProperty(heroRail, "BackgroundColor3", "Accent")
        local heroRailGradient = Utility:Create("UIGradient", {Parent = heroRail})
        Utility:RegisterGradient(heroRailGradient, "Accent", "Accent2", "Accent3")

        local avatar = Utility:Create("ImageLabel", {
            Parent = hero, BackgroundColor3 = Library.Theme.Main,
            Position = UDim2.fromOffset(20, 20), Size = UDim2.fromOffset(88, 88),
            Image = Utility:NormalizeAssetId(options.Avatar, ICONS.Profile),
            ScaleType = Enum.ScaleType.Crop, BorderSizePixel = 0, ZIndex = 5
        })
        Utility:RegisterProperty(avatar, "BackgroundColor3", "Main")
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 13), Parent = avatar})
        local avatarStroke = Utility:Create("UIStroke", {Parent = avatar, Color = Library.Theme.Accent, Thickness = 1})
        Utility:RegisterProperty(avatarStroke, "Color", "Accent")

        local greeting = Utility:Create("TextLabel", {
            Parent = hero, BackgroundTransparency = 1, Position = UDim2.fromOffset(128, 31),
            Size = UDim2.new(1, -156, 0, 30), Font = Enum.Font.GothamBold,
            Text = tostring(options.Greeting or ("Welcome, " .. (Plr.DisplayName or Plr.Name))),
            TextColor3 = Library.Theme.Text, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5
        })
        Utility:RegisterProperty(greeting, "TextColor3", "Text")
        local subtitle = Utility:Create("TextLabel", {
            Parent = hero, BackgroundTransparency = 1, Position = UDim2.fromOffset(128, 63),
            Size = UDim2.new(1, -156, 0, 22), Font = Enum.Font.Gotham,
            Text = tostring(options.Subtitle or ("Your control center · @" .. Plr.Name)),
            TextColor3 = Library.Theme.SubText, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5
        })
        Utility:RegisterProperty(subtitle, "TextColor3", "SubText")
        if not Utility:NormalizeAssetId(options.Avatar) then
            task.spawn(function()
                local ok, image = pcall(function()
                    return Players:GetUserThumbnailAsync(tonumber(options.UserId) or Plr.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size180x180)
                end)
                if ok and avatar.Parent then avatar.Image = image end
            end)
        end

        dashboardTab:SetHeader(hero, heroHeight + 12)
        dashboardTab:OnResponsive(function(mobile)
            heroHeight = mobile and 112 or 132
            hero.Size = UDim2.new(1, -4, 0, heroHeight)
            avatar.Position = mobile and UDim2.fromOffset(14, 20) or UDim2.fromOffset(20, 20)
            avatar.Size = mobile and UDim2.fromOffset(58, 58) or UDim2.fromOffset(88, 88)
            greeting.Position = mobile and UDim2.fromOffset(84, 24) or UDim2.fromOffset(128, 31)
            greeting.Size = mobile and UDim2.new(1, -98, 0, 26) or UDim2.new(1, -156, 0, 30)
            greeting.TextSize = mobile and 17 or 22
            subtitle.Position = mobile and UDim2.fromOffset(84, 51) or UDim2.fromOffset(128, 63)
            subtitle.Size = mobile and UDim2.new(1, -98, 0, 34) or UDim2.new(1, -156, 0, 22)
            subtitle.TextWrapped = mobile
            dashboardTab:SetHeader(hero, heroHeight + 12)
        end)

        local dashboard = {Tab = dashboardTab, Hero = hero, Cards = {}}
        function dashboard:AddCard(cardOptions)
            cardOptions = cardOptions or {}
            local section = dashboardTab:CreateSection({
                Name = cardOptions.Name or "Card",
                Side = cardOptions.Side or "Auto",
                Icon = cardOptions.Icon
            })
            if cardOptions.Description then
                section:CreateParagraph({Content = cardOptions.Description})
            end
            for _, metric in ipairs(cardOptions.Metrics or {}) do
                section:CreateMetric(metric)
            end
            if cardOptions.Action then
                section:CreateButton({
                    Name = cardOptions.Action.Name or "Open",
                    Description = cardOptions.Action.Description,
                    Icon = cardOptions.Action.Icon,
                    Callback = cardOptions.Action.Callback
                })
            end
            table.insert(self.Cards, section)
            return section
        end
        function dashboard:SetGreeting(text) greeting.Text = tostring(text) end
        function dashboard:SetSubtitle(text) subtitle.Text = tostring(text) end
        function dashboard:SetAvatar(asset) avatar.Image = Utility:NormalizeAssetId(asset, avatar.Image) end
        for _, card in ipairs(options.Cards or {}) do dashboard:AddCard(card) end
        return dashboard
    end

    -- Native Overview is always available directly above UI Settings. It is
