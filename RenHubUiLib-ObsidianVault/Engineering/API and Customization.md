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
