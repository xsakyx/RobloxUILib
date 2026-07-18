-- Module fragment: DPI and scale preview
-- Generated from the working V7 baseline; edit this feature in isolation.
--// DPI SCALING
function Library:SetDPIScale(percent)
    percent = math.clamp(tonumber(percent) or 100, 100, 150)
    local scale = percent / 100
    for _, uiScale in ipairs(self.Scales) do
        uiScale.Scale = scale
    end
    self.DPIScale = scale
    if self.Window and self.Window.ApplyResponsiveLayout then
        task.defer(function()
            RunService.RenderStepped:Wait()
            if self.Window and not self.Unloaded then
                self.Window:ApplyResponsiveLayout(true)
                task.defer(function()
                    if self.Window and not self.Unloaded then self.Window:ApplyResponsiveLayout(false) end
                end)
            end
        end)
    end
    return percent
end

function Library:KeepDPIScale(token)
    local preview = self.ScalePreview
    if not preview or (token and preview.Token ~= token) then return false end
    preview.Kept = true
    self.ScalePreview = nil
    return true
end

function Library:RevertDPIScale(token)
    local preview = self.ScalePreview
    if not preview or (token and preview.Token ~= token) then return false end
    self.ScalePreview = nil
    self:SetDPIScale(preview.OriginalPercent)
    self.Flags.__RenLibScale = preview.OriginalPercent
    local scaleOption = self.Options.__RenLibScale
    if scaleOption and scaleOption.SetSilent then scaleOption:SetSilent(preview.OriginalPercent) end
    return true
end

function Library:PreviewDPIScale(percent, timeout)
    timeout = math.clamp(tonumber(timeout) or 10, 5, 30)
    local activePreview = self.ScalePreview
    local originalPercent = activePreview and activePreview.OriginalPercent or math.floor(self.DPIScale * 100 + 0.5)
    local token = Utility:RandomString(12)
    local candidate = self:SetDPIScale(percent)
    self.Flags.__RenLibScale = candidate
    self.ScalePreview = {
        Token = token,
        OriginalPercent = originalPercent,
        CandidatePercent = candidate,
        Kept = false
    }

    if self.Notify then
        self:Notify({
            Title = "Keep this UI size?",
            Content = tostring(candidate) .. "% preview. It will reset in " .. tostring(timeout) .. " seconds unless you keep it.",
            Duration = timeout,
            Actions = {
                {Name = "Keep", Callback = function()
                    if self:KeepDPIScale(token) and self.Notify then
                        self:Notify({Title = "UI size kept", Content = tostring(candidate) .. "%", Duration = 2})
                    end
                end},
                {Name = "Revert", Callback = function()
                    if self:RevertDPIScale(token) and self.Notify then
                        self:Notify({Title = "UI size restored", Content = tostring(originalPercent) .. "%", Duration = 2})
                    end
                end}
            }
        })
    end

    task.delay(timeout, function()
        local preview = self.ScalePreview
        if preview and preview.Token == token and not preview.Kept then
            self:RevertDPIScale(token)
            if self.Notify and not self.Unloaded then
                self:Notify({Title = "UI size restored", Content = "The preview timed out safely.", Duration = 3})
            end
        end
    end)
    return token
end

