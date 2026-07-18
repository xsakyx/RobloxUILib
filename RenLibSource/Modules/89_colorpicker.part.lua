-- Module fragment: color picker
-- Generated from the working V7 baseline; edit this feature in isolation.
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
                    if Capabilities:SetClipboard(colorDisplay.Text) then
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
                }, container, name, options.Tooltip)
                Library:RegisterOption(flag, controller)
                return controller
            end

            function Section:CreateGroup(options)
                if type(options) == "string" then options = {Name = options} end
                options = options or {}
                local name = tostring(options.Name or "Group")
                local expanded = options.Expanded ~= false
                local headerHeight = IsMobile and 38 or 42
                local container = Utility:Create("Frame", {
                    Name = "Group_" .. name, Parent = ContentContainer, BackgroundColor3 = Library.Theme.Secondary,
                    Size = UDim2.new(1, 0, 0, headerHeight), ClipsDescendants = true,
                    BorderSizePixel = 0, ZIndex = 5
                })
                Utility:RegisterProperty(container, "BackgroundColor3", "Secondary")
                Utility:RegisterMaterial(container, 0.42, 0.08)
                Utility:Create("UICorner", {Parent = container, CornerRadius = UDim.new(0, 8)})
                local groupStroke = Utility:Create("UIStroke", {Parent = container, Color = Library.Theme.Divider, Thickness = 1})
                Utility:RegisterProperty(groupStroke, "Color", "Divider")
                local header = Utility:Create("TextButton", {
                    Parent = container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, headerHeight),
                    Text = "", AutoButtonColor = false, ZIndex = 6
                })
                local title = Utility:Create("TextLabel", {
                    Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(1, -48, 1, 0), Text = name, TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7
                })
                Utility:RegisterProperty(title, "TextColor3", "Text")
                local chevron = Utility:Create("ImageLabel", {
                    Parent = header, BackgroundTransparency = 1, Position = UDim2.new(1, -28, 0.5, -7),
                    Size = UDim2.fromOffset(14, 14), Image = ICONS.ChevronDown,
                    ImageColor3 = Library.Theme.SubText, Rotation = expanded and 0 or -90, ZIndex = 7
                })
                Utility:RegisterProperty(chevron, "ImageColor3", "SubText")
                local body = Utility:Create("Frame", {
                    Parent = container, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, headerHeight),
                    Size = UDim2.new(1, 0, 0, 0), Visible = expanded, ZIndex = 6
                })
                Utility:Create("UIPadding", {
                    Parent = body, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
                    PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8)
                })
                local bodyLayout = Utility:Create("UIListLayout", {Parent = body, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder})
                local function refresh()
                    local bodyHeight = expanded and bodyLayout.AbsoluteContentSize.Y + 12 or 0
                    body.Visible = expanded
                    body.Size = UDim2.new(1, 0, 0, bodyHeight)
                    Utility:Tween(container, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, headerHeight + bodyHeight)
                    })
                    Utility:Tween(chevron, TweenInfo.new(0.2), {Rotation = expanded and 0 or -90})
                    RefreshLayout()
                end
                Library:Connect(bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"), refresh)
                addElement({Holder = container, Text = name})
                local group = finishController({Type = "Group"}, container, name, options.Tooltip)
                function group:SetExpanded(value) expanded = value == true refresh() return self end
                function group:Toggle() return self:SetExpanded(not expanded) end
                function group:IsExpanded() return expanded end
                function group:SetTitle(value) name = tostring(value); title.Text = name; self.Name = name return self end
                local function attach(method, value)
                    local controller = Section[method](Section, value)
                    if controller and controller.Holder then
                        controller.Holder.Parent = body
                        for _, element in ipairs(Section.Elements) do
                            if element.Holder == controller.Holder then element.NestedParentHolder = container break end
                        end
                        Library:Connect(controller.Holder:GetPropertyChangedSignal("Size"), refresh)
                        task.defer(refresh)
                    end
                    return controller
                end
                function group:CreateButton(value) return attach("CreateButton", value) end
                function group:CreateToggle(value) return attach("CreateToggle", value) end
                function group:CreateSlider(value) return attach("CreateSlider", value) end
                function group:CreateDropdown(value) return attach("CreateDropdown", value) end
                function group:CreateMultiDropdown(value) return attach("CreateMultiDropdown", value) end
                function group:CreateInput(value) return attach("CreateInput", value) end
                function group:CreateParagraph(value) return attach("CreateParagraph", value) end
                function group:CreateMetric(value) return attach("CreateMetric", value) end
                function group:CreateKeyPicker(value) return attach("CreateKeyPicker", value) end
                function group:CreateColorPicker(value) return attach("CreateColorPicker", value) end
                function group:CreateImage(value) return attach("CreateImage", value) end
                function group:CreateLabel(value) return attach("CreateLabel", value) end
                function group:CreateDivider(value) return attach("CreateDivider", value) end
                function group:CreateGroup(value) return attach("CreateGroup", value) end
                function group:CreateList(value) return attach("CreateList", value) end
                function group:CreateTable(value) return attach("CreateTable", value) end
                function group:CreatePlayerList(value) return attach("CreatePlayerList", value) end
                function group:CreateLogConsole(value) return attach("CreateLogConsole", value) end
                function group:CreateSkeleton(value) return attach("CreateSkeleton", value) end
                Library:Connect(header.MouseButton1Click, function() group:Toggle() end)
                task.defer(refresh)
                return group
            end

            function Section:CreateList(options)
                options = options or {}
                local name = tostring(options.Name or "List")
                local items = type(options.Items) == "table" and options.Items or {}
                local selected = options.Default
                local container = Utility:Create("Frame", {
                    Parent = ContentContainer, BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, tonumber(options.Height) or 176),
                    BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 5
                })
                Utility:RegisterProperty(container, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {Parent = container, CornerRadius = UDim.new(0, 7)})
                local stroke = Utility:Create("UIStroke", {Parent = container, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(stroke, "Color", "Stroke")
                local title = Utility:Create("TextLabel", {
                    Parent = container, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 5),
                    Size = UDim2.new(1, -20, 0, 24), Text = name, TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6
                })
                Utility:RegisterProperty(title, "TextColor3", "Text")
                local list = Utility:Create("ScrollingFrame", {
                    Parent = container, BackgroundTransparency = 1, Position = UDim2.fromOffset(7, 32),
                    Size = UDim2.new(1, -14, 1, -39), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent, BorderSizePixel = 0, ZIndex = 6
                })
                Utility:RegisterProperty(list, "ScrollBarImageColor3", "Accent")
                Utility:Create("UIListLayout", {Parent = list, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
                local controller
                local function parts(item)
                    if type(item) == "table" then return tostring(item.Label or item.Name or item.Value or "Item"), item.Value ~= nil and item.Value or item, item.Description end
                    return tostring(item), item, nil
                end
                local function render()
                    for _, child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
                    for index, item in ipairs(items) do
                        local labelText, value, description = parts(item)
                        local row = Utility:Create("TextButton", {
                            Parent = list, BackgroundColor3 = Library.Theme.Secondary,
                            BackgroundTransparency = value == selected and 0 or 0.24,
                            Size = UDim2.new(1, -4, 0, description and 44 or 34), Text = "",
                            AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = index, ZIndex = 7
                        })
                        Utility:RegisterProperty(row, "BackgroundColor3", value == selected and "Accent" or "Secondary")
                        Utility:Create("UICorner", {Parent = row, CornerRadius = UDim.new(0, 5)})
                        local label = Utility:Create("TextLabel", {
                            Parent = row, BackgroundTransparency = 1, Position = UDim2.fromOffset(9, description and 4 or 0),
                            Size = UDim2.new(1, -18, 0, description and 20 or 34), Text = labelText,
                            TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8
                        })
                        Utility:RegisterProperty(label, "TextColor3", "Text")
                        if description then
                            local detail = Utility:Create("TextLabel", {
                                Parent = row, BackgroundTransparency = 1, Position = UDim2.fromOffset(9, 22),
                                Size = UDim2.new(1, -18, 0, 16), Text = tostring(description), TextColor3 = Library.Theme.SubText,
                                Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8
                            })
                            Utility:RegisterProperty(detail, "TextColor3", "SubText")
                        end
                        Library:Connect(row.MouseButton1Click, function()
                            selected = value
                            render()
                            Utility:SafeCall(options.Callback, value, item, index)
                        end)
                    end
                end
                addElement({Holder = container, Text = name})
                controller = finishController({Type = "List"}, container, name, options.Tooltip)
                function controller:SetItems(nextItems) items = type(nextItems) == "table" and nextItems or {} render() return self end
                function controller:GetItems() return items end
                function controller:Add(item) table.insert(items, item) render() return self end
                function controller:Remove(value)
                    for index, item in ipairs(items) do local _, itemValue = parts(item) if itemValue == value then table.remove(items, index) break end end
                    if selected == value then selected = nil end render() return self
                end
                function controller:Clear() table.clear(items) selected = nil render() return self end
                function controller:Select(value) selected = value render() return self end
                function controller:GetSelected() return selected end
                render()
                return controller
            end

            function Section:CreateTable(options)
                options = options or {}
                local name = tostring(options.Name or "Table")
                local columns = type(options.Columns) == "table" and options.Columns or {{Key = "value", Name = "Value"}}
                local rows = type(options.Rows) == "table" and options.Rows or {}
                local container = Utility:Create("Frame", {
                    Parent = ContentContainer, BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, tonumber(options.Height) or 196), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 5
                })
                Utility:RegisterProperty(container, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {Parent = container, CornerRadius = UDim.new(0, 7)})
                local title = Utility:Create("TextLabel", {
                    Parent = container, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -20, 0, 24),
                    Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6
                })
                Utility:RegisterProperty(title, "TextColor3", "Text")
                local header = Utility:Create("Frame", {Parent = container, BackgroundColor3 = Library.Theme.Secondary, Position = UDim2.fromOffset(7, 30), Size = UDim2.new(1, -14, 0, 28), BorderSizePixel = 0, ZIndex = 6})
                Utility:RegisterProperty(header, "BackgroundColor3", "Secondary")
                Utility:Create("UICorner", {Parent = header, CornerRadius = UDim.new(0, 5)})
                local list = Utility:Create("ScrollingFrame", {
                    Parent = container, BackgroundTransparency = 1, Position = UDim2.fromOffset(7, 63), Size = UDim2.new(1, -14, 1, -70),
                    CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Library.Theme.Accent, BorderSizePixel = 0, ZIndex = 6
                })
                Utility:RegisterProperty(list, "ScrollBarImageColor3", "Accent")
                Utility:Create("UIListLayout", {Parent = list, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
                local function cell(parent, text, index, count, bold)
                    local label = Utility:Create("TextLabel", {
                        Parent = parent, BackgroundTransparency = 1, Position = UDim2.new((index - 1) / count, 7, 0, 0),
                        Size = UDim2.new(1 / count, -12, 1, 0), Text = tostring(text or ""), TextColor3 = bold and Library.Theme.Text or Library.Theme.SubText,
                        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham, TextSize = bold and 10 or 11,
                        TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = parent.ZIndex + 1
                    })
                    Utility:RegisterProperty(label, "TextColor3", bold and "Text" or "SubText")
                end
                local function render()
                    for _, child in ipairs(header:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
                    for index, column in ipairs(columns) do cell(header, column.Name or column.Label or column.Key or index, index, #columns, true) end
                    for _, child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
                    for rowIndex, rowData in ipairs(rows) do
                        local row = Utility:Create("Frame", {Parent = list, BackgroundColor3 = Library.Theme.Secondary, BackgroundTransparency = 0.3, Size = UDim2.new(1, -4, 0, 30), BorderSizePixel = 0, LayoutOrder = rowIndex, ZIndex = 7})
                        Utility:RegisterProperty(row, "BackgroundColor3", "Secondary")
                        Utility:Create("UICorner", {Parent = row, CornerRadius = UDim.new(0, 4)})
                        for columnIndex, column in ipairs(columns) do
                            local key = column.Key or column.Field or columnIndex
                            cell(row, type(rowData) == "table" and rowData[key] or rowData, columnIndex, #columns, false)
                        end
                    end
                end
                addElement({Holder = container, Text = name})
                local controller = finishController({Type = "Table"}, container, name, options.Tooltip)
                function controller:SetRows(nextRows) rows = type(nextRows) == "table" and nextRows or {} render() return self end
                function controller:SetColumns(nextColumns) columns = type(nextColumns) == "table" and nextColumns or columns render() return self end
                function controller:AddRow(row) table.insert(rows, row) render() return self end
                function controller:Clear() table.clear(rows) render() return self end
                function controller:GetRows() return rows end
                render()
                return controller
            end

            function Section:CreatePlayerList(options)
                options = options or {}
                local listOptions = {}
                for key, value in pairs(options) do listOptions[key] = value end
                listOptions.Name = options.Name or "Players"
                local userCallback = options.Callback
                listOptions.Callback = function(player) Utility:SafeCall(userCallback, player) end
                local controller = self:CreateList(listOptions)
                controller.Type = "PlayerList"
                local function refreshPlayers()
                    local values = {}
                    for _, player in ipairs(Players:GetPlayers()) do
                        table.insert(values, {Label = player.DisplayName, Description = "@" .. player.Name, Value = player})
                    end
                    table.sort(values, function(a, b) return a.Label:lower() < b.Label:lower() end)
                    controller:SetItems(values)
                end
                Library:Connect(Players.PlayerAdded, function() task.defer(refreshPlayers) end)
                Library:Connect(Players.PlayerRemoving, function() task.defer(refreshPlayers) end)
                refreshPlayers()
                return controller
            end

            function Section:CreateLogConsole(options)
                options = options or {}
                local name = tostring(options.Name or "Console")
                local maxLines = math.max(10, tonumber(options.MaxLines) or 150)
                local entries = {}
                local container = Utility:Create("Frame", {
                    Parent = ContentContainer, BackgroundColor3 = Library.Theme.Main,
                    Size = UDim2.new(1, 0, 0, tonumber(options.Height) or 190), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 5
                })
                Utility:RegisterProperty(container, "BackgroundColor3", "Main")
                Utility:Create("UICorner", {Parent = container, CornerRadius = UDim.new(0, 7)})
                local title = Utility:Create("TextLabel", {Parent = container, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -78, 0, 24), Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6})
                Utility:RegisterProperty(title, "TextColor3", "Text")
                local clearButton = Utility:Create("TextButton", {Parent = container, BackgroundTransparency = 1, Position = UDim2.new(1, -64, 0, 4), Size = UDim2.fromOffset(54, 24), Text = "Clear", TextColor3 = Library.Theme.SubText, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false, ZIndex = 7})
                Utility:RegisterProperty(clearButton, "TextColor3", "SubText")
                local output = Utility:Create("ScrollingFrame", {Parent = container, BackgroundColor3 = Library.Theme.Secondary, BackgroundTransparency = 0.25, Position = UDim2.fromOffset(7, 31), Size = UDim2.new(1, -14, 1, -38), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent, BorderSizePixel = 0, ZIndex = 6})
                Utility:RegisterProperty(output, "BackgroundColor3", "Secondary")
                Utility:RegisterProperty(output, "ScrollBarImageColor3", "Accent")
                Utility:Create("UIPadding", {Parent = output, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)})
                Utility:Create("UIListLayout", {Parent = output, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder})
                local function render()
                    for _, child in ipairs(output:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
                    for index, entry in ipairs(entries) do
                        local semantic = entry.Level == "Error" and "Error" or entry.Level == "Warn" and "Warn" or entry.Level == "Success" and "Success" or "SubText"
                        local line = Utility:Create("TextLabel", {Parent = output, BackgroundTransparency = 1, Size = UDim2.new(1, -4, 0, 16), AutomaticSize = Enum.AutomaticSize.Y, Text = "[" .. entry.Level .. "] " .. entry.Text, TextColor3 = Library.Theme[semantic], Font = Enum.Font.Code, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = index, ZIndex = 7})
                        Utility:RegisterProperty(line, "TextColor3", semantic)
                    end
                    task.defer(function() output.CanvasPosition = Vector2.new(0, math.max(0, output.AbsoluteCanvasSize.Y)) end)
                end
                addElement({Holder = container, Text = name})
                local controller = finishController({Type = "LogConsole"}, container, name, options.Tooltip)
                function controller:Write(text, level)
                    table.insert(entries, {Text = tostring(text), Level = tostring(level or "Info")})
                    while #entries > maxLines do table.remove(entries, 1) end
                    render() return self
                end
                function controller:Log(text) return self:Write(text, "Info") end
                function controller:Warn(text) return self:Write(text, "Warn") end
                function controller:Error(text) return self:Write(text, "Error") end
                function controller:Success(text) return self:Write(text, "Success") end
                function controller:Clear() table.clear(entries) render() return self end
                function controller:GetEntries() return entries end
                Library:Connect(clearButton.MouseButton1Click, function() controller:Clear() end)
                for _, entry in ipairs(options.Entries or {}) do controller:Write(entry.Text or entry[1] or entry, entry.Level or entry[2]) end
                return controller
            end

            function Section:CreateSkeleton(options)
                options = options or {}
                local lineCount = math.clamp(tonumber(options.Lines) or 3, 1, 8)
                local container = Utility:Create("Frame", {Parent = ContentContainer, BackgroundColor3 = Library.Theme.Surface, Size = UDim2.new(1, 0, 0, 22 + lineCount * 18), BorderSizePixel = 0, ZIndex = 5})
                Utility:RegisterProperty(container, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {Parent = container, CornerRadius = UDim.new(0, 7)})
                local bars = {}
                for index = 1, lineCount do
                    local bar = Utility:Create("Frame", {Parent = container, BackgroundColor3 = Library.Theme.Hover, BackgroundTransparency = 0.15, Position = UDim2.new(0, 10, 0, 10 + (index - 1) * 18), Size = UDim2.new(index == lineCount and 0.62 or 1, index == lineCount and -10 or -20, 0, 10), BorderSizePixel = 0, ZIndex = 6})
                    Utility:RegisterProperty(bar, "BackgroundColor3", "Hover")
                    Utility:Create("UICorner", {Parent = bar, CornerRadius = UDim.new(1, 0)})
                    table.insert(bars, bar)
                end
                addElement({Holder = container, Text = tostring(options.Name or "Loading placeholder")})
                local controller = finishController({Type = "Skeleton"}, container, options.Name or "Skeleton")
                local animationToken = 1
                task.spawn(function()
                    local bright = false
                    while animationToken == 1 and container.Parent and not Library.Unloaded do
                        bright = not bright
                        for _, bar in ipairs(bars) do Utility:Tween(bar, TweenInfo.new(0.55), {BackgroundTransparency = bright and 0.48 or 0.15}) end
                        task.wait(0.62)
                    end
                end)
                local destroy = controller.Destroy
                function controller:Destroy() animationToken = 0 destroy(self) end
                return controller
            end

