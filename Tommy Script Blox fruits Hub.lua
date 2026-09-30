-- ============================================================
-- 👑 TOMMY SCRIPT - BLOX FRUITS PVP
-- Interfaz custom + Key System + Glitches + Visuals
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
-- KEY SYSTEM
-- ============================================================
local KEY_FILE = "tommy_key.json"
local KEY_DURATION = 86400 -- 24 horas
local VALID_KEYS = {
    ["TOMMY-VIP"]     = true,
    ["TOMMY-TEST"]    = true,
    ["TOMMY-FREE"]    = true,
    ["TOMMY-CUSTOM"]  = true,
    ["TOMMY-2026-PRO"]= true,
}

local function saveKey(key)
    pcall(function()
        writefile(KEY_FILE, HttpService:JSONEncode({key = key, savedAt = os.time()}))
    end)
end

local function loadSavedKey()
    if not isfile(KEY_FILE) then return nil end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(KEY_FILE))
    end)
    if ok and data and data.key and VALID_KEYS[data.key] then
        if os.time() - (data.savedAt or 0) < KEY_DURATION then
            return data.key
        end
    end
    return nil
end

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
-- KEY UI
-- ============================================================
local function showKeyScreen(onSuccess)
    local gui = new("ScreenGui", {Name = "Tommy_Key", ResetOnSpawn = false}, parentGui)
    local main = new("Frame", {
        Size = UDim2.new(0, 400, 0, 280),
        Position = UDim2.new(0.5, -200, 0.5, -140),
        BackgroundColor3 = CONFIG.BG, BorderSizePixel = 0, Active = true,
    }, gui)
    corner(18, main); stroke(CONFIG.Accent, 1.5, main)
    new("Frame", {Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = CONFIG.Accent, BorderSizePixel = 0}, main)

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1, Text = "👑 TOMMY SCRIPT",
        TextColor3 = CONFIG.Accent, Font = Enum.Font.GothamBlack, TextSize = 24,
    }, main)

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 65),
        BackgroundTransparency = 1, Text = "Ingresa tu Key para continuar",
        TextColor3 = CONFIG.TextDim, Font = Enum.Font.Gotham, TextSize = 11,
    }, main)

    local input = new("TextBox", {
        Size = UDim2.new(0.85, 0, 0, 42), Position = UDim2.new(0.075, 0, 0, 105),
        BackgroundColor3 = CONFIG.Card, BorderSizePixel = 0, PlaceholderText = "TOMMY-XXXX",
        Text = "", TextColor3 = CONFIG.Text, PlaceholderColor3 = CONFIG.TextDim,
        Font = Enum.Font.GothamBold, TextSize = 13, ClearTextOnFocus = false,
    }, main)
    corner(10, input); stroke(CONFIG.AccentDim, 1, input)

    local btn = new("TextButton", {
        Size = UDim2.new(0.85, 0, 0, 42), Position = UDim2.new(0.075, 0, 0, 165),
        BackgroundColor3 = CONFIG.Accent, BorderSizePixel = 0, Text = "VERIFICAR",
        TextColor3 = Color3.fromRGB(20, 15, 0), Font = Enum.Font.GothamBlack, TextSize = 13,
    }, main)
    corner(10, btn)

    local status = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 220),
        BackgroundTransparency = 1, Text = "", TextColor3 = CONFIG.Danger,
        Font = Enum.Font.Gotham, TextSize = 11,
    }, main)

    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = main.Position
        end
    end)
    main.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        local k = input.Text:gsub("%s", "")
        if VALID_KEYS[k] then
            saveKey(k)
            status.TextColor3 = CONFIG.Success
            status.Text = "✅ Acceso concedido"
            task.wait(0.7)
            gui:Destroy()
            onSuccess()
        else
            status.TextColor3 = CONFIG.Danger
            status.Text = "❌ Key inválida"
        end
    end)
end

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
-- SERVICES
-- ============================================================
local RS = ReplicatedStorage

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
                _G.TommyDamageDetected = (dmgText > 0)
            end)
            break
        end
        task.wait(1)
    end
end)

