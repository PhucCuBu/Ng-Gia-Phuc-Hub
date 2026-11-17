-- ╔══════════════════════════════════════════════════════════════╗
-- ║              NGUYEN GIA PHUC HUB                             ║
-- ║   Neon UI | Full Notification | Splash Load                  ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ===================== EXECUTOR COMPAT =====================
local ENV = (getgenv and getgenv()) or _G
local VIM_OK = pcall(function() return game:GetService("VirtualInputManager") end)

local function PressKey(kc, state)
    if VIM_OK then
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(state, kc, false, nil)
        end)
    else
        pcall(function()
            if state then keypress(kc.Value) else keyrelease(kc.Value) end
        end)
    end
end

local function CopyClip(txt)
    pcall(function()
        if setclipboard then setclipboard(txt)
        elseif toclipboard then toclipboard(txt) end
    end)
end

-- ===================== SERVICES =====================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS               = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local CoreGui           = game:GetService("CoreGui")

local lp   = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")
local hum  = char:WaitForChild("Humanoid")

lp.CharacterAdded:Connect(function(c)
    char = c
    hrp  = c:WaitForChild("HumanoidRootPart")
    hum  = c:WaitForChild("Humanoid")
end)

-- ===================== MOB FILTER =====================
local NPC_BLACKLIST = {
    "Blox Fruit Dealer","Boat Dealer","Upgrade","Rumble","Rocket","Spin",
    "Flame","Ice","Dark","Light","Sand","Gravity","Barrier","Rubber","Magma",
    "Quake","Love","Spider","Phoenix","Paw","Buddha","Soul","Dough","Shadow",
    "Venom","Control","Dragon","Leopard","Kitsune","Bartilo","Shanks",
    "Monkey.D.Garp","Cipher Pol","Swan","Wysper","Thunder God","Greybeard",
    "Order","Cyber","Professor Clover","Mysterious Scientist","Mysterious Expert",
    "Horned Man","Advanced Fruit Dealer","Luxury Boat Dealer","Ship Dealer",
    "Jeremy","Grimm","Zoro","Arlong","Fishman Lord","Don Swan","Fajita",
    "Galley Master","Island Empress","Blox Fruit Dealer Cousin",
}

local function IsBlacklisted(name)
    for _, v in ipairs(NPC_BLACKLIST) do
        if name:lower():find(v:lower()) then return true end
    end
    return false
end

local function IsMob(obj)
    if not obj:IsA("Model") then return false end
    local h = obj:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    if not obj:FindFirstChild("HumanoidRootPart") then return false end
    if obj == char then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == obj then return false end
    end
    if IsBlacklisted(obj.Name) then return false end
    return true
end

-- ===================== STATE =====================
local State = {
    AutoFarm=false, FarmMode="Farm Level", FarmTarget="Auto",
    FlyHeight=50, AutoSkill=false,
    BringMobRange=150,
    FlyEnabled=false, FlyBV=nil, FlyBG=nil, FlySpeed=120,
    NoclipEnabled=true,
    SkillDelay=0.3,
    AutoCollectBerry=false, AutoChest=false,
    ESPEnabled=false, ESPHighlights={},
    AutoStats=false, StatPoints={Melee=0,Sword=0,Gun=0,Fruit=0,Defense=0},
    AutoFishing=false, AutoSellFish=false,
    AutoTrickOrTreat=false, AutoPumpkinHunt=false, AutoGreatPumpkin=false,
    DiscordWebhook="",
    AutoHopFarm=false,
    SecretQuestDone=0,
    WebhookUserId="", PingMode="None",
    SelectedBoss="Darkbeard",
    SkillHold={Z=250,X=250,C=250,V=250},
    SelectedPlayer="",
    AimRadius=150, ChangeSpeed=16, JumpPower=50,
    SelectedBoat="Dinghy",
    SelectedDungeon="Normal", MinimumPlayers=1,
    SelectedTeam="Pirates",
    AutoGachaFruit=false,
}

local MOB_TARGETS = {
    Auto=nil, Monkey=Vector3.new(-1241,10,3875), Gorilla=Vector3.new(-1352,10,3923),
    Pirate=Vector3.new(-1402,10,755), Bandit=Vector3.new(980,15,1757),
    ["God's Guard"]=Vector3.new(-4860,453,155), ["Toga Warrior"]=Vector3.new(-4820,453,90),
    ["Galley Pirate"]=Vector3.new(-3011,8,1430), Scientist=Vector3.new(-2370,72,2820),
    ["Snow Trooper"]=Vector3.new(1176,8,3817), ["Magma Ninja"]=Vector3.new(1038,20,4629),
    ["Lava Pirate"]=Vector3.new(1100,20,4700), ["Dragon Crew"]=Vector3.new(930,8,-3243),
    Terrorshark=Vector3.new(-3215,8,2800), ["Fishman Pirate"]=Vector3.new(-3610,8,2360),
    ["Cake Guard"]=Vector3.new(-5074,15,-4855), Zombie=Vector3.new(-5894,8,-3718),
    ["Ice Fairy"]=Vector3.new(-5842,100,-3745), ["Dark Master"]=Vector3.new(-6660,7,-1600),
    Bringer=Vector3.new(-10208,7,-1038), ["Cake Prince"]=Vector3.new(-5100,15,-4900),
    Darkbeard=Vector3.new(-1796,9,1819), Rip_indra=Vector3.new(1016,185,-3015),
    ["Dough King"]=Vector3.new(-5212,8,-3300), ["Elite Pirate"]=Vector3.new(-5212,8,-3300),
}

local GATEWAYS = {
    ["Dough King"] = { waypoints = { Vector3.new(-5074,15,-4855) }, final = Vector3.new(-5212,8,-3300) },
    ["Cake Prince"] = { waypoints = { Vector3.new(-5074,15,-4855) }, final = Vector3.new(-5100,15,-4900) },
    ["Cake Guard"] = { waypoints = { Vector3.new(-5074,15,-4855) }, final = Vector3.new(-5074,15,-4855) },
    ["Elite Pirate"] = { waypoints = { Vector3.new(-5074,15,-4855) }, final = Vector3.new(-5212,8,-3300) },
    ["Rip_indra"] = { waypoints = { Vector3.new(-4849,453,150) }, final = Vector3.new(1016,185,-3015) },
    ["Darkbeard"] = { waypoints = { Vector3.new(5900,7.9,-4150) }, final = Vector3.new(-1796,9,1819) },
    ["Dark Master"] = { waypoints = { Vector3.new(5900,7.9,-4150) }, final = Vector3.new(-6660,7,-1600) },
    ["Ice Fairy"] = { waypoints = { Vector3.new(1176,8.4,3817) }, final = Vector3.new(-5842,100,-3745) },
    ["God's Guard"] = { waypoints = { Vector3.new(-1282,8.4,-1413) }, final = Vector3.new(-4860,453,155) },
    ["Toga Warrior"] = { waypoints = { Vector3.new(-1282,8.4,-1413) }, final = Vector3.new(-4820,453,90) },
    ["Magma Ninja"] = { waypoints = { Vector3.new(-537,8.4,-170) }, final = Vector3.new(1038,20,4629) },
    ["Lava Pirate"] = { waypoints = { Vector3.new(-537,8.4,-170) }, final = Vector3.new(1100,20,4700) },
    ["Terrorshark"] = { waypoints = { Vector3.new(-3610,8,2360) }, final = Vector3.new(-3215,8,2800) },
}

local SECRET_QUESTS = {
    {name="Mysterious Expert",   pos=Vector3.new(-3610,8,2360)},
    {name="Mysterious Scientist",pos=Vector3.new(-2370,72,2820)},
    {name="Horned Man",          pos=Vector3.new(-2855,8,2165)},
    {name="Shanks Hint",         pos=Vector3.new(2074,10,-4221)},
}

-- ===================== UTILS =====================
local function RemoteInvoke(...)
    local args={...}
    local ok,res = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer(table.unpack(args))
    end)
    return ok,res
end

local function GetNearestMob(range)
    local nearest,nd = nil, range or 9999
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if IsMob(obj) then
            local d=(hrp.Position-obj.HumanoidRootPart.Position).Magnitude
            if d<nd then nearest=obj nd=d end
        end
    end
    return nearest
end

local function GetAllMobsInRange(range)
    local mobs={}
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if IsMob(obj) then
            local d=(hrp.Position-obj.HumanoidRootPart.Position).Magnitude
            if d<(range or State.BringMobRange) then table.insert(mobs,obj) end
        end
    end
    return mobs
end

local function AutoBringMob()
    if not char or not hrp then return end
    local mobs = GetAllMobsInRange(State.BringMobRange)
    if #mobs == 0 then return end
    local anchor = hrp.Position - Vector3.new(0, 3, 0)
    for _, mob in ipairs(mobs) do
        local mobHrp = mob:FindFirstChild("HumanoidRootPart")
        if mobHrp then
            mobHrp.CFrame = CFrame.new(anchor + Vector3.new(
                math.random(-5,5), 0, math.random(-5,5)
            ))
        end
    end
end

-- ===================== NOCLIP =====================
local noclipConn = nil
local function StartNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if not State.NoclipEnabled then return end
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end)
end
StartNoclip()

-- ===================== TWEEN =====================
local function TweenMove(targetPos, speed, cancelCheck)
    if not hrp then return false end
    speed = speed or State.FlySpeed
    local target = Vector3.new(targetPos.X, targetPos.Y, targetPos.Z)
    if hrp:FindFirstChild("NGP_Tween") then hrp.NGP_Tween:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "NGP_Tween"
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    local reached = false
    local startTime = tick()
    local lastBring = 0
    while tick() - startTime < 30 do
        if not hrp or not hrp.Parent or not bv.Parent then break end
        if cancelCheck and cancelCheck() then break end
        if tick() - lastBring > 0.3 then AutoBringMob() lastBring = tick() end
        local delta = target - hrp.Position
        local dist = delta.Magnitude
        if dist < 4 then reached = true break end
        local desired = math.min(speed, dist * 3)
        bv.Velocity = delta.Unit * desired
        task.wait(0.03)
    end
    bv:Destroy()
    return reached
end

