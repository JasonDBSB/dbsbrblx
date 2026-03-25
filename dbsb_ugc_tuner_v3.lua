-- ═══════════════════════════════════════════════════════
--  DBSB.su | UGC Tuner v3.0
--  PlaceId: 5829141886
--  A-Chassis require() writes — no attribute touches
--  RightAlt to toggle UI
-- ═══════════════════════════════════════════════════════
local Library={}
Library.__index=Library
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local VIM=game:GetService("VirtualInputManager")
local lp=Players.LocalPlayer
local T={BG=Color3.fromRGB(18,18,22),Sidebar=Color3.fromRGB(24,24,30),Card=Color3.fromRGB(28,28,35),CardHover=Color3.fromRGB(34,34,42),Input=Color3.fromRGB(22,22,28),Dropdown=Color3.fromRGB(26,26,33),Purple=Color3.fromRGB(128,58,255),PurpleDim=Color3.fromRGB(80,35,160),PurpleDark=Color3.fromRGB(30,15,60),PurpleGlow=Color3.fromRGB(160,90,255),TextPrimary=Color3.fromRGB(240,240,245),TextSecond=Color3.fromRGB(160,160,175),TextMuted=Color3.fromRGB(90,90,105),Divider=Color3.fromRGB(38,38,48),Border=Color3.fromRGB(45,45,58),BorderAccent=Color3.fromRGB(80,45,160),Green=Color3.fromRGB(50,210,100),Red=Color3.fromRGB(230,60,60),Orange=Color3.fromRGB(255,150,40),CheckBG=Color3.fromRGB(28,28,35),ScrollBar=Color3.fromRGB(60,35,120),NotifBG=Color3.fromRGB(22,22,28)}
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
    local main=new("Frame",{Size=UDim2.new(0,660,0,480),Position=UDim2.new(0.5,-330,0.5,-240),BackgroundColor3=T.BG,BorderSizePixel=0},sg)
    corner(10,main) stroke(T.Border,1,main) Win._main=main
    local sidebar=new("Frame",{Size=UDim2.new(0,200,1,0),BackgroundColor3=T.Sidebar,BorderSizePixel=0,ZIndex=2},main)
    corner(10,sidebar)
    new("Frame",{Size=UDim2.new(0,10,1,0),Position=UDim2.new(1,-10,0,0),BackgroundColor3=T.Sidebar,BorderSizePixel=0,ZIndex=2},sidebar)
    new("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Divider,BorderSizePixel=0,ZIndex=3},sidebar)
    local sideHeader=new("Frame",{Size=UDim2.new(1,0,0,70),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=3},sidebar)
    new("TextLabel",{Size=UDim2.new(1,-16,0,22),Position=UDim2.new(0,14,0,12),BackgroundTransparency=1,Text=title,TextColor3=T.TextPrimary,TextSize=16,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},sideHeader)
    new("TextLabel",{Size=UDim2.new(0,110,0,14),Position=UDim2.new(0,14,0,32),BackgroundTransparency=1,Text=subtitle or "",TextColor3=T.Purple,TextSize=10,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},sideHeader)
    local applyBtn=new("TextButton",{Size=UDim2.new(0,60,0,24),Position=UDim2.new(1,-68,0,22),BackgroundColor3=T.PurpleDark,Text="APPLY",TextColor3=T.PurpleGlow,TextSize=11,Font=F.Bold,BorderSizePixel=0,AutoButtonColor=false,ZIndex=6},sideHeader)
    corner(4,applyBtn) stroke(T.BorderAccent,1,applyBtn)
    applyBtn.MouseEnter:Connect(function() tw(applyBtn,{BackgroundColor3=T.PurpleDim},0.1) end)
    applyBtn.MouseLeave:Connect(function() tw(applyBtn,{BackgroundColor3=T.PurpleDark},0.1) end)
    Win._applyBtn=applyBtn
    new("Frame",{Size=UDim2.new(1,-14,0,1),Position=UDim2.new(0,14,1,-1),BackgroundColor3=T.Divider,BorderSizePixel=0,ZIndex=3},sideHeader)
    local tabList=new("ScrollingFrame",{Size=UDim2.new(1,0,1,-90),Position=UDim2.new(0,0,0,70),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),ZIndex=3},sidebar)
    local tll=new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},tabList)
    pad(0,0,6,6,tabList)
    tll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabList.CanvasSize=UDim2.new(0,0,0,tll.AbsoluteContentSize.Y+12) end)
    Win._tabList=tabList
    local content=new("Frame",{Size=UDim2.new(1,-200,1,0),Position=UDim2.new(0,200,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2},main)
    Win._content=content
    new("TextLabel",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,1,-20),BackgroundTransparency=1,Text="DBSB.su",TextColor3=T.TextMuted,TextSize=10,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=3},sidebar)
    local dragging,dragStart,startPos
    sideHeader.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true dragStart=i.Position startPos=main.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dragStart main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputBegan:Connect(function(i,gpe) if not gpe and i.KeyCode==Enum.KeyCode.RightAlt then sg.Enabled=not sg.Enabled end end)
    local nHolder=new("Frame",{Size=UDim2.new(0,280,1,0),Position=UDim2.new(1,-294,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9999},sg)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,6)},nHolder)
    pad(0,0,0,14,nHolder) Win._nc=0
    function Win:Notify(t,msg,dur)
        Win._nc=Win._nc+1 dur=dur or 3
        local n=new("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=T.NotifBG,BorderSizePixel=0,LayoutOrder=Win._nc,ClipsDescendants=true},nHolder)
        corner(6,n) stroke(T.BorderAccent,1,n)
        new("Frame",{Size=UDim2.new(0,3,1,-8),Position=UDim2.new(0,0,0,4),BackgroundColor3=T.Purple,BorderSizePixel=0},n)
        new("TextLabel",{Size=UDim2.new(1,-22,0,18),Position=UDim2.new(0,14,0,10),BackgroundTransparency=1,Text=t,TextColor3=T.TextPrimary,TextSize=13,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},n)
        new("TextLabel",{Size=UDim2.new(1,-22,0,16),Position=UDim2.new(0,14,0,30),BackgroundTransparency=1,Text=msg,TextColor3=T.TextSecond,TextSize=11,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},n)
        local pb=new("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=T.Divider,BorderSizePixel=0},n)
        local pf=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Purple,BorderSizePixel=0},pb)
        n.BackgroundTransparency=1 tw(n,{BackgroundTransparency=0},0.2)
        tw(pf,{Size=UDim2.new(0,0,1,0)},dur,Enum.EasingStyle.Linear)
        task.delay(dur,function() tw(n,{BackgroundTransparency=1},0.3) task.wait(0.35) n:Destroy() end)
    end
    function Win:TabDivider(label)
        local d=new("Frame",{Size=UDim2.new(1,-8,0,26),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=#Win._tabs+0.5},tabList)
        new("TextLabel",{Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=(label or ""):upper(),TextColor3=T.TextMuted,TextSize=9,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left},d)
        new("Frame",{Size=UDim2.new(1,-14,0,1),Position=UDim2.new(0,14,1,-1),BackgroundColor3=T.Divider,BorderSizePixel=0},d)
    end
    function Win:Tab(tabName,icon)
        local Tab={_win=Win,_name=tabName,_order=#Win._tabs+1}
        local tabBtn=new("Frame",{Size=UDim2.new(1,-8,0,36),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=Tab._order},tabList)
        local leftBar=new("Frame",{Size=UDim2.new(0,3,0,20),Position=UDim2.new(0,0,0.5,-10),BackgroundColor3=T.Purple,BorderSizePixel=0,Visible=false},tabBtn) corner(2,leftBar)
        local tabBg=new("Frame",{Size=UDim2.new(1,-4,1,0),Position=UDim2.new(0,4,0,0),BackgroundColor3=T.PurpleDark,BackgroundTransparency=1,BorderSizePixel=0},tabBtn) corner(6,tabBg)
        local iconLbl=new("TextLabel",{Size=UDim2.new(0,22,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=icon or "//",TextColor3=T.TextMuted,TextSize=11,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Center},tabBtn)
        local tabLbl=new("TextLabel",{Size=UDim2.new(1,-42,1,0),Position=UDim2.new(0,38,0,0),BackgroundTransparency=1,Text=tabName,TextColor3=T.TextMuted,TextSize=13,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left},tabBtn)
        local scroll=new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.ScrollBar,CanvasSize=UDim2.new(0,0,0,0),Visible=false},content)
        local sl=new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},scroll)
        pad(14,14,14,14,scroll)
        sl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize=UDim2.new(0,0,0,sl.AbsoluteContentSize.Y+28) end)
        Tab._scroll=scroll Tab._order2=0
        local function activate()
            for _,t in ipairs(Win._tabs) do t._scroll.Visible=false t._leftBar.Visible=false tw(t._tabBg,{BackgroundTransparency=1},0.15) tw(t._iconLbl,{TextColor3=T.TextMuted},0.15) tw(t._tabLbl,{TextColor3=T.TextMuted},0.15) t._tabLbl.Font=F.Medium end
            scroll.Visible=true leftBar.Visible=true Win._activeTab=Tab
            tw(tabBg,{BackgroundTransparency=0.85},0.15) tw(iconLbl,{TextColor3=T.Purple},0.15) tw(tabLbl,{TextColor3=T.TextPrimary},0.15) tabLbl.Font=F.Bold
        end
        Tab._leftBar=leftBar Tab._tabBg=tabBg Tab._iconLbl=iconLbl Tab._tabLbl=tabLbl Tab._activate=activate
        local cbt=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},tabBtn)
        cbt.MouseButton1Click:Connect(activate)
        cbt.MouseEnter:Connect(function() if Win._activeTab~=Tab then tw(tabBg,{BackgroundTransparency=0.95},0.1) tw(tabLbl,{TextColor3=T.TextSecond},0.1) end end)
        cbt.MouseLeave:Connect(function() if Win._activeTab~=Tab then tw(tabBg,{BackgroundTransparency=1},0.1) tw(tabLbl,{TextColor3=T.TextMuted},0.1) end end)
        table.insert(Win._tabs,Tab) if #Win._tabs==1 then activate() end
        function Tab:Section(label)
            Tab._order2=Tab._order2+1
            local r=new("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll)
            new("TextLabel",{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=label:upper(),TextColor3=T.TextMuted,TextSize=10,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left},r)
            new("Frame",{Size=UDim2.new(1,-8,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Divider,BorderSizePixel=0},r)
        end
        function Tab:Label(text)
            Tab._order2=Tab._order2+1
            local r=new("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll)
            new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=text,TextColor3=T.TextSecond,TextSize=11,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},r)
        end
        function Tab:Spacer(h) Tab._order2=Tab._order2+1 new("Frame",{Size=UDim2.new(1,0,0,h or 8),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll) end
        function Tab:Toggle(label,desc,default,callback)
            Tab._order2=Tab._order2+1 local val=default or false
            local r=new("Frame",{Size=UDim2.new(1,0,0,desc and 52 or 36),BackgroundColor3=T.Card,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll)
            corner(6,r) local rs=stroke(T.Border,1,r)
            local lb=new("Frame",{Size=UDim2.new(0,3,1,-12),Position=UDim2.new(0,0,0,6),BackgroundColor3=T.Purple,BorderSizePixel=0,Visible=val},r) corner(2,lb)
            new("TextLabel",{Size=UDim2.new(1,-64,0,20),Position=UDim2.new(0,14,0,desc and 8 or 8),BackgroundTransparency=1,Text=label,TextColor3=T.TextPrimary,TextSize=13,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left},r)
            if desc then new("TextLabel",{Size=UDim2.new(1,-64,0,16),Position=UDim2.new(0,14,0,28),BackgroundTransparency=1,Text=desc,TextColor3=T.TextSecond,TextSize=11,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left},r) end
            local cb2=new("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(1,-36,0.5,-9),BackgroundColor3=val and T.Purple or T.CheckBG,BorderSizePixel=0},r)
            corner(4,cb2) stroke(val and T.Purple or T.Border,1,cb2)
            local cm=new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="v",TextColor3=T.TextPrimary,TextSize=11,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Center,TextTransparency=val and 0 or 1},cb2)
            local function ref() tw(cb2,{BackgroundColor3=val and T.Purple or T.CheckBG},0.15) tw(cm,{TextTransparency=val and 0 or 1},0.1) tw(rs,{Color=val and T.BorderAccent or T.Border},0.15) lb.Visible=val if callback then pcall(callback,val) end end
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
            local r=new("Frame",{Size=UDim2.new(1,0,0,desc and 64 or 52),BackgroundColor3=T.Card,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll)
            corner(6,r) stroke(T.Border,1,r)
            new("TextLabel",{Size=UDim2.new(0.65,0,0,18),Position=UDim2.new(0,14,0,desc and 8 or 6),BackgroundTransparency=1,Text=label,TextColor3=T.TextPrimary,TextSize=13,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left},r)
            if desc then new("TextLabel",{Size=UDim2.new(0.65,0,0,14),Position=UDim2.new(0,14,0,26),BackgroundTransparency=1,Text=desc,TextColor3=T.TextSecond,TextSize=10,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left},r) end
            local function fmt(v) return isInt and tostring(math.floor(v)) or string.format("%.3f",v) end
            local vl=new("TextLabel",{Size=UDim2.new(0.3,0,0,18),Position=UDim2.new(0.68,0,0,desc and 8 or 6),BackgroundTransparency=1,Text=fmt(val),TextColor3=T.Purple,TextSize=14,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Right},r)
            local tb=new("Frame",{Size=UDim2.new(1,-28,0,4),Position=UDim2.new(0,14,1,-18),BackgroundColor3=T.Divider,BorderSizePixel=0},r) corner(2,tb)
            local p0=(val-min)/(max-min)
            local tf=new("Frame",{Size=UDim2.new(p0,0,1,0),BackgroundColor3=T.Purple,BorderSizePixel=0},tb) corner(2,tf)
            local kn=new("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(p0,-7,0.5,-7),BackgroundColor3=T.PurpleGlow,BorderSizePixel=0},tb) corner(7,kn)
            local sliding=false
            local function upd(x)
                local p=math.clamp((x-tb.AbsolutePosition.X)/tb.AbsoluteSize.X,0,1)
                val=min+(max-min)*p if isInt then val=math.floor(val+0.5) end
                val=math.clamp(val,min,max) local p2=(val-min)/(max-min)
                tf.Size=UDim2.new(p2,0,1,0) kn.Position=UDim2.new(p2,-7,0.5,-7) vl.Text=fmt(val)
                if callback then pcall(callback,val) end
            end
            tb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true upd(i.Position.X) end end)
            kn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true end end)
            UIS.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
            r.MouseEnter:Connect(function() tw(r,{BackgroundColor3=T.CardHover},0.1) end)
            r.MouseLeave:Connect(function() tw(r,{BackgroundColor3=T.Card},0.1) end)
            local ctrl={} function ctrl:Set(v) val=math.clamp(v,min,max) local p2=(val-min)/(max-min) tf.Size=UDim2.new(p2,0,1,0) kn.Position=UDim2.new(p2,-7,0.5,-7) vl.Text=fmt(val) if callback then pcall(callback,val) end end function ctrl:Get() return val end return ctrl
        end
        function Tab:Button(label,desc,callback,primary)
            Tab._order2=Tab._order2+1
            local r=new("Frame",{Size=UDim2.new(1,0,0,desc and 52 or 36),BackgroundColor3=primary and T.PurpleDark or T.Card,BorderSizePixel=0,LayoutOrder=Tab._order2},scroll)
            corner(6,r) stroke(primary and T.BorderAccent or T.Border,1,r)
            new("TextLabel",{Size=UDim2.new(1,-28,0,20),Position=UDim2.new(0,14,0,desc and 8 or 8),BackgroundTransparency=1,Text=label,TextColor3=primary and T.PurpleGlow or T.TextPrimary,TextSize=13,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Left},r)
            if desc then new("TextLabel",{Size=UDim2.new(1,-28,0,16),Position=UDim2.new(0,14,0,28),BackgroundTransparency=1,Text=desc,TextColor3=T.TextSecond,TextSize=11,Font=F.Medium,TextXAlignment=Enum.TextXAlignment.Left},r) end
            new("TextLabel",{Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-24,0,0),BackgroundTransparency=1,Text=">",TextColor3=primary and T.Purple or T.TextMuted,TextSize=14,Font=F.Bold,TextXAlignment=Enum.TextXAlignment.Center},r)
            local btn=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},r)
            btn.MouseButton1Click:Connect(function() tw(r,{BackgroundColor3=primary and T.PurpleDim or T.CardHover},0.08) task.delay(0.12,function() tw(r,{BackgroundColor3=primary and T.PurpleDark or T.Card},0.12) end) if callback then pcall(callback) end end)
            btn.MouseEnter:Connect(function() tw(r,{BackgroundColor3=primary and T.PurpleDim or T.CardHover},0.1) end)
            btn.MouseLeave:Connect(function() tw(r,{BackgroundColor3=primary and T.PurpleDark or T.Card},0.1) end)
        end
        return Tab
    end
    return Win