-- ============================================================
-- GLITCHES - BOOSTS ARREGLADOS
-- ============================================================
_G.TommyMultiEnabled = false
_G.TommyMultiPower = 400
_G.TommyMultiDuration = 0.9
_G.TommyMultiCharge = 1.0
_G.TommyMultiCharging = false
_G.TommyMultiChargeStart = 0

_G.TommyDiamondEnabled = false
_G.TommyDiamondPower = 250
_G.TommyDiamondDuration = 0.3
_G.TommyDiamondCharge = 1.0
_G.TommyDiamondCharging = false
_G.TommyDiamondChargeStart = 0

_G.TommyDTalonEnabled = false
_G.TommyDTalonPower = 400
_G.TommyDTalonDuration = 0.9
_G.TommyDTalonCharge = 1.0
_G.TommyDTalonCharging = false
_G.TommyDTalonChargeStart = 0

local function createLinearBoost(power, duration)
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local dir = camera.CFrame.LookVector

    hum.PlatformStand = true
    local att = Instance.new("Attachment", hrp)
    local lv = Instance.new("LinearVelocity", hrp)
    lv.MaxForce = 9999999
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity = dir * power
    lv.Attachment0 = att
    
    task.delay(duration, function()
        if lv then lv:Destroy() end
        if att then att:Destroy() end
        if hum then hum.PlatformStand = false end
    end)
end

-- Sanguine watcher
RunService.Heartbeat:Connect(function()
    if not _G.TommyMultiEnabled then return end
    local char = lp.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end
    local isCharging = false
    for _, a in pairs(hum:GetPlayingAnimationTracks()) do
        if a.Animation.AnimationId:find("14418367908") or a.Name == "GhoulZCharge" then
            isCharging = true; break
        end
    end
    if isCharging then
        if not _G.TommyMultiCharging then
            _G.TommyMultiCharging = true
            _G.TommyMultiChargeStart = tick()
        end
    else
        if _G.TommyMultiCharging then
            if (tick() - _G.TommyMultiChargeStart) >= _G.TommyMultiCharge then
                task.spawn(function()
                    createLinearBoost(_G.TommyMultiPower, _G.TommyMultiDuration)
                end)
            end
            _G.TommyMultiCharging = false
            _G.TommyMultiChargeStart = 0
        end
    end
end)

-- Diamond watcher
RunService.Heartbeat:Connect(function()
    if not _G.TommyDiamondEnabled then return end
    local char = lp.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end
    local isCharging = false
    for _, a in pairs(hum:GetPlayingAnimationTracks()) do
        if a.Animation.AnimationId:find("14414815375") then
            isCharging = true; break
        end
    end
    if isCharging then
        if not _G.TommyDiamondCharging then
            _G.TommyDiamondCharging = true
            _G.TommyDiamondChargeStart = tick()
        end
    else
        if _G.TommyDiamondCharging then
            if (tick() - _G.TommyDiamondChargeStart) >= _G.TommyDiamondCharge then
                task.spawn(function()
                    createLinearBoost(_G.TommyDiamondPower, _G.TommyDiamondDuration)
                end)
            end
            _G.TommyDiamondCharging = false
            _G.TommyDiamondChargeStart = 0
        end
    end
end)

-- DTalon watcher
RunService.Heartbeat:Connect(function()
    if not _G.TommyDTalonEnabled then return end
    local char = lp.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end
    local isCharging = false
    for _, a in pairs(hum:GetPlayingAnimationTracks()) do
        if a.Animation.AnimationId:find("18839089313") or a.Name == "DTalon_ZCharge" then
            isCharging = true; break
        end
    end
    if isCharging then
        if not _G.TommyDTalonCharging then
            _G.TommyDTalonCharging = true
            _G.TommyDTalonChargeStart = tick()
        end
    else
        if _G.TommyDTalonCharging then
            if (tick() - _G.TommyDTalonChargeStart) >= _G.TommyDTalonCharge then
                task.spawn(function()
                    createLinearBoost(_G.TommyDTalonPower, _G.TommyDTalonDuration)
                end)
            end
            _G.TommyDTalonCharging = false
            _G.TommyDTalonChargeStart = 0
        end
    end
end)

