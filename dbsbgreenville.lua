-- ─────────────────────────────────────────
--  DBSB Greenville Tuner GUI
--  Full in-game tuning interface
--  Press RightAlt to toggle
-- ─────────────────────────────────────────

local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local RS          = game:GetService("RunService")
local lp          = Players.LocalPlayer
local mouse       = lp:GetMouse()

-- ── Get car + tune ────────────────────────
local function getCar()
    local char = lp.Character
    if not char then return nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil, nil end
    local car = hum.SeatPart.Parent
    local ok, tune = pcall(require, car:FindFirstChild("A-Chassis Tune"))
    if not ok or type(tune) ~= "table" then return nil, nil end
    return car, tune
end

local function getDriveSeat()
    local char = lp.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return nil end
    return hum.SeatPart
end


-- ── Read stock values from car ────────────
local stockValues = {}
local function loadStockValues()
    local car, tune = getCar()
    if not tune then return false end
    
    -- Engine
    stockValues["Horsepower"]    = tune.Horsepower    or 86
    stockValues["E_Horsepower"]  = tune.E_Horsepower  or 223
    stockValues["E_Torque"]      = tune.E_Torque      or 173
    stockValues["Redline"]       = tune.Redline       or 6000
    stockValues["E_Redline"]     = tune.E_Redline     or 16000
    stockValues["PeakRPM"]       = tune.PeakRPM       or 5000
    stockValues["IdleRPM"]       = tune.IdleRPM       or 750
    stockValues["RevBounce"]     = tune.RevBounce     or 500
    stockValues["RevAccel"]      = tune.RevAccel      or 250
    stockValues["RevDecay"]      = tune.RevDecay      or 75
    stockValues["ThrotAccel"]    = tune.ThrotAccel    or 1
    stockValues["ThrotDecel"]    = tune.ThrotDecel    or 1
    stockValues["LaunchMult"]    = tune.LaunchMult    or 25
    stockValues["LaunchRPM"]     = tune.LaunchRPM     or 4000
    -- Turbo
    stockValues["Turbochargers"] = tune.Turbochargers or 0
    stockValues["T_Size"]        = tune.T_Size        or 76
    stockValues["T_Boost"]       = tune.T_Boost       or 2
    stockValues["T_Efficiency"]  = tune.T_Efficiency  or 6
    stockValues["Superchargers"] = tune.Superchargers or 0
    stockValues["S_Boost"]       = tune.S_Boost       or 6
    stockValues["S_Efficiency"]  = tune.S_Efficiency  or 4
    -- Trans
    stockValues["FinalDrive"]    = tune.FinalDrive    or 3.46
    stockValues["ShiftUpTime"]   = tune.ShiftUpTime   or 0.15
    stockValues["ShiftDnTime"]   = tune.ShiftDnTime   or 0.15
    stockValues["ShiftThrot"]    = tune.ShiftThrot    or 15
    stockValues["ClutchEngage"]  = tune.ClutchEngage  or 95
    stockValues["AutoDownThresh"]= tune.AutoDownThresh or 1400
    stockValues["AutoUpThresh"]  = tune.AutoUpThresh  or -300
    -- Gear ratios
    if tune.Ratios then
        stockValues["Gear1"] = tune.Ratios[3] or 3.45
        stockValues["Gear2"] = tune.Ratios[4] or 3.72
        stockValues["Gear3"] = tune.Ratios[5] or 2.02
        stockValues["Gear4"] = tune.Ratios[6] or 1.32
        stockValues["Gear5"] = tune.Ratios[7] or 1.00
        stockValues["Gear6"] = tune.Ratios[8] or 0.81
    end
    -- Handling
    stockValues["Weight"]        = tune.Weight        or 2634
    stockValues["WeightDist"]    = tune.WeightDist    or 55
    stockValues["CGHeight"]      = tune.CGHeight      or 0.75
    stockValues["BrakeForce"]    = tune.BrakeForce    or 2000
    stockValues["BrakeBias"]     = tune.BrakeBias     or 0.55
    stockValues["PBrakeForce"]   = tune.PBrakeForce   or 8000
    stockValues["FSusStiffness"] = tune.FSusStiffness or 5500
    stockValues["RSusStiffness"] = tune.RSusStiffness or 4500
    stockValues["FSusDamping"]   = tune.FSusDamping   or 750
    stockValues["RSusDamping"]   = tune.RSusDamping   or 875
    stockValues["FCamber"]       = tune.FCamber       or -0.75
    stockValues["RCamber"]       = tune.RCamber       or -0.75
    stockValues["FToe"]          = tune.FToe          or 0
    stockValues["RToe"]          = tune.RToe          or 0
    -- Safety
    stockValues["TCSEnabled"]    = tune.TCSEnabled    or false
    stockValues["ABSEnabled"]    = tune.ABSEnabled    or true
    stockValues["TCSLimit"]      = tune.TCSLimit      or 10
    stockValues["ABSThreshold"]  = tune.ABSThreshold  or 20
    stockValues["Stall"]         = tune.Stall         or false
    stockValues["AutoFlip"]      = tune.AutoFlip      or true
    stockValues["ClutchKick"]    = tune.ClutchKick    or true
    stockValues["TorqueVector"]  = tune.TorqueVector  or 0.25
    
    stockValues["SteerRatio"]     = tune.SteerRatio     or 12.58
    stockValues["SteerSpeed"]     = tune.SteerSpeed     or 0.05
    stockValues["LockToLock"]     = tune.LockToLock     or 2.54
    stockValues["Ackerman"]       = tune.Ackerman       or 0.9
    stockValues["MinSteer"]       = tune.MinSteer       or 10
    stockValues["SteerInner"]     = tune.SteerInner     or 43
    stockValues["SteerOuter"]     = tune.SteerOuter     or 37
    stockValues["SteerP"]         = tune.SteerP         or 100000
    stockValues["SteerD"]         = tune.SteerD         or 1000
    stockValues["SteerDecay"]     = tune.SteerDecay     or 110
    stockValues["SteerMaxTorque"] = tune.SteerMaxTorque or 50000
    stockValues["RDiffPower"]     = tune.RDiffPower     or 40
    stockValues["RDiffCoast"]     = tune.RDiffCoast     or 20
    stockValues["RDiffPreload"]   = tune.RDiffPreload   or 20
    stockValues["RDiffLockThres"] = tune.RDiffLockThres or 75
    stockValues["RDiffSlipThres"] = tune.RDiffSlipThres or 80
    stockValues["FDiffPower"]     = tune.FDiffPower     or 30
    stockValues["FDiffCoast"]     = tune.FDiffCoast     or 10
    stockValues["FDiffPreload"]   = tune.FDiffPreload   or 10
    stockValues["FDiffLockThres"] = tune.FDiffLockThres or 25
    stockValues["FDiffSlipThres"] = tune.FDiffSlipThres or 25
    stockValues["CDiffSlipThres"] = tune.CDiffSlipThres or 50
    stockValues["CDiffLockThres"] = tune.CDiffLockThres or 50
    stockValues["BrakeDecel"]     = tune.BrakeDecel     or 1
    stockValues["BrakeAccel"]     = tune.BrakeAccel     or 1
    stockValues["EBrakeForce"]    = tune.EBrakeForce    or 0
    stockValues["PBrakeBias"]     = tune.PBrakeBias     or 0
    stockValues["Flywheel"]       = tune.Flywheel       or 250
    stockValues["EqPoint"]        = tune.EqPoint        or 3625
    stockValues["PeakSharpness"]  = tune.PeakSharpness  or 8.75
    stockValues["KickMult"]       = tune.KickMult       or 10
    stockValues["KickRPMThreshold"]    = tune.KickRPMThreshold    or 2000
    stockValues["KickSpeedThreshold"]  = tune.KickSpeedThreshold  or 20

    return true
