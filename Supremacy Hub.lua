--==============================================================
-- 👑 XIMENA HUB ❤️  |  by Tommy
-- Auto Bounty + Fruit M1 Void + Fast Attack
--==============================================================
repeat task.wait() until game:IsLoaded()

--==================== WINDUI ====================
local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not ok then warn("WindUI failed to load") return end

--==================== SERVICIOS ====================
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local Run     = game:GetService("RunService")
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

Camera    = workspace.CurrentCamera
Lighting  = game:GetService("Lighting")
Stats     = game:GetService("Stats")
playerGui = lp:FindFirstChild("PlayerGui")

local Modules = RS:WaitForChild("Modules", 10)
local Net     = Modules and Modules:WaitForChild("Net", 10)
local Remotes = RS:WaitForChild("Remotes", 10)
local CommF   = Remotes and Remotes:WaitForChild("CommF_", 10)
local RegisterAttack = Net and Net:WaitForChild("RE/RegisterAttack", 10)
local RegisterHit    = Net and Net:WaitForChild("RE/RegisterHit", 10)
local RemoteSeed     = Net and Net:FindFirstChild("seed")

--==================== ESTADO ====================
getgenv().AttackEnabled  = false
getgenv().AttackRange    = 1000
getgenv().SelectedPlayer = nil

_G.G_FruitM1              = _G.G_FruitM1              or false
_G.G_VoidFruitM1          = _G.G_VoidFruitM1          or true
_G.G_AttackPlayers        = _G.G_AttackPlayers        or true
_G.G_AttackMobs           = _G.G_AttackMobs           or false
_G.G_FastAttack           = _G.G_FastAttack           or false
_G.G_FruitM1TurboMode     = _G.G_FruitM1TurboMode     or false
_G.G_FruitM1Speed         = _G.G_FruitM1Speed         or 0.02
_G.G_FruitM1ComboSpeed    = _G.G_FruitM1ComboSpeed    or 0.05
_G.G_AutoLagSwitch        = _G.G_AutoLagSwitch        or true
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

_G.G_AutoFollowEnabled    = _G.G_AutoFollowEnabled    ~= false
_G.G_AutoFollowDistance   = _G.G_AutoFollowDistance   or 6
_G.G_AutoFollowHeight     = _G.G_AutoFollowHeight     or 5
_G.G_AutoFollowRate       = _G.G_AutoFollowRate       or 0.05

--==================== SAFE ZONE ====================
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
local LagSwitch = { lastPos = nil, lastPosCheck = 0, desyncCount = 0, currentMultiplier = 1.0 }

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

--==================== FRUIT M1 ENGINE (TU CÓDIGO) ====================
local FruitM1 = { maxVec = Vector3.new(9e30, 9e30, 9e30), on = false, conn = nil, clickConn = nil }

function FruitM1.GetFruit()
    local char = lp.Character
    if not char then return nil end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == "Blox Fruit" then return tool end
    end
    local backpack = lp:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == "Blox Fruit" then return tool end
        end
    end
    return nil
end

function FruitM1.GetInterval(tool)
    if not tool then return 0.1 end
    local char = lp.Character
    if not char then return 0.1 end
    local base
    pcall(function()
        local gui = lp:FindFirstChild("PlayerGui")
        local container = gui and gui:FindFirstChild("MovesetModules")
        local mod = container and container:FindFirstChild(tool.Name)
        local agg = mod and mod:FindFirstChild("LegacyDataAggregate")
        local data = agg and require(agg)
        if type(data) ~= "table" then return end
        local cd
        local aw = tool:FindFirstChild("AwakenedMoves")
        if aw and aw:FindFirstChild("TAP") and type(data.Awakening) == "table" and type(data.Awakening.Cooldown) == "table" then
            cd = data.Awakening.Cooldown.TAP
        elseif type(data.Cooldown) == "table" then
            cd = data.Cooldown.TAP
        end
        if type(cd) == "function" then cd = cd(tool) end
        if type(cd) == "number" then base = cd end
    end)
    if type(base) ~= "number" then return 0.1 end
    local tip = tool.ToolTip
    if tip == "Blox Fruit" then tip = "Fruit" end
    local tapCd = char:GetAttribute(tip .. "TAPCooldown") or 0
    local nsuns = lp:GetAttribute("NSUNS")
    local speed = (1 - tapCd) * (nsuns and 0 or 1)
    return base * speed * 1.5