-- ============================================================
-- FAKE HEADLESS / KORBLOX
-- ============================================================
_G.TommyFakeHeadless = false
_G.TommyFakeKorblox = false
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
    task.wait(0.5)
    if _G.TommyFakeHeadless then applyFakeHeadless() end
    if _G.TommyFakeKorblox then applyFakeKorblox() end
end)

-- ============================================================
-- MOVEMENT
-- ============================================================
_G.TommyBunnyHop = false
_G.TommySuperJump = false
_G.TommySuperJumpPower = 150
_G.TommyDashLengthEnabled = false
_G.TommyDashLengthValue = 1
_G.TommySpeedHack = false
_G.TommySpeedMode = "WalkSpeed"
_G.TommySpeedValue = 50
_G.TommyFly = false
_G.TommyFlyMode = "CFrame"
_G.TommyFlySpeed = 50
_G.TommyNoclip = false

local flyConn, noclipConn

local function StartFly()
    if flyConn then flyConn:Disconnect() end
    _G.TommyFly = true
    flyConn = RunService.Stepped:Connect(function()
        if not _G.TommyFly then return end
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local moveDir = hum.MoveDirection
        local camCF = camera.CFrame
        local direction = Vector3.new(0, 0, 0)
        if moveDir.Magnitude > 0 then
            local relativeMove = camCF:VectorToObjectSpace(moveDir)
            direction = ((camCF.RightVector * relativeMove.X) + (camCF.LookVector * -relativeMove.Z)).Unit
        end
        if _G.TommyFlyMode == "CFrame" then
            hum.PlatformStand = true
            hrp.CFrame = hrp.CFrame + (direction * (_G.TommyFlySpeed / 10))
            hrp.Velocity = Vector3.zero
        elseif _G.TommyFlyMode == "Velocity" then
            hrp.Velocity = (direction * _G.TommyFlySpeed) + Vector3.new(0, 2, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, _G.TommyFlySpeed / 15, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, -_G.TommyFlySpeed / 15, 0)
        end
    end)
end

local function StopFly()
    _G.TommyFly = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.PlatformStand = false
    end
end

local function StartNoClip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if not _G.TommyNoclip then return end
        if lp.Character then
            for _, p in pairs(lp.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end

local function StopNoClip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

RunService.Heartbeat:Connect(function()
    if _G.TommySpeedHack and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if _G.TommySpeedMode == "WalkSpeed" then
                hum.WalkSpeed = _G.TommySpeedValue
            elseif _G.TommySpeedMode == "CFrame" then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame + (moveDir * (_G.TommySpeedValue / 100))
                end
            elseif _G.TommySpeedMode == "Velocity" then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    lp.Character.HumanoidRootPart.Velocity = Vector3.new(moveDir.X * _G.TommySpeedValue, lp.Character.HumanoidRootPart.Velocity.Y, moveDir.Z * _G.TommySpeedValue)
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if _G.TommySuperJump and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = _G.TommySuperJumpPower
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if _G.TommyDashLengthEnabled and lp.Character then
        lp.Character:SetAttribute("DashLength", _G.TommyDashLengthValue)
        lp.Character:SetAttribute("DashLengthAir", _G.TommyDashLengthValue)
    end
end)

-- ============================================================
-- DASH GLITCH (Skull Guitar)
-- ============================================================
_G.TommyDashEnabled = false
_G.TommyDashV1Active = false
_G.TommyDashCooldown = 1.5
_G.TommyDashLength = 190
_G.TommyDashSpeed = 350
_G.TommyDashAir = 400

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
    pcall(function()
        remote:FireServer("TAP", Vector3.new(-1221.487548828125, 69.36107635498047, -566.5001220703125))
    end)

    char:SetAttribute("DashLength", _G.TommyDashLength)
    char:SetAttribute("DashLengthAir", _G.TommyDashLength)
    hrp.AssemblyLinearVelocity = hrp.CFrame.LookVector * _G.TommyDashSpeed

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
        task.wait(_G.TommyDashCooldown)
        if _G.TommyDashEnabled and _G.TommyDashV1Active then
            local char = lp.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool and tool.Name == "Skull Guitar" then doDashCombo() end
        end
    end
end)

