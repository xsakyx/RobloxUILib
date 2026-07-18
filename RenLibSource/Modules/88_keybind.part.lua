-- Module fragment: keybind picker
-- Generated from the working V7 baseline; edit this feature in isolation.
            -- KEYBIND PICKER
            function Section:CreateKeyPicker(options)
                options = options or {}
                local name = options.Name or "Keybind"
                local defaultKey = options.Default or "None"
                if typeof(defaultKey) == "EnumItem" then defaultKey = defaultKey.Name else defaultKey = tostring(defaultKey) end
                local mode = options.Mode or "Toggle"
                local callback = options.Callback or function() end
                local flag = options.Flag or name

                local currentKey = Library.Flags[flag] or defaultKey
                if typeof(currentKey) == "EnumItem" then currentKey = currentKey.Name else currentKey = tostring(currentKey) end
                local toggled = false
                local listening = false
                local keyHeld = false
                local keybindEntry = {name = name, key = currentKey, default = defaultKey, mode = mode, callback = callback, flag = flag}
                table.insert(Library.KeybindList, keybindEntry)
                Library.KeybindDefaults[flag] = defaultKey

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
                            keybindEntry.key = currentKey
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

                Library:Connect(UserInputService.InputBegan, function(input, processed)
                    if processed or listening or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if input.KeyCode.Name ~= currentKey then return end
                    if mode == "Hold" then
                        if keyHeld then return end
                        keyHeld = true
                        stateIndicator.Visible = true
                        Utility:SafeCall(callback, currentKey, true)
                    elseif mode == "Toggle" then
                        toggled = not toggled
                        stateIndicator.Visible = toggled
                        Utility:SafeCall(callback, currentKey, toggled)
                    else
                        Utility:SafeCall(callback, currentKey, true)
                    end
                end)
                Library:Connect(UserInputService.InputEnded, function(input)
                    if mode ~= "Hold" or input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode.Name ~= currentKey then return end
                    keyHeld = false
                    stateIndicator.Visible = false
                    Utility:SafeCall(callback, currentKey, false)
                end)

                addElement({Holder = container, Text = name})
                local controller = finishController({
                    Type = "KeyPicker",
                    Set = function(self, key)
                        currentKey = typeof(key) == "EnumItem" and key.Name or tostring(key)
                        keyBtn.Text = currentKey
                        Library.Flags[flag] = currentKey
                        keybindEntry.key = currentKey
                    end,
                    Get = function() return currentKey end,
                    GetKey = function() return currentKey end,
                    GetState = function() return toggled end
                }, container, name, options.Tooltip)
                Library.Flags[flag] = currentKey
                Library:RegisterOption(flag, controller)
                keybindEntry.controller = controller
                return controller
            end

