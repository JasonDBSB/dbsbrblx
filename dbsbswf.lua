-- ─────────────────────────────────────────
--  DBSB SWF Tuner v3.0
--  Carbon / Racing Aesthetic
--  Live stats panel + top speed control
--  RightAlt to toggle
-- ─────────────────────────────────────────

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

local buildTunerUI
local tunerRows   = {}
local currentTune = nil
local stockValues = {}
local statsConn   = nil

-- ── Helpers ───────────────────────────────
local function getVehicle()
    local char = lp.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil end
    return hum.SeatPart.Parent
end

local function getInterface()
    local veh = getVehicle()
    if not veh then return nil end
    local mod = veh:FindFirstChild("A-Chassis Tune")
    if not mod then return nil end
    return mod:FindFirstChild("A-Chassis Interface")
end

local function loadStock()
    local veh = getVehicle()
    if not veh then return false end
    local mod = veh:FindFirstChild("A-Chassis Tune")
    if not mod then return false end
    local ok, tune = pcall(require, mod)
    if not ok or type(tune) ~= "table" then return false end
    currentTune = tune
    stockValues = {}
    for k, v in pairs(tune) do
        if type(v) == "number" then stockValues[k] = v end
    end
    local fd = veh:FindFirstChild("fD")
    if fd then stockValues["fD"] = fd.Value end
    return true
end

local function applyValue(key, value)
    if key == "fD" then
        local veh = getVehicle()
        if veh then
            local fd = veh:FindFirstChild("fD")
            if fd then fd.Value = value end
        end
        return
    end
    if currentTune and currentTune[key] ~= nil then
        currentTune[key] = value
    end
end

local function resetAll()
    for k, v in pairs(stockValues) do applyValue(k, v) end
    buildTunerUI()
    print("[DBSB] Reset to stock")
end

-- ── Colors ────────────────────────────────
local C = {
    bg        = Color3.fromRGB(10,  10,  10),
    panel     = Color3.fromRGB(16,  16,  16),
    card      = Color3.fromRGB(20,  20,  20),
    border    = Color3.fromRGB(35,  35,  35),
    accent    = Color3.fromRGB(220, 160, 40),   -- gold
    accent2   = Color3.fromRGB(255, 200, 80),
    accentDim = Color3.fromRGB(60,  45,  10),
    text      = Color3.fromRGB(220, 220, 220),
    textDim   = Color3.fromRGB(120, 120, 120),
    green     = Color3.fromRGB(60,  200, 80),
    red       = Color3.fromRGB(220, 60,  60),
    track     = Color3.fromRGB(30,  30,  30),
}

-- ── GUI root ──────────────────────────────
local old = lp.PlayerGui:FindFirstChild("DBSB_SWFTuner")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "DBSB_SWFTuner"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999
sg.IgnoreGuiInset = true
sg.Parent = lp.PlayerGui
sg.Enabled = false

-- Main window
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 560, 0, 620)
main.Position = UDim2.new(0.5, -280, 0.5, -310)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)

-- Gold top accent line
local topLine = Instance.new("Frame", main)
topLine.Size = UDim2.new(1, 0, 0, 2)
topLine.BackgroundColor3 = C.accent
topLine.BorderSizePixel = 0

-- Outer border
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(40, 40, 40)
stroke.Thickness = 1

-- ── Header ────────────────────────────────
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 50)
header.Position = UDim2.new(0, 0, 0, 2)
header.BackgroundColor3 = C.panel
header.BorderSizePixel = 0