local function SmartTravel(targetPos, targetName, cancelCheck)
    if not hrp then return false end
    local gate = targetName and GATEWAYS[targetName]
    if gate then
        for _, wp in ipairs(gate.waypoints) do
            if cancelCheck and cancelCheck() then return false end
            TweenMove(wp, State.FlySpeed, cancelCheck)
        end
        return TweenMove(gate.final, State.FlySpeed, cancelCheck)
    end
    return TweenMove(targetPos, State.FlySpeed, cancelCheck)
end

-- ===================== MANUAL FLY =====================
local function EnableFly()
    if State.FlyEnabled then return end
    State.FlyEnabled = true
    if hrp:FindFirstChild("NGP_BV") then hrp.NGP_BV:Destroy() end
    if hrp:FindFirstChild("NGP_BG") then hrp.NGP_BG:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "NGP_BV"
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Parent = hrp
    State.FlyBV = bv
    local bg = Instance.new("BodyGyro")
    bg.Name = "NGP_BG"
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bg.D = 100
    bg.Parent = hrp
    State.FlyBG = bg
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
    RunService:BindToRenderStep("NGPFly", Enum.RenderPriority.Camera.Value+1, function()
        if not State.FlyEnabled then RunService:UnbindFromRenderStep("NGPFly") return end
        local cam = Workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * State.FlySpeed or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end

local function DisableFly()
    State.FlyEnabled = false
    RunService:UnbindFromRenderStep("NGPFly")
    if State.FlyBV then State.FlyBV:Destroy() State.FlyBV = nil end
    if State.FlyBG then State.FlyBG:Destroy() State.FlyBG = nil end
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
end

-- ===================== SKILLS =====================
local function UseSkills()
    for _,k in ipairs({Enum.KeyCode.Z,Enum.KeyCode.X,Enum.KeyCode.C,Enum.KeyCode.V}) do
        PressKey(k,true); task.wait(State.SkillDelay)
        PressKey(k,false); task.wait(State.SkillDelay)
    end
end

local function AttackMob(mob, cancelCheck)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    local above = mob.HumanoidRootPart.Position + Vector3.new(0, State.FlyHeight, 0)
    TweenMove(above, State.FlySpeed, cancelCheck)
    AutoBringMob()
    task.wait(0.1)
    AutoBringMob()
    if State.AutoSkill then UseSkills() end
    pcall(function()
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local ev = tool:FindFirstChild("Activated") or tool:FindFirstChild("MouseButton1Down")
            if ev then ev:Fire() end
        end
    end)
end

-- ===================== FARM LOOPS =====================
local function FarmLevelLoop()
    while State.AutoFarm and State.FarmMode == "Farm Level" do
        if not(char and hrp and hum and hum.Health > 0) then task.wait(2) continue end
        local cancelCheck = function() return not State.AutoFarm end
        local targetName = State.FarmTarget
        local targetPos = targetName ~= "Auto" and MOB_TARGETS[targetName]
        local mob
        if targetPos then
            if (hrp.Position - targetPos).Magnitude > 200 then
                SmartTravel(targetPos, targetName, cancelCheck)
            end
            for _,obj in ipairs(Workspace:GetDescendants()) do
                if IsMob(obj) and obj.Name:lower():find(targetName:lower()) then
                    mob = obj break
                end
            end
        end
        if not mob then mob = GetNearestMob(500) end
        if mob then AttackMob(mob, cancelCheck) end
        task.wait(0.1)
    end
end

local function FarmNearMobsLoop()
    while State.AutoFarm and State.FarmMode == "Farm Near Mobs" do
        if not(char and hrp and hum and hum.Health > 0) then task.wait(2) continue end
        local cancelCheck = function() return not State.AutoFarm end
        AutoBringMob()
        if State.AutoSkill then UseSkills() end
        local mob = GetNearestMob(State.BringMobRange + 20)
        if mob then AttackMob(mob, cancelCheck) end
        task.wait(0.2)
    end
end

local function FarmSecretLoop()
    local step = 1
    while State.AutoFarm and State.FarmMode == "Farm Level Secret" do
        if not(char and hrp and hum and hum.Health > 0) then task.wait(2) continue end
        local cancelCheck = function() return not State.AutoFarm end
        local q = SECRET_QUESTS[step]
        if not q then step = 1 State.SecretQuestDone += 1 task.wait(3) continue end
        TweenMove(q.pos, State.FlySpeed, cancelCheck)
        RemoteInvoke("StartQuest", q.name) task.wait(0.5)
        local killMob = GetNearestMob(300)
        if killMob then
            for _ = 1, 20 do
                if not(State.AutoFarm and State.FarmMode == "Farm Level Secret") then break end
                AttackMob(killMob, cancelCheck) task.wait(0.3)
                if not killMob.Parent or killMob:FindFirstChildOfClass("Humanoid").Health <= 0 then
                    killMob = GetNearestMob(300)
                    if not killMob then break end
                end
            end
        end
        RemoteInvoke("CompleteQuest", q.name) task.wait(0.5)
        step += 1 task.wait(1)
    end
end

local function StartFarmLoop()
    if State.FarmMode == "Farm Level" then task.spawn(FarmLevelLoop)
    elseif State.FarmMode == "Farm Near Mobs" then task.spawn(FarmNearMobsLoop)
    elseif State.FarmMode == "Farm Level Secret" then task.spawn(FarmSecretLoop)
    end
end

-- ===================== MISC LOOPS =====================
local function CollectBerryLoop()
    while State.AutoCollectBerry do
        local cancelCheck = function() return not State.AutoCollectBerry end
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if cancelCheck() then break end
            local n = obj.Name:lower()
            if n:find("berry") or n:find("beli") then
                local pos
                if obj:IsA("BasePart") then pos = obj.Position
                elseif obj:IsA("Model") then
                    local h = obj:FindFirstChild("Handle")
                    pos = h and h.Position
                end
                if pos then TweenMove(pos, State.FlySpeed, cancelCheck) end
            end
        end
        task.wait(1.5)
    end
end

local function CollectChestLoop()
    while State.AutoChest do
        local cancelCheck = function() return not State.AutoChest end
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if cancelCheck() then break end
            if obj.Name:lower():find("chest") then
                local p = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj:FindFirstChildOfClass("BasePart"))
                if p then TweenMove(p.Position, State.FlySpeed, cancelCheck) end
            end
        end
        task.wait(2)
    end
end

local function ESPLoop()
    while State.ESPEnabled do
        for obj in pairs(State.ESPHighlights) do
            if not obj or not obj.Parent then
                pcall(function() State.ESPHighlights[obj]:Destroy() end)
                State.ESPHighlights[obj] = nil
            end
        end
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if IsMob(obj) and not State.ESPHighlights[obj] then
                local ok,hl = pcall(function()
                    local h = Instance.new("Highlight")
                    h.FillTransparency = 0.5
                    h.OutlineColor = Color3.fromRGB(0,255,200)
                    h.FillColor = Color3.fromRGB(0,255,180)
                    h.Adornee = obj
                    h.Parent = obj
                    return h
                end)
                if ok then State.ESPHighlights[obj] = hl end
            end
        end
        task.wait(1)
    end
    for obj in pairs(State.ESPHighlights) do
        pcall(function() State.ESPHighlights[obj]:Destroy() end)
        State.ESPHighlights[obj] = nil
    end
end

local function AutoStatsLoop()
    local statMap = {Melee="Melee",Sword="Sword",Gun="Gun",Fruit="BloxFruit",Defense="Defense"}
    while State.AutoStats do
        for k,v in pairs(statMap) do
            if (State.StatPoints[k] or 0) > 0 then RemoteInvoke("AddStats", v, State.StatPoints[k]) end
        end
        task.wait(5)
    end
end

local function FishingLoop()
    while State.AutoFishing do
        RemoteInvoke("StartFishing") task.wait(10)
        RemoteInvoke("CollectFish") task.wait(2)
        if State.AutoSellFish then RemoteInvoke("SellFish") task.wait(1) end
    end
end

local function HWTrickLoop()
    while State.AutoTrickOrTreat do
        RemoteInvoke("HalloweenEvent","TrickOrTreat")
        local mob = GetNearestMob(300)
        if mob then AttackMob(mob, function() return not State.AutoTrickOrTreat end) end
        task.wait(2)
    end
end

local function HWPumpkinLoop()
    while State.AutoPumpkinHunt do
        local cancelCheck = function() return not State.AutoPumpkinHunt end
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if cancelCheck() then break end
            if obj.Name:lower():find("pumpkin") then
                local p = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj:FindFirstChildOfClass("BasePart"))
                if p then
                    TweenMove(p.Position + Vector3.new(0,5,0), State.FlySpeed, cancelCheck)
                    if State.AutoSkill then UseSkills() end
                end
            end
        end
        task.wait(1)
    end
end

local function HWGreatPumpkinLoop()
    while State.AutoGreatPumpkin do
        RemoteInvoke("HalloweenEvent","SummonGreatPumpkin") task.wait(2)
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("pumpkin") and obj:FindFirstChild("HumanoidRootPart") then
                for _ = 1, 30 do
                    if not State.AutoGreatPumpkin then break end
                    AttackMob(obj, function() return not State.AutoGreatPumpkin end) task.wait(0.3)
                    if not obj.Parent or obj:FindFirstChildOfClass("Humanoid").Health <= 0 then break end
                end
                break
            end
        end
        task.wait(5)
    end
end

local function SendWebhook(msg)
    if State.DiscordWebhook == "" then return end
    local prefix = ""
    if State.PingMode == "Everyone" then prefix = "@everyone "
    elseif State.PingMode == "Here" then prefix = "@here "
    elseif State.PingMode == "User" and State.WebhookUserId ~= "" then prefix = "<@"..State.WebhookUserId.."> " end
    pcall(function()
        HttpService:PostAsync(State.DiscordWebhook,
            HttpService:JSONEncode({
                content = prefix..msg,
                allowed_mentions = {parse = State.PingMode == "Everyone" and {"everyone"} or (State.PingMode == "Here" and {"everyone"} or {}), users = (State.PingMode == "User" and State.WebhookUserId ~= "" and {State.WebhookUserId} or {})}
            }),
            Enum.HttpContentType.ApplicationJson)
    end)
end

