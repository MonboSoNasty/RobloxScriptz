-- ============================================================
-- Moon Incremental by NVHeadMonbo
-- v2.0 - Tiny Ocean UI Style + Working Get Key Notification
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
if PlayerGui:FindFirstChild("MoonIncrementalGUI") then
    PlayerGui:FindFirstChild("MoonIncrementalGUI"):Destroy()
end
if PlayerGui:FindFirstChild("JunkieKeySystemUI") then
    PlayerGui:FindFirstChild("JunkieKeySystemUI"):Destroy()
end

-- ============================================================
-- JUNKIE KEY SYSTEM
-- ============================================================
print("[Moon Incremental] Loading Junkie Key System...")

local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service    = "Cuty"
Junkie.identifier = "1037885"
Junkie.provider   = "Cuty/Moon Incremental"

local options = {
    title       = "Moon Incremental",
    subtitle    = "by NVHeadMonbo",
    description = "Please complete key verification to use the script"
}

local function saveVerifiedKey(key)  pcall(function() writefile("moonincremental_key.txt", key) end) end
local function loadVerifiedKey()
    local ok, k = pcall(function() return readfile("moonincremental_key.txt") end)
    return ok and k or nil
end
local function clearSavedKey() pcall(function() delfile("moonincremental_key.txt") end) end

-- Key UI Colors
local KC = {
    background    = Color3.fromRGB(13,  17,  23),
    surface       = Color3.fromRGB(22,  27,  34),
    surfaceLight  = Color3.fromRGB(30,  36,  44),
    primary       = Color3.fromRGB(88,  166, 255),
    success       = Color3.fromRGB(63,  185, 80),
    error         = Color3.fromRGB(248, 81,  73),
    textPrimary   = Color3.fromRGB(230, 237, 243),
    textSecondary = Color3.fromRGB(139, 148, 158),
    border        = Color3.fromRGB(48,  54,  61),
}

-- ============================================================
-- KEY SYSTEM UI CLASS
-- ============================================================
local UI = {}
UI.__index = UI

function UI.new(opts)
    local self       = setmetatable({}, UI)
    self.title       = opts.title       or "Key Verification"
    self.subtitle    = opts.subtitle    or "Powered by Junkie"
    self.description = opts.description or "Please verify your key to continue"
    self.gui         = nil
    self.elements    = {}
    self._connections = {}
    return self
end

