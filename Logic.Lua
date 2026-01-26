-- RenLib Complete Test Script
-- Tests all components and features

local function LoadLibrary()
    local URL = "https://raw.githubusercontent.com/xsakyx/RenLib/main/RenLib.lua"
    
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

print("[RenLib] Library loaded successfully!")

-- Create Window
local Window = Library:CreateWindow({
    Name = "RenLib Hub | v3.0 FIXED",
    LoadingTitle = "Loading..."
})

--------------------------------------------------------------------------------
-- MAIN TAB - Combat & Movement
--------------------------------------------------------------------------------
local MainTab = Window:CreateTab({ 
    Name = "Main", 
    Icon = "rbxassetid://4483345998" 
})

local Combat = MainTab:CreateSection({ Name = "Combat Features", Side = "Left" })

Combat:CreateButton({
    Name = "Test Button",
    Callback = function()
        Library:Notify({
            Title = "Button Clicked!",
            Content = "Button callback executed successfully",
            Duration = 2
        })
    end
})

Combat:CreateToggle({
    Name = "Silent Aim",
    Default = false,
    Flag = "SilentAim",
    Callback = function(state)
        print("[Combat] Silent Aim:", state)
        Library:Notify({
            Title = "Silent Aim",
            Content = state and "Enabled" or "Disabled",
            Duration = 1.5
        })
    end
})

Combat:CreateToggle({
    Name = "Aimbot",
    Default = false,
    Flag = "Aimbot",
    Callback = function(state)
        print("[Combat] Aimbot:", state)
    end
})

Combat:CreateSlider({
    Name = "FOV Radius",
    Min = 0, 
    Max = 360, 
    Default = 90,
    Flag = "FOV",
    Callback = function(val)
        print("[Combat] FOV:", val)
    end
})

Combat:CreateSlider({
    Name = "Prediction",
    Min = 0, 
    Max = 100, 
    Default = 50,
    Flag = "Prediction",
    Callback = function(val)
        print("[Combat] Prediction:", val / 100)
    end
})

Combat:CreateDropdown({
    Name = "Target Part",
    Values = {"Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm"},
    Default = "Head",
    Flag = "TargetPart",
    Callback = function(val)
        print("[Combat] Target Part:", val)
    end
})

Combat:CreateDropdown({
    Name = "Resolver Mode",
    Values = {"None", "Basic", "Advanced", "Custom"},
    Default = "None",
    Flag = "Resolver",
    Callback = function(val)
        print("[Combat] Resolver:", val)
    end
})

local Movement = MainTab:CreateSection({ Name = "Movement", Side = "Right" })

