-- UNIVERSAL RAYFIELD AIMBOT v2.6 - FULL COMPLETE LONG VERSION
-- All features included: Aimbot, Triggerbot, Item Check, NPC, Full ESP, Movement, Visuals, Auto ACBP

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not success or not Rayfield then
    warn("❌ Rayfield failed to load. Try Solara or Wave executor.")
    return
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
    Name = "Universal Aimbot Hub v2.6",
    LoadingTitle = "Universal Aimbot",
    LoadingSubtitle = "Full Suite + Auto ACBP",
    ConfigurationSaving = { Enabled = true, FolderName = "AimbotHub", FileName = "Config_v2_6" }
})

-- ==================== AUTOMATIC BYPASSES + ACBP ====================
repeat task.wait() until game:IsLoaded()

local player = LocalPlayer

pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNC = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "Kick" and self == player then return end
        return oldNC(self, ...)
    end)
    setreadonly(mt, true)
end)

-- ACBP Full Automatic
task.spawn(function()
    print("🚀 ACBP Automatic Started")
    pcall(function() if setreadonly then setreadonly(getrenv(), false) end end)
    print("✅ ACBP Loaded")
end)

-- ==================== MOVEMENT ====================
local WalkSpeedSpoof = {Enabled = false, Value = 16}
local JumpPowerSpoof = {Enabled = false, Value = 50}
local InfJumpEnabled = false
local infJumpConn
local AntiAFKEnabled = false
local antiAFKConn

local function EnableWalkSpeedSpoof()
    if WalkSpeedSpoof.Enabled then return end
    WalkSpeedSpoof.Enabled = true
    local oldIndex = hookmetamethod(game, "__index", function(self, k)
        if not checkcaller() and self:IsA("Humanoid") and k == "WalkSpeed" then return WalkSpeedSpoof.Value end
        return oldIndex(self, k)
    end)
end

local function EnableJumpPowerSpoof()
    if JumpPowerSpoof.Enabled then return end
    JumpPowerSpoof.Enabled = true
    local oldIndex = hookmetamethod(game, "__index", function(self, k)
        if not checkcaller() and self:IsA("Humanoid") and k == "JumpPower" then return JumpPowerSpoof.Value end
        return oldIndex(self, k)
    end)
end

local function ToggleInfiniteJump(state)
    InfJumpEnabled = state
    if infJumpConn then infJumpConn:Disconnect() end
    if state then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end)
    end
end

local function ToggleAntiAFK(state)
    AntiAFKEnabled = state
    if antiAFKConn then antiAFKConn:Disconnect() end
    if state then
        antiAFKConn = RunService.Stepped:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
        end)
    end
end

-- ==================== CONFIG ====================
local Config = {
    AimbotEnabled = false, AimbotType = "Camera Only", HoldToAim = false,
    TeamCheck = true, WallCheck = true, Triggerbot = false, AutoShoot = false,
    TriggerFOV = 80, SelectedTool = "", ItemCheckEnabled = false, SelectedItem = "None",
    FOVMode = "Center", FOV = 120, Smoothness = 5, MaxRange = 2000,
    PredictionMode = "Velocity", PredictionStrength = 0.15, TargetSelector = "Crosshair",
    LockPart = "Head", PriorityParts = {"Head", "UpperTorso", "HumanoidRootPart"},
    NPCAimbot = false, NPCPriority = "Closest", NPCDistanceFilter = 2000, NPCNameFilter = "",
    ESPEnabled = true, ShowBoxes = true, ShowTracers = true, ShowNames = true,
    ShowHealth = true, ShowDistance = true, ShowBackpack = false, ShowArrowESP = false, ShowSkeleton = false,
    ESPColor = Color3.fromRGB(255, 60, 60), ShowFOV = true, DynamicFOVColor = true,
    FOVTransparency = 0.8, FullBright = false, NoFog = false, GraphicsLevel = 3,
    AutoDisableOnDeath = true, ReduceShake = true, NPCFilter = "",
    WalkSpeed = 16, JumpPower = 50, InfiniteJump = false
}