end

-- ══════════════════════════════════════════
--  UGC GAME CODE
-- ══════════════════════════════════════════
local sv={}
local sc={}

local function getCar()
    local char=lp.Character if not char then return nil,nil end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil,nil end
    local car=hum.SeatPart.Parent
    local ok,tune=pcall(require,car:FindFirstChild("A-Chassis Tune"))
    if not ok or type(tune)~="table" then return nil,nil end
    return car,tune
end

local function getDriveSeat()
    local char=lp.Character if not char then return nil end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil end
    return hum.SeatPart
end

local function inCar()
    local char=lp.Character if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid")
    return hum and hum.SeatPart~=nil
end

local function writeValues(tune)
    local function a(k) if sv[k]~=nil then tune[k]=sv[k] end end
    a("E_Torque") a("HPLimit") a("Weight") a("WeightDist") a("CGHeight")
    a("Redline") a("E_Redline") a("IdleRPM") a("RevBounce") a("RevAccel") a("RevDecay")
    a("ThrotAccel") a("ThrotDecel") a("InclineComp") a("FDMult")
    a("VVLRPM") a("VVLTorque")
    a("Turbochargers") a("T_Boost") a("T_Efficiency") a("T_PeakRPM")
    a("T_SpoolIncrease") a("T_SpoolDecrease")
    a("Superchargers") a("S_PeakBoost") a("S_Efficiency") a("S_PeakRPM")
    a("FinalDrive") a("ShiftUpTime") a("ShiftDnTime") a("ShiftThrot") a("ShiftRPM")
    a("ClutchEngage") a("RPMEngage") a("SpeedEngage") a("SpeedLimit") a("ReverseSpeed")
    a("AutoUpThresh") a("AutoDownThresh")
    a("FSusStiffness") a("FSusDamping") a("FSusLength") a("FSusAngle")
    a("FPreCompress") a("FCompressLim") a("FExtensionLim") a("FGyroDampening") a("FSwayBar")
    a("RSusStiffness") a("RSusDamping") a("RSusLength") a("RSusAngle")
    a("RPreCompress") a("RCompressLim") a("RExtensionLim") a("RGyroDampening") a("RSwayBar")
    a("FCamber") a("RCamber") a("FCaster") a("RCaster") a("FToe") a("RToe")
    a("BrakeForce") a("BrakeBias") a("BrakeAccel") a("BrakeDecel")
    a("PBrakeForce") a("PBrakeBias") a("EBrakeForce")
    a("SteerRatio") a("LockToLock") a("SteerSpeed") a("ReturnSpeed") a("Ackerman") a("MinSteer")
    a("SteerP") a("SteerD") a("SteerDecay") a("SteerMaxTorque")
    a("RSteerDecay") a("RSteerInner") a("RSteerOuter") a("RSteerSpeed")
    a("RDiffPower") a("RDiffCoast") a("RDiffPreload")
    a("FDiffPower") a("FDiffCoast") a("FDiffPreload")
    a("TorqueVector") a("GravComp")
    a("TCSEnabled") a("TCSLimit") a("TCSGradient") a("TCSThreshold")
    a("ABSEnabled") a("ABSLimit") a("ABSThreshold")
    a("ESCEnabled") a("ESCThreshold") a("ESCBrake") a("ESCThrottle") a("ESCSpeed")
    a("Stall") a("AutoFlip")
