-- ╔══════════════════════════════════════════════════════════════╗
-- ║         NGUYEN GIA PHUC HUB v3 — CUSTOM BUBBLE UI          ║
-- ║   Custom GUI (No Rayfield) | Blox Fruits | Universal       ║
-- ║   Arceus X · Delta X · Fluxus · Hydrogen · Solara          ║
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
    -- Extended module configuration
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

-- ===================== BRING MOB (chỉ mob/quái) =====================
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
--              CUSTOM BUBBLE GUI — NGP HUB
-- ============================================================

-- destroy old if re-run
if CoreGui:FindFirstChild("NGPHub") then CoreGui.NGPHub:Destroy() end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name="NGPHub"
ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset=true
pcall(function() ScreenGui.Parent=CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent=lp.PlayerGui end

-- ===================== THEME =====================
local CLR = {
    BG        = Color3.fromRGB(10,10,18),
    PANEL     = Color3.fromRGB(15,15,28),
    SIDEBAR   = Color3.fromRGB(12,12,22),
    ACCENT    = Color3.fromRGB(120,60,255),
    ACCENT2   = Color3.fromRGB(180,100,255),
    ACTIVE    = Color3.fromRGB(100,220,100),
    INACTIVE  = Color3.fromRGB(180,60,60),
    TEXT      = Color3.fromRGB(230,230,255),
    SUBTEXT   = Color3.fromRGB(140,140,180),
    BORDER    = Color3.fromRGB(40,40,70),
    BUBBLE    = Color3.fromRGB(120,60,255),
    BUBBLEIN  = Color3.fromRGB(180,100,255),
    HEADER    = Color3.fromRGB(18,18,35),
    TOGGLE_ON = Color3.fromRGB(100,220,100),
    TOGGLE_OFF= Color3.fromRGB(60,60,90),
    BUTTON    = Color3.fromRGB(30,30,55),
    BTNHOVER  = Color3.fromRGB(50,50,90),
    SECTION   = Color3.fromRGB(80,40,180),
    DROPDOWN  = Color3.fromRGB(20,20,38),
    INPUT_BG  = Color3.fromRGB(20,20,38),
    SLIDER_BG = Color3.fromRGB(20,20,38),
    SLIDER_FG = Color3.fromRGB(120,60,255),
}

-- ===================== HELPERS =====================
local function MakeCorner(r,p)
    local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=p return c
end
local function MakeStroke(t,c,p)
    local s=Instance.new("UIStroke") s.Thickness=t s.Color=c s.Parent=p return s
end
local function MakePadding(top,bot,left,right,p)
    local pad=Instance.new("UIPadding")
    pad.PaddingTop=UDim.new(0,top) pad.PaddingBottom=UDim.new(0,bot)
    pad.PaddingLeft=UDim.new(0,left) pad.PaddingRight=UDim.new(0,right)
    pad.Parent=p return pad
end
local function MakeList(spacing,p)
    local l=Instance.new("UIListLayout")
    l.SortOrder=Enum.SortOrder.LayoutOrder
    l.Padding=UDim.new(0,spacing)
    l.Parent=p return l
end

local function NewFrame(name,size,pos,color,parent)
    local f=Instance.new("Frame")
    f.Name=name f.Size=size f.Position=pos
    f.BackgroundColor3=color f.BorderSizePixel=0
    f.Parent=parent return f
end

local function NewLabel(txt,size,pos,color,textSize,parent)
    local l=Instance.new("TextLabel")
    l.Text=txt l.Size=size l.Position=pos
    l.BackgroundTransparency=1 l.TextColor3=color
    l.TextSize=textSize l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=parent return l
end

local function NewButton(txt,size,pos,color,textColor,parent,callback)
    local btn=Instance.new("TextButton")
    btn.Text=txt btn.Size=size btn.Position=pos
    btn.BackgroundColor3=color btn.TextColor3=textColor
    btn.TextSize=13 btn.Font=Enum.Font.GothamSemibold
    btn.BorderSizePixel=0 btn.AutoButtonColor=false
    btn.Parent=parent
    MakeCorner(6,btn)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=CLR.ACCENT}):Play()
        task.delay(0.15,function()
            TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=color}):Play()
        end)
        if callback then callback() end
    end)
    return btn
end

-- ===================== TOGGLE FACTORY =====================
local function MakeToggle(parent, labelText, default, onToggle)
    local row=NewFrame("ToggleRow",UDim2.new(1,0,0,32),UDim2.new(0,0,0,0),Color3.fromRGB(0,0,0),parent)
    row.BackgroundTransparency=1

    NewLabel(labelText,UDim2.new(1,-52,1,0),UDim2.new(0,0,0,0),CLR.TEXT,13,row)

    local track=NewFrame("Track",UDim2.new(0,42,0,22),UDim2.new(1,-42,0.5,-11),
        default and CLR.TOGGLE_ON or CLR.TOGGLE_OFF,row)
    MakeCorner(11,track)

    local knob=NewFrame("Knob",UDim2.new(0,16,0,16),
        UDim2.new(default and 1 or 0,default and -19 or 3,0.5,-8),
        Color3.fromRGB(255,255,255),track)
    MakeCorner(8,knob)

    local state=default
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1
    btn.Text="" btn.Parent=row
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(track,TweenInfo.new(0.2),{BackgroundColor3=state and CLR.TOGGLE_ON or CLR.TOGGLE_OFF}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2),{Position=UDim2.new(state and 1 or 0,state and -19 or 3,0.5,-8)}):Play()
        if onToggle then onToggle(state) end
    end)
    return row
end

-- ===================== SLIDER FACTORY =====================
local function MakeSlider(parent, labelText, min, max, default, suffix, onChange)
    local container=NewFrame("SliderContainer",UDim2.new(1,0,0,52),UDim2.new(0,0,0,0),Color3.fromRGB(0,0,0),parent)
    container.BackgroundTransparency=1

    local lbl=NewLabel(labelText,UDim2.new(0.7,0,0,18),UDim2.new(0,0,0,0),CLR.TEXT,12,container)
    local valLbl=NewLabel(tostring(default)..(suffix or ""),UDim2.new(0.3,0,0,18),UDim2.new(0.7,0,0,0),CLR.ACCENT2,12,container)
    valLbl.TextXAlignment=Enum.TextXAlignment.Right

    local track=NewFrame("Track",UDim2.new(1,0,0,8),UDim2.new(0,0,0,24),CLR.SLIDER_BG,container)
    MakeCorner(4,track)

    local fill=NewFrame("Fill",UDim2.new((default-min)/(max-min),0,1,0),UDim2.new(0,0,0,0),CLR.SLIDER_FG,track)
    MakeCorner(4,fill)

    local knob=NewFrame("Knob",UDim2.new(0,14,0,14),UDim2.new((default-min)/(max-min),0,-7,0.5,-7),CLR.ACCENT2,track)
    MakeCorner(7,knob)

    local dragging=false
    local function updateVal(x)
        local abs=track.AbsolutePosition.X
        local w=track.AbsoluteSize.X
        local pct=math.clamp((x-abs)/w,0,1)
        local val=math.floor(min+pct*(max-min))
        fill.Size=UDim2.new(pct,0,1,0)
        knob.Position=UDim2.new(pct,0,-7,0.5,-7)
        valLbl.Text=tostring(val)..(suffix or "")
        if onChange then onChange(val) end
    end

    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and(inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            updateVal(inp.Position.X)
        end
    end)
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            updateVal(inp.Position.X)
        end
    end)
    return container
end

