--==============================================================
-- WINDUI INTERFAZ MEJORADA (Tommy Hub 67 v2)
--==============================================================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then warn("❌ No se pudo cargar WindUI") return end

-- Paleta de colores personalizada
local ACCENT = Color3.fromRGB(140, 90, 255)
local ACCENT_DARK = Color3.fromRGB(90, 55, 180)

-- Crear ventana principal con estilo mejorado
local Window = WindUI:CreateWindow({
    Title = "Tommy Hub 67",
    Icon = "rbxassetid://10734950309",
    Author = "@accountxz  •  Blox Fruits  •  v2.0",
    Folder = "TommyHub67",
    Size = UDim2.fromOffset(640, 480),
    Transparent = true,
    Theme = "Dark",
    User = { Enabled = true, Anonymous = true },
    SideBarWidth = 190,
    HasOutline = true,
    Resizable = false,
})

-- Notificación de bienvenida más elegante
Window:Notification({
    Title = "👑 Tommy Hub 67",
    Content = "Cargado correctamente · " .. tostring(math.floor(tick() % 1000)) .. "ms",
    Duration = 6,
    Icon = "check-circle",
})

-- Actualizar el ping/estado cada 2 segundos
task.spawn(function()
    while true do
        task.wait(2)
        local ping = 0
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        pcall(function()
            Window:SetTitle("Tommy Hub 67  ·  " .. ping .. "ms")
        end)
    end
end)

-- Helper: sección siempre abierta
local function Section(tab, title)
    local s
    pcall(function() s = tab:Section({Title = title, Opened = true}) end)
    if not s then pcall(function() s = tab:Section({Title = title, Collapsed = false}) end) end
    if not s then pcall(function() s = tab:Section(title) end) end
    return s
end

--==================== TAB: COMBAT ====================
local CombatTab = Window:Tab({Title = "Combat", Icon = "sword", Locked = false})

local S1 = Section(CombatTab, "⚔ Silent Aim (Skills)")
S1:Toggle({Title = "Silent Aim (Skills)", Desc = "Redirige los remotes sin mover la cámara.", Default = false, Callback = function(state) S.SkillAimbot = state end})
S1:Toggle({Title = "Aimbot M1 (Dragon Gun) ⚠ BAN", Default = false, Callback = function(state) S.DragonM1 = state end})
S1:Toggle({Title = "Target Players", Default = true, Callback = function(state) S.TargetPlayers = state end})
S1:Toggle({Title = "Target NPCs", Default = false, Callback = function(state) S.TargetMobs = state end})
S1:Toggle({Title = "Team Check", Default = false, Callback = function(state) S.TeamCheck = state end})
S1:Toggle({Title = "Ignore PvP OFF", Default = true, Callback = function(state) S.PvPCheck = state end})
S1:Toggle({Title = "Rainbow Target ESP", Default = false, Callback = function(state) S.Rainbow = state end})
S1:Slider({Title = "Max Dist", Min = 100, Max = 5000, Default = 2500, Rounding = 0, Callback = function(value) S.MaxDist = value end})

local S2 = Section(CombatTab, "🎯 Aimbot 67 Descarado")
S2:Toggle({Title = "▶ Aimbot 67 Descarado", Desc = "Mueve la cámara con predicción.", Default = false, Callback = function(state) S.A67_Enabled = state end})
S2:Toggle({Title = "Atacar NPCs", Default = true, Callback = function(state) S.A67_TargetNPC = state end})
S2:Toggle({Title = "Atacar Players", Default = false, Callback = function(state) S.A67_TargetPlayer = state end})
S2:Toggle({Title = "Mostrar Marcador", Default = true, Callback = function(state) S.A67_ShowMarker = state end})
S2:Slider({Title = "Predicción", Min = 0, Max = 1, Default = 0.15, Rounding = 2, Callback = function(value) S.A67_Prediction = value end})
S2:Slider({Title = "Distancia Máx", Min = 100, Max = 5000, Default = 1500, Rounding = 0, Callback = function(value) S.A67_MaxDist = value end})

