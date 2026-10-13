-- Ximena Hub  | WindUI
repeat task.wait() until game:IsLoaded()

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not ok or not WindUI then
    warn("WindUI failed:", WindUI)
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local UserInputService = UIS
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RS = ReplicatedStorage
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local CommE = ReplicatedStorage:WaitForChild("Remotes"):FindFirstChild("CommE")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")

local registerAttack = Net:FindFirstChild("RE/RegisterAttack")
local registerHit
pcall(function()
    registerHit = require(ReplicatedStorage.Modules.Net):RemoteEvent("RegisterHit", true)
end)
if not registerHit then
    registerHit = Net:FindFirstChild("RE/RegisterHit")
end
local ShootGunEvent = Net:FindFirstChild("RE/ShootGunEvent")

local Config = {
    FastAttack = false, FastAttackDelay = 0, FAPlayers = true, FAMobs = true, FARange = 60,
    GunAura = false, GunRange = 500, GunPlayers = true, GunMobs = true,
    BringMobs = false, BringRange = 300,
    FruitAura = false, SpecialFruitAura = false, FruitInterval = 0.05,
    OneShotKitsune = false, KitsuneInterval = 0.05,
    AutoV3 = false, AutoV4 = false, AutoPvP = false,
    InfiniteZoom = false, AntiAFK = true,
    DeleteShip = false,
    Fly = false, FlySpeed = 250, FlyVertical = 180, FlySmooth = true,
    FontEnabled = false, FontPreset = "Gotham",
    WalkOnWater = false,
    AntiLava = false,
    SpeedEnabled = false, SpeedMode = "CFrame", SpeedValue = 50,
    Tracker = false,
    TrackerFly = false,
    TrackerFlySpeed = 275,
    TrackerOrbitRadius = 50,
    TrackerNoTpRange = 300,
    TrackerPositionMode = "orbit",
    M1Extender = false, M1Range = 50,
    GunClickSL = false,
    -- Silent Aim completo (estilo Nameless)
    SilentPlayer = false, SilentNPC = false,
    AimMode = "360", AimPriority = "Nearest",
    ShowFOV = false, FOVMode = "V1", FOVRadius = 100, AimMaxRange = 1000,
    Tracer = false, TracerColor = "Red",
    SoruAutoAim = false, SoruMode = "360", SoruFOVType = "V1",
    SoruPriority = "Nearest", SoruFOVRadius = 100, SoruRange = 300, SoruShowFOV = false,
    -- Z Boost (estilo Kavo)
    ZBoostEnabled = true,
    ZBoostPower = 450,
    ZBoostDuration = 0.55,
}

local CONFIG_FILE = "Ximenahub_Config.json"

local function SaveConfig()
    pcall(function()
        if not writefile then return end
        local data = {}
        for k, v in pairs(Config) do
            local t = type(v)
            if t == "boolean" or t == "number" or t == "string" then
                data[k] = v
            end
        end
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end)
end

local function LoadConfig()
    pcall(function()
        if not (isfile and readfile) then return end
        if not isfile(CONFIG_FILE) then return end
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(data) ~= "table" then return end
        for k, v in pairs(data) do
            if Config[k] ~= nil then Config[k] = v end
        end
    end)
end

LoadConfig()

task.spawn(function()
    while true do
        task.wait(8)
        SaveConfig()
    end
end)

pcall(function()
    game:BindToClose(function() SaveConfig() end)
end)

local function save()
    SaveConfig()
end

local FONT_LIST_RAW = {
    "Legacy","Arial","ArialBold","SourceSans","SourceSansBold","SourceSansSemibold","SourceSansLight","SourceSansItalic",
    "Bodoni","Garamond","Cartoon","Code","Highway","SciFi","Arcade","Fantasy","Antique",
    "Gotham","GothamMedium","GothamBold","GothamBlack",
    "AmaticSC","Bangers","Creepster","DenkOne","Fondamento","FredokaOne",
    "GrenzeGotisch","IndieFlower","JosefinSans","Jura","Kalam","LuckiestGuy",
    "Merriweather","Michroma","Nunito","Oswald","PatrickHand","PermanentMarker",
    "Roboto","RobotoCondensed","RobotoMono","Sarpanch","SpecialElite","TitilliumWeb","Ubuntu",
}
local FONT_LIST = {}
for _, name in ipairs(FONT_LIST_RAW) do
    if Enum.Font[name] then table.insert(FONT_LIST, name) end
end
if #FONT_LIST == 0 then FONT_LIST = {"Gotham", "SourceSans", "Arial"} end

local character = lp.Character or lp.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
lp.CharacterAdded:Connect(function(c)
    character = c
    humanoidRootPart = c:WaitForChild("HumanoidRootPart")
end)
local savedZoom = lp.CameraMaxZoomDistance

local function isAlive(model)
    if not model or not model.Parent then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    return hum and hum.Health > 0 and root ~= nil
end

local function collectTargets(range, doPlayers, doMobs)
    local hrp = humanoidRootPart
    if not hrp then return {} end
    local list, myPos = {}, hrp.Position
    if doMobs then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, child in ipairs(enemies:GetChildren()) do
                if isAlive(child) and not child:GetAttribute("IsBoat") then
                    local root = child.PrimaryPart or child:FindFirstChild("HumanoidRootPart")
                    if root and not Players:GetPlayerFromCharacter(child) then
                        local d = (myPos - root.Position).Magnitude
                        if d <= range then table.insert(list, { child, root, d }) end
                    end
                end
            end
        end
    end
    if doPlayers and not lp:GetAttribute("PvpDisabled") then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    local d = (myPos - root.Position).Magnitude
                    if d <= range then table.insert(list, { plr.Character, root, d }) end
                end
            end
        end
    end
    table.sort(list, function(a, b) return a[3] < b[3] end)
    return list
end

local function getFruit()
    local char, bp = lp.Character, lp:FindFirstChild("Backpack")
    for _, container in ipairs({ char, bp }) do
        if container then
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and (t:GetAttribute("WeaponType") == "Demon Fruit" or t.Name:find("-")) then
                    return t
                end
            end
        end
    end
end

-- ==================== Z BOOST (estilo Kavo) ====================
local boostGui = nil

local function destroyBoostGui()
    if boostGui then
        boostGui:Destroy()
        boostGui = nil
    end
end

local function doBoost()
    if not Config.ZBoostEnabled then return end
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dir = Camera.CFrame.LookVector
    local att = Instance.new("Attachment")
    att.Parent = hrp

    local lv = Instance.new("LinearVelocity")
    lv.MaxForce = 99999999
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity = dir * Config.ZBoostPower
    lv.Attachment0 = att
    lv.Parent = hrp

    task.delay(Config.ZBoostDuration, function()
        if lv and lv.Parent then lv:Destroy() end
        if att and att.Parent then att:Destroy() end
    end)
end

local function createBoostGui()
    destroyBoostGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MichelleZBoost"
    gui.ResetOnSpawn = false
    gui.Parent = lp:WaitForChild("PlayerGui")
    boostGui = gui

    local f = Instance.new("Frame", gui)
    f.Size = UDim2.new(0, 90, 0, 42)
    f.Position = UDim2.new(0.37, 0, 0.26, 0)
    f.BackgroundColor3 = Color3.fromRGB(75, 30, 135)
    f.Active = true
    f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)

    local zBtn = Instance.new("TextButton", f)
    zBtn.Size = UDim2.new(0, 40, 0, 30)
    zBtn.Position = UDim2.new(0, 12, 0, 6)
    zBtn.BackgroundColor3 = Color3.fromRGB(210, 140, 255)
    zBtn.Text = "Z"
    zBtn.TextSize = 18
    zBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", zBtn).CornerRadius = UDim.new(0, 8)

    zBtn.MouseButton1Click:Connect(function()
        doBoost()
        zBtn.Text = "!"
        zBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
        task.wait(0.35)
        zBtn.Text = "Z"
        zBtn.BackgroundColor3 = Color3.fromRGB(210, 140, 255)
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z and Config.ZBoostEnabled then
        doBoost()
    end
end)

-- ==================== TRACKER ORBIT ====================
local TrackerState = {
    Conn = nil, LeaveConn = nil,
    Attachment = nil, LinearVel = nil, AntiGrav = nil,
    OrbitOffset = nil, NextOrbitTime = 0,
    CurrentTarget = nil, TargetLockTime = 0, TimeoutLimit = 120,
    History = {}, HistoryWindow = 0.35,
    Blacklist = {}, ValidCache = {}, ValidCacheTime = 0,
    TeleportPauseUntil = 0, LastTeleportTicks = {}, TeleportFails = {}, BlockedEntrances = {},
    CachedChar = nil, CachedParts = nil, LastNoclipScan = 0,
    SelectedTarget = nil,
}

local SafeZones = {
    World1 = {
        { pos = Vector3.new(-3000, 250, 2057), radius = 700 },
        { pos = Vector3.new(1101, 16, 1446), radius = 400 },
    },
    World2 = {
        { pos = Vector3.new(-12, 29, 2840), radius = 200 },
        { pos = Vector3.new(-376, 149, 307), radius = 150 },
        { pos = Vector3.new(-6437, 306, -4730), radius = 150 },
    },
    World3 = {
        { pos = Vector3.new(-338, 21, 5539), radius = 200 },
        { pos = Vector3.new(-12550, 337, -7506), radius = 400 },
        { pos = Vector3.new(-5046, 315, -2993), radius = 300 },
        { pos = Vector3.new(-16228, 9, 443), radius = 300 },
    },
}

