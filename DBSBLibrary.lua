-- ═══════════════════════════════════════════════════════
--  DBSB.su UI Library v1.0
--  Usage:
--      local UI = loadstring(...)() or paste inline
--      local win = UI:Window("DBSB.su", "Game Name")
--      local tab = win:Tab("Section", "⚙")
--      tab:Section("Header")
--      tab:Toggle("Label", "Description", false, function(v) end)
--      tab:Slider("Label", "Description", 0, 100, 50, function(v) end)
--      tab:Button("Label", "Description", function() end)
--      tab:Input("Label", "Placeholder", function(v) end)
--      tab:Dropdown("Label", {"A","B","C"}, "A", function(v) end)
--      tab:Keybind("Label", Enum.KeyCode.F, function() end)
--      tab:Label("Some info text")
--      win:Notify("Title", "Message", 3)
-- ═══════════════════════════════════════════════════════

local Library = {}
Library.__index = Library

-- ── Services ──────────────────────────────
local Players          = game:GetService("Players")
local UIS              = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local lp               = Players.LocalPlayer

-- ── Theme ─────────────────────────────────
local T = {
    -- Backgrounds
    BG          = Color3.fromRGB(18,  18,  22),   -- main window bg
    Sidebar     = Color3.fromRGB(24,  24,  30),   -- left sidebar
    Content     = Color3.fromRGB(18,  18,  22),   -- right content
    Card        = Color3.fromRGB(28,  28,  35),   -- element bg
    CardHover   = Color3.fromRGB(34,  34,  42),   -- element hover
    Input       = Color3.fromRGB(22,  22,  28),   -- input bg
    Dropdown    = Color3.fromRGB(26,  26,  33),   -- dropdown bg

    -- Accent
    Purple      = Color3.fromRGB(128, 58,  255),  -- main purple
    PurpleDim   = Color3.fromRGB(80,  35,  160),  -- dim purple
    PurpleDark  = Color3.fromRGB(30,  15,  60),   -- very dark purple bg
    PurpleGlow  = Color3.fromRGB(160, 90,  255),  -- bright purple

    -- Text
    TextPrimary = Color3.fromRGB(240, 240, 245),  -- main text
    TextSecond  = Color3.fromRGB(160, 160, 175),  -- secondary / descriptions
    TextMuted   = Color3.fromRGB(90,  90,  105),  -- section headers / muted
    TextDisable = Color3.fromRGB(70,  70,  80),   -- disabled

    -- Lines / borders
    Divider     = Color3.fromRGB(38,  38,  48),   -- section dividers
    Border      = Color3.fromRGB(45,  45,  58),   -- subtle borders
    BorderAccent= Color3.fromRGB(80,  45,  160),  -- purple border

    -- States
    Green       = Color3.fromRGB(50,  210, 100),
    Red         = Color3.fromRGB(230, 60,  60),
    Orange      = Color3.fromRGB(255, 150, 40),

    -- Checkbox
    CheckBG     = Color3.fromRGB(28,  28,  35),
    CheckActive = Color3.fromRGB(128, 58,  255),

    -- Scrollbar
    ScrollBar   = Color3.fromRGB(60,  35,  120),

    -- Notification
    NotifBG     = Color3.fromRGB(22,  22,  28),
}

-- ── Fonts ─────────────────────────────────
local F = {
    Bold    = Enum.Font.GothamBold,
    Medium  = Enum.Font.Gotham,
    Mono    = Enum.Font.Code,
}

-- ── Tween helper ──────────────────────────
local function tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration    or 0.2,
        style       or Enum.EasingStyle.Quad,
        direction   or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ── Instance helper ───────────────────────
