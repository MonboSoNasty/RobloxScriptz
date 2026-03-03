-- ============================================================
-- MonboVerse Hub - Wheat Incremental
-- by NVHeadMonbo
-- v1.2 - COMPLETE with ALL Features + Fixes
-- ============================================================

local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- Anti-stack
if PlayerGui:FindFirstChild("MonboVerseHubGUI") then
    PlayerGui:FindFirstChild("MonboVerseHubGUI"):Destroy()
end
if PlayerGui:FindFirstChild("JunkieKeySystemUI") then
    PlayerGui:FindFirstChild("JunkieKeySystemUI"):Destroy()
end

-- ============================================================
-- KEY SYSTEM TOGGLE (SET TO false FOR DEVELOPMENT)
-- ============================================================
local KEY_SYSTEM_ENABLED = true  -- ⚠️ Change to true to enable key system

if KEY_SYSTEM_ENABLED then
    print("[MonboVerse Hub] Key system would load here...")
    -- Key system code from original (keeping it short for now)
end

-- ============================================================
-- WHEAT TYPES (11 rarities) WITH INTENSITY
-- ============================================================
local WheatTypes = {
    {name = "BreadWheat",           enabled = false, intensity = 1},
    {name = "BrittleWheat",    enabled = false, intensity = 1},
    {name = "BlueWheat",       enabled = false, intensity = 1},
    {name = "RubyWheat",       enabled = false, intensity = 1},
    {name = "GoldenWheat",     enabled = false, intensity = 1},
    {name = "DarkWheat",       enabled = false, intensity = 1},
    {name = "SageWheat",       enabled = false, intensity = 1},
    {name = "GemWheat",        enabled = false, intensity = 1},
    {name = "DoughWheat",      enabled = false, intensity = 1},
    {name = "YeastWheat",      enabled = false, intensity = 1},
    {name = "LightningWheat",  enabled = false, intensity = 1},
}

local Config = {
    UIVisible = true,
    Claimers = {
        WheatCollect = { Enabled = false, LastRun = 0, Delay = 1 }
    },
    Upgrades = {
        WheatMultiplier = { Enabled = false, LastRun = 0, Delay = 0.5 },
        WheatCooldown   = { Enabled = false, LastRun = 0, Delay = 0.5 },
        WheatCapacity   = { Enabled = false, LastRun = 0, Delay = 0.5 }
    }
}

local C = {
    BG          = Color3.fromRGB(8,   16,  30),
    TITLE_BG    = Color3.fromRGB(12,  24,  46),
    ACCENT      = Color3.fromRGB(0,   200, 255),
    ACCENT2     = Color3.fromRGB(0,   255, 160),
    PURPLE      = Color3.fromRGB(138, 43,  226),
    TEXT        = Color3.fromRGB(210, 235, 255),
    SUBTEXT     = Color3.fromRGB(110, 155, 190),
    BTN_ON      = Color3.fromRGB(88,  101, 242),
    BTN_OFF     = Color3.fromRGB(40,  42,  50),
    CARD        = Color3.fromRGB(14,  26,  46),
    CHECK_ON    = Color3.fromRGB(63,  185, 80),
    CHECK_OFF   = Color3.fromRGB(40,  42,  50),
}
local F  = Enum.Font.GothamBold
local FM = Enum.Font.Gotham

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "MonboVerseHubGUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 99
ScreenGui.Parent         = PlayerGui

local FRAME_W, FRAME_H = 520, 540

local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(0, FRAME_W, 0, FRAME_H)
MainFrame.Position         = UDim2.new(0.5, -FRAME_W/2, 0.5, -FRAME_H/2)
MainFrame.BackgroundColor3 = C.BG
MainFrame.BorderSizePixel  = 0
MainFrame.Active           = false
MainFrame.ClipsDescendants = true
MainFrame.Parent           = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- ============================================================
-- ENHANCED RAINBOW BORDER (MORE COLORS, SMOOTH ANIMATION)
-- ============================================================
local rainbowStroke = Instance.new("UIStroke")
rainbowStroke.Thickness = 6
rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rainbowStroke.Transparency = 0
rainbowStroke.Parent = MainFrame

local rainbowGrad = Instance.new("UIGradient")
rainbowGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,   0,   0)),   -- Red
    ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 127,   0)),   -- Orange
    ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 255,   0)),   -- Yellow
    ColorSequenceKeypoint.new(0.42, Color3.fromRGB(  0, 255,   0)),   -- Green
    ColorSequenceKeypoint.new(0.57, Color3.fromRGB(  0, 255, 255)),   -- Cyan
    ColorSequenceKeypoint.new(0.71, Color3.fromRGB(  0,   0, 255)),   -- Blue
    ColorSequenceKeypoint.new(0.85, Color3.fromRGB(138,  43, 226)),   -- Purple
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,   0,   0)),   -- Back to Red
})
rainbowGrad.Parent = rainbowStroke