-- ===================== DROPDOWN FACTORY =====================
local function MakeDropdown(parent, labelText, options, default, onChange)
    local container=NewFrame("DropContainer",UDim2.new(1,0,0,52),UDim2.new(0,0,0,0),Color3.fromRGB(0,0,0),parent)
    container.BackgroundTransparency=1

    NewLabel(labelText,UDim2.new(1,0,0,18),UDim2.new(0,0,0,0),CLR.TEXT,12,container)

    local selected=default or options[1]
    local dropBtn=NewFrame("DropBtn",UDim2.new(1,0,0,28),UDim2.new(0,0,0,20),CLR.DROPDOWN,container)
    MakeCorner(6,dropBtn)
    MakeStroke(1,CLR.BORDER,dropBtn)
    MakePadding(0,0,8,8,dropBtn)

    local selLbl=NewLabel(selected,UDim2.new(0.85,0,1,0),UDim2.new(0,0,0,0),CLR.TEXT,12,dropBtn)
    local arrow=NewLabel("▼",UDim2.new(0.15,0,1,0),UDim2.new(0.85,0,0,0),CLR.SUBTEXT,10,dropBtn)
    arrow.TextXAlignment=Enum.TextXAlignment.Right

    local list=NewFrame("List",UDim2.new(1,0,0,#options*28),UDim2.new(0,0,1,2),CLR.DROPDOWN,container)
    list.ZIndex=10 list.Visible=false
    MakeCorner(6,list) MakeStroke(1,CLR.BORDER,list)

    for i,opt in ipairs(options) do
        local row=NewButton(opt,UDim2.new(1,0,0,28),UDim2.new(0,0,0,(i-1)*28),
            CLR.DROPDOWN,CLR.TEXT,list,function()
                selected=opt selLbl.Text=opt list.Visible=false
                if onChange then onChange(opt) end
            end)
        row.TextXAlignment=Enum.TextXAlignment.Left
        MakePadding(0,0,8,0,row)
        row.ZIndex=11
    end

    local open=false
    local clickBtn=Instance.new("TextButton")
    clickBtn.Size=UDim2.new(1,0,1,0) clickBtn.BackgroundTransparency=1
    clickBtn.Text="" clickBtn.Parent=dropBtn clickBtn.ZIndex=5
    clickBtn.MouseButton1Click:Connect(function()
        open=not open list.Visible=open
        arrow.Text=open and "▲" or "▼"
    end)
    container.Size=UDim2.new(1,0,0,52)
    return container
end

-- ===================== SECTION LABEL =====================
local function MakeSection(parent, text)
    local row=NewFrame("Section",UDim2.new(1,0,0,22),UDim2.new(0,0,0,0),Color3.fromRGB(0,0,0),parent)
    row.BackgroundTransparency=1
    local line=NewFrame("Line",UDim2.new(1,0,0,1),UDim2.new(0,0,0.5,0),CLR.SECTION,row)
    local bg=NewFrame("SectionBG",UDim2.new(0,0,1,0),UDim2.new(0,0,0,0),CLR.SECTION,row)
    bg.BackgroundTransparency=1
    local lbl=NewLabel("  "..text,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),CLR.ACCENT2,11,row)
    lbl.Font=Enum.Font.GothamBold
    return row
end

-- ===================== NOTIFICATION =====================
local notifContainer=NewFrame("Notifs",UDim2.new(0,280,0,0),UDim2.new(1,-290,1,-10),
    Color3.fromRGB(0,0,0),ScreenGui)
notifContainer.BackgroundTransparency=1 notifContainer.AnchorPoint=Vector2.new(0,1)
MakeList(6,notifContainer)
notifContainer.AutomaticSize=Enum.AutomaticSize.Y

local function ShowNotif(title,msg,dur)
    local card=NewFrame("Notif",UDim2.new(1,0,0,56),UDim2.new(0,0,0,0),CLR.PANEL,notifContainer)
    card.BackgroundTransparency=0.1
    MakeCorner(8,card) MakeStroke(1,CLR.ACCENT,card)
    MakePadding(6,6,10,10,card)

    local tBar=NewFrame("Bar",UDim2.new(0,3,1,-12),UDim2.new(0,0,0,6),CLR.ACCENT,card)
    MakeCorner(2,tBar)

    NewLabel("🔔 "..title,UDim2.new(1,-16,0,18),UDim2.new(16,0,0,0),CLR.ACCENT2,12,card)
    NewLabel(msg,UDim2.new(1,-16,0,16),UDim2.new(16,0,0,20),CLR.TEXT,11,card)

    card.Position=UDim2.new(1,10,0,0)
    TweenService:Create(card,TweenInfo.new(0.3,Enum.EasingStyle.Quart),{Position=UDim2.new(0,0,0,0)}):Play()
    task.delay(dur or 3,function()
        TweenService:Create(card,TweenInfo.new(0.3),{Position=UDim2.new(1,10,0,0),BackgroundTransparency=1}):Play()
        task.delay(0.35,function() card:Destroy() end)
    end)
end

-- ===================== MAIN PANEL =====================
local PanelOpen=false

-- Main panel frame
local Panel=NewFrame("Panel",UDim2.new(0,520,0,440),UDim2.new(0.5,-260,0.5,-220),CLR.BG,ScreenGui)
MakeCorner(12,Panel) MakeStroke(1,CLR.BORDER,Panel)
Panel.Visible=false

-- Header
local Header=NewFrame("Header",UDim2.new(1,0,0,42),UDim2.new(0,0,0,0),CLR.HEADER,Panel)
MakeCorner(12,Header)

local LogoGlow=NewFrame("Glow",UDim2.new(0,24,0,24),UDim2.new(0,10,0.5,-12),CLR.ACCENT,Header)
MakeCorner(6,LogoGlow)
NewLabel("N",UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(255,255,255),14,LogoGlow).TextXAlignment=Enum.TextXAlignment.Center

NewLabel("Nguyen Gia Phuc Hub",UDim2.new(0,220,1,0),UDim2.new(0,42,0,0),CLR.TEXT,15,Header)
NewLabel("Blox Fruits • Universal",UDim2.new(0,180,1,0),UDim2.new(0,42,0,18),CLR.SUBTEXT,10,Header)

-- version badge
local verBadge=NewFrame("Ver",UDim2.new(0,42,0,18),UDim2.new(1,-52,0.5,-9),CLR.ACCENT,Header)
MakeCorner(9,verBadge)
NewLabel("v4.0",UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(255,255,255),10,verBadge).TextXAlignment=Enum.TextXAlignment.Center

-- close button
local CloseBtn=NewButton("✕",UDim2.new(0,26,0,26),UDim2.new(1,-32,0.5,-13),
    Color3.fromRGB(180,50,50),Color3.fromRGB(255,255,255),Header,function()
        TweenService:Create(Panel,TweenInfo.new(0.2),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
        task.delay(0.2,function() Panel.Visible=false PanelOpen=false end)
    end)

-- drag
local dragging_panel,drag_offset=false,Vector2.new()
Header.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        dragging_panel=true
        drag_offset=Vector2.new(inp.Position.X-Panel.AbsolutePosition.X,inp.Position.Y-Panel.AbsolutePosition.Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        dragging_panel=false
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging_panel and(inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
        Panel.Position=UDim2.new(0,inp.Position.X-drag_offset.X,0,inp.Position.Y-drag_offset.Y)
    end
end)

-- ===================== SIDEBAR =====================
local Sidebar=Instance.new("ScrollingFrame")
Sidebar.Name="Sidebar"
Sidebar.Size=UDim2.new(0,110,1,-42)
Sidebar.Position=UDim2.new(0,0,0,42)
Sidebar.BackgroundColor3=CLR.SIDEBAR
Sidebar.BorderSizePixel=0
Sidebar.ScrollBarThickness=3
Sidebar.ScrollBarImageColor3=CLR.ACCENT
Sidebar.CanvasSize=UDim2.new(0,0,0,0)
Sidebar.AutomaticCanvasSize=Enum.AutomaticSize.Y
Sidebar.Parent=Panel
MakeStroke(1,CLR.BORDER,Sidebar)
MakePadding(8,8,0,0,Sidebar)
MakeList(2,Sidebar)

-- ===================== CONTENT AREA =====================
local ContentArea=NewFrame("Content",UDim2.new(1,-112,1,-42),UDim2.new(0,112,0,42),CLR.PANEL,Panel)
MakePadding(0,0,0,0,ContentArea)

-- ===================== TAB PAGES =====================
local Pages={}
local ActiveTab=nil

local function MakePage(name)
    local page=NewFrame("Page_"..name,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),CLR.PANEL,ContentArea)
    page.Visible=false
    local scroll=Instance.new("ScrollingFrame")
    scroll.Size=UDim2.new(1,0,1,0)
    scroll.Position=UDim2.new(0,0,0,0)
    scroll.BackgroundTransparency=1
    scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=3
    scroll.ScrollBarImageColor3=CLR.ACCENT
    scroll.CanvasSize=UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.Parent=page
    MakePadding(8,8,10,10,scroll)
    MakeList(5,scroll)
    Pages[name]={frame=page,scroll=scroll}
    return Pages[name]
end

-- ===================== SIDEBAR TABS =====================
local TAB_ICONS={
    Farm="🌾", ["Bring Mob"]="👾", Bay="✈️", Skill="⚔️",
    Halloween="🎃", ["Level 3000"]="🔎", Fishing="🎣", ESP="👁", Stats="📊",
    Fruits="🍎", Stack="⚡", ["Hop Farm"]="🔁", Quest="📋", Sea="🌊",
    Teleport="🗺", Race="🧬", Shop="🛒", Server="🖥", PVP="🎯",
    Settings="⚙️", Discord="💬",
}

local TAB_ORDER={
    "Farm","Bring Mob","Bay","Skill","Halloween","Level 3000","Fishing","ESP","Stats",
    "Fruits","Stack","Hop Farm","Quest","Sea","Teleport","Race","Shop","Server","PVP","Settings","Discord",
}

local SidebarBtns={}
local function SelectTab(name)
    for n,btn in pairs(SidebarBtns) do
        TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=n==name and CLR.ACCENT or Color3.fromRGB(0,0,0)}):Play()
        btn.BackgroundTransparency=n==name and 0 or 1
    end
    for n,pg in pairs(Pages) do pg.frame.Visible=n==name end
    ActiveTab=name
