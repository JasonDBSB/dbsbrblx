-- ═══════════════════════════════════════════════════════
--  DBSB.su | Criminality Loader
--  discord.gg/AgTYJNjrVb
-- ═══════════════════════════════════════════════════════
local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local TweenService= game:GetService("TweenService")
local lp          = Players.LocalPlayer

local T = {
    BG           = Color3.fromRGB(11,11,15),
    Sidebar      = Color3.fromRGB(15,15,21),
    Card         = Color3.fromRGB(20,20,28),
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
    Red          = Color3.fromRGB(230,60,60),
    Green        = Color3.fromRGB(50,210,100),
    PillOff      = Color3.fromRGB(32,32,46),
}
local F = Enum.Font.Code

local function tw(o,p,d,s,dir)
    local t=TweenService:Create(o,TweenInfo.new(d or 0.2,s or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),p)
    t:Play() return t
end
local function new(c,p,par)
    local i=Instance.new(c)
    if p then for k,v in pairs(p) do i[k]=v end end
    if par then i.Parent=par end
    return i
end
local function corner(r,p) return new("UICorner",{CornerRadius=UDim.new(0,r or 6)},p) end
local function stroke(c,t,p) return new("UIStroke",{Color=c or T.Border,Thickness=t or 1},p) end

-- ── Destroy old ──────────────────────────────────────
local old = lp.PlayerGui:FindFirstChild("DBSB_KeySystem")
if old then old:Destroy() end

local sg = new("ScreenGui",{
    Name="DBSB_KeySystem", ResetOnSpawn=false, DisplayOrder=9999,
    IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
},lp.PlayerGui)

-- ── Main frame ───────────────────────────────────────
local main = new("Frame",{
    Size=UDim2.new(0,440,0,290),
    Position=UDim2.new(0.5,-220,0.5,-145),
    BackgroundColor3=T.BG, BorderSizePixel=0,
},sg)
corner(10,main)
local mainStroke = stroke(T.Border,1,main)

-- animated border pulse
task.spawn(function()
    local t=0
    while main.Parent do
        t=t+0.016
        mainStroke.Color=T.Border:Lerp(T.BorderAccent,(math.sin(t*1.1)+1)/2*0.6)
        task.wait(0.016)
    end
end)

-- ── Sidebar header ───────────────────────────────────
local header = new("Frame",{
    Size=UDim2.new(0,196,1,0),
    BackgroundColor3=T.Sidebar, BorderSizePixel=0,
},main)
corner(10,header)
-- cover right-side corners of sidebar
new("Frame",{Size=UDim2.new(0,10,1,0),Position=UDim2.new(1,-10,0,0),BackgroundColor3=T.Sidebar,BorderSizePixel=0},header)
new("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Divider,BorderSizePixel=0,ZIndex=3},header)

-- purple header wash
new("Frame",{Size=UDim2.new(1,0,0,58),BackgroundColor3=T.PurpleDark,BackgroundTransparency=0.55,BorderSizePixel=0,ZIndex=2},header)

-- title + badge
new("TextLabel",{
    Size=UDim2.new(0,110,0,22),Position=UDim2.new(0,14,0,13),
    BackgroundTransparency=1, Text="DBSB.su",
    TextColor3=T.TextPrimary, TextSize=16, Font=F,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4,
},header)

local badge=new("Frame",{Size=UDim2.new(0,28,0,14),Position=UDim2.new(0,114,0,17),BackgroundColor3=T.PurpleDark,BorderSizePixel=0,ZIndex=5},header)
corner(3,badge) stroke(T.BorderAccent,1,badge)
new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="v2.0",TextColor3=T.PurpleGlow,TextSize=9,Font=F,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6},badge)

new("TextLabel",{
    Size=UDim2.new(1,-28,0,14),Position=UDim2.new(0,14,0,37),
    BackgroundTransparency=1, Text="CRIMINALITY",
    TextColor3=T.TextMuted, TextSize=9, Font=F,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4,
},header)

-- animated accent line
local accentLine=new("Frame",{Size=UDim2.new(0,30,0,1),Position=UDim2.new(0,14,0,58),BackgroundColor3=T.Purple,BorderSizePixel=0,ZIndex=4},header)
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

-- bottom bar with discord button
local bottomBar=new("Frame",{Size=UDim2.new(1,0,0,40),Position=UDim2.new(0,0,1,-40),BackgroundColor3=T.Sidebar,BorderSizePixel=0,ZIndex=5},header)
new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Divider,BorderSizePixel=0},bottomBar)
local statusDot=new("Frame",{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,14,0.5,-3),BackgroundColor3=T.Green,BorderSizePixel=0,ZIndex=6},bottomBar) corner(3,statusDot)
new("TextLabel",{Size=UDim2.new(0,40,1,0),Position=UDim2.new(0,24,0,0),BackgroundTransparency=1,Text="ready",TextColor3=T.TextMuted,TextSize=9,Font=F,ZIndex=6},bottomBar)
task.spawn(function()
    while statusDot.Parent do
        tw(statusDot,{BackgroundTransparency=0.55},0.9,Enum.EasingStyle.Sine) task.wait(0.9)
        tw(statusDot,{BackgroundTransparency=0},0.9,Enum.EasingStyle.Sine) task.wait(0.9)
    end
end)

