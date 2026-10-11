-- Michelle Hub v6 | English | WindUI
repeat task.wait() until game:IsLoaded()

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not ok then warn("WindUI failed") return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local Camera = Workspace.CurrentCamera
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local CommE = ReplicatedStorage:WaitForChild("Remotes"):FindFirstChild("CommE")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local registerAttack = Net:FindFirstChild("RE/RegisterAttack")
local registerHit
pcall(function() registerHit = require(ReplicatedStorage.Modules.Net):RemoteEvent("RegisterHit", true) end)
if not registerHit then registerHit = Net:FindFirstChild("RE/RegisterHit") end
local ShootGunEvent = Net:FindFirstChild("RE/ShootGunEvent")
local Validator2 = Remotes:FindFirstChild("Validator2")

local Config = {
    FastAttack = false, FastAttackDelay = 0, FAPlayers = true, FAMobs = true, FARange = 60,
    MammothFA = false, MammothInterval = 0.05,
    HPPanel = false,
    GunAura = false, GunRange = 500, GunPlayers = true, GunMobs = true,
    BringMobs = false, BringRange = 3000,
    FruitAura = false, SpecialFruitAura = false, FruitInterval = 0.05,
    AutoV3 = false, AutoV4 = false, AutoPvP = false,
    InfiniteZoom = false,
    SpeedEnabled = false, WalkSpeed = 50,
    JumpEnabled = false, JumpPower = 50,
    WalkOnWater = false, WalkOnLava = false,
    SkinEnabled = false, SkinRGB = false, SkinColor = Color3.fromRGB(160, 70, 255), SkinStrength = 100,
    BypassTP = false, AttackHeight = 40,
    FTP2 = false, FTP2Speed = 275, FTP2OrbitRadius = 50, FTP2Mode = "orbit",
    -- Auto Flee
    AutoFlee = false, AutoFleeHP = 30,
    -- Auto Soru
    AutoSoru = false,
    -- Silent Aim
    SilentM1R = false, SilentSkill = false,
    SilentSkills = { Z = true, X = true, C = true, V = true, F = true },
    SilentFOV = 150, SilentShowFOV = false, SilentShowLine = false,
    SilentFOVMode = "Mouse", SilentPart = "Head",
    SilentPlayers = true, SilentMobs = false,
    SilentTeamCheck = true, SilentExcludePVP = false,
    SilentMethod = "Closest to Mouse",
    -- ESP Rich
    ESP = false, ESP_Name = true, ESP_Level = true, ESP_Bounty = true,
    ESP_Fruit = true, ESP_Distance = true, ESP_HP = true,
    ESP_Highlight = false, ESP_TextSize = 13,
}

local character = lp.Character or lp.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
lp.CharacterAdded:Connect(function(c)
    character = c
    humanoidRootPart = c:WaitForChild("HumanoidRootPart")
    task.wait(0.2)
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        if Config.SpeedEnabled then hum.WalkSpeed = Config.WalkSpeed end
        if Config.JumpEnabled then hum.UseJumpPower = true; hum.JumpPower = Config.JumpPower end
    end
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

-- ==================== FAST ATTACK ====================
task.spawn(function()
    while true do
        task.wait(0.03)
        if not Config.FastAttack then continue end
        pcall(function()
            local char = lp.Character
            if not char then return end
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
            local tip = tool.ToolTip
            if not table.find({ "Melee", "Sword", "Blox Fruit", "Gun" }, tip) then return end
            if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
                pcall(function() tool.LeftClickRemote:FireServer(Vector3.new(0.01, -500, 0.01), 1, true) end)
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
                pcall(function()
                    registerHit:FireServer(firstPart, tbl9, nil, nil,
                        tostring(lp.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15))
                end)
            end
            pcall(function() tool:Activate() end)
        end)
    end
end)

-- ==================== MAMMOTH ====================
task.spawn(function()
    while true do
        task.wait(Config.MammothInterval)
        if not Config.MammothFA then continue end
        pcall(function()
            local tool = lp.Character and lp.Character:FindFirstChild("Mammoth-Mammoth")
            local remote = tool and tool:FindFirstChild("LeftClickRemote")
            if remote then remote:FireServer(vector.create(9e30, 9e30, 9e30)) end
        end)
    end
end)

-- ==================== HP PANEL ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MichelleHPPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = lp:WaitForChild("PlayerGui") end

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 200, 0, 280)
Panel.Position = UDim2.new(0, 12, 0.35, 0)
Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Panel.BackgroundTransparency = 0.25
Panel.BorderSizePixel = 0
Panel.Visible = false
Panel.Active = true
Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 8)

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.BackgroundTransparency = 0.3
TitleBar.Text = "  Players HP  (drag)"
TitleBar.TextColor3 = Color3.fromRGB(160, 0, 255)
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 12
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = Panel
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -8, 1, -34)
List.Position = UDim2.new(0, 4, 0, 30)
List.BackgroundTransparency = 1
List.BorderSizePixel = 0
List.ScrollBarThickness = 3
List.CanvasSize = UDim2.new(0, 0, 0, 0)
List.Parent = Panel
local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.Name
Layout.Padding = UDim.new(0, 4)
Layout.Parent = List

local rows = {}
local function hpColor(pct)
    if pct > 0.6 then return Color3.fromRGB(0, 220, 80)
    elseif pct > 0.3 then return Color3.fromRGB(255, 200, 0)
    else return Color3.fromRGB(255, 50, 50) end
end
local function makeRow(plr)
    if rows[plr] then return rows[plr] end
    local row = Instance.new("Frame")
    row.Name = plr.Name; row.Size = UDim2.new(1, -4, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 45); row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0; row.Parent = List
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "Name"; nameLbl.Size = UDim2.new(1, -8, 0, 16); nameLbl.Position = UDim2.new(0, 6, 0, 2)
    nameLbl.BackgroundTransparency = 1; nameLbl.Text = plr.Name; nameLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    nameLbl.Font = Enum.Font.Gotham; nameLbl.TextSize = 11; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = row
    local barBG = Instance.new("Frame")
    barBG.Name = "BarBG"; barBG.Size = UDim2.new(1, -12, 0, 8); barBG.Position = UDim2.new(0, 6, 0, 20)
    barBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50); barBG.BorderSizePixel = 0; barBG.Parent = row
    Instance.new("UICorner", barBG).CornerRadius = UDim.new(0, 3)
    local bar = Instance.new("Frame")
    bar.Name = "Bar"; bar.Size = UDim2.new(1, 0, 1, 0); bar.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
    bar.BorderSizePixel = 0; bar.Parent = barBG
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)
    local hpLbl = Instance.new("TextLabel")
    hpLbl.Name = "HP"; hpLbl.Size = UDim2.new(1, -8, 0, 10); hpLbl.Position = UDim2.new(0, 4, 0, 19)
    hpLbl.BackgroundTransparency = 1; hpLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpLbl.Font = Enum.Font.GothamBold; hpLbl.TextSize = 9; hpLbl.TextXAlignment = Enum.TextXAlignment.Right
    hpLbl.ZIndex = 2; hpLbl.Parent = row
    rows[plr] = row; return row
