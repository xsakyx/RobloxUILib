local RenLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xsakyx/RobloxUILib/main/RenLib.lua"
))()

local Window = RenLib:CreateWindow({
    Name = "RenLib V6.2 Showcase",
    Icon = "6034316009",
    SettingsIcon = "6031280882",
    ShowUserProfile = true,
    ProfileSubtitle = "Showcase session",
    EnableGlobalSearch = true,
    EnableSidebarResize = true,
})

local Home = Window:CreateTab({Name = "Home", Icon = "9080449299"})
local Overview = Home:CreateSection({Name = "Overview", Side = "Left"})
local Actions = Home:CreateSection({Name = "Actions", Side = "Right"})

Overview:CreateParagraph({
    Title = "Welcome to RenLib V6.2",
    Content = "Try a narrow Roblox window, expand the color picker, preview a new UI scale, and replace any example icon with your own Roblox image ID.",
})
Overview:CreateToggle({Name = "Enabled", Flag = "DemoEnabled", Default = true})
Overview:CreateSlider({Name = "Intensity", Flag = "DemoIntensity", Min = 0, Max = 10, Step = 0.5, Default = 4.5, CallbackMode = "Release"})
Overview:CreateDropdown({Name = "Mode", Flag = "DemoMode", Values = {"Calm", "Fast", "Wild"}, Default = "Calm"})
Overview:CreateInput({Name = "Message", Flag = "DemoMessage", Placeholder = "Say something..."})
Overview:CreateColorPicker({Name = "Favorite color", Flag = "DemoColor", Default = Color3.fromRGB(89, 171, 255)})

Actions:CreateButton({Name = "Show notification", Description = "Exercise actions and timed progress.", Icon = "6034304908", Callback = function()
    RenLib:Notify({
        Title = "RenLib V6.2",
        Content = "Notifications can now include actions and progress.",
        Duration = 6,
        Actions = {{Name = "Nice"}},
    })
end})
Actions:CreateButton({Name = "Open dialog", Description = "Responsive confirmation surface.", Icon = "6031094678", Callback = function()
    Window:Dialog({
        Title = "Try the dialog API",
        Content = "Dialogs are responsive and support any number of actions.",
        Actions = {{Name = "Close"}, {Name = "Confirm", Primary = true}},
    })
end})
Actions:CreateButton({Name = "Use Aurora theme", Icon = "6034316009", Callback = function() RenLib:ApplyThemePreset("Aurora") end})
Actions:CreateButton({Name = "Preview 125% scale", Description = "Auto-reverts after 10 seconds unless kept.", Icon = "6031260800", Callback = function() RenLib:PreviewDPIScale(125, 10) end})
Actions:CreateButton({Name = "Save demo config", Icon = "6023426951", Callback = function() RenLib:SaveConfig("showcase") end})

RenLib:Notify({Title = "Loaded", Content = "RenLib V6.2 showcase is ready.", Duration = 4})