local function GetEntrances()
    local pid = game.PlaceId
    if table.find({2753915549, 85211729168715}, pid) then
        return {
            { Arg = Vector3.new(61163.85, 11.68, 1819.78), Dest = Vector3.new(61164, 5, 1820) },
            { Arg = Vector3.new(3864.68, 6.73, -1926.21), Dest = Vector3.new(3865, 5, -1926) },
            { Arg = Vector3.new(-4607.82, 874.39, -1667.55), Dest = Vector3.new(-4608, 873, -1668) },
            { Arg = Vector3.new(-7894.61, 5547.14, -380.29), Dest = Vector3.new(-7895, 5546, -380) },
        }
    elseif table.find({4442272183, 79091703265657}, pid) then
        return {
            { Arg = Vector3.new(2285, 15, 882), Dest = Vector3.new(2285, 15, 882) },
            { Arg = Vector3.new(-380, 350, 630), Dest = Vector3.new(-380, 350, 630) },
            { Arg = Vector3.new(924, 125, 32882), Dest = Vector3.new(924, 125, 32882) },
            { Arg = Vector3.new(-6491, 116, -107), Dest = Vector3.new(-6491, 116, -107) },
        }
    elseif table.find({7449423635, 100117331123089}, pid) then
        return {
            { Arg = Vector3.new(5678, 1013, -312), Dest = Vector3.new(5678, 1013, -312) },
            { Arg = Vector3.new(-12551, 337, -7507), Dest = Vector3.new(-12551, 337, -7507) },
            { Arg = Vector3.new(-5038, 315, -3135), Dest = Vector3.new(-5038, 315, -3135) },
            { Arg = Vector3.new(-5098, 317, -3179), Dest = Vector3.new(-16813, 58, 305) },
        }
    end
    return {}
end

local function IsInSafeZone(plr)
    if not plr or not plr.Character then return false end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local pid = game.PlaceId
    local zones = {}
    if table.find({2753915549, 85211729168715}, pid) then zones = SafeZones.World1
    elseif table.find({4442272183, 79091703265657}, pid) then zones = SafeZones.World2
    elseif table.find({7449423635, 100117331123089}, pid) then zones = SafeZones.World3
    end
    local pos = hrp.Position
    for _, z in ipairs(zones) do
        if (pos - z.pos).Magnitude <= z.radius then return true end
    end
    return false
end

local function IsAlly(plr)
    local main = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main")
    if not main then return false end
    local allies = main:FindFirstChild("Allies")
    local container = allies and allies:FindFirstChild("Container")
    local sub = container and container:FindFirstChild("Allies")
    if not sub then return false end
    local frame = sub:FindFirstChild("Frame")
        or (sub:FindFirstChild("ScrollingFrame") and sub.ScrollingFrame:FindFirstChild("Frame"))
    if not frame then return false end
    return frame:FindFirstChild(plr.Name) ~= nil
end

