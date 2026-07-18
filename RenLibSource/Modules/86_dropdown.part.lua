-- Module fragment: dropdown controls
-- Generated from the working V7 baseline; edit this feature in isolation.
            -- DROPDOWN
            function Section:CreateDropdown(options)
                options = options or {}
                local Name = options.Name or "Dropdown"
                local Values = options.Values or {}
                local Multi = options.Multi or false
                local Default = options.Default or (Multi and {} or Values[1])
                local Callback = options.Callback or function() end
                local Flag = options.Flag or Name

                local function normalizeMulti(value)
                    if not Multi then return value end
                    local normalized = {}
                    if type(value) == "table" then
                        for key, selected in pairs(value) do
                            if type(key) == "number" then
                                normalized[selected] = true
                            elseif selected == true then
                                normalized[key] = true
                            end
                        end
                    end
                    return normalized
                end

                local CurrentValue = normalizeMulti(Default)
                if Library.Flags[Flag] ~= nil then CurrentValue = Library.Flags[Flag] end
                CurrentValue = normalizeMulti(CurrentValue)
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
                Utility:RegisterMaterial(ListFrame, 0.24, 0)
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

                local function UpdateStatus()
                    if Multi then
                        local selected = {}
                        for _, optionValue in ipairs(Values) do
                            if CurrentValue[optionValue] then table.insert(selected, tostring(optionValue)) end
                        end
                        if #selected == 0 then
                            Status.Text = "None selected"
                        elseif #selected <= 2 then
                            Status.Text = table.concat(selected, ", ")
                        else
                            Status.Text = selected[1] .. ", " .. selected[2] .. " +" .. tostring(#selected - 2)
                        end
                    else
                        Status.Text = CurrentValue ~= nil and tostring(CurrentValue) or "No options"
                    end
                end

                local function Refresh()
                    UpdateStatus()
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
                            Text = "",
                            ZIndex = 21,
                            BorderSizePixel = 0
                        })
                        Utility:RegisterProperty(Item, "BackgroundColor3", "SurfaceAlt")
                        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Item})
                        local IsSelected = Multi and CurrentValue[val] or (not Multi and CurrentValue == val)
                        local itemText = Utility:Create("TextLabel", {
                            Parent = Item, BackgroundTransparency = 1, Position = UDim2.fromOffset(9, 0),
                            Size = UDim2.new(1, -38, 1, 0), Text = tostring(val),
                            TextColor3 = IsSelected and Library.Theme.Text or Library.Theme.SubText,
                            Font = Enum.Font.Gotham, TextSize = IsMobile and 12 or 13,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 22
                        })
                        Utility:RegisterProperty(itemText, "TextColor3", IsSelected and "Text" or "SubText")
                        local checkIcon = Utility:Create("ImageLabel", {
                            Parent = Item, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0.5, -7),
                            Size = UDim2.fromOffset(14, 14), Image = ICONS.Check,
                            ImageColor3 = Library.Theme.Accent, ImageTransparency = IsSelected and 0 or 1,
                            ScaleType = Enum.ScaleType.Fit, ZIndex = 22
                        })
                        Utility:RegisterProperty(checkIcon, "ImageColor3", "Accent")
                        if IsSelected then
                            Item.BackgroundTransparency = 0.08
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
                UpdateStatus()
                addElement({Holder = DropdownContainer, Text = Name})

                local dropObj = {
                    Type = "Dropdown",
                    Set = function(self, val)
                        CurrentValue = normalizeMulti(val)
                        Refresh()
                        BuildList()
                    end,
                    Refresh = function(self, newVals, preserveSelection)
                        Values = type(newVals) == "table" and newVals or {}
                        if not Multi then
                            local stillExists = false
                            for _, optionValue in ipairs(Values) do
                                if optionValue == CurrentValue then stillExists = true break end
                            end
                            if not stillExists and preserveSelection ~= true then CurrentValue = Values[1] end
                        end
                        Refresh()
                        BuildList()
                    end,
                    Get = function() return CurrentValue end,
                    GetList = function()
                        local selected = {}
                        if Multi then
                            for _, value in ipairs(Values) do if CurrentValue[value] then table.insert(selected, value) end end
                        elseif CurrentValue ~= nil then
                            table.insert(selected, CurrentValue)
                        end
                        return selected
                    end,
                    Clear = function(self)
                        if Multi then CurrentValue = {} else CurrentValue = nil end
                        Refresh(); BuildList()
                    end,
                    SelectAll = function(self)
                        if Multi then
                            CurrentValue = {}
                            for _, value in ipairs(Values) do CurrentValue[value] = true end
                            Refresh(); BuildList()
                        end
                    end,
                    OnChanged = function(self, fn)
                        table.insert(changeListeners, fn)
                    end,
                    SetExpanded = function(self, open) SetExpanded(open) end
                }
                finishController(dropObj, DropdownContainer, Name, options.Tooltip)
                Library:RegisterOption(Flag, dropObj)
                return dropObj
            end

            function Section:CreateMultiDropdown(options)
                options = options or {}
                options.Multi = true
                return self:CreateDropdown(options)
            end