-- ===================== FRUIT =====================
local function HasFruitEquipped()
    if not lp then return false end
    local backpack = lp:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("fruit") or item.Name:lower():find("devil")) then
                return true, item.Name
            end
        end
    end
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("fruit") or item.Name:lower():find("devil")) then
                return true, item.Name
            end
        end
    end
    local data = lp:FindFirstChild("Data")
    if data then
        local fruits = data:FindFirstChild("Fruits") or data:FindFirstChild("StoredFruits")
        if fruits and #fruits:GetChildren() > 0 then
            return true, fruits:GetChildren()[1].Name
        end
    end
    return false
end

-- QUÉT FRUIT TRONG SERVER (Workspace + ReplicatedStorage)
local function ScanFruitsInServer()
    local found = {}
    local seen = {}
    local function check(obj)
        if not obj or seen[obj] then return end
        seen[obj] = true
        local n = obj.Name:lower()
        if n:find("fruit") or n:find("devil") then
            -- bỏ qua tool đang cầm
            if obj:IsA("Tool") then return end
            local pos
            if obj:IsA("BasePart") then pos = obj.Position
            elseif obj:IsA("Model") then
                local ok, cf = pcall(function() return obj:GetModelCFrame().Position end)
                if ok then pos = cf end
            end
            if pos then table.insert(found, {name = obj.Name, obj = obj, pos = pos}) end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do check(obj) end
    return found
end

local function AutoGachaLoop()
    while State.AutoGachaFruit do
        local has, name = HasFruitEquipped()
        if not has then
            RemoteInvoke("BuyFruit", "Random")
            ShowNotif("Gacha", "Đã gacha 1 trái random", 3)
            task.wait(5)
        else
            ShowNotif("Gacha", "Đã có fruit: "..name.." — dừng", 3)
            break
        end
        task.wait(3)
    end
    State.AutoGachaFruit = false
end

local function FruitPickupLoop()
    while ENV["NGP_Fruits"] do
        local cancelCheck = function() return not ENV["NGP_Fruits"] end
        local found = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if cancelCheck() then break end
            if obj:IsA("Tool") then continue end
            if obj.Name:find("Fruit") or obj.Name:find("Devil") then
                local pos, hint
                if obj:IsA("BasePart") then
                    pos = obj.Position
                    hint = obj.Parent and obj.Parent.Name
                elseif obj:IsA("Model") then
                    local ok, cf = pcall(function() return obj:GetModelCFrame().Position end)
                    if ok then pos = cf hint = obj.Name end
                end
                if pos then
                    SmartTravel(pos, hint, cancelCheck)
                    found = true
                    task.wait(0.3)
                end
            end
        end
        task.wait(found and 0.5 or 2)
    end
end

-- ============================================================
--                    NEON THEME + SPLASH + UI
-- ============================================================

if CoreGui:FindFirstChild("NGPHub") then CoreGui.NGPHub:Destroy() end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NGPHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = lp.PlayerGui end

-- NEON THEME: trắng nền chủ đạo, đen viền, neon accent
local THEME = {
    WHITE       = Color3.fromRGB(245,245,250),   -- nền chính
    WHITE_SOFT  = Color3.fromRGB(232,232,242),
    WHITE_DIM   = Color3.fromRGB(215,215,230),
    BLACK       = Color3.fromRGB(8,8,12),         -- viền
    BLACK_SOFT  = Color3.fromRGB(30,30,40),
    TEXT_DARK   = Color3.fromRGB(15,15,25),
    TEXT_LIGHT  = Color3.fromRGB(245,245,250),
    SUBTEXT     = Color3.fromRGB(90,90,110),
    NEON_PINK   = Color3.fromRGB(255,40,180),
    NEON_PURPLE = Color3.fromRGB(160,80,255),
    NEON_CYAN   = Color3.fromRGB(0,230,255),
    NEON_GREEN  = Color3.fromRGB(50,255,150),
    NEON_YELLOW = Color3.fromRGB(255,220,50),
    NEON_RED    = Color3.fromRGB(255,70,90),
    TOGGLE_ON   = Color3.fromRGB(50,255,150),
    TOGGLE_OFF  = Color3.fromRGB(200,200,215),
}

local function Corner(r,p) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=p; return c end
local function Stroke(t,c,p,trans) local s=Instance.new("UIStroke"); s.Thickness=t; s.Color=c; s.Transparency=trans or 0; s.Parent=p; return s end
local function Padding(t,b,l,r,p)
    local pad=Instance.new("UIPadding")
    pad.PaddingTop=UDim.new(0,t) pad.PaddingBottom=UDim.new(0,b)
    pad.PaddingLeft=UDim.new(0,l) pad.PaddingRight=UDim.new(0,r)
    pad.Parent=p return pad
end
local function List(sp,p)
    local l=Instance.new("UIListLayout")
    l.SortOrder=Enum.SortOrder.LayoutOrder
    l.Padding=UDim.new(0,sp)
    l.Parent=p return l
end
local function Frame(name,size,pos,color,parent)
    local f=Instance.new("Frame")
    f.Name=name f.Size=size f.Position=pos
    f.BackgroundColor3=color f.BorderSizePixel=0
    f.Parent=parent return f
end
local function Label(txt,size,pos,color,textSize,parent)
    local l=Instance.new("TextLabel")
    l.Text=txt l.Size=size l.Position=pos
    l.BackgroundTransparency=1 l.TextColor3=color
    l.TextSize=textSize l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=parent return l
end

local BG_IMAGE_ID = "rbxassetid://126404341275153"
local imgOk = pcall(function()
    local test = Instance.new("ImageLabel")
    test.Image = BG_IMAGE_ID test.Parent = ScreenGui
    test.Size = UDim2.new(0,1,0,1)
    task.wait(0.05)
    test:Destroy()
end)

-- ===================== SPLASH LOAD (Rayfield style) =====================
local Splash = Frame("Splash", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), THEME.BLACK, ScreenGui)
Splash.ZIndex = 500
Splash.BackgroundTransparency = 0.15

local SplashCard = Frame("SplashCard", UDim2.new(0,380,0,180), UDim2.new(0.5,-190,0.5,-90), THEME.WHITE, Splash)
SplashCard.ZIndex = 501
Corner(18, SplashCard)
Stroke(3, THEME.NEON_PURPLE, SplashCard, 0.2)

local SplashLogo = Frame("SplashLogo", UDim2.new(0,64,0,64), UDim2.new(0.5,-32,0,24), THEME.NEON_PURPLE, SplashCard)
SplashLogo.ZIndex = 502
Corner(16, SplashLogo)
local SplashLogoLabel = Label("N", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), THEME.TEXT_LIGHT, 30, SplashLogo)
SplashLogoLabel.TextXAlignment = Enum.TextXAlignment.Center
SplashLogoLabel.Font = Enum.Font.GothamBlack

local SplashTitle = Label("Nguyen Gia Phuc Hub", UDim2.new(1,0,0,28), UDim2.new(0,0,0,100), THEME.TEXT_DARK, 20, SplashCard)
SplashTitle.TextXAlignment = Enum.TextXAlignment.Center
SplashTitle.Font = Enum.Font.GothamBold

local SplashSub = Label("Loading...", UDim2.new(1,0,0,18), UDim2.new(0,0,0,132), THEME.SUBTEXT, 12, SplashCard)
SplashSub.TextXAlignment = Enum.TextXAlignment.Center
SplashSub.Font = Enum.Font.Gotham

-- progress bar
local SplashBarBG = Frame("SplashBarBG", UDim2.new(1,-60,0,4), UDim2.new(0,30,0,158), THEME.WHITE_DIM, SplashCard)
Corner(2, SplashBarBG)
local SplashBarFill = Frame("SplashBarFill", UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), THEME.NEON_PURPLE, SplashBarBG)
Corner(2, SplashBarFill)

task.spawn(function()
    TweenService:Create(SplashBarFill, TweenInfo.new(1.6, Enum.EasingStyle.Quad), {Size = UDim2.new(1,0,1,0)}):Play()
    task.wait(1.7)
    TweenService:Create(Splash, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    TweenService:Create(SplashCard, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.45)
    Splash:Destroy()
end)

-- ===================== MAIN PANEL =====================
local DEFAULT_W, DEFAULT_H = 720, 500
local Panel = Frame("Panel", UDim2.new(0,DEFAULT_W,0,DEFAULT_H), UDim2.new(0.5,-DEFAULT_W/2,0.5,-DEFAULT_H/2), THEME.WHITE, ScreenGui)
Panel.Visible = false
Corner(18, Panel)
Stroke(2.5, THEME.BLACK, Panel, 0)

local DrawContainer = Frame("DrawContainer", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), THEME.WHITE, Panel)
DrawContainer.ClipsDescendants = true
Corner(18, DrawContainer)

-- image nền mờ
local BGImage = Instance.new("ImageLabel")
BGImage.Size = UDim2.new(1,0,1,0)
BGImage.BackgroundTransparency = 1
BGImage.Image = BG_IMAGE_ID
BGImage.ScaleType = Enum.ScaleType.Crop
BGImage.ImageTransparency = imgOk and 0.82 or 1
BGImage.Parent = DrawContainer
Corner(18, BGImage)

-- neon glow
local GlowTop = Frame("GlowTop", UDim2.new(0,350,0,350), UDim2.new(1,-175,0,-175), THEME.NEON_PURPLE, DrawContainer)
GlowTop.BackgroundTransparency = 0.85
local gc1 = Instance.new("UICorner"); gc1.CornerRadius = UDim.new(1,0); gc1.Parent = GlowTop
GlowTop.ZIndex = 2

local GlowBottom = Frame("GlowBottom", UDim2.new(0,280,0,280), UDim2.new(0,-120,1,-120), THEME.NEON_CYAN, DrawContainer)
GlowBottom.BackgroundTransparency = 0.88
local gc2 = Instance.new("UICorner"); gc2.CornerRadius = UDim.new(1,0); gc2.Parent = GlowBottom
GlowBottom.ZIndex = 2