RunService.Stepped:Connect(function()
    if not _G.TommyDashEnabled then return end
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local tool = char and char:FindFirstChildOfClass("Tool")
    if hum and tool and tool.Name == "Skull Guitar" then
        if hum.FloorMaterial == Enum.Material.Air then
            hum.WalkSpeed = _G.TommyDashAir
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
-- MISC
-- ============================================================
_G.TommyAntiVoid = true
_G.TommyAntiLava = false
_G.TommyInfiniteZoom = false
_G.TommyWalkOnWater = false
_G.TommyDeleteShip = false
_G.TommyNoGFXMode = "Off"

task.spawn(function()
    while true do
        task.wait(0.5)
        workspace.FallenPartsDestroyHeight = _G.TommyAntiVoid and -math.huge or -50
        if _G.TommyInfiniteZoom then
            player.CameraMaxZoomDistance = math.huge
        else
            player.CameraMaxZoomDistance = 128
        end
    end
end)

RunService.Stepped:Connect(function()
    if _G.TommyAntiLava and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Head" then
                part.CanTouch = false
            end
        end
    end
end)

-- Walk on water
local waterPart = nil
task.spawn(function()
    while true do
        task.wait(0.15)
        if _G.TommyWalkOnWater then
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

-- Delete ship
task.spawn(function()
    while true do
        task.wait(3)
        if _G.TommyDeleteShip then
            local shipNames = {"CursedShip", "Cursed Ship", "Ship"}
            for _, obj in pairs(workspace:GetDescendants()) do
                for _, sName in ipairs(shipNames) do
                    if obj.Name:find(sName) and (obj:IsA("Model") or obj:IsA("Folder")) then
                        for _, child in pairs(obj:GetDescendants()) do
                            if child:IsA("BasePart") and not child.Parent:FindFirstChild("Humanoid") then
                                if not child.Name:find("Wall") and not child.Name:find("Floor") then
                                    child:Destroy()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- No GFX
local noGfxModified = {}
local noGfxConn = nil

local function restoreNoGfx()
    for obj, data in pairs(noGfxModified) do
        pcall(function()
            if data.Texture ~= nil then obj.Texture = data.Texture end
            if data.Enabled ~= nil then obj.Enabled = data.Enabled end
        end)
    end
    noGfxModified = {}
    if noGfxConn then noGfxConn:Disconnect(); noGfxConn = nil end
end

local function processNoGfx(inst)
    local cn = inst.ClassName
    if (cn == "Beam" or cn == "Trail") and not noGfxModified[inst] then
        noGfxModified[inst] = {Texture = inst.Texture}
        inst.Texture = "rbxassetid://84308155859778"
    elseif cn == "ParticleEmitter" and not noGfxModified[inst] then
        noGfxModified[inst] = {Texture = inst.Texture, Enabled = inst.Enabled}
        inst.Texture = ""
        inst.Enabled = false
    end
end

local function setNoGfxMode(mode)
    _G.TommyNoGFXMode = mode
    restoreNoGfx()
    if mode ~= "Off" then
        task.spawn(function()
            for _, inst in pairs(workspace:GetDescendants()) do
                if not inst:IsA("Terrain") and not inst:IsA("Camera") then processNoGfx(inst) end
            end
        end)
        noGfxConn = workspace.DescendantAdded:Connect(processNoGfx)
    end
end

-- ============================================================
-- ESP
-- ============================================================
_G.TommyESP = false
_G.TommyESPBox = true
_G.TommyESPName = true
_G.TommyESPDist = true
_G.TommyESPHealth = true
_G.TommyESPLine = true
_G.TommyESPAll = false

local espDrawings = {}

local function clearESP()
    for _, d in pairs(espDrawings) do pcall(function() d:Remove() end) end
    espDrawings = {}
end

local function updateESP()
    clearESP()
    if not _G.TommyESP then return end
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local vp = camera.ViewportSize
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lp then continue end
        if not _G.TommyESPAll and plr.Team and lp.Team and plr.Team == lp.Team then continue end
        if not plr.Character then continue end
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end
        
        local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end
        
        local dist = myHrp and (hrp.Position - myHrp.Position).Magnitude or 0
        local size = Vector2.new(2000 / math.max(dist, 1), 4000 / math.max(dist, 1))
        
        if _G.TommyESPBox then
            local tl = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
            local tr = Vector2.new(pos.X + size.X/2, pos.Y - size.Y/2)
            local bl = Vector2.new(pos.X - size.X/2, pos.Y + size.Y/2)
            local br = Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2)
            local function addLine(p1, p2)
                local l = Drawing.new("Line")
                l.Visible = true; l.Color = CONFIG.Accent; l.Thickness = 1
                l.From = p1; l.To = p2
                table.insert(espDrawings, l)
            end
            addLine(tl, tr); addLine(tr, br); addLine(br, bl); addLine(bl, tl)
        end
        
        if _G.TommyESPName then
            local t = Drawing.new("Text")
            t.Visible = true; t.Text = "👑 " .. plr.Name
            t.Color = CONFIG.Accent; t.Size = 13; t.Center = true
            t.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 15)
            t.Font = 2; t.Outline = true
            table.insert(espDrawings, t)
        end
        
        if _G.TommyESPDist then
            local t = Drawing.new("Text")
            t.Visible = true; t.Text = math.floor(dist) .. "m"
            t.Color = Color3.fromRGB(255, 255, 255); t.Size = 12; t.Center = true
            t.Position = Vector2.new(pos.X, pos.Y + size.Y/2 + 2)
            t.Font = 2; t.Outline = true
            table.insert(espDrawings, t)
        end
        
        if _G.TommyESPHealth then
            local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barW, barH = size.X, 4
            local barPos = Vector2.new(pos.X - barW/2, pos.Y + size.Y/2 + 14)
            local bg = Drawing.new("Square")
            bg.Visible = true; bg.Color = Color3.new(0,0,0); bg.Filled = true
            bg.Size = Vector2.new(barW, barH); bg.Position = barPos
            table.insert(espDrawings, bg)
            local fg = Drawing.new("Square")
            fg.Visible = true; fg.Color = Color3.new(1-hpRatio, hpRatio, 0); fg.Filled = true
            fg.Size = Vector2.new(barW * hpRatio, barH); fg.Position = barPos
            table.insert(espDrawings, fg)
        end
        
        if _G.TommyESPLine and myHrp then
            local myPos, myOnScreen = camera:WorldToViewportPoint(myHrp.Position)
            if myOnScreen then
                local l = Drawing.new("Line")
                l.Visible = true; l.Color = CONFIG.Accent; l.Thickness = 1
                l.From = Vector2.new(myPos.X, myPos.Y); l.To = Vector2.new(pos.X, pos.Y)
                table.insert(espDrawings, l)
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    pcall(updateESP)
end)

