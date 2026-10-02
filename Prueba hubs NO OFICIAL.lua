--==============================================================
-- TOMMY HUB 67  |  Grief.cc Edition
-- Combat · Glitches · Soru · ESP · Dungeons · Aimbot 67
-- TikTok: @accountxz
--==============================================================

--==================== SERVICIOS ====================
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
if env.Grief_Unload then pcall(env.Grief_Unload) end

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
    SoulGuitar=false, SoulDash=121, AntiLava=false, DelShip=false, SuperJump=false,
    InfSoru=false, SoruAimbot=false, SoruTarget="Nearest", SoruDist=1000,
    PortalSoru=false, PortalSoruDelay=0.35,
    PortalSangC=false, PortalSangCDelay=0.35, PortalSangCTrigger="PortalF",
    FlashCombo=false, FlashWeapon="Fruit", FlashKey="Z", FlashDelay=0.3,
    ESP=false, ESPName=true, ESPLevel=true, ESPBounty=true, ESPFruit=true,
    ESPDist=true, ESPHP=true, ESPHighlight=false, ESPSize=12,
    AutoDungeon=false, DungeonWeapon="Sword", DungeonHeight=40, DungeonV4=false,
}
local Blacklist = {}

--==================== HELPERS ====================
local function getHRP() local c = player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function pressKey(kc, hold)
    if not VIM or not kc then return end
    VIM:SendKeyEvent(true, kc, false, game); task.wait(hold or 0.05); VIM:SendKeyEvent(false, kc, false, game)
end
local SLOT_KEYS = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
local ATTACK_KW = {"attack","slash","punch","m1","combo","hit","tool","ability","skill","bullet","gun","sword","melee","fruit"}
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

--==================== SILENT AIM (HOOKS) ====================
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
                if S.SkillAimbot and currentTarget then
                    if k == "Hit" then return CFrame.new(currentTarget.Position) end
                    return currentTarget
                end
            end
            return oldIdx(self, k)
        end))
    end)
end

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

--==================== AIMBOT 67 DESCARADO ====================
local A67_marker = nil
local A67_findNPC, A67_findPlayer

A67_findNPC = function()
    local me = getHRP(); if not me then return nil end
    local best, bd = nil, S.A67_MaxDist
    local en = workspace:FindFirstChild("Enemies")
    if en then
        for _, m in ipairs(en:GetChildren()) do
            if m:IsA("Model") and m ~= player.Character then
                local h = m:FindFirstChildOfClass("Humanoid")
                local r = m:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health > 0 then
                    local d = (r.Position - me.Position).Magnitude
                    if d < bd then bd = d; best = m end
                end
            end
        end
    end
    return best
end

A67_findPlayer = function()
    local me = getHRP(); if not me then return nil end
    local best, bd = nil, S.A67_MaxDist
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
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

local function A67_createMarker()
    if A67_marker and A67_marker.Parent then return A67_marker end
    local m = Instance.new("Part")
    m.Name = "TommyA67_Marker"
    m.Shape = Enum.PartType.Ball
    m.Size = Vector3.new(1, 1, 1)
    m.Material = Enum.Material.Neon
    m.Color = Color3.fromRGB(255, 60, 60)
    m.Anchored = true
    m.CanCollide = false
    m.CanQuery = false
    m.CanTouch = false
    m.Transparency = 1
    m.Parent = workspace
    A67_marker = m
    return m
end

track(RunService.RenderStepped:Connect(function()
    if not S.A67_Enabled then
        if A67_marker and A67_marker.Parent then A67_marker.Transparency = 1 end
        return
    end

    local targetChar = nil
    if S.A67_TargetNPC then targetChar = A67_findNPC() end
    if not targetChar and S.A67_TargetPlayer then targetChar = A67_findPlayer() end

    if not targetChar then
        if A67_marker and A67_marker.Parent then A67_marker.Transparency = 1 end
        return
    end

    local root = targetChar:FindFirstChild("HumanoidRootPart")
    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then
        if A67_marker and A67_marker.Parent then A67_marker.Transparency = 1 end
        return
    end

    local targetPos = root.Position
    if hum.WalkSpeed >= 5 then
        targetPos = root.Position + root.Velocity * S.A67_Prediction
    end

    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), 0.4)

    if S.A67_ShowMarker then
        local m = A67_createMarker()
        m.Position = targetPos
        m.Transparency = 0.4
    elseif A67_marker and A67_marker.Parent then
        A67_marker.Transparency = 1
    end
