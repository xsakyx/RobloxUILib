-- Module fragment: slider control
-- Generated from the working V7 baseline; edit this feature in isolation.
            -- SLIDER
            function Section:CreateSlider(options)
                options = options or {}
                local Name = options.Name or "Slider"
                local Min = options.Min or 0
                local Max = options.Max or 100
                local Default = options.Default or Min
                local Callback = options.Callback or function() end
                local Flag = options.Flag or Name
                local Step = math.max(tonumber(options.Step) or 1, 0.000001)
                local CallbackMode = options.CallbackMode or (options.CallbackOnRelease and "Release" or "Changed")

                local Value = Default
                if Library.Flags[Flag] ~= nil then Value = Library.Flags[Flag] end
                Library.Flags[Flag] = Value

                local sliderHeight = IsMobile and 44 or 50
                local SliderContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, sliderHeight),
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                Utility:RegisterProperty(SliderContainer, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SliderContainer})
                local stroke = Utility:Create("UIStroke", {Parent = SliderContainer, Color = Library.Theme.Stroke, Thickness = 1})
                Utility:RegisterProperty(stroke, "Color", "Stroke")

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
                    BackgroundColor3 = Library.Theme.SurfaceAlt,
                    Position = UDim2.new(0, 12, 0, IsMobile and 28 or 34),
                    Size = UDim2.new(1, -24, 0, trackHeight),
                    AutoButtonColor = false,
                    Text = "",
                    ZIndex = 6,
                    BorderSizePixel = 0
                })
                Utility:RegisterProperty(Track, "BackgroundColor3", "SurfaceAlt")
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})
                local Fill = Utility:Create("Frame", {
                    Parent = Track,
                    BackgroundColor3 = Library.Theme.Accent,
                    Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
                    BorderSizePixel = 0,
                    ZIndex = 7
                })
                Utility:RegisterProperty(Fill, "BackgroundColor3", "Accent")
                local fillGradient = Utility:Create("UIGradient", {Parent = Fill})
                Utility:RegisterGradient(fillGradient, "Accent", "Accent2", "Accent3")
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})
                local Dragging = false
                local DragInput = nil
                local pendingCallback = false

                local function EmitValue()
                    pendingCallback = false
                    Utility:SafeCall(Callback, Value)
                end

                local function UpdateSlider(input)
                    local SizeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / math.max(1, Track.AbsoluteSize.X), 0, 1)
                    local NewValue = Min + ((Max - Min) * SizeX)
                    NewValue = math.clamp(Min + math.floor(((NewValue - Min) / Step) + 0.5) * Step, Min, Max)
                    Value = NewValue
                    ValueLabel.Text = tostring(Value)
                    Library.Flags[Flag] = Value
                    pendingCallback = true
                    if CallbackMode ~= "Release" then EmitValue() end
                    Utility:Tween(Fill, TweenInfo.new(0.05), {Size = UDim2.new((Value - Min) / math.max(0.000001, Max - Min), 0, 1, 0)})
                end

                Library:Connect(Track.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        DragInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
                        UpdateSlider(input)
                    end
                end)
                Library:Connect(UserInputService.InputChanged, function(input)
                    local pointerMove = input.UserInputType == Enum.UserInputType.MouseMovement
                        or (input.UserInputType == Enum.UserInputType.Touch and input == DragInput)
                    if Dragging and pointerMove then
                        UpdateSlider(input)
                    end
                end)
                Library:Connect(UserInputService.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local wasDragging = Dragging
                        Dragging = false
                        if wasDragging and pendingCallback then task.defer(EmitValue) end
                        if wasDragging and options.Finished then task.defer(function() Utility:SafeCall(options.Finished, Value) end) end
                    end
                end)

                addElement({Holder = SliderContainer, Text = Name})
                local function SetValue(val, fire)
                    Value = math.clamp(tonumber(val) or Min, Min, Max)
                    ValueLabel.Text = tostring(Value)
                    Library.Flags[Flag] = Value
                    Utility:Tween(Fill, TweenInfo.new(0.1), {Size = UDim2.new((Value - Min) / math.max(0.000001, Max - Min), 0, 1, 0)})
                    pendingCallback = false
                    if fire ~= false then EmitValue() end
                end
                local sliderObj = {
                    Type = "Slider",
                    Set = function(self, val)
                        SetValue(val, true)
                    end,
                    SetSilent = function(self, val) SetValue(val, false) end,
                    Get = function() return Value end
                }
                finishController(sliderObj, SliderContainer, Name, options.Tooltip)
                Library:RegisterOption(Flag, sliderObj)
                return sliderObj
            end