task.spawn(function()
    while Panel.Parent do
        TweenService:Create(GlowTop, TweenInfo.new(3, Enum.EasingStyle.Sine), {BackgroundTransparency=0.72, Position=UDim2.new(1,-190,0,-160)}):Play()
        TweenService:Create(GlowBottom, TweenInfo.new(3, Enum.EasingStyle.Sine), {BackgroundTransparency=0.75, Position=UDim2.new(0,-90,1,-140)}):Play()
        task.wait(3)
        TweenService:Create(GlowTop, TweenInfo.new(3, Enum.EasingStyle.Sine), {BackgroundTransparency=0.9, Position=UDim2.new(1,-150,0,-180)}):Play()
        TweenService:Create(GlowBottom, TweenInfo.new(3, Enum.EasingStyle.Sine), {BackgroundTransparency=0.92, Position=UDim2.new(0,-130,1,-100)}):Play()
        task.wait(3)
    end
end)

-- HEADER
local Header = Frame("Header", UDim2.new(1,0,0,60), UDim2.new(0,0,0,0), THEME.BLACK, Panel)
Header.BackgroundTransparency = 0
local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0,18); hc.Parent = Header
local headerMask = Frame("HeaderMask", UDim2.new(1,0,0.5,0), UDim2.new(0,0,0,0.5), THEME.BLACK, Header)

local Logo = Frame("Logo", UDim2.new(0,40,0,40), UDim2.new(0,18,0.5,-20), THEME.NEON_PURPLE, Header)
Corner(12, Logo)
Stroke(2, THEME.NEON_PINK, Logo, 0.3)
local LogoLabel = Label("N", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), THEME.TEXT_LIGHT, 20, Logo)
LogoLabel.TextXAlignment = Enum.TextXAlignment.Center
LogoLabel.Font = Enum.Font.GothamBlack

local Title = Label("Nguyen Gia Phuc Hub", UDim2.new(0,300,0,22), UDim2.new(0,70,0,10), THEME.TEXT_LIGHT, 17, Header)
local Subtitle = Label("Blox Fruits • Universal", UDim2.new(0,300,0,14), UDim2.new(0,70,0,32), THEME.NEON_CYAN, 11, Header)
Subtitle.Font = Enum.Font.Gotham

local Badge = Frame("Badge", UDim2.new(0,58,0,22), UDim2.new(1,-140,0.5,-11), THEME.NEON_PURPLE, Header)
Corner(11, Badge)
Stroke(1.5, THEME.NEON_PINK, Badge, 0.3)
local BadgeLabel = Label("HUB", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), THEME.TEXT_LIGHT, 11, Badge)
BadgeLabel.TextXAlignment = Enum.TextXAlignment.Center

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,28,0,28)
CloseBtn.Position = UDim2.new(1,-38,0.5,-14)
CloseBtn.BackgroundColor3 = THEME.NEON_RED
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = THEME.TEXT_LIGHT
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
Corner(8, CloseBtn)
Stroke(1.5, THEME.NEON_RED, CloseBtn, 0)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
        Size=UDim2.new(0,0,0,0),
        Position=UDim2.new(0.5,0,0.5,0),
    }):Play()
    task.delay(0.25, function() Panel.Visible = false end)
end)

-- DRAG HEADER
local dragging, dragOffset = false, Vector2.new()
Header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragOffset = Vector2.new(inp.Position.X - Panel.AbsolutePosition.X, inp.Position.Y - Panel.AbsolutePosition.Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        Panel.Position = UDim2.new(0, inp.Position.X - dragOffset.X, 0, inp.Position.Y - dragOffset.Y)
    end
end)

-- RESIZE HANDLE
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size = UDim2.new(0,18,0,18)
ResizeHandle.Position = UDim2.new(1,-18,1,-18)
ResizeHandle.BackgroundColor3 = THEME.NEON_PURPLE
ResizeHandle.BackgroundTransparency = 0.3
ResizeHandle.Text = ""
ResizeHandle.BorderSizePixel = 0
ResizeHandle.AutoButtonColor = false
ResizeHandle.ZIndex = 100
ResizeHandle.Parent = Panel
Corner(6, ResizeHandle)
Stroke(1.5, THEME.BLACK, ResizeHandle, 0)

for i = 1, 3 do
    local line = Frame("RL"..i, UDim2.new(0,8,0,1), UDim2.new(1,-10-i*2,1,-10-i*2), THEME.TEXT_LIGHT, ResizeHandle)
    line.Rotation = -45
end

local resizing, resizeStart, resizeStartSize = false, Vector2.new(), Vector2.new()
ResizeHandle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = Vector2.new(inp.Position.X, inp.Position.Y)
        resizeStartSize = Vector2.new(Panel.AbsoluteSize.X, Panel.AbsoluteSize.Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)
UIS.InputChanged:Connect(function(inp)
    if resizing and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local dx = inp.Position.X - resizeStart.X
        local dy = inp.Position.Y - resizeStart.Y
        Panel.Size = UDim2.new(0, math.clamp(resizeStartSize.X + dx, 480, 1100), 0, math.clamp(resizeStartSize.Y + dy, 340, 780))
    end
end)

-- SIDEBAR (trắng, viền đen)
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0,150,1,-72)
Sidebar.Position = UDim2.new(0,10,0,68)
Sidebar.BackgroundColor3 = THEME.WHITE_SOFT
Sidebar.BackgroundTransparency = 0
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 3
Sidebar.ScrollBarImageColor3 = THEME.NEON_PURPLE
Sidebar.CanvasSize = UDim2.new(0,0,0,0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.Parent = Panel
Corner(12, Sidebar)
Stroke(2, THEME.BLACK, Sidebar, 0)
Padding(8, 8, 6, 6, Sidebar)
List(3, Sidebar)

local ContentArea = Frame("Content", UDim2.new(1,-172,1,-72), UDim2.new(0,168,0,68), THEME.WHITE, Panel)
ContentArea.BackgroundTransparency = 0
Corner(12, ContentArea)
Stroke(2, THEME.BLACK, ContentArea, 0)

-- TABS
local Pages = {}
local TabButtons = {}

local function MakePage(name)
    local page = Frame("Page_"..name, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), THEME.WHITE, ContentArea)
    page.BackgroundTransparency = 1 page.Visible = false
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,0) scroll.Position = UDim2.new(0,0,0,0)
    scroll.BackgroundTransparency = 1 scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3 scroll.ScrollBarImageColor3 = THEME.NEON_PURPLE
    scroll.CanvasSize = UDim2.new(0,0,0,0) scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = page
    Padding(12, 12, 14, 14, scroll)
    List(7, scroll)
    Pages[name] = {frame=page, scroll=scroll}
    return Pages[name]
end

local TAB_ORDER = {
    "Farm","Skill","Halloween","Level 3000","Fishing","ESP",
    "Stats","Fruits","Stack","Hop Farm","Quest","Sea","Teleport","Race",
    "Shop","Server","PVP","Settings","Discord",
}
local TAB_ICONS = {
    Farm="🌾", Skill="⚔️",
    Halloween="🎃", ["Level 3000"]="🔎", Fishing="🎣", ESP="👁",
    Stats="📊", Fruits="🍎", Stack="⚡", ["Hop Farm"]="🔁",
    Quest="📋", Sea="🌊", Teleport="🗺", Race="🧬",
    Shop="🛒", Server="🖥", PVP="🎯", Settings="⚙️", Discord="💬",
}

local function SelectTab(name)
    for n, btn in pairs(TabButtons) do
        TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            BackgroundColor3 = n == name and THEME.NEON_PURPLE or THEME.WHITE,
            BackgroundTransparency = n == name and 0 or 0.6,
        }):Play()
        btn.TextColor3 = n == name and THEME.TEXT_LIGHT or THEME.TEXT_DARK
    end
    for n, pg in pairs(Pages) do pg.frame.Visible = (n == name) end
end

for _, tabName in ipairs(TAB_ORDER) do
    MakePage(tabName)
    local icon = TAB_ICONS[tabName] or "•"
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,34)
    btn.BackgroundColor3 = THEME.WHITE
    btn.BackgroundTransparency = 0.6
    btn.TextColor3 = THEME.TEXT_DARK
    btn.Text = icon.."  "..tabName
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    Corner(7, btn) Padding(0, 0, 10, 4, btn)
    Stroke(1, THEME.BLACK, btn, 0.5)
    TabButtons[tabName] = btn
    btn.MouseButton1Click:Connect(function() SelectTab(tabName) end)
end

-- WIDGETS
local function Add(tabName, element)
    local pg = Pages[tabName]
    if pg then element.Parent = pg.scroll end
end

local function MakeSection(parent, text)
    local row = Frame("Section", UDim2.new(1,0,0,26), UDim2.new(0,0,0,0), Color3.fromRGB(0,0,0), parent)
    row.BackgroundTransparency = 1
    local bar = Frame("Bar", UDim2.new(0,3,0,16), UDim2.new(0,0,0.5,-8), THEME.NEON_PURPLE, row)
    Corner(2, bar)
    local lbl = Label("  "..text, UDim2.new(1,0,1,0), UDim2.new(8,0,0,0), THEME.NEON_PURPLE, 12, row)
    return row
end

local function MakeToggle(parent, labelText, default, onToggle)
    local row = Frame("ToggleRow", UDim2.new(1,0,0,38), UDim2.new(0,0,0,0), Color3.fromRGB(0,0,0), parent)
    row.BackgroundTransparency = 1
    Label(labelText, UDim2.new(1,-60,1,0), UDim2.new(0,0,0,0), THEME.TEXT_DARK, 13, row)
    local track = Frame("Track", UDim2.new(0,46,0,24), UDim2.new(1,-50,0.5,-12), default and THEME.TOGGLE_ON or THEME.TOGGLE_OFF, row)
    Corner(12, track)
    Stroke(1.5, THEME.BLACK, track, 0.3)
    local knob = Frame("Knob", UDim2.new(0,18,0,18), UDim2.new(default and 1 or 0, default and -21 or 3, 0.5, -9), THEME.WHITE, track)
    Corner(9, knob)
    Stroke(1, THEME.BLACK, knob, 0.4)
    local state = default
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0) btn.BackgroundTransparency = 1 btn.Text = "" btn.Parent = row
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {BackgroundColor3 = state and THEME.TOGGLE_ON or THEME.TOGGLE_OFF}):Play()
        TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = UDim2.new(state and 1 or 0, state and -21 or 3, 0.5, -9)}):Play()
        if onToggle then onToggle(state) end
    end)
    return row
end