Movement:CreateToggle({
    Name = "Speed Boost",
    Default = false,
    Flag = "SpeedBoost",
    Callback = function(state)
        print("[Movement] Speed Boost:", state)
        if state then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

Movement:CreateSlider({
    Name = "Walk Speed",
    Min = 16, 
    Max = 200, 
    Default = 16,
    Flag = "WalkSpeed",
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        print("[Movement] WalkSpeed:", val)
    end
})

Movement:CreateSlider({
    Name = "Jump Power",
    Min = 50, 
    Max = 200, 
    Default = 50,
    Flag = "JumpPower",
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
        print("[Movement] JumpPower:", val)
    end
})

Movement:CreateToggle({
    Name = "Infinite Jump",
    Default = false,
    Flag = "InfJump",
    Callback = function(state)
        print("[Movement] Infinite Jump:", state)
    end
})

Movement:CreateButton({
    Name = "Reset Character",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
        Library:Notify({
            Title = "Movement",
            Content = "Character reset",
            Duration = 2
        })
    end
})

--------------------------------------------------------------------------------
-- VISUALS TAB - ESP & UI Customization
--------------------------------------------------------------------------------
local VisualsTab = Window:CreateTab({ 
    Name = "Visuals", 
    Icon = "rbxassetid://4483345998" 
})

local ESP = VisualsTab:CreateSection({ Name = "ESP Settings", Side = "Left" })

ESP:CreateToggle({
    Name = "Box ESP",
    Default = false,
    Flag = "BoxESP",
    Callback = function(state)
        print("[ESP] Box ESP:", state)
    end
})

ESP:CreateToggle({
    Name = "Name ESP",
    Default = false,
    Flag = "NameESP",
    Callback = function(state)
        print("[ESP] Name ESP:", state)
    end
})

ESP:CreateToggle({
    Name = "Health ESP",
    Default = false,
    Flag = "HealthESP",
    Callback = function(state)
        print("[ESP] Health ESP:", state)
    end
})

ESP:CreateToggle({
    Name = "Distance ESP",
    Default = false,
    Flag = "DistanceESP",
    Callback = function(state)
        print("[ESP] Distance ESP:", state)
    end
})

ESP:CreateColorPicker({
    Name = "Enemy Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "EnemyColor",
    Callback = function(color)
        print("[ESP] Enemy Color:", color)
    end
})

ESP:CreateColorPicker({
    Name = "Team Color",
    Default = Color3.fromRGB(0, 255, 0),
    Flag = "TeamColor",
    Callback = function(color)
        print("[ESP] Team Color:", color)
    end
})

ESP:CreateSlider({
    Name = "ESP Distance",
    Min = 100, 
    Max = 2000, 
    Default = 1000,
    Flag = "ESPDistance",
    Callback = function(val)
        print("[ESP] Max Distance:", val)
    end
})

local UI = VisualsTab:CreateSection({ Name = "UI Customization", Side = "Right" })

UI:CreateColorPicker({
    Name = "Accent Color",
    Default = Color3.fromRGB(0, 150, 255),
    Flag = "AccentColor",
    Callback = function(color)
        print("[UI] Accent Color:", color)
        Library.Theme.Accent = color
    end
})

UI:CreateToggle({
    Name = "Show FPS",
    Default = false,
    Flag = "ShowFPS",
    Callback = function(state)
        print("[UI] Show FPS:", state)
    end
})

UI:CreateToggle({
    Name = "Show Ping",
    Default = false,
    Flag = "ShowPing",
    Callback = function(state)
        print("[UI] Show Ping:", state)
    end
})

UI:CreateDropdown({
    Name = "Theme",
    Values = {"Dark", "Light", "Blue", "Purple", "Red"},
    Default = "Dark",
    Flag = "Theme",
    Callback = function(val)
        print("[UI] Theme:", val)
    end
})

UI:CreateLabel("UI settings apply instantly")
UI:CreateLabel("Created by RenLib Team")

--------------------------------------------------------------------------------
-- MISC TAB - Utilities & Tools
--------------------------------------------------------------------------------
local MiscTab = Window:CreateTab({ 
    Name = "Misc", 
    Icon = "rbxassetid://4483345998" 
})

local Utilities = MiscTab:CreateSection({ Name = "Utilities", Side = "Left" })

Utilities:CreateToggle({
    Name = "Anti AFK",
    Default = false,
    Flag = "AntiAFK",
    Callback = function(state)
        print("[Misc] Anti AFK:", state)
    end
})

Utilities:CreateToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(state)
        print("[Misc] Auto Farm:", state)
        if state then
            Library:Notify({
                Title = "Auto Farm",
                Content = "Farming started",
                Duration = 2
            })
        else
            Library:Notify({
                Title = "Auto Farm",
                Content = "Farming stopped",
                Duration = 2
            })
        end
    end
})

Utilities:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            game.Players.LocalPlayer
        )
    end
})

Utilities:CreateButton({
    Name = "Copy JobId",
    Callback = function()
        setclipboard(game.JobId)
        Library:Notify({
            Title = "Success",
            Content = "JobId copied to clipboard",
            Duration = 2
        })
    end
})

Utilities:CreateTextbox({
    Name = "Custom Status",
    Default = "",
    Placeholder = "Enter status message...",
    Flag = "CustomStatus",
    Callback = function(text, enter)
        if enter then
            print("[Misc] Custom Status:", text)
            Library:Notify({
                Title = "Status Set",
                Content = text,
                Duration = 3
            })
        end
    end
})

local Tools = MiscTab:CreateSection({ Name = "Developer Tools", Side = "Right" })

Tools:CreateButton({
    Name = "Copy Game ID",
    Callback = function()
        setclipboard(tostring(game.PlaceId))
        Library:Notify({
            Title = "Copied",
            Content = "Game ID: " .. game.PlaceId,
            Duration = 2
        })
    end
})

Tools:CreateButton({
    Name = "Print Player Stats",
    Callback = function()
        local plr = game.Players.LocalPlayer
        print("========== PLAYER STATS ==========")
        print("Username:", plr.Name)
        print("DisplayName:", plr.DisplayName)
        print("UserId:", plr.UserId)
        print("Health:", plr.Character.Humanoid.Health)
        print("WalkSpeed:", plr.Character.Humanoid.WalkSpeed)
        print("JumpPower:", plr.Character.Humanoid.JumpPower)
        print("==================================")
        
        Library:Notify({
            Title = "Stats Printed",
            Content = "Check console (F9)",
            Duration = 2
        })
    end
})