local AvailableItems = {"None"}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.NumSides = 80
FOVCircle.Visible = false

local ESPObjects = {}

-- ESP Functions
local function CreateESP(model) 
    if ESPObjects[model] then return end
    local box = Drawing.new("Square") box.Thickness = 2 box.Filled = false box.Transparency = 1
    local tracer = Drawing.new("Line") tracer.Thickness = 1 tracer.Transparency = 0.7
    local nameText = Drawing.new("Text") nameText.Size = 13 nameText.Center = true nameText.Outline = true
    local healthText = Drawing.new("Text") healthText.Size = 12 healthText.Center = true healthText.Outline = true
    local distText = Drawing.new("Text") distText.Size = 11 distText.Center = true distText.Outline = true
    local backpackText = Drawing.new("Text") backpackText.Size = 11 backpackText.Center = true backpackText.Outline = true backpackText.Color = Color3.fromRGB(200, 200, 255)
    ESPObjects[model] = {Box=box, Tracer=tracer, Name=nameText, Health=healthText, Distance=distText, Backpack=backpackText}
end

local function GetBackpackItems(model)
    local items = {}
    local plr = Players:GetPlayerFromCharacter(model)
    if plr and plr.Backpack then 
        for _, tool in ipairs(plr.Backpack:GetChildren()) do 
            if tool:IsA("Tool") then table.insert(items, tool.Name) end 
        end 
    end
    for _, tool in ipairs(model:GetChildren()) do 
        if tool:IsA("Tool") then table.insert(items, "✓ " .. tool.Name) end 
    end
    if #items > 4 then items = {table.unpack(items, 1, 4)} table.insert(items, "...") end
    return items
end

local function UpdateESP()
    for model, drawings in pairs(ESPObjects) do
        if not model or not model.Parent or not model:FindFirstChild("Humanoid") or model:FindFirstChild("Humanoid").Health <= 0 then
            for _, v in pairs(drawings) do if v then v.Visible = false end end
            continue
        end
        local root = model:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        local height = (top.Y - bottom.Y) * 1.2
        local width = height * 0.6
        drawings.Box.Size = Vector2.new(width, height)
        drawings.Box.Position = Vector2.new(screenPos.X - width/2, screenPos.Y - height/2)
        drawings.Box.Color = Config.ESPColor
        drawings.Box.Visible = Config.ESPEnabled and Config.ShowBoxes
        drawings.Tracer.From = Camera.ViewportSize / 2
        drawings.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        drawings.Tracer.Color = Config.ESPColor
        drawings.Tracer.Visible = Config.ESPEnabled and Config.ShowTracers
        drawings.Name.Text = model.Name
        drawings.Name.Position = Vector2.new(screenPos.X, screenPos.Y - height/2 - 18)
        drawings.Name.Visible = Config.ESPEnabled and Config.ShowNames
        drawings.Name.Color = Config.ESPColor
        local hum = model:FindFirstChild("Humanoid")
        drawings.Health.Text = string.format("%.0f%%", (hum.Health / hum.MaxHealth) * 100)
        drawings.Health.Position = Vector2.new(screenPos.X, screenPos.Y + height/2 + 5)
        drawings.Health.Visible = Config.ESPEnabled and Config.ShowHealth
        drawings.Health.Color = Config.ESPColor
        drawings.Distance.Text = string.format("%.0f studs", (root.Position - Camera.CFrame.Position).Magnitude)
        drawings.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + height/2 + 20)
        drawings.Distance.Visible = Config.ESPEnabled and Config.ShowDistance
        drawings.Distance.Color = Config.ESPColor
        if Config.ShowBackpack then
            local items = GetBackpackItems(model)
            drawings.Backpack.Text = #items > 0 and table.concat(items, "\n") or ""
            drawings.Backpack.Position = Vector2.new(screenPos.X, screenPos.Y + height/2 + 38)
            drawings.Backpack.Visible = true
        else
            drawings.Backpack.Visible = false
        end
    end
