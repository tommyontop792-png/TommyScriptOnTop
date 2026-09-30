-- ============================================================
-- 👑 TOMMY SCRIPT - BLOX FRUITS PVP
-- Interfaz custom dorada + Todas las funciones de Nameless
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local lp = player

-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG = {
    Accent    = Color3.fromRGB(255, 200, 40),
    AccentDim = Color3.fromRGB(180, 140, 30),
    BG        = Color3.fromRGB(14, 14, 18),
    Card      = Color3.fromRGB(22, 22, 28),
    CardHover = Color3.fromRGB(30, 30, 38),
    Text      = Color3.fromRGB(240, 240, 245),
    TextDim   = Color3.fromRGB(150, 150, 160),
    Success   = Color3.fromRGB(80, 220, 120),
    Danger    = Color3.fromRGB(240, 80, 80),
}

-- ============================================================
-- HELPERS
-- ============================================================
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")

local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(r, parent) return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, parent) end
local function stroke(color, thickness, parent) return new("UIStroke", {Color = color, Thickness = thickness or 1}, parent) end

-- ============================================================
-- PERMANENT MARKER FONT
-- ============================================================
local PermanentMarkerFont = Font.new(
    "rbxasset://fonts/families/PermanentMarker.json",
    Enum.FontWeight.Regular,
    Enum.FontStyle.Normal
)

local function applyFont()
    local CoreGui = game:GetService("CoreGui")
    local PlayerGui = lp:FindFirstChild("PlayerGui")
    for _, p in ipairs({CoreGui, PlayerGui}) do
        if p then
            for _, obj in pairs(p:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    pcall(function() obj.FontFace = PermanentMarkerFont end)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(applyFont)
    end
end)

-- ============================================================
-- SERVICES & VARIABLES
-- ============================================================
local RS = ReplicatedStorage

local sharkZActive, vActive, cursedZActive = false, false, false
local rightTouchActive = false
local damageDetected = false
local isBunnyHopping = false

-- ============================================================
-- AHK LOADERS
-- ============================================================
local function UnloadAHKsoru()
    _G.TommyAHKRunning = nil
    pcall(function()
        local containers = {lp:FindFirstChild("PlayerGui"), game:GetService("CoreGui")}
        for _, parent in ipairs(containers) do
            if parent then
                for _, child in pairs(parent:GetChildren()) do
                    if child.Name:find("AHK_Soru") or child.Name:find("Tommy_AHK_Soru") then
                        child:Destroy()
                    end
                end
            end
        end
    end)
end

local function LoadAHKsoru()
    _G.TommyAHKRunning = nil
    pcall(function()
        local script_code = game:HttpGet("https://raw.githubusercontent.com/sykq0/Namelesssoru/refs/heads/main/ahk.lua")
        loadstring(script_code)()
    end)
end

local function UnloadAHKComboScript()
    _G.TommyComboRunning = nil
    pcall(function()
        local containers = {lp:FindFirstChild("PlayerGui"), game:GetService("CoreGui")}
        for _, parent in ipairs(containers) do
            if parent then
                for _, child in pairs(parent:GetChildren()) do
                    if child.Name:find("AHK_Combo") or child.Name:find("Tommy_AHK_Combo") then
                        child:Destroy()
                    end
                end
            end
        end
    end)
end

local function LoadAHKComboScript()
    _G.TommyComboRunning = nil
    pcall(function()
        local script_code = game:HttpGet("https://raw.githubusercontent.com/sykq0/Namelesssoru/refs/heads/main/fetched-1.lua")
        loadstring(script_code)()
    end)
end

-- ============================================================
-- DAMAGE MONITOR
-- ============================================================
task.spawn(function()
    while true do
        local gui = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main")
        local dmgCounter = gui and gui:FindFirstChild("DmgCounter")
        local dmgTextLabel = dmgCounter and dmgCounter:FindFirstChild("Text")
        if dmgTextLabel then
            dmgTextLabel:GetPropertyChangedSignal("Text"):Connect(function()
                local dmgText = tonumber(dmgTextLabel.Text) or 0
                damageDetected = (dmgText > 0)
            end)
            break
        end
        task.wait(1)
    end
end)

local function isValidStopCondition()
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    return (tool and tool.Name == "Shark Anchor" and sharkZActive)
        or (vActive)
        or (tool and tool.Name == "Cursed Dual Katana" and cursedZActive)
end

-- ============================================================
-- BOOSTS
-- ============================================================
local multiEnabled = false; local multiPower = 400; local multiDuration = 0.9
local multiCharging = false; local multiChargeStart = 0; local multiRequiredCharge = 1.0

local diamondEnabled = false; local diamondPower = 250; local diamondDuration = 0.3
local diamondCharging = false; local diamondChargeStart = 0; local diamondRequiredCharge = 1.0

local dtalonEnabled = false; local dtalonPower = 400; local dtalonDuration = 0.9
local dtalonCharging = false; local dtalonChargeStart = 0; local dtalonRequiredCharge = 1.0

local EClawBoost

local function createBoost(power, duration)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    local dir = camera.CFrame.LookVector
    hum.PlatformStand = true
    local att = Instance.new("Attachment", hrp)
    local lv = Instance.new("LinearVelocity", hrp)
    lv.MaxForce = 9999999
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity = dir * power
    lv.Attachment0 = att
    local boostActive = true
    local boostEndTime = tick() + duration
    local dmgConn
    local function stopPropulsion()
        if not boostActive then return end
        boostActive = false
        if lv then lv:Destroy() end
        if att then att:Destroy() end
        if hum then hum.PlatformStand = false end
        if dmgConn then dmgConn:Disconnect() end
    end
    local dmgLabel = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("DmgCounter") and lp.PlayerGui.Main.DmgCounter:FindFirstChild("Text")
    local startText = dmgLabel and dmgLabel.Text or ""
    if dmgLabel then
        dmgConn = dmgLabel:GetPropertyChangedSignal("Text"):Connect(function()
            local currentText = dmgLabel.Text
            if (currentText ~= startText and currentText ~= "" and currentText ~= "0") or (rightTouchActive and isValidStopCondition()) then
                stopPropulsion()
            end
        end)
    end
    while boostActive and tick() < boostEndTime do task.wait() end
    stopPropulsion()
end

RunService.Heartbeat:Connect(function()
    if not multiEnabled then return end
    local char = lp.Character; local hum = char and char:FindFirstChild("Humanoid"); if not hum then return end
    local isGC = false
    for _, a in pairs(hum:GetPlayingAnimationTracks()) do
        if a.Animation.AnimationId:find("14418367908") or a.Name == "GhoulZCharge" then isGC = true; break end
    end
    if isGC then
        if not multiCharging then multiCharging = true; multiChargeStart = tick() end
    else
        if multiCharging then
            if (tick() - multiChargeStart) >= multiRequiredCharge then task.spawn(function() createBoost(multiPower, multiDuration) end) end
            multiCharging = false; multiChargeStart = 0
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not diamondEnabled then return end
    local char = lp.Character; local hum = char and char:FindFirstChild("Humanoid"); if not hum then return end
    local isC = false
    for _, a in pairs(hum:GetPlayingAnimationTracks()) do
        if a.Animation.AnimationId:find("14414815375") then isC = true; break end
    end
    if isC then
        if not diamondCharging then diamondCharging = true; diamondChargeStart = tick() end
    else
        if diamondCharging then
            if (tick() - diamondChargeStart) >= diamondRequiredCharge then task.spawn(function() createBoost(diamondPower, diamondDuration) end) end
            diamondCharging = false; diamondChargeStart = 0
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not dtalonEnabled then return end
    local char = lp.Character; local hum = char and char:FindFirstChild("Humanoid"); if not hum then return end
    local isC = false
    for _, a in pairs(hum:GetPlayingAnimationTracks()) do
        if a.Animation.AnimationId:find("18839089313") or a.Name == "DTalon_ZCharge" then isC = true; break end
    end
    if isC then
        if not dtalonCharging then dtalonCharging = true; dtalonChargeStart = tick() end
    else
        if dtalonCharging then
            if (tick() - dtalonChargeStart) >= dtalonRequiredCharge then task.spawn(function() createBoost(dtalonPower, dtalonDuration) end) end
            dtalonCharging = false; dtalonChargeStart = 0
        end
    end
end)

