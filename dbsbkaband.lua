-- ═══════════════════════════════════════════════════════
--  DBSB.su | Radar Detector v1.0
--  Realistic Uniden R8-style HUD
--  Universal — Greenville / SWF / Pacifico / Any game
--  RightShift to toggle display
-- ═══════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- ── Config ────────────────────────────────
local cfg = {
    MaxRange = 1200,      -- max detection range in studs
    AlertRange = 600,     -- close alert threshold
    CriticalRange = 250,  -- very close / instant alert
    UpdateRate = 0.15,    -- seconds between scans
    Enabled = true,
    Muted = false,
    SoundEnabled = true,
}

-- ── Police Detection Keywords ─────────────
local COP_TEAMS = {
    "police","patrol","sheriff","officer","trooper","deputy",
    "law enforcement","lspd","lcpd","swat","fvmpd","ocso",
    "state patrol","highway patrol","constable","marshal",
    "fire rescue","ems","paramedic", -- some games group emergency
    "wisconsin state","outagamie county","fox valley metro",
    "greenville fire","brookmere fire",
    "security guard",
}

local COP_TOOLS = {
    "radar","laser","lidar","gun","taser","handcuff","cuff",
    "baton","spike","cone","stop sign","slow sign",
}

local COP_VEHICLES = {
    "police","patrol","cruiser","interceptor","sheriff",
    "charger police","explorer police","tahoe police",
    "crown vic","cvpi","fpiu","piu","slicktop",
    "unmarked","undercover","unit","squad",
    "wsp","fvmpd","ocso","swat",
}