end

function FruitM1.IsTrex(tool) return tool ~= nil and tool.Name == "T-Rex-T-Rex" end
function FruitM1.IsTransformed(tool)
    local rig = tool and tool:FindFirstChild("TransformedRigObject")
    return rig ~= nil and rig.Value ~= nil
end
function FruitM1.IsDragon(tool)  return tool ~= nil and tool.Name == "Dragon-Dragon" end
function FruitM1.IsBlade(tool)   return tool ~= nil and tool.Name == "Blade-Blade" end
function FruitM1.IsPain(tool)    return tool ~= nil and tool.Name == "Pain-Pain" end
function FruitM1.IsControl(tool) return tool ~= nil and tool.Name == "Control-Control" end
function FruitM1.IsGas(tool)     return tool ~= nil and tool.Name == "Gas-Gas" end

function FruitM1.MaxCombo(tool)
    if FruitM1.IsTrex(tool) then return 4 end
    if FruitM1.IsBlade(tool) then return 2 end
    if FruitM1.IsPain(tool) then return 4 end
    if FruitM1.IsControl(tool) then return 4 end
    if FruitM1.IsGas(tool) then return 5 end
    if FruitM1.IsDragon(tool) then
        local char = lp.Character
        return (char and char:FindFirstChild("DragonHybrid")) and 5 or 3
    end
    return 5
end

function FruitM1.ScanTapFn(tool, fn)
    local comboIdx, nextIdx, timerIdx, hasTool, stateTable
    for n = 1, 30 do
        local ok2, v = pcall(debug.getupvalue, fn, n)
        if not ok2 then break end
        if v == tool then hasTool = true end
        if type(v) == "number" then
            if not comboIdx and v >= 1 and v <= 5 and v == math.floor(v) then comboIdx = n
            elseif not nextIdx and v > 1 then nextIdx = n end
        elseif type(v) == "thread" and not timerIdx then timerIdx = n
        elseif type(v) == "table" and not stateTable then
            local ok3, ability = pcall(function() return v.thisAbility end)
            if ok3 and type(ability) == "number" and type(v.lastUseTime) == "number" then stateTable = v end
        end
    end
    if stateTable then return { tbl = stateTable, fn = fn } end
    if hasTool and comboIdx and nextIdx and timerIdx then
        return { fn = fn, combo = comboIdx, next = nextIdx, timer = timerIdx }
    end
    return nil
end

function FruitM1.GetTapState(tool)
    local ok, conns = pcall(getconnections, tool.Activated)
    if not ok or type(conns) ~= "table" then return nil end
    for _, c in ipairs(conns) do
        local fn = c.Function
        if fn then
            local st = FruitM1.ScanTapFn(tool, fn)
            if st then return st end
            for n = 1, 8 do
                local ok2, v = pcall(debug.getupvalue, fn, n)
                if not ok2 then break end
                if type(v) == "function" then
                    st = FruitM1.ScanTapFn(tool, v)
                    if st then return st end
                end
            end
        end
    end
    return nil
end

function FruitM1.TapInterval(combo, maxCombo)
    if _G.G_VoidFruitM1 and combo and maxCombo and combo >= maxCombo then return 1 end
    local char = lp.Character
    local cd = 0
    if char then cd = char:GetAttribute("FruitTAPCooldown") or 0 end
    return 0.2 - cd
end

