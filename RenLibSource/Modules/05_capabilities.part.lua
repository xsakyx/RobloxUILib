-- Module fragment: host capability discovery and safe adapters
-- Optional executor functions are captured once and never called directly by UI modules.

local Capabilities = {
    Functions = {},
    Failures = {}
}

local function captureCapability(name, resolver)
    local ok, value = pcall(resolver)
    if ok and type(value) == "function" then
        Capabilities.Functions[name] = value
        return value
    end
    return nil
end

captureCapability("loadstring", function() return loadstring end)
captureCapability("request", function() return request end)
captureCapability("request", function() return http_request end)
captureCapability("request", function() return syn and syn.request end)
captureCapability("request", function() return http and http.request end)
captureCapability("gethui", function() return gethui end)
captureCapability("protectGui", function() return syn and syn.protect_gui end)
captureCapability("setclipboard", function() return setclipboard end)
captureCapability("setclipboard", function() return toclipboard end)
captureCapability("isfolder", function() return isfolder end)
captureCapability("makefolder", function() return makefolder end)
captureCapability("isfile", function() return isfile end)
captureCapability("readfile", function() return readfile end)
captureCapability("writefile", function() return writefile end)
captureCapability("delfile", function() return delfile end)
captureCapability("listfiles", function() return listfiles end)

function Capabilities:Has(name)
    return type(self.Functions[name]) == "function"
end

function Capabilities:Call(name, ...)
    local fn = self.Functions[name]
    if type(fn) ~= "function" then
        return false, name .. " is unavailable"
    end
    return pcall(fn, ...)
end

function Capabilities:Disable(name, reason)
    self.Functions[name] = nil
    self.Failures[name] = tostring(reason or "capability failed")
end

function Capabilities:HttpGet(url)
    local gameOk, gameResult = pcall(function()
        return game:HttpGet(url)
    end)
    if gameOk and type(gameResult) == "string" and gameResult ~= "" then
        return true, gameResult
    end

    local requestFn = self.Functions.request
    if type(requestFn) == "function" then
        local requestOk, response = pcall(requestFn, {Url = url, Method = "GET"})
        if requestOk and type(response) == "table" then
            local status = response.StatusCode or response.Status or response.status_code
            local body = response.Body or response.body
            if (status == nil or (tonumber(status) and tonumber(status) >= 200 and tonumber(status) < 300))
                and type(body) == "string" then
                return true, body
            end
            return false, "request returned status " .. tostring(status)
        end
        self:Disable("request", response)
    end

    return false, gameOk and "HTTP returned an empty response" or gameResult
end

function Capabilities:Compile(source)
    local compiler = self.Functions.loadstring
    if type(compiler) ~= "function" then
        return false, "loadstring is unavailable"
    end
    local callOk, chunk, compileError = pcall(compiler, source)
    if not callOk then return false, chunk end
    if type(chunk) ~= "function" then return false, compileError or "compiler returned no function" end
    return true, chunk
end

function Capabilities:SetClipboard(text)
    local ok, result = self:Call("setclipboard", tostring(text or ""))
    if not ok then self.Failures.setclipboard = tostring(result) end
    return ok, result
end

function Capabilities:GetGuiParent()
    local getHui = self.Functions.gethui
    if type(getHui) == "function" then
        local ok, result = pcall(getHui)
        if ok and result then return result end
        self:Disable("gethui", result)
    end
    if CoreGui then return CoreGui end
    return Plr and Plr:FindFirstChildOfClass("PlayerGui") or nil
end

function Capabilities:ProtectGui(gui)
    local protect = self.Functions.protectGui
    if type(protect) ~= "function" then return false end
    return pcall(protect, gui)
end

function Capabilities:GetReport()
    local report = {}
    for name in pairs(self.Functions) do report[name] = true end
    for name, reason in pairs(self.Failures) do report[name] = reason end
    return report
end

Library.Capabilities = Capabilities

