-- Moon Incremental by NVHeadMonbo v2.0 — MonboVerse Library entry
-- ============================================================================
-- NOTE: This script is loaded POST-VERIFICATION by the MonboVerse Library Hub
-- (src/Core/ScriptLoader.lua). It contains NO key-system code of its own — the
-- Junkie key gate was removed and centralized into src/Services/KeySystem.lua.
-- It is also fully standalone: launching it directly runs the UI and the game
-- loop immediately (no key gate), so it behaves identically either way.
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("MoonIncrementalGUI")
if existing then
    existing:Destroy()
end

local C = {
    BG          = Color3.fromRGB(8, 16, 30),
    TITLE_BG    = Color3.fromRGB(12, 24, 46),
    ACCENT      = Color3.fromRGB(0, 200, 255),
    ACCENT2     = Color3.fromRGB(0, 255, 160),
    PURPLE      = Color3.fromRGB(88, 101, 242),
    TEXT        = Color3.fromRGB(210, 235, 255),
    SUBTEXT     = Color3.fromRGB(110, 155, 190),
    BTN_ON      = Color3.fromRGB(88, 101, 242),
    BTN_OFF     = Color3.fromRGB(40, 42, 50),
    SLIDER_TRK  = Color3.fromRGB(20, 40, 65),
    SLIDER_FIL  = Color3.fromRGB(0, 200, 255),
    INTENSITY   = Color3.fromRGB(255, 107, 107),
    BORDER      = Color3.fromRGB(0, 180, 230),
    MINIMIZE    = Color3.fromRGB(255, 180, 0),
    CARD        = Color3.fromRGB(14, 26, 46),
    CARD_BORDER = Color3.fromRGB(20, 45, 75),
}
local FONT_BOLD = Enum.Font.GothamBold
local FONT_REG = Enum.Font.Gotham

local VERSION = "2.0.0"
local WINDOW_W = 500
local FULL_HEIGHT = 600
local MINI_HEIGHT = 42

local function create(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    inst.Parent = parent
    return inst
end

local gui = create("ScreenGui", {
    Name = "MoonIncrementalGUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local MainFrame = create("Frame", {
    Name = "MainFrame",
    Size = UDim2.fromOffset(WINDOW_W, FULL_HEIGHT),
    Position = UDim2.new(0.5, -WINDOW_W / 2, 0, 24),
    BackgroundColor3 = C.BG,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
create("UICorner", { CornerRadius = UDim.new(0, 10) }, MainFrame)

local BorderStroke = create("UIStroke", {
    Thickness = 3,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = C.BORDER,
}, MainFrame)
local RainbowGrad = create("UIGradient", {
    Rotation = 0,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 128, 0)),
        ColorSequenceKeypoint.new(0.34, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.51, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.68, Color3.fromRGB(0, 128, 255)),
        ColorSequenceKeypoint.new(0.85, Color3.fromRGB(128, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
    }),
}, BorderStroke)

local TitleBar = create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = C.TITLE_BG,
    BorderSizePixel = 0,
    Active = true,
}, MainFrame)
create("UICorner", { CornerRadius = UDim.new(0, 10) }, TitleBar)
create("Frame", { Name = "TitleBarFill", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = C.TITLE_BG, BorderSizePixel = 0 }, TitleBar)

create("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, -170, 0, 42),
    Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1,
    Text = "🌙 Moon Incremental",
    Font = FONT_BOLD,
    TextSize = 17,
    TextColor3 = C.TEXT,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TitleBar)

create("TextLabel", {
    Name = "Credit",
    Size = UDim2.new(0, 140, 0, 18),
    Position = UDim2.new(0, 200, 0, 12),
    BackgroundTransparency = 1,
    Text = "by NVHeadMonbo",
    Font = FONT_REG,
    TextSize = 12,
    TextColor3 = C.SUBTEXT,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TitleBar)

local MinimizeBtn = create("TextButton", {
    Name = "MinimizeBtn",
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -42, 0, 4),
    BackgroundColor3 = C.TITLE_BG,
    Text = "—",
    Font = FONT_BOLD,
    TextSize = 18,
    TextColor3 = C.MINIMIZE,
    AutoButtonColor = false,
    ZIndex = 2,
}, TitleBar)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, MinimizeBtn)