end

for _,tabName in ipairs(TAB_ORDER) do
    MakePage(tabName)
    local icon=TAB_ICONS[tabName] or "•"
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,36)
    btn.BackgroundColor3=CLR.ACCENT
    btn.BackgroundTransparency=1
    btn.TextColor3=CLR.TEXT
    btn.Text=icon.." "..tabName
    btn.TextSize=11
    btn.Font=Enum.Font.GothamSemibold
    btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.BorderSizePixel=0
    btn.Parent=Sidebar
    MakeCorner(6,btn)
    MakePadding(0,0,8,4,btn)
    SidebarBtns[tabName]=btn
    btn.MouseButton1Click:Connect(function() SelectTab(tabName) end)
end

-- ===================== POPULATE TABS =====================
local function Add(tabName, element)
    local pg=Pages[tabName]
    if pg then element.Parent=pg.scroll end
end

local function AddSection(tabName,text) Add(tabName,MakeSection(nil,text)) end

local function AddToggle(tabName,label,default,cb)
    Add(tabName,MakeToggle(nil,label,default,cb))
end

local function AddButton(tabName,label,cb)
    local btn=NewButton(label,UDim2.new(1,0,0,30),UDim2.new(0,0,0,0),CLR.BUTTON,CLR.TEXT,nil,cb)
    Add(tabName,btn)
end

local function AddSlider(tabName,label,min,max,default,suffix,cb)
    Add(tabName,MakeSlider(nil,label,min,max,default,suffix,cb))
end

local function AddDropdown(tabName,label,opts,default,cb)
    Add(tabName,MakeDropdown(nil,label,opts,default,cb))
end

local function AddLabel(tabName,text)
    local lbl=NewLabel(text,UDim2.new(1,0,0,18),UDim2.new(0,0,0,0),CLR.SUBTEXT,11,nil)
    lbl.Font=Enum.Font.Gotham
    Add(tabName,lbl)
end

local function AddInput(tabName,placeholder,cb)
    local bg=NewFrame("InputBG",UDim2.new(1,0,0,30),UDim2.new(0,0,0,0),CLR.INPUT_BG,nil)
    MakeCorner(6,bg) MakeStroke(1,CLR.BORDER,bg)
    local box=Instance.new("TextBox")
    box.Size=UDim2.new(1,-10,1,0) box.Position=UDim2.new(0,5,0,0)
    box.BackgroundTransparency=1 box.TextColor3=CLR.TEXT
    box.PlaceholderText=placeholder box.PlaceholderColor3=CLR.SUBTEXT
    box.TextSize=12 box.Font=Enum.Font.Gotham
    box.TextXAlignment=Enum.TextXAlignment.Left
    box.ClearTextOnFocus=false box.Parent=bg
    box.FocusLost:Connect(function() if cb then cb(box.Text) end end)
    Add(tabName,bg)
end

-- ==================== FARM TAB ====================
AddSection("Farm","Chế Độ Farm")
AddDropdown("Farm","Farm Mode",{"Farm Level","Farm Near Mobs","Farm Level Secret"},"Farm Level",function(v)
    State.FarmMode=v
end)
AddLabel("Farm Level: Bay đến mob, đánh liên tục")
AddLabel("Farm Near Mobs: Đứng yên, bring mob đến")
AddLabel("Farm Level Secret: Nhiệm vụ bí ẩn Sea 1 (2800+)")
AddSection("Farm","Chọn Mục Tiêu")
local targetList={"Auto"}
for k in pairs(MOB_TARGETS) do if k~="Auto" then table.insert(targetList,k) end end
table.sort(targetList)
AddDropdown("Farm","Mob Target",targetList,"Auto",function(v) State.FarmTarget=v end)
AddSection("Farm","Điều Khiển")
AddToggle("Farm","Auto Farm",false,function(v)
    State.AutoFarm=v
    if v then StartFarmLoop() end
end)
AddToggle("Farm","Auto Skill khi Farm",false,function(v) State.AutoSkill=v end)
AddSlider("Farm","Chiều Cao Bay",0,200,50," studs",function(v) State.FlyHeight=v end)
AddSection("Farm","Thu Thập")
AddToggle("Farm","Auto Collect Berry",false,function(v)
    State.AutoCollectBerry=v
    if v then task.spawn(CollectBerryLoop) end
end)
AddToggle("Farm","Auto Collect Chest",false,function(v)
    State.AutoChest=v
    if v then task.spawn(CollectChestLoop) end
end)
AddToggle("Farm","Auto Hop Find Berry",false,function(v)
    ENV["NGP_HopBerry"]=v
    if v then
        task.spawn(function()
            while ENV["NGP_HopBerry"] do
                RemoteInvoke("HopFindBerry")
                task.wait(30)
            end
        end)
    end
end)
AddToggle("Farm","Accept Quests (Bone/Cake/Tyrant)",false,function(v)
    ENV["NGP_Quest"]=v
    if v then
        task.spawn(function()
            while ENV["NGP_Quest"] do RemoteInvoke("StartQuest","Current") task.wait(5) end
        end)
    end
end)
AddToggle("Farm","Auto Complete Bartilo Quest",false,function(v)
    ENV["NGP_Bartilo"]=v
    if v then
        task.spawn(function()
            while ENV["NGP_Bartilo"] do
                RemoteInvoke("StartQuest","Bartilo") task.wait(2)
                RemoteInvoke("CompleteQuest","Bartilo") task.wait(3)
            end
        end)
    end
end)
AddToggle("Farm","Auto Training Dummy",false,function(v)
    ENV["NGP_Dummy"]=v
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
end)
AddToggle("Farm","Ignore Cake Prince",false,function(v) ENV["NGP_IgnoreCake"]=v end)
AddSection("Farm","Auto Level 3000 (Secret Quest)")
AddLabel("Yêu cầu: Level 2800+ tại Sea 1")
AddLabel("Thứ tự NPC: Expert → Scientist → Horned Man → Shanks")
AddButton("Farm","Xem Tiến Độ Secret Quest",function()
    ShowNotif("Secret Quest","Đã hoàn thành: "..State.SecretQuestDone.." lượt",4)
end)

-- ==================== BRING MOB TAB ====================
AddSection("Bring Mob","⚠ Chỉ Kéo Mob/Quái (Đã lọc NPC)")
AddLabel("Tự lọc: vendor, quest giver, player")
AddToggle("Bring Mob","Bật Bring Mob",false,function(v)
    State.BringMob=v
    if v then task.spawn(BringMobLoop) end
end)
AddSlider("Bring Mob","Phạm Vi Kéo Mob",20,500,150," studs",function(v) State.BringMobRange=v end)
AddDropdown("Bring Mob","Bring Mode",{"Tất cả mob trong tầm","Chỉ mob đang farm","Boss Only"},"Tất cả mob trong tầm",function(v) end)