end

-- ── Cleanup old GUI ───────────────────────
local old = lp.PlayerGui:FindFirstChild("DBSBTuner")
if old then old:Destroy() end

-- ── GUI setup ─────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name             = "DBSBTuner"
gui.ResetOnSpawn     = false
gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset   = true
gui.Parent           = lp.PlayerGui

-- Main frame
local main = Instance.new("Frame")
main.Name            = "Main"
main.Size            = UDim2.new(0, 420, 0, 560)
main.Position        = UDim2.new(0, 20, 0.5, -280)
main.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
main.BorderSizePixel = 0
main.Parent          = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- Accent top bar
local accent = Instance.new("Frame")
accent.Size             = UDim2.new(1, 0, 0, 3)
accent.BackgroundColor3 = Color3.fromRGB(50, 100, 220)
accent.BorderSizePixel  = 0
accent.Parent           = main

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 36)
titleBar.Position         = UDim2.new(0, 0, 0, 3)
titleBar.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = main

local title = Instance.new("TextLabel")
title.Size               = UDim2.new(1, -80, 1, 0)
title.Position           = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text               = "DBSB  Tuner"
title.TextColor3         = Color3.fromRGB(77, 136, 255)
title.TextSize           = 15
title.Font               = Enum.Font.Code
title.TextXAlignment     = Enum.TextXAlignment.Left
title.Parent             = titleBar

local statusLbl = Instance.new("TextLabel")
statusLbl.Size               = UDim2.new(0, 120, 1, 0)
statusLbl.Position           = UDim2.new(0, 140, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text               = "No car"
statusLbl.TextColor3         = Color3.fromRGB(180, 50, 50)
statusLbl.TextSize           = 11
statusLbl.Font               = Enum.Font.Code
statusLbl.TextXAlignment     = Enum.TextXAlignment.Left
statusLbl.Parent             = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size               = UDim2.new(0, 30, 0, 30)
closeBtn.Position           = UDim2.new(1, -34, 0, 3)
closeBtn.BackgroundColor3   = Color3.fromRGB(20, 14, 14)
closeBtn.Text               = "✕"
closeBtn.TextColor3         = Color3.fromRGB(180, 60, 60)
closeBtn.TextSize           = 14
closeBtn.Font               = Enum.Font.Code
closeBtn.BorderSizePixel    = 0
closeBtn.Parent             = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Apply button
local applyBtn = Instance.new("TextButton")
applyBtn.Size               = UDim2.new(1, -20, 0, 38)
applyBtn.Position           = UDim2.new(0, 10, 1, -48)
applyBtn.BackgroundColor3   = Color3.fromRGB(20, 50, 120)
applyBtn.Text               = "APPLY — Get out and back in car"
applyBtn.TextColor3         = Color3.fromRGB(100, 160, 255)
applyBtn.TextSize           = 13
applyBtn.Font               = Enum.Font.Code
applyBtn.BorderSizePixel    = 0
applyBtn.Parent             = main
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)