end

local function autoReload(UI)
    local char=lp.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
    if not hum.SeatPart then return end
    task.spawn(function()
        VIM:SendKeyEvent(true,Enum.KeyCode.Space,false,game)
        task.wait(0.1)
        VIM:SendKeyEvent(false,Enum.KeyCode.Space,false,game)
        task.wait(1)
        VIM:SendKeyEvent(true,Enum.KeyCode.E,false,game)
        task.wait(0.1)
        VIM:SendKeyEvent(false,Enum.KeyCode.E,false,game)
        task.wait(0.5)
        UI:Notify("Done","Tune applied successfully.",3)
    end)
end

local function doApply(UI)
    if not inCar() then UI:Notify("No Vehicle","Get in a car first.",3) return end
    local car,tune=getCar()
    if not tune then UI:Notify("Error","Could not read tune from car.",3) return end
    writeValues(tune)
    UI:Notify("Applying...","Exiting and re-entering vehicle.",2)
    autoReload(UI)
end

-- ══════════════════════════════════════════
--  UI
-- ══════════════════════════════════════════
local UI=Library:Window("DBSB.su","Realistic Car Driving")
UI._applyBtn.MouseButton1Click:Connect(function() doApply(UI) end)

local function loadCarStats()
    local car,tune=getCar() if not tune then return end
    local function s(k,default)
        local val=tune[k] if val==nil then val=default end
        sv[k]=val if sc[k] then sc[k]:Set(val) end
    end
    s("E_Torque",1080)       s("HPLimit",135)         s("Weight",1055)
    s("WeightDist",63)       s("CGHeight",0.1)         s("InclineComp",1)
    s("FDMult",1)            s("Redline",6500)         s("E_Redline",20000)
    s("IdleRPM",1000)        s("RevBounce",200)        s("RevAccel",1)
    s("RevDecay",20)         s("ThrotAccel",0.1)       s("ThrotDecel",0.2)
    s("VVLRPM",6340)         s("VVLTorque",0)
    s("Turbochargers",1)     s("T_Boost",14.5)         s("T_Efficiency",5)
    s("T_PeakRPM",2500)      s("T_SpoolIncrease",0.8)  s("T_SpoolDecrease",0.9)
    s("Superchargers",0)     s("S_PeakBoost",13.3)     s("S_Efficiency",7.3)   s("S_PeakRPM",5500)
    s("FinalDrive",3.733)    s("ShiftUpTime",0.25)     s("ShiftDnTime",0.1)
    s("ShiftThrot",100)      s("ShiftRPM",6500)        s("ClutchEngage",10)
    s("RPMEngage",3500)      s("SpeedEngage",20)       s("SpeedLimit",208.5)   s("ReverseSpeed",85.5)
    s("AutoUpThresh",-200)   s("AutoDownThresh",1400)
    s("FSusStiffness",2.9)   s("FSusDamping",2900)     s("FSusLength",1.6)
    s("FSusAngle",80)        s("FPreCompress",0.2)     s("FCompressLim",1.25)
    s("FExtensionLim",1)     s("FGyroDampening",50)    s("FSwayBar",2.1)
    s("RSusStiffness",3.2)   s("RSusDamping",3100)     s("RSusLength",1.4)
    s("RSusAngle",80)        s("RPreCompress",0.2)     s("RCompressLim",2)
    s("RExtensionLim",1)     s("RGyroDampening",50)    s("RSwayBar",1.2)
    s("FCamber",-1)          s("RCamber",-2)           s("FCaster",0)
    s("RCaster",0)           s("FToe",0)               s("RToe",0)
    s("BrakeForce",2100)     s("BrakeBias",0.7)        s("BrakeAccel",0.1)
    s("BrakeDecel",0.2)      s("PBrakeForce",3000)     s("PBrakeBias",0)       s("EBrakeForce",500)
    s("SteerRatio",15)       s("LockToLock",2.7)       s("SteerSpeed",0.05)
    s("ReturnSpeed",0.15)    s("Ackerman",1.1)         s("MinSteer",25)
    s("SteerP",30000)        s("SteerD",1200)          s("SteerDecay",250)     s("SteerMaxTorque",4000)
    s("RSteerDecay",330)     s("RSteerInner",10)       s("RSteerOuter",10)     s("RSteerSpeed",60)
    s("RDiffPower",0)        s("RDiffCoast",0)         s("RDiffPreload",0)
    s("FDiffPower",0)        s("FDiffCoast",0)         s("FDiffPreload",0)
    s("TorqueVector",0.7)    s("GravComp",45)
    s("TCSEnabled",true)     s("TCSLimit",8)           s("TCSGradient",20)     s("TCSThreshold",10)
    s("ABSEnabled",true)     s("ABSLimit",0)           s("ABSThreshold",5)
    s("ESCEnabled",true)     s("ESCThreshold",0.75)    s("ESCBrake",60)
    s("ESCThrottle",60)      s("ESCSpeed",30)
    s("Stall",true)          s("AutoFlip",true)
    UI:Notify("Car Loaded",car.Name,2)