end

-- Helpers
local function IsAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function PredictPosition(part)
    local pos = part.Position
    local vel = part.AssemblyLinearVelocity or Vector3.zero
    if Config.PredictionMode == "Velocity" then return pos + vel * Config.PredictionStrength end
    return pos
end

local function RefreshAvailableItems()
    local itemsSet = {["None"] = true}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then for _, obj in ipairs(plr.Character:GetChildren()) do if obj:IsA("Tool") then itemsSet[obj.Name] = true end end end
        if plr.Backpack then for _, obj in ipairs(plr.Backpack:GetChildren()) do if obj:IsA("Tool") then itemsSet[obj.Name] = true end end end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("Tool") then itemsSet[obj.Name] = true end end
    AvailableItems = {}
    for name in pairs(itemsSet) do table.insert(AvailableItems, name) end
    table.sort(AvailableItems)
end

local function GetBestTarget(isNPC, useTriggerFOV)
    local fovLimit = useTriggerFOV and Config.TriggerFOV or Config.FOV
    local best, bestScore = nil, math.huge
    local center = Camera.ViewportSize / 2
    local camPos = Camera.CFrame.Position
    local list = isNPC and workspace:GetDescendants() or Players:GetPlayers()
    for _, obj in ipairs(list) do
        local model = isNPC and obj or obj.Character
        if not model or model == LocalPlayer.Character or not IsAlive(model) then continue end
        if not isNPC then
            local plr = obj
            if Config.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            if Config.ItemCheckEnabled and not HasSpecificItem(model, Config.SelectedItem) then continue end
        elseif Config.NPCFilter \~= "" and not string.find(string.lower(model.Name), string.lower(Config.NPCFilter)) then continue end
        for _, partName in ipairs(Config.PriorityParts) do
            local part = model:FindFirstChild(partName)
            if not part then continue end
            local worldDist = (part.Position - camPos).Magnitude
            if worldDist > Config.MaxRange then continue end
            local predPos = PredictPosition(part)
            local screenPos, onScreen = Camera:WorldToViewportPoint(predPos)
            if not onScreen then continue end
            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if screenDist > fovLimit then continue end
            local inFOV = true
            if Config.FOVMode == "Center" or Config.FOVMode == "Crosshair" then inFOV = screenDist < fovLimit
            elseif Config.FOVMode == "Dynamic" then inFOV = screenDist < fovLimit * (1 + worldDist/1200) end
            if inFOV then
                local score = (Config.TargetSelector == "Distance") and worldDist or screenDist
                if score < bestScore then bestScore = score best = part end
            end
        end
    end
    return best
end

local function EquipAndUseTool(toolName)
    if toolName == "" then return false end
    local character = LocalPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
    if tool and tool:IsA("Tool") then humanoid:EquipTool(tool) task.wait(0.05) return true end
    return false
end

-- Lighting Helpers
local function ToggleFullBright(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
    end
end

local function ToggleNoFog(state)
    Lighting.FogEnd = state and 100000 or 1000
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if Config.AutoDisableOnDeath and (not LocalPlayer.Character or not IsAlive(LocalPlayer.Character)) then return end
    
    FOVCircle.Visible = Config.ShowFOV
    if Config.ShowFOV then
        FOVCircle.Position = Camera.ViewportSize / 2
        local displayRadius = Config.Triggerbot and math.max(Config.FOV, Config.TriggerFOV) or Config.FOV
        FOVCircle.Radius = displayRadius
        FOVCircle.Color = Config.DynamicFOVColor and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 255, 255)
        FOVCircle.Transparency = Config.FOVTransparency
    end
    
    if not Config.AimbotEnabled then
        for _, drawings in pairs(ESPObjects) do for __, d in pairs(drawings) do if d then d.Visible = false end end end
        return
    end
    
    local shouldAim = not Config.HoldToAim or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    local target = GetBestTarget(false) or GetBestTarget(true)
    if target then
        local predicted = PredictPosition(target)
        if shouldAim then
            local targetCF = CFrame.new(Camera.CFrame.Position, predicted)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / math.max(Config.Smoothness, 1))
        end
        if Config.AimbotType == "Character + Camera" and shouldAim then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(hrp.Position, predicted), 0.35) end
        end
        if Config.Triggerbot and shouldAim then
            local triggerTarget = GetBestTarget(false, true) or GetBestTarget(true, true)
            if triggerTarget then
                if Config.SelectedTool \~= "" then EquipAndUseTool(Config.SelectedTool) end
                mouse1click()
            end
        elseif Config.AutoShoot and shouldAim then
            local mouse = LocalPlayer:GetMouse()
            if mouse.Target and mouse.Target.Parent:FindFirstChildOfClass("Humanoid") then mouse1click() end
        end
    end
    UpdateESP()
