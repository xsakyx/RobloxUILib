-- Module fragment: config storage and autoload
-- Disk persistence is preferred, with a transparent session-memory fallback.

local MEMORY_STORAGE_KEY = "__RENLIB_V8_MEMORY_STORAGE"
local AUTOLOAD_PATH = "RenLib/autoload.txt"

local virtualReadOk, VirtualStorage = pcall(function()
    return RuntimeEnvironment[MEMORY_STORAGE_KEY]
end)
if not virtualReadOk then VirtualStorage = nil end
if type(VirtualStorage) ~= "table" then
    VirtualStorage = {Configs = {}, Autoload = nil}
    pcall(function() RuntimeEnvironment[MEMORY_STORAGE_KEY] = VirtualStorage end)
end
if type(VirtualStorage.Configs) ~= "table" then VirtualStorage.Configs = {} end

local Storage = {
    Mode = "Memory",
    Persistent = false,
    LastError = nil,
    Initialized = false,
    WarningShown = false
}

local function cleanConfigName(name)
    local cleaned = tostring(name or "default"):gsub("[^%w_%-%s]", ""):sub(1, 64)
    cleaned = cleaned:match("^%s*(.-)%s*$") or ""
    return cleaned ~= "" and cleaned or "default"
end

local CONFIG_MANAGER_FLAGS = {
    __RenLibConfigSelection = true,
    __RenLibConfigName = true,
    __RenLibConfigRename = true
}

local function encodeValue(value)
    if typeof(value) == "Color3" then
        return {__type = "Color3", r = value.R, g = value.G, b = value.B}
    elseif type(value) == "table" then
        local encoded = {}
        for key, item in pairs(value) do encoded[key] = encodeValue(item) end
        return encoded
    end
    return value
end

local function decodeValue(value)
    if type(value) == "table" and value.__type == "Color3" then
        return Color3.new(value.r or 1, value.g or 1, value.b or 1)
    elseif type(value) == "table" then
        local decoded = {}
        for key, item in pairs(value) do decoded[key] = decodeValue(item) end
        return decoded
    end
    return value
end

local function copyPayload(payload)
    if type(payload) ~= "table" then return payload end
    local copied = {}
    for key, value in pairs(payload) do
        copied[key] = type(value) == "table" and copyPayload(value) or value
    end
    return copied
end

function Storage:UseMemory(reason)
    self.Mode = "Memory"
    self.Persistent = false
    self.LastError = reason and tostring(reason) or self.LastError
    Library.StorageMode = self.Mode
    Library.PersistenceAvailable = false
    if self.LastError and not self.WarningShown then
        self.WarningShown = true
        warn("[RenLib] Persistent config storage unavailable; using session memory: " .. self.LastError)
    end
    return true
end

function Storage:Initialize()
    if self.Initialized then return true end
    self.Initialized = true

    local required = {"isfolder", "makefolder", "isfile", "readfile", "writefile"}
    for _, name in ipairs(required) do
        if not Capabilities:Has(name) then
            return self:UseMemory(name .. " is unavailable")
        end
    end

    local ok, failure = pcall(function()
        local rootOk, rootExists = Capabilities:Call("isfolder", "RenLib")
        if not rootOk then error(rootExists) end
        if not rootExists then
            local makeOk, makeError = Capabilities:Call("makefolder", "RenLib")
            if not makeOk then error(makeError) end
        end

        local folderOk, folderExists = Capabilities:Call("isfolder", CONFIG_FOLDER)
        if not folderOk then error(folderExists) end
        if not folderExists then
            local makeOk, makeError = Capabilities:Call("makefolder", CONFIG_FOLDER)
            if not makeOk then error(makeError) end
        end
    end)

    if not ok then return self:UseMemory(failure) end
    self.Mode = "File"
    self.Persistent = true
    self.LastError = nil
    Library.StorageMode = self.Mode
    Library.PersistenceAvailable = true
    return true
end

function Storage:Save(name, payload)
    self:Initialize()
    local cleaned = cleanConfigName(name)
    VirtualStorage.Configs[cleaned] = copyPayload(payload)

    if self.Mode == "File" then
        local encodedOk, encoded = pcall(function() return HttpService:JSONEncode(payload) end)
        if not encodedOk then return false, encoded end
        local writeOk, writeError = Capabilities:Call("writefile", CONFIG_FOLDER .. "/" .. cleaned .. ".json", encoded)
        if not writeOk then self:UseMemory(writeError) end
    end
    return true, self.Mode == "Memory" and "Saved for this session" or nil
end