end

local function watchSeat(char)
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
    hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
        if hum.SeatPart then task.wait(0.4) loadCarStats() end
    end)
    if hum.SeatPart then task.wait(0.4) loadCarStats() end
end
if lp.Character then watchSeat(lp.Character) end
lp.CharacterAdded:Connect(watchSeat)

-- ══════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════
UI:TabDivider("Engine")
local eTab=UI:Tab("Engine","//")
eTab:Section("Torque & Power")
sc["E_Torque"]=eTab:Slider("E_Torque","Engine torque",100,3000,1080,function(v) sv["E_Torque"]=v end)
sc["HPLimit"]=eTab:Slider("HPLimit","Horsepower limit",50,800,135,function(v) sv["HPLimit"]=v end)
sc["Weight"]=eTab:Slider("Weight","Vehicle weight (kg)",200,3000,1055,function(v) sv["Weight"]=v end)
sc["WeightDist"]=eTab:Slider("WeightDist","Weight dist % front",20,80,63,function(v) sv["WeightDist"]=v end)
sc["CGHeight"]=eTab:Slider("CGHeight","Center of gravity height",0.01,2,0.1,function(v) sv["CGHeight"]=v end)
eTab:Section("RPM")
sc["Redline"]=eTab:Slider("Redline","Engine redline",2000,10000,6500,function(v) sv["Redline"]=v end)
sc["E_Redline"]=eTab:Slider("E_Redline","Max RPM limit",5000,25000,20000,function(v) sv["E_Redline"]=v end)
sc["IdleRPM"]=eTab:Slider("IdleRPM","Idle RPM",400,2000,1000,function(v) sv["IdleRPM"]=v end)
sc["RevBounce"]=eTab:Slider("RevBounce","Rev bounce",50,1000,200,function(v) sv["RevBounce"]=v end)
sc["RevAccel"]=eTab:Slider("RevAccel","Rev acceleration",0.1,5,1,function(v) sv["RevAccel"]=v end)
sc["RevDecay"]=eTab:Slider("RevDecay","Rev decay",1,100,20,function(v) sv["RevDecay"]=v end)
eTab:Section("Throttle")
sc["ThrotAccel"]=eTab:Slider("ThrotAccel","Throttle accel",0.01,2,0.1,function(v) sv["ThrotAccel"]=v end)
sc["ThrotDecel"]=eTab:Slider("ThrotDecel","Throttle decel",0.01,2,0.2,function(v) sv["ThrotDecel"]=v end)
sc["InclineComp"]=eTab:Slider("InclineComp","Incline compensation",0,5,1,function(v) sv["InclineComp"]=v end)
sc["FDMult"]=eTab:Slider("FDMult","Final drive multiplier",0.1,3,1,function(v) sv["FDMult"]=v end)
eTab:Section("VVL")
sc["VVLRPM"]=eTab:Slider("VVLRPM","VVL activation RPM",1000,10000,6340,function(v) sv["VVLRPM"]=v end)
sc["VVLTorque"]=eTab:Slider("VVLTorque","VVL torque gain",0,500,0,function(v) sv["VVLTorque"]=v end)

