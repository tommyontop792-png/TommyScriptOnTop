do
    local abToggleBtnRef = nil
    local abStatusLblRef = nil
    local abToggleBtnStroke = nil
    local function autoBusoAndPvPRespawn()
        if not (FeatureStates["AutoBuso"] or Settings.autoBuso) then return end
        pcall(function()
            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            local commF = remotes and remotes:FindFirstChild("CommF_")
            if commF then
                local char = LocalPlayer.Character
                if char and not char:FindFirstChild("HasBuso") and char:GetAttribute("HasBuso") ~= true then
                    commF:InvokeServer("Buso")
                end
            end
        end)
    end
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.spawn(function()
            task.wait(1.2)
            if FeatureStates["AutoBuso"] or Settings.autoBuso then autoBusoAndPvPRespawn() end
            task.wait(2.0)
            if FeatureStates["AutoBuso"] or Settings.autoBuso then autoBusoAndPvPRespawn() end
        end)
    end)
    local bountyEpoch = 0
    local bountyConnections = {}
    local function disconnectBounty()
        bountyEpoch += 1
        for _, conn in ipairs(bountyConnections) do pcall(function() conn:Disconnect() end) end
        table.clear(bountyConnections)
    end
    local function stopTommyAutoBountyExact()
        disconnectBounty()
        getgenv().TommyAutoBountyRunning = false
        getgenv().targ = nil
        pcall(function()
            if tween then
                tween:Cancel()
            end
        end)
        pcall(function()
            local lp = game:GetService("Players").LocalPlayer
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("Hold") then
                hrp.Hold:Destroy()
            end
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                workspace.CurrentCamera.CameraSubject = hum
            end
        end)
        pcall(function()
            if DisableESP then
                DisableESP()
            end
        end)
        pcall(function()
            local pGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            local existing = pGui and pGui:FindFirstChild("Tommy_AutoBounty")
            if existing then
                existing.Enabled = false
                existing:Destroy()
            end
        end)
        pcall(function()
            if _G.CleanupAutoBountyTweenAndPart then
                _G.CleanupAutoBountyTweenAndPart()
            end
        end)
        pcall(function()
            if _G.StopAutoBountyNoclip then
                _G.StopAutoBountyNoclip()
            end
        end)
        pcall(function()
            local waterPlane = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WaterBase-Plane")
            if waterPlane and not (FeatureStates and FeatureStates["WalkOnWater"]) then
                waterPlane.CanCollide = false
                waterPlane.Size = Vector3.new(1000, 80, 1000)
            end
        end)
        if abToggleBtnRef then
            abToggleBtnRef.Text = (CurrentLang == "ES") and "Iniciar Auto Bounty" or "Start Auto Bounty"
            abToggleBtnRef.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
            if abToggleBtnStroke then
                abToggleBtnStroke.Color = Color3.fromRGB(55, 55, 68)
            end
        end
        if abStatusLblRef then
            abStatusLblRef.Text = (CurrentLang == "ES") and "Estado: Inactivo / Detenido" or "Status: Inactive / Stopped"
            abStatusLblRef.TextColor3 = Color3.fromRGB(190, 190, 205)
        end
        notifyToggle("Tommy Auto Bounty Stopped!", false)
    end
    _G.stopTommyAutoBountyExact = stopTommyAutoBountyExact
    getgenv().StopTommyAutoBountyExact = stopTommyAutoBountyExact
    local function runTommyAutoBountyExact()
        if getgenv().TommyAutoBountyRunning then
            notifyToggle("Auto Bounty is already running!", true)
            return
        end
        disconnectBounty()
        local runEpoch = bountyEpoch
        getgenv().TommyAutoBountyRunning = true
        getgenv().checked = {}
        getgenv().targ = nil
        getgenv().target = nil
        getgenv().HealingInSky = false
        getgenv().CancelHealing = false
        getgenv().NoDamageRunning = false
        getgenv().AutoBountyReachedTarget = false
        getgenv().safeZoneWaitRetries = 0
        local function isBountyCurrent()
            return isCurrentSession() and bountyEpoch == runEpoch and getgenv().TommyAutoBountyRunning == true
        end
        local function bountyConnect(signal, callback)
            if not isBountyCurrent() then return nil end
            local conn = signal:Connect(function(...)
                if isBountyCurrent() then callback(...) end
            end)
            table.insert(bountyConnections, conn)
            return conn
        end
        task.spawn(function() if isBountyCurrent() then autoBusoAndPvPRespawn() end end)
        if abToggleBtnRef then
            abToggleBtnRef.Text = (CurrentLang == "ES") and "Detener Auto Bounty" or "Stop Auto Bounty"
            abToggleBtnRef.BackgroundColor3 = Color3.fromRGB(48, 22, 32)
            if abToggleBtnStroke then
                abToggleBtnStroke.Color = Color3.fromRGB(95, 42, 56)
            end
        end
        if abStatusLblRef then
            abStatusLblRef.Text = (CurrentLang == "ES") and "Estado: Cazando Objetivos..." or "Status: Hunting Targets..."
            abStatusLblRef.TextColor3 = Color3.fromRGB(245, 245, 255)
        end
        task.spawn(function()
    if not isBountyCurrent() then return end
    local initialized,initError=pcall(function()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local lp = LocalPlayer
local tween = nil
getgenv().checked = getgenv().checked or {}
function hasValue(array, targetString)
    if not array then return false end
    for _, value in ipairs(array) do
        if value == targetString then
            return true
        end
    end
    return false
end
getgenv().hasValue = hasValue
local function AX_ReadPvPState(target)
    if _G.TommyPvPAllowed then return _G.TommyPvPAllowed(target) end
    if not target then return false end
    local ok, pvpOn = pcall(function()
        if target:IsA("Player") and target:GetAttribute("PvpDisabled") == true then
            return false
        end
        local char = target.Character or (target:IsA("Model") and target)
        if char then
            if char:FindFirstChildOfClass("ForceField") then
                return false
            end
            if char:GetAttribute("PvpDisabled") == true then
                return false
            end
        end
        return true
    end)
    return ok and pvpOn
end
local function isTargetProtected(targetPlayer)
    if not targetPlayer then return true end
    return not AX_ReadPvPState(targetPlayer)
end
local function AX_InSafeZone(target)
    if _G.TommyInSafeZone then return _G.TommyInSafeZone(target) end
    if not target then return false end
    local ok, inZone = pcall(function()
        local char = target.Character or (target:IsA("Model") and target)
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Sit == true then return true end
        if char:FindFirstChildOfClass("ForceField") then return true end
        if char:GetAttribute("SafeZone") == true then return true end
        if target:IsA("Player") and target:GetAttribute("SafeZone") == true then return true end
        local wo = workspace:FindFirstChild("_WorldOrigin")
        if not wo then return false end
        local safeZones = wo:FindFirstChild("SafeZones")
        if safeZones then
            for _, zone in pairs(safeZones:GetChildren()) do
                if zone:IsA("BasePart") then
                    local mesh = zone:FindFirstChild("Mesh")
                    local radius = 0
                    if mesh and mesh:IsA("SpecialMesh") then
                        radius = (zone.Size.X * mesh.Scale.X) / 2
                    else
                        radius = math.min(zone.Size.X, zone.Size.Z) / 2
                    end
                    if radius > 500 then radius = 350 end
                    if radius <= 0 then radius = 350 end
                    if (zone.Position - hrp.Position).Magnitude <= radius then
                        return true
                    end
                end
            end
        end
        return false
    end)
    return ok and inZone
end
local function isAllyWithMe(targetplayer)
    local myGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not myGui then return false end
    local scrolling = myGui:FindFirstChild("Main") and myGui.Main:FindFirstChild("Allies")
        and myGui.Main.Allies:FindFirstChild("Container") and myGui.Main.Allies.Container:FindFirstChild("Allies")
        and myGui.Main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
    if scrolling then
        for _, frame in pairs(scrolling:GetDescendants()) do
            if frame:IsA("ImageButton") and frame.Name == targetplayer.Name then return true end
        end
    end
    return false
end
local function isEnemy(targetplayer)
    if _G.TommyIsEnemy then return _G.TommyIsEnemy(targetplayer) end
    if not targetplayer or targetplayer == LocalPlayer then return false end
    local myTeam = LocalPlayer.Team
    local targetTeam = targetplayer.Team
    if myTeam and targetTeam then
        if myTeam.Name == "Pirates" and targetTeam.Name == "Marines" then return true
        elseif myTeam.Name == "Marines" and targetTeam.Name == "Pirates" then return true end
        if myTeam.Name == "Pirates" and targetTeam.Name == "Pirates" then return not isAllyWithMe(targetplayer) end
        if myTeam.Name == "Marines" and targetTeam.Name == "Marines" then return false end
    end
    return true
end
local function isLocalPvpDisabled()
    local ok, dis = pcall(function()
        if LocalPlayer:GetAttribute("PvpDisabled") == true then return true end
        local main = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not main then return false end
        local bList = main:FindFirstChild("BottomHUDList")
        if bList and bList:FindFirstChild("PvpDisabled") and bList.PvpDisabled.Visible == true then
            return true
        end
        if main:FindFirstChild("PvpDisabled") and main.PvpDisabled.Visible == true then
            return true
        end
        return false
    end)
    return ok and dis
end
_G.G_ESPEnabled         = _G.G_ESPEnabled ~= false
_G.G_ESP_Name           = _G.G_ESP_Name ~= false
_G.G_ESP_Level          = _G.G_ESP_Level ~= false
_G.G_ESP_Bounty         = _G.G_ESP_Bounty ~= false
_G.G_ESP_Fruit          = _G.G_ESP_Fruit ~= false
_G.G_ESP_Distance       = _G.G_ESP_Distance ~= false
_G.G_ESP_HP             = _G.G_ESP_HP ~= false
_G.G_ESP_TextSize       = _G.G_ESP_TextSize or 14
_G.G_ESP_Highlight      = _G.G_ESP_Highlight ~= false
_G.G_ESP_HighlightColor = _G.G_ESP_HighlightColor or "FF0000"
_G.G_ESP_FruitGround    = _G.G_ESP_FruitGround ~= false
_G.G_ESP_Flower         = _G.G_ESP_Flower ~= false
local ESPRunning = false
local espObjects = {}
local espUpdateConnection = nil
local function getTeamInfo(player)
    if not player.Team then
        return "Unknown", Color3.fromRGB(255, 255, 255)
    end
    if player.Team.Name == "Marines" then
        return "Marines", Color3.fromRGB(0, 170, 255)
    else
        return "Pirates", Color3.fromRGB(255, 70, 70)
    end
end
local function hexToColor3(hex)
    local r = tonumber(hex:sub(1,2), 16) and (tonumber(hex:sub(1,2), 16) / 255) or 1
    local g = tonumber(hex:sub(3,4), 16) and (tonumber(hex:sub(3,4), 16) / 255) or 0
    local b = tonumber(hex:sub(5,6), 16) and (tonumber(hex:sub(5,6), 16) / 255) or 0
    return Color3.new(r, g, b)
end
local function removeESP(player)
    if espObjects[player] then
        pcall(function()
            if espObjects[player].gui then espObjects[player].gui:Destroy() end
            if espObjects[player].highlight then espObjects[player].highlight:Destroy() end
        end)
        espObjects[player] = nil
    end
end
local function createESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local team, color = getTeamInfo(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Tommy_PlayerESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 220, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextScaled = false
    text.TextSize = _G.G_ESP_TextSize or 14
    text.RichText = true
    text.Font = Enum.Font.SourceSansBold
    text.TextStrokeTransparency = 0
    text.TextColor3 = color
    text.Parent = billboard
    billboard.Parent = head
    local highlight = nil
    if _G.G_ESP_Highlight then
        local hlColor = hexToColor3(_G.G_ESP_HighlightColor)
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_PlayerHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = hlColor
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = hlColor
        highlight.OutlineTransparency = 0
        highlight.Parent = char
    end
    espObjects[player] = {
        gui = billboard,
        label = text,
        char = char,
        highlight = highlight
    }
end
local lastESPUpdate = 0
local ESP_UPDATE_INTERVAL = 0.1
local playerCache = {}
local function getPlayerData(player)
    if not playerCache[player] then
        playerCache[player] = {
            level = "?",
            fruit = "None",
            bounty = 0,
            team = "Unknown",
            color = Color3.fromRGB(255, 255, 255),
            lastUpdate = 0
        }
    end
    local data = playerCache[player]
    local now = tick()
    if now - data.lastUpdate > 5 then
        pcall(function() data.level = player.Data.Level.Value end)
        pcall(function() data.fruit = player.Data.DevilFruit.Value end)
        pcall(function() data.bounty = player.leaderstats["Bounty/Honor"].Value end)
        data.team, data.color = getTeamInfo(player)
        data.lastUpdate = now
    end
    return data
end
local extraESPObjects = {}
local function updateExtraESP()
    if _G.G_ESP_FruitGround then
        pcall(function()
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Tool") or (obj:IsA("Model") and string.find(string.lower(obj.Name), "fruit")) then
                    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                    if handle and not extraESPObjects[obj] then
                        local bill = Instance.new("BillboardGui", handle)
                        bill.Name = "ExtraFruitESP"
                        bill.Size = UDim2.new(0, 150, 0, 35)
                        bill.AlwaysOnTop = true
                        local lbl = Instance.new("TextLabel", bill)
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(255, 105, 180)
                        lbl.TextSize = 13
                        lbl.Font = Enum.Font.SourceSansBold
                        lbl.TextStrokeTransparency = 0
                        lbl.Text = "[Fruit] " .. obj.Name
                        extraESPObjects[obj] = bill
                    end
                end
            end
        end)
    end
    if _G.G_ESP_Flower then
        pcall(function()
            local map = workspace:FindFirstChild("Map")
            if map then
                for _, v in ipairs(map:GetChildren()) do
                    if string.find(v.Name, "Flower") then
                        local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                        if part and not extraESPObjects[v] then
                            local bill = Instance.new("BillboardGui", part)
                            bill.Name = "ExtraFlowerESP"
                            bill.Size = UDim2.new(0, 120, 0, 30)
                            bill.AlwaysOnTop = true
                            local lbl = Instance.new("TextLabel", bill)
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                            lbl.TextSize = 13
                            lbl.Font = Enum.Font.SourceSansBold
                            lbl.TextStrokeTransparency = 0
                            lbl.Text = "[Flower] " .. v.Name
                            extraESPObjects[v] = bill
                        end
                    end
                end
            end
        end)
    end
end
local function updateESP()
    local now = tick()
    if now - lastESPUpdate < ESP_UPDATE_INTERVAL then return end
    lastESPUpdate = now
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local head = char and char:FindFirstChild("Head")
            local data = espObjects[player]
            if char and head then
                if not data or data.char ~= char or not data.gui.Parent then
                    removeESP(player)
                    createESP(player)
                    data = espObjects[player]
                end
            else
                if data then
                    removeESP(player)
                    data = nil
                end
            end
            if data then
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                local distance = math.floor((root.Position - myPos).Magnitude)
                local maxH = hum.MaxHealth > 0 and hum.MaxHealth or 100
                local hp = math.floor((hum.Health / maxH) * 100)
                local pData = getPlayerData(player)
                local level = pData.level
                local fruit = pData.fruit
                local bounty = pData.bounty
                local team = pData.team
                local color = pData.color
                local warnTag = ""
                if bounty > 10000000 then
                    warnTag = "[!] "
                end
                local inSafe = AX_InSafeZone(player)
                local isPvpDisabled = false
                local pvpState = "PVP: ON"
                local pvpIcon = "[PVP] "
                if player:GetAttribute("PvpDisabled") == true or char:FindFirstChildOfClass("ForceField") then
                    pvpState = "PvP: OFF"
                    pvpIcon = "[SAFE] "
                    isPvpDisabled = true
                end
                if inSafe then
                    pvpState = pvpState .. " (SafeZone)"
                end
                data.label.TextColor3 = color
                if data.label.TextSize ~= _G.G_ESP_TextSize then
                    data.label.TextSize = _G.G_ESP_TextSize or 14
                end
                local parts = {}
                if _G.G_ESP_Name then parts[#parts+1] = warnTag .. "[" .. team .. "] <font color=\"rgb(255,255,0)\">" .. player.Name .. "</font>" end
                if _G.G_ESP_Level then parts[#parts+1] = " [Lv." .. level .. "]" end
                if isPvpDisabled or inSafe then
                    parts[#parts+1] = "\n<font color=\"rgb(0,255,0)\">" .. pvpIcon .. pvpState .. "</font>\n"
                else
                    parts[#parts+1] = "\n<font color=\"rgb(255,70,70)\">" .. pvpIcon .. pvpState .. "</font>\n"
                end
                if _G.G_ESP_Fruit and fruit and fruit ~= "None" and fruit ~= "" then parts[#parts+1] = "Fruit: " .. fruit .. "\n" end
                if _G.G_ESP_Bounty then parts[#parts+1] = "Bounty: " .. (math.floor(bounty / 100000) / 10) .. "M\n" end
                if _G.G_ESP_Distance then parts[#parts+1] = distance .. "m | " end
                if _G.G_ESP_HP then
                    if _G.G_ESP_HP_Format == "Percentage" then
                        parts[#parts+1] = "Health: " .. hp .. "%"
                    elseif _G.G_ESP_HP_Format == "Both" then
                        parts[#parts+1] = "HP: " .. math.floor(hum.Health) .. " / " .. math.floor(maxH) .. " (" .. hp .. "%)"
                    else
                        parts[#parts+1] = "HP: " .. math.floor(hum.Health) .. " / " .. math.floor(maxH)
                    end
                end
                data.label.Text = table.concat(parts)
                if _G.G_ESP_Highlight then
                    local hlColor = hexToColor3(_G.G_ESP_HighlightColor)
                    if not data.highlight or not data.highlight.Parent then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESP_PlayerHighlight"
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = hlColor
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = hlColor
                        hl.OutlineTransparency = 0
                        hl.Parent = char
                        data.highlight = hl
                    else
                        data.highlight.FillColor = hlColor
                        data.highlight.OutlineColor = hlColor
                        data.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                else
                    if data.highlight then
                        data.highlight:Destroy()
                        data.highlight = nil
                    end
                end
            end
        end
    end
    end
    updateExtraESP()
end
function EnableESP()
    if ESPRunning then return end
    ESPRunning = true
    for _, player in ipairs(Players:GetPlayers()) do
        createESP(player)
    end
    if espUpdateConnection then task.cancel(espUpdateConnection) end
    espUpdateConnection = task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and ESPRunning do
            if not isBountyCurrent() then return end
            pcall(updateESP)
            task.wait(ESP_UPDATE_INTERVAL)
            if not isBountyCurrent() then return end
        end
    end)
end
function DisableESP()
    ESPRunning = false
    if espUpdateConnection then
        task.cancel(espUpdateConnection)
        espUpdateConnection = nil
    end
    for player, _ in pairs(espObjects) do
        removeESP(player)
    end
    espObjects = {}
    for obj, bill in pairs(extraESPObjects) do
        pcall(function() bill:Destroy() end)
    end
    extraESPObjects = {}
end
do
    bountyConnect(Players.PlayerRemoving, function(player)
        removeESP(player)
        playerCache[player] = nil
    end)
end
task.spawn(function()
    if not isBountyCurrent() then return end
    task.wait(1)
    if not isBountyCurrent() then return end
    if _G.G_ESPEnabled then
        EnableESP()
    end
end)
local UI = (function()
    local UI = {}
    function UI.SetTarget(name)
        pcall(function()
            if targetNameBox then
                targetNameBox.Text = (CurrentLang == "ES") and ("Objetivo: " .. tostring(name or "Ninguno")) or ("Target: " .. tostring(name or "None"))
            end
        end)
    end
    function UI.UpdateStats(EarnedVal, TotalEarnedVal, BountyVal)
        pcall(function()
            if earnedBox then
                earnedBox.Text = (CurrentLang == "ES") and ("Ganado: " .. tostring(EarnedVal or 0)) or ("Earned: " .. tostring(EarnedVal or 0))
            end
            if Tommy.UI.targetBountyBox and BountyVal then
                Tommy.UI.targetBountyBox.Text = "Bounty: " .. tostring(BountyVal)
            end
        end)
    end
    function UI.ShowNotification(text, nType)
        pcall(function()
            if abStatusLblRef then
                abStatusLblRef.Text = tostring(text or "")
            end
            if _G.Tommy_Log then
                _G.Tommy_Log(tostring(text or ""))
            end
        end)
    end
    function UI.UpdateTargetsList(list)
    end
    return UI
end)()
local aimbotOn = true
local PlayersPosition = nil
local currentTool, currentToolCategory = nil, "Melee"
local currentSkillKey = nil
local lastSkillTime = 0
local maxRange = 1000
local PredictionEnabled = true
local PredictionAmount = 0.12
local PingService = pcall(function() return game:GetService("Stats").Network.ServerStatsItem end) and game:GetService("Stats").Network.ServerStatsItem or nil
local SKILL_KEYS = { "Z", "X", "C", "V", "F", "TAP" }
local function getHRP(model)
    if model and model:FindFirstChild("HumanoidRootPart") then return model.HumanoidRootPart end
    return nil
end
local function getToolCategory(tool)
    if not tool then return "Melee" end
    local name = string.lower(tool.Name)
    local gunNames = { "guitar", "rifle", "cannon", "gun", "slingshot", "kabucha", "serpent bow", "bow" }
    for _, g in ipairs(gunNames) do
        if string.find(name, g) then return "Gun" end
    end
    local meleeNames = { "claw", "godhuman", "superhuman", "talon", "step", "karate", "breath", "kung fu", "combat", "fist", "sanguine" }
    for _, m in ipairs(meleeNames) do
        if string.find(name, m) then return "Melee" end
    end
    if string.find(name, "fruit") or string.find(name, "-") then return "Fruit" end
    return "Sword"
end
local function isOverrideTool(tool)
    if not tool then return false end
    local name = string.lower(tool.Name)
    if name == "godhuman" or string.find(name, "sanguine") then return true end
    if currentToolCategory == "Sword" then return true end
    if string.find(name, "yama") then return true end
    return false
end
local lastDirection = nil
local function predicted(hrp)
    if not hrp then return nil end
    local hum = hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return hrp.Position end
    if not PredictionEnabled then return hrp.Position end
    local vel = hrp.Velocity
    local speed = vel.Magnitude
    if speed < 5 then
        lastDirection = nil
        return hrp.Position
    end
    local currentDirection = vel.Unit
    if lastDirection then
        local dot = lastDirection:Dot(currentDirection)
        if dot < 0.7 then
            lastDirection = nil
            return hrp.Position
        end
    end
    lastDirection = currentDirection
    local ping = 0
    pcall(function()
        if PingService then ping = PingService:GetValue() / 1000 end
    end)
    ping = math.clamp(ping, 0, 0.35)
    local predictionFactor = PredictionAmount + ping
    if speed > 100 then
        predictionFactor = math.min(predictionFactor, 0.15)
    end
    return hrp.Position + (vel * predictionFactor)
end
local function getClosestplayer(lpHRP)
    if not lpHRP then return nil end
    if getgenv().targ and getgenv().targ.Character and isEnemy(getgenv().targ) and not AX_InSafeZone(getgenv().targ) then
        local hum = getgenv().targ.Character:FindFirstChildWhichIsA("Humanoid")
        local hrp = getHRP(getgenv().targ.Character)
        if hum and hum.Health > 0 and hrp then
            return getgenv().targ
        end
    end
    local valid = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and not (_G.PlayerBlacklist and (_G.PlayerBlacklist[pl.UserId] or _G.PlayerBlacklist[pl.Name])) and isEnemy(pl) and not AX_InSafeZone(pl) and pl.Character and pl.Character.Parent then
            local hum = pl.Character:FindFirstChildWhichIsA("Humanoid")
            local hrp = getHRP(pl.Character)
            if hum and hum.Health > 0 and hrp then
                local dist = (hrp.Position - lpHRP.Position).Magnitude
                if dist <= maxRange then
                    table.insert(valid, { Player = pl, Humanoid = hum, HRP = hrp, Distance = dist })
                end
            end
        end
    end
    if #valid == 0 then return nil end
    table.sort(valid, function(a, b) return a.Distance < b.Distance end)
    return valid[1].Player
end
local function faceTarget(targetPos)
    if not targetPos then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local currentPos = hrp.Position
    local lookVector = (Vector3.new(targetPos.X, currentPos.Y, targetPos.Z) - currentPos).Unit
    if lookVector.Magnitude < 0.001 then return end
    hrp.CFrame = CFrame.lookAt(currentPos, currentPos + lookVector, Vector3.new(0, 1, 0))
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
end
local function setCurrentSkillKey(key)
    currentSkillKey = key
    lastSkillTime = os.clock()
    if aimbotOn and PlayersPosition then
        task.spawn(function() faceTarget(PlayersPosition) end)
    if not isBountyCurrent() then return end
    end
    task.spawn(function()
    if not isBountyCurrent() then return end
        local myTime = lastSkillTime
        task.wait(1.5)
        if not isBountyCurrent() then return end
        if lastSkillTime == myTime and currentSkillKey == key then
            currentSkillKey = nil
        end
    end)
end
local function getSkillKeyFromArgs(args)
    for _, arg in ipairs(args) do
        if type(arg) == "string" and table.find(SKILL_KEYS, arg) then return arg end
    end
    return nil
end
bountyConnect(UserInputService.InputBegan, function(input, gp)
    if gp then return end
    local keyMap = { [Enum.KeyCode.Z] = "Z", [Enum.KeyCode.X] = "X", [Enum.KeyCode.C] = "C", [Enum.KeyCode.V] = "V", [Enum.KeyCode.F] = "F" }
    local key = keyMap[input.KeyCode]
    if key then setCurrentSkillKey(key) end
end)
task.spawn(function()
    if not isBountyCurrent() then return end
    local pg = LocalPlayer:WaitForChild("PlayerGui", 10)
    local main = pg and pg:WaitForChild("Main", 10)
    if not main then return end
    local skills = main:WaitForChild("Skills", 10)
    if not skills then return end
    local function hookMobileButton(btn)
        if btn:GetAttribute("Hooked") then return end
        btn:SetAttribute("Hooked", true)
        local key = btn.Name
        if table.find(SKILL_KEYS, key) then
            bountyConnect(btn.Activated, function() setCurrentSkillKey(key) end)
        end
    end
    for _, wf in ipairs(skills:GetChildren()) do
        if wf:IsA("GuiObject") then
            for _, b in ipairs(wf:GetChildren()) do
                if b:IsA("ImageButton") or b:IsA("TextButton") then hookMobileButton(b) end
            end
        end
    end
    bountyConnect(skills.ChildAdded, function(wf)
        if wf:IsA("GuiObject") then
            for _, b in ipairs(wf:GetChildren()) do
                if b:IsA("ImageButton") or b:IsA("TextButton") then hookMobileButton(b) end
            end
        end
    end)
end)
local function trackCharacterTools(char)
    local function watchTool(child)
        currentTool = child
        currentToolCategory = getToolCategory(child)
        currentSkillKey = nil
        bountyConnect(child.AncestryChanged, function(_, p)
            if not p then currentTool = nil end
        end)
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then watchTool(child) end
    end
    bountyConnect(char.ChildAdded, function(child)
        if child:IsA("Tool") then watchTool(child) end
    end)
    bountyConnect(char.ChildRemoved, function(child)
        if child == currentTool then currentTool = nil end
    end)
end
if LocalPlayer.Character then trackCharacterTools(LocalPlayer.Character) end
bountyConnect(LocalPlayer.CharacterAdded, function(char)
    trackCharacterTools(char)
    task.delay(0.2, function()
    if not isBountyCurrent() then return end
        if FeatureStates["SuperJump"] then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    hum.JumpPower = 50
                    hum.JumpHeight = 7.2
                end)
            end
        end
        if FeatureStates["AntiLavaShip"] and getgenv().EnableAntiLava then
            getgenv().EnableAntiLava()
        end
    end)
    getgenv().UsedVWithoutBar = false
    task.delay(1.5, function()
    if not isBountyCurrent() then return end
        if (isBountyCurrent()) and not getgenv().targ and getgenv().target then
            getgenv().target()
        elseif not (isBountyCurrent()) then
            pcall(function()
                local c = LocalPlayer.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("Hold") then
                    hrp.Hold:Destroy()
                end
            end)
        end
    end)
end)
bountyConnect(RunService.RenderStepped, function()
if not isBountyCurrent() then return end
    pcall(function()
        local lpChar = LocalPlayer.Character
        local lpHRP = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
        if not lpHRP or not aimbotOn then
            PlayersPosition = nil
            return
        end
        local targetplayer = getClosestplayer(lpHRP)
        if targetplayer and targetplayer.Character then
            local tHRP = getHRP(targetplayer.Character)
            PlayersPosition = predicted(tHRP)
            if not getgenv().SpectateTarget and tHRP then
                local hum = targetplayer.Character:FindFirstChildWhichIsA("Humanoid")
                if hum and hum.Health > 0 then
                    local camTarget = tHRP.Position + (tHRP.Velocity * 0.163186)
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, camTarget)
                end
            end
        else
            PlayersPosition = nil
        end
    end)
end)
local mouseModuleData = nil
local mouseModuleResolved = false
local function getMouseModule()
    if not mouseModuleResolved then
        mouseModuleResolved = true
        local mm = ReplicatedStorage:FindFirstChild("Mouse")
        if mm and typeof(mm) == "Instance" then
            local ok, res = pcall(require, mm)
            if ok and type(res) == "table" then mouseModuleData = res end
        end
    end
    return mouseModuleData
end
bountyConnect(RunService.Heartbeat, function()
if not isBountyCurrent() then return end
    if not aimbotOn or currentSkillKey ~= "Z" or not isOverrideTool(currentTool) then return end
    if currentTool and (string.find(string.lower(currentTool.Name), "portal") or string.find(string.lower(currentTool.Name), "lightning")) then return end
    local targetPos = PlayersPosition
    local mouseData = getMouseModule()
    if targetPos and mouseData then
        local targetCFrame = CFrame.new(targetPos)
        pcall(function()
            mouseData.Hit = targetCFrame
            mouseData.Target = nil
        end)
    end
end)

do
    local antiLavaActive = false
    local antiLavaConn = nil
    local waterPlatform = nil

    local function suppressHazardPart(part)
        if not part or not part:IsA("BasePart") then return end
        local n = string.lower(part.Name)
        if n:find("lava") or n:find("acid") or n:find("toxic") then
            pcall(function()
                part.CanTouch = false
                local tt = part:FindFirstChildWhichIsA("TouchTransmitter")
                if tt then tt:Destroy() end
            end)
        end
    end

    local function scanHazards()
        pcall(function()
            local map = workspace:FindFirstChild("Map")
            if map then
                for _, obj in ipairs(map:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        suppressHazardPart(obj)
                    end
                end
            end
            local hazards = workspace:FindFirstChild("SeaHazards")
            if hazards then
                for _, obj in ipairs(hazards:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        suppressHazardPart(obj)
                    end
                end
            end
            for _, child in ipairs(workspace:GetChildren()) do
                if child:IsA("BasePart") then
                    suppressHazardPart(child)
                end
            end
        end)
    end

    local lastAntiLavaCharTouch = 0
    local function enableAntiLava()
        antiLavaActive = true
        task.spawn(scanHazards)
        if antiLavaConn then return end
        antiLavaConn = bountyConnect(RunService.Stepped, function()
            if not antiLavaActive then return end
            local char = LocalPlayer.Character
            if not char then return end

            local now = tick()
            if now - lastAntiLavaCharTouch > 0.4 then
                lastAntiLavaCharTouch = now
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanTouch = false end)
                    end
                end
            end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < 4 then
                if not waterPlatform or not waterPlatform.Parent then
                    local p = Instance.new("Part")
                    p.Name = "TommyWaterPlatform"
                    p.Size = Vector3.new(28, 2, 28)
                    p.Anchored = true
                    p.CanCollide = true
                    p.Transparency = 1
                    p.Parent = workspace
                    waterPlatform = p
                end
                waterPlatform.CFrame = CFrame.new(hrp.Position.X, 1, hrp.Position.Z)
            else
                if waterPlatform and waterPlatform.Parent then
                    waterPlatform:Destroy()
                    waterPlatform = nil
                end
            end
        end)
    end

    local function disableAntiLava()
        antiLavaActive = false
        if antiLavaConn then antiLavaConn:Disconnect(); antiLavaConn = nil end
        if waterPlatform and waterPlatform.Parent then
            waterPlatform:Destroy()
            waterPlatform = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanTouch = true end)
                end
            end
        end
    end

    getgenv().EnableAntiLava = enableAntiLava
    getgenv().DisableAntiLava = disableAntiLava
    FeatureCallbacks["AntiLavaShip"] = function(v)
        if v then
            task.spawn(function()
    if not isBountyCurrent() then return end
                pcall(scanHazards)
            end)
        end
    end
    local function enableAutoBuso() end
    local function disableAutoBuso() end
    getgenv().EnableAutoBuso = enableAutoBuso
    getgenv().DisableAutoBuso = disableAutoBuso
end

local function isCandidateTarget(v)
    if not v or v == LocalPlayer or not v.Parent then return false end
    if _G.isPlayerBlacklisted and _G.isPlayerBlacklisted(v) then return false end
    if not isEnemy(v) then return false end
    if hasValue(getgenv().checked, v) then return false end
    if not AX_ReadPvPState(v) then return false end
    if AX_InSafeZone(v) then return false end
    local char = v.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    if hrp.Position.Y > 12000 then return false end
    local vData = v:FindFirstChild("Data")
    local vLevel = _G.getPlayerLevel and _G.getPlayerLevel(v) or (vData and vData:FindFirstChild("Level") and tonumber(vData.Level.Value) or 0)
    local bVal = 0
    if v:FindFirstChild("leaderstats") then
        local bStat = v.leaderstats:FindFirstChild("Bounty/Honor") or v.leaderstats:FindFirstChild("Bounty") or v.leaderstats:FindFirstChild("Honor")
        if bStat then bVal = tonumber(bStat.Value) or 0 end
    end
    if not ((vLevel >= 2400) or (vLevel == 0 and bVal >= 2400000)) then
        return false
    end
    local abSetting = _G.TommyAutoBountySettings
    if abSetting then
        if abSetting.Hunt and (bVal < (abSetting.Hunt.Min or 0) or bVal > (abSetting.Hunt.Max or 30000000)) then
            return false
        end
        if abSetting.Skip then
            if abSetting.Skip.Fruit and vData and vData:FindFirstChild("DevilFruit") then
                if hasValue(abSetting.Skip.FruitList, vData.DevilFruit.Value) then
                    return false
                end
            end
            if abSetting.Skip.V4 and char:FindFirstChild("RaceTransformed") and char.RaceTransformed.Value == true then
                return false
            end
        end
    end
    return true
end
getgenv().isCandidateTarget = isCandidateTarget
local function selectTarget(p)
    if not isCandidateTarget(p) then return end
    if getgenv().targ == p then return end
    getgenv().targ = p
    getgenv().AutoBountyReachedTarget = false
    getgenv().safeZoneWaitRetries = 0
    if UI and UI.SetTarget then
        UI.SetTarget(p.Name)
    end
    if UI and UI.ShowNotification then
        UI.ShowNotification("Target: " .. p.Name, "info")
    end
    local teamObject = p.Team
    local teamName = teamObject and teamObject.Name or ""
    local rType = (teamName == "Pirates") and "Bounty" or "Honor"
    local bVal = 0
    if p:FindFirstChild("leaderstats") then
        local bStat = p.leaderstats:FindFirstChild("Bounty/Honor") or p.leaderstats:FindFirstChild("Bounty") or p.leaderstats:FindFirstChild("Honor")
        if bStat then bVal = tonumber(bStat.Value) or 0 end
    end
    if UI and UI.UpdateTargetsList then
        UI.UpdateTargetsList({p.Name .. ": " .. (math.round((bVal / 1000000) * 100) / 100) .. "M " .. rType})
    end
end
getgenv().selectTarget = selectTarget
do
    local ServerPlayerStatus = {}
    local function logPlayerStatus(player, tag)
        pcall(function()
            if not player or player == LocalPlayer then return end
            local pvpOn = AX_ReadPvPState(player)
            local inSafe = AX_InSafeZone(player)
            local enemy = isEnemy(player)
            local pvpState = pvpOn and "PvP: ON" or "PvP: OFF"
            local zoneState = inSafe and "In SafeZone" or "Free Zone"
            print(string.format("[Tommy Monitor] %s: %s | %s | %s | %s",
                tag or "Info", player.Name, pvpState, zoneState, enemy and "Enemy" or "Neutral/Ally"))
        end)
    end
    bountyConnect(Players.PlayerAdded, function(newPlayer)
        task.spawn(function()
    if not isBountyCurrent() then return end
            task.wait(1)
            if not isBountyCurrent() then return end
            local pvpOn = AX_ReadPvPState(newPlayer)
            local inSafe = AX_InSafeZone(newPlayer)
            local pvpState = pvpOn and "PvP: ON" or "PvP: OFF"
            local zoneState = inSafe and "SafeZone" or "Free Zone"
            UI.ShowNotification("Joined: " .. newPlayer.Name .. " (" .. pvpState .. " | " .. zoneState .. ")", "info")
            logPlayerStatus(newPlayer, "NEW PLAYER")
            if (isBountyCurrent()) and not getgenv().targ and isCandidateTarget(newPlayer) then
                selectTarget(newPlayer)
            end
            bountyConnect(newPlayer.CharacterAdded, function()
                task.wait(0.5)
                if not isBountyCurrent() then return end
                logPlayerStatus(newPlayer, "RESPAWN")
                if (isBountyCurrent()) and not getgenv().targ and isCandidateTarget(newPlayer) then
                    selectTarget(newPlayer)
                end
            end)
        end)
    end)
    bountyConnect(Players.PlayerRemoving, function(leavingPlayer)
        if getgenv().targ == leavingPlayer then
            UI.ShowNotification(leavingPlayer.Name .. " left the server!", "warn")
            SkipPlayer(false)
        end
        ServerPlayerStatus[leavingPlayer] = nil
    end)
    task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and task.wait(0.2) do
            if not isBountyCurrent() then return end
            pcall(function()
                local countPvP = 0
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer then
                        local pvpOn = AX_ReadPvPState(pl)
                        local inSafe = AX_InSafeZone(pl)
                        local enemy = isEnemy(pl)
                        local prev = ServerPlayerStatus[pl]
                        if prev then
                            if not prev.pvpOn and pvpOn then
                                logPlayerStatus(pl, "ACTIVATED PVP")
                                if enemy and not inSafe and isCandidateTarget(pl) then
                                    if not getgenv().targ or AX_InSafeZone(getgenv().targ) or not AX_ReadPvPState(getgenv().targ) then
                                        selectTarget(pl)
                                    end
                                end
                            end
                            if prev.inSafe and not inSafe then
                                logPlayerStatus(pl, "LEFT SAFEZONE")
                                if enemy and pvpOn and isCandidateTarget(pl) then
                                    if not getgenv().targ or AX_InSafeZone(getgenv().targ) or not AX_ReadPvPState(getgenv().targ) then
                                        selectTarget(pl)
                                    end
                                end
                            end
                            if not prev.inSafe and inSafe and getgenv().targ == pl then
                                UI.ShowNotification(pl.Name .. " entered SafeZone!", "warn")
                                SkipPlayer(false)
                            end
                            if prev.pvpOn and not pvpOn and getgenv().targ == pl then
                                UI.ShowNotification(pl.Name .. " PvP disabled!", "warn")
                                SkipPlayer(false)
                            end
                        end
                        ServerPlayerStatus[pl] = {
                            pvpOn = pvpOn,
                            inSafe = inSafe,
                            enemy = enemy
                        }
                        if enemy and not inSafe and pvpOn and isCandidateTarget(pl) then
                            countPvP = countPvP + 1
                        end
                    end
                end
                if not getgenv().targ and countPvP > 0 then
                    target()
                end
            end)
        end
    end)
end
local Setting = _G.TommyAutoBountySettings
if not Setting then
    Setting = {
        ["Set"] = {
            ["Team"] = "Marines"
        },
        ["Chat"] = {
            ["Enabled"] = false,
            ["List"] = {""}
        }
    }
end
if not Setting.Melee then
    Setting.Melee = {
        ["Enable"] = true,
        ["Z"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["X"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["C"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["Delay"] = 1.5
    }
end
if not Setting.Sword then
    Setting.Sword = {
        ["Enable"] = true,
        ["Z"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["X"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["Delay"] = 1
    }
end
if not Setting.Gun then
    Setting.Gun = {
        ["Enable"] = true,
        ["Z"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["X"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["Delay"] = 1,
        ["GunMode"] = false
    }
end
if not Setting.Fruit then
    Setting.Fruit = {
        ["Enable"] = true,
        ["Z"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["X"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["C"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["F"] = {["Enable"] = true, ["HoldTime"] = 0.1},
        ["Delay"] = 1
    }
end
Setting.Fruit.V = nil
if not Setting.Click then
    Setting.Click = {
        ["FastAttack"] = true,
        ["AutoClick"] = true
    }
end
if not Setting.Hunt then
    Setting.Hunt = {
        ["Min"] = 0,
        ["Max"] = 30000000
    }
end
if not Setting.Skip then
    Setting.Skip = {
        ["V4"] = false,
        ["Fruit"] = false,
        ["FruitList"] = {"Buddha", "Leopard", "T-Rex"},
        ["MinLevel"] = 450,
        ["timer"] = 16
    }
end
if not Setting.SafeHealth then
    Setting.SafeHealth = {
        ["Health"] = 7000
    }
end
if not Setting.Another then
    Setting.Another = {
        ["V3"] = true,
        ["V4"] = true,
        ["CustomHealth"] = true,
        ["Health"] = 7000,
        ["WhiteScreen"] = false,
        ["FPSBoots"] = false,
        ["CamLock"] = false,
        ["AutoBuso"] = true,
        ["WalkWater"] = false
    }
end

while isBountyCurrent() do
    if not isBountyCurrent() then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if game:IsLoaded() and char and char:FindFirstChild("HumanoidRootPart") and hum and hum.Health > 0
        and ReplicatedStorage:FindFirstChild("Remotes") then break end
    task.wait(0.2)
    if not isBountyCurrent() then return end
end
if not isBountyCurrent() then return end
do

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualUser = game:GetService("VirtualUser")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local StarterGui = game:GetService("StarterGui")
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local CollectionService = game:GetService("CollectionService")

    local lp = Players.LocalPlayer
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local CommF = Remotes and Remotes:FindFirstChild("CommF_")
    local CommE = Remotes and Remotes:FindFirstChild("CommE")
    local Camera = Workspace.CurrentCamera
    bountyConnect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
        Camera = Workspace.CurrentCamera
    end)

    do
        local tries = 0
        while isBountyCurrent() and tries < 8 and (not lp.Team or lp.Team.Name ~= "Marines") do
            if CommF then pcall(function() CommF:InvokeServer("SetTeam", "Marines") end) end
            task.wait(1)
            tries = tries + 1
        end
    end
    local pGui = lp and (lp:FindFirstChild("PlayerGui") or lp:WaitForChild("PlayerGui", 5))
    if pGui and pGui:FindFirstChild("Main (minimal)") then
        local teamToSet = (Setting and Setting.Set and Setting.Set.Team) or "Marines"
        local tries = 0
        repeat
            if CommF then
                pcall(function() CommF:InvokeServer("SetTeam", teamToSet) end)
            end
            task.wait(2)
            if not isBountyCurrent() then return end
            tries = tries + 1
        until not isBountyCurrent() or not pGui:FindFirstChild("Main (minimal)") or tries >= 5
    end

    if pGui and not pGui:FindFirstChild("Main") then
        local waited = 0
        repeat
            task.wait(0.2)
            if not isBountyCurrent() then return end
            waited = waited + 0.2
        until not isBountyCurrent() or pGui:FindFirstChild("Main") or waited >= 5
    end

    if not isBountyCurrent() then return end
    getgenv().weapon = "Melee"
    getgenv().targ = nil
    getgenv().lasttarrget = nil
    getgenv().checked = getgenv().checked or {}
    getgenv().pl = Players:GetPlayers()
    getgenv().killed = nil
    getgenv().SpectateTarget = false
    getgenv().FruitTransform = false
    getgenv().UsedVWithoutBar = false
    getgenv().LastHP = 0
    _G.Earned = 0
    _G.TotalEarn = _G.TotalEarn or 0
    _G.Time = 0

    local function Notify(msg)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Tommy Bounty",
                Text = msg or "Activated",
                Duration = 5
            })
        end)
    end

    local World1, World2, World3 = false, false, false
    if workspace:FindFirstChild("Great Tree") then
        World3 = true
        Notify("Detected Sea 3!")
    elseif workspace:FindFirstChild("Cafe") then
        World2 = true
        Notify("Detected Sea 2!")
    elseif workspace:FindFirstChild("Starter Island") then
        World1 = true
        Notify("Detected Sea 1!")
    else
        Notify("Tommy Bounty Ready!")
    end

    local tween = nil
    local currentAutoBountyTargetCF = nil
    local cachedPartTele = nil
    local partTeleConnection = nil
    local lastToNoclipTime = 0
    local lastTrackAt = os.clock()
    local bountyCollision = setmetatable({}, {__mode="k"})

    local function cleanupAutoBountyTweenAndPart()
        if partTeleConnection then partTeleConnection:Disconnect(); partTeleConnection = nil end
        if tween then
            pcall(function() tween:Cancel() end)
            tween = nil
        end
        currentAutoBountyTargetCF = nil
        if cachedPartTele then pcall(function() cachedPartTele:Destroy() end); cachedPartTele = nil end
        for part, collision in pairs(bountyCollision) do
            if part.Parent then part.CanCollide = collision end
        end
        table.clear(bountyCollision)

        local char = lp.Character
        if char then
            if cachedPartTele and cachedPartTele.Parent == char then
                pcall(function() cachedPartTele:Destroy() end)
            end
            cachedPartTele = nil

            for _, child in ipairs(char:GetChildren()) do
                if child.Name == "PartTele" then
                    pcall(function() child:Destroy() end)
                end
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hold = hrp:FindFirstChild("Hold")
                if hold then pcall(function() hold:Destroy() end) end
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        else
            cachedPartTele = nil
        end
    end
    _G.CleanupAutoBountyTweenAndPart = cleanupAutoBountyTweenAndPart
    getgenv().CleanupAutoBountyTweenAndPart = cleanupAutoBountyTweenAndPart

    local function TweenToSky(height)
        local h = height or 1500
        pcall(function()
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                to(hrp.CFrame * CFrame.new(0, h, 0))
            end
        end)
    end

    local autoBountyNoclipConn = nil
    local function startAutoBountyNoclip()
        if not autoBountyNoclipConn then
            autoBountyNoclipConn = bountyConnect(RunService.Stepped, function()
                local isRunning = isBountyCurrent()
                if not isRunning then
                    if autoBountyNoclipConn then
                        autoBountyNoclipConn:Disconnect()
                        autoBountyNoclipConn = nil
                    end
                    return
                end
                local char = lp.Character
                if char then
                    local cachedParts = _G.cachedCharacterParts
                    if cachedParts and #cachedParts > 0 then
                        for i = 1, #cachedParts do
                            local p = cachedParts[i]
                            if p and p.CanCollide then bountyCollision[p] = true; p.CanCollide = false end
                        end
                    else
                        for _, p in ipairs(char:GetDescendants()) do
                            if p:IsA("BasePart") and p.CanCollide then bountyCollision[p] = true; p.CanCollide = false end
                        end
                    end
                end
            end)
        end
    end
    _G.StartAutoBountyNoclip = startAutoBountyNoclip

    local function stopAutoBountyNoclip()
        if autoBountyNoclipConn then
            pcall(function() autoBountyNoclipConn:Disconnect() end)
            autoBountyNoclipConn = nil
        end
    end
    _G.StopAutoBountyNoclip = stopAutoBountyNoclip

    function to(Pos)
        if not isBountyCurrent() then return end
        local okMove,moveError=pcall(function()
            local isRunning = isCurrentSession() and (isBountyCurrent())
            if not isRunning then
                cleanupAutoBountyTweenAndPart()
                stopAutoBountyNoclip()
                return
            end

            local char = lp.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then
                return
            end

            if cachedPartTele and cachedPartTele.Parent ~= char then cleanupAutoBountyTweenAndPart() end

            if hrp.Position.Y < 5 then
                hrp.CFrame = CFrame.new(hrp.Position.X, 35, hrp.Position.Z)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end

            if typeof(Pos) ~= "CFrame" then return end
            local targetPos = Pos
            if targetPos.Position.Y < 18 then
                targetPos = CFrame.new(targetPos.Position.X, 18, targetPos.Position.Z) * targetPos.Rotation
            end

            local distance = (targetPos.Position - hrp.Position).Magnitude

            startAutoBountyNoclip()

            if distance <= 25 then
                if tween then
                    pcall(function() tween:Cancel() end)
                    tween = nil
                end
                local currentCF = hrp.CFrame
                local now = os.clock()
                local dt = math.clamp(now - lastTrackAt, 0, 0.1)
                lastTrackAt = now
                local speed = Tommy.Runtime.number(getgenv().AutoBountyNearSpeed, 350, 25, 1000)
                local newCF = currentCF:Lerp(targetPos, math.min(1, speed * dt / math.max(distance, 0.001)))
                hrp.CFrame = newCF
                if cachedPartTele and cachedPartTele.Parent == char then
                    cachedPartTele.CFrame = newCF
                end
                currentAutoBountyTargetCF = targetPos
                return
            end

            if tween and tween.PlaybackState == Enum.PlaybackState.Playing and currentAutoBountyTargetCF then
                local drift = (targetPos.Position - currentAutoBountyTargetCF.Position).Magnitude
                if drift < 12 then
                    return
                end
            end

            local existingHold = hrp:FindFirstChild("Hold")
            if existingHold then pcall(function() existingHold:Destroy() end) end

            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

            if hum.Sit then
                hum.Sit = false
            end

            local partTele = cachedPartTele
            if not (partTele and partTele.Parent == char and partTele:IsA("BasePart")) then
                local stalePart = char:FindFirstChild("PartTele")
                if stalePart then stalePart:Destroy() end
                if partTeleConnection then partTeleConnection:Disconnect(); partTeleConnection = nil end
                partTele = nil
                if not partTele then
                    partTele = Instance.new("Part")
                    partTele.Size = Vector3.new(10, 1, 10)
                    partTele.Name = "PartTele"
                    partTele.Anchored = true
                    partTele.Transparency = 1
                    partTele.CanCollide = false
                    partTele.CFrame = hrp.CFrame
                    partTele.Parent = char
                    partTeleConnection = bountyConnect(partTele:GetPropertyChangedSignal("CFrame"), function()
                        local curRunning = isBountyCurrent()
                        if curRunning and lp.Character == char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = partTele.CFrame
                            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        end
                    end)
                end
                cachedPartTele = partTele
            end

            partTele.Anchored = true
            partTele.CanCollide = false
            if (partTele.Position - hrp.Position).Magnitude > 40 then
                partTele.CFrame = hrp.CFrame
            end

            local farSpeed = Tommy.Runtime.number(getgenv().AutoBountyFarSpeed, 160, 25, 1000)
            local nearSpeed = Tommy.Runtime.number(getgenv().AutoBountyNearSpeed, 350, 25, 1000)
            local speed = nearSpeed

            local curTarg = getgenv().targ
            if curTarg and curTarg.Character then
                local tHrp = curTarg.Character:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    local distToEnemy = (tHrp.Position - hrp.Position).Magnitude
                    if distToEnemy <= 300 then
                        getgenv().AutoBountyReachedTarget = true
                    end
                    if getgenv().AutoBountyReachedTarget then
                        speed = nearSpeed
                    else
                        speed = farSpeed
                    end
                else
                    speed = nearSpeed
                end
            else
                speed = nearSpeed
            end

            lastTrackAt = os.clock()
            local duration = math.max(distance / speed, 0.05)

            if tween then
                pcall(function() tween:Cancel() end)
                tween = nil
            end

            currentAutoBountyTargetCF = targetPos
            tween = TweenService:Create(
                partTele,
                TweenInfo.new(duration, Enum.EasingStyle.Linear),
                { CFrame = targetPos }
            )
            tween:Play()
        end)
        if not okMove then Tommy.ReportIssue("Auto Bounty tween",moveError) end
    end
    getgenv().to = to

    function buso()
        pcall(function()
            local char = lp.Character
            if char and not char:FindFirstChild("HasBuso") and char:GetAttribute("HasBuso") ~= true then
                if CommF then
                    CommF:InvokeServer("Buso")
                end
            end
        end)
    end

    function down(use, waitTime)
        if not isBountyCurrent() or (_G.TommySkillBlocked and _G.TommySkillBlocked(use)) then return end
        pcall(function()

            if string.upper(tostring(use)) == "V" then return end
            local char = lp.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if VirtualInputManager then
                    VirtualInputManager:SendKeyEvent(true, use, false, nil)
                    task.wait(waitTime or 0.1)
                    if not isBountyCurrent() then return end
                    VirtualInputManager:SendKeyEvent(false, use, false, nil)
                end
            end
        end)
    end

    function equip(tooltip)
        local char = lp.Character
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end

        local curTool = char:FindFirstChildOfClass("Tool")
        if curTool and curTool.ToolTip == tooltip then
            return true
        end

        local bp = lp:FindFirstChildOfClass("Backpack") or lp:FindFirstChild("Backpack")
        if not bp then return false end

        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and item.ToolTip == tooltip then
                hum:EquipTool(item)
                return true
            end
        end
        return false
    end

    local lastBountyClick = -math.huge
    function Click()
        if not isBountyCurrent() or os.clock() - lastBountyClick < 0.10 then return end
        lastBountyClick = os.clock()
        if getgenv().HealingInSky then return end
        pcall(function()
            local _ENV = (getgenv or getrenv or getfenv)()
            if _ENV and _ENV.rz_FastAttack then
                _ENV.rz_FastAttack:BladeHits()
            end
            if mouse1click then
                mouse1click()
                return
            end
            if VirtualUser then
                VirtualUser:Button1Down(Vector2.new(0, 1, 0, 1))
                task.wait(0.04)
                if not isBountyCurrent() then return end
                VirtualUser:Button1Up(Vector2.new(0, 1, 0, 1))
            end
        end)
    end

    local waterPart = workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
    local lastWaterWalk = nil
    local lastWaterSize = nil
    task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and RunService.Stepped:wait() do
            if not isBountyCurrent() then return end
            pcall(function()
                local char = lp.Character
                if char then
                    local cachedParts = _G.cachedCharacterParts
                    if cachedParts and #cachedParts > 0 then
                        for i = 1, #cachedParts do
                            local v = cachedParts[i]
                            if v and v ~= waterPart and v.CanCollide then
                                v.CanCollide = false
                            end
                        end
                    else
                        for _, v in ipairs(char:GetChildren()) do
                            if v:IsA("BasePart") and v ~= waterPart and v.CanCollide then
                                v.CanCollide = false
                            end
                        end
                    end
                end
                if waterPart then
                    local shouldWalk = (Setting.Another and Setting.Another.WalkWater == true) or (FeatureStates and FeatureStates["WalkOnWater"] == true)
                    local targetSize = shouldWalk and Vector3.new(1000, 115, 1000) or Vector3.new(1000, 80, 1000)
                    if lastWaterWalk ~= shouldWalk or lastWaterSize ~= targetSize then
                        waterPart.CanCollide = shouldWalk
                        waterPart.Size = targetSize
                        lastWaterWalk = shouldWalk
                        lastWaterSize = targetSize
                    end
                end
            end)
        end
    end)

    if Setting.Another and Setting.Another.FPSBoots then
        local removedecals = false
        local w = Workspace
        local l = game:GetService("Lighting")
        local t = w.Terrain
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
        l.GlobalShadows = false
        l.FogEnd = 9e9
        l.Brightness = 0
        pcall(function() settings().Rendering.QualityLevel = "Level01" end)
        for _, v in ipairs(w:GetChildren()) do
            if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                v.Material = "Plastic"
                v.Reflectance = 0
            end
        end
        for _, e in ipairs(l:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end
    end

    if Setting.Another and Setting.Another.WhiteScreen then
        RunService:Set3dRenderingEnabled(false)
    end

    if Setting.Click and Setting.Click.FastAttack then
        local _ENV = (getgenv or getrenv or getfenv)()
        local SafeWaitForChild = function(parent, childName)
            if not parent then return nil end
            local found = parent:FindFirstChild(childName)
            if found then return found end
            local ok, res = pcall(function() return parent:WaitForChild(childName, 3) end)
            return ok and res or nil
        end

        local ChestModels = SafeWaitForChild(Workspace, "ChestModels")
        local WorldOrigin = SafeWaitForChild(Workspace, "_WorldOrigin")
        local Characters = SafeWaitForChild(Workspace, "Characters")
        local Enemies = SafeWaitForChild(Workspace, "Enemies")
        local Modules = SafeWaitForChild(ReplicatedStorage, "Modules")
        local Net = SafeWaitForChild(Modules, "Net")

        local FastSettings = {
            AutoClick = true,
            ClickDelay = 0
        }

        local Module = {}
        Module.FastAttack = (function()
            if _ENV.rz_FastAttack then
                return _ENV.rz_FastAttack
            end
            local FastAttack = {
                Distance = 150,
                attackMobs = true,
                attackPlayers = true,
                Equipped = nil
            }
            local RegisterAttack = Net and SafeWaitForChild(Net, "RE/RegisterAttack")
            local RegisterHit = Net and SafeWaitForChild(Net, "RE/RegisterHit")

            local function IsAlive(character)
                local hum = character and character:FindFirstChildOfClass("Humanoid")
                return hum and hum.Health > 0
            end

            local function ProcessEnemies(OthersEnemies, Folder)
                if not Folder then return nil end
                local BasePart = nil
                local myChar = lp.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myPos = myHrp and myHrp.Position
                if not myPos then return nil end

                for _, Enemy in ipairs(Folder:GetChildren()) do
                    local targetPlayer = Players:GetPlayerFromCharacter(Enemy)
                    local allowed = not targetPlayer or (_G.TommyCombatTargetValid and _G.TommyCombatTargetValid(targetPlayer,150))
                    if Enemy ~= myChar and IsAlive(Enemy) and allowed then
                        local Head = Enemy:FindFirstChild("Head") or Enemy:FindFirstChild("HumanoidRootPart")
                        if Head and (Head.Position - myPos).Magnitude < FastAttack.Distance then
                            table.insert(OthersEnemies, { Enemy, Head })
                            BasePart = Head
                        end
                    end
                end
                return BasePart
            end

            function FastAttack:Attack(BasePart, OthersEnemies)
                if not BasePart or #OthersEnemies == 0 then return end
                if RegisterAttack then RegisterAttack:FireServer(FastSettings.ClickDelay or 0) end
                if RegisterHit then RegisterHit:FireServer(BasePart, OthersEnemies) end
            end

            function FastAttack:AttackNearest()
                if not isBountyCurrent() or not Tommy.TakeAttackBudget("M1",0.15) then return end
                local OthersEnemies = {}
                local Part1 = ProcessEnemies(OthersEnemies, Enemies)
                local Part2 = ProcessEnemies(OthersEnemies, Characters)
                local character = lp.Character
                if not character then return end
                local equippedWeapon = character:FindFirstChildOfClass("Tool")
                if equippedWeapon and equippedWeapon:FindFirstChild("LeftClickRemote") then
                    local pivotPos = character:GetPivot().Position
                    for _, enemyData in ipairs({OthersEnemies[1]}) do
                        local enemy = enemyData[1]
                        local eHrp = enemy:FindFirstChild("HumanoidRootPart")
                        if eHrp then
                            local direction = (eHrp.Position - pivotPos).Unit
                            pcall(function()
                                equippedWeapon.LeftClickRemote:FireServer(direction, 1)
                            end)
                        end
                    end
                elseif #OthersEnemies > 0 then
                    self:Attack(Part1 or Part2, OthersEnemies)
                end
            end

            function FastAttack:BladeHits()
                local char = lp.Character
                if IsAlive(char) and not char:GetAttribute("UsingSkill") and not char:GetAttribute("isUsingSkill") and not char:GetAttribute("Busy") then
                    local equipped = char:FindFirstChildOfClass("Tool")
                    if equipped and equipped.ToolTip ~= "Gun" then
                        self:AttackNearest()
                    end
                end
            end

            task.spawn(function()
    if not isBountyCurrent() then return end
                while isBountyCurrent() and task.wait(math.max(tonumber(FastSettings.ClickDelay) or 0.1, 0.1)) do
                    if not isBountyCurrent() then return end
                    if FastSettings.AutoClick and not getgenv().HealingInSky then
                        FastAttack:BladeHits()
                    end
                end
            end)

            _ENV.rz_FastAttack = FastAttack
            return FastAttack
        end)()
    end

    local stopbypass = false
    task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and task.wait(0.5) do
            if not isBountyCurrent() then return end
            if _G.hopserver then
                stopbypass = true
            end
        end
    end)

    function CheckInComBat()
        local inCombat = false
        pcall(function()
            local playerGui = lp:FindFirstChild("PlayerGui")
            local main = playerGui and playerGui:FindFirstChild("Main")
            local bList = main and main:FindFirstChild("BottomHUDList")
            local ic = bList and bList:FindFirstChild("InCombat")
            if ic and ic.Visible and ic.Text and string.find(string.lower(ic.Text), "risk") then
                inCombat = true
            end
        end)
        return inCombat
    end

    function HopServer(counts)
        local countLimit = counts or 8
        local function dismissPrompt(v)
            if v and v.Name == "ErrorPrompt" then
                if v.Visible then
                    local tf = v:FindFirstChild("TitleFrame")
                    local et = tf and tf:FindFirstChild("ErrorTitle")
                    if et and et.Text == "Teleport Failed" then
                        v.Visible = false
                    end
                end
                bountyConnect(v:GetPropertyChangedSignal("Visible"), function()
                    if v.Visible then
                        local tf = v:FindFirstChild("TitleFrame")
                        local et = tf and tf:FindFirstChild("ErrorTitle")
                        if et and et.Text == "Teleport Failed" then
                            v.Visible = false
                        end
                    end
                end)
            end
        end

        pcall(function()
            local promptOverlay = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
            and game:GetService("CoreGui").RobloxPromptGui:FindFirstChild("promptOverlay")
            if promptOverlay then
                for _, v in ipairs(promptOverlay:GetChildren()) do
                    dismissPrompt(v)
                end
                bountyConnect(promptOverlay.ChildAdded, dismissPrompt)
            end
        end)

        pcall(function()
            local playerGui = lp:FindFirstChild("PlayerGui")
            local sb = playerGui and playerGui:FindFirstChild("ServerBrowser")
            local frame = sb and sb:FindFirstChild("Frame")
            local filters = frame and frame:FindFirstChild("Filters")
            local region = filters and filters:FindFirstChild("SearchRegion")
            local tb = region and region:FindFirstChild("TextBox")
            if tb then tb.Text = "Singapore" end
        end)

        while isBountyCurrent() and task.wait(1) do

            if not isBountyCurrent() then return end
            if not CheckInComBat() then
                for r = 1, 100 do
                    local s, servers = pcall(function()
                        return ReplicatedStorage.__ServerBrowser:InvokeServer(r)
                    end)
                    if s and type(servers) == "table" then
                        for k, v in pairs(servers) do
                            if k ~= game.JobId and type(v) == "table" and v["Count"] and v["Count"] <= countLimit then
                                ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", k)
                            end
                        end
                    else
                        pcall(function()
                            TeleportService:Teleport(game.PlaceId)
                        end)
                        break
                    end
                end
            end
        end
    end
    getgenv().HopServer = HopServer

    function SkipPlayer(isKilled)
        local oldTarg = getgenv().targ
        getgenv().targ = nil
        getgenv().AutoBountyReachedTarget = false
        if UI and UI.SetTarget then UI.SetTarget("None") end
        if oldTarg then
            if isKilled == true then
                if not hasValue(getgenv().checked, oldTarg) then
                    table.insert(getgenv().checked, oldTarg)
                end
                if UI and UI.ShowNotification then
                    UI.ShowNotification("Target defeated: " .. oldTarg.Name, "info")
                end
            else
                if UI and UI.ShowNotification then
                    UI.ShowNotification("Target in SafeZone or protected, pausing: " .. oldTarg.Name, "warn")
                end
            end
        end
        if tween then pcall(function() tween:Cancel() end) end
        pcall(function()
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hold = hrp:FindFirstChild("Hold")
                if hold then hold.Velocity = Vector3.zero end
                hrp.Velocity = Vector3.zero
            end
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and Camera then
                Camera.CameraSubject = hum
            end
        end)
        target()
    end
    getgenv().SkipPlayer = SkipPlayer

    local isTargeting = false
    local targetReadyAt = os.clock() + 5
    local nextTargetScan = 0
    function target()
        local isRunning = isBountyCurrent()
        if not isRunning then
            isTargeting = false
            pcall(function()
                local c = lp and lp.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("Hold") then
                    hrp.Hold:Destroy()
                end
            end)
            return
        end
        if isTargeting or os.clock() < nextTargetScan then return end
        nextTargetScan = os.clock() + 0.35
        isTargeting = true

        pcall(function()
            local myChar = lp.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHrp then
                isTargeting = false
                return
            end
            local myPos = myHrp.Position

            local bestTarget = nil
            local bestDist = math.huge
            local totalPvPEnemies = 0
            local enemiesInSafeZone = 0

            local checkedList = getgenv().checked or {}
            local abSetting = _G.TommyAutoBountySettings or Setting
            local huntMin = (abSetting and abSetting.Hunt and abSetting.Hunt.Min) or 0
            local huntMax = (abSetting and abSetting.Hunt and abSetting.Hunt.Max) or 30000000
            local skipFruit = (abSetting and abSetting.Skip and abSetting.Skip.Fruit)
            local fruitList = (abSetting and abSetting.Skip and abSetting.Skip.FruitList) or {}
            local skipV4 = (abSetting and abSetting.Skip and abSetting.Skip.V4)

            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= lp and isEnemy(v) and not hasValue(checkedList, v) then
                    if not (_G.isPlayerBlacklisted and _G.isPlayerBlacklisted(v)) then
                        local pvpOn = AX_ReadPvPState(v)
                        local char = v.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if pvpOn and hrp and hum and hum.Health > 0 and hrp.Position.Y <= 12000 then
                            local vData = v:FindFirstChild("Data")
                            local vLevel = _G.getPlayerLevel and _G.getPlayerLevel(v) or (vData and vData:FindFirstChild("Level") and tonumber(vData.Level.Value) or 0)
                            local bVal = 0
                            local lstats = v:FindFirstChild("leaderstats")
                            if lstats then
                                local bStat = lstats:FindFirstChild("Bounty/Honor") or lstats:FindFirstChild("Bounty") or lstats:FindFirstChild("Honor")
                                if bStat then bVal = tonumber(bStat.Value) or 0 end
                            end

                            local levelOk = (vLevel >= 2400) or (vLevel == 0 and bVal >= 2400000)
                            if levelOk then
                                totalPvPEnemies = totalPvPEnemies + 1
                                local inSafe = AX_InSafeZone(v)
                                if inSafe then
                                    enemiesInSafeZone = enemiesInSafeZone + 1
                                else
                                    local fruitOk = true
                                    if skipFruit and vData and vData:FindFirstChild("DevilFruit") then
                                        if hasValue(fruitList, vData.DevilFruit.Value) then
                                            fruitOk = false
                                        end
                                    end

                                    local v4Ok = true
                                    if skipV4 and char:FindFirstChild("RaceTransformed") and char.RaceTransformed.Value == true then
                                        v4Ok = false
                                    end

                                    local bOk = (bVal >= huntMin and bVal <= huntMax)

                                    if fruitOk and v4Ok and bOk then
                                        local dist = (hrp.Position - myPos).Magnitude
                                        if dist < bestDist then
                                            bestTarget = v
                                            bestDist = dist
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if bestTarget == nil then
                if os.clock() < targetReadyAt then return end
                if totalPvPEnemies > 0 and enemiesInSafeZone > 0 and (getgenv().safeZoneWaitRetries or 0) < 5 then
                    getgenv().safeZoneWaitRetries = (getgenv().safeZoneWaitRetries or 0) + 1
                    if UI and UI.ShowNotification then
                        UI.ShowNotification("Target(s) in SafeZone (" .. enemiesInSafeZone .. "), watching... (" .. getgenv().safeZoneWaitRetries .. "/5)", "info")
                    end
                    task.wait(2)
                    if not isBountyCurrent() then return end
                    isTargeting = false
                    if not getgenv().targ then
                        target()
                    end
                    return
                end
                getgenv().safeZoneWaitRetries = 0
                if myHrp then
                    to(myHrp.CFrame * CFrame.new(0, math.random(50000, 200000), 0))
                end
                task.wait(1)
                if not isBountyCurrent() then return end
                if CheckInComBat() then
                    if UI and UI.ShowNotification then
                        UI.ShowNotification("Waiting for combat to end before server hop...", "warn")
                    end
                    repeat
                        task.wait(1)
                        if not isBountyCurrent() then return end
                        local curHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        if curHrp then
                            to(curHrp.CFrame * CFrame.new(0, 500, 0))
                        end
                    until not CheckInComBat() or not isBountyCurrent() or not isCurrentSession()
                end
                if UI and UI.ShowNotification then
                    UI.ShowNotification("No valid PvP targets >2400 in server, hopping...", "warn")
                end
                task.wait(2)
                if not isBountyCurrent() then return end
                if isBountyCurrent() and isCurrentSession() then HopServer() end
            else
                selectTarget(bestTarget)
            end
        end)
        isTargeting = false
    end
    getgenv().target = target

    function CheckSafeZone(nitga)
        if not nitga then return false end
        local wo = workspace:FindFirstChild("_WorldOrigin")
        local safeZones = wo and wo:FindFirstChild("SafeZones")
        if safeZones then
            for _, v in ipairs(safeZones:GetChildren()) do
                if v:IsA("BasePart") then
                    if (v.Position - nitga.Position).Magnitude <= 400 then
                        return true
                    end
                end
            end
        end
        return false
    end

    local function HasTag(tagName)
        local char = lp.Character
        if not char then return false end
        return CollectionService:HasTag(char, tagName)
    end

    local kenCooldown = 0
    function Ken()
        if tick() - kenCooldown < 1.5 then return end
        kenCooldown = tick()
        task.spawn(function()
    if not isBountyCurrent() then return end
            pcall(function()
                if HasTag("Ken") then
                    local playerGui = lp:FindFirstChild("PlayerGui")
                    if playerGui then
                        local mob = playerGui:FindFirstChild("MobileContextButtons")
                        local frame = mob and mob:FindFirstChild("ContextButtonFrame")
                        local kenBtn = frame and frame:FindFirstChild("BoundActionKen")
                        if kenBtn and kenBtn:GetAttribute("Selected") ~= true then
                            kenBtn:SetAttribute("Selected", true)
                        end
                    end
                    local renvG = getrenv and getrenv()._G
                    local om = renvG and renvG.OM
                    if om and not om.active then
                        om.radius = 0
                        om:setActive(true)
                        if CommE then CommE:FireServer("Ken", true) end
                    elseif not om then
                        if CommE then CommE:FireServer("Ken", true) end
                    end
                end
            end)
        end)
    end

    task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and task.wait(0.5) do
            if not isBountyCurrent() then return end
            pcall(function()
                local curTarg = getgenv().targ
                local myChar = lp.Character
                if curTarg and curTarg.Character and myChar then
                    local tHrp = curTarg.Character:FindFirstChild("HumanoidRootPart")
                    local mHrp = myChar:FindFirstChild("HumanoidRootPart")
                    if tHrp and mHrp and (tHrp.Position - mHrp.Position).Magnitude < 40 then
                        Ken()
                    end
                end
            end)
        end
    end)

    task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and task.wait(0.2) do
            if not isBountyCurrent() then return end
            pcall(function()
                if isLocalPvpDisabled() then
                    if CommF then CommF:InvokeServer("EnablePvp") end
                end
                local curTarg = getgenv().targ
                local myChar = lp.Character
                if curTarg and curTarg.Character and myChar then
                    local tHrp = curTarg.Character:FindFirstChild("HumanoidRootPart")
                    local mHrp = myChar:FindFirstChild("HumanoidRootPart")
                    if tHrp and mHrp and (tHrp.Position - mHrp.Position).Magnitude < 50 then
                        buso()
                        if Setting.Another and Setting.Another.V3 then
                            local hum = myChar:FindFirstChildOfClass("Humanoid")
                            if Setting.Another.CustomHealth and hum and hum.Health <= Setting.Another.Health then
                                down("T", 0.1)
                            end
                        end

                        if (FeatureStates["AutoV4Bounty"] or getgenv().AutoV4Bounty or FeatureStates["AutoV4"]) then
                            local energy = myChar:FindFirstChild("RaceEnergy")
                            local transformed = myChar:FindFirstChild("RaceTransformed")
                            local stun = myChar:FindFirstChild("Stun")
                            local busy = myChar:FindFirstChild("Busy")

                            local hasEnergy = energy and tonumber(energy.Value) and tonumber(energy.Value) >= 1
                            local notTransformed = not transformed or (transformed.Value ~= true)
                            local notStunned = not stun or (tonumber(stun.Value) or 0) <= 0
                            local notBusy = not busy or (busy.Value ~= true)

                            if hasEnergy and notTransformed and notStunned and notBusy then
                                if CommE then
                                    pcall(function() CommE:FireServer("ActivateAwakening", true) end)
                                end
                                if VirtualInputManager then
                                    pcall(function()
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                                        task.wait(0.05)
                                        if not isBountyCurrent() then return end
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                                    end)
                                end
                                local bp = lp:FindFirstChildOfClass("Backpack") or lp:FindFirstChild("Backpack")
                                local awk = bp and bp:FindFirstChild("Awakening")
                                if awk then
                                    local rf = awk:FindFirstChild("RemoteFunction")
                                    if rf and rf:IsA("RemoteFunction") then pcall(function() rf:InvokeServer(true) end) end
                                    local re = awk:FindFirstChild("RemoteEvent")
                                    if re and re:IsA("RemoteEvent") then pcall(function() re:FireServer(true) end) end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)

    task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and task.wait(0.1) do
            if not isBountyCurrent() then return end
            pcall(function()
                local curTarg = getgenv().targ
                local myChar = lp.Character
                if curTarg and curTarg.Character and myChar then
                    local tHrp = curTarg.Character:FindFirstChild("HumanoidRootPart")
                    local mHrp = myChar:FindFirstChild("HumanoidRootPart")
                    if tHrp and mHrp and (tHrp.Position - mHrp.Position).Magnitude < 40 then
                        if Setting.Melee and Setting.Melee.Enable then
                            if not isBountyCurrent() then return end
    getgenv().weapon = "Melee"
                            task.wait(Setting.Melee.Delay or 0.1)
                            if not isBountyCurrent() then return end
                        end
                        if Setting.Fruit and Setting.Fruit.Enable then
                            getgenv().weapon = "Blox Fruit"
                            task.wait(Setting.Fruit.Delay or 0.1)
                            if not isBountyCurrent() then return end
                        end
                        if Setting.Sword and Setting.Sword.Enable then
                            getgenv().weapon = "Sword"
                            task.wait(Setting.Sword.Delay or 0.1)
                            if not isBountyCurrent() then return end
                        end
                        if Setting.Gun and Setting.Gun.Enable then
                            getgenv().weapon = "Gun"
                            task.wait(Setting.Gun.Delay or 0.1)
                            if not isBountyCurrent() then return end
                        end
                    end
                end
            end)
        end
    end)

    local function StartNoDamageTimer(targetPlayer)
        if not targetPlayer or not targetPlayer.Character then return end
        if getgenv().NoDamageRunning then return end
        getgenv().NoDamageRunning = true
        task.spawn(function()
    if not isBountyCurrent() then return end
            local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not hum then
                getgenv().NoDamageRunning = false
                return
            end
            local counter = (Setting.Skip and Setting.Skip.timer) or 16
            local lastHealth = hum.Health
            local damaged = false
            local combat = false
            while isBountyCurrent() and counter > 0 and getgenv().targ == targetPlayer do
                if not isBountyCurrent() then return end
                task.wait(1)
                if not isBountyCurrent() then return end
                if not getgenv().HealingInSky then
                    if hum.Health < lastHealth then
                        damaged = true
                    end
                    lastHealth = hum.Health
                    if CheckInComBat() then
                        combat = true
                    end
                    counter = counter - 1
                end
            end
            if getgenv().targ == targetPlayer and damaged == false and combat == false and not getgenv().HealingInSky then
                SkipPlayer(true)
            end
            getgenv().NoDamageRunning = false
        end)
    end

    local cachedSkillsGui = nil
    local lastNotifCheck = 0

    task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and task.wait() do
            if not isBountyCurrent() then return end
            if not getgenv().targ or not getgenv().targ.Character then
                target()
            end
            pcall(function()
                if getgenv().HealingInSky then return end
                local curTarg = getgenv().targ
                local myChar = lp.Character
                if curTarg and curTarg.Character and myChar then
                    local tHrp = curTarg.Character:FindFirstChild("HumanoidRootPart")
                    local mHrp = myChar:FindFirstChild("HumanoidRootPart")
                    if tHrp and mHrp and (tHrp.Position - mHrp.Position).Magnitude < 40 then
                        StartNoDamageTimer(curTarg)

                        local desiredWep = getgenv().weapon or "Melee"
                        local curTool = myChar:FindFirstChildOfClass("Tool")
                        if not curTool or curTool.ToolTip ~= desiredWep then
                            equip(desiredWep)
                            curTool = myChar:FindFirstChildOfClass("Tool")
                        end

                        if curTool then
                            local toolTip = curTool.ToolTip
                            local skillGui = cachedSkillsGui
                            if not (skillGui and skillGui.Parent) then
                                local playerGui = lp:FindFirstChild("PlayerGui")
                                local main = playerGui and playerGui:FindFirstChild("Main")
                                skillGui = main and main:FindFirstChild("Skills")
                                cachedSkillsGui = skillGui
                            end

                            local skillFrame = skillGui and skillGui:FindFirstChild(curTool.Name)

                            if toolTip == "Melee" and Setting.Melee and Setting.Melee.Enable and skillFrame then
                                if Setting.Melee.Z and Setting.Melee.Z.Enable and skillFrame:FindFirstChild("Z") and skillFrame.Z.Cooldown.AbsoluteSize.X <= 0 then
                                    down("Z", Setting.Melee.Z.HoldTime)
                                elseif Setting.Melee.X and Setting.Melee.X.Enable and skillFrame:FindFirstChild("X") and skillFrame.X.Cooldown.AbsoluteSize.X <= 0 then
                                    down("X", Setting.Melee.X.HoldTime)
                                elseif Setting.Melee.C and Setting.Melee.C.Enable and skillFrame:FindFirstChild("C") and skillFrame.C.Cooldown.AbsoluteSize.X <= 0 then
                                    down("C", Setting.Melee.C.HoldTime)
                                else
                                    Click()
                                end
                            elseif toolTip == "Gun" and Setting.Gun and Setting.Gun.Enable and skillFrame then
                                if Setting.Gun.Z and Setting.Gun.Z.Enable and skillFrame:FindFirstChild("Z") and skillFrame.Z.Cooldown.AbsoluteSize.X <= 0 then
                                    down("Z", Setting.Gun.Z.HoldTime)
                                elseif Setting.Gun.X and Setting.Gun.X.Enable and skillFrame:FindFirstChild("X") and skillFrame.X.Cooldown.AbsoluteSize.X <= 0 then
                                    down("X", Setting.Gun.X.HoldTime)
                                else
                                    Click()
                                end
                            elseif toolTip == "Sword" and Setting.Sword and Setting.Sword.Enable and skillFrame then
                                if Setting.Sword.Z and Setting.Sword.Z.Enable and skillFrame:FindFirstChild("Z") and skillFrame.Z.Cooldown.AbsoluteSize.X <= 0 then
                                    down("Z", Setting.Sword.Z.HoldTime)
                                elseif Setting.Sword.X and Setting.Sword.X.Enable and skillFrame:FindFirstChild("X") and skillFrame.X.Cooldown.AbsoluteSize.X <= 0 then
                                    down("X", Setting.Sword.X.HoldTime)
                                else
                                    Click()
                                end
                            elseif toolTip == "Blox Fruit" and Setting.Fruit and Setting.Fruit.Enable and skillFrame then
                                if Setting.Fruit.Z and Setting.Fruit.Z.Enable and skillFrame:FindFirstChild("Z") and skillFrame.Z.Cooldown.AbsoluteSize.X <= 0 then
                                    down("Z", Setting.Fruit.Z.HoldTime)
                                elseif Setting.Fruit.X and Setting.Fruit.X.Enable and skillFrame:FindFirstChild("X") and skillFrame.X.Cooldown.AbsoluteSize.X <= 0 then
                                    down("X", Setting.Fruit.X.HoldTime)
                                elseif Setting.Fruit.C and Setting.Fruit.C.Enable and skillFrame:FindFirstChild("C") and skillFrame.C.Cooldown.AbsoluteSize.X <= 0 then
                                    down("C", Setting.Fruit.C.HoldTime)
                                elseif Setting.Fruit.F and Setting.Fruit.F.Enable and skillFrame:FindFirstChild("F") and skillFrame.F.Cooldown.AbsoluteSize.X <= 0 then
                                    down("F", Setting.Fruit.F.HoldTime)
                                else
                                    Click()
                                end
                            else
                                Click()
                            end
                        else
                            Click()
                        end

                        local now = tick()
                        if now - lastNotifCheck > 0.3 then
                            lastNotifCheck = now
                            local playerGui = lp:FindFirstChild("PlayerGui")
                            local notifs = playerGui and playerGui:FindFirstChild("Notifications")
                            if notifs and curTarg then
                                local targNameLower = string.lower(curTarg.Name)
                                for _, v in ipairs(notifs:GetChildren()) do
                                    if v:IsA("TextLabel") then
                                        local textLower = string.lower(v.Text)
                                        if string.find(textLower, targNameLower) and (string.find(textLower, "died") or string.find(textLower, "left") or string.find(textLower, "killed")) then
                                            SkipPlayer(true)
                                            pcall(function() v:Destroy() end)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)

    local helloae = false
    local b = nil
    local cachedIsland1 = nil

    task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and task.wait() do
            if not isBountyCurrent() then return end
            if not getgenv().targ then target() end
            pcall(function()
                local curTarg = getgenv().targ
                local myChar = lp.Character
                if curTarg and curTarg.Character and myChar then
                    local targetHRP = curTarg.Character:FindFirstChild("HumanoidRootPart")
                    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                    local myHum = myChar:FindFirstChildOfClass("Humanoid")
                    if targetHRP and myHRP and myHum then
                        local currentPos = targetHRP.Position
                        local dist = (currentPos - myHRP.Position).Magnitude
                        local isMoving = (b and (currentPos - b).Magnitude > 1) or false
                        b = currentPos

                        local gotoPos
                        local targetY = math.max(targetHRP.Position.Y, 18)
                        if dist < 40 then

                            gotoPos = targetHRP.CFrame * CFrame.new(0, 7.5, -6)
                        elseif dist < 120 then

                            gotoPos = targetHRP.CFrame * CFrame.new(0, 14, -12)
                        else

                            local transitY = math.max(targetY + 45, 95)
                            gotoPos = CFrame.new(targetHRP.Position.X, transitY, targetHRP.Position.Z)
                        end
                        if gotoPos.Position.Y < 18 then
                            gotoPos = CFrame.new(gotoPos.Position.X, 18, gotoPos.Position.Z) * gotoPos.Rotation
                        end

                        local maxHp = myHum.MaxHealth > 0 and myHum.MaxHealth or 12000
                        local healThreshold = tonumber(getgenv().TommyHealThreshold) or (Setting.SafeHealth and Setting.SafeHealth.Health) or 5000

                        local returnHP = tonumber(getgenv().TommyHealReturnHP) or 6000
                        if myHum.Health >= returnHP then
                            getgenv().CancelHealing = false
                            if getgenv().HealingInSky then
                                getgenv().HealingInSky = false
                                pcall(function()
                                    if tween then tween:Cancel() end
                                    local pt = myChar:FindFirstChild("PartTele")
                                    if pt then pt:Destroy() end
                                    cachedPartTele = nil
                                    myHRP.AssemblyLinearVelocity = Vector3.zero
                                end)
                            end
                        end

                        if not getgenv().HealingInSky then
                            if myHum.Health < healThreshold and not getgenv().CancelHealing then
                                getgenv().HealingInSky = true
                            end
                        else

                            if getgenv().CancelHealing or myHum.Health >= (tonumber(getgenv().TommyHealReturnHP) or 6000) then
                                getgenv().HealingInSky = false
                                pcall(function()
                                    if tween then tween:Cancel() end
                                    local pt = myChar:FindFirstChild("PartTele")
                                    if pt then pt:Destroy() end
                                    cachedPartTele = nil
                                    myHRP.AssemblyLinearVelocity = Vector3.zero
                                end)
                            end
                        end

                        if getgenv().HealingInSky and not getgenv().CancelHealing then

                            local skyTargetCF = targetHRP.CFrame * CFrame.new(0, 1500, 0)
                            to(skyTargetCF)
                        else

                            pcall(function()
                                local isl1 = cachedIsland1
                                if not (isl1 and isl1.Parent) then
                                    local wo = workspace:FindFirstChild("_WorldOrigin")
                                    local locs = wo and wo:FindFirstChild("Locations")
                                    isl1 = locs and locs:FindFirstChild("Island 1")
                                    cachedIsland1 = isl1
                                end

                                if isl1 and (targetHRP.Position - isl1.Position).Magnitude < 500 then
                                    print("Raid")
                                    SkipPlayer(false)
                                    return
                                end

                                if not AX_ReadPvPState(curTarg) then
                                    SkipPlayer(false)
                                    return
                                end
                                if AX_InSafeZone(curTarg) then
                                    SkipPlayer(false)
                                    return
                                end

                                if Camera then
                                    local desiredSubject = getgenv().SpectateTarget and curTarg.Character or myHum
                                    if desiredSubject and Camera.CameraSubject ~= desiredSubject then
                                        Camera.CameraSubject = desiredSubject
                                    end
                                end

                                local tHum = curTarg.Character:FindFirstChildOfClass("Humanoid")
                                if tHum then
                                    if tHum.Health > 0 then
                                        to(gotoPos)
                                    else
                                        SkipPlayer(true)
                                    end
                                end
                            end)
                            helloae = (targetHRP.CFrame.Y >= 10)
                        end
                    end
                end
            end)
        end
    end)

    local aim = false
    local CFrameHunt

    task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and task.wait() do
            if not isBountyCurrent() then return end
            local curTarg = getgenv().targ
            local myChar = lp.Character
            if curTarg and curTarg.Character and myChar then
                local tHrp = curTarg.Character:FindFirstChild("HumanoidRootPart")
                local mHrp = myChar:FindFirstChild("HumanoidRootPart")
                if tHrp and mHrp then
                    local dist = (tHrp.Position - mHrp.Position).Magnitude
                    if dist < 40 then
                        aim = true
                        local offsetDist = (Setting.Gun and Setting.Gun.Enable and Setting.Gun.GunMode) and 2 or 5
                        CFrameHunt = CFrame.new(
                            tHrp.Position + tHrp.CFrame.LookVector * offsetDist,
                            tHrp.Position
                        )
                    else
                        aim = false
                    end

                    local targetRoot = tHrp or curTarg.Character:FindFirstChild("Head")
                    if targetRoot then
                        _G.G_SilentAimTargetPos = targetRoot.Position
                        if Setting.Another and Setting.Another.CamLock and Camera then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
                        end
                    end
                else
                    aim = false
                end
            else
                aim = false
            end
        end
    end)

    local Urlsent = ""
    function wSend(main)
        if not isBountyCurrent() or not Urlsent:match("^https://") then return end
        task.spawn(function()
    if not isBountyCurrent() then return end
            local success, err = pcall(function()
                local Data = HttpService:JSONEncode(main)
                local Head = { ["content-type"] = "application/json" }
                local Send = http_request or request or HttpPost or (syn and syn.request)
                if Send then
                    Send({ Url = Urlsent, Body = Data, Method = "POST", Headers = Head })
                end
            end)
            if not success then
                print("webhook: " .. tostring(err))
            end
        end)
    end

    local rewardTypes = "Bounty"
    function wEarn(targ, earn, total)
        if getgenv().killed then
            local targetName = (targ and targ.Name) or "Unknown"
            local myTeamObj = lp.Team
            local myTeamName = myTeamObj and myTeamObj.Name or ""
            local rewardType = (myTeamName == "Marines") and "Honor" or "Bounty"

            local targTeamObj = targ and targ.Team
            local targTeamName = targTeamObj and targTeamObj.Name or ""
            rewardTypes = (targTeamName == "Marines") and "Honor" or "Bounty"

            local myLstats = lp:FindFirstChild("leaderstats")
            local myBStat = myLstats and (myLstats:FindFirstChild("Bounty/Honor") or myLstats:FindFirstChild("Bounty") or myLstats:FindFirstChild("Honor"))
            local myBVal = myBStat and tonumber(myBStat.Value) or 0

            local targLstats = targ and targ:FindFirstChild("leaderstats")
            local targBStat = targLstats and (targLstats:FindFirstChild("Bounty/Honor") or targLstats:FindFirstChild("Bounty") or targLstats:FindFirstChild("Honor"))
            local targBVal = targBStat and tonumber(targBStat.Value) or 0

            local data = {
                ["content"] = "",
                ["embeds"] = {
                    {
                        ["title"] = "TOMMY BOUNTY",
                        ["color"] = 3447003,
                        ["fields"] = {
                            {
                                ["name"] = "User: ",
                                ["value"] = "||" .. lp.Name .. "||",
                                ["inline"] = false,
                            },
                            {
                                ["name"] = "Target: ",
                                ["value"] = "```" .. targetName .. ":\n" .. (math.round((targBVal / 1000000) * 100) / 100) .. "M " .. rewardTypes .. "```",
                                ["inline"] = false,
                            },
                            {
                                ["name"] = "Bounty Earned: ",
                                ["value"] = "```Earned: " .. tostring(earn) .. "```",
                                ["inline"] = false,
                            },
                            {
                                ["name"] = "Total Bounty: ",
                                ["value"] = "```Earned: " .. tostring(total) .. "```",
                                ["inline"] = false,
                            },
                            {
                                ["name"] = "Current Bounty/Honor: ",
                                ["value"] = "```" .. (math.round((myBVal / 1000000) * 100) / 100) .. "M " .. rewardType .. "```",
                                ["inline"] = false,
                            }
                        },
                        ["thumbnail"] = {
                            ["url"] = "https://cdn.discordapp.com/attachments/1417144752167452874/1443316299248963735/file_00000000161c7206a557007160088d00.png?ex=6928a08d&is=69274f0d&hm=decc168419a57692fd26a0afcf23c58bcbfc3b9fbcb92fb7d290713581b32932&",
                        },
                        ["footer"] = {
                            ["text"] = "Tommy Bounty Auto Hunt",
                        },
                        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                    }
                }
            }
            wSend(data)
        end
    end

    local lstatsInit = lp:FindFirstChild("leaderstats")
    local bStatInit = lstatsInit and (lstatsInit:FindFirstChild("Bounty/Honor") or lstatsInit:FindFirstChild("Bounty") or lstatsInit:FindFirstChild("Honor"))
    local Bounty = bStatInit and tonumber(bStatInit.Value) or 0
    local Earned = 0
    local startTime = tick()
    local OldTotalEarned = _G.TotalEarn or 0
    local TotalEarned = _G.TotalEarn or 0

    function FormatNumber(number)
        if number >= 1000000 then
            return string.format("%.2fM", number / 1000000)
        elseif number >= 1000 then
            return string.format("%.1fK", number / 1000)
        else
            return tostring(number)
        end
    end

    task.spawn(function()
    if not isBountyCurrent() then return end
        while isBountyCurrent() and task.wait(0.5) do
            if not isBountyCurrent() then return end
            pcall(function()
                local curLstats = lp:FindFirstChild("leaderstats")
                local curBStat = curLstats and (curLstats:FindFirstChild("Bounty/Honor") or curLstats:FindFirstChild("Bounty") or curLstats:FindFirstChild("Honor"))
                local currentBVal = curBStat and tonumber(curBStat.Value) or Bounty
                Earned = currentBVal - Bounty
                local elapsedTime = tick() - startTime
                local hours = math.floor(elapsedTime / 3600)
                local minutes = math.floor((elapsedTime % 3600) / 60)
                local seconds = math.floor(elapsedTime % 60)
                _G.Time = elapsedTime
                local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                if UI and UI.UpdateStats then
                    UI.UpdateStats(
                        FormatNumber(Earned),
                        FormatNumber(TotalEarned + Earned),
                        FormatNumber(currentBVal)
                    )
                end
                if Earned ~= 0 and TotalEarned ~= OldTotalEarned + Earned then
                    TotalEarned = OldTotalEarned + Earned
                    _G.TotalEarn = TotalEarned
                    if getgenv().killed then
                        wEarn(getgenv().killed, Earned, TotalEarned)
                    end
                end
            end)
        end
    end)

    if UI and UI.ShowNotification then
        UI.ShowNotification("Tommy Bounty Active & Hunting!", "success")
    end
end
    end)
    if not initialized and isBountyCurrent() then
        stopTommyAutoBountyExact()
        Tommy.ReportIssue("Auto Bounty initialization",initError)
        if abStatusLblRef then abStatusLblRef.Text="Auto Bounty: initialization failed; see Diagnostics" end
    end
        end)
        notifyToggle("Tommy Auto Bounty Started!", true)
    end
    getgenv().RunTommyAutoBountyExact = runTommyAutoBountyExact
    local AutoBountyPage = createScrollPage("AutoBounty_Page", 980)
    local c1 = makeCard(AutoBountyPage, "Auto Bounty", "Auto Bounty", 146, 2)
    abStatusLblRef = Instance.new("TextLabel", c1)
    abStatusLblRef.Size = UDim2.new(1, -20, 0, 22)
    abStatusLblRef.Position = UDim2.new(0, 10, 0, 24)
    abStatusLblRef.BackgroundTransparency = 1
    abStatusLblRef.Font = Enum.Font.GothamBold
    abStatusLblRef.TextSize = 12.5
    abStatusLblRef.TextColor3 = Color3.fromRGB(190, 190, 205)
    abStatusLblRef.TextXAlignment = Enum.TextXAlignment.Left
    abStatusLblRef.Text = (CurrentLang == "ES") and "Estado: Inactivo / Detenido" or "Status: Inactive / Stopped"
    table.insert(TranslatableUI, {
        label = abStatusLblRef,
        en = "Status: Inactive / Stopped",
        es = "Estado: Inactivo / Detenido"
    })
    abToggleBtnRef = createActionButton(c1, "Start Auto Bounty", "Iniciar Auto Bounty", UDim2.new(1, -20, 0, 42), UDim2.new(0, 10, 0, 50), function()
        if getgenv().TommyAutoBountyRunning then
            stopTommyAutoBountyExact()
        else
            runTommyAutoBountyExact()
        end
    end)
    abToggleBtnRef.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    abToggleBtnRef.TextColor3 = Color3.fromRGB(240, 240, 250)
    abToggleBtnStroke = Instance.new("UIStroke", abToggleBtnRef)
    abToggleBtnStroke.Color = Color3.fromRGB(55, 55, 68)
    local subRow = Instance.new("Frame", c1)
    subRow.Size = UDim2.new(1, -20, 0, 32)
    subRow.Position = UDim2.new(0, 10, 0, 100)
    subRow.BackgroundTransparency = 1
    local btnW = UDim2.new(0.315, 0, 1, 0)
    local skipBtn = createActionButton(subRow, "Skip Target", "Saltar Objetivo", btnW, UDim2.new(0, 0, 0, 0), function()
        if getgenv().SkipPlayer then
            pcall(function() getgenv().SkipPlayer(true) end)
            notifyToggle((CurrentLang == "ES") and "Objetivo saltado!" or "Target skipped!", true)
        else
            notifyToggle((CurrentLang == "ES") and "Auto Bounty inactivo" or "Auto Bounty not running", false)
        end
    end)
    table.insert(TranslatableUI, { btn = skipBtn, en = "Skip Target", es = "Saltar Objetivo" })
    local hopBtn = createActionButton(subRow, "Server Hop", "Cambiar Servidor", btnW, UDim2.new(0.342, 0, 0, 0), function()
        notifyToggle((CurrentLang == "ES") and "Buscando nuevo servidor..." or "Hopping server...", true)
        if getgenv().TommyAutoBountyRunning == true and (HopServer or getgenv().HopServer) then
            task.spawn(HopServer or getgenv().HopServer)
        else
            task.spawn(function()
                local sb = game:GetService("ReplicatedStorage"):FindFirstChild("__ServerBrowser")
                if sb then
                    for page = 1, 15 do
                        local ok, servers = pcall(function() return sb:InvokeServer(page) end)
                        if not ok or type(servers) ~= "table" then break end
                        for id, v in pairs(servers) do
                            if id ~= game.JobId and type(v) == "table" and (tonumber(v.Count) or 99) <= 8 then
                                pcall(function() sb:InvokeServer("teleport", id) end)
                                task.wait(5)
                                return
                            end
                        end
                    end
                end
                pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId) end)
            end)
        end
    end)
    table.insert(TranslatableUI, { btn = hopBtn, en = "Server Hop", es = "Cambiar Servidor" })
    local resetBtn = createActionButton(subRow, "Reset Filter", "Reiniciar Filtro", btnW, UDim2.new(0.685, 0, 0, 0), function()
        getgenv().checked = {}
        notifyToggle((CurrentLang == "ES") and "Lista de objetivos reiniciada!" or "Target blacklist cleared!", true)
    end)
    table.insert(TranslatableUI, { btn = resetBtn, en = "Reset Filter", es = "Reiniciar Filtro" })
    local c2 = makeCard(AutoBountyPage, "Hunter Telemetry", "Telemetría", 112, 154)
    local targetNameBox = Instance.new("TextLabel", c2)
    targetNameBox.Size = UDim2.new(0.48, 0, 0, 30)
    targetNameBox.Position = UDim2.new(0, 10, 0, 26)
    targetNameBox.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    targetNameBox.Font = Enum.Font.GothamMedium
    targetNameBox.TextSize = 11.5
    targetNameBox.TextColor3 = Color3.fromRGB(220, 220, 235)
    targetNameBox.Text = (CurrentLang == "ES") and "Objetivo: Ninguno" or "Target: None"
    Instance.new("UICorner", targetNameBox).CornerRadius = UDim.new(0, 6)
    local tbStk1 = Instance.new("UIStroke", targetNameBox)
    tbStk1.Color = Color3.fromRGB(38, 38, 48)

    local targetBountyBox = Instance.new("TextLabel", c2)
    Tommy.UI.targetBountyBox=targetBountyBox
    targetBountyBox.Size = UDim2.new(0.48, 0, 0, 30)
    targetBountyBox.Position = UDim2.new(0.51, 0, 0, 26)
    targetBountyBox.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    targetBountyBox.Font = Enum.Font.GothamMedium
    targetBountyBox.TextSize = 11.5
    targetBountyBox.TextColor3 = Color3.fromRGB(220, 220, 235)
    targetBountyBox.Text = "Bounty: -"
    Instance.new("UICorner", targetBountyBox).CornerRadius = UDim.new(0, 6)
    local tbStk2 = Instance.new("UIStroke", targetBountyBox)
    tbStk2.Color = Color3.fromRGB(38, 38, 48)

    local distBox = Instance.new("TextLabel", c2)
    distBox.Size = UDim2.new(0.48, 0, 0, 30)
    distBox.Position = UDim2.new(0, 10, 0, 64)
    distBox.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    distBox.Font = Enum.Font.GothamMedium
    distBox.TextSize = 11.5
    distBox.TextColor3 = Color3.fromRGB(220, 220, 235)
    distBox.Text = (CurrentLang == "ES") and "Distancia: -" or "Distance: -"
    Instance.new("UICorner", distBox).CornerRadius = UDim.new(0, 6)
    local tbStk3 = Instance.new("UIStroke", distBox)
    tbStk3.Color = Color3.fromRGB(38, 38, 48)

    local earnedBox = Instance.new("TextLabel", c2)
    earnedBox.Size = UDim2.new(0.48, 0, 0, 30)
    earnedBox.Position = UDim2.new(0.51, 0, 0, 64)
    earnedBox.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    earnedBox.Font = Enum.Font.GothamMedium
    earnedBox.TextSize = 11.5
    earnedBox.TextColor3 = Color3.fromRGB(225, 225, 240)
    earnedBox.Text = (CurrentLang == "ES") and "Ganado: 0" or "Earned: 0"
    Instance.new("UICorner", earnedBox).CornerRadius = UDim.new(0, 6)
    local tbStk4 = Instance.new("UIStroke", earnedBox)
    tbStk4.Color = Color3.fromRGB(38, 38, 48)

    task.spawn(function()
        while isCurrentSession() and task.wait(0.5) do
            pcall(function()
                if getgenv().TommyAutoBountyRunning then
                    local t = getgenv().targ
                    if t and t.Character then
                        local hrp = t.Character:FindFirstChild("HumanoidRootPart")
                        local lpHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local dist = (hrp and lpHrp) and math.floor((hrp.Position - lpHrp.Position).Magnitude) or 0
                        targetNameBox.Text = (CurrentLang == "ES") and ("Objetivo: " .. tostring(t.DisplayName or t.Name)) or ("Target: " .. tostring(t.DisplayName or t.Name))
                        distBox.Text = (CurrentLang == "ES") and ("Distancia: " .. tostring(dist) .. "m") or ("Distance: " .. tostring(dist) .. "m")
                        local bStat = t:FindFirstChild("leaderstats") and (t.leaderstats:FindFirstChild("Bounty/Honor") or t.leaderstats:FindFirstChild("Bounty") or t.leaderstats:FindFirstChild("Honor"))
                        local bVal = bStat and tonumber(bStat.Value) or 0
                        targetBountyBox.Text = string.format("Bounty: %.1fM", bVal / 1000000)
                    else
                        targetNameBox.Text = (CurrentLang == "ES") and "Objetivo: Buscando..." or "Target: Searching..."
                        distBox.Text = (CurrentLang == "ES") and "Distancia: -" or "Distance: -"
                        targetBountyBox.Text = "Bounty: -"
                    end
                    earnedBox.Text = (CurrentLang == "ES") and ("Ganado: " .. tostring(Earned or 0)) or ("Earned: " .. tostring(Earned or 0))
                else
                    targetNameBox.Text = (CurrentLang == "ES") and "Objetivo: Ninguno" or "Target: None"
                    distBox.Text = (CurrentLang == "ES") and "Distancia: -" or "Distance: -"
                    targetBountyBox.Text = "Bounty: -"
                    earnedBox.Text = (CurrentLang == "ES") and "Ganado: 0" or "Earned: 0"
                end
            end)
        end
    end)
    local c3 = makeCard(AutoBountyPage, "Respawn & Race V4", "Respawn y Raza V4", 148, 272)
    local p1 = Instance.new("TextLabel", c3)
    p1.Size = UDim2.new(0.48, 0, 0, 30)
    p1.Position = UDim2.new(0, 10, 0, 26)
    p1.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    p1.Font = Enum.Font.GothamMedium
    p1.TextSize = 11
    p1.TextColor3 = Color3.fromRGB(215, 215, 230)
    p1.Text = "Auto Buso (Respawn): ON"
    Instance.new("UICorner", p1).CornerRadius = UDim.new(0, 6)
    local pStk1 = Instance.new("UIStroke", p1)
    pStk1.Color = Color3.fromRGB(38, 38, 48)

    local p2 = Instance.new("TextLabel", c3)
    p2.Size = UDim2.new(0.48, 0, 0, 30)
    p2.Position = UDim2.new(0.51, 0, 0, 26)
    p2.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    p2.Font = Enum.Font.GothamMedium
    p2.TextSize = 11
    p2.TextColor3 = Color3.fromRGB(215, 215, 230)
    p2.Text = "Auto PvP (Respawn): ON"
    Instance.new("UICorner", p2).CornerRadius = UDim.new(0, 6)
    local pStk2 = Instance.new("UIStroke", p2)
    pStk2.Color = Color3.fromRGB(38, 38, 48)

    local p3 = Instance.new("TextLabel", c3)
    p3.Size = UDim2.new(0.48, 0, 0, 30)
    p3.Position = UDim2.new(0, 10, 0, 62)
    p3.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    p3.Font = Enum.Font.GothamMedium
    p3.TextSize = 11
    p3.TextColor3 = Color3.fromRGB(215, 215, 230)
    p3.Text = "SafeZone Evasion: ON"
    Instance.new("UICorner", p3).CornerRadius = UDim.new(0, 6)
    local pStk3 = Instance.new("UIStroke", p3)
    pStk3.Color = Color3.fromRGB(38, 38, 48)

    local p4 = Instance.new("TextLabel", c3)
    p4.Size = UDim2.new(0.48, 0, 0, 30)
    p4.Position = UDim2.new(0.51, 0, 0, 62)
    p4.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    p4.Font = Enum.Font.GothamMedium
    p4.TextSize = 11
    p4.TextColor3 = Color3.fromRGB(215, 215, 230)
    p4.Text = "Anti-AFK 20m: ON"
    Instance.new("UICorner", p4).CornerRadius = UDim.new(0, 6)
    local pStk4 = Instance.new("UIStroke", p4)
    pStk4.Color = Color3.fromRGB(38, 38, 48)

    createToggleButton(c3, "AutoV4Bounty", "Auto Race V4", "Auto Despertar V4", UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, 100))

    local c4 = makeCard(AutoBountyPage, "Healing Controls", "Control de Curación", 120, 430)
    local healLabel = Instance.new("TextLabel", c4)
    healLabel.Size = UDim2.new(0.60, 0, 0, 28)
    healLabel.Position = UDim2.new(0, 10, 0, 26)
    healLabel.BackgroundTransparency = 1
    healLabel.Font = Enum.Font.GothamMedium
    healLabel.TextSize = 11.5
    healLabel.TextColor3 = Color3.fromRGB(215, 215, 230)
    healLabel.TextXAlignment = Enum.TextXAlignment.Left
    healLabel.Text = (CurrentLang == "ES") and ("Límite Curación: " .. tostring(getgenv().TommyHealThreshold or 6000)) or ("Heal Threshold: " .. tostring(getgenv().TommyHealThreshold or 6000))
    table.insert(TranslatableUI, {
        label = healLabel,
        en = "Heal Threshold: " .. tostring(getgenv().TommyHealThreshold or 6000),
        es = "Límite Curación: " .. tostring(getgenv().TommyHealThreshold or 6000)
    })

    local healInput = Instance.new("TextBox", c4)
    healInput.Size = UDim2.new(0.30, 0, 0, 28)
    healInput.Position = UDim2.new(0.65, 0, 0, 26)
    healInput.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    healInput.Font = Enum.Font.GothamBold
    healInput.TextSize = 13
    healInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    healInput.Text = tostring(getgenv().TommyHealThreshold or 6000)
    healInput.PlaceholderText = "HP"
    healInput.ClearTextOnFocus = false
    Instance.new("UICorner", healInput).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", healInput).Color = Color3.fromRGB(55, 55, 68)
    healInput.FocusLost:Connect(function()
        local val = tonumber(healInput.Text)
        if val and val > 0 then
            getgenv().TommyHealThreshold = val
            healLabel.Text = (CurrentLang == "ES") and ("Límite Curación: " .. tostring(val)) or ("Heal Threshold: " .. tostring(val))
        else
            healInput.Text = tostring(getgenv().TommyHealThreshold or 6000)
        end
    end)

    local cancelHealBtn = createActionButton(c4, "Cancel Healing", "Cancelar Curación", UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, 68), function()
        getgenv().CancelHealing = true
        getgenv().HealingInSky = false
        pcall(function()
            if tween then tween:Cancel() end
            local lp = game:GetService("Players").LocalPlayer
            local char = lp and lp.Character
            local pt = char and char:FindFirstChild("PartTele")
            if pt then pt:Destroy() end
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
        end)
        notifyToggle((CurrentLang == "ES") and "Curación cancelada! Volviendo al combate al instante." or "Healing cancelled! Returning to combat instantly.", true)
    end)
    table.insert(TranslatableUI, {
        btn = cancelHealBtn,
        en = "Cancel Healing",
        es = "Cancelar Curación"
    })

    local c5BountySpeed = makeCard(AutoBountyPage, "Tween Speed Controls", "Velocidad de Desplazamiento", 104, 560)
    getgenv().AutoBountyFarSpeed = getgenv().AutoBountyFarSpeed or 160
    getgenv().AutoBountyNearSpeed = getgenv().AutoBountyNearSpeed or 350

    local farLabel = Instance.new("TextLabel", c5BountySpeed)
    farLabel.Size = UDim2.new(0.32, 0, 0, 26)
    farLabel.Position = UDim2.new(0, 8, 0, 26)
    farLabel.BackgroundTransparency = 1
    farLabel.Font = Enum.Font.GothamMedium
    farLabel.TextSize = 11
    farLabel.TextColor3 = Color3.fromRGB(215, 215, 230)
    farLabel.TextXAlignment = Enum.TextXAlignment.Left
    farLabel.Text = (CurrentLang == "ES") and "Vel. Lejos:" or "Far Speed:"

    local farInput = Instance.new("TextBox", c5BountySpeed)
    farInput.Size = UDim2.new(0.16, 0, 0, 26)
    farInput.Position = UDim2.new(0.33, 0, 0, 26)
    farInput.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    farInput.Font = Enum.Font.GothamBold
    farInput.TextSize = 12
    farInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    farInput.Text = tostring(getgenv().AutoBountyFarSpeed or 160)
    farInput.PlaceholderText = "160"
    farInput.ClearTextOnFocus = false
    Instance.new("UICorner", farInput).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", farInput).Color = Color3.fromRGB(55, 55, 68)
    farInput.FocusLost:Connect(function()
        local val = tonumber(farInput.Text)
        if val and val > 0 then
            getgenv().AutoBountyFarSpeed = val
            notifyToggle((CurrentLang == "ES") and ("Velocidad Lejos: " .. tostring(val)) or ("Far Speed: " .. tostring(val)), true)
        else
            farInput.Text = tostring(getgenv().AutoBountyFarSpeed or 160)
        end
    end)

    local nearLabel = Instance.new("TextLabel", c5BountySpeed)
    nearLabel.Size = UDim2.new(0.32, 0, 0, 26)
    nearLabel.Position = UDim2.new(0.52, 0, 0, 26)
    nearLabel.BackgroundTransparency = 1
    nearLabel.Font = Enum.Font.GothamMedium
    nearLabel.TextSize = 11
    nearLabel.TextColor3 = Color3.fromRGB(215, 215, 230)
    nearLabel.TextXAlignment = Enum.TextXAlignment.Left
    nearLabel.Text = (CurrentLang == "ES") and "Vel. Cerca:" or "Near Speed:"

    local nearInput = Instance.new("TextBox", c5BountySpeed)
    nearInput.Size = UDim2.new(0.16, 0, 0, 26)
    nearInput.Position = UDim2.new(0.84, -6, 0, 26)
    nearInput.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    nearInput.Font = Enum.Font.GothamBold
    nearInput.TextSize = 12
    nearInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    nearInput.Text = tostring(getgenv().AutoBountyNearSpeed or 350)
    nearInput.PlaceholderText = "350"
    nearInput.ClearTextOnFocus = false
    Instance.new("UICorner", nearInput).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", nearInput).Color = Color3.fromRGB(55, 55, 68)
    nearInput.FocusLost:Connect(function()
        local val = tonumber(nearInput.Text)
        if val and val > 0 then
            getgenv().AutoBountyNearSpeed = val
            notifyToggle((CurrentLang == "ES") and ("Velocidad Cerca: " .. tostring(val)) or ("Near Speed: " .. tostring(val)), true)
        else
            nearInput.Text = tostring(getgenv().AutoBountyNearSpeed or 350)
        end
    end)

    local spdInfo = Instance.new("TextLabel", c5BountySpeed)
    spdInfo.Size = UDim2.new(1, -16, 0, 36)
    spdInfo.Position = UDim2.new(0, 8, 0, 60)
    spdInfo.BackgroundTransparency = 1
    spdInfo.Font = Enum.Font.GothamMedium
    spdInfo.TextSize = 10.5
    spdInfo.TextColor3 = Color3.fromRGB(180, 185, 205)
    spdInfo.TextWrapped = true
    spdInfo.Text = (CurrentLang == "ES") and "Lejos (>300m): 160 | Cerca (<=300m): 350 hasta eliminar el objetivo" or "Far (>300m): 160 | Near (<=300m): 350 until target is killed"

    local c6AutoTeam = makeCard(AutoBountyPage, "Auto Join Team", "Auto Unirse a Equipo", 84, 672)

    local currentAutoTeam = "Marines"
    pcall(function()
        if isfile and isfile("Tommy_AutoTeam.txt") and readfile then
            local raw = readfile("Tommy_AutoTeam.txt")
            if raw then
                local t = string.match(raw, "%a+")
                if t == "Marines" or t == "Pirates" or t == "None" then
                    currentAutoTeam = t
                end
            end
        else
            if writefile then writefile("Tommy_AutoTeam.txt", "Marines") end
        end
    end)

    local statusLbl = Instance.new("TextLabel", c6AutoTeam)
    statusLbl.Name = "AutoTeamStatus"
    statusLbl.Size = UDim2.new(1, -20, 0, 18)
    statusLbl.Position = UDim2.new(0, 10, 0, 58)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Font = Enum.Font.GothamMedium
    statusLbl.TextSize = 11
    statusLbl.TextColor3 = Color3.fromRGB(165, 170, 190)
    statusLbl.TextXAlignment = Enum.TextXAlignment.Center

    local teamButtons = {}

    local function updateTeamVisuals()
        local curAccent = _G.CurrentAccentColor or Color3.fromRGB(65, 145, 255)
        for team, btn in pairs(teamButtons) do
            local isSel = (team == currentAutoTeam)
            btn.BackgroundColor3 = isSel and Color3.fromRGB(30, 42, 68) or Color3.fromRGB(20, 20, 26)
            local st = btn:FindFirstChildOfClass("UIStroke")
            if st then
                st.Color = isSel and curAccent or Color3.fromRGB(45, 45, 58)
                st.Thickness = isSel and 1.5 or 1
            end
            local lbl = btn:FindFirstChildOfClass("TextLabel")
            if lbl then
                lbl.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 195)
            end
        end
        if statusLbl then
            local selDescEN, selDescES
            if currentAutoTeam == "Pirates" then
                selDescEN = "Pirates (Active)"
                selDescES = "Piratas (Activo)"
            elseif currentAutoTeam == "Marines" then
                selDescEN = "Marines (Active)"
                selDescES = "Marinos (Activo)"
            else
                selDescEN = "None (Disabled)"
                selDescES = "Ninguno (Desactivado)"
            end
            statusLbl.Text = (CurrentLang == "ES") and ("Auto-Unirse: " .. selDescES) or ("Auto-Join: " .. selDescEN)
        end
    end
    _G.TommyUpdateTeamVisuals = updateTeamVisuals

    local function switchAndSaveTeam(teamName)
        currentAutoTeam = teamName
        pcall(function()
            if writefile then
                writefile("Tommy_AutoTeam.txt", teamName)
            end
        end)
        if teamName == "Marines" or teamName == "Pirates" then
            task.spawn(function()
                pcall(function()
                    local rem = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                    local comm = rem and rem:FindFirstChild("CommF_")
                    if comm then
                        comm:InvokeServer("SetTeam", teamName)
                    end
                end)
            end)
            local msg = (CurrentLang == "ES") and ("Auto-Unirse configurado: " .. (teamName == "Marines" and "Marinos" or "Piratas")) or ("Auto-Join set: " .. teamName)
            notifyToggle(msg, true)
        else
            local msg = (CurrentLang == "ES") and "Auto-Unirse desactivado" or "Auto-Join disabled"
            notifyToggle(msg, false)
        end
        updateTeamVisuals()
    end

    local btnSize = UDim2.new(0.31, -4, 0, 28)
    teamButtons["Pirates"] = createActionButton(c6AutoTeam, "Pirates", "Piratas", btnSize, UDim2.new(0, 8, 0, 26), function()
        switchAndSaveTeam("Pirates")
    end)
    teamButtons["Marines"] = createActionButton(c6AutoTeam, "Marines", "Marinos", btnSize, UDim2.new(0.335, 3, 0, 26), function()
        switchAndSaveTeam("Marines")
    end)
    teamButtons["None"] = createActionButton(c6AutoTeam, "None", "Desactivar", btnSize, UDim2.new(0.67, -2, 0, 26), function()
        switchAndSaveTeam("None")
    end)

    for team, btn in pairs(teamButtons) do
        btn.MouseLeave:Connect(function()
            task.defer(function()
                if currentAutoTeam == team then
                    local curAccent = _G.CurrentAccentColor or Color3.fromRGB(65, 145, 255)
                    btn.BackgroundColor3 = Color3.fromRGB(30, 42, 68)
                    local st = btn:FindFirstChildOfClass("UIStroke")
                    if st then
                        st.Color = curAccent
                        st.Thickness = 1.5
                    end
                    local lbl = btn:FindFirstChildOfClass("TextLabel")
                    if lbl then
                        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end
            end)
        end)
    end
    updateTeamVisuals()

    FeatureCallbacks["AutoBounty"] = function(v)
        if v then
            runTommyAutoBountyExact()
        else
            stopTommyAutoBountyExact()
        end
    end

    local bountyV4Conn = nil
    FeatureCallbacks["AutoV4Bounty"] = function(v)
        getgenv().AutoV4Bounty = v
        if v then
            if bountyV4Conn then task.cancel(bountyV4Conn) end
            bountyV4Conn = task.spawn(function()
                while FeatureStates["AutoV4Bounty"] do
                    task.wait(0.5)
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local energy = char:FindFirstChild("RaceEnergy")
                            local transformed = char:FindFirstChild("RaceTransformed")
                            local stun = char:FindFirstChild("Stun")
                            local busy = char:FindFirstChild("Busy")

                            local hasEnergy = energy and tonumber(energy.Value) and tonumber(energy.Value) >= 1
                            local notTransformed = not transformed or (transformed.Value ~= true)
                            local notStunned = not stun or (tonumber(stun.Value) or 0) <= 0
                            local notBusy = not busy or (busy.Value ~= true)

                            if hasEnergy and notTransformed and notStunned and notBusy then
                                pcall(function()
                                    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                                    local commE = remotes and remotes:FindFirstChild("CommE")
                                    if commE then commE:FireServer("ActivateAwakening", true) end
                                end)
                                pcall(function()
                                    local vim = game:GetService("VirtualInputManager")
                                    if vim then
                                        vim:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                                        task.wait(0.05)
                                        vim:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                                    end
                                end)
                                pcall(function()
                                    local bp = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:FindFirstChild("Backpack")
                                    local awk = bp and bp:FindFirstChild("Awakening")
                                    if awk then
                                        local rf = awk:FindFirstChild("RemoteFunction")
                                        if rf and rf:IsA("RemoteFunction") then pcall(function() rf:InvokeServer(true) end) end
                                        local re = awk:FindFirstChild("RemoteEvent")
                                        if re and re:IsA("RemoteEvent") then pcall(function() re:FireServer(true) end) end
                                    end
                                end)
                                task.wait(2.0)
                            end
                        end
                    end)
                end
            end)
        else
            if bountyV4Conn then task.cancel(bountyV4Conn); bountyV4Conn = nil end
        end
    end
    setFeatureState("AutoV4Bounty", true)
end