function Storage:Load(name)
    self:Initialize()
    local cleaned = cleanConfigName(name)
    if self.Mode == "File" then
        local path = CONFIG_FOLDER .. "/" .. cleaned .. ".json"
        local existsOk, exists = Capabilities:Call("isfile", path)
        if not existsOk then
            self:UseMemory(exists)
        elseif exists then
            local readOk, contents = Capabilities:Call("readfile", path)
            if readOk then
                local decodeOk, payload = pcall(function() return HttpService:JSONDecode(contents) end)
                if decodeOk and type(payload) == "table" then
                    VirtualStorage.Configs[cleaned] = copyPayload(payload)
                    return true, payload
                end
                return false, payload
            end
            self:UseMemory(contents)
        end
    end

    local payload = VirtualStorage.Configs[cleaned]
    if type(payload) ~= "table" then return false, "Config does not exist" end
    return true, copyPayload(payload)
end

function Storage:List()
    self:Initialize()
    local names, seen = {}, {}
    local function add(name)
        name = cleanConfigName(name)
        local key = name:lower()
        if not seen[key] then
            seen[key] = true
            table.insert(names, name)
        end
    end

    for name in pairs(VirtualStorage.Configs) do add(name) end
    for name in pairs(Library.KnownConfigs) do add(name) end

    if self.Mode == "File" and Capabilities:Has("listfiles") then
        local listOk, files = Capabilities:Call("listfiles", CONFIG_FOLDER)
        if listOk and type(files) == "table" then
            for _, path in ipairs(files) do
                local normalized = tostring(path):gsub("\\", "/")
                local name = normalized:match("/([^/]+)%.json$") or normalized:match("^([^/]+)%.json$")
                if name then add(name) end
            end
        elseif not listOk then
            Capabilities:Disable("listfiles", files)
        end
    end

    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

function Storage:Delete(name)
    self:Initialize()
    local cleaned = cleanConfigName(name)
    local existedInMemory = VirtualStorage.Configs[cleaned] ~= nil
    VirtualStorage.Configs[cleaned] = nil

    if self.Mode == "File" then
        local path = CONFIG_FOLDER .. "/" .. cleaned .. ".json"
        local existsOk, exists = Capabilities:Call("isfile", path)
        if not existsOk then
            self:UseMemory(exists)
        elseif exists then
            if not Capabilities:Has("delfile") then
                return false, "delfile is unavailable"
            end
            local deleteOk, deleteError = Capabilities:Call("delfile", path)
            if not deleteOk then return false, deleteError end
            return true
        elseif not existedInMemory then
            return false, "Config does not exist"
        end
    elseif not existedInMemory then
        return false, "Config does not exist"
    end
    return true
end

function Storage:Rename(oldName, newName)
    local oldClean, newClean = cleanConfigName(oldName), cleanConfigName(newName)
    if oldClean == newClean then return true end
    local loadOk, payload = self:Load(oldClean)
    if not loadOk then return false, payload end
    local duplicateOk = self:Load(newClean)
    if duplicateOk then return false, "A config already uses that name" end
    local saveOk, saveError = self:Save(newClean, payload)
    if not saveOk then return false, saveError end
    local deleteOk, deleteError = self:Delete(oldClean)
    if not deleteOk then return false, deleteError end
    return true
end

function Storage:GetAutoload()
    self:Initialize()
    if self.Mode == "File" then
        local existsOk, exists = Capabilities:Call("isfile", AUTOLOAD_PATH)
        if existsOk and exists then
            local readOk, name = Capabilities:Call("readfile", AUTOLOAD_PATH)
            if readOk then
                name = tostring(name or ""):match("^%s*(.-)%s*$")
                if name and name ~= "" then
                    VirtualStorage.Autoload = cleanConfigName(name)
                    return VirtualStorage.Autoload
                end
            else
                self:UseMemory(name)
            end
        elseif not existsOk then
            self:UseMemory(exists)
        end
    end
    return VirtualStorage.Autoload and cleanConfigName(VirtualStorage.Autoload) or nil
end

function Storage:SetAutoload(name)
    local cleaned = cleanConfigName(name)
    local exists = self:Load(cleaned)
    if not exists then return false, "Config does not exist" end
    VirtualStorage.Autoload = cleaned
    if self.Mode == "File" then
        local writeOk, writeError = Capabilities:Call("writefile", AUTOLOAD_PATH, cleaned)
        if not writeOk then self:UseMemory(writeError) end
    end
    return true, self.Mode == "Memory" and "Autoload applies for this session" or nil
end

function Storage:ClearAutoload()
    self:Initialize()
    VirtualStorage.Autoload = nil
    if self.Mode == "File" then
        local existsOk, exists = Capabilities:Call("isfile", AUTOLOAD_PATH)
        if not existsOk then
            self:UseMemory(exists)
        elseif exists then
            if Capabilities:Has("delfile") then
                local deleteOk, deleteError = Capabilities:Call("delfile", AUTOLOAD_PATH)
                if not deleteOk then return false, deleteError end
            else
                local clearOk, clearError = Capabilities:Call("writefile", AUTOLOAD_PATH, "")
                if not clearOk then return false, clearError end
            end
        end
    end
    return true
