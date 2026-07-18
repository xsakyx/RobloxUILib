-- Module fragment: button control
-- Generated from the working V7 baseline; edit this feature in isolation.
            -- BUTTON
            function Section:CreateButton(options)
                options = options or {}
                local Name = options.Name or "Button"
                local Callback = options.Callback or function() end
                local Description = tostring(options.Description or "")
                local ButtonIconAsset = Utility:NormalizeAssetId(options.Icon)

                local btnHeight = Description ~= "" and (IsMobile and 56 or 54) or (IsMobile and 44 or 42)
                local ButtonContainer = Utility:Create("Frame", {
                    Name = Name,
                    Parent = ContentContainer,
                    BackgroundColor3 = Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, btnHeight),
                    ClipsDescendants = true,
                    ZIndex = 5,
                    BorderSizePixel = 0
                })
                Utility:RegisterProperty(ButtonContainer, "BackgroundColor3", "Surface")
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ButtonContainer})
                local Stroke = Utility:Create("UIStroke", {
                    Parent = ButtonContainer,
                    Color = Library.Theme.Stroke,
                    Thickness = 1
                })
                Utility:RegisterProperty(Stroke, "Color", "Stroke")

                local Btn = Utility:Create("TextButton", {
                    Parent = ButtonContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 9,
                    BorderSizePixel = 0
                })

                local textInset = ButtonIconAsset and 44 or 12
                if ButtonIconAsset then
                    local ButtonIcon = Utility:Create("ImageLabel", {
                        Parent = ButtonContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0.5, -10),
                        Size = UDim2.fromOffset(20, 20),
                        Image = ButtonIconAsset,
                        ImageColor3 = Library.Theme.SubText,
                        ScaleType = Enum.ScaleType.Fit,
                        ZIndex = 7
                    })
                    Utility:RegisterProperty(ButtonIcon, "ImageColor3", "SubText")
                end
                local ButtonTitle = Utility:Create("TextLabel", {
                    Parent = ButtonContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, textInset, 0, Description ~= "" and 7 or 0),
                    Size = UDim2.new(1, -(textInset + 32), 0, Description ~= "" and 20 or btnHeight),
                    Font = Enum.Font.GothamMedium,
                    Text = Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7
                })
                Utility:RegisterProperty(ButtonTitle, "TextColor3", "Text")
                local ButtonDescription
                if Description ~= "" then
                    ButtonDescription = Utility:Create("TextLabel", {
                        Parent = ButtonContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, textInset, 0, 27),
                        Size = UDim2.new(1, -(textInset + 32), 0, 17),
                        Font = Enum.Font.Gotham,
                        Text = Description,
                        TextColor3 = Library.Theme.SubText,
                        TextSize = IsMobile and 10 or 11,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 7
                    })
                    Utility:RegisterProperty(ButtonDescription, "TextColor3", "SubText")
                end
                local ButtonArrow = Utility:Create("ImageLabel", {
                    Parent = ButtonContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -24, 0.5, -8),
                    Size = UDim2.fromOffset(16, 16),
                    Image = ICONS.ChevronRight,
                    ImageColor3 = Library.Theme.SubText,
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 7
                })
                Utility:RegisterProperty(ButtonArrow, "ImageColor3", "SubText")

                Library:Connect(Btn.MouseEnter, function()
                    Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Accent})
                    Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Hover})
                end)
                Library:Connect(Btn.MouseLeave, function()
                    Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Stroke})
                    Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Surface})
                end)
                Library:Connect(Btn.MouseButton1Click, function()
                    if IsMobile then
                        Utility:Tween(Stroke, TweenInfo.new(0.1), {Color = Library.Theme.Accent})
                        Utility:Tween(ButtonContainer, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Hover})
                        task.delay(0.15, function()
                            Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Library.Theme.Stroke})
                            Utility:Tween(ButtonContainer, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Surface})
                        end)
                    end
                    Utility:SafeCall(Callback)
                end)
                addElement({Holder = ButtonContainer, Text = Name .. " " .. Description})
                return finishController({
                    SetText = function(self, text) ButtonTitle.Text = tostring(text) end,
                    SetDescription = function(self, text)
                        if ButtonDescription then ButtonDescription.Text = tostring(text) end
                    end
                }, ButtonContainer, Name, options.Tooltip)
            end