function UI:buildUI()
    local gui = Instance.new("ScreenGui")
    gui.Name           = "JunkieKeySystemUI"
    gui.ResetOnSpawn   = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent         = LocalPlayer:WaitForChild("PlayerGui")
    self.gui           = gui

    local blur = Instance.new("BlurEffect")
    blur.Name   = "JunkieUIBlur"
    blur.Size   = 0
    blur.Parent = Lighting
    TweenService:Create(blur, TweenInfo.new(0.3), {Size = 12}):Play()

    -- Container (Active=false so it doesn't eat clicks)
    local container = Instance.new("Frame")
    container.Name             = "Container"
    container.Size             = UDim2.new(0, 420, 0, 280)
    container.Position         = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint      = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = KC.surface
    container.BorderSizePixel  = 0
    container.Active           = false
    container.Parent           = gui
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
    local cStroke = Instance.new("UIStroke")
    cStroke.Color = KC.border cStroke.Thickness = 1 cStroke.Parent = container

    -- Header
    local header = Instance.new("Frame")
    header.Size             = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = KC.background
    header.BorderSizePixel  = 0
    header.Active           = false
    header.Parent           = container
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)
    local hFix = Instance.new("Frame")
    hFix.Size = UDim2.new(1,0,0,10) hFix.Position = UDim2.new(0,0,1,-10)
    hFix.BackgroundColor3 = KC.background hFix.BorderSizePixel = 0 hFix.Active = false hFix.Parent = header

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1,-60,0,24) titleLbl.Position = UDim2.new(0,20,0,8)
    titleLbl.BackgroundTransparency = 1 titleLbl.Text = self.title
    titleLbl.TextColor3 = KC.textPrimary titleLbl.TextSize = 16
    titleLbl.Font = Enum.Font.GothamBold titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = header

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1,-60,0,16) subLbl.Position = UDim2.new(0,20,0,30)
    subLbl.BackgroundTransparency = 1 subLbl.Text = self.subtitle
    subLbl.TextColor3 = KC.textSecondary subLbl.TextSize = 12
    subLbl.Font = Enum.Font.Gotham subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,30,0,30) closeBtn.Position = UDim2.new(1,-40,0.5,-15)
    closeBtn.BackgroundColor3 = KC.surfaceLight closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×" closeBtn.TextColor3 = KC.textSecondary
    closeBtn.TextSize = 20 closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = true closeBtn.ZIndex = 10
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    self.elements.closeButton = closeBtn

    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-40,1,-90) content.Position = UDim2.new(0,20,0,70)
    content.BackgroundTransparency = 1 content.Active = false content.Parent = container

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1,0,0,30) desc.BackgroundTransparency = 1
    desc.Text = self.description desc.TextColor3 = KC.textSecondary
    desc.TextSize = 13 desc.Font = Enum.Font.Gotham
    desc.TextWrapped = true desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = content

    local inputCont = Instance.new("Frame")
    inputCont.Size = UDim2.new(1,0,0,44) inputCont.Position = UDim2.new(0,0,0,40)
    inputCont.BackgroundColor3 = KC.background inputCont.BorderSizePixel = 0
    inputCont.Active = false inputCont.Parent = content
    Instance.new("UICorner", inputCont).CornerRadius = UDim.new(0, 8)
    local iStroke = Instance.new("UIStroke")
    iStroke.Color = KC.border iStroke.Thickness = 1 iStroke.Parent = inputCont

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(1,-20,1,0) keyInput.Position = UDim2.new(0,10,0,0)
    keyInput.BackgroundTransparency = 1 keyInput.PlaceholderText = "Enter your key..."
    keyInput.PlaceholderColor3 = KC.textSecondary keyInput.Text = ""
    keyInput.TextColor3 = KC.textPrimary keyInput.TextSize = 14
    keyInput.Font = Enum.Font.Gotham keyInput.TextXAlignment = Enum.TextXAlignment.Left
    keyInput.ClearTextOnFocus = false keyInput.ZIndex = 10
    keyInput.Parent = inputCont
    self.elements.keyInput = keyInput

    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(1,0,0,44) verifyBtn.Position = UDim2.new(0,0,0,94)
    verifyBtn.BackgroundColor3 = KC.primary verifyBtn.BorderSizePixel = 0
    verifyBtn.Text = "Verify Key" verifyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    verifyBtn.TextSize = 14 verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.AutoButtonColor = true verifyBtn.ZIndex = 10
    verifyBtn.Parent = content
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)
    self.elements.verifyButton = verifyBtn

    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(1,0,0,40) getKeyBtn.Position = UDim2.new(0,0,0,148)
    getKeyBtn.BackgroundColor3 = KC.surfaceLight getKeyBtn.BorderSizePixel = 0
    getKeyBtn.Text = "Get Key" getKeyBtn.TextColor3 = KC.textPrimary
    getKeyBtn.TextSize = 14 getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.AutoButtonColor = true getKeyBtn.ZIndex = 10
    getKeyBtn.Parent = content
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)
    self.elements.getLinkButton = getKeyBtn

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1,0,0,20) statusLbl.Position = UDim2.new(0,0,1,-25)
    statusLbl.BackgroundTransparency = 1 statusLbl.Text = ""
    statusLbl.TextColor3 = KC.textSecondary statusLbl.TextSize = 12
    statusLbl.Font = Enum.Font.Gotham statusLbl.TextXAlignment = Enum.TextXAlignment.Center
    statusLbl.Visible = false statusLbl.Parent = content
    self.elements.statusLabel = statusLbl

    -- Entrance animation
    container.Position = UDim2.new(0.5, 0, 0.5, 20)
    TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
end

function UI:createUI()
    self:buildUI()
    if not self.elements.closeButton then warn("[Moon Incremental] UI elements missing!") return end

    table.insert(self._connections, self.elements.closeButton.MouseButton1Click:Connect(function()
        self:close()
    end))
    table.insert(self._connections, self.elements.getLinkButton.MouseButton1Click:Connect(function()
        self:handleGetLink()
    end))
    table.insert(self._connections, self.elements.verifyButton.MouseButton1Click:Connect(function()
        self:handleVerifyKey()
    end))
    table.insert(self._connections, self.elements.keyInput.FocusLost:Connect(function(entered)
        if entered then self:handleVerifyKey() end
    end))
end

function UI:close()
    getgenv().UI_CLOSED = true
    for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    self._connections = {}
    if self.gui then self.gui:Destroy() end
    local blur = Lighting:FindFirstChild("JunkieUIBlur")
    if blur then blur:Destroy() end
end

function UI:updateStatus(msg, color, duration)
    local lbl = self.elements.statusLabel
    if not lbl then return end
    lbl.Text = msg lbl.TextColor3 = color lbl.Visible = true
    if duration and duration > 0 then
        task.delay(duration, function()
            if lbl and lbl.Parent then lbl.Visible = false end
        end)
    end
end