end
local function removeRow(plr) if rows[plr] then rows[plr]:Destroy() rows[plr] = nil end end

RunService.RenderStepped:Connect(function()
    if not Config.HPPanel then return end
    local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == lp then continue end
        local row = makeRow(plr)
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local nameLbl, barBG = row:FindFirstChild("Name"), row:FindFirstChild("BarBG")
        local bar = barBG and barBG:FindFirstChild("Bar")
        local hpLbl = row:FindFirstChild("HP")
        if hum and hum.Health > 0 then
            local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            if bar then bar.Size = UDim2.new(pct, 0, 1, 0) bar.BackgroundColor3 = hpColor(pct) end
            local dist = (myHRP and hrp) and ("  " .. math.floor((hrp.Position - myHRP.Position).Magnitude) .. "m") or ""
            if nameLbl then nameLbl.Text = plr.Name .. dist end
            if hpLbl then hpLbl.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) end
        else
            if bar then bar.Size = UDim2.new(0, 0, 1, 0) end
            if nameLbl then nameLbl.Text = plr.Name .. " (dead)" end
            if hpLbl then hpLbl.Text = "0" end
        end
    end
    for plr in pairs(rows) do if not plr.Parent then removeRow(plr) end end
    List.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 8)
end)
Players.PlayerRemoving:Connect(removeRow)

-- ==================== GUN AURA ====================
local ShootFunction, getupval, setupval, getupvals
pcall(function()
    getupval = debug.getupvalue or getupvalue
    setupval = debug.setupvalue or setupvalue
    getupvals = debug.getupvalues or getupvalues
end)
local V_Idx = { v26 = 12, v22 = 13, v25 = 14, v21 = 15, v23 = 16, v24 = 17, v27 = 18 }

local function InitDragonGun()
    local ok2, result = pcall(require, ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("CombatController"))
    if ok2 and type(result) == "table" and result.Attack and getupval then
        ShootFunction = getupval(result.Attack, 9)
    end
end

local function GetNextValidator()
    if not getupval then return 0, 0 end
    if not ShootFunction then InitDragonGun() end
    if not ShootFunction then return 0, 0 end
    local upvals = getupvals and getupvals(ShootFunction)
    if not upvals then return 0, 0 end
    if upvals[V_Idx.v21] ~= 727595 then
        for i, v in pairs(upvals) do
            if v == 727595 then
                local o = i - 15
                V_Idx.v21 = i; V_Idx.v22 = 13 + o; V_Idx.v23 = 16 + o; V_Idx.v24 = 17 + o
                V_Idx.v26 = 12 + o; V_Idx.v25 = 14 + o; V_Idx.v27 = 18 + o
                break
            end
        end
    end
    local v1 = getupval(ShootFunction, V_Idx.v21)
    local v2 = getupval(ShootFunction, V_Idx.v22)
    local v3 = getupval(ShootFunction, V_Idx.v23)
    local v4 = getupval(ShootFunction, V_Idx.v24)
    local v5 = getupval(ShootFunction, V_Idx.v25)
    local v6 = getupval(ShootFunction, V_Idx.v26)
    local v7 = getupval(ShootFunction, V_Idx.v27)
    if not (v1 and v2 and v3 and v4 and v5 and v6 and v7) then return 0, 0 end
    local v9 = ((v5 * v2 + v6 * v1) % v3 * v3 + v6 * v2) % v4
    v5 = math.floor(v9 / v3); v6 = v9 - v5 * v3; v7 = v7 + 1
    setupval(ShootFunction, V_Idx.v25, v5)
    setupval(ShootFunction, V_Idx.v26, v6)
    setupval(ShootFunction, V_Idx.v27, v7)
    return math.floor(v9 / v4 * 16777215), v7
end

local function GetBestPart(model)
    return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
end

local function GetClosestGunTarget()
    local root = humanoidRootPart
    if not root then return nil end
    local closest, dist, myPos = nil, math.huge, root.Position
    if Config.GunMobs then
        local ef = Workspace:FindFirstChild("Enemies")
        if ef then
            for _, enemy in pairs(ef:GetChildren()) do
                local h = enemy:FindFirstChildOfClass("Humanoid")
                local r = GetBestPart(enemy)
                if h and h.Health > 0 and r then
                    local d = (r.Position - myPos).Magnitude
                    if d < dist and d <= Config.GunRange then dist = d; closest = r end
                end
            end
        end
    end
    if Config.GunPlayers then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= lp and player.Character then
                local h = player.Character:FindFirstChildOfClass("Humanoid")
                local r = GetBestPart(player.Character)
                if h and h.Health > 0 and r then
                    local d = (r.Position - myPos).Magnitude
                    if d < dist and d <= Config.GunRange then dist = d; closest = r end
                end
            end
        end
    end
    return closest
end

local _cachedTool, _cachedTarget, _targetTimer = nil, nil, 0
task.spawn(function()
    while true do
        if not Config.GunAura then task.wait(0.05) continue end
        pcall(function()
            local char = lp.Character
            if not char then return end
            if not _cachedTool or not _cachedTool.Parent or _cachedTool.ToolTip ~= "Gun" then
                _cachedTool = char:FindFirstChildOfClass("Tool")
                if not _cachedTool or _cachedTool.ToolTip ~= "Gun" then _cachedTool = nil return end
            end
            _targetTimer += 1
            if _targetTimer >= 3 or not _cachedTarget or not _cachedTarget.Parent then
                _cachedTarget = GetClosestGunTarget(); _targetTimer = 0
            end
            if not _cachedTarget then return end
            local valCode, valCount = GetNextValidator()
            if valCode ~= 0 and Validator2 then pcall(function() Validator2:FireServer(valCode, valCount) end) end
            _cachedTool:SetAttribute("LocalOverheat", 0)
            _cachedTool:SetAttribute("IsReloading_Client", false)
            _cachedTool:SetAttribute("LocalShotsLeft", 100)
            if ShootGunEvent then ShootGunEvent:FireServer(_cachedTarget.Position, { _cachedTarget }) end
        end)
        task.wait(0.03)
    end
end)