local function GetLevel(plr)
    if not plr then return nil end
    local obj = (plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Level"))
        or (plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Level"))
    return obj and obj.Value or nil
end

local function IsValidTarget(plr)
    if not plr or plr == lp then return false end
    if TrackerState.Blacklist[plr] then return false end
    local char = plr.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    if char:FindFirstChildOfClass("ForceField") then TrackerState.Blacklist[plr] = true return false end
    if plr:GetAttribute("SafeZone") or plr:GetAttribute("InSafeZone") or plr:GetAttribute("PvpDisabled") then
        TrackerState.Blacklist[plr] = true
        return false
    end
    if IsInSafeZone(plr) then TrackerState.Blacklist[plr] = true return false end
    local myTeam, tgTeam = lp.Team, plr.Team
    if myTeam and tgTeam and myTeam.Name == "Marines" and tgTeam.Name == "Marines" then
        TrackerState.Blacklist[plr] = true
        return false
    end
    if IsAlly(plr) then TrackerState.Blacklist[plr] = true return false end
    local myLv, tgLv = GetLevel(lp), GetLevel(plr)
    if myLv and tgLv and math.abs(myLv - tgLv) > 550 then
        TrackerState.Blacklist[plr] = true
        return false
    end
    local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and (myHRP.Position - hrp.Position).Magnitude > 30000 then return false end
    return true
end

local function IsValidFast(plr)
    local now = os.clock()
    if now - TrackerState.ValidCacheTime > 0.15 then
        TrackerState.ValidCacheTime = now
        table.clear(TrackerState.ValidCache)
    end
    if TrackerState.ValidCache[plr] ~= nil then return TrackerState.ValidCache[plr] end
    local v = IsValidTarget(plr)
    TrackerState.ValidCache[plr] = v
    return v
end

local function GetNearest()
    local nearest, shortest = nil, math.huge
    local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if IsValidFast(plr) then
            local tgHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if tgHRP then
                local d = (tgHRP.Position - myHRP.Position).Magnitude
                if d < shortest then shortest = d; nearest = plr end
            end
        end
    end
    return nearest
end

local function UpdateHistory()
    local now = os.clock()
    local active = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            active[plr] = true
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if not TrackerState.History[plr] then TrackerState.History[plr] = {} end
                local hist = TrackerState.History[plr]
                table.insert(hist, { time = now, pos = hrp.Position, vel = hrp.AssemblyLinearVelocity })
                while #hist > 0 and (now - hist[1].time) > TrackerState.HistoryWindow do
                    table.remove(hist, 1)
                end
            end
        end
    end
    for plr in pairs(TrackerState.History) do
        if not active[plr] then TrackerState.History[plr] = nil end
    end
end

local function GetPredictedPos(plr)
    if not plr or not plr.Character then return nil end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local currentPos = hrp.Position
    local currentVel = hrp.AssemblyLinearVelocity
    local ping = 0.04
    pcall(function()
        ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    local history = TrackerState.History[plr]
    if not history or #history < 3 then
        local t = math.clamp(ping, 0.03, 0.25)
        local pos = currentPos + (currentVel * t)
        return pos.Y < currentPos.Y and Vector3.new(pos.X, currentPos.Y, pos.Z) or pos
    end
    local count = #history
    local now = os.clock()
    local totalWeight, weightedVel = 0, Vector3.new(0, 0, 0)
    for i = 2, count do
        local prev, curr = history[i - 1], history[i]
        local dt = curr.time - prev.time
        if dt > 0.001 then
            local instVel = (curr.pos - prev.pos) / dt
            local weight = math.exp((curr.time - now) / 0.1)
            weightedVel = weightedVel + (instVel * weight)
            totalWeight = totalWeight + weight
        end
    end
    local histVel = (totalWeight > 0) and (weightedVel / totalWeight) or currentVel
    local finalVel = histVel:Lerp(currentVel, 0.3)
    if finalVel.Magnitude > 280 then finalVel = finalVel.Unit * 280 end
    local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local predTime = 0.15
    if myHRP then
        local dist = (currentPos - myHRP.Position).Magnitude
        predTime = math.clamp((dist / Config.TrackerFlySpeed * 0.55) + ping, 0.04, 0.45)
    end
    local predictedPos = currentPos + (finalVel * predTime)
    return predictedPos.Y < currentPos.Y and Vector3.new(predictedPos.X, currentPos.Y, predictedPos.Z) or predictedPos
end

local function ClearComponents()
    if TrackerState.LinearVel then pcall(function() TrackerState.LinearVel:Destroy() end) TrackerState.LinearVel = nil end
    if TrackerState.AntiGrav then pcall(function() TrackerState.AntiGrav:Destroy() end) TrackerState.AntiGrav = nil end
    if TrackerState.Attachment then pcall(function() TrackerState.Attachment:Destroy() end) TrackerState.Attachment = nil end
end

local function SetupComponents(hrp)
    ClearComponents()
    local att = Instance.new("Attachment")
    att.Name = "MichelleTrackerAtt"
    att.Parent = hrp
    TrackerState.Attachment = att
    local lv = Instance.new("LinearVelocity")
    lv.MaxForce = math.huge
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity = Vector3.zero
    lv.Attachment0 = att
    lv.Parent = hrp
    TrackerState.LinearVel = lv
    local totalMass = 0
    local char = hrp.Parent
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and not p.Massless then totalMass = totalMass + p:GetMass() end
        end
    end
    local vf = Instance.new("VectorForce")
    vf.ApplyAtCenterOfMass = true
    vf.Attachment0 = att
    vf.Force = Vector3.new(0, totalMass * Workspace.Gravity, 0)
    vf.Parent = hrp
    TrackerState.AntiGrav = vf
end

local function ForceStandUp()
    local myChar = lp.Character
    if not myChar then return end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHum or myHum.Health <= 0 then return end
    if myHum.Sit then
        myHum.Sit = false
        pcall(function() myHum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    if myHRP then
        for _, child in ipairs(myHRP:GetChildren()) do
            if child:IsA("Weld") then
                pcall(function() child:Destroy() end)
            elseif child:IsA("Motor6D") then
                local n = string.lower(child.Name)
                if n:find("seat") or n:find("sit") or n:find("vehicle") then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

local function FlyToTarget(tgt)
    if not tgt or not tgt.Character then return end
    local myChar = lp.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local tgHRP = tgt.Character:FindFirstChild("HumanoidRootPart")
    if not tgHRP then return end
    local now = os.clock()
    if now < TrackerState.TeleportPauseUntil then
        if TrackerState.LinearVel then TrackerState.LinearVel.VectorVelocity = Vector3.zero end
        myHRP.AssemblyLinearVelocity = Vector3.zero
        return
    end
    local rawPos = GetPredictedPos(tgt) or tgHRP.Position
    local targetPos
    if Config.TrackerPositionMode == "above" then
        targetPos = Vector3.new(rawPos.X, rawPos.Y + Config.TrackerOrbitRadius, rawPos.Z)
        TrackerState.OrbitOffset = Vector3.zero
    elseif Config.TrackerPositionMode == "hrp" then
        targetPos = rawPos
        TrackerState.OrbitOffset = Vector3.zero
    else
        if not TrackerState.OrbitOffset or now >= TrackerState.NextOrbitTime then
            local d = math.random(1, math.max(1, Config.TrackerOrbitRadius))
            local dir = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1)
            if dir.Magnitude > 0 then dir = dir.Unit end
            TrackerState.OrbitOffset = dir * d
            TrackerState.NextOrbitTime = now + 0.033
        end
        targetPos = rawPos + TrackerState.OrbitOffset
    end
    local flyDir = targetPos - myHRP.Position
    local distToTarget = (rawPos - myHRP.Position).Magnitude
    local bestEntrance, bestTime = nil, distToTarget / math.max(1, Config.TrackerFlySpeed)
    if distToTarget >= Config.TrackerNoTpRange then
        for _, e in ipairs(GetEntrances()) do
            if not TrackerState.BlockedEntrances[tostring(e.Arg)] then
                local destDist = (e.Dest - rawPos).Magnitude
                local timeViaPortal = (destDist / math.max(1, Config.TrackerFlySpeed)) + 1.5
                if timeViaPortal < bestTime and (distToTarget - destDist) > 150 then
                    bestTime = timeViaPortal
                    bestEntrance = e
                end
            end
        end
    end
    if bestEntrance then
        local key = tostring(bestEntrance.Arg)
        local lastT = TrackerState.LastTeleportTicks[key] or 0
        if now - lastT > 4 then
            TrackerState.LastTeleportTicks[key] = now
            TrackerState.TeleportPauseUntil = now + 1.2
            local preDist = (myHRP.Position - bestEntrance.Dest).Magnitude
            if TrackerState.LinearVel then TrackerState.LinearVel.VectorVelocity = Vector3.zero end
            myHRP.AssemblyLinearVelocity = Vector3.zero
            task.spawn(function()
                pcall(function() CommF:InvokeServer("requestEntrance", bestEntrance.Arg) end)
            end)
            task.spawn(function()
                task.wait(1.5)
                local h2 = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if h2 then
                    local postDist = (h2.Position - bestEntrance.Dest).Magnitude
                    if postDist > 150 and postDist >= preDist * 0.5 then
                        local fails = (TrackerState.TeleportFails[key] or 0) + 1
                        TrackerState.TeleportFails[key] = fails
                        if fails >= 3 then TrackerState.BlockedEntrances[key] = true end
                    end
                end
            end)
            return
        end
    end
    if not TrackerState.LinearVel or TrackerState.LinearVel.Parent ~= myHRP then
        SetupComponents(myHRP)
    end
    if flyDir.Magnitude > 0.01 then
        TrackerState.LinearVel.VectorVelocity = flyDir.Unit * Config.TrackerFlySpeed
    end
    local lookAt = Vector3.new(rawPos.X, myHRP.Position.Y, rawPos.Z)
    if (lookAt - myHRP.Position).Magnitude > 0.1 then
        myHRP.CFrame = CFrame.new(myHRP.Position, lookAt)
    end
end

local function StartTrackerFly()
    if TrackerState.Conn then return end
    Config.TrackerFly = true
    TrackerState.TeleportPauseUntil = 0
    TrackerState.LastTeleportTicks = {}
    TrackerState.TeleportFails = {}
    TrackerState.BlockedEntrances = {}
    TrackerState.History = {}
    TrackerState.OrbitOffset = nil
    TrackerState.NextOrbitTime = 0
    TrackerState.CurrentTarget = nil
    TrackerState.TargetLockTime = os.clock()
    TrackerState.CachedChar = nil
    TrackerState.CachedParts = nil
    TrackerState.LastNoclipScan = 0
    table.clear(TrackerState.Blacklist)
    table.clear(TrackerState.ValidCache)
    TrackerState.ValidCacheTime = 0
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
    if TrackerState.LeaveConn then TrackerState.LeaveConn:Disconnect() end
    TrackerState.LeaveConn = Players.PlayerRemoving:Connect(function(plr)
        TrackerState.History[plr] = nil
        TrackerState.Blacklist[plr] = nil
        TrackerState.ValidCache[plr] = nil
        if TrackerState.CurrentTarget == plr then TrackerState.CurrentTarget = nil end
    end)
    local lastHistUpdate = 0
    TrackerState.Conn = RunService.Heartbeat:Connect(function()
        if not Config.TrackerFly then return end
        pcall(function()
            local now = os.clock()
            ForceStandUp()
            if now - lastHistUpdate >= 0.1 then
                lastHistUpdate = now
                UpdateHistory()
            end
            local myChar = lp.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myChar or not myHRP or not myHum or myHum.Health <= 0 then return end
            if myChar ~= TrackerState.CachedChar or not TrackerState.CachedParts or now - TrackerState.LastNoclipScan >= 1 then
                TrackerState.LastNoclipScan = now
                TrackerState.CachedChar = myChar
                TrackerState.CachedParts = {}
                for _, p in ipairs(myChar:GetDescendants()) do
                    if p:IsA("BasePart") then table.insert(TrackerState.CachedParts, p) end
                end
            end
            for _, p in ipairs(TrackerState.CachedParts) do
                if p.CanCollide then p.CanCollide = false end
            end
            if not myHum.PlatformStand then myHum.PlatformStand = true end
            if TrackerState.CurrentTarget and not IsValidFast(TrackerState.CurrentTarget) then
                TrackerState.CurrentTarget = nil
            end
            local preferred = TrackerState.SelectedTarget
            if preferred and IsValidFast(preferred) then
                if TrackerState.CurrentTarget ~= preferred then
                    TrackerState.CurrentTarget = preferred
                    TrackerState.TargetLockTime = now
                end
            else
                local nearest = GetNearest()
                if nearest then
                    if TrackerState.CurrentTarget ~= nearest then
                        TrackerState.CurrentTarget = nearest
                        TrackerState.TargetLockTime = now
                    end
                else
                    TrackerState.CurrentTarget = nil
                end
            end
            if TrackerState.CurrentTarget and now - TrackerState.TargetLockTime >= TrackerState.TimeoutLimit then
                TrackerState.CurrentTarget = nil
                TrackerState.TargetLockTime = now
            end
            if TrackerState.CurrentTarget then
                FlyToTarget(TrackerState.CurrentTarget)
            else
                if TrackerState.LinearVel then TrackerState.LinearVel.VectorVelocity = Vector3.zero end
                myHRP.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end)
end

local function StopTrackerFly()
    Config.TrackerFly = false
    if TrackerState.Conn then TrackerState.Conn:Disconnect() TrackerState.Conn = nil end
    if TrackerState.LeaveConn then TrackerState.LeaveConn:Disconnect() TrackerState.LeaveConn = nil end
    ClearComponents()
    TrackerState.CurrentTarget = nil
    local char = lp.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.PlatformStand = false
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    end
end

-- ==================== M1 EXTENDER ====================
local M1ExtenderMod = (function()
    local M = {}
    local active = false
    local maxRange = 100
    local NetM = RS:WaitForChild("Modules"):WaitForChild("Net")
    local RH = NetM["RE/RegisterHit"]
    local RA = NetM["RE/RegisterAttack"]
    local function getTarget()
        local myChar = lp.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        local target, shortestDist = nil, maxRange
        for _, folder in pairs({ Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Characters") }) do
            if folder then
                for _, v in pairs(folder:GetChildren()) do
                    local eRoot = v:FindFirstChild("HumanoidRootPart")
                    local eHum = v:FindFirstChildOfClass("Humanoid")
                    if v ~= myChar and eRoot and eHum and eHum.Health > 0 then
                        local dist = (eRoot.Position - myRoot.Position).Magnitude
                        if dist < shortestDist then shortestDist = dist; target = v end
                    end
                end
            end
        end
        return target
    end
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or not active then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local target = getTarget()
            local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
            if target and tool then
                local head = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart")
                if head then
                    local sessionId = tostring(lp.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
                    pcall(function()
                        if RA then RA:FireServer() end
                        local hitData = {}
                        for _, part in pairs(target:GetChildren()) do
                            if part:IsA("BasePart") then table.insert(hitData, { target, part }) end
                        end
                        if RH then RH:FireServer(head, hitData, {}, sessionId) end
                    end)
                end
            end
        end
    end)
    function M:Toggle(v) active = v end
    function M:SetRange(v) maxRange = v end
    return M
end)()

-- ==================== GUN CLICK SL ====================
local GunClickSLMod = (function()
    local enabled = false
    local aimPos = nil
    local hookInstalled = false
    local function getClosestTarget()
        local char = lp.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closest, dist = nil, math.huge
        local myPos = root.Position
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character then
                local targetPart = player.Character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health > 0 then
                        local d = (targetPart.Position - myPos).Magnitude
                        if d < dist then dist = d; closest = targetPart end
                    end
                end
            end
        end
        return closest
    end
    local function installHook()
        if hookInstalled or not getrawmetatable or not newcclosure then return end
        hookInstalled = true
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local args = { ... }
            local method = getnamecallmethod()
            if enabled and aimPos and method == "FireServer" then
                local remoteName = tostring(self.Name or self)
                if remoteName:find("ShootGunEvent") then
                    if typeof(args[1]) == "Vector3" then args[1] = aimPos.Position end
                    if typeof(args[2]) == "table" then args[2] = { [1] = aimPos } end
                end
            end
            return oldNamecall(self, unpack(args))
        end)
        setreadonly(mt, true)
    end
    local M = {}
    function M:SetEnabled(state)
        if state == enabled then return end
        enabled = state
        if state then
            aimPos = nil
            installHook()
            task.spawn(function()
                while enabled do
                    aimPos = getClosestTarget()
                    task.wait(0.05)
                end
            end)
        else
            aimPos = nil
        end
    end
    return M
end)()

-- ==================== SILENT AIM COMPLETO (estilo Nameless - FOV + Soru + Tracer) ====================
local SilentAimModule = (function()
    local module = {}
    local player = Players.LocalPlayer
    local camera = Workspace.CurrentCamera
    local SilentAimPlayersEnabled, SilentAimNPCsEnabled = false, false
    local PredictionEnabled, PredictionAmount = true, 0.12
    local ShowFOVCircle, FOVRadius, FOVMode = false, 100, "V1"
    local AimMode, TargetPriority = "360", "Nearest"
    local SoruAutoAimEnabled, SoruAutoAimRange = false, 300
    local SoruTargetingMode, SoruFOVType, SoruFOVRadius = "360", "V1", 100
    local SoruTargetPriority, SoruShowFOVCircle = "Nearest", false
    local TracerEnabled, TracerColor = false, "Red"
    local PlayersPosition, NPCPosition, Selectedplayer
    local maxRange = 1000
    local SoruPredictedPosition
    local renderConnection, heartbeatConnection
    local currentTool, currentToolCategory = nil, "Melee"
    local currentSkillKey = nil
    local SKILL_KEYS = {"Z", "X", "C", "V", "F", "TAP"}
    local lastSkillTime = 0
    local lastDirection = nil
    local PlayerMouse = player:GetMouse()
    local PingService = game:GetService("Stats").Network.ServerStatsItem
    local OverrideEnabled = true

    local BlacklistedKeys = {
        Melee = { Z = false, X = false, C = false },
        Sword = { Z = false, X = false },
        Fruit = { Z = false, X = false, C = false, V = false, F = false, TAP = false },
        Gun   = { Z = false, X = false },
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MichelleFOV"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = CoreGui

    local FOVFrame = Instance.new("Frame")
    FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVFrame.BackgroundTransparency = 1
    FOVFrame.Visible = false
    FOVFrame.Parent = ScreenGui
    local s1 = Instance.new("UIStroke", FOVFrame)
    s1.Color = Color3.fromRGB(255, 0, 0)
    s1.Thickness = 2
    Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

    local SoruFOVFrame = Instance.new("Frame")
    SoruFOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    SoruFOVFrame.BackgroundTransparency = 1
    SoruFOVFrame.Visible = false
    SoruFOVFrame.Parent = ScreenGui
    local s2 = Instance.new("UIStroke", SoruFOVFrame)
    s2.Color = Color3.fromRGB(0, 255, 0)
    s2.Thickness = 2
    Instance.new("UICorner", SoruFOVFrame).CornerRadius = UDim.new(1, 0)

    local function getToolCategory(tool)
        if not tool then return "Melee" end
        local name = string.lower(tool.Name)
        for _, g in ipairs({"guitar", "rifle", "cannon", "gun", "slingshot", "kabucha", "serpent bow", "bow"}) do
            if string.find(name, g) then return "Gun" end
        end
        for _, m in ipairs({"claw", "godhuman", "superhuman", "talon", "step", "karate", "breath", "kung fu", "combat", "fist", "sanguine"}) do
            if string.find(name, m) then return "Melee" end
        end
        if string.find(name, "fruit") or string.find(name, "-") then return "Fruit" end
        return "Sword"
    end

    local function isOverrideTool(tool)
        if not tool then return false end
        local name = string.lower(tool.Name)
        if name == "godhuman" or string.find(name, "sanguine") or string.find(name, "yama") then return true end
        return currentToolCategory == "Sword"
    end

    local function isKeyBlacklisted(key)
        if not key then return false end
        return BlacklistedKeys[currentToolCategory] and BlacklistedKeys[currentToolCategory][key] or false
    end

    local function getHRP(model)
        return model and model:FindFirstChild("HumanoidRootPart")
    end

    local function faceTarget(targetPos)
        if not targetPos then return end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local currentPos = hrp.Position
        local lookVector = Vector3.new(targetPos.X, currentPos.Y, targetPos.Z) - currentPos
        if lookVector.Magnitude < 0.001 then return end
        hrp.CFrame = CFrame.lookAt(currentPos, currentPos + lookVector.Unit, Vector3.new(0, 1, 0))
    end

    local function setCurrentSkillKey(key)
        currentSkillKey = key
        lastSkillTime = os.clock()
        if SilentAimPlayersEnabled or SilentAimNPCsEnabled then
            local targetPos = PlayersPosition or NPCPosition
            if targetPos then task.spawn(function() faceTarget(targetPos) end) end
        end
        task.spawn(function()
            local myTime = lastSkillTime
            task.wait(1.5)
            if lastSkillTime == myTime and currentSkillKey == key then currentSkillKey = nil end
        end)
    end

    local function predicted(hrp)
        if not hrp then return nil end
        local hum = hrp.Parent:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return hrp.Position end
        if not PredictionEnabled then return hrp.Position end
        local vel = hrp.AssemblyLinearVelocity or hrp.Velocity
        local speed = vel.Magnitude
        if speed < 5 then lastDirection = nil return hrp.Position end
        local currentDirection = vel.Unit
        if lastDirection and lastDirection:Dot(currentDirection) < 0.7 then
            lastDirection = nil
            return hrp.Position
        end
        lastDirection = currentDirection
        local ping = 0
        pcall(function() if PingService then ping = PingService:GetValue() / 1000 end end)
        local factor = math.min(PredictionAmount + math.clamp(ping, 0, 0.35), speed > 100 and 0.15 or 1)
        return hrp.Position + vel * factor
    end

    local function isEnemy(tp)
        if not tp or tp == player then return false end
        if tp:GetAttribute("PvpDisabled") then return false end
        if tp.Character and tp.Character:FindFirstChildWhichIsA("ForceField") then return false end
        local myTeam, targetTeam = player.Team, tp.Team
        if myTeam and targetTeam and myTeam.Name == "Marines" and targetTeam.Name == "Marines" then return false end
        return true
    end

    local function getFOVCenter(mode)
        if mode == "V2" then return UserInputService:GetMouseLocation() end
        if not camera then camera = Workspace.CurrentCamera end
        return camera.ViewportSize / 2
    end

    local function isTargetValid(hrp, lpHRP, aimMode, fovRadius, fovType)
        if not hrp or not lpHRP then return false end
        if aimMode == "180" then
            local dir = (hrp.Position - lpHRP.Position)
            if dir.Magnitude < 0.01 then return false end
            if lpHRP.CFrame.LookVector:Dot(dir.Unit) < 0 then return false end
        elseif aimMode == "FOV" then
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if not onScreen then return false end
            if (Vector2.new(screenPos.X, screenPos.Y) - getFOVCenter(fovType)).Magnitude > fovRadius then return false end
        end
        return true
    end

    local function getClosestPlayer(lpHRP)
        if not lpHRP then return nil end
        if TargetPriority == "Lock Player" and Selectedplayer and Selectedplayer.Character then
            local hum = Selectedplayer.Character:FindFirstChildOfClass("Humanoid")
            local hrp = getHRP(Selectedplayer.Character)
            if hum and hum.Health > 0 and hrp and isTargetValid(hrp, lpHRP, AimMode, FOVRadius, FOVMode) then
                if (hrp.Position - lpHRP.Position).Magnitude <= maxRange then return Selectedplayer end
            end
            return nil
        end
        local best, bestD = nil, math.huge
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= player and isEnemy(pl) and pl.Character then
                local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                local hrp = getHRP(pl.Character)
                if hum and hum.Health > 0 and hrp and isTargetValid(hrp, lpHRP, AimMode, FOVRadius, FOVMode) then
                    local d = (hrp.Position - lpHRP.Position).Magnitude
                    if d <= maxRange and d < bestD then bestD = d; best = pl end
                end
            end
        end
        return best
    end

    local function getClosestNPC(lpHRP)
        if not lpHRP then return nil end
        local folder = Workspace:FindFirstChild("Enemies")
        if not folder then return nil end
        local best, bestD = nil, math.huge
        for _, npc in ipairs(folder:GetChildren()) do
            if npc:IsA("Model") then
                local hum = npc:FindFirstChildOfClass("Humanoid")
                local hrp = getHRP(npc)
                if hum and hum.Health > 0 and hrp and isTargetValid(hrp, lpHRP, AimMode, FOVRadius, FOVMode) then
                    local d = (hrp.Position - lpHRP.Position).Magnitude
                    if d <= maxRange and d < bestD then bestD = d; best = npc end
                end
            end
        end
        return best
    end

    local function getSoruTarget(lpHRP)
        if not lpHRP then return nil end
        local best, bestD = nil, math.huge
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= player and isEnemy(pl) and pl.Character then
                local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                local hrp = getHRP(pl.Character)
                if hum and hum.Health > 0 and hrp and isTargetValid(hrp, lpHRP, SoruTargetingMode, SoruFOVRadius, SoruFOVType) then
                    local d = (hrp.Position - lpHRP.Position).Magnitude
                    if d <= SoruAutoAimRange and d < bestD then bestD = d; best = hrp end
                end
            end
        end
        return best
    end

    task.spawn(function()
        while true do
            task.wait(0.2)
            if SoruAutoAimEnabled then
                local myHRP = getHRP(player.Character)
                local targetHRP = myHRP and getSoruTarget(myHRP)
                SoruPredictedPosition = targetHRP and targetHRP.Position or nil
            else
                SoruPredictedPosition = nil
            end
        end
    end)

    local function startRenderLoop()
        if renderConnection then return end
        renderConnection = RunService.RenderStepped:Connect(function()
            if ShowFOVCircle then
                local c = getFOVCenter(FOVMode)
                FOVFrame.Position = UDim2.new(0, c.X, 0, c.Y)
                FOVFrame.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
                FOVFrame.Visible = true
            else
                FOVFrame.Visible = false
            end
            if SoruShowFOVCircle then
                local c = getFOVCenter(SoruFOVType)
                SoruFOVFrame.Position = UDim2.new(0, c.X, 0, c.Y)
                SoruFOVFrame.Size = UDim2.new(0, SoruFOVRadius * 2, 0, SoruFOVRadius * 2)
                SoruFOVFrame.Visible = true
            else
                SoruFOVFrame.Visible = false
            end
            pcall(function()
                local lpHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not lpHRP then return end
                if SilentAimPlayersEnabled then
                    local tp = getClosestPlayer(lpHRP)
                    PlayersPosition = tp and predicted(getHRP(tp.Character)) or nil
                else
                    PlayersPosition = nil
                end
                if SilentAimNPCsEnabled then
                    local npc = getClosestNPC(lpHRP)
                    NPCPosition = npc and predicted(getHRP(npc)) or nil
                else
                    NPCPosition = nil
                end
            end)
        end)
        if not heartbeatConnection then
            heartbeatConnection = RunService.Heartbeat:Connect(function()
                if not OverrideEnabled then return end
                if not (SilentAimPlayersEnabled or SilentAimNPCsEnabled) then return end
                if currentSkillKey and isKeyBlacklisted(currentSkillKey) then return end
                if not isOverrideTool(currentTool) then return end
                if currentSkillKey ~= "Z" then return end
                local targetPos = PlayersPosition or NPCPosition
                if targetPos then
                    local cf = CFrame.new(targetPos)
                    pcall(function() PlayerMouse.Hit = cf; PlayerMouse.Target = nil end)
                end
            end)
        end
    end

    local function stopRenderLoop()
        if renderConnection then renderConnection:Disconnect() renderConnection = nil end
        if heartbeatConnection then heartbeatConnection:Disconnect() heartbeatConnection = nil end
        FOVFrame.Visible = false
        SoruFOVFrame.Visible = false
        PlayersPosition, NPCPosition = nil, nil
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local map = {
            [Enum.KeyCode.Z] = "Z", [Enum.KeyCode.X] = "X", [Enum.KeyCode.C] = "C",
            [Enum.KeyCode.V] = "V", [Enum.KeyCode.F] = "F",
        }
        if map[input.KeyCode] then setCurrentSkillKey(map[input.KeyCode]) end
    end)

    task.spawn(function()
        if not getrawmetatable or not newcclosure then return end
        local mt = getrawmetatable(game)
        if not mt then return end
        local oldNamecall, oldIndex = mt.__namecall, mt.__index
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = { ... }
            if args[1] == "TAP" then return oldNamecall(self, ...) end
            local skillKey = nil
            for _, arg in ipairs(args) do
                if type(arg) == "string" and table.find(SKILL_KEYS, arg) then skillKey = arg break end
            end
            if skillKey then
                if SilentAimPlayersEnabled or SilentAimNPCsEnabled then
                    local tp = PlayersPosition or NPCPosition
                    if tp then task.spawn(function() faceTarget(tp) end) end
                end
                setCurrentSkillKey(skillKey)
            end
            if SoruAutoAimEnabled and SoruPredictedPosition and skillKey == "C" then
                for i, arg in ipairs(args) do
                    if typeof(arg) == "Vector3" then args[i] = SoruPredictedPosition end
                end
            end
            local skip = (skillKey and isKeyBlacklisted(skillKey))
                or (not skillKey and currentSkillKey and isKeyBlacklisted(currentSkillKey))
            if not skip and method == "FireServer" and typeof(args[1]) == "Vector3" then
                if SilentAimPlayersEnabled and PlayersPosition then
                    args[1] = PlayersPosition
                elseif SilentAimNPCsEnabled and NPCPosition then
                    args[1] = NPCPosition
                end
            end
            return oldNamecall(self, unpack(args))
        end)
        mt.__index = newcclosure(function(t, k)
            if SoruAutoAimEnabled and t == PlayerMouse and SoruPredictedPosition then
                if k == "Hit" then return CFrame.new(SoruPredictedPosition) end
                if k == "Target" then return nil end
            end
            return oldIndex(t, k)
        end)
        setreadonly(mt, true)
    end)

    local function onCharacterAdded(char)
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                currentTool = child
                currentToolCategory = getToolCategory(child)
            end
        end
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                currentTool = child
                currentToolCategory = getToolCategory(child)
            end
        end)
        char.ChildRemoved:Connect(function(child)
            if child == currentTool then currentTool = nil end
        end)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then onCharacterAdded(player.Character) end

    function module:SetPlayerSilentAim(state)
        SilentAimPlayersEnabled = state
        if state then startRenderLoop() elseif not SilentAimNPCsEnabled then stopRenderLoop() end
    end
    function module:SetNPCSilentAim(state)
        SilentAimNPCsEnabled = state
        if state then startRenderLoop() elseif not SilentAimPlayersEnabled then stopRenderLoop() end
    end
    function module:SetAimMode(mode) AimMode = mode end
    function module:SetTargetPriority(prio) TargetPriority = prio end
    function module:SetShowFOVCircle(state) ShowFOVCircle = state end
    function module:SetFOVRadius(num) FOVRadius = num end
    function module:SetFOVMode(mode) FOVMode = mode end
    function module:SetDistanceLimit(num) if type(num) == "number" then maxRange = num end end
    function module:SetSoruAutoAim(state) SoruAutoAimEnabled = state; if not state then SoruPredictedPosition = nil end end
    function module:SetSoruRange(r) SoruAutoAimRange = r end
    function module:SetSoruAimMode(mode) SoruTargetingMode = mode end
    function module:SetSoruFOVType(mode) SoruFOVType = mode end
    function module:SetSoruFOVRadius(r) SoruFOVRadius = r end
    function module:SetSoruPriority(p) SoruTargetPriority = p end
    function module:SetSoruShowFOVCircle(state) SoruShowFOVCircle = state end
    function module:SetTracerEnabled(state) TracerEnabled = state end
    function module:SetTracerColor(color) TracerColor = color end
    function module:SetSelectedPlayer(name)
        Selectedplayer = (name and name ~= "") and Players:FindFirstChild(name) or nil
    end
    function module:GetTargetPos() return PlayersPosition or NPCPosition end

    -- Blacklist API
    function module:SetBlacklistKey(cat, key, state)
        if BlacklistedKeys[cat] and BlacklistedKeys[cat][key] ~= nil then
            BlacklistedKeys[cat][key] = state
        end
    end
    function module:GetBlacklistKey(cat, key)
        return BlacklistedKeys[cat] and BlacklistedKeys[cat][key] or false
    end

    return module
end)()

-- ==================== LOOPS ====================
task.spawn(function()
    while true do
        task.wait(0.03)
        if Config.FastAttack then
            pcall(function()
                local char = lp.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if not tool then return end
                local tip = tool.ToolTip
                if not table.find({ "Melee", "Sword", "Blox Fruit", "Gun" }, tip) then return end
                if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
                    tool.LeftClickRemote:FireServer(Vector3.new(0.01, -500, 0.01), 1, true)
                    return
                end
                local hits = collectTargets(Config.FARange, Config.FAPlayers, Config.FAMobs)
                if #hits == 0 then return end
                local tbl9, firstPart = {}, nil
                for _, h in ipairs(hits) do
                    local part = h[1]:FindFirstChild("Head") or h[2]
                    table.insert(tbl9, { h[1], part })
                    firstPart = firstPart or part
                end
                if registerAttack then registerAttack:FireServer(Config.FastAttackDelay or 0) end
                if firstPart and registerHit then
                    registerHit:FireServer(firstPart, tbl9, nil, nil,
                        tostring(lp.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15))
                end
                pcall(function() tool:Activate() end)
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(Config.KitsuneInterval or 0.05)
        if Config.OneShotKitsune then
            pcall(function()
                local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
                if not tool then return end
                local name = tool.Name:lower()
                if not (name:find("kitsune") or tool.ToolTip == "Blox Fruit") then return end
                local remote = tool:FindFirstChild("LeftClickRemote")
                if remote then remote:FireServer(Vector3.new(9e30, 9e30, 9e30), 5, false) end
                if registerAttack then registerAttack:FireServer(0) end
            end)
        end
    end
end)

pcall(function()
    lp.Idled:Connect(function()
        if not Config.AntiAFK then return end
        local vu = game:GetService("VirtualUser")
        if vu then vu:CaptureController(); vu:ClickButton2(Vector2.zero) end
    end)
end)

task.spawn(function()
    while true do
        task.wait(1)
        if Config.AutoV3 and CommE then pcall(function() CommE:FireServer("ActivateAbility") end) end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AutoV4 then
            pcall(function()
                local aw = (lp.Character and lp.Character:FindFirstChild("Awakening"))
                    or (lp.Backpack and lp.Backpack:FindFirstChild("Awakening"))
                if aw then
                    local rf = aw:FindFirstChildWhichIsA("RemoteFunction")
                    if rf then rf:InvokeServer(true) end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(30)
        if Config.AutoPvP then pcall(function() CommF:InvokeServer("EnablePvp") end) end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if Config.DeleteShip then
            pcall(function()
                local boats = Workspace:FindFirstChild("Boats") or Workspace:FindFirstChild("Ships")
                if boats then
                    for _, b in ipairs(boats:GetChildren()) do pcall(function() b:Destroy() end) end
                end
            end)
        end
    end
end)

local fontConn
local function applyFontsOnce()
    local font = Enum.Font[Config.FontPreset]
    if not font then return end
    for _, root in ipairs({ lp:FindFirstChild("PlayerGui"), CoreGui }) do
        if root then
            for _, obj in pairs(root:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    pcall(function() obj.Font = font end)
                end
            end
        end
    end
end
local function startFonts()
    if fontConn then fontConn:Disconnect() end
    fontConn = RunService.Heartbeat:Connect(function()
        if Config.FontEnabled then applyFontsOnce() end
    end)
end
local function stopFonts()
    if fontConn then fontConn:Disconnect() fontConn = nil end
end

RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local md = hum.MoveDirection
    if Config.SpeedMode == "WalkSpeed" then
        hum.WalkSpeed = Config.SpeedValue
    elseif Config.SpeedMode == "CFrame" and md.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + md * (Config.SpeedValue / 100)
    elseif Config.SpeedMode == "Velocity" and md.Magnitude > 0 then
        hrp.AssemblyLinearVelocity = Vector3.new(md.X * Config.SpeedValue, hrp.AssemblyLinearVelocity.Y, md.Z * Config.SpeedValue)
    elseif Config.SpeedMode == "TP-Flash" and md.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -Config.SpeedValue / 50)
    elseif Config.SpeedMode == "AnimSpeed" then
        hum.WalkSpeed = Config.SpeedValue
        for _, tr in pairs(hum:GetPlayingAnimationTracks()) do
            pcall(function() tr:AdjustSpeed(Config.SpeedValue / 16) end)
        end
    end
end)

local waterPart
task.spawn(function()
    while true do
        task.wait(0.15)
        if Config.WalkOnWater then
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if not waterPart or not waterPart.Parent then
                waterPart = Instance.new("Part")
                waterPart.Size = Vector3.new(200, 1, 200)
                waterPart.Transparency = 1
                waterPart.Anchored = true
                waterPart.CanCollide = false
                waterPart.Name = "MichelleWaterPlatform"
                waterPart.Parent = Workspace
            end
            if hrp and hrp.Position.Y >= 9.5 then
                waterPart.Position = Vector3.new(hrp.Position.X, 9.2, hrp.Position.Z)
                waterPart.CanCollide = true
            else
                waterPart.CanCollide = false
            end
        elseif waterPart then
            waterPart.CanCollide = false
        end
    end
end)

local antiLavaConn
local function startAntiLava()
    if antiLavaConn then antiLavaConn:Disconnect() end
    local t = 0
    antiLavaConn = RunService.Stepped:Connect(function(_, dt)
        t = t + dt
        if t < 0.2 then return end
        t = 0
        local char = lp.Character
        if not (char and Config.AntiLava) then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart")
                and part.Name ~= "HumanoidRootPart"
                and part.Name ~= "Head"
                and part.Name ~= "Torso"
                and part.Name ~= "UpperTorso"
                and part.Name ~= "LowerTorso" then
                pcall(function() part.CanTouch = false end)
            end
        end
    end)
end
local function stopAntiLava()
    if antiLavaConn then antiLavaConn:Disconnect() antiLavaConn = nil end
end

task.spawn(function()
    while true do
        task.wait(0.03)
        if Config.GunAura then
            pcall(function()
                local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
                if not tool or tool.ToolTip ~= "Gun" then return end
                local root = humanoidRootPart
                if not root then return end
                local best, bd = nil, Config.GunRange
                if Config.GunMobs then
                    local ef = Workspace:FindFirstChild("Enemies")
                    if ef then
                        for _, e in ipairs(ef:GetChildren()) do
                            local r = e:FindFirstChild("HumanoidRootPart")
                            local h = e:FindFirstChildOfClass("Humanoid")
                            if r and h and h.Health > 0 then
                                local d = (r.Position - root.Position).Magnitude
                                if d < bd then bd = d; best = r end
                            end
                        end
                    end
                end
                if Config.GunPlayers then
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl ~= lp and pl.Character then
                            local r = pl.Character:FindFirstChild("HumanoidRootPart")
                            local h = pl.Character:FindFirstChildOfClass("Humanoid")
                            if r and h and h.Health > 0 then
                                local d = (r.Position - root.Position).Magnitude
                                if d < bd then bd = d; best = r end
                            end
                        end
                    end
                end
                if best and ShootGunEvent then
                    tool:SetAttribute("LocalOverheat", 0)
                    tool:SetAttribute("LocalShotsLeft", 100)
                    ShootGunEvent:FireServer(best.Position, { best })
                end
            end)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not Config.BringMobs then return end
    pcall(function()
        local hrp = humanoidRootPart
        if not hrp then return end
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end
        for _, enemy in ipairs(enemies:GetChildren()) do
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if eRoot and eHum and eHum.Health > 0 and (eRoot.Position - hrp.Position).Magnitude <= Config.BringRange then
                eRoot.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 18, hrp.Position.Z)
                eRoot.CanCollide = false
            end
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(Config.FruitInterval)
        if Config.FruitAura or Config.SpecialFruitAura then
            pcall(function()
                local fruit = getFruit()
                if not fruit then return end
                local remote = fruit:FindFirstChild("LeftClickRemote")
                if not remote then return end
                if Config.SpecialFruitAura then
                    remote:FireServer(Vector3.new(9e30, 9e30, 9e30), 5, false)
                else
                    remote:FireServer(Vector3.new(0, 0, -1), 1, true)
                end
            end)
        end
    end
end)

-- HP Tracker
local trackerGui, trackerLabels = nil, {}
local function clearTracker()
    for _, l in pairs(trackerLabels) do pcall(function() l:Destroy() end) end
    trackerLabels = {}
end
local function ensureTrackerGui()
    if trackerGui and trackerGui.Parent then return end
    trackerGui = Instance.new("ScreenGui")
    trackerGui.Name = "XimenaTracker"
    trackerGui.ResetOnSpawn = false
    trackerGui.Parent = CoreGui
end
RunService.RenderStepped:Connect(function()
    if not Config.Tracker then clearTracker() return end
    ensureTrackerGui()
    local seen = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= lp and pl.Character then
            local hum = pl.Character:FindFirstChildOfClass("Humanoid")
            local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                seen[pl] = true
                local label = trackerLabels[pl]
                if not label or not label.Parent then
                    label = Instance.new("BillboardGui")
                    label.Name = "Track_" .. pl.Name
                    label.Size = UDim2.new(0, 120, 0, 40)
                    label.AlwaysOnTop = true
                    label.StudsOffset = Vector3.new(0, 3, 0)
                    label.Adornee = hrp
                    label.Parent = trackerGui
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.TextColor3 = Color3.fromRGB(255, 80, 80)
                    text.TextStrokeTransparency = 0.3
                    text.Font = Enum.Font.GothamBold
                    text.TextSize = 14
                    text.Parent = label
                    trackerLabels[pl] = label
                end
                label.Adornee = hrp
                local text = label:FindFirstChildOfClass("TextLabel")
                if text then
                    text.Text = string.format("%s\n%d / %d", pl.Name, math.floor(hum.Health), math.floor(hum.MaxHealth))
                end
            end
        end
    end
    for pl, label in pairs(trackerLabels) do
        if not seen[pl] then
            pcall(function() label:Destroy() end)
            trackerLabels[pl] = nil
        end
    end
end)

-- Manual Fly
local flyBV, flyBG, flyConn
local holdUp, holdDown = false, false
local noclipParts = {}
local function setNoclip(on)
    local char = lp.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if on then
                if noclipParts[part] == nil then noclipParts[part] = part.CanCollide end
                part.CanCollide = false
            else
                if noclipParts[part] ~= nil then part.CanCollide = noclipParts[part] end
            end
        end
    end
    if not on then noclipParts = {} end
end
local function destroyFlyMovers()
    pcall(function() if flyBV then flyBV:Destroy() end end)
    pcall(function() if flyBG then flyBG:Destroy() end end)
    flyBV, flyBG = nil, nil
end
local function cleanupFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    destroyFlyMovers()
    setNoclip(false)
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.PlatformStand = false end) end
end
local function ensureFlyMovers(hrp)
    if not hrp then return end
    if not flyBV or not flyBV.Parent then
        flyBV = Instance.new("BodyVelocity")
        flyBV.Name = "XimenaFlyBV"
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = hrp
    end
    if not flyBG or not flyBG.Parent then
        flyBG = Instance.new("BodyGyro")
        flyBG.Name = "XimenaFlyBG"
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 3e4
        flyBG.Parent = hrp
    end
end
local function startFly()
    cleanupFly()
    local hrp = humanoidRootPart
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    Config.Fly = true
    hum.PlatformStand = true
    setNoclip(true)
    ensureFlyMovers(hrp)
    flyConn = RunService.Heartbeat:Connect(function(dt)
        if not Config.Fly then return end
        hrp = humanoidRootPart
        hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        ensureFlyMovers(hrp)
        hum.PlatformStand = true
        setNoclip(true)
        local camCF = Camera.CFrame
        local look, right = camCF.LookVector, camCF.RightVector
        local md = hum.MoveDirection
        local move = Vector3.zero
        if md.Magnitude > 0.08 then
            local flatLook = Vector3.new(look.X, 0, look.Z)
            local flatRight = Vector3.new(right.X, 0, right.Z)
            if flatLook.Magnitude > 0.01 then flatLook = flatLook.Unit end
            if flatRight.Magnitude > 0.01 then flatRight = flatRight.Unit end
            local flatMd = Vector3.new(md.X, 0, md.Z)
            local fwd, str = 0, 0
            if flatMd.Magnitude > 0.01 then
                flatMd = flatMd.Unit
                fwd = flatMd:Dot(flatLook)
                str = flatMd:Dot(flatRight)
            end
            move = look * fwd + right * str
            if move.Magnitude > 0.01 then move = move.Unit * math.clamp(md.Magnitude, 0, 1) end
        end
        if holdUp then move = move + Vector3.new(0, 1, 0) end
        if holdDown then move = move - Vector3.new(0, 1, 0) end
        local targetVel = Vector3.zero
        if move.Magnitude > 0.05 then
            move = move.Unit
            targetVel = Vector3.new(move.X * Config.FlySpeed, move.Y * Config.FlyVertical, move.Z * Config.FlySpeed)
        end
        if Config.FlySmooth then
            flyBV.Velocity = flyBV.Velocity:Lerp(targetVel, math.clamp(dt * 12, 0.1, 0.5))
        else
            flyBV.Velocity = targetVel
        end
        flyBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)
    end)
end
local function stopFly()
    Config.Fly = false
    cleanupFly()
end
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space then holdUp = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift then holdDown = true end
end)
UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then holdUp = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift then holdDown = false end
end)
lp.CharacterAdded:Connect(function()
    destroyFlyMovers()
    noclipParts = {}
    task.wait(0.6)
    if Config.Fly then startFly() end
    if Config.TrackerFly then
        ClearComponents()
        task.wait(0.3)
        StartTrackerFly()
    end
end)