-- ============================================================
-- TOAST NOTIFICATION (used for Get Key + anywhere else)
-- ============================================================
local function showToast(parentGui, message, color, duration)
    duration = duration or 3

    -- Remove existing toast
    local existing = parentGui:FindFirstChild("ToastNotif")
    if existing then existing:Destroy() end

    local toast = Instance.new("Frame")
    toast.Name              = "ToastNotif"
    toast.Size              = UDim2.new(0, 320, 0, 44)
    toast.Position          = UDim2.new(0.5, 0, 0, -50)
    toast.AnchorPoint       = Vector2.new(0.5, 0)
    toast.BackgroundColor3  = color or KC.success
    toast.BorderSizePixel   = 0
    toast.ZIndex            = 100
    toast.Active            = false
    toast.Parent            = parentGui
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)

    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0,0,0) shadow.Thickness = 1
    shadow.Transparency = 0.5 shadow.Parent = toast

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,1,0) lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1 lbl.Text = message
    lbl.TextColor3 = Color3.fromRGB(255,255,255) lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.ZIndex = 101 lbl.Parent = toast

    -- Slide in
    TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 14)
    }):Play()

    -- Slide out after duration
    task.delay(duration, function()
        if toast and toast.Parent then
            TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0, -50)
            }):Play()
            task.delay(0.35, function()
                if toast and toast.Parent then toast:Destroy() end
            end)
        end
    end)

    return toast
end

function UI:handleGetLink()
    local link = Junkie.get_key_link()
    if not link then
        self:updateStatus("System not initialized", KC.error, 3)
        return
    end

    -- Try to copy to clipboard
    local copied = false
    if setclipboard then
        pcall(function() setclipboard(link) copied = true end)
    end
    if not copied and Clipboard and Clipboard.set then
        pcall(function() Clipboard.set(link) copied = true end)
    end

    -- Toast notification on the key system GUI
    if copied then
        showToast(self.gui, "✅  Key link copied to clipboard!", KC.success, 3)
        self:updateStatus("Link copied!", KC.success, 3)
    else
        -- Fallback: show URL in status so user can see it
        showToast(self.gui, "⚠  Copy manually: " .. link:sub(1, 40) .. "...", KC.error, 6)
        self:updateStatus("Could not copy — see console", KC.error, 5)
        print("[Moon Incremental] Get Key link: " .. link)
    end
end

function UI:handleVerifyKey()
    local key = self.elements.keyInput.Text:gsub("%s+", "")
    if key == "" then self:updateStatus("Please enter a key", KC.error, 3) return end

    self.elements.verifyButton.Text = "Verifying..."
    self:updateStatus("Verifying...", KC.primary, 0)

    local result = Junkie.check_key(key)
    if result and result.valid then
        saveVerifiedKey(key)
        self:updateStatus("Key verified!", KC.success, 0)
        task.wait(1)
        getgenv().SCRIPT_KEY = key
        self:close()
    else
        self:updateStatus("Invalid key", KC.error, 3)
        self.elements.verifyButton.Text = "Verify Key"
    end
end

-- Run key system
getgenv().UI_CLOSED = false
getgenv().SCRIPT_KEY = nil

local ui = UI.new(options)
ui:createUI()

local savedKey = loadVerifiedKey()
if savedKey then
    print("[Moon Incremental] Checking saved key...")
    local result = Junkie.check_key(savedKey)
    if result and result.valid then
        print("[Moon Incremental] ✓ Saved key verified!")
        getgenv().SCRIPT_KEY = savedKey
        ui:close()
    else
        print("[Moon Incremental] Saved key invalid, clearing...")
        clearSavedKey()
    end
end

if not getgenv().SCRIPT_KEY then
    print("[Moon Incremental] Waiting for key verification...")
    while not getgenv().UI_CLOSED do task.wait(0.1) end
end

if not getgenv().SCRIPT_KEY then
    warn("[Moon Incremental] ⚠ Key verification failed or cancelled")
    return
end

print("[Moon Incremental] ✓ Key verified! Loading main script...")
task.wait(0.5)

-- ============================================================
-- MAIN SCRIPT - Tiny Ocean UI style, Moon Incremental logic
-- ============================================================

-- Config (all original Moon Incremental toggles preserved)
local Config = {
    UIVisible = true,
    Toggles = {
        Stars        = { Enabled=false, Speed=0.1,  Intensity=1, LastRun=0 },
        Essence      = { Enabled=false, Speed=0.1,  Intensity=1, LastRun=0 },
        Fragments    = { Enabled=false, Speed=0.1,  Intensity=1, LastRun=0 },
        SmeltScrap   = { Enabled=false, Delay=1,                 LastRun=0 },
        SmeltCollect = { Enabled=false, Delay=1,                 LastRun=0 },
        Diamonds     = { Enabled=false, Delay=1,                 LastRun=0 },
    }
}