-- ==================== BRING MOBS ====================
RunService.Heartbeat:Connect(function()
    if not Config.BringMobs then return end
    pcall(function()
        local hrp = humanoidRootPart
        if not hrp then return end
        if sethiddenproperty then pcall(function() sethiddenproperty(lp, "SimulationRadius", math.huge) end) end
        local targetPos = hrp.Position
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end
        for _, enemy in ipairs(enemies:GetChildren()) do
            if enemy:IsA("Model") then
                local eHum = enemy:FindFirstChildOfClass("Humanoid")
                local eRoot = enemy:FindFirstChild("HumanoidRootPart")
                if eHum and eRoot and eHum.Health > 0 then
                    if (eRoot.Position - targetPos).Magnitude <= Config.BringRange then
                        local isOwner = isnetworkowner and isnetworkowner(eRoot) or (eRoot.ReceiveAge == 0 and not eRoot.Anchored)
                        if isOwner then
                            eRoot.CFrame = CFrame.new(targetPos.X, targetPos.Y - 18, targetPos.Z)
                        end
                        eRoot.CanCollide = false
                        eHum.WalkSpeed = 0
                        eHum.JumpPower = 0
                    end
                end
            end
        end
    end)
end)

-- ==================== FRUIT AURA ====================
task.spawn(function()
    while true do
        task.wait(Config.FruitInterval)
        if not (Config.FruitAura or Config.SpecialFruitAura) then continue end
        pcall(function()
            local fruit = getFruit()
            if not fruit then return end
            local remote = fruit:FindFirstChild("LeftClickRemote")
            if not remote then return end
            if Config.SpecialFruitAura then
                remote:FireServer(Vector3.new(9e30, 9e30, 9e30), 5, false)
            else
                local targets = collectTargets(200, true, true)
                local dir = Vector3.new(0, 0, -1)
                if #targets > 0 and humanoidRootPart then
                    dir = (targets[1][2].Position - humanoidRootPart.Position).Unit
                end
                remote:FireServer(dir, 1, true)
            end
        end)
    end
end)

-- ==================== AUTO BUFFS ====================
task.spawn(function()
    while true do
        task.wait(1)
        if Config.AutoV3 and CommE then pcall(function() CommE:FireServer("ActivateAbility") end) end
    end
end)
task.spawn(function()
    while true do
        task.wait(0.5)
        if not Config.AutoV4 then continue end
        pcall(function()
            local aw = (lp.Character and lp.Character:FindFirstChild("Awakening"))
                or (lp.Backpack and lp.Backpack:FindFirstChild("Awakening"))
            if aw then
                local rf = aw:FindFirstChildWhichIsA("RemoteFunction")
                if rf then rf:InvokeServer(true) end
            end
        end)
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
        task.wait(0.15)
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if not hum then continue end
        if Config.SpeedEnabled and hum.WalkSpeed ~= Config.WalkSpeed then hum.WalkSpeed = Config.WalkSpeed end
        if Config.JumpEnabled then
            hum.UseJumpPower = true
            if hum.JumpPower ~= Config.JumpPower then hum.JumpPower = Config.JumpPower end
        end
    end
end)

-- ==================== WALK WATER / LAVA ====================
local function isLavaPart(p)
    if not p:IsA("BasePart") then return false end
    local n = p.Name:lower()
    return p.Material == Enum.Material.CrackedLava or n:find("lava") or n:find("magma")
end

task.spawn(function()
    while true do
        task.wait(0.1)
        local hrp = humanoidRootPart
        if not hrp then continue end
        if Config.WalkOnWater then
            local pos = hrp.Position
            local plat = Workspace:FindFirstChild("MichelleWaterPlat")
            if not plat then
                plat = Instance.new("Part")
                plat.Name = "MichelleWaterPlat"
                plat.Size = Vector3.new(12, 1, 12)
                plat.Anchored = true
                plat.Transparency = 1
                plat.Parent = Workspace
            end
            plat.Position = Vector3.new(pos.X, pos.Y - 3.5, pos.Z)
            plat.CanCollide = true
        else
            local plat = Workspace:FindFirstChild("MichelleWaterPlat")
            if plat then plat.CanCollide = false end
        end
        if Config.WalkOnLava then
            for _, p in ipairs(Workspace:GetDescendants()) do
                if isLavaPart(p) then
                    pcall(function()
                        p.CanTouch = false
                        local ti = p:FindFirstChildOfClass("TouchInterest")
                        if ti then ti:Destroy() end
                    end)
                end
            end
        end
    end
end)

-- ==================== SKIN CHANGER (tools only) ====================
local function getSkinColor()
    if Config.SkinRGB then
        return Color3.fromHSV((tick() * 0.25) % 1, 1, 1)
    end
    return Config.SkinColor
end

local function recolorTool(tool, color)
    if not tool or not tool:IsA("Tool") then return end
    local tip = tool.ToolTip
    if not table.find({ "Melee", "Sword", "Blox Fruit", "Gun" }, tip) then return end
    local strength = (Config.SkinStrength or 100) / 100
    for _, d in ipairs(tool:GetDescendants()) do
        pcall(function()
            if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then
                local c = d.Color
                if typeof(c) == "ColorSequence" then
                    d.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 1 - strength))
                end
            elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                d.Color = color
            elseif d:IsA("BasePart") and (d.Name:lower():find("effect") or d.Transparency > 0.3) then
                d.Color = color
            end
        end)
    end
end

task.spawn(function()
    while true do
        task.wait(0.12)
        if not Config.SkinEnabled then continue end
        local color = getSkinColor()
        local char = lp.Character
        local bp = lp:FindFirstChild("Backpack")
        for _, container in ipairs({ char, bp }) do
            if container then
                for _, t in ipairs(container:GetChildren()) do
                    if t:IsA("Tool") then recolorTool(t, color) end
                end
            end
        end
    end
end)

-- ==================== AUTO FLEE ====================
local fleeTeleported = false
local function GetFleeDestination()
    local pid = game.PlaceId
    if pid == 4442272183 or pid == 79091703265657 then
        return Vector3.new(923, 126, 32852) -- Ship
    elseif pid == 7449423635 or pid == 100117331123089 then
        return Vector3.new(-5027.03, 316.43, -3206.07) -- Hydra
    end
    return nil
end