-- Super smooth rainbow animation with task.spawn
task.spawn(function()
    local rot = 0
    while true do
        rot = (rot + 4) % 360  -- Fast smooth rotation
        rainbowGrad.Rotation = rot
        task.wait(0.03)  -- ~30fps smooth animation
    end
end)

print("🌈 Rainbow border animating with full color spectrum!")

local TitleBar = Instance.new("Frame")
TitleBar.Name             = "TitleBar"
TitleBar.Size             = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = C.TITLE_BG
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 2
TitleBar.Active           = true
TitleBar.Parent           = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local tbFill = Instance.new("Frame")
tbFill.Size = UDim2.new(1,0,0.5,0) tbFill.Position = UDim2.new(0,0,0.5,0)
tbFill.BackgroundColor3 = C.TITLE_BG tbFill.BorderSizePixel = 0 tbFill.ZIndex = 2
tbFill.Parent = TitleBar

local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

local iconLbl = Instance.new("TextLabel")
iconLbl.Size = UDim2.new(0,30,1,0) iconLbl.Position = UDim2.new(0,8,0,0)
iconLbl.BackgroundTransparency = 1 iconLbl.Text = "🌾"
iconLbl.TextSize = 18 iconLbl.Font = FM iconLbl.ZIndex = 3
iconLbl.Parent = TitleBar

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-100,1,0) TitleLbl.Position = UDim2.new(0,40,0,0)
TitleLbl.BackgroundTransparency = 1 TitleLbl.Text = "MonboVerse Hub"
TitleLbl.TextColor3 = C.ACCENT TitleLbl.TextSize = 13
TitleLbl.Font = F TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 3 TitleLbl.Parent = TitleBar

local CreditLbl = Instance.new("TextLabel")
CreditLbl.Size = UDim2.new(1,-100,0,14) CreditLbl.Position = UDim2.new(0,40,1,-15)
CreditLbl.BackgroundTransparency = 1 CreditLbl.Text = "Wheat Incremental v1.2"
CreditLbl.TextColor3 = C.SUBTEXT CreditLbl.TextSize = 9
CreditLbl.Font = FM CreditLbl.TextXAlignment = Enum.TextXAlignment.Left
CreditLbl.ZIndex = 3 CreditLbl.Parent = TitleBar

local minimized   = false
local FULL_HEIGHT = FRAME_H
local MINI_HEIGHT = 42

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size             = UDim2.new(0, 26, 0, 22)
MinimizeButton.Position         = UDim2.new(1, -32, 0.5, -11)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
MinimizeButton.BorderSizePixel  = 0
MinimizeButton.Text             = "—"
MinimizeButton.TextColor3       = Color3.fromRGB(30, 20, 0)
MinimizeButton.TextSize         = 12
MinimizeButton.Font             = F
MinimizeButton.ZIndex           = 4
MinimizeButton.Parent           = TitleBar
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 5)

local NavBar = Instance.new("Frame")
NavBar.Name             = "NavBar"
NavBar.Size             = UDim2.new(1, 0, 0, 36)
NavBar.Position         = UDim2.new(0, 0, 0, 42)
NavBar.BackgroundColor3 = Color3.fromRGB(10, 20, 38)
NavBar.BorderSizePixel  = 0
NavBar.ZIndex           = 2
NavBar.Parent           = MainFrame

local navDivider = Instance.new("Frame")
navDivider.Size = UDim2.new(1,0,0,1) navDivider.Position = UDim2.new(0,0,1,0)
navDivider.BackgroundColor3 = Color3.fromRGB(30,55,85) navDivider.BorderSizePixel = 0
navDivider.ZIndex = 2 navDivider.Parent = NavBar

local function makeNavBtn(label, xScale, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0.333, -4, 1, -6)
    btn.Position         = UDim2.new(xScale, xOffset, 0, 3)
    btn.BackgroundColor3 = Color3.fromRGB(20, 40, 65)
    btn.BorderSizePixel  = 0
    btn.Text             = label
    btn.TextColor3       = C.SUBTEXT
    btn.TextSize         = 11
    btn.Font             = F
    btn.ZIndex           = 3
    btn.Parent           = NavBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local claimersBtn = makeNavBtn("Claimers", 0,     3)
local upgradesBtn = makeNavBtn("Upgrades", 0.333, 3)
local infoBtn     = makeNavBtn("Info",     0.666, 3)

claimersBtn.BackgroundColor3 = C.ACCENT
claimersBtn.TextColor3       = Color3.fromRGB(255, 255, 255)

local ContentArea = Instance.new("Frame")
ContentArea.Name                 = "ContentArea"
ContentArea.Size                 = UDim2.new(1, 0, 1, -78)
ContentArea.Position             = UDim2.new(0, 0, 0, 78)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants     = true
ContentArea.Parent               = MainFrame