UI:TabDivider("Forced Induction")
local tTab=UI:Tab("Turbo","//")
tTab:Section("Turbocharger")
sc["Turbochargers"]=tTab:Slider("Turbochargers","Number of turbos",0,4,1,function(v) sv["Turbochargers"]=v end)
sc["T_Boost"]=tTab:Slider("T_Boost","Boost pressure",1,30,14.5,function(v) sv["T_Boost"]=v end)
sc["T_Efficiency"]=tTab:Slider("T_Efficiency","Turbo efficiency",1,15,5,function(v) sv["T_Efficiency"]=v end)
sc["T_PeakRPM"]=tTab:Slider("T_PeakRPM","Peak boost RPM",500,8000,2500,function(v) sv["T_PeakRPM"]=v end)
sc["T_SpoolIncrease"]=tTab:Slider("T_SpoolIncrease","Spool up rate",0.1,2,0.8,function(v) sv["T_SpoolIncrease"]=v end)
sc["T_SpoolDecrease"]=tTab:Slider("T_SpoolDecrease","Spool down rate",0.1,2,0.9,function(v) sv["T_SpoolDecrease"]=v end)
tTab:Section("Supercharger")
sc["Superchargers"]=tTab:Slider("Superchargers","Number of superchargers",0,2,0,function(v) sv["Superchargers"]=v end)
sc["S_PeakBoost"]=tTab:Slider("S_PeakBoost","Peak boost",1,30,13.3,function(v) sv["S_PeakBoost"]=v end)
sc["S_Efficiency"]=tTab:Slider("S_Efficiency","Efficiency",1,15,7.3,function(v) sv["S_Efficiency"]=v end)
sc["S_PeakRPM"]=tTab:Slider("S_PeakRPM","Peak RPM",500,8000,5500,function(v) sv["S_PeakRPM"]=v end)