-- Tab buttons
local tabs = {"Engine", "Turbo", "Trans", "Handle", "Steer", "Diff", "Brake", "Safety", "Fuel"}
local tabFrames = {}
local tabBtns = {}
local currentTab = "Engine"

local tabBar = Instance.new("ScrollingFrame")
tabBar.Size                  = UDim2.new(1, 0, 0, 32)
tabBar.Position              = UDim2.new(0, 0, 0, 39)
tabBar.BackgroundColor3      = Color3.fromRGB(6, 8, 14)
tabBar.BorderSizePixel       = 0
tabBar.ScrollBarThickness    = 0
tabBar.CanvasSize            = UDim2.new(0, #tabs * 58, 0, 0)
tabBar.ScrollingDirection    = Enum.ScrollingDirection.X
tabBar.Parent                = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder     = Enum.SortOrder.LayoutOrder
tabLayout.Parent        = tabBar

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(0, 56, 1, 0)
    btn.BackgroundColor3   = Color3.fromRGB(8, 10, 16)
    btn.Text               = name
    btn.TextColor3         = Color3.fromRGB(40, 60, 100)
    btn.TextSize           = 11
    btn.Font               = Enum.Font.Code
    btn.BorderSizePixel    = 0
    btn.LayoutOrder        = i
    btn.Parent             = tabBar
    tabBtns[name] = btn
end

-- Scroll content area
local content = Instance.new("ScrollingFrame")
content.Size                  = UDim2.new(1, 0, 1, -120)
content.Position              = UDim2.new(0, 0, 0, 67)
content.BackgroundTransparency = 1
content.BorderSizePixel       = 0
content.ScrollBarThickness    = 4
content.ScrollBarImageColor3  = Color3.fromRGB(40, 80, 180)
content.CanvasSize            = UDim2.new(0, 0, 0, 0)
content.Parent                = main

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder      = Enum.SortOrder.LayoutOrder
contentLayout.Padding        = UDim.new(0, 2)
contentLayout.Parent         = content

contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
end)

-- ── Dragging ──────────────────────────────
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos  = main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ── Widget helpers ────────────────────────
local sliderValues = {}

local function makeSection(name, order)
    local frame = Instance.new("Frame")
    frame.Size               = UDim2.new(1, -16, 0, 28)
    frame.BackgroundColor3   = Color3.fromRGB(12, 16, 26)
    frame.BorderSizePixel    = 0
    frame.LayoutOrder        = order
    frame.Parent             = content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = "  " .. name
    lbl.TextColor3         = Color3.fromRGB(50, 100, 200)
    lbl.TextSize           = 12
    lbl.Font               = Enum.Font.Code
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.Parent             = frame

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft  = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent       = frame

    return frame
end

local function makeSlider(label, min, max, default, order, isInt)
    local h = 64
    local frame = Instance.new("Frame")
    frame.Size               = UDim2.new(1, -16, 0, h)
    frame.BackgroundColor3   = Color3.fromRGB(10, 13, 20)
    frame.BorderSizePixel    = 0
    frame.LayoutOrder        = order
    frame.Parent             = content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size               = UDim2.new(0.6, 0, 0, 18)
    nameLbl.Position           = UDim2.new(0, 10, 0, 4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text               = label
    nameLbl.TextColor3         = Color3.fromRGB(140, 160, 200)
    nameLbl.TextSize           = 13
    nameLbl.Font               = Enum.Font.Code
    nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
    nameLbl.Parent             = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size               = UDim2.new(0.35, 0, 0, 18)
    valLbl.Position           = UDim2.new(0.62, 0, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text               = tostring(default)
    valLbl.TextColor3         = Color3.fromRGB(77, 136, 255)
    valLbl.TextSize           = 13
    valLbl.Font               = Enum.Font.Code
    valLbl.TextXAlignment     = Enum.TextXAlignment.Right
    valLbl.Parent             = frame

    -- Track bg
    local trackBg = Instance.new("Frame")
    trackBg.Size               = UDim2.new(1, -24, 0, 10)
    trackBg.Position           = UDim2.new(0, 10, 0, 38)
    trackBg.BackgroundColor3   = Color3.fromRGB(20, 26, 40)
    trackBg.BorderSizePixel    = 0
    trackBg.Parent             = frame
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(0, 3)

    -- Track fill
    local pct = math.clamp((default - min) / (max - min), 0, 1)
    local trackFill = Instance.new("Frame")
    trackFill.Size               = UDim2.new(pct, 0, 1, 0)
    trackFill.BackgroundColor3   = Color3.fromRGB(40, 90, 200)
    trackFill.BorderSizePixel    = 0
    trackFill.Parent             = trackBg
    Instance.new("UICorner", trackFill).CornerRadius = UDim.new(0, 3)

    -- Knob
    local knob = Instance.new("Frame")
    knob.Size               = UDim2.new(0, 12, 0, 12)
    knob.Position           = UDim2.new(pct, -9, 0.5, -9)
    knob.BackgroundColor3   = Color3.fromRGB(77, 136, 255)
    knob.BorderSizePixel    = 0
    knob.Parent             = trackBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)

    sliderValues[label] = default

    local sliding = false
    local function updateSlider(x)
        local abs = trackBg.AbsolutePosition.X
        local w   = trackBg.AbsoluteSize.X
        local p   = math.clamp((x - abs) / w, 0, 1)
        local val = min + (max - min) * p
        if isInt then val = math.floor(val + 0.5) end
        val = math.floor(val * 100 + 0.5) / 100
        sliderValues[label] = val
        trackFill.Size     = UDim2.new(p, 0, 1, 0)
        knob.Position      = UDim2.new(p, -9, 0.5, -9)
        valLbl.Text        = tostring(val)
    end

    trackBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateSlider(inp.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(inp.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)

    return frame
end

local function makeToggle(label, default, order)
    local frame = Instance.new("Frame")
    frame.Size               = UDim2.new(1, -16, 0, 36)
    frame.BackgroundColor3   = Color3.fromRGB(10, 13, 20)
    frame.BorderSizePixel    = 0
    frame.LayoutOrder        = order
    frame.Parent             = content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(0.7, 0, 1, 0)
    lbl.Position           = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = Color3.fromRGB(140, 160, 200)
    lbl.TextSize           = 11
    lbl.Font               = Enum.Font.Code
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.Parent             = frame

    local val = default
    sliderValues[label] = val

    local pill = Instance.new("TextButton")
    pill.Size               = UDim2.new(0, 44, 0, 22)
    pill.Position           = UDim2.new(1, -54, 0.5, -11)
    pill.BackgroundColor3   = val and Color3.fromRGB(40,90,200) or Color3.fromRGB(25,30,45)
    pill.Text               = ""
    pill.BorderSizePixel    = 0
    pill.Parent             = frame
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0.5, 0)

    local knob = Instance.new("Frame")
    knob.Size               = UDim2.new(0, 16, 0, 16)
    knob.Position           = val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3   = Color3.fromRGB(200, 210, 255)
    knob.BorderSizePixel    = 0
    knob.Parent             = pill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)

    pill.MouseButton1Click:Connect(function()
        val = not val
        sliderValues[label] = val
        pill.BackgroundColor3 = val and Color3.fromRGB(40,90,200) or Color3.fromRGB(25,30,45)
        knob.Position = val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    end)

    return frame