-- ── Band Simulation ───────────────────────
-- Real R8 bands: X, K, Ka, Laser
-- We simulate based on what type of "radar" the cop has
local function getBand(cop, dist)
    -- Check for laser tool
    if cop.Character then
        for _, tool in ipairs(cop.Character:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("BackpackItem") then
                local nl = tool.Name:lower()
                if nl:find("laser") or nl:find("lidar") then return "L" end
            end
        end
    end
    -- Check backpack too
    if cop:FindFirstChild("Backpack") then
        for _, tool in ipairs(cop.Backpack:GetChildren()) do
            local nl = tool.Name:lower()
            if nl:find("laser") or nl:find("lidar") then return "L" end
        end
    end
    -- Simulate band based on distance behavior
    if dist < 300 then return "Ka" end
    if dist < 700 then return "K" end
    return "K"
end

-- ── Frequency Simulation ──────────────────
local function getFrequency(band, dist)
    if band == "L" then return "" end -- laser doesn't show freq
    if band == "Ka" then
        local freqs = {"33.800", "34.700", "35.500"}
        return freqs[math.random(1, #freqs)]
    end
    return "24.150" -- K band standard
end

-- ── Helpers ───────────────────────────────
local function getMyRoot()
    local char = lp.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    -- If in vehicle, use the seat itself as position reference
    if hum and hum.SeatPart then
        return hum.SeatPart
    end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") or char:FindFirstChild("Middle")
end

local function getPlayerPosition(player)
    if not player or not player.Character then return nil end
    local char = player.Character
    -- Check if seated (in vehicle)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Position
    end
    -- Standard character parts
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") or char:FindFirstChild("Middle")
    if hrp then return hrp.Position end
    -- Last resort: any BasePart in character
    local part = char:FindFirstChildWhichIsA("BasePart")
    if part then return part.Position end
    return nil
end

local function getMyVelocity()
    local root = getMyRoot()
    if not root then return 0 end
    local vel = root.AssemblyLinearVelocity or root.Velocity
    if vel then return vel.Magnitude end
    return 0
end

local function getMyForward()
    local root = getMyRoot()
    if not root then return Vector3.new(0, 0, -1) end
    return root.CFrame.LookVector
end

local function stringContainsAny(str, keywords)
    local lower = str:lower()
    for _, kw in ipairs(keywords) do
        if lower:find(kw) then return true end
    end
    return false
end

local function isCop(player)
    local ok, result = pcall(function()
        if player == lp then return false end
        if not player or not player.Parent then return false end
        -- Team check
        if player.Team and player.Team.Name then
            if stringContainsAny(player.Team.Name, COP_TEAMS) then return true end
        end
        -- Tool check (character)
        if player.Character then
            for _, child in ipairs(player.Character:GetChildren()) do
                if child and (child:IsA("Tool") or child:IsA("BackpackItem")) and child.Name then
                    if stringContainsAny(child.Name, COP_TOOLS) then return true end
                end
            end
        end
        -- Tool check (backpack)
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, child in ipairs(bp:GetChildren()) do
                if child and child.Name then
                    if stringContainsAny(child.Name, COP_TOOLS) then return true end
                end
            end
        end
        -- Vehicle check
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart and hum.SeatPart.Parent and hum.SeatPart.Parent.Name then
                if stringContainsAny(hum.SeatPart.Parent.Name, COP_VEHICLES) then return true end
            end
        end
        return false
    end)
    if ok then return result end
    return false
end

local function getCompassDirection(forward, toTarget)
    -- Project to XZ plane
    local f2 = Vector3.new(forward.X, 0, forward.Z).Unit
    local t2 = Vector3.new(toTarget.X, 0, toTarget.Z).Unit
    local dot = f2:Dot(t2)
    local cross = f2:Cross(t2).Y

    local angle = math.deg(math.atan2(cross, dot))
    -- Relative to vehicle: 0=ahead, 180=behind, 90=right, -90=left
    return angle
end

local function getCompassLabel(angle)
    if angle > -22.5 and angle <= 22.5 then return "AHEAD"
    elseif angle > 22.5 and angle <= 67.5 then return "R FRT"
    elseif angle > 67.5 and angle <= 112.5 then return "RIGHT"
    elseif angle > 112.5 and angle <= 157.5 then return "R RR"
    elseif angle > 157.5 or angle <= -157.5 then return "BEHIND"
    elseif angle > -157.5 and angle <= -112.5 then return "L RR"
    elseif angle > -112.5 and angle <= -67.5 then return "LEFT"
    elseif angle > -67.5 and angle <= -22.5 then return "L FRT"
    end
    return "AHEAD"
end

local function getArrowDirection(angle)
    -- Returns: "front", "behind", "left", "right"
    if angle > -45 and angle <= 45 then return "front"
    elseif angle > 45 and angle <= 135 then return "right"
    elseif angle > -135 and angle <= -45 then return "left"
    else return "behind" end
end

local function getSignalStrength(dist)
    if dist > cfg.MaxRange then return 0 end
    return math.clamp(1 - (dist / cfg.MaxRange), 0, 1)
end

-- ── GUI ───────────────────────────────────
local old = lp.PlayerGui:FindFirstChild("DBSB_Radar")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "DBSB_Radar"
sg.ResetOnSpawn = false
sg.DisplayOrder = 998
sg.IgnoreGuiInset = true
sg.Parent = lp.PlayerGui

-- Dimensions — matched to real R8 proportions
local W, H = 440, 148
local PAD = 14
local DISP_W = 270
local DISP_H = 90
local BRAND_W = W - DISP_W - PAD * 3
local BTN_H = 24
local BTN_W = 100

-- Main body
local body = Instance.new("Frame", sg)
body.Size = UDim2.new(0, W, 0, H)
body.Position = UDim2.new(0.5, -W/2, 1, -(H + 15))
body.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
body.BorderSizePixel = 0
Instance.new("UICorner", body).CornerRadius = UDim.new(0, 10)
local bodyStroke = Instance.new("UIStroke", body)
bodyStroke.Color = Color3.fromRGB(38, 38, 38)
bodyStroke.Thickness = 1.5

-- Top chrome strip
local chrome = Instance.new("Frame", body)
chrome.Size = UDim2.new(1, 0, 0, 2)
chrome.Position = UDim2.new(0, 0, 0, 0)
chrome.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
chrome.BorderSizePixel = 0

-- ── OLED Display ──────────────────────────
local display = Instance.new("Frame", body)
display.Size = UDim2.new(0, DISP_W, 0, DISP_H)
display.Position = UDim2.new(0, PAD, 0, PAD)
display.BackgroundColor3 = Color3.fromRGB(1, 1, 1)
display.BorderSizePixel = 0
Instance.new("UICorner", display).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", display).Color = Color3.fromRGB(22, 22, 22)

-- ── Compass (top-left of display) ─────────
local compassLbl = Instance.new("TextLabel", display)
compassLbl.Size = UDim2.new(0, 60, 0, 16)
compassLbl.Position = UDim2.new(0, 8, 0, 2)
compassLbl.BackgroundTransparency = 1
compassLbl.Text = "--"
compassLbl.TextColor3 = Color3.fromRGB(60, 60, 60)
compassLbl.TextSize = 14
compassLbl.Font = Enum.Font.Code
compassLbl.TextXAlignment = Enum.TextXAlignment.Left

-- ── Arrow box (below compass, left column) ──
local arrowFrame = Instance.new("Frame", display)
arrowFrame.Size = UDim2.new(0, 38, 0, 38)
arrowFrame.Position = UDim2.new(0, 10, 0, 18)
arrowFrame.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
arrowFrame.BackgroundTransparency = 1
arrowFrame.BorderSizePixel = 0
Instance.new("UICorner", arrowFrame).CornerRadius = UDim.new(0, 6)
local arrowStroke = Instance.new("UIStroke", arrowFrame)
arrowStroke.Color = Color3.fromRGB(160, 0, 0)
arrowStroke.Thickness = 2.5
arrowStroke.Transparency = 1

local arrowLbl = Instance.new("TextLabel", arrowFrame)
arrowLbl.Size = UDim2.new(1, 0, 1, 0)
arrowLbl.BackgroundTransparency = 1
arrowLbl.Text = ""
arrowLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
arrowLbl.TextSize = 26
arrowLbl.Font = Enum.Font.GothamBold

-- ── Band label (right column, top) ────────
local bandLbl = Instance.new("TextLabel", display)
bandLbl.Size = UDim2.new(0, 30, 0, 16)
bandLbl.Position = UDim2.new(0, 58, 0, 2)
bandLbl.BackgroundTransparency = 1
bandLbl.Text = ""
bandLbl.TextColor3 = Color3.fromRGB(255, 60, 60)
bandLbl.TextSize = 16
bandLbl.Font = Enum.Font.GothamBold
bandLbl.TextXAlignment = Enum.TextXAlignment.Left

-- ── Frequency (right column, below band) ──
local freqLbl = Instance.new("TextLabel", display)
freqLbl.Size = UDim2.new(0, 130, 0, 26)
freqLbl.Position = UDim2.new(0, 56, 0, 18)
freqLbl.BackgroundTransparency = 1
freqLbl.Text = ""
freqLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
freqLbl.TextSize = 24
freqLbl.Font = Enum.Font.Code
freqLbl.TextXAlignment = Enum.TextXAlignment.Left

local freqUnit = Instance.new("TextLabel", display)
freqUnit.Size = UDim2.new(0, 30, 0, 14)
freqUnit.Position = UDim2.new(0, 56, 0, 42)
freqUnit.BackgroundTransparency = 1
freqUnit.Text = ""
freqUnit.TextColor3 = Color3.fromRGB(100, 100, 100)
freqUnit.TextSize = 11
freqUnit.Font = Enum.Font.Code
freqUnit.TextXAlignment = Enum.TextXAlignment.Left

-- ── Signal bars ───────────────────────────
local barCount = 10
local bars = {}
local barFrame = Instance.new("Frame", display)
local barPadX = 8
local barTotalW = DISP_W - barPadX * 2
local barGap = 3
local barW = math.floor((barTotalW - (barCount - 1) * barGap) / barCount)
barFrame.Size = UDim2.new(0, barTotalW, 0, 28)
barFrame.Position = UDim2.new(0, barPadX, 1, -36)
barFrame.BackgroundTransparency = 1
barFrame.BorderSizePixel = 0

for i = 1, barCount do
    local bar = Instance.new("Frame", barFrame)
    local h = math.floor(8 + (i / barCount) * 18)
    bar.Size = UDim2.new(0, barW, 0, h)
    bar.Position = UDim2.new(0, (i - 1) * (barW + barGap), 1, -h)
    bar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)
    bars[i] = bar
end

-- ── Distance (next to GHz label) ──────────
local distLbl = Instance.new("TextLabel", display)
distLbl.Size = UDim2.new(0, 50, 0, 14)
distLbl.Position = UDim2.new(0, 90, 0, 42)
distLbl.BackgroundTransparency = 1
distLbl.Text = ""
distLbl.TextColor3 = Color3.fromRGB(80, 80, 80)
distLbl.TextSize = 11
distLbl.Font = Enum.Font.Code
distLbl.TextXAlignment = Enum.TextXAlignment.Left

-- ── Speed (top-right of display) ──────────
local speedLbl = Instance.new("TextLabel", display)
speedLbl.Size = UDim2.new(0, 50, 0, 18)
speedLbl.Position = UDim2.new(1, -80, 0, 6)
speedLbl.BackgroundTransparency = 1
speedLbl.Text = "0"
speedLbl.TextColor3 = Color3.fromRGB(45, 45, 45)
speedLbl.TextSize = 14
speedLbl.Font = Enum.Font.Code
speedLbl.TextXAlignment = Enum.TextXAlignment.Right

local speedUnit = Instance.new("TextLabel", display)
speedUnit.Size = UDim2.new(0, 26, 0, 18)
speedUnit.Position = UDim2.new(1, -28, 0, 6)
speedUnit.BackgroundTransparency = 1
speedUnit.Text = "mph"
speedUnit.TextColor3 = Color3.fromRGB(35, 35, 35)
speedUnit.TextSize = 10
speedUnit.Font = Enum.Font.Code
speedUnit.TextXAlignment = Enum.TextXAlignment.Left

-- ── Right panel (branding) ────────────────
local brandPanel = Instance.new("Frame", body)
brandPanel.Size = UDim2.new(0, BRAND_W, 0, DISP_H)
brandPanel.Position = UDim2.new(0, PAD + DISP_W + PAD, 0, PAD)
brandPanel.BackgroundTransparency = 1
brandPanel.BorderSizePixel = 0

-- Status dot
local statusDot = Instance.new("Frame", brandPanel)
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(1, -8, 0, 0)
statusDot.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
statusDot.BorderSizePixel = 0
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(0.5, 0)

local brandLbl = Instance.new("TextLabel", brandPanel)
brandLbl.Size = UDim2.new(1, 0, 0, 32)
brandLbl.Position = UDim2.new(0, 0, 0.5, -20)
brandLbl.BackgroundTransparency = 1
brandLbl.Text = "DBSB"
brandLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
brandLbl.TextSize = 26
brandLbl.Font = Enum.Font.GothamBold
brandLbl.TextXAlignment = Enum.TextXAlignment.Right

local modelLbl = Instance.new("TextLabel", brandPanel)
modelLbl.Size = UDim2.new(1, 0, 0, 14)
modelLbl.Position = UDim2.new(0, 0, 0.5, 14)
modelLbl.BackgroundTransparency = 1
modelLbl.Text = "R8 // v1.0"
modelLbl.TextColor3 = Color3.fromRGB(60, 60, 60)
modelLbl.TextSize = 11
modelLbl.Font = Enum.Font.Code
modelLbl.TextXAlignment = Enum.TextXAlignment.Right

-- ── Bottom buttons (perfectly centered across full body) ──
local btnY = H - BTN_H - 6
local btnGap = 12
local totalBtnW = BTN_W * 2 + btnGap
local btnStartX = math.floor((W - totalBtnW) / 2)

local muteBtn = Instance.new("TextButton", body)
muteBtn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
muteBtn.Position = UDim2.new(0, btnStartX, 0, btnY)
muteBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
muteBtn.Text = "MUTE/DIM"
muteBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
muteBtn.TextSize = 11
muteBtn.Font = Enum.Font.GothamBold
muteBtn.BorderSizePixel = 0
muteBtn.AutoButtonColor = false
Instance.new("UICorner", muteBtn).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", muteBtn).Color = Color3.fromRGB(35, 35, 35)

local markBtn = Instance.new("TextButton", body)
markBtn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
markBtn.Position = UDim2.new(0, btnStartX + BTN_W + btnGap, 0, btnY)
markBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
markBtn.Text = "MARK"
markBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
markBtn.TextSize = 11
markBtn.Font = Enum.Font.GothamBold
markBtn.BorderSizePixel = 0
markBtn.AutoButtonColor = false
Instance.new("UICorner", markBtn).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", markBtn).Color = Color3.fromRGB(35, 35, 35)

-- ── Mute button logic ─────────────────────
muteBtn.MouseButton1Click:Connect(function()
    cfg.Muted = not cfg.Muted
    muteBtn.TextColor3 = cfg.Muted and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(100, 100, 100)
    muteBtn.Text = cfg.Muted and "MUTED" or "MUTE/DIM"
end)

-- ── Mark button — saves current position as speed trap ──
local markedLocations = {}
local markBBs = {}

local function clearMarks()
    for _, bb in pairs(markBBs) do pcall(function() bb:Destroy() end) end
    markBBs = {}
end

local function addMarkBillboard(pos, idx)
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Position = pos
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = workspace
    local bb = Instance.new("BillboardGui", part)
    bb.Size = UDim2.new(0, 80, 0, 24)
    bb.StudsOffset = Vector3.new(0, 6, 0)
    bb.AlwaysOnTop = true
    local tl = Instance.new("TextLabel", bb)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "TRAP #" .. idx
    tl.TextColor3 = Color3.fromRGB(255, 80, 80)
    tl.TextStrokeTransparency = 0
    tl.TextStrokeColor3 = Color3.new(0, 0, 0)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 12
    markBBs[idx] = part
    return part
end

markBtn.MouseButton1Click:Connect(function()
    local root = getMyRoot()
    if not root then return end
    local pos = root.Position
    local idx = #markedLocations + 1
    table.insert(markedLocations, pos)
    addMarkBillboard(pos, idx)
    markBtn.TextColor3 = Color3.fromRGB(80, 255, 80)
    task.delay(0.5, function() markBtn.TextColor3 = Color3.fromRGB(100, 100, 100) end)
end)

-- ── Sound system ─────────────────────────
-- rbxasset:// sounds are built into the Roblox client — always work, no permissions needed
-- We use these for guaranteed audio on any game

local function makeSound(id, vol, pitch)
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = vol or 0.3
    s.PlaybackSpeed = pitch or 1
    s.Looped = false
    s.Parent = sg
    return s
end

-- Built-in Roblox engine sounds (always available, no permissions needed)
local beepSound = makeSound("rbxasset://sounds/electronicpingshort.wav", 2)

local lastAlertTime = 0
local lastBand = ""

local function playAlert(strength, band)
    if cfg.Muted or not cfg.SoundEnabled then return end
    local now = tick()

    -- Interval tightens as signal gets stronger — mimics real R8 ramping
    local interval
    if strength > 0.85 then interval = 0.1
    elseif strength > 0.7 then interval = 0.18
    elseif strength > 0.5 then interval = 0.35
    elseif strength > 0.3 then interval = 0.6
    else interval = 1.0 end

    if now - lastAlertTime < interval then return end
    lastAlertTime = now

    if band == "L" then
        beepSound.PlaybackSpeed = 1.6 + strength * 0.4
        beepSound.Volume = 1.75
    elseif band == "Ka" then
        beepSound.PlaybackSpeed = 1.1 + strength * 0.3
        beepSound.Volume = 1.5
    else
        beepSound.PlaybackSpeed = 0.8 + strength * 0.3
        beepSound.Volume = 1.25
    end

    beepSound:Play()
end

-- ── MPH smoothing (lag behind real speed) ──
local smoothMPH = 0
local targetMPH = 0
local mphLerpSpeed = 3 -- how fast it catches up (lower = laggier)

-- ── Color helpers ─────────────────────────
local function barColor(idx, total, strength)
    local ratio = idx / total
    if strength < ratio then return Color3.fromRGB(30, 30, 30) end -- off
    if ratio < 0.33 then return Color3.fromRGB(50, 180, 50) end -- green
    if ratio < 0.66 then return Color3.fromRGB(220, 180, 30) end -- yellow
    return Color3.fromRGB(220, 40, 40) end -- red

local function getArrowChar(dir)
    if dir == "front" then return "▲" end -- ahead
    if dir == "behind" then return "▼" end -- behind
    if dir == "left" then return "◄" end
    if dir == "right" then return "►" end
    return ""
end

-- ── IDLE state (no threats) ───────────────
local function setIdle()
    compassLbl.Text = "--"
    compassLbl.TextColor3 = Color3.fromRGB(60, 60, 60)
    arrowFrame.BackgroundTransparency = 1
    arrowLbl.Text = ""
    bandLbl.Text = ""
    freqLbl.Text = ""
    freqUnit.Text = ""
    distLbl.Text = ""
    for i = 1, barCount do
        bars[i].BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    end
end

-- ── ALERT state ───────────────────────────
local function setAlert(threat)
    local dist = threat.dist
    local band = threat.band
    local freq = threat.freq
    local strength = threat.strength
    local dirLabel = threat.dirLabel
    local arrow = threat.arrow

    -- Compass
    compassLbl.Text = dirLabel
    compassLbl.TextColor3 = strength > 0.6 and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(200, 200, 200)

    -- Arrow
    arrowLbl.Text = getArrowChar(arrow)
    arrowLbl.TextColor3 = strength > 0.6 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 50, 50)

    -- Band
    bandLbl.Text = band
    bandLbl.TextColor3 = band == "L" and Color3.fromRGB(255, 80, 80) or
                          band == "Ka" and Color3.fromRGB(255, 170, 40) or
                          Color3.fromRGB(255, 60, 60)

    -- Frequency
    if freq ~= "" then
        freqLbl.Text = freq
        freqUnit.Text = "GHz"
        freqLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
    else
        freqLbl.Text = "LASER"
        freqUnit.Text = ""
        freqLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
    end

    -- Signal bars
    for i = 1, barCount do
        bars[i].BackgroundColor3 = barColor(i, barCount, strength)
    end

    -- Distance
    distLbl.Text = math.floor(dist) .. "m"
    distLbl.TextColor3 = strength > 0.7 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(80, 80, 80)

    -- Sound
    playAlert(strength, band)
end

-- ── Speed readout (smoothed, lags behind real speed) ───
RunService.RenderStepped:Connect(function(dt)
    local vel = getMyVelocity()
    local rawMPH = vel * 0.567 -- calibrated: 25 ingame = 25 on detector
    targetMPH = rawMPH > 2 and (math.floor(rawMPH) + 1) or 0 -- Uniden +1 overshoot when moving
    -- Lerp toward target — gives that real radar detector lag feel
    smoothMPH = smoothMPH + (targetMPH - smoothMPH) * math.clamp(dt * mphLerpSpeed, 0, 1)
    local displayMPH = math.floor(smoothMPH)
    speedLbl.Text = tostring(displayMPH)
    speedLbl.TextColor3 = displayMPH > 0 and Color3.fromRGB(90, 90, 90) or Color3.fromRGB(45, 45, 45)
end)

-- ── Idle scanning animation ───────────────
local idleBarIdx = 0
local lastIdleAnim = 0
local function idleAnimation()
    local now = tick()
    if now - lastIdleAnim < 0.3 then return end
    lastIdleAnim = now
    idleBarIdx = (idleBarIdx % barCount) + 1
    for i = 1, barCount do
        if i == idleBarIdx then
            bars[i].BackgroundColor3 = Color3.fromRGB(35, 50, 35)
        else
            bars[i].BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        end
    end
end

-- ── Main scan loop ────────────────────────
local lastScan = 0
local currentFreqs = {} -- cache random freqs per cop so they don't flicker

RunService.Heartbeat:Connect(function()
    if not cfg.Enabled then body.Visible = false return end
    body.Visible = true

    local now = tick()
    if now - lastScan < cfg.UpdateRate then return end
    lastScan = now

    local myRoot = getMyRoot()
    if not myRoot then setIdle() return end

    local myPos = myRoot.Position
    local myFwd = getMyForward()

    -- Scan all players
    local closestThreat = nil
    local closestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if not isCop(player) then continue end
        local copPos = getPlayerPosition(player)
        if not copPos then continue end

        local dist = (copPos - myPos).Magnitude
        if dist > cfg.MaxRange then continue end

        if dist < closestDist then
            closestDist = dist

            local toTarget = (copPos - myPos)
            local angle = getCompassDirection(myFwd, toTarget)
            local band = getBand(player, dist)

            -- Cache frequency per player so it doesn't randomize every frame
            if not currentFreqs[player] then
                currentFreqs[player] = getFrequency(band, dist)
            end

            closestThreat = {
                player = player,
                dist = dist,
                band = band,
                freq = currentFreqs[player],
                strength = getSignalStrength(dist),
                dir = angle,
                dirLabel = getCompassLabel(angle),
                arrow = getArrowDirection(angle),
            }
        end
    end

    -- Also check marked speed trap locations
    for idx, markPos in ipairs(markedLocations) do
        local dist = (markPos - myPos).Magnitude
        if dist > cfg.MaxRange then continue end
        if dist < closestDist then
            closestDist = dist
            local toTarget = (markPos - myPos)
            local angle = getCompassDirection(myFwd, toTarget)
            closestThreat = {
                player = nil,
                dist = dist,
                band = "Ka",
                freq = "34.700",
                strength = getSignalStrength(dist),
                dir = angle,
                dirLabel = getCompassLabel(angle),
                arrow = getArrowDirection(angle),
            }
        end
    end

    -- Clean stale freq cache
    for p, _ in pairs(currentFreqs) do
        if not p.Parent then currentFreqs[p] = nil end
    end

    if closestThreat then
        setAlert(closestThreat)
        statusDot.BackgroundColor3 = closestThreat.strength > 0.5 and
            Color3.fromRGB(255, 40, 40) or Color3.fromRGB(255, 180, 40)
    else
        setIdle()
        idleAnimation()
        statusDot.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
    end
end)

-- ── Toggle with RightShift ────────────────
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        cfg.Enabled = not cfg.Enabled
    end
end)

-- ── Draggable ─────────────────────────────
local dragging, dragStart, startPos
body.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = body.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        body.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

setIdle()
print("[DBSB.su] Radar Detector v1.0 loaded // RightShift to toggle")