local function MakeSlider(parent, labelText, min, max, default, suffix, onChange)
    local container = Frame("SliderContainer", UDim2.new(1,0,0,58), UDim2.new(0,0,0,0), Color3.fromRGB(0,0,0), parent)
    container.BackgroundTransparency = 1
    Label(labelText, UDim2.new(0.7,0,0,18), UDim2.new(0,0,0,0), THEME.TEXT_DARK, 12, container)
    local valLbl = Label(tostring(default)..(suffix or ""), UDim2.new(0.3,0,0,18), UDim2.new(0.7,0,0,0), THEME.NEON_PURPLE, 12, container)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    local track = Frame("Track", UDim2.new(1,0,0,8), UDim2.new(0,0,0,28), THEME.WHITE_DIM, container)
    Corner(4, track)
    Stroke(1, THEME.BLACK, track, 0.4)
    local fill = Frame("Fill", UDim2.new((default-min)/(max-min),0,1,0), UDim2.new(0,0,0,0), THEME.NEON_PURPLE, track)
    Corner(4, fill)
    local knob = Frame("Knob", UDim2.new(0,14,0,14), UDim2.new((default-min)/(max-min),0,-7,0.5,-7), THEME.WHITE, track)
    Corner(7, knob)
    Stroke(1.5, THEME.BLACK, knob, 0.3)
    local drag = false
    local function update(x)
        local abs = track.AbsolutePosition.X
        local w = track.AbsoluteSize.X
        local pct = math.clamp((x-abs)/w, 0, 1)
        local val = math.floor(min + pct*(max-min))
        fill.Size = UDim2.new(pct,0,1,0)
        knob.Position = UDim2.new(pct,0,-7,0.5,-7)
        valLbl.Text = tostring(val)..(suffix or "")
        if onChange then onChange(val) end
    end
    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then drag = true end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UIS.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then update(inp.Position.X) end
    end)
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then update(inp.Position.X) end
    end)
    return container
end

local function MakeDropdown(parent, labelText, options, default, onChange)
    local container = Frame("DropContainer", UDim2.new(1,0,0,58), UDim2.new(0,0,0,0), Color3.fromRGB(0,0,0), parent)
    container.BackgroundTransparency = 1
    Label(labelText, UDim2.new(1,0,0,18), UDim2.new(0,0,0,0), THEME.TEXT_DARK, 12, container)
    local selected = default or options[1]
    local dropBtn = Frame("DropBtn", UDim2.new(1,0,0,32), UDim2.new(0,0,0,22), THEME.WHITE_SOFT, container)
    Corner(7, dropBtn) Stroke(1.5, THEME.BLACK, dropBtn, 0.3)
    Padding(0, 0, 10, 10, dropBtn)
    local selLbl = Label(selected, UDim2.new(0.85,0,1,0), UDim2.new(0,0,0,0), THEME.TEXT_DARK, 12, dropBtn)
    local arrow = Label("▼", UDim2.new(0.15,0,1,0), UDim2.new(0.85,0,0,0), THEME.NEON_PURPLE, 10, dropBtn)
    arrow.TextXAlignment = Enum.TextXAlignment.Right
    local list = Frame("List", UDim2.new(1,0,0,#options*30), UDim2.new(0,0,1,3), THEME.WHITE, container)
    list.ZIndex = 10 list.Visible = false
    Corner(7, list) Stroke(1.5, THEME.BLACK, list, 0.3)
    for i, opt in ipairs(options) do
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1,0,0,30)
        row.Position = UDim2.new(0,0,0,(i-1)*30)
        row.BackgroundColor3 = THEME.WHITE
        row.BackgroundTransparency = 0.1
        row.Text = opt row.TextColor3 = THEME.TEXT_DARK row.TextSize = 12
        row.Font = Enum.Font.Gotham row.TextXAlignment = Enum.TextXAlignment.Left
        row.BorderSizePixel = 0 row.AutoButtonColor = false row.ZIndex = 11 row.Parent = list
        Padding(0, 0, 12, 0, row)
        row.MouseButton1Click:Connect(function()
            selected = opt selLbl.Text = opt list.Visible = false
            if onChange then onChange(opt) end
        end)
    end
    local open = false
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1,0,1,0) clickBtn.BackgroundTransparency = 1
    clickBtn.Text = "" clickBtn.Parent = dropBtn clickBtn.ZIndex = 5
    clickBtn.MouseButton1Click:Connect(function()
        open = not open list.Visible = open
        arrow.Text = open and "▲" or "▼"
    end)
    return container
end

local function MakeButton(parent, labelText, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,34)
    btn.BackgroundColor3 = THEME.WHITE_SOFT
    btn.TextColor3 = THEME.TEXT_DARK
    btn.Text = labelText
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    Corner(7, btn)
    Stroke(1.5, THEME.BLACK, btn, 0.3)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.WHITE}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.WHITE_SOFT}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = THEME.NEON_PURPLE, TextColor3 = THEME.TEXT_LIGHT}):Play()
        task.delay(0.2, function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.WHITE_SOFT, TextColor3 = THEME.TEXT_DARK}):Play()
        end)
        if onClick then onClick() end
    end)
    return btn
end

local function MakeInput(parent, placeholder, onChange)
    local bg = Frame("InputBG", UDim2.new(1,0,0,34), UDim2.new(0,0,0,0), THEME.WHITE_SOFT, parent)
    Corner(7, bg) Stroke(1.5, THEME.BLACK, bg, 0.3)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-18,1,0) box.Position = UDim2.new(0,9,0,0)
    box.BackgroundTransparency = 1 box.TextColor3 = THEME.TEXT_DARK
    box.PlaceholderText = placeholder box.PlaceholderColor3 = THEME.SUBTEXT
    box.TextSize = 12 box.Font = Enum.Font.Gotham
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false box.Parent = bg
    box.FocusLost:Connect(function() if onChange then onChange(box.Text) end end)
    return bg
end

local function MakeLabel(parent, text, color)
    local l = Label(text, UDim2.new(1,0,0,18), UDim2.new(0,0,0,0), color or THEME.SUBTEXT, 11, parent)
    l.Font = Enum.Font.Gotham
    return l
end

local function AddSection(tab, text) Add(tab, MakeSection(nil, text)) end
local function AddToggle(tab, label, default, cb) Add(tab, MakeToggle(nil, label, default, cb)) end
local function AddButton(tab, label, cb) Add(tab, MakeButton(nil, label, cb)) end
local function AddSlider(tab, label, min, max, default, suffix, cb) Add(tab, MakeSlider(nil, label, min, max, default, suffix, cb)) end
local function AddDropdown(tab, label, opts, default, cb) Add(tab, MakeDropdown(nil, label, opts, default, cb)) end
local function AddLabel(tab, text) Add(tab, MakeLabel(nil, text)) end
local function AddInput(tab, placeholder, cb) Add(tab, MakeInput(nil, placeholder, cb)) end

-- ===================== NOTIFICATION =====================
local notifContainer = Frame("Notifs", UDim2.new(0,320,0,0), UDim2.new(1,-340,1,-30), Color3.fromRGB(0,0,0), ScreenGui)
notifContainer.BackgroundTransparency = 1
notifContainer.AnchorPoint = Vector2.new(0,1)
notifContainer.AutomaticSize = Enum.AutomaticSize.Y
List(7, notifContainer)

function ShowNotif(title, msg, dur)
    local card = Frame("Notif", UDim2.new(1,0,0,64), UDim2.new(0,0,0,0), THEME.WHITE, notifContainer)
    card.BackgroundTransparency = 0
    Corner(10, card) Stroke(2, THEME.NEON_PURPLE, card, 0)
    Padding(8, 8, 12, 12, card)
    local bar = Frame("Bar", UDim2.new(0,3,1,-16), UDim2.new(0,0,0,8), THEME.NEON_PURPLE, card)
    Corner(2, bar)
    Label("⚡ "..title, UDim2.new(1,-16,0,20), UDim2.new(18,0,0,0), THEME.NEON_PURPLE, 13, card)
    Label(msg, UDim2.new(1,-16,0,20), UDim2.new(18,0,0,24), THEME.TEXT_DARK, 11, card)
    card.Position = UDim2.new(1,12,0,0)
    TweenService:Create(card, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
    task.delay(dur or 3.5, function()
        TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1,12,0,0), BackgroundTransparency = 1}):Play()
        task.delay(0.35, function() card:Destroy() end)
    end)
end

-- ============================================================
--                    POPULATE TABS
-- ============================================================

-- FARM
AddSection("Farm", "Chế Độ Farm")
AddDropdown("Farm", "Farm Mode", {"Farm Level","Farm Near Mobs","Farm Level Secret"}, "Farm Level", function(v)
    State.FarmMode = v
    ShowNotif("Farm", "Đã đổi mode: "..v, 3)
end)
AddLabel("Farm", "Farm Level: Bay gateway tới mob, auto bring mob")
AddLabel("Farm", "Farm Near Mobs: Đứng yên, auto bring mob")
AddLabel("Farm", "Farm Level Secret: Nhiệm vụ bí ẩn Sea 1")

AddSection("Farm", "Chọn Mục Tiêu")
local targetList = {"Auto"}
for k in pairs(MOB_TARGETS) do if k ~= "Auto" then table.insert(targetList, k) end end
table.sort(targetList)
AddDropdown("Farm", "Mob Target", targetList, "Auto", function(v)
    State.FarmTarget = v
    ShowNotif("Farm", "Mục tiêu: "..v, 3)
end)

AddSection("Farm", "Điều Khiển")
AddToggle("Farm", "Auto Farm", false, function(v)
    State.AutoFarm = v
    if v then
        ShowNotif("Farm", "Auto Farm BẬT — Mode: "..State.FarmMode, 3)
        StartFarmLoop()
    else
        ShowNotif("Farm", "Auto Farm TẮT", 3)
    end
end)
AddToggle("Farm", "Auto Skill khi Farm", false, function(v)
    State.AutoSkill = v
    ShowNotif("Skill", v and "Auto Skill BẬT" or "Auto Skill TẮT", 3)
end)
AddSlider("Farm", "Chiều Cao Bay", 0, 200, 50, " studs", function(v) State.FlyHeight = v end)
AddSlider("Farm", "Phạm Vi Auto Bring Mob", 30, 400, 150, " studs", function(v) State.BringMobRange = v end)
AddLabel("Farm", "Bring Mob tự động — không cần bật/tắt riêng")