-- ==================== UI ====================
local Window = WindUI:CreateWindow({
    Title = "Michelle Hub",
    Icon = "star",
    Theme = "Dark",
})

local Main = Window:Tab({ Title = "Main", Icon = "home" })
Main:Toggle({ Title = "Fast Attack", Value = Config.FastAttack, Callback = function(v) Config.FastAttack = v; save() end })
Main:Toggle({ Title = "Attack Players", Value = Config.FAPlayers, Callback = function(v) Config.FAPlayers = v; save() end })
Main:Toggle({ Title = "Attack NPCs", Value = Config.FAMobs, Callback = function(v) Config.FAMobs = v; save() end })
Main:Slider({ Title = "FA Range", Step = 5, Value = { Min = 20, Max = 120, Default = Config.FARange }, Callback = function(v) Config.FARange = v; save() end })

local Profits = Window:Tab({ Title = "Profits", Icon = "dollar-sign" })
Profits:Toggle({
    Title = "Enable Fly",
    Value = Config.Fly,
    Callback = function(v)
        if v then startFly() else stopFly() end
        save()
    end,
})
Profits:Slider({ Title = "Fly Speed", Step = 10, Value = { Min = 50, Max = 600, Default = Config.FlySpeed }, Callback = function(v) Config.FlySpeed = v; save() end })
Profits:Slider({ Title = "Vertical Speed", Step = 10, Value = { Min = 50, Max = 400, Default = Config.FlyVertical }, Callback = function(v) Config.FlyVertical = v; save() end })
Profits:Toggle({ Title = "Smooth Fly", Value = Config.FlySmooth, Callback = function(v) Config.FlySmooth = v; save() end })

