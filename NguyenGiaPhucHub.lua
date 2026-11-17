-- ╔══════════════════════════════════════════════════════════════╗
-- ║         NGUYEN GIA PHUC HUB v4 — RAYFIELD UI               ║
-- ║   Rayfield | Blox Fruits | Universal                       ║
-- ║   Arceus X · Delta X · Fluxus · Hydrogen · Solara          ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ===================== LOAD RAYFIELD =====================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
    BringMob=false, BringMobRange=150,
    FlyEnabled=false, FlyBV=nil, FlyBG=nil, TweenSpeed=1,
    SkillDelay=0.3,
    AutoCollectBerry=false, AutoChest=false,
    ESPEnabled=false, ESPHighlights={},
    AutoStats=false, StatPoints={Melee=0,Sword=0,Gun=0,Fruit=0,Defense=0},
    AutoFishing=false, AutoSellFish=false,
    AutoTrickOrTreat=false, AutoPumpkinHunt=false, AutoGreatPumpkin=false,
    DiscordWebhook="",
    AutoHopFarm=false, AutoHopSecret=false,
    SecretQuestDone=0,
    WebhookUserId="", PingMode="None", FruitRarity="All",
    NotifyAccount=false, NotifyStoredFruit=false, NotifyPrehistoric=false,
    NotifyFrozen=false, NotifyMirage=false, NotifySpy=false,
    ServerJobInput="", ServerTimeStarted=0,
    SelectedFightingStyle="Black Leg", SelectedBoss="Darkbeard",
    IgnoreCakePrince=false, AcceptQuests=false,
    ChestHopLimit=45, MasteryHealthPercent=35,
    SkillHold={Z=250,X=250,C=250,V=250},
    SelectedMaterial="Scrap Metal", SelectedPlayer="",
    AimRadius=150, ChangeSpeed=1, JumpPower=50,
    SelectedBoat="Dinghy", BoatSpeed=50, SeaLevel="Normal",
    AutoOpenHopMenu=false, HopMenuOpen=false,
    SelectedDungeon="Normal", MinimumPlayers=1, AccountStartsDungeon=false,
    SelectedCard="Auto", AutoCollectCard=false,
    SelectedFruit="Auto", SelectedGun="Slingshot",
    SelectedSword="Katana", SelectedAbility="Skyjump",
    SelectedTeam="Pirates", BringMobMode="All",
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

local SECRET_QUESTS = {
    {name="Mysterious Expert",   pos=Vector3.new(-3610,8,2360)},
    {name="Mysterious Scientist",pos=Vector3.new(-2370,72,2820)},
    {name="Horned Man",          pos=Vector3.new(-2855,8,2165)},
    {name="Shanks Hint",         pos=Vector3.new(2074,10,-4221)},
}

-- ===================== UTILS =====================
local function SafeTP(pos)
    if char and hrp then hrp.CFrame = CFrame.new(pos) end
end

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

-- ===================== FLY =====================
local function EnableFly()
    if State.FlyEnabled then return end
    State.FlyEnabled=true
    if hrp:FindFirstChild("NGP_BV") then hrp.NGP_BV:Destroy() end
    if hrp:FindFirstChild("NGP_BG") then hrp.NGP_BG:Destroy() end
    local bv=Instance.new("BodyVelocity")
    bv.Name="NGP_BV";bv.Velocity=Vector3.zero
    bv.MaxForce=Vector3.new(1e5,1e5,1e5);bv.Parent=hrp
    State.FlyBV=bv
    local bg=Instance.new("BodyGyro")
    bg.Name="NGP_BG";bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
    bg.D=100;bg.Parent=hrp
    State.FlyBG=bg
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
    RunService:BindToRenderStep("NGPFly",Enum.RenderPriority.Camera.Value+1,function()
        if not State.FlyEnabled then RunService:UnbindFromRenderStep("NGPFly") return end
        local cam=Workspace.CurrentCamera
        local dir=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.new(0,1,0) end
        bv.Velocity=dir.Magnitude>0 and dir.Unit*60 or Vector3.zero
        bg.CFrame=cam.CFrame
    end)
end

local function DisableFly()
    State.FlyEnabled=false
    RunService:UnbindFromRenderStep("NGPFly")
    if State.FlyBV then State.FlyBV:Destroy() State.FlyBV=nil end
    if State.FlyBG then State.FlyBG:Destroy() State.FlyBG=nil end
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
end

-- ===================== BRING MOB =====================
local function BringMobLoop()
    while State.BringMob do
        if char and hrp then
            for _,mob in ipairs(GetAllMobsInRange(State.BringMobRange)) do
                if mob:FindFirstChild("HumanoidRootPart") then
                    local drop=hrp.Position-Vector3.new(0,State.FlyHeight-3,0)
                    mob.HumanoidRootPart.CFrame=CFrame.new(drop+Vector3.new(math.random(-4,4),0,math.random(-4,4)))
                end
            end
        end
        task.wait(0.4)
    end
end

-- ===================== SKILLS =====================
local function UseSkills()
    for _,k in ipairs({Enum.KeyCode.Z,Enum.KeyCode.X,Enum.KeyCode.C,Enum.KeyCode.V}) do
        PressKey(k,true); task.wait(State.SkillDelay)
        PressKey(k,false); task.wait(State.SkillDelay)
    end
end

local function AttackMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    local above=mob.HumanoidRootPart.Position+Vector3.new(0,State.FlyHeight,0)
    hrp.CFrame=CFrame.new(above)
    task.wait(0.1)
    if State.BringMob then
        for _,m in ipairs(GetAllMobsInRange(State.BringMobRange)) do
            if m:FindFirstChild("HumanoidRootPart") then
                local drop=hrp.Position-Vector3.new(0,State.FlyHeight-3,0)
                m.HumanoidRootPart.CFrame=CFrame.new(drop+Vector3.new(math.random(-4,4),0,math.random(-4,4)))
            end
        end
        task.wait(0.1)
    end
    if State.AutoSkill then UseSkills() end
    pcall(function()
        local tool=char:FindFirstChildOfClass("Tool")
        if tool then
            local ev=tool:FindFirstChild("Activated") or tool:FindFirstChild("MouseButton1Down")
            if ev then ev:Fire() end
        end
    end)
end

-- ===================== FARM LOOPS =====================
local function FarmLevelLoop()
    while State.AutoFarm and State.FarmMode=="Farm Level" do
        if not(char and hrp and hum and hum.Health>0) then task.wait(2) continue end
        local target=State.FarmTarget~="Auto" and MOB_TARGETS[State.FarmTarget]
        local mob
        if target then
            if(hrp.Position-target).Magnitude>200 then SafeTP(target) task.wait(0.5) end
            for _,obj in ipairs(Workspace:GetDescendants()) do
                if IsMob(obj) and obj.Name:lower():find(State.FarmTarget:lower()) then mob=obj break end
            end
        end
        if not mob then mob=GetNearestMob(500) end
        if mob then AttackMob(mob) end
        task.wait(0.1)
    end