end

Library.Storage = Storage
Library.StorageMode = "Memory"
Library.PersistenceAvailable = false

local function ensureConfigFolders()
    return Storage:Initialize()
end

function Library:SaveConfig(name)
    local payload = {version = self.Version, flags = {}}
    for flag, value in pairs(self.Flags) do
        if not CONFIG_MANAGER_FLAGS[flag] then payload.flags[flag] = encodeValue(value) end
    end
    local cleaned = cleanConfigName(name)
    local ok, result = Storage:Save(cleaned, payload)
    if ok then self.KnownConfigs[cleaned] = true end
    return ok, result
end

function Library:GetConfigList()
    return Storage:List()
end

function Library:LoadConfig(name)
    local cleaned = cleanConfigName(name)
    local ok, payload = Storage:Load(cleaned)
    if not ok or type(payload) ~= "table" then return false, payload end
    self.KnownConfigs[cleaned] = true
    for flag, rawValue in pairs(payload.flags or {}) do
        local value = decodeValue(rawValue)
        self.Flags[flag] = value
        local option = self.Options[flag]
        if option and option.Set then Utility:SafeCall(function() option:Set(value) end) end
    end
    return true
end

function Library:DeleteConfig(name)
    local cleaned = cleanConfigName(name)
    local ok, err = Storage:Delete(cleaned)
    if not ok then return false, err end
    self.KnownConfigs[cleaned] = nil
    if self:GetAutoloadConfigName() == cleaned then
        local cleared, clearError = self:ClearAutoloadConfig()
        if not cleared then return false, "Config deleted, but autoload cleanup failed: " .. tostring(clearError) end
    end
    return true
end

function Library:RenameConfig(oldName, newName)
    local oldClean, newClean = cleanConfigName(oldName), cleanConfigName(newName)
    local ok, err = Storage:Rename(oldClean, newClean)
    if not ok then return false, err end
    self.KnownConfigs[oldClean] = nil
    self.KnownConfigs[newClean] = true
    if self:GetAutoloadConfigName() == oldClean then
        local updated, updateError = self:SetAutoloadConfig(newClean)
        if not updated then return false, "Config renamed, but autoload update failed: " .. tostring(updateError) end
    end
    return true
end

function Library:GetAutoloadConfigName()
    return Storage:GetAutoload()
end

function Library:SetAutoloadConfig(name)
    local ok, err = Storage:SetAutoload(name)
    if ok then self.AutoloadConfigName = cleanConfigName(name) end
    return ok, err
end

function Library:ClearAutoloadConfig()
    local ok, err = Storage:ClearAutoload()
    if ok then
        self.AutoloadConfigName = nil
        self.AutoloadThemeName = nil
    end
    return ok, err
end

function Library:PrepareAutoloadConfig()
    self.AutoloadThemeName = nil
    local name = self:GetAutoloadConfigName()
    if not name then return false, "No autoload config" end
    local ok, payload = Storage:Load(name)
    if not ok or type(payload) ~= "table" then
        self:ClearAutoloadConfig()
        return false, payload or "Autoload config no longer exists"
    end
    self.AutoloadConfigName = name
    self.KnownConfigs[name] = true
    self.PendingAutoloadFlags = {}
    for flag, rawValue in pairs(payload.flags or {}) do
        local value = decodeValue(rawValue)
        self.PendingAutoloadFlags[flag] = value
        self.Flags[flag] = value
    end
    local preset = self.PendingAutoloadFlags.__RenLibTheme
    if type(preset) == "string" and self.ThemePresets[preset] then
        self.AutoloadThemeName = preset
        self:ApplyThemePreset(preset)
    end
    local material = self.PendingAutoloadFlags.__RenLibMaterial
    if material == "Solid" or material == "Frosted" then self:SetMaterialMode(material) end
    if self.PendingAutoloadFlags.__RenLibFrostIntensity ~= nil then
        self:SetMaterialIntensity(self.PendingAutoloadFlags.__RenLibFrostIntensity)
    end
    if self.PendingAutoloadFlags.__RenLibReducedMotion ~= nil then
        self:SetReducedMotion(self.PendingAutoloadFlags.__RenLibReducedMotion)
    end
    if self.PendingAutoloadFlags.__RenLibScale ~= nil then
        self:SetDPIScale(self.PendingAutoloadFlags.__RenLibScale)
    end
    self.PendingAutoloadFlags.__RenLibTheme = nil
    self.PendingAutoloadFlags.__RenLibMaterial = nil
    self.PendingAutoloadFlags.__RenLibFrostIntensity = nil
    self.PendingAutoloadFlags.__RenLibReducedMotion = nil
    self.PendingAutoloadFlags.__RenLibScale = nil
    return true
end