local Aim = Window:Tab({ Title = "Aim", Icon = "crosshair" })
Aim:Toggle({ Title = "Player Silent Aim", Value = Config.SilentPlayer, Callback = function(v)
    Config.SilentPlayer = v
    SilentAimModule:SetPlayerSilentAim(v)
    save()
end })
Aim:Toggle({ Title = "NPC Silent Aim", Value = Config.SilentNPC, Callback = function(v)
    Config.SilentNPC = v
    SilentAimModule:SetNPCSilentAim(v)
    save()
end })
Aim:Dropdown({ Title = "Aim Mode", Values = {"360","180","FOV"}, Value = Config.AimMode, Callback = function(v)
    Config.AimMode = v
    SilentAimModule:SetAimMode(v)
    save()
end })
Aim:Dropdown({ Title = "Priority", Values = {"Nearest","Low HP","Looking At Me","Lock Player"}, Value = Config.AimPriority, Callback = function(v)
    Config.AimPriority = v
    SilentAimModule:SetTargetPriority(v)
    save()
end })
Aim:Toggle({ Title = "Show FOV", Value = Config.ShowFOV, Callback = function(v)
    Config.ShowFOV = v
    SilentAimModule:SetShowFOVCircle(v)
    save()
end })
Aim:Dropdown({ Title = "FOV Mode", Values = {"V1","V2"}, Value = Config.FOVMode, Callback = function(v)
    Config.FOVMode = v
    SilentAimModule:SetFOVMode(v)
    save()
end })
-- RANGOS SUBIDOS
Aim:Slider({ Title = "FOV Radius", Step = 5, Value = { Min = 10, Max = 2000, Default = Config.FOVRadius }, Callback = function(v)
    Config.FOVRadius = v
    SilentAimModule:SetFOVRadius(v)
    save()
end })
Aim:Slider({ Title = "Max Range", Step = 50, Value = { Min = 100, Max = 10000, Default = Config.AimMaxRange }, Callback = function(v)
    Config.AimMaxRange = v
    SilentAimModule:SetDistanceLimit(v)
    save()
end })
Aim:Toggle({ Title = "M1 Extender", Value = Config.M1Extender, Callback = function(v)
    Config.M1Extender = v
    M1ExtenderMod:Toggle(v)
    save()
end })
Aim:Slider({ Title = "M1 Range", Step = 1, Value = { Min = 10, Max = 100, Default = Config.M1Range }, Callback = function(v)
    Config.M1Range = v
    M1ExtenderMod:SetRange(v)
    save()
end })
Aim:Toggle({ Title = "Gun Click SL", Value = Config.GunClickSL, Callback = function(v)
    Config.GunClickSL = v
    GunClickSLMod:SetEnabled(v)
    save()
end })

