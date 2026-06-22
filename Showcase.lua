local RenLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xsakyx/RobloxUILib/main/RenLib.lua"
))()

RenLib:ApplyThemePreset("Prism Frost")

local Window = RenLib:CreateWindow({
    Name = "RenLib V7 Framework Showcase",
    SettingsIcon = "6031280882",
    ShowUserProfile = true,
    ProfileSubtitle = "Harmony session",
    EnableGlobalSearch = true,
    EnableSidebarResize = true,
    SidebarMode = "Dynamic",
    MaterialMode = "Frosted",
    MaterialIntensity = 18,
})

Window:CreateTabCategory("Playground")
local Elements = Window:CreateTab({Name = "Elements", Icon = "6034328955"})
local Core = Elements:CreateSection({Name = "Core controls", Side = "Left", Icon = "6031280882"})
local Nested = Elements:CreateSection({Name = "Nested composition", Side = "Right", Icon = "6034328955"})

Core:CreateParagraph({
    Title = "Hierarchy you can feel",
    Content = "Sections, inner surfaces, controls, and active states now have distinct depth instead of being separated by one lonely line.",
})
Core:CreateToggle({Name = "Enabled", Flag = "DemoEnabled", Default = true, Tooltip = "Tooltips work with a mouse and with a touch-and-hold gesture."})
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
        Title = "RenLib V7",
        Content = "Central navigation, safe search, and framework controls are active.",
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
Actions:CreateButton({Name = "Open prompt", Description = "Validated text input without building a custom modal.", Icon = "6031068426", Callback = function()
    Window:Prompt({
        Title = "Rename this session",
        Content = "The value must contain at least three characters.",
        Placeholder = "Session name",
        Validate = function(value)
            if #value < 3 then return false, "Please enter at least three characters." end
            return true
        end,
        Callback = function(value) Window:SetTitle(value) end,
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

Window:CreateTabCategory("Framework")
local FrameworkTab = Window:CreateTab({Name = "Framework", Icon = RenLib.Icons.Layers})
local Composition = FrameworkTab:CreateSection({Name = "Composition", Side = "Left", Icon = RenLib.Icons.Layers})
local Data = FrameworkTab:CreateSection({Name = "Data controls", Side = "Right", Icon = RenLib.Icons.Dashboard})

local CombatGroup = Composition:CreateGroup({
    Name = "Collapsible group",
    Tooltip = "Groups can contain normal controls, nested groups, or data controls.",
})
CombatGroup:CreateToggle({Name = "Safe mode", Flag = "DemoSafeMode", Default = true})
CombatGroup:CreateSlider({Name = "Range", Flag = "DemoRange", Min = 1, Max = 100, Default = 35, CallbackMode = "Release"})
CombatGroup:CreateDropdown({Name = "Strategy", Flag = "DemoStrategy", Values = {"Balanced", "Fast", "Careful"}})

local LoadingButton
LoadingButton = Composition:CreateButton({
    Name = "Simulate async work",
    Description = "Every control receives the same loading lifecycle.",
    Tooltip = "Loading overlays lock visual interaction while work is pending.",
    Callback = function()
        LoadingButton:SetLoading(true, "Fetching data…")
        task.delay(1.5, function() LoadingButton:SetLoading(false) end)
    end,
})
Composition:CreateKeyPicker({Name = "Showcase shortcut", Flag = "DemoShortcut", Default = "P", Mode = "Toggle"})
Composition:CreateButton({Name = "Open keybind manager", Callback = function() RenLib.KeybindManager:Show() end})
Composition:CreateSkeleton({Name = "Loading card", Lines = 3})

Data:CreateList({
    Name = "Deploy targets",
    Items = {
        {Label = "Production", Description = "Stable public release", Value = "production"},
        {Label = "Beta", Description = "Early access testers", Value = "beta"},
        {Label = "Local", Description = "Current Roblox session", Value = "local"},
    },
})
Data:CreateTable({
    Name = "Performance budget",
    Columns = {{Key = "area", Name = "Area"}, {Key = "budget", Name = "Budget"}, {Key = "state", Name = "State"}},
    Rows = {
        {area = "Navigation", budget = "< 1 ms", state = "Ready"},
        {area = "Search", budget = "Indexed", state = "Ready"},
        {area = "Layout", budget = "Responsive", state = "Ready"},
    },
    Height = 168,
})
Data:CreatePlayerList({Name = "Players in server", Height = 148})

local Console = Data:CreateLogConsole({Name = "Runtime log", Height = 174, MaxLines = 40})
Console:Success("RenLib V7 initialized")
Console:Log("Search highlights matches without hiding controls")
Console:Warn("This is a demonstration warning")

RenLib:RegisterAddon("ShowcaseLogger", {
    AutoStart = true,
    Start = function() Console:Success("ShowcaseLogger addon started") end,
    Stop = function() if Console and Console.Holder.Parent then Console:Log("ShowcaseLogger addon stopped") end end,
})

RenLib:Notify({Title = "Framework loaded", Content = "RenLib V7 showcase is ready. Search a control and press Enter to jump through matches.", Duration = 5})