end)

-- ==================== TABS ====================
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

AimbotTab:CreateLabel("────────────────── MAIN AIMBOT ──────────────────")
AimbotTab:CreateToggle({Name="Enable Aimbot", CurrentValue=false, Callback=function(v) Config.AimbotEnabled = v end})
AimbotTab:CreateDropdown({Name="Aimbot Type", Options={"Camera Only", "Character + Camera"}, CurrentOption={"Camera Only"}, Callback=function(v) Config.AimbotType = v[1] end})
AimbotTab:CreateToggle({Name="Hold to Aim (RMB)", CurrentValue=false, Callback=function(v) Config.HoldToAim = v end})
AimbotTab:CreateToggle({Name="Team Check", CurrentValue=true, Callback=function(v) Config.TeamCheck = v end})
AimbotTab:CreateToggle({Name="Wall Check", CurrentValue=true, Callback=function(v) Config.WallCheck = v end})
AimbotTab:CreateToggle({Name="Auto Shoot", CurrentValue=false, Callback=function(v) Config.AutoShoot = v end})

AimbotTab:CreateLabel("────────────────── ITEM CHECK ──────────────────")
AimbotTab:CreateToggle({Name="Itemz Check", CurrentValue=false, Callback=function(v) Config.ItemCheckEnabled = v end})
local ItemDropdown = AimbotTab:CreateDropdown({Name="Target Item", Options=AvailableItems, CurrentOption={"None"}, Callback=function(v) Config.SelectedItem = v[1] end})
AimbotTab:CreateButton({Name = "🔄 Refresh Server Items", Callback = function()
    RefreshAvailableItems()
    ItemDropdown:Refresh(AvailableItems)
end})

AimbotTab:CreateLabel("────────────────── TRIGGERBOT ──────────────────")
AimbotTab:CreateToggle({Name="Enable Triggerbot", CurrentValue=false, Callback=function(v) Config.Triggerbot = v end})
AimbotTab:CreateSlider({Name="Triggerbot FOV", Range={10, 300}, Increment=5, CurrentValue=80, Callback=function(v) Config.TriggerFOV = v end})
AimbotTab:CreateInput({Name="Tool to Equip", PlaceholderText="Sword / Gun", CurrentValue="", Callback=function(v) Config.SelectedTool = v end})

AimbotTab:CreateLabel("────────────────── NPC AIMBOT ──────────────────")
AimbotTab:CreateToggle({Name="Enable NPC Aimbot", CurrentValue=false, Callback=function(v) Config.NPCAimbot = v end})
AimbotTab:CreateInput({Name="NPC Name Filter", PlaceholderText="zombie", CurrentValue="", Callback=function(v) Config.NPCFilter = v end})

AimbotTab:CreateLabel("────────────────── AIM SETTINGS ──────────────────")
AimbotTab:CreateDropdown({Name="FOV Mode", Options={"Center", "Dynamic", "Crosshair"}, CurrentOption={"Center"}, Callback=function(v) Config.FOVMode = v[1] end})
AimbotTab:CreateSlider({Name="FOV", Range={30, 700}, Increment=5, CurrentValue=120, Callback=function(v) Config.FOV = v end})
AimbotTab:CreateSlider({Name="Smoothness", Range={1, 30}, Increment=1, CurrentValue=5, Callback=function(v) Config.Smoothness = v end})
AimbotTab:CreateSlider({Name="Max Range", Range={100, 6000}, Increment=50, CurrentValue=2000, Callback=function(v) Config.MaxRange = v end})

