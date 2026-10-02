--==============================================================
-- TOMMY HUB 67  |  WindUI Edition
-- TikTok: @accountxz
--==============================================================

-- Cargar WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Crear ventana principal
local Window = WindUI:CreateWindow({
    Title = "Tommy Hub 67",
    Icon = "rbxassetid://10734950309", -- ícono opcional
    Author = "@accountxz",
    Folder = "TommyHub67",
    Size = UDim2.fromOffset(600, 420),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true,
        Anonymous = true,
    },
    SideBarWidth = 180,
})

-- Pestañas
local CombatTab   = Window:Tab({Title = "Combat",   Icon = "sword"})
local GlitchTab   = Window:Tab({Title = "Glitches", Icon = "sparkles"})
local SoruTab     = Window:Tab({Title = "Soru",     Icon = "zap"})
local ESPTab      = Window:Tab({Title = "ESP",      Icon = "eye"})
local DungeonTab  = Window:Tab({Title = "Dungeons", Icon = "castle"})
local MiscTab     = Window:Tab({Title = "Misc",     Icon = "settings"})

--==================== COMBAT ====================
local SilentSection = CombatTab:Section({Title = "Silent Aim (Antiguo Aimbot)"})

SilentSection:Toggle({
    Title = "Silent Aim (Skills)",
    Desc = "Aimbot invisible: redirige los remotes sin mover la cámara",
    Default = false,
    Callback = function(state)
        S.SkillAimbot = state
    end,
})

SilentSection:Toggle({
    Title = "Aimbot M1 (Dragon Gun) ⚠ BAN",
    Default = false,
    Callback = function(state) S.DragonM1 = state end,
})

SilentSection:Toggle({
    Title = "Target Players",
    Default = true,
    Callback = function(state) S.TargetPlayers = state end,
})

SilentSection:Toggle({
    Title = "Target NPCs",
    Default = false,
    Callback = function(state) S.TargetMobs = state end,
})

SilentSection:Toggle({
    Title = "Team Check",
    Default = false,
    Callback = function(state) S.TeamCheck = state end,
})

SilentSection:Slider({
    Title = "Max Dist",
    Desc = "Distancia máxima del objetivo",
    Min = 100,
    Max = 5000,
    Default = 2500,
    Rounding = 0,
    Callback = function(value) S.MaxDist = value end,
})

-- Aimbot 67 Descarado
local A67Section = CombatTab:Section({Title = "Aimbot 67 Descarado (Visible)"})

A67Section:Toggle({
    Title = "▶ Aimbot 67 Descarado",
    Desc = "Mueve la cámara al objetivo con predicción",
    Default = false,
    Callback = function(state) S.A67_Enabled = state end,
})

A67Section:Toggle({
    Title = "Atacar NPCs",
    Default = true,
    Callback = function(state) S.A67_TargetNPC = state end,
})

A67Section:Toggle({
    Title = "Atacar Players",
    Default = false,
    Callback = function(state) S.A67_TargetPlayer = state end,
})

A67Section:Slider({
    Title = "Predicción",
    Min = 0,
    Max = 1,
    Default = 0.15,
    Rounding = 2,
    Callback = function(value) S.A67_Prediction = value end,
})

--==================== GLITCHES ====================
local SangSection = GlitchTab:Section({Title = "Sanguine Z"})

SangSection:Toggle({
    Title = "Sanguine Z No Cooldown",
    Default = false,
    Callback = function(state)
        S.SangNoCD = state
        local c = player.Character
        if c then c:SetAttribute("AllCooldown", state and 3 or nil) end
    end,
})

SangSection:Button({
    Title = "🩸 Sanguine Z Manual",
    Callback = function() sangManual() end,
})

SangSection:Slider({
    Title = "Drop Duration",
    Min = 0.5,
    Max = 5,
    Default = 2,
    Rounding = 1,
    Callback = function(value) S.SangDrop = value end,
})

--==================== SORU ====================
local SoruSection = SoruTab:Section({Title = "Soru"})

SoruSection:Toggle({
    Title = "Infinite Soru",
    Default = false,
    Callback = function(state)
        S.InfSoru = state
        if player.Character then attachInfSoru(player.Character) end
    end,
})

SoruSection:Slider({
    Title = "Soru Dist",
    Min = 100,
    Max = 3500,
    Default = 1000,
    Callback = function(value) S.SoruDist = value end,
})

--==================== ESP ====================
local ESPSection = ESPTab:Section({Title = "ESP & Visuals"})

ESPSection:Toggle({
    Title = "ESP (General)",
    Default = false,
    Callback = function(state)
        S.ESP = state
        if not state then for p in pairs(esp) do clearESP(p) end end
    end,
})

ESPSection:Toggle({
    Title = "Show Name",
    Default = true,
    Callback = function(state) S.ESPName = state end,
})

ESPSection:Toggle({
    Title = "Show Level",
    Default = true,
    Callback = function(state) S.ESPLevel = state end,
})

ESPSection:Slider({
    Title = "Text Size",
    Min = 8,
    Max = 32,
    Default = 12,
    Callback = function(value) S.ESPSize = value end,
})

--==================== DUNGEONS ====================
local DgSection = DungeonTab:Section({Title = "Auto Dungeon"})

DgSection:Toggle({
    Title = "▶ Auto Dungeon (Start/Stop)",
    Default = false,
    Callback = function(state) dgSet(state) end,
})

DgSection:Slider({
    Title = "Altura de ataque",
    Min = 10,
    Max = 100,
    Default = 40,
    Callback = function(value) S.DungeonHeight = value end,
})

--==================== MISC ====================
local MiscSection = MiscTab:Section({Title = "Config"})

MiscSection:Button({
    Title = "💾 Guardar Config",
    Callback = function() saveConfig() end,
})

MiscSection:Button({
    Title = "📂 Cargar Config",
    Callback = function() loadConfig() end,
})

-- Notificación inicial
Window:Notification({
    Title = "Tommy Hub 67",
    Content = "Script cargado correctamente",
    Duration = 5,
})