EClawBoost = (function()
    local M = {}; local enabled = false; local power = 400; local duration = 1.7; local requiredCharge = 0.0; local boosted = false
    local function boost()
        local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local mouse = lp:GetMouse(); local dir = (mouse.Hit.p - hrp.Position).Unit
        hum.PlatformStand = true
        local att = Instance.new("Attachment", hrp)
        local lv = Instance.new("LinearVelocity", hrp)
        lv.MaxForce = 9999999
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.VectorVelocity = dir * power
        lv.Attachment0 = att
        local boostActive = true
        local boostEndTime = tick() + duration
        local dmgConn
        local function stopPropulsion()
            if not boostActive then return end; boostActive = false
            if lv then lv:Destroy() end; if att then att:Destroy() end; if hum then hum.PlatformStand = false end; if dmgConn then dmgConn:Disconnect() end
        end
        local dmgLabel = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("DmgCounter") and lp.PlayerGui.Main.DmgCounter:FindFirstChild("Text")
        local startText = dmgLabel and dmgLabel.Text or ""
        if dmgLabel then
            dmgConn = dmgLabel:GetPropertyChangedSignal("Text"):Connect(function()
                local currentText = dmgLabel.Text
                if (currentText ~= startText and currentText ~= "" and currentText ~= "0") or (rightTouchActive and isValidStopCondition()) then
                    stopPropulsion()
                end
            end)
        end
        while boostActive and tick() < boostEndTime do task.wait() end; stopPropulsion()
    end
    local function hookAnimations(hum)
        hum.AnimationPlayed:Connect(function(track)
            if not enabled then return end
            if track.Animation.AnimationId:find("6875496851") or track.Name == "ElectroClawXImpact" then
                boosted = false; local chargeStart = tick()
                track.Stopped:Connect(function()
                    if not enabled and not boosted then return end
                    if (tick() - chargeStart) >= requiredCharge then boosted = true; task.spawn(boost) end
                end)
            end
        end)
    end
    function M:Toggle(v) enabled = v; if not v then boosted = false end end
    function M:SetPower(v) power = v end
    function M:SetDuration(v) duration = v end
    function M:SetRequiredCharge(v) requiredCharge = v end
    function M:Init(char) local hum = char:WaitForChild("Humanoid"); hookAnimations(hum) end
    return M
end)()

lp.CharacterAdded:Connect(function(char) EClawBoost:Init(char) end)
if lp.Character then EClawBoost:Init(lp.Character) end

-- ============================================================
-- FAKE HEADLESS / KORBLOX
-- ============================================================
local fakeHeadlessEnabled = false
local fakeKorbloxEnabled = false
local korbloxMeshes = {}

local function applyFakeKorblox()
    local char = lp.Character; if not char then return end
    local rl = char:FindFirstChild("RightUpperLeg")
    local rl2 = char:FindFirstChild("RightLowerLeg")
    local rf = char:FindFirstChild("RightFoot")
    if rl then
        rl.Transparency = 1
        for _, c in pairs(rl:GetChildren()) do if c:IsA("SpecialMesh") then c:Destroy() end end
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://139607718"
        mesh.TextureId = "rbxassetid://139607673"
        mesh.Scale = Vector3.new(1,1,1)
        mesh.Parent = rl
        table.insert(korbloxMeshes, mesh)
    end
    if rl2 then rl2.Transparency = 1 end
    if rf then rf.Transparency = 1 end
end

local function removeFakeKorblox()
    for _, m in pairs(korbloxMeshes) do pcall(function() m:Destroy() end) end
    korbloxMeshes = {}
    local char = lp.Character; if not char then return end
    for _, n in pairs({"RightUpperLeg","RightLowerLeg","RightFoot"}) do
        local p = char:FindFirstChild(n); if p then p.Transparency = 0 end
    end
end

local function applyFakeHeadless()
    local char = lp.Character; if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        local face = head:FindFirstChild("face")
        if face then face.Transparency = 1 end
    end
end

local function removeFakeHeadless()
    local char = lp.Character; if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0
        local face = head:FindFirstChild("face")
        if face then face.Transparency = 0 end
    end
end

lp.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if fakeHeadlessEnabled then applyFakeHeadless() end
    if fakeKorbloxEnabled then applyFakeKorblox() end
end)

-- ============================================================
-- MOVEMENT
-- ============================================================
local bunnyHopEnabled = false
local superJumpEnabled = false
local superJumpPower = 150
local superJumpButton = nil

local dashLengthEnabled = false
local dashLengthValue = 1
local dashLengthConnection = nil

local flySettings = { flyActive = false, noclipActive = false, mode = "CFrame", speed = 50, incore = nil, nocore = nil }
local speedSettings = { speedActive = false, mode = "WalkSpeed", speedValue = 50, incore = nil }