Tools:CreateToggle({
    Name = "Debug Mode",
    Default = false,
    Flag = "DebugMode",
    Callback = function(state)
        print("[Tools] Debug Mode:", state)
    end
})

Tools:CreateSlider({
    Name = "Test Slider",
    Min = 0, 
    Max = 100, 
    Default = 50,
    Flag = "TestSlider",
    Callback = function(val)
        print("[Tools] Test Slider:", val)
    end
})

Tools:CreateDropdown({
    Name = "Test Dropdown",
    Values = {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5"},
    Default = "Option 1",
    Flag = "TestDropdown",
    Callback = function(val)
        print("[Tools] Test Dropdown:", val)
    end
})

--------------------------------------------------------------------------------
-- SETTINGS TAB - Keybinds & Config
--------------------------------------------------------------------------------
local SettingsTab = Window:CreateTab({ 
    Name = "Settings", 
    Icon = "rbxassetid://4483345998" 
})

local Keybinds = SettingsTab:CreateSection({ Name = "Keybinds", Side = "Left" })

Keybinds:CreateKeybind({
    Name = "Toggle Menu",
    Default = Enum.KeyCode.RightShift,
    Mode = "Toggle",
    Flag = "MenuToggle",
    Callback = function(state)
        print("[Keybind] Menu Toggle:", state)
        Window.Main.Visible = state
    end
})

Keybinds:CreateKeybind({
    Name = "Panic Key",
    Default = Enum.KeyCode.Delete,
    Mode = "Press",
    Flag = "PanicKey",
    Callback = function()
        print("[Keybind] Panic Key Pressed!")
        Library:Unload()
        Library:Notify({
            Title = "Panic!",
            Content = "Script unloaded",
            Duration = 2
        })
    end
})

Keybinds:CreateKeybind({
    Name = "Aimbot Toggle",
    Default = Enum.KeyCode.Q,
    Mode = "Toggle",
    Flag = "AimbotToggle",
    Callback = function(state)
        print("[Keybind] Aimbot:", state)
    end
})

Keybinds:CreateKeybind({
    Name = "Silent Aim Key",
    Default = Enum.KeyCode.E,
    Mode = "Held",
    Flag = "SilentHold",
    Callback = function(state)
        print("[Keybind] Silent Aim Held:", state)
    end
})

local Config = SettingsTab:CreateSection({ Name = "Configuration", Side = "Right" })

Config:CreateLabel("Save/Load your settings")

Config:CreateTextbox({
    Name = "Config Name",
    Default = "default",
    Placeholder = "Enter config name...",
    Flag = "ConfigName",
    Callback = function(text)
        print("[Config] Name set:", text)
    end
})

Config:CreateButton({
    Name = "Save Config",
    Callback = function()
        local name = Library.Flags["ConfigName"] or "default"
        Library:SaveConfig(name)
    end
})

Config:CreateButton({
    Name = "Load Config",
    Callback = function()
        local name = Library.Flags["ConfigName"] or "default"
        Library:LoadConfig(name)
    end
})

Config:CreateButton({
    Name = "Reset to Defaults",
    Callback = function()
        Library.Flags = {}
        Library:Notify({
            Title = "Reset",
            Content = "All settings reset to defaults",
            Duration = 2
        })
    end
})

Config:CreateButton({
    Name = "Unload Script",
    Callback = function()
        Library:Unload()
        Library:Notify({
            Title = "Unloaded",
            Content = "Script has been unloaded",
            Duration = 2
        })
    end
})

--------------------------------------------------------------------------------
-- FINAL NOTIFICATIONS
--------------------------------------------------------------------------------
task.wait(0.5)

Library:Notify({
    Title = "RenLib Loaded",
    Content = "All features initialized successfully!",
    Duration = 4,
    Image = "rbxassetid://4483345998"
})

task.wait(1)

Library:Notify({
    Title = "Welcome!",
    Content = "Press RightShift to toggle menu",
    Duration = 3
})

print("[RenLib] All components loaded successfully!")
print("[RenLib] Keybinds registered:", #Library.Keybinds)
print("[RenLib] Flags created:", #Library.Flags)
print("[RenLib] Ready to use!")