-- ============================================================
-- THEME  (Tiny Ocean palette)
-- ============================================================
local C = {
    BG          = Color3.fromRGB(8,   16,  30),
    TITLE_BG    = Color3.fromRGB(12,  24,  46),
    ACCENT      = Color3.fromRGB(0,   200, 255),
    ACCENT2     = Color3.fromRGB(0,   255, 160),
    PURPLE      = Color3.fromRGB(88,  101, 242),   -- kept for sliders matching original
    TEXT        = Color3.fromRGB(210, 235, 255),
    SUBTEXT     = Color3.fromRGB(110, 155, 190),
    BTN_ON      = Color3.fromRGB(88,  101, 242),
    BTN_OFF     = Color3.fromRGB(40,  42,  50),
    SLIDER_TRK  = Color3.fromRGB(20,  40,  65),
    SLIDER_FIL  = Color3.fromRGB(0,   200, 255),
    INTENSITY   = Color3.fromRGB(255, 107, 107),
    BORDER      = Color3.fromRGB(0,   180, 230),
    MINIMIZE    = Color3.fromRGB(255, 180, 0),
    CARD        = Color3.fromRGB(14,  26,  46),
}
local F  = Enum.Font.GothamBold
local FM = Enum.Font.Gotham

-- ============================================================
-- SCREEN GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "MoonIncrementalGUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 99
ScreenGui.Parent         = PlayerGui

local FRAME_W, FRAME_H = 400, 600

-- ============================================================
-- MAIN FRAME
-- ============================================================
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

-- Rainbow border
local rainbowStroke = Instance.new("UIStroke")
rainbowStroke.Thickness = 3
rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rainbowStroke.Parent = MainFrame

local rainbowGrad = Instance.new("UIGradient")
rainbowGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,   0,   0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 127,   0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255,   0)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(  0, 255,   0)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(  0, 127, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(139,   0, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,   0,   0)),
})
rainbowGrad.Parent = rainbowStroke

local rainbowRot = 0
RunService.Heartbeat:Connect(function(dt)
    rainbowRot = (rainbowRot + dt * 40) % 360
    rainbowGrad.Rotation = rainbowRot
end)

-- ============================================================
-- TITLE BAR  (draggable, Tiny Ocean style)
-- ============================================================
local TitleBar = Instance.new("Frame")
TitleBar.Name             = "TitleBar"
TitleBar.Size             = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = C.TITLE_BG
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 2
TitleBar.Active           = true
TitleBar.Parent           = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

-- Bottom half fill to square off the bottom edge of title bar
local tbFill = Instance.new("Frame")
tbFill.Size = UDim2.new(1,0,0.5,0) tbFill.Position = UDim2.new(0,0,0.5,0)
tbFill.BackgroundColor3 = C.TITLE_BG tbFill.BorderSizePixel = 0 tbFill.ZIndex = 2
tbFill.Parent = TitleBar

-- Dragging
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

-- Icon
local iconLbl = Instance.new("TextLabel")
iconLbl.Size = UDim2.new(0,30,1,0) iconLbl.Position = UDim2.new(0,8,0,0)
iconLbl.BackgroundTransparency = 1 iconLbl.Text = "🌙"
iconLbl.TextSize = 18 iconLbl.Font = FM iconLbl.ZIndex = 3
iconLbl.Parent = TitleBar

-- Title
local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-100,1,0) TitleLbl.Position = UDim2.new(0,40,0,0)
TitleLbl.BackgroundTransparency = 1 TitleLbl.Text = "Moon Incremental"
TitleLbl.TextColor3 = C.ACCENT TitleLbl.TextSize = 13
TitleLbl.Font = F TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 3 TitleLbl.Parent = TitleBar

-- Credit
local CreditLbl = Instance.new("TextLabel")
CreditLbl.Size = UDim2.new(1,-100,0,14) CreditLbl.Position = UDim2.new(0,40,1,-15)
CreditLbl.BackgroundTransparency = 1 CreditLbl.Text = "by NVHeadMonbo"
CreditLbl.TextColor3 = C.SUBTEXT CreditLbl.TextSize = 9
CreditLbl.Font = FM CreditLbl.TextXAlignment = Enum.TextXAlignment.Left
CreditLbl.ZIndex = 3 CreditLbl.Parent = TitleBar

-- Minimize button
local minimized   = false
local FULL_HEIGHT = FRAME_H
local MINI_HEIGHT = 42

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size             = UDim2.new(0, 26, 0, 22)
MinimizeButton.Position         = UDim2.new(1, -32, 0.5, -11)
MinimizeButton.BackgroundColor3 = C.MINIMIZE
MinimizeButton.BorderSizePixel  = 0
MinimizeButton.Text             = "—"
MinimizeButton.TextColor3       = Color3.fromRGB(30, 20, 0)
MinimizeButton.TextSize         = 12
MinimizeButton.Font             = F
MinimizeButton.ZIndex           = 4
MinimizeButton.Parent           = TitleBar
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 5)

-- ============================================================
-- NAVIGATION BAR  (Main / Info)
-- ============================================================
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
    btn.Size             = UDim2.new(0.5, -4, 1, -6)
    btn.Position         = UDim2.new(xScale, xOffset, 0, 3)
    btn.BackgroundColor3 = C.SLIDER_TRK
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

local mainNavBtn = makeNavBtn("Main", 0,   3)
local infoNavBtn = makeNavBtn("Info", 0.5, 3)
mainNavBtn.BackgroundColor3 = C.ACCENT
mainNavBtn.TextColor3       = Color3.fromRGB(255, 255, 255)