local function StartFly()
    if flySettings.incore then flySettings.incore:Disconnect() end
    flySettings.flyActive = true
    flySettings.incore = RunService.Stepped:Connect(function()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not flySettings.flyActive or not hrp or not hum then return end
        local moveDir = hum.MoveDirection
        local camCF = camera.CFrame
        local direction = Vector3.new(0, 0, 0)
        if moveDir.Magnitude > 0 then
            local relativeMove = camCF:VectorToObjectSpace(moveDir)
            direction = ((camCF.RightVector * relativeMove.X) + (camCF.LookVector * -relativeMove.Z)).Unit
        end
        if flySettings.mode == "CFrame" then
            hum.PlatformStand = true
            hrp.CFrame = hrp.CFrame + (direction * (flySettings.speed / 10))
            hrp.Velocity = Vector3.zero
        elseif flySettings.mode == "Velocity" then
            hrp.Velocity = (direction * flySettings.speed) + Vector3.new(0, 2, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then hrp.CFrame = hrp.CFrame + Vector3.new(0, flySettings.speed / 15, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then hrp.CFrame = hrp.CFrame + Vector3.new(0, -flySettings.speed / 15, 0) end
    end)
end

local function StopFly()
    flySettings.flyActive = false
    if flySettings.incore then flySettings.incore:Disconnect(); flySettings.incore = nil end
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.PlatformStand = false end
end

local function StartNoClip()
    if flySettings.nocore then flySettings.nocore:Disconnect() end
    flySettings.nocore = RunService.Stepped:Connect(function()
        if lp.Character then
            for _, p in pairs(lp.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end

local function StopNoClip()
    if flySettings.nocore then flySettings.nocore:Disconnect(); flySettings.nocore = nil end
end

local function applySpeedHack()
    local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local moveDir = hum.MoveDirection
    if speedSettings.mode == "WalkSpeed" then
        hum.WalkSpeed = speedSettings.speedValue
    elseif speedSettings.mode == "CFrame" and moveDir.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (moveDir * (speedSettings.speedValue / 100))
    elseif speedSettings.mode == "Velocity" and moveDir.Magnitude > 0 then
        hrp.Velocity = Vector3.new(moveDir.X * speedSettings.speedValue, hrp.Velocity.Y, moveDir.Z * speedSettings.speedValue)
    elseif speedSettings.mode == "TP-Flash" and moveDir.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -speedSettings.speedValue / 50)
    elseif speedSettings.mode == "AnimSpeed" then
        hum.WalkSpeed = speedSettings.speedValue
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(speedSettings.speedValue / 16) end
    end
end

local function StartSpeedHack() speedSettings.speedActive = true end
local function StopSpeedHack()
    speedSettings.speedActive = false
    if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then lp.Character.Humanoid.WalkSpeed = 16 end
end

RunService.Heartbeat:Connect(function()
    if not speedSettings.speedActive then return end
    applySpeedHack()
end)

-- ============================================================
-- SUPER JUMP
-- ============================================================
local function applySuperJumpV1()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = superJumpPower
    end
end

local function resetSuperJumpToNormal()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 50 end
end

RunService.Heartbeat:Connect(function()
    if superJumpEnabled and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = (damageDetected or isBunnyHopping) and 50 or superJumpPower end
    end
end)

-- ============================================================
-- DASH GLITCH (Skull Guitar)
-- ============================================================
local dashLength = 190
local speedBoost = 350
local airSpeed = 400
local dashCooldown = 1.5
local dashEnabled = false
local dashV1Active = false
local dashV2Trigger = false

local function doDashCombo()
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or tool.Name ~= "Skull Guitar" or not hrp or not hum then return end
    local remote = tool:FindFirstChild("RemoteEvent")
    if not remote then return end

    hum.PlatformStand = true
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    remote:FireServer("TAP", Vector3.new(-1221.487548828125, 69.36107635498047, -566.5001220703125))

    char:SetAttribute("DashLength", dashLength)
    char:SetAttribute("DashLengthAir", dashLength)
    hrp.AssemblyLinearVelocity = hrp.CFrame.LookVector * speedBoost

    task.delay(0.2, function()
        if char then
            char:SetAttribute("DashLength", 1)
            char:SetAttribute("DashLengthAir", 1)
        end
    end)
    task.wait(0.25)
    hum.PlatformStand = false
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
end

task.spawn(function()
    while true do
        task.wait(dashCooldown)
        if dashEnabled and dashV1Active then
            local char = lp.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool and tool.Name == "Skull Guitar" then doDashCombo() end
        end
    end
end)

RunService.Stepped:Connect(function()
    if not dashEnabled then return end
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local tool = char and char:FindFirstChildOfClass("Tool")
    if hum and tool and tool.Name == "Skull Guitar" then
        if hum.FloorMaterial == Enum.Material.Air then
            hum.WalkSpeed = airSpeed
        else
            hum.WalkSpeed = 16
            hum.PlatformStand = false
        end
    elseif hum then
        hum.WalkSpeed = 16
        hum.PlatformStand = false
    end
end)

-- ============================================================
-- NO GFX
-- ============================================================
local noGfxMode = "Off"
local noGfxModifiedObjects = {}
local noGfxConnection = nil

local function restoreNoGfx()
    for obj, data in pairs(noGfxModifiedObjects) do
        pcall(function()
            if data.Texture ~= nil then obj.Texture = data.Texture end
            if data.Enabled ~= nil then obj.Enabled = data.Enabled end
        end)
    end
    noGfxModifiedObjects = {}
    if noGfxConnection then noGfxConnection:Disconnect(); noGfxConnection = nil end
end

local function processObject(inst)
    local cn = inst.ClassName
    if cn == "Beam" or cn == "Trail" then
        if not noGfxModifiedObjects[inst] then
            noGfxModifiedObjects[inst] = {Texture = inst.Texture}
            inst.Texture = "rbxassetid://84308155859778"
        end
    elseif cn == "ParticleEmitter" then
        if not noGfxModifiedObjects[inst] then
            noGfxModifiedObjects[inst] = {Texture = inst.Texture, Enabled = inst.Enabled}
            inst.Texture = ""
            inst.Enabled = false
        end
    end
end

local function setNoGfxMode(mode)
    if mode == noGfxMode then return end
    noGfxMode = mode
    restoreNoGfx()
    if mode ~= "Off" then
        task.spawn(function()
            for _, inst in pairs(workspace:GetDescendants()) do
                if not inst:IsA("Terrain") and not inst:IsA("Camera") then processObject(inst) end
            end
        end)
        noGfxConnection = workspace.DescendantAdded:Connect(processObject)
    end
end

-- ============================================================
-- DELETE SHIP
-- ============================================================
local deleteShipActive = false

local function deleteShipStructure()
    if not deleteShipActive then return end
    task.spawn(function()
        local shipNames = {"CursedShip", "Cursed Ship", "Ship"}
        local exteriorNames = {"Wall", "Floor", "Ceiling", "Base", "Hull", "Window", "DoorFrame"}
        for _, obj in pairs(workspace:GetDescendants()) do
            for _, sName in ipairs(shipNames) do
                if obj.Name:find(sName) and (obj:IsA("Model") or obj:IsA("Folder")) then
                    for _, child in pairs(obj:GetDescendants()) do
                        if child:IsA("BasePart") and not child.Parent:FindFirstChild("Humanoid") then
                            local isExterior = false
                            for _, ext in ipairs(exteriorNames) do
                                if child.Name:find(ext) then isExterior = true; break end
                            end
                            if not isExterior then child:Destroy() end
                        end
                    end
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(3)
        if deleteShipActive then deleteShipStructure() end
    end
end)

-- ============================================================
-- WALK ON WATER
-- ============================================================
local WalkOnWaterEnabled = false
local waterPart = nil

task.spawn(function()
    while true do
        task.wait(0.15)
        if WalkOnWaterEnabled then
            if not waterPart or not waterPart.Parent then
                waterPart = Instance.new("Part")
                waterPart.Size = Vector3.new(200, 1, 200)
                waterPart.Transparency = 1
                waterPart.Anchored = true
                waterPart.CanCollide = false
                waterPart.Name = "TommyWater"
                waterPart.Parent = workspace
            end
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y >= 9.5 then
                waterPart.Position = Vector3.new(hrp.Position.X, 9.2, hrp.Position.Z)
                waterPart.CanCollide = true
            else
                waterPart.CanCollide = false
            end
        elseif waterPart and waterPart.Parent then
            waterPart.CanCollide = false
        end
    end
end)

-- ============================================================
-- ANTI LAVA
-- ============================================================
local antiLavaActive = false

RunService.Stepped:Connect(function(_, dt)
    if antiLavaActive and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Head" then
                part.CanTouch = false
            end
        end
    end
end)

-- ============================================================
-- ESP
-- ============================================================
local ESPModule = (function()
    local module = {}
    local ESPEnabled = false
    local ShowBox, ShowName, ShowDistance, ShowHealth, ShowLine = true, true, true, true, true
    local BoxColor, TextColor, LineColor = "Red", "White", "Red"
    local ShowAllPlayers = false
    local LineOrigin = "Player"
    local drawings = {}
    
    local function clearDrawings()
        for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
        drawings = {}
    end
    
    local function getColor(name)
        local colors = {
            Red=Color3.new(1,0,0), Green=Color3.new(0,1,0), Blue=Color3.new(0,0,1),
            Yellow=Color3.new(1,1,0), White=Color3.new(1,1,1), Cyan=Color3.new(0,1,1),
            Magenta=Color3.new(1,0,1)
        }
        return colors[name] or Color3.new(1,1,1)
    end
    
    local function isEnemy(plr)
        if plr == lp then return false end
        if ShowAllPlayers then return true end
        local myTeam = lp.Team; local targetTeam = plr.Team
        if myTeam and targetTeam then
            if myTeam.Name == "Pirates" and targetTeam.Name == "Marines" then return true
            elseif myTeam.Name == "Marines" and targetTeam.Name == "Pirates" then return true end
            if myTeam.Name == "Pirates" and targetTeam.Name == "Pirates" then return true end
            if myTeam.Name == "Marines" and targetTeam.Name == "Marines" then return false end
        end
        return true
    end
    
    local function updateESP()
        clearDrawings()
        if not ESPEnabled then return end
        local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local vp = camera.ViewportSize
        for _, plr in pairs(Players:GetPlayers()) do
            if plr == lp or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
            if not isEnemy(plr) then continue end
            local hrp = plr.Character.HumanoidRootPart
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            local size = Vector2.new(2000/(camera.CFrame.Position-hrp.Position).Magnitude, 4000/(camera.CFrame.Position-hrp.Position).Magnitude)
            local boxCol = getColor(BoxColor)
            local txtCol = getColor(TextColor)
            local lineCol = getColor(LineColor)
            
            if ShowBox and onScreen then
                local tl = Vector2.new(pos.X-size.X/2, pos.Y-size.Y/2)
                local tr = Vector2.new(pos.X+size.X/2, pos.Y-size.Y/2)
                local bl = Vector2.new(pos.X-size.X/2, pos.Y+size.Y/2)
                local br = Vector2.new(pos.X+size.X/2, pos.Y+size.Y/2)
                local function addLine(p1,p2)
                    local l = Drawing.new("Line"); l.Visible=true; l.Color=boxCol; l.Thickness=1; l.From=p1; l.To=p2
                    table.insert(drawings,l)
                end
                addLine(tl,tr); addLine(tr,br); addLine(br,bl); addLine(bl,tl)
            end
            
            if ShowName and onScreen then
                local t = Drawing.new("Text"); t.Visible=true; t.Text=plr.Name; t.Color=txtCol; t.Size=13; t.Center=true
                t.Position=Vector2.new(pos.X, pos.Y-size.Y/2-15); t.Font=2
                table.insert(drawings,t)
            end
            
            if ShowDistance and onScreen then
                local dist = math.floor((hrp.Position-(myHrp and myHrp.Position or Vector3.zero)).Magnitude)
                local t = Drawing.new("Text"); t.Visible=true; t.Text=dist.."m"; t.Color=txtCol; t.Size=13; t.Center=true
                t.Position=Vector2.new(pos.X, pos.Y+size.Y/2+2); t.Font=2
                table.insert(drawings,t)
            end
            
            if ShowHealth and onScreen then
                local hpRatio = math.clamp(hum.Health/hum.MaxHealth,0,1)
                local barW, barH = size.X, 4
                local barPos = Vector2.new(pos.X-barW/2, pos.Y+size.Y/2+12)
                local bg = Drawing.new("Square"); bg.Visible=true; bg.Color=Color3.new(0,0,0); bg.Filled=true
                bg.Size=Vector2.new(barW,barH); bg.Position=barPos
                table.insert(drawings,bg)
                local fg = Drawing.new("Square"); fg.Visible=true; fg.Color=Color3.new(1-hpRatio, hpRatio, 0); fg.Filled=true
                fg.Size=Vector2.new(barW*hpRatio,barH); fg.Position=barPos
                table.insert(drawings,fg)
            end
            
            if ShowLine then
                local lineStart = nil
                if LineOrigin == "Player" then
                    if myHrp then
                        local myPos, onScr = camera:WorldToViewportPoint(myHrp.Position)
                        if onScr then lineStart = Vector2.new(myPos.X, myPos.Y) else lineStart = Vector2.new(vp.X/2, vp.Y/2) end
                    else lineStart = Vector2.new(vp.X/2, vp.Y/2) end
                elseif LineOrigin == "Center" then lineStart = Vector2.new(vp.X/2, vp.Y/2)
                elseif LineOrigin == "Top" then lineStart = Vector2.new(vp.X/2, 0) end
                if lineStart then
                    local l = Drawing.new("Line"); l.Visible=true; l.Color=lineCol; l.Thickness=1
                    l.From=lineStart; l.To=Vector2.new(pos.X, pos.Y)
                    table.insert(drawings,l)
                end
            end
        end
    end
    
    local espConnection
    function module:SetESPEnabled(state)
        ESPEnabled=state
        if state then
            if espConnection then espConnection:Disconnect() end
            espConnection=RunService.RenderStepped:Connect(updateESP)
        else
            if espConnection then espConnection:Disconnect(); espConnection=nil end
            clearDrawings()
        end
    end
    function module:SetShowBox(v) ShowBox=v end
    function module:SetShowName(v) ShowName=v end
    function module:SetShowDistance(v) ShowDistance=v end
    function module:SetShowHealth(v) ShowHealth=v end
    function module:SetShowLine(v) ShowLine=v end
    function module:SetBoxColor(c) BoxColor=c end
    function module:SetTextColor(c) TextColor=c end
    function module:SetLineColor(c) LineColor=c end
    function module:SetShowAllPlayers(v) ShowAllPlayers=v end
    function module:SetLineOrigin(v) LineOrigin=v end
    return module
end)()

-- ============================================================
-- SILENT AIM MODULE
-- ============================================================
local SilentAimModule = (function()
    local module = {}
    local SilentAimPlayersEnabled = false
    local SilentAimNPCsEnabled = false
    local PredictionEnabled = true
    local PredictionAmount = 0.12
    local ShowFOVCircle = false
    local FOVRadius = 100
    local FOVMode = "V1"
    local AimMode = "360"
    local TargetPriority = "Nearest"
    local SoruAutoAimEnabled = false
    local SoruAutoAimRange = 300
    local SoruTargetingMode = "360"
    local SoruFOVType = "V1"
    local SoruFOVRadius = 100
    local SoruTargetPriority = "Nearest"
    local SoruShowFOVCircle = false
    local SoruPredictedPosition = nil
    local currentTool, currentToolCategory = nil, "Melee"
    local PlayersPosition, NPCPosition = nil, nil
    local Selectedplayer = nil
    local characterConnections = {}
    local maxRange = 1000
    local BlacklistedKeys = {
        Melee = { Z=false, X=false, C=false },
        Sword = { Z=false, X=false },
        Fruit = { Z=false, X=false, C=false, V=false, F=false, TAP=false },
        Gun   = { Z=false, X=false }
    }
    local currentSkillKey = nil
    local SKILL_KEYS = {"Z","X","C","V","F","TAP"}
    local lastSkillTime = 0

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name="Tommy_FOV"
    ScreenGui.ResetOnSpawn=false
    ScreenGui.IgnoreGuiInset=true
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent=game:GetService("CoreGui")
    elseif gethui then ScreenGui.Parent=gethui()
    else ScreenGui.Parent=game:GetService("CoreGui") end
    
    local FOVFrame = Instance.new("Frame")
    FOVFrame.AnchorPoint=Vector2.new(0.5,0.5)
    FOVFrame.BackgroundTransparency=1
    FOVFrame.Visible=false
    FOVFrame.Parent=ScreenGui
    local FOVStroke = Instance.new("UIStroke")
    FOVStroke.Color=CONFIG.Accent
    FOVStroke.Thickness=2
    FOVStroke.Parent=FOVFrame
    Instance.new("UICorner", FOVFrame).CornerRadius=UDim.new(1,0)
    
    local SoruFOVFrame = Instance.new("Frame")
    SoruFOVFrame.AnchorPoint=Vector2.new(0.5,0.5)
    SoruFOVFrame.BackgroundTransparency=1
    SoruFOVFrame.Visible=false
    SoruFOVFrame.Parent=ScreenGui
    local SoruStroke = Instance.new("UIStroke")
    SoruStroke.Color=Color3.fromRGB(0,255,0)
    SoruStroke.Thickness=2
    SoruStroke.Parent=SoruFOVFrame
    Instance.new("UICorner", SoruFOVFrame).CornerRadius=UDim.new(1,0)

    local PingService = game:GetService("Stats").Network.ServerStatsItem

    local function getToolCategory(tool)
        if not tool then return "Melee" end
        local name = string.lower(tool.Name)
        local gunNames = {"guitar","rifle","cannon","gun","slingshot","kabucha","serpent bow","bow"}
        for _,g in ipairs(gunNames) do if string.find(name,g) then return "Gun" end end
        local meleeNames = {"claw","godhuman","superhuman","talon","step","karate","breath","kung fu","combat","fist","sanguine"}
        for _,m in ipairs(meleeNames) do if string.find(name,m) then return "Melee" end end
        if string.find(name,"fruit") or string.find(name,"-") then return "Fruit" end
        return "Sword"
    end

    local function isKeyCurrentlyBlacklisted(key)
        if not key then return false end
        local cat = currentToolCategory
        if BlacklistedKeys[cat] and BlacklistedKeys[cat][key] ~= nil then return BlacklistedKeys[cat][key] end
        return false
    end
    
    local function getHRP(model)
        if model and model:FindFirstChild("HumanoidRootPart") then return model.HumanoidRootPart end
        return nil
    end
    
    local function clearConnections()
        for _,c in ipairs(characterConnections) do pcall(function() c:Disconnect() end) end
        characterConnections = {}
    end

    local lastDirection = nil
    local function predicted(hrp)
        if not hrp then return nil end
        local hum = hrp.Parent:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return hrp.Position end
        if not PredictionEnabled then return hrp.Position end
        local vel = hrp.Velocity
        local speed = vel.Magnitude
        if speed < 5 then lastDirection = nil; return hrp.Position end
        local currentDirection = vel.Unit
        if lastDirection then
            local dot = lastDirection:Dot(currentDirection)
            if dot < 0.7 then lastDirection = nil; return hrp.Position end
        end
        lastDirection = currentDirection
        local ping = 0
        pcall(function() if PingService then ping = PingService:GetValue() / 1000 end end)
        ping = math.clamp(ping, 0, 0.35)
        local predictionFactor = PredictionAmount + ping
        if speed > 100 then predictionFactor = math.min(predictionFactor, 0.15) end
        return hrp.Position + (vel * predictionFactor)
    end

    local function isAllyWithMe(targetplayer)
        local myGui = lp:FindFirstChild("PlayerGui")
        if not myGui then return false end
        local scrolling = myGui:FindFirstChild("Main") and myGui.Main:FindFirstChild("Allies")
            and myGui.Main.Allies:FindFirstChild("Container")
            and myGui.Main.Allies.Container:FindFirstChild("Allies")
            and myGui.Main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
        if scrolling then
            for _,frame in pairs(scrolling:GetDescendants()) do
                if frame:IsA("ImageButton") and frame.Name==targetplayer.Name then return true end
            end
        end
        return false
    end
    
    local function isTargetProtected(targetPlayer)
        if not targetPlayer then return false end
        local char = targetPlayer.Character
        if not char then return false end
        if char:GetAttribute("SafeZone")==true or char:GetAttribute("PvpDisabled")==true then return true end
        if char:FindFirstChildWhichIsA("ForceField") then return true end
        return false
    end
    
    local function isEnemy(targetplayer)
        if not targetplayer or targetplayer==lp then return false end
        if isTargetProtected(targetplayer) then return false end
        local myTeam = lp.Team; local targetTeam = targetplayer.Team
        if myTeam and targetTeam then
            if myTeam.Name=="Pirates" and targetTeam.Name=="Marines" then return true
            elseif myTeam.Name=="Marines" and targetTeam.Name=="Pirates" then return true end
            if myTeam.Name=="Pirates" and targetTeam.Name=="Pirates" then return not isAllyWithMe(targetplayer) end
            if myTeam.Name=="Marines" and targetTeam.Name=="Marines" then return false end
        end
        return true
    end

    local function getFOVCenter(mode)
        if mode=="V2" then return UserInputService:GetMouseLocation() end
        return camera.ViewportSize/2
    end
    
    local function isTargetValid(hrp, lpHRP, aimMode, fovRadius, fovType)
        if not hrp or not lpHRP then return false end
        if aimMode=="180" then
            local dir=(hrp.Position-lpHRP.Position).Unit
            if lpHRP.CFrame.LookVector:Dot(dir)<0 then return false end
        elseif aimMode=="FOV" then
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if not onScreen then return false end
            local center = getFOVCenter(fovType)
            if (Vector2.new(screenPos.X, screenPos.Y)-center).Magnitude > fovRadius then return false end
        end
        return true
    end

    local function getClosestplayer(lpHRP)
        if not lpHRP then return nil end
        if TargetPriority=="Lock Player" then
            if Selectedplayer and Selectedplayer.Character and Selectedplayer.Character.Parent then
                if isTargetProtected(Selectedplayer) then return nil end
                local hum = Selectedplayer.Character:FindFirstChildWhichIsA("Humanoid")
                local hrp = getHRP(Selectedplayer.Character)
                if hum and hum.Health>0 and hrp then
                    if isTargetValid(hrp, lpHRP, AimMode, FOVRadius, FOVMode) and (hrp.Position-lpHRP.Position).Magnitude <= maxRange then
                        return Selectedplayer
                    end
                end
            end
            return nil
        end
        local valid = {}
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=lp and isEnemy(pl) and pl.Character and pl.Character.Parent then
                local hum = pl.Character:FindFirstChildWhichIsA("Humanoid")
                local hrp = getHRP(pl.Character)
                if hum and hum.Health>0 and hrp and isTargetValid(hrp, lpHRP, AimMode, FOVRadius, FOVMode) then
                    local dist = (hrp.Position-lpHRP.Position).Magnitude
                    if dist <= maxRange then table.insert(valid, {Player=pl, Humanoid=hum, HRP=hrp, Distance=dist}) end
                end
            end
        end
        if #valid==0 then return nil end
        if TargetPriority=="Nearest" then table.sort(valid, function(a,b) return a.Distance<b.Distance end)
        elseif TargetPriority=="Low HP" then table.sort(valid, function(a,b) return a.Humanoid.Health<b.Humanoid.Health end)
        elseif TargetPriority=="Looking At Me" then
            table.sort(valid, function(a,b)
                local dirA=(lpHRP.Position-a.HRP.Position).Unit; local lookA=a.HRP.CFrame.LookVector
                local dirB=(lpHRP.Position-b.HRP.Position).Unit; local lookB=b.HRP.CFrame.LookVector
                return lookA:Dot(dirA)>lookB:Dot(dirB)
            end)
        end
        return valid[1].Player
    end

    local function getSoruTarget(lpHRP)
        if not lpHRP then return nil end
        local valid = {}
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=lp and pl.Character and isEnemy(pl) then
                local hum = pl.Character:FindFirstChildWhichIsA("Humanoid")
                local hrp = getHRP(pl.Character)
                if hum and hum.Health>0 and hrp then
                    if isTargetValid(hrp, lpHRP, SoruTargetingMode, SoruFOVRadius, SoruFOVType) then
                        local dist = (hrp.Position-lpHRP.Position).Magnitude
                        if dist <= SoruAutoAimRange then table.insert(valid, {HRP=hrp, Humanoid=hum, Distance=dist}) end
                    end
                end
            end
        end
        if #valid==0 then return nil end
        table.sort(valid, function(a,b) return a.Distance<b.Distance end)
        return valid[1].HRP
    end

    task.spawn(function()
        while true do
            task.wait(0.2)
            if SoruAutoAimEnabled then
                local myHRP = getHRP(lp.Character)
                local targetHRP = myHRP and getSoruTarget(myHRP)
                SoruPredictedPosition = targetHRP and targetHRP.Position or nil
            else
                SoruPredictedPosition = nil
            end
        end
    end)

    local function installMouseOverride()
        local MouseModuleInstance = RS:FindFirstChild("Mouse")
        if not MouseModuleInstance then return end
        local MouseModule = nil
        pcall(function() MouseModule = require(MouseModuleInstance) end)
        if not MouseModule or typeof(MouseModule) ~= "table" then return end
        local realStore = { Hit = rawget(MouseModule, "Hit"), Target = rawget(MouseModule, "Target") }
        local mmt = getrawmetatable(MouseModule)
        if mmt then setreadonly(mmt, false) else mmt = {}; setmetatable(MouseModule, mmt) end
        rawset(MouseModule, "Hit", nil); rawset(MouseModule, "Target", nil)
        mmt.__index = function(self, key)
            if key == "Hit" and (SilentAimPlayersEnabled or SilentAimNPCsEnabled) and (PlayersPosition or NPCPosition) and currentSkillKey == "Z" then
                local pos = PlayersPosition or NPCPosition
                if pos then return CFrame.new(pos) end
            end
            if key == "Target" and (SilentAimPlayersEnabled or SilentAimNPCsEnabled) and (PlayersPosition or NPCPosition) and currentSkillKey == "Z" then
                return nil
            end
            return realStore[key] or rawget(self, key)
        end
        mmt.__newindex = function(self, key, value)
            if key == "Hit" or key == "Target" then realStore[key] = value else rawset(self, key, value) end
        end
        setreadonly(mmt, true)
    end
    installMouseOverride()

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local keyMap = { [Enum.KeyCode.Z]="Z", [Enum.KeyCode.X]="X", [Enum.KeyCode.C]="C", [Enum.KeyCode.V]="V", [Enum.KeyCode.F]="F" }
        local key = keyMap[input.KeyCode]
        if key then currentSkillKey = key end
    end)

    local Mouse = lp:GetMouse()
    
    local renderConnection = RunService.RenderStepped:Connect(function()
        if ShowFOVCircle then
            local center = getFOVCenter(FOVMode)
            FOVFrame.Position=UDim2.new(0,center.X,0,center.Y)
            FOVFrame.Size=UDim2.new(0,FOVRadius*2,0,FOVRadius*2)
            FOVFrame.Visible=true
        else FOVFrame.Visible=false end
        
        if SoruShowFOVCircle then
            local center = getFOVCenter(SoruFOVType)
            SoruFOVFrame.Position=UDim2.new(0,center.X,0,center.Y)
            SoruFOVFrame.Size=UDim2.new(0,SoruFOVRadius*2,0,SoruFOVRadius*2)
            SoruFOVFrame.Visible=true
        else SoruFOVFrame.Visible=false end
        
        pcall(function()
            local lpChar = lp.Character; if not lpChar then return end
            local lpHRP = lpChar:FindFirstChild("HumanoidRootPart"); if not lpHRP then return end
            if not SilentAimPlayersEnabled and not SilentAimNPCsEnabled then
                PlayersPosition = nil; NPCPosition = nil
                return
            end
            if SilentAimPlayersEnabled then
                local targetplayer = getClosestplayer(lpHRP)
                if targetplayer and targetplayer.Character then
                    PlayersPosition = predicted(getHRP(targetplayer.Character))
                else PlayersPosition=nil end
            end
            if SilentAimNPCsEnabled then
                local enemiesFolder = workspace:FindFirstChild("Enemies")
                if enemiesFolder then
                    local closest, closestDist = nil, math.huge
                    for _,npc in ipairs(enemiesFolder:GetChildren()) do
                        if npc:IsA("Model") then
                            local hum = npc:FindFirstChildWhichIsA("Humanoid")
                            local hrp = getHRP(npc)
                            if hum and hum.Health>0 and hrp then
                                local dist = (hrp.Position-lpHRP.Position).Magnitude
                                if dist<=maxRange and dist<closestDist then closestDist=dist; closest=npc end
                            end
                        end
                    end
                    if closest then NPCPosition = predicted(getHRP(closest)) else NPCPosition=nil end
                end
            end
        end)
    end)

    local function onCharacterAdded(char)
        clearConnections()
        for _,child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                currentTool=child; currentToolCategory=getToolCategory(child); currentSkillKey=nil
            end
        end
        table.insert(characterConnections, char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                currentTool=child; currentToolCategory=getToolCategory(child); currentSkillKey=nil
            end
        end))
        table.insert(characterConnections, char.ChildRemoved:Connect(function(child)
            if child==currentTool then currentTool=nil end
        end))
    end
    lp.CharacterAdded:Connect(onCharacterAdded)
    if lp.Character then onCharacterAdded(lp.Character) end

    function module:SetPlayerSilentAim(state) SilentAimPlayersEnabled=state end
    function module:SetNPCSilentAim(state) SilentAimNPCsEnabled=state end
    function module:SetBlacklistKey(cat,key,state)
        if BlacklistedKeys[cat] and BlacklistedKeys[cat][key]~=nil then BlacklistedKeys[cat][key]=state end
    end
    function module:SetAimMode(mode) AimMode=mode end
    function module:SetTargetPriority(prio) TargetPriority=prio end
    function module:SetShowFOVCircle(state) ShowFOVCircle=state end
    function module:SetFOVRadius(num) FOVRadius=num end
    function module:SetFOVMode(mode) FOVMode=mode end
    function module:SetDistanceLimit(num) if type(num)=="number" then maxRange=num end end
    function module:SetSelectedPlayer(playerName)
        if not playerName or playerName=="" then Selectedplayer=nil return end
        Selectedplayer=Players:FindFirstChild(playerName)
    end
    function module:SetSoruAutoAim(state) SoruAutoAimEnabled=state end
    function module:SetSoruRange(r) SoruAutoAimRange=r end
    function module:SetSoruAimMode(mode) SoruTargetingMode=mode end
    function module:SetSoruFOVType(mode) SoruFOVType=mode end
    function module:SetSoruFOVRadius(r) SoruFOVRadius=r end
    function module:SetSoruPriority(p) SoruTargetPriority=p end
    function module:SetSoruShowFOVCircle(state) SoruShowFOVCircle=state end
    return module
end)()

-- ============================================================
-- UI PRINCIPAL - Tommy Style
-- ============================================================
local function buildHub()
    local gui = new("ScreenGui", {Name = "TommyScript_Hub", ResetOnSpawn = false}, parentGui)
    local main = new("Frame", {
        Size = UDim2.new(0, 700, 0, 500),
        Position = UDim2.new(0.5, -350, 0.5, -250),
        BackgroundColor3 = CONFIG.BG, BorderSizePixel = 0, Active = true,
    }, gui)
    corner(16, main); stroke(CONFIG.Accent, 1.2, main)

    local topBar = new("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = CONFIG.Card, BorderSizePixel = 0}, main)
    corner(16, topBar)
    new("Frame", {Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 1, -16), BackgroundColor3 = CONFIG.Card, BorderSizePixel = 0}, topBar)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1, Text = "👑  TOMMY SCRIPT",
        TextColor3 = CONFIG.Accent, Font = Enum.Font.GothamBlack, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, topBar)
    
    local closeBtn = new("TextButton", {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -36, 0.5, -15),
        BackgroundColor3 = CONFIG.Danger, BorderSizePixel = 0, Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 14,
    }, topBar)
    corner(8, closeBtn)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    
    local minBtn = new("TextButton", {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -70, 0.5, -15),
        BackgroundColor3 = CONFIG.CardHover, BorderSizePixel = 0, Text = "—",
        TextColor3 = CONFIG.Text, Font = Enum.Font.GothamBold, TextSize = 14,
    }, topBar)
    corner(8, minBtn)

    local sidebar = new("Frame", {
        Size = UDim2.new(0, 165, 1, -44), Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = CONFIG.BG, BorderSizePixel = 0,
    }, main)
    local content = new("Frame", {
        Size = UDim2.new(1, -165, 1, -44), Position = UDim2.new(0, 165, 0, 44),
        BackgroundColor3 = CONFIG.BG, BorderSizePixel = 0,
    }, main)

    local pages = {}
    local function createPage(name)
        local p = new("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, content)
        new("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)}, p)
        new("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, p)
        pages[name] = p
        return p
    end

    local function createCard(page, title, height)
        local card = new("Frame", {
            Size = UDim2.new(1, 0, 0, height or 60),
            BackgroundColor3 = CONFIG.Card, BorderSizePixel = 0,
        }, page)
        corner(10, card); stroke(CONFIG.CardHover, 1, card)
        if title then
            new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1, Text = title, TextColor3 = CONFIG.Accent,
                Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
            }, card)
        end
        return card
    end

    local function createToggle(parent, yPos, label, default, callback)
        local row = new("Frame", {Size = UDim2.new(1, -24, 0, 26), Position = UDim2.new(0, 12, 0, yPos), BackgroundTransparency = 1}, parent)
        new("TextLabel", {
            Size = UDim2.new(0.75, 0, 1, 0), BackgroundTransparency = 1, Text = label,
            TextColor3 = CONFIG.Text, Font = Enum.Font.GothamMedium, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local state = default or false
        local btn = new("TextButton", {
            Size = UDim2.new(0, 54, 0, 22), Position = UDim2.new(1, -54, 0.5, -11),
            BackgroundColor3 = state and CONFIG.Accent or CONFIG.CardHover,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        }, row)
        corner(11, btn)
        local knob = new("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
        }, btn)
        corner(8, knob)
        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and CONFIG.Accent or CONFIG.CardHover}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)}):Play()
            if callback then callback(state) end
        end)
    end

    local function createSlider(parent, yPos, label, min, max, default, callback)
        local row = new("Frame", {Size = UDim2.new(1, -24, 0, 40), Position = UDim2.new(0, 12, 0, yPos), BackgroundTransparency = 1}, parent)
        local labelRef = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Text = label .. ": " .. default, TextColor3 = CONFIG.Text,
            Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local bar = new("Frame", {
            Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 26),
            BackgroundColor3 = CONFIG.CardHover, BorderSizePixel = 0,
        }, row)
        corner(3, bar)
        local fill = new("Frame", {
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = CONFIG.Accent, BorderSizePixel = 0,
        }, bar)
        corner(3, fill)
        local dragging = false
        local function update(input)
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * rel
            if max - min <= 10 then val = math.floor(val * 100 + 0.5) / 100 else val = math.floor(val) end
            fill.Size = UDim2.new(rel, 0, 1, 0)
            labelRef.Text = label .. ": " .. val
            if callback then callback(val) end
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; update(i) end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
    end

    local function createDropdown(parent, yPos, label, options, default, callback)
        local row = new("Frame", {Size = UDim2.new(1, -24, 0, 30), Position = UDim2.new(0, 12, 0, yPos), BackgroundTransparency = 1}, parent)
        new("TextLabel", {
            Size = UDim2.new(0.4, 0, 1, 0), BackgroundTransparency = 1, Text = label,
            TextColor3 = CONFIG.Text, Font = Enum.Font.GothamMedium, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local idx = 1
        for i, v in ipairs(options) do if v == default then idx = i; break end end
        local btn = new("TextButton", {
            Size = UDim2.new(0.58, 0, 1, 0), Position = UDim2.new(0.42, 0, 0, 0),
            BackgroundColor3 = CONFIG.CardHover, BorderSizePixel = 0,
            Text = options[idx], TextColor3 = CONFIG.Text,
            Font = Enum.Font.GothamBold, TextSize = 11,
        }, row)
        corner(6, btn)
        btn.MouseButton1Click:Connect(function()
            idx = idx + 1
            if idx > #options then idx = 1 end
            btn.Text = options[idx]
            if callback then callback(options[idx]) end
        end)
    end

    local function createButton(parent, yPos, label, callback)
        local btn = new("TextButton", {
            Size = UDim2.new(1, -24, 0, 30), Position = UDim2.new(0, 12, 0, yPos),
            BackgroundColor3 = CONFIG.CardHover, BorderSizePixel = 0, Text = label,
            TextColor3 = CONFIG.Text, Font = Enum.Font.GothamBold, TextSize = 11,
        }, parent)
        corner(8, btn)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Accent}):Play()
            btn.TextColor3 = Color3.fromRGB(20, 15, 0)
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.CardHover}):Play()
            btn.TextColor3 = CONFIG.Text
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local tabs = {
        {name = "Silent Aim", icon = "🎯"},
        {name = "Glitch",     icon = "🌀"},
        {name = "Movement",   icon = "🏃"},
        {name = "Apparence",  icon = "👤"},
        {name = "Visuals",    icon = "👁️"},
        {name = "Soru",       icon = "⚡"},
        {name = "Misc",       icon = "🛠️"},
        {name = "SA Blacklist", icon = "🚫"},
    }
    local tabButtons = {}
    local function selectTab(name)
        for _, p in pairs(pages) do p.Visible = false end
        pages[name].Visible = true
        for n, b in pairs(tabButtons) do
            TweenService:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = (n == name) and CONFIG.CardHover or CONFIG.BG,
            }):Play()
        end
    end

    for i, t in ipairs(tabs) do
        local btn = new("TextButton", {
            Size = UDim2.new(1, -16, 0, 38), Position = UDim2.new(0, 8, 0, 12 + (i - 1) * 44),
            BackgroundColor3 = CONFIG.BG, BorderSizePixel = 0,
            Text = "  " .. t.icon .. "   " .. t.name,
            TextColor3 = CONFIG.Text, Font = Enum.Font.GothamBold, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, sidebar)
        corner(8, btn)
        tabButtons[t.name] = btn
        btn.MouseButton1Click:Connect(function() selectTab(t.name) end)
        createPage(t.name)
    end

    -- SILENT AIM
    local silentPage = pages["Silent Aim"]
    local sc1 = createCard(silentPage, "SILENT AIM", 130)
    createToggle(sc1, 34, "Player Silent Aim", false, function(v) SilentAimModule:SetPlayerSilentAim(v) end)
    createToggle(sc1, 62, "NPC Silent Aim", false, function(v) SilentAimModule:SetNPCSilentAim(v) end)
    createToggle(sc1, 90, "Show FOV Circle", false, function(v) SilentAimModule:SetShowFOVCircle(v) end)

    local sc2 = createCard(silentPage, "TARGET", 130)
    createDropdown(sc2, 34, "Aim Mode", {"360", "180", "FOV"}, "360", function(v) SilentAimModule:SetAimMode(v) end)
    createDropdown(sc2, 66, "Priority", {"Nearest", "Low HP", "Looking At Me", "Lock Player"}, "Nearest", function(v) SilentAimModule:SetTargetPriority(v) end)
    createSlider(sc2, 98, "Max Range", 100, 3000, 1000, function(v) SilentAimModule:SetDistanceLimit(v) end)

    local sc3 = createCard(silentPage, "FOV SETTINGS", 90)
    createDropdown(sc3, 34, "FOV Mode", {"V1", "V2"}, "V1", function(v) SilentAimModule:SetFOVMode(v) end)
    createSlider(sc3, 62, "FOV Radius", 10, 800, 100, function(v) SilentAimModule:SetFOVRadius(v) end)

    -- GLITCH
    local glitchPage = pages["Glitch"]
    local gc1 = createCard(glitchPage, "SANGUINE Z BOOST", 130)
    createToggle(gc1, 34, "Enabled", false, function(v) multiEnabled = v end)
    createSlider(gc1, 62, "Power", 100, 5000, 400, function(v) multiPower = v end)
    createSlider(gc1, 90, "Charge (x0.1s)", 1, 50, 10, function(v) multiRequiredCharge = v / 10 end)

    local gc2 = createCard(glitchPage, "DIAMOND BOOST", 130)
    createToggle(gc2, 34, "Enabled", false, function(v) diamondEnabled = v end)
    createSlider(gc2, 62, "Power", 100, 5000, 250, function(v) diamondPower = v end)
    createSlider(gc2, 90, "Charge (x0.1s)", 1, 50, 10, function(v) diamondRequiredCharge = v / 10 end)

    local gc3 = createCard(glitchPage, "DTALON Z BOOST", 130)
    createToggle(gc3, 34, "Enabled", false, function(v) dtalonEnabled = v end)
    createSlider(gc3, 62, "Power", 100, 5000, 400, function(v) dtalonPower = v end)
    createSlider(gc3, 90, "Charge (x0.1s)", 1, 50, 10, function(v) dtalonRequiredCharge = v / 10 end)

    local gc4 = createCard(glitchPage, "ECLAW X BOOST", 130)
    createToggle(gc4, 34, "Enabled", false, function(v) EClawBoost:Toggle(v) end)
    createSlider(gc4, 62, "Power", 100, 5000, 400, function(v) EClawBoost:SetPower(v) end)
    createSlider(gc4, 90, "Duration (cs)", 10, 200, 170, function(v) EClawBoost:SetDuration(v / 100) end)

    local gc5 = createCard(glitchPage, "SKULL GUITAR DASH", 190)
    createToggle(gc5, 34, "Enabled", false, function(v) dashEnabled = v end)
    createToggle(gc5, 62, "Auto Dash (V1)", false, function(v) dashV1Active = v end)
    createSlider(gc5, 90, "Cooldown", 0.2, 5, 1.5, function(v) dashCooldown = v end)
    createSlider(gc5, 118, "Dash Length", 10, 500, 190, function(v) dashLength = v end)
    createSlider(gc5, 146, "Speed Boost", 50, 1000, 350, function(v) speedBoost = v end)

    -- MOVEMENT
    local movePage = pages["Movement"]
    local mc1 = createCard(movePage, "SPEED HACK", 130)
    createToggle(mc1, 34, "Enabled", false, function(v) if v then StartSpeedHack() else StopSpeedHack() end end)
    createDropdown(mc1, 62, "Mode", {"WalkSpeed", "CFrame", "Velocity", "TP-Flash", "AnimSpeed"}, "WalkSpeed", function(v) speedSettings.mode = v end)
    createSlider(mc1, 94, "Speed", 16, 500, 50, function(v) speedSettings.speedValue = v end)

    local mc2 = createCard(movePage, "SUPER JUMP", 90)
    createToggle(mc2, 34, "Enabled", false, function(v) superJumpEnabled = v end)
    createSlider(mc2, 62, "Power", 50, 500, 150, function(v) superJumpPower = v end)

    local mc3 = createCard(movePage, "FLY", 130)
    createToggle(mc3, 34, "Enabled", false, function(v) if v then StartFly() else StopFly() end end)
    createDropdown(mc3, 62, "Mode", {"CFrame", "Velocity"}, "CFrame", function(v) flySettings.mode = v end)
    createSlider(mc3, 94, "Speed", 10, 500, 50, function(v) flySettings.speed = v end)

    local mc4 = createCard(movePage, "NOCLIP", 60)
    createToggle(mc4, 34, "Enabled", false, function(v) if v then StartNoClip() else StopNoClip() end end)

    local mc5 = createCard(movePage, "DASH LENGTH", 90)
    createToggle(mc5, 34, "Enabled", false, function(v)
        dashLengthEnabled = v
        if v then
            task.spawn(function()
                while dashLengthEnabled do
                    task.wait(0.1)
                    if lp.Character then
                        lp.Character:SetAttribute("DashLength", dashLengthValue)
                        lp.Character:SetAttribute("DashLengthAir", dashLengthValue)
                    end
                end
            end)
        end
    end)
    createSlider(mc5, 62, "Distance", 1, 300, 1, function(v) dashLengthValue = v end)

    local mc6 = createCard(movePage, "BUNNY HOP", 60)
    createToggle(mc6, 34, "Enabled", false, function(v) bunnyHopEnabled = v end)

    -- APARENCE
    local appPage = pages["Apparence"]
    local ac1 = createCard(appPage, "FAKE HEADLESS", 60)
    createToggle(ac1, 34, "Enabled", false, function(v)
        fakeHeadlessEnabled = v
        if v then applyFakeHeadless() else removeFakeHeadless() end
    end)

    local ac2 = createCard(appPage, "FAKE KORBLOX", 60)
    createToggle(ac2, 34, "Enabled", false, function(v)
        fakeKorbloxEnabled = v
        if v then applyFakeKorblox() else removeFakeKorblox() end
    end)

    -- VISUALS
    local visPage = pages["Visuals"]
    local vc1 = createCard(visPage, "ESP", 160)
    createToggle(vc1, 34, "Enabled", false, function(v) ESPModule:SetESPEnabled(v) end)
    createToggle(vc1, 62, "Show Box", true, function(v) ESPModule:SetShowBox(v) end)
    createToggle(vc1, 90, "Show Name", true, function(v) ESPModule:SetShowName(v) end)
    createToggle(vc1, 118, "Show Distance", true, function(v) ESPModule:SetShowDistance(v) end)

    local vc2 = createCard(visPage, "ESP EXTRA", 130)
    createToggle(vc2, 34, "Show Health Bar", true, function(v) ESPModule:SetShowHealth(v) end)
    createToggle(vc2, 62, "Show Tracer", true, function(v) ESPModule:SetShowLine(v) end)
    createToggle(vc2, 90, "Show All Players", false, function(v) ESPModule:SetShowAllPlayers(v) end)

    -- SORU
    local soruPage = pages["Soru"]
    local src1 = createCard(soruPage, "SORU AUTO AIM", 190)
    createToggle(src1, 34, "Enabled", false, function(v) SilentAimModule:SetSoruAutoAim(v) end)
    createSlider(src1, 62, "Range", 50, 1000, 300, function(v) SilentAimModule:SetSoruRange(v) end)
    createDropdown(src1, 94, "Aim Mode", {"360", "180", "FOV"}, "360", function(v) SilentAimModule:SetSoruAimMode(v) end)
    createSlider(src1, 126, "FOV Radius", 50, 800, 100, function(v) SilentAimModule:SetSoruFOVRadius(v) end)
    createToggle(src1, 158, "Show FOV", false, function(v) SilentAimModule:SetSoruShowFOVCircle(v) end)

    local src2 = createCard(soruPage, "AHK SCRIPTS", 130)
    createToggle(src2, 34, "AHK Soru", false, function(v)
        if v then LoadAHKsoru() else UnloadAHKsoru() end
    end)
    createToggle(src2, 62, "AHK Combo", false, function(v)
        if v then LoadAHKComboScript() else UnloadAHKComboScript() end
    end)

    -- MISC
    local miscPage = pages["Misc"]
    local mm1 = createCard(miscPage, "PROTECTION", 130)
    createToggle(mm1, 34, "Anti Void", true, function(v) workspace.FallenPartsDestroyHeight = v and -math.huge or -50 end)
    createToggle(mm1, 62, "Anti Lava", false, function(v) antiLavaActive = v end)
    createToggle(mm1, 90, "Infinite Zoom", false, function(v) player.CameraMaxZoomDistance = v and math.huge or 128 end)

    local mm2 = createCard(miscPage, "WORLD", 130)
    createToggle(mm2, 34, "Walk on Water", false, function(v) WalkOnWaterEnabled = v end)
    createToggle(mm2, 62, "Delete Ship", false, function(v) deleteShipActive = v end)
    createDropdown(mm2, 90, "No GFX Mode", {"Off", "V1", "V2"}, "Off", function(v) setNoGfxMode(v) end)

    -- SA BLACKLIST
    local blPage = pages["SA Blacklist"]
    local blc1 = createCard(blPage, "MELEE", 130)
    createToggle(blc1, 34, "Blacklist Z", false, function(v) SilentAimModule:SetBlacklistKey("Melee", "Z", v) end)
    createToggle(blc1, 62, "Blacklist X", false, function(v) SilentAimModule:SetBlacklistKey("Melee", "X", v) end)
    createToggle(blc1, 90, "Blacklist C", false, function(v) SilentAimModule:SetBlacklistKey("Melee", "C", v) end)

    local blc2 = createCard(blPage, "SWORD", 90)
    createToggle(blc2, 34, "Blacklist Z", false, function(v) SilentAimModule:SetBlacklistKey("Sword", "Z", v) end)
    createToggle(blc2, 62, "Blacklist X", false, function(v) SilentAimModule:SetBlacklistKey("Sword", "X", v) end)

    local blc3 = createCard(blPage, "FRUIT", 160)
    createToggle(blc3, 34, "Blacklist Z", false, function(v) SilentAimModule:SetBlacklistKey("Fruit", "Z", v) end)
    createToggle(blc3, 62, "Blacklist X", false, function(v) SilentAimModule:SetBlacklistKey("Fruit", "X", v) end)
    createToggle(blc3, 90, "Blacklist C", false, function(v) SilentAimModule:SetBlacklistKey("Fruit", "C", v) end)
    createToggle(blc3, 118, "Blacklist V", false, function(v) SilentAimModule:SetBlacklistKey("Fruit", "V", v) end)

    local blc4 = createCard(blPage, "GUN", 90)
    createToggle(blc4, 34, "Blacklist Z", false, function(v) SilentAimModule:SetBlacklistKey("Gun", "Z", v) end)
    createToggle(blc4, 62, "Blacklist X", false, function(v) SilentAimModule:SetBlacklistKey("Gun", "X", v) end)

    -- Drag
    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = main.Position
        end
    end)
    topBar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        TweenService:Create(main, TweenInfo.new(0.2), {
            Size = minimized and UDim2.new(0, 700, 0, 44) or UDim2.new(0, 700, 0, 500),
        }):Play()
        minBtn.Text = minimized and "▢" or "—"
    end)

    selectTab("Silent Aim")
end

buildHub()

print("✅ TOMMY SCRIPT - Interfaz custom cargada")
