--!nocheck
--!nolint
-- RenLib V9.0 beta feature and regression exercise.
-- Execute after RenLibBêta.lua for local development, or let this script load
-- the beta from GitHub after the branch has been published.

local runtime = (getgenv and getgenv()) or shared or _G
local RenLib = runtime.__RENLIB_V8_RUNTIME
if not RenLib then
    RenLib = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/xsakyx/RobloxUILib/main/RenLibB%C3%AAta.lua"
    ))()
end

local Test = {
    Passed = 0,
    Failed = 0,
    Results = {},
    Actions = 0,
}

local function check(name, condition, detail)
    local passed = condition == true
    Test.Passed = Test.Passed + (passed and 1 or 0)
    Test.Failed = Test.Failed + (passed and 0 or 1)
    table.insert(Test.Results, {Name = name, Passed = passed, Detail = detail})
    print(string.format("[RenLib V9.0 Test] %s  %s%s", passed and "PASS" or "FAIL", name, detail and ("  --  " .. tostring(detail)) or ""))
    return passed
end

check("Correct beta version", RenLib.Version == "9.0.0-beta", RenLib.Version)
RenLib:ApplyThemePreset("Obsidian")
check("Obsidian rework theme", RenLib.ActiveTheme == "Obsidian")

local Window = RenLib:CreateWindow({
    Name = "RenLib V9.0 QA",
    Width = 940,
    Height = 620,
    EnableGlobalSearch = true,
    EnableCommandPalette = true,
    PhoneCompact = true,
    SidebarMode = "Expanded",
    ShowUserProfile = true,
    ProfileSubtitle = "Feature validation session",
})

local CatalogTab = Window:CreateTab({Name = "Catalog", Emoji = "C"})
local AutomationTab = Window:CreateTab({Name = "Automation", Emoji = "A"})
local WorldTab = Window:CreateTab({Name = "World", Emoji = "W"})
local ProfilesTab = Window:CreateTab({Name = "Profiles", Emoji = "P"})
local VisualsTab = Window:CreateTab({Name = "ESP", Emoji = "E"})

CatalogTab:SetStatus("Active", "Catalog is ready")
AutomationTab:SetStatus("Waiting", "Waiting for a target")
WorldTab:SetStatus("Error", "Intentional QA error state")
ProfilesTab:SetStatus("Idle")
VisualsTab:SetStatus("Active", "Object renderer online")
CatalogTab:SetBadge(3, "Accent")
AutomationTab:SetBadge(1, "Warn")
WorldTab:SetBadge(2, "Error")
check("Active tab status", CatalogTab.Status == "active" and CatalogTab.StatusDot.Visible)
check("Waiting tab status", AutomationTab.Status == "waiting" and AutomationTab.StatusDot.Visible)
check("Error tab status", WorldTab.Status == "error" and WorldTab.StatusDot.Visible)
check("Idle tab hides status", ProfilesTab.Status == "idle" and not ProfilesTab.StatusDot.Visible)
check("Tab badge count", CatalogTab.BadgeValue == 3 and CatalogTab.Badge.Visible)
check("Named tab lookup", Window:GetTab("World") == WorldTab)
check("Named tab navigation", Window:SelectTabByName("Automation") == true and Window.ActiveTab == AutomationTab)
check("Tab navigation command", Window.Commands["tab-world"] ~= nil and Window.Commands["tab-profiles"] ~= nil)
check("Tight content density", Window:SetContentDensity("Tight") == true and Window.ContentSpacing == 2)
Window:SetContentDensity("Compact")
Window:SetSectionOutlines(false)