end))

--==================== DRAGON GUN ====================
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

--==================== ANTI STUN ====================
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
    end
end

--==================== MOVIMIENTO ====================
track(RunService.Heartbeat:Connect(function(dt)
    if not S.WalkSpeed then return end
    local c = player.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not (h and r) or h.Health <= 0 or h.Sit then return end
    local dir = h.MoveDirection
    local extra = S.Speed - h.WalkSpeed
    if dir.Magnitude > 0 and extra > 0 then
        r.CFrame = r.CFrame + dir * extra * dt
    end
end))

track(RunService.Stepped:Connect(function()
    local c = player.Character; if not c then return end
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

--==================== SANGUINE Z ====================
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

--==================== NO ANIMS / SUPER JUMP ====================
track(RunService.Stepped:Connect(function()
    if not S.NoAnim then return end
    local h = getHum(); if h then h.AutoRotate = true end
    stopNonAttackAnims()
end))

local function superJump()
    local r, h = getHRP(), getHum()
    if not r or not h or h.Health <= 0 then return end
    stopNonAttackAnims()
    r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, S.JumpPower, r.AssemblyLinearVelocity.Z)
    h:ChangeState(Enum.HumanoidStateType.Jumping)
end
local lastJump = 0
track(UIS.JumpRequest:Connect(function()
    if S.SuperJump and tick() - lastJump > 0.35 then
        lastJump = tick()
        superJump()
    end
end))

--==================== SOUL GUITAR ====================
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
    task.wait(0.6)
    guitarBusy = false
end
track(UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 and S.SoulGuitar then soulGuitarJump() end
end))

--==================== ANTI LAVA / DEL SHIP ====================
track(RunService.Stepped:Connect(function()
    if not S.AntiLava then return end
    local c = player.Character; if not c then return end
    for _, p in pairs(c:GetDescendants()) do
        if p:IsA("BasePart") and not ({HumanoidRootPart=1, Torso=1, UpperTorso=1, LowerTorso=1, Head=1})[p.Name] then p.CanTouch = false end
    end
end))

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

--==================== ESP ====================
local esp, cache = {}, {}
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

--==================== DUNGEONS ====================
local dgJustDied, dgLast, dgGen = false, nil, 0
track(player.CharacterAdded:Connect(function() dgJustDied = true end))

local function dgMatch(tool)
    return tool.ToolTip == S.DungeonWeapon or string.find(string.lower(tool.Name), string.lower(S.DungeonWeapon)) ~= nil
end
local function dgEquip()
    local c, h = player.Character, getHum()
    if not (c and h) then return end
    local cur = c:FindFirstChildOfClass("Tool")
    if cur and dgMatch(cur) then return end
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and dgMatch(t) then h:EquipTool(t) return end
        end
    end
end

local function dgRun(gen)
    while alive and S.AutoDungeon and gen == dgGen do
        task.wait(1)
        pcall(dgEquip)
    end
end

local function dgSet(on)
    dgGen = dgGen + 1
    dgLast = nil; dgJustDied = false
    if not on then return end
    local gen = dgGen
    task.spawn(dgRun, gen)
end

--==============================================================
-- UI: GRIEF.CC (OBSIDIAN) CON TODAS LAS OPCIONES EN LISTA
--==============================================================
local ObsidianRepo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
loadstring(game:HttpGet(ObsidianRepo .. "Library.lua"))()
Library = getgenv().Library or getgenv().ObsidianLibrary
getgenv().Library = Library
_G.Library = Library

ThemeManager = loadstring(game:HttpGet(ObsidianRepo .. "addons/ThemeManager.lua"))()
SaveManager = loadstring(game:HttpGet(ObsidianRepo .. "addons/SaveManager.lua"))()

local QuartzTheme = { 
    FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", 
    BackgroundColor = "1d1b26", OutlineColor = "27232f", FontFace = "Code", BackgroundImage = "" 
}

pcall(function()
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetDefaultTheme(QuartzTheme)
end)