UI:TabDivider("Drivetrain")
local trTab=UI:Tab("Trans","//")
trTab:Section("Shifting")
sc["FinalDrive"]=trTab:Slider("FinalDrive","Final drive ratio",1,8,3.733,function(v) sv["FinalDrive"]=v end)
sc["ShiftUpTime"]=trTab:Slider("ShiftUpTime","Upshift time (s)",0.01,1,0.25,function(v) sv["ShiftUpTime"]=v end)
sc["ShiftDnTime"]=trTab:Slider("ShiftDnTime","Downshift time (s)",0.01,1,0.1,function(v) sv["ShiftDnTime"]=v end)
sc["ShiftThrot"]=trTab:Slider("ShiftThrot","Shift throttle %",0,100,100,function(v) sv["ShiftThrot"]=v end)
sc["ShiftRPM"]=trTab:Slider("ShiftRPM","Shift RPM",1000,10000,6500,function(v) sv["ShiftRPM"]=v end)
trTab:Section("Clutch")
sc["ClutchEngage"]=trTab:Slider("ClutchEngage","Clutch engage %",1,100,10,function(v) sv["ClutchEngage"]=v end)
sc["RPMEngage"]=trTab:Slider("RPMEngage","RPM engage",500,8000,3500,function(v) sv["RPMEngage"]=v end)
sc["SpeedEngage"]=trTab:Slider("SpeedEngage","Speed engage",1,100,20,function(v) sv["SpeedEngage"]=v end)
trTab:Section("Limits")
sc["SpeedLimit"]=trTab:Slider("SpeedLimit","Top speed limit",50,500,208.5,function(v) sv["SpeedLimit"]=v end)
sc["ReverseSpeed"]=trTab:Slider("ReverseSpeed","Reverse speed limit",10,200,85.5,function(v) sv["ReverseSpeed"]=v end)
sc["AutoUpThresh"]=trTab:Slider("AutoUpThresh","Auto upshift threshold",-1000,0,-200,function(v) sv["AutoUpThresh"]=v end)
sc["AutoDownThresh"]=trTab:Slider("AutoDownThresh","Auto downshift threshold",200,5000,1400,function(v) sv["AutoDownThresh"]=v end)