local NavBar = create("Frame", {
    Name = "NavBar",
    Size = UDim2.new(1, 0, 0, 44),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundColor3 = C.BG,
    BorderSizePixel = 0,
}, MainFrame)

local pages = {}
local navButtons = {}

local function switchPage(page)
    for name, frame in pairs(pages) do
        frame.Visible = (name == page)
    end
    for name, btn in pairs(navButtons) do
        local active = (name == page)
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = active and C.ACCENT or C.SLIDER_TRK,
        }):Play()
    end
end

local function makeNavBtn(label, xScale, xOffset, page)
    local btn = create("TextButton", {
        Name = "Nav_" .. label,
        Size = UDim2.new(0.5, -12, 0.7, 0),
        Position = UDim2.new(xScale, xOffset, 0.15, 0),
        BackgroundColor3 = C.SLIDER_TRK,
        Text = label,
        Font = FONT_BOLD,
        TextSize = 14,
        TextColor3 = C.TEXT,
        AutoButtonColor = false,
    }, NavBar)
    create("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)
    navButtons[page] = btn
    btn.Activated:Connect(function()
        switchPage(page)
    end)
    return btn
end

local ContentArea = create("Frame", {
    Name = "ContentArea",
    Size = UDim2.new(1, 0, 1, -86),
    Position = UDim2.new(0, 0, 0, 86),
    BackgroundColor3 = C.BG,
    BorderSizePixel = 0,
}, MainFrame)

local MainPage = create("ScrollingFrame", {
    Name = "MainPage",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, ContentArea)
create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 20),
    PaddingRight = UDim.new(0, 20),
}, MainPage)
local MainList = create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 10),
}, MainPage)

local InfoPage = create("ScrollingFrame", {
    Name = "InfoPage",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollingDirection = Enum.ScrollingDirection.Y,
    Visible = false,
}, ContentArea)
create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 20),
    PaddingRight = UDim.new(0, 20),
}, InfoPage)
create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 10),
}, InfoPage)

pages["Main"] = MainPage
pages["Info"] = InfoPage

local function showToast(parentGui, message, color, duration)
    duration = duration or 3
    local toast = create("Frame", {
        Name = "Toast",
        Size = UDim2.fromOffset(320, 44),
        Position = UDim2.new(0.5, -160, 0, -50),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(10, 14, 20),
        BorderSizePixel = 0,
        ZIndex = 20,
    }, parentGui)
    create("UICorner", { CornerRadius = UDim.new(0, 10) }, toast)
    create("UIStroke", {
        Thickness = 1,
        Color = color or C.ACCENT,
        Transparency = 0.4,
    }, toast)
    create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = message,
        Font = FONT_BOLD,
        TextSize = 14,
        TextColor3 = C.TEXT,
        TextWrapped = true,
    }, toast)
    TweenService:Create(toast, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -160, 0, 14),
    }):Play()
    task.delay(duration, function()
        if not toast.Parent then return end
        local out = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -160, 0, -50),
        })
        out.Completed:Once(function()
            if toast.Parent then toast:Destroy() end
        end)
        out:Play()
    end)
end

local sliderHandlers = {}
local activeSlider = nil

local function wireSlider(track, update)
    sliderHandlers[track] = update
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeSlider = track
            update(input)
        end
    end)
    track.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if activeSlider == track then update(input) end
        end
    end)
end

UserInputService.InputChanged:Connect(function(input)
    if activeSlider then
        local m = input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
        if m then
            local handler = sliderHandlers[activeSlider]
            if handler then handler(input) end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        activeSlider = nil
    end
end)