-- ==================== BAY TAB ====================
AddSection("Bay","Điều Khiển Bay")
AddToggle("Bay","Bật Bay (WASD + Space/Ctrl)",false,function(v)
    if v then EnableFly() else DisableFly() end
end)
AddSlider("Bay","Tốc Độ Bay",1,20,1,"x",function(v) State.TweenSpeed=v end)
AddLabel("Bay tự động bật khi Auto Farm chạy")

-- ==================== SKILL TAB ====================
AddSection("Skill","Cấu Hình Kỹ Năng")
AddSlider("Skill","Skill Delay",0,2,0," ms",function(v) State.SkillDelay=v/10 end)
for _,info in ipairs({{"Z",Enum.KeyCode.Z},{"X",Enum.KeyCode.X},{"C",Enum.KeyCode.C},{"V",Enum.KeyCode.V}}) do
    local name,kc=info[1],info[2]
    local fk="NGP_SK"..name
    AddToggle("Skill","Spam Skill "..name,false,function(v)
        ENV[fk]=v
        if v then
            task.spawn(function()
                while ENV[fk] do
                    PressKey(kc,true) task.wait(State.SkillDelay)
                    PressKey(kc,false) task.wait(State.SkillDelay)
                end
            end)
        end
    end)
end

-- ==================== HALLOWEEN TAB ====================
AddSection("Halloween","🎃 Trick or Treat")
AddToggle("Halloween","Auto Trick or Treat",false,function(v)
    State.AutoTrickOrTreat=v
    if v then task.spawn(HWTrickLoop) end
end)
AddButton("Halloween","Oni Celestial Choice",function()
    RemoteInvoke("HalloweenEvent","CelestialChoice","Oni")
    ShowNotif("Halloween","Đã chọn Celestial Oni",3)
end)
AddSection("Halloween","🎃 Pumpkin Hunt")
AddToggle("Halloween","Auto Pumpkin Hunt",false,function(v)
    State.AutoPumpkinHunt=v
    if v then task.spawn(HWPumpkinLoop) end
end)
AddButton("Halloween","Hop Server for Cursed Pumpkin Seed",function()
    ShowNotif("Halloween","Hopping server...",3)
    TeleportService:Teleport(game.PlaceId,lp)
end)
AddSection("Halloween","🎃 Great Pumpkin")
AddToggle("Halloween","Auto Farm Great Pumpkin",false,function(v)
    State.AutoGreatPumpkin=v
    if v then task.spawn(HWGreatPumpkinLoop) end
end)
AddButton("Halloween","Summon Great Pumpkin",function()
    RemoteInvoke("HalloweenEvent","SummonGreatPumpkin")
    ShowNotif("Halloween","Đã summon Great Pumpkin",3)
end)
AddSection("Halloween","🎃 Auto Level 3000")
AddToggle("Halloween","Auto Secret Hint (Hop)",false,function(v)
    State.AutoHopSecret=v
    if v then
        task.spawn(function()
            while State.AutoHopSecret do
                RemoteInvoke("HopSecretHint")
                task.wait(30)
            end
        end)
    end
end)

-- ==================== FISHING TAB ====================
AddSection("Fishing","Auto Fishing")
AddToggle("Fishing","Auto Fishing Quest",false,function(v)
    State.AutoFishing=v
    if v then task.spawn(FishingLoop) end
end)
AddToggle("Fishing","Auto Sell Fish",false,function(v) State.AutoSellFish=v end)
AddButton("Fishing","Teleport đến Fishing Spot",function()
    SafeTP(Vector3.new(1746,11,1297))
    ShowNotif("Teleport","Đã đến Fishing Spot",3)
end)
AddButton("Fishing","Teleport đến Sharkman Master",function()
    SafeTP(Vector3.new(-3215,8,2800))
    ShowNotif("Teleport","Đã đến Sharkman Master",3)
end)
AddToggle("Fishing","Auto Tween to Event Fishing Spot",false,function(v)
    ENV["NGP_FishTween"]=v
    if v then
        task.spawn(function()
            while ENV["NGP_FishTween"] do
                SafeTP(Vector3.new(1746,11,1297)) task.wait(15)
            end
        end)
    end
end)

-- ==================== ESP TAB ====================
AddSection("ESP","ESP Mob / Enemy")
AddToggle("ESP","Bật ESP Mob",false,function(v)
    State.ESPEnabled=v
    if v then task.spawn(ESPLoop) end
end)

-- ==================== STATS TAB ====================
AddSection("Stats","Phân Phối Chỉ Số")
for _,s in ipairs({"Melee","Sword","Gun","Fruit","Defense"}) do
    AddInput("Stats","Điểm "..s.." (nhập số)...",function(v)
        State.StatPoints[s]=tonumber(v) or 0
    end)
end
AddToggle("Stats","Auto Phân Phối Stats",false,function(v)
    State.AutoStats=v
    if v then task.spawn(AutoStatsLoop) end
end)
AddSection("Stats","Auto Stats Buttons")
for _,s in ipairs({"Melee","Sword","Gun","Fruit","Defense"}) do
    AddButton("Stats","Auto Max "..s,function()
        RemoteInvoke("AddStats",s=="Fruit" and "BloxFruit" or s,99999)
        ShowNotif("Stats","Max "..s.." done",3)
    end)
end

-- ==================== FRUITS TAB ====================
AddSection("Fruits","Trái Ác Quỷ")
AddToggle("Fruits","Auto Nhặt Trái Rơi",false,function(v)
    ENV["NGP_Fruits"]=v
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
end)
AddButton("Fruits","Auto Buy Random Fruit",function()
    RemoteInvoke("BuyFruit","Random")
    ShowNotif("Fruits","Đã mua Random Fruit",3)
end)
AddToggle("Fruits","Store Fruits Auto",false,function(v)
    ENV["NGP_StoreFruit"]=v
    if v then
        task.spawn(function()
            while ENV["NGP_StoreFruit"] do RemoteInvoke("StoreFruit") task.wait(5) end
        end)
    end
end)
AddSection("Fruits","Raid / Dungeon")
AddDropdown("Fruits","Chọn Độ Khó",{"Normal","Hard","Extreme"},"Normal",function(v) end)
AddToggle("Fruits","Auto Join Dungeon",false,function(v)
    ENV["NGP_JoinDungeon"]=v
    if v then
        task.spawn(function()
            while ENV["NGP_JoinDungeon"] do RemoteInvoke("JoinRaid") task.wait(5) end
        end)
    end
end)
AddToggle("Fruits","Auto Raid Farm Boss",false,function(v)
    ENV["NGP_RaidFarm"]=v
    if v then
        task.spawn(function()
            while ENV["NGP_RaidFarm"] do
                local mob=GetNearestMob(500)
                if mob then AttackMob(mob) end
                task.wait(1)
            end
        end)
    end
end)
AddToggle("Fruits","Auto Nhặt Thẻ (Card)",false,function(v)
    ENV["NGP_Card"]=v
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
end)

-- ==================== STACK TAB ====================
AddSection("Stack","Boss & Elite Farm")
for _,b in ipairs({
    {"Auto Elite Quest","EliteQuest"},{"Auto Dough King","DoughKing"},
    {"Auto Darkbeard","Darkbeard"},{"Auto Rip_indra","Rip_indra"},
    {"Auto Factory Raid","FactoryRaid"},
}) do
    AddButton("Stack",b[1],function()
        State.FarmTarget=b[2] State.FarmMode="Farm Level" State.AutoFarm=true
        task.spawn(FarmLevelLoop)
        ShowNotif("Stack Farm",b[1].." đang chạy",3)
    end)
end
AddButton("Stack","Auto Craft Shark Anchor",function()
    RemoteInvoke("CraftItem","SharkAnchor")
    ShowNotif("Craft","Crafting Shark Anchor",3)
end)
AddSection("Stack","Hop Farm")
AddToggle("Stack","Auto Hop Farm (Chuyển Server)",false,function(v)
    State.AutoHopFarm=v
    if v then
        task.spawn(function()
            while State.AutoHopFarm do
                TeleportService:Teleport(game.PlaceId,lp)
                task.wait(60)
            end
        end)
    end
end)