local function RestoreFleeState()
    pcall(function()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if not Config.AutoFlee then
            if fleeTeleported then fleeTeleported = false; RestoreFleeState() end
            continue
        end
        pcall(function()
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp or hum.Health <= 0 then
                fleeTeleported = false
                return
            end
            local hpPercent = (hum.Health / hum.MaxHealth) * 100
            if hpPercent <= Config.AutoFleeHP then
                if not fleeTeleported then
                    fleeTeleported = true
                    local dest = GetFleeDestination()
                    if dest then
                        pcall(function() CommF:InvokeServer("requestEntrance", dest) end)
                    end
                end
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hum:ChangeState(Enum.HumanoidStateType.Physics)
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 20, 0)
            elseif fleeTeleported then
                fleeTeleported = false
                RestoreFleeState()
            end
        end)
    end
end)

-- ==================== AUTO SORU ====================
local function soruTo(targetPosition)
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    local startCF = hrp.CFrame
    local finalCF = (startCF - startCF.Position) + targetPosition + Vector3.new(0, hrp.Size.Y * 1.5, 0)
    if CommE then
        pcall(function()
            CommE:FireServer("Soru", startCF, finalCF, workspace:GetServerTimeNow(), math.random(1, 999999999))
        end)
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if not Config.AutoSoru then continue end
        pcall(function()
            local myRoot = humanoidRootPart
            if not myRoot then return end
            local closest, shortest = nil, math.huge
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= lp and player.Character then
                    local otherHum = player.Character:FindFirstChildOfClass("Humanoid")
                    local otherRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if otherHum and otherRoot and otherHum.Health > 0 then
                        local d = (otherRoot.Position - myRoot.Position).Magnitude
                        if d < shortest then shortest = d; closest = otherRoot end
                    end
                end
            end
            if closest then
                soruTo((closest.CFrame * CFrame.new(0, 0, 3)).Position)
            end
        end)
    end
end)

-- ==================== SILENT AIM ====================
local currentSilentTarget = nil
local FOVCircle, AimLine

pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.NumSides = 64
        FOVCircle.Radius = Config.SilentFOV
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(255, 50, 50)
        FOVCircle.Transparency = 1
        FOVCircle.Visible = false

        AimLine = Drawing.new("Line")
        AimLine.Thickness = 1.5
        AimLine.Color = Color3.fromRGB(255, 50, 50)
        AimLine.Transparency = 1
        AimLine.Visible = false
    end
end)

local function IsAlly(player)
    local main = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main")
    local frame = main and main:FindFirstChild("Allies")
        and main.Allies:FindFirstChild("Container")
        and main.Allies.Container:FindFirstChild("Allies")
        and main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
        and main.Allies.Container.Allies.ScrollingFrame:FindFirstChild("Frame")
    if not frame then return false end
    return frame:FindFirstChild(player.Name) ~= nil
end

local function IsEnemy(player)
    if not player or player == lp then return false end
    if IsAlly(player) then return false end
    local myTeam, targetTeam = lp.Team, player.Team
    if myTeam and targetTeam and myTeam.Name == "Marines" and targetTeam.Name == "Marines" then
        return false
    end
    return true
end

local function GetAimOrigin()
    local p = UIS:GetMouseLocation()
    if Config.SilentFOVMode == "Center" or p.X <= 0 or p.Y <= 0 then
        local v = Camera.ViewportSize
        return Vector2.new(v.X / 2, v.Y / 2)
    end
    return p
end

local function GetClosestSilentTarget()
    local method = Config.SilentMethod

    if method == "Closest Player" then
        local myRoot = humanoidRootPart
        if not myRoot then return nil end
        local closest, shortest = nil, math.huge
        local myPos = myRoot.Position
        if Config.SilentPlayers then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Character and isAlive(player.Character) then
                    if Config.SilentTeamCheck and not IsEnemy(player) then continue end
                    if Config.SilentExcludePVP and player:GetAttribute("PvpDisabled") == true then continue end
                    local part = player.Character:FindFirstChild(Config.SilentPart)
                        or player.Character:FindFirstChild("HumanoidRootPart")
                    if part then
                        local d = (part.Position - myPos).Magnitude
                        if d < shortest then shortest = d; closest = part end
                    end
                end
            end
        end
        if Config.SilentMobs then
            local enemies = Workspace:FindFirstChild("Enemies")
            if enemies then
                for _, enemy in ipairs(enemies:GetChildren()) do
                    if isAlive(enemy) then
                        local part = enemy:FindFirstChild(Config.SilentPart)
                            or enemy:FindFirstChild("HumanoidRootPart")
                        if part then
                            local d = (part.Position - myPos).Magnitude
                            if d < shortest then shortest = d; closest = part end
                        end
                    end
                end
            end
        end
        return closest
    end

    -- Closest to Mouse (default)
    local origin = GetAimOrigin()
    local closest, shortest = nil, math.huge

    local function check(part)
        if not part then return end
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then return end
        local dist = (Vector2.new(pos.X, pos.Y) - origin).Magnitude
        if dist <= Config.SilentFOV and dist < shortest then
            closest = part
            shortest = dist
        end
    end

    if Config.SilentPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character and isAlive(player.Character) then
                if Config.SilentTeamCheck and not IsEnemy(player) then continue end
                if Config.SilentExcludePVP and player:GetAttribute("PvpDisabled") == true then continue end
                local part = player.Character:FindFirstChild(Config.SilentPart)
                    or player.Character:FindFirstChild("HumanoidRootPart")
                check(part)
            end
        end
    end
    if Config.SilentMobs then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, enemy in ipairs(enemies:GetChildren()) do
                if isAlive(enemy) then
                    local part = enemy:FindFirstChild(Config.SilentPart)
                        or enemy:FindFirstChild("HumanoidRootPart")
                    check(part)
                end
            end
        end
    end
    return closest
end

local function IsSkillKeyEnabled()
    -- Check if any enabled skill key is being held (simplified: always true when skill aim on)
    return true
end

-- Hook mouse Hit/Target for M1R
pcall(function()
    if not hookmetamethod then return end
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if Config.SilentM1R and currentSilentTarget and not checkcaller() and self == mouse then
            local tp = currentSilentTarget.Position
            local cp = Camera.CFrame.Position
            if key == "Hit" then return CFrame.new(tp)
            elseif key == "Target" then return currentSilentTarget
            elseif key == "UnitRay" then return Ray.new(cp, (tp - cp).Unit)
            elseif key == "Origin" then return cp
            elseif key == "Direction" then return (tp - cp).Unit
            end
        end
        return oldIndex(self, key)
    end)
end)

-- Hook FireServer/InvokeServer for skill aim
pcall(function()
    if not hookmetamethod then return end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = { ... }
        if Config.SilentSkill and currentSilentTarget and not checkcaller() then
            if method == "FireServer" or method == "InvokeServer" then
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = currentSilentTarget.Position
                    elseif typeof(v) == "CFrame" then
                        args[i] = CFrame.new(currentSilentTarget.Position)
                    end
                end
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)
end)