end

-- ── Build tab content ─────────────────────
local function clearContent()
    for _, v in ipairs(content:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
end

local function showTab(name)
    currentTab = name
    -- Try to load stock values, retry up to 10 times if not seated yet
    if not loadStockValues() then
        task.spawn(function()
            for i = 1, 10 do
                task.wait(0.5)
                if loadStockValues() then
                    showTab(currentTab)
                    break
                end
            end
        end)
    end
    for n, b in pairs(tabBtns) do
        b.BackgroundColor3 = n == name and Color3.fromRGB(16,24,46) or Color3.fromRGB(8,10,16)
        b.TextColor3       = n == name and Color3.fromRGB(77,136,255) or Color3.fromRGB(40,60,100)
    end
    clearContent()

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft  = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingTop   = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent       = content

    if name == "Engine" then
        makeSection("SPEED & HORSEPOWER", 1)
        makeSlider("Horsepower", 50, 5000, stockValues["Horsepower"] or 2000, 2, true)
        makeSlider("E_Horsepower", 50, 5000, stockValues["E_Horsepower"] or 2000, 3, true)
        makeSlider("E_Torque", 50, 5000, stockValues["E_Torque"] or 2000, 4, true)
        makeSection("RPM", 5)
        makeSlider("Redline", 2000, 12000, stockValues["Redline"] or 9000, 6, true)
        makeSlider("E_Redline", 2000, 20000, stockValues["E_Redline"] or 11000, 7, true)
        makeSlider("PeakRPM", 1000, 10000, stockValues["PeakRPM"] or 7000, 8, true)
        makeSlider("IdleRPM", 400, 2000, stockValues["IdleRPM"] or 750, 9, true)
        makeSlider("RevBounce", 50, 2000, stockValues["RevBounce"] or 200, 10, true)
        makeSlider("RevAccel", 50, 2000, stockValues["RevAccel"] or 800, 11, true)
        makeSlider("RevDecay", 10, 500, stockValues["RevDecay"] or 50, 12, true)
        makeSection("THROTTLE", 13)
        makeSlider("ThrotAccel", 0.1, 10, stockValues["ThrotAccel"] or 3, 14, false)
        makeSlider("ThrotDecel", 0.1, 10, stockValues["ThrotDecel"] or 3, 15, false)
        makeSlider("LaunchMult", 1, 100, stockValues["LaunchMult"] or 50, 16, true)
        makeSlider("LaunchRPM", 500, 8000, stockValues["LaunchRPM"] or 5000, 17, true)

    elseif name == "Turbo" then
        makeSection("TURBOCHARGER", 1)
        makeSlider("Turbochargers", 0, 4, stockValues["Turbochargers"] or 2, 2, true)
        makeSlider("T_Size", 10, 200, stockValues["T_Size"] or 76, 3, true)
        makeSlider("T_Boost", 1, 20, stockValues["T_Boost"] or 8, 4, false)
        makeSlider("T_Efficiency", 1, 20, stockValues["T_Efficiency"] or 6, 5, false)
        makeSection("SUPERCHARGER", 6)
        makeSlider("Superchargers", 0, 2, stockValues["Superchargers"] or 0, 7, true)
        makeSlider("S_Boost", 1, 20, stockValues["S_Boost"] or 6, 8, false)
        makeSlider("S_Efficiency", 1, 20, stockValues["S_Efficiency"] or 4, 9, false)

    elseif name == "Trans" then
        makeSection("FINAL DRIVE & GEARS", 1)
        makeSlider("FinalDrive", 1, 8, stockValues["FinalDrive"] or 4.2, 2, false)
        makeSlider("ShiftUpTime", 0.01, 0.5, stockValues["ShiftUpTime"] or 0.05, 3, false)
        makeSlider("ShiftDnTime", 0.01, 0.5, stockValues["ShiftDnTime"] or 0.05, 4, false)
        makeSlider("ShiftThrot", 0, 100, stockValues["ShiftThrot"] or 5, 5, true)
        makeSlider("ClutchEngage", 10, 100, stockValues["ClutchEngage"] or 95, 6, true)
        makeSection("GEAR RATIOS", 7)
        makeSlider("Gear1", 1, 6, stockValues["Gear1"] or 3.45, 8, false)
        makeSlider("Gear2", 0.5, 5, stockValues["Gear2"] or 3.72, 9, false)
        makeSlider("Gear3", 0.5, 4, stockValues["Gear3"] or 2.02, 10, false)
        makeSlider("Gear4", 0.3, 3, stockValues["Gear4"] or 1.32, 11, false)
        makeSlider("Gear5", 0.2, 2, stockValues["Gear5"] or 0.95, 12, false)
        makeSlider("Gear6", 0.1, 1.5, stockValues["Gear6"] or 0.65, 13, false)
        makeSection("AUTO SHIFT", 14)
        makeSlider("AutoDownThresh", 500, 5000, stockValues["AutoDownThresh"] or 1400, 15, true)
        makeSlider("AutoUpThresh", -1000, 0, stockValues["AutoUpThresh"] or -300, 16, true)

    elseif name == "Handle" then
        makeSection("WEIGHT", 1)
        makeSlider("Weight", 200, 5000, stockValues["Weight"] or 500, 2, true)
        makeSlider("WeightDist", 20, 80, stockValues["WeightDist"] or 55, 3, true)
        makeSlider("CGHeight", 0.1, 3, stockValues["CGHeight"] or 0.75, 4, false)
        makeSection("BRAKES", 5)
        makeSlider("BrakeForce", 500, 8000, stockValues["BrakeForce"] or 2000, 6, true)
        makeSlider("BrakeBias", 0.1, 0.9, stockValues["BrakeBias"] or 0.55, 7, false)
        makeSlider("PBrakeForce", 1000, 20000, stockValues["PBrakeForce"] or 8000, 8, true)
        makeSection("SUSPENSION", 9)
        makeSlider("FSusStiffness", 500, 15000, stockValues["FSusStiffness"] or 5500, 10, true)
        makeSlider("RSusStiffness", 500, 15000, stockValues["RSusStiffness"] or 4500, 11, true)
        makeSlider("FSusDamping", 100, 3000, stockValues["FSusDamping"] or 750, 12, true)
        makeSlider("RSusDamping", 100, 3000, stockValues["RSusDamping"] or 875, 13, true)
        makeSection("CAMBER & TOE", 14)
        makeSlider("FCamber", -3, 3, stockValues["FCamber"] or -0.75, 15, false)
        makeSlider("RCamber", -3, 3, stockValues["RCamber"] or -0.75, 16, false)
        makeSlider("FToe", -2, 2, stockValues["FToe"] or 0, 17, false)
        makeSlider("RToe", -2, 2, stockValues["RToe"] or 0, 18, false)

    elseif name == "Steer" then
        makeSection("STEERING", 1)
        makeSlider("SteerRatio",   5,    25,    12.58, 2,  false)
        makeSlider("SteerSpeed",   0.01, 0.2,   0.05,  3,  false)
        makeSlider("LockToLock",   1,    5,     2.54,  4,  false)
        makeSlider("Ackerman",     0,    2,     0.9,   5,  false)
        makeSlider("MinSteer",     1,    30,    10,    6,  true)
        makeSlider("SteerInner",   10,   60,    43,    7,  true)
        makeSlider("SteerOuter",   10,   60,    37,    8,  true)
        makeSection("STEERING RESPONSE", 9)
        makeSlider("SteerP",       10000,200000,100000,10, true)
        makeSlider("SteerD",       100,  5000,  1000,  11, true)
        makeSlider("SteerDecay",   10,   500,   110,   12, true)
        makeSlider("SteerMaxTorque",10000,200000,50000,13, true)

    elseif name == "Diff" then
        makeSection("REAR DIFFERENTIAL", 1)
        makeSlider("RDiffPower",    0,  100,  40,  2,  true)
        makeSlider("RDiffCoast",    0,  100,  20,  3,  true)
        makeSlider("RDiffPreload",  0,  100,  20,  4,  true)
        makeSlider("RDiffLockThres",0,  100,  75,  5,  true)
        makeSlider("RDiffSlipThres",0,  100,  80,  6,  true)
        makeSection("FRONT DIFFERENTIAL", 7)
        makeSlider("FDiffPower",    0,  100,  30,  8,  true)
        makeSlider("FDiffCoast",    0,  100,  10,  9,  true)
        makeSlider("FDiffPreload",  0,  100,  10,  10, true)
        makeSlider("FDiffLockThres",0,  100,  25,  11, true)
        makeSlider("FDiffSlipThres",0,  100,  25,  12, true)
        makeSection("CENTER DIFFERENTIAL", 13)
        makeSlider("CDiffSlipThres",0,  100,  50,  14, true)
        makeSlider("CDiffLockThres",0,  100,  50,  15, true)

    elseif name == "Brake" then
        makeSection("BRAKES", 1)
        makeSlider("BrakeForce",   500,  10000, 2000,  2,  true)
        makeSlider("BrakeBias",    0.1,  0.9,   0.55,  3,  false)
        makeSlider("BrakeDecel",   0.1,  5,     1,     4,  false)
        makeSlider("BrakeAccel",   0.1,  5,     1,     5,  false)
        makeSection("HANDBRAKE", 6)
        makeSlider("PBrakeForce",  1000, 20000, 8000,  7,  true)
        makeSlider("PBrakeBias",   0,    1,     0,     8,  false)
        makeSlider("EBrakeForce",  0,    5000,  0,     9,  true)
        makeSection("FLYWHEEL & ENGINE FEEL", 10)
        makeSlider("Flywheel",     50,   1000,  250,   11, true)
        makeSlider("EqPoint",      1000, 8000,  3625,  12, true)
        makeSlider("PeakSharpness",1,    20,    8.75,  13, false)
        makeSlider("KickMult",     1,    50,    10,    14, true)
        makeSlider("KickRPMThreshold",500,5000, 2000,  15, true)
        makeSlider("KickSpeedThreshold",5,100,  20,    16, true)

    elseif name == "Safety" then
        makeSection("SAFETY SYSTEMS", 1)
        makeToggle("TCSEnabled", stockValues["TCSEnabled"] ~= nil and stockValues["TCSEnabled"] or false, 2)
        makeToggle("ABSEnabled", stockValues["ABSEnabled"] ~= nil and stockValues["ABSEnabled"] or false, 3)
        makeSlider("TCSLimit", 1, 50, stockValues["TCSLimit"] or 10, 4, true)
        makeSlider("ABSThreshold", 5, 50, stockValues["ABSThreshold"] or 20, 5, true)
        makeSection("STALL & LAUNCH", 6)
        makeToggle("Stall", stockValues["Stall"] ~= nil and stockValues["Stall"] or false, 7)
        makeToggle("AutoFlip", stockValues["AutoFlip"] ~= nil and stockValues["AutoFlip"] or true, 8)
        makeToggle("ClutchKick", stockValues["ClutchKick"] ~= nil and stockValues["ClutchKick"] or true, 9)
        makeSlider("TorqueVector", 0, 1, stockValues["TorqueVector"] or 0.25, 10, false)

    elseif name == "Fuel" then
        makeSection("INFINITE FUEL", 1)
        makeToggle("InfiniteFuel", stockValues["InfiniteFuel"] ~= nil and stockValues["InfiniteFuel"] or false, 2)

        local infoFrame = Instance.new("Frame")
        infoFrame.Size               = UDim2.new(1, -16, 0, 50)
        infoFrame.BackgroundColor3   = Color3.fromRGB(10, 20, 14)
        infoFrame.BorderSizePixel    = 0
        infoFrame.LayoutOrder        = 3
        infoFrame.Parent             = content
        Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 4)

        local info = Instance.new("TextLabel")
        info.Size               = UDim2.new(1, -20, 1, 0)
        info.Position           = UDim2.new(0, 10, 0, 0)
        info.BackgroundTransparency = 1
        info.Text               = "Keeps fuel at 100% continuously.\nApplies immediately when toggled on."
        info.TextColor3         = Color3.fromRGB(60, 160, 80)
        info.TextSize           = 11
        info.Font               = Enum.Font.Code
        info.TextXAlignment     = Enum.TextXAlignment.Left
        info.TextWrapped        = true
        info.Parent             = infoFrame
    end
