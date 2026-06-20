local RenLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xsakyx/RobloxUILib/main/RenLib.lua"
))()

RenLib:ApplyThemePreset("Prism Frost")

local Window = RenLib:CreateWindow({
    Name = "RenLib V6.5 Motion & Coherence Showcase",
    SettingsIcon = "6031280882",
    ShowUserProfile = true,
    ProfileSubtitle = "Harmony session",
    EnableGlobalSearch = true,
    EnableSidebarResize = true,
    SidebarMode = "Dynamic",
    MaterialMode = "Frosted",
    MaterialIntensity = 18,
})

Window:CreateTabCategory("Start")
local Dashboard = Window:CreateDashboard({
    Name = "Overview",
    Greeting = "Welcome back, " .. game:GetService("Players").LocalPlayer.DisplayName,
    Subtitle = "Your RenLib control center · everything useful stays one glance away",
    Cards = {
        {
            Name = "Interface health",
            Side = "Left",
            Icon = "6034287594",
            Description = "Live information about this responsive UI session.",
            Metrics = {
                {Name = "Device mode", Value = RenLib.DeviceMode, Detail = "Reflows automatically as the viewport changes"},
                {Name = "Material", Value = RenLib.MaterialMode, Detail = "Glass stays local to the RenLib window"},
                {Name = "UI scale", Value = math.floor(RenLib.DPIScale * 100) .. "%", Detail = "Protected by the ten-second recovery flow"},
            },
        },
        {
            Name = "Session",
            Side = "Right",
            Icon = "6022668898",
            Metrics = {
                {Name = "Players", Value = tostring(#game:GetService("Players"):GetPlayers()), Detail = "Currently connected"},
                {Name = "Capacity", Value = tostring(game:GetService("Players").MaxPlayers), Detail = "Maximum server size"},
                {Name = "Library", Value = "V" .. RenLib.Version, Detail = "Harmony release"},
            },
        },
        {
            Name = "Quick launch",
            Side = "Right",
            Icon = "6026663699",
            Description = "Jump directly into the full component playground.",
            Action = {
                Name = "Open playground",
                Description = "Nested controls, multi-select, colors, and motion.",
                Icon = "6034328955",
                Callback = function()
                    RenLib:Notify({Title = "Playground", Content = "Choose the Elements tab from the sidebar.", Duration = 3})
                end,
            },
        },
    },
})

Window:CreateTabCategory("Playground")
local Elements = Window:CreateTab({Name = "Elements", Icon = "6034328955"})
local Core = Elements:CreateSection({Name = "Core controls", Side = "Left", Icon = "6031280882"})
local Nested = Elements:CreateSection({Name = "Nested composition", Side = "Right", Icon = "6034328955"})

Core:CreateParagraph({
    Title = "Hierarchy you can feel",
    Content = "Sections, inner surfaces, controls, and active states now have distinct depth instead of being separated by one lonely line.",
})
Core:CreateToggle({Name = "Enabled", Flag = "DemoEnabled", Default = true})
Core:CreateSlider({Name = "Intensity", Flag = "DemoIntensity", Min = 0, Max = 10, Step = 0.5, Default = 4.5, CallbackMode = "Release"})
Core:CreateDropdown({Name = "Mode", Flag = "DemoMode", Values = {"Calm", "Fast", "Wild"}, Default = "Calm"})
Core:CreateMultiDropdown({
    Name = "Active roles",
    Flag = "DemoRoles",
    Values = {"Scout", "Builder", "Support", "Navigator", "Tester"},
    Default = {"Builder", "Tester"},
})
Core:CreateInput({Name = "Message", Flag = "DemoMessage", Placeholder = "Say something..."})

local AdvancedToggle = Nested:CreateToggle({Name = "Advanced styling", Flag = "DemoAdvanced", Default = true})
local NestedMode = Nested:CreateDropdown({
    Name = "Surface behavior",
    Flag = "DemoSurface",
    Values = {"Quiet", "Raised", "Luminous"},
    Default = "Raised",
})
local NestedColor = Nested:CreateColorPicker({
    Name = "Nested accent",
    Flag = "DemoNestedColor",
    Default = Color3.fromRGB(157, 112, 255),
})
AdvancedToggle:AddNested(NestedMode):AddNested(NestedColor)

local LabelHost = Nested:CreateLabel("A label can host useful controls too")
local LabelMulti = Nested:CreateMultiDropdown({
    Name = "Visible modules",
    Flag = "DemoModules",
    Values = {"Status", "Friends", "Server", "Changelog"},
    Default = {"Status", "Server"},
})
LabelHost:AddNested(LabelMulti)

Window:CreateTabCategory("Actions")
local ActionsTab = Window:CreateTab({Name = "Actions", Icon = "6026663699"})
local Actions = ActionsTab:CreateSection({Name = "Experience controls", Side = "Left", Icon = "6026663699"})
local Themes = ActionsTab:CreateSection({Name = "Original palettes", Side = "Right", Icon = "6034316009"})

Actions:CreateButton({Name = "Show notification", Description = "Exercise actions and timed progress.", Icon = "6034304908", Callback = function()
    RenLib:Notify({
        Title = "RenLib V6.5",
        Content = "Layered surfaces, responsive composition, and frosted material are active.",
        Duration = 6,
        Actions = {{Name = "Lovely"}},
    })
end})
Actions:CreateButton({Name = "Open dialog", Description = "Responsive confirmation surface.", Icon = "6031094678", Callback = function()
    Window:Dialog({
        Title = "Try the dialog API",
        Content = "Dialogs inherit the active palette and remain usable at narrow widths.",
        Actions = {{Name = "Close"}, {Name = "Confirm", Primary = true}},
    })
end})
Actions:CreateButton({Name = "Preview 125% scale", Description = "Auto-reverts after 10 seconds unless kept.", Icon = "6031260800", Callback = function()
    RenLib:PreviewDPIScale(125, 10)
end})
Actions:CreateButton({Name = "Toggle sidebar mode", Description = "Pin the full navigation or return to hover expansion.", Icon = "6031091002", Callback = function()
    Window:SetSidebarMode(Window.SidebarMode == "Expanded" and "Dynamic" or "Expanded")
end})

Themes:CreateButton({Name = "Prism Frost", Description = "Airy ice, warm light, and clear dark text.", Icon = "6034316009", Callback = function()
    RenLib:ApplyThemePreset("Prism Frost")
    RenLib:SetMaterialMode("Frosted")
end})
Themes:CreateButton({Name = "Moss Archive", Description = "Charcoal forest surfaces with sage and parchment.", Icon = "6034316009", Callback = function()
    RenLib:ApplyThemePreset("Moss Archive")
end})
Themes:CreateButton({Name = "Velvet Latte", Description = "Deep indigo with rose, lilac, and blue light.", Icon = "6034316009", Callback = function()
    RenLib:ApplyThemePreset("Velvet Latte")
end})
Themes:CreateButton({Name = "Toggle frosted material", Description = "Switches local glass without blurring the game screen.", Icon = "6034925618", Callback = function()
    RenLib:SetMaterialMode(RenLib.MaterialMode == "Frosted" and "Solid" or "Frosted")
end})

RenLib:Notify({Title = "Coherence loaded", Content = "RenLib V6.5 showcase is ready.", Duration = 4})