-- ==================== QUEST TAB ====================
AddSection("Quest","Skull Guitar")
AddButton("Quest","Auto Skull Guitar Quest",function()
    RemoteInvoke("StartQuest","SkullGuitar")
    ShowNotif("Quest","Skull Guitar started",3)
end)
AddButton("Quest","Auto Farm Material Skull Guitar",function()
    State.FarmTarget="SkullGuitarMat" State.FarmMode="Farm Level" State.AutoFarm=true
    task.spawn(FarmLevelLoop)
    ShowNotif("Farm","Farming Skull Guitar materials",3)
end)
AddButton("Quest","Talk With Stone",function()
    RemoteInvoke("InteractNPC","Stone")
    ShowNotif("Quest","Interacted with Stone",3)
end)
AddSection("Quest","Special Items")
for _,item in ipairs({"Rengoku Sword","Rengoku Key","Dark Blade V3","Midnight Blade","True Triple Katana","Swan Glasses","Don Swan"}) do
    AddButton("Quest","Auto Farm "..item,function()
        State.FarmTarget=item State.FarmMode="Farm Level" State.AutoFarm=true
        task.spawn(FarmLevelLoop)
        ShowNotif("Farm","Đang farm "..item,3)
    end)
end

-- ==================== SEA TAB ====================
AddSection("Sea","Điều Khiển Thuyền")
AddDropdown("Sea","Chọn Thuyền",{"Dinghy","Coffin Boat","Caravel","Galleon","Warship"},"Dinghy",function(v) end)
AddSlider("Sea","Tốc Độ Thuyền",1,100,50,"",function(v) ENV["NGP_BoatSpeed"]=v end)
AddToggle("Sea","Auto Sail Boat",false,function(v) ENV["NGP_AutoSail"]=v end)
AddToggle("Sea","Auto Escape Rough Sea",false,function(v)
    ENV["NGP_EscapeSea"]=v
    if v then
        task.spawn(function()
            while ENV["NGP_EscapeSea"] do RemoteInvoke("EscapeRoughSea") task.wait(3) end
        end)
    end
end)
AddSection("Sea","Farm Sự Kiện Biển")
AddToggle("Sea","Auto Farm Sea Event",false,function(v)
    ENV["NGP_SeaFarm"]=v
    if v then
        task.spawn(function()
            while ENV["NGP_SeaFarm"] do
                local mob=GetNearestMob(300)
                if mob then AttackMob(mob) end
                task.wait(1)
            end
        end)
    end
end)
AddToggle("Sea","Farm M1 Fruit Only",false,function(v) ENV["NGP_FruitOnly"]=v end)
AddToggle("Sea","Farm Use Gun Only",false,function(v) ENV["NGP_GunOnly"]=v end)
AddToggle("Sea","Xóa Sky Fog (Tăng FPS)",false,function(v)
    Workspace.FogEnd=v and 10000 or 1000
    Workspace.FogStart=v and 10000 or 0
end)

-- ==================== TELEPORT TAB ====================
AddSection("Teleport","Sea 1")
for _,v in ipairs({
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
    AddButton("Teleport","→ "..v[1],function()
        SafeTP(v[2]) ShowNotif("Teleport","Đã đến "..v[1],3)
    end)
end
AddSection("Teleport","Sea 2")
for _,v in ipairs({
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
    AddButton("Teleport","→ "..v[1],function()
        SafeTP(v[2]) ShowNotif("Teleport","Đã đến "..v[1],3)
    end)
end

-- ==================== RACE TAB ====================
AddSection("Race","Nâng Cấp Tộc")
for _,r in ipairs({
    {"Auto Cyborg V1","Cyborg",1},{"Auto Ghoul V1","Ghoul",1},
    {"Auto Upgrade V2","Current",2},{"Auto Upgrade V3","Current",3},
}) do
    AddButton("Race",r[1],function()
        RemoteInvoke("StartRaceUpgrade",r[2],r[3])
        ShowNotif("Race",r[1].." đang chạy",3)
    end)
end

-- ==================== SHOP TAB ====================
AddSection("Shop","Mua Vật Phẩm")
for _,item in ipairs({
    {"Mua Observation Haki","BuyHaki","Observation"},
    {"Mua Soru","BuyHaki","Soru"},
    {"Mua Ghoul Race","BuyRace","Ghoul"},
    {"Đổi Chủng Tộc (Fragment)","ChangeRace",nil},
    {"Refund Stats","RefundStats",nil},
}) do
    local label,remote,arg=item[1],item[2],item[3]
    AddButton("Shop",label,function()
        if arg then RemoteInvoke(remote,arg) else RemoteInvoke(remote) end
        ShowNotif("Shop",label.." thành công",3)
    end)
end

-- ==================== SERVER TAB ====================
AddSection("Server","Thông Tin Server")
AddLabel("Server","Place ID: "..tostring(game.PlaceId))
AddLabel("Server","Job ID: "..tostring(game.JobId))
AddButton("Server","Copy Job ID",function()
    CopyClip(game.JobId) ShowNotif("Server","Đã copy Job ID",3)
end)
AddSection("Server","Join Server")
AddInput("Server","Nhập Job ID để Join...",function(v)
    if v and v~="" then
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,v,lp) end)
    end
end)
AddButton("Server","Hop Server (Rejoin)",function()
    TeleportService:Teleport(game.PlaceId,lp)
end)

-- ==================== SETTINGS TAB ====================
AddSection("Settings","Cài Đặt Chung")
AddToggle("Settings","Auto Destroy Lava",false,function(v)
    ENV["NGP_Lava"]=v
    if v then
        task.spawn(function()
            while ENV["NGP_Lava"] do
                for _,p in ipairs(Workspace:GetDescendants()) do
                    if p:IsA("BasePart") and(p.Name:lower():find("lava") or p.Name:lower():find("magma")) then
                        pcall(function() p:Destroy() end)
                    end
                end
                task.wait(1)
            end
        end)
    end
end)
AddToggle("Settings","Auto Load Script after Teleport",false,function(v)
    if v then
        lp.CharacterAdded:Connect(function()
            task.wait(3) ShowNotif("NGP Hub","Script vẫn đang chạy ✓",3)
        end)
    end
end)
AddButton("Settings","Redeem All Codes",function()
    local codes={"Sub2Fer999","Sub2OfficialNoobie","Sub2Daigrock","Enyu_is_Pro",
        "Magicbus","Bignews","STARcodeMUSE","Sub2Gamer456","Sub2UncleKizaru",
        "TheGreatAce","JCWK","CHANDLER","fudd10_v2","StrawHatMaine","Axiore"}
    for _,code in ipairs(codes) do RemoteInvoke("UseCode",code) task.wait(0.3) end
    ShowNotif("Codes","Đã redeem tất cả code!",4)
end)
AddSection("Settings","Chọn Team")
AddDropdown("Settings","Chọn Team",{"Pirates","Marines","None"},"None",function(v)
    RemoteInvoke("SetTeam",v)
end)
AddSection("Settings","Bring Mob Max")
AddSlider("Settings","Bring Mob Max Distance",20,1000,300," studs",function(v)
    ENV["NGP_BringMax"]=v
end)

-- ==================== DISCORD TAB ====================
AddSection("Discord","Webhook Notifications")
AddInput("Discord","Webhook URL: https://discord.com/api/webhooks/...",function(v) State.DiscordWebhook=v end)
AddButton("Discord","Test Webhook",function()
    SendWebhook("[NGP Hub] Test từ "..lp.Name)
    ShowNotif("Discord","Đã gửi test webhook",3)
end)
AddToggle("Discord","Notify khi Level Up",false,function(v)
    if v then
        lp:GetAttributeChangedSignal("Level"):Connect(function()
            SendWebhook("[NGP Hub] "..lp.Name.." vừa lên level!")
        end)
    end
end)
AddToggle("Discord","Notify khi Trái Rơi",false,function(v)
    if v then
        Workspace.DescendantAdded:Connect(function(obj)
            if obj.Name:find("Fruit") or obj.Name:find("Devil") then
                SendWebhook("[NGP Hub] Trái rơi: "..obj.Name.." | "..game.JobId)
            end
        end)
    end
end)


-- ============================================================
--              EXTENDED MODULES / SEPARATE CONTROLS
-- ============================================================

-- Discord notification configuration
AddSection("Discord","Account & Mention Settings")
AddInput("Discord","Discord User ID (optional)",function(v) State.WebhookUserId=v end)
AddDropdown("Discord","Ping Mode",{"None","User","Everyone","Here"},"None",function(v) State.PingMode=v end)
AddToggle("Discord","Account Profile Alert",false,function(v) State.NotifyAccount=v end)
AddToggle("Discord","Stored Fruit Alert",false,function(v) State.NotifyStoredFruit=v end)
AddDropdown("Discord","Fruit Rarity",{"All","Common","Uncommon","Rare","Legendary","Mythical"},"All",function(v) State.FruitRarity=v end)
AddToggle("Discord","Prehistoric Island Alert",false,function(v) State.NotifyPrehistoric=v end)
AddToggle("Discord","Frozen Dimension Alert",false,function(v) State.NotifyFrozen=v end)
AddToggle("Discord","Mirage Island Alert",false,function(v) State.NotifyMirage=v end)
AddToggle("Discord","Spy Ready Alert",false,function(v) State.NotifySpy=v end)
AddLabel("Discord","Webhook gửi thông báo; User ID và Ping Mode chỉ dùng khi bật mention.")

-- Server: distinct server metrics and explicit Job ID join
AddSection("Server","Server Metrics")
AddLabel("Server","Server Uptime: "..tostring(math.floor(Workspace.DistributedGameTime)).." seconds")
local initialPing="N/A"
pcall(function() initialPing=tostring(math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())).." ms" end)
AddLabel("Server","Ping hiện tại: "..initialPing)
AddButton("Server","Refresh Server Information",function()
    local ping="N/A"
    pcall(function() ping=tostring(math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())).." ms" end)
    ShowNotif("Server","PlaceId: "..game.PlaceId.." | Ping: "..ping,4)
end)
AddInput("Server","Job ID cần tham gia...",function(v) State.ServerJobInput=v end)
AddButton("Server","Teleport [Job ID]",function()
    if State.ServerJobInput and #State.ServerJobInput>5 then
        local ok,err=pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,State.ServerJobInput,lp) end)
        if not ok then ShowNotif("Server","Teleport lỗi: "..tostring(err),4) end
    else
        ShowNotif("Server","Job ID không hợp lệ",3)
    end