-- Logo area
local logo = Instance.new("TextLabel", header)
logo.Size = UDim2.new(0, 160, 1, 0)
logo.Position = UDim2.new(0, 14, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "DBSB  TUNER"
logo.TextColor3 = C.accent
logo.TextSize = 18
logo.Font = Enum.Font.GothamBold
logo.TextXAlignment = Enum.TextXAlignment.Left

local subLogo = Instance.new("TextLabel", header)
subLogo.Size = UDim2.new(0, 160, 0, 14)
subLogo.Position = UDim2.new(0, 14, 1, -16)
subLogo.BackgroundTransparency = 1
subLogo.Text = "SOUTHWEST FLORIDA"
subLogo.TextColor3 = C.textDim
subLogo.TextSize = 9
subLogo.Font = Enum.Font.Gotham
subLogo.TextXAlignment = Enum.TextXAlignment.Left

local statusLbl = Instance.new("TextLabel", header)
statusLbl.Size = UDim2.new(0, 220, 0, 14)
statusLbl.Position = UDim2.new(1, -230, 0.5, -7)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "NO VEHICLE"
statusLbl.TextColor3 = C.red
statusLbl.TextSize = 10
statusLbl.Font = Enum.Font.GothamBold
statusLbl.TextXAlignment = Enum.TextXAlignment.Right

-- Header separator
local hSep = Instance.new("Frame", header)
hSep.Size = UDim2.new(1, -28, 0, 1)
hSep.Position = UDim2.new(0, 14, 1, -1)
hSep.BackgroundColor3 = C.border
hSep.BorderSizePixel = 0

-- Drag on header
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

-- ── Live Stats Bar ────────────────────────
local statsBar = Instance.new("Frame", main)
statsBar.Size = UDim2.new(1, -28, 0, 56)
statsBar.Position = UDim2.new(0, 14, 0, 58)
statsBar.BackgroundColor3 = C.card
statsBar.BorderSizePixel = 0
Instance.new("UICorner", statsBar).CornerRadius = UDim.new(0, 4)
local statStroke = Instance.new("UIStroke", statsBar)
statStroke.Color = C.border
statStroke.Thickness = 1

local statDefs = {
    {key="RPM",   label="RPM",    fmt="%d",   unit=""},
    {key="Boost", label="BOOST",  fmt="%.1f", unit="psi"},
    {key="Speed", label="SPEED",  fmt="%d",   unit="mph"},
    {key="Gear",  label="GEAR",   fmt="%s",   unit=""},
    {key="HP",    label="HP",     fmt="%d",   unit=""},
    {key="Fuel",  label="FUEL",   fmt="%d",   unit="%"},
}

local statLabels = {}
local statW = 1 / #statDefs

for i, def in ipairs(statDefs) do
    local col = Instance.new("Frame", statsBar)
    col.Size = UDim2.new(statW, 0, 1, 0)
    col.Position = UDim2.new(statW*(i-1), 0, 0, 0)
    col.BackgroundTransparency = 1

    if i > 1 then
        local div = Instance.new("Frame", col)
        div.Size = UDim2.new(0, 1, 0.6, 0)
        div.Position = UDim2.new(0, 0, 0.2, 0)
        div.BackgroundColor3 = C.border
        div.BorderSizePixel = 0
    end

    local valLbl = Instance.new("TextLabel", col)
    valLbl.Size = UDim2.new(1, 0, 0, 26)
    valLbl.Position = UDim2.new(0, 0, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = "--"
    valLbl.TextColor3 = C.accent
    valLbl.TextSize = 18
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Center

    local keyLbl = Instance.new("TextLabel", col)
    keyLbl.Size = UDim2.new(1, 0, 0, 12)
    keyLbl.Position = UDim2.new(0, 0, 1, -14)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Text = def.label
    keyLbl.TextColor3 = C.textDim
    keyLbl.TextSize = 8
    keyLbl.Font = Enum.Font.GothamBold
    keyLbl.TextXAlignment = Enum.TextXAlignment.Center

    statLabels[def.key] = {val=valLbl, def=def}
end

-- Stats updater
local function startStats()
    if statsConn then statsConn:Disconnect() end
    statsConn = RunService.Heartbeat:Connect(function()
        local iface = getInterface()
        local veh   = getVehicle()
        if not iface then
            for _, s in pairs(statLabels) do s.val.Text = "--" end
            return
        end
        local vals = iface:FindFirstChild("Values")
        if not vals then return end

        local rpm   = vals:FindFirstChild("RPM")
        local boost = vals:FindFirstChild("Boost")
        local vel   = vals:FindFirstChild("Velocity")
        local gear  = vals:FindFirstChild("Gear")
        local hp    = vals:FindFirstChild("HpBoosted")
        local fuel  = veh and veh:FindFirstChild("Fuel")
        local gasCap = veh and veh:FindFirstChild("gasCap")

        if statLabels.RPM and rpm then
            statLabels.RPM.val.Text = string.format("%d", rpm.Value)
        end
        if statLabels.Boost and boost then
            local b = boost.Value * 14.5 -- convert to psi approx
            statLabels.Boost.val.Text = string.format("%.1f", b)
            statLabels.Boost.val.TextColor3 = b > 10 and C.accent2 or C.accent
        end
        if statLabels.Speed and vel then
            local spd = vel.Value.Magnitude * 2.237 -- studs/s to mph approx
            statLabels.Speed.val.Text = string.format("%d", spd)
            statLabels.Speed.val.TextColor3 = spd > 150 and C.accent2 or C.accent
        end
        if statLabels.Gear and gear then
            local g = gear.Value
            statLabels.Gear.val.Text = g == 0 and "N" or g == -1 and "R" or tostring(g)
        end
        if statLabels.HP and hp then
            statLabels.HP.val.Text = string.format("%d", hp.Value)
        end
        if statLabels.Fuel and fuel and gasCap then
            local pct = math.floor((fuel.Value / gasCap.Value) * 100)
            statLabels.Fuel.val.Text = tostring(math.clamp(pct, 0, 100))
            statLabels.Fuel.val.TextColor3 = pct < 20 and C.red or C.accent
        end
    end)
end

-- ── Tab system ────────────────────────────
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1, -28, 0, 30)
tabBar.Position = UDim2.new(0, 14, 0, 122)
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)

