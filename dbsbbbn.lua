-- ═══════════════════════════════════════════════════════
--  DBSB.su | Bite by Night
--  ESP, Auto Farm, Player Mods
--  RightAlt to toggle UI
-- ═══════════════════════════════════════════════════════
--  USE THE LOADER — do not inject this script directly
--  Loader: dbsb_bbn_loader.lua
-- ═══════════════════════════════════════════════════════

if getgenv().__dbsb_auth ~= "d7f2a91bc84e3065fda28791c430b5e2" then
    local lp = game:GetService("Players").LocalPlayer
    local sg = Instance.new("ScreenGui")
    sg.Name = "DBSB_Err"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 9999
    sg.IgnoreGuiInset = true
    sg.Parent = lp.PlayerGui
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,40)
    lbl.Position = UDim2.new(0,0,0.5,-20)
    lbl.BackgroundTransparency = 1
    lbl.Text = "DBSB.su — Use the loader to launch Bite by Night"
    lbl.TextColor3 = Color3.fromRGB(230,60,60)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Code
    lbl.Parent = sg
    task.delay(4, function() sg:Destroy() end)
    return
end

-- bot/decompiler detection
local isBot = true
local ok, err = pcall(function()
    return game:GetService("bro really tried to deob a DBSB script lmaooo")
end)
if not ok and type(err) == "string" and string.find(err, "valid Service name") then
    isBot = false
end
if isBot then return end