local S3 = Section(CombatTab, "🥊 Combate")
S3:Toggle({Title = "Fast Attack", Default = false, Callback = function(state) S.FastAttack = state; if state then startFastAttack() end end})
S3:Toggle({Title = "Anti Stun + Hitbox [Beta]", Default = false, Callback = function(state) setAntiStun(state) end})
S3:Toggle({Title = "Auto Race V4", Default = false, Callback = function(state) S.AutoV4 = state end})

local S4 = Section(CombatTab, "🏃 Movimiento")
S4:Toggle({Title = "Walk Speed", Default = false, Callback = function(state) S.WalkSpeed = state end})
S4:Slider({Title = "Speed", Min = 16, Max = 300, Default = 50, Callback = function(value) S.Speed = value end})
S4:Toggle({Title = "Dash Distance", Default = false, Callback = function(state) S.Dash = state; if state then applyDash(S.DashLen) else applyDash(1) end end})
S4:Slider({Title = "Dash", Min = 1, Max = 300, Default = 50, Callback = function(value) S.DashLen = value; if S.Dash then applyDash(value) end end})
S4:Toggle({Title = "Noclip", Default = false, Callback = function(state)
    S.Noclip = state
    if not state and player.Character then
        for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    end
end})
S4:Toggle({Title = "Walk on Water", Default = false, Callback = function(state) S.WaterWalk = state end})

--==================== TAB: GLITCHES ====================
local GlitchTab = Window:Tab({Title = "Glitches", Icon = "sparkles"})

local G1 = Section(GlitchTab, "🩸 Sanguine Z")
G1:Toggle({Title = "Sanguine Z No Cooldown", Default = false, Callback = function(state)
    S.SangNoCD = state
    local c = player.Character
    if c then c:SetAttribute("AllCooldown", state and 3 or nil) end
end})
G1:Button({Title = "🩸 Sanguine Z Manual", Callback = function() sangManual() end})
G1:Toggle({Title = "Sanguine Z Auto", Default = false, Callback = function(state)
    S.SangAuto = state
    if state then startSangAuto() elseif sangConn then sangConn:Disconnect(); sangConn = nil end
end})
G1:Slider({Title = "Drop Duration", Min = 0.5, Max = 5, Default = 2, Rounding = 1, Callback = function(value) S.SangDrop = value end})

local G2 = Section(GlitchTab, "🎩 Trucos")
G2:Toggle({Title = "No Animations", Default = false, Callback = function(state) S.NoAnim = state end})
G2:Toggle({Title = "Super Jump (botón de salto)", Default = false, Callback = function(state) S.SuperJump = state end})
G2:Slider({Title = "Jump Power", Min = 50, Max = 1000, Default = 500, Callback = function(value) S.JumpPower = value end})
G2:Toggle({Title = "Soul Guitar Glitch (Beta)", Default = false, Callback = function(state) S.SoulGuitar = state end})
G2:Slider({Title = "Soul Dash", Min = 1, Max = 300, Default = 121, Callback = function(value) S.SoulDash = value end})
G2:Toggle({Title = "Anti Lava", Default = false, Callback = function(state) S.AntiLava = state end})
G2:Toggle({Title = "Delete Ghost Ship (Sea 2)", Default = false, Callback = function(state) S.DelShip = state end})

--==================== TAB: SORU ====================
local SoruTab = Window:Tab({Title = "Soru", Icon = "zap"})

local SR1 = Section(SoruTab, "⚡ Soru")
SR1:Toggle({Title = "Infinite Soru", Default = false, Callback = function(state)
    S.InfSoru = state
    if player.Character then attachInfSoru(player.Character) end
end})
SR1:Toggle({Title = "Soru Aimbot (TP)", Default = false, Callback = function(state) S.SoruAimbot = state end})
SR1:Slider({Title = "Soru Dist", Min = 100, Max = 3500, Default = 1000, Callback = function(value) S.SoruDist = value end})
SR1:Dropdown({Title = "Soru Target", Values = {"Nearest"}, Default = 1, Callback = function(option) S.SoruTarget = option end})