local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, -28, 1, -222)
contentArea.Position = UDim2.new(0, 14, 0, 158)
contentArea.BackgroundColor3 = C.card
contentArea.BorderSizePixel = 0
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 4)
local cStroke = Instance.new("UIStroke", contentArea)
cStroke.Color = C.border
cStroke.Thickness = 1

local tabs = {}
local activeTab = nil

local function makeTab(name, order)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0, 68, 1, 0)
    btn.BackgroundColor3 = C.card
    btn.Text = name
    btn.TextColor3 = C.textDim
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.AutoButtonColor = false
    btn.Selectable = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = C.border
    btnStroke.Thickness = 1

    local scroll = Instance.new("ScrollingFrame", contentArea)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = C.accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Visible = false

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 4)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingLeft  = UDim.new(0, 8)
    pad.PaddingTop   = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 8)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    local tab = {btn=btn, scroll=scroll, btnStroke=btnStroke}
    tabs[name] = tab

    btn.MouseButton1Click:Connect(function()
        if activeTab then
            activeTab.btn.BackgroundColor3 = C.card
            activeTab.btn.TextColor3 = C.textDim
            activeTab.btnStroke.Color = C.border
            activeTab.scroll.Visible = false
        end
        activeTab = tab
        btn.BackgroundColor3 = C.accentDim
        btn.TextColor3 = C.accent
        btnStroke.Color = C.accent
        scroll.Visible = true
    end)

    return tab
end

local tEngine = makeTab("ENGINE", 1)
local tTurbo  = makeTab("TURBO",  2)
local tTrans  = makeTab("TRANS",  3)
local tHandle = makeTab("HANDLE", 4)
local tSusp   = makeTab("SUSP",   5)
local tBrakes = makeTab("BRAKES", 6)
local tGrip   = makeTab("GRIP",   7)

-- Activate engine tab
activeTab = tEngine
tEngine.btn.BackgroundColor3 = C.accentDim
tEngine.btn.TextColor3 = C.accent
tEngine.btnStroke.Color = C.accent
tEngine.scroll.Visible = true

-- ── Bottom bar ────────────────────────────
local botBar = Instance.new("Frame", main)
botBar.Size = UDim2.new(1, -28, 0, 44)
botBar.Position = UDim2.new(0, 14, 1, -52)
botBar.BackgroundTransparency = 1
botBar.BorderSizePixel = 0

local function makeBtn(parent, text, x, w, accent, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, w, 0, 30)
    b.Position = UDim2.new(0, x, 0.5, -15)
    b.BackgroundColor3 = accent and C.accentDim or C.card
    b.Text = text
    b.TextColor3 = accent and C.accent or C.textDim
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Selectable = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", b)
    s.Color = accent and C.accent or C.border
    s.Thickness = 1
    b.MouseButton1Click:Connect(cb)
    -- Hover
    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = accent and Color3.fromRGB(80,55,10) or Color3.fromRGB(28,28,28)
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = accent and C.accentDim or C.card
    end)
    return b
end

makeBtn(botBar, "RELOAD",     0,   80,  true,  function()
    if loadStock() then
        statusLbl.Text = "LOADED: "..(getVehicle() and getVehicle().Name:upper() or "?")
        statusLbl.TextColor3 = C.green
        buildTunerUI()
        startStats()
    else
        statusLbl.Text = "NO VEHICLE"
        statusLbl.TextColor3 = C.red
    end
end)
makeBtn(botBar, "RESET",      88,  70,  false, resetAll)
makeBtn(botBar, "APPLY ALL",  166, 90,  false, function()
    for key, row in pairs(tunerRows) do applyValue(key, row.currentVal) end
    print("[DBSB] Applied all")
end)
makeBtn(botBar, "CLOSE",      264, 70,  false, function() sg.Enabled = false end)