local Library={}
Library.__index=Library
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local lp=Players.LocalPlayer
local T={
    BG           = Color3.fromRGB(11,11,15),
    Sidebar      = Color3.fromRGB(15,15,21),
    Card         = Color3.fromRGB(20,20,28),
    CardHover    = Color3.fromRGB(26,26,36),
    CardTop      = Color3.fromRGB(32,32,44),
    Input        = Color3.fromRGB(16,16,24),
    Purple       = Color3.fromRGB(128,58,255),
    PurpleDim    = Color3.fromRGB(80,35,160),
    PurpleDark   = Color3.fromRGB(20,10,44),
    PurpleGlow   = Color3.fromRGB(168,100,255),
    TextPrimary  = Color3.fromRGB(238,238,244),
    TextSecond   = Color3.fromRGB(148,148,168),
    TextMuted    = Color3.fromRGB(72,72,92),
    Divider      = Color3.fromRGB(28,28,40),
    Border       = Color3.fromRGB(38,38,54),
    BorderAccent = Color3.fromRGB(88,48,178),
    Green        = Color3.fromRGB(50,210,100),
    Red          = Color3.fromRGB(230,60,60),
    Orange       = Color3.fromRGB(255,150,40),
    PillOff      = Color3.fromRGB(32,32,46),
    ScrollBar    = Color3.fromRGB(55,30,115),
    NotifBG      = Color3.fromRGB(15,15,21),
}
local F={Bold=Enum.Font.Code,Medium=Enum.Font.Code,Mono=Enum.Font.Code}
local function tw(o,p,d,s,dir) local t=TweenService:Create(o,TweenInfo.new(d or 0.2,s or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),p) t:Play() return t end
local function new(c,p,par) local i=Instance.new(c) if p then for k,v in pairs(p) do i[k]=v end end if par then i.Parent=par end return i end
local function corner(r,p) return new("UICorner",{CornerRadius=UDim.new(0,r or 6)},p) end
local function stroke(c,t,p) return new("UIStroke",{Color=c or T.Border,Thickness=t or 1},p) end
local function pad(l,r,t,b,p) return new("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0)},p) end

function Library:Window(title,subtitle)
    local Win={_tabs={},_activeTab=nil}
    local old=lp.PlayerGui:FindFirstChild("DBSB_UI_"..title:gsub("%s","")) if old then old:Destroy() end
    local sg=new("ScreenGui",{Name="DBSB_UI_"..title:gsub("%s",""),ResetOnSpawn=false,DisplayOrder=9999,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},lp.PlayerGui)
    Win._sg=sg
    local main=new("Frame",{Size=UDim2.new(0,680,0,500),Position=UDim2.new(0.5,-340,0.5,-250),BackgroundColor3=T.BG,BorderSizePixel=0},sg)
    local mainStroke=stroke(T.Border,1,main)
    Win._main=main
    task.spawn(function()
        local t=0
        while main.Parent do
            t=t+0.016
            mainStroke.Color=T.Border:Lerp(T.BorderAccent,(math.sin(t*1.1)+1)/2*0.6)
            task.wait(0.016)
        end
    end)
    local dotCanvas=new("Frame",{Size=UDim2.new(1,-196,1,0),Position=UDim2.new(0,196,0,0),BackgroundColor3=T.BG,BorderSizePixel=0,ZIndex=1,ClipsDescendants=true},main)
    task.spawn(function()
        local spacing=20
        for row=0,math.floor(500/spacing)+1 do
            for col=0,math.floor(484/spacing)+1 do
                new("Frame",{Size=UDim2.new(0,1,0,1),Position=UDim2.new(0,col*spacing,0,row*spacing),BackgroundColor3=Color3.fromRGB(33,33,50),BorderSizePixel=0,ZIndex=1},dotCanvas)
            end
        end
    end)
    local sidebar=new("Frame",{Size=UDim2.new(0,196,1,0),BackgroundColor3=T.Sidebar,BorderSizePixel=0,ZIndex=2},main)
    new("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Divider,BorderSizePixel=0,ZIndex=3},sidebar)
    new("Frame",{Size=UDim2.new(1,0,0,58),BackgroundColor3=T.PurpleDark,BackgroundTransparency=0.55,BorderSizePixel=0,ZIndex=2},sidebar)
    local sideHeader=new("Frame",{Size=UDim2.new(1,0,0,76),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=3},sidebar)
    new("TextLabel",{Size=UDim2.new(0,96,0,22),Position=UDim2.new(0,14,0,13),BackgroundTransparency=1,Text=title,TextColor3=T.TextPrimary,TextSize=16,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},sideHeader)
    local badge=new("Frame",{Size=UDim2.new(0,28,0,14),Position=UDim2.new(0,114,0,17),BackgroundColor3=T.PurpleDark,BorderSizePixel=0,ZIndex=5},sideHeader)
    corner(3,badge) stroke(T.BorderAccent,1,badge)
    new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="v1.5",TextColor3=T.PurpleGlow,TextSize=9,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6},badge)
    new("TextLabel",{Size=UDim2.new(1,-28,0,14),Position=UDim2.new(0,14,0,37),BackgroundTransparency=1,Text=(subtitle or ""):upper(),TextColor3=T.TextMuted,TextSize=9,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},sideHeader)
    local accentLine=new("Frame",{Size=UDim2.new(0,30,0,1),Position=UDim2.new(0,14,1,-1),BackgroundColor3=T.Purple,BorderSizePixel=0,ZIndex=4},sideHeader)
    new("Frame",{Size=UDim2.new(1,-44,0,1),Position=UDim2.new(0,44,1,-1),BackgroundColor3=T.Divider,BorderSizePixel=0,ZIndex=3},sideHeader)
    task.spawn(function()
        local t=0
        while accentLine.Parent do
            t=t+0.016
            local s=math.abs(math.sin(t*0.7))
            accentLine.Size=UDim2.new(0,20+s*70,0,1)
            accentLine.BackgroundColor3=T.Purple:Lerp(T.PurpleGlow,s)
            task.wait(0.016)
        end
    end)
    local tabList=new("ScrollingFrame",{Size=UDim2.new(1,0,1,-110),Position=UDim2.new(0,0,0,76),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),ZIndex=3},sidebar)
    local tll=new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,1)},tabList)
    pad(0,0,4,4,tabList)
    tll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabList.CanvasSize=UDim2.new(0,0,0,tll.AbsoluteContentSize.Y+8) end)
    Win._tabList=tabList
    local content=new("Frame",{Size=UDim2.new(1,-196,1,0),Position=UDim2.new(0,196,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=3},main)
    Win._content=content
    local bottomBar=new("Frame",{Size=UDim2.new(1,0,0,40),Position=UDim2.new(0,0,1,-40),BackgroundColor3=T.Sidebar,BorderSizePixel=0,ZIndex=5},sidebar)
    new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Divider,BorderSizePixel=0},bottomBar)
    local statusDot=new("Frame",{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,14,0.5,-3),BackgroundColor3=T.Green,BorderSizePixel=0,ZIndex=6},bottomBar) corner(3,statusDot)
    new("TextLabel",{Size=UDim2.new(0,40,1,0),Position=UDim2.new(0,24,0,0),BackgroundTransparency=1,Text="active",TextColor3=T.TextMuted,TextSize=9,Font=F.Bold,ZIndex=6},bottomBar)
    task.spawn(function()
        while statusDot.Parent do
            tw(statusDot,{BackgroundTransparency=0.55},0.9,Enum.EasingStyle.Sine) task.wait(0.9)
            tw(statusDot,{BackgroundTransparency=0},0.9,Enum.EasingStyle.Sine) task.wait(0.9)
        end
    end)
    local discordBtn=new("TextButton",{Size=UDim2.new(0,76,0,20),Position=UDim2.new(1,-88,0.5,-10),BackgroundColor3=Color3.fromRGB(72,85,210),BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=6},bottomBar)
    corner(3,discordBtn) stroke(Color3.fromRGB(95,108,232),1,discordBtn)
    new("TextLabel",{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Text="✦ discord",TextColor3=Color3.fromRGB(255,255,255),TextSize=9,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,ZIndex=7},discordBtn)
    discordBtn.MouseEnter:Connect(function() tw(discordBtn,{BackgroundColor3=Color3.fromRGB(58,70,185)},0.1) end)
    discordBtn.MouseLeave:Connect(function() tw(discordBtn,{BackgroundColor3=Color3.fromRGB(72,85,210)},0.1) end)
    discordBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/A3NVXZsWc9") end)
        Win:Notify("Discord","Invite copied to clipboard",2)
    end)
    local dragging,dragStart,startPos
    sideHeader.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true dragStart=i.Position startPos=main.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dragStart main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputBegan:Connect(function(i,gpe) if not gpe and i.KeyCode==Enum.KeyCode.RightAlt then sg.Enabled=not sg.Enabled end end)
    local nHolder=new("Frame",{Size=UDim2.new(0,290,1,0),Position=UDim2.new(1,-306,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9999},sg)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,5)},nHolder)
    pad(0,0,0,14,nHolder) Win._nc=0
    function Win:Notify(t,msg,dur)
        Win._nc=Win._nc+1 dur=dur or 3
        local n=new("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=T.NotifBG,BorderSizePixel=0,LayoutOrder=Win._nc,ClipsDescendants=true,Position=UDim2.new(1,8,0,0)},nHolder)
        stroke(T.BorderAccent,1,n)
        new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.BorderAccent,BorderSizePixel=0},n)
        local ab=new("Frame",{Size=UDim2.new(0,2,1,-12),Position=UDim2.new(0,0,0,6),BackgroundColor3=T.PurpleGlow,BorderSizePixel=0},n) corner(1,ab)
        new("TextLabel",{Size=UDim2.new(1,-22,0,18),Position=UDim2.new(0,14,0,11),BackgroundTransparency=1,Text=t,TextColor3=T.TextPrimary,TextSize=13,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},n)
        new("TextLabel",{Size=UDim2.new(1,-22,0,16),Position=UDim2.new(0,14,0,30),BackgroundTransparency=1,Text=msg,TextColor3=T.TextSecond,TextSize=11,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},n)
        local pb=new("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=T.Divider,BorderSizePixel=0},n)
        local pf=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Purple,BorderSizePixel=0},pb)
        tw(n,{Position=UDim2.new(0,0,0,0)},0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        tw(pf,{Size=UDim2.new(0,0,1,0)},dur,Enum.EasingStyle.Linear)
        task.delay(dur,function() tw(n,{Position=UDim2.new(1,8,0,0)},0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.In) task.wait(0.25) n:Destroy() end)
    end
    function Win:TabDivider(label)
        local d=new("Frame",{Size=UDim2.new(1,-8,0,24),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=#Win._tabs+0.5},tabList)
        local dot=new("Frame",{Size=UDim2.new(0,4,0,4),Position=UDim2.new(0,10,0.5,-2),BackgroundColor3=T.Purple,BorderSizePixel=0},d) corner(2,dot)
        new("TextLabel",{Size=UDim2.new(1,-22,1,0),Position=UDim2.new(0,20,0,0),BackgroundTransparency=1,Text=(label or ""):upper(),TextColor3=T.TextMuted,TextSize=8,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left},d)
        new("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,20,1,-1),BackgroundColor3=T.Divider,BorderSizePixel=0},d)
    end
    function Win:Tab(tabName,icon)
        local Tab={_win=Win,_name=tabName,_order=#Win._tabs+1}
        local tabBtn=new("Frame",{Size=UDim2.new(1,-6,0,32),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=Tab._order},tabList)
        local tabBg=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.PurpleDark,BackgroundTransparency=1,BorderSizePixel=0},tabBtn)
        local leftBar=new("Frame",{Size=UDim2.new(0,3,0,20),Position=UDim2.new(0,0,0.5,-10),BackgroundColor3=T.PurpleGlow,BorderSizePixel=0,Visible=false},tabBtn) corner(1,leftBar)
        local tabLbl=new("TextLabel",{Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=tabName,TextColor3=T.TextMuted,TextSize=12,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left},tabBtn)
        local scroll=new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.BG,BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.ScrollBar,CanvasSize=UDim2.new(0,0,0,0),Visible=false,TopImage="",BottomImage="",MidImage=""},content)
        local sl=new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},scroll)
        pad(16,16,14,14,scroll)
        sl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize=UDim2.new(0,0,0,sl.AbsoluteContentSize.Y+28) end)
        Tab._scroll=scroll Tab._order2=0
        local function activate()
            for _,t in ipairs(Win._tabs) do
                t._scroll.Visible=false t._leftBar.Visible=false
                tw(t._tabBg,{BackgroundTransparency=1},0.15) tw(t._tabLbl,{TextColor3=T.TextMuted},0.15) t._tabLbl.Font=F.Medium
            end
            scroll.Visible=true; scroll.Position=UDim2.new(0,10,0,0)
            tw(scroll,{Position=UDim2.new(0,0,0,0)},0.2,Enum.EasingStyle.Quint)
            leftBar.Visible=true Win._activeTab=Tab
            tw(tabBg,{BackgroundTransparency=0.78},0.15) tw(tabLbl,{TextColor3=T.TextPrimary},0.15) tabLbl.Font=F.Bold
            local items={}
            for _,c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") and c.BackgroundTransparency<0.5 then table.insert(items,c) end end
            table.sort(items,function(a,b) return a.LayoutOrder<b.LayoutOrder end)
            for i,item in ipairs(items) do
                item.BackgroundTransparency=1
                task.delay(i*0.02,function() if item.Parent then tw(item,{BackgroundTransparency=0},0.14,Enum.EasingStyle.Quint) end end)
            end
        end
        Tab._leftBar=leftBar Tab._tabBg=tabBg Tab._tabLbl=tabLbl Tab._activate=activate
        local cbt=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},tabBtn)
        cbt.MouseButton1Click:Connect(activate)
        cbt.MouseEnter:Connect(function() if Win._activeTab~=Tab then tw(tabBg,{BackgroundTransparency=0.92},0.1) tw(tabLbl,{TextColor3=T.TextSecond},0.1) end end)
        cbt.MouseLeave:Connect(function() if Win._activeTab~=Tab then tw(tabBg,{BackgroundTransparency=1},0.1) tw(tabLbl,{TextColor3=T.TextMuted},0.1) end end)
        table.insert(Win._tabs,Tab) if #Win._tabs==1 then activate() end
        function Tab:Section(label)
            Tab._order2=Tab._order2+1
            local r=new("Frame",{Size=UDim2.new(1,0,0,26),BackgroundColor3=T.BG,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll)
            local sb=new("Frame",{Size=UDim2.new(0,3,0,13),Position=UDim2.new(0,0,0.5,-6.5),BackgroundColor3=T.Purple,BorderSizePixel=0},r) corner(1,sb)
            new("TextLabel",{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,10,0,0),BackgroundColor3=T.BG,BackgroundTransparency=1,Text=label:upper(),TextColor3=T.PurpleGlow,TextSize=9,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left},r)
            new("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Divider,BorderSizePixel=0},r)
        end
        function Tab:Label(text)
            Tab._order2=Tab._order2+1
            local r=new("Frame",{Size=UDim2.new(1,0,0,20),BackgroundColor3=T.BG,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll)
            new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.BG,BackgroundTransparency=1,Text=text,TextColor3=T.TextMuted,TextSize=10,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},r)
        end
        function Tab:Spacer(h) Tab._order2=Tab._order2+1 new("Frame",{Size=UDim2.new(1,0,0,h or 6),BackgroundColor3=T.BG,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll) end
        function Tab:Toggle(label,desc,default,callback)
            Tab._order2=Tab._order2+1 local val=default or false
            local h=desc and 50 or 34
            local r=new("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=T.Card,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll)
            local rs=stroke(T.Border,1,r)
            new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.CardTop,BorderSizePixel=0,ZIndex=2},r)
            new("TextLabel",{Size=UDim2.new(1,-60,0,16),Position=UDim2.new(0,12,0,desc and 6 or 9),BackgroundTransparency=1,Text=label,TextColor3=T.TextPrimary,TextSize=12,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left},r)
            if desc then new("TextLabel",{Size=UDim2.new(1,-60,0,14),Position=UDim2.new(0,12,0,23),BackgroundTransparency=1,Text=desc,TextColor3=T.TextMuted,TextSize=10,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left},r) end
            local pill=new("Frame",{Size=UDim2.new(0,34,0,17),Position=UDim2.new(1,-46,0.5,-8.5),BackgroundColor3=val and T.Purple or T.PillOff,BorderSizePixel=0},r)
            corner(9,pill) stroke(val and T.BorderAccent or T.Border,1,pill)
            local knob=new("Frame",{Size=UDim2.new(0,11,0,11),Position=UDim2.new(val and 1 or 0,val and -14 or 3,0.5,-5.5),BackgroundColor3=val and Color3.fromRGB(255,255,255) or T.TextMuted,BorderSizePixel=0},pill)
            corner(6,knob)
            local function ref()
                tw(pill,{BackgroundColor3=val and T.Purple or T.PillOff},0.16)
                tw(knob,{Position=UDim2.new(val and 1 or 0,val and -14 or 3,0.5,-5.5)},0.16,Enum.EasingStyle.Quint)
                tw(knob,{BackgroundColor3=val and Color3.fromRGB(255,255,255) or T.TextMuted},0.14)
                tw(rs,{Color=val and T.BorderAccent or T.Border},0.14)
                if callback then pcall(callback,val) end
            end
            local btn=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},r)
            btn.MouseButton1Click:Connect(function() val=not val ref() end)
            btn.MouseEnter:Connect(function() tw(r,{BackgroundColor3=T.CardHover},0.1) end)
            btn.MouseLeave:Connect(function() tw(r,{BackgroundColor3=T.Card},0.1) end)
            local ctrl={} function ctrl:Set(v) val=v ref() end function ctrl:Get() return val end return ctrl
        end
        function Tab:Slider(label,desc,min,max,default,callback)
            Tab._order2=Tab._order2+1
            min=min or 0 max=max or 100 default=math.clamp(default or min,min,max) local val=default
            local isInt=(math.floor(min)==min and math.floor(max)==max and math.floor(default)==default)
            local r=new("Frame",{Size=UDim2.new(1,0,0,desc and 60 or 48),BackgroundColor3=T.Card,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll)
            stroke(T.Border,1,r)
            new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.CardTop,BorderSizePixel=0,ZIndex=2},r)
            new("TextLabel",{Size=UDim2.new(0.58,0,0,16),Position=UDim2.new(0,12,0,desc and 6 or 4),BackgroundTransparency=1,Text=label,TextColor3=T.TextPrimary,TextSize=12,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left},r)
            if desc then new("TextLabel",{Size=UDim2.new(0.58,0,0,13),Position=UDim2.new(0,12,0,22),BackgroundTransparency=1,Text=desc,TextColor3=T.TextMuted,TextSize=10,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left},r) end
            local function fmt(v) return isInt and tostring(math.floor(v)) or string.format("%.2f",v) end
            local valPill=new("Frame",{Size=UDim2.new(0,38,0,16),Position=UDim2.new(1,-50,0,desc and 6 or 4),BackgroundColor3=T.PurpleDark,BorderSizePixel=0},r)
            corner(3,valPill) stroke(T.BorderAccent,1,valPill)
            local vl=new("TextLabel",{Size=UDim2.new(1,-4,1,0),Position=UDim2.new(0,2,0,0),BackgroundTransparency=1,Text=fmt(val),TextColor3=T.PurpleGlow,TextSize=11,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Center},valPill)
            local tb=new("Frame",{Size=UDim2.new(1,-24,0,3),Position=UDim2.new(0,12,1,-13),BackgroundColor3=T.Divider,BorderSizePixel=0},r) corner(2,tb)
            local p0=(val-min)/(max-min)
            local tf=new("Frame",{Size=UDim2.new(p0,0,1,0),BackgroundColor3=T.Purple,BorderSizePixel=0},tb) corner(2,tf)
            new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.PurpleGlow,BackgroundTransparency=0.72,BorderSizePixel=0},tf)
            local kn=new("Frame",{Size=UDim2.new(0,13,0,13),Position=UDim2.new(p0,-6.5,0.5,-6.5),BackgroundColor3=T.PurpleGlow,BorderSizePixel=0},tb) corner(7,kn) stroke(T.BorderAccent,1,kn)
            local sliding=false
            local function upd(x)
                local p=math.clamp((x-tb.AbsolutePosition.X)/tb.AbsoluteSize.X,0,1)
                val=min+(max-min)*p if isInt then val=math.floor(val+0.5) end
                val=math.clamp(val,min,max) local p2=(val-min)/(max-min)
                tf.Size=UDim2.new(p2,0,1,0) kn.Position=UDim2.new(p2,-6.5,0.5,-6.5) vl.Text=fmt(val)
                if callback then pcall(callback,val) end
            end
            tb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true tw(kn,{Size=UDim2.new(0,16,0,16)},0.1) upd(i.Position.X) end end)
            kn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true tw(kn,{Size=UDim2.new(0,16,0,16)},0.1) end end)
            UIS.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 and sliding then sliding=false tw(kn,{Size=UDim2.new(0,13,0,13)},0.1) end end)
            r.MouseEnter:Connect(function() tw(r,{BackgroundColor3=T.CardHover},0.1) end)
            r.MouseLeave:Connect(function() tw(r,{BackgroundColor3=T.Card},0.1) end)
            local ctrl={}
            function ctrl:Set(v) val=math.clamp(v,min,max) local p2=(val-min)/(max-min) tf.Size=UDim2.new(p2,0,1,0) kn.Position=UDim2.new(p2,-6.5,0.5,-6.5) vl.Text=fmt(val) if callback then pcall(callback,val) end end
            function ctrl:Get() return val end
            return ctrl
        end
        function Tab:Button(label,desc,callback,primary)
            Tab._order2=Tab._order2+1
            local r=new("Frame",{Size=UDim2.new(1,0,0,desc and 48 or 32),BackgroundColor3=primary and T.PurpleDark or T.Card,BorderSizePixel=0,LayoutOrder=Tab._order2,ClipsDescendants=true},scroll)
            stroke(primary and T.BorderAccent or T.Border,1,r)
            new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=primary and T.BorderAccent or T.CardTop,BorderSizePixel=0,ZIndex=2},r)
            local titleLbl=new("TextLabel",{Size=UDim2.new(1,-32,0,16),Position=UDim2.new(0,12,0,desc and 6 or 8),BackgroundTransparency=1,Text=label,TextColor3=primary and T.PurpleGlow or T.TextPrimary,TextSize=12,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left},r)
            if desc then new("TextLabel",{Size=UDim2.new(1,-32,0,13),Position=UDim2.new(0,12,0,24),BackgroundTransparency=1,Text=desc,TextColor3=T.TextMuted,TextSize=10,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left},r) end
            new("TextLabel",{Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-20,0,0),BackgroundTransparency=1,Text="▸",TextColor3=primary and T.PurpleGlow or T.TextMuted,TextSize=11,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Center},r)
            local btn=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},r)
            btn.MouseButton1Click:Connect(function()
                local mp=UIS:GetMouseLocation(); local rp=mp-r.AbsolutePosition
                local ripple=new("Frame",{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0,rp.X,0,rp.Y),BackgroundColor3=T.Purple,BackgroundTransparency=0.65,BorderSizePixel=0,ZIndex=6},r)
                corner(50,ripple)
                tw(ripple,{Size=UDim2.new(0,160,0,160),Position=UDim2.new(0,rp.X-80,0,rp.Y-80),BackgroundTransparency=1},0.45,Enum.EasingStyle.Quad)
                task.delay(0.45,function() ripple:Destroy() end)
                tw(r,{BackgroundColor3=primary and T.PurpleDim or T.CardHover},0.08)
                task.delay(0.15,function() tw(r,{BackgroundColor3=primary and T.PurpleDark or T.Card},0.15) end)
                if callback then pcall(callback) end
            end)
            btn.MouseEnter:Connect(function() tw(r,{BackgroundColor3=primary and T.PurpleDim or T.CardHover},0.1) end)
            btn.MouseLeave:Connect(function() tw(r,{BackgroundColor3=primary and T.PurpleDark or T.Card},0.1) end)
            local ctrl={}
            function ctrl:SetLabel(t) titleLbl.Text=t end
            function ctrl:SetColor(c) titleLbl.TextColor3=c end
            return ctrl
        end
        return Tab
    end
    return Win
