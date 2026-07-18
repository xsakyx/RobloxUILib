-- Module fragment: section composition and controller contracts
-- Generated from the working V7 baseline; edit this feature in isolation.
        --// SECTIONS
        function Tab:CreateSection(options)
            options = options or {}
            local SectionName = options.Name or "Section"
            local Side = options.Side or "Auto"
            local SectionIcon = Utility:NormalizeAssetId(options.Icon)

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

            local Section = { Name = SectionName, RequestedSide = Side, Elements = {}, SectionFrame = nil, ContentContainer = nil }
            table.insert(Tab.Sections, Section)

            local SectionFrame = Utility:Create("Frame", {
                Name = SectionName,
                Parent = ParentCol,
                BackgroundColor3 = Library.Theme.Surface,
                Size = UDim2.new(1, 0, 0, 50),
                -- Allow expanded controls to render above the section frame.
                ClipsDescendants = false,
                ZIndex = 3,
                BorderSizePixel = 0
            })
            Utility:RegisterProperty(SectionFrame, "BackgroundColor3", "Surface")
            Utility:RegisterMaterial(SectionFrame, 0.24, 0)
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = SectionFrame})
            local sectionStroke = Utility:Create("UIStroke", {
                Parent = SectionFrame,
                Color = Library.Theme.Stroke,
                Thickness = 1
            })
            Utility:RegisterProperty(sectionStroke, "Color", "Stroke")
            local sectionGradient = Utility:Create("UIGradient", {Parent = SectionFrame, Rotation = 105})
            Utility:RegisterGradient(sectionGradient, "SurfaceAlt", "Surface")
            local sectionAccent = Utility:Create("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = Library.Theme.Accent,
                Position = UDim2.fromOffset(12, 12),
                Size = UDim2.fromOffset(3, 16),
                BorderSizePixel = 0,
                ZIndex = 5
            })
            Utility:RegisterProperty(sectionAccent, "BackgroundColor3", "Accent")
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sectionAccent})
            if SectionIcon then
                sectionAccent.Visible = false
                local sectionIcon = Utility:Create("ImageLabel", {
                    Parent = SectionFrame, BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(10, 9), Size = UDim2.fromOffset(20, 20),
                    Image = SectionIcon, ImageColor3 = Library.Theme.Accent,
                    ScaleType = Enum.ScaleType.Fit, ZIndex = 5
                })
                Utility:RegisterProperty(sectionIcon, "ImageColor3", "Accent")
            end
            Section.SectionFrame = SectionFrame

            local Head = Utility:Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, SectionIcon and 38 or 22, 0, 10),
                Size = UDim2.new(1, SectionIcon and -50 or -34, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = SectionName,
                TextColor3 = Library.Theme.Text,
                TextSize = IsMobile and 12 or 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 4
            })
            Utility:RegisterProperty(Head, "TextColor3", "Text")

            local ContentContainer = Utility:Create("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = Library.Theme.Main,
                BackgroundTransparency = 0.12,
                Position = UDim2.new(0, 8, 0, IsMobile and 34 or 36),
                Size = UDim2.new(1, -16, 0, 0),
                ZIndex = 4,
                BorderSizePixel = 0
            })
            Utility:RegisterProperty(ContentContainer, "BackgroundColor3", "Main")
            Utility:RegisterMaterial(ContentContainer, 0.4, 0.12)
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 9), Parent = ContentContainer})
            local contentStroke = Utility:Create("UIStroke", {Parent = ContentContainer, Color = Library.Theme.Divider, Thickness = 1, Transparency = 0.2})
            Utility:RegisterProperty(contentStroke, "Color", "Divider")
            Utility:Create("UIPadding", {
                Parent = ContentContainer,
                PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)
            })
            Section.ContentContainer = ContentContainer

            local ContentLayout = Utility:Create("UIListLayout", {
                Parent = ContentContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, IsMobile and 6 or 8)
            })

            local function RefreshLayout()
                ContentContainer.Size = UDim2.new(1, -16, 0, ContentLayout.AbsoluteContentSize.Y + 16)
                SectionFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + (IsMobile and 58 or 60))
            end

            Library:Connect(ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                ContentContainer.Size = UDim2.new(1, -16, 0, ContentLayout.AbsoluteContentSize.Y + 16)
                Utility:Tween(SectionFrame, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + (IsMobile and 58 or 60))
                })
            end)

            local function addElement(element)
                table.insert(Section.Elements, element)
                -- Only re-parent if the holder isn't already in ContentContainer
                if element.Holder and element.Holder.Parent ~= ContentContainer then
                    element.Holder.Parent = ContentContainer
                end
                if Window.SearchQuery ~= "" and Window.RefreshSearch then
                    task.defer(function()
                        if not Library.Unloaded then Window:RefreshSearch(Window.SearchQuery) end
                    end)
                end
            end

            local function finishController(controller, holder, name, tooltip)
                controller = controller or {}
                controller.Holder = holder
                controller.Name = name
                controller.Locked = false
                if holder:IsA("GuiObject") and holder.BackgroundTransparency < 0.98 and not Library.MaterialRegistry[holder] then
                    Utility:RegisterMaterial(holder, math.min(0.48, holder.BackgroundTransparency + 0.3), holder.BackgroundTransparency)
                end
                local nestedHost, nestedLayout
                local nestedBaseHeight = holder.Size.Y.Offset
                local nestedVisible = true

                local function refreshNested()
                    if not nestedHost then return end
                    local nestedHeight = nestedVisible and (nestedLayout.AbsoluteContentSize.Y + 16) or 0
                    nestedHost.Visible = nestedVisible
                    nestedHost.Size = UDim2.new(1, -16, 0, nestedHeight)
                    holder.Size = UDim2.new(holder.Size.X.Scale, holder.Size.X.Offset, 0, nestedBaseHeight + (nestedHeight > 0 and nestedHeight + 8 or 0))
                    RefreshLayout()
                end

                function controller:AddNested(childController)
                    if not childController or not childController.Holder then return self end
                    if not nestedHost then
                        holder.ClipsDescendants = true
                        nestedHost = Utility:Create("Frame", {
                            Name = "NestedControls", Parent = holder, BackgroundColor3 = Library.Theme.Main,
                            BackgroundTransparency = 0.22, Position = UDim2.new(0, 8, 0, nestedBaseHeight),
                            Size = UDim2.new(1, -16, 0, 0), BorderSizePixel = 0,
                            ClipsDescendants = true, ZIndex = holder.ZIndex + 2
                        })
                        Utility:RegisterProperty(nestedHost, "BackgroundColor3", "Main")
                        Utility:RegisterMaterial(nestedHost, 0.48, 0.22)
                        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = nestedHost})
                        local nestedStroke = Utility:Create("UIStroke", {Parent = nestedHost, Color = Library.Theme.Divider, Thickness = 1, Transparency = 0.15})
                        Utility:RegisterProperty(nestedStroke, "Color", "Divider")
                        Utility:Create("UIPadding", {
                            Parent = nestedHost, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
                            PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)
                        })
                        nestedLayout = Utility:Create("UIListLayout", {
                            Parent = nestedHost, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)
                        })
                        Library:Connect(nestedLayout:GetPropertyChangedSignal("AbsoluteContentSize"), refreshNested)
                    end
                    childController.Holder.Parent = nestedHost
                    childController.NestedParent = self
                    for _, sectionElement in ipairs(Section.Elements) do
                        if sectionElement.Holder == childController.Holder then
                            sectionElement.NestedParentHolder = holder
                            break
                        end
                    end
                    childController.Holder.LayoutOrder = #nestedHost:GetChildren()
                    Library:Connect(childController.Holder:GetPropertyChangedSignal("Size"), refreshNested)
                    task.defer(refreshNested)
                    return self
                end

                function controller:SetNestedVisible(visible)
                    nestedVisible = visible == true
                    refreshNested()
                    return self
                end
                local blocker
                local loadingOverlay
                local loadingToken = 0
                function controller:SetVisible(visible)
                    holder.Visible = visible == true
                    RefreshLayout()
                end
                function controller:Destroy()
                    holder:Destroy()
                    RefreshLayout()
                end
                function controller:SetLocked(locked)
                    self.Locked = locked == true
                    if self.Locked and not blocker then
                        blocker = Utility:Create("TextButton", {
                            Name = "RenLibLock",
                            Parent = holder,
                            BackgroundColor3 = Library.Theme.Main,
                            BackgroundTransparency = 0.35,
                            Size = UDim2.fromScale(1, 1),
                            Text = EMOJIS.Lock,
                            TextColor3 = Library.Theme.SubText,
                            TextSize = 14,
                            AutoButtonColor = false,
                            ZIndex = 100
                        })
                        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = blocker})
                    elseif blocker then
                        blocker:Destroy()
                        blocker = nil
                    end
                end
                function controller:SetLoading(loading, message)
                    loadingToken = loadingToken + 1
                    local token = loadingToken
                    if loading == true then
                        if not loadingOverlay then
                            loadingOverlay = Utility:Create("Frame", {
                                Name = "RenLibLoading", Parent = holder, BackgroundColor3 = Library.Theme.Main,
                                BackgroundTransparency = 0.18, Size = UDim2.fromScale(1, 1),
                                BorderSizePixel = 0, ZIndex = 110
                            })
                            Utility:RegisterProperty(loadingOverlay, "BackgroundColor3", "Main")
                            Utility:Create("UICorner", {Parent = loadingOverlay, CornerRadius = UDim.new(0, 6)})
                            local loadingText = Utility:Create("TextLabel", {
                                Name = "Status", Parent = loadingOverlay, BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 1), Text = tostring(message or "Loading…"),
                                TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold,
                                TextSize = 12, ZIndex = 111
                            })
                            Utility:RegisterProperty(loadingText, "TextColor3", "Text")
                        else
                            loadingOverlay.Status.Text = tostring(message or "Loading…")
                            loadingOverlay.Status.TextTransparency = 0
                            loadingOverlay.Visible = true
                        end
                        task.spawn(function()
                            local dim = false
                            while token == loadingToken and loadingOverlay and loadingOverlay.Parent and not Library.Unloaded do
                                dim = not dim
                                Utility:Tween(loadingOverlay.Status, TweenInfo.new(0.45), {TextTransparency = dim and 0.45 or 0})
                                task.wait(0.5)
                            end
                        end)
                    elseif loadingOverlay then
                        loadingOverlay.Visible = false
                    end
                    return self
                end
                function controller:SetTooltip(text)
                    self.Tooltip = tostring(text or "")
                    if self._TooltipAttached then
                        self._TooltipAttached:Set(self.Tooltip)
                    elseif self.Tooltip ~= "" then
                        self._TooltipAttached = Window:AttachTooltip(holder, self.Tooltip)
                    end
                    return self
                end
                function controller:Lock() self:SetLocked(true) end
                function controller:Unlock() self:SetLocked(false) end
                if tooltip ~= nil then controller:SetTooltip(tooltip) end
                return controller
            end