AddSection("Farm", "Thu Thập")
AddToggle("Farm", "Auto Collect Berry", false, function(v)
    State.AutoCollectBerry = v
    ShowNotif("Farm", v and "Auto Berry BẬT" or "Auto Berry TẮT", 3)
    if v then task.spawn(CollectBerryLoop) end
end)
AddToggle("Farm", "Auto Collect Chest", false, function(v)
    State.AutoChest = v
    ShowNotif("Farm", v and "Auto Chest BẬT" or "Auto Chest TẮT", 3)
    if v then task.spawn(CollectChestLoop) end
end)
AddToggle("Farm", "Auto Hop Find Berry", false, function(v)
    ENV["NGP_HopBerry"] = v
    ShowNotif("Farm", v and "Auto Hop Berry BẬT" or "Auto Hop Berry TẮT", 3)
    if v then task.spawn(function() while ENV["NGP_HopBerry"] do RemoteInvoke("HopFindBerry") task.wait(30) end end) end
end)
AddToggle("Farm", "Accept Quests", false, function(v)
    ENV["NGP_Quest"] = v
    ShowNotif("Quest", v and "Auto Accept Quests BẬT" or "TẮT", 3)
    if v then task.spawn(function() while ENV["NGP_Quest"] do RemoteInvoke("StartQuest","Current") task.wait(5) end end) end
end)
AddToggle("Farm", "Auto Complete Bartilo", false, function(v)
    ENV["NGP_Bartilo"] = v
    ShowNotif("Quest", v and "Auto Bartilo BẬT" or "TẮT", 3)
    if v then task.spawn(function()
        while ENV["NGP_Bartilo"] do
            RemoteInvoke("StartQuest","Bartilo") task.wait(2)
            RemoteInvoke("CompleteQuest","Bartilo") task.wait(3)
        end
    end) end
end)
AddToggle("Farm", "Auto Training Dummy", false, function(v)
    ENV["NGP_Dummy"] = v
    ShowNotif("Farm", v and "Auto Training Dummy BẬT" or "TẮT", 3)
    if v then task.spawn(function()
        while ENV["NGP_Dummy"] do
            local d = Workspace:FindFirstChild("TrainingDummy", true)
            if d and d:FindFirstChild("HumanoidRootPart") then
                TweenMove(d.HumanoidRootPart.Position + Vector3.new(0,3,0), State.FlySpeed, function() return not ENV["NGP_Dummy"] end)
                if State.AutoSkill then UseSkills() end
            end
            task.wait(0.5)
        end
    end) end
end)

AddSection("Farm", "Boss Farm")
local bossList = {"Darkbeard","Rip_indra","Dough King","Cake Prince","Terrorshark","Elite Pirate","Stone","Island Empress"}
AddDropdown("Farm", "Choose Boss", bossList, "Darkbeard", function(v)
    State.SelectedBoss = v
    ShowNotif("Boss", "Đã chọn: "..v, 3)
end)
AddButton("Farm", "Boss Farm (selected)", function()
    State.FarmTarget = State.SelectedBoss
    State.FarmMode = "Farm Level"
    State.AutoFarm = true
    ShowNotif("Boss", "Farm "..State.SelectedBoss.." — bật Auto Farm", 3)
    StartFarmLoop()
end)

-- SKILL
AddSection("Skill", "Cấu Hình Kỹ Năng")
AddSlider("Skill", "Skill Delay", 0, 20, 3, " ms", function(v) State.SkillDelay = v/10 end)
for _, info in ipairs({{"Z",Enum.KeyCode.Z},{"X",Enum.KeyCode.X},{"C",Enum.KeyCode.C},{"V",Enum.KeyCode.V}}) do
    local name, kc = info[1], info[2]
    local fk = "NGP_SK"..name
    AddToggle("Skill", "Spam Skill "..name, false, function(v)
        ENV[fk] = v
        ShowNotif("Skill", "Spam "..name..(v and " BẬT" or " TẮT"), 2.5)
        if v then task.spawn(function()
            while ENV[fk] do
                PressKey(kc, true) task.wait(State.SkillDelay)
                PressKey(kc, false) task.wait(State.SkillDelay)
            end
        end) end
    end)
end

-- HALLOWEEN
AddSection("Halloween", "🎃 Trick or Treat")
AddToggle("Halloween", "Auto Trick or Treat", false, function(v)
    State.AutoTrickOrTreat = v
    ShowNotif("Halloween", v and "Auto Trick or Treat BẬT" or "TẮT", 3)
    if v then task.spawn(HWTrickLoop) end
end)
AddButton("Halloween", "Oni Celestial Choice", function()
    RemoteInvoke("HalloweenEvent", "CelestialChoice", "Oni")
    ShowNotif("Halloween", "Đã chọn Celestial Oni", 3)
end)
AddSection("Halloween", "🎃 Pumpkin Hunt")
AddToggle("Halloween", "Auto Pumpkin Hunt", false, function(v)
    State.AutoPumpkinHunt = v
    ShowNotif("Halloween", v and "Auto Pumpkin Hunt BẬT" or "TẮT", 3)
    if v then task.spawn(HWPumpkinLoop) end
end)
AddButton("Halloween", "Hop Server for Cursed Pumpkin Seed", function()
    ShowNotif("Halloween", "Đang hop server...", 3)
    TeleportService:Teleport(game.PlaceId, lp)
end)
AddSection("Halloween", "🎃 Great Pumpkin")
AddToggle("Halloween", "Auto Farm Great Pumpkin", false, function(v)
    State.AutoGreatPumpkin = v
    ShowNotif("Halloween", v and "Auto Great Pumpkin BẬT" or "TẮT", 3)
    if v then task.spawn(HWGreatPumpkinLoop) end
end)
AddButton("Halloween", "Summon Great Pumpkin", function()
    RemoteInvoke("HalloweenEvent", "SummonGreatPumpkin")
    ShowNotif("Halloween", "Đã summon Great Pumpkin", 3)
end)

-- LEVEL 3000
AddSection("Level 3000", "Secret Quest Seal")
AddLabel("Level 3000", "Yêu cầu: Level 2800+ tại Sea 1")
AddLabel("Level 3000", "Thứ tự NPC: Expert → Scientist → Horned Man → Shanks")
AddButton("Level 3000", "Xem Tiến Độ Secret Quest", function()
    ShowNotif("Secret Quest", "Đã hoàn thành: "..State.SecretQuestDone.." lượt", 4)
end)
AddToggle("Level 3000", "Auto Secret Quest", false, function(v)
    State.AutoSecretQuest = v
    if v then
        State.FarmMode = "Farm Level Secret"
        State.AutoFarm = true
        ShowNotif("Secret Quest", "Auto Secret Quest BẬT", 3)
        StartFarmLoop()
    else
        ShowNotif("Secret Quest", "TẮT", 3)
    end
end)

-- FISHING
AddSection("Fishing", "Auto Fishing")
AddToggle("Fishing", "Auto Fishing Quest", false, function(v)
    State.AutoFishing = v
    ShowNotif("Fishing", v and "Auto Fishing BẬT" or "TẮT", 3)
    if v then task.spawn(FishingLoop) end
end)
AddToggle("Fishing", "Auto Sell Fish", false, function(v)
    State.AutoSellFish = v
    ShowNotif("Fishing", v and "Auto Sell Fish BẬT" or "TẮT", 3)
end)
AddButton("Fishing", "Teleport đến Fishing Spot", function()
    ShowNotif("Teleport", "Đang bay tới Fishing Spot...", 3)
    TweenMove(Vector3.new(1746, 11, 1297), State.FlySpeed)
    ShowNotif("Teleport", "Đã đến Fishing Spot", 3)
end)
AddButton("Fishing", "Teleport đến Sharkman Master", function()
    ShowNotif("Teleport", "Đang bay tới Sharkman Master...", 3)
    TweenMove(Vector3.new(-3215, 8, 2800), State.FlySpeed)
    ShowNotif("Teleport", "Đã đến Sharkman Master", 3)
end)

-- ESP
AddSection("ESP", "ESP Mob / Enemy")
AddToggle("ESP", "Bật ESP Mob", false, function(v)
    State.ESPEnabled = v
    ShowNotif("ESP", v and "ESP Mob BẬT" or "TẮT", 3)
    if v then task.spawn(ESPLoop) end
end)

-- STATS
AddSection("Stats", "Phân Phối Chỉ Số")
for _, s in ipairs({"Melee","Sword","Gun","Fruit","Defense"}) do
    AddInput("Stats", "Điểm "..s.." (nhập số)...", function(v) State.StatPoints[s] = tonumber(v) or 0 end)
end
AddToggle("Stats", "Auto Phân Phối Stats", false, function(v)
    State.AutoStats = v
    ShowNotif("Stats", v and "Auto Stats BẬT" or "TẮT", 3)
    if v then task.spawn(AutoStatsLoop) end
end)
AddSection("Stats", "Auto Stats Buttons")
for _, s in ipairs({"Melee","Sword","Gun","Fruit","Defense"}) do
    AddButton("Stats", "Auto Max "..s, function()
        ShowNotif("Stats", "Đang max "..s.."...", 2)
        RemoteInvoke("AddStats", s == "Fruit" and "BloxFruit" or s, 99999)
        ShowNotif("Stats", "Đã max "..s, 3)
    end)
end

