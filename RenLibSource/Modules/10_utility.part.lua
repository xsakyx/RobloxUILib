-- Module fragment: utility, assets, animation, responsive helpers
-- Generated from the working V7 baseline; edit this feature in isolation.
--// MODULE: UTILITY (extended)
local Utility = {}

function Library:Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

function Utility:SafeCall(callback, ...)
    if type(callback) ~= "function" then return true end
    local args = table.pack(...)
    local ok, err = xpcall(function()
        callback(table.unpack(args, 1, args.n))
    end, debug.traceback)
    if not ok then
        warn("[RenLib] Callback error:\n" .. tostring(err))
        if Library.Notify and not Library.Unloaded then
            Library:Notify({Title = "Callback error", Content = tostring(err):match("^[^\n]+") or "Unknown error", Duration = 5})
        end
    end
    return ok, err
end

function Utility:RandomString(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

function Utility:NormalizeAssetId(asset, fallback)
    if asset == nil or asset == "" then return fallback end
    local value = tostring(asset)
    if value:match("^%d+$") then
        if tonumber(value) <= 0 then return fallback end
        return "rbxassetid://" .. value
    end
    if value:match("^rbxassetid://%d+$") or value:match("^https?://") then
        return value
    end
    return fallback
end

local THEME_PROPERTY_KEYS = {
    BackgroundColor3 = {"Main", "Secondary", "Surface", "SurfaceAlt", "Hover", "Click", "Accent", "Accent2", "Accent3", "Success", "Warn", "Error", "Divider"},
    TextColor3 = {"Text", "SubText", "Accent", "Accent2", "Accent3", "Success", "Warn", "Error"},
    PlaceholderColor3 = {"SubText", "Text"},
    ImageColor3 = {"Text", "SubText", "Accent", "Accent2", "Accent3", "Success", "Warn", "Error"},
    ScrollBarImageColor3 = {"Accent", "Accent2", "SubText", "Text"},
    Color = {"Stroke", "Divider", "Accent", "Accent2", "Accent3", "Text", "SubText"}
}

local function resolveThemeKey(property, value)
    if typeof(value) ~= "Color3" then return nil end
    for _, key in ipairs(THEME_PROPERTY_KEYS[property] or {}) do
        if Library.Theme[key] == value then return key end
    end
    return nil
end

function Utility:Create(class, properties)
    local instance = Instance.new(class)
    if class == "UIStroke" and properties.Transparency == nil then
        instance.Transparency = 0.24
    end
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            instance[k] = v
        end
    end
    -- Theme registration is automatic for semantic theme colors. Explicit
    -- RegisterProperty calls still override this, but missed labels can no
    -- longer keep a stale color after a preset change.
    for property, value in pairs(properties) do
        local colorKey = resolveThemeKey(property, value)
        if colorKey then
            Library.Registry[instance] = Library.Registry[instance] or {}
            Library.Registry[instance][property] = colorKey
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility:LoadBrandIcon(callback)
    task.spawn(function()
        local resolved = Utility:NormalizeAssetId(BRAND_ICON_ASSET_ID, BRAND_ICON_FALLBACK)
        local preloadOk = pcall(function()
            ContentProvider:PreloadAsync({resolved})
        end)
        if not preloadOk then
            resolved = BRAND_ICON_FALLBACK
        end
        Library.BrandIcon = resolved
        Library.BrandIconTint = nil
        for mark in pairs(Library.BrandMarks) do
            local markOk = pcall(function()
                if mark and mark.Parent then
                    mark.Image = resolved
                    if Library.Registry[mark] then Library.Registry[mark].ImageColor3 = nil end
                    mark.ImageColor3 = Color3.new(1, 1, 1)
                end
            end)
            if not markOk or not mark or not mark.Parent then Library.BrandMarks[mark] = nil end
        end
        if callback then Utility:SafeCall(callback, resolved) end
    end)
end

function Library:SetBrandIcon(asset)
    local resolved = Utility:NormalizeAssetId(asset)
    if not resolved then return false, "Invalid icon asset" end
    BRAND_ICON_ASSET_ID = resolved
    Utility:LoadBrandIcon()
    return true
end

function Utility:Tween(instance, info, properties, callback)
    if not instance or not instance.Parent then return nil end
    local previous = Library.ActiveTweens[instance]
    if previous then
        pcall(function() previous:Cancel() end)
        Library.ActiveTweens[instance] = nil
    end

    local duration = Library.ReducedMotion and 0 or math.max(0, info.Time * Library.MotionScale)
    if duration == 0 then
        for property, value in pairs(properties) do
            instance[property] = value
        end
        if callback then task.defer(callback) end
        return nil
    end

    local tweenInfo = TweenInfo.new(duration, info.EasingStyle, info.EasingDirection, info.RepeatCount, info.Reverses, info.DelayTime)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    Library.ActiveTweens[instance] = tween
    tween:Play()
    Library:Connect(tween.Completed, function(playbackState)
        if Library.ActiveTweens[instance] == tween then
            Library.ActiveTweens[instance] = nil
        end
        if callback and playbackState == Enum.PlaybackState.Completed then callback() end
    end)
    return tween
end

function Utility:StopTween(instance)
    local tween = instance and Library.ActiveTweens[instance]
    if not tween then return false end
    Library.ActiveTweens[instance] = nil
    pcall(function() tween:Cancel() end)
    return true
end

-- Geometry and visual-state animations must not cancel one another. A hover
-- color tween used to stop an in-flight sidebar resize tween, leaving active
-- tabs and profile cards permanently stuck in their compact geometry.
function Utility:TweenLayout(instance, info, properties, callback)
    if not instance or not instance.Parent then return nil end
    local previous = Library.LayoutTweens[instance]
    if previous then
        pcall(function() previous:Cancel() end)
        Library.LayoutTweens[instance] = nil
    end

    local duration = Library.ReducedMotion and 0 or math.max(0, info.Time * Library.MotionScale)
    if duration == 0 then
        for property, value in pairs(properties) do instance[property] = value end
        if callback then task.defer(callback) end
        return nil
    end

    local tweenInfo = TweenInfo.new(duration, info.EasingStyle, info.EasingDirection, info.RepeatCount, info.Reverses, info.DelayTime)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    Library.LayoutTweens[instance] = tween
    tween:Play()
    Library:Connect(tween.Completed, function(playbackState)
        if Library.LayoutTweens[instance] == tween then Library.LayoutTweens[instance] = nil end
        if callback and playbackState == Enum.PlaybackState.Completed then callback() end
    end)
    return tween
end

function Utility:StopLayoutTween(instance)
    local tween = instance and Library.LayoutTweens[instance]
    if not tween then return false end
    Library.LayoutTweens[instance] = nil
    pcall(function() tween:Cancel() end)
    return true
end

function Utility:TweenVisibility(instance, info, properties, callback)
    if not instance or not instance.Parent then return nil end
    local previous = Library.VisibilityTweens[instance]
    if previous then
        pcall(function() previous:Cancel() end)
        Library.VisibilityTweens[instance] = nil
    end
    local duration = Library.ReducedMotion and 0 or math.max(0, info.Time * Library.MotionScale)
    if duration == 0 then
        for property, value in pairs(properties) do instance[property] = value end
        if callback then task.defer(callback) end
        return nil
    end
    local tweenInfo = TweenInfo.new(duration, info.EasingStyle, info.EasingDirection, info.RepeatCount, info.Reverses, info.DelayTime)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    Library.VisibilityTweens[instance] = tween
    tween:Play()
    Library:Connect(tween.Completed, function(playbackState)
        if Library.VisibilityTweens[instance] == tween then Library.VisibilityTweens[instance] = nil end
        if callback and playbackState == Enum.PlaybackState.Completed then callback() end
    end)
    return tween
end

function Utility:StopVisibilityTween(instance)
    local tween = instance and Library.VisibilityTweens[instance]
    if not tween then return false end
    Library.VisibilityTweens[instance] = nil
    pcall(function() tween:Cancel() end)
    return true
end

function Utility:MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    local dragState = {Moved = false}

    function dragState:ConsumeDrag()
        local moved = self.Moved
        self.Moved = false
        return moved
    end

    local function keepRecoverable()
        if not object or not object.Parent then return end
        local viewport = getViewport()
        local position = object.AbsolutePosition
        local size = object.AbsoluteSize
        local minimumVisible = math.min(52, math.max(28, viewport.X * 0.12))
        local deltaX, deltaY = 0, 0
        if position.X + size.X < minimumVisible then
            deltaX = minimumVisible - (position.X + size.X)
        elseif position.X > viewport.X - minimumVisible then
            deltaX = (viewport.X - minimumVisible) - position.X
        end
        if position.Y + 40 < 0 then
            deltaY = -(position.Y + 40)
        elseif position.Y > viewport.Y - minimumVisible then
            deltaY = (viewport.Y - minimumVisible) - position.Y
        end
        if deltaX ~= 0 or deltaY ~= 0 then
            local scale = math.max(0.01, Library.DPIScale)
            object.Position = UDim2.new(
                object.Position.X.Scale,
                object.Position.X.Offset + deltaX / scale,
                object.Position.Y.Scale,
                object.Position.Y.Offset + deltaY / scale
            )
        end
    end

    Library:Connect(topbar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragState.Moved = false
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = object.Position
            dragInput = input.UserInputType == Enum.UserInputType.Touch and input or nil

            Library:Connect(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    task.defer(keepRecoverable)
                end
            end)
        end
    end)

    Library:Connect(topbar.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    Library:Connect(UserInputService.InputChanged, function(input)
        local isPointerMove = input.UserInputType == Enum.UserInputType.MouseMovement
            or (input.UserInputType == Enum.UserInputType.Touch and input == dragInput)
        if dragging and isPointerMove then
            local pointer = Vector2.new(input.Position.X, input.Position.Y)
            local delta = (pointer - dragStart) / math.max(0.01, Library.DPIScale)
            if delta.Magnitude >= 4 then dragState.Moved = true end
            object.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    return dragState
end

function Utility:GetColor(colorKey)
    if type(colorKey) == "string" then
        return Library.Theme[colorKey] or Color3.new(1,1,1)
    end
    return colorKey
end

function Utility:RegisterProperty(instance, property, colorKey)
    if not Library.Registry[instance] then
        Library.Registry[instance] = {}
    end
    Library.Registry[instance][property] = colorKey
    instance[property] = Utility:GetColor(colorKey)
end

local function buildGradient(keys)
    local points = {}
    local count = math.max(#keys, 2)
    for index, key in ipairs(keys) do
        table.insert(points, ColorSequenceKeypoint.new((index - 1) / (count - 1), Utility:GetColor(key)))
    end
    if #points == 1 then
        table.insert(points, ColorSequenceKeypoint.new(1, points[1].Value))
    end
    return ColorSequence.new(points)
end

function Utility:RegisterGradient(instance, ...)
    local keys = {...}
    Library.GradientRegistry[instance] = keys
    instance.Color = buildGradient(keys)
end

function Utility:RegisterMaterial(instance, frostedTransparency, solidTransparency, property)
    property = property or "BackgroundTransparency"
    Library.MaterialRegistry[instance] = {
        Frosted = math.clamp(tonumber(frostedTransparency) or 0.18, 0, 1),
        Solid = math.clamp(tonumber(solidTransparency) or instance[property] or 0, 0, 1),
        Property = property
    }
    local state = Library.MaterialRegistry[instance]
    instance[property] = Library:ResolveMaterialTransparency(state)
end