function FruitM1.Effect(tool, index, dir)
    if not tool then return end
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if FruitM1.IsGas(tool) then
        task.defer(function()
            pcall(function()
                local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
                local container = game.ReplicatedStorage:FindFirstChild("EffectContainer")
                local gas = container and container:FindFirstChild("Gas")
                local name = char:FindFirstChild("GasRig") and "Transformed" or nil
                local folder = name and gas:FindFirstChild(name) or gas
                local tmpl = folder and folder:FindFirstChild("M1")
                Effect.new(tmpl):play({
                    Character = char, Index = index or 1,
                    CFrame = CFrame.new(Vector3.new(0, 0, 0), dir or hrp.CFrame.LookVector) + hrp.Position,
                })
            end)
        end)
        return
    end
    if FruitM1.IsControl(tool) then
        task.delay(0.05, function()
            pcall(function()
                local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
                local container = game.ReplicatedStorage:FindFirstChild("EffectContainer")
                local cr = container and container:FindFirstChild("ControlRework")
                local m1 = cr and cr:FindFirstChild("M1")
                local tmpl = m1 and m1:FindFirstChild("Dagger_Outside")
                Effect.new(tmpl):play({
                    Origin = hrp.Position, Player = lp,
                    Combo = index or 1, Character = char, Root = hrp,
                })
            end)
        end)
        return
    end
    if FruitM1.IsPain(tool) then
        task.delay(0.08, function()
            pcall(function()
                local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
                local container = game.ReplicatedStorage:FindFirstChild("EffectContainer")
                local pain = container and container:FindFirstChild("Pain")
                local name = char:FindFirstChild("PainTransformed") and "M1_Awakened" or "M1"
                local tmpl = pain and pain:FindFirstChild(name)
                Effect.new(tmpl):play({
                    origin = hrp.Position, player = lp,
                    Combo = index or 1, Character = char, Root = hrp,
                })
            end)
        end)
        return
    end
    if FruitM1.IsBlade(tool) then
        task.delay(0.1, function()
            pcall(function()
                local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
                local container = game.ReplicatedStorage:FindFirstChild("EffectContainer")
                local blade = container and container:FindFirstChild("Blade")
                local tmpl = blade and blade:FindFirstChild("M1")
                Effect.new(tmpl):replicate({
                    Root = hrp, Combo = index or 1,
                    CFrame = CFrame.new(Vector3.new(0, 0, 0), dir or hrp.CFrame.LookVector) + hrp.Position,
                    player = lp,
                })
            end)
        end)
        return
    end
    if FruitM1.IsDragon(tool) then
        task.delay(0.1, function()
            pcall(function()
                local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
                local container = game.ReplicatedStorage:FindFirstChild("EffectContainer")
                local dragon2 = container and container:FindFirstChild("Dragon2")
                local tmpl = dragon2 and dragon2:FindFirstChild("M1")
                Effect.new(tmpl):replicate({
                    player = lp, Root = hrp, Combo = index or 1,
                    MaxCombo = FruitM1.MaxCombo(tool),
                    Hybrid = char:FindFirstChild("DragonHybrid") ~= nil,
                    CFrame = CFrame.new(Vector3.new(0, 0, 0), dir or hrp.CFrame.LookVector) + hrp.Position,
                })
            end)
        end)
        return
    end
    if FruitM1.IsTrex(tool) then
        local path = "Dino." .. (FruitM1.IsTransformed(tool) and "Transformed." or "") .. "TAP"
        task.delay(0.1, function()
            pcall(function()
                local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
                Effect.new(Effect.getModule(path)):play({
                    Character = char, ID = index or 1, player = lp,
                })
            end)
        end)
        return
    end
    local fruit = tool.Name:match("^([^%-]+)")
    local container = game.ReplicatedStorage:FindFirstChild("EffectContainer")
    local folder = container and fruit and container:FindFirstChild(fruit)
    local template = folder and folder:FindFirstChild("M1Combo")
    if not template then return end
    local filter = { char }
    for _, childName in ipairs({ "_WorldOrigin", "Characters", "Enemies" }) do
        local child = workspace:FindFirstChild(childName)
        if child then table.insert(filter, child) end
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = filter
    local onGround = workspace:Raycast(hrp.Position, -(hum.HipHeight + hrp.Size.Y * 0.5 + 4) * Vector3.new(0, 1, 0), params) ~= nil
    local transformed = false
    local flag = tool:FindFirstChild("IsTransformed")
    if flag then transformed = flag.Value end
    task.delay(0.1, function()
        pcall(function()
            local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
            Effect.new(template):replicate({
                player = lp, hrp = hrp, index = index or 1,
                playerOnGround = onGround, transformed = transformed,
            })
        end)
    end)
end