-- FRUITS (notify toàn bộ)
AddSection("Fruits", "Quét & Gacha Fruit")
AddLabel("Fruits", "Bấm quét để kiểm tra fruit trong server")
AddButton("Fruits", "🔍 Quét Trái Trong Server", function()
    ShowNotif("Scan", "Đang quét trái trong server...", 2)
    local fruits = ScanFruitsInServer()
    if #fruits > 0 then
        local names = {}
        for i, f in ipairs(fruits) do
            table.insert(names, f.name)
            if i >= 5 then break end
        end
        ShowNotif("Scan", "Tìm thấy "..#fruits.." trái: "..table.concat(names, ", "), 5)
        ShowNotif("Scan", "Bật 'Auto Nhặt Trái Rơi' để tự động lấy", 5)
    else
        ShowNotif("Scan", "Server hiện không có trái nào đang rơi", 4)
    end
end)
AddButton("Fruits", "Check Fruit Đang Sở Hữu", function()
    local has, name = HasFruitEquipped()
    if has then
        ShowNotif("Fruits", "Bạn đang có: "..name, 4)
    else
        ShowNotif("Fruits", "Bạn chưa có fruit nào", 4)
    end
end)
AddToggle("Fruits", "Auto Gacha (nếu chưa có)", false, function(v)
    State.AutoGachaFruit = v
    if v then
        local has, name = HasFruitEquipped()
        if has then
            ShowNotif("Gacha", "Đã có: "..tostring(name).." — không gacha", 3)
            State.AutoGachaFruit = false
        else
            ShowNotif("Gacha", "Auto Gacha BẬT — sẽ mua random tới khi có fruit", 3)
            task.spawn(AutoGachaLoop)
        end
    else
        ShowNotif("Gacha", "Auto Gacha TẮT", 3)
    end
end)

AddSection("Fruits", "Trái Ác Quỷ")
AddToggle("Fruits", "Auto Nhặt Trái Rơi", false, function(v)
    ENV["NGP_Fruits"] = v
    ShowNotif("Fruits", v and "Auto Nhặt Trái BẬT" or "TẮT", 3)
    if v then task.spawn(FruitPickupLoop) end
end)
AddButton("Fruits", "Auto Buy Random Fruit", function()
    ShowNotif("Fruits", "Đang mua Random Fruit...", 2)
    RemoteInvoke("BuyFruit", "Random")
    ShowNotif("Fruits", "Đã mua Random Fruit", 3)
end)
AddToggle("Fruits", "Store Fruits Auto", false, function(v)
    ENV["NGP_StoreFruit"] = v
    ShowNotif("Fruits", v and "Auto Store Fruit BẬT" or "TẮT", 3)
    if v then task.spawn(function() while ENV["NGP_StoreFruit"] do RemoteInvoke("StoreFruit") task.wait(5) end end) end
end)

-- STACK
AddSection("Stack", "Boss & Elite Farm")
for _, b in ipairs({
    {"Auto Elite Quest","EliteQuest"},{"Auto Dough King","Dough King"},
    {"Auto Darkbeard","Darkbeard"},{"Auto Rip_indra","Rip_indra"},
}) do
    AddButton("Stack", b[1], function()
        State.FarmTarget = b[2]
        State.FarmMode = "Farm Level"
        State.AutoFarm = true
        ShowNotif("Stack", "Bật "..b[1].." — Auto Farm ON", 3)
        task.spawn(FarmLevelLoop)
    end)
end

-- HOP FARM
AddSection("Hop Farm", "Hop Farm Controller")
AddButton("Hop Farm", "Hop to another public server", function()
    ShowNotif("Hop", "Đang hop server...", 3)
    pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
end)
AddToggle("Hop Farm", "Auto Hop Farm", false, function(v)
    State.AutoHopFarm = v
    ShowNotif("Hop", v and "Auto Hop Farm BẬT" or "TẮT", 3)
    if v then task.spawn(function()
        while State.AutoHopFarm do
            TeleportService:Teleport(game.PlaceId, lp)
            task.wait(60)
        end
    end) end
end)

-- QUEST
AddSection("Quest", "Skull Guitar")
AddButton("Quest", "Auto Skull Guitar Quest", function()
    ShowNotif("Quest", "Bắt đầu Skull Guitar...", 2)
    RemoteInvoke("StartQuest", "SkullGuitar")
    ShowNotif("Quest", "Đã start Skull Guitar", 3)
end)
AddButton("Quest", "Talk With Stone", function()
    RemoteInvoke("InteractNPC", "Stone")
    ShowNotif("Quest", "Đã interact với Stone", 3)
end)
AddSection("Quest", "Special Items")
for _, item in ipairs({"Rengoku Sword","Rengoku Key","Dark Blade V3","Midnight Blade","True Triple Katana","Swan Glasses","Don Swan"}) do
    AddButton("Quest", "Auto Farm "..item, function()
        State.FarmTarget = item
        State.FarmMode = "Farm Level"
        State.AutoFarm = true
        ShowNotif("Farm", "Đang farm "..item, 3)
        task.spawn(FarmLevelLoop)
    end)
end

-- SEA
AddSection("Sea", "Điều Khiển Thuyền")
AddDropdown("Sea", "Chọn Thuyền", {"Dinghy","Coffin Boat","Caravel","Galleon","Warship"}, "Dinghy", function(v)
    State.SelectedBoat = v
    ShowNotif("Sea", "Đã chọn thuyền: "..v, 3)
end)
AddToggle("Sea", "Auto Sail Boat", false, function(v)
    ENV["NGP_AutoSail"] = v
    ShowNotif("Sea", v and "Auto Sail BẬT" or "TẮT", 3)
end)
AddToggle("Sea", "Auto Escape Rough Sea", false, function(v)
    ENV["NGP_EscapeSea"] = v
    ShowNotif("Sea", v and "Auto Escape Rough Sea BẬT" or "TẮT", 3)
    if v then task.spawn(function() while ENV["NGP_EscapeSea"] do RemoteInvoke("EscapeRoughSea") task.wait(3) end end) end
end)
AddSection("Sea", "Farm Sự Kiện Biển")
AddToggle("Sea", "Auto Farm Sea Event", false, function(v)
    ENV["NGP_SeaFarm"] = v
    ShowNotif("Sea", v and "Auto Sea Event BẬT" or "TẮT", 3)
    if v then task.spawn(function()
        while ENV["NGP_SeaFarm"] do
            local mob = GetNearestMob(300)
            if mob then AttackMob(mob, function() return not ENV["NGP_SeaFarm"] end) end
            task.wait(1)
        end
    end) end
end)
AddToggle("Sea", "Xóa Sky Fog (Tăng FPS)", false, function(v)
    Workspace.FogEnd = v and 10000 or 1000
    Workspace.FogStart = v and 10000 or 0
    ShowNotif("Sea", v and "Đã xóa Sky Fog" or "Đã khôi phục Fog", 3)
end)

-- TELEPORT
AddSection("Teleport", "Sea 1")
for _, v in ipairs({
    {"Starter Island", Vector3.new(979.37,15.35,1757.48)},
    {"Marine Starter", Vector3.new(-2.90,9.46,1527.88)},
    {"Jungle", Vector3.new(-1239.75,10.28,3799.16)},
    {"Pirate Village", Vector3.new(-1402.94,10,755.55)},
    {"Desert", Vector3.new(930.95,8.4,-3243.11)},
    {"Frozen Village", Vector3.new(1176.68,8.4,3817.95)},
    {"Marine Fortress", Vector3.new(-3010.68,8.47,1430.74)},
    {"Skylands", Vector3.new(-4849.55,453.78,150.93)},
    {"Colosseum", Vector3.new(-1282.64,8.4,-1413.49)},
    {"Magma Village", Vector3.new(1038.49,20.18,4629.57)},
    {"Middle Town", Vector3.new(-537.47,8.4,-170.06)},
    {"Impel Down", Vector3.new(26.97,8.4,-1600)},
}) do
    AddButton("Teleport", "→ "..v[1], function()
        ShowNotif("Teleport", "Bay tới "..v[1].."...", 2)
        TweenMove(v[2], State.FlySpeed)
        ShowNotif("Teleport", "Đã đến "..v[1], 3)
    end)
end
AddSection("Teleport", "Sea 2")
for _, v in ipairs({
    {"Flower Hill", Vector3.new(-3433,8.09,-2924)},
    {"Punk Hazard", Vector3.new(5212.3,177.9,2769)},
    {"Cursed Ship", Vector3.new(5900,7.9,-4150)},
    {"Ice Castle", Vector3.new(-5842,100,-3745)},
    {"Zombie Island", Vector3.new(-5894,8,-3718)},
    {"Dark Arena", Vector3.new(-6660,7,-1600)},
    {"Cocoa Island", Vector3.new(-5074,15,-4855)},
    {"Thriller Bark", Vector3.new(-5918,8,-3718)},
    {"Dressrosa", Vector3.new(-10208,7,-1038)},
}) do
    AddButton("Teleport", "→ "..v[1], function()
        ShowNotif("Teleport", "Bay tới "..v[1].."...", 2)
        TweenMove(v[2], State.FlySpeed)
        ShowNotif("Teleport", "Đã đến "..v[1], 3)
    end)
end

-- RACE
AddSection("Race", "Nâng Cấp Tộc")
for _, r in ipairs({
    {"Auto Cyborg V1","Cyborg",1},{"Auto Ghoul V1","Ghoul",1},
    {"Auto Upgrade V2","Current",2},{"Auto Upgrade V3","Current",3},
}) do
    AddButton("Race", r[1], function()
        ShowNotif("Race", "Bắt đầu "..r[1], 2)
        RemoteInvoke("StartRaceUpgrade", r[2], r[3])
        ShowNotif("Race", r[1].." — đã gửi request", 3)
    end)
end

-- SHOP
AddSection("Shop", "Mua Vật Phẩm")
for _, item in ipairs({
    {"Mua Observation Haki","BuyHaki","Observation"},
    {"Mua Soru","BuyHaki","Soru"},
    {"Mua Ghoul Race","BuyRace","Ghoul"},
    {"Refund Stats","RefundStats",nil},
}) do
    local label, remote, arg = item[1], item[2], item[3]
    AddButton("Shop", label, function()
        ShowNotif("Shop", "Đang "..label.."...", 2)
        if arg then RemoteInvoke(remote, arg) else RemoteInvoke(remote) end
        ShowNotif("Shop", label.." — đã gửi request", 3)
    end)
end

-- SERVER
AddSection("Server", "Thông Tin Server")
AddLabel("Server", "Place ID: "..tostring(game.PlaceId))
AddLabel("Server", "Job ID: "..tostring(game.JobId))
AddButton("Server", "Copy Job ID", function()
    CopyClip(game.JobId)
    ShowNotif("Server", "Đã copy Job ID vào clipboard", 3)
end)
AddSection("Server", "Join Server")
AddInput("Server", "Nhập Job ID để Join...", function(v)
    if v and v ~= "" then
        ShowNotif("Server", "Đang join server "..string.sub(v,1,8).."...", 3)
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, v, lp) end)
    end
end)
AddButton("Server", "Hop Server (Rejoin)", function()
    ShowNotif("Server", "Đang rejoin server...", 3)
    TeleportService:Teleport(game.PlaceId, lp)
end)

