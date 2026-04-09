-- DBSB.su | Blox Fruits | Key System
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local HttpService=game:GetService("HttpService")
local lp=Players.LocalPlayer
local T={
    BG=Color3.fromRGB(11,11,15),Sidebar=Color3.fromRGB(15,15,21),
    Card=Color3.fromRGB(20,20,28),CardHover=Color3.fromRGB(26,26,36),
    CardTop=Color3.fromRGB(32,32,44),Input=Color3.fromRGB(16,16,24),
    Purple=Color3.fromRGB(128,58,255),PurpleDim=Color3.fromRGB(80,35,160),
    PurpleDark=Color3.fromRGB(20,10,44),PurpleGlow=Color3.fromRGB(168,100,255),
    TextPrimary=Color3.fromRGB(238,238,244),TextSecond=Color3.fromRGB(148,148,168),
    TextMuted=Color3.fromRGB(72,72,92),Divider=Color3.fromRGB(28,28,40),
    Border=Color3.fromRGB(38,38,54),BorderAccent=Color3.fromRGB(88,48,178),
    Green=Color3.fromRGB(50,210,100),Red=Color3.fromRGB(230,60,60),
}
local F=Enum.Font.Code
local function tw(o,p,d,s,dir) local t=TweenService:Create(o,TweenInfo.new(d or 0.2,s or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),p) t:Play() return t end
local function new(c,p,par) local i=Instance.new(c) if p then for k,v in pairs(p) do i[k]=v end end if par then i.Parent=par end return i end
local function corner(r,p) return new("UICorner",{CornerRadius=UDim.new(0,r or 6)},p) end
local function stroke(c,t,p) return new("UIStroke",{Color=c or T.Border,Thickness=t or 1},p) end

local KEYAUTH={name="BF",ownerid="nSAWKQYzAd",secret="d7542ce19e4cc9a09d57097ccfc5e08fda04a201eb91fa2a26f80af35f71785f",version="1.0"}
local KEY_FILE="dbsb_key_bf2.txt"
local BASE="https://keyauth.win/api/1.2/"

local function doValidate(key)
    local initRaw=game:HttpGet(BASE.."?type=init&ver="..KEYAUTH.version.."&name="..HttpService:UrlEncode(KEYAUTH.name).."&ownerid="..KEYAUTH.ownerid)
    local initRes=HttpService:JSONDecode(initRaw)
    if not initRes.success then error(initRes.message or "Init failed") end
    local licRaw=game:HttpGet(BASE.."?type=license&key="..HttpService:UrlEncode(key).."&name="..HttpService:UrlEncode(KEYAUTH.name).."&ownerid="..KEYAUTH.ownerid.."&sessionid="..initRes.sessionid)
    local licRes=HttpService:JSONDecode(licRaw)
    if not licRes.success then error(licRes.message or "Invalid key") end
end

local old=lp.PlayerGui:FindFirstChild("DBSB_BF_Auth") if old then old:Destroy() end
local sg=new("ScreenGui",{Name="DBSB_BF_Auth",ResetOnSpawn=false,DisplayOrder=9999,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},lp.PlayerGui)
local W,H=480,300
local main=new("Frame",{Size=UDim2.new(0,W,0,H),Position=UDim2.new(0.5,-W/2,0.5,-H/2),BackgroundColor3=T.BG,BorderSizePixel=0},sg)
corner(10,main)
local mainStroke=stroke(T.Border,1,main)

task.spawn(function()
    local t=0
    while main.Parent do
        t=t+0.016
        mainStroke.Color=T.Border:Lerp(T.BorderAccent,(math.sin(t*1.1)+1)/2*0.6)
        task.wait(0.016)
    end
end)

