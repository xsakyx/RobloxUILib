-- Module fragment: themes and material system
-- Generated from the working V7 baseline; edit this feature in isolation.
--// DYNAMIC THEME UPDATE
function Library:UpdateColors()
    for instance, props in pairs(self.Registry) do
        for prop, colorKey in pairs(props) do
            pcall(function()
                instance[prop] = Utility:GetColor(colorKey)
            end)
        end
    end
    for gradient, keys in pairs(self.GradientRegistry) do
        pcall(function()
            gradient.Color = buildGradient(keys)
        end)
    end
end

function Library:SetTheme(newTheme)
    if type(newTheme) ~= "table" then return false, "Theme must be a table" end
    local merged = {}
    for key, value in pairs(self.Theme) do merged[key] = value end
    for key, value in pairs(newTheme) do
        if typeof(value) == "Color3" then merged[key] = value end
    end
    if typeof(newTheme.Accent2) ~= "Color3" and typeof(newTheme.Accent) == "Color3" then
        merged.Accent2 = newTheme.Accent
    end
    if typeof(newTheme.Accent3) ~= "Color3" then
        merged.Accent3 = merged.Accent2 or merged.Accent
    end
    for key, value in pairs(merged) do self.Theme[key] = value end
    self:UpdateColors()
    self:SetMaterialIntensity(self.MaterialIntensity)
    if self.Window and self.Window.RefreshThemeState then self.Window:RefreshThemeState() end
    return true
end

function Library:ApplyThemePreset(name)
    if name == "Starlight" then name = "Celestial" end -- V6.2 compatibility alias
    local preset = self.ThemePresets[name]
    if not preset then
        return false, "Unknown theme preset: " .. tostring(name)
    end
    self:SetTheme(preset)
    self.ActiveTheme = name
    return true
end

function Library:SetReducedMotion(enabled)
    self.ReducedMotion = enabled == true
end

function Library:SetMotionScale(scale)
    self.MotionScale = math.clamp(tonumber(scale) or 1, 0, 2)
end

function Library:GetThemeLuminance()
    local color = self.Theme.Main
    return color.R * 0.2126 + color.G * 0.7152 + color.B * 0.0722
end

function Library:ResolveMaterialTransparency(state)
    if not state then return 0 end
    if self.MaterialMode ~= "Frosted" then return state.Solid end
    local transparencyBoost = (self.MaterialIntensity / 32) * 0.24
    if self:GetThemeLuminance() < 0.35 then transparencyBoost = transparencyBoost + 0.08 end
    return math.clamp(state.Frosted + transparencyBoost, 0, 0.84)
end

function Library:SetMaterialIntensity(value)
    self.MaterialIntensity = math.clamp(tonumber(value) or 18, 0, 32)
    if self.MaterialMode == "Frosted" then
        for instance, state in pairs(self.MaterialRegistry) do
            pcall(function()
                instance[state.Property or "BackgroundTransparency"] = self:ResolveMaterialTransparency(state)
            end)
        end
    end
    return self.MaterialIntensity
end

function Library:RefreshMaterialVisibility()
    local visible = self.MaterialMode == "Frosted" and not self.Unloaded and not self.IsMinimized
    for decoration in pairs(self.MaterialDecorations) do
        pcall(function() decoration.Visible = visible end)
    end
end

function Library:SetMaterialMode(mode)
    mode = tostring(mode or "Solid")
    if mode ~= "Solid" and mode ~= "Frosted" then
        return false, "Unknown material mode: " .. mode
    end
    self.MaterialMode = mode
    for instance, state in pairs(self.MaterialRegistry) do
        pcall(function()
            local property = state.Property or "BackgroundTransparency"
            Utility:Tween(instance, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                [property] = self:ResolveMaterialTransparency(state)
            })
        end)
    end
    self:RefreshMaterialVisibility()
    return true
end