local discordBtn=new("TextButton",{Size=UDim2.new(0,76,0,20),Position=UDim2.new(1,-88,0.5,-10),BackgroundColor3=Color3.fromRGB(72,85,210),BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=6},bottomBar)
corner(3,discordBtn) stroke(Color3.fromRGB(95,108,232),1,discordBtn)
new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="✦ discord",TextColor3=Color3.fromRGB(255,255,255),TextSize=9,Font=F,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,ZIndex=7},discordBtn)
discordBtn.MouseEnter:Connect(function() tw(discordBtn,{BackgroundColor3=Color3.fromRGB(58,70,185)},0.1) end)
discordBtn.MouseLeave:Connect(function() tw(discordBtn,{BackgroundColor3=Color3.fromRGB(72,85,210)},0.1) end)
discordBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/AgTYJNjrVb") end)
end)

-- ── Right panel ───────────────────────────────────────
local panel = new("Frame",{
    Size=UDim2.new(1,-196,1,0), Position=UDim2.new(0,196,0,0),
    BackgroundTransparency=1, BorderSizePixel=0,
},main)

-- dot canvas background
task.spawn(function()
    local spacing=20
    for row=0,math.floor(290/spacing)+1 do
        for col=0,math.floor(244/spacing)+1 do
            new("Frame",{Size=UDim2.new(0,1,0,1),Position=UDim2.new(0,col*spacing,0,row*spacing),BackgroundColor3=Color3.fromRGB(33,33,50),BorderSizePixel=0,ZIndex=1},panel)
        end
    end
end)

-- status label
local statusLbl = new("TextLabel",{
    Size=UDim2.new(1,-24,0,14), Position=UDim2.new(0,14,0,32),
    BackgroundTransparency=1, Text="Enter your license key to continue.",
    TextColor3=T.TextSecond, TextSize=10, Font=F,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4,
},panel)

-- key input
local inputBg = new("Frame",{
    Size=UDim2.new(1,-24,0,38), Position=UDim2.new(0,12,0,56),
    BackgroundColor3=T.Input, BorderSizePixel=0, ZIndex=3,
},panel)
corner(6,inputBg)
local iStroke = stroke(T.Border,1,inputBg)

local keyBox = new("TextBox",{
    Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0),
    BackgroundTransparency=1,
    PlaceholderText="Paste key here...",
    PlaceholderColor3=T.TextMuted,
    Text="", TextColor3=T.TextPrimary,
    TextSize=12, Font=F,
    TextXAlignment=Enum.TextXAlignment.Left,
    ClearTextOnFocus=false, ZIndex=4,
},inputBg)

keyBox.Focused:Connect(function() tw(iStroke,{Color=T.Purple},0.15) end)
keyBox.FocusLost:Connect(function() tw(iStroke,{Color=T.Border},0.15) end)

-- activate button
local activateBtn = new("TextButton",{
    Size=UDim2.new(1,-24,0,38), Position=UDim2.new(0,12,0,106),
    BackgroundColor3=T.PurpleDark, BorderSizePixel=0,
    Text="", AutoButtonColor=false, ZIndex=3, ClipsDescendants=true,
},panel)
corner(6,activateBtn)
stroke(T.BorderAccent,1,activateBtn)
new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.BorderAccent,BorderSizePixel=0,ZIndex=4},activateBtn)

local activateLbl = new("TextLabel",{
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="Activate", TextColor3=T.PurpleGlow,
    TextSize=12, Font=F, TextXAlignment=Enum.TextXAlignment.Center,
    ZIndex=5,
},activateBtn)

activateBtn.MouseEnter:Connect(function() tw(activateBtn,{BackgroundColor3=T.PurpleDim},0.1) end)
activateBtn.MouseLeave:Connect(function() tw(activateBtn,{BackgroundColor3=T.PurpleDark},0.1) end)

-- get key button
local getKeyBtn = new("TextButton",{
    Size=UDim2.new(1,-24,0,30), Position=UDim2.new(0,12,0,156),
    BackgroundColor3=T.Card, BorderSizePixel=0,
    Text="", AutoButtonColor=false, ZIndex=3,
},panel)
corner(6,getKeyBtn) stroke(T.Border,1,getKeyBtn)
new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(32,32,44),BorderSizePixel=0,ZIndex=4},getKeyBtn)
new("TextLabel",{
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="Get a key  //  discord.gg/AgTYJNjrVb",
    TextColor3=T.TextMuted, TextSize=9, Font=F,
    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=4,
},getKeyBtn)
getKeyBtn.MouseEnter:Connect(function() tw(getKeyBtn,{BackgroundColor3=Color3.fromRGB(26,26,36)},0.1) end)
getKeyBtn.MouseLeave:Connect(function() tw(getKeyBtn,{BackgroundColor3=T.Card},0.1) end)
getKeyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/AgTYJNjrVb") end)
end)