GriefWindow = Library:CreateWindow({ 
    Title = "Tommy Hub 67", 
    Footer = "Grief.cc Edition | @accountxz", 
    Center = true, AutoShow = true, NotifySide = "Right", ShowCustomCursor = false 
})
Window = GriefWindow
getgenv().Window = Window

Tabs = {}
Tabs.Combat    = Window:AddTab("Combat", "swords")
Tabs.Character = Window:AddTab("Character", "person-standing")
Tabs.Visuals   = Window:AddTab("Visuals", "eye")
Tabs.World     = Window:AddTab("World", "earth")
Tabs.Misc      = Window:AddTab("Misc", "circle-ellipsis")
Tabs['UI Settings'] = Window:AddTab("UI Settings", "settings")
_G.Tabs = Tabs
getgenv().Tabs = Tabs

--==================== TAB: COMBAT ====================
local CombatLeft = Tabs.Combat:AddLeftGroupbox("Silent Aim")

CombatLeft:AddToggle("SilentAim", {
    Text = "silent aim (enable)",
    Default = false,
    Callback = function(val)
        S.SkillAimbot = val
        if not val then currentTarget = nil end
    end
}):AddKeyPicker("SilentAimKey", {
    Text = "silent aim",
    Default = "None",
    Mode = "Toggle",
    SyncToggleState = false,
    Callback = function(state)
        S.SkillAimbot = state
        if not state then currentTarget = nil end
    end
})

CombatLeft:AddSlider("HitChance", {
    Text = "hit chance",
    Default = 100, Min = 0, Max = 100, Rounding = 0, Compact = true,
    Callback = function(val) end
})

CombatLeft:AddDropdown("HitPartDropdown", {
    Text = "hit part",
    Default = "Head",
    Values = {"Head","HumanoidRootPart","Torso","UpperTorso","LowerTorso","Left Arm","Right Arm","Left Leg","Right Leg","Closest","Random"},
    Callback = function(val) end
})

CombatLeft:AddToggle("TargetPlayers", { Text = "target players", Default = true, Callback = function(v) S.TargetPlayers = v end })
CombatLeft:AddToggle("TargetMobs", { Text = "target npcs", Default = false, Callback = function(v) S.TargetMobs = v end })
CombatLeft:AddToggle("Rainbow", { Text = "rainbow target esp", Default = false, Callback = function(v) S.Rainbow = v end })

local CombatRight = Tabs.Combat:AddRightGroupbox("Aimbot 67 Descarado")

CombatRight:AddToggle("A67_Enabled", {
    Text = "aimbot 67 descarado (enable)",
    Default = false,
    Callback = function(v) S.A67_Enabled = v end,
})
CombatRight:AddToggle("A67_TargetNPC", { Text = "atacar npcs", Default = true, Callback = function(v) S.A67_TargetNPC = v end })
CombatRight:AddToggle("A67_TargetPlayer", { Text = "atacar players", Default = false, Callback = function(v) S.A67_TargetPlayer = v end })
CombatRight:AddToggle("A67_ShowMarker", { Text = "mostrar marcador", Default = true, Callback = function(v) S.A67_ShowMarker = v end })
CombatRight:AddSlider("A67_Prediction", { Text = "prediccion", Default = 0.15, Min = 0, Max = 1, Rounding = 2, Compact = true, Callback = function(v) S.A67_Prediction = v end })
CombatRight:AddSlider("A67_MaxDist", { Text = "distancia max", Default = 1500, Min = 100, Max = 5000, Rounding = 0, Compact = true, Callback = function(v) S.A67_MaxDist = v end })

CombatRight:AddToggle("DragonM1", { Text = "aimbot m1 (dragon gun) ⚠ ban", Default = false, Callback = function(v) S.DragonM1 = v end })
CombatRight:AddToggle("FastAttack", { Text = "fast attack", Default = false, Callback = function(v) S.FastAttack = v; if v then startFastAttack() end end })
CombatRight:AddToggle("AntiStun", { Text = "anti stun + hitbox [beta]", Default = false, Callback = function(v) setAntiStun(v) end })
CombatRight:AddToggle("AutoV4", { Text = "auto race v4", Default = false, Callback = function(v) S.AutoV4 = v end })

