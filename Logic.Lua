
local Library = loadfile("RobloxUILib/libraryui.lua")()

local Window = Library:CreateWindow({
    Name = "Universal Hub | v2.0"
})

local MainTab = Window:AddTab({ Name = "Main", Icon = "rbxassetid://4483345998" })
local VisualsTab = Window:AddTab({ Name = "Visuals", Icon = "rbxassetid://4483345998" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "rbxassetid://4483345998" })

--// Main Section
local Combat = MainTab:AddSection({ Name = "Combat" })

Combat:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(state)
        print("Silent Aim:", state)
    end
})

Combat:AddButton({
    Name = "Kill All",
    Callback = function()
        Library:Notify({
            Title = "Combat",
            Content = "Eliminating enemies...",
            Duration = 2,
            Image = "rbxassetid://4483345998"
        })
    end
})

Combat:AddSlider({
    Name = "FOV Radius",
    Min = 0, 
    Max = 360, 
    Default = 90,
    Callback = function(val)
        -- print("FOV:", val)
    end
})

Combat:AddDropdown({
    Name = "Target Part",
    Values = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(val)
        print("Target:", val)
    end
})

--// Visuals Section
local ESP = VisualsTab:AddSection({ Name = "ESP Settings" })

ESP:AddColorPicker({
    Name = "Enemy Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        -- print("Color:", color)
    end
})

ESP:AddKeybind({
    Name = "Toggle Menu",
    Default = Enum.KeyCode.RightShift,
    Mode = "Toggle",
    Callback = function(state)
        print("Menu Toggled:", state)
    end
})

--// Notification Test
Library:Notify({
    Title = "Welcome",
    Content = "Universal UI Library v2.0 Loaded",
    Duration = 5
})