local startAutomation, pauseAutomation, resetAutomation
local Controls = AutomationTab:CreateSection({Name = "Automation controls", Side = "Left"})
local Enabled = Controls:CreateToggle({Name = "Automation enabled", Flag = "QAEnabled", Default = false})
local Radius = Controls:CreateSlider({Name = "Search radius", Flag = "QARadius", Min = 10, Max = 100, Default = 40})
local Density = Controls:CreateDropdown({Name = "Density", Flag = "QADensity", Values = {"Low", "Balanced", "High"}, Default = "Balanced"})
local Label = Controls:CreateInput({Name = "Strategy label", Flag = "QALabel", Default = "Default strategy"})
local _Ping = Controls:CreateButton({
    Id = "qa-ping",
    Name = "Run health check",
    Description = "Used to validate button-to-command registration.",
    Synonyms = {"ping", "pong", "healthcheck"},
    Callback = function() Test.Actions = Test.Actions + 1 end,
})
Controls:CreateButton({Id = "qa-start-automation", Name = "Start / resume", Description = "Runs the visible round simulator.", Synonyms = {"play", "run bot", "resume"}, Callback = function() if startAutomation then startAutomation() end end})
Controls:CreateButton({Id = "qa-pause-automation", Name = "Pause automation", Description = "Freezes the live workflow without resetting it.", Synonyms = {"stop", "hold", "freeze"}, Callback = function() if pauseAutomation then pauseAutomation() end end})
Controls:CreateButton({Id = "qa-reset-automation", Name = "Reset round", Description = "Restarts the simulator and clears its counters.", Synonyms = {"restart", "clear round"}, Callback = function() if resetAutomation then resetAutomation() end end})