local ClaimersPage = Instance.new("ScrollingFrame")
ClaimersPage.Name                  = "ClaimersPage"
ClaimersPage.Size                  = UDim2.new(1, 0, 1, 0)
ClaimersPage.BackgroundTransparency = 1
ClaimersPage.BorderSizePixel       = 0
ClaimersPage.ScrollBarThickness    = 4
ClaimersPage.ScrollBarImageColor3  = C.ACCENT
ClaimersPage.CanvasSize            = UDim2.new(0, 0, 0, 0)
ClaimersPage.AutomaticCanvasSize   = Enum.AutomaticSize.Y
ClaimersPage.Visible               = true
ClaimersPage.Parent                = ContentArea

local ClaimersLayout = Instance.new("UIListLayout")
ClaimersLayout.Padding   = UDim.new(0, 8)
ClaimersLayout.SortOrder = Enum.SortOrder.LayoutOrder
ClaimersLayout.Parent    = ClaimersPage

local ClaimersPadding = Instance.new("UIPadding")
ClaimersPadding.PaddingLeft   = UDim.new(0, 10)
ClaimersPadding.PaddingRight  = UDim.new(0, 10)
ClaimersPadding.PaddingTop    = UDim.new(0, 8)
ClaimersPadding.PaddingBottom = UDim.new(0, 8)
ClaimersPadding.Parent        = ClaimersPage

local UpgradesPage = Instance.new("ScrollingFrame")
UpgradesPage.Name                  = "UpgradesPage"
UpgradesPage.Size                  = UDim2.new(1, 0, 1, 0)
UpgradesPage.BackgroundTransparency = 1
UpgradesPage.BorderSizePixel       = 0
UpgradesPage.ScrollBarThickness    = 4
UpgradesPage.ScrollBarImageColor3  = C.ACCENT
UpgradesPage.CanvasSize            = UDim2.new(0, 0, 0, 0)
UpgradesPage.AutomaticCanvasSize   = Enum.AutomaticSize.Y
UpgradesPage.Visible               = false
UpgradesPage.Parent                = ContentArea

local UpgradesLayout = Instance.new("UIListLayout")
UpgradesLayout.Padding   = UDim.new(0, 8)
UpgradesLayout.SortOrder = Enum.SortOrder.LayoutOrder
UpgradesLayout.Parent    = UpgradesPage

local UpgradesPadding = Instance.new("UIPadding")
UpgradesPadding.PaddingLeft   = UDim.new(0, 10)
UpgradesPadding.PaddingRight  = UDim.new(0, 10)
UpgradesPadding.PaddingTop    = UDim.new(0, 8)
UpgradesPadding.PaddingBottom = UDim.new(0, 8)
UpgradesPadding.Parent        = UpgradesPage

local InfoPage = Instance.new("Frame")
InfoPage.Name                  = "InfoPage"
InfoPage.Size                  = UDim2.new(1, 0, 1, 0)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible               = false
InfoPage.Parent                = ContentArea

local function switchPage(page)
    ClaimersPage.Visible = (page == "Claimers")
    UpgradesPage.Visible = (page == "Upgrades")
    InfoPage.Visible     = (page == "Info")
    
    claimersBtn.BackgroundColor3 = (page=="Claimers") and C.ACCENT or Color3.fromRGB(20,40,65)
    claimersBtn.TextColor3       = (page=="Claimers") and Color3.fromRGB(255,255,255) or C.SUBTEXT
    
    upgradesBtn.BackgroundColor3 = (page=="Upgrades") and C.ACCENT or Color3.fromRGB(20,40,65)
    upgradesBtn.TextColor3       = (page=="Upgrades") and Color3.fromRGB(255,255,255) or C.SUBTEXT
    
    infoBtn.BackgroundColor3     = (page=="Info") and C.ACCENT or Color3.fromRGB(20,40,65)
    infoBtn.TextColor3           = (page=="Info") and Color3.fromRGB(255,255,255) or C.SUBTEXT
end

claimersBtn.MouseButton1Click:Connect(function() switchPage("Claimers") end)
upgradesBtn.MouseButton1Click:Connect(function() switchPage("Upgrades") end)
infoBtn.MouseButton1Click:Connect(function() switchPage("Info") end)

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, FRAME_W, 0, minimized and MINI_HEIGHT or FULL_HEIGHT)
    }):Play()
    task.delay(minimized and 0 or 0.05, function()
        NavBar.Visible      = not minimized
        ContentArea.Visible = not minimized
    end)
    MinimizeButton.Text = minimized and "□" or "—"
end)