-- ============================================================
-- SILENT AIM (básico)
-- ============================================================
_G.TommySilentPlayers = false
_G.TommySilentNPCs = false
_G.TommySilentFOV = 150
_G.TommySilentShowFOV = false

local FOVCircle = nil
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Color = CONFIG.Accent
        FOVCircle.Radius = _G.TommySilentFOV
        FOVCircle.Thickness = 2
        FOVCircle.Filled = false
    end
end)

local currentSilentTarget = nil
local currentSilentPart = nil

local function getClosestPlayer(maxDist)
    maxDist = maxDist or 3500
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = lp.Character.HumanoidRootPart.Position
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if p.Team and lp.Team and p.Team == lp.Team then continue end
                local d = (p.Character.Head.Position - myPos).Magnitude
                if d < dist and d <= maxDist then closest = p; dist = d end
            end
        end
    end
    return closest
end

if hookmetamethod then
    local oldIndex
    pcall(function()
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if not checkcaller() then
                if self == mouse and (key == "Hit" or key == "Target") then
                    if (_G.TommySilentPlayers or _G.TommySilentNPCs) and currentSilentPart then
                        if key == "Hit" then return CFrame.new(currentSilentPart.Position) end
                        if key == "Target" then return currentSilentPart end
                    end
                end
            end
            return oldIndex(self, key)
        end))
    end)