-- ── Drag (from header) ────────────────────────────────
local dragging, dragStart, startPos
header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true dragStart=i.Position startPos=main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- ── KeyAuth ───────────────────────────────────────────
local KEYAUTH = {
    name    = "CRM",
    ownerid = "cOq8oN1yAR",  
    secret  = "d2a9110da9db065488cbcaeee5d6404fdf3f5f923ffd5bc3b4b66dbc6bfa4db8",
    version = "1.0",
}

-- URL to your hosted main script
local SCRIPT_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/dbsb_criminality.lua"

local function setStatus(msg, color)
    statusLbl.Text = msg
    statusLbl.TextColor3 = color or T.TextSecond
end

local function shakeInput()
    local orig = inputBg.Position
    for i = 1, 4 do
        tw(inputBg,{Position=UDim2.new(
            orig.X.Scale, orig.X.Offset+(i%2==0 and 5 or -5),
            orig.Y.Scale, orig.Y.Offset
        )},0.05)
        task.wait(0.055)
    end
    tw(inputBg,{Position=orig},0.05)
end

local function validateKey(key)
    key = key:gsub("%s+","")
    if key == "" then
        setStatus("Please enter a key.", T.Red)
        shakeInput()
        return
    end

    setStatus("Validating...", T.TextMuted)
    activateLbl.Text = "Validating..."

    local ok, result = pcall(function()
        local HS  = game:GetService("HttpService")
        local url = "https://keyauth.win/api/1.3/"
        local hwid = tostring(game:GetService("RbxAnalyticsService"):GetClientId())

        -- Step 1: init — get a sessionid
        local initUrl = url
            .."?type=init"
            .."&name="    ..HS:UrlEncode(KEYAUTH.name)
            .."&ownerid=" ..HS:UrlEncode(KEYAUTH.ownerid)
            .."&version=" ..HS:UrlEncode(KEYAUTH.version)
            .."&secret="  ..HS:UrlEncode(KEYAUTH.secret)
        local initResp = HS:JSONDecode(game:HttpGet(initUrl))
        if not initResp or not initResp.success then
            return false, (initResp and initResp.message) or "Init failed"
        end
        local sessionid = initResp.sessionid

        -- Step 2: license check
        local licUrl = url
            .."?type=license"
            .."&key="       ..HS:UrlEncode(key)
            .."&sessionid=" ..HS:UrlEncode(sessionid)
            .."&name="      ..HS:UrlEncode(KEYAUTH.name)
            .."&ownerid="   ..HS:UrlEncode(KEYAUTH.ownerid)
            .."&hwid="      ..HS:UrlEncode(hwid)
        local licResp = HS:JSONDecode(game:HttpGet(licUrl))
        return licResp and licResp.success == true, licResp and licResp.message
    end)

    -- ok=true means pcall succeeded; result is the bool from inner return
    local success = ok and result

    if success then
        setStatus("Key valid! Loading...", T.Green)
        activateLbl.Text = "Loading..."
        tw(activateBtn,{BackgroundColor3=Color3.fromRGB(15,40,20)},0.2)
        task.wait(1.2)
        getgenv().__dbsb_auth = "d7f2a91bc84e3065fda28791c430b5e2"
        sg:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL))()
    else
        local errMsg = type(result)=="string" and result or "Invalid or expired key."
        setStatus(errMsg, T.Red)
        activateLbl.Text = "Activate"
        tw(activateBtn,{BackgroundColor3=T.PurpleDark},0.2)
        shakeInput()
    end
end

activateBtn.MouseButton1Click:Connect(function()
    -- ripple effect
    local mp=UIS:GetMouseLocation() local rp=mp-activateBtn.AbsolutePosition
    local ripple=new("Frame",{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0,rp.X,0,rp.Y),BackgroundColor3=T.Purple,BackgroundTransparency=0.65,BorderSizePixel=0,ZIndex=6},activateBtn)
    corner(50,ripple)
    tw(ripple,{Size=UDim2.new(0,300,0,300),Position=UDim2.new(0,rp.X-150,0,rp.Y-150),BackgroundTransparency=1},0.5,Enum.EasingStyle.Quad)
    task.delay(0.5,function() ripple:Destroy() end)
    validateKey(keyBox.Text)
end)

keyBox.FocusLost:Connect(function(enter)
    if enter then validateKey(keyBox.Text) end
end)