-- PVP
local function GetPlayerNames()
    local out = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then table.insert(out, p.Name) end end
    table.sort(out)
    if #out == 0 then out = {"No other players"} end
    return out
end
AddSection("PVP", "Players")
AddDropdown("PVP", "Choose Players", GetPlayerNames(), "No other players", function(v)
    State.SelectedPlayer = v
    ShowNotif("PVP", "Đã chọn: "..v, 3)
end)
AddButton("PVP", "Refresh Players", function()
    local n = #Players:GetPlayers() - 1
    ShowNotif("PVP", "Có "..n.." người chơi khác trong server", 3)
end)
AddButton("PVP", "Teleport to Choose Players", function()
    local p = Players:FindFirstChild(State.SelectedPlayer)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        ShowNotif("PVP", "Bay tới "..p.Name.."...", 2)
        TweenMove(p.Character.HumanoidRootPart.Position + Vector3.new(0,4,0), State.FlySpeed)
        ShowNotif("PVP", "Đã tới "..p.Name, 3)
    else
        ShowNotif("PVP", "Không tìm thấy player", 3)
    end
end)
AddButton("PVP", "Spectate Choose Players", function()
    local p = Players:FindFirstChild(State.SelectedPlayer)
    if p and p.Character then
        local targetHum = p.Character:FindFirstChildOfClass("Humanoid")
        if targetHum then
            Workspace.CurrentCamera.CameraSubject = targetHum
            ShowNotif("PVP", "Đang spectate "..p.Name, 3)
        end
    else
        ShowNotif("PVP", "Không tìm thấy player", 3)
    end
end)
AddButton("PVP", "Stop Spectating", function()
    if hum then
        Workspace.CurrentCamera.CameraSubject = hum
        ShowNotif("PVP", "Đã dừng spectate", 2)
    end
end)
AddSection("PVP", "Combat Settings")
AddSlider("PVP", "Bán kính aim PvP", 20, 600, 150, " px", function(v) State.AimRadius = v end)
AddSlider("PVP", "Change Speed", 1, 100, 16, "", function(v) State.ChangeSpeed = v; if hum then hum.WalkSpeed = v end end)
AddSlider("PVP", "Jump Power", 10, 200, 50, "", function(v) State.JumpPower = v; if hum then hum.UseJumpPower = true; hum.JumpPower = v end end)
AddButton("PVP", "Restore Movement", function()
    if hum then hum.WalkSpeed = 16; hum.UseJumpPower = true; hum.JumpPower = 50 end
    ShowNotif("PVP", "Đã khôi phục movement mặc định", 3)
end)

-- SETTINGS
AddSection("Settings", "Bay / Fly")
AddToggle("Settings", "Bật Bay (WASD + Space/Ctrl)", false, function(v)
    if v then EnableFly() ShowNotif("Fly", "Bay BẬT", 3)
    else DisableFly() ShowNotif("Fly", "Bay TẮT", 3) end
end)
AddSlider("Settings", "Tốc Độ Bay", 20, 500, 120, " studs/s", function(v)
    State.FlySpeed = v
    if State.FlyEnabled and State.FlyBV then
        State.FlyBV.Velocity = State.FlyBV.Velocity.Unit * v
    end
end)

AddSection("Settings", "Noclip")
AddToggle("Settings", "Noclip (xuyên tường)", true, function(v)
    State.NoclipEnabled = v
    ShowNotif("Noclip", v and "Noclip BẬT" or "TẮT", 3)
end)

AddSection("Settings", "Cài Đặt Chung")
AddToggle("Settings", "Auto Destroy Lava", false, function(v)
    ENV["NGP_Lava"] = v
    ShowNotif("Settings", v and "Auto Destroy Lava BẬT" or "TẮT", 3)
    if v then task.spawn(function()
        while ENV["NGP_Lava"] do
            for _, p in ipairs(Workspace:GetDescendants()) do
                if p:IsA("BasePart") and (p.Name:lower():find("lava") or p.Name:lower():find("magma")) then
                    pcall(function() p:Destroy() end)
                end
            end
            task.wait(1)
        end
    end) end
end)
AddButton("Settings", "Redeem All Codes", function()
    ShowNotif("Codes", "Đang redeem tất cả code...", 2)
    local codes = {"Sub2Fer999","Sub2OfficialNoobie","Sub2Daigrock","Enyu_is_Pro",
        "Magicbus","Bignews","STARcodeMUSE","Sub2Gamer456","Sub2UncleKizaru",
        "TheGreatAce","JCWK","CHANDLER","fudd10_v2","StrawHatMaine","Axiore"}
    for _, code in ipairs(codes) do RemoteInvoke("UseCode", code) task.wait(0.3) end
    ShowNotif("Codes", "Đã redeem xong "..#codes.." code", 4)
end)
AddSection("Settings", "Chọn Team")
AddDropdown("Settings", "Chọn Team", {"Pirates","Marines","None"}, "None", function(v)
    RemoteInvoke("SetTeam", v)
    ShowNotif("Team", "Đã đổi team: "..v, 3)
end)

-- DISCORD
AddSection("Discord", "Webhook Notifications")
AddInput("Discord", "Webhook URL: https://discord.com/api/webhooks/...", function(v) State.DiscordWebhook = v end)
AddButton("Discord", "Test Webhook", function()
    if State.DiscordWebhook == "" then
        ShowNotif("Discord", "Chưa nhập webhook URL", 3)
    else
        ShowNotif("Discord", "Đang gửi test webhook...", 2)
        SendWebhook("[NGP Hub] Test từ "..lp.Name)
        ShowNotif("Discord", "Đã gửi test webhook", 3)
    end
end)
AddToggle("Discord", "Notify khi Level Up", false, function(v)
    ShowNotif("Discord", v and "Notify Level Up BẬT" or "TẮT", 3)
    if v then
        lp:GetAttributeChangedSignal("Level"):Connect(function()
            SendWebhook("[NGP Hub] "..lp.Name.." vừa lên level!")
        end)
    end
end)
AddToggle("Discord", "Notify khi Trái Rơi", false, function(v)
    ShowNotif("Discord", v and "Notify Fruit BẬT" or "TẮT", 3)
    if v then
        Workspace.DescendantAdded:Connect(function(obj)
            if obj.Name:find("Fruit") or obj.Name:find("Devil") then
                SendWebhook("[NGP Hub] Trái rơi: "..obj.Name.." | "..game.JobId)
            end
        end)
    end
end)

SelectTab("Farm")

-- ===================== BUBBLE (bottom-left, draggable) =====================
local Bubble = Frame("Bubble", UDim2.new(0,58,0,58), UDim2.new(0,24,1,-84), THEME.WHITE, ScreenGui)
Bubble.AnchorPoint = Vector2.new(0,1)
Corner(29, Bubble)
Stroke(2.5, THEME.BLACK, Bubble, 0)

local BubbleBG = Instance.new("ImageLabel")
BubbleBG.Size = UDim2.new(1,-4,1,-4)
BubbleBG.Position = UDim2.new(0,2,0,2)
BubbleBG.BackgroundTransparency = 1
BubbleBG.Image = BG_IMAGE_ID
BubbleBG.ScaleType = Enum.ScaleType.Crop
BubbleBG.ImageTransparency = imgOk and 0.55 or 1
BubbleBG.Parent = Bubble
Corner(27, BubbleBG)

local BubbleGlow = Frame("BGlow", UDim2.new(1,-4,1,-4), UDim2.new(0,2,0,2), THEME.NEON_PURPLE, Bubble)
BubbleGlow.BackgroundTransparency = 0.6
Corner(27, BubbleGlow)

local BubbleLabel = Label("NGP", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), THEME.TEXT_DARK, 13, Bubble)
BubbleLabel.TextXAlignment = Enum.TextXAlignment.Center
BubbleLabel.Font = Enum.Font.GothamBlack
BubbleLabel.ZIndex = 5

task.spawn(function()
    while Bubble.Parent do
        TweenService:Create(BubbleGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.35}):Play()
        task.wait(1.4)
        TweenService:Create(BubbleGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.75}):Play()
        task.wait(1.4)
    end
end)

local bDragging, bDragOffset, bDragStart = false, Vector2.new(), Vector2.new()
local bClickFired = false
local DRAG_THRESHOLD = 6

Bubble.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        bDragging = true bClickFired = false
        bDragStart = Vector2.new(inp.Position.X, inp.Position.Y)
        bDragOffset = Vector2.new(inp.Position.X - Bubble.AbsolutePosition.X, inp.Position.Y - Bubble.AbsolutePosition.Y)
    end
end)

local function OpenPanel()
    Panel.Visible = true
    -- Luôn center màn hình
    Panel.Size = UDim2.new(0, 0, 0, 0)
    Panel.Position = UDim2.new(0.5, -DEFAULT_W/2, 0.5, -DEFAULT_H/2)
    TweenService:Create(Panel, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, DEFAULT_W, 0, DEFAULT_H),
    }):Play()
end

local function ClosePanel()
    TweenService:Create(Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    }):Play()
    task.delay(0.22, function() Panel.Visible = false end)
end

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        if bDragging then
            local dist = (Vector2.new(inp.Position.X, inp.Position.Y) - bDragStart).Magnitude
            if dist < DRAG_THRESHOLD and not bClickFired then
                if Panel.Visible then ClosePanel() else OpenPanel() end
                bClickFired = true
            end
        end
        bDragging = false
    end
end)

UIS.InputChanged:Connect(function(inp)
    if bDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local dist = (Vector2.new(inp.Position.X, inp.Position.Y) - bDragStart).Magnitude
        if dist > DRAG_THRESHOLD then
            local vp = Workspace.CurrentCamera.ViewportSize
            local nx = math.clamp(inp.Position.X - bDragOffset.X, 0, vp.X - 58)
            local ny = math.clamp(inp.Position.Y - bDragOffset.Y, 0, vp.Y - 58)
            Bubble.Position = UDim2.new(0, nx, 0, ny)
            Bubble.AnchorPoint = Vector2.new(0,0)
        end
    end
end)

task.delay(2.2, function()
    ShowNotif("Nguyen Gia Phuc Hub", "Load thành công! Nhấn bubble NGP để mở menu", 5)
end)