end)
AddLabel("Server","Lowest Ping Server: cần danh sách server công khai từ endpoint; không tự giả lập kết quả.")

-- Shop categories
AddSection("Shop","Melee / Fighting Style")
AddDropdown("Shop","Choose Fighting Style",{"Black Leg","Electro","Fishman Karate","Dragon Claw","Superhuman","Death Step","Sharkman Karate","Electric Claw","Dragon Talon","Godhuman"},"Black Leg",function(v) State.SelectedFightingStyle=v end)
AddButton("Shop","Auto Buy Fighting Style (selected)",function()
    ShowNotif("Shop","Đã chọn: "..State.SelectedFightingStyle..". Remote mua cần được xác minh theo game build.",4)
end)
AddSection("Shop","Sword Shop")
for _,item in ipairs({"Cutlass — 1,000 Beli","Katana — 1,000 Beli","Iron Mace — 25,000 Beli","Dual Katana — 12,000 Beli","Triple Katana — 60,000 Beli","Pipe — 100,000 Beli","Soul Cane — 750,000 Beli","Pole V2 — 5,000 Fragments"}) do
    AddLabel("Shop",item)
end
AddSection("Shop","Gun Shop")
for _,item in ipairs({"Slingshot","Musket","Flintlock","Refined Slingshot","Cannon","Kabucha","Bizarre Rifle"}) do AddLabel("Shop",item) end
AddDropdown("Shop","Choose Gun",{"Slingshot","Musket","Flintlock","Refined Slingshot","Cannon","Kabucha","Bizarre Rifle"},"Slingshot",function(v) State.SelectedGun=v end)
AddSection("Shop","Abilities")
for _,ability in ipairs({"Skyjump","Buso Haki","Observation Haki","Soru"}) do
    AddButton("Shop","Buy "..ability,function()
        local remoteMap={["Skyjump"]={"BuyHaki","Skyjump"},["Buso Haki"]={"BuyHaki","Buso"},["Observation Haki"]={"BuyHaki","Observation"},Soru={"BuyHaki","Soru"}}
        local r=remoteMap[ability]
        local ok=RemoteInvoke(r[1],r[2])
        ShowNotif("Shop",ok and ("Đã gửi yêu cầu: "..ability) or ("Không gọi được: "..ability),3)
    end)
end
AddSection("Shop","Misc Shop")
AddButton("Shop","Buy Refund Stat",function() RemoteInvoke("BlackbeardReward","Refund") end)
AddButton("Shop","Buy Reroll Race",function() RemoteInvoke("BlackbeardReward","Reroll") end)
AddButton("Shop","Buy Ghoul Race",function() RemoteInvoke("BuyRace","Ghoul") end)
AddButton("Shop","Buy Cyborg Race",function() RemoteInvoke("CyborgTrainer","Buy") end)

-- Halloween status and separate objective controls
AddSection("Halloween","Halloween Status")
AddLabel("Halloween","Event / Door / Idle status được đọc từ game state khi có object tương ứng.")
AddButton("Halloween","Refresh Halloween Status",function()
    local found=Workspace:FindFirstChild("Halloween",true) or Workspace:FindFirstChild("HalloweenEvent",true)
    ShowNotif("Halloween",found and "Đã tìm thấy object sự kiện." or "Chưa tìm thấy object sự kiện trong Workspace.",4)
end)
AddDropdown("Halloween","Oni Celestial Choice",{"Right","Left"},"Right",function(v) State.HalloweenCelestialChoice=v end)
AddToggle("Halloween","Auto Hellfire Gas",false,function(v) State.AutoHellfireGas=v end)
AddToggle("Halloween","Auto Unbound Werewolf",false,function(v) State.AutoUnboundWerewolf=v end)
AddToggle("Halloween","Auto Equip Coven Witch Hat",false,function(v)
    State.AutoEquipCovenHat=v
    if v then
        local tool=(char and char:FindFirstChild("Coven Witch Hat")) or lp.Backpack:FindFirstChild("Coven Witch Hat")
        if tool and hum then pcall(function() hum:EquipTool(tool) end) end
    end
end)
AddToggle("Halloween","Auto Candy Concoction",false,function(v) State.AutoCandyConcoction=v end)
AddLabel("Halloween","Summon Great Pumpkin requirements: 3 Cursed Pumpkin Seed + 200 Pumpkin (status check required).")

-- Dedicated secret quest page
AddSection("Level 3000","Secret Quest Seal")
AddLabel("Level 3000","Secret Quest Status: "..tostring(State.SecretQuestDone).."/39 (local counter)")
AddLabel("Level 3000","Current Quest / Upcoming Secret Quest: theo dõi chuỗi quest trong game.")
AddToggle("Level 3000","Auto Secret Quest",false,function(v)
    State.AutoSecretQuest=v
    if v then State.FarmMode="Farm Level Secret"; State.AutoFarm=true; StartFarmLoop() end
end)
AddToggle("Level 3000","Auto Hop Secret Hint",false,function(v)
    State.AutoHopSecret=v
    if v then
        task.spawn(function()
            while State.AutoHopSecret do
                local ok=pcall(function() TeleportService:Teleport(game.PlaceId,lp) end)
                if not ok then task.wait(10) end
                task.wait(30)
            end
        end)
    end
end)
AddButton("Level 3000","Refresh Secret Quest Status",function()
    ShowNotif("Secret Quest","Local progress: "..tostring(State.SecretQuestDone).."/39",4)
end)