RunService.RenderStepped:Connect(function()
    local origin = GetAimOrigin()

    if FOVCircle then
        FOVCircle.Position = origin
        FOVCircle.Radius = Config.SilentFOV
        FOVCircle.Visible = Config.SilentShowFOV and (Config.SilentM1R or Config.SilentSkill)
    end

    if Config.SilentM1R or Config.SilentSkill then
        currentSilentTarget = GetClosestSilentTarget()
    else
        currentSilentTarget = nil
    end

    if AimLine then
        if Config.SilentShowLine and currentSilentTarget then
            local pos, onScreen = Camera:WorldToViewportPoint(currentSilentTarget.Position)
            if onScreen then
                AimLine.From = origin
                AimLine.To = Vector2.new(pos.X, pos.Y)
                AimLine.Visible = true
            else
                AimLine.Visible = false
            end
        else
            AimLine.Visible = false
        end
    end
end)

-- ==================== RICH ESP ====================
local espFolder = Instance.new("Folder")
espFolder.Name = "MichelleESP"
pcall(function() espFolder.Parent = CoreGui end)
if not espFolder.Parent then espFolder.Parent = lp:WaitForChild("PlayerGui") end

local espData = {}

local function getPlayerFruit(plr)
    local data = plr:FindFirstChild("Data")
    if data then
        local df = data:FindFirstChild("DevilFruit")
        if df and df.Value and df.Value ~= "" then return df.Value end
    end
    local char = plr.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and (t.ToolTip == "Blox Fruit" or t.Name:find("-")) then
                return t.Name
            end
        end
    end
    return "None"
end

local function getPlayerLevel(plr)
    local data = plr:FindFirstChild("Data")
    if data then
        local lvl = data:FindFirstChild("Level")
        if lvl then return tostring(lvl.Value) end
    end
    return "?"
end

local function getPlayerBounty(plr)
    local leaderstats = plr:FindFirstChild("leaderstats")
    if leaderstats then
        local b = leaderstats:FindFirstChild("Bounty/Honor") or leaderstats:FindFirstChild("Bounty")
        if b then
            local v = b.Value
            if v >= 1000000 then return string.format("%.1fM", v / 1000000)
            elseif v >= 1000 then return string.format("%.1fK", v / 1000)
            else return tostring(v) end
        end
    end
    return "0"
end

local function clearESP()
    for plr, data in pairs(espData) do
        pcall(function() if data.bb then data.bb:Destroy() end end)
        pcall(function() if data.hl then data.hl:Destroy() end end)
    end
    espData = {}
    for _, c in ipairs(espFolder:GetChildren()) do c:Destroy() end
end

local function createESP(plr)
    if espData[plr] then return end
    local char = plr.Character
    if not char or not char:FindFirstChild("Head") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_" .. plr.Name
    bb.Size = UDim2.new(0, 200, 0, 80)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = char.Head
    bb.Parent = espFolder

    local text = Instance.new("TextLabel")
    text.Name = "Info"
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = plr.Name
    text.TextColor3 = Color3.fromRGB(255, 255, 100)
    text.TextStrokeTransparency = 0.3
    text.Font = Enum.Font.GothamBold
    text.TextSize = Config.ESP_TextSize
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.Parent = bb

    local hl = nil
    if Config.ESP_Highlight then
        hl = Instance.new("Highlight")
        hl.Name = "ESP_HL"
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(255, 50, 50)
        hl.OutlineColor = Color3.fromRGB(255, 100, 100)
        hl.FillTransparency = 0.7
        hl.OutlineTransparency = 0.3
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = espFolder
    end

    espData[plr] = { bb = bb, text = text, hl = hl, char = char }
end

local function updateESP()
    if not Config.ESP then
        clearESP()
        return
    end
    local myHRP = humanoidRootPart
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == lp then continue end
        local char = plr.Character
        if not char or not isAlive(char) then
            if espData[plr] then
                pcall(function() if espData[plr].bb then espData[plr].bb:Destroy() end end)
                pcall(function() if espData[plr].hl then espData[plr].hl:Destroy() end end)
                espData[plr] = nil
            end
            continue
        end
        if not espData[plr] or espData[plr].char ~= char then
            if espData[plr] then
                pcall(function() if espData[plr].bb then espData[plr].bb:Destroy() end end)
                pcall(function() if espData[plr].hl then espData[plr].hl:Destroy() end end)
            end
            createESP(plr)
        end
        local data = espData[plr]
        if not data or not data.text then continue end

        local lines = {}
        if Config.ESP_Name then table.insert(lines, plr.Name) end
        if Config.ESP_Level then table.insert(lines, "Lv " .. getPlayerLevel(plr)) end
        if Config.ESP_Bounty then table.insert(lines, "B: " .. getPlayerBounty(plr)) end
        if Config.ESP_Fruit then table.insert(lines, getPlayerFruit(plr)) end
        if Config.ESP_HP then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                table.insert(lines, math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth))
            end
        end
        if Config.ESP_Distance and myHRP then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                table.insert(lines, math.floor((hrp.Position - myHRP.Position).Magnitude) .. "m")
            end
        end
        data.text.Text = table.concat(lines, "\n")
        data.text.TextSize = Config.ESP_TextSize

        if Config.ESP_Highlight and not data.hl then
            local hl = Instance.new("Highlight")
            hl.Name = "ESP_HL"
            hl.Adornee = char
            hl.FillColor = Color3.fromRGB(255, 50, 50)
            hl.OutlineColor = Color3.fromRGB(255, 100, 100)
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 0.3
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = espFolder
            data.hl = hl
        elseif not Config.ESP_Highlight and data.hl then
            data.hl:Destroy()
            data.hl = nil
        end
    end
    for plr in pairs(espData) do
        if not plr.Parent then
            pcall(function() if espData[plr].bb then espData[plr].bb:Destroy() end end)
            pcall(function() if espData[plr].hl then espData[plr].hl:Destroy() end end)
            espData[plr] = nil
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.4)
        pcall(updateESP)
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    if espData[plr] then
        pcall(function() if espData[plr].bb then espData[plr].bb:Destroy() end end)
        pcall(function() if espData[plr].hl then espData[plr].hl:Destroy() end end)
        espData[plr] = nil
    end
end)