local CombatMove = Tabs.Combat:AddRightGroupbox("Movimiento")
CombatMove:AddToggle("WalkSpeed", { Text = "walk speed", Default = false, Callback = function(v) S.WalkSpeed = v end })
CombatMove:AddSlider("Speed", { Text = "speed", Default = 50, Min = 16, Max = 300, Rounding = 0, Compact = true, Callback = function(v) S.Speed = v end })
CombatMove:AddToggle("Dash", { Text = "dash distance", Default = false, Callback = function(v) S.Dash = v; applyDash(v and S.DashLen or 1) end })
CombatMove:AddSlider("DashLen", { Text = "dash", Default = 50, Min = 1, Max = 300, Rounding = 0, Compact = true, Callback = function(v) S.DashLen = v; if S.Dash then applyDash(v) end end })
CombatMove:AddToggle("Noclip", { Text = "noclip", Default = false, Callback = function(v) S.Noclip = v end })
CombatMove:AddToggle("WaterWalk", { Text = "walk on water", Default = false, Callback = function(v) S.WaterWalk = v end })

--==================== TAB: CHARACTER ====================
local SoruBox = Tabs.Character:AddLeftGroupbox("Soru")

SoruBox:AddToggle("InfSoru", {
    Text = "infinite soru",
    Default = false,
    Callback = function(v)
        S.InfSoru = v
        if player.Character then attachInfSoru(player.Character) end
    end
})
SoruBox:AddToggle("SoruAimbot", { Text = "soru aimbot (tp)", Default = false, Callback = function(v) S.SoruAimbot = v end })
SoruBox:AddSlider("SoruDist", { Text = "soru dist", Default = 1000, Min = 100, Max = 3500, Rounding = 0, Compact = true, Callback = function(v) S.SoruDist = v end })
SoruBox:AddDropdown("SoruTarget", { Text = "soru target", Default = "Nearest", Values = {"Nearest"}, Callback = function(v) S.SoruTarget = v end })
SoruBox:AddToggle("PortalSoru", { Text = "portal soru combo (x+z)", Default = false, Callback = function(v) S.PortalSoru = v end })
SoruBox:AddSlider("PortalSoruDelay", { Text = "portal soru delay", Default = 0.35, Min = 0.05, Max = 2, Rounding = 2, Compact = true, Callback = function(v) S.PortalSoruDelay = v end })
SoruBox:AddToggle("PortalSangC", { Text = "portal sanguine c combo", Default = false, Callback = function(v) S.PortalSangC = v end })
SoruBox:AddSlider("PortalSangCDelay", { Text = "sanguine c delay", Default = 0.35, Min = 0.05, Max = 2, Rounding = 2, Compact = true, Callback = function(v) S.PortalSangCDelay = v end })
SoruBox:AddToggle("FlashCombo", { Text = "flashstep skill combo", Default = false, Callback = function(v) S.FlashCombo = v end })

--==================== TAB: VISUALS ====================
local ESPBox = Tabs.Visuals:AddLeftGroupbox("ESP")

ESPBox:AddToggle("ESP", {
    Text = "esp (enable)",
    Default = false,
    Callback = function(v)
        S.ESP = v
        if not v then for p in pairs(esp) do clearESP(p) end end
    end
})
ESPBox:AddToggle("ESPName", { Text = "show name", Default = true, Callback = function(v) S.ESPName = v end })
ESPBox:AddToggle("ESPLevel", { Text = "show level", Default = true, Callback = function(v) S.ESPLevel = v end })
ESPBox:AddToggle("ESPBounty", { Text = "show bounty / pvp", Default = true, Callback = function(v) S.ESPBounty = v end })
ESPBox:AddToggle("ESPFruit", { Text = "show devil fruit", Default = true, Callback = function(v) S.ESPFruit = v end })
ESPBox:AddToggle("ESPDist", { Text = "show distance", Default = true, Callback = function(v) S.ESPDist = v end })
ESPBox:AddToggle("ESPHP", { Text = "show hp %", Default = true, Callback = function(v) S.ESPHP = v end })
ESPBox:AddToggle("ESPHighlight", { Text = "highlight players", Default = false, Callback = function(v) S.ESPHighlight = v end })
ESPBox:AddSlider("ESPSize", { Text = "text size", Default = 12, Min = 8, Max = 32, Rounding = 0, Compact = true, Callback = function(v) S.ESPSize = v end })