end

RunService.RenderStepped:Connect(function()
    if _G.TommySilentPlayers then
        local target = getClosestPlayer(_G.TommySilentFOV)
        if target and target.Character then
            currentSilentTarget = target
            currentSilentPart = target.Character:FindFirstChild("Head")
        else
            currentSilentTarget = nil
            currentSilentPart = nil
        end
    end
    
    if FOVCircle then
        FOVCircle.Visible = _G.TommySilentShowFOV
        FOVCircle.Radius = _G.TommySilentFOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end
end)

-- ============================================================
-- SORU
-- ============================================================
_G.TommySoruAutoAim = false
_G.TommySoruRange = 300

local CommF = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("CommF_")

local function soruTo(targetPos)
    if not targetPos then return end
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (targetPos - hrp.Position).Magnitude
    if dist <= 950 then
        pcall(function()
            if CommF then CommF:InvokeServer("Flashstep", targetPos)
            else hrp.CFrame = CFrame.new(targetPos) end
        end)
    else
        local steps = math.ceil(dist / 900)
        local dir = (targetPos - hrp.Position).Unit
        for i = 1, steps do
            local nextDist = math.min(i * 900, dist)
            local nextPos = hrp.Position + (dir * nextDist)
            pcall(function()
                if CommF then CommF:InvokeServer("Flashstep", nextPos)
                else hrp.CFrame = CFrame.new(nextPos) end
            end)
            task.wait(0.02)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.TommySoruAutoAim then
            local target = getClosestPlayer(_G.TommySoruRange)
            if target and target.Character then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp then soruTo(hrp.Position) end
            end
        end
    end
end)