-- ==================== DUNGEON BYPASS ====================
task.spawn(function()
    while true do
        task.wait()
        if not Config.BypassTP then continue end
        pcall(function()
            if not humanoidRootPart then return end
            local closest, shortest = nil, math.huge
            local folder = Workspace:FindFirstChild("Enemies") or Workspace
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj ~= character then
                    local nameL = string.lower(obj.Name)
                    if nameL == "blank buddy" or nameL == "sombra" then continue end
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                    if hum and hum.Health > 0 and root then
                        local d = (root.Position - humanoidRootPart.Position).Magnitude
                        if string.find(nameL, "gas knight") or string.find(nameL, "kitsune") then d = d - 1000 end
                        if d < shortest then shortest = d; closest = obj end
                    end
                end
            end
            if closest then
                local root = closest:FindFirstChild("HumanoidRootPart") or closest:FindFirstChild("Head")
                if root then humanoidRootPart.CFrame = root.CFrame * CFrame.new(0, Config.AttackHeight, 0) end
            end
        end)
    end
end)

-- ==================== FTP2 ====================
local FTP2_LV, FTP2_Att, FTP2_AG, FTP2_Conn = nil, nil, nil, nil
local FTP2_OrbitOffset, FTP2_NextOrbit, FTP2_CurrentTarget = nil, 0, nil

local function FTP2_Clear()
    pcall(function() if FTP2_LV then FTP2_LV:Destroy() end end)
    pcall(function() if FTP2_AG then FTP2_AG:Destroy() end end)
    pcall(function() if FTP2_Att then FTP2_Att:Destroy() end end)
    FTP2_LV, FTP2_Att, FTP2_AG = nil, nil, nil
end

local function FTP2_Setup(hrp)
    FTP2_Clear()
    local att = Instance.new("Attachment"); att.Name = "MichelleFTP2"; att.Parent = hrp; FTP2_Att = att
    local lv = Instance.new("LinearVelocity")
    lv.MaxForce = math.huge; lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity = Vector3.zero; lv.Attachment0 = att; lv.Parent = hrp; FTP2_LV = lv
    local mass = 0
    for _, p in ipairs(hrp.Parent:GetDescendants()) do
        if p:IsA("BasePart") and not p.Massless then mass += p:GetMass() end
    end
    local vf = Instance.new("VectorForce")
    vf.ApplyAtCenterOfMass = true; vf.Attachment0 = att
    vf.Force = Vector3.new(0, mass * Workspace.Gravity, 0); vf.Parent = hrp; FTP2_AG = vf
end

local function FTP2_GetNearest()
    local myHRP = humanoidRootPart
    if not myHRP then return nil end
    local nearest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if d < shortest then shortest = d; nearest = plr end
            end
        end
    end
    return nearest
end

local function StartFTP2()
    if FTP2_Conn then return end
    FTP2_Conn = RunService.RenderStepped:Connect(function()
        if not Config.FTP2 then return end
        pcall(function()
            local myChar = lp.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            if not myHRP or not myHum or myHum.Health <= 0 then return end
            for _, p in ipairs(myChar:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
            myHum.PlatformStand = true
            if not FTP2_CurrentTarget or not FTP2_CurrentTarget.Character then
                FTP2_CurrentTarget = FTP2_GetNearest()
            end
            if not FTP2_CurrentTarget then
                if FTP2_LV then FTP2_LV.VectorVelocity = Vector3.zero end
                return
            end
            local tgHRP = FTP2_CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
            if not tgHRP then return end
            if not FTP2_LV or FTP2_LV.Parent ~= myHRP then FTP2_Setup(myHRP) end
            local rawPos = tgHRP.Position
            local targetPos, now = nil, os.clock()
            if Config.FTP2Mode == "above" then
                targetPos = Vector3.new(rawPos.X, rawPos.Y + Config.FTP2OrbitRadius, rawPos.Z)
            elseif Config.FTP2Mode == "hrp" then
                targetPos = rawPos
            else
                if not FTP2_OrbitOffset or now >= FTP2_NextOrbit then
                    local d = math.random(1, Config.FTP2OrbitRadius)
                    local dir = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1)
                    if dir.Magnitude > 0 then dir = dir.Unit end
                    FTP2_OrbitOffset = dir * d; FTP2_NextOrbit = now + 0.033
                end
                targetPos = rawPos + FTP2_OrbitOffset
            end
            local flyDir = targetPos - myHRP.Position
            if flyDir.Magnitude > 0 then FTP2_LV.VectorVelocity = flyDir.Unit * Config.FTP2Speed end
        end)
    end)
end

local function StopFTP2()
    Config.FTP2 = false
    if FTP2_Conn then FTP2_Conn:Disconnect(); FTP2_Conn = nil end
    FTP2_Clear(); FTP2_CurrentTarget = nil
    local char = lp.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- ==================== UI ====================
local Window = WindUI:CreateWindow({
    Title = "Michelle Hub",
    Icon = "star",
    Theme = "Dark",
    Folder = "MichelleHub",
})

-- MAIN
local Main = Window:Tab({ Title = "Main", Icon = "home" })
Main:Toggle({ Title = "Fast Attack", Value = false, Callback = function(v) Config.FastAttack = v end })
Main:Toggle({ Title = "Attack Players", Value = true, Callback = function(v) Config.FAPlayers = v end })
Main:Toggle({ Title = "Attack NPCs", Value = true, Callback = function(v) Config.FAMobs = v end })
Main:Slider({ Title = "FA Range", Step = 5, Value = { Min = 20, Max = 120, Default = 60 }, Callback = function(v) Config.FARange = v end })
Main:Slider({ Title = "FA Delay", Step = 0.05, Value = { Min = 0, Max = 1, Default = 0 }, Callback = function(v) Config.FastAttackDelay = v end })
Main:Toggle({ Title = "HP Panel", Value = false, Callback = function(v)
    Config.HPPanel = v; Panel.Visible = v
    if not v then for plr in pairs(rows) do removeRow(plr) end end
end })

-- PROFITS (empty / future)
local Profits = Window:Tab({ Title = "Profits", Icon = "dollar-sign" })
Profits:Paragraph({ Title = "Profits", Desc = "Reserved for future farm features" })

-- GUN AURA
local GunAura = Window:Tab({ Title = "Gun Aura", Icon = "crosshair" })
GunAura:Toggle({ Title = "Enable Gun Aura", Value = false, Callback = function(v)
    Config.GunAura = v; _cachedTool = nil; _cachedTarget = nil
end })
GunAura:Toggle({ Title = "Attack Players", Value = true, Callback = function(v) Config.GunPlayers = v end })
GunAura:Toggle({ Title = "Attack NPCs", Value = true, Callback = function(v) Config.GunMobs = v end })
GunAura:Toggle({ Title = "Bring Mobs", Value = false, Callback = function(v) Config.BringMobs = v end })
GunAura:Slider({ Title = "Gun Range", Step = 50, Value = { Min = 50, Max = 30000, Default = 500 }, Callback = function(v) Config.GunRange = v end })
GunAura:Slider({ Title = "Bring Range", Step = 100, Value = { Min = 100, Max = 5000, Default = 3000 }, Callback = function(v) Config.BringRange = v end })
GunAura:Paragraph({ Title = "Info", Desc = "Equip the gun yourself\nValidator2 keeps it stable\nBring places NPCs under you" })