--==================== TAB: WORLD ====================
local DgBox = Tabs.World:AddLeftGroupbox("Auto Dungeon")

DgBox:AddToggle("AutoDungeon", {
    Text = "▶ auto dungeon (start/stop)",
    Default = false,
    Callback = function(v)
        S.AutoDungeon = v
        dgSet(v)
    end
})
DgBox:AddDropdown("DungeonWeapon", {
    Text = "arma",
    Default = "Sword",
    Values = {"Sword", "Melee", "Blox Fruit"},
    Callback = function(v) S.DungeonWeapon = v end
})
DgBox:AddSlider("DungeonHeight", {
    Text = "altura de ataque",
    Default = 40, Min = 10, Max = 100, Rounding = 0, Compact = true,
    Callback = function(v) S.DungeonHeight = v end
})
DgBox:AddToggle("DungeonV4", {
    Text = "auto v4 (tecla y)",
    Default = false,
    Callback = function(v) S.DungeonV4 = v end
})

--==================== TAB: MISC ====================
local SangBox = Tabs.Misc:AddLeftGroupbox("Sanguine Z")

SangBox:AddToggle("SangNoCD", {
    Text = "sanguine z no cooldown",
    Default = false,
    Callback = function(v)
        S.SangNoCD = v
        local c = player.Character
        if c then c:SetAttribute("AllCooldown", v and 3 or nil) end
    end
})
SangBox:AddButton({ Text = "🩸 sanguine z manual", Func = function() sangManual() end })
SangBox:AddToggle("SangAuto", {
    Text = "sanguine z auto",
    Default = false,
    Callback = function(v)
        S.SangAuto = v
        if v then startSangAuto() elseif sangConn then sangConn:Disconnect(); sangConn = nil end
    end
})
SangBox:AddSlider("SangDrop", { Text = "drop duration", Default = 2, Min = 0.5, Max = 5, Rounding = 1, Compact = true, Callback = function(v) S.SangDrop = v end })

local TrucosBox = Tabs.Misc:AddRightGroupbox("Trucos")
TrucosBox:AddToggle("NoAnim", { Text = "no animations", Default = false, Callback = function(v) S.NoAnim = v end })
TrucosBox:AddToggle("SuperJump", { Text = "super jump", Default = false, Callback = function(v) S.SuperJump = v end })
TrucosBox:AddSlider("JumpPower", { Text = "jump power", Default = 500, Min = 50, Max = 1000, Rounding = 0, Compact = true, Callback = function(v) S.JumpPower = v end })
TrucosBox:AddToggle("SoulGuitar", { Text = "soul guitar glitch [beta]", Default = false, Callback = function(v) S.SoulGuitar = v end })
TrucosBox:AddSlider("SoulDash", { Text = "soul dash", Default = 121, Min = 1, Max = 300, Rounding = 0, Compact = true, Callback = function(v) S.SoulDash = v end })
TrucosBox:AddToggle("AntiLava", { Text = "anti lava", Default = false, Callback = function(v) S.AntiLava = v end })
TrucosBox:AddToggle("DelShip", { Text = "delete ghost ship (sea 2)", Default = false, Callback = function(v) S.DelShip = v end })

--==================== TAB: UI SETTINGS ====================
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('TommyHub67')
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:SetLibrary(Library)
SaveManager:SetFolder('TommyHub67')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
pcall(function() SaveManager:LoadAutoloadConfig() end)

--==================== CLEANUP ====================
local function cleanup()
    alive = false
    S.SkillAimbot = false; S.A67_Enabled = false; S.AutoDungeon = false
    setAntiStun(false)
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for p in pairs(esp) do clearESP(p) end
    if rainbowHL then rainbowHL:Destroy() end
    if A67_marker then A67_marker:Destroy() end
    applyDash(1)
    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
    env.TommyHub67 = nil
end
env.TommyHub67 = cleanup

Library:OnUnload(function()
    pcall(cleanup)
end)

print("✅ TOMMY HUB 67 (Grief.cc Edition) cargado correctamente")