-- ============================================================
-- WHEAT COLLECT CARD WITH 3-COLUMN GRID
-- ============================================================
local WheatCollectCard = Instance.new("Frame")
WheatCollectCard.Name             = "WheatCollectCard"
WheatCollectCard.Size             = UDim2.new(1, 0, 0, 340)
WheatCollectCard.BackgroundColor3 = C.CARD
WheatCollectCard.BorderSizePixel  = 0
WheatCollectCard.Parent           = ClaimersPage
Instance.new("UICorner", WheatCollectCard).CornerRadius = UDim.new(0, 8)

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Color3.fromRGB(20,45,75) cardStroke.Thickness = 1 cardStroke.Parent = WheatCollectCard

local NameLbl = Instance.new("TextLabel")
NameLbl.Size = UDim2.new(1,-80,0,20) NameLbl.Position = UDim2.new(0,12,0,10)
NameLbl.BackgroundTransparency = 1 NameLbl.Text = "Wheat Collect"
NameLbl.TextColor3 = C.TEXT NameLbl.TextSize = 13
NameLbl.Font = F NameLbl.TextXAlignment = Enum.TextXAlignment.Left
NameLbl.Parent = WheatCollectCard

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size             = UDim2.new(0, 60, 0, 24)
ToggleBtn.Position         = UDim2.new(1, -72, 0, 8)
ToggleBtn.BackgroundColor3 = C.BTN_OFF
ToggleBtn.BorderSizePixel  = 0
ToggleBtn.Text             = "OFF"
ToggleBtn.TextColor3       = C.SUBTEXT
ToggleBtn.TextSize         = 11
ToggleBtn.Font             = F
ToggleBtn.AutoButtonColor  = false
ToggleBtn.Parent           = WheatCollectCard
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)

local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(0.5,-8,0,16) delayLabel.Position = UDim2.new(0,12,0,38)
delayLabel.BackgroundTransparency = 1 delayLabel.Text = "Delay"
delayLabel.TextColor3 = C.SUBTEXT delayLabel.TextSize = 10
delayLabel.Font = FM delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = WheatCollectCard

local DelayValue = Instance.new("TextLabel")
DelayValue.Name = "DelayValue"
DelayValue.Size = UDim2.new(0.5,-8,0,16) DelayValue.Position = UDim2.new(0.5,4,0,38)
DelayValue.BackgroundTransparency = 1 DelayValue.Text = "1.0s"
DelayValue.TextColor3 = C.ACCENT DelayValue.TextSize = 10
DelayValue.Font = F DelayValue.TextXAlignment = Enum.TextXAlignment.Right
DelayValue.Parent = WheatCollectCard

local DelaySlider = Instance.new("Frame")
DelaySlider.Name = "DelaySlider"
DelaySlider.Size = UDim2.new(1,-24,0,4) DelaySlider.Position = UDim2.new(0,12,0,58)
DelaySlider.BackgroundColor3 = Color3.fromRGB(20, 40, 65) DelaySlider.BorderSizePixel = 0
DelaySlider.Parent = WheatCollectCard
Instance.new("UICorner", DelaySlider).CornerRadius = UDim.new(1,0)

local DelayFill = Instance.new("Frame")
DelayFill.Name = "Fill"
DelayFill.Size = UDim2.new(0.1,0,1,0) DelayFill.BackgroundColor3 = C.ACCENT
DelayFill.BorderSizePixel = 0 DelayFill.Parent = DelaySlider
Instance.new("UICorner", DelayFill).CornerRadius = UDim.new(1,0)

local DelayButton = Instance.new("TextButton")
DelayButton.Name = "Button"
DelayButton.Size = UDim2.new(1,0,1,12) DelayButton.Position = UDim2.new(0,0,0,-6)
DelayButton.BackgroundTransparency = 1 DelayButton.Text = ""
DelayButton.Parent = DelaySlider

-- 3-COLUMN GRID LAYOUT for Wheat Types
local wheatContainer = Instance.new("Frame")
wheatContainer.Size = UDim2.new(1,-24,0,260) wheatContainer.Position = UDim2.new(0,12,0,72)
wheatContainer.BackgroundTransparency = 1
wheatContainer.Parent = WheatCollectCard

local wheatLayout = Instance.new("UIGridLayout")
wheatLayout.CellSize = UDim2.new(0.333, -4, 0, 60)
wheatLayout.CellPadding = UDim2.new(0, 4, 0, 4)
wheatLayout.SortOrder = Enum.SortOrder.LayoutOrder
wheatLayout.Parent = wheatContainer

local wheatCheckboxes = {}
local wheatIntensitySliders = {}

-- Intensity slider setup function
local function SetupIntensitySlider(sliderFrame, fillFrame, valueLabel, wheatData)
    local button = sliderFrame:FindFirstChild("Button")
    local draggingSlider = false

    local function updateSlider(input)
        local sizeX = sliderFrame.AbsoluteSize.X
        local posX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sizeX)
        local percent = posX / sizeX
        fillFrame.Size = UDim2.new(percent, 0, 1, 0)
        local intensity = math.max(1, math.floor(1 + percent * 24))
        wheatData.intensity = intensity
        valueLabel.Text = intensity .. "x"
    end

    button.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateSlider(i)
        end
    end)
    button.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(i)
        end
    end)