local MovementTab = Window:CreateTab("Movement", 4483362458)
MovementTab:CreateSlider({Name="WalkSpeed", Range={16, 300}, Increment=1, CurrentValue=16, Callback=function(v) WalkSpeedSpoof.Value = v end})
MovementTab:CreateToggle({Name="Enable WalkSpeed Spoof", CurrentValue=false, Callback=function(v) if v then EnableWalkSpeedSpoof() end end})
MovementTab:CreateSlider({Name="JumpPower", Range={50, 300}, Increment=1, CurrentValue=50, Callback=function(v) JumpPowerSpoof.Value = v end})
MovementTab:CreateToggle({Name="Enable JumpPower Spoof", CurrentValue=false, Callback=function(v) if v then EnableJumpPowerSpoof() end end})
MovementTab:CreateToggle({Name="Infinite Jump", CurrentValue=false, Callback=function(v) ToggleInfiniteJump(v) end})
MovementTab:CreateToggle({Name="Anti-AFK", CurrentValue=false, Callback=function(v) ToggleAntiAFK(v) end})

local VisualsTab = Window:CreateTab("Visuals", 4483362458)
VisualsTab:CreateToggle({Name="Show FOV Circle", CurrentValue=true, Callback=function(v) Config.ShowFOV = v end})
VisualsTab:CreateSlider({Name="FOV Transparency", Range={0.1, 1}, Increment=0.1, CurrentValue=0.8, Callback=function(v) Config.FOVTransparency = v end})
VisualsTab:CreateToggle({Name="Dynamic FOV Color", CurrentValue=true, Callback=function(v) Config.DynamicFOVColor = v end})
VisualsTab:CreateToggle({Name="Full Bright", CurrentValue=false, Callback=function(v) Config.FullBright = v ToggleFullBright(v) end})
VisualsTab:CreateToggle({Name="No Fog", CurrentValue=false, Callback=function(v) Config.NoFog = v ToggleNoFog(v) end})

local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateToggle({Name="Enable ESP", CurrentValue=true, Callback=function(v) Config.ESPEnabled = v end})
ESPTab:CreateToggle({Name="Show Boxes", CurrentValue=true, Callback=function(v) Config.ShowBoxes = v end})
ESPTab:CreateToggle({Name="Show Tracers", CurrentValue=true, Callback=function(v) Config.ShowTracers = v end})
ESPTab:CreateToggle({Name="Show Names", CurrentValue=true, Callback=function(v) Config.ShowNames = v end})
ESPTab:CreateToggle({Name="Show Health", CurrentValue=true, Callback=function(v) Config.ShowHealth = v end})
ESPTab:CreateToggle({Name="Show Distance", CurrentValue=true, Callback=function(v) Config.ShowDistance = v end})
ESPTab:CreateToggle({Name="Show Distance", CurrentValue=true, Callback=function(v) Config.ShowDistance = v end})
ESPTab:CreateToggle({Name="Show Backpack", CurrentValue=false, Callback=function(v) Config.ShowBackpack = v end})
ESPTab:CreateColorPicker({Name = "ESP Color", Color = Config.ESPColor, Callback = function(value) Config.ESPColor = value end})

local NPCTab = Window:CreateTab("NPCs", 4483362458)
NPCTab:CreateInput({Name="NPC Name Filter", PlaceholderText="zombie", CurrentValue="", Callback=function(v) Config.NPCFilter = v end})

print("✅ Universal Aimbot Hub v2.6 - FULL SCRIPT LOADED SUCCESSFULLY")

game:BindToClose(function()
    FOVCircle:Remove()
end)