-- Soru Auto Aim
Aim:Toggle({ Title = "Soru Auto Aim", Value = Config.SoruAutoAim, Callback = function(v)
    Config.SoruAutoAim = v
    SilentAimModule:SetSoruAutoAim(v)
    save()
end })
Aim:Dropdown({ Title = "Soru Mode", Values = {"360","180","FOV"}, Value = Config.SoruMode, Callback = function(v)
    Config.SoruMode = v
    SilentAimModule:SetSoruAimMode(v)
    save()
end })
Aim:Slider({ Title = "Soru Range", Step = 10, Value = { Min = 50, Max = 1000, Default = Config.SoruRange }, Callback = function(v)
    Config.SoruRange = v
    SilentAimModule:SetSoruRange(v)
    save()
end })
Aim:Toggle({ Title = "Soru Show FOV", Value = Config.SoruShowFOV, Callback = function(v)
    Config.SoruShowFOV = v
    SilentAimModule:SetSoruShowFOVCircle(v)
    save()
end })

-- Tracer
Aim:Toggle({ Title = "Tracer", Value = Config.Tracer, Callback = function(v)
    Config.Tracer = v
    SilentAimModule:SetTracerEnabled(v)
    save()
end })
Aim:Dropdown({ Title = "Tracer Color", Values = {"Red","Green","Blue","Yellow","White"}, Value = Config.TracerColor, Callback = function(v)
    Config.TracerColor = v
    SilentAimModule:SetTracerColor(v)
    save()
end })