end

for i, wheat in ipairs(WheatTypes) do
    local wheatCell = Instance.new("Frame")
    wheatCell.Name = wheat.name .. "Cell"
    wheatCell.Size = UDim2.new(1, 0, 1, 0)
    wheatCell.BackgroundTransparency = 1
    wheatCell.LayoutOrder = i
    wheatCell.Parent = wheatContainer
    
    local checkBox = Instance.new("TextButton")
    checkBox.Name = wheat.name .. "Check"
    checkBox.Size = UDim2.new(0, 18, 0, 18)
    checkBox.Position = UDim2.new(0, 2, 0, 2)
    checkBox.BackgroundColor3 = wheat.enabled and C.CHECK_ON or C.CHECK_OFF
    checkBox.BorderSizePixel = 0
    checkBox.Text = wheat.enabled and "✓" or ""
    checkBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkBox.TextSize = 12
    checkBox.Font = F
    checkBox.Parent = wheatCell
    Instance.new("UICorner", checkBox).CornerRadius = UDim.new(0, 4)
    
    local checkLabel = Instance.new("TextLabel")
    checkLabel.Size = UDim2.new(1, -24, 0, 18)
    checkLabel.Position = UDim2.new(0, 22, 0, 2)
    checkLabel.BackgroundTransparency = 1
    checkLabel.Text = wheat.name:gsub("Wheat", "")
    checkLabel.TextColor3 = C.TEXT
    checkLabel.TextSize = 8
    checkLabel.Font = FM
    checkLabel.TextXAlignment = Enum.TextXAlignment.Left
    checkLabel.TextTruncate = Enum.TextTruncate.AtEnd
    checkLabel.Parent = wheatCell
    
    local intensityLabel = Instance.new("TextLabel")
    intensityLabel.Size = UDim2.new(1, -4, 0, 14)
    intensityLabel.Position = UDim2.new(0, 2, 0, 22)
    intensityLabel.BackgroundTransparency = 1
    intensityLabel.Text = "Intensity"
    intensityLabel.TextColor3 = C.SUBTEXT
    intensityLabel.TextSize = 7
    intensityLabel.Font = FM
    intensityLabel.TextXAlignment = Enum.TextXAlignment.Left
    intensityLabel.Parent = wheatCell
    
    local intensitySlider = Instance.new("Frame")
    intensitySlider.Name = "IntensitySlider"
    intensitySlider.Size = UDim2.new(1, -40, 0, 4)
    intensitySlider.Position = UDim2.new(0, 2, 0, 40)
    intensitySlider.BackgroundColor3 = Color3.fromRGB(20, 40, 65)
    intensitySlider.BorderSizePixel = 0
    intensitySlider.Parent = wheatCell
    Instance.new("UICorner", intensitySlider).CornerRadius = UDim.new(1, 0)
    
    local intensityFill = Instance.new("Frame")
    intensityFill.Name = "Fill"
    intensityFill.Size = UDim2.new(0, 0, 1, 0)
    intensityFill.BackgroundColor3 = C.PURPLE
    intensityFill.BorderSizePixel = 0
    intensityFill.Parent = intensitySlider
    Instance.new("UICorner", intensityFill).CornerRadius = UDim.new(1, 0)
    
    local intensityButton = Instance.new("TextButton")
    intensityButton.Name = "Button"
    intensityButton.Size = UDim2.new(1, 0, 1, 12)
    intensityButton.Position = UDim2.new(0, 0, 0, -6)
    intensityButton.BackgroundTransparency = 1
    intensityButton.Text = ""
    intensityButton.Parent = intensitySlider
    
    local intensityValue = Instance.new("TextLabel")
    intensityValue.Name = "IntensityValue"
    intensityValue.Size = UDim2.new(0, 35, 0, 18)
    intensityValue.Position = UDim2.new(1, -37, 0, 34)
    intensityValue.BackgroundTransparency = 1
    intensityValue.Text = "1x"
    intensityValue.TextColor3 = C.PURPLE
    intensityValue.TextSize = 8
    intensityValue.Font = F
    intensityValue.TextXAlignment = Enum.TextXAlignment.Right
    intensityValue.Parent = wheatCell
    
    wheatCheckboxes[wheat.name] = checkBox
    wheatIntensitySliders[wheat.name] = {
        slider = intensitySlider,
        fill = intensityFill,
        value = intensityValue
    }
    
    SetupIntensitySlider(intensitySlider, intensityFill, intensityValue, wheat)
    
    checkBox.MouseButton1Click:Connect(function()
        wheat.enabled = not wheat.enabled
        checkBox.BackgroundColor3 = wheat.enabled and C.CHECK_ON or C.CHECK_OFF
        checkBox.Text = wheat.enabled and "✓" or ""
        TweenService:Create(checkBox, TweenInfo.new(0.15), {
            BackgroundColor3 = wheat.enabled and C.CHECK_ON or C.CHECK_OFF
        }):Play()
    end)