end

-- ═══════════════════════════════════════════════════════
--  DBSB.su | Bite by Night
--  ESP, Auto Farm, Player Mods
--  RightAlt to toggle UI
-- ═══════════════════════════════════════════════════════
if game.PlaceId ~= 70845479499574 then error("Wrong game") return end

-- ── Services ──────────────────────────────
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local RS         = game:GetService("ReplicatedStorage")
local lp         = Players.LocalPlayer

-- ── State ─────────────────────────────────
local cfg = {
    EspSurvivors      = false,
    EspKillers        = false,
    EspGenerators     = false,
    EspFuseBoxes      = false,
    EspBattery        = false,
    EspTraps          = false,
    EspWireEyes       = false,
    EspDistance       = false,
    EspTracers        = false,
    EspDisableLimit   = false,
    EspRange          = 100,

    AutoGenerator     = false,
    AutoBarricade     = false,
    AutoEscape        = false,
    AutoParry         = false,
    InstantPrompt     = false,
    BigPrompt         = false,
    AutoShakeWireEyes = false,
    NoBlindness       = false,
    InfiniteStamina   = false,
    HealWhileMoving   = false,
    HealMoveSpeed     = 20,
    AntiStun          = false,
    StunMoveSpeed     = 16,
    WalkSpeedBind     = Enum.KeyCode.E,
    WalkSpeedEnabled  = false,
    MoonwalkEnabled   = false,
    MoonwalkBind      = Enum.KeyCode.Z,
    MoonwalkSpeed     = 20,
    SpinSpeed         = 15,
    UndergroundEnabled = false,
    UndergroundActive  = false,
    UndergroundBind   = Enum.KeyCode.X,
    UndergroundDepth  = 8,
}