-- ============================================================
-- PAGE CONTAINERS
-- ============================================================
local ContentArea = Instance.new("Frame")
ContentArea.Name                 = "ContentArea"
ContentArea.Size                 = UDim2.new(1, 0, 1, -78)
ContentArea.Position             = UDim2.new(0, 0, 0, 78)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants     = true
ContentArea.Parent               = MainFrame

-- Main Page — ScrollingFrame to handle many cards
local MainPage = Instance.new("ScrollingFrame")
MainPage.Name                  = "MainPage"
MainPage.Size                  = UDim2.new(1, 0, 1, 0)
MainPage.BackgroundTransparency = 1
MainPage.BorderSizePixel       = 0
MainPage.ScrollBarThickness    = 4
MainPage.ScrollBarImageColor3  = C.ACCENT
MainPage.CanvasSize            = UDim2.new(0, 0, 0, 0)
MainPage.AutomaticCanvasSize   = Enum.AutomaticSize.Y
MainPage.Visible               = true
MainPage.Parent                = ContentArea

local MainLayout = Instance.new("UIListLayout")
MainLayout.Padding      = UDim.new(0, 8)
MainLayout.SortOrder    = Enum.SortOrder.LayoutOrder
MainLayout.Parent       = MainPage

local MainPadding = Instance.new("UIPadding")
MainPadding.PaddingLeft   = UDim.new(0, 10)
MainPadding.PaddingRight  = UDim.new(0, 10)
MainPadding.PaddingTop    = UDim.new(0, 8)
MainPadding.PaddingBottom = UDim.new(0, 8)
MainPadding.Parent        = MainPage

-- Info Page
local InfoPage = Instance.new("Frame")
InfoPage.Name                  = "InfoPage"
InfoPage.Size                  = UDim2.new(1, 0, 1, 0)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible               = false
InfoPage.Parent                = ContentArea

-- Page switching
local function switchPage(page)
    MainPage.Visible = (page == "Main")
    InfoPage.Visible = (page == "Info")
    mainNavBtn.BackgroundColor3 = (page=="Main") and C.ACCENT or C.SLIDER_TRK
    mainNavBtn.TextColor3       = (page=="Main") and Color3.fromRGB(255,255,255) or C.SUBTEXT
    infoNavBtn.BackgroundColor3 = (page=="Info") and C.ACCENT or C.SLIDER_TRK
    infoNavBtn.TextColor3       = (page=="Info") and Color3.fromRGB(255,255,255) or C.SUBTEXT
end

mainNavBtn.MouseButton1Click:Connect(function() switchPage("Main") end)
infoNavBtn.MouseButton1Click:Connect(function()  switchPage("Info")  end)