local dTab=UI:Tab("Diff","//")
dTab:Section("Rear Differential")
sc["RDiffPower"]=dTab:Slider("RDiffPower","Power lock %",0,100,0,function(v) sv["RDiffPower"]=v end)
sc["RDiffCoast"]=dTab:Slider("RDiffCoast","Coast lock %",0,100,0,function(v) sv["RDiffCoast"]=v end)
sc["RDiffPreload"]=dTab:Slider("RDiffPreload","Preload",0,100,0,function(v) sv["RDiffPreload"]=v end)
dTab:Section("Front Differential")
sc["FDiffPower"]=dTab:Slider("FDiffPower","Power lock %",0,100,0,function(v) sv["FDiffPower"]=v end)
sc["FDiffCoast"]=dTab:Slider("FDiffCoast","Coast lock %",0,100,0,function(v) sv["FDiffCoast"]=v end)
sc["FDiffPreload"]=dTab:Slider("FDiffPreload","Preload",0,100,0,function(v) sv["FDiffPreload"]=v end)
dTab:Section("Handling")
sc["TorqueVector"]=dTab:Slider("TorqueVector","Torque vectoring",-1,1,0.7,function(v) sv["TorqueVector"]=v end)
sc["GravComp"]=dTab:Slider("GravComp","Gravity compensation",0,100,45,function(v) sv["GravComp"]=v end)

UI:TabDivider("Chassis")
local hTab=UI:Tab("Susp","//")
hTab:Section("Front Suspension")
sc["FSusStiffness"]=hTab:Slider("FSusStiffness","Spring stiffness",0.5,15,2.9,function(v) sv["FSusStiffness"]=v end)
sc["FSusDamping"]=hTab:Slider("FSusDamping","Damping",100,8000,2900,function(v) sv["FSusDamping"]=v end)
sc["FSusLength"]=hTab:Slider("FSusLength","Travel length",0.5,5,1.6,function(v) sv["FSusLength"]=v end)
sc["FSusAngle"]=hTab:Slider("FSusAngle","Angle",60,90,80,function(v) sv["FSusAngle"]=v end)
sc["FPreCompress"]=hTab:Slider("FPreCompress","Pre-compression",0,1,0.2,function(v) sv["FPreCompress"]=v end)
sc["FCompressLim"]=hTab:Slider("FCompressLim","Compress limit",0.1,3,1.25,function(v) sv["FCompressLim"]=v end)
sc["FExtensionLim"]=hTab:Slider("FExtensionLim","Extension limit",0.1,3,1,function(v) sv["FExtensionLim"]=v end)
sc["FGyroDampening"]=hTab:Slider("FGyroDampening","Gyro dampening",0,200,50,function(v) sv["FGyroDampening"]=v end)
sc["FSwayBar"]=hTab:Slider("FSwayBar","Sway bar stiffness",0,10,2.1,function(v) sv["FSwayBar"]=v end)
hTab:Section("Rear Suspension")
sc["RSusStiffness"]=hTab:Slider("RSusStiffness","Spring stiffness",0.5,15,3.2,function(v) sv["RSusStiffness"]=v end)
sc["RSusDamping"]=hTab:Slider("RSusDamping","Damping",100,8000,3100,function(v) sv["RSusDamping"]=v end)
sc["RSusLength"]=hTab:Slider("RSusLength","Travel length",0.5,5,1.4,function(v) sv["RSusLength"]=v end)
sc["RSusAngle"]=hTab:Slider("RSusAngle","Angle",60,90,80,function(v) sv["RSusAngle"]=v end)
sc["RPreCompress"]=hTab:Slider("RPreCompress","Pre-compression",0,1,0.2,function(v) sv["RPreCompress"]=v end)
sc["RCompressLim"]=hTab:Slider("RCompressLim","Compress limit",0.1,3,2,function(v) sv["RCompressLim"]=v end)
sc["RExtensionLim"]=hTab:Slider("RExtensionLim","Extension limit",0.1,3,1,function(v) sv["RExtensionLim"]=v end)
sc["RGyroDampening"]=hTab:Slider("RGyroDampening","Gyro dampening",0,200,50,function(v) sv["RGyroDampening"]=v end)
sc["RSwayBar"]=hTab:Slider("RSwayBar","Sway bar stiffness",0,10,1.2,function(v) sv["RSwayBar"]=v end)

local alTab=UI:Tab("Align","//")
alTab:Section("Camber")
sc["FCamber"]=alTab:Slider("FCamber","Front camber",-10,5,-1,function(v) sv["FCamber"]=v end)
sc["RCamber"]=alTab:Slider("RCamber","Rear camber",-10,5,-2,function(v) sv["RCamber"]=v end)
alTab:Section("Caster")
sc["FCaster"]=alTab:Slider("FCaster","Front caster",-10,10,0,function(v) sv["FCaster"]=v end)
sc["RCaster"]=alTab:Slider("RCaster","Rear caster",-10,10,0,function(v) sv["RCaster"]=v end)
alTab:Section("Toe")
sc["FToe"]=alTab:Slider("FToe","Front toe",-5,5,0,function(v) sv["FToe"]=v end)
sc["RToe"]=alTab:Slider("RToe","Rear toe",-5,5,0,function(v) sv["RToe"]=v end)