-- ── ESP cache + helpers ────────────────────
local ESPs      = {}
local Camera    = workspace.CurrentCamera
local SavedCFrame = nil
local Teleported  = false
local CanParry    = true
local CanShake    = true

task.spawn(function()
    while true do task.wait()
        if workspace.CurrentCamera then Camera = workspace.CurrentCamera end
    end
end)

local function CreateEsp(char, color, text, part)
    if not char or not part then return end
    -- remove existing
    local existing = char:FindFirstChildOfClass("Highlight")
    if existing then existing:Destroy() end
    local existingBB = part:FindFirstChild("ESP")
    if existingBB then existingBB:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.Adornee = char
    hl.FillColor = color
    hl.FillTransparency = 1
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false
    hl.Parent = char

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP"
    bb.Size = UDim2.new(10,0,2.5,0)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0,-2,0)
    bb.Adornee = part
    bb.Enabled = false
    bb.Parent = part

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextScaled = false
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Code
    lbl.TextStrokeTransparency = 0.4
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = bb

    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = color
    line.Thickness = 1.5
    line.Transparency = 1

    table.insert(ESPs, {
        Char=char, Highlight=hl, Billboard=bb,
        Label=lbl, Part=part, Line=line,
        Text=text, Color=color
    })
end

local function RemoveEsp(char, part)
    for i=#ESPs,1,-1 do
        local e=ESPs[i]
        if e.Char==char then
            pcall(function() e.Highlight:Destroy() end)
            pcall(function() e.Billboard:Destroy() end)
            pcall(function() e.Line:Remove() end)
            table.remove(ESPs,i)
        end
    end
end

local function SetupCharacterEsp(child, folder, part)
    if not child:IsA("Model") then return end
    child.AncestryChanged:Connect(function()
        if not child:IsDescendantOf(folder) then
            RemoveEsp(child, part)
        end
    end)
end

local function clearEspGroup(folder, partName)
    for _,v in pairs(folder:GetChildren()) do
        if v:IsA("Model") then
            local p = partName and v:FindFirstChild(partName) or v.PrimaryPart
            if p then RemoveEsp(v, p) end
        end
    end
end

-- ── RenderStepped ESP update ───────────────
RunService.RenderStepped:Connect(function()
    if not Camera then return end
    local camPos = Camera.CFrame.Position
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)

    for _,e in ipairs(ESPs) do
        local part = e.Part
        if not part or not part.Parent then
            if e.Line then e.Line.Visible = false end
        else
            local dist = (camPos - part.Position).Magnitude
            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
            local inRange = cfg.EspDisableLimit or dist <= cfg.EspRange

            e.Highlight.Enabled = inRange and onScreen
            e.Billboard.Enabled = inRange and onScreen
            e.Label.Text = cfg.EspDistance and (e.Text.." ("..math.floor(dist+0.5).."m)") or e.Text

            if cfg.EspTracers and onScreen and inRange then
                e.Line.Visible = true
                e.Line.From = screenCenter
                e.Line.To = Vector2.new(sp.X, sp.Y)
            else
                e.Line.Visible = false
            end
        end
    end
end)

-- ── Game helpers ──────────────────────────
local function getMap()
    return workspace.MAPS:FindFirstChild("GAME MAP")
end

local function getNewestDot()
    for _,child in ipairs(lp.PlayerGui:GetChildren()) do
        if child.Name=="Dot" then return child end
    end
end

local function doShakeWireEyes(wui)
    task.spawn(function()
        local wc = wui:FindFirstChild("WireyesClient")
        if wc then
            local remote = wc:FindFirstChild("WireyesEvent")
            if remote then
                CanShake = false
                task.spawn(function() task.wait(0.5); CanShake = true end)
                pcall(function() remote:FireServer("Shaking") end)
                task.wait(0.05)
                pcall(function() remote:FireServer("TakeOff", workspace:GetServerTimeNow()) end)
            end
        end
    end)
end

-- ── Main game loop ────────────────────────
RunService.RenderStepped:Connect(function()
    if not lp.Character then return end
    local char = lp.Character
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")

    -- Auto Barricade
    if cfg.AutoBarricade then
        local dot = getNewestDot()
        if dot then
            local container = dot:FindFirstChild("Container")
            if container then
                local frame = container:FindFirstChild("Frame")
                local box   = container:FindFirstChild("Box")
                if frame and box then
                    local ba = box.AbsolutePosition
                    local bs = box.AbsoluteSize
                    local ca = container.AbsolutePosition
                    frame.Position = UDim2.new(0,(ba.X+bs.X*0.5)-ca.X,0,(ba.Y+bs.Y*0.5)-ca.Y)
                end
            end
        end
    end

    -- Infinite Stamina
    if cfg.InfiniteStamina then
        local mx = char:GetAttribute("MaxStamina") or 100
        if (char:GetAttribute("Stamina") or mx) < mx then
            char:SetAttribute("Stamina", mx)
        end
    end

    -- Heal while moving — inject BodyVelocity while heal anim plays
    if cfg.HealWhileMoving and hum and hrp then
        local animator = hum:FindFirstChildOfClass("Animator")
        local healing = false
        if animator then
            for _,track in pairs(animator:GetPlayingAnimationTracks()) do
                if track.Animation
                    and track.Animation.AnimationId == "rbxassetid://140498597133326"
                    and track.IsPlaying
                then
                    -- use TimePosition > 0.1 to avoid triggering at very start/end blip
                    -- and WeightCurrent > 0 to detect it's actually influencing the character
                    if track.TimePosition > 0.1 and track.WeightCurrent > 0.01 then
                        healing = true
                    end
                    break
                end
            end
        end
        local bv = hrp:FindFirstChild("DBSB_HealVelocity")
        if healing then
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "DBSB_HealVelocity"
                bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                bv.P = 1e4
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hrp
            end
            local moveDir = hum.MoveDirection
            local spd = cfg.WalkSpeedEnabled and UIS:IsKeyDown(cfg.WalkSpeedBind)
                and math.min(cfg.WalkSpeed, 30) or cfg.HealMoveSpeed
            bv.Velocity = moveDir * spd
        else
            if bv then bv:Destroy() end
        end
    else
        if lp.Character then
            local hrp2 = lp.Character:FindFirstChild("HumanoidRootPart")
            local bv = hrp2 and hrp2:FindFirstChild("DBSB_HealVelocity")
            if bv then bv:Destroy() end
        end
    end

    -- Anti Stun — inject BodyVelocity while stun/tase animation plays
    if cfg.AntiStun and hum and hrp then
        local animator = hum:FindFirstChildOfClass("Animator")
        local stunned = false
        if animator then
            for _,track in pairs(animator:GetPlayingAnimationTracks()) do
                if track.Animation and track.IsPlaying and track.WeightCurrent > 0.01 then
                    local id = track.Animation.AnimationId
                    -- tase stun anim (confirmed from dump)
                    if id == "rbxassetid://72376427571966" then
                        stunned = true
                        break
                    end
                end
            end
        end
        local bv = hrp:FindFirstChild("DBSB_StunVelocity")
        if stunned then
            -- remove lunge velocity so they don't conflict
            local lungeBv = hrp:FindFirstChild("DBSB_LungeVelocity")
            if lungeBv then lungeBv:Destroy() end
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "DBSB_StunVelocity"
                bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                bv.P = 1e4
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hrp
            end
            local moveDir = hum.MoveDirection
            bv.Velocity = moveDir * (cfg.StunMoveSpeed or 16)
        else
            if bv then bv:Destroy() end
        end
    else
        if lp.Character then
            local hrp2 = lp.Character:FindFirstChild("HumanoidRootPart")
            local bv = hrp2 and hrp2:FindFirstChild("DBSB_StunVelocity")
            if bv then bv:Destroy() end
        end
    end

    -- Auto Shake Wire Eyes
    if cfg.AutoShakeWireEyes and CanShake then
        local wui = lp.PlayerGui:FindFirstChild("WireyesUI")
        if wui then doShakeWireEyes(wui) end
    end

    if cfg.NoBlindness then
        pcall(function()
            local gameUI = lp.PlayerGui:FindFirstChild("GameUIContainer", true)
            if not gameUI then return end
            local vig = gameUI:FindFirstChild("Vignette")
            if vig then vig:Destroy() end
            local blood = gameUI:FindFirstChild("Blood")
            if blood then blood:Destroy() end
        end)
    end

    -- Walk Speed / Moonwalk — unified so they don't fight each other
    if hum then
        local moonwalkActive = cfg.MoonwalkEnabled and hrp and UIS:IsKeyDown(cfg.MoonwalkBind)
        local speedActive = cfg.WalkSpeedEnabled and UIS:IsKeyDown(cfg.WalkSpeedBind)

        if moonwalkActive then
            -- flip HRP away from camera
            local camCF = workspace.CurrentCamera.CFrame
            local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position - flatLook)
            char:SetAttribute("WalkSpeed", cfg.MoonwalkSpeed)
        elseif speedActive then
            char:SetAttribute("WalkSpeed", math.min(cfg.WalkSpeed, 30))
        elseif cfg.WalkSpeedEnabled or cfg.MoonwalkEnabled then
            -- only restore if one of them is enabled, avoid overwriting other systems
            char:SetAttribute("WalkSpeed", 12)
        end
    end

    -- Underground — keep transparency while underground (lightweight check only)
    if cfg.UndergroundActive and char then
        for _,p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.LocalTransparencyModifier ~= 1 then
                p.LocalTransparencyModifier = 1
            end
        end
    end



    -- Auto Generator
    if cfg.AutoGenerator then
        local genGui = lp.PlayerGui:FindFirstChild("Gen")
        if genGui then
            pcall(function() genGui.GeneratorMain.Event:FireServer(true) end)
        end
    end

    -- Auto Escape
    if cfg.AutoEscape and not Teleported and hrp then
        pcall(function()
            if workspace.GAME.CAN_ESCAPE.Value == true then
                local map = getMap()
                if map and char.Parent == workspace.PLAYERS.ALIVE then
                    for _,p in pairs(map.Escapes:GetChildren()) do
                        if p:IsA("BasePart") and p:GetAttribute("Enabled") then
                            local hl = p:FindFirstChildOfClass("Highlight")
                            if hl and hl.Enabled then
                                Teleported = true
                                hrp.Anchored = true
                                char.PrimaryPart.CFrame = p.CFrame
                                task.spawn(function()
                                    task.wait(0.15)
                                    hrp.Anchored = false
                                end)
                                task.wait(10)
                                Teleported = false
                            end
                        end
                    end
                end
            end
        end)
    end