-- Z Boost
Aim:Toggle({ Title = "Z Boost", Value = Config.ZBoostEnabled, Callback = function(v)
    Config.ZBoostEnabled = v
    if v then createBoostGui() else destroyBoostGui() end
    save()
end })
Aim:Slider({ Title = "Z Boost Power", Step = 25, Value = { Min = 100, Max = 1500, Default = Config.ZBoostPower }, Callback = function(v)
    Config.ZBoostPower = v
    save()
end })
Aim:Slider({ Title = "Z Boost Duration", Step = 0.05, Value = { Min = 0.1, Max = 2, Default = Config.ZBoostDuration }, Callback = function(v)
    Config.ZBoostDuration = v
    save()
end })

-- ==================== BLACKLIST TAB ====================
local BlacklistTab = Window:Tab({ Title = "Blacklist", Icon = "ban" })

BlacklistTab:Paragraph({ Title = "Melee", Desc = "Bloquear teclas de Melee" })
BlacklistTab:Toggle({ Title = "Melee: Blacklist Z", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Melee", "Z", v)
end })
BlacklistTab:Toggle({ Title = "Melee: Blacklist X", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Melee", "X", v)
end })
BlacklistTab:Toggle({ Title = "Melee: Blacklist C", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Melee", "C", v)
end })

BlacklistTab:Paragraph({ Title = "Sword", Desc = "Bloquear teclas de Sword" })
BlacklistTab:Toggle({ Title = "Sword: Blacklist Z", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Sword", "Z", v)
end })
BlacklistTab:Toggle({ Title = "Sword: Blacklist X", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Sword", "X", v)
end })

BlacklistTab:Paragraph({ Title = "Fruit", Desc = "Bloquear teclas de Fruit" })
BlacklistTab:Toggle({ Title = "Fruit: Blacklist Z", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Fruit", "Z", v)
end })
BlacklistTab:Toggle({ Title = "Fruit: Blacklist X", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Fruit", "X", v)
end })
BlacklistTab:Toggle({ Title = "Fruit: Blacklist C", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Fruit", "C", v)
end })
BlacklistTab:Toggle({ Title = "Fruit: Blacklist V", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Fruit", "V", v)
end })
BlacklistTab:Toggle({ Title = "Fruit: Blacklist F", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Fruit", "F", v)
end })
BlacklistTab:Toggle({ Title = "Fruit: Blacklist TAP", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Fruit", "TAP", v)
end })

BlacklistTab:Paragraph({ Title = "Gun", Desc = "Bloquear teclas de Gun" })
BlacklistTab:Toggle({ Title = "Gun: Blacklist Z", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Gun", "Z", v)
end })
BlacklistTab:Toggle({ Title = "Gun: Blacklist X", Value = false, Callback = function(v)
    SilentAimModule:SetBlacklistKey("Gun", "X", v)
end })