-- ATTACK FRUIT
local AttackFruit = Window:Tab({ Title = "Attack Fruit", Icon = "sword" })
AttackFruit:Toggle({ Title = "Mammoth FA", Value = false, Callback = function(v) Config.MammothFA = v end })
AttackFruit:Slider({ Title = "Mammoth Speed", Step = 0.005, Value = { Min = 0.01, Max = 0.2, Default = 0.05 }, Callback = function(v) Config.MammothInterval = v end })
AttackFruit:Toggle({ Title = "Fruit Aura", Value = false, Callback = function(v) Config.FruitAura = v end })
AttackFruit:Toggle({ Title = "Special Fruit Aura", Value = false, Callback = function(v) Config.SpecialFruitAura = v end })
AttackFruit:Slider({ Title = "Fruit Speed", Step = 0.01, Value = { Min = 0.01, Max = 0.2, Default = 0.05 }, Callback = function(v) Config.FruitInterval = v end })

-- AIM
local Aim = Window:Tab({ Title = "Aim", Icon = "target" })
Aim:Toggle({ Title = "Silent Aim M1R", Value = false, Callback = function(v) Config.SilentM1R = v end })
Aim:Toggle({ Title = "Skill Aimbot", Value = false, Callback = function(v) Config.SilentSkill = v end })
Aim:Toggle({ Title = "Target Players", Value = true, Callback = function(v) Config.SilentPlayers = v end })
Aim:Toggle({ Title = "Target NPCs", Value = false, Callback = function(v) Config.SilentMobs = v end })
Aim:Toggle({ Title = "Team Check", Value = true, Callback = function(v) Config.SilentTeamCheck = v end })
Aim:Toggle({ Title = "Exclude PvP Off", Value = false, Callback = function(v) Config.SilentExcludePVP = v end })
Aim:Dropdown({
    Title = "Aim Method",
    Values = { "Closest to Mouse", "Closest Player" },
    Value = "Closest to Mouse",
    Callback = function(v) Config.SilentMethod = v end,
})
Aim:Dropdown({
    Title = "Aim Part",
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" },
    Value = "Head",
    Callback = function(v) Config.SilentPart = v end,
})
Aim:Slider({ Title = "FOV Radius", Step = 5, Value = { Min = 20, Max = 800, Default = 150 }, Callback = function(v)
    Config.SilentFOV = v
    if FOVCircle then FOVCircle.Radius = v end
end })
Aim:Toggle({ Title = "Show FOV", Value = false, Callback = function(v) Config.SilentShowFOV = v end })
Aim:Toggle({ Title = "Show Lock Line", Value = false, Callback = function(v) Config.SilentShowLine = v end })
Aim:Dropdown({
    Title = "FOV Position",
    Values = { "Mouse", "Center" },
    Value = "Mouse",
    Callback = function(v) Config.SilentFOVMode = v end,
})
Aim:Paragraph({ Title = "Info", Desc = "M1R redirects mouse hit\nSkill Aimbot redirects skill remotes\nWorks with FOV filter" })

-- MISC
local Misc = Window:Tab({ Title = "Misc", Icon = "settings" })
Misc:Toggle({ Title = "Auto V3", Value = false, Callback = function(v) Config.AutoV3 = v end })
Misc:Toggle({ Title = "Auto V4", Value = false, Callback = function(v) Config.AutoV4 = v end })
Misc:Toggle({ Title = "Auto PvP", Value = false, Callback = function(v) Config.AutoPvP = v end })
Misc:Toggle({ Title = "Auto Flee", Value = false, Callback = function(v)
    Config.AutoFlee = v
    if not v then fleeTeleported = false; RestoreFleeState() end
end })
Misc:Slider({ Title = "Flee HP %", Step = 1, Value = { Min = 5, Max = 80, Default = 30 }, Callback = function(v) Config.AutoFleeHP = v end })
Misc:Toggle({ Title = "Auto Soru", Value = false, Callback = function(v) Config.AutoSoru = v end })
Misc:Toggle({ Title = "Infinite Zoom", Value = false, Callback = function(v)
    Config.InfiniteZoom = v
    lp.CameraMaxZoomDistance = v and math.huge or savedZoom
end })
Misc:Toggle({ Title = "Walk Speed", Value = false, Callback = function(v)
    Config.SpeedEnabled = v
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v and Config.WalkSpeed or 16 end
end })
Misc:Slider({ Title = "Speed Value", Step = 1, Value = { Min = 16, Max = 300, Default = 50 }, Callback = function(v)
    Config.WalkSpeed = v
    if Config.SpeedEnabled then
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end })
Misc:Toggle({ Title = "Jump Power", Value = false, Callback = function(v)
    Config.JumpEnabled = v
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = v and Config.JumpPower or 50 end
end })
Misc:Slider({ Title = "Jump Value", Step = 1, Value = { Min = 50, Max = 500, Default = 50 }, Callback = function(v)
    Config.JumpPower = v
    if Config.JumpEnabled then
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end })
Misc:Toggle({ Title = "Walk on Water", Value = false, Callback = function(v) Config.WalkOnWater = v end })
Misc:Toggle({ Title = "Walk on Lava", Value = false, Callback = function(v) Config.WalkOnLava = v end })

Misc:Paragraph({ Title = "Voldigoad Shop", Desc = "Cyborg / Ghoul / Stats / Race" })
Misc:Button({ Title = "Buy Cyborg Race", Callback = function()
    pcall(function() CommF:InvokeServer("CyborgTrainer", "Buy") end)
    WindUI:Notify({ Title = "Shop", Content = "Cyborg sent", Duration = 2 })
end })
Misc:Button({ Title = "Buy Ghoul Race", Callback = function()
    pcall(function()
        CommF:InvokeServer("Ectoplasm", "BuyCheck", 4)
        CommF:InvokeServer("Ectoplasm", "Change", 4)
    end)
    WindUI:Notify({ Title = "Shop", Content = "Ghoul sent", Duration = 2 })
end })
Misc:Button({ Title = "Reset Player Stats", Callback = function()
    pcall(function() CommF:InvokeServer("BlackbeardReward", "Refund", "2") end)
    WindUI:Notify({ Title = "Shop", Content = "Reset Stats sent", Duration = 2 })
end })
Misc:Button({ Title = "Reroll Race", Callback = function()
    pcall(function() CommF:InvokeServer("BlackbeardReward", "Reroll", "2") end)
    WindUI:Notify({ Title = "Shop", Content = "Reroll Race sent", Duration = 2 })
end })