end)


-- ── Underground — teleport on keypress ────
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe or not cfg.UndergroundEnabled then return end
    if inp.KeyCode ~= cfg.UndergroundBind then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    cfg.UndergroundActive = true
    cfg._surfaceY = hrp.Position.Y  -- save surface Y before going under
    hrp.CFrame = CFrame.new(hrp.Position.X, -(cfg.UndergroundDepth), hrp.Position.Z)
end)

UIS.InputEnded:Connect(function(inp)
    if inp.KeyCode ~= cfg.UndergroundBind then return end
    if not cfg.UndergroundActive then return end
    cfg.UndergroundActive = false
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(hrp.Position.X, cfg._surfaceY or 3, hrp.Position.Z)
    for _,p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
    end
end)

-- ── DescendantAdded — ESP + mechanics ─────
workspace.DescendantAdded:Connect(function(child)
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")

    -- Auto Parry (Fighter)
    if child:IsA("BoxHandleAdornment") and hrp and CanParry then
        local c = char
        if cfg.AutoParry
            and not c:GetAttribute("IFrames")
            and not c:GetAttribute("InAbility")
            and not c:GetAttribute("Stun")
            and c:GetAttribute("Team")=="Survivor"
            and c:GetAttribute("Character")=="Survivor-Fighter"
        then
            if (child.CFrame.Position - hrp.Position).Magnitude <= 10 then
                CanParry = false
                task.spawn(function()
                    task.spawn(function() task.wait(0.5); CanParry = true end)
                    local ok, Module = pcall(function()
                        return require(RS.Modules.Warp).Client("Input")
                    end)
                    if ok and Module then
                        Module:Fire(true,{"Ability",2})
                    end
                end)
            end
        end
    end

    task.wait(0.75)

    -- Instant Prompt on new prompts
    if cfg.InstantPrompt then
        if child:IsA("ProximityPrompt") and child.HoldDuration ~= 0.1 then
            child:SetAttribute("HoldDurationOld", child.HoldDuration)
            child.HoldDuration = 0.1
        end
    end

    -- ESP on new survivors
    if cfg.EspSurvivors then
        if child.Parent==workspace.PLAYERS.ALIVE and child:IsA("Model") and child.PrimaryPart
            and not child.PrimaryPart:FindFirstChild("ESP")
        then
            local p = Players:GetPlayerFromCharacter(child)
            if p then
                SetupCharacterEsp(child, workspace.PLAYERS.ALIVE, child.PrimaryPart)
                CreateEsp(child, Color3.fromRGB(0,255,0), child.Name, child.PrimaryPart)
            end
        end
    end

    -- ESP on new killers
    if cfg.EspKillers then
        if child.Parent==workspace.PLAYERS.KILLER and child:IsA("Model") and child:FindFirstChild("RootPart")
            and not child.RootPart:FindFirstChild("ESP")
        then
            local p = Players:GetPlayerFromCharacter(child)
            if p then
                SetupCharacterEsp(child, workspace.PLAYERS.KILLER, child.RootPart)
                CreateEsp(child, Color3.fromRGB(255,0,0), child.Name, child.RootPart)
            end
        end
    end

    -- ESP on new generators
    if cfg.EspGenerators then
        local map = getMap()
        if map and child.Parent==map.Generators and child:IsA("Model") and child.PrimaryPart
            and not child.PrimaryPart:FindFirstChild("ESP")
        then
            CreateEsp(child, Color3.fromRGB(255,255,0), "Generator", child.PrimaryPart)
        end
    end

    -- ESP on new fuse boxes
    if cfg.EspFuseBoxes then
        local map = getMap()
        if map and map:FindFirstChild("FuseBoxes") and child.Parent==map.FuseBoxes
            and child:IsA("Model") and child.PrimaryPart and not child.PrimaryPart:FindFirstChild("ESP")
        then
            CreateEsp(child, Color3.fromRGB(0,100,255), "Fuse Box", child.PrimaryPart)
        end
    end

    -- ESP on new traps
    if cfg.EspTraps then
        if child.Parent==workspace.IGNORE and child.Name=="Trap" and child:IsA("Model")
            and child.PrimaryPart and not child.PrimaryPart:FindFirstChild("ESP")
        then
            CreateEsp(child, Color3.fromRGB(255,50,50), "Trap", child.PrimaryPart)
        end
    end

    -- ESP on new wire eyes
    if cfg.EspWireEyes then
        if child.Parent==workspace.IGNORE and child.Name=="Minion" and child:IsA("Model")
            and child.PrimaryPart and not child.PrimaryPart:FindFirstChild("ESP")
        then
            SetupCharacterEsp(child, workspace.IGNORE, child.PrimaryPart)
            CreateEsp(child, Color3.fromRGB(255,0,200), "Wire Eyes", child.PrimaryPart)
        end
    end

    -- ESP on new batteries
    if cfg.EspBattery then
        if child.Parent==workspace.IGNORE and child.Name=="Battery" and child:IsA("BasePart")
            and not child:FindFirstChild("ESP")
        then
            CreateEsp(child, Color3.fromRGB(0,200,255), "Battery", child)
        end
    end
end)

-- ── DescendantRemoving — cleanup ESP ──────
workspace.DescendantRemoving:Connect(function(child)
    if child:IsA("Model") then
        if cfg.EspSurvivors and child:IsDescendantOf(workspace.PLAYERS.ALIVE) and child.PrimaryPart then
            RemoveEsp(child, child.PrimaryPart)
        end
        if cfg.EspKillers and child:IsDescendantOf(workspace.PLAYERS.KILLER) and child:FindFirstChild("RootPart") then
            RemoveEsp(child, child.RootPart)
        end
        local map = getMap()
        if map then
            if cfg.EspGenerators and child:IsDescendantOf(map.Generators) and child.PrimaryPart then
                RemoveEsp(child, child.PrimaryPart)
            end
            if cfg.EspFuseBoxes and map:FindFirstChild("FuseBoxes") and child:IsDescendantOf(map.FuseBoxes) and child.PrimaryPart then
                RemoveEsp(child, child.PrimaryPart)
            end
        end
        if cfg.EspTraps and child:IsDescendantOf(workspace.IGNORE) and child.Name=="Trap" and child.PrimaryPart then
            RemoveEsp(child, child.PrimaryPart)
        end
        if cfg.EspWireEyes and child:IsDescendantOf(workspace.IGNORE) and child.Name=="Minion" and child.PrimaryPart then
            RemoveEsp(child, child.PrimaryPart)
        end
    elseif child:IsA("BasePart") then
        if cfg.EspBattery and child:IsDescendantOf(workspace.IGNORE) and child.Name=="Battery" then
            RemoveEsp(child, child)
        end
    end
end)

-- ── Instant prompt — existing prompts ─────
local function applyInstantPrompts(state)
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            if state then
                if v.HoldDuration ~= 0.1 then
                    v:SetAttribute("HoldDurationOld", v.HoldDuration)
                    v.HoldDuration = 0.1
                end
            else
                local old = v:GetAttribute("HoldDurationOld")
                if old and old ~= 0 then v.HoldDuration = old end
            end
        end
    end
end

-- ── Bind setter helper ────────────────────
-- Single button element — shows current key, click to remap
local bindListening = false
local function makeBindSetter(tab, cfgTable, cfgKey, name)
    local ctrl
    ctrl = tab:Button(name..":  [ "..cfgTable[cfgKey].Name.." ]", "Click to remap", function()
        if bindListening then return end
        bindListening = true
        ctrl:SetLabel(name..":  [ press a key... ]")
        ctrl:SetColor(Color3.fromRGB(180,100,255))
        task.spawn(function()
            task.wait(0.2)
            local conn
            conn = UIS.InputBegan:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if inp.KeyCode == Enum.KeyCode.Unknown then return end
                bindListening = false
                cfgTable[cfgKey] = inp.KeyCode
                ctrl:SetLabel(name..":  [ "..inp.KeyCode.Name.." ]")
                ctrl:SetColor(Color3.fromRGB(220,220,235))
                conn:Disconnect()
            end)
        end)
    end)
