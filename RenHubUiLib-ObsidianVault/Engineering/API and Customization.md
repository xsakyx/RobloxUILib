# API and Customization

## Custom window and settings icons

```lua
local Window = RenLib:CreateWindow({
    Name = "My Hub",
    Icon = "1234567890",
    SettingsIcon = "9876543210",
})
```

Numeric strings, numbers, `rbxassetid://` values, and HTTPS image URLs are normalized by the asset helper.

## Custom tab and button icons

```lua
local Main = Window:CreateTab({Name = "Main", Icon = "1234567890"})

Section:CreateButton({
    Name = "Run action",
    Description = "Optional supporting copy.",
    Icon = "9876543210",
    Callback = function() end,
})
```

When no tab icon or emoji is supplied, RenLib uses its default home icon.

## Profile surface

```lua
local Window = RenLib:CreateWindow({
    ShowUserProfile = true,
    ProfileUserId = game.Players.LocalPlayer.UserId,
    ProfileTitle = "Display name override",
    ProfileSubtitle = "Custom status",
    ProfileAvatar = "1234567890", -- optional; otherwise Roblox thumbnail
    OnProfileClick = function(player) end,
})

Window:SetProfile({Title = "New title", Subtitle = "Ready", Avatar = "1234567890"})
```

## Safe scaling

```lua
RenLib:PreviewDPIScale(125, 10)
RenLib:KeepDPIScale()
RenLib:RevertDPIScale()
```

The built-in settings slider uses preview mode automatically.
## Material

```lua
RenLib:SetMaterialMode("Frosted") -- or "Solid"
RenLib:SetMaterialIntensity(18)   -- 0..32, capped lower on mobile
```

The window also accepts `MaterialMode` and `MaterialIntensity` at creation.

## Navigation groups

```lua
Window:CreateTabCategory("Playground")
local Tab = Window:CreateTab({Name = "Elements", Icon = "6034328955"})
```

Category labels are hidden in compact navigation so icons retain the available space.

## Dashboard

```lua
local Dashboard = Window:CreateDashboard({
    Name = "Overview",
    Greeting = "Welcome back",
    Subtitle = "Everything useful in one glance",
    Cards = {
        {
            Name = "Session",
            Side = "Left",
            Metrics = {
                {Name = "Players", Value = "12", Detail = "Currently connected"},
            },
        },
    },
})

Dashboard:AddCard({Name = "Quick actions", Side = "Right"})
Dashboard:SetGreeting("Good evening")
Dashboard:SetSubtitle("Ready")
Dashboard:SetAvatar("1234567890")
```

## Nested controls

```lua
local Parent = Section:CreateToggle({Name = "Advanced", Default = true})
local Mode = Section:CreateDropdown({Name = "Mode", Values = {"Safe", "Fast"}})
local Color = Section:CreateColorPicker({Name = "Accent"})

Parent:AddNested(Mode):AddNested(Color)
Parent:SetNestedVisible(true)
```

The child is created normally, then transferred into the parent's nested surface. Expansion and size changes propagate to the section and page.

## Multi-select dropdown

```lua
local Roles = Section:CreateMultiDropdown({
    Name = "Roles",
    Values = {"Builder", "Scout", "Tester"},
    Default = {"Builder", "Tester"},
})

Roles:GetList()
Roles:SelectAll()
Roles:Clear()
```

`CreateDropdown({Multi = true})` remains supported.

## Metrics

```lua
local Metric = Section:CreateMetric({
    Name = "Latency",
    Value = "48 ms",
    Detail = "Healthy",
})

Metric:SetValue("52 ms")
Metric:SetDetail("Stable")
```
