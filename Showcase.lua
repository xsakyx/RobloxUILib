local RenLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xsakyx/RobloxUILib/main/RenLib.lua"
))()

local Window = RenLib:CreateWindow({
    Name = "RenLib V6 Showcase",
    EnableGlobalSearch = true,
    EnableSidebarResize = true,
})

local Home = Window:CreateTab({Name = "Home", Emoji = "H"})
local Overview = Home:CreateSection({Name = "Overview", Side = "Left"})
local Actions = Home:CreateSection({Name = "Actions", Side = "Right"})

Overview:CreateParagraph({
    Title = "Welcome to RenLib V6",
    Content = "Resize or rotate the viewport to see this layout switch between two columns and one.",
})
Overview:CreateToggle({Name = "Enabled", Flag = "DemoEnabled", Default = true})
Overview:CreateSlider({Name = "Intensity", Flag = "DemoIntensity", Min = 0, Max = 10, Step = 0.5, Default = 4.5})
Overview:CreateDropdown({Name = "Mode", Flag = "DemoMode", Values = {"Calm", "Fast", "Wild"}, Default = "Calm"})
Overview:CreateInput({Name = "Message", Flag = "DemoMessage", Placeholder = "Say something..."})
Overview:CreateColorPicker({Name = "Favorite color", Flag = "DemoColor", Default = Color3.fromRGB(89, 171, 255)})

Actions:CreateButton({Name = "Show notification", Callback = function()
    RenLib:Notify({
        Title = "RenLib V6",
        Content = "Notifications can now include actions and progress.",
        Duration = 6,
        Actions = {{Name = "Nice"}},
    })
end})
Actions:CreateButton({Name = "Open dialog", Callback = function()
    Window:Dialog({
        Title = "Try the dialog API",
        Content = "Dialogs are responsive and support any number of actions.",
        Actions = {{Name = "Close"}, {Name = "Confirm", Primary = true}},
    })
end})
Actions:CreateButton({Name = "Use Nebula theme", Callback = function() RenLib:ApplyThemePreset("Nebula") end})
Actions:CreateButton({Name = "Save demo config", Callback = function() RenLib:SaveConfig("showcase") end})

RenLib:Notify({Title = "Loaded", Content = "RenLib V6 showcase is ready.", Duration = 4})
