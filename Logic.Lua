local function LoadLibrary()
    -- Ensure we don't crash if HttpGet fails (returns nil)
    local URL = "https://raw.githubusercontent.com/renardiusse/RenLib/main/RenLib.lua"
    
    local success, response = pcall(function()
        return game:HttpGet(URL)
    end)

    if not success or type(response) ~= "string" then
        warn("RenLib Error: Failed to fetch library from GitHub.")
        warn("URL:", URL)
        return nil
    end

    local loader, syntaxErr = loadstring(response)
    if not loader then
        warn("RenLib Syntax Error:", syntaxErr)
        return nil
    end
    
    return loader()
end

local Library = LoadLibrary()
if not Library then return end

local Window = Library:CreateWindow({
    Name = "RenLib Hub | v2.0"
})

local MainTab = Window:CreateTab({ Name = "Main", Icon = "rbxassetid://4483345998" })
local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "rbxassetid://4483345998" })
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "rbxassetid://4483345998" })

--// Main Section
local Combat = MainTab:CreateSection({ Name = "Combat" })

Combat:CreateToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(state)
        print("Silent Aim:", state)
    end
})

Combat:CreateButton({
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

Combat:CreateSlider({
    Name = "FOV Radius",
    Min = 0, 
    Max = 360, 
    Default = 90,
    Callback = function(val)
        -- print("FOV:", val)
    end
})

Combat:CreateDropdown({
    Name = "Target Part",
    Values = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(val)
        print("Target:", val)
    end
})

--// Visuals Section
local ESP = VisualsTab:CreateSection({ Name = "ESP Settings" })

ESP:CreateColorPicker({
    Name = "Enemy Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        -- print("Color:", color)
    end
})

ESP:CreateKeybind({
    Name = "Toggle Menu",
    Default = Enum.KeyCode.RightShift,
    Mode = "Toggle",
    Callback = function(state)
        print("Menu Toggled:", state)
    end
})

--// Notification Test
Library:Notify({
    Title = "RenLib",
    Content = "Library Loaded Successfully",
    Duration = 5
})
