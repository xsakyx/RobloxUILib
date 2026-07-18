-- Module fragment: unload and startup lifecycle
-- Generated from the working V7 baseline; edit this feature in isolation.
--// UNLOAD
function Library:Unload(reason)
    if self.Unloaded then return end
    self.Unloaded = true
    self.ScalePreview = nil
    for index = #self.AddonOrder, 1, -1 do
        self:UnregisterAddon(self.AddonOrder[index])
    end
    for _, tween in pairs(self.ActiveTweens) do
        pcall(function() tween:Cancel() end)
    end
    for _, tween in pairs(self.LayoutTweens) do
        pcall(function() tween:Cancel() end)
    end
    for _, tween in pairs(self.VisibilityTweens) do
        pcall(function() tween:Cancel() end)
    end
    for _, conn in pairs(Library.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end
    table.clear(self.Connections)
    table.clear(self.Registry)
    table.clear(self.GradientRegistry)
    table.clear(self.MaterialRegistry)
    table.clear(self.MaterialDecorations)
    table.clear(self.BrandMarks)
    table.clear(self.Scales)
    table.clear(self.Options)
    table.clear(self.KeybindList)
    table.clear(self.KeybindDefaults)
    table.clear(self.PendingAutoloadFlags)
    table.clear(self.LayoutTweens)
    table.clear(self.VisibilityTweens)
    self.Window = nil
    self.KeybindManager = nil
    self.ScreenGui = nil
    if RuntimeEnvironment[RUNTIME_KEY] == self then RuntimeEnvironment[RUNTIME_KEY] = nil end
    print("[RenLib] Unloaded" .. (reason and (" (" .. tostring(reason) .. ")") or ""))
end

--// TOGGLE KEY (PC only)
local inputOk, inputErr = pcall(function()
    Library:Connect(UserInputService.InputBegan, function(input, gpe)
        if gpe then return end
        if input.KeyCode == Library.ToggleKey then
            if Library.Window then Library.Window:Toggle() end
        end
    end)
end)
if not inputOk then
    warn("[RenLib] Input initialization failed: " .. tostring(inputErr))
end

local runtimeOk, runtimeErr = pcall(function()
    RuntimeEnvironment[RUNTIME_KEY] = Library
end)
if not runtimeOk then
    warn("[RenLib] Runtime registration failed: " .. tostring(runtimeErr))
end

local filesystemOk, filesystemReady = pcall(ensureConfigFolders)
if not filesystemOk then
    warn("[RenLib] Filesystem initialization failed: " .. tostring(filesystemReady))
elseif filesystemReady then
    local autoloadOk, autoloadErr = pcall(function()
        Library:PrepareAutoloadConfig()
    end)
    if not autoloadOk then
        warn("[RenLib] Autoload initialization failed: " .. tostring(autoloadErr))
    end
end

print("[RenLib] Loaded - Version " .. Library.Version .. " (" .. Library.DeviceMode .. ")")

return Library