end

-- ── UI ────────────────────────────────────
local UI = Library:Window("DBSB.su", "Bite by Night")

-- ── ESP Tab ───────────────────────────────
UI:TabDivider("Visual")
local espTab = UI:Tab("ESP", "//")

espTab:Section("Players")
espTab:Toggle("Survivors", "Green highlight on survivors", false, function(v)
    cfg.EspSurvivors = v
    if v then
        pcall(function()
            for _,p in pairs(workspace.PLAYERS.ALIVE:GetChildren()) do
                if p:IsA("Model") and p.PrimaryPart and not p.PrimaryPart:FindFirstChild("ESP") then
                    SetupCharacterEsp(p, workspace.PLAYERS.ALIVE, p.PrimaryPart)
                    CreateEsp(p, Color3.fromRGB(0,255,0), p.Name, p.PrimaryPart)
                end
            end
        end)
    else
        pcall(function() clearEspGroup(workspace.PLAYERS.ALIVE, nil) end)
    end
end)

espTab:Toggle("Killers", "Red highlight on killers", false, function(v)
    cfg.EspKillers = v
    if v then
        pcall(function()
            for _,p in pairs(workspace.PLAYERS.KILLER:GetChildren()) do
                if p:IsA("Model") and p:FindFirstChild("RootPart") and not p.RootPart:FindFirstChild("ESP") then
                    SetupCharacterEsp(p, workspace.PLAYERS.KILLER, p.RootPart)
                    CreateEsp(p, Color3.fromRGB(255,0,0), p.Name, p.RootPart)
                end
            end
        end)
    else
        pcall(function() clearEspGroup(workspace.PLAYERS.KILLER, "RootPart") end)
    end
end)

espTab:Section("Map Objects")
espTab:Toggle("Generators", "Yellow highlight on generators", false, function(v)
    cfg.EspGenerators = v
    if v then
        pcall(function()
            local map = getMap()
            if not map then return end
            for _,p in pairs(map.Generators:GetChildren()) do
                if p:IsA("Model") and p.PrimaryPart and not p.PrimaryPart:FindFirstChild("ESP") then
                    CreateEsp(p, Color3.fromRGB(255,255,0), "Generator", p.PrimaryPart)
                end
            end
        end)
    else
        pcall(function()
            local map = getMap()
            if map then clearEspGroup(map.Generators, nil) end
        end)
    end
end)

espTab:Toggle("Fuse Boxes", "Blue highlight on fuse boxes", false, function(v)
    cfg.EspFuseBoxes = v
    if v then
        pcall(function()
            local map = getMap()
            if not map or not map:FindFirstChild("FuseBoxes") then return end
            for _,p in pairs(map.FuseBoxes:GetChildren()) do
                if p:IsA("Model") and p.PrimaryPart and not p.PrimaryPart:FindFirstChild("ESP") then
                    CreateEsp(p, Color3.fromRGB(0,100,255), "Fuse Box", p.PrimaryPart)
                end
            end
        end)
    else
        pcall(function()
            local map = getMap()
            if map and map:FindFirstChild("FuseBoxes") then clearEspGroup(map.FuseBoxes, nil) end
        end)
    end
end)

espTab:Toggle("Batteries", "Cyan highlight on batteries", false, function(v)
    cfg.EspBattery = v
    if v then
        pcall(function()
            for _,p in pairs(workspace.IGNORE:GetChildren()) do
                if p:IsA("BasePart") and p.Name=="Battery" and not p:FindFirstChild("ESP") then
                    CreateEsp(p, Color3.fromRGB(0,200,255), "Battery", p)
                end
            end
        end)
    else
        pcall(function()
            for _,p in pairs(workspace.IGNORE:GetChildren()) do
                if p:IsA("BasePart") and p.Name=="Battery" then RemoveEsp(p, p) end
            end
        end)
    end
end)

espTab:Toggle("Traps", "Red highlight on traps", false, function(v)
    cfg.EspTraps = v
    if v then
        pcall(function()
            for _,p in pairs(workspace.IGNORE:GetChildren()) do
                if p:IsA("Model") and p.Name=="Trap" and p.PrimaryPart and not p.PrimaryPart:FindFirstChild("ESP") then
                    CreateEsp(p, Color3.fromRGB(255,50,50), "Trap", p.PrimaryPart)
                end
            end
        end)
    else
        pcall(function()
            for _,p in pairs(workspace.IGNORE:GetChildren()) do
                if p:IsA("Model") and p.Name=="Trap" and p.PrimaryPart then RemoveEsp(p, p.PrimaryPart) end
            end
        end)
    end
end)

espTab:Toggle("Wire Eyes", "Purple highlight on Wire Eyes", false, function(v)
    cfg.EspWireEyes = v
    if v then
        pcall(function()
            for _,p in pairs(workspace.IGNORE:GetChildren()) do
                if p:IsA("Model") and p.Name=="Minion" and p.PrimaryPart and not p.PrimaryPart:FindFirstChild("ESP") then
                    SetupCharacterEsp(p, workspace.IGNORE, p.PrimaryPart)
                    CreateEsp(p, Color3.fromRGB(255,0,200), "Wire Eyes", p.PrimaryPart)
                end
            end
        end)
    else
        pcall(function()
            for _,p in pairs(workspace.IGNORE:GetChildren()) do
                if p:IsA("Model") and p.Name=="Minion" and p.PrimaryPart then RemoveEsp(p, p.PrimaryPart) end
            end
        end)
    end
end)

espTab:Section("ESP Settings")
espTab:Toggle("Show Distance", "Show distance in ESP labels", false, function(v) cfg.EspDistance = v end)
espTab:Toggle("Tracers", "Draw lines from screen bottom to entities", false, function(v) cfg.EspTracers = v end)
espTab:Toggle("Disable Range Limit", "Show ESP at any distance", false, function(v) cfg.EspDisableLimit = v end)
espTab:Slider("ESP Range", "Max distance to show ESP", 25, 1000, 100, function(v) cfg.EspRange = v end)

-- ── Main Tab ──────────────────────────────
UI:TabDivider("Game")
local survivorTab = UI:Tab("Survivor", "//")

survivorTab:Section("Auto Actions")
survivorTab:Toggle("Auto Generator", "Auto complete generator minigame", false, function(v) cfg.AutoGenerator = v end)
survivorTab:Toggle("Auto Barricade", "Auto solve barricade timing minigame", false, function(v) cfg.AutoBarricade = v end)
survivorTab:Toggle("Auto Escape", "Teleport to escape zone when available", false, function(v) cfg.AutoEscape = v end)
survivorTab:Toggle("Auto Shake Wire Eyes", "Auto shake Wire Eyes off you", false, function(v) cfg.AutoShakeWireEyes = v end)

survivorTab:Section("Combat")
survivorTab:Toggle("Fighter Auto Parry", "Auto parry killer attacks (Fighter only)", false, function(v) cfg.AutoParry = v end)

survivorTab:Section("Utility")
survivorTab:Toggle("Instant Prompt", "Set all proximity prompts to 0.1s hold", false, function(v)
    cfg.InstantPrompt = v
    task.spawn(function() applyInstantPrompts(v) end)
end)
survivorTab:Toggle("Big Distance Prompt", "Extend proximity prompt trigger distance", false, function(v)
    cfg.BigPrompt = v
    task.spawn(function()
        for _,a in pairs(workspace:GetDescendants()) do
            if a:IsA("ProximityPrompt") then
                a.MaxActivationDistance = v and 50 or 10
            end
        end
    end)
end)
survivorTab:Toggle("No Blindness", "Remove blindness overlay", false, function(v) cfg.NoBlindness = v end)
survivorTab:Button("Delete Doors", "Remove all map doors", function()
    pcall(function()
        local map = getMap()
        if map and map:FindFirstChild("Doors") then
            map.Doors:Destroy()
            UI:Notify("BBN", "Doors deleted", 2)
        end
    end)
end)

-- ── Killer Tab ────────────────────────────
UI:TabDivider("Killer")
local killerTab = UI:Tab("Killer", "//")

killerTab:Section("Attack")

killerTab:Section("Defense")
killerTab:Toggle("Anti Stun", "Move freely while stunned/tased", false, function(v) cfg.AntiStun = v end)
killerTab:Slider("Stun Move Speed", "Speed while stunned", 5, 40, 16, function(v) cfg.StunMoveSpeed = v end)

-- ── Player Tab ────────────────────────────
UI:TabDivider("Player")
local playerTab = UI:Tab("Player", "//")

playerTab:Section("Underground")
playerTab:Toggle("Underground", "Hold bind to sink below map — invisible to others", false, function(v)
    cfg.UndergroundEnabled = v
    if not v then
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and char then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, cfg.UndergroundDepth, 0)
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
            end
        end
    end