end

local function FarmNearMobsLoop()
    while State.AutoFarm and State.FarmMode=="Farm Near Mobs" do
        if not(char and hrp and hum and hum.Health>0) then task.wait(2) continue end
        if State.BringMob then
            for _,m in ipairs(GetAllMobsInRange(State.BringMobRange)) do
                if m:FindFirstChild("HumanoidRootPart") then
                    m.HumanoidRootPart.CFrame=hrp.CFrame*CFrame.new(math.random(-5,5),-2,math.random(-5,5))
                end
            end
        end
        if State.AutoSkill then UseSkills() end
        local mob=GetNearestMob(State.BringMobRange+20)
        if mob then AttackMob(mob) end
        task.wait(0.2)
    end
end

local function FarmSecretLoop()
    local step=1
    while State.AutoFarm and State.FarmMode=="Farm Level Secret" do
        if not(char and hrp and hum and hum.Health>0) then task.wait(2) continue end
        local q=SECRET_QUESTS[step]
        if not q then
            step=1 State.SecretQuestDone+=1
            task.wait(3) continue
        end
        SafeTP(q.pos) task.wait(0.8)
        RemoteInvoke("StartQuest",q.name) task.wait(0.5)
        local killMob=GetNearestMob(300)
        if killMob then
            for _=1,20 do
                if not(State.AutoFarm and State.FarmMode=="Farm Level Secret") then break end
                AttackMob(killMob) task.wait(0.3)
                if not killMob.Parent or killMob:FindFirstChildOfClass("Humanoid").Health<=0 then
                    killMob=GetNearestMob(300) if not killMob then break end
                end
            end
        end
        RemoteInvoke("CompleteQuest",q.name) task.wait(0.5)
        step+=1 task.wait(1)
    end
end

local function StartFarmLoop()
    if State.FarmMode=="Farm Level" then task.spawn(FarmLevelLoop)
    elseif State.FarmMode=="Farm Near Mobs" then task.spawn(FarmNearMobsLoop)
    elseif State.FarmMode=="Farm Level Secret" then task.spawn(FarmSecretLoop)
    end
end

-- ===================== MISC LOOPS =====================
local function CollectBerryLoop()
    while State.AutoCollectBerry do
        for _,obj in ipairs(Workspace:GetDescendants()) do
            local n=obj.Name:lower()
            if n:find("berry") or n:find("beli") then
                local pos
                if obj:IsA("BasePart") then pos=obj.Position
                elseif obj:IsA("Model") then local h=obj:FindFirstChild("Handle") pos=h and h.Position end
                if pos then SafeTP(pos) task.wait(0.1) end
            end
        end
        task.wait(1.5)
    end
end

local function CollectChestLoop()
    while State.AutoChest do
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("chest") then
                local p=obj:IsA("BasePart") and obj or(obj:IsA("Model") and obj:FindFirstChildOfClass("BasePart"))
                if p then SafeTP(p.Position) task.wait(0.3) end
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
                State.ESPHighlights[obj]=nil
            end
        end
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if IsMob(obj) and not State.ESPHighlights[obj] then
                local ok,hl=pcall(function()
                    local h=Instance.new("Highlight")
                    h.FillTransparency=0.5
                    h.OutlineColor=Color3.fromRGB(255,50,50)
                    h.FillColor=Color3.fromRGB(255,100,100)
                    h.Adornee=obj h.Parent=obj return h
                end)
                if ok then State.ESPHighlights[obj]=hl end
            end
        end
        task.wait(1)
    end
    for obj in pairs(State.ESPHighlights) do
        pcall(function() State.ESPHighlights[obj]:Destroy() end)
        State.ESPHighlights[obj]=nil
    end
end

local function AutoStatsLoop()
    local statMap={Melee="Melee",Sword="Sword",Gun="Gun",Fruit="BloxFruit",Defense="Defense"}
    while State.AutoStats do
        for k,v in pairs(statMap) do
            if(State.StatPoints[k] or 0)>0 then RemoteInvoke("AddStats",v,State.StatPoints[k]) end
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
        local mob=GetNearestMob(300)
        if mob then AttackMob(mob) end
        task.wait(2)
    end
end

local function HWPumpkinLoop()
    while State.AutoPumpkinHunt do
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("pumpkin") then
                local p=obj:IsA("BasePart") and obj or(obj:IsA("Model") and obj:FindFirstChildOfClass("BasePart"))
                if p then
                    SafeTP(p.Position+Vector3.new(0,5,0))
                    if State.AutoSkill then UseSkills() end
                    task.wait(0.5)
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
                for _=1,30 do
                    if not State.AutoGreatPumpkin then break end
                    AttackMob(obj) task.wait(0.3)
                    if not obj.Parent or obj:FindFirstChildOfClass("Humanoid").Health<=0 then break end
                end
                break
            end
        end
        task.wait(5)
    end
end

local function SendWebhook(msg)
    if State.DiscordWebhook=="" then return end
    local prefix=""
    if State.PingMode=="Everyone" then prefix="@everyone "
    elseif State.PingMode=="Here" then prefix="@here "
    elseif State.PingMode=="User" and State.WebhookUserId~="" then prefix="<@"..State.WebhookUserId.."> " end
    pcall(function()
        HttpService:PostAsync(State.DiscordWebhook,
            HttpService:JSONEncode({
                content=prefix..msg,
                allowed_mentions={parse=State.PingMode=="Everyone" and {"everyone"} or (State.PingMode=="Here" and {"everyone"} or {}), users=(State.PingMode=="User" and State.WebhookUserId~="" and {State.WebhookUserId} or {})}
            }),
            Enum.HttpContentType.ApplicationJson)
    end)
end

-- ============================================================
--              RAYFIELD UI
-- ============================================================

local Window = Rayfield:CreateWindow({
    Name = "Nguyen Gia Phuc Hub v4",
    LoadingTitle = "NGP Hub đang tải...",
    LoadingSubtitle = "by Nguyen Gia Phuc",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "NGPHub",
        FileName = "NGP_Config"
    },
    KeySystem = false,
})

-- ==================== FARM TAB ====================
local FarmTab = Window:CreateTab("Farm", 4483362458)

FarmTab:CreateSection("Chế Độ Farm")
FarmTab:CreateDropdown({
    Name = "Farm Mode",
    Options = {"Farm Level","Farm Near Mobs","Farm Level Secret"},
    CurrentOption = "Farm Level",
    Flag = "FarmMode",
    Callback = function(v) State.FarmMode = v end,
})

local targetList = {"Auto"}
for k in pairs(MOB_TARGETS) do if k~="Auto" then table.insert(targetList,k) end end
table.sort(targetList)
FarmTab:CreateDropdown({
    Name = "Mob Target",
    Options = targetList,
    CurrentOption = "Auto",
    Flag = "FarmTarget",
    Callback = function(v) State.FarmTarget = v end,
})