-- 🔥 FIX: SOLO usa canAttackPlayer (con SafeZone + Lvl 2200+)
function FruitM1.SetNormal(enabled)
    FruitM1.on = enabled
    if enabled then
        if FruitM1.conn then task.cancel(FruitM1.conn) end
        if FruitM1.clickConn then task.cancel(FruitM1.clickConn) end
        FruitM1.clickConn = task.spawn(function()
            local vu = game:GetService("VirtualUser")
            while FruitM1.on do
                pcall(function() vu:Button1Down(Vector2.new(1280, 672)) end)
                task.wait(5)
            end
        end)
        FruitM1.conn = task.spawn(function()
            task.wait(2)
            while FruitM1.on do
                local fruit = FruitM1.GetFruit()
                local char = lp.Character
                local myHRP = char and char:FindFirstChild("HumanoidRootPart")
                local remote = fruit and fruit:FindFirstChild("LeftClickRemote")
                if not fruit or not remote or not myHRP then task.wait(0.1) continue end

                -- 🔒 Forzar equip
                local currentTool = char:FindFirstChildOfClass("Tool")
                if currentTool ~= fruit then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and fruit.Parent ~= char then
                        pcall(function() hum:EquipTool(fruit) end)
                        task.wait(0.05)
                    end
                end

                if FruitM1.tapTool ~= fruit or (not FruitM1.tapState and tick() - (FruitM1.tapAt or 0) > 1) then
                    FruitM1.tapTool = fruit
                    FruitM1.tapAt = tick()
                    FruitM1.tapState = FruitM1.GetTapState(fruit)
                end
                local st = FruitM1.tapState
                local combo, nextT
                if st then
                    if st.tbl then
                        if type(st.tbl.thisAbility) == "number" then combo = st.tbl.thisAbility end
                        if type(st.tbl.lastUseTime) == "number" then nextT = st.tbl.lastUseTime end
                    else
                        local ok1, c = pcall(debug.getupvalue, st.fn, st.combo)
                        local ok2, n = pcall(debug.getupvalue, st.fn, st.next)
                        if ok1 and type(c) == "number" then combo = c end
                        if ok2 and type(n) == "number" then nextT = n end
                    end
                end
                if not combo or not nextT then
                    if tick() - (FruitM1.fbAt or 0) > 1 then FruitM1.fbCombo = 1 end
                    combo = FruitM1.fbCombo or 1
                    nextT = 0
                end
                local stun = char:FindFirstChild("Stun")
                local busy = char:FindFirstChild("Busy")
                local isTrex   = FruitM1.IsTrex(fruit)
                local isDragon = FruitM1.IsDragon(fruit)
                local isBlade  = FruitM1.IsBlade(fruit)
                local isGas    = FruitM1.IsGas(fruit)
                local dragonRig = isDragon and (char:FindFirstChild("EasternBloxfruitsDragon") or char:FindFirstChild("WesternDragonRig"))
                local blocked = (stun and stun.Value > 0) or (busy and busy.Value) or dragonRig
                local range = _G.G_AutoBountyRange or 500
                local hit = false
                if combo and nextT and not blocked and time() >= nextT then
                    local maxCombo = _G.G_VoidFruitM1 and FruitM1.MaxCombo(fruit) or (FruitM1.MaxCombo(fruit) - 1)
                    if maxCombo < 1 then maxCombo = 1 end
                    if st and combo > maxCombo then
                        combo = maxCombo
                        if st.tbl then st.tbl.thisAbility = combo
                        else pcall(debug.setupvalue, st.fn, st.combo, combo) end
                    end
                    local bestHRP, bestDist
                    -- ✅ Solo Players con filtros
                    if _G.G_AttackPlayers then
                        for _, player in pairs(Players:GetPlayers()) do
                            if canAttackPlayer(player) then
                                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                                if targetHRP then
                                    local dist = (targetHRP.Position - myHRP.Position).Magnitude
                                    if dist < range and (not bestDist or dist < bestDist) then
                                        bestHRP, bestDist = targetHRP, dist
                                    end
                                end
                            end
                        end
                    end
                    -- Mobs (desactivado por default)
                    if _G.G_AttackMobs then
                        local enemiesFolder = workspace:FindFirstChild("Enemies")
                        if enemiesFolder then
                            for _, npc in pairs(enemiesFolder:GetChildren()) do
                                local targetHRP = npc:FindFirstChild("HumanoidRootPart")
                                local hum       = npc:FindFirstChild("Humanoid")
                                if targetHRP and hum and hum.Health > 0 then
                                    local dist = (targetHRP.Position - myHRP.Position).Magnitude
                                    if dist < range and (not bestDist or dist < bestDist) then
                                        bestHRP, bestDist = targetHRP, dist
                                    end
                                end
                            end
                        end
                    end
                    if bestHRP then
                        local dir = ((bestHRP.Position - myHRP.Position) * Vector3.new(1, 0, 1)).Unit
                        local fireDir = (_G.G_VoidFruitM1 and combo >= maxCombo) and FruitM1.maxVec or dir
                        if isTrex or isDragon or isBlade or isGas then
                            pcall(function() remote:FireServer(fireDir, combo) end)
                        else
                            pcall(function() remote:FireServer(fireDir, combo, true) end)
                        end
                        if st then
                            local nextCombo = combo < maxCombo and combo + 1 or 1
                            local nextTime = time() + FruitM1.TapInterval(combo, maxCombo)
                            if st.tbl then
                                st.tbl.thisAbility = nextCombo
                                st.tbl.lastUseTime = nextTime
                                if st.tbl.prevTask then pcall(task.cancel, st.tbl.prevTask) end
                                st.tbl.prevTask = task.delay(1, function() st.tbl.thisAbility = 1 end)
                            else
                                pcall(debug.setupvalue, st.fn, st.combo, nextCombo)
                                pcall(debug.setupvalue, st.fn, st.next, nextTime)
                                local okT, timer = pcall(debug.getupvalue, st.fn, st.timer)
                                if okT and timer then pcall(task.cancel, timer) end
                                pcall(debug.setupvalue, st.fn, st.timer, task.delay(1, function()
                                    pcall(debug.setupvalue, st.fn, st.combo, 1)
                                end))
                            end
                        else
                            FruitM1.fbCombo = combo < maxCombo and combo + 1 or 1
                            FruitM1.fbAt = tick()
                        end
                        FruitM1.Effect(fruit, combo, dir)
                        hit = true
                    end
                end
                if hit then
                    if st then
                        task.wait(_G.G_FastAttack and 0.025 or 0.05)
                    else
                        local w = FruitM1.TapInterval(combo, FruitM1.MaxCombo(fruit))
                        if w < 0 then w = 0 end
                        if _G.G_FastAttack then w = w * 0.5 end
                        task.wait(w)
                    end
                else
                    task.wait(_G.G_FastAttack and 0.05 or 0.1)
                end
            end
        end)
    else
        if FruitM1.conn then task.cancel(FruitM1.conn); FruitM1.conn = nil end
        if FruitM1.clickConn then task.cancel(FruitM1.clickConn); FruitM1.clickConn = nil end
    end