local stTab=UI:Tab("Steer","//")
stTab:Section("Steering")
sc["SteerRatio"]=stTab:Slider("SteerRatio","Steering ratio",5,25,15,function(v) sv["SteerRatio"]=v end)
sc["LockToLock"]=stTab:Slider("LockToLock","Lock to lock turns",1,5,2.7,function(v) sv["LockToLock"]=v end)
sc["SteerSpeed"]=stTab:Slider("SteerSpeed","Steer speed",0.01,0.5,0.05,function(v) sv["SteerSpeed"]=v end)
sc["ReturnSpeed"]=stTab:Slider("ReturnSpeed","Return speed",0.01,0.5,0.15,function(v) sv["ReturnSpeed"]=v end)
sc["Ackerman"]=stTab:Slider("Ackerman","Ackerman geometry",0,2,1.1,function(v) sv["Ackerman"]=v end)
sc["MinSteer"]=stTab:Slider("MinSteer","Min steer angle",1,60,25,function(v) sv["MinSteer"]=v end)
stTab:Section("Steering Response")
sc["SteerP"]=stTab:Slider("SteerP","Steer P gain",5000,100000,30000,function(v) sv["SteerP"]=v end)
sc["SteerD"]=stTab:Slider("SteerD","Steer D gain",100,5000,1200,function(v) sv["SteerD"]=v end)
sc["SteerDecay"]=stTab:Slider("SteerDecay","Steer decay",10,1000,250,function(v) sv["SteerDecay"]=v end)
sc["SteerMaxTorque"]=stTab:Slider("SteerMaxTorque","Max steer torque",500,20000,4000,function(v) sv["SteerMaxTorque"]=v end)
stTab:Section("Rear Steer")
sc["RSteerDecay"]=stTab:Slider("RSteerDecay","Rear steer decay",0,1000,330,function(v) sv["RSteerDecay"]=v end)
sc["RSteerInner"]=stTab:Slider("RSteerInner","Rear inner angle",0,60,10,function(v) sv["RSteerInner"]=v end)
sc["RSteerOuter"]=stTab:Slider("RSteerOuter","Rear outer angle",0,60,10,function(v) sv["RSteerOuter"]=v end)
sc["RSteerSpeed"]=stTab:Slider("RSteerSpeed","Rear steer speed",0,200,60,function(v) sv["RSteerSpeed"]=v end)

local bkTab=UI:Tab("Brakes","//")
bkTab:Section("Brakes")
sc["BrakeForce"]=bkTab:Slider("BrakeForce","Brake force",100,10000,2100,function(v) sv["BrakeForce"]=v end)
sc["BrakeBias"]=bkTab:Slider("BrakeBias","Brake bias F/R",0.1,0.9,0.7,function(v) sv["BrakeBias"]=v end)
sc["BrakeAccel"]=bkTab:Slider("BrakeAccel","Brake accel",0.01,1,0.1,function(v) sv["BrakeAccel"]=v end)
sc["BrakeDecel"]=bkTab:Slider("BrakeDecel","Brake decel",0.01,1,0.2,function(v) sv["BrakeDecel"]=v end)
bkTab:Section("Handbrake")
sc["PBrakeForce"]=bkTab:Slider("PBrakeForce","Parking brake force",500,20000,3000,function(v) sv["PBrakeForce"]=v end)
sc["PBrakeBias"]=bkTab:Slider("PBrakeBias","Parking brake bias",0,1,0,function(v) sv["PBrakeBias"]=v end)
sc["EBrakeForce"]=bkTab:Slider("EBrakeForce","E-brake force",0,5000,500,function(v) sv["EBrakeForce"]=v end)

UI:TabDivider("System")
local sfTab=UI:Tab("Safety","//")
sfTab:Section("TCS")
sfTab:Toggle("TCS Enabled","Traction control system",true,function(v) sv["TCSEnabled"]=v end)
sc["TCSLimit"]=sfTab:Slider("TCSLimit","TCS slip limit %",0,50,8,function(v) sv["TCSLimit"]=v end)
sc["TCSGradient"]=sfTab:Slider("TCSGradient","TCS gradient",0,100,20,function(v) sv["TCSGradient"]=v end)
sc["TCSThreshold"]=sfTab:Slider("TCSThreshold","TCS threshold",0,50,10,function(v) sv["TCSThreshold"]=v end)
sfTab:Section("ABS")
sfTab:Toggle("ABS Enabled","Anti-lock braking system",true,function(v) sv["ABSEnabled"]=v end)
sc["ABSLimit"]=sfTab:Slider("ABSLimit","ABS limit",0,100,0,function(v) sv["ABSLimit"]=v end)
sc["ABSThreshold"]=sfTab:Slider("ABSThreshold","ABS threshold",0,50,5,function(v) sv["ABSThreshold"]=v end)
sfTab:Section("ESC")
sfTab:Toggle("ESC Enabled","Electronic stability control",true,function(v) sv["ESCEnabled"]=v end)
sc["ESCThreshold"]=sfTab:Slider("ESCThreshold","ESC threshold",0,2,0.75,function(v) sv["ESCThreshold"]=v end)
sc["ESCBrake"]=sfTab:Slider("ESCBrake","ESC brake %",0,100,60,function(v) sv["ESCBrake"]=v end)
sc["ESCThrottle"]=sfTab:Slider("ESCThrottle","ESC throttle cut %",0,100,60,function(v) sv["ESCThrottle"]=v end)
sc["ESCSpeed"]=sfTab:Slider("ESCSpeed","ESC min speed",0,100,30,function(v) sv["ESCSpeed"]=v end)
sfTab:Section("Misc")
sfTab:Toggle("Stall","Engine can stall",true,function(v) sv["Stall"]=v end)
sfTab:Toggle("Auto Flip","Auto flip upside down",true,function(v) sv["AutoFlip"]=v end)

task.wait(1)
UI:Notify("DBSB.su Loaded","UGC Tuner — RightAlt to toggle",4)
print("[DBSB.su] UGC Tuner v3.0 loaded — press APPLY in the sidebar header")