FarmTab:CreateSection("Điều Khiển")
FarmTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(v)
        State.AutoFarm = v
        if v then StartFarmLoop() end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Skill khi Farm",
    CurrentValue = false,
    Flag = "AutoSkill",
    Callback = function(v) State.AutoSkill = v end,
})

FarmTab:CreateSlider({
    Name = "Chiều Cao Bay",
    Range = {0, 200},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 50,
    Flag = "FlyHeight",
    Callback = function(v) State.FlyHeight = v end,
})

FarmTab:CreateSection("Thu Thập")
FarmTab:CreateToggle({
    Name = "Auto Collect Berry",
    CurrentValue = false,
    Flag = "AutoBerry",
    Callback = function(v)
        State.AutoCollectBerry = v
        if v then task.spawn(CollectBerryLoop) end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Collect Chest",
    CurrentValue = false,
    Flag = "AutoChest",
    Callback = function(v)
        State.AutoChest = v
        if v then task.spawn(CollectChestLoop) end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Hop Find Berry",
    CurrentValue = false,
    Flag = "HopBerry",
    Callback = function(v)
        ENV["NGP_HopBerry"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_HopBerry"] do
                    RemoteInvoke("HopFindBerry")
                    task.wait(30)
                end
            end)
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Accept Quests (Bone/Cake/Tyrant)",
    CurrentValue = false,
    Flag = "AcceptQuests",
    Callback = function(v)
        ENV["NGP_Quest"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_Quest"] do RemoteInvoke("StartQuest","Current") task.wait(5) end
            end)
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Complete Bartilo Quest",
    CurrentValue = false,
    Flag = "Bartilo",
    Callback = function(v)
        ENV["NGP_Bartilo"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_Bartilo"] do
                    RemoteInvoke("StartQuest","Bartilo") task.wait(2)
                    RemoteInvoke("CompleteQuest","Bartilo") task.wait(3)
                end
            end)
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Training Dummy",
    CurrentValue = false,
    Flag = "Dummy",
    Callback = function(v)
        ENV["NGP_Dummy"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_Dummy"] do
                    local d=Workspace:FindFirstChild("TrainingDummy",true)
                    if d and d:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame=CFrame.new(d.HumanoidRootPart.Position+Vector3.new(0,3,0))
                        if State.AutoSkill then UseSkills() end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Ignore Cake Prince",
    CurrentValue = false,
    Flag = "IgnoreCake",
    Callback = function(v) ENV["NGP_IgnoreCake"] = v end,
})

FarmTab:CreateSection("Auto Level 3000 (Secret Quest)")
FarmTab:CreateParagraph({Title="Yêu cầu:", Content="Level 2800+ tại Sea 1\nThứ tự NPC: Expert → Scientist → Horned Man → Shanks"})

FarmTab:CreateButton({
    Name = "Xem Tiến Độ Secret Quest",
    Callback = function()
        Rayfield:Notify({Title="Secret Quest", Content="Đã hoàn thành: "..State.SecretQuestDone.." lượt", Duration=4})
    end,
})

FarmTab:CreateSection("Boss Farm")
local bossList = {"Darkbeard","Rip_indra","Dough King","Cake Prince","Terrorshark","Elite Pirate","Stone","Island Empress","Kilo Admiral","Captain Elephant"}
FarmTab:CreateDropdown({
    Name = "Choose Boss",
    Options = bossList,
    CurrentOption = "Darkbeard",
    Flag = "SelectedBoss",
    Callback = function(v) State.SelectedBoss = v end,
})

FarmTab:CreateButton({
    Name = "Boss Farm (selected)",
    Callback = function()
        State.FarmTarget = State.SelectedBoss
        State.FarmMode = "Farm Level"
        State.AutoFarm = true
        StartFarmLoop()
    end,
})

FarmTab:CreateSection("Materials / Mastery")
local materials = {"Scrap Metal","Leather","Demonic Wisp","Vampire Fang","Mystic Droplet","Dragon Scale","Conjured Cocoa","Mini Tusk","Fish Tail","Gunpowder"}
FarmTab:CreateDropdown({
    Name = "Choose Material",
    Options = materials,
    CurrentOption = "Scrap Metal",
    Flag = "SelectedMaterial",
    Callback = function(v) State.SelectedMaterial = v end,
})

FarmTab:CreateToggle({
    Name = "Auto Materials",
    CurrentValue = false,
    Flag = "AutoMaterials",
    Callback = function(v) State.AutoMaterials = v end,
})

FarmTab:CreateSlider({
    Name = "Farm Around Range",
    Range = {50, 2000},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 500,
    Flag = "FarmAroundRange",
    Callback = function(v) State.FarmAroundRange = v end,
})

FarmTab:CreateSlider({
    Name = "Health Percent",
    Range = {5, 95},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 35,
    Flag = "HealthPercent",
    Callback = function(v) State.MasteryHealthPercent = v end,
})

FarmTab:CreateToggle({
    Name = "Auto Mastery Fruit",
    CurrentValue = false,
    Flag = "MasteryFruit",
    Callback = function(v) State.AutoMasteryFruit = v end,
})

FarmTab:CreateToggle({
    Name = "Auto Mastery Gun",
    CurrentValue = false,
    Flag = "MasteryGun",
    Callback = function(v) State.AutoMasteryGun = v end,
})

FarmTab:CreateToggle({
    Name = "Auto Mastery All Sword",
    CurrentValue = false,
    Flag = "MasterySword",
    Callback = function(v) State.AutoMasterySword = v end,
})

-- ==================== BRING MOB TAB ====================
local BringTab = Window:CreateTab("Bring Mob", 4483362458)

BringTab:CreateSection("Chỉ Kéo Mob/Quái (Đã lọc NPC)")
BringTab:CreateParagraph({Title="Bộ lọc tự động:", Content="Vendor, quest giver, player đều bị loại bỏ."})

BringTab:CreateToggle({
    Name = "Bật Bring Mob",
    CurrentValue = false,
    Flag = "BringMob",
    Callback = function(v)
        State.BringMob = v
        if v then task.spawn(BringMobLoop) end
    end,
})

BringTab:CreateSlider({
    Name = "Phạm Vi Kéo Mob",
    Range = {20, 500},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 150,
    Flag = "BringMobRange",
    Callback = function(v) State.BringMobRange = v end,
})

BringTab:CreateDropdown({
    Name = "Bring Mode",
    Options = {"Tất cả mob trong tầm","Chỉ mob đang farm","Boss Only"},
    CurrentOption = "Tất cả mob trong tầm",
    Flag = "BringMobMode",
    Callback = function(v) State.BringMobMode = v end,
})

-- ==================== BAY TAB ====================
local FlyTab = Window:CreateTab("Bay", 4483362458)

FlyTab:CreateSection("Điều Khiển Bay")
FlyTab:CreateToggle({
    Name = "Bật Bay (WASD + Space/Ctrl)",
    CurrentValue = false,
    Flag = "FlyEnabled",
    Callback = function(v)
        if v then EnableFly() else DisableFly() end
    end,
})

FlyTab:CreateSlider({
    Name = "Tốc Độ Bay",
    Range = {1, 20},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "FlySpeed",
    Callback = function(v) State.TweenSpeed = v end,
})

-- ==================== SKILL TAB ====================
local SkillTab = Window:CreateTab("Skill", 4483362458)

SkillTab:CreateSection("Cấu Hình Kỹ Năng")
SkillTab:CreateSlider({
    Name = "Skill Delay",
    Range = {0, 20},
    Increment = 1,
    Suffix = " ms",
    CurrentValue = 3,
    Flag = "SkillDelay",
    Callback = function(v) State.SkillDelay = v/10 end,
})

for _, info in ipairs({{"Z",Enum.KeyCode.Z},{"X",Enum.KeyCode.X},{"C",Enum.KeyCode.C},{"V",Enum.KeyCode.V}}) do
    local name, kc = info[1], info[2]
    local fk = "NGP_SK"..name
    SkillTab:CreateToggle({
        Name = "Spam Skill "..name,
        CurrentValue = false,
        Flag = "SpamSkill"..name,
        Callback = function(v)
            ENV[fk] = v
            if v then
                task.spawn(function()
                    while ENV[fk] do
                        PressKey(kc,true) task.wait(State.SkillDelay)
                        PressKey(kc,false) task.wait(State.SkillDelay)
                    end
                end)
            end
        end,
    })
end

SkillTab:CreateSection("Hold Skill Duration (ms)")
for _, key in ipairs({"Z","X","C","V"}) do
    SkillTab:CreateSlider({
        Name = "Hold Skill "..key,
        Range = {50, 2000},
        Increment = 10,
        Suffix = " ms",
        CurrentValue = 250,
        Flag = "Hold"..key,
        Callback = function(v) State.SkillHold[key] = v end,
    })
end

-- ==================== HALLOWEEN TAB ====================
local HalloTab = Window:CreateTab("Halloween", 4483362458)

HalloTab:CreateSection("🎃 Trick or Treat")
HalloTab:CreateToggle({
    Name = "Auto Trick or Treat",
    CurrentValue = false,
    Flag = "TrickOrTreat",
    Callback = function(v)
        State.AutoTrickOrTreat = v
        if v then task.spawn(HWTrickLoop) end
    end,
})

HalloTab:CreateButton({
    Name = "Oni Celestial Choice",
    Callback = function()
        RemoteInvoke("HalloweenEvent","CelestialChoice","Oni")
        Rayfield:Notify({Title="Halloween", Content="Đã chọn Celestial Oni", Duration=3})
    end,
})

HalloTab:CreateSection("🎃 Pumpkin Hunt")
HalloTab:CreateToggle({
    Name = "Auto Pumpkin Hunt",
    CurrentValue = false,
    Flag = "PumpkinHunt",
    Callback = function(v)
        State.AutoPumpkinHunt = v
        if v then task.spawn(HWPumpkinLoop) end
    end,
})

HalloTab:CreateButton({
    Name = "Hop Server for Cursed Pumpkin Seed",
    Callback = function()
        TeleportService:Teleport(game.PlaceId,lp)
    end,
})

HalloTab:CreateSection("🎃 Great Pumpkin")
HalloTab:CreateToggle({
    Name = "Auto Farm Great Pumpkin",
    CurrentValue = false,
    Flag = "GreatPumpkin",
    Callback = function(v)
        State.AutoGreatPumpkin = v
        if v then task.spawn(HWGreatPumpkinLoop) end
    end,
})

HalloTab:CreateButton({
    Name = "Summon Great Pumpkin",
    Callback = function()
        RemoteInvoke("HalloweenEvent","SummonGreatPumpkin")
        Rayfield:Notify({Title="Halloween", Content="Đã summon Great Pumpkin", Duration=3})
    end,
})

HalloTab:CreateSection("🎃 Auto Level 3000")
HalloTab:CreateToggle({
    Name = "Auto Secret Hint (Hop)",
    CurrentValue = false,
    Flag = "AutoHopSecret",
    Callback = function(v)
        State.AutoHopSecret = v
        if v then
            task.spawn(function()
                while State.AutoHopSecret do
                    RemoteInvoke("HopSecretHint")
                    task.wait(30)
                end
            end)
        end
    end,
})

-- ==================== FISHING TAB ====================
local FishTab = Window:CreateTab("Fishing", 4483362458)

FishTab:CreateSection("Auto Fishing")
FishTab:CreateToggle({
    Name = "Auto Fishing Quest",
    CurrentValue = false,
    Flag = "AutoFishing",
    Callback = function(v)
        State.AutoFishing = v
        if v then task.spawn(FishingLoop) end
    end,
})

FishTab:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Flag = "AutoSellFish",
    Callback = function(v) State.AutoSellFish = v end,
})