local function makeSliderTrack(card, y, name)
    local track = create("TextButton", {
        Name = name .. "Track",
        Size = UDim2.new(1, -28, 0, 4),
        Position = UDim2.new(0, 14, 0, y),
        BackgroundColor3 = C.SLIDER_TRK,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, card)
    create("UICorner", { CornerRadius = UDim.new(1, 0) }, track)
    local fill = create("Frame", {
        Name = name .. "Fill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = (name == "Intensity" and C.INTENSITY) or C.SLIDER_FIL,
        BorderSizePixel = 0,
    }, track)
    create("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)
    local handle = create("Frame", {
        Name = name .. "Handle",
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, -7, 0.5, -7),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = C.TEXT,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, track)
    create("UICorner", { CornerRadius = UDim.new(1, 0) }, handle)
    return track, fill, handle
end

local function SetupSlider(sliderFrame, fillFrame, valueLabel, config, property, isDelay)
    local function apply(percent)
        percent = math.clamp(percent, 0, 1)
        fillFrame.Size = UDim2.new(percent, 0, 1, 0)
        local handle = nil
        for _, child in ipairs(sliderFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("Handle$") then
                handle = child
                break
            end
        end
        if handle then
            handle.Position = UDim2.new(percent, 0, 0.5, 0)
        end
        if property == "Intensity" then
            local value = 1 + math.floor(percent * 9)
            config[property] = value
            valueLabel.Text = "Intensity: " .. value .. "x"
        elseif isDelay then
            local value = 0.1 + percent * 9.9
            config[property] = value
            valueLabel.Text = string.format("Delay: %.1fs", value)
        else
            local value = 0.01 + percent * 0.99
            config[property] = value
            valueLabel.Text = string.format("Speed: %.2fs", value)
        end
    end
    local function update(input)
        local sizeX = sliderFrame.AbsoluteSize.X
        if sizeX <= 0 then return end
        local percent = (input.Position.X - sliderFrame.AbsolutePosition.X) / sizeX
        apply(percent)
    end
    wireSlider(sliderFrame, update)
    if property == "Intensity" then
        apply(((config[property] or 1) - 1) / 9)
    elseif isDelay then
        apply(((config[property] or 1) - 0.1) / 9.9)
    else
        apply(((config[property] or 0.5) - 0.01) / 0.99)
    end
    return apply
end

local function SetupIntensitySlider(sliderFrame, fillFrame, valueLabel, config)
    SetupSlider(sliderFrame, fillFrame, valueLabel, config, "Intensity", false)
end

local function SetupToggleButton(button, config)
    local function refresh()
        local on = config.Enabled
        button.Text = on and "ON" or "OFF"
        button.TextColor3 = on and C.TEXT or C.SUBTEXT
        TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = on and C.ACCENT or C.BTN_OFF,
        }):Play()
    end
    button.Activated:Connect(function()
        config.Enabled = not config.Enabled
        refresh()
        showToast(gui, (config.DisplayName or "Toggle") .. (config.Enabled and " enabled" or " disabled"), config.Enabled and C.ACCENT2 or C.SUBTEXT, 1.5)
    end)
    refresh()
end

local cardOrder = 0

local function CreateToggleCard(displayName, config, hasIntensity)
    cardOrder = cardOrder + 1
    local h = hasIntensity and 118 or 84

    local Card = create("Frame", {
        Name = "Card_" .. (config.DisplayName or displayName):gsub("%s+", ""),
        Size = UDim2.new(1, 0, 0, h),
        LayoutOrder = cardOrder,
        BackgroundColor3 = C.CARD,
        BorderSizePixel = 0,
    }, MainPage)
    create("UICorner", { CornerRadius = UDim.new(0, 8) }, Card)
    create("UIStroke", { Thickness = 1, Color = C.CARD_BORDER }, Card)

    create("TextLabel", {
        Name = "Name",
        Size = UDim2.new(1, -88, 0, 20),
        Position = UDim2.new(0, 14, 0, 10),
        BackgroundTransparency = 1,
        Text = displayName,
        Font = FONT_BOLD,
        TextSize = 16,
        TextColor3 = C.TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Card)

    local ToggleButton = create("TextButton", {
        Name = "Toggle",
        Size = UDim2.fromOffset(60, 24),
        Position = UDim2.new(1, -74, 0, 8),
        BackgroundColor3 = C.BTN_OFF,
        Text = "OFF",
        Font = FONT_BOLD,
        TextSize = 12,
        TextColor3 = C.SUBTEXT,
        AutoButtonColor = false,
    }, Card)
    create("UICorner", { CornerRadius = UDim.new(0, 6) }, ToggleButton)

    local SpeedValue = create("TextLabel", {
        Name = "SpeedValue",
        Size = UDim2.new(1, -30, 0, 16),
        Position = UDim2.new(0, 14, 0, 34),
        BackgroundTransparency = 1,
        Text = "",
        Font = FONT_REG,
        TextSize = 13,
        TextColor3 = C.SUBTEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Card)

    local SpeedSlider, SpeedFill, SpeedButton = makeSliderTrack(Card, hasIntensity and 52 or 56, "Speed")
    local IntensitySlider, IntensityFill, IntensityValue = nil, nil, nil

    if hasIntensity then
        IntensityValue = create("TextLabel", {
            Name = "IntensityValue",
            Size = UDim2.new(1, -30, 0, 16),
            Position = UDim2.new(0, 14, 0, 66),
            BackgroundTransparency = 1,
            Text = "",
            Font = FONT_REG,
            TextSize = 13,
            TextColor3 = C.SUBTEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, Card)
        IntensitySlider, IntensityFill = makeSliderTrack(Card, 86, "Intensity")
    end

    if hasIntensity then
        SetupSlider(SpeedSlider, SpeedFill, SpeedValue, config, "Speed", false)
        SetupIntensitySlider(IntensitySlider, IntensityFill, IntensityValue, config)
    else
        SetupSlider(SpeedSlider, SpeedFill, SpeedValue, config, "Delay", true)
    end
    SetupToggleButton(ToggleButton, config)

    return {
        Card = Card,
        ToggleButton = ToggleButton,
        SpeedSlider = SpeedSlider,
        SpeedFill = SpeedFill,
        SpeedButton = SpeedButton,
        SpeedValue = SpeedValue,
        IntensitySlider = IntensitySlider,
        IntensityFill = IntensityFill,
        IntensityValue = IntensityValue,
        Config = config,
    }
end

local infoOrder = 0

local function addInfoCard(title, lines)
    infoOrder = infoOrder + 1
    local h = 12 + (title and 24 or 0) + 4 + #lines * 20 + 12
    local card = create("Frame", {
        Name = "InfoCard_" .. infoOrder,
        Size = UDim2.new(1, 0, 0, h),
        LayoutOrder = infoOrder,
        BackgroundColor3 = C.CARD,
        BorderSizePixel = 0,
    }, InfoPage)
    create("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
    create("UIStroke", { Thickness = 1, Color = C.CARD_BORDER }, card)
    local y = 12
    if title then
        create("TextLabel", {
            Size = UDim2.new(1, -28, 0, 24),
            Position = UDim2.new(0, 14, 0, y),
            BackgroundTransparency = 1,
            Text = title,
            Font = FONT_BOLD,
            TextSize = 16,
            TextColor3 = C.TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)
        y = y + 24 + 4
    end
    for _, lineText in ipairs(lines) do
        create("TextLabel", {
            Size = UDim2.new(1, -28, 0, 20),
            Position = UDim2.new(0, 14, 0, y),
            BackgroundTransparency = 1,
            Text = lineText,
            Font = FONT_REG,
            TextSize = 13,
            TextColor3 = C.SUBTEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)
        y = y + 20
    end
end

addInfoCard("🌙 Moon Incremental", {
    "Version " .. VERSION .. " · by NVHeadMonbo",
    "Automation & quality-of-life for the Moon Incremental experience.",
})
addInfoCard("Features", {
    "Stars — mines star stats (speed + intensity)",
    "Essence — mines essence stats (speed + intensity)",
    "Fragments — mines rock fragments (speed + intensity)",
    "Smelt Scrap — deposits scrap into the smelter (delay)",
    "Smelt Collect — collects smelted materials (delay)",
    "Diamonds — collects from the mineshaft (delay)",
})
addInfoCard("Notes", {
    "Press K to show or hide this window.",
    "Loaded post-verification by the MonboVerse Library Hub.",
    "This script contains no key-system code — verification is central.",
    "Repository: MonboSoNasty/RobloxScriptz",
})

makeNavBtn("Main", 0, 8, "Main")
makeNavBtn("Info", 0.5, 4, "Info")
switchPage("Main")

local minimized = false
MinimizeBtn.Activated:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.fromOffset(WINDOW_W, MINI_HEIGHT) or UDim2.fromOffset(WINDOW_W, FULL_HEIGHT)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
        Size = targetSize,
    }):Play()
    NavBar.Visible = not minimized
    ContentArea.Visible = not minimized
    MinimizeBtn.Text = minimized and "□" or "—"
end)

local dragging = false
local dragStart = Vector2.zero
local startPos = MainFrame.Position

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        local mbPos = MinimizeBtn.AbsolutePosition
        local mbSize = MinimizeBtn.AbsoluteSize
        local onBtn = pos.X >= mbPos.X and pos.X <= mbPos.X + mbSize.X and pos.Y >= mbPos.Y and pos.Y <= mbPos.Y + mbSize.Y
        if not onBtn then
            dragging = true
            dragStart = pos
            startPos = MainFrame.Position
        end
    end
end)

local dragConn = UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        activeSlider = nil
    end
end)

local kConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        gui.Enabled = not gui.Enabled
    end
end)

local function getRemote(name)
    local r = ReplicatedStorage:FindFirstChild(name)
    if not r then
        local ok, found = pcall(function()
            return ReplicatedStorage:WaitForChild(name, 5)
        end)
        if ok and found then r = found end
    end
    return r
end

local StarsFire = function()
    local r = getRemote("UpdateStarStat")
    if r then r:FireServer(Vector3.new(-221.68, 5.27, -17.19)) end
end
local EssenceFire = function()
    local r = getRemote("UpdateEssenceStat")
    if r then r:FireServer(Vector3.new(-200, 9.51, -35), true) end
end
local FragmentsFire = function()
    local cave = workspace:FindFirstChild("Cave")
    local ore = cave and cave:FindFirstChild("Ore_9217932433")
    if ore then
        local r = getRemote("MineRock")
        if r then r:FireServer(ore) end
    end
end
local SmeltScrapFire = function()
    local r = getRemote("SmeltDeposit")
    if r then r:FireServer() end
end
local SmeltCollectFire = function()
    local r = getRemote("SmeltCollect")
    if r then r:FireServer() end
end
local DiamondsFire = function()
    local r = getRemote("MineshaftCollect")
    if r then r:FireServer() end
end

local Stars = CreateToggleCard("Stars", { DisplayName = "Stars", Enabled = false, Speed = 0.5, Intensity = 1, Fire = StarsFire }, true)
local Essence = CreateToggleCard("Essence", { DisplayName = "Essence", Enabled = false, Speed = 0.5, Intensity = 1, Fire = EssenceFire }, true)
local Fragments = CreateToggleCard("Fragments", { DisplayName = "Fragments", Enabled = false, Speed = 0.5, Intensity = 1, Fire = FragmentsFire }, true)
local SmeltScrap = CreateToggleCard("Smelt Scrap", { DisplayName = "Smelt Scrap", Enabled = false, Delay = 1, Fire = SmeltScrapFire }, false)
local SmeltCollect = CreateToggleCard("Smelt Collect", { DisplayName = "Smelt Collect", Enabled = false, Delay = 1, Fire = SmeltCollectFire }, false)
local Diamonds = CreateToggleCard("Diamonds", { DisplayName = "Diamonds", Enabled = false, Delay = 1, Fire = DiamondsFire }, false)

local toggles = {
    Stars.Config,
    Essence.Config,
    Fragments.Config,
    SmeltScrap.Config,
    SmeltCollect.Config,
    Diamonds.Config,
}

local LastRun = {}

local heartbeat = RunService.Heartbeat:Connect(function(dt)
    RainbowGrad.Rotation = (RainbowGrad.Rotation + dt * 40) % 360

    local now = os.clock()
    for _, t in ipairs(toggles) do
        if t.Enabled and t.Fire then
            local interval = t.Delay or t.Speed or 0.5
            local last = LastRun[t]
            if not last or (now - last) >= interval then
                LastRun[t] = now
                task.spawn(function()
                    local ok, err = pcall(t.Fire)
                    if not ok then
                        warn("[Moon Incremental] remote error: " .. tostring(err))
                    end
                end)
            end
        end
    end
end)

gui.Destroying:Connect(function()
    kConn:Disconnect()
    dragConn:Disconnect()
    heartbeat:Disconnect()
end)

task.delay(0.5, function()
    if gui and gui.Parent then
        showToast(gui, "Moon Incremental v2.0 loaded", C.ACCENT2, 3)
    end
end)
print("[Moon Incremental v2.0] Loaded — Press K to toggle UI")