Enabled:Set(true)
Radius:Set(90)
Density:Set("High")
Label:Set("Changed")
check("Reset one feature", RenLib:ResetFeature("QAEnabled") and Enabled:Get() == false)
local resetAllOk = RenLib:ResetFeatures({"QARadius", "QADensity", "QALabel"})
check("Reset multiple features", resetAllOk and Radius:Get() == 40 and Density:Get() == "Balanced" and Label:Get() == "Default strategy")
check("Button registered in palette", Window.Commands["qa-ping"] ~= nil)
Window:ExecuteCommand("qa-ping")
check("Command executes button callback", Test.Actions == 1)
local synonymResults = Window:RefreshSearch("healthcheck")
check("Global search indexes synonyms", #synonymResults >= 1)
Window:ClearSearch()

local LiveSection = AutomationTab:CreateSection({Name = "Live round", Side = "Right"})
local RoundProgress = LiveSection:CreateProgressCard({
    Name = "Round automation",
    Status = "Waiting",
    Detail = "Preparing simulator…",
    Step = "Step 0 / 4",
    Metrics = "Score: 0",
    Synonyms = {"round", "progress", "live bot"},
})
local Objectives = LiveSection:CreateChecklist({
    Name = "Round objectives",
    Items = {
        {Id = "scan", Name = "Scan available targets"},
        {Id = "select", Name = "Select the efficient route"},
        {Id = "execute", Name = "Execute the automation"},
        {Id = "score", Name = "Submit score and advance"},
    },
})
local ActivitySection = AutomationTab:CreateSection({Name = "Automation timeline", Side = "Left"})
local Activity = ActivitySection:CreateActivityFeed({Name = "Live activity", Height = 210, MaxEntries = 30})
Activity:Push("Simulator initialized", "Info", "Waiting for the automatic start")
check("Progress card created", RoundProgress.Type == "ProgressCard")
check("Activity feed records entries", #Activity:GetEntries() == 1)
check("Checklist reports progress", Objectives:GetProgress() == 0)

local ESPDemoFolder = Instance.new("Folder")
ESPDemoFolder.Name = "RenLibV9ESPDemo"
ESPDemoFolder.Parent = workspace
local camera = workspace.CurrentCamera
local demoOrigin = camera and camera.CFrame * CFrame.new(0, 0, -34) or CFrame.new(0, 12, 0)

local ObjectTarget = Instance.new("Part")
ObjectTarget.Name = "EnergyCore"
ObjectTarget.Anchored = true
ObjectTarget.CanCollide = false
ObjectTarget.Material = Enum.Material.Neon
ObjectTarget.Color = Color3.fromRGB(72, 210, 190)
ObjectTarget.Size = Vector3.new(3, 3, 3)
ObjectTarget.CFrame = demoOrigin * CFrame.new(-5, 0, 0)
ObjectTarget:SetAttribute("Health", 75)
ObjectTarget:SetAttribute("MaxHealth", 100)
ObjectTarget.Parent = ESPDemoFolder

local RigTarget = Instance.new("Model")
RigTarget.Name = "OptionalSkeletonRig"
RigTarget.Parent = ESPDemoFolder
local function rigPart(name, size, offset)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.SmoothPlastic
    part.Color = Color3.fromRGB(103, 151, 255)
    part.Size = size
    part.CFrame = demoOrigin * CFrame.new(4, 0, 0) * CFrame.new(offset)
    part.Parent = RigTarget
    return part
end
local rigTorso = rigPart("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0))
rigPart("Head", Vector3.new(1.3, 1.3, 1.3), Vector3.new(0, 1.7, 0))
rigPart("Left Arm", Vector3.new(0.8, 2, 0.8), Vector3.new(-1.45, 0, 0))
rigPart("Right Arm", Vector3.new(0.8, 2, 0.8), Vector3.new(1.45, 0, 0))
rigPart("Left Leg", Vector3.new(0.9, 2, 0.9), Vector3.new(-0.55, -2, 0))
rigPart("Right Leg", Vector3.new(0.9, 2, 0.9), Vector3.new(0.55, -2, 0))
RigTarget.PrimaryPart = rigTorso

local ESP = RenLib:CreateESP({
    Enabled = true,
    Skeleton = false,
    BoxStyle = "Corners",
    Highlight = true,
    Tracer = false,
    MaxDistance = 5000,
    VisibilityCheck = true,
})
local ObjectRecord = ESP:Add(ObjectTarget, {Name = "Energy Core", Skeleton = false, Color = Color3.fromRGB(72, 210, 190), Text = "WORLD OBJECT  •  skeleton off"})
local RigRecord = ESP:Add(RigTarget, {Name = "Training Rig", Skeleton = true, Color = Color3.fromRGB(103, 151, 255), Text = "MODEL  •  optional skeleton on"})
check("ESP manager created", ESP.Type == "ESPManager" and ESP.OverlayGui.Parent ~= nil)
check("Non-player object ESP", ObjectRecord and ObjectRecord.Target == ObjectTarget and ObjectRecord.Style.Skeleton == false)
check("Skeleton is independently optional", RigRecord and RigRecord.Style.Skeleton == true and ESP.Options.Skeleton == false)
ESP:SetOption("BoxThickness", 2.25)
check("ESP style updates live records", RigRecord.Style.BoxThickness == 2.25)

local PickupFolder = Instance.new("Folder")
PickupFolder.Name = "Pickups"
PickupFolder.Parent = ESPDemoFolder
local Pickup = Instance.new("Part")
Pickup.Name = "RaidKey"
Pickup.Anchored = true
Pickup.CanCollide = false
Pickup.Size = Vector3.new(1.5, 0.5, 2.5)
Pickup.CFrame = demoOrigin * CFrame.new(0, -4, 0)
Pickup.Parent = PickupFolder
local ObjectTrack = ESP:TrackContainer(PickupFolder, {Skeleton = false, ShowDetails = true, Text = "AUTO-TRACKED PICKUP"})
check("ESP container tracking", ESP:GetRecord(Pickup) ~= nil)

local ESPSection = VisualsTab:CreateSection({Name = "ESP renderer", Side = "Left"})
local ESPPresets = ESPSection:CreateESPPresets({Engine = ESP, Default = "High"})
local ESPControls = ESPSection:CreateESPControls({Engine = ESP, Expanded = false, MaxTargets = 120})
check("ESP presets control real renderer", ESPPresets.Engine == ESP)
check("Full ESP editor created", ESPControls.Type == "ESPControls" and ESPControls.Controls.Skeleton ~= nil)
ESPPresets:SetPreset("Low")
check("ESP density preset applies", ESP.Options.MaxVisible == 12 and ESP.Options.Skeleton == false)
ESPPresets:SetPreset("High")

local ItemSection = CatalogTab:CreateSection({Name = "Searchable inventory", Side = "Left"})
local Catalog = ItemSection:CreateCatalog({
    Name = "Upgrade catalog",
    Id = "qa-catalog",
    Items = {
        {
            Id = "iron-blade", Name = "Iron Blade", Description = "Fast starter weapon upgrade.",
            Owned = true, Cost = "250 points", Requirement = "Level 2",
            Synonyms = {"sword", "melee", "starter"},
            Callback = function() Test.Actions = Test.Actions + 1 end,
        },
        {
            Id = "raid-core", Name = "Raid Core", Description = "Unlocks the raid automation API.",
            Owned = false, Cost = "1,200 points", Requirement = function() return false, "Win 3 raids" end,
            Synonyms = {"chip", "raid unlock", "boss"},
        },
        {
            Id = "event-radar", Name = "Event Radar", Description = "Highlights temporary event objectives.",
            Cost = "600 points", Requirement = "Event active", Synonyms = {"seasonal", "event esp"},
        },
    },
})
Catalog:SetQuery("sword")
Catalog:SetQuery("")
Catalog:ToggleFavorite("qa-catalog-iron-blade")
check("Catalog favorite state", #Catalog:GetFavorites() == 1)
local catalogRun = Catalog:Activate("qa-catalog-iron-blade")
check("Catalog action executes", catalogRun == true and Test.Actions == 2)
check("Catalog recent state", #Catalog:GetRecent() >= 1)
Catalog:SetOwned("raid-core", true)
check("Catalog ownership updates", Catalog:GetItems()[2].Owned == true)

local WorkflowSection = CatalogTab:CreateSection({Name = "Ready-made workflows", Side = "Right"})
local Workflows = WorkflowSection:CreateWorkflowPresets({
    Presets = {
        Leveling = {
            Name = "Leveling",
            Description = "Enable safe leveling and balanced ESP.",
            Synonyms = {"xp", "grind", "quest"},
            Flags = {QAEnabled = true, QADensity = "Balanced", QARadius = 70},
        },
        Items = {
            Name = "Items",
            Description = "Use high item visibility.",
            Synonyms = {"loot", "inventory"},
            Flags = {QADensity = "High", QARadius = 90},
        },
        Raids = {
            Name = "Raids",
            Description = "Prepare the raid workflow.",
            Synonyms = {"boss", "chip", "islands"},
            Flags = {QAEnabled = true, QADensity = "Low"},
        },
    },
    Notify = false,
})
local workflowOk = RenLib:ApplyWorkflowPreset("Leveling")
check("Leveling workflow applies flags", workflowOk and Enabled:Get() == true and Density:Get() == "Balanced" and Radius:Get() == 70)
check("Workflow catalog exists", Workflows.Type == "Catalog")
local lowEndOk = RenLib:ApplyWorkflowPreset("LowEnd")
check("Low-end workflow applies UI settings", lowEndOk and RenLib.ReducedMotion and RenLib.MaterialMode == "Solid")
RenLib:SetReducedMotion(false)

local AutomationSection = AutomationTab:CreateSection({Name = "Visibility presets", Side = "Right"})
local VisibilityPresets = AutomationSection:CreateESPPresets({
    Name = "ESP density and focus",
    DensityFlag = "QAESPDensity",
    NearestFlag = "QAESPNearest",
    Default = "Balanced",
})
VisibilityPresets:SetPreset("High")
VisibilityPresets:SetNearestOnly(true)
check("ESP density preset", VisibilityPresets:Get().Preset == "High")
check("ESP nearest-only preset", VisibilityPresets:Get().NearestOnly == true)
VisibilityPresets:Reset()
check("ESP reset", VisibilityPresets:Get().Preset == "Balanced" and VisibilityPresets:Get().NearestOnly == false)

local HUD = Window:CreateAutomationHUD({
    Title = "Leveling workflow",
    Status = "Active",
    StatusText = "Farming level targets",
    Detail = "Nearest target: QA Dummy",
    Progress = 0.42,
    Metrics = "XP/min: 12.4k  •  Errors: 0",
    Dock = "TopRight",
})
HUD:SetProgress(0.75):SetMetrics({Round = 4, Score = 1280})
HUD:SetStatus("Waiting", "Waiting for spawn", "Next scan in 2 seconds")
check("Automation HUD status", HUD.Status == "waiting" and HUD.Holder.Visible)
HUD:SetCollapsed(true)
check("Automation HUD collapse", HUD.Collapsed == true)
HUD:SetCollapsed(false)
local QuickActions = Window:CreateQuickActions({
    Dock = "BottomCenter",
    Actions = {
        {Id = "start", Name = "Start", Status = "Waiting", Synonyms = {"play", "resume"}, Callback = function() if startAutomation then startAutomation() end end},
        {Id = "pause", Name = "Pause", Callback = function() if pauseAutomation then pauseAutomation() end end},
        {Id = "reset", Name = "Reset", Callback = function() if resetAutomation then resetAutomation() end end},
        {Id = "world", Name = "World", Callback = function() WorldTab:Activate() end},
        {Id = "profiles", Name = "Profiles", Callback = function() ProfilesTab:Activate() end},
        {Id = "esp", Name = "ESP", Status = "Active", Callback = function() VisualsTab:Activate() end},
    },
})
check("Quick-action dock created", QuickActions.Type == "QuickActions" and #QuickActions:GetActions() == 6)

local WorldCards = WorldTab:CreateSection({Name = "Context cards", Side = "Left"})
local Boss = WorldCards:CreateBossCard({
    Name = "Clockwork Warden", Status = "Active", Level = 1250,
    Location = "Event Citadel", Drop = "Warden Core", Requirement = "Raid key",
    ActionText = "Track boss", Synonyms = {"warden", "event boss"},
    Callback = function() Test.Actions = Test.Actions + 1 end,
})
Boss:SetStatus("Waiting", "Respawns in 01:30")
check("Boss context updates", Boss:GetContext().Status == "Waiting")

local Islands = WorldTab:CreateSection({Name = "Island types", Side = "Right"})
local PermanentIsland = Islands:CreateIslandCard({Name = "Starter Harbor", Kind = "Permanent", Description = "Always available progression hub."})
local RaidIsland = Islands:CreateIslandCard({Name = "Flame Trial", Kind = "Raid", Description = "Appears during an active raid."})
local EventIsland = Islands:CreateIslandCard({Name = "Meteor Fair", Kind = "Event", Description = "Temporary seasonal destination."})
check("Permanent island kind", PermanentIsland:GetData().Kind == "Permanent")
check("Raid island kind", RaidIsland:GetData().Kind == "Raid")
check("Event island kind", EventIsland:GetData().Kind == "Event")

local ProfileSection = ProfilesTab:CreateSection({Name = "Persistence", Side = "Left"})
local StrategyProfiles = ProfileSection:CreateStrategyProfiles({
    Flags = {"QAEnabled", "QARadius", "QADensity", "QAESPNearest"},
})
Enabled:Set(true)
Radius:Set(55)
local saved, saveError = RenLib:SaveStrategyProfile("QA Strategy", {"QAEnabled", "QARadius", "QADensity"})
check("Named strategy saves", saved, saveError)
Enabled:Set(false)
Radius:Set(10)
local loaded, loadError = RenLib:LoadStrategyProfile("QA Strategy")
check("Named strategy loads", loaded and Enabled:Get() == true and Radius:Get() == 55, loadError)
local profiles = RenLib:GetStrategyProfiles()
check("Named strategy appears in list", table.find(profiles, "QA Strategy") ~= nil)
local deleted, deleteError = RenLib:DeleteStrategyProfile("QA Strategy")
check("Named strategy deletes", deleted, deleteError)
StrategyProfiles:RefreshProfiles()

local AutomationState = {
    Token = 0,
    Running = false,
    Paused = false,
    Round = 1,
    Progress = 0,
    Step = 1,
    Score = 0,
}
Test.Automation = AutomationState
local stepIds = {"scan", "select", "execute", "score"}
local stepNames = {"Scanning targets", "Selecting route", "Executing script", "Submitting score"}

local function applyStep(nextStep)
    nextStep = math.clamp(nextStep, 1, #stepIds)
    if AutomationState.Step ~= nextStep then
        Activity:Push(stepNames[nextStep], "Active", "Round " .. tostring(AutomationState.Round))
    end
    AutomationState.Step = nextStep
    for index, id in ipairs(stepIds) do
        Objectives:SetItemStatus(id, index < nextStep and "Done" or (index == nextStep and "Active" or "Pending"))
    end
end

local function syncAutomation()
    local stateName = AutomationState.Paused and "Paused" or (AutomationState.Running and "Active" or "Waiting")
    local detail = AutomationState.Paused and "Automation paused by user" or stepNames[AutomationState.Step]
    RoundProgress:SetStatus(stateName, detail)
    RoundProgress:SetProgress(AutomationState.Progress, detail)
    RoundProgress:SetStep(AutomationState.Step, #stepIds)
    RoundProgress:SetMetrics({Round = AutomationState.Round, Score = AutomationState.Score})
    HUD:SetTitle("Round " .. tostring(AutomationState.Round) .. " automation")
    HUD:SetStatus(stateName, detail, string.format("Step %d/%d", AutomationState.Step, #stepIds))
    HUD:SetProgress(AutomationState.Progress)
    HUD:SetMetrics({Round = AutomationState.Round, Score = AutomationState.Score})
    AutomationTab:SetStatus(stateName, detail)
    AutomationTab:SetBadge(AutomationState.Round, AutomationState.Paused and "Warn" or "Success")
    QuickActions:SetStatus("start", AutomationState.Running and not AutomationState.Paused and "Active" or "Waiting")
    QuickActions:SetStatus("pause", AutomationState.Paused and "Waiting" or "Idle")
    Boss:SetStatus(AutomationState.Step == 3 and "Active" or "Waiting", AutomationState.Step == 3 and "Automation is engaging the boss" or "Waiting for execution step")
end

pauseAutomation = function()
    if not AutomationState.Running then return false end
    AutomationState.Paused = not AutomationState.Paused
    Activity:Push(AutomationState.Paused and "Automation paused" or "Automation resumed", AutomationState.Paused and "Warning" or "Success")
    syncAutomation()
    return true
end

startAutomation = function()
    if AutomationState.Running then
        AutomationState.Paused = false
        syncAutomation()
        return true
    end
    AutomationState.Token = AutomationState.Token + 1
    local token = AutomationState.Token
    AutomationState.Running = true
    AutomationState.Paused = false
    Activity:Push("Automation started", "Success", "Round " .. tostring(AutomationState.Round))
    applyStep(math.max(1, AutomationState.Step))
    syncAutomation()
    task.spawn(function()
        while token == AutomationState.Token and AutomationState.Running and not RenLib.Unloaded do
            task.wait(0.35)
            if not AutomationState.Paused then
                AutomationState.Progress = math.min(1, AutomationState.Progress + 0.045)
                local nextStep = math.min(#stepIds, math.floor(AutomationState.Progress * #stepIds) + 1)
                applyStep(nextStep)
                AutomationState.Score = AutomationState.Score + math.floor(8 + AutomationState.Step * 2)
                syncAutomation()
                if AutomationState.Progress >= 1 then
                    for _, id in ipairs(stepIds) do Objectives:SetItemStatus(id, "Done") end
                    RoundProgress:Complete("Round completed successfully")
                    Activity:Push("Round " .. tostring(AutomationState.Round) .. " completed", "Success", "Score " .. tostring(AutomationState.Score))
                    task.wait(0.7)
                    if token ~= AutomationState.Token or not AutomationState.Running then break end
                    AutomationState.Round = AutomationState.Round + 1
                    AutomationState.Progress = 0
                    AutomationState.Step = 1
                    applyStep(1)
                    Activity:Push("Round " .. tostring(AutomationState.Round) .. " started", "Active")
                    syncAutomation()
                end
            end
        end
    end)
    return true
end

resetAutomation = function()
    AutomationState.Token = AutomationState.Token + 1
    AutomationState.Running = false
    AutomationState.Paused = false
    AutomationState.Round = 1
    AutomationState.Progress = 0
    AutomationState.Step = 1
    AutomationState.Score = 0
    Objectives:Reset()
    Activity:Push("Automation reset", "Warning")
    syncAutomation()
    return startAutomation()
end

Window:SetSidebarMode("Expanded")
Window:SelectTabByName("Automation", {ResetScroll = true, Animate = false})
startAutomation()
check("Automation simulator is running", AutomationState.Running and HUD.Status == "active")

check("Phone compact API", Window:SetPhoneCompact(false) == Window and Window:SetPhoneCompact(true) == Window)
check("Command palette opens", Window:OpenCommandPalette("xp") == true)
Window:CloseCommandPalette()
local diagnosticsPassed, diagnostics = Window:GetLayoutDiagnostics()
check("Layout diagnostics callable", type(diagnosticsPassed) == "boolean" and type(diagnostics) == "table")

Test.Window = Window
Test.Catalog = Catalog
Test.HUD = HUD
Test.Boss = Boss
Test.ESP = ESP
Test.QuickActions = QuickActions
Test.Progress = RoundProgress
Test.Activity = Activity
Test.Objectives = Objectives
Test.ESPPresets = VisibilityPresets
Test.ObjectESPRecord = ObjectRecord
Test.RigESPRecord = RigRecord
Test.Cleanup = function()
    AutomationState.Token = AutomationState.Token + 1
    AutomationState.Running = false
    if ObjectTrack then ObjectTrack:Stop() end
    if ESP and not ESP.Destroyed then ESP:Destroy() end
    if ESPDemoFolder and ESPDemoFolder.Parent then ESPDemoFolder:Destroy() end
    if QuickActions and QuickActions.Holder and QuickActions.Holder.Parent then QuickActions:Destroy() end
    if HUD and HUD.Holder and HUD.Holder.Parent then HUD:Destroy() end
    RenLib:Unload("V9.0 test cleanup")
end
runtime.__RENLIB_V81_TEST = Test
runtime.__RENLIB_V82_TEST = Test
runtime.__RENLIB_V90_TEST = Test

local summary = string.format("%d passed, %d failed", Test.Passed, Test.Failed)
RenLib:Notify({
    Title = Test.Failed == 0 and "RenLib V9.0 tests passed" or "RenLib V9.0 test failures",
    Content = summary .. ". Automation and the world-object ESP demo are live.",
    Duration = 8,
})
print("[RenLib V9.0 Test] " .. summary)
print("[RenLib V9.0 Test] Manual QA: object/player ESP, optional skeleton, compact sections/cards, live rounds, quick actions, Ctrl+K/Ctrl+Tab, and phone rotation.")

return Test