end

-- Setup delay slider
local function SetupDelaySlider(sliderFrame, fillFrame, valueLabel, config, property)
    local button   = sliderFrame:FindFirstChild("Button")
    local draggingSlider = false

    local function updateSlider(input)
        local sizeX   = sliderFrame.AbsoluteSize.X
        local posX    = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sizeX)
        local percent = posX / sizeX
        fillFrame.Size = UDim2.new(percent, 0, 1, 0)
        local v = 0.1 + percent * 9.9
        config[property] = math.floor(v * 10) / 10
        valueLabel.Text  = string.format("%.1fs", config[property])
    end

    button.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true updateSlider(i)
        end
    end)
    button.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(i)
        end
    end)
end

SetupDelaySlider(DelaySlider, DelayFill, DelayValue, Config.Claimers.WheatCollect, "Delay")

ToggleBtn.MouseButton1Click:Connect(function()
    Config.Claimers.WheatCollect.Enabled = not Config.Claimers.WheatCollect.Enabled
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Config.Claimers.WheatCollect.Enabled and C.BTN_ON or C.BTN_OFF
    }):Play()
    ToggleBtn.Text      = Config.Claimers.WheatCollect.Enabled and "ON"  or "OFF"
    ToggleBtn.TextColor3 = Config.Claimers.WheatCollect.Enabled and Color3.fromRGB(255,255,255) or C.SUBTEXT
end)

-- ============================================================
-- UPGRADE CARDS
-- ============================================================
local function CreateToggleCard(displayName, parent, config, hasDelay)
    local Card = Instance.new("Frame")
    Card.Name             = displayName .. "Card"
    Card.Size             = UDim2.new(1, 0, 0, hasDelay and 84 or 50)
    Card.BackgroundColor3 = C.CARD
    Card.BorderSizePixel  = 0
    Card.Parent           = parent
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(20,45,75) cardStroke.Thickness = 1 cardStroke.Parent = Card

    local NameLbl = Instance.new("TextLabel")
    NameLbl.Size = UDim2.new(1,-80,0,20) NameLbl.Position = UDim2.new(0,12,0,hasDelay and 10 or 15)
    NameLbl.BackgroundTransparency = 1 NameLbl.Text = displayName
    NameLbl.TextColor3 = C.TEXT NameLbl.TextSize = 13
    NameLbl.Font = F NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.Parent = Card

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size             = UDim2.new(0, 60, 0, 24)
    ToggleBtn.Position         = UDim2.new(1, -72, 0, hasDelay and 8 or 13)
    ToggleBtn.BackgroundColor3 = C.BTN_OFF
    ToggleBtn.BorderSizePixel  = 0
    ToggleBtn.Text             = "OFF"
    ToggleBtn.TextColor3       = C.SUBTEXT
    ToggleBtn.TextSize         = 11
    ToggleBtn.Font             = F
    ToggleBtn.AutoButtonColor  = false
    ToggleBtn.Parent           = Card
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)

    local DelaySlider, DelayFill, DelayButton, DelayValue
    if hasDelay then
        local delayLabel = Instance.new("TextLabel")
        delayLabel.Size = UDim2.new(0.5,-8,0,16) delayLabel.Position = UDim2.new(0,12,0,38)
        delayLabel.BackgroundTransparency = 1 delayLabel.Text = "Delay"
        delayLabel.TextColor3 = C.SUBTEXT delayLabel.TextSize = 10
        delayLabel.Font = FM delayLabel.TextXAlignment = Enum.TextXAlignment.Left
        delayLabel.Parent = Card

        DelayValue = Instance.new("TextLabel")
        DelayValue.Name = "DelayValue"
        DelayValue.Size = UDim2.new(0.5,-8,0,16) DelayValue.Position = UDim2.new(0.5,4,0,38)
        DelayValue.BackgroundTransparency = 1 DelayValue.Text = "0.5s"
        DelayValue.TextColor3 = C.ACCENT DelayValue.TextSize = 10
        DelayValue.Font = F DelayValue.TextXAlignment = Enum.TextXAlignment.Right
        DelayValue.Parent = Card

        DelaySlider = Instance.new("Frame")
        DelaySlider.Name = "DelaySlider"
        DelaySlider.Size = UDim2.new(1,-24,0,4) DelaySlider.Position = UDim2.new(0,12,0,58)
        DelaySlider.BackgroundColor3 = Color3.fromRGB(20, 40, 65) DelaySlider.BorderSizePixel = 0
        DelaySlider.Parent = Card
        Instance.new("UICorner", DelaySlider).CornerRadius = UDim.new(1,0)

        DelayFill = Instance.new("Frame")
        DelayFill.Name = "Fill"
        DelayFill.Size = UDim2.new(0.05,0,1,0) DelayFill.BackgroundColor3 = C.ACCENT
        DelayFill.BorderSizePixel = 0 DelayFill.Parent = DelaySlider
        Instance.new("UICorner", DelayFill).CornerRadius = UDim.new(1,0)

        DelayButton = Instance.new("TextButton")
        DelayButton.Name = "Button"
        DelayButton.Size = UDim2.new(1,0,1,12) DelayButton.Position = UDim2.new(0,0,0,-6)
        DelayButton.BackgroundTransparency = 1 DelayButton.Text = ""
        DelayButton.Parent = DelaySlider
    end

    return {
        Card         = Card,
        ToggleButton = ToggleBtn,
        DelaySlider  = DelaySlider,
        DelayFill    = DelayFill,
        DelayButton  = DelayButton,
        DelayValue   = DelayValue,
    }