local function new(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(radius, parent)
    return new("UICorner", {CornerRadius = UDim.new(0, radius or 6)}, parent)
end

local function stroke(color, thickness, parent)
    return new("UIStroke", {
        Color     = color     or T.Border,
        Thickness = thickness or 1,
    }, parent)
end

local function pad(l, r, t, b, parent)
    return new("UIPadding", {
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
    }, parent)
end

-- ══════════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════════
function Library:Window(title, subtitle)
    local Win = {}
    Win._tabs      = {}
    Win._activeTab = nil
    Win._library   = self

    -- Cleanup old
    local old = lp.PlayerGui:FindFirstChild("DBSB_UI_"..title:gsub("%s",""))
    if old then old:Destroy() end

    -- ScreenGui
    local sg = new("ScreenGui", {
        Name           = "DBSB_UI_"..title:gsub("%s",""),
        ResetOnSpawn   = false,
        DisplayOrder   = 9999,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, lp.PlayerGui)
    Win._sg = sg

    -- ── Main window frame ─────────────────
    local main = new("Frame", {
        Size             = UDim2.new(0, 660, 0, 480),
        Position         = UDim2.new(0.5, -330, 0.5, -240),
        BackgroundColor3 = T.BG,
        BorderSizePixel  = 0,
    }, sg)
    corner(10, main)
    stroke(T.Border, 1, main)
    Win._main = main

    -- Drop shadow effect (frame behind)
    local shadow = new("Frame", {
        Size             = UDim2.new(1, 20, 1, 20),
        Position         = UDim2.new(0, -10, 0, 8),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.6,
        BorderSizePixel  = 0,
        ZIndex           = 0,
    }, main)
    corner(14, shadow)

    -- ── Sidebar ───────────────────────────
    local sidebar = new("Frame", {
        Size             = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, main)
    -- Rounded only left side — use separate corner frame
    corner(10, sidebar)
    -- Cover right corners
    local sidebarFill = new("Frame", {
        Size             = UDim2.new(0, 10, 1, 0),
        Position         = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, sidebar)

    -- Sidebar right divider
    new("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = T.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, sidebar)

    -- ── Sidebar header ────────────────────
    local sideHeader = new("Frame", {
        Size             = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, sidebar)

    new("TextLabel", {
        Size               = UDim2.new(1, -16, 0, 22),
        Position           = UDim2.new(0, 14, 0, 14),
        BackgroundTransparency = 1,
        Text               = title,
        TextColor3         = T.TextPrimary,
        TextSize           = 16,
        Font               = F.Bold,
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 3,
    }, sideHeader)

    new("TextLabel", {
        Size               = UDim2.new(1, -16, 0, 14),
        Position           = UDim2.new(0, 14, 0, 36),
        BackgroundTransparency = 1,
        Text               = subtitle or "",
        TextColor3         = T.Purple,
        TextSize           = 10,
        Font               = F.Medium,
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 3,
    }, sideHeader)

    -- Header bottom line
    new("Frame", {
        Size             = UDim2.new(1, -14, 0, 1),
        Position         = UDim2.new(0, 14, 1, -1),
        BackgroundColor3 = T.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, sideHeader)

    -- ── Sidebar tab list ──────────────────
    local tabList = new("ScrollingFrame", {
        Size                  = UDim2.new(1, 0, 1, -70),
        Position              = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        ScrollBarThickness    = 0,
        CanvasSize            = UDim2.new(0, 0, 0, 0),
        ZIndex                = 3,
    }, sidebar)

    local tabListLayout = new("UIListLayout", {
        SortOrder      = Enum.SortOrder.LayoutOrder,
        Padding        = UDim.new(0, 2),
    }, tabList)

    pad(0, 0, 6, 6, tabList)

    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabList.CanvasSize = UDim2.new(0, 0, 0,
            tabListLayout.AbsoluteContentSize.Y + 12)
    end)

    Win._tabList = tabList

    -- ── Content area ──────────────────────
    local content = new("Frame", {
        Size             = UDim2.new(1, -200, 1, 0),
        Position         = UDim2.new(0, 200, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, main)
    Win._content = content

    -- ── Bottom branding ───────────────────
    local brand = new("TextLabel", {
        Size               = UDim2.new(1, 0, 0, 20),
        Position           = UDim2.new(0, 0, 1, -20),
        BackgroundTransparency = 1,
        Text               = "DBSB.su  //  discord.gg/dbsb",
        TextColor3         = T.TextMuted,
        TextSize           = 10,
        Font               = F.Medium,
        TextXAlignment     = Enum.TextXAlignment.Center,
        ZIndex             = 3,
    }, sidebar)

    -- ── Dragging ──────────────────────────
    local dragging, dragStart, startPos
    sideHeader.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── RightAlt toggle ───────────────────
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightAlt then
            sg.Enabled = not sg.Enabled
        end
    end)

    -- ── Notification system ───────────────
    local notifHolder = new("Frame", {
        Size             = UDim2.new(0, 280, 1, 0),
        Position         = UDim2.new(1, -294, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 9999,
    }, sg)

    local notifLayout = new("UIListLayout", {
        SortOrder        = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding          = UDim.new(0, 6),
    }, notifHolder)

    pad(0, 0, 0, 14, notifHolder)
    Win._notifHolder  = notifHolder
    Win._notifCount   = 0

    function Win:Notify(ntitle, message, duration)
        Win._notifCount = Win._notifCount + 1
        duration = duration or 3

        local notif = new("Frame", {
            Size             = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = T.NotifBG,
            BorderSizePixel  = 0,
            AutomaticSize    = Enum.AutomaticSize.Y,
            LayoutOrder      = Win._notifCount,
            ClipsDescendants = true,
        }, notifHolder)
        corner(6, notif)
        stroke(T.BorderAccent, 1, notif)

        -- Purple left accent bar
        new("Frame", {
            Size             = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = T.Purple,
            BorderSizePixel  = 0,
        }, notif)

        local notifContent = new("Frame", {
            Size             = UDim2.new(1, -14, 0, 0),
            Position         = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize    = Enum.AutomaticSize.Y,
        }, notif)

        new("TextLabel", {
            Size               = UDim2.new(1, 0, 0, 20),
            Position           = UDim2.new(0, 0, 0, 8),
            BackgroundTransparency = 1,
            Text               = ntitle,
            TextColor3         = T.TextPrimary,
            TextSize           = 13,
            Font               = F.Bold,
            TextXAlignment     = Enum.TextXAlignment.Left,
        }, notifContent)

        new("TextLabel", {
            Size               = UDim2.new(1, -8, 0, 0),
            Position           = UDim2.new(0, 0, 0, 28),
            BackgroundTransparency = 1,
            Text               = message,
            TextColor3         = T.TextSecond,
            TextSize           = 11,
            Font               = F.Medium,
            TextXAlignment     = Enum.TextXAlignment.Left,
            TextWrapped        = true,
            AutomaticSize      = Enum.AutomaticSize.Y,
        }, notifContent)

        -- Progress bar
        local progBg = new("Frame", {
            Size             = UDim2.new(1, 0, 0, 2),
            Position         = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = T.Divider,
            BorderSizePixel  = 0,
        }, notif)

        local progFill = new("Frame", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = T.Purple,
            BorderSizePixel  = 0,
        }, progBg)

        -- Animate in
        notif.BackgroundTransparency = 1
        tween(notif, {BackgroundTransparency = 0}, 0.2)

        -- Progress shrink
        tween(progFill, {Size = UDim2.new(0, 0, 1, 0)}, duration,
            Enum.EasingStyle.Linear)

        -- Auto dismiss
        task.delay(duration, function()
            tween(notif, {BackgroundTransparency = 1}, 0.3)
            task.wait(0.35)
            notif:Destroy()
        end)
    end

    -- ── Tab constructor ───────────────────
    function Win:Tab(tabName, icon)
        local Tab   = {}
        Tab._win    = Win
        Tab._name   = tabName
        Tab._order  = #Win._tabs + 1

        -- ── Sidebar button ────────────────
        local tabBtn = new("Frame", {
            Size             = UDim2.new(1, -8, 0, 36),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            LayoutOrder      = Tab._order,
        }, tabList)

        -- Purple left bar (hidden when inactive)
        local leftBar = new("Frame", {
            Size             = UDim2.new(0, 3, 0, 20),
            Position         = UDim2.new(0, 0, 0.5, -10),
            BackgroundColor3 = T.Purple,
            BorderSizePixel  = 0,
        }, tabBtn)
        corner(2, leftBar)
        leftBar.Visible = false

        -- Hover/active bg
        local tabBg = new("Frame", {
            Size             = UDim2.new(1, -4, 1, 0),
            Position         = UDim2.new(0, 4, 0, 0),
            BackgroundColor3 = T.PurpleDark,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
        }, tabBtn)
        corner(6, tabBg)

        -- Icon label
        local iconLbl = new("TextLabel", {
            Size               = UDim2.new(0, 20, 1, 0),
            Position           = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text               = icon or "○",
            TextColor3         = T.TextMuted,
            TextSize           = 14,
            Font               = F.Bold,
            TextXAlignment     = Enum.TextXAlignment.Center,
        }, tabBtn)

        -- Tab name label
        local tabLbl = new("TextLabel", {
            Size               = UDim2.new(1, -42, 1, 0),
            Position           = UDim2.new(0, 38, 0, 0),
            BackgroundTransparency = 1,
            Text               = tabName,
            TextColor3         = T.TextMuted,
            TextSize           = 13,
            Font               = F.Medium,
            TextXAlignment     = Enum.TextXAlignment.Left,
        }, tabBtn)

        -- ── Content scroll ────────────────
        local scroll = new("ScrollingFrame", {
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            ScrollBarThickness    = 3,
            ScrollBarImageColor3  = T.ScrollBar,
            CanvasSize            = UDim2.new(0, 0, 0, 0),
            Visible               = false,
        }, content)

        local scrollLayout = new("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 4),
        }, scroll)

        pad(14, 14, 14, 14, scroll)

        scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0,
                scrollLayout.AbsoluteContentSize.Y + 28)
        end)

        Tab._scroll = scroll
        Tab._order2 = 0  -- element order counter

        -- ── Activate tab ──────────────────
        local function activate()
            -- Deactivate all tabs
            for _, t in ipairs(Win._tabs) do
                t._scroll.Visible = false
                t._leftBar.Visible = false
                tween(t._tabBg, {BackgroundTransparency = 1}, 0.15)
                tween(t._iconLbl, {TextColor3 = T.TextMuted}, 0.15)
                tween(t._tabLbl, {
                    TextColor3 = T.TextMuted,
                    Font       = Enum.Font.Gotham,
                }, 0.15)
            end
            -- Activate this
            scroll.Visible   = true
            leftBar.Visible  = true
            Win._activeTab   = Tab
            tween(tabBg,   {BackgroundTransparency = 0.85}, 0.15)
            tween(iconLbl, {TextColor3 = T.Purple}, 0.15)
            tween(tabLbl,  {
                TextColor3 = T.TextPrimary,
            }, 0.15)
            tabLbl.Font = F.Bold
        end

        Tab._leftBar = leftBar
        Tab._tabBg   = tabBg
        Tab._iconLbl = iconLbl
        Tab._tabLbl  = tabLbl
        Tab._activate = activate

        -- Click to activate
        local clickBtn = new("TextButton", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text             = "",
            ZIndex           = 5,
        }, tabBtn)

        clickBtn.MouseButton1Click:Connect(activate)

        -- Hover effect
        clickBtn.MouseEnter:Connect(function()
            if Win._activeTab ~= Tab then
                tween(tabBg, {BackgroundTransparency = 0.95}, 0.1)
                tween(tabLbl, {TextColor3 = T.TextSecond}, 0.1)
            end
        end)
        clickBtn.MouseLeave:Connect(function()
            if Win._activeTab ~= Tab then
                tween(tabBg, {BackgroundTransparency = 1}, 0.1)
                tween(tabLbl, {TextColor3 = T.TextMuted}, 0.1)
            end
        end)

        table.insert(Win._tabs, Tab)

        -- Auto activate first tab
        if #Win._tabs == 1 then
            activate()
        end

        -- ══════════════════════════════════
        --  ELEMENTS
        -- ══════════════════════════════════

        -- ── Section header ────────────────
        function Tab:Section(label)
            Tab._order2 = Tab._order2 + 1

            local row = new("Frame", {
                Size             = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order2,
            }, scroll)

            new("TextLabel", {
                Size               = UDim2.new(0, 0, 1, 0),
                AutomaticSize      = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text               = label:upper(),
                TextColor3         = T.TextMuted,
                TextSize           = 10,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Left,
            }, row)

            -- Divider line extending right
            new("Frame", {
                Size             = UDim2.new(1, -8, 0, 1),
                Position         = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = T.Divider,
                BorderSizePixel  = 0,
            }, row)

            return row
        end

        -- ── Label ─────────────────────────
        function Tab:Label(text)
            Tab._order2 = Tab._order2 + 1

            local row = new("Frame", {
                Size             = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order2,
            }, scroll)

            new("TextLabel", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = text,
                TextColor3         = T.TextSecond,
                TextSize           = 11,
                Font               = F.Medium,
                TextXAlignment     = Enum.TextXAlignment.Left,
                TextWrapped        = true,
            }, row)

            return row
        end

        -- ── Toggle ────────────────────────
        function Tab:Toggle(label, desc, default, callback)
            Tab._order2 = Tab._order2 + 1
            local val = default or false

            local row = new("Frame", {
                Size             = UDim2.new(1, 0, 0, desc and 52 or 36),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order2,
            }, scroll)
            corner(6, row)
            local rStroke = stroke(T.Border, 1, row)

            -- Left purple bar (hidden when off)
            local lBar = new("Frame", {
                Size             = UDim2.new(0, 3, 1, -12),
                Position         = UDim2.new(0, 0, 0, 6),
                BackgroundColor3 = T.Purple,
                BorderSizePixel  = 0,
                Visible          = val,
            }, row)
            corner(2, lBar)

            -- Labels
            new("TextLabel", {
                Size               = UDim2.new(1, -64, 0, 20),
                Position           = UDim2.new(0, 14, 0, desc and 8 or 8),
                BackgroundTransparency = 1,
                Text               = label,
                TextColor3         = T.TextPrimary,
                TextSize           = 13,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Left,
            }, row)

            if desc then
                new("TextLabel", {
                    Size               = UDim2.new(1, -64, 0, 16),
                    Position           = UDim2.new(0, 14, 0, 28),
                    BackgroundTransparency = 1,
                    Text               = desc,
                    TextColor3         = T.TextSecond,
                    TextSize           = 11,
                    Font               = F.Medium,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                }, row)
            end

            -- Checkbox
            local checkBg = new("Frame", {
                Size             = UDim2.new(0, 18, 0, 18),
                Position         = UDim2.new(1, -36, 0.5, -9),
                BackgroundColor3 = val and T.Purple or T.CheckBG,
                BorderSizePixel  = 0,
            }, row)
            corner(4, checkBg)
            stroke(val and T.Purple or T.Border, 1, checkBg)

            -- Checkmark
            local checkMark = new("TextLabel", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = "✓",
                TextColor3         = T.TextPrimary,
                TextSize           = 12,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Center,
                TextTransparency   = val and 0 or 1,
            }, checkBg)

            local function refresh()
                tween(checkBg, {
                    BackgroundColor3 = val and T.Purple or T.CheckBG
                }, 0.15)
                tween(checkMark, {
                    TextTransparency = val and 0 or 1
                }, 0.1)
                tween(rStroke, {Color = val and T.BorderAccent or T.Border}, 0.15)
                lBar.Visible = val
                if callback then
                    pcall(callback, val)
                end
            end

            -- Click area
            local btn = new("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 5,
            }, row)

            btn.MouseButton1Click:Connect(function()
                val = not val
                refresh()
            end)

            btn.MouseEnter:Connect(function()
                tween(row, {BackgroundColor3 = T.CardHover}, 0.1)
            end)
            btn.MouseLeave:Connect(function()
                tween(row, {BackgroundColor3 = T.Card}, 0.1)
            end)

            -- Return controller
            local ctrl = {}
            function ctrl:Set(v)
                val = v
                refresh()
            end
            function ctrl:Get() return val end
            return ctrl
        end

        -- ── Slider ────────────────────────
        function Tab:Slider(label, desc, min, max, default, callback)
            Tab._order2 = Tab._order2 + 1
            min     = min     or 0
            max     = max     or 100
            default = math.clamp(default or min, min, max)
            local val = default
            local isInt = (math.floor(min) == min and math.floor(max) == max
                and math.floor(default) == default)

            local row = new("Frame", {
                Size             = UDim2.new(1, 0, 0, desc and 64 or 52),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order2,
            }, scroll)
            corner(6, row)
            stroke(T.Border, 1, row)

            -- Label
            new("TextLabel", {
                Size               = UDim2.new(0.65, 0, 0, 18),
                Position           = UDim2.new(0, 14, 0, desc and 8 or 6),
                BackgroundTransparency = 1,
                Text               = label,
                TextColor3         = T.TextPrimary,
                TextSize           = 13,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Left,
            }, row)

            if desc then
                new("TextLabel", {
                    Size               = UDim2.new(0.65, 0, 0, 14),
                    Position           = UDim2.new(0, 14, 0, 26),
                    BackgroundTransparency = 1,
                    Text               = desc,
                    TextColor3         = T.TextSecond,
                    TextSize           = 10,
                    Font               = F.Medium,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                }, row)
            end

            -- Value label
            local valLbl = new("TextLabel", {
                Size               = UDim2.new(0.3, 0, 0, 18),
                Position           = UDim2.new(0.68, 0, 0, desc and 8 or 6),
                BackgroundTransparency = 1,
                Text               = tostring(isInt and math.floor(val) or
                    math.floor(val*100+0.5)/100),
                TextColor3         = T.Purple,
                TextSize           = 14,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Right,
            }, row)

            -- Track
            local trackBg = new("Frame", {
                Size             = UDim2.new(1, -28, 0, 4),
                Position         = UDim2.new(0, 14, 1, -18),
                BackgroundColor3 = T.Divider,
                BorderSizePixel  = 0,
            }, row)
            corner(2, trackBg)

            local pct0 = (val - min) / (max - min)

            local trackFill = new("Frame", {
                Size             = UDim2.new(pct0, 0, 1, 0),
                BackgroundColor3 = T.Purple,
                BorderSizePixel  = 0,
            }, trackBg)
            corner(2, trackFill)

            local knob = new("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = UDim2.new(pct0, -7, 0.5, -7),
                BackgroundColor3 = T.PurpleGlow,
                BorderSizePixel  = 0,
            }, trackBg)
            corner(7, knob)

            local function fmtVal(v)
                if isInt then
                    return tostring(math.floor(v))
                else
                    return string.format("%.2f", v)
                end
            end

            local sliding = false

            local function updateSlider(x)
                local p = math.clamp(
                    (x - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X,
                    0, 1)
                val = min + (max - min) * p
                if isInt then val = math.floor(val + 0.5) end
                val = math.clamp(val, min, max)
                local p2 = (val - min) / (max - min)
                trackFill.Size     = UDim2.new(p2, 0, 1, 0)
                knob.Position      = UDim2.new(p2, -7, 0.5, -7)
                valLbl.Text        = fmtVal(val)
                if callback then pcall(callback, val) end
            end

            trackBg.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    updateSlider(i.Position.X)
                end
            end)
            knob.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(i.Position.X)
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)

            row.MouseEnter:Connect(function()
                tween(row, {BackgroundColor3 = T.CardHover}, 0.1)
            end)
            row.MouseLeave:Connect(function()
                tween(row, {BackgroundColor3 = T.Card}, 0.1)
            end)

            local ctrl = {}
            function ctrl:Set(v)
                val = math.clamp(v, min, max)
                local p2 = (val-min)/(max-min)
                trackFill.Size = UDim2.new(p2,0,1,0)
                knob.Position  = UDim2.new(p2,-7,0.5,-7)
                valLbl.Text    = fmtVal(val)
                if callback then pcall(callback, val) end
            end
            function ctrl:Get() return val end
            return ctrl
        end

        -- ── Button ────────────────────────
        function Tab:Button(label, desc, callback, primary)
            Tab._order2 = Tab._order2 + 1

            local h = desc and 52 or 36
            local row = new("Frame", {
                Size             = UDim2.new(1, 0, 0, h),
                BackgroundColor3 = primary and T.PurpleDark or T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order2,
            }, scroll)
            corner(6, row)
            stroke(primary and T.BorderAccent or T.Border, 1, row)

            new("TextLabel", {
                Size               = UDim2.new(1, -28, 0, 20),
                Position           = UDim2.new(0, 14, 0, desc and 8 or 8),
                BackgroundTransparency = 1,
                Text               = label,
                TextColor3         = primary and T.PurpleGlow or T.TextPrimary,
                TextSize           = 13,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Left,
            }, row)

            if desc then
                new("TextLabel", {
                    Size               = UDim2.new(1, -28, 0, 16),
                    Position           = UDim2.new(0, 14, 0, 28),
                    BackgroundTransparency = 1,
                    Text               = desc,
                    TextColor3         = T.TextSecond,
                    TextSize           = 11,
                    Font               = F.Medium,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                }, row)
            end

            -- Arrow indicator
            new("TextLabel", {
                Size               = UDim2.new(0, 20, 1, 0),
                Position           = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text               = "›",
                TextColor3         = primary and T.Purple or T.TextMuted,
                TextSize           = 18,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Center,
            }, row)

            local btn = new("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 5,
            }, row)

            btn.MouseButton1Click:Connect(function()
                tween(row, {BackgroundColor3 = primary and T.PurpleDim or T.CardHover}, 0.08)
                task.delay(0.12, function()
                    tween(row, {BackgroundColor3 = primary and T.PurpleDark or T.Card}, 0.12)
                end)
                if callback then pcall(callback) end
            end)

            btn.MouseEnter:Connect(function()
                tween(row, {BackgroundColor3 = primary and T.PurpleDim or T.CardHover}, 0.1)
            end)
            btn.MouseLeave:Connect(function()
                tween(row, {BackgroundColor3 = primary and T.PurpleDark or T.Card}, 0.1)
            end)

            return row
        end

        -- ── Input ─────────────────────────
        function Tab:Input(label, placeholder, callback)
            Tab._order2 = Tab._order2 + 1

            local row = new("Frame", {
                Size             = UDim2.new(1, 0, 0, 58),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order2,
            }, scroll)
            corner(6, row)
            stroke(T.Border, 1, row)

            new("TextLabel", {
                Size               = UDim2.new(1, -14, 0, 18),
                Position           = UDim2.new(0, 14, 0, 6),
                BackgroundTransparency = 1,
                Text               = label,
                TextColor3         = T.TextPrimary,
                TextSize           = 13,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Left,
            }, row)

            local inputBg = new("Frame", {
                Size             = UDim2.new(1, -28, 0, 24),
                Position         = UDim2.new(0, 14, 0, 28),
                BackgroundColor3 = T.Input,
                BorderSizePixel  = 0,
            }, row)
            corner(4, inputBg)
            local iStroke = stroke(T.Border, 1, inputBg)

            local box = new("TextBox", {
                Size               = UDim2.new(1, -16, 1, 0),
                Position           = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                PlaceholderText    = placeholder or "Enter value...",
                PlaceholderColor3  = T.TextMuted,
                Text               = "",
                TextColor3         = T.TextPrimary,
                TextSize           = 12,
                Font               = F.Medium,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ClearTextOnFocus   = false,
            }, inputBg)

            box.Focused:Connect(function()
                tween(iStroke, {Color = T.Purple}, 0.15)
            end)
            box.FocusLost:Connect(function(enter)
                tween(iStroke, {Color = T.Border}, 0.15)
                if callback then pcall(callback, box.Text, enter) end
            end)

            row.MouseEnter:Connect(function()
                tween(row, {BackgroundColor3 = T.CardHover}, 0.1)
            end)
            row.MouseLeave:Connect(function()
                tween(row, {BackgroundColor3 = T.Card}, 0.1)
            end)

            local ctrl = {}
            function ctrl:Set(v) box.Text = tostring(v) end
            function ctrl:Get() return box.Text end
            return ctrl
        end

        -- ── Dropdown ──────────────────────
        function Tab:Dropdown(label, options, default, callback)
            Tab._order2 = Tab._order2 + 1
            local val    = default or options[1]
            local open   = false

            local row = new("Frame", {
                Size             = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order2,
                ClipsDescendants = false,
                ZIndex           = 10,
            }, scroll)
            corner(6, row)
            local rStroke = stroke(T.Border, 1, row)

            new("TextLabel", {
                Size               = UDim2.new(1, -14, 0, 18),
                Position           = UDim2.new(0, 14, 0, 6),
                BackgroundTransparency = 1,
                Text               = label,
                TextColor3         = T.TextPrimary,
                TextSize           = 13,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 11,
            }, row)

            -- Selected value display
            local selBg = new("Frame", {
                Size             = UDim2.new(1, -28, 0, 22),
                Position         = UDim2.new(0, 14, 0, 24),
                BackgroundColor3 = T.Input,
                BorderSizePixel  = 0,
                ZIndex           = 11,
            }, row)
            corner(4, selBg)
            stroke(T.Border, 1, selBg)

            local selLbl = new("TextLabel", {
                Size               = UDim2.new(1, -28, 1, 0),
                Position           = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text               = tostring(val),
                TextColor3         = T.TextPrimary,
                TextSize           = 12,
                Font               = F.Medium,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 12,
            }, selBg)

            -- Arrow
            local arrowLbl = new("TextLabel", {
                Size               = UDim2.new(0, 20, 1, 0),
                Position           = UDim2.new(1, -22, 0, 0),
                BackgroundTransparency = 1,
                Text               = "▾",
                TextColor3         = T.TextMuted,
                TextSize           = 14,
                Font               = F.Bold,
                ZIndex             = 12,
            }, selBg)

            -- Dropdown list (shown below)
            local listBg = new("Frame", {
                Size             = UDim2.new(1, -28, 0, #options * 28 + 8),
                Position         = UDim2.new(0, 14, 0, 54),
                BackgroundColor3 = T.Dropdown,
                BorderSizePixel  = 0,
                Visible          = false,
                ZIndex           = 20,
            }, row)
            corner(6, listBg)
            stroke(T.BorderAccent, 1, listBg)

            pad(4,4,4,4, listBg)
            local listLayout2 = new("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 2),
            }, listBg)

            for idx, opt in ipairs(options) do
                local optBtn = new("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = tostring(opt) == tostring(val)
                        and T.PurpleDark or Color3.fromRGB(0,0,0),
                    BackgroundTransparency = tostring(opt) == tostring(val) and 0 or 1,
                    Text             = tostring(opt),
                    TextColor3       = tostring(opt) == tostring(val)
                        and T.PurpleGlow or T.TextSecond,
                    TextSize         = 12,
                    Font             = F.Medium,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    BorderSizePixel  = 0,
                    ZIndex           = 21,
                    LayoutOrder      = idx,
                }, listBg)
                corner(4, optBtn)
                pad(8,0,0,0, optBtn)

                optBtn.MouseEnter:Connect(function()
                    if tostring(opt) ~= tostring(val) then
                        tween(optBtn, {BackgroundTransparency = 0.9,
                            TextColor3 = T.TextPrimary}, 0.1)
                        optBtn.BackgroundColor3 = T.CardHover
                    end
                end)
                optBtn.MouseLeave:Connect(function()
                    if tostring(opt) ~= tostring(val) then
                        tween(optBtn, {BackgroundTransparency = 1,
                            TextColor3 = T.TextSecond}, 0.1)
                    end
                end)

                optBtn.MouseButton1Click:Connect(function()
                    val    = opt
                    selLbl.Text = tostring(opt)
                    open   = false
                    listBg.Visible = false
                    arrowLbl.Text  = "▾"
                    tween(rStroke, {Color = T.Border}, 0.15)
                    -- Reset all options
                    for _, child in ipairs(listBg:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.BackgroundTransparency = 1
                            child.TextColor3 = T.TextSecond
                        end
                    end
                    optBtn.BackgroundTransparency = 0
                    optBtn.BackgroundColor3 = T.PurpleDark
                    optBtn.TextColor3 = T.PurpleGlow
                    if callback then pcall(callback, val) end
                end)
            end

            -- Toggle dropdown
            local toggleBtn = new("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 15,
            }, selBg)

            toggleBtn.MouseButton1Click:Connect(function()
                open = not open
                listBg.Visible = open
                arrowLbl.Text  = open and "▴" or "▾"
                tween(rStroke, {Color = open and T.BorderAccent or T.Border}, 0.15)
            end)

            row.MouseEnter:Connect(function()
                tween(row, {BackgroundColor3 = T.CardHover}, 0.1)
            end)
            row.MouseLeave:Connect(function()
                tween(row, {BackgroundColor3 = T.Card}, 0.1)
            end)

            local ctrl = {}
            function ctrl:Set(v)
                val = v
                selLbl.Text = tostring(v)
                if callback then pcall(callback, val) end
            end
            function ctrl:Get() return val end
            return ctrl
        end

        -- ── Keybind ───────────────────────
        function Tab:Keybind(label, desc, default, callback)
            Tab._order2 = Tab._order2 + 1
            local currentKey = default or Enum.KeyCode.Unknown
            local listening  = false

            local row = new("Frame", {
                Size             = UDim2.new(1, 0, 0, desc and 52 or 36),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order2,
            }, scroll)
            corner(6, row)
            local rStroke = stroke(T.Border, 1, row)

            new("TextLabel", {
                Size               = UDim2.new(1, -100, 0, 20),
                Position           = UDim2.new(0, 14, 0, desc and 8 or 8),
                BackgroundTransparency = 1,
                Text               = label,
                TextColor3         = T.TextPrimary,
                TextSize           = 13,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Left,
            }, row)

            if desc then
                new("TextLabel", {
                    Size               = UDim2.new(1, -100, 0, 16),
                    Position           = UDim2.new(0, 14, 0, 28),
                    BackgroundTransparency = 1,
                    Text               = desc,
                    TextColor3         = T.TextSecond,
                    TextSize           = 11,
                    Font               = F.Medium,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                }, row)
            end

            -- Key display
            local keyBg = new("Frame", {
                Size             = UDim2.new(0, 72, 0, 24),
                Position         = UDim2.new(1, -84, 0.5, -12),
                BackgroundColor3 = T.Input,
                BorderSizePixel  = 0,
            }, row)
            corner(4, keyBg)
            local kStroke = stroke(T.Border, 1, keyBg)

            local keyLbl = new("TextLabel", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = currentKey == Enum.KeyCode.Unknown
                    and "NONE" or currentKey.Name,
                TextColor3         = T.Purple,
                TextSize           = 11,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Center,
            }, keyBg)

            local keyBtn = new("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 5,
            }, keyBg)

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyLbl.Text      = "..."
                keyLbl.TextColor3 = T.Orange
                tween(kStroke, {Color = T.Orange}, 0.15)
            end)

            UIS.InputBegan:Connect(function(input, gpe)
                if not listening then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                listening    = false
                currentKey   = input.KeyCode
                keyLbl.Text  = currentKey.Name
                keyLbl.TextColor3 = T.Purple
                tween(kStroke, {Color = T.Border}, 0.15)
            end)

            -- Global key listener
            UIS.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if not listening and input.KeyCode == currentKey
                    and currentKey ~= Enum.KeyCode.Unknown then
                    if callback then pcall(callback) end
                end
            end)

            row.MouseEnter:Connect(function()
                tween(row, {BackgroundColor3 = T.CardHover}, 0.1)
            end)
            row.MouseLeave:Connect(function()
                tween(row, {BackgroundColor3 = T.Card}, 0.1)
            end)

            local ctrl = {}
            function ctrl:Set(k)
                currentKey   = k
                keyLbl.Text  = k == Enum.KeyCode.Unknown and "NONE" or k.Name
            end
            function ctrl:Get() return currentKey end
            return ctrl
        end

        -- ── Color picker (basic) ──────────
        function Tab:ColorPicker(label, default, callback)
            Tab._order2 = Tab._order2 + 1
            local val = default or Color3.fromRGB(255, 255, 255)

            local row = new("Frame", {
                Size             = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order2,
            }, scroll)
            corner(6, row)
            stroke(T.Border, 1, row)

            new("TextLabel", {
                Size               = UDim2.new(1, -80, 0, 20),
                Position           = UDim2.new(0, 14, 0, 12),
                BackgroundTransparency = 1,
                Text               = label,
                TextColor3         = T.TextPrimary,
                TextSize           = 13,
                Font               = F.Bold,
                TextXAlignment     = Enum.TextXAlignment.Left,
            }, row)

            -- Color preview swatch
            local swatch = new("Frame", {
                Size             = UDim2.new(0, 44, 0, 22),
                Position         = UDim2.new(1, -58, 0.5, -11),
                BackgroundColor3 = val,
                BorderSizePixel  = 0,
            }, row)
            corner(4, swatch)
            stroke(T.Border, 1, swatch)

            -- RGB inputs below (open on click)
            local expanded = false
            local rgbFrame = new("Frame", {
                Size             = UDim2.new(1, 0, 0, 44),
                Position         = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = T.Card,
                BorderSizePixel  = 0,
                Visible          = false,
                ZIndex           = 8,
            }, row)
            corner(6, rgbFrame)
            stroke(T.BorderAccent, 1, rgbFrame)

            local function makeRGBInput(placeholder, xPos, getVal, setVal)
                local bg = new("Frame", {
                    Size             = UDim2.new(0.3, -4, 0, 24),
                    Position         = UDim2.new(xPos, 2, 0, 10),
                    BackgroundColor3 = T.Input,
                    BorderSizePixel  = 0,
                    ZIndex           = 9,
                }, rgbFrame)
                corner(4, bg)
                local box = new("TextBox", {
                    Size               = UDim2.new(1, -8, 1, 0),
                    Position           = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    PlaceholderText    = placeholder,
                    PlaceholderColor3  = T.TextMuted,
                    Text               = tostring(math.floor(getVal()*255)),
                    TextColor3         = T.TextPrimary,
                    TextSize           = 11,
                    Font               = F.Mono,
                    ZIndex             = 10,
                }, bg)
                box.FocusLost:Connect(function()
                    local n = tonumber(box.Text)
                    if n then
                        n = math.clamp(math.floor(n), 0, 255)
                        box.Text = tostring(n)
                        setVal(n/255)
                        swatch.BackgroundColor3 = val
                        if callback then pcall(callback, val) end
                    end
                end)
                return box
            end

            makeRGBInput("R", 0,     function() return val.R end,
                function(v) val = Color3.new(v, val.G, val.B) end)
            makeRGBInput("G", 0.333, function() return val.G end,
                function(v) val = Color3.new(val.R, v, val.B) end)
            makeRGBInput("B", 0.666, function() return val.B end,
                function(v) val = Color3.new(val.R, val.G, v) end)

            -- Expand on swatch click
            local swatchBtn = new("TextButton", {
                Size             = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 5,
            }, swatch)

            swatchBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                rgbFrame.Visible = expanded
                if expanded then
                    row.Size = UDim2.new(1, 0, 0, 44+46)
                else
                    row.Size = UDim2.new(1, 0, 0, 44)
                end
            end)

            row.MouseEnter:Connect(function()
                tween(row, {BackgroundColor3 = T.CardHover}, 0.1)
            end)
            row.MouseLeave:Connect(function()
                tween(row, {BackgroundColor3 = T.Card}, 0.1)
            end)

            local ctrl = {}
            function ctrl:Set(c)
                val = c
                swatch.BackgroundColor3 = c
                if callback then pcall(callback, val) end
            end
            function ctrl:Get() return val end
            return ctrl
        end

        -- ── Spacer ────────────────────────
        function Tab:Spacer(height)
            Tab._order2 = Tab._order2 + 1
            new("Frame", {
                Size             = UDim2.new(1, 0, 0, height or 8),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                LayoutOrder      = Tab._order2,
            }, scroll)
        end

        return Tab
    end

    -- ── Section divider between tab groups ─
    function Win:TabDivider(label)
        local divRow = new("Frame", {
            Size             = UDim2.new(1, -8, 0, 26),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            LayoutOrder      = #Win._tabs + 0.5,
        }, tabList)

        new("TextLabel", {
            Size               = UDim2.new(1, -14, 1, 0),
            Position           = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text               = (label or ""):upper(),
            TextColor3         = T.TextMuted,
            TextSize           = 9,
            Font               = F.Bold,
            TextXAlignment     = Enum.TextXAlignment.Left,
        }, divRow)

        -- Divider line
        new("Frame", {
            Size             = UDim2.new(1, -14, 0, 1),
            Position         = UDim2.new(0, 14, 1, -1),
            BackgroundColor3 = T.Divider,
            BorderSizePixel  = 0,
        }, divRow)
    end

    return Win
end

-- ══════════════════════════════════════════
--  Return library
-- ══════════════════════════════════════════
return Library