-- Minimize
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
-- CARD BUILDER  (Tiny Ocean style cards, Moon logic inside)
-- ============================================================
local function CreateToggleCard(displayName, config, hasIntensity)
    local isDelay = (displayName == "Smelt Scrap Auto" or displayName == "Smelt Collect Auto" or displayName == "Diamonds Collect")

    local cardH = hasIntensity and 118 or 84
    local Card = Instance.new("Frame")
    Card.Name             = displayName .. "Card"
    Card.Size             = UDim2.new(1, 0, 0, cardH)
    Card.BackgroundColor3 = C.CARD
    Card.BorderSizePixel  = 0
    Card.Parent           = MainPage
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(20,45,75) cardStroke.Thickness = 1 cardStroke.Parent = Card

    -- Name label
    local NameLbl = Instance.new("TextLabel")
    NameLbl.Size = UDim2.new(1,-80,0,20) NameLbl.Position = UDim2.new(0,12,0,10)
    NameLbl.BackgroundTransparency = 1 NameLbl.Text = displayName
    NameLbl.TextColor3 = C.TEXT NameLbl.TextSize = 13
    NameLbl.Font = F NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.Parent = Card

    -- Toggle button
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
    ToggleBtn.Parent           = Card
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)

    -- Speed/Delay label + value
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.5,-8,0,16) speedLabel.Position = UDim2.new(0,12,0,38)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = isDelay and "Delay" or "Speed"
    speedLabel.TextColor3 = C.SUBTEXT speedLabel.TextSize = 10
    speedLabel.Font = FM speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = Card

    local speedVal = Instance.new("TextLabel")
    speedVal.Name = "SpeedValue"
    speedVal.Size = UDim2.new(0.5,-8,0,16) speedVal.Position = UDim2.new(0.5,4,0,38)
    speedVal.BackgroundTransparency = 1
    speedVal.Text = isDelay and "1.0s" or "0.10s"
    speedVal.TextColor3 = C.ACCENT speedVal.TextSize = 10
    speedVal.Font = F speedVal.TextXAlignment = Enum.TextXAlignment.Right
    speedVal.Parent = Card

    -- Speed slider track
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.Size = UDim2.new(1,-24,0,4) SpeedSlider.Position = UDim2.new(0,12,0,58)
    SpeedSlider.BackgroundColor3 = C.SLIDER_TRK SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Parent = Card
    Instance.new("UICorner", SpeedSlider).CornerRadius = UDim.new(1,0)

    local SpeedFill = Instance.new("Frame")
    SpeedFill.Name = "Fill"
    SpeedFill.Size = UDim2.new(0.1,0,1,0) SpeedFill.BackgroundColor3 = C.SLIDER_FIL
    SpeedFill.BorderSizePixel = 0 SpeedFill.Parent = SpeedSlider
    Instance.new("UICorner", SpeedFill).CornerRadius = UDim.new(1,0)

    local SpeedButton = Instance.new("TextButton")
    SpeedButton.Name = "Button"
    SpeedButton.Size = UDim2.new(1,0,1,12) SpeedButton.Position = UDim2.new(0,0,0,-6)
    SpeedButton.BackgroundTransparency = 1 SpeedButton.Text = ""
    SpeedButton.Parent = SpeedSlider

    -- Intensity (for Stars/Essence/Fragments)
    local IntensitySlider, IntensityFill, IntensityValue
    if hasIntensity then
        local intLabel = Instance.new("TextLabel")
        intLabel.Size = UDim2.new(0.5,-8,0,16) intLabel.Position = UDim2.new(0,12,0,72)
        intLabel.BackgroundTransparency = 1 intLabel.Text = "Intensity"
        intLabel.TextColor3 = C.SUBTEXT intLabel.TextSize = 10
        intLabel.Font = FM intLabel.TextXAlignment = Enum.TextXAlignment.Left
        intLabel.Parent = Card

        IntensityValue = Instance.new("TextLabel")
        IntensityValue.Name = "IntensityValue"
        IntensityValue.Size = UDim2.new(0.5,-8,0,16) IntensityValue.Position = UDim2.new(0.5,4,0,72)
        IntensityValue.BackgroundTransparency = 1 IntensityValue.Text = "1x"
        IntensityValue.TextColor3 = C.INTENSITY IntensityValue.TextSize = 10
        IntensityValue.Font = F IntensityValue.TextXAlignment = Enum.TextXAlignment.Right
        IntensityValue.Parent = Card

        IntensitySlider = Instance.new("Frame")
        IntensitySlider.Name = "IntensitySlider"
        IntensitySlider.Size = UDim2.new(1,-24,0,4) IntensitySlider.Position = UDim2.new(0,12,0,92)
        IntensitySlider.BackgroundColor3 = C.SLIDER_TRK IntensitySlider.BorderSizePixel = 0
        IntensitySlider.Parent = Card
        Instance.new("UICorner", IntensitySlider).CornerRadius = UDim.new(1,0)

        IntensityFill = Instance.new("Frame")
        IntensityFill.Name = "Fill"
        IntensityFill.Size = UDim2.new(0,0,1,0) IntensityFill.BackgroundColor3 = C.INTENSITY
        IntensityFill.BorderSizePixel = 0 IntensityFill.Parent = IntensitySlider
        Instance.new("UICorner", IntensityFill).CornerRadius = UDim.new(1,0)

        local intBtn = Instance.new("TextButton")
        intBtn.Name = "Button"
        intBtn.Size = UDim2.new(1,0,1,12) intBtn.Position = UDim2.new(0,0,0,-6)
        intBtn.BackgroundTransparency = 1 intBtn.Text = ""
        intBtn.Parent = IntensitySlider
    end

    return {
        Card            = Card,
        ToggleButton    = ToggleBtn,
        SpeedSlider     = SpeedSlider,
        SpeedFill       = SpeedFill,
        SpeedButton     = SpeedButton,
        SpeedValue      = speedVal,
        IntensitySlider = IntensitySlider,
        IntensityFill   = IntensityFill,
        IntensityValue  = IntensityValue,
    }
end

-- Build all cards
local StarsCard        = CreateToggleCard("Stars",            Config.Toggles.Stars,        true)
local EssenceCard      = CreateToggleCard("Essence",          Config.Toggles.Essence,      true)
local FragmentsCard    = CreateToggleCard("Fragments",        Config.Toggles.Fragments,    true)
local SmeltCard        = CreateToggleCard("Smelt Scrap Auto", Config.Toggles.SmeltScrap,   false)
local SmeltCollectCard = CreateToggleCard("Smelt Collect Auto",Config.Toggles.SmeltCollect,false)
local DiamondsCard     = CreateToggleCard("Diamonds Collect", Config.Toggles.Diamonds,     false)