-- ── Section header ────────────────────────
local function makeSectionHeader(scroll, title)
    local f = Instance.new("Frame", scroll)
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0

    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = C.border
    line.BorderSizePixel = 0

    local accent = Instance.new("Frame", f)
    accent.Size = UDim2.new(0, 3, 0, 14)
    accent.Position = UDim2.new(0, 0, 0.5, -7)
    accent.BackgroundColor3 = C.accent
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -12, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = C.accent
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- ── Slider ────────────────────────────────
local function makeSlider(scroll, key, label, min, max, step, unit)
    unit = unit or ""
    local val = (currentTune and currentTune[key]) or stockValues[key] or (min+max)/2
    val = math.clamp(val, min, max)
    step = step or 1

    local row = Instance.new("Frame", scroll)
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = C.panel
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
    local rStroke = Instance.new("UIStroke", row)
    rStroke.Color = C.border
    rStroke.Thickness = 1

    -- Label
    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(0.32, 0, 0, 16)
    nameLbl.Position = UDim2.new(0, 10, 0, 4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = label:upper()
    nameLbl.TextColor3 = C.textDim
    nameLbl.TextSize = 9
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Value display
    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size = UDim2.new(0.22, 0, 0, 16)
    valLbl.Position = UDim2.new(0, 10, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = ""
    valLbl.TextColor3 = C.accent
    valLbl.TextSize = 11
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Size = UDim2.new(1, -100, 0, 16)
    valLbl.Position = UDim2.new(0, 0, 0, 4)

    -- Track background
    local trackBg = Instance.new("Frame", row)
    trackBg.Size = UDim2.new(1, -100, 0, 4)
    trackBg.Position = UDim2.new(0, 10, 1, -14)
    trackBg.BackgroundColor3 = C.track
    trackBg.BorderSizePixel = 0
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(0, 2)

    local pct = math.clamp((val-min)/(max-min), 0, 1)

    -- Fill
    local fill = Instance.new("Frame", trackBg)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

    -- Glow on fill end
    local knob = Instance.new("Frame", trackBg)
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(pct, -5, 0.5, -5)
    knob.BackgroundColor3 = C.accent2
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)

    -- SET button
    local setBtn = Instance.new("TextButton", row)
    setBtn.Size = UDim2.new(0, 42, 0, 22)
    setBtn.Position = UDim2.new(1, -48, 0.5, -11)
    setBtn.BackgroundColor3 = C.accentDim
    setBtn.Text = "SET"
    setBtn.TextColor3 = C.accent
    setBtn.TextSize = 9
    setBtn.Font = Enum.Font.GothamBold
    setBtn.BorderSizePixel = 0
    setBtn.AutoButtonColor = false
    setBtn.Selectable = false
    Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 3)
    local sBtnStroke = Instance.new("UIStroke", setBtn)
    sBtnStroke.Color = C.accent
    sBtnStroke.Thickness = 1

    -- Format value
    local function fmtVal(v)
        if step < 0.01 then return string.format("%.3f", v)
        elseif step < 0.1 then return string.format("%.2f", v)
        elseif step < 1   then return string.format("%.1f", v)
        else return string.format("%d", v) end
    end

    -- Init display
    valLbl.Text = fmtVal(val) .. (unit ~= "" and " "..unit or "")

    local currentVal = val
    local sliding = false

    local function update(x)
        local p2 = math.clamp((x - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        local v = min + (max-min)*p2
        if step > 0 then v = math.floor(v/step + 0.5)*step end
        v = math.clamp(v, min, max)
        currentVal = v
        local p3 = math.clamp((v-min)/(max-min), 0, 1)
        fill.Size = UDim2.new(p3, 0, 1, 0)
        knob.Position = UDim2.new(p3, -5, 0.5, -5)
        valLbl.Text = fmtVal(v) .. (unit ~= "" and " "..unit or "")
    end

    trackBg.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true update(i.Position.X) end
    end)
    knob.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true end
    end)
    UIS.InputChanged:Connect(function(i)
        if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
    end)

    setBtn.MouseButton1Click:Connect(function()
        applyValue(key, currentVal)
        -- Flash green
        setBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 20)
        setBtn.TextColor3 = C.green
        sBtnStroke.Color = C.green
        task.delay(0.4, function()
            setBtn.BackgroundColor3 = C.accentDim
            setBtn.TextColor3 = C.accent
            sBtnStroke.Color = C.accent
        end)
    end)

    -- Row hover
    row.MouseEnter:Connect(function() rStroke.Color = Color3.fromRGB(55,55,55) end)
    row.MouseLeave:Connect(function() rStroke.Color = C.border end)

    tunerRows[key] = {currentVal=currentVal}
    return row