end

if _G.G_FruitM1 then
    task.defer(function() FruitM1.SetNormal(true) end)
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
            _G.AB_SafeZoneCount or 0, _G.AB_LowLevelCount or 0, _G.AB_ValidCount or 0
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

--==================== SAFE ZONE VISUAL ====================
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
    Title = "✅ SafeZone Check",
    Value = _G.G_AutoBountySafeCheck,
    Callback = function(v) _G.G_AutoBountySafeCheck = v end
})

TabBounty:Toggle({
    Title = "Team Check",
    Value = _G.G_AutoBountyTeamCheck,
    Callback = function(v) _G.G_AutoBountyTeamCheck = v end
})

TabBounty:Slider({
    Title = "Attack Range",
    Value = { Min = 500, Max = 15000, Default = 5000 },
    Callback = function(v) _G.G_AutoBountyRange = v end
})

TabBounty:Button({
    Title = "🔍 Ver SafeZones detectadas",
    Callback = function()
        scanSafeZones()
        WindUI:Notify({
            Title = "SafeZones",
            Content = string.format("Detectadas: %d", #SafeZoneCache.zones),
            Duration = 4
        })
    end
})

TabBounty:Toggle({
    Title = "🔍 Ver SafeZones (debug)",
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
    Title = "⚡ Fast Attack",
    Value = _G.G_FastAttack,
    Callback = function(v) _G.G_FastAttack = v end
})

TabBounty:Toggle({
    Title = "🚀 Turbo Mode",
    Value = _G.G_FruitM1TurboMode,
    Callback = function(v) _G.G_FruitM1TurboMode = v end
})

TabBounty:Toggle({
    Title = "🛡️ Auto-Lag Switch",
    Value = _G.G_AutoLagSwitch,
    Callback = function(v) _G.G_AutoLagSwitch = v end
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
    Title = "🎯 Auto Follow",
    Value = true,
    Callback = function(v) _G.G_AutoFollowEnabled = v end
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
        Content = "by Tommy • Fruit M1 Void + Auto Bounty cargado",
        Duration = 5
    })
    sendWebhook("EJECUTADO")
    print("👑 Ximena Hub ❤️ by Tommy cargado")
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