local GunAura = Window:Tab({ Title = "Gun Aura", Icon = "target" })
GunAura:Toggle({ Title = "Enable Gun Aura", Value = Config.GunAura, Callback = function(v) Config.GunAura = v; save() end })
GunAura:Toggle({ Title = "Attack Players", Value = Config.GunPlayers, Callback = function(v) Config.GunPlayers = v; save() end })
GunAura:Toggle({ Title = "Attack NPCs", Value = Config.GunMobs, Callback = function(v) Config.GunMobs = v; save() end })
GunAura:Toggle({ Title = "Bring Mobs", Value = Config.BringMobs, Callback = function(v) Config.BringMobs = v; save() end })
GunAura:Slider({ Title = "Gun Range", Step = 50, Value = { Min = 50, Max = 30000, Default = Config.GunRange }, Callback = function(v) Config.GunRange = v; save() end })
GunAura:Slider({ Title = "Bring Range", Step = 50, Value = { Min = 50, Max = 3000, Default = Config.BringRange }, Callback = function(v) Config.BringRange = v; save() end })

local AttackFruit = Window:Tab({ Title = "Attack Fruit", Icon = "sword" })
AttackFruit:Toggle({ Title = "Fruit Aura", Value = Config.FruitAura, Callback = function(v) Config.FruitAura = v; save() end })
AttackFruit:Toggle({ Title = "Special Fruit Aura", Value = Config.SpecialFruitAura, Callback = function(v) Config.SpecialFruitAura = v; save() end })
AttackFruit:Toggle({ Title = "One Shot Kitsune", Value = Config.OneShotKitsune, Callback = function(v) Config.OneShotKitsune = v; save() end })
AttackFruit:Slider({ Title = "Fruit Speed", Step = 0.01, Value = { Min = 0.01, Max = 0.2, Default = Config.FruitInterval }, Callback = function(v) Config.FruitInterval = v; save() end })
AttackFruit:Slider({ Title = "Kitsune Interval", Step = 0.01, Value = { Min = 0.01, Max = 0.2, Default = Config.KitsuneInterval }, Callback = function(v) Config.KitsuneInterval = v; save() end })

local TrackerTab = Window:Tab({ Title = "Tracker", Icon = "eye" })
TrackerTab:Toggle({
    Title = "Player HP Tracker",
    Value = Config.Tracker,
    Callback = function(v)
        Config.Tracker = v
        if not v then clearTracker() end
        save()
    end,
})

local Misc = Window:Tab({ Title = "Misc", Icon = "settings" })
Misc:Toggle({ Title = "Anti AFK", Value = Config.AntiAFK, Callback = function(v) Config.AntiAFK = v; save() end })
Misc:Toggle({ Title = "Auto V3", Value = Config.AutoV3, Callback = function(v) Config.AutoV3 = v; save() end })
Misc:Toggle({ Title = "Auto V4", Value = Config.AutoV4, Callback = function(v) Config.AutoV4 = v; save() end })
Misc:Toggle({ Title = "Auto PvP", Value = Config.AutoPvP, Callback = function(v) Config.AutoPvP = v; save() end })
Misc:Toggle({ Title = "Infinite Zoom", Value = Config.InfiniteZoom, Callback = function(v)
    Config.InfiniteZoom = v
    lp.CameraMaxZoomDistance = v and math.huge or savedZoom
    save()
end })
Misc:Button({ Title = "Buy Cyborg Race", Callback = function() pcall(function() CommF:InvokeServer("CyborgTrainer", "Buy") end) end })
Misc:Button({ Title = "Buy Ghoul Race", Callback = function()
    pcall(function()
        CommF:InvokeServer("Ectoplasm", "BuyCheck", 4)
        CommF:InvokeServer("Ectoplasm", "Change", 4)
    end)
end })
Misc:Button({ Title = "Reset Stats", Callback = function() pcall(function() CommF:InvokeServer("BlackbeardReward", "Refund", "2") end) end })
Misc:Button({ Title = "Reroll Race", Callback = function() pcall(function() CommF:InvokeServer("BlackbeardReward", "Reroll", "2") end) end })
Misc:Button({ Title = "Save Config Now", Callback = function()
    SaveConfig()
    pcall(function() WindUI:Notify({ Title = "Michelle Hub", Content = "Config guardada", Duration = 2 }) end)
end })

local Utils = Window:Tab({ Title = "Utilities", Icon = "layers" })
Utils:Toggle({ Title = "Delete Ships", Value = Config.DeleteShip, Callback = function(v) Config.DeleteShip = v; save() end })

local Deidad = Window:Tab({ Title = "Deidad", Icon = "crown" })
Deidad:Dropdown({
    Title = "Font Style",
    Values = FONT_LIST,
    Value = Config.FontPreset,
    Callback = function(v)
        Config.FontPreset = v
        if Config.FontEnabled then applyFontsOnce() end
        save()
    end,
})
Deidad:Toggle({ Title = "Enable Font", Value = Config.FontEnabled, Callback = function(v)
    Config.FontEnabled = v
    if v then startFonts() else stopFonts() end
    save()
end })
Deidad:Toggle({ Title = "Walk on Water", Value = Config.WalkOnWater, Callback = function(v) Config.WalkOnWater = v; save() end })
Deidad:Toggle({ Title = "Anti Lava", Value = Config.AntiLava, Callback = function(v)
    Config.AntiLava = v
    if v then startAntiLava() else stopAntiLava() end
    save()
end })
Deidad:Toggle({ Title = "Speed Hack", Value = Config.SpeedEnabled, Callback = function(v)
    Config.SpeedEnabled = v
    if not v then
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
    save()
end })
Deidad:Dropdown({
    Title = "Speed Mode",
    Values = {"WalkSpeed","CFrame","Velocity","TP-Flash","AnimSpeed"},
    Value = Config.SpeedMode,
    Callback = function(v) Config.SpeedMode = v; save() end,
})
Deidad:Slider({ Title = "Speed Value", Step = 1, Value = { Min = 16, Max = 500, Default = Config.SpeedValue }, Callback = function(v) Config.SpeedValue = v; save() end })

-- OTHERS = Tracker Orbit
local Others = Window:Tab({ Title = "Others", Icon = "map" })
Others:Paragraph({ Title = "Tracker Orbit", Desc = "Orbit / above / hrp al jugador" })
Others:Toggle({
    Title = "Enable Tracker Orbit",
    Value = Config.TrackerFly,
    Callback = function(v)
        if v then
            StartTrackerFly()
            pcall(function() WindUI:Notify({ Title = "Michelle Hub", Content = "Orbit ON", Duration = 2 }) end)
        else
            StopTrackerFly()
            pcall(function() WindUI:Notify({ Title = "Michelle Hub", Content = "Orbit OFF", Duration = 2 }) end)
        end
        save()
    end,
})
Others:Dropdown({
    Title = "Position Mode",
    Values = {"orbit", "above", "hrp"},
    Value = Config.TrackerPositionMode,
    Callback = function(v)
        Config.TrackerPositionMode = v
        TrackerState.OrbitOffset = nil
        save()
    end,
})
Others:Slider({
    Title = "Fly Speed",
    Step = 25,
    Value = { Min = 50, Max = 600, Default = Config.TrackerFlySpeed },
    Callback = function(v) Config.TrackerFlySpeed = v; save() end,
})
Others:Slider({
    Title = "Orbit Radius",
    Step = 5,
    Value = { Min = 5, Max = 150, Default = Config.TrackerOrbitRadius },
    Callback = function(v) Config.TrackerOrbitRadius = v; save() end,
})
Others:Slider({
    Title = "No Portal Range",
    Step = 25,
    Value = { Min = 50, Max = 600, Default = Config.TrackerNoTpRange },
    Callback = function(v) Config.TrackerNoTpRange = v; save() end,
})
local playerNames = {"Nearest"}
for _, pl in ipairs(Players:GetPlayers()) do
    if pl ~= lp then table.insert(playerNames, pl.Name) end
end
Others:Dropdown({
    Title = "Lock Target",
    Values = playerNames,
    Value = "Nearest",
    Callback = function(name)
        if name == "Nearest" then
            TrackerState.SelectedTarget = nil
        else
            TrackerState.SelectedTarget = Players:FindFirstChild(name)
        end
    end,
})

task.defer(function()
    if Config.SilentPlayer then SilentAimModule:SetPlayerSilentAim(true) end
    if Config.SilentNPC then SilentAimModule:SetNPCSilentAim(true) end
    SilentAimModule:SetAimMode(Config.AimMode)
    SilentAimModule:SetTargetPriority(Config.AimPriority)
    SilentAimModule:SetShowFOVCircle(Config.ShowFOV)
    SilentAimModule:SetFOVMode(Config.FOVMode)
    SilentAimModule:SetFOVRadius(Config.FOVRadius)
    SilentAimModule:SetDistanceLimit(Config.AimMaxRange)
    if Config.M1Extender then M1ExtenderMod:Toggle(true) end
    M1ExtenderMod:SetRange(Config.M1Range)
    if Config.GunClickSL then GunClickSLMod:SetEnabled(true) end
    if Config.SoruAutoAim then SilentAimModule:SetSoruAutoAim(true) end
    if Config.TrackerFly then StartTrackerFly() end
    if Config.Fly then startFly() end
    if Config.AntiLava then startAntiLava() end
    if Config.FontEnabled then startFonts() end
    if Config.InfiniteZoom then lp.CameraMaxZoomDistance = math.huge end
    if Config.ZBoostEnabled then createBoostGui() end
end)

pcall(function()
    WindUI:Notify({ Title = "Ximena Hub", Content = "Cargado correctamente", Duration = 3 })
end)
print("Ximena hub ")