FishTab:CreateButton({
    Name = "Teleport đến Fishing Spot",
    Callback = function()
        SafeTP(Vector3.new(1746,11,1297))
        Rayfield:Notify({Title="Teleport", Content="Đã đến Fishing Spot", Duration=3})
    end,
})

FishTab:CreateButton({
    Name = "Teleport đến Sharkman Master",
    Callback = function()
        SafeTP(Vector3.new(-3215,8,2800))
        Rayfield:Notify({Title="Teleport", Content="Đã đến Sharkman Master", Duration=3})
    end,
})

-- ==================== ESP TAB ====================
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateSection("ESP Mob / Enemy")
ESPTab:CreateToggle({
    Name = "Bật ESP Mob",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(v)
        State.ESPEnabled = v
        if v then task.spawn(ESPLoop) end
    end,
})

ESPTab:CreateSection("World ESP")
for _, name in ipairs({"ESP Chests","ESP Fruits","ESP Island Location","ESP Flower","ESP Legendary Sword","ESP Aura Colour Dealers"}) do
    ESPTab:CreateToggle({
        Name = name,
        CurrentValue = false,
        Flag = name:gsub("[^%w]",""),
        Callback = function(v)
            State[name:gsub("[^%w]","")] = v
        end,
    })
end

-- ==================== STATS TAB ====================
local StatsTab = Window:CreateTab("Stats", 4483362458)

StatsTab:CreateSection("Phân Phối Chỉ Số")
for _, s in ipairs({"Melee","Sword","Gun","Fruit","Defense"}) do
    StatsTab:CreateInput({
        Name = "Điểm "..s,
        PlaceholderText = "Nhập số điểm...",
        RemoveTextAfterFocusLost = false,
        Flag = "Stat"..s,
        Callback = function(v) State.StatPoints[s] = tonumber(v) or 0 end,
    })
end