-- ============================================================
-- SLIDER SETUP  (unchanged Moon Incremental logic)
-- ============================================================
local function SetupSlider(sliderFrame, fillFrame, valueLabel, config, property, isDelay)
    local button   = sliderFrame:FindFirstChild("Button")
    local draggingSlider = false

    local function updateSlider(input)
        local sizeX   = sliderFrame.AbsoluteSize.X
        local posX    = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sizeX)
        local percent = posX / sizeX
        fillFrame.Size = UDim2.new(percent, 0, 1, 0)
        if isDelay then
            local v = 0.1 + percent * 9.9
            config[property] = math.floor(v * 10) / 10
            valueLabel.Text  = string.format("%.1fs", config[property])
        else
            local v = 0.01 + percent * 0.99
            config[property] = math.floor(v * 100) / 100
            valueLabel.Text  = string.format("%.2fs", config[property])
        end
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

local function SetupIntensitySlider(sliderFrame, fillFrame, valueLabel, config)
    local button       = sliderFrame:FindFirstChild("Button")
    local draggingInt  = false

    local function updateSlider(input)
        local sizeX   = sliderFrame.AbsoluteSize.X
        local posX    = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sizeX)
        local percent = posX / sizeX
        fillFrame.Size   = UDim2.new(percent, 0, 1, 0)
        local v          = 1 + math.floor(percent * 9)
        config.Intensity = v
        valueLabel.Text  = string.format("%dx", v)
    end

    button.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            draggingInt = true updateSlider(i)
        end
    end)
    button.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            draggingInt = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingInt and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(i)
        end
    end)
end

SetupSlider(StarsCard.SpeedSlider,        StarsCard.SpeedFill,        StarsCard.SpeedValue,        Config.Toggles.Stars,        "Speed", false)
SetupIntensitySlider(StarsCard.IntensitySlider, StarsCard.IntensityFill, StarsCard.IntensityValue, Config.Toggles.Stars)

SetupSlider(EssenceCard.SpeedSlider,      EssenceCard.SpeedFill,      EssenceCard.SpeedValue,      Config.Toggles.Essence,      "Speed", false)
SetupIntensitySlider(EssenceCard.IntensitySlider, EssenceCard.IntensityFill, EssenceCard.IntensityValue, Config.Toggles.Essence)

SetupSlider(FragmentsCard.SpeedSlider,    FragmentsCard.SpeedFill,    FragmentsCard.SpeedValue,    Config.Toggles.Fragments,    "Speed", false)
SetupIntensitySlider(FragmentsCard.IntensitySlider, FragmentsCard.IntensityFill, FragmentsCard.IntensityValue, Config.Toggles.Fragments)

SetupSlider(SmeltCard.SpeedSlider,        SmeltCard.SpeedFill,        SmeltCard.SpeedValue,        Config.Toggles.SmeltScrap,   "Delay", true)
SetupSlider(SmeltCollectCard.SpeedSlider, SmeltCollectCard.SpeedFill, SmeltCollectCard.SpeedValue, Config.Toggles.SmeltCollect, "Delay", true)
SetupSlider(DiamondsCard.SpeedSlider,     DiamondsCard.SpeedFill,     DiamondsCard.SpeedValue,     Config.Toggles.Diamonds,     "Delay", true)

-- ============================================================
-- TOGGLE BUTTONS  (Tiny Ocean style colours, Moon logic)
-- ============================================================
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

SetupToggleButton(StarsCard.ToggleButton,        Config.Toggles.Stars)
SetupToggleButton(EssenceCard.ToggleButton,      Config.Toggles.Essence)
SetupToggleButton(FragmentsCard.ToggleButton,    Config.Toggles.Fragments)
SetupToggleButton(SmeltCard.ToggleButton,        Config.Toggles.SmeltScrap)
SetupToggleButton(SmeltCollectCard.ToggleButton, Config.Toggles.SmeltCollect)
SetupToggleButton(DiamondsCard.ToggleButton,     Config.Toggles.Diamonds)

-- ============================================================
-- INFO PAGE CONTENT
-- ============================================================
local infoBox = Instance.new("Frame")
infoBox.Size = UDim2.new(1,-20,0,200) infoBox.Position = UDim2.new(0,10,0,10)
infoBox.BackgroundColor3 = Color3.fromRGB(14,26,46) infoBox.BorderSizePixel = 0
infoBox.Parent = InfoPage
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0,8)
local infoStroke = Instance.new("UIStroke")
infoStroke.Color = C.BORDER infoStroke.Thickness = 1 infoStroke.Parent = infoBox

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1,-16,1,-16) infoText.Position = UDim2.new(0,8,0,8)
infoText.BackgroundTransparency = 1 infoText.TextWrapped = true
infoText.Text = [[🌙 Moon Incremental v2.0

🆕 Changes:
• Tiny Ocean UI style applied
• Rainbow border
• Draggable title bar
• Nav pages (Main / Info)
• Ocean colour theme
• Get Key copies to clipboard + toast
• Smooth scrolling card list

⚙️ Features:
• Stars / Essence / Fragments farming
• Smelt Scrap Auto + Collect Auto
• Diamonds Collect Auto
• Speed & Intensity sliders per toggle

⌨️ Keybind:  [ K ]  Toggle UI]]
infoText.TextColor3 = C.TEXT infoText.TextSize = 11 infoText.Font = FM
infoText.TextXAlignment = Enum.TextXAlignment.Left infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoBox

local credBox = Instance.new("Frame")
credBox.Size = UDim2.new(1,-20,0,36) credBox.Position = UDim2.new(0,10,0,220)
credBox.BackgroundColor3 = Color3.fromRGB(14,26,46) credBox.BorderSizePixel = 0
credBox.Parent = InfoPage
Instance.new("UICorner", credBox).CornerRadius = UDim.new(0,8)
local credStroke = Instance.new("UIStroke")
credStroke.Color = C.ACCENT2 credStroke.Thickness = 1 credStroke.Parent = credBox

local credText = Instance.new("TextLabel")
credText.Size = UDim2.new(1,-16,1,0) credText.Position = UDim2.new(0,8,0,0)
credText.BackgroundTransparency = 1
credText.Text = "🌙 Moon Incremental v2.0 — by NVHeadMonbo"
credText.TextColor3 = C.ACCENT2 credText.TextSize = 11 credText.Font = F
credText.TextXAlignment = Enum.TextXAlignment.Center credText.TextYAlignment = Enum.TextYAlignment.Center
credText.Parent = credBox

-- Keybind hint at bottom of info
local kbHint = Instance.new("TextLabel")
kbHint.Size = UDim2.new(1,-20,0,18) kbHint.Position = UDim2.new(0,10,0,265)
kbHint.BackgroundTransparency = 1 kbHint.Text = "[ K ]  Toggle UI visibility"
kbHint.TextColor3 = C.SUBTEXT kbHint.TextSize = 10 kbHint.Font = FM
kbHint.TextXAlignment = Enum.TextXAlignment.Center kbHint.Parent = InfoPage

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
-- HEARTBEAT  (all original Moon Incremental remote logic, untouched)
-- ============================================================
RunService.Heartbeat:Connect(function()
    local t = tick()

    if Config.Toggles.Stars.Enabled then
        if t - Config.Toggles.Stars.LastRun >= Config.Toggles.Stars.Speed then
            Config.Toggles.Stars.LastRun = t
            for i = 1, Config.Toggles.Stars.Intensity do
                task.spawn(function()
                    pcall(function()
                        ReplicatedStorage:WaitForChild("UpdateStarStat"):FireServer(
                            Vector3.new(-221.68064880371094, 5.273603916168213, -17.193782806396484)
                        )
                    end)
                end)
            end
        end
    end

    if Config.Toggles.Essence.Enabled then
        if t - Config.Toggles.Essence.LastRun >= Config.Toggles.Essence.Speed then
            Config.Toggles.Essence.LastRun = t
            for i = 1, Config.Toggles.Essence.Intensity do
                task.spawn(function()
                    pcall(function()
                        ReplicatedStorage:WaitForChild("UpdateEssenceStat"):FireServer(
                            Vector3.new(-200, 9.514981269836426, -35), true
                        )
                    end)
                end)
            end
        end
    end

    if Config.Toggles.Fragments.Enabled then
        if t - Config.Toggles.Fragments.LastRun >= Config.Toggles.Fragments.Speed then
            Config.Toggles.Fragments.LastRun = t
            for i = 1, Config.Toggles.Fragments.Intensity do
                task.spawn(function()
                    pcall(function()
                        ReplicatedStorage:WaitForChild("MineRock"):FireServer(
                            workspace:WaitForChild("Cave"):WaitForChild("Ore_9217932433")
                        )
                    end)
                end)
            end
        end
    end

    if Config.Toggles.SmeltScrap.Enabled then
        if t - Config.Toggles.SmeltScrap.LastRun >= Config.Toggles.SmeltScrap.Delay then
            Config.Toggles.SmeltScrap.LastRun = t
            task.spawn(function() pcall(function() ReplicatedStorage:WaitForChild("SmeltDeposit"):FireServer() end) end)
        end
    end

    if Config.Toggles.SmeltCollect.Enabled then
        if t - Config.Toggles.SmeltCollect.LastRun >= Config.Toggles.SmeltCollect.Delay then
            Config.Toggles.SmeltCollect.LastRun = t
            task.spawn(function() pcall(function() ReplicatedStorage:WaitForChild("SmeltCollect"):FireServer() end) end)
        end
    end

    if Config.Toggles.Diamonds.Enabled then
        if t - Config.Toggles.Diamonds.LastRun >= Config.Toggles.Diamonds.Delay then
            Config.Toggles.Diamonds.LastRun = t
            task.spawn(function() pcall(function() ReplicatedStorage:WaitForChild("MineshaftCollect"):FireServer() end) end)
        end
    end
end)

-- ============================================================
-- DONE
-- ============================================================
print("[Moon Incremental v2.0] Loaded — Press K to toggle UI")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title    = "Moon Incremental";
    Text     = "v2.0 loaded! Press K to toggle UI.";
    Duration = 4;
})
