-- Module fragment: text input control
-- Generated from the working V7 baseline; edit this feature in isolation.
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
                }, container, name, options.Tooltip)
                Library:RegisterOption(flag, controller)
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
                }, container, title, options.Tooltip)
                addElement({Holder = container, Text = title .. " " .. content})
                task.defer(resize)
                return controller
            end

            function Section:CreateMetric(options)
                options = options or {}
                local name = tostring(options.Name or "Metric")
                local value = tostring(options.Value or "--")
                local detail = tostring(options.Detail or "")
                local container = Utility:Create("Frame", {
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, detail ~= "" and 54 or 42),
                    BorderSizePixel = 0,
                    ZIndex = 5
                })
                Utility:RegisterProperty(container, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = container})
                local accent = Utility:Create("Frame", {
                    Parent = container, BackgroundColor3 = Library.Theme.Accent,
                    Position = UDim2.new(0, 0, 0, 8), Size = UDim2.new(0, 3, 1, -16),
                    BorderSizePixel = 0, ZIndex = 6
                })
                Utility:RegisterProperty(accent, "BackgroundColor3", "Accent")
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = accent})
                local nameLabel = Utility:Create("TextLabel", {
                    Parent = container, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 5),
                    Size = UDim2.new(0.62, -12, 0, 20), Text = name, TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.GothamMedium, TextSize = IsMobile and 11 or 12,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6
                })
                Utility:RegisterProperty(nameLabel, "TextColor3", "Text")
                local valueLabel = Utility:Create("TextLabel", {
                    Parent = container, BackgroundTransparency = 1, Position = UDim2.new(0.62, 0, 0, 5),
                    Size = UDim2.new(0.38, -12, 0, 20), Text = value, TextColor3 = Library.Theme.Accent,
                    Font = Enum.Font.GothamBold, TextSize = IsMobile and 12 or 14,
                    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 6
                })
                Utility:RegisterProperty(valueLabel, "TextColor3", "Accent")
                local detailLabel
                if detail ~= "" then
                    detailLabel = Utility:Create("TextLabel", {
                        Parent = container, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 27),
                        Size = UDim2.new(1, -24, 0, 17), Text = detail, TextColor3 = Library.Theme.SubText,
                        Font = Enum.Font.Gotham, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6
                    })
                    Utility:RegisterProperty(detailLabel, "TextColor3", "SubText")
                end
                local controller = finishController({
                    Type = "Metric",
                    SetValue = function(self, nextValue) valueLabel.Text = tostring(nextValue) end,
                    SetDetail = function(self, nextDetail) if detailLabel then detailLabel.Text = tostring(nextDetail) end end
                }, container, name, options.Tooltip)
                addElement({Holder = container, Text = name .. " " .. value .. " " .. detail})
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