-- ============================================================
-- UI PRINCIPAL
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

    -- Sidebar con UIListLayout para alineación perfecta
    local sidebar = new("Frame", {
        Size = UDim2.new(0, 165, 1, -44), Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = CONFIG.BG, BorderSizePixel = 0,
    }, main)
    local sidebarLayout = new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, sidebar)
    new("UIPadding", {PaddingTop = UDim.new(0, 12)}, sidebar)

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
            BackgroundColor3 = state and CONFIG.Success or CONFIG.CardHover,
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
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = state and CONFIG.Success or CONFIG.CardHover
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
            }):Play()
            if callback then callback(state) end
        end)
        return btn
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

    local tabs = {
        {name = "Silent Aim", icon = "🎯"},
        {name = "Glitch",     icon = "🌀"},
        {name = "Movement",   icon = "🏃"},
        {name = "Apparence",  icon = "👤"},
        {name = "Visuals",    icon = "👁️"},
        {name = "Soru",       icon = "⚡"},
        {name = "Misc",       icon = "🛠️"},
    }
    local tabButtons = {}
    local function selectTab(name)
        for _, p in pairs(pages) do p.Visible = false end
        pages[name].Visible = true
        for n, b in pairs(tabButtons) do
            TweenService:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = (n == name) and CONFIG.CardHover or CONFIG.BG,
            }):Play()
            if n == name then
                b.TextColor3 = CONFIG.Accent
            else
                b.TextColor3 = CONFIG.Text
            end
        end
    end

    for i, t in ipairs(tabs) do
        local btn = new("TextButton", {
            Size = UDim2.new(1, -16, 0, 36),
            BackgroundColor3 = CONFIG.BG, BorderSizePixel = 0,
            Text = "  " .. t.icon .. "   " .. t.name,
            TextColor3 = CONFIG.Text, Font = Enum.Font.GothamBold, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = i,
        }, sidebar)
        corner(8, btn)
        tabButtons[t.name] = btn
        btn.MouseButton1Click:Connect(function() selectTab(t.name) end)
        createPage(t.name)
    end

    -- ============ SILENT AIM ============
    local silentPage = pages["Silent Aim"]
    local sc1 = createCard(silentPage, "SILENT AIM", 130)
    createToggle(sc1, 34, "Player Silent Aim", false, function(v) _G.TommySilentPlayers = v end)
    createToggle(sc1, 62, "NPC Silent Aim", false, function(v) _G.TommySilentNPCs = v end)
    createToggle(sc1, 90, "Show FOV Circle", false, function(v) _G.TommySilentShowFOV = v end)
    
    local sc2 = createCard(silentPage, "FOV SETTINGS", 90)
    createSlider(sc2, 34, "FOV Radius", 50, 800, 150, function(v) _G.TommySilentFOV = v end)

    -- ============ GLITCH ============
    local glitchPage = pages["Glitch"]
    
    local gc1 = createCard(glitchPage, "SANGUINE Z BOOST", 130)
    createToggle(gc1, 34, "Enabled", false, function(v) _G.TommyMultiEnabled = v end)
    createSlider(gc1, 62, "Power", 100, 5000, 400, function(v) _G.TommyMultiPower = v end)
    createSlider(gc1, 90, "Charge (x0.1s)", 1, 50, 10, function(v) _G.TommyMultiCharge = v / 10 end)

    local gc2 = createCard(glitchPage, "DIAMOND BOOST", 130)
    createToggle(gc2, 34, "Enabled", false, function(v) _G.TommyDiamondEnabled = v end)
    createSlider(gc2, 62, "Power", 100, 5000, 250, function(v) _G.TommyDiamondPower = v end)
    createSlider(gc2, 90, "Charge (x0.1s)", 1, 50, 10, function(v) _G.TommyDiamondCharge = v / 10 end)

    local gc3 = createCard(glitchPage, "DTALON Z BOOST", 130)
    createToggle(gc3, 34, "Enabled", false, function(v) _G.TommyDTalonEnabled = v end)
    createSlider(gc3, 62, "Power", 100, 5000, 400, function(v) _G.TommyDTalonPower = v end)
    createSlider(gc3, 90, "Charge (x0.1s)", 1, 50, 10, function(v) _G.TommyDTalonCharge = v / 10 end)

    local gc4 = createCard(glitchPage, "SKULL GUITAR DASH", 190)
    createToggle(gc4, 34, "Enabled", false, function(v) _G.TommyDashEnabled = v end)
    createToggle(gc4, 62, "Auto Dash (V1)", false, function(v) _G.TommyDashV1Active = v end)
    createSlider(gc4, 90, "Cooldown", 0.2, 5, 1.5, function(v) _G.TommyDashCooldown = v end)
    createSlider(gc4, 118, "Dash Length", 10, 500, 190, function(v) _G.TommyDashLength = v end)
    createSlider(gc4, 146, "Speed Boost", 50, 1000, 350, function(v) _G.TommyDashSpeed = v end)

    -- ============ MOVEMENT ============
    local movePage = pages["Movement"]
    
    local mc1 = createCard(movePage, "SPEED HACK", 130)
    createToggle(mc1, 34, "Enabled", false, function(v) _G.TommySpeedHack = v end)
    createDropdown(mc1, 62, "Mode", {"WalkSpeed", "CFrame", "Velocity"}, "WalkSpeed", function(v) _G.TommySpeedMode = v end)
    createSlider(mc1, 94, "Speed", 16, 500, 50, function(v) _G.TommySpeedValue = v end)

    local mc2 = createCard(movePage, "SUPER JUMP", 90)
    createToggle(mc2, 34, "Enabled", false, function(v) _G.TommySuperJump = v end)
    createSlider(mc2, 62, "Power", 50, 500, 150, function(v) _G.TommySuperJumpPower = v end)

    local mc3 = createCard(movePage, "FLY", 130)
    createToggle(mc3, 34, "Enabled", false, function(v) if v then StartFly() else StopFly() end end)
    createDropdown(mc3, 62, "Mode", {"CFrame", "Velocity"}, "CFrame", function(v) _G.TommyFlyMode = v end)
    createSlider(mc3, 94, "Speed", 10, 500, 50, function(v) _G.TommyFlySpeed = v end)

    local mc4 = createCard(movePage, "NOCLIP", 60)
    createToggle(mc4, 34, "Enabled", false, function(v)
        _G.TommyNoclip = v
        if v then StartNoClip() else StopNoClip() end
    end)

    local mc5 = createCard(movePage, "DASH LENGTH", 90)
    createToggle(mc5, 34, "Enabled", false, function(v) _G.TommyDashLengthEnabled = v end)
    createSlider(mc5, 62, "Distance", 1, 300, 1, function(v) _G.TommyDashLengthValue = v end)

    -- ============ APARENCE ============
    local appPage = pages["Apparence"]
    local ac1 = createCard(appPage, "FAKE HEADLESS", 60)
    createToggle(ac1, 34, "Enabled", false, function(v)
        _G.TommyFakeHeadless = v
        if v then applyFakeHeadless() else removeFakeHeadless() end
    end)

    local ac2 = createCard(appPage, "FAKE KORBLOX", 60)
    createToggle(ac2, 34, "Enabled", false, function(v)
        _G.TommyFakeKorblox = v
        if v then applyFakeKorblox() else removeFakeKorblox() end
    end)

    -- ============ VISUALS ============
    local visPage = pages["Visuals"]
    local vc1 = createCard(visPage, "ESP", 190)
    createToggle(vc1, 34, "Enabled", false, function(v) _G.TommyESP = v end)
    createToggle(vc1, 62, "Show Box", true, function(v) _G.TommyESPBox = v end)
    createToggle(vc1, 90, "Show Name", true, function(v) _G.TommyESPName = v end)
    createToggle(vc1, 118, "Show Distance", true, function(v) _G.TommyESPDist = v end)
    createToggle(vc1, 146, "Show Health Bar", true, function(v) _G.TommyESPHealth = v end)

    local vc2 = createCard(visPage, "ESP EXTRA", 90)
    createToggle(vc2, 34, "Show Tracer", true, function(v) _G.TommyESPLine = v end)
    createToggle(vc2, 62, "Show All Players", false, function(v) _G.TommyESPAll = v end)

    -- ============ SORU ============
    local soruPage = pages["Soru"]
    local src1 = createCard(soruPage, "SORU AUTO AIM", 90)
    createToggle(src1, 34, "Enabled", false, function(v) _G.TommySoruAutoAim = v end)
    createSlider(src1, 62, "Range", 50, 1000, 300, function(v) _G.TommySoruRange = v end)

    local src2 = createCard(soruPage, "AHK SCRIPTS", 130)
    createToggle(src2, 34, "AHK Soru", false, function(v)
        if v then LoadAHKsoru() else UnloadAHKsoru() end
    end)
    createToggle(src2, 62, "AHK Combo", false, function(v)
        if v then LoadAHKComboScript() else UnloadAHKComboScript() end
    end)

    -- ============ MISC ============
    local miscPage = pages["Misc"]
    local mm1 = createCard(miscPage, "PROTECTION", 130)
    createToggle(mm1, 34, "Anti Void", true, function(v) _G.TommyAntiVoid = v end)
    createToggle(mm1, 62, "Anti Lava", false, function(v) _G.TommyAntiLava = v end)
    createToggle(mm1, 90, "Infinite Zoom", false, function(v) _G.TommyInfiniteZoom = v end)

    local mm2 = createCard(miscPage, "WORLD", 130)
    createToggle(mm2, 34, "Walk on Water", false, function(v) _G.TommyWalkOnWater = v end)
    createToggle(mm2, 62, "Delete Ship", false, function(v) _G.TommyDeleteShip = v end)
    createDropdown(mm2, 90, "No GFX Mode", {"Off", "V1", "V2"}, "Off", function(v) setNoGfxMode(v) end)

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

-- ============================================================
-- INICIALIZAR
-- ============================================================
if loadSavedKey() then
    buildHub()
else
    showKeyScreen(function()
        buildHub()
    end)
end

print("✅ TOMMY SCRIPT cargado - Key System + Glitches + Visuals arreglados")