task.spawn(function()
    local spacing=20
    local dc=new("Frame",{Size=UDim2.new(1,-180,1,0),Position=UDim2.new(0,180,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1,ClipsDescendants=true},main)
    for row=0,math.floor(H/spacing)+1 do
        for col=0,math.floor((W-180)/spacing)+1 do
            new("Frame",{Size=UDim2.new(0,1,0,1),Position=UDim2.new(0,col*spacing,0,row*spacing),BackgroundColor3=Color3.fromRGB(33,33,50),BorderSizePixel=0,ZIndex=1},dc)
        end
    end
end)

-- sidebar
local sb=new("Frame",{Size=UDim2.new(0,180,1,0),BackgroundColor3=T.Sidebar,BorderSizePixel=0,ZIndex=2},main)
corner(10,sb)
new("Frame",{Size=UDim2.new(0,10,1,0),Position=UDim2.new(1,-10,0,0),BackgroundColor3=T.Sidebar,BorderSizePixel=0,ZIndex=2},sb)
new("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Divider,BorderSizePixel=0,ZIndex=3},sb)
new("Frame",{Size=UDim2.new(1,0,0,58),BackgroundColor3=T.PurpleDark,BackgroundTransparency=0.55,BorderSizePixel=0,ZIndex=2},sb)
new("TextLabel",{Size=UDim2.new(1,-16,0,22),Position=UDim2.new(0,14,0,14),BackgroundTransparency=1,Text="DBSB.su",TextColor3=T.TextPrimary,TextSize=16,Font=F,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},sb)
local badge=new("Frame",{Size=UDim2.new(0,28,0,14),Position=UDim2.new(0,14,0,38),BackgroundColor3=T.PurpleDark,BorderSizePixel=0,ZIndex=5},sb)
corner(3,badge) stroke(T.BorderAccent,1,badge)
new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="v1.0",TextColor3=T.PurpleGlow,TextSize=9,Font=F,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6},badge)
new("TextLabel",{Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,14,0,54),BackgroundTransparency=1,Text="BLOX FRUITS",TextColor3=T.TextMuted,TextSize=9,Font=F,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},sb)

local accentLine=new("Frame",{Size=UDim2.new(0,30,0,1),Position=UDim2.new(0,14,0,72),BackgroundColor3=T.Purple,BorderSizePixel=0,ZIndex=4},sb)
new("Frame",{Size=UDim2.new(1,-44,0,1),Position=UDim2.new(0,44,0,72),BackgroundColor3=T.Divider,BorderSizePixel=0,ZIndex=3},sb)
task.spawn(function()
    local t=0
    while accentLine.Parent do
        t=t+0.016
        local s=math.abs(math.sin(t*0.7))
        accentLine.Size=UDim2.new(0,14+s*50,0,1)
        accentLine.BackgroundColor3=T.Purple:Lerp(T.PurpleGlow,s)
        task.wait(0.016)
    end
end)

new("TextLabel",{Size=UDim2.new(1,-28,0,14),Position=UDim2.new(0,14,0,90),BackgroundTransparency=1,Text="// paste your key",TextColor3=T.TextMuted,TextSize=9,Font=F,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},sb)

new("Frame",{Size=UDim2.new(1,-28,0,1),Position=UDim2.new(0,14,0,172),BackgroundColor3=T.Divider,BorderSizePixel=0,ZIndex=3},sb)
local dot=new("Frame",{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,14,0,182),BackgroundColor3=T.Green,BorderSizePixel=0,ZIndex=4},sb)
corner(3,dot)
new("TextLabel",{Size=UDim2.new(1,-28,0,14),Position=UDim2.new(0,26,0,178),BackgroundTransparency=1,Text="online",TextColor3=T.TextMuted,TextSize=9,Font=F,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},sb)
task.spawn(function()
    while dot.Parent do
        tw(dot,{BackgroundTransparency=0.6},0.9,Enum.EasingStyle.Sine)
        task.wait(0.9)
        tw(dot,{BackgroundTransparency=0},0.9,Enum.EasingStyle.Sine)
        task.wait(0.9)
    end
end)

local discBtn=new("TextButton",{Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,1,-38),BackgroundColor3=T.Card,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=4},sb)
corner(5,discBtn) stroke(T.Border,1,discBtn)
local discLbl=new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="// discord",TextColor3=T.Purple,TextSize=10,Font=F,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=5},discBtn)
discBtn.MouseEnter:Connect(function() tw(discBtn,{BackgroundColor3=T.CardHover},0.1) end)
discBtn.MouseLeave:Connect(function() tw(discBtn,{BackgroundColor3=T.Card},0.1) end)
discBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/9nPG6Gzg9p") end)
    discLbl.Text="// copied!" discLbl.TextColor3=T.Green
    task.delay(2,function() if discLbl.Parent then discLbl.Text="// discord" discLbl.TextColor3=T.Purple end end)
end)