local SR2 = Section(SoruTab, "🔥 Combos")
SR2:Toggle({Title = "Portal Soru Combo (X+Z)", Default = false, Callback = function(state) S.PortalSoru = state end})
SR2:Slider({Title = "Portal Soru Delay", Min = 0.05, Max = 2, Default = 0.35, Rounding = 2, Callback = function(value) S.PortalSoruDelay = value end})
SR2:Toggle({Title = "Portal Sanguine C Combo", Default = false, Callback = function(state) S.PortalSangC = state end})
SR2:Slider({Title = "Sanguine C Delay", Min = 0.05, Max = 2, Default = 0.35, Rounding = 2, Callback = function(value) S.PortalSangCDelay = value end})
SR2:Dropdown({Title = "Trigger", Values = {"PortalF", "Soru"}, Default = 1, Callback = function(option) S.PortalSangCTrigger = option end})
SR2:Toggle({Title = "Flashstep Skill Combo", Default = false, Callback = function(state) S.FlashCombo = state end})
SR2:Dropdown({Title = "Arma", Values = {"Melee", "Fruit", "Sword", "Gun"}, Default = 2, Callback = function(option) S.FlashWeapon = option end})
SR2:Dropdown({Title = "Skill Key", Values = {"Z", "X", "C", "V", "F"}, Default = 1, Callback = function(option) S.FlashKey = option end})
SR2:Slider({Title = "Skill Delay", Min = 0.05, Max = 2, Default = 0.3, Rounding = 2, Callback = function(value) S.FlashDelay = value end})

--==================== TAB: ESP ====================
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})

local E1 = Section(ESPTab, "👁 ESP & Visuals")
E1:Toggle({Title = "ESP (General)", Default = false, Callback = function(state)
    S.ESP = state
    if not state then for p in pairs(esp) do clearESP(p) end end
end})
E1:Toggle({Title = "Show Name", Default = true, Callback = function(state) S.ESPName = state end})
E1:Toggle({Title = "Show Level", Default = true, Callback = function(state) S.ESPLevel = state end})
E1:Toggle({Title = "Show Bounty / PvP", Default = true, Callback = function(state) S.ESPBounty = state end})
E1:Toggle({Title = "Show Devil Fruit", Default = true, Callback = function(state) S.ESPFruit = state end})
E1:Toggle({Title = "Show Distance", Default = true, Callback = function(state) S.ESPDist = state end})
E1:Toggle({Title = "Show HP %", Default = true, Callback = function(state) S.ESPHP = state end})
E1:Toggle({Title = "Highlight Players", Default = false, Callback = function(state) S.ESPHighlight = state end})
E1:Slider({Title = "Text Size", Min = 8, Max = 32, Default = 12, Rounding = 0, Callback = function(value) S.ESPSize = value end})

--==================== TAB: DUNGEONS ====================
local DungeonTab = Window:Tab({Title = "Dungeons", Icon = "castle"})

local D1 = Section(DungeonTab, "🏰 Auto Dungeon")
D1:Toggle({Title = "▶ Auto Dungeon (Start/Stop)", Default = false, Callback = function(state) S.AutoDungeon = state; dgSet(state) end})
D1:Dropdown({Title = "Arma", Values = {"Sword", "Melee", "Blox Fruit"}, Default = 1, Callback = function(option) S.DungeonWeapon = option end})
D1:Slider({Title = "Altura de ataque", Min = 10, Max = 100, Default = 40, Rounding = 0, Callback = function(value) S.DungeonHeight = value end})
D1:Toggle({Title = "Auto V4 (tecla Y)", Default = false, Callback = function(state) S.DungeonV4 = state end})

--==================== TAB: MISC ====================
local MiscTab = Window:Tab({Title = "Misc", Icon = "settings"})

local M1 = Section(MiscTab, "⚙ Config")