end)
playerTab:Slider("Depth", "How far underground (studs)", 2, 20, 8, function(v) cfg.UndergroundDepth = v end)
makeBindSetter(playerTab, cfg, "UndergroundBind", "Underground Bind")
playerTab:Slider("Walk Speed Value", "Speed while holding bind (max 30)", 0, 30, 15, function(v) cfg.WalkSpeed = v end)
playerTab:Toggle("Walk Speed Enabled", "Toggle on/off — hold bind to activate", false, function(v)
    cfg.WalkSpeedEnabled = v
    if not v then
        local char = lp.Character
        if char then char:SetAttribute("WalkSpeed", 12) end
    end
end)
makeBindSetter(playerTab, cfg, "WalkSpeedBind", "Speed Bind")

playerTab:Section("Moonwalk")
playerTab:Toggle("Moonwalk", "Hold bind to moonwalk — faces character away from camera", false, function(v)
    cfg.MoonwalkEnabled = v
    if not v then
        local char = lp.Character
        if char then char:SetAttribute("WalkSpeed", 12) end
    end
end)
playerTab:Slider("Moonwalk Speed", "Speed while moonwalking", 10, 60, 20, function(v) cfg.MoonwalkSpeed = v end)
makeBindSetter(playerTab, cfg, "MoonwalkBind", "Moonwalk Bind")

playerTab:Section("Stats")
playerTab:Toggle("Infinite Stamina", "Keep stamina maxed out", false, function(v) cfg.InfiniteStamina = v end)
playerTab:Toggle("Heal While Moving", "Move freely during heal animation", false, function(v) cfg.HealWhileMoving = v end)
playerTab:Slider("Heal Move Speed", "Speed while healing (default 20)", 5, 50, 20, function(v) cfg.HealMoveSpeed = v end)

playerTab:Section("Spin")
local spinActive = false
local spinConn = nil
local spinAngle = 0
playerTab:Toggle("Spin", "Rapidly spin your character (works in shift lock)", false, function(v)
    spinActive = v
    if v then
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        spinAngle = 0
        if spinConn then spinConn:Disconnect() end
        spinConn = RunService.RenderStepped:Connect(function()
            if not spinActive then spinConn:Disconnect(); spinConn = nil return end
            char = lp.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            spinAngle = (spinAngle + cfg.SpinSpeed) % 360
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
        end)
    else
        if spinConn then spinConn:Disconnect(); spinConn = nil end
    end
end)
playerTab:Slider("Spin Speed", "Degrees per frame", 5, 45, 15, function(v) cfg.SpinSpeed = v end)

-- ── Animation Player ──────────────────

task.wait(1)
UI:Notify("DBSB.su", "Bite by Night loaded // RightAlt to toggle", 4)

-- ── Player List Tab ───────────────────────
UI:TabDivider("Player List")
local playersTab = UI:Tab("Player List", "//")

-- troll state
local trollTarget = nil
local trollConn = nil
local spectateConn = nil
local savedPos = nil

local function stopAllTroll()
    if trollConn then trollConn:Disconnect(); trollConn = nil end
    if spectateConn then spectateConn:Disconnect(); spectateConn = nil end
    pcall(function()
        local cam = workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    end)
    if savedPos then
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = savedPos end
        savedPos = nil
    end
end

local function getTargetHRP()
    if not trollTarget then return nil end
    local char = trollTarget.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ── Custom player list UI ─────────────────
local scroll = playersTab._scroll
local selectedCard = nil

local function getTeamColor(team)
    team = (team or ""):lower()
    if team == "killer" then return T.Red
    elseif team == "survivor" then return T.Green
    else return T.TextMuted end
end

local function getTeamLabel(team)
    team = (team or ""):lower()
    if team == "killer" then return "killer"
    elseif team == "survivor" then return "survivor"
    else return "lobby" end
end

local playerCards = {}

-- persistent container inserted BEFORE actions section at a fixed order
playersTab._order2 = playersTab._order2 + 1
local listContainer = new("Frame",{
    Size=UDim2.new(1,0,0,0),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    LayoutOrder=playersTab._order2,
    AutomaticSize=Enum.AutomaticSize.Y,
},playersTab._scroll)
new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},listContainer)

local function buildPlayerList()
    -- clear only the container children
    for _,f in pairs(playerCards) do pcall(function() f:Destroy() end) end
    playerCards = {}
    for _,c in pairs(listContainer:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end

    local playerList = Players:GetPlayers()
    local hasOthers = false
    for _,p in ipairs(playerList) do
        if p ~= lp then hasOthers = true break end
    end

    if not hasOthers then
        local none = new("Frame",{
            Size=UDim2.new(1,0,0,36),BackgroundColor3=T.Card,BorderSizePixel=0,LayoutOrder=1
        },listContainer)
        corner(6,none) stroke(T.Border,1,none)
        new("TextLabel",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            Text="// no other players in server",
            TextColor3=T.TextMuted,TextSize=11,Font=F.Medium,
            TextXAlignment=Enum.TextXAlignment.Center
        },none)
        return
    end

    for i,p in ipairs(playerList) do
        if p ~= lp then
            local char = p.Character
            local team = char and char:GetAttribute("Team") or "Lobby"
            local teamCol = getTeamColor(team)
            local teamLbl = getTeamLabel(team)

            local card = new("Frame",{
                Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Card,
                BorderSizePixel=0,LayoutOrder=i
            },listContainer)
            corner(6,card)
            local cStroke = stroke(T.Border,1,card)
            new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.CardTop,BorderSizePixel=0,ZIndex=2},card)

            -- team color bar
            local bar = new("Frame",{
                Size=UDim2.new(0,3,1,-8),Position=UDim2.new(0,0,0,4),
                BackgroundColor3=teamCol,BorderSizePixel=0,ZIndex=3
            },card)
            corner(2,bar)

            -- player name
            new("TextLabel",{
                Size=UDim2.new(1,-80,0,18),Position=UDim2.new(0,14,0,8),
                BackgroundTransparency=1,Text=p.Name,
                TextColor3=T.TextPrimary,TextSize=12,Font=F.Bold,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3
            },card)

            -- team badge
            local badge = new("Frame",{
                Size=UDim2.new(0,56,0,14),Position=UDim2.new(1,-66,0,10),
                BackgroundColor3=T.PurpleDark,BorderSizePixel=0,ZIndex=3
            },card)
            corner(3,badge)
            stroke(teamCol,1,badge)
            new("TextLabel",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text=teamLbl,TextColor3=teamCol,TextSize=9,Font=F.Bold,
                TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4
            },badge)

            -- selected dot + label (vertically centered together)
            local selDot = new("Frame",{
                Size=UDim2.new(0,6,0,6),
                Position=UDim2.new(0,14,1,-16),
                BackgroundColor3=T.PurpleGlow,BorderSizePixel=0,ZIndex=3,Visible=false
            },card)
            corner(3,selDot)
            new("TextLabel",{
                Size=UDim2.new(1,-28,0,12),
                Position=UDim2.new(0,24,1,-19),
                BackgroundTransparency=1,Text="selected",
                TextColor3=T.TextMuted,TextSize=9,Font=F.Medium,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3,Visible=false,
                Name="SelLabel"
            },card)

            local btn = new("TextButton",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5
            },card)

            btn.MouseEnter:Connect(function()
                if trollTarget ~= p then tw(card,{BackgroundColor3=T.CardHover},0.1) end
            end)
            btn.MouseLeave:Connect(function()
                if trollTarget ~= p then tw(card,{BackgroundColor3=T.Card},0.1) end
            end)

            btn.MouseButton1Click:Connect(function()
                if selectedCard then
                    tw(selectedCard.card,{BackgroundColor3=T.Card},0.15)
                    pcall(function() selectedCard.card:FindFirstChild("SelLabel").Visible=false end)
                    pcall(function() selectedCard.dot.Visible=false end)
                    pcall(function() tw(selectedCard.cStroke,{Color=T.Border},0.15) end)
                end
                trollTarget = p
                selectedCard = {card=card, dot=selDot, cStroke=cStroke}
                tw(card,{BackgroundColor3=Color3.fromRGB(28,18,52)},0.15)
                tw(cStroke,{Color=T.BorderAccent},0.15)
                selDot.Visible = true
                card:FindFirstChild("SelLabel").Visible = true
                UI:Notify("Player List", p.Name.." // "..teamLbl, 2)
            end)

            table.insert(playerCards, card)
        end
    end
end

-- refresh button
playersTab:Section("Players")
playersTab:Button("Refresh", "Reload player list", function()
    stopAllTroll()
    trollTarget = nil
    selectedCard = nil
    buildPlayerList()
end)

-- build initial list
task.spawn(buildPlayerList)

-- auto-refresh when players join/leave
Players.PlayerAdded:Connect(function() buildPlayerList() end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    buildPlayerList()
end)

-- ── Actions ───────────────────────────────
playersTab:Section("Actions")
playersTab:Label("// select a player from the list above")

playersTab:Button("Teleport To (RISKY)", "One-shot teleport directly to selected player", function()
    if not trollTarget then UI:Notify("Player List", "No player selected", 2) return end
    local thrp = getTargetHRP()
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not thrp or not hrp then return end
    task.spawn(function()
        hrp.Anchored = true
        task.wait(0.1)
        hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, -4)
        task.wait(0.05)
        hrp.Anchored = false
        UI:Notify("Player List", "Teleported to "..trollTarget.Name, 2)
    end)
end)