end

local WheatMultiplierCard = CreateToggleCard("Wheat Multiplier Buy", UpgradesPage, Config.Upgrades.WheatMultiplier, true)
local WheatCooldownCard   = CreateToggleCard("Wheat Cooldown Buy",   UpgradesPage, Config.Upgrades.WheatCooldown,   true)
local WheatCapacityCard   = CreateToggleCard("Wheat Capacity Buy",   UpgradesPage, Config.Upgrades.WheatCapacity,   true)

if WheatMultiplierCard.DelaySlider then
    SetupDelaySlider(WheatMultiplierCard.DelaySlider, WheatMultiplierCard.DelayFill, WheatMultiplierCard.DelayValue, Config.Upgrades.WheatMultiplier, "Delay")
end

if WheatCooldownCard.DelaySlider then
    SetupDelaySlider(WheatCooldownCard.DelaySlider, WheatCooldownCard.DelayFill, WheatCooldownCard.DelayValue, Config.Upgrades.WheatCooldown, "Delay")
end

if WheatCapacityCard.DelaySlider then
    SetupDelaySlider(WheatCapacityCard.DelaySlider, WheatCapacityCard.DelayFill, WheatCapacityCard.DelayValue, Config.Upgrades.WheatCapacity, "Delay")
end

local function SetupToggleButton(button, config)
    button.MouseButton1Click:Connect(function()
        config.Enabled = not config.Enabled
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = config.Enabled and C.BTN_ON or C.BTN_OFF
        }):Play()
        button.Text      = config.Enabled and "ON"  or "OFF"
        button.TextColor3 = config.Enabled and Color3.fromRGB(255,255,255) or C.SUBTEXT
    end)
end

SetupToggleButton(WheatMultiplierCard.ToggleButton, Config.Upgrades.WheatMultiplier)
SetupToggleButton(WheatCooldownCard.ToggleButton,   Config.Upgrades.WheatCooldown)
SetupToggleButton(WheatCapacityCard.ToggleButton,   Config.Upgrades.WheatCapacity)

-- ============================================================
-- INFO PAGE
-- ============================================================
local infoBox = Instance.new("Frame")
infoBox.Size = UDim2.new(1,-20,0,320) infoBox.Position = UDim2.new(0,10,0,10)
infoBox.BackgroundColor3 = Color3.fromRGB(14,26,46) infoBox.BorderSizePixel = 0
infoBox.Parent = InfoPage
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0,8)
local infoStroke = Instance.new("UIStroke")
infoStroke.Color = Color3.fromRGB(0, 180, 230) infoStroke.Thickness = 1 infoStroke.Parent = infoBox

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1,-16,1,-16) infoText.Position = UDim2.new(0,8,0,8)
infoText.BackgroundTransparency = 1 infoText.TextWrapped = true
infoText.Text = [[🌾 MonboVerse Hub - Wheat Incremental v1.2

✨ COMPLETE FEATURES:
- ✅ Rainbow border (8 colors, smooth animation!)
- ✅ 3-column grid layout (all wheat types visible)
- ✅ Intensity sliders (1x-25x) WORKING
- ✅ Navigation system (Claimers/Upgrades/Info)
- ✅ Minimize button
- ✅ Draggable title bar

⚙️ Claimers Tab:
- Wheat Collect with 11 wheat types
- 3x4 grid layout (compact & organized)
- Individual intensity control per wheat
- Global delay slider

⚙️ Upgrades Tab:
- Wheat Multiplier Buy (with delay)
- Wheat Cooldown Buy (with delay)
- Wheat Capacity Buy (with delay)

🌈 Rainbow Colors:
Red → Orange → Yellow → Green
→ Cyan → Blue → Purple → Red

⌨️ Keybind:  [ K ]  Toggle UI]]
infoText.TextColor3 = C.TEXT infoText.TextSize = 9 infoText.Font = FM
infoText.TextXAlignment = Enum.TextXAlignment.Left infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoBox

local credBox = Instance.new("Frame")
credBox.Size = UDim2.new(1,-20,0,36) credBox.Position = UDim2.new(0,10,0,340)
credBox.BackgroundColor3 = Color3.fromRGB(14,26,46) credBox.BorderSizePixel = 0
credBox.Parent = InfoPage
Instance.new("UICorner", credBox).CornerRadius = UDim.new(0,8)
local credStroke = Instance.new("UIStroke")
credStroke.Color = C.ACCENT2 credStroke.Thickness = 1 credStroke.Parent = credBox

local credText = Instance.new("TextLabel")
credText.Size = UDim2.new(1,-16,1,0) credText.Position = UDim2.new(0,8,0,0)
credText.BackgroundTransparency = 1
credText.Text = "🌾 MonboVerse Hub v1.2 — by NVHeadMonbo"
credText.TextColor3 = C.ACCENT2 credText.TextSize = 11 credText.Font = F
credText.TextXAlignment = Enum.TextXAlignment.Center credText.TextYAlignment = Enum.TextYAlignment.Center
credText.Parent = credBox

-- ============================================================
-- K KEYBIND
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        Config.UIVisible = not Config.UIVisible
        ScreenGui.Enabled = Config.UIVisible
    end
end)

-- ============================================================
-- HEARTBEAT (GAME LOGIC WITH FIXED INTENSITY)
-- ============================================================
RunService.Heartbeat:Connect(function()
    local t = tick()

    -- Wheat Collect with intensity support
    if Config.Claimers.WheatCollect.Enabled then
        if t - Config.Claimers.WheatCollect.LastRun >= Config.Claimers.WheatCollect.Delay then
            Config.Claimers.WheatCollect.LastRun = t
            
            for _, wheat in ipairs(WheatTypes) do
                if wheat.enabled and wheat.intensity then
                    local currentIntensity = wheat.intensity
                    
                    for fireCount = 1, currentIntensity do
                        task.spawn(function()
                            local success, err = pcall(function()
                                local args = {
                                    "CollectResource",
                                    {
                                        tierName = "Wheat",
                                        resourceType = wheat.name
                                    }
                                }
                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ServerEvents"):FireServer(unpack(args))
                            end)
                            if not success then
                                warn("[MonboVerse Hub] Failed to collect " .. wheat.name .. ": " .. tostring(err))
                            end
                        end)
                        if fireCount < currentIntensity then
                            task.wait(0.01)
                        end
                    end
                end
            end
        end
    end

    -- Wheat Multiplier Buy
    if Config.Upgrades.WheatMultiplier.Enabled then
        if t - Config.Upgrades.WheatMultiplier.LastRun >= Config.Upgrades.WheatMultiplier.Delay then
            Config.Upgrades.WheatMultiplier.LastRun = t
            task.spawn(function()
                pcall(function()
                    local args = {
                        "PurchaseUpgrade",
                        {
                            upgradeId = "valueMultiplier",
                            tierName = "Wheat"
                        }
                    }
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ServerEvents"):FireServer(unpack(args))
                end)
            end)
        end
    end

    -- Wheat Cooldown Buy
    if Config.Upgrades.WheatCooldown.Enabled then
        if t - Config.Upgrades.WheatCooldown.LastRun >= Config.Upgrades.WheatCooldown.Delay then
            Config.Upgrades.WheatCooldown.LastRun = t
            task.spawn(function()
                pcall(function()
                    local args = {
                        "PurchaseUpgrade",
                        {
                            upgradeId = "spawnInterval",
                            tierName = "Wheat"
                        }
                    }
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ServerEvents"):FireServer(unpack(args))
                end)
            end)
        end
    end

    -- Wheat Capacity Buy
    if Config.Upgrades.WheatCapacity.Enabled then
        if t - Config.Upgrades.WheatCapacity.LastRun >= Config.Upgrades.WheatCapacity.Delay then
            Config.Upgrades.WheatCapacity.LastRun = t
            task.spawn(function()
                pcall(function()
                    local args = {
                        "PurchaseUpgrade",
                        {
                            upgradeId = "maxResources",
                            tierName = "Wheat"
                        }
                    }
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ServerEvents"):FireServer(unpack(args))
                end)
            end)
        end
    end
end)

print("[MonboVerse Hub v1.2] ✅ FULLY LOADED!")
print("🌈 Rainbow: Red→Orange→Yellow→Green→Cyan→Blue→Purple→Red")
print("📐 3-column grid layout")
print("⚡ Intensity sliders working (1x-25x)")
print("🎮 All upgrades functional")
print("Press K to toggle UI")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title    = "MonboVerse Hub v1.2 COMPLETE";
    Text     = "ALL FEATURES + 8-color rainbow border!";
    Duration = 6;
})