-- Farm extensions
AddSection("Farm","Boss Farm")
local bossList={"Darkbeard","Rip_indra","Dough King","Cake Prince","Terrorshark","Elite Pirate","Stone","Island Empress","Kilo Admiral","Captain Elephant"}
AddDropdown("Farm","Choose Boss",bossList,"Darkbeard",function(v) State.SelectedBoss=v end)
AddLabel("Farm","Boss Status: ".."đang chờ kiểm tra mục tiêu trong Workspace.")
AddButton("Farm","Boss Farm (selected)",function()
    State.FarmTarget=State.SelectedBoss
    State.FarmMode="Farm Level"
    State.AutoFarm=true
    StartFarmLoop()
end)
AddSection("Farm","Materials / Mastery")
local materials={"Scrap Metal","Leather","Demonic Wisp","Vampire Fang","Mystic Droplet","Dragon Scale","Conjured Cocoa","Mini Tusk","Fish Tail","Gunpowder"}
AddDropdown("Farm","Choose Material",materials,"Scrap Metal",function(v) State.SelectedMaterial=v end)
AddToggle("Farm","Auto Materials",false,function(v) State.AutoMaterials=v end)
AddSlider("Farm","Farm Around Range",50,2000,500," studs",function(v) State.FarmAroundRange=v end)
AddToggle("Farm","Auto Farm Nearest",false,function(v) State.AutoFarmNearest=v end)
AddSlider("Farm","Choose Health Percent",5,95,35,"%",function(v) State.MasteryHealthPercent=v end)
AddToggle("Farm","Auto Mastery Fruit",false,function(v) State.AutoMasteryFruit=v end)
AddToggle("Farm","Auto Mastery Gun",false,function(v) State.AutoMasteryGun=v end)
AddToggle("Farm","Auto Mastery All Sword",false,function(v) State.AutoMasterySword=v end)
AddButton("Farm","Auto Buy Haki Recipes",function() RemoteInvoke("BuyHaki","Buso") end)
AddSection("Farm","Observation / Instinct")
AddLabel("Farm","Observation Information: hiển thị điểm né khi game cung cấp dữ liệu.")
AddToggle("Farm","Auto Farm Observation",false,function(v) State.AutoObservation=v end)
AddToggle("Farm","Auto Farm Observation Hop",false,function(v) State.AutoObservationHop=v end)
AddLabel("Farm","Chest Limit to Hop: "..tostring(State.ChestHopLimit))
AddSlider("Farm","Chest Limit to Hop",1,200,45," chests",function(v) State.ChestHopLimit=v end)
AddToggle("Farm","Auto Hop Server after Chest Limit",false,function(v) State.AutoChestHop=v end)

-- Skill hold duration in milliseconds, separate from cooldown/delay
AddSection("Skill","Hold Skill Duration (ms)")
for _,key in ipairs({"Z","X","C","V"}) do
    AddSlider("Skill","Hold Skill "..key.." (ms)",50,2000,250," ms",function(v) State.SkillHold[key]=v end)
end
AddLabel("Skill","Hold duration is separate from skill cooldown.")

-- Hop Farm distinct from Berry / chest hopping
AddSection("Hop Farm","Hop Farm Controller")
AddToggle("Hop Farm","Auto Open Menu Hop Farm",false,function(v)
    State.AutoOpenHopMenu=v
    if v then ShowNotif("Hop Farm","Auto-open preference saved.",3) end
end)
AddButton("Hop Farm","Open Menu Hop Farm",function()
    State.HopMenuOpen=true
    SelectTab("Hop Farm")
    ShowNotif("Hop Farm","Hop Farm menu is open.",3)
end)
AddLabel("Hop Farm","Crash / use new hop: trạng thái thông tin; không kích hoạt crash client.")
AddButton("Hop Farm","Hop to another public server",function()
    pcall(function() TeleportService:Teleport(game.PlaceId,lp) end)
end)

-- Stack farming: explicit independent actions
AddSection("Stack","Quest Farming")
AddButton("Stack","Auto Travel Dressrosa (Level 700)",function()
    local data=lp:FindFirstChild("Data")
    local level=data and data:FindFirstChild("Level")
    if level and level.Value>=700 then RemoteInvoke("TravelDressrosa")
    else ShowNotif("Stack","Không đọc được Level hoặc chưa đạt Level 700.",3) end
end)
AddButton("Stack","Auto Zou Quest (Level 1500)",function()
    local data=lp:FindFirstChild("Data")
    local level=data and data:FindFirstChild("Level")
    if level and level.Value>=1500 then RemoteInvoke("TravelZou")
    else ShowNotif("Stack","Không đọc được Level hoặc chưa đạt Level 1500.",3) end
end)
AddLabel("Stack","Elites Process: ".."theo dõi tiến độ Elite.")
AddButton("Stack","Auto Elite Quest",function() RemoteInvoke("EliteHunter") end)
AddButton("Stack","Auto Farm Elite Hunter",function()
    State.FarmTarget="Elite Pirate"; State.FarmMode="Farm Level"; State.AutoFarm=true; StartFarmLoop()
end)