end

-- ── Top Speed Calculator ──────────────────
local function makeTopSpeedControl(scroll)
    local f = Instance.new("Frame", scroll)
    f.Size = UDim2.new(1, 0, 0, 60)
    f.BackgroundColor3 = C.accentDim
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local fStroke = Instance.new("UIStroke", f)
    fStroke.Color = C.accent
    fStroke.Thickness = 1

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -160, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = "TARGET TOP SPEED"
    lbl.TextColor3 = C.accent
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", f)
    sub.Size = UDim2.new(1, -160, 0, 14)
    sub.Position = UDim2.new(0, 10, 0, 26)
    sub.BackgroundTransparency = 1
    sub.Text = "Auto-calculates Final Drive"
    sub.TextColor3 = C.textDim
    sub.TextSize = 9
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", f)
    valLbl.Size = UDim2.new(0, 80, 0, 30)
    valLbl.Position = UDim2.new(1, -150, 0.5, -15)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = "200 mph"
    valLbl.TextColor3 = C.accent2
    valLbl.TextSize = 20
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local applyBtn = Instance.new("TextButton", f)
    applyBtn.Size = UDim2.new(0, 60, 0, 28)
    applyBtn.Position = UDim2.new(1, -68, 0.5, -14)
    applyBtn.BackgroundColor3 = C.accent
    applyBtn.Text = "APPLY"
    applyBtn.TextColor3 = C.bg
    applyBtn.TextSize = 10
    applyBtn.Font = Enum.Font.GothamBold
    applyBtn.BorderSizePixel = 0
    applyBtn.AutoButtonColor = false
    applyBtn.Selectable = false
    Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 4)

    -- Track for target speed
    local trackBg = Instance.new("Frame", f)
    trackBg.Size = UDim2.new(1, -170, 0, 4)
    trackBg.Position = UDim2.new(0, 10, 1, -14)
    trackBg.BackgroundColor3 = C.track
    trackBg.BorderSizePixel = 0
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(0, 2)

    local tfill = Instance.new("Frame", trackBg)
    tfill.Size = UDim2.new(0.5, 0, 1, 0)
    tfill.BackgroundColor3 = C.accent
    tfill.BorderSizePixel = 0
    Instance.new("UICorner", tfill).CornerRadius = UDim.new(0, 2)

    local tknob = Instance.new("Frame", trackBg)
    tknob.Size = UDim2.new(0, 10, 0, 10)
    tknob.Position = UDim2.new(0.5, -5, 0.5, -5)
    tknob.BackgroundColor3 = C.accent2
    tknob.BorderSizePixel = 0
    Instance.new("UICorner", tknob).CornerRadius = UDim.new(0.5, 0)

    local targetSpeed = 200
    local minSpd, maxSpd = 50, 500
    local sliding = false

    local function updateSpeed(x)
        local p = math.clamp((x - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        targetSpeed = math.floor(minSpd + (maxSpd-minSpd)*p)
        tfill.Size = UDim2.new(p, 0, 1, 0)
        tknob.Position = UDim2.new(p, -5, 0.5, -5)
        valLbl.Text = targetSpeed .. " mph"
    end

    trackBg.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true updateSpeed(i.Position.X) end
    end)
    tknob.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true end
    end)
    UIS.InputChanged:Connect(function(i)
        if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then updateSpeed(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
    end)

    applyBtn.MouseButton1Click:Connect(function()
        -- top speed mph = (E_Redline / 60) * (1/fD) * wheel_circ_approx
        -- Solve for fD: fD = (E_Redline / 60) * wheel_circ / targetSpeed_studs
        -- wheel circ approx 2.0 studs, 1 stud/s = 0.681 mph
        local redline = (currentTune and currentTune.E_Redline) or 12700
        local wheelCirc = 2.0
        local targetStuds = targetSpeed / 0.681 / 2.237
        local newFD = (redline / 60) * wheelCirc / targetStuds
        newFD = math.clamp(newFD, 0.05, 5.0)
        applyValue("fD", newFD)
        -- Also update the fD slider if it exists
        if tunerRows["fD"] then tunerRows["fD"].currentVal = newFD end
        applyBtn.BackgroundColor3 = C.green
        task.delay(0.5, function() applyBtn.BackgroundColor3 = C.accent end)
        print("[DBSB] Target " .. targetSpeed .. " mph → fD = " .. string.format("%.3f", newFD))
    end)
end

-- ── Build tabs ────────────────────────────
function buildTunerUI()
    tunerRows = {}
    for _, tab in pairs(tabs) do
        for _, v in ipairs(tab.scroll:GetChildren()) do
            if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then v:Destroy() end
        end
    end

    if not currentTune then
        statusLbl.Text = "NO VEHICLE"
        statusLbl.TextColor3 = C.red
        return
    end

    -- ENGINE
    local s = tEngine.scroll
    makeSectionHeader(s, "TOP SPEED")
    makeTopSpeedControl(s)
    makeSectionHeader(s, "POWER")
    makeSlider(s, "fD",           "Final Drive",   0.05, 3,     0.001)
    makeSlider(s, "Horsepower",   "Horsepower",    50,   2000,  1,   "hp")
    makeSlider(s, "E_Torque",     "Torque",        50,   2000,  1,   "nm")
    makeSlider(s, "PeakRPM",      "Peak RPM",      1000, 10000, 100)
    makeSlider(s, "E_Redline",    "Redline",       4000, 20000, 100, "rpm")
    makeSlider(s, "NeutralRevRPM","Idle RPM",      500,  5000,  50,  "rpm")
    makeSectionHeader(s, "REV")
    makeSlider(s, "RevAccel",     "Rev Accel",     50,   1000,  10)
    makeSlider(s, "RevDecay",     "Rev Decay",     10,   500,   5)
    makeSlider(s, "EH_EndMult",   "End Mult",      0.5,  10,    0.1)

    -- TURBO
    s = tTurbo.scroll
    makeSectionHeader(s, "FORCED INDUCTION")
    makeSlider(s, "Turbochargers", "Turbos",        0, 100,  1)
    makeSlider(s, "Superchargers", "Superchargers", 0, 100,  1)
    makeSlider(s, "T_Size",        "Turbo Size",    0, 500,  1)
    makeSlider(s, "S_Boost",       "Boost",         0, 500,  0.1, "psi")
    makeSlider(s, "S_Sensitivity", "Boost Sens",    0, 1,    0.01)
    makeSectionHeader(s, "SAFETY")
    makeSlider(s, "TCSLimit",      "TCS Limit",     0, 100,  1)
    makeSlider(s, "ABSThreshold",  "ABS Threshold", 0, 100,  1)

    -- TRANS
    s = tTrans.scroll
    makeSectionHeader(s, "SHIFTING")
    makeSlider(s, "ShiftUpTime",   "Shift Time",    0.01, 1,   0.01, "s")
    makeSlider(s, "ShiftThrot",    "Shift Throttle",0,    100, 1,   "%")
    makeSlider(s, "ClutchEngage",  "Clutch Engage", 0,    100, 1)
    makeSlider(s, "ClutchRPMMult", "Clutch RPM",    0,    5,   0.1)
    makeSectionHeader(s, "DIFFERENTIAL")
    makeSlider(s, "RDiffPreload",  "R Preload",     0,   200,  1)
    makeSlider(s, "RDiffLockThres","R Lock",        0,   100,  1)
    makeSlider(s, "RDiffSlipThres","R Slip",        0,   200,  1)
    makeSlider(s, "RDiffCoast",    "R Coast",       0,   100,  1)
    makeSlider(s, "CDiffSlipThres","C Slip",        0,   200,  1)

    -- HANDLING
    s = tHandle.scroll
    makeSectionHeader(s, "STEERING")
    makeSlider(s, "SteerRatio",    "Ratio",         1,    30,  0.1)
    makeSlider(s, "SteerSpeed",    "Speed",         0.01, 0.5, 0.01)
    makeSlider(s, "ReturnSpeed",   "Return",        0.01, 1,   0.01)
    makeSlider(s, "MinSteer",      "Min Angle",     0,    90,  1,   "deg")
    makeSlider(s, "Ackerman",      "Ackerman",      0,    2,   0.01)
    makeSectionHeader(s, "WEIGHT")
    makeSlider(s, "WeightDist",    "Distribution",  0,   100,  1,   "%")
    makeSlider(s, "WeightScaling", "Scaling",       0,   0.1,  0.001)
    makeSlider(s, "CGHeight",      "CG Height",     0,    3,   0.01)
    makeSlider(s, "TorqueVector",  "Torque Vector", -1,   1,   0.01)
    makeSlider(s, "CurveMult",     "Curve Mult",    -5,   5,   0.1)

    -- SUSPENSION
    s = tSusp.scroll
    makeSectionHeader(s, "FRONT")
    makeSlider(s, "FSusDamping",   "Damping",       0,  2000, 10)
    makeSlider(s, "FSusAngle",     "Angle",         0,   180, 1,  "deg")
    makeSlider(s, "FPreCompress",  "Precompress",   0,    2,  0.01)
    makeSlider(s, "FCaster",       "Caster",       -20,  20,  0.1)
    makeSlider(s, "FWsBoneLen",    "Bone Length",   0,   20,  0.1)
    makeSectionHeader(s, "REAR")
    makeSlider(s, "RSusDamping",   "Damping",       0,  2000, 10)
    makeSlider(s, "RCompressLim",  "Compress Lim",  0,    2,  0.01)
    makeSlider(s, "RExtensionLim", "Extend Lim",    0,    2,  0.01)
    makeSlider(s, "RCaster",       "Caster",       -20,  20,  0.1)
    makeSlider(s, "RCamber",       "Camber",       -20,  20,  0.1)
    makeSlider(s, "RGyroDamp",     "Gyro Damp",     0,  1000, 10)

    -- BRAKES
    s = tBrakes.scroll
    makeSectionHeader(s, "BRAKES")
    makeSlider(s, "BrakeBias",     "Bias F/R",      0,    1,  0.01)

    -- GRIP
    s = tGrip.scroll
    makeSectionHeader(s, "TRACTION")
    makeSlider(s, "TCSLimit",      "TCS Limit",     0,  100,  1,  "% slip")
    makeSlider(s, "InclineComp",   "Incline Comp",  0,    5,  0.1)
    makeSlider(s, "RDiffLockThres","Diff Lock",     0,  100,  1)
    makeSlider(s, "RDiffSlipThres","Diff Slip",     0,  200,  1)
    makeSectionHeader(s, "CORNER GRIP")
    makeSlider(s, "CurveMult",     "Curve Mult",    -5,   5,  0.1)
    makeSlider(s, "Ackerman",      "Ackerman",       0,   2,  0.01)
    makeSlider(s, "RCamber",       "Rear Camber",  -20,  20,  0.1)
    makeSlider(s, "FCaster",       "Front Caster", -20,  20,  0.1)
    makeSectionHeader(s, "LAUNCH")
    makeSlider(s, "WeightDist",    "Weight Dist",    0, 100,  1,  "%")
    makeSlider(s, "TorqueVector",  "Torque Vector", -1,   1,  0.01)
    makeSlider(s, "KickRPMThreshold","Kick RPM",     0,5000,  100, "rpm")
end

-- ── Auto load ─────────────────────────────
local function tryAutoLoad(silent)
    if loadStock() then
        statusLbl.Text = "LOADED: "..(getVehicle() and getVehicle().Name:upper() or "?")
        statusLbl.TextColor3 = C.green
        buildTunerUI()
        startStats()
        return true
    else
        if not silent then
            statusLbl.Text = "NO VEHICLE"
            statusLbl.TextColor3 = C.red
        end
        return false
    end
end

local function setupSeatWatcher(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
        if hum.SeatPart then
            task.wait(0.3)
            tryAutoLoad(true)
            sg.Enabled = true
        else
            if statsConn then statsConn:Disconnect() statsConn=nil end
        end
    end)
    if hum.SeatPart then task.wait(0.3) tryAutoLoad(true) end
end

if lp.Character then setupSeatWatcher(lp.Character) end
lp.CharacterAdded:Connect(setupSeatWatcher)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        sg.Enabled = not sg.Enabled
        if sg.Enabled then tryAutoLoad(false) end
    end
end)

buildTunerUI()
print("[DBSB SWF Tuner v3] Loaded — RightAlt to toggle")