end

-- Tab click handlers
for _, name in ipairs(tabs) do
    tabBtns[name].MouseButton1Click:Connect(function() showTab(name) end)
end

-- ── Apply logic ───────────────────────────
applyBtn.MouseButton1Click:Connect(function()
    local car, tune = getCar()
    if not tune then
        applyBtn.Text = "Get in a car first!"
        applyBtn.TextColor3 = Color3.fromRGB(200, 60, 60)
        task.wait(2)
        applyBtn.Text = "APPLY — Get out and back in car"
        applyBtn.TextColor3 = Color3.fromRGB(100, 160, 255)
        return
    end

    -- Only apply values that differ from stock
    local function applyIfChanged(tuneKey, sliderKey, tuneVal)
        local sv = sliderValues[sliderKey]
        local stock = stockValues[sliderKey]
        if sv ~= nil and sv ~= stock then
            return sv
        end
        return tuneVal
    end
    -- Engine
    tune.Horsepower   = sliderValues["Horsepower"]   or tune.Horsepower
    tune.E_Horsepower = applyIfChanged("tune.E_Horsepower", "E_Horsepower", tune.E_Horsepower)
    tune.E_Torque     = sliderValues["E_Torque"]     or tune.E_Torque
    tune.Redline      = sliderValues["Redline"]      or tune.Redline
    tune.E_Redline    = applyIfChanged("tune.E_Redline", "E_Redline", tune.E_Redline)
    tune.PeakRPM      = sliderValues["PeakRPM"]      or tune.PeakRPM
    tune.IdleRPM      = sliderValues["IdleRPM"]      or tune.IdleRPM
    tune.RevBounce    = applyIfChanged("tune.RevBounce", "RevBounce", tune.RevBounce)
    tune.RevAccel     = sliderValues["RevAccel"]     or tune.RevAccel
    tune.RevDecay     = sliderValues["RevDecay"]     or tune.RevDecay
    tune.ThrotAccel   = sliderValues["ThrotAccel"]   or tune.ThrotAccel
    tune.ThrotDecel   = sliderValues["ThrotDecel"]   or tune.ThrotDecel
    tune.LaunchMult   = sliderValues["LaunchMult"]   or tune.LaunchMult
    tune.LaunchRPM    = applyIfChanged("tune.LaunchRPM", "LaunchRPM", tune.LaunchRPM)

    -- Turbo
    tune.Turbochargers = applyIfChanged("tune.Turbochargers", "Turbochargers", tune.Turbochargers)
    tune.T_Size        = sliderValues["T_Size"]        or tune.T_Size
    tune.T_Boost       = sliderValues["T_Boost"]       or tune.T_Boost
    tune.T_Efficiency  = sliderValues["T_Efficiency"]  or tune.T_Efficiency
    tune.Superchargers = applyIfChanged("tune.Superchargers", "Superchargers", tune.Superchargers)
    tune.S_Boost       = sliderValues["S_Boost"]       or tune.S_Boost
    tune.S_Efficiency  = sliderValues["S_Efficiency"]  or tune.S_Efficiency

    -- Trans
    tune.FinalDrive    = applyIfChanged("tune.FinalDrive", "FinalDrive", tune.FinalDrive)
    tune.ShiftUpTime   = sliderValues["ShiftUpTime"]   or tune.ShiftUpTime
    tune.ShiftDnTime   = sliderValues["ShiftDnTime"]   or tune.ShiftDnTime
    tune.ShiftThrot    = applyIfChanged("tune.ShiftThrot", "ShiftThrot", tune.ShiftThrot)
    tune.ClutchEngage  = sliderValues["ClutchEngage"]  or tune.ClutchEngage
    tune.AutoDownThresh = applyIfChanged("tune.AutoDownThresh", "AutoDownThresh", tune.AutoDownThresh)
    tune.AutoUpThresh  = sliderValues["AutoUpThresh"]  or tune.AutoUpThresh

    -- Gear ratios
    if tune.Ratios then
        local map = {Gear1=3,Gear2=4,Gear3=5,Gear4=6,Gear5=7,Gear6=8}
        for k, idx in pairs(map) do
            if sliderValues[k] then tune.Ratios[idx] = sliderValues[k] end
        end
    end

    -- Handling
    tune.Weight        = sliderValues["Weight"]        or tune.Weight
    tune.WeightDist    = applyIfChanged("tune.WeightDist", "WeightDist", tune.WeightDist)
    tune.CGHeight      = sliderValues["CGHeight"]      or tune.CGHeight
    tune.BrakeForce    = applyIfChanged("tune.BrakeForce", "BrakeForce", tune.BrakeForce)
    tune.BrakeBias     = sliderValues["BrakeBias"]     or tune.BrakeBias
    tune.PBrakeForce   = sliderValues["PBrakeForce"]   or tune.PBrakeForce
    tune.FSusStiffness = applyIfChanged("tune.FSusStiffness", "FSusStiffness", tune.FSusStiffness)
    tune.RSusStiffness = applyIfChanged("tune.RSusStiffness", "RSusStiffness", tune.RSusStiffness)
    tune.FSusDamping   = sliderValues["FSusDamping"]   or tune.FSusDamping
    tune.RSusDamping   = sliderValues["RSusDamping"]   or tune.RSusDamping
    tune.FCamber       = sliderValues["FCamber"]       or tune.FCamber
    tune.RCamber       = sliderValues["RCamber"]       or tune.RCamber
    tune.FToe          = sliderValues["FToe"]          or tune.FToe
    tune.RToe          = sliderValues["RToe"]          or tune.RToe

    -- Safety
    tune.TCSEnabled    = sliderValues["TCSEnabled"]
    tune.ABSEnabled    = sliderValues["ABSEnabled"]
    tune.TCSLimit      = sliderValues["TCSLimit"]      or tune.TCSLimit
    tune.ABSThreshold  = sliderValues["ABSThreshold"]  or tune.ABSThreshold
    tune.Stall         = sliderValues["Stall"]
    tune.AutoFlip      = sliderValues["AutoFlip"]
    tune.ClutchKick    = sliderValues["ClutchKick"]
    tune.TorqueVector  = sliderValues["TorqueVector"]  or tune.TorqueVector

    -- Steering
    tune.SteerRatio    = applyIfChanged("tune.SteerRatio",    "SteerRatio",    tune.SteerRatio)
    tune.SteerSpeed    = applyIfChanged("tune.SteerSpeed",    "SteerSpeed",    tune.SteerSpeed)
    tune.LockToLock    = applyIfChanged("tune.LockToLock",    "LockToLock",    tune.LockToLock)
    tune.Ackerman      = applyIfChanged("tune.Ackerman",      "Ackerman",      tune.Ackerman)
    tune.MinSteer      = applyIfChanged("tune.MinSteer",      "MinSteer",      tune.MinSteer)
    tune.SteerInner    = applyIfChanged("tune.SteerInner",    "SteerInner",    tune.SteerInner)
    tune.SteerOuter    = applyIfChanged("tune.SteerOuter",    "SteerOuter",    tune.SteerOuter)
    tune.SteerP        = applyIfChanged("tune.SteerP",        "SteerP",        tune.SteerP)
    tune.SteerD        = applyIfChanged("tune.SteerD",        "SteerD",        tune.SteerD)
    tune.SteerDecay    = applyIfChanged("tune.SteerDecay",    "SteerDecay",    tune.SteerDecay)
    tune.SteerMaxTorque = applyIfChanged("tune.SteerMaxTorque","SteerMaxTorque",tune.SteerMaxTorque)
    -- Differentials
    tune.RDiffPower    = applyIfChanged("tune.RDiffPower",    "RDiffPower",    tune.RDiffPower)
    tune.RDiffCoast    = applyIfChanged("tune.RDiffCoast",    "RDiffCoast",    tune.RDiffCoast)
    tune.RDiffPreload  = applyIfChanged("tune.RDiffPreload",  "RDiffPreload",  tune.RDiffPreload)
    tune.RDiffLockThres = applyIfChanged("tune.RDiffLockThres","RDiffLockThres",tune.RDiffLockThres)
    tune.RDiffSlipThres = applyIfChanged("tune.RDiffSlipThres","RDiffSlipThres",tune.RDiffSlipThres)
    tune.FDiffPower    = applyIfChanged("tune.FDiffPower",    "FDiffPower",    tune.FDiffPower)
    tune.FDiffCoast    = applyIfChanged("tune.FDiffCoast",    "FDiffCoast",    tune.FDiffCoast)
    tune.FDiffPreload  = applyIfChanged("tune.FDiffPreload",  "FDiffPreload",  tune.FDiffPreload)
    tune.FDiffLockThres = applyIfChanged("tune.FDiffLockThres","FDiffLockThres",tune.FDiffLockThres)
    tune.FDiffSlipThres = applyIfChanged("tune.FDiffSlipThres","FDiffSlipThres",tune.FDiffSlipThres)
    tune.CDiffSlipThres = applyIfChanged("tune.CDiffSlipThres","CDiffSlipThres",tune.CDiffSlipThres)
    tune.CDiffLockThres = applyIfChanged("tune.CDiffLockThres","CDiffLockThres",tune.CDiffLockThres)
    -- Brakes & Flywheel
    tune.BrakeDecel    = applyIfChanged("tune.BrakeDecel",    "BrakeDecel",    tune.BrakeDecel)
    tune.BrakeAccel    = applyIfChanged("tune.BrakeAccel",    "BrakeAccel",    tune.BrakeAccel)
    tune.EBrakeForce   = applyIfChanged("tune.EBrakeForce",   "EBrakeForce",   tune.EBrakeForce)
    tune.PBrakeBias    = applyIfChanged("tune.PBrakeBias",    "PBrakeBias",    tune.PBrakeBias)
    tune.Flywheel      = applyIfChanged("tune.Flywheel",      "Flywheel",      tune.Flywheel)
    tune.EqPoint       = applyIfChanged("tune.EqPoint",       "EqPoint",       tune.EqPoint)
    tune.PeakSharpness = applyIfChanged("tune.PeakSharpness", "PeakSharpness", tune.PeakSharpness)
    tune.KickMult      = applyIfChanged("tune.KickMult",      "KickMult",      tune.KickMult)
    tune.KickRPMThreshold = applyIfChanged("tune.KickRPMThreshold","KickRPMThreshold",tune.KickRPMThreshold)
    tune.KickSpeedThreshold = applyIfChanged("tune.KickSpeedThreshold","KickSpeedThreshold",tune.KickSpeedThreshold)

    applyBtn.Text = "✓ Applied! Get out and back in"
    applyBtn.BackgroundColor3 = Color3.fromRGB(10, 60, 20)
    applyBtn.TextColor3 = Color3.fromRGB(60, 200, 80)
    task.wait(2.5)
    applyBtn.Text = "APPLY — Get out and back in car"
    applyBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 120)
    applyBtn.TextColor3 = Color3.fromRGB(100, 160, 255)
end)

-- ── Infinite fuel loop ────────────────────
RS.Heartbeat:Connect(function()
    if sliderValues["InfiniteFuel"] then
        local seat = getDriveSeat()
        if seat then
            local fuel = seat:FindFirstChild("Fuel")
            if fuel then fuel.Value = 1 end
        end
    end
    -- Update status
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        statusLbl.Text      = "● " .. hum.SeatPart.Parent.Name:gsub("-Car","")
        statusLbl.TextColor3 = Color3.fromRGB(50, 180, 80)
    else
        statusLbl.Text      = "No car"
        statusLbl.TextColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

-- ── Toggle with RightAlt ──────────────────
UIS.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.RightAlt then
        main.Visible = not main.Visible
    end
end)

-- Init
showTab("Engine")
print("[DBSB] Tuner loaded — RightAlt to toggle")