-- FLAGS
local Flags = Window:Tab({ Title = "Flags", Icon = "flag" })
local flagPaste = ""
Flags:Paragraph({ Title = "Paste FFlags", Desc = "Paste flags (one per line: Name=Value)\nThen press Apply Pasted" })
Flags:Input({
    Title = "Paste Flags Here",
    Placeholder = "DFIntTaskSchedulerTargetFps=999\nDFIntTextureQualityOverride=1",
    Callback = function(text) flagPaste = text or "" end,
})
Flags:Button({ Title = "Apply Pasted Flags", Callback = function()
    local count = 0
    for line in string.gmatch(flagPaste, "[^\r\n]+") do
        local name, value = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
        if name and value and setfflag then
            pcall(function() setfflag(name, value) end)
            count += 1
        end
    end
    WindUI:Notify({ Title = "Flags", Content = "Applied " .. count .. " flags", Duration = 2 })
end })
Flags:Button({ Title = "Apply FPS Flags", Callback = function()
    pcall(function()
        if setfflag then
            setfflag("DFIntTaskSchedulerTargetFps", "999")
            setfflag("DFFlagTextureQualityOverrideEnabled", "True")
            setfflag("DFIntTextureQualityOverride", "1")
        end
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end)
    WindUI:Notify({ Title = "Flags", Content = "FPS flags applied", Duration = 2 })
end })
Flags:Button({ Title = "Apply Network Flags", Callback = function()
    pcall(function()
        if setfflag then
            setfflag("DFIntConnectionMTUSize", "1492")
        end
        if sethiddenproperty then
            sethiddenproperty(lp, "SimulationRadius", 1000)
            sethiddenproperty(lp, "MaxSimulationRadius", 1000)
        end
    end)
    WindUI:Notify({ Title = "Flags", Content = "Network flags applied", Duration = 2 })
end })
Flags:Button({ Title = "Apply All Preset Flags", Callback = function()
    pcall(function()
        if setfflag then
            setfflag("DFIntTaskSchedulerTargetFps", "999")
            setfflag("DFIntTextureQualityOverride", "1")
            setfflag("DFFlagTextureQualityOverrideEnabled", "True")
            setfflag("DFIntConnectionMTUSize", "1492")
        end
        if sethiddenproperty then sethiddenproperty(lp, "SimulationRadius", math.huge) end
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end)
    WindUI:Notify({ Title = "Flags", Content = "All preset flags applied", Duration = 2 })
end })

-- UTILITIES
local Utils = Window:Tab({ Title = "Utilities", Icon = "zap" })
Utils:Toggle({ Title = "FTP2 Tween", Value = false, Callback = function(v)
    Config.FTP2 = v
    if v then StartFTP2() else StopFTP2() end
end })
Utils:Slider({ Title = "Fly Speed", Step = 25, Value = { Min = 50, Max = 600, Default = 275 }, Callback = function(v) Config.FTP2Speed = v end })
Utils:Slider({ Title = "Orbit Radius", Step = 5, Value = { Min = 5, Max = 150, Default = 50 }, Callback = function(v) Config.FTP2OrbitRadius = v end })
Utils:Dropdown({
    Title = "Position Mode",
    Values = { "orbit", "above", "hrp" },
    Value = "orbit",
    Callback = function(v) Config.FTP2Mode = v; FTP2_OrbitOffset = nil end,
})

local Others = Window:Tab({ Title = "Others", Icon = "layers" })
Others:Toggle({ Title = "Dungeon Bypass TP", Value = false, Callback = function(v) Config.BypassTP = v end })
Others:Slider({ Title = "TP Height", Step = 5, Value = { Min = 10, Max = 100, Default = 40 }, Callback = function(v) Config.AttackHeight = v end })

-- VISUALS
local Visuals = Window:Tab({ Title = "Visuals", Icon = "eye" })
Visuals:Paragraph({ Title = "Rich ESP", Desc = "Name / Level / Bounty / Fruit / HP / Distance" })
Visuals:Toggle({ Title = "ESP Enabled", Value = false, Callback = function(v)
    Config.ESP = v
    if not v then clearESP() end
end })
Visuals:Toggle({ Title = "Show Name", Value = true, Callback = function(v) Config.ESP_Name = v end })
Visuals:Toggle({ Title = "Show Level", Value = true, Callback = function(v) Config.ESP_Level = v end })
Visuals:Toggle({ Title = "Show Bounty", Value = true, Callback = function(v) Config.ESP_Bounty = v end })
Visuals:Toggle({ Title = "Show Fruit", Value = true, Callback = function(v) Config.ESP_Fruit = v end })
Visuals:Toggle({ Title = "Show Distance", Value = true, Callback = function(v) Config.ESP_Distance = v end })
Visuals:Toggle({ Title = "Show HP", Value = true, Callback = function(v) Config.ESP_HP = v end })
Visuals:Toggle({ Title = "Highlight", Value = false, Callback = function(v) Config.ESP_Highlight = v end })
Visuals:Slider({ Title = "Text Size", Step = 1, Value = { Min = 10, Max = 22, Default = 13 }, Callback = function(v) Config.ESP_TextSize = v end })

Visuals:Paragraph({ Title = "Skin Changer", Desc = "Colors Fruit / Melee / Sword / Gun only" })
Visuals:Toggle({ Title = "Enable Skin Changer", Value = false, Callback = function(v) Config.SkinEnabled = v end })
Visuals:Toggle({ Title = "RGB Cycle", Value = false, Callback = function(v)
    Config.SkinRGB = v
    if v and not Config.SkinEnabled then Config.SkinEnabled = true end
end })
Visuals:Slider({ Title = "Color Strength", Step = 5, Value = { Min = 0, Max = 100, Default = 100 }, Callback = function(v) Config.SkinStrength = v end })
pcall(function()
    Visuals:Colorpicker({
        Title = "Preset Color",
        Default = Color3.fromRGB(160, 70, 255),
        Callback = function(c) Config.SkinColor = c end,
    })
end)

WindUI:Notify({ Title = "Michelle Hub", Content = "v6 loaded — Aim / Flee / Soru / ESP", Duration = 3 })
print("✅ Michelle Hub v6 EN")