-- PVP page: player selection / spectate / movement settings
AddSection("PVP","Players")
local function GetPlayerNames()
    local out={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=lp then table.insert(out,p.Name) end end
    table.sort(out)
    if #out==0 then out={"No other players"} end
    return out
end
AddDropdown("PVP","Choose Players",GetPlayerNames(),"No other players",function(v) State.SelectedPlayer=v end)
AddButton("PVP","Refresh Players",function()
    ShowNotif("PVP","Players online: "..tostring(#Players:GetPlayers()-1),3)
end)
AddButton("PVP","Teleport to Choose Players",function()
    local p=Players:FindFirstChild(State.SelectedPlayer)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then SafeTP(p.Character.HumanoidRootPart.Position+Vector3.new(0,4,0)) end
end)
AddButton("PVP","Spectate Choose Players",function()
    local p=Players:FindFirstChild(State.SelectedPlayer)
    if p and p.Character then
        local targetHum=p.Character:FindFirstChildOfClass("Humanoid")
        if targetHum then Workspace.CurrentCamera.CameraSubject=targetHum end
    end
end)
AddButton("PVP","Stop Spectating",function()
    if hum then Workspace.CurrentCamera.CameraSubject=hum end
end)
AddSection("PVP","Combat Settings")
AddToggle("PVP","Aimbot Skills",false,function(v) State.AimbotSkills=v end)
AddLabel("PVP","Aimbot Status: cấu hình lưu; target/aim implementation chưa được xác thực.")
AddSlider("PVP","Bán kính vòng aim PvP",20,600,150," px",function(v) State.AimRadius=v end)
AddSlider("PVP","Change Speed",1,100,16,"",function(v) State.ChangeSpeed=v; if hum then hum.WalkSpeed=v end end)
AddSlider("PVP","Jump Power",10,200,50,"",function(v) State.JumpPower=v; if hum then hum.UseJumpPower=true; hum.JumpPower=v end end)
AddButton("PVP","Restore Movement",function()
    if hum then hum.WalkSpeed=16; hum.UseJumpPower=true; hum.JumpPower=50 end
end)

-- ESP object types (mob highlighting remains in existing ESP loop)
AddSection("ESP","World ESP")
for _,name in ipairs({"ESP Chests","ESP Fruits","ESP Island Location","ESP Flower","ESP Legendary Sword","ESP Aura Colour Dealers"}) do
    AddToggle("ESP",name,false,function(v)
        State[name:gsub("[^%w]","")]=v
    end)
end
AddLabel("ESP","Các ESP object riêng cần resolver theo cấu trúc Workspace của từng bản game.")

-- Fruits / raid configuration
AddSection("Fruits","Fruit Inventory")
AddButton("Fruits","Check Fruit",function()
    local fruit="No fruit detected"
    pcall(function()
        for _,v in ipairs(lp.Backpack:GetChildren()) do if v.Name:lower():find("fruit") then fruit=v.Name break end end
    end)
    ShowNotif("Fruits",fruit,4)
end)
AddLabel("Fruits","Normal Stock / Mirage Stock: stock data phụ thuộc server game.")
AddDropdown("Fruits","Dungeon Selection",{"Normal","Hard","Extreme"},"Normal",function(v) State.SelectedDungeon=v end)
AddSlider("Fruits","Minimum Players",1,12,1,"",function(v) State.MinimumPlayers=v end)
AddToggle("Fruits","Account Start Dungeon",false,function(v) State.AccountStartsDungeon=v end)
AddDropdown("Fruits","Card Selection",{"Auto","Damage","Defense","Heal","Energy"},"Auto",function(v) State.SelectedCard=v end)
AddToggle("Fruits","Auto Collect Card",false,function(v) State.AutoCollectCard=v end)
AddLabel("Fruits","Raid Status: trạng thái sẽ hiển thị khi có raid object được nhận diện.")

-- Quest & item expansion
AddSection("Quest","Legendary Sword / True Triple Katana")
AddLabel("Quest","Legendary Sword Dealer status: kiểm tra NPC Dealer trong Workspace.")
AddButton("Quest","Refresh Legendary Sword Dealer",function()
    local dealer=Workspace:FindFirstChild("Legendary Sword Dealer",true)
    ShowNotif("Quest",dealer and "Dealer found." or "Dealer not found in current Workspace.",3)
end)
AddButton("Quest","Buy Legendary Sword",function() RemoteInvoke("BuyLegendarySword") end)
AddSection("Quest","Additional Items")
for _,item in ipairs({"Saddi","Shisui","Wando","Rengoku","Rengoku Key","Dark Blade V3","Midnight Blade","Dragon Trident","Longsword","Swan Glasses","True Triple Katana","Don Swan"}) do
    AddLabel("Quest",item)
end

-- Sea event extensions
AddSection("Sea","Boat Configuration")
AddDropdown("Sea","Choose Boat",{"Dinghy","Caravel","Galleon","Brig","Coffin Boat"},"Dinghy",function(v) State.SelectedBoat=v end)
AddDropdown("Sea","Boat Owner",{"Me","Friend","Any"},"Me",function(v) State.BoatOwner=v end)
AddButton("Sea","Buy Boat (selected)",function() RemoteInvoke("BuyBoat",State.SelectedBoat) end)
AddDropdown("Sea","Sea Level",{"Normal","Rough Sea","Danger Zone"},"Normal",function(v) State.SeaLevel=v end)
AddSlider("Sea","Boat Speed",1,300,50,"",function(v) State.BoatSpeed=v end)
AddToggle("Sea","Destroy Nearby Rocks",false,function(v) State.DestroyNearbyRocks=v end)
AddToggle("Sea","Sea Event With Friend",false,function(v) State.SeaEventWithFriend=v end)
AddButton("Sea","Refresh Sea Event Friends",function()
    local names={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=lp then table.insert(names,p.Name) end end
    ShowNotif("Sea Event","Friends/players visible: "..tostring(#names),3)
end)
AddLabel("Sea","Targets: Leviathan / Prehistoric Island / Frozen Dimension / Mirage Island / Sea Beast.")

-- Teleport world travel
AddSection("Teleport","Travel — Worlds")
AddButton("Teleport","Travel East Blue (World 1)",function() RemoteInvoke("TravelMain") end)
AddButton("Teleport","Travel Dressrosa (World 2)",function() RemoteInvoke("TravelDressrosa") end)
AddButton("Teleport","Travel Zou (World 3)",function() RemoteInvoke("TravelZou") end)

-- Race upgrades
AddSection("Race","Race V2 / V3")
AddButton("Race","Race V2",function() RemoteInvoke("UpgradeRace","2") end)
AddButton("Race","Race V3",function() RemoteInvoke("UpgradeRace","3") end)

-- Settings refinements
AddSection("Settings","Movement / Mob Controls")
AddSlider("Settings","Tween Speed",1,350,50,"",function(v) State.TweenSpeed=v end)
AddDropdown("Settings","Bring Mob Mode",{"All","Current Target","Boss Only"},"All",function(v) State.BringMobMode=v end)
AddSlider("Settings","Bring Mob Max",1,100,20,"",function(v) State.BringMobMax=v end)
AddButton("Settings","Redeem All Codes (retry)",function()
    local codes={"SUB2GAMERROBOT_EXP1","SUB2GAMERROBOT_RESET1","KITT_RESET","Sub2Fer999","Sub2OfficialNoobie","TheGreatAce","Fudd10"}
    for _,code in ipairs(codes) do RemoteInvoke("Redeem",code); task.wait(0.25) end
end)


-- default tab
SelectTab("Farm")

-- ===================== BUBBLE BUTTON =====================
local BubbleSize=UDim2.new(0,58,0,58)

local Bubble=NewFrame("Bubble",BubbleSize,UDim2.new(0,20,1,-80),CLR.BUBBLE,ScreenGui)
Bubble.AnchorPoint=Vector2.new(0,1)
MakeCorner(29,Bubble)
MakeStroke(2,CLR.BUBBLEIN,Bubble)

-- glow effect
local BubbleGlow=NewFrame("Glow",UDim2.new(1,16,1,16),UDim2.new(0,-8,0,-8),CLR.ACCENT,Bubble)
BubbleGlow.BackgroundTransparency=0.75
MakeCorner(37,BubbleGlow)
BubbleGlow.ZIndex=0

-- inner icon
local BubbleInner=NewFrame("Inner",UDim2.new(0,42,0,42),UDim2.new(0.5,-21,0.5,-21),CLR.ACCENT,Bubble)
MakeCorner(21,BubbleInner)
local BubbleLabel=NewLabel("NGP",UDim2.new(1,0,0.6,0),UDim2.new(0,0,0.1,0),Color3.fromRGB(255,255,255),11,BubbleInner)
BubbleLabel.TextXAlignment=Enum.TextXAlignment.Center
BubbleLabel.Font=Enum.Font.GothamBold
local BubbleIcon=NewLabel("🎮",UDim2.new(1,0,0.5,0),UDim2.new(0,0,-0.1,0),Color3.fromRGB(255,255,255),18,BubbleInner)
BubbleIcon.TextXAlignment=Enum.TextXAlignment.Center

-- pulse animation
task.spawn(function()
    while true do
        TweenService:Create(BubbleGlow,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
            {BackgroundTransparency=0.5}):Play()
        task.wait(1)
        TweenService:Create(BubbleGlow,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
            {BackgroundTransparency=0.85}):Play()
        task.wait(1)
    end
end)

-- bubble drag
local bDragging,bDragOffset,bDragStart=false,Vector2.new(),Vector2.new()
local DRAG_THRESHOLD=6
local clickFired=false

Bubble.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        bDragging=true clickFired=false
        bDragStart=Vector2.new(inp.Position.X,inp.Position.Y)
        bDragOffset=Vector2.new(inp.Position.X-Bubble.AbsolutePosition.X,inp.Position.Y-Bubble.AbsolutePosition.Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        if bDragging then
            local dist=(Vector2.new(inp.Position.X,inp.Position.Y)-bDragStart).Magnitude
            if dist<DRAG_THRESHOLD and not clickFired then
                -- toggle panel
                if PanelOpen then
                    TweenService:Create(Panel,TweenInfo.new(0.2,Enum.EasingStyle.Back),
                        {Size=UDim2.new(0,0,0,0),Position=UDim2.new(Panel.Position.X.Scale,Panel.Position.X.Offset+260,Panel.Position.Y.Scale,Panel.Position.Y.Offset+220)}):Play()
                    task.delay(0.2,function() Panel.Visible=false PanelOpen=false end)
                else
                    Panel.Visible=true
                    Panel.Size=UDim2.new(0,0,0,0)
                    local bAbs=Bubble.AbsolutePosition
                    Panel.Position=UDim2.new(0,bAbs.X-260,0,bAbs.Y-220)
                    TweenService:Create(Panel,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
                        {Size=UDim2.new(0,520,0,440)}):Play()
                    PanelOpen=true
                end
                clickFired=true
            end
        end
        bDragging=false
    end
end)
UIS.InputChanged:Connect(function(inp)
    if bDragging and(inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
        local dist=(Vector2.new(inp.Position.X,inp.Position.Y)-bDragStart).Magnitude
        if dist>DRAG_THRESHOLD then
            local vp=Workspace.CurrentCamera.ViewportSize
            local nx=math.clamp(inp.Position.X-bDragOffset.X,0,vp.X-58)
            local ny=math.clamp(inp.Position.Y-bDragOffset.Y,0,vp.Y-58)
            Bubble.Position=UDim2.new(0,nx,0,ny)
        end
    end
end)

-- ===================== BOOT NOTIFY =====================
task.delay(1,function()
    ShowNotif("Nguyen Gia Phuc Hub v3","Load thành công! Nhấn bubble 🎮 để mở",5)
end)
