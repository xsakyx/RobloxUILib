-- Module fragment: Rayfield compatibility adapter
-- Generated from the working V7 baseline; edit this feature in isolation.
function Library:CreateRayfieldAdapter()
    local source = self
    local adapter = {ConfigName = nil, Window = nil}

    local function safeCallback(callback, ...)
        if callback then Utility:SafeCall(callback, ...) end
    end

    local function unwrapSingle(value)
        if type(value) == "table" then return value[1] end
        return value
    end

    local function selectedArray(value, values)
        local selected = {}
        if type(value) ~= "table" then
            if value ~= nil then table.insert(selected, value) end
            return selected
        end
        for _, option in ipairs(values or {}) do
            if value[option] == true then table.insert(selected, option) end
        end
        if #selected == 0 then
            for key, item in pairs(value) do
                if type(key) == "number" then table.insert(selected, item) end
            end
        end
        return selected
    end

    local function proxyController(controller, transformSet)
        local proxy = {Raw = controller}
        function proxy:Set(value)
            if controller and controller.Set then controller:Set(transformSet and transformSet(value) or value) end
            return self
        end
        function proxy:Get()
            return controller and controller.Get and controller:Get() or nil
        end
        return setmetatable(proxy, {__index = controller})
    end

    function adapter:Notify(options)
        return source:Notify(options or {})
    end

    function adapter:Destroy()
        return source:Unload("compatibility adapter")
    end

    function adapter:LoadConfiguration()
        if self.ConfigName then
            local ok = source:LoadConfig(self.ConfigName)
            if ok then return true end
        end
        return source:LoadAutoloadConfig()
    end

    function adapter:CreateWindow(options)
        options = options or {}
        local saving = options.ConfigurationSaving or {}
        if saving.Enabled then self.ConfigName = cleanConfigName(saving.FileName or options.Name or "default") end
        local themeAliases = {
            Default = "Celestial", AmberGlow = "Ember", Amethyst = "Nebula",
            Bloom = "Rose", DarkBlue = "Midnight", Green = "Moss Archive",
            Light = "Prism Frost", Ocean = "Aurora", Serenity = "Celestial"
        }
        -- A saved autoload theme is the user's explicit choice and must win
        -- over a legacy script's hard-coded Rayfield theme.
        if not source.AutoloadThemeName and type(options.Theme) == "string" then
            source:ApplyThemePreset(themeAliases[options.Theme] or options.Theme)
        elseif not source.AutoloadThemeName and type(options.Theme) == "table" then
            source:SetTheme({
                Main = options.Theme.Background,
                Secondary = options.Theme.Topbar or options.Theme.Background,
                Surface = options.Theme.ElementBackground,
                SurfaceAlt = options.Theme.SecondaryElementBackground or options.Theme.ElementBackground,
                Stroke = options.Theme.ElementStroke,
                Divider = options.Theme.SecondaryElementStroke or options.Theme.ElementStroke,
                Text = options.Theme.TextColor,
                SubText = options.Theme.PlaceholderColor,
                Hover = options.Theme.ElementBackgroundHover,
                Click = options.Theme.DropdownSelected,
                Accent = options.Theme.ToggleEnabled or options.Theme.SliderProgress,
                Accent2 = options.Theme.ToggleEnabledStroke or options.Theme.SliderProgress,
                Accent3 = options.Theme.TabBackgroundSelected or options.Theme.ToggleEnabled
            })
        end
        local toggleKey = options.ToggleUIKeybind
        if typeof(toggleKey) == "EnumItem" then
            source.ToggleKey = toggleKey
        elseif type(toggleKey) == "string" and Enum.KeyCode[toggleKey] then
            source.ToggleKey = Enum.KeyCode[toggleKey]
        end
        local rawWindow = source:CreateWindow({
            Name = options.Name or options.LoadingTitle or "RenLib Script",
            Icon = options.Icon,
            SidebarMode = "Dynamic",
            ShowUserProfile = true,
            ShowInfiniteYield = false,
            EnableGlobalSearch = true
        })
        self.Window = rawWindow
        local window = {Raw = rawWindow}

        function window:CreateTab(name, icon)
            local rawTab = rawWindow:CreateTab({Name = tostring(name or "Tab"), Icon = icon})
            local tab = {Raw = rawTab, CurrentSection = nil, SectionCount = 0}

            local function currentSection()
                if not tab.CurrentSection then
                    tab.SectionCount = tab.SectionCount + 1
                    tab.CurrentSection = rawTab:CreateSection({Name = "Controls", Side = "Left"})
                end
                return tab.CurrentSection
            end

            function tab:CreateSection(sectionOptions)
                local sectionName = type(sectionOptions) == "table" and sectionOptions.Name or sectionOptions
                self.SectionCount = self.SectionCount + 1
                self.CurrentSection = rawTab:CreateSection({
                    Name = tostring(sectionName or "Section"),
                    Side = self.SectionCount % 2 == 1 and "Left" or "Right"
                })
                return self.CurrentSection
            end

            function tab:CreateButton(controlOptions)
                controlOptions = controlOptions or {}
                return currentSection():CreateButton({
                    Name = controlOptions.Name,
                    Description = controlOptions.Description,
                    Icon = controlOptions.Icon,
                    Callback = controlOptions.Callback
                })
            end

            function tab:CreateToggle(controlOptions)
                controlOptions = controlOptions or {}
                return proxyController(currentSection():CreateToggle({
                    Name = controlOptions.Name,
                    Default = controlOptions.CurrentValue,
                    Flag = controlOptions.Flag,
                    Callback = controlOptions.Callback
                }))
            end

            function tab:CreateSlider(controlOptions)
                controlOptions = controlOptions or {}
                local range = controlOptions.Range or {0, 100}
                return proxyController(currentSection():CreateSlider({
                    Name = controlOptions.Name,
                    Min = range[1],
                    Max = range[2],
                    Step = controlOptions.Increment or 1,
                    Default = controlOptions.CurrentValue or range[1],
                    Flag = controlOptions.Flag,
                    CallbackMode = controlOptions.CallbackMode or "Changed",
                    Callback = controlOptions.Callback
                }))
            end

            function tab:CreateDropdown(controlOptions)
                controlOptions = controlOptions or {}
                local values = controlOptions.Options or {}
                local multi = controlOptions.MultipleOptions == true
                local default = multi and (controlOptions.CurrentOption or {}) or unwrapSingle(controlOptions.CurrentOption)
                local callback = controlOptions.Callback
                local raw = currentSection():CreateDropdown({
                    Name = controlOptions.Name,
                    Values = values,
                    Multi = multi,
                    Default = default,
                    Flag = controlOptions.Flag,
                    Callback = function(value)
                        safeCallback(callback, multi and selectedArray(value, values) or {value})
                    end
                })
                local proxy = proxyController(raw, function(value) return multi and value or unwrapSingle(value) end)
                function proxy:Refresh(newValues, newSelection)
                    values = type(newValues) == "table" and newValues or {}
                    raw:Refresh(values)
                    if newSelection ~= nil and newSelection ~= true then self:Set(newSelection) end
                    return self
                end
                return proxy
            end

            function tab:CreateInput(controlOptions)
                controlOptions = controlOptions or {}
                return proxyController(currentSection():CreateInput({
                    Name = controlOptions.Name,
                    Default = controlOptions.CurrentValue or "",
                    Placeholder = controlOptions.PlaceholderText or controlOptions.Placeholder,
                    Flag = controlOptions.Flag,
                    Callback = controlOptions.Callback
                }))
            end

            function tab:CreateColorPicker(controlOptions)
                controlOptions = controlOptions or {}
                return proxyController(currentSection():CreateColorPicker({
                    Name = controlOptions.Name,
                    Default = controlOptions.Color or controlOptions.CurrentColor or Color3.new(1, 1, 1),
                    Flag = controlOptions.Flag,
                    Callback = controlOptions.Callback
                }))
            end

            function tab:CreateLabel(labelOptions)
                local text = type(labelOptions) == "table" and (labelOptions.Text or labelOptions.Name) or labelOptions
                local raw = currentSection():CreateLabel(tostring(text or ""))
                local proxy = {Raw = raw}
                function proxy:Set(nextText) raw:SetText(tostring(nextText or "")); return self end
                return setmetatable(proxy, {__index = raw})
            end

            function tab:CreateParagraph(controlOptions)
                controlOptions = type(controlOptions) == "table" and controlOptions or {Content = controlOptions}
                local raw = currentSection():CreateParagraph({Title = controlOptions.Title, Content = controlOptions.Content})
                local proxy = {Raw = raw}
                function proxy:Set(value)
                    if type(value) == "table" then
                        if value.Title ~= nil then raw:SetTitle(value.Title) end
                        if value.Content ~= nil then raw:SetContent(value.Content) end
                    else
                        raw:SetContent(tostring(value or ""))
                    end
                    return self
                end
                return setmetatable(proxy, {__index = raw})
            end

            function tab:CreateKeybind(controlOptions)
                controlOptions = controlOptions or {}
                local key = controlOptions.CurrentKeybind
                if typeof(key) == "EnumItem" then key = key.Name end
                key = tostring(key or "None")
                local callback = controlOptions.Callback
                local raw = currentSection():CreateKeyPicker({
                    Name = controlOptions.Name,
                    Default = key,
                    Flag = controlOptions.Flag,
                    Mode = "Toggle",
                    Callback = function() end
                })
                source:Connect(UserInputService.InputBegan, function(input, processed)
                    if not processed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == raw:GetKey() then
                        safeCallback(callback)
                    end
                end)
                return proxyController(raw, function(value)
                    return typeof(value) == "EnumItem" and value.Name or tostring(value)
                end)
            end

            return tab
        end

        return window
    end

    return adapter
end