local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "TommyHub67_Config.json"

local function saveConfig()
    if not writefile then return false end
    local conf = {}
    for k, v in pairs(S) do if k ~= "SoruTarget" then conf[k] = v end end
    return pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(conf)) end)
end
local function loadConfig()
    if not (isfile and readfile and isfile(CONFIG_FILE)) then return false end
    local ok, conf = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
    if not ok or type(conf) ~= "table" then return false end
    for k, v in pairs(conf) do
        if k ~= "SoruTarget" and S[k] ~= nil and type(v) == type(S[k]) then S[k] = v end
    end
    return true
end

M1:Button({Title = "💾 Guardar Config", Callback = function()
    local ok = saveConfig()
    Window:Notification({Title = "Config", Content = ok and "✅ Guardado" or "❌ Error", Duration = 3})
end})
M1:Button({Title = "📂 Cargar Config", Callback = function()
    local ok = loadConfig()
    Window:Notification({Title = "Config", Content = ok and "✅ Cargado" or "❌ No hay config", Duration = 3})
end})

--==================== TAB: INTERFAZ ====================
local UITab = Window:Tab({Title = "Interfaz", Icon = "palette"})

local U1 = Section(UITab, "🎨 Tema Predefinido")
U1:Dropdown({
    Title = "Tema de Interfaz",
    Values = {"Dark", "Light", "Rose", "Pro", "Aqua", "Mint", "Sunset", "Violet", "Crimson", "Blood"},
    Default = 1,
    Callback = function(option) pcall(function() Window:SetTheme(option) end) end,
})

local U2 = Section(UITab, "🎨 Colores Personalizados")
U2:Colorpicker({
    Title = "Color de Acento",
    Default = ACCENT,
    Transparency = false,
    Callback = function(color)
        pcall(function()
            ACCENT = color
            Window:SetTheme("Dark")
            if Window.Frame then
                for _, v in ipairs(Window.Frame:GetDescendants()) do
                    pcall(function()
                        if v:IsA("Frame") and v.BackgroundColor3 ~= Color3.new() then
                            local n = v.Name:lower()
                            if n:find("accent") or n:find("toggle") or n:find("fill") or n:find("selected") then
                                v.BackgroundColor3 = color
                            end
                        elseif v:IsA("UIStroke") then
                            local n = v.Name:lower()
                            if n:find("accent") or n:find("outline") then v.Color = color end
                        end
                    end)
                end
            end
        end)
    end,
})

U2:Colorpicker({
    Title = "Color de Fondo",
    Default = Color3.fromRGB(15, 15, 22),
    Transparency = false,
    Callback = function(color)
        pcall(function()
            if Window.Frame then
                for _, v in ipairs(Window.Frame:GetDescendants()) do
                    pcall(function()
                        if v:IsA("Frame") and v.Name:lower():find("background") then v.BackgroundColor3 = color end
                    end)
                end
            end
        end)
    end,
})

U2:Colorpicker({
    Title = "Color de Texto",
    Default = Color3.fromRGB(240, 240, 250),
    Transparency = false,
    Callback = function(color)
        pcall(function()
            if Window.Frame then
                for _, v in ipairs(Window.Frame:GetDescendants()) do
                    pcall(function()
                        if v:IsA("TextLabel") then v.TextColor3 = color end
                    end)
                end
            end
        end)
    end,
})

local U3 = Section(UITab, "🎛 Transparencia")
U3:Slider({
    Title = "Transparencia de Ventana",
    Min = 0, Max = 100, Default = 0, Rounding = 0,
    Callback = function(value)
        pcall(function()
            if Window.Frame then Window.Frame.BackgroundTransparency = value / 100 end
        end)
    end,
})

--==================== HOTKEY INFO ====================
Window:Notification({
    Title = "⌨ Atajo",
    Content = "Presiona F4 para mostrar/ocultar la interfaz",
    Duration = 6,
})

if loadConfig() then print("✅ Tommy Hub 67: config cargada automáticamente") end