StatsTab:CreateToggle({
    Name = "Auto Phân Phối Stats",
    CurrentValue = false,
    Flag = "AutoStats",
    Callback = function(v)
        State.AutoStats = v
        if v then task.spawn(AutoStatsLoop) end
    end,
})

StatsTab:CreateSection("Auto Stats Buttons")
for _, s in ipairs({"Melee","Sword","Gun","Fruit","Defense"}) do
    StatsTab:CreateButton({
        Name = "Auto Max "..s,
        Callback = function()
            RemoteInvoke("AddStats",s=="Fruit" and "BloxFruit" or s,99999)
            Rayfield:Notify({Title="Stats", Content="Max "..s.." done", Duration=3})
        end,
    })
end

-- ==================== FRUITS TAB ====================
local FruitTab = Window:CreateTab("Fruits", 4483362458)

FruitTab:CreateSection("Trái Ác Quỷ")
FruitTab:CreateToggle({
    Name = "Auto Nhặt Trái Rơi",
    CurrentValue = false,
    Flag = "AutoFruit",
    Callback = function(v)
        ENV["NGP_Fruits"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_Fruits"] do
                    for _,obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name:find("Fruit") or obj.Name:find("Devil") then
                            local pos
                            if obj:IsA("BasePart") then pos=obj.Position
                            elseif obj:IsA("Model") then
                                local ok,cf=pcall(function() return obj:GetModelCFrame().Position end)
                                if ok then pos=cf end
                            end
                            if pos then SafeTP(pos) task.wait(0.5) end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

FruitTab:CreateButton({
    Name = "Auto Buy Random Fruit",
    Callback = function()
        RemoteInvoke("BuyFruit","Random")
        Rayfield:Notify({Title="Fruits", Content="Đã mua Random Fruit", Duration=3})
    end,
})

FruitTab:CreateToggle({
    Name = "Store Fruits Auto",
    CurrentValue = false,
    Flag = "StoreFruit",
    Callback = function(v)
        ENV["NGP_StoreFruit"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_StoreFruit"] do RemoteInvoke("StoreFruit") task.wait(5) end
            end)
        end
    end,
})

FruitTab:CreateSection("Raid / Dungeon")
FruitTab:CreateDropdown({
    Name = "Chọn Độ Khó",
    Options = {"Normal","Hard","Extreme"},
    CurrentOption = "Normal",
    Flag = "DungeonDiff",
    Callback = function(v) State.SelectedDungeon = v end,
})

FruitTab:CreateSlider({
    Name = "Minimum Players",
    Range = {1, 12},
    Increment = 1,
    CurrentValue = 1,
    Flag = "MinPlayers",
    Callback = function(v) State.MinimumPlayers = v end,
})

FruitTab:CreateToggle({
    Name = "Auto Join Dungeon",
    CurrentValue = false,
    Flag = "JoinDungeon",
    Callback = function(v)
        ENV["NGP_JoinDungeon"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_JoinDungeon"] do RemoteInvoke("JoinRaid") task.wait(5) end
            end)
        end
    end,
})

FruitTab:CreateToggle({
    Name = "Auto Raid Farm Boss",
    CurrentValue = false,
    Flag = "RaidFarm",
    Callback = function(v)
        ENV["NGP_RaidFarm"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_RaidFarm"] do
                    local mob=GetNearestMob(500)
                    if mob then AttackMob(mob) end
                    task.wait(1)
                end
            end)
        end
    end,
})

FruitTab:CreateToggle({
    Name = "Auto Nhặt Thẻ (Card)",
    CurrentValue = false,
    Flag = "Card",
    Callback = function(v)
        ENV["NGP_Card"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_Card"] do
                    for _,obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name:lower():find("card") and obj:IsA("BasePart") then
                            SafeTP(obj.Position) task.wait(0.3)
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

-- ==================== STACK TAB ====================
local StackTab = Window:CreateTab("Stack", 4483362458)

StackTab:CreateSection("Boss & Elite Farm")
for _, b in ipairs({
    {"Auto Elite Quest","EliteQuest"},{"Auto Dough King","Dough King"},
    {"Auto Darkbeard","Darkbeard"},{"Auto Rip_indra","Rip_indra"},
    {"Auto Factory Raid","FactoryRaid"},
}) do
    StackTab:CreateButton({
        Name = b[1],
        Callback = function()
            State.FarmTarget = b[2] State.FarmMode = "Farm Level" State.AutoFarm = true
            task.spawn(FarmLevelLoop)
            Rayfield:Notify({Title="Stack Farm", Content=b[1].." đang chạy", Duration=3})
        end,
    })
end

StackTab:CreateButton({
    Name = "Auto Craft Shark Anchor",
    Callback = function()
        RemoteInvoke("CraftItem","SharkAnchor")
        Rayfield:Notify({Title="Craft", Content="Crafting Shark Anchor", Duration=3})
    end,
})

StackTab:CreateSection("Quest Farming")
StackTab:CreateButton({
    Name = "Auto Travel Dressrosa (Level 700)",
    Callback = function()
        local data = lp:FindFirstChild("Data")
        local level = data and data:FindFirstChild("Level")
        if level and level.Value >= 700 then RemoteInvoke("TravelDressrosa")
        else Rayfield:Notify({Title="Stack", Content="Chưa đạt Level 700", Duration=3}) end
    end,
})

StackTab:CreateButton({
    Name = "Auto Zou Quest (Level 1500)",
    Callback = function()
        local data = lp:FindFirstChild("Data")
        local level = data and data:FindFirstChild("Level")
        if level and level.Value >= 1500 then RemoteInvoke("TravelZou")
        else Rayfield:Notify({Title="Stack", Content="Chưa đạt Level 1500", Duration=3}) end
    end,
})

-- ==================== HOP FARM TAB ====================
local HopTab = Window:CreateTab("Hop Farm", 4483362458)

HopTab:CreateSection("Hop Farm Controller")
HopTab:CreateToggle({
    Name = "Auto Open Menu Hop Farm",
    CurrentValue = false,
    Flag = "OpenHopMenu",
    Callback = function(v)
        State.AutoOpenHopMenu = v
        if v then Rayfield:Notify({Title="Hop Farm", Content="Auto-open preference saved.", Duration=3}) end
    end,
})

HopTab:CreateButton({
    Name = "Open Menu Hop Farm",
    Callback = function()
        State.HopMenuOpen = true
        Rayfield:Notify({Title="Hop Farm", Content="Hop Farm menu is open.", Duration=3})
    end,
})

HopTab:CreateButton({
    Name = "Hop to another public server",
    Callback = function()
        pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
    end,
})

HopTab:CreateSection("Auto Hop Farm")
HopTab:CreateToggle({
    Name = "Auto Hop Farm (Chuyển Server)",
    CurrentValue = false,
    Flag = "AutoHopFarm",
    Callback = function(v)
        State.AutoHopFarm = v
        if v then
            task.spawn(function()
                while State.AutoHopFarm do
                    TeleportService:Teleport(game.PlaceId, lp)
                    task.wait(60)
                end
            end)
        end
    end,
})

-- ==================== QUEST TAB ====================
local QuestTab = Window:CreateTab("Quest", 4483362458)

QuestTab:CreateSection("Skull Guitar")
QuestTab:CreateButton({
    Name = "Auto Skull Guitar Quest",
    Callback = function()
        RemoteInvoke("StartQuest","SkullGuitar")
        Rayfield:Notify({Title="Quest", Content="Skull Guitar started", Duration=3})
    end,
})

QuestTab:CreateButton({
    Name = "Auto Farm Material Skull Guitar",
    Callback = function()
        State.FarmTarget = "SkullGuitarMat" State.FarmMode = "Farm Level" State.AutoFarm = true
        task.spawn(FarmLevelLoop)
        Rayfield:Notify({Title="Farm", Content="Farming Skull Guitar materials", Duration=3})
    end,
})

QuestTab:CreateButton({
    Name = "Talk With Stone",
    Callback = function()
        RemoteInvoke("InteractNPC","Stone")
        Rayfield:Notify({Title="Quest", Content="Interacted with Stone", Duration=3})
    end,
})

QuestTab:CreateSection("Special Items")
for _, item in ipairs({"Rengoku Sword","Rengoku Key","Dark Blade V3","Midnight Blade","True Triple Katana","Swan Glasses","Don Swan"}) do
    QuestTab:CreateButton({
        Name = "Auto Farm "..item,
        Callback = function()
            State.FarmTarget = item State.FarmMode = "Farm Level" State.AutoFarm = true
            task.spawn(FarmLevelLoop)
            Rayfield:Notify({Title="Farm", Content="Đang farm "..item, Duration=3})
        end,
    })
end

-- ==================== LEVEL 3000 TAB ====================
local L3kTab = Window:CreateTab("Level 3000", 4483362458)

L3kTab:CreateSection("Secret Quest Seal")
L3kTab:CreateParagraph({Title="Secret Quest Status:", Content="Local counter: "..tostring(State.SecretQuestDone).."/39"})

L3kTab:CreateToggle({
    Name = "Auto Secret Quest",
    CurrentValue = false,
    Flag = "AutoSecretQuest",
    Callback = function(v)
        State.AutoSecretQuest = v
        if v then
            State.FarmMode = "Farm Level Secret"
            State.AutoFarm = true
            StartFarmLoop()
        end
    end,
})

L3kTab:CreateToggle({
    Name = "Auto Hop Secret Hint",
    CurrentValue = false,
    Flag = "AutoHopSecretHint",
    Callback = function(v)
        State.AutoHopSecret = v
        if v then
            task.spawn(function()
                while State.AutoHopSecret do
                    local ok = pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
                    if not ok then task.wait(10) end
                    task.wait(30)
                end
            end)
        end
    end,
})

L3kTab:CreateButton({
    Name = "Refresh Secret Quest Status",
    Callback = function()
        Rayfield:Notify({Title="Secret Quest", Content="Local progress: "..tostring(State.SecretQuestDone).."/39", Duration=4})
    end,
})

-- ==================== SEA TAB ====================
local SeaTab = Window:CreateTab("Sea", 4483362458)

SeaTab:CreateSection("Điều Khiển Thuyền")
SeaTab:CreateDropdown({
    Name = "Chọn Thuyền",
    Options = {"Dinghy","Coffin Boat","Caravel","Galleon","Warship"},
    CurrentOption = "Dinghy",
    Flag = "SelectedBoat",
    Callback = function(v) State.SelectedBoat = v end,
})

SeaTab:CreateSlider({
    Name = "Tốc Độ Thuyền",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 50,
    Flag = "BoatSpeed",
    Callback = function(v) ENV["NGP_BoatSpeed"] = v end,
})

SeaTab:CreateToggle({
    Name = "Auto Sail Boat",
    CurrentValue = false,
    Flag = "AutoSail",
    Callback = function(v) ENV["NGP_AutoSail"] = v end,
})

SeaTab:CreateToggle({
    Name = "Auto Escape Rough Sea",
    CurrentValue = false,
    Flag = "EscapeSea",
    Callback = function(v)
        ENV["NGP_EscapeSea"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_EscapeSea"] do RemoteInvoke("EscapeRoughSea") task.wait(3) end
            end)
        end
    end,
})

SeaTab:CreateSection("Farm Sự Kiện Biển")
SeaTab:CreateToggle({
    Name = "Auto Farm Sea Event",
    CurrentValue = false,
    Flag = "SeaFarm",
    Callback = function(v)
        ENV["NGP_SeaFarm"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_SeaFarm"] do
                    local mob = GetNearestMob(300)
                    if mob then AttackMob(mob) end
                    task.wait(1)
                end
            end)
        end
    end,
})

SeaTab:CreateToggle({
    Name = "Farm M1 Fruit Only",
    CurrentValue = false,
    Flag = "FruitOnly",
    Callback = function(v) ENV["NGP_FruitOnly"] = v end,
})

SeaTab:CreateToggle({
    Name = "Farm Use Gun Only",
    CurrentValue = false,
    Flag = "GunOnly",
    Callback = function(v) ENV["NGP_GunOnly"] = v end,
})

SeaTab:CreateToggle({
    Name = "Xóa Sky Fog (Tăng FPS)",
    CurrentValue = false,
    Flag = "SkyFog",
    Callback = function(v)
        Workspace.FogEnd = v and 10000 or 1000
        Workspace.FogStart = v and 10000 or 0
    end,
})

-- ==================== TELEPORT TAB ====================
local TPTab = Window:CreateTab("Teleport", 4483362458)

TPTab:CreateSection("Sea 1")
for _, v in ipairs({
    {"Starter Island",Vector3.new(979.37,15.35,1757.48)},
    {"Marine Starter",Vector3.new(-2.90,9.46,1527.88)},
    {"Jungle",Vector3.new(-1239.75,10.28,3799.16)},
    {"Pirate Village",Vector3.new(-1402.94,10,755.55)},
    {"Desert",Vector3.new(930.95,8.4,-3243.11)},
    {"Frozen Village",Vector3.new(1176.68,8.4,3817.95)},
    {"Marine Fortress",Vector3.new(-3010.68,8.47,1430.74)},
    {"Skylands",Vector3.new(-4849.55,453.78,150.93)},
    {"Colosseum",Vector3.new(-1282.64,8.4,-1413.49)},
    {"Magma Village",Vector3.new(1038.49,20.18,4629.57)},
    {"Middle Town",Vector3.new(-537.47,8.4,-170.06)},
    {"Impel Down",Vector3.new(26.97,8.4,-1600)},
}) do
    TPTab:CreateButton({
        Name = "→ "..v[1],
        Callback = function()
            SafeTP(v[2]) Rayfield:Notify({Title="Teleport", Content="Đã đến "..v[1], Duration=3})
        end,
    })
end

TPTab:CreateSection("Sea 2")
for _, v in ipairs({
    {"Flower Hill",Vector3.new(-3433,8.09,-2924)},
    {"Punk Hazard",Vector3.new(5212.3,177.9,2769)},
    {"Cursed Ship",Vector3.new(5900,7.9,-4150)},
    {"Ice Castle",Vector3.new(-5842,100,-3745)},
    {"Zombie Island",Vector3.new(-5894,8,-3718)},
    {"Dark Arena",Vector3.new(-6660,7,-1600)},
    {"Cocoa Island",Vector3.new(-5074,15,-4855)},
    {"Thriller Bark",Vector3.new(-5918,8,-3718)},
    {"Dressrosa",Vector3.new(-10208,7,-1038)},
}) do
    TPTab:CreateButton({
        Name = "→ "..v[1],
        Callback = function()
            SafeTP(v[2]) Rayfield:Notify({Title="Teleport", Content="Đã đến "..v[1], Duration=3})
        end,
    })
end

TPTab:CreateSection("Travel — Worlds")
TPTab:CreateButton({ Name = "Travel East Blue (World 1)", Callback = function() RemoteInvoke("TravelMain") end })
TPTab:CreateButton({ Name = "Travel Dressrosa (World 2)", Callback = function() RemoteInvoke("TravelDressrosa") end })
TPTab:CreateButton({ Name = "Travel Zou (World 3)", Callback = function() RemoteInvoke("TravelZou") end })

-- ==================== RACE TAB ====================
local RaceTab = Window:CreateTab("Race", 4483362458)

RaceTab:CreateSection("Nâng Cấp Tộc")
for _, r in ipairs({
    {"Auto Cyborg V1","Cyborg",1},{"Auto Ghoul V1","Ghoul",1},
    {"Auto Upgrade V2","Current",2},{"Auto Upgrade V3","Current",3},
}) do
    RaceTab:CreateButton({
        Name = r[1],
        Callback = function()
            RemoteInvoke("StartRaceUpgrade", r[2], r[3])
            Rayfield:Notify({Title="Race", Content=r[1].." đang chạy", Duration=3})
        end,
    })
end

RaceTab:CreateSection("Race V2 / V3")
RaceTab:CreateButton({ Name = "Race V2", Callback = function() RemoteInvoke("UpgradeRace","2") end })
RaceTab:CreateButton({ Name = "Race V3", Callback = function() RemoteInvoke("UpgradeRace","3") end })

-- ==================== SHOP TAB ====================
local ShopTab = Window:CreateTab("Shop", 4483362458)

ShopTab:CreateSection("Mua Vật Phẩm")
for _, item in ipairs({
    {"Mua Observation Haki","BuyHaki","Observation"},
    {"Mua Soru","BuyHaki","Soru"},
    {"Mua Ghoul Race","BuyRace","Ghoul"},
    {"Đổi Chủng Tộc (Fragment)","ChangeRace",nil},
    {"Refund Stats","RefundStats",nil},
}) do
    local label, remote, arg = item[1], item[2], item[3]
    ShopTab:CreateButton({
        Name = label,
        Callback = function()
            if arg then RemoteInvoke(remote, arg) else RemoteInvoke(remote) end
            Rayfield:Notify({Title="Shop", Content=label.." thành công", Duration=3})
        end,
    })
end

ShopTab:CreateSection("Fighting Style")
ShopTab:CreateDropdown({
    Name = "Choose Fighting Style",
    Options = {"Black Leg","Electro","Fishman Karate","Dragon Claw","Superhuman","Death Step","Sharkman Karate","Electric Claw","Dragon Talon","Godhuman"},
    CurrentOption = "Black Leg",
    Flag = "FightingStyle",
    Callback = function(v) State.SelectedFightingStyle = v end,
})

ShopTab:CreateButton({
    Name = "Auto Buy Fighting Style (selected)",
    Callback = function()
        Rayfield:Notify({Title="Shop", Content="Đã chọn: "..State.SelectedFightingStyle, Duration=4})
    end,
})

ShopTab:CreateSection("Abilities")
for _, ability in ipairs({"Skyjump","Buso Haki","Observation Haki","Soru"}) do
    ShopTab:CreateButton({
        Name = "Buy "..ability,
        Callback = function()
            local remoteMap = {
                ["Skyjump"] = {"BuyHaki","Skyjump"},
                ["Buso Haki"] = {"BuyHaki","Buso"},
                ["Observation Haki"] = {"BuyHaki","Observation"},
                ["Soru"] = {"BuyHaki","Soru"}
            }
            local r = remoteMap[ability]
            local ok = RemoteInvoke(r[1], r[2])
            Rayfield:Notify({Title="Shop", Content=ok and ("Đã mua: "..ability) or ("Lỗi: "..ability), Duration=3})
        end,
    })
end

ShopTab:CreateSection("Misc Shop")
ShopTab:CreateButton({ Name = "Buy Refund Stat", Callback = function() RemoteInvoke("BlackbeardReward","Refund") end })
ShopTab:CreateButton({ Name = "Buy Reroll Race", Callback = function() RemoteInvoke("BlackbeardReward","Reroll") end })
ShopTab:CreateButton({ Name = "Buy Ghoul Race", Callback = function() RemoteInvoke("BuyRace","Ghoul") end })
ShopTab:CreateButton({ Name = "Buy Cyborg Race", Callback = function() RemoteInvoke("CyborgTrainer","Buy") end })

-- ==================== SERVER TAB ====================
local ServerTab = Window:CreateTab("Server", 4483362458)

ServerTab:CreateSection("Thông Tin Server")
ServerTab:CreateParagraph({Title="Place ID:", Content=tostring(game.PlaceId)})
ServerTab:CreateParagraph({Title="Job ID:", Content=tostring(game.JobId)})

ServerTab:CreateButton({
    Name = "Copy Job ID",
    Callback = function()
        CopyClip(game.JobId)
        Rayfield:Notify({Title="Server", Content="Đã copy Job ID", Duration=3})
    end,
})

ServerTab:CreateSection("Join Server")
ServerTab:CreateInput({
    Name = "Job ID",
    PlaceholderText = "Nhập Job ID để Join...",
    RemoveTextAfterFocusLost = false,
    Flag = "JobInput",
    Callback = function(v) State.ServerJobInput = v end,
})

ServerTab:CreateButton({
    Name = "Teleport [Job ID]",
    Callback = function()
        if State.ServerJobInput and #State.ServerJobInput > 5 then
            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, State.ServerJobInput, lp)
            end)
            if not ok then Rayfield:Notify({Title="Server", Content="Lỗi: "..tostring(err), Duration=4}) end
        else
            Rayfield:Notify({Title="Server", Content="Job ID không hợp lệ", Duration=3})
        end
    end,
})

ServerTab:CreateButton({
    Name = "Hop Server (Rejoin)",
    Callback = function() TeleportService:Teleport(game.PlaceId, lp) end,
})

-- ==================== PVP TAB ====================
local PVPTab = Window:CreateTab("PVP", 4483362458)

PVPTab:CreateSection("Players")
local function GetPlayerNames()
    local out = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then table.insert(out, p.Name) end end
    table.sort(out)
    if #out == 0 then out = {"No other players"} end
    return out
end

PVPTab:CreateDropdown({
    Name = "Choose Players",
    Options = GetPlayerNames(),
    CurrentOption = "No other players",
    Flag = "SelectedPlayer",
    Callback = function(v) State.SelectedPlayer = v end,
})

PVPTab:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        Rayfield:Notify({Title="PVP", Content="Players online: "..tostring(#Players:GetPlayers()-1), Duration=3})
    end,
})

PVPTab:CreateButton({
    Name = "Teleport to Choose Players",
    Callback = function()
        local p = Players:FindFirstChild(State.SelectedPlayer)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            SafeTP(p.Character.HumanoidRootPart.Position + Vector3.new(0,4,0))
        end
    end,
})

PVPTab:CreateButton({
    Name = "Spectate Choose Players",
    Callback = function()
        local p = Players:FindFirstChild(State.SelectedPlayer)
        if p and p.Character then
            local targetHum = p.Character:FindFirstChildOfClass("Humanoid")
            if targetHum then Workspace.CurrentCamera.CameraSubject = targetHum end
        end
    end,
})

PVPTab:CreateButton({
    Name = "Stop Spectating",
    Callback = function()
        if hum then Workspace.CurrentCamera.CameraSubject = hum end
    end,
})

PVPTab:CreateSection("Combat Settings")
PVPTab:CreateSlider({
    Name = "Bán kính vòng aim PvP",
    Range = {20, 600},
    Increment = 10,
    Suffix = " px",
    CurrentValue = 150,
    Flag = "AimRadius",
    Callback = function(v) State.AimRadius = v end,
})

PVPTab:CreateSlider({
    Name = "Change Speed",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 16,
    Flag = "ChangeSpeed",
    Callback = function(v) State.ChangeSpeed = v; if hum then hum.WalkSpeed = v end end,
})

PVPTab:CreateSlider({
    Name = "Jump Power",
    Range = {10, 200},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(v) State.JumpPower = v; if hum then hum.UseJumpPower = true; hum.JumpPower = v end end,
})

PVPTab:CreateButton({
    Name = "Restore Movement",
    Callback = function()
        if hum then hum.WalkSpeed = 16; hum.UseJumpPower = true; hum.JumpPower = 50 end
    end,
})

-- ==================== SETTINGS TAB ====================
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("Cài Đặt Chung")
SettingsTab:CreateToggle({
    Name = "Auto Destroy Lava",
    CurrentValue = false,
    Flag = "AutoLava",
    Callback = function(v)
        ENV["NGP_Lava"] = v
        if v then
            task.spawn(function()
                while ENV["NGP_Lava"] do
                    for _, p in ipairs(Workspace:GetDescendants()) do
                        if p:IsA("BasePart") and (p.Name:lower():find("lava") or p.Name:lower():find("magma")) then
                            pcall(function() p:Destroy() end)
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

SettingsTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        local codes = {"Sub2Fer999","Sub2OfficialNoobie","Sub2Daigrock","Enyu_is_Pro",
            "Magicbus","Bignews","STARcodeMUSE","Sub2Gamer456","Sub2UncleKizaru",
            "TheGreatAce","JCWK","CHANDLER","fudd10_v2","StrawHatMaine","Axiore"}
        for _, code in ipairs(codes) do RemoteInvoke("UseCode", code) task.wait(0.3) end
        Rayfield:Notify({Title="Codes", Content="Đã redeem tất cả code!", Duration=4})
    end,
})

SettingsTab:CreateSection("Chọn Team")
SettingsTab:CreateDropdown({
    Name = "Chọn Team",
    Options = {"Pirates","Marines","None"},
    CurrentOption = "None",
    Flag = "Team",
    Callback = function(v) RemoteInvoke("SetTeam", v) end,
})

SettingsTab:CreateSection("Bring Mob Max")
SettingsTab:CreateSlider({
    Name = "Bring Mob Max Distance",
    Range = {20, 1000},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 300,
    Flag = "BringMax",
    Callback = function(v) ENV["NGP_BringMax"] = v end,
})

SettingsTab:CreateSection("Movement")
SettingsTab:CreateSlider({
    Name = "Tween Speed",
    Range = {1, 350},
    Increment = 1,
    CurrentValue = 50,
    Flag = "TweenSpeed",
    Callback = function(v) State.TweenSpeed = v end,
})

-- ==================== DISCORD TAB ====================
local DiscordTab = Window:CreateTab("Discord", 4483362458)

DiscordTab:CreateSection("Webhook Notifications")
DiscordTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Flag = "Webhook",
    Callback = function(v) State.DiscordWebhook = v end,
})

DiscordTab:CreateButton({
    Name = "Test Webhook",
    Callback = function()
        SendWebhook("[NGP Hub] Test từ "..lp.Name)
        Rayfield:Notify({Title="Discord", Content="Đã gửi test webhook", Duration=3})
    end,
})

DiscordTab:CreateToggle({
    Name = "Notify khi Level Up",
    CurrentValue = false,
    Flag = "NotifyLevel",
    Callback = function(v)
        if v then
            lp:GetAttributeChangedSignal("Level"):Connect(function()
                SendWebhook("[NGP Hub] "..lp.Name.." vừa lên level!")
            end)
        end
    end,
})

DiscordTab:CreateToggle({
    Name = "Notify khi Trái Rơi",
    CurrentValue = false,
    Flag = "NotifyFruit",
    Callback = function(v)
        if v then
            Workspace.DescendantAdded:Connect(function(obj)
                if obj.Name:find("Fruit") or obj.Name:find("Devil") then
                    SendWebhook("[NGP Hub] Trái rơi: "..obj.Name.." | "..game.JobId)
                end
            end)
        end
    end,
})

DiscordTab:CreateSection("Account & Mention Settings")
DiscordTab:CreateInput({
    Name = "Discord User ID",
    PlaceholderText = "User ID (optional)",
    RemoveTextAfterFocusLost = false,
    Flag = "DiscordUserID",
    Callback = function(v) State.WebhookUserId = v end,
})

DiscordTab:CreateDropdown({
    Name = "Ping Mode",
    Options = {"None","User","Everyone","Here"},
    CurrentOption = "None",
    Flag = "PingMode",
    Callback = function(v) State.PingMode = v end,
})

-- ===================== BOOT NOTIFY =====================
Rayfield:Notify({
    Title = "Nguyen Gia Phuc Hub v4",
    Content = "Load thành công! UI đã chuyển sang Rayfield.",
    Duration = 5,
})