-- right panel
local panel=new("Frame",{Size=UDim2.new(1,-180,1,0),Position=UDim2.new(0,180,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=3},main)
local statusLbl=new("TextLabel",{Size=UDim2.new(1,-32,0,16),Position=UDim2.new(0,16,0,16),BackgroundTransparency=1,Text="Enter your key to continue",TextColor3=T.TextMuted,TextSize=10,Font=F,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},panel)

local inputBg=new("Frame",{Size=UDim2.new(1,-32,0,40),Position=UDim2.new(0,16,0,40),BackgroundColor3=T.Input,BorderSizePixel=0,ZIndex=4},panel)
corner(6,inputBg)
new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.CardTop,BorderSizePixel=0,ZIndex=5},inputBg)
local inputSt=stroke(T.Border,1,inputBg)
local keyBox=new("TextBox",{Size=UDim2.new(1,-16,1,-2),Position=UDim2.new(0,10,0,2),BackgroundTransparency=1,PlaceholderText="Paste key here...",PlaceholderColor3=T.TextMuted,Text="",TextColor3=T.TextPrimary,TextSize=12,Font=F,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=5},inputBg)
keyBox.Focused:Connect(function() tw(inputSt,{Color=T.Purple},0.15) end)
keyBox.FocusLost:Connect(function() tw(inputSt,{Color=T.Border},0.15) end)

local actBtn=new("TextButton",{Size=UDim2.new(1,-32,0,38),Position=UDim2.new(0,16,0,92),BackgroundColor3=T.PurpleDark,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=4},panel)
corner(6,actBtn) stroke(T.BorderAccent,1,actBtn)
new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(60,30,120),BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=5},actBtn)
local actLbl=new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="ACTIVATE",TextColor3=T.PurpleGlow,TextSize=12,Font=F,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=5},actBtn)
actBtn.MouseEnter:Connect(function() tw(actBtn,{BackgroundColor3=T.PurpleDim},0.1) end)
actBtn.MouseLeave:Connect(function() tw(actBtn,{BackgroundColor3=T.PurpleDark},0.1) end)

new("TextLabel",{Size=UDim2.new(1,-32,0,14),Position=UDim2.new(0,16,0,138),BackgroundTransparency=1,Text="// key saves automatically",TextColor3=T.TextMuted,TextSize=9,Font=F,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},panel)

local dragging,dragStart,startPos
main.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true dragStart=i.Position startPos=main.Position end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

local function setStatus(msg,color) statusLbl.Text=msg statusLbl.TextColor3=color or T.TextMuted end

local busy=false
local function validateKey(key)
    if busy then return end
    key=key:gsub("%s+","")
    if key=="" then setStatus("Paste your key first.",T.Red) return end
    busy=true
    setStatus("Validating...",T.TextMuted)
    actLbl.Text="..."
    tw(actBtn,{BackgroundColor3=T.PurpleDark},0.1)
    task.spawn(function()
        local ok,err=pcall(doValidate,key)
        if ok then
            pcall(function() writefile(KEY_FILE,key) end)
            setStatus("Key valid — loading...",T.Green)
            actLbl.Text="LOADING..."
            tw(actBtn,{BackgroundColor3=Color3.fromRGB(12,44,22)},0.2)
            task.wait(0.8)
            sg:Destroy()
            getgenv().__dbsb_auth="d7f2a91bc84e3065fda28791c430b5e2"
            loadstring(game:HttpGet("https://raw.githubusercontent.com/JasonDBSB/dbsbrblx/refs/heads/main/dbsbbfscript.lua"))()
        else
            local msg=tostring(err):gsub(".*: ","")
            pcall(function() delfile(KEY_FILE) end)
            setStatus(msg,T.Red)
            actLbl.Text="ACTIVATE"
            tw(actBtn,{BackgroundColor3=T.PurpleDark},0.2)
            tw(inputBg,{BackgroundColor3=Color3.fromRGB(36,14,14)},0.1)
            task.delay(0.4,function() if inputBg.Parent then tw(inputBg,{BackgroundColor3=T.Input},0.3) end end)
            busy=false
        end
    end)
end

actBtn.MouseButton1Click:Connect(function() validateKey(keyBox.Text) end)
keyBox.FocusLost:Connect(function(enter) if enter then validateKey(keyBox.Text) end end)

task.spawn(function()
    local ok,saved=pcall(readfile,KEY_FILE)
    if ok and saved and saved~="" then
        saved=saved:gsub("%s+","")
        keyBox.Text=saved
        setStatus("Saved key found — validating...",T.TextMuted)
        task.wait(0.5)
        validateKey(saved)
    end
end)
