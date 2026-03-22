local ok, err = xpcall(function()
-- DBSB.SU Violence District
-- RightAlt to open/close

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local cfg = {
    ESP_Survivors=false, ESP_Killer=false, ESP_Names=false,
    ESP_Distance=false, ESP_Health=false, ESP_Skeleton=false,
    ESP_Offscreen=false, ESP_Velocity=false, ESP_Chams=false, ESP_MaxDist=500,
    ESP_Generator=false, ESP_Hook=false, ESP_Gate=false,
    ESP_Pallet=false, ESP_Window=false, ESP_ClosestHook=false,
    RADAR=false, RADAR_Size=120, RADAR_Circle=false,
    AutoSkillCheck=false, AutoWiggle=false, AutoParry=false,
    NoFall=false, TeleAway=false, TeleAwayDist=40,
    BeatSurvivor=false, AutoGen=false,
    AutoAttack=false, AutoAttackRange=12,
    DoubleTap=false, InfiniteLunge=false,
    AutoHook=false, FullGenBreak=false,
    DestroyPallets=false, NoPalletStun=false,
    AntiBlind=false, NoSlowdown=false,
    HitboxEnabled=false, HitboxSize=15, BeatKiller=false,
    SpeedEnabled=false, SpeedValue=32,
    NoclipEnabled=false, FlyEnabled=false, FlySpeed=50,
    InfiniteJump=false, JumpPower=50,
    FlingEnabled=false, FlingStrength=10000,
    NO_Fog=false, FovEnabled=false, FovValue=90,
    ColSurvChams=Color3.fromRGB(65,220,130),
    ColKillChams=Color3.fromRGB(255,65,65),
    ColSurvName=Color3.fromRGB(65,220,130),
    ColKillName=Color3.fromRGB(255,65,65),
    ColSurvSkel=Color3.fromRGB(65,220,130),
    ColKillSkel=Color3.fromRGB(255,65,65),
    ColTracer=Color3.fromRGB(255,65,65),
    ColInfo=Color3.fromRGB(180,180,180),
    ThirdPerson=false, ShiftLock=false,
    FOVValue=113, LungeAtk=20, MB1Atk=-1,
    FastVault=false,
}

local State = {
    OrigSpeed=16, OrigFOV=nil, FlyBV=nil, FlyBG=nil,
    LastTeleAway=0, KillerTarget=nil, LastFogState=false,
    LastAutoHook=0, AutoHookPhase=0, AutoHookTime=0,
    BeatSurvivorDone=false,
}

local Cache = {Generators={},Gates={},Hooks={},Pallets={},Windows={},Visibility={},ClosestHook=nil}
local espObjects = {}
local chams = {}
local objHL = {}
local objBB = {}
local skillConn = nil
local autoGenActive = false
local velData = {}
local fogCache = {}
local binds = {}

local function isKiller(p)
    if not p or not p.Team then return false end
    if p.Team.Name=="Killer" then return true end
    if p.Team.Name=="Survivors" then return false end
    local c=p.Character
    if c then
        if c:GetAttribute("TerrorRadius")~=nil then return true end
        if c:GetAttribute("vaultspeed")~=nil then return false end
    end
    return false
end
local function isSurv(p) return p and p.Team and p.Team.Name=="Survivors" end
local function getRole() if not lp.Team then return "Lobby" end if lp.Team.Name=="Killer" then return "Killer" end if lp.Team.Name=="Survivors" then return "Survivor" end return "Lobby" end
local function getRoot() local c=lp.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function getDist(pos) local r=getRoot() return r and (pos-r.Position).Magnitude or math.huge end
local function isVis(char)
    if not char then return false end
    local o=cam.CFrame.Position
    local p=RaycastParams.new() p.FilterType=Enum.RaycastFilterType.Blacklist p.FilterDescendantsInstances={cam,lp.Character,char}
    for _,n in ipairs({"Head","UpperTorso","Torso","HumanoidRootPart"}) do
        local pt=char:FindFirstChild(n)
        if pt and not workspace:Raycast(o,pt.Position-o,p) then return true end
    end
    return false
end

local function scanMap()
    local map=workspace:FindFirstChild("Map") if not map then return end
    local g,ga,h,pa,w={},{},{},{},{}
    local seen = {}
    for _,obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Model") and not seen[obj] then
            local p=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if p then
                local n = obj.Name
                local nl = n:lower()
                seen[obj] = true
                if n=="Generator" then table.insert(g,{model=obj,part=p})
                elseif n=="Gate" then table.insert(ga,{model=obj,part=p})
                elseif n=="Hook" then table.insert(h,{model=obj,part=p})
                elseif nl:find("pallet") or nl:find("plank") or nl:find("board") then
                    table.insert(pa,{model=obj,part=p})
                elseif n=="Window" or nl:find("window") or nl:find("vault") then
                    table.insert(w,{model=obj,part=p})
                end
            end
        end
    end
    Cache.Generators=g Cache.Gates=ga Cache.Hooks=h Cache.Pallets=pa Cache.Windows=w
    local root=getRoot()
    if root and #h>0 then
        local cl,cd=nil,math.huge
        for _,hk in ipairs(h) do
            if hk.part then
                local occupied=false
                for _,plr in ipairs(Players:GetPlayers()) do
                    if plr.Character then
                        local pr=plr.Character:FindFirstChild("HumanoidRootPart")
                        local hp=plr.Character:GetAttribute("HookedProgress")
                        if pr and hp and hp<100 then
                            if (pr.Position-hk.part.Position).Magnitude<8 then occupied=true break end
                        end
                    end
                end
                if not occupied then
                    local d=(hk.part.Position-root.Position).Magnitude
                    if d<cd then cd=d cl=hk end
                end
            end
        end
        Cache.ClosestHook=cl
    end
end

local R6={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local R15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"}}
local Cols={Killer=Color3.fromRGB(255,65,65),Surv=Color3.fromRGB(65,220,130),Gen=Color3.fromRGB(255,180,50),Gate=Color3.fromRGB(200,200,220),Hook=Color3.fromRGB(255,100,100),HookClose=Color3.fromRGB(255,230,80),Pallet=Color3.fromRGB(220,180,100),Win=Color3.fromRGB(100,180,255)}

local function nL() local l=Drawing.new("Line") l.Visible=false l.Thickness=1.5 return l end
local function nT(s) local t=Drawing.new("Text") t.Visible=false t.Size=s or 13 t.Center=true t.Outline=true t.OutlineColor=Color3.new(0,0,0) t.Font=Drawing.Fonts.UI return t end
local function nS() local s=Drawing.new("Square") s.Visible=false s.Filled=false s.Thickness=1.5 return s end
local function nTri() local t=Drawing.new("Triangle") t.Visible=false t.Filled=true return t end

local function mkESP(plr)
    if espObjects[plr] then return end
    espObjects[plr]={box=nS(),boxOut=nS(),name=nT(13),info=nT(11),tracer=nL(),off=nTri(),vel=nL(),skel={}}
    espObjects[plr].boxOut.Thickness=3 espObjects[plr].boxOut.Color=Color3.new(0,0,0)
    espObjects[plr].vel.Color=Color3.fromRGB(0,255,255) espObjects[plr].vel.Thickness=2
end

local function rmESP(plr)
    local o=espObjects[plr] if not o then return end
    o.box:Remove() o.boxOut:Remove() o.name:Remove() o.info:Remove() o.tracer:Remove() o.off:Remove() o.vel:Remove()
    for _,l in pairs(o.skel) do l:Remove() end
    espObjects[plr]=nil
    if chams[plr] then pcall(function() chams[plr]:Destroy() end) chams[plr]=nil end
end

local function hideESP(o)
    o.box.Visible=false o.boxOut.Visible=false o.name.Visible=false
    o.info.Visible=false o.tracer.Visible=false o.off.Visible=false o.vel.Visible=false
    for _,l in pairs(o.skel) do l.Visible=false end
end

local function clearObjESP()
    for _,h in pairs(objHL) do pcall(function() h:Destroy() end) end
    for _,b in pairs(objBB) do pcall(function() b:Destroy() end) end
    objHL={} objBB={}
end

local function addObj(obj,lbl,col)
    local base=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") if not base then return end
    local h=Instance.new("Highlight") h.FillColor=col h.OutlineColor=col h.FillTransparency=0.6 h.OutlineTransparency=0 h.Adornee=obj h.Parent=workspace
    table.insert(objHL,h)
    local bb=Instance.new("BillboardGui") bb.Size=UDim2.new(0,140,0,26) bb.StudsOffset=Vector3.new(0,4,0) bb.AlwaysOnTop=true bb.Adornee=base bb.Parent=workspace
    table.insert(objBB,bb)
    local tl=Instance.new("TextLabel",bb) tl.Size=UDim2.new(1,0,1,0) tl.BackgroundTransparency=1 tl.Text=lbl tl.TextColor3=col tl.TextStrokeTransparency=0 tl.TextStrokeColor3=Color3.new(0,0,0) tl.Font=Enum.Font.GothamBold tl.TextSize=13
end

local function updateObjESP()
    clearObjESP()
    if cfg.ESP_Generator then for _,o in ipairs(Cache.Generators) do if o.model and o.model.Parent then local p=o.model:GetAttribute("RepairProgress") addObj(o.model,p and string.format("Gen %d%%",p) or "Gen",Cols.Gen) end end end
    if cfg.ESP_Gate then for _,o in ipairs(Cache.Gates) do if o.model and o.model.Parent then addObj(o.model,"Gate",Cols.Gate) end end end
    if cfg.ESP_Hook then for _,o in ipairs(Cache.Hooks) do if o.model and o.model.Parent then local cl=cfg.ESP_ClosestHook and o==Cache.ClosestHook addObj(o.model,cl and "HOOK!" or "Hook",cl and Cols.HookClose or Cols.Hook) end end end
    if cfg.ESP_Pallet then
        for _,o in ipairs(Cache.Pallets) do if o.model and o.model.Parent then addObj(o.model,"Pallet",Cols.Pallet) end end
        -- Also scan directly in case cache missed some
        local map2=workspace:FindFirstChild("Map")
        if map2 then for _,obj in ipairs(map2:GetDescendants()) do
            if obj:IsA("Model") then local nl=obj.Name:lower()
                if nl:find("pallet") or nl:find("plank") then addObj(obj,"Pallet",Cols.Pallet) end
            end
        end end
    end
    if cfg.ESP_Window then
        for _,o in ipairs(Cache.Windows) do if o.model and o.model.Parent then addObj(o.model,"Window",Cols.Win) end end
        local map2=workspace:FindFirstChild("Map")
        if map2 then for _,obj in ipairs(map2:GetDescendants()) do
            if obj:IsA("Model") then local nl=obj.Name:lower()
                if nl:find("window") or nl:find("vault") then addObj(obj,"Window",Cols.Win) end
            end
        end end
    end
end

local lastScan=0 local lastVis=0
RunService.RenderStepped:Connect(function()
    local now=tick()
    if now-lastScan>1 then lastScan=now scanMap() end
    if now-lastVis>0.15 then lastVis=now
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then Cache.Visibility[p]=isVis(p.Character) end end
    end
    local vp=cam.ViewportSize local vc=Vector2.new(vp.X/2,vp.Y/2)
    for plr,o in pairs(espObjects) do
        if plr==lp then hideESP(o) continue end
        local killer=isKiller(plr)
        local show=killer and cfg.ESP_Killer or (not killer and cfg.ESP_Survivors)
        if not show then hideESP(o) if chams[plr] then pcall(function() chams[plr]:Destroy() end) chams[plr]=nil end continue end
        local char=plr.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hrp then hideESP(o) continue end
        local dist=(hrp.Position-cam.CFrame.Position).Magnitude
        if dist>cfg.ESP_MaxDist then hideESP(o) continue end
        local sp,onSc=cam:WorldToViewportPoint(hrp.Position)
        local vis=Cache.Visibility[plr]
        local baseCol=killer and cfg.ColKillChams or cfg.ColSurvChams
        if cfg.ESP_Chams then
            hideESP(o)
            if not chams[plr] then local h=Instance.new("Highlight") h.FillColor=killer and cfg.ColKillChams or cfg.ColSurvChams h.OutlineColor=killer and cfg.ColKillChams or cfg.ColSurvChams h.FillTransparency=0.6 h.OutlineTransparency=0 h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop h.Adornee=char h.Parent=char chams[plr]=h end
            continue
        else if chams[plr] then pcall(function() chams[plr]:Destroy() end) chams[plr]=nil end end
        if not onSc then
            hideESP(o)
            if cfg.ESP_Offscreen and vis then
                local dx,dy=sp.X-vc.X,sp.Y-vc.Y local ang=math.atan2(dy,dx) local e=50
                local ax=math.clamp(vc.X+math.cos(ang)*(vp.X/2-e),e,vp.X-e)
                local ay=math.clamp(vc.Y+math.sin(ang)*(vp.Y/2-e),e,vp.Y-e)
                local f=Vector2.new(math.cos(ang),math.sin(ang)) local r=Vector2.new(-f.Y,f.X) local p=Vector2.new(ax,ay) local sz=12
                o.off.PointA=p+f*sz o.off.PointB=p-f*sz/2-r*sz/2 o.off.PointC=p-f*sz/2+r*sz/2 o.off.Color=baseCol o.off.Visible=true
            end
            continue
        end
        o.off.Visible=false
        local ns=plr.Name local nc=baseCol local is=""
        if killer then
            local ic=char:GetAttribute("IsChasing") or false local icar=char:GetAttribute("IsCarrying") or false
            if icar then ns="[K] "..plr.Name.." [CARRYING]" nc=Color3.fromRGB(255,0,0)
            elseif ic then ns="[K] "..plr.Name.." [CHASING]" nc=Color3.fromRGB(255,100,0)
            else ns="[K] "..plr.Name nc=cfg.ColKillName end
            is=string.format("%.1fspd TR:%d BL:%d",char:GetAttribute("Speed") or 0,char:GetAttribute("TerrorRadius") or 0,char:GetAttribute("BloodLust") or 0)
        else
            local hc=char:GetAttribute("HookCount") or 0 local kn=char:GetAttribute("Knocked") or false
            local rep=char:GetAttribute("repairing") or 0 local ic2=char:GetAttribute("IsChased") or false
            nc=cfg.ColSurvName
            if kn then ns="[!] "..plr.Name.." [DOWN]" nc=Color3.fromRGB(255,100,0)
            elseif hc>=2 then ns="[X] "..plr.Name.." [DYING]" nc=Color3.fromRGB(255,0,0)
            elseif hc==1 then ns=plr.Name.." [1/2]" nc=Color3.fromRGB(255,180,0) end
            is=math.floor(dist).."m" if rep>0 then is=is.." [GEN]" end if ic2 then is=is.." [CHASED]" end
        end
        local head=char:FindFirstChild("Head")
        if head then
            local top,tOn=cam:WorldToViewportPoint(head.Position+Vector3.new(0,1,0))
            local bot,bOn=cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
            o.box.Visible=false o.boxOut.Visible=false
            if tOn then
                local bh=bot.Y-top.Y local cx=top.X
                if cfg.ESP_Names then o.name.Text=ns o.name.Color=nc o.name.Position=Vector2.new(cx,top.Y-6) o.name.Visible=true else o.name.Visible=false end
                if cfg.ESP_Distance or killer then o.info.Text=is o.info.Color=Color3.fromRGB(180,180,180) o.info.Position=Vector2.new(cx,top.Y+10) o.info.Visible=true else o.info.Visible=false end
            else o.name.Visible=false o.info.Visible=false end
        end
        if killer then o.tracer.From=Vector2.new(vp.X/2,vp.Y) o.tracer.To=Vector2.new(sp.X,sp.Y) o.tracer.Color=cfg.ColTracer o.tracer.Visible=true else o.tracer.Visible=false end
        if cfg.ESP_Skeleton then
            local bones=(hum and hum.RigType==Enum.HumanoidRigType.R6) and R6 or R15
            for i,conn in ipairs(bones) do
                local pA=char:FindFirstChild(conn[1]) local pB=char:FindFirstChild(conn[2])
                if not o.skel[i] then o.skel[i]=nL() end
                local ln=o.skel[i]
                if pA and pB then
                    local a,aOn=cam:WorldToViewportPoint(pA.Position) local b,bOn=cam:WorldToViewportPoint(pB.Position)
                    if aOn and bOn then ln.From=Vector2.new(a.X,a.Y) ln.To=Vector2.new(b.X,b.Y) ln.Color=killer and cfg.ColKillSkel or cfg.ColSurvSkel ln.Visible=true else ln.Visible=false end
                else ln.Visible=false end
            end
            for i=#((hum and hum.RigType==Enum.HumanoidRigType.R6) and R6 or R15)+1,#o.skel do o.skel[i].Visible=false end
        else for _,l in pairs(o.skel) do l.Visible=false end end
        if cfg.ESP_Velocity then
            local vd=velData[plr] if not vd then vd={pos=hrp.Position,vel=Vector3.zero,t=now} velData[plr]=vd end
            local dt=now-vd.t if dt>0.03 then local rv=(hrp.Position-vd.pos)/dt vd.vel=vd.vel*0.7+rv*0.3 vd.pos=hrp.Position vd.t=now end
            local fl=Vector3.new(vd.vel.X,0,vd.vel.Z)
            if fl.Magnitude>2 then
                local fut=hrp.Position+fl.Unit*math.clamp(fl.Magnitude*0.4,5,20)
                local fs,fOn=cam:WorldToViewportPoint(fut)
                if fOn then o.vel.From=Vector2.new(sp.X,sp.Y) o.vel.To=Vector2.new(fs.X,fs.Y) o.vel.Visible=true else o.vel.Visible=false end
            else o.vel.Visible=false end
        else o.vel.Visible=false end
    end
end)

local rdots={} local robj={}
for i=1,50 do rdots[i]=nTri() robj[i]=Drawing.new("Circle") robj[i].Filled=true robj[i].NumSides=16 robj[i].Visible=false end
local rbg=Drawing.new("Square") rbg.Filled=true rbg.Color=Color3.fromRGB(20,20,20)
local rborder=Drawing.new("Square") rborder.Filled=false rborder.Color=Cols.Killer rborder.Thickness=2
local rcenter=nTri() rcenter.Color=Color3.fromRGB(0,255,0)
RunService.RenderStepped:Connect(function()
    if not cfg.RADAR then rbg.Visible=false rborder.Visible=false rcenter.Visible=false for _,d in ipairs(rdots) do d.Visible=false end for _,d in ipairs(robj) do d.Visible=false end return end
    local vp=cam.ViewportSize local sz=cfg.RADAR_Size
    local pos=Vector2.new(vp.X-sz-20,20) local ctr=pos+Vector2.new(sz/2,sz/2)
    rbg.Position=pos rbg.Size=Vector2.new(sz,sz) rbg.Visible=true
    rborder.Position=pos rborder.Size=Vector2.new(sz,sz) rborder.Visible=true
    local myRoot=getRoot() if not myRoot then return end
    local ml=cam.CFrame.LookVector local ma=math.atan2(-ml.X,-ml.Z)
    local ca,sa=math.cos(ma),math.sin(ma) local sc=(sz/2-10)/150
    local idx=1 local oi=1
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and idx<=#rdots then
            local r=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local rx,rz=r.Position.X-myRoot.Position.X,r.Position.Z-myRoot.Position.Z
                local rx2=rx*ca-rz*sa local ry2=rx*sa+rz*ca
                local mx=sz/2-8 local rd=math.sqrt(rx2^2+ry2^2)
                if rd<mx then
                    local dp=ctr+Vector2.new(rx2*sc,ry2*sc)
                    rdots[idx].PointA=dp+Vector2.new(0,-5) rdots[idx].PointB=dp+Vector2.new(-3,3) rdots[idx].PointC=dp+Vector2.new(3,3)
                    rdots[idx].Color=isKiller(plr) and Cols.Killer or Cols.Surv rdots[idx].Visible=true idx=idx+1
                end
            end
        end
    end
    for _,gen in ipairs(Cache.Generators) do
        if oi<=#robj and gen.part then
            local rx,rz=gen.part.Position.X-myRoot.Position.X,gen.part.Position.Z-myRoot.Position.Z
            local rx2=rx*ca-rz*sa local ry2=rx*sa+rz*ca
            local rd=math.sqrt((rx2*sc)^2+(ry2*sc)^2)
            if rd<sz/2-8 then robj[oi].Position=ctr+Vector2.new(rx2*sc,ry2*sc) robj[oi].Radius=3 robj[oi].Color=Cols.Gen robj[oi].Visible=true oi=oi+1 end
        end
    end
    for i=idx,#rdots do rdots[i].Visible=false end for i=oi,#robj do robj[i].Visible=false end
    rcenter.PointA=ctr+Vector2.new(0,-6) rcenter.PointB=ctr+Vector2.new(-4,4) rcenter.PointC=ctr+Vector2.new(4,4) rcenter.Visible=true
end)

RunService.Stepped:Connect(function()
    if cfg.NoclipEnabled and lp.Character then
        for _,p in pairs(lp.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end
end)

local function applySpeed()
    local char=lp.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
    if State.OrigSpeed==16 and hum.WalkSpeed~=cfg.SpeedValue then State.OrigSpeed=hum.WalkSpeed end
    if cfg.SpeedEnabled then hum.WalkSpeed=cfg.SpeedValue else hum.WalkSpeed=State.OrigSpeed end
end

local function updateFly()
    local char=lp.Character if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart") local hum=char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if cfg.FlyEnabled then
        hum.PlatformStand=true
        if not State.FlyBV then State.FlyBV=Instance.new("BodyVelocity") State.FlyBV.MaxForce=Vector3.new(math.huge,math.huge,math.huge) State.FlyBV.Velocity=Vector3.zero State.FlyBV.Parent=root end
        if not State.FlyBG then State.FlyBG=Instance.new("BodyGyro") State.FlyBG.MaxTorque=Vector3.new(math.huge,math.huge,math.huge) State.FlyBG.P=9e4 State.FlyBG.Parent=root end
        local move=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move=move+cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move=move-cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move=move-cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move=move+cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move=move-Vector3.new(0,1,0) end
        if move.Magnitude>0 then move=move.Unit*cfg.FlySpeed end
        State.FlyBV.Velocity=move State.FlyBG.CFrame=cam.CFrame
    else
        if State.FlyBV then State.FlyBV:Destroy() State.FlyBV=nil end
        if State.FlyBG then State.FlyBG:Destroy() State.FlyBG=nil end
        if hum then hum.PlatformStand=false end
    end
end

UIS.JumpRequest:Connect(function()
    if cfg.InfiniteJump then
        local c=lp.Character if not c then return end
        local h=c:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local function tpSafe(pos)
    local root=getRoot() if not root then return end
    local char=lp.Character
    if char then for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    root.CFrame=CFrame.new(pos+Vector3.new(0,3,0))
    task.delay(0.3,function()
        if lp.Character then for _,p in pairs(lp.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.CanCollide=true end end end
    end)
end

local function instantEscape()
    local map=workspace:FindFirstChild("Map") if not map then return end
    local root=getRoot() if not root then return end
    local nearest,d2=nil,math.huge
    for _,gate in ipairs(map:GetChildren()) do
        if gate.Name=="Gate" then
            local lever=gate:FindFirstChild("ExitLever")
            if lever then
                local tp=lever:FindFirstChild("Tp") or lever:FindFirstChildWhichIsA("BasePart")
                if tp then local d=(tp.Position-root.Position).Magnitude if d<d2 then nearest=tp d2=d end end
            end
        end
    end
    if nearest then tpSafe(nearest.Position) end
end

local function tpToPlayer(findKiller)
    local root=getRoot() if not root then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and isKiller(plr)==findKiller then
            local c=plr.Character local h=c and c:FindFirstChild("HumanoidRootPart")
            if h then tpSafe(h.Position) return end
        end
    end
end

local function tpToGen()
    if #Cache.Generators==0 then return end
    local root=getRoot() if not root then return end
    local nearest,d2=nil,math.huge
    for _,gen in ipairs(Cache.Generators) do
        if gen.part then local d=(gen.part.Position-root.Position).Magnitude if d<d2 then nearest=gen.part d2=d end end
    end
    if nearest then tpSafe(nearest.Position) end
end

local function instantGen()
    local root=getRoot() if not root then return end
    local nearest,d2=nil,math.huge
    for _,gen in ipairs(Cache.Generators) do
        if gen.model then
            local base=gen.part or gen.model:FindFirstChildWhichIsA("BasePart")
            if base then local d=(base.Position-root.Position).Magnitude if d<d2 then nearest=gen.model d2=d end end
        end
    end
    if nearest then
        for _,child in ipairs(nearest:GetChildren()) do
            if child.Name:find("GeneratorPoint") then
                pcall(function() RS.Remotes.Generator.RepairEvent:FireServer(child,true) end)
                pcall(function() RS.Remotes.Generator.SkillCheckResultEvent:FireServer("success",1,nearest,child) end)
            end
        end
        pcall(function() RS.Remotes.Generator.RepairEvent:FireServer(nearest) end)
        pcall(function() nearest:SetAttribute("RepairProgress",100) end)
    end
end

local function unhookNearest()
    local root=getRoot() if not root then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local c=plr.Character if c then
                local hp=c:GetAttribute("HookedProgress")
                if hp and hp<100 then
                    local pHrp=c:FindFirstChild("HumanoidRootPart")
                    if pHrp then
                        tpSafe(pHrp.Position) task.wait(0.2)
                        pcall(function() RS.Remotes.Carry.UnhookEvent:FireServer(plr) end)
                        pcall(function() RS.Remotes.Carry.HookEvent:FireServer(plr,false) end)
                        return
                    end
                end
            end
        end
    end
end

local function unhookSelf()
    pcall(function() RS.Remotes.Carry.SelfUnHookEvent:FireServer() end)
    pcall(function() RS.Remotes.Carry.UnhookEvent:FireServer(lp) end)
end

local function destroyPallets()
    pcall(function()
        local p=RS.Remotes.Pallet
        if p then for _,kf in ipairs(p:GetChildren()) do local dg=kf:FindFirstChild("Destroy-Global") if dg then dg:FireServer() end end end
    end)
end

local function fullGenBreak()
    local root=getRoot() if not root then return end
    pcall(function()
        local be=RS.Remotes.Generator.BreakGenEvent
        for _,gen in ipairs(Cache.Generators) do
            if gen.part and (gen.part.Position-root.Position).Magnitude<=20 then be:FireServer(gen.model) end
        end
    end)
end

local function flingNearest()
    local root=getRoot() if not root then return end
    local cl,cd=nil,math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local r=plr.Character:FindFirstChild("HumanoidRootPart")
            if r then local d=(r.Position-root.Position).Magnitude if d<cd then cd=d cl=r end end
        end
    end
    if cl then
        local orig=root.CFrame
        for i=1,10 do root.CFrame=cl.CFrame root.Velocity=Vector3.new(cfg.FlingStrength,cfg.FlingStrength/2,cfg.FlingStrength) root.RotVelocity=Vector3.new(9999,9999,9999) task.wait() end
        root.CFrame=orig root.Velocity=Vector3.zero root.RotVelocity=Vector3.zero
    end
end

local function startAutoGen()
    if autoGenActive then return end
    autoGenActive=true
    task.spawn(function()
        local re,se
        pcall(function() re=RS.Remotes.Generator.RepairEvent se=RS.Remotes.Generator.SkillCheckResultEvent end)
        while autoGenActive do
            for _,gen in ipairs(Cache.Generators) do
                if not autoGenActive then break end
                if gen.model and (gen.model:GetAttribute("RepairProgress") or 0)<100 then
                    for _,child in ipairs(gen.model:GetChildren()) do
                        if child.Name:find("GeneratorPoint") then
                            pcall(function() re:FireServer(child,true) end)
                            pcall(function() se:FireServer("success",1,gen.model,child) end)
                        end
                    end
                    pcall(function() re:FireServer(gen.model) end)
                end
            end
            task.wait(0.15)
        end
    end)
end

local function setupSkillCheck()
    local pg=lp:FindFirstChild("PlayerGui") if not pg then return end
    local function tryConn()
        local cg=pg:FindFirstChild("SkillCheckPromptGui") if not cg then return end
        local check=cg:FindFirstChild("Check") if not check then return end
        local line=check:FindFirstChild("Line") local goal=check:FindFirstChild("Goal")
        if not line or not goal then return end
        local function inGoal()
            local lr=line.Rotation%360 local gr=goal.Rotation%360
            local gs=(gr+104)%360 local ge=(gr+114)%360
            if gs>ge then return lr>=gs or lr<=ge else return lr>=gs and lr<=ge end
        end
        local function press() VIM:SendKeyEvent(true,Enum.KeyCode.Space,false,game) task.wait(0.01) VIM:SendKeyEvent(false,Enum.KeyCode.Space,false,game) end
        check:GetPropertyChangedSignal("Visible"):Connect(function()
            if not cfg.AutoSkillCheck then return end
            if lp.Team and lp.Team.Name~="Survivors" then return end
            if check.Visible then
                if skillConn then skillConn:Disconnect() end
                skillConn=RunService.Heartbeat:Connect(function()
                    if not cfg.AutoSkillCheck or not check.Visible then skillConn:Disconnect() skillConn=nil return end
                    if inGoal() then press() skillConn:Disconnect() skillConn=nil end
                end)
            else if skillConn then skillConn:Disconnect() skillConn=nil end end
        end)
    end
    tryConn()
    pg.ChildAdded:Connect(function(child) if child.Name=="SkillCheckPromptGui" then task.wait(0.1) tryConn() end end)
end

local function removeFog()
    pcall(function()
        local li=game:GetService("Lighting")
        for _,obj in ipairs(li:GetChildren()) do if obj:IsA("Atmosphere") then fogCache[obj]=obj.Density obj.Density=0 end end
        fogCache.FogEnd=li.FogEnd li.FogEnd=100000
    end)
end
local function restoreFog()
    pcall(function()
        local li=game:GetService("Lighting")
        for obj,val in pairs(fogCache) do if type(obj)~="string" and obj.Parent then obj.Density=val end end
        if fogCache.FogEnd then li.FogEnd=fogCache.FogEnd end fogCache={}
    end)
end

local HitboxSizes={}
local function updateHitboxes()
    if getRole()~="Killer" or not cfg.HitboxEnabled then
        for plr,sz in pairs(HitboxSizes) do if plr.Character then local r=plr.Character:FindFirstChild("HumanoidRootPart") if r then r.Size=sz r.Transparency=1 r.CanCollide=true end end end
        HitboxSizes={} return
    end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and isSurv(plr) and plr.Character then
            local r=plr.Character:FindFirstChild("HumanoidRootPart") local h=plr.Character:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health>0 then
                if not HitboxSizes[plr] then HitboxSizes[plr]=r.Size end
                r.Size=Vector3.new(cfg.HitboxSize,cfg.HitboxSize,cfg.HitboxSize) r.CanCollide=false r.Transparency=0.7
            end
        end
    end
end

local featureConns={}
local function stopFeature(key) if featureConns[key] then featureConns[key]:Disconnect() featureConns[key]=nil end end
local function startFeature(key,interval,fn)
    stopFeature(key)
    local last=0
    featureConns[key]=RunService.Heartbeat:Connect(function()
        local now=tick() if now-last<interval then return end last=now fn()
    end)
end

local speedPropConn=nil
local function runSpeedLoop()
    if speedPropConn then speedPropConn:Disconnect() speedPropConn=nil end
    startFeature("speed",0.03,function()
        local char=lp.Character if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
        if cfg.SpeedEnabled then
            if State.OrigSpeed==16 and hum.WalkSpeed>0 and hum.WalkSpeed~=cfg.SpeedValue then State.OrigSpeed=hum.WalkSpeed end
            hum.WalkSpeed=cfg.SpeedValue
            if not speedPropConn then
                speedPropConn=hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if cfg.SpeedEnabled and hum.WalkSpeed~=cfg.SpeedValue then hum.WalkSpeed=cfg.SpeedValue end
                end)
            end
        else
            if speedPropConn then speedPropConn:Disconnect() speedPropConn=nil end
            if hum.WalkSpeed==cfg.SpeedValue then hum.WalkSpeed=State.OrigSpeed end
            stopFeature("speed")
        end
    end)
end

local function runFlyLoop()
    startFeature("fly",0.05,function()
        if not cfg.FlyEnabled then
            if State.FlyBV then State.FlyBV:Destroy() State.FlyBV=nil end
            if State.FlyBG then State.FlyBG:Destroy() State.FlyBG=nil end
            local char=lp.Character if char then local h=char:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=false end end
            stopFeature("fly") return
        end
        updateFly()
    end)
end
local function runNoclipLoop()
    startFeature("noclip",0.05,function()
        if not cfg.NoclipEnabled then stopFeature("noclip") return end
        if lp.Character then for _,p in pairs(lp.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    end)
end
local function runWiggleLoop()
    startFeature("wiggle",0.3,function()
        if not cfg.AutoWiggle then stopFeature("wiggle") return end
        pcall(function() RS.Remotes.Carry.SelfUnHookEvent:FireServer() end)
    end)
end
local function runAutoAttackLoop()
    startFeature("autoattack",0.1,function()
        if not cfg.AutoAttack or getRole()~="Killer" then stopFeature("autoattack") return end
        local r=getRoot() if not r then return end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=lp and isSurv(plr) and plr.Character then
                local pr=plr.Character:FindFirstChild("HumanoidRootPart")
                if pr and (pr.Position-r.Position).Magnitude<=cfg.AutoAttackRange then pcall(function() RS.Remotes.Attacks.BasicAttack:FireServer(false) end) break end
            end
        end
    end)
end
local function runDoubleTapLoop()
    startFeature("doubletap",0.5,function()
        if not cfg.DoubleTap or getRole()~="Killer" then stopFeature("doubletap") return end
        pcall(function() RS.Remotes.Attacks.BasicAttack:FireServer(false) end)
        task.wait(0.05)
        pcall(function() RS.Remotes.Attacks.BasicAttack:FireServer(false) end)
    end)
end
local function runNoSlowdownLoop()
    startFeature("noslowdown",0.1,function()
        if not cfg.NoSlowdown or getRole()~="Killer" then stopFeature("noslowdown") return end
        local char=lp.Character if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
        if hum.WalkSpeed<15 then hum.WalkSpeed=State.OrigSpeed end
    end)
end
local function runLungeLoop()
    startFeature("lunge",0.05,function()
        if not cfg.InfiniteLunge or getRole()~="Killer" then stopFeature("lunge") return end
        local r=getRoot() if r then r.Velocity=r.CFrame.LookVector*100+Vector3.new(0,10,0) end
    end)
end
local function runNoFallLoop()
    startFeature("nofall",0.1,function()
        if not cfg.NoFall then stopFeature("nofall") return end
        local char=lp.Character if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
    end)
end
local function runHitboxLoop()
    startFeature("hitbox",0.1,function()
        if not cfg.HitboxEnabled then
            for plr,sz in pairs(HitboxSizes) do if plr.Character then local r=plr.Character:FindFirstChild("HumanoidRootPart") if r then r.Size=sz r.Transparency=1 r.CanCollide=true end end end
            HitboxSizes={} stopFeature("hitbox") return
        end
        updateHitboxes()
    end)
end
local function runAutoHookLoop()
    startFeature("autohook",0.1,function()
        if not cfg.AutoHook or getRole()~="Killer" then State.AutoHookPhase=0 State.AutoHookTarget=nil stopFeature("autohook") return end
        local r=getRoot() if not r then return end
        if State.AutoHookPhase==3 and tick()-State.AutoHookTime>2 then State.AutoHookPhase=0 end
        if State.AutoHookPhase==2 then
            local bestHook,bestDist=nil,math.huge
            for _,hk in ipairs(Cache.Hooks) do
                if hk.part and hk.part.Parent then
                    local occupied=false
                    for _,plr in ipairs(Players:GetPlayers()) do
                        if plr~=lp and isSurv(plr) and plr.Character then
                            local pr=plr.Character:FindFirstChild("HumanoidRootPart")
                            local hp=plr.Character:GetAttribute("HookedProgress")
                            if pr and hp and hp<100 then if (pr.Position-hk.part.Position).Magnitude<8 then occupied=true break end end
                        end
                    end
                    if not occupied then local d=(hk.part.Position-r.Position).Magnitude if d<bestDist then bestDist=d bestHook=hk end end
                end
            end
            if bestHook and bestHook.part then
                tpSafe(bestHook.part.Position)
                for i=1,3 do VIM:SendKeyEvent(true,Enum.KeyCode.Space,false,game) task.wait(0.05) VIM:SendKeyEvent(false,Enum.KeyCode.Space,false,game) task.wait(0.08) end
                State.AutoHookPhase=3 State.AutoHookTime=tick()
            else State.AutoHookPhase=0 end
        elseif State.AutoHookPhase==1 then
            if tick()-State.AutoHookTime>1 then State.AutoHookPhase=2 end
        elseif State.AutoHookPhase==0 and tick()-State.LastAutoHook>0.5 then
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=lp and isSurv(plr) and plr.Character then
                    local pr=plr.Character:FindFirstChild("HumanoidRootPart")
                    local h=plr.Character:FindFirstChildOfClass("Humanoid")
                    if pr and h then local p=h.MaxHealth>0 and h.Health/h.MaxHealth or 0
                        if p<=0.25 and p>0 then
                            tpSafe(pr.Position)
                            for i=1,3 do VIM:SendKeyEvent(true,Enum.KeyCode.Space,false,game) task.wait(0.05) VIM:SendKeyEvent(false,Enum.KeyCode.Space,false,game) task.wait(0.08) end
                            State.AutoHookPhase=1 State.AutoHookTime=tick() State.LastAutoHook=tick() break
                        end
                    end
                end
            end
        end
    end)
end
local function runBeatKillerLoop()
    startFeature("beatkiller",0.1,function()
        if not cfg.BeatKiller or getRole()~="Killer" then State.KillerTarget=nil stopFeature("beatkiller") return end
        local r=getRoot() if not r then return end
        if State.KillerTarget and State.KillerTarget.Character then
            local h=State.KillerTarget.Character:FindFirstChildOfClass("Humanoid")
            if not h or h.Health/h.MaxHealth<=0.25 then State.KillerTarget=nil end
        end
        if not State.KillerTarget then
            local cl,cd=nil,math.huge
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=lp and isSurv(plr) and plr.Character then
                    local pr=plr.Character:FindFirstChild("HumanoidRootPart")
                    local h=plr.Character:FindFirstChildOfClass("Humanoid")
                    if pr and h and h.Health/h.MaxHealth>0.25 then local d=(pr.Position-r.Position).Magnitude if d<cd then cd=d cl=plr end end
                end
            end
            State.KillerTarget=cl
        end
        if State.KillerTarget and State.KillerTarget.Character then
            local tr=State.KillerTarget.Character:FindFirstChild("HumanoidRootPart")
            if tr then tpSafe(tr.Position) pcall(function() RS.Remotes.Attacks.BasicAttack:FireServer(false) end) end
        end
    end)
end
local function runTeleAwayLoop()
    startFeature("teleaway",0.5,function()
        if not cfg.TeleAway or getRole()~="Survivor" then stopFeature("teleaway") return end
        if tick()-State.LastTeleAway<3 then return end
        local r=getRoot() if not r then return end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=lp and isKiller(plr) and plr.Character then
                local kr=plr.Character:FindFirstChild("HumanoidRootPart")
                if kr and (kr.Position-r.Position).Magnitude<cfg.TeleAwayDist then
                    State.LastTeleAway=tick()
                    local best,bd=nil,0
                    for _,gen in ipairs(Cache.Generators) do if gen.part then local d=(gen.part.Position-kr.Position).Magnitude if d>bd then bd=d best=gen.part.Position end end end
                    if best then tpSafe(best) end break
                end
            end
        end
    end)
end
local function runBeatSurvivor()
    if not cfg.BeatSurvivor or getRole()~="Survivor" or State.BeatSurvivorDone then return end
    local map=workspace:FindFirstChild("Map") if not map then return end
    local ep=nil
    for _,obj in ipairs(map:GetDescendants()) do if obj:IsA("BasePart") and obj.Name:lower():find("finish") then ep=obj.Position break end end
    if not ep and #Cache.Gates>0 and Cache.Gates[1].part then ep=Cache.Gates[1].part.Position end
    if ep then tpSafe(ep) State.BeatSurvivorDone=true end
end
local function runAutoParryLoop()
    startFeature("autoparry",0.2,function()
        if not cfg.AutoParry or getRole()~="Survivor" then stopFeature("autoparry") return end
        local r=getRoot() if not r then return end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=lp and isKiller(plr) and plr.Character then
                local pr=plr.Character:FindFirstChild("HumanoidRootPart")
                if pr and (pr.Position-r.Position).Magnitude<=15 then pcall(function() RS.Remotes.Items["Parrying Dagger"].parry:FireServer() end) break end
            end
        end
    end)
end
local function runDestroyPalletsLoop()
    startFeature("destroypallets",1,function()
        if not cfg.DestroyPallets then stopFeature("destroypallets") return end
        destroyPallets()
    end)
end
local function runFullGenBreakLoop()
    startFeature("fullgenbreak",0.5,function()
        if not cfg.FullGenBreak then stopFeature("fullgenbreak") return end
        fullGenBreak()
    end)
end

local lastLoop=0
RunService.Heartbeat:Connect(function()
    local now=tick() if now-lastLoop<0.1 then return end lastLoop=now
    if cfg.FovEnabled then local c=workspace.CurrentCamera if c then if not State.OrigFOV then State.OrigFOV=c.FieldOfView end c.FieldOfView=cfg.FovValue end end
    if cfg.ThirdPerson and getRole()=="Killer" then local c=lp.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.CameraOffset=Vector3.new(2,1,8) end end end
    if cfg.ShiftLock then local r=getRoot() if r then local lk=cam.CFrame.LookVector local fl=Vector3.new(lk.X,0,lk.Z).Unit r.CFrame=CFrame.new(r.Position,r.Position+fl) end end
    if cfg.NO_Fog~=State.LastFogState then State.LastFogState=cfg.NO_Fog if cfg.NO_Fog then removeFog() else restoreFog() end end
    if cfg.BeatSurvivor then runBeatSurvivor() end
end)

local lastFastVault=0
local function getNearestWindow()
    local char=lp.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil,nil,nil end
    local map=workspace:FindFirstChild("Map") if not map then return nil,nil,nil end
    local nearest,dist2,nearestBase=nil,math.huge,nil
    for _,obj in ipairs(map:GetDescendants()) do
        if obj.Name=="Window" and obj:IsA("Model") then
            local base=obj:FindFirstChildWhichIsA("BasePart")
            if base then local d=(base.Position-hrp.Position).Magnitude if d<dist2 then nearest=obj nearestBase=base dist2=d end end
        end
    end
    return nearest,dist2,nearestBase
end
local function doFastVault()
    if tick()-lastFastVault<0.3 then return end
    local char=lp.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local window,dist,base=getNearestWindow()
    if not window or not base or dist>15 then return end
    lastFastVault=tick()
    local winSize=base.Size local moveDir=hrp.CFrame.LookVector
    local tpDist=math.max(winSize.X,winSize.Z)/2+3
    local targetPos=base.Position+Vector3.new(moveDir.X*tpDist,0,moveDir.Z*tpDist)
    for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    hrp.CFrame=CFrame.new(targetPos+Vector3.new(0,1,0))
    task.wait(0.05)
    pcall(function() RS.Remotes.Window.fastvault:FireServer(window) end)
    pcall(function() RS.Remotes.Window.VaultCompleteEventpart1:FireServer(window) end)
    task.wait(0.05)
    pcall(function() RS.Remotes.Window.VaultCompleteEvent:FireServer(window) end)
    local animator=hum:FindFirstChildOfClass("Animator")
    if animator then for _,track in ipairs(animator:GetPlayingAnimationTracks()) do if track.Length>0.2 and track.Length<2 then track:AdjustSpeed(20) end end end
    task.delay(0.2,function()
        if not lp.Character then return end
        for _,p in pairs(lp.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.CanCollide=true end end
    end)
end
RunService.Heartbeat:Connect(function()
    if not cfg.FastVault then return end
    local _,dist=getNearestWindow()
    if dist and dist<5 then doFastVault() end
end)

local moonwalkActive=false local moonwalkConn=nil
local function startMoonwalk()
    if moonwalkConn then moonwalkConn:Disconnect() moonwalkConn=nil end
    moonwalkActive=true local t=0
    moonwalkConn=RunService.Heartbeat:Connect(function(dt)
        if not moonwalkActive then moonwalkConn:Disconnect() moonwalkConn=nil return end
        local char=lp.Character if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart") local hum=char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        t=t+dt*8 local offset=math.sin(t)*0.4
        hum.AutoRotate=false
        root.CFrame=root.CFrame*CFrame.Angles(0,offset*0.1,0)
        local lookDir=root.CFrame.LookVector
        root.AssemblyLinearVelocity=Vector3.new(-lookDir.X*cfg.SpeedValue*0.8,root.AssemblyLinearVelocity.Y,-lookDir.Z*cfg.SpeedValue*0.8)
    end)
end
local function stopMoonwalk()
    moonwalkActive=false
    if moonwalkConn then moonwalkConn:Disconnect() moonwalkConn=nil end
    local char=lp.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum.AutoRotate=true end
end


-- GUI
local Library=loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()

local MainFrame=Library:CreateWindow({
    Name="DBSB.SU",
    Themeable={Info="Violence District",Credit=false},
    Theme=[[{"__Designer.Colors.topGradient":"0D0D0D","__Designer.Colors.section":"C25252","__Designer.Colors.hoveredOptionBottom":"2A0A0A","__Designer.Colors.background":"0D0D0D","__Designer.Colors.selectedOption":"3A1010","__Designer.Colors.unselectedOption":"1A0A0A","__Designer.Colors.unhoveredOptionTop":"0A0808","__Designer.Colors.outerBorder":"2A1515","__Designer.Colors.tabText":"B9B9B9","__Designer.Colors.elementBorder":"160808","__Designer.Colors.innerBorder":"4A1515","__Designer.Colors.bottomGradient":"0A0808","__Designer.Colors.sectionBackground":"0A0505","__Designer.Colors.hoveredOptionTop":"6B1010","__Designer.Colors.otherElementText":"8A3030","__Designer.Colors.main":"C25252","__Designer.Colors.elementText":"9F7D7D","__Designer.Colors.unhoveredOptionBottom":"1A0000","__Designer.Background.UseBackgroundImage":false}]]
})

local guiVisible=true
UIS.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode==Enum.KeyCode.RightAlt then
        guiVisible=not guiVisible
        pcall(function() if guiVisible then Library:Show() else Library:Hide() end end)
        pcall(function()
            for _,gui in ipairs(lp.PlayerGui:GetChildren()) do
                if gui.Name:find("Pepsi") or gui.Name:find("Library") then gui.Enabled=guiVisible end
            end
        end)
    end
    for _,bind in pairs(binds) do
        if bind.key and bind.key~=Enum.KeyCode.Unknown and bind.key==input.KeyCode and bind.fn then bind.fn() end
    end
end)

local ESPTab=MainFrame:CreateTab({Name="ESP"})
local SurvTab=MainFrame:CreateTab({Name="Survivor"})
local KillTab=MainFrame:CreateTab({Name="Killer"})
local MoveTab=MainFrame:CreateTab({Name="Movement"})
local VisTab=MainFrame:CreateTab({Name="Visuals"})
local SetTab=MainFrame:CreateTab({Name="Settings"})

local EP=ESPTab:CreateSection({Name="Players"})
local EO=ESPTab:CreateSection({Name="Objects",Side="Right"})
EP:AddToggle({Name="Survivor ESP",Value=false,Callback=function(v) cfg.ESP_Survivors=v end})
EP:AddToggle({Name="Killer ESP",Value=false,Callback=function(v) cfg.ESP_Killer=v end})
EP:AddToggle({Name="Names",Value=false,Callback=function(v) cfg.ESP_Names=v end})
EP:AddToggle({Name="Distance",Value=false,Callback=function(v) cfg.ESP_Distance=v end})
EP:AddToggle({Name="Health",Value=false,Callback=function(v) cfg.ESP_Health=v end})
EP:AddToggle({Name="Skeleton",Value=false,Callback=function(v) cfg.ESP_Skeleton=v end})
EP:AddToggle({Name="Offscreen",Value=false,Callback=function(v) cfg.ESP_Offscreen=v end})
EP:AddToggle({Name="Velocity",Value=false,Callback=function(v) cfg.ESP_Velocity=v end})
EP:AddToggle({Name="Chams Mode",Value=false,Callback=function(v) cfg.ESP_Chams=v end})
EP:AddSlider({Name="Max Distance",Value=500,Min=100,Max=1000,Callback=function(v) cfg.ESP_MaxDist=v end})
EO:AddToggle({Name="Generators",Value=false,Callback=function(v) cfg.ESP_Generator=v updateObjESP() end})
EO:AddToggle({Name="Hooks",Value=false,Callback=function(v) cfg.ESP_Hook=v updateObjESP() end})
EO:AddToggle({Name="Gates",Value=false,Callback=function(v) cfg.ESP_Gate=v updateObjESP() end})
EO:AddToggle({Name="Pallets",Value=false,Callback=function(v) cfg.ESP_Pallet=v updateObjESP() end})
EO:AddToggle({Name="Windows",Value=false,Callback=function(v) cfg.ESP_Window=v updateObjESP() end})
EO:AddToggle({Name="Closest Hook",Value=false,Callback=function(v) cfg.ESP_ClosestHook=v updateObjESP() end})
local EC=ESPTab:CreateSection({Name="Colors"})
EC:AddColorPicker({Name="Survivor Color",Value=cfg.ColSurvChams,Callback=function(v) cfg.ColSurvChams=v cfg.ColSurvName=v cfg.ColSurvSkel=v end})
EC:AddColorPicker({Name="Killer Color",Value=cfg.ColKillChams,Callback=function(v) cfg.ColKillChams=v cfg.ColKillName=v cfg.ColKillSkel=v end})
EC:AddColorPicker({Name="Tracer Color",Value=cfg.ColTracer,Callback=function(v) cfg.ColTracer=v end})
EC:AddColorPicker({Name="Info Text Color",Value=cfg.ColInfo,Callback=function(v) cfg.ColInfo=v end})

local SA=SurvTab:CreateSection({Name="Automation"})
local SB=SurvTab:CreateSection({Name="Actions",Side="Right"})
SA:AddToggle({Name="Auto Skill Check",Value=false,Callback=function(v) cfg.AutoSkillCheck=v end})
SA:AddKeybind({Name="Skill Check Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) if k~=Enum.KeyCode.Unknown then binds.skillcheck={name="Skill Check",key=k,fn=function() cfg.AutoSkillCheck=not cfg.AutoSkillCheck end} end end})
SA:AddToggle({Name="Auto Wiggle",Value=false,Callback=function(v) cfg.AutoWiggle=v if v then runWiggleLoop() end end})
SA:AddKeybind({Name="Wiggle Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.wiggle={name="Auto Wiggle",key=k,fn=function() cfg.AutoWiggle=not cfg.AutoWiggle end} end})
SA:AddToggle({Name="Auto Parry",Value=false,Callback=function(v) cfg.AutoParry=v if v then runAutoParryLoop() end end})
SA:AddToggle({Name="Flee Killer",Value=false,Callback=function(v) cfg.TeleAway=v if v then runTeleAwayLoop() end end})
SA:AddSlider({Name="Flee Distance",Value=40,Min=10,Max=80,Callback=function(v) cfg.TeleAwayDist=v end})
SA:AddToggle({Name="No Fall Damage",Value=false,Callback=function(v) cfg.NoFall=v if v then runNoFallLoop() end end})
SA:AddToggle({Name="Auto Generator",Value=false,Callback=function(v) cfg.AutoGen=v if v then startAutoGen() else autoGenActive=false end end})
SA:AddKeybind({Name="Auto Gen Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.autogen={name="Auto Gen",key=k,fn=function() cfg.AutoGen=not cfg.AutoGen if cfg.AutoGen then startAutoGen() else autoGenActive=false end end} end})
SA:AddToggle({Name="Beat Survivor",Value=false,Callback=function(v) cfg.BeatSurvivor=v end})
SB:AddButton({Name="Instant Gen",Callback=instantGen})
SB:AddKeybind({Name="Instant Gen Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.instantgen={name="Instant Gen",key=k,fn=instantGen} end})
SB:AddButton({Name="Unhook Nearest",Callback=unhookNearest})
SB:AddKeybind({Name="Unhook Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.unhook={name="Unhook Nearest",key=k,fn=unhookNearest} end})
SB:AddButton({Name="Unhook Self",Callback=unhookSelf})
SB:AddKeybind({Name="Unhook Self Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.unhookself={name="Unhook Self",key=k,fn=unhookSelf} end})
SB:AddButton({Name="Instant Escape",Callback=instantEscape})
SB:AddKeybind({Name="Escape Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.escape={name="Escape",key=k,fn=instantEscape} end})
SB:AddButton({Name="TP to Generator",Callback=tpToGen})
SB:AddKeybind({Name="TP Gen Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.tpgen={name="TP Gen",key=k,fn=tpToGen} end})

local KA=KillTab:CreateSection({Name="Combat"})
local KB=KillTab:CreateSection({Name="Protection",Side="Right"})
KA:AddToggle({Name="Auto Attack",Value=false,Callback=function(v) cfg.AutoAttack=v if v then runAutoAttackLoop() end end})
KA:AddSlider({Name="Attack Range",Value=12,Min=5,Max=30,Callback=function(v) cfg.AutoAttackRange=v end})
KA:AddToggle({Name="Double Tap",Value=false,Callback=function(v) cfg.DoubleTap=v if v then runDoubleTapLoop() end end})
KA:AddKeybind({Name="Double Tap Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.doubletap={name="Double Tap",key=k,fn=function() cfg.DoubleTap=not cfg.DoubleTap end} end})
KA:AddToggle({Name="Infinite Lunge",Value=false,Callback=function(v) cfg.InfiniteLunge=v if v then runLungeLoop() end end})
KA:AddKeybind({Name="Lunge Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.lunge={name="Inf Lunge",key=k,fn=function() cfg.InfiniteLunge=not cfg.InfiniteLunge end} end})
KA:AddToggle({Name="Auto Hook",Value=false,Callback=function(v) cfg.AutoHook=v if v then runAutoHookLoop() else State.AutoHookPhase=0 end end})
KA:AddToggle({Name="Beat Killer",Value=false,Callback=function(v) cfg.BeatKiller=v if v then runBeatKillerLoop() else State.KillerTarget=nil end end})
KA:AddToggle({Name="Expand Hitboxes",Value=false,Callback=function(v) cfg.HitboxEnabled=v if v then runHitboxLoop() end end})
KA:AddSlider({Name="Hitbox Size",Value=15,Min=5,Max=30,Callback=function(v) cfg.HitboxSize=v end})
KA:AddToggle({Name="Full Gen Break",Value=false,Callback=function(v) cfg.FullGenBreak=v if v then runFullGenBreakLoop() end end})
KA:AddToggle({Name="Destroy Pallets",Value=false,Callback=function(v) cfg.DestroyPallets=v if v then runDestroyPalletsLoop() end end})
KA:AddButton({Name="Destroy Pallets Now",Callback=destroyPallets})
KB:AddToggle({Name="No Pallet Stun",Value=false,Callback=function(v) cfg.NoPalletStun=v end})
KB:AddToggle({Name="Anti Blind",Value=false,Callback=function(v) cfg.AntiBlind=v end})
KB:AddToggle({Name="No Slowdown",Value=false,Callback=function(v) cfg.NoSlowdown=v if v then runNoSlowdownLoop() end end})
KB:AddToggle({Name="Third Person",Value=false,Callback=function(v) cfg.ThirdPerson=v end})

local MA=MoveTab:CreateSection({Name="Speed & Flight"})
local MB=MoveTab:CreateSection({Name="Teleport",Side="Right"})
MA:AddToggle({Name="Speed Hack",Value=false,Callback=function(v) cfg.SpeedEnabled=v if v then runSpeedLoop() else local char=lp.Character if char then local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=State.OrigSpeed end end end end})
do
    local shc,shec
    MA:AddKeybind({Name="Speed Bind (Hold)",Value=Enum.KeyCode.Unknown,Callback=function(k)
        if shc then shc:Disconnect() end if shec then shec:Disconnect() end
        binds.speed={name="Speed [Hold]",key=k,fn=nil}
        shc=UIS.InputBegan:Connect(function(input,gpe) if gpe then return end if input.KeyCode==k then cfg.SpeedEnabled=true runSpeedLoop() end end)
        shec=UIS.InputEnded:Connect(function(input)
            if input.KeyCode==k then
                cfg.SpeedEnabled=false
                if speedPropConn then speedPropConn:Disconnect() speedPropConn=nil end
                local char=lp.Character if char then local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=State.OrigSpeed hum:Move(Vector3.new(0,0,0),false) end end
            end
        end)
    end})
end
MA:AddSlider({Name="Speed Value",Value=32,Min=16,Max=150,Callback=function(v) cfg.SpeedValue=v end})
MA:AddToggle({Name="Fly",Value=false,Callback=function(v) cfg.FlyEnabled=v if v then runFlyLoop() end end})
MA:AddKeybind({Name="Fly Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.fly={name="Fly",key=k,fn=function() cfg.FlyEnabled=not cfg.FlyEnabled if cfg.FlyEnabled then runFlyLoop() end end} end})
MA:AddSlider({Name="Fly Speed",Value=50,Min=10,Max=200,Callback=function(v) cfg.FlySpeed=v end})
MA:AddToggle({Name="Infinite Jump",Value=false,Callback=function(v) cfg.InfiniteJump=v end})
MA:AddKeybind({Name="Inf Jump Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.infjump={name="Inf Jump",key=k,fn=function() cfg.InfiniteJump=not cfg.InfiniteJump end} end})
MA:AddSlider({Name="Jump Power",Value=50,Min=50,Max=200,Callback=function(v) cfg.JumpPower=v end})
MA:AddToggle({Name="Noclip",Value=false,Callback=function(v) cfg.NoclipEnabled=v if v then runNoclipLoop() end end})
MA:AddKeybind({Name="Noclip Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.noclip={name="Noclip",key=k,fn=function() cfg.NoclipEnabled=not cfg.NoclipEnabled if cfg.NoclipEnabled then runNoclipLoop() end end} end})
MA:AddToggle({Name="Fling",Value=false,Callback=function(v) cfg.FlingEnabled=v end})
MA:AddSlider({Name="Fling Strength",Value=10000,Min=1000,Max=50000,Callback=function(v) cfg.FlingStrength=v end})
MA:AddButton({Name="Fling Nearest",Callback=flingNearest})
MA:AddKeybind({Name="Fling Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.fling={name="Fling",key=k,fn=flingNearest} end})
MA:AddToggle({Name="Moonwalk",Value=false,Callback=function(v) if v then startMoonwalk() else stopMoonwalk() end end})
MA:AddKeybind({Name="Moonwalk Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.moonwalk={name="Moonwalk",key=k,fn=function() if moonwalkActive then stopMoonwalk() else startMoonwalk() end end} end})
MA:AddToggle({Name="Fast Vault",Value=false,Callback=function(v) cfg.FastVault=v end})
MA:AddKeybind({Name="Fast Vault Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.fastvault={name="Fast Vault",key=k,fn=function() cfg.FastVault=not cfg.FastVault end} end})
MB:AddButton({Name="Fast Vault Now",Callback=doFastVault})
MB:AddButton({Name="TP to Killer",Callback=function() tpToPlayer(true) end})
MB:AddKeybind({Name="TP Killer Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.tpkiller={name="TP Killer",key=k,fn=function() tpToPlayer(true) end} end})
MB:AddButton({Name="TP to Survivor",Callback=function() tpToPlayer(false) end})
MB:AddKeybind({Name="TP Surv Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.tpsurv={name="TP Survivor",key=k,fn=function() tpToPlayer(false) end} end})
MB:AddButton({Name="TP to Generator",Callback=tpToGen})
MB:AddButton({Name="Instant Escape",Callback=instantEscape})
MB:AddButton({Name="TP Closest Hook",Callback=function() if Cache.ClosestHook and Cache.ClosestHook.part then tpSafe(Cache.ClosestHook.part.Position) end end})
MB:AddKeybind({Name="TP Hook Bind",Value=Enum.KeyCode.Unknown,Callback=function(k) binds.tphook={name="TP Hook",key=k,fn=function() if Cache.ClosestHook and Cache.ClosestHook.part then tpSafe(Cache.ClosestHook.part.Position) end end} end})

local VA=VisTab:CreateSection({Name="Visual"})
local VB=VisTab:CreateSection({Name="Radar",Side="Right"})
VA:AddToggle({Name="Remove Fog",Value=false,Callback=function(v) cfg.NO_Fog=v end})
VA:AddToggle({Name="Custom FOV",Value=false,Callback=function(v) cfg.FovEnabled=v end})
VA:AddSlider({Name="FOV Value",Value=90,Min=30,Max=120,Callback=function(v) cfg.FovValue=v end})
VA:AddToggle({Name="Shift Lock",Value=false,Callback=function(v) cfg.ShiftLock=v end})
VB:AddToggle({Name="Radar",Value=false,Callback=function(v) cfg.RADAR=v end})
VB:AddSlider({Name="Radar Size",Value=120,Min=80,Max=200,Callback=function(v) cfg.RADAR_Size=v end})
VB:AddToggle({Name="Radar Circle",Value=false,Callback=function(v) cfg.RADAR_Circle=v end})

local STA=SetTab:CreateSection({Name="Misc"})
local STB=SetTab:CreateSection({Name="Actions",Side="Right"})
STA:AddSlider({Name="Lunge Atk",Value=20,Min=0,Max=100,Callback=function(v) cfg.LungeAtk=v end})
STA:AddSlider({Name="MB1 Atk",Value=-1,Min=-20,Max=20,Callback=function(v) cfg.MB1Atk=v end})
STB:AddButton({Name="Instant Gen",Callback=instantGen})
STB:AddButton({Name="Unhook Nearest",Callback=unhookNearest})
STB:AddButton({Name="Unhook Self",Callback=unhookSelf})
STB:AddButton({Name="Instant Escape",Callback=instantEscape})
STB:AddButton({Name="TP Killer",Callback=function() tpToPlayer(true) end})
STB:AddButton({Name="TP Survivor",Callback=function() tpToPlayer(false) end})
STB:AddButton({Name="TP Generator",Callback=tpToGen})
STB:AddButton({Name="Destroy Pallets",Callback=destroyPallets})
STB:AddButton({Name="Full Gen Break",Callback=fullGenBreak})
STB:AddButton({Name="Fling Nearest",Callback=flingNearest})
STB:AddButton({Name="Refresh ESP",Callback=function() scanMap() updateObjESP() end})


for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp then mkESP(plr) end end
Players.PlayerAdded:Connect(function(plr) if plr~=lp then mkESP(plr) end end)
Players.PlayerRemoving:Connect(rmESP)
lp.CharacterAdded:Connect(function()
    task.wait(1) setupSkillCheck() State.BeatSurvivorDone=false State.OrigSpeed=16
    if cfg.SpeedEnabled then runSpeedLoop() end
    if cfg.FlyEnabled then runFlyLoop() end
    if cfg.NoclipEnabled then runNoclipLoop() end
    if cfg.NoFall then runNoFallLoop() end
end)
setupSkillCheck()
scanMap()
print("[DBSB.SU] Loaded - RightAlt to open")
end, function(e)
    print("[DBSB ERROR] " .. tostring(e))
    print(debug.traceback())
end)
if not ok then print("[DBSB] Script failed") end