playersTab:Button("Spectate", "Follow selected player with free-look camera", function()
    if not trollTarget then UI:Notify("Player List", "No player selected", 2) return end
    stopAllTroll()
    local cam = workspace.CurrentCamera
    local targetChar = trollTarget.Character
    local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    if not targetHum then
        UI:Notify("Player List", "Target has no character", 2) return
    end
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = targetHum
    spectateConn = RunService.Heartbeat:Connect(function()
        if not trollTarget or not trollTarget.Character then
            spectateConn:Disconnect(); spectateConn = nil
            cam.CameraSubject = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            return
        end
        local hum = trollTarget.Character:FindFirstChildOfClass("Humanoid")
        if hum and cam.CameraSubject ~= hum then
            cam.CameraSubject = hum
        end
    end)
    UI:Notify("Player List", "Spectating "..trollTarget.Name.." — free look active", 3)
end)

playersTab:Button("Stop", "Cancel spectate + restore camera", function()
    stopAllTroll()
    trollTarget = nil
    if selectedCard then
        tw(selectedCard.card,{BackgroundColor3=T.Card},0.15)
        pcall(function() selectedCard.card:FindFirstChild("SelLabel").Visible=false end)
        pcall(function() selectedCard.dot.Visible=false end)
        selectedCard = nil
    end
    UI:Notify("Player List", "Stopped", 2)
end, true)

-- ── Animations Tab ───────────────────────
UI:TabDivider("Animations")
local animTab = UI:Tab("Animations", "//")

local currentTrack = nil
local function stopAnim()
    if currentTrack then pcall(function() currentTrack:Stop() end) currentTrack = nil end
end
local function playAnim(id, loop)
    stopAnim()
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not animator then UI:Notify("Animations", "No animator found", 2) return end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://"..id
    local track = animator:LoadAnimation(anim)
    track.Looped = loop or false
    track:Play()
    currentTrack = track
end

-- Emotes
animTab:Section("Emotes")
local EMOTES = {
    {"Boat Dance",        "86301902924851",  true},
    {"Join us for a Bite","85062462974800",  true},
    {"PBJ",               "132370068810935", true},
    {"Panic",             "138107670682182", true},
    {"Heroic Dance",      "81249106203107",  true},
    {"A Dare",            "70475318940837",  true},
    {"Clown",             "119930424849354", true},
    {"Friendly Stance",   "119165322803316", true},
    {"Prince of Egypt",   "102081122191776", true},
    {"RAAHH",             "124020375905937", false},
    {"Jump for Joy",      "103876323954001", true},
    {"Smile",             "80607086275648",  true},
    {"Oh Yeah",           "84017859956276",  true},
    {"Hardstyle",         "119852673619030", true},
    {"Down",              "130303526943099", true},
    {"Low Cortisol",      "74010459972595",  true},
    {"Flex",              "116833434226572", false},
    {"Birdbrain",         "90246233828833",  true},
    {"Good for You",      "132202524623790", true},
    {"Pop Dat",           "93670008886747",  true},
    {"Math",              "109728296012105", true},
    {"Toy",               "122265021553467", true},
    {"Blue Shirt Sturdy", "99387378307743",  true},
    {"Bang Bang",         "93908334120692",  true},
    {"Yoink Sploinky",    "73217550616514",  true},
}
for _,e in ipairs(EMOTES) do
    local name, id, loop = e[1], e[2], e[3]
    animTab:Button(name, "rbxassetid://"..id, function()
        playAnim(id, loop)
    end)
end

-- Survivor
animTab:Section("Survivor")
local SURVIVOR = {
    {"Spawn",          "136483191996283", false},
    {"Heal Start",     "79197151128836",  false},
    {"Heal Loop",      "89212574084371",  true},
    {"Self Heal",      "140498597133326", false},
    {"Self Heal Loop", "123191331170780", true},
    {"Calling",        "122385051718048", false},
    {"Fighter Parry",  "92429524316030",  false},
    {"Fighter Swing",  "86249888440012",  false},
    {"Fighter Slam",   "77922157111991",  false},
    {"Fighter Spawn",  "76298695732547",  false},
    {"Taser Fire",     "130467442785091", false},
    {"Taser Idle",     "137853681896194", true},
    {"Tablet Idle",    "122165308651466", true},
    {"Tablet Equip",   "117969178583801", false},
    {"Tablet Locate",  "100476886386638", false},
    {"Energy Drink",   "130456765294800", false},
    {"Pizza Eat",      "70432523697256",  false},
    {"Injured",        "71810550745849",  false},
}
for _,e in ipairs(SURVIVOR) do
    local name, id, loop = e[1], e[2], e[3]
    animTab:Button(name, "rbxassetid://"..id, function()
        playAnim(id, loop)
    end)
end

-- Killer
animTab:Section("Killer — Springtrap")
local SPRINGTRAP = {
    {"Spawn",         "106852525953836", false},
    {"Swing",         "70869035406359",  false},
    {"Swing Kill",    "134493215841357", false},
    {"Throw Start",   "93908270616381",  false},
    {"Throw Hold",    "77150341615948",  true},
    {"Throw",         "119495869953586", false},
    {"Rush",          "71147082224885",  false},
    {"Rush Grab",     "106320614031108", false},
    {"Rush End",      "86724503345527",  false},
    {"Stun",          "107842227037730", false},
    {"Stun End",      "132052084450670", false},
    {"Scream",        "120579972228705", false},
    {"Door Kick 1",   "103610455655414", false},
    {"Door Kick 2",   "98803680881853",  false},
    {"Door Kick 3",   "85092048420324",  false},
    {"Pick Up Trap",  "110168182541123", false},
    {"Axe Pull Wall", "78973933786069",  false},
}
for _,e in ipairs(SPRINGTRAP) do
    local name, id, loop = e[1], e[2], e[3]
    animTab:Button(name, "rbxassetid://"..id, function()
        playAnim(id, loop)
    end)
end

animTab:Section("Killer — Mimic")
local MIMIC = {
    {"Spawn",      "73087694364910",  false},
    {"Swing",      "106673226682917", false},
    {"Grab",       "95722006705414",  false},
    {"Hold",       "109651076359925", true},
    {"Throw",      "81424218341162",  false},
    {"Leap",       "71098053103714",  false},
    {"Leap Land",  "81381542397159",  false},
    {"Kill Mimic", "98549068696030",  false},
    {"Kill Victim","102715219228553", false},
    {"Stun",       "118530537729528", false},
    {"Stun End",   "78605787329564",  false},
    {"Drill Hole", "95483601477510",  false},
    {"Drill Out",  "80615350960130",  false},
}
for _,e in ipairs(MIMIC) do
    local name, id, loop = e[1], e[2], e[3]
    animTab:Button(name, "rbxassetid://"..id, function()
        playAnim(id, loop)
    end)
end

animTab:Section("Killer — Ennard")
local ENNARD = {
    {"Spawn",        "89677035457300",  false},
    {"Swing",        "112503015929213", false},
    {"Kill Ennard",  "72882749096087",  false},
    {"Kill Victim",  "93927488584919",  false},
    {"Possess",      "111261793531584", false},
    {"Explode",      "105408411673740", false},
    {"Pull",         "133752270724243", false},
    {"Stun",         "131406552769551", false},
    {"Stun End",     "86982337006154",  false},
    {"Disguise",     "123633391946492", false},
    {"Disguise Kill","124481568753890", false},
    {"Disguise Throw","79701284741250", false},
}
for _,e in ipairs(ENNARD) do
    local name, id, loop = e[1], e[2], e[3]
    animTab:Button(name, "rbxassetid://"..id, function()
        playAnim(id, loop)
    end)
end

animTab:Section("Cutscenes")
local CUTSCENES = {
    {"Springtrap Intro",   "122662400584918", false},
    {"Springtrap Outro",   "127454518119555", false},
    {"Springtrap Kill Cam","76468339707017",  false},
    {"Mimic Intro",        "104330959328080", false},
    {"Mimic Kill",         "109317843370127", false},
    {"Mimic Outro",        "106847984288876", false},
    {"Ennard Intro",       "119209213064662", false},
    {"Ennard Kill",        "73696738753197",  false},
    {"Ennard Outro",       "118864693363212", false},
    {"Elevator Alone",     "130582889249338", false},
    {"Elevator Full Win",  "89458402908006",  false},
    {"Grab Springtrap",    "78169407480383",  false},
    {"Full Win 1",         "107208396186597", false},
    {"Full Win 2",         "95193023074026",  false},
    {"Full Win 3",         "93108544112476",  false},
}
for _,e in ipairs(CUTSCENES) do
    local name, id, loop = e[1], e[2], e[3]
    animTab:Button(name, "rbxassetid://"..id, function()
        playAnim(id, loop)
    end)
end

animTab:Section("Controls")
animTab:Button("▶ Loop Current", "Loop the current animation", function()
    if currentTrack and currentTrack.Animation then
        local id = currentTrack.Animation.AnimationId:match("%d+")
        if id then playAnim(id, true) end
    else
        UI:Notify("Animations", "Play an animation first", 2)
    end
end)
animTab:Button("■ Stop", "Stop current animation", function()
    stopAnim()
end, true)

-- ── Done ──────────────────────────────────
task.wait(1)
UI:Notify("DBSB.su", "Bite by Night loaded // RightAlt to toggle", 4)
