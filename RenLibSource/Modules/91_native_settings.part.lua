-- Module fragment: native overview and settings
-- Generated from the working V7 baseline; edit this feature in isolation.
    -- intentionally created after user-navigation plumbing but outside the
    -- scrollable tab list, so scripts cannot accidentally push it offscreen.
    local NativeOverview = Window:CreateDashboard({
        Name = "Overview",
        IsNative = true,
        Greeting = "Welcome, " .. (Plr.DisplayName or Plr.Name),
        Subtitle = "RenLib session · @" .. Plr.Name,
        Cards = {
            {
                Name = "RenCore launcher",
                Side = "Left",
                Icon = ICONS.Play,
                Description = "Close this RenLib session and return to the official RenCore script selector.",
                Action = {
                    Name = "Relaunch RenCore",
                    Description = "Unload this interface, then start the official RenCore loader.",
                    Icon = ICONS.Restore,
                    Callback = function()
                        Window:Dialog({
                            Title = "Relaunch RenCore?",
                            Content = "RenLib will close this interface and start the official RenCore selector.",
                            Actions = {
                                {Name = "Cancel"},
                                {Name = "Relaunch", Primary = true, Callback = function()
                                    Library:RelaunchRenCore(options.BeforeRelaunch)
                                end}
                            }
                        })
                    end
                }
            },
            {
                Name = "Session",
                Side = "Right",
                Icon = ICONS.Dashboard,
                Metrics = {
                    {Name = "Library", Value = "V" .. Library.Version, Detail = "Current RenLib release"},
                    {Name = "Device", Value = Library.DeviceMode, Detail = "Responsive layout mode"},
                    {Name = "Material", Value = Library.MaterialMode, Detail = "Current window material"}
                }
            }
        }
    })
    Window.OverviewTab = NativeOverview.Tab

    -- Create Settings Tab
    local SettingsTab = Window:CreateTab({
        Name = "UI Settings",
        Emoji = EMOJIS.Settings,
        IsSettings = true
    })
    Window.SettingsTab = SettingsTab

    task.defer(function()
        if not Library.Unloaded and not Window.ActiveTab and Window.OverviewTab then
            Window.OverviewTab:Activate()
        end
    end)

    local UISection = SettingsTab:CreateSection({ Name = "UI Controls", Side = "Left" })
    if not IsMobile then
        UISection:CreateLabel("Toggle UI Key: " .. Library.ToggleKey.Name)
        UISection:CreateButton({
            Name = "Change Toggle Key",
            Callback = function()
                Library:Notify({ Title = "Press Any Key", Content = "Press a key to set as toggle...", Emoji = "⌨️", Duration = 5 })
                local conn
                conn = Library:Connect(UserInputService.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Library.ToggleKey = input.KeyCode
                        Library:Notify({ Title = "Success", Content = "Toggle key set to: " .. input.KeyCode.Name, Emoji = EMOJIS.Success })
                        conn:Disconnect()
                    end
                end)
            end
        })
    else
        UISection:CreateLabel("Tap the floating RenCore button to toggle UI")
    end
    UISection:CreateButton({ Name = "Minimize UI", Icon = ICONS.Minimize, Callback = function() Window:Minimize() end })
    UISection:CreateButton({ Name = "Close UI", Icon = ICONS.Close, Callback = function() Window:Close() end })

    local AppearanceSection = SettingsTab:CreateSection({ Name = "Appearance & motion", Side = "Right" })
    AppearanceSection:CreateDropdown({
        Name = "Theme preset",
        Values = {"Midnight", "Nebula", "Celestial", "Rose", "Aurora", "Ember", "Prism Frost", "Moss Archive", "Velvet Latte"},
        Default = Library.ActiveTheme or "Midnight",
        Flag = "__RenLibTheme",
        Callback = function(theme)
            Library:ApplyThemePreset(theme)
        end
    })
    AppearanceSection:CreateDropdown({
        Name = "Window material",
        Values = {"Solid", "Frosted"},
        Default = Library.MaterialMode,
        Flag = "__RenLibMaterial",
        Callback = function(mode)
            Library:SetMaterialMode(mode)
        end
    })
    AppearanceSection:CreateSlider({
        Name = "Glass transparency",
        Min = 0,
        Max = 32,
        Step = 2,
        Default = Library.MaterialIntensity,
        Flag = "__RenLibFrostIntensity",
        CallbackMode = "Release",
        Callback = function(value) Library:SetMaterialIntensity(value) end
    })
    local ScaleSlider = AppearanceSection:CreateSlider({
        Name = "UI scale",
        Min = 100,
        Max = 150,
        Step = 5,
        Default = math.floor(Library.DPIScale * 100),
        Flag = "__RenLibScale",
        CallbackMode = "Release",
        Callback = function(scale)
            task.defer(function() Library:PreviewDPIScale(scale, 10) end)
        end
    })
    AppearanceSection:CreateButton({
        Name = "Reset UI size",
        Description = "Preview the safe 100% size with the same 10-second recovery.",
        Icon = ICONS.Restore,
        Callback = function()
            ScaleSlider:SetSilent(100)
            Library:PreviewDPIScale(100, 10)
        end
    })
    AppearanceSection:CreateToggle({
        Name = "Reduced motion",
        Default = Library.ReducedMotion,
        Flag = "__RenLibReducedMotion",
        Callback = function(enabled) Library:SetReducedMotion(enabled) end
    })
    AppearanceSection:CreateParagraph({
        Title = "Responsive by default",
        Content = "RenLib reflows from the UI's real visible width, so small scales and phones use one safe column. Frosted material is local to the RenLib window and never changes the game screen."
    })

    local UtilitySection = SettingsTab:CreateSection({ Name = "Utilities", Side = "Right" })
    UtilitySection:CreateButton({
        Name = "Keybind manager",
        Description = "Review, edit, or reset every registered shortcut in one place.",
        Icon = ICONS.Menu,
        Callback = function() Window:ShowKeybindManager() end
    })
    if options.ShowInfiniteYield == nil or options.ShowInfiniteYield then
        UtilitySection:CreateButton({
            Name = "Launch Infinite Yield",
            Description = "Fetch the current official EdgeIY source after confirmation.",
            Icon = ICONS.Play,
            Callback = function()
                Window:Dialog({
                    Title = "Launch Infinite Yield?",
                    Content = "This downloads and runs the current script directly from the official EdgeIY/infiniteyield repository.",
                    Actions = {
                        {Name = "Cancel"},
                        {Name = "Launch", Primary = true, Callback = function() Library:LaunchInfiniteYield() end}
                    }
                })
            end
        })
    end

    local ConfigSection = SettingsTab:CreateSection({ Name = "Configuration", Side = "Left" })
    ConfigSection:CreateParagraph({
        Title = Library.PersistenceAvailable and "Persistent storage" or "Session storage",
        Content = Library.PersistenceAvailable
            and "Configs are saved to the executor filesystem."
            or "This executor blocks file APIs. Configs still work, but reset when the Roblox client closes."
    })
    local configNames = Library:GetConfigList()
    local selectedConfig = configNames[1]
    local desiredConfigName = selectedConfig or "default"
    local ConfigDropdown, AutoloadStatus

    local function hasConfig(name, values)
        for _, item in ipairs(values or {}) do if item == name then return true end end
        return false
    end

    local function refreshConfigManager(preferred)
        configNames = Library:GetConfigList()
        local target
        if preferred and hasConfig(preferred, configNames) then
            target = preferred
        elseif hasConfig(selectedConfig, configNames) then
            target = selectedConfig
        else
            target = configNames[1]
        end
        if ConfigDropdown then
            ConfigDropdown:Refresh(configNames)
            selectedConfig = target
            if target then ConfigDropdown:Set(target) end
        else
            selectedConfig = target
        end
        if AutoloadStatus then
            AutoloadStatus:SetContent(Library:GetAutoloadConfigName() or "None")
        end
    end

    ConfigDropdown = ConfigSection:CreateDropdown({
        Name = "Saved configs",
        Values = configNames,
        Default = selectedConfig,
        Flag = "__RenLibConfigSelection",
        Callback = function(value) selectedConfig = value end
    })
    ConfigSection:CreateInput({
        Name = "Config name / rename target",
        Default = desiredConfigName,
        Placeholder = "default",
        Flag = "__RenLibConfigName",
        Callback = function(value) desiredConfigName = cleanConfigName(value) end
    })
    AutoloadStatus = ConfigSection:CreateParagraph({
        Title = "Current autoload",
        Content = Library:GetAutoloadConfigName() or "None"
    })
    ConfigSection:CreateButton({Name = "Save or overwrite", Callback = function()
        local ok, err = Library:SaveConfig(desiredConfigName)
        if ok then selectedConfig = desiredConfigName; refreshConfigManager(desiredConfigName) end
        local savedTitle = Library.PersistenceAvailable and "Config saved" or "Config saved for session"
        Library:Notify({Title = ok and savedTitle or "Save failed", Content = ok and desiredConfigName or tostring(err), Duration = 3})
    end})
    ConfigSection:CreateButton({Name = "Load selected", Callback = function()
        if not selectedConfig then
            Library:Notify({Title = "No config selected", Content = "Save or select a config first.", Duration = 3})
            return
        end
        local ok, err = Library:LoadConfig(selectedConfig)
        Library:Notify({Title = ok and "Config loaded" or "Load failed", Content = ok and selectedConfig or tostring(err), Duration = 3})
    end})
    ConfigSection:CreateButton({Name = "Rename selected", Callback = function()
        if not selectedConfig then
            Library:Notify({Title = "No config selected", Content = "Choose a saved config first.", Duration = 3})
            return
        end
        local oldName = selectedConfig
        local ok, err = Library:RenameConfig(oldName, desiredConfigName)
        if ok then selectedConfig = desiredConfigName; refreshConfigManager(desiredConfigName) end
        Library:Notify({Title = ok and "Config renamed" or "Rename failed", Content = ok and (oldName .. " → " .. desiredConfigName) or tostring(err), Duration = 3})
    end})
    ConfigSection:CreateButton({Name = "Set selected as autoload", Callback = function()
        if not selectedConfig then
            Library:Notify({Title = "No config selected", Content = "Choose a saved config first.", Duration = 3})
            return
        end
        local ok, err = Library:SetAutoloadConfig(selectedConfig)
        refreshConfigManager(selectedConfig)
        local autoloadTitle = Library.PersistenceAvailable and "Autoload set" or "Session autoload set"
        Library:Notify({Title = ok and autoloadTitle or "Autoload unavailable", Content = ok and selectedConfig or tostring(err), Duration = 3})
    end})
    ConfigSection:CreateButton({Name = "Delete selected", Icon = EMOJIS.Trash, Callback = function()
        if not selectedConfig then
            Library:Notify({Title = "No config selected", Content = "Choose a saved config first.", Duration = 3})
            return
        end
        local deleting = selectedConfig
        Window:Dialog({
            Title = "Delete " .. deleting .. "?",
            Content = "This permanently removes the saved config. Its autoload link will also be cleared.",
            Actions = {
                {Name = "Cancel"},
                {Name = "Delete", Primary = true, Callback = function()
                    local ok, err = Library:DeleteConfig(deleting)
                    if ok then selectedConfig = nil; refreshConfigManager() end
                    Library:Notify({Title = ok and "Config deleted" or "Delete failed", Content = ok and deleting or tostring(err), Duration = 3})
                end}
            }
        })
    end})
    ConfigSection:CreateButton({Name = "Clear autoload", Callback = function()
        local ok, err = Library:ClearAutoloadConfig()
        refreshConfigManager(selectedConfig)
        Library:Notify({Title = ok and "Autoload cleared" or "Clear failed", Content = ok and "No config will load automatically." or tostring(err), Duration = 3})
    end})
    ConfigSection:CreateButton({Name = "Refresh config list", Icon = EMOJIS.Refresh, Callback = function()
        refreshConfigManager(selectedConfig)
    end})

    Library:Connect(SettingsBtn.MouseButton1Click, function()
        if SettingsTab then
            SettingsTab:Activate()
        end
    end)

    Library.Window = Window
    return Window
end

