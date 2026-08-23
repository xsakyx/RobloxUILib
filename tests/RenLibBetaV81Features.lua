--!nocheck
--!nolint
-- RenLib V9.1 beta feature and regression exercise.
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
    print(string.format("[RenLib V9.1 Test] %s  %s%s", passed and "PASS" or "FAIL", name, detail and ("  --  " .. tostring(detail)) or ""))
    return passed
end

check("Correct beta version", RenLib.Version == "9.1.0-beta", RenLib.Version)
RenLib:ApplyThemePreset("Obsidian")
check("Obsidian rework theme", RenLib.ActiveTheme == "Obsidian")

local Window = RenLib:CreateWindow({
    Name = "RenLib V9.1 QA",
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
local InlineActions = Controls:CreateActionBar({
    Name = "Round controls",
    Category = "Automation",
    Synonyms = {"start", "pause", "reset", "round controls"},
    Actions = {
        {Id = "start", Name = "Start", Status = "Waiting", Synonyms = {"play", "run bot", "resume"}, Callback = function() if startAutomation then startAutomation() end end},
        {Id = "pause", Name = "Pause", Synonyms = {"stop", "hold", "freeze"}, Callback = function() if pauseAutomation then pauseAutomation() end end},
        {Id = "reset", Name = "Reset", Synonyms = {"restart", "clear round"}, Callback = function() if resetAutomation then resetAutomation() end end},
    },
})

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
local RoundBanner = LiveSection:CreateStatusBanner({
    Title = "Round engine ready",
    Status = "Waiting",
    Content = "Use the compact controls to start a live strategy run.",
    Synonyms = {"automation status", "round state", "engine"},
})
local RoundStats = LiveSection:CreateStatGrid({
    Name = "Live round statistics",
    Columns = 2,
    Items = {
        {Id = "round", Name = "Round", Value = 1, Trend = "current", Color = "Accent"},
        {Id = "score", Name = "Score", Value = 0, Trend = "+0", Color = "Accent2"},
        {Id = "efficiency", Name = "Efficiency", Value = "100%", Trend = "stable", Color = "Success"},
        {Id = "errors", Name = "Errors", Value = 0, Trend = "clean", Color = "Success"},
    },
})
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
local ExecutionQueue = ActivitySection:CreateExecutionQueue({
    Name = "Execution queue",
    Height = 205,
    Items = {
        {Id = "scan", Name = "Scan targets", Status = "Waiting"},
        {Id = "select", Name = "Choose route", Status = "Pending"},
        {Id = "execute", Name = "Run user script", Status = "Pending"},
        {Id = "score", Name = "Submit score", Status = "Pending"},
    },
})
local Activity = ActivitySection:CreateActivityFeed({Name = "Live activity", Height = 210, MaxEntries = 30})
Activity:Push("Simulator initialized", "Info", "Waiting for the automatic start")
check("Progress card created", RoundProgress.Type == "ProgressCard")
check("Activity feed records entries", #Activity:GetEntries() == 1)
check("Checklist reports progress", Objectives:GetProgress() == 0)
check("Integrated action bar created", InlineActions.Type == "ActionBar" and #InlineActions:GetActions() == 3)
check("Action bar commands are namespaced", Window.Commands[InlineActions:GetActions()[1].CommandId] ~= nil)
check("Integrated status banner created", RoundBanner.Type == "StatusBanner" and RoundBanner.Status == "waiting")
check("Stat grid created", RoundStats.Type == "StatGrid" and #RoundStats:GetItems() == 4)
check("Execution queue created", ExecutionQueue.Type == "ExecutionQueue" and #ExecutionQueue:GetItems() == 4)

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

check("Floating overlays removed", Window.CreateAutomationHUD == nil and Window.CreateQuickActions == nil)

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

local RankingSection = ProfilesTab:CreateSection({Name = "Round ranking", Side = "Right"})
local RoundLeaderboard = RankingSection:CreateLeaderboard({
    Name = "Efficiency leaderboard",
    Height = 205,
    Synonyms = {"ranking", "best script", "scores", "winners"},
    Entries = {
        {Name = "RouteBot", Score = 880, Color = "Accent2"},
        {Name = "SafeRunner", Score = 640, Color = "Success"},
        {Name = "Your script", Score = 0, Highlighted = true, Color = "Accent"},
    },
})
check("Leaderboard sorts entries", RoundLeaderboard.Type == "Leaderboard" and RoundLeaderboard:GetEntries()[1].Name == "RouteBot")

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
        local queueStatus = index < nextStep and "Done" or (index == nextStep and (AutomationState.Paused and "Paused" or "Running") or "Pending")
        local queueProgress = index < nextStep and 1 or (index == nextStep and math.clamp((AutomationState.Progress * #stepIds) - (index - 1), 0, 1) or 0)
        ExecutionQueue:SetStatus(id, queueStatus, queueProgress)
    end
end

local function syncAutomation()
    local stateName = AutomationState.Paused and "Paused" or (AutomationState.Running and "Active" or "Waiting")
    local detail = AutomationState.Paused and "Automation paused by user" or stepNames[AutomationState.Step]
    RoundProgress:SetStatus(stateName, detail)
    RoundProgress:SetProgress(AutomationState.Progress, detail)
    RoundProgress:SetStep(AutomationState.Step, #stepIds)
    RoundProgress:SetMetrics({Round = AutomationState.Round, Score = AutomationState.Score})
    RoundBanner:SetTitle("Round " .. tostring(AutomationState.Round) .. " · " .. stateName)
    RoundBanner:SetStatus(stateName)
    RoundBanner:SetContent(detail .. string.format("  ·  Step %d/%d", AutomationState.Step, #stepIds))
    RoundStats:SetValue("round", AutomationState.Round, "current")
    RoundStats:SetValue("score", AutomationState.Score, "+" .. tostring(math.max(0, AutomationState.Step * 2 + 8)))
    RoundStats:SetValue("efficiency", tostring(96 + (AutomationState.Round % 5)) .. "%", AutomationState.Paused and "paused" or "stable")
    RoundStats:SetValue("errors", 0, "clean")
    RoundLeaderboard:Update("Your script", {Score = AutomationState.Score, Highlighted = true, Color = "Accent"})
    AutomationTab:SetStatus(stateName, detail)
    AutomationTab:SetBadge(AutomationState.Round, AutomationState.Paused and "Warn" or "Success")
    InlineActions:SetStatus("start", AutomationState.Running and not AutomationState.Paused and "Active" or "Waiting")
    InlineActions:SetStatus("pause", AutomationState.Paused and "Waiting" or "Idle")
    InlineActions:SetStatus("reset", "Idle")
    Boss:SetStatus(AutomationState.Step == 3 and "Active" or "Waiting", AutomationState.Step == 3 and "Automation is engaging the boss" or "Waiting for execution step")
end

pauseAutomation = function()
    if not AutomationState.Running then return false end
    AutomationState.Paused = not AutomationState.Paused
    Activity:Push(AutomationState.Paused and "Automation paused" or "Automation resumed", AutomationState.Paused and "Warning" or "Success")
    applyStep(AutomationState.Step)
    syncAutomation()
    return true
end

startAutomation = function()
    if AutomationState.Running then
        AutomationState.Paused = false
        applyStep(AutomationState.Step)
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
check("Automation simulator is running", AutomationState.Running and RoundBanner.Status == "active")

check("Phone compact API", Window:SetPhoneCompact(false) == Window and Window:SetPhoneCompact(true) == Window)
check("Command palette opens", Window:OpenCommandPalette("xp") == true)
Window:CloseCommandPalette()
local diagnosticsPassed, diagnostics = Window:GetLayoutDiagnostics()
check("Layout diagnostics callable", type(diagnosticsPassed) == "boolean" and type(diagnostics) == "table")

Test.Window = Window
Test.Catalog = Catalog
Test.Boss = Boss
Test.ESP = ESP
Test.InlineActions = InlineActions
Test.StatusBanner = RoundBanner
Test.Stats = RoundStats
Test.ExecutionQueue = ExecutionQueue
Test.Leaderboard = RoundLeaderboard
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
    RenLib:Unload("V9.1 test cleanup")
end
runtime.__RENLIB_V81_TEST = Test
runtime.__RENLIB_V82_TEST = Test
runtime.__RENLIB_V90_TEST = Test
runtime.__RENLIB_V91_TEST = Test

local summary = string.format("%d passed, %d failed", Test.Passed, Test.Failed)
RenLib:Notify({
    Title = Test.Failed == 0 and "RenLib V9.1 tests passed" or "RenLib V9.1 test failures",
    Content = summary .. ". Automation and the world-object ESP demo are live.",
    Duration = 8,
})
print("[RenLib V9.1 Test] " .. summary)
print("[RenLib V9.1 Test] Manual QA: inline controls, status banner, stats, queue, leaderboard, object/player ESP, optional skeleton, Ctrl+K/Ctrl+Tab, and phone rotation.")

return Test
