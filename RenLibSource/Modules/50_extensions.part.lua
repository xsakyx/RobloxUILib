-- Module fragment: options, icons, addons, relaunch helpers
-- Generated from the working V7 baseline; edit this feature in isolation.
function Library:RegisterOption(flag, controller)
    self.Options[flag] = controller
    if self.PendingAutoloadFlags[flag] ~= nil and controller and controller.Set then
        local value = self.PendingAutoloadFlags[flag]
        self.PendingAutoloadFlags[flag] = nil
        task.defer(function()
            if not self.Unloaded and self.Options[flag] == controller then
                Utility:SafeCall(function() controller:Set(value) end)
            end
        end)
    end
    return controller
end

function Library:RegisterIcon(name, asset)
    name = tostring(name or "")
    assert(name ~= "", "[RenLib] RegisterIcon requires a name")
    local normalized = Utility:NormalizeAssetId(asset)
    assert(normalized, "[RenLib] RegisterIcon requires a Roblox image asset")
    self.Icons[name] = normalized
    return normalized
end

function Library:GetIcon(name, fallback)
    if name == nil then return Utility:NormalizeAssetId(fallback) end
    return self.Icons[tostring(name)] or Utility:NormalizeAssetId(name, fallback)
end

function Library:RegisterAddon(name, addon)
    name = tostring(name or "")
    assert(name ~= "", "[RenLib] RegisterAddon requires a name")
    assert(type(addon) == "table", "[RenLib] RegisterAddon requires an addon table")
    if self.Addons[name] then self:DisableAddon(name) end
    local record = {Name = name, Module = addon, Enabled = false}
    self.Addons[name] = record
    table.insert(self.AddonOrder, name)
    if type(addon.Init) == "function" then
        local ok = Utility:SafeCall(addon.Init, addon, self)
        if not ok then
            self.Addons[name] = nil
            return nil
        end
    end
    if addon.AutoStart ~= false then self:EnableAddon(name) end
    return record
end

function Library:GetAddon(name)
    local record = self.Addons[tostring(name or "")]
    return record and record.Module or nil
end

function Library:EnableAddon(name)
    local record = self.Addons[tostring(name or "")]
    if not record or record.Enabled then return record ~= nil end
    record.Enabled = true
    if type(record.Module.Start) == "function" then
        local ok = Utility:SafeCall(record.Module.Start, record.Module, self)
        if not ok then record.Enabled = false end
    end
    return record.Enabled
end

function Library:DisableAddon(name)
    local record = self.Addons[tostring(name or "")]
    if not record or not record.Enabled then return record ~= nil end
    record.Enabled = false
    if type(record.Module.Stop) == "function" then
        Utility:SafeCall(record.Module.Stop, record.Module, self)
    end
    return true
end

function Library:UnregisterAddon(name)
    name = tostring(name or "")
    local record = self.Addons[name]
    if not record then return false end
    self:DisableAddon(name)
    if type(record.Module.Unload) == "function" then
        Utility:SafeCall(record.Module.Unload, record.Module, self)
    end
    self.Addons[name] = nil
    for index, registeredName in ipairs(self.AddonOrder) do
        if registeredName == name then table.remove(self.AddonOrder, index) break end
    end
    return true
end

function Library:LoadAutoloadConfig()
    local name = self:GetAutoloadConfigName()
    if not name then return false, "No autoload config" end
    return self:LoadConfig(name)
end

function Library:LaunchInfiniteYield()
    if not Capabilities:Has("loadstring") then
        if self.Notify then self:Notify({Title = "Infinite Yield unavailable", Content = "This environment does not expose loadstring.", Duration = 4}) end
        return false, "loadstring is unavailable"
    end

    local ok, source = Capabilities:HttpGet(INFINITE_YIELD_URL)
    if not ok or type(source) ~= "string" or source == "" then
        if self.Notify then self:Notify({Title = "Infinite Yield failed", Content = tostring(source), Duration = 5}) end
        return false, source
    end

    local compiled, chunk = Capabilities:Compile(source)
    if not compiled then
        local compileError = chunk
        if self.Notify then self:Notify({Title = "Infinite Yield failed", Content = tostring(compileError), Duration = 5}) end
        return false, compileError
    end

    task.spawn(function()
        local ran, runtimeError = pcall(chunk)
        if not ran and self.Notify and not self.Unloaded then
            self:Notify({Title = "Infinite Yield error", Content = tostring(runtimeError), Duration = 5})
        end
    end)
    if self.Notify then self:Notify({Title = "Infinite Yield launched", Content = "Loaded from the official EdgeIY source.", Duration = 3}) end
    return true
end

function Library:RelaunchRenCore(beforeRelaunch)
    if not Capabilities:Has("loadstring") then
        if self.Notify then self:Notify({Title = "RenCore unavailable", Content = "This environment does not expose loadstring.", Duration = 4}) end
        return false, "loadstring is unavailable"
    end
    local ok, source = Capabilities:HttpGet(RenCore_LOADER_URL)
    if not ok or type(source) ~= "string" or source == "" then
        if self.Notify then self:Notify({Title = "RenCore failed to load", Content = tostring(source), Duration = 5}) end
        return false, source
    end
    local compiled, chunk = Capabilities:Compile(source)
    if not compiled then
        local compileError = chunk
        if self.Notify then self:Notify({Title = "RenCore failed to compile", Content = tostring(compileError), Duration = 5}) end
        return false, compileError
    end
    Utility:SafeCall(beforeRelaunch)
    self:Unload("relaunching RenCore")
    task.defer(function()
        local ran, runtimeError = pcall(chunk)
        if not ran then warn("[RenLib] RenCore relaunch failed: " .. tostring(runtimeError)) end
    end)
    return true
end

-- Compatibility facade for safely migrating scripts that were authored
-- against Rayfield's tab-level control API. The rendered UI, persistence,
-- cleanup, input handling, and controllers are all RenLib-owned.
