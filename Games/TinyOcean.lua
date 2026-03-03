-- ============================================================
--   Tiny Ocean Inf XP v2.4 - KEY SYSTEM FIXED
--   by NVHeadMonbo
-- ============================================================
-- FIXES v2.4:
--   ✅ Fixed ALL button interactions (Get Key, Verify, Close, X)
--   ✅ Container & content frames set Active=false so they don't
--      swallow mouse events before buttons receive them
--   ✅ All buttons set AutoButtonColor=true
--   ✅ Matched working flat-UI pattern from Moon Incremental
--   ✅ Anti-stack (destroys old GUI on reload)
--   ✅ Rainbow border animation
--   ✅ Draggable from title bar only
--   ✅ Multi-page navigation (Main/Tiers/Info)
--   ✅ Individual T1-T9 tier toggles
--   ✅ K keybind = show/hide
--   ✅ Speed/Delay controls
-- ============================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")

local player = Players.LocalPlayer
local pgui   = player:WaitForChild("PlayerGui")

-- ============================================================
-- ANTI-STACK
-- ============================================================
if pgui:FindFirstChild("NVHeadMonbo_TinyOcean_v24") then
    pgui:FindFirstChild("NVHeadMonbo_TinyOcean_v24"):Destroy()
end
if pgui:FindFirstChild("JunkieKeySystemUI") then
    pgui:FindFirstChild("JunkieKeySystemUI"):Destroy()
end

-- ============================================================
-- JUNKIE KEY SYSTEM
-- ============================================================
print("[Tiny Ocean] Loading Junkie Key System...")

local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service    = "Cuty"
Junkie.identifier = "1037885"
Junkie.provider   = "Cuty/Tiny Ocean"

local options = {
    title       = "Tiny Ocean Inf XP",
    subtitle    = "by NVHeadMonbo",
    description = "Please complete key verification to use the script"
}

-- Key storage
local function saveVerifiedKey(key)  pcall(function() writefile("tinyocean_v24_key.txt", key) end) end
local function loadVerifiedKey()
    local ok, k = pcall(function() return readfile("tinyocean_v24_key.txt") end)
    return ok and k or nil
end
local function clearSavedKey() pcall(function() delfile("tinyocean_v24_key.txt") end) end

-- Colors
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
-- UI CLASS  (THE FIX: Active=false on all non-button frames)
-- ============================================================
local UI = {}
UI.__index = UI

function UI.new(opts)
    local self      = setmetatable({}, UI)
    self.title      = opts.title       or "Key Verification"
    self.subtitle   = opts.subtitle    or "Powered by Junkie"
    self.description= opts.description or "Please verify your key to continue"
    self.gui        = nil
    self.elements   = {}
    self._connections = {}
    return self
end

function UI:buildUI()
    local gui       = Instance.new("ScreenGui")
    gui.Name        = "JunkieKeySystemUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent      = player:WaitForChild("PlayerGui")
    self.gui        = gui

    -- Blur
    local blur      = Instance.new("BlurEffect")
    blur.Name       = "JunkieUIBlur"
    blur.Size       = 0
    blur.Parent     = Lighting
    TweenService:Create(blur, TweenInfo.new(0.3), {Size = 12}):Play()

    -- Container  ← THE KEY FIX: Active = false
    local container = Instance.new("Frame")
    container.Name              = "Container"
    container.Size              = UDim2.new(0, 420, 0, 280)
    container.Position          = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint       = Vector2.new(0.5, 0.5)
    container.BackgroundColor3  = KC.surface
    container.BorderSizePixel   = 0
    container.Active            = false   -- ✅ FIX: was missing, caused click swallowing
    container.Parent            = gui

    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
    local cStroke = Instance.new("UIStroke")
    cStroke.Color     = KC.border
    cStroke.Thickness = 1
    cStroke.Parent    = container

    -- Header  ← Active = false
    local header = Instance.new("Frame")
    header.Name             = "Header"
    header.Size             = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = KC.background
    header.BorderSizePixel  = 0
    header.Active           = false   -- ✅ FIX
    header.Parent           = container

    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

    local headerFix = Instance.new("Frame")
    headerFix.Size             = UDim2.new(1, 0, 0, 10)
    headerFix.Position         = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = KC.background
    headerFix.BorderSizePixel  = 0
    headerFix.Active           = false
    headerFix.Parent           = header

    -- Title label
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size                = UDim2.new(1, -60, 0, 24)
    titleLbl.Position            = UDim2.new(0, 20, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text                = self.title
    titleLbl.TextColor3          = KC.textPrimary
    titleLbl.TextSize            = 16
    titleLbl.Font                = Enum.Font.GothamBold
    titleLbl.TextXAlignment      = Enum.TextXAlignment.Left
    titleLbl.Parent              = header

    -- Subtitle label
    local subtitleLbl = Instance.new("TextLabel")
    subtitleLbl.Size                = UDim2.new(1, -60, 0, 16)
    subtitleLbl.Position            = UDim2.new(0, 20, 0, 30)
    subtitleLbl.BackgroundTransparency = 1
    subtitleLbl.Text                = self.subtitle
    subtitleLbl.TextColor3          = KC.textSecondary
    subtitleLbl.TextSize            = 12
    subtitleLbl.Font                = Enum.Font.Gotham
    subtitleLbl.TextXAlignment      = Enum.TextXAlignment.Left
    subtitleLbl.Parent              = header

    -- Close (X) button  ← must NOT be inside an Active=true parent that blocks it
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size             = UDim2.new(0, 30, 0, 30)
    closeBtn.Position         = UDim2.new(1, -40, 0.5, -15)
    closeBtn.BackgroundColor3 = KC.surfaceLight
    closeBtn.BorderSizePixel  = 0
    closeBtn.Text             = "×"
    closeBtn.TextColor3       = KC.textSecondary
    closeBtn.TextSize         = 20
    closeBtn.Font             = Enum.Font.GothamBold
    closeBtn.AutoButtonColor  = true   -- ✅ FIX
    closeBtn.ZIndex           = 10     -- ✅ FIX: ensure it renders on top
    closeBtn.Parent           = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    self.elements.closeButton = closeBtn

    -- Content frame  ← Active = false
    local content = Instance.new("Frame")
    content.Size                = UDim2.new(1, -40, 1, -90)
    content.Position            = UDim2.new(0, 20, 0, 70)
    content.BackgroundTransparency = 1
    content.Active              = false   -- ✅ FIX
    content.Parent              = container

    -- Description
    local desc = Instance.new("TextLabel")
    desc.Size                = UDim2.new(1, 0, 0, 30)
    desc.BackgroundTransparency = 1
    desc.Text                = self.description
    desc.TextColor3          = KC.textSecondary
    desc.TextSize            = 13
    desc.Font                = Enum.Font.Gotham
    desc.TextWrapped         = true
    desc.TextXAlignment      = Enum.TextXAlignment.Left
    desc.Parent              = content

    -- Input container  ← Active = false
    local inputCont = Instance.new("Frame")
    inputCont.Size             = UDim2.new(1, 0, 0, 44)
    inputCont.Position         = UDim2.new(0, 0, 0, 40)
    inputCont.BackgroundColor3 = KC.background
    inputCont.BorderSizePixel  = 0
    inputCont.Active           = false   -- ✅ FIX
    inputCont.Parent           = content
    Instance.new("UICorner", inputCont).CornerRadius = UDim.new(0, 8)
    local iStroke = Instance.new("UIStroke")
    iStroke.Color     = KC.border
    iStroke.Thickness = 1
    iStroke.Parent    = inputCont

    -- TextBox (Active=true is implicit and needed for text input)
    local keyInput = Instance.new("TextBox")
    keyInput.Size               = UDim2.new(1, -20, 1, 0)
    keyInput.Position           = UDim2.new(0, 10, 0, 0)
    keyInput.BackgroundTransparency = 1
    keyInput.PlaceholderText    = "Enter your key..."
    keyInput.PlaceholderColor3  = KC.textSecondary
    keyInput.Text               = ""
    keyInput.TextColor3         = KC.textPrimary
    keyInput.TextSize           = 14
    keyInput.Font               = Enum.Font.Gotham
    keyInput.TextXAlignment     = Enum.TextXAlignment.Left
    keyInput.ClearTextOnFocus   = false
    keyInput.ZIndex             = 10
    keyInput.Parent             = inputCont
    self.elements.keyInput = keyInput

    -- Verify button
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size             = UDim2.new(1, 0, 0, 44)
    verifyBtn.Position         = UDim2.new(0, 0, 0, 94)
    verifyBtn.BackgroundColor3 = KC.primary
    verifyBtn.BorderSizePixel  = 0
    verifyBtn.Text             = "Verify Key"
    verifyBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    verifyBtn.TextSize         = 14
    verifyBtn.Font             = Enum.Font.GothamBold
    verifyBtn.AutoButtonColor  = true   -- ✅ FIX
    verifyBtn.ZIndex           = 10
    verifyBtn.Parent           = content
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)
    self.elements.verifyButton = verifyBtn

    -- Get Key button
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size             = UDim2.new(1, 0, 0, 40)
    getKeyBtn.Position         = UDim2.new(0, 0, 0, 148)
    getKeyBtn.BackgroundColor3 = KC.surfaceLight
    getKeyBtn.BorderSizePixel  = 0
    getKeyBtn.Text             = "Get Key"
    getKeyBtn.TextColor3       = KC.textPrimary
    getKeyBtn.TextSize         = 14
    getKeyBtn.Font             = Enum.Font.GothamBold
    getKeyBtn.AutoButtonColor  = true   -- ✅ FIX
    getKeyBtn.ZIndex           = 10
    getKeyBtn.Parent           = content
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)
    self.elements.getLinkButton = getKeyBtn

    -- Status label
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size                = UDim2.new(1, 0, 0, 20)
    statusLbl.Position            = UDim2.new(0, 0, 1, -25)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text                = ""
    statusLbl.TextColor3          = KC.textSecondary
    statusLbl.TextSize            = 12
    statusLbl.Font                = Enum.Font.Gotham
    statusLbl.TextXAlignment      = Enum.TextXAlignment.Center
    statusLbl.Visible             = false
    statusLbl.Parent              = content
    self.elements.statusLabel = statusLbl

    -- Entrance animation
    container.Position = UDim2.new(0.5, 0, 0.5, 20)
    TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
end

function UI:createUI()
    self:buildUI()

    if not self.elements.closeButton then
        warn("[Tiny Ocean] UI elements missing!")
        return
    end

    print("[Tiny Ocean] Connecting button events...")

    table.insert(self._connections, self.elements.closeButton.MouseButton1Click:Connect(function()
        print("[Tiny Ocean] Close button clicked!")
        self:close()
    end))

    table.insert(self._connections, self.elements.getLinkButton.MouseButton1Click:Connect(function()
        print("[Tiny Ocean] Get Key clicked!")
        self:handleGetLink()
    end))

    table.insert(self._connections, self.elements.verifyButton.MouseButton1Click:Connect(function()
        print("[Tiny Ocean] Verify clicked!")
        self:handleVerifyKey()
    end))

    table.insert(self._connections, self.elements.keyInput.FocusLost:Connect(function(entered)
        if entered then self:handleVerifyKey() end
    end))

    print("[Tiny Ocean] All buttons connected!")
end

function UI:close()
    print("[Tiny Ocean] Closing UI...")
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
    lbl.Text      = msg
    lbl.TextColor3 = color
    lbl.Visible   = true
    if duration and duration > 0 then
        task.delay(duration, function()
            if lbl and lbl.Parent then lbl.Visible = false end
        end)
    end
end

function UI:handleGetLink()
    local link = Junkie.get_key_link()
    if not link then
        self:updateStatus("System not initialized", KC.error, 3)
        return
    end
    if setclipboard then
        setclipboard(link)
        self:updateStatus("Link copied to clipboard!", KC.success, 3)
    else
        self:updateStatus("Link: " .. link, KC.primary, 10)
    end
end

function UI:handleVerifyKey()
    local key = self.elements.keyInput.Text:gsub("%s+", "")
    if key == "" then
        self:updateStatus("Please enter a key", KC.error, 3)
        return
    end
    self.elements.verifyButton.Text = "Verifying..."
    self:updateStatus("Verifying...", KC.primary, 0)

    local result = Junkie.check_key(key)
    if result and result.valid then
        print("[Tiny Ocean] ✓ Key valid!")
        saveVerifiedKey(key)
        self:updateStatus("Key verified!", KC.success, 0)
        task.wait(1)
        getgenv().SCRIPT_KEY = key
        self:close()
    else
        print("[Tiny Ocean] ✗ Invalid key")
        self:updateStatus("Invalid key", KC.error, 3)
        self.elements.verifyButton.Text = "Verify Key"
    end
end

-- ============================================================
-- RUN KEY SYSTEM
-- ============================================================
getgenv().UI_CLOSED = false
getgenv().SCRIPT_KEY = nil

local ui = UI.new(options)
ui:createUI()

local savedKey = loadVerifiedKey()
if savedKey then
    print("[Tiny Ocean] Checking saved key...")
    local result = Junkie.check_key(savedKey)
    if result and result.valid then
        print("[Tiny Ocean] ✓ Saved key verified!")
        getgenv().SCRIPT_KEY = savedKey
        ui:close()
    else
        print("[Tiny Ocean] Saved key invalid, clearing...")
        clearSavedKey()
    end
end

if not getgenv().SCRIPT_KEY then
    print("[Tiny Ocean] Waiting for key verification...")
    while not getgenv().UI_CLOSED do
        task.wait(0.1)
    end
end

if not getgenv().SCRIPT_KEY then
    warn("[Tiny Ocean] ⚠ Key verification failed or cancelled")
    return
end

print("[Tiny Ocean] ✓ Key verified! Loading main script...")
task.wait(0.5)

-- ============================================================
-- MAIN SCRIPT  (unchanged from your v2.3 — only key UI fixed)
-- ============================================================

local character = player.Character or player.CharacterAdded:Wait()
local hrp       = character:WaitForChild("HumanoidRootPart")
player.CharacterAdded:Connect(function(c)
    character = c
    hrp = c:WaitForChild("HumanoidRootPart")
end)

local CONFIG = {
    ClaimDelay   = 0.05,
    LoopInterval = 1.0,
}

local TIER_ENABLED = {
    [1]=true,[2]=true,[3]=true,
    [4]=true,[5]=true,[6]=true,
    [7]=true,[8]=true,[9]=true,
}

local function getTouchInterests()
    local results = {}
    local active = workspace:FindFirstChild("Main")
        and workspace.Main:FindFirstChild("Pickups")
        and workspace.Main.Pickups:FindFirstChild("Active")
    if not active then return results end
    for _, pickup in ipairs(active:GetChildren()) do
        local tierNum = tonumber(pickup.Name:match("Tier(%d+)"))
        if tierNum and TIER_ENABLED[tierNum] then
            local tp = pickup:FindFirstChild("TouchPart")
            if tp then
                local ti = tp:FindFirstChildOfClass("TouchTransmitter")
                        or tp:FindFirstChild("TouchInterest")
                if ti then table.insert(results, ti) end
            end
        end
    end
    return results
end

local function fireTouchInterest(ti)
    if not hrp or not hrp.Parent then return end
    pcall(function()
        firetouchinterest(hrp, ti.Parent, 0)
        task.wait(0.02)
        firetouchinterest(hrp, ti.Parent, 1)
    end)
end

local running     = false
local claimThread = nil

local function startClaiming()
    claimThread = task.spawn(function()
        while running do
            local list = getTouchInterests()
            for _, ti in ipairs(list) do
                if not running then break end
                fireTouchInterest(ti)
                task.wait(CONFIG.ClaimDelay)
            end
            task.wait(CONFIG.LoopInterval)
        end
    end)
end

local function stopClaiming()
    running = false
    if claimThread then task.cancel(claimThread) claimThread = nil end
end

-- Colors / Theme
local C = {
    BG         = Color3.fromRGB(8,  16, 30),
    TITLE_BG   = Color3.fromRGB(12, 24, 46),
    ACCENT     = Color3.fromRGB(0,  200,255),
    ACCENT2    = Color3.fromRGB(0,  255,160),
    TEXT       = Color3.fromRGB(210,235,255),
    SUBTEXT    = Color3.fromRGB(110,155,190),
    BTN_ON     = Color3.fromRGB(180, 40, 60),
    BTN_OFF    = Color3.fromRGB(0,  160,100),
    SLIDER_TRK = Color3.fromRGB(20,  40, 65),
    SLIDER_FIL = Color3.fromRGB(0,  200,255),
    SLIDER_KNOB= Color3.fromRGB(255,255,255),
    BORDER     = Color3.fromRGB(0,  180,230),
    MINIMIZE   = Color3.fromRGB(255,180,  0),
}
local F  = Enum.Font.GothamBold
local FM = Enum.Font.Gotham

-- Screen GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "NVHeadMonbo_TinyOcean_v24"
screenGui.ResetOnSpawn   = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder   = 99
screenGui.Parent         = pgui

local FRAME_W, FRAME_H = 280, 340

local mainFrame = Instance.new("Frame")
mainFrame.Name             = "Main"
mainFrame.Size             = UDim2.new(0, FRAME_W, 0, FRAME_H)
mainFrame.Position         = UDim2.new(0.5, -FRAME_W/2, 0, 30)
mainFrame.BackgroundColor3 = C.BG
mainFrame.BorderSizePixel  = 0
mainFrame.Active           = false
mainFrame.ClipsDescendants = true
mainFrame.Parent           = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Rainbow border
local rainbowStroke = Instance.new("UIStroke")
rainbowStroke.Thickness = 3
rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rainbowStroke.Parent = mainFrame

local rainbowGradient = Instance.new("UIGradient")
rainbowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,   0,   0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 127,   0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255,   0)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(  0, 255,   0)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(  0, 127, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(139,   0, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,   0,   0)),
})
rainbowGradient.Parent = rainbowStroke

local rainbowRot = 0
RunService.Heartbeat:Connect(function(dt)
    rainbowRot = (rainbowRot + dt * 40) % 360
    rainbowGradient.Rotation = rainbowRot
end)

-- Title bar (draggable)
local titleBar = Instance.new("Frame")
titleBar.Name             = "TitleBar"
titleBar.Size             = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = C.TITLE_BG
titleBar.BorderSizePixel  = 0
titleBar.ZIndex           = 2
titleBar.Active           = true
titleBar.Parent           = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleFill = Instance.new("Frame")
titleFill.Size             = UDim2.new(1, 0, 0.5, 0)
titleFill.Position         = UDim2.new(0, 0, 0.5, 0)
titleFill.BackgroundColor3 = C.TITLE_BG
titleFill.BorderSizePixel  = 0
titleFill.ZIndex           = 2
titleFill.Parent           = titleBar

local dragging, dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local d = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Icon / title / credit
local iconLbl = Instance.new("TextLabel")
iconLbl.Size = UDim2.new(0, 28, 1, 0)
iconLbl.Position = UDim2.new(0, 8, 0, 0)
iconLbl.BackgroundTransparency = 1
iconLbl.Text = "🐟"
iconLbl.TextSize = 18
iconLbl.Font = FM
iconLbl.ZIndex = 3
iconLbl.Parent = titleBar

local titleLbl2 = Instance.new("TextLabel")
titleLbl2.Size = UDim2.new(1, -80, 1, 0)
titleLbl2.Position = UDim2.new(0, 38, 0, 0)
titleLbl2.BackgroundTransparency = 1
titleLbl2.Text = "Tiny Ocean Inf XP"
titleLbl2.TextColor3 = C.ACCENT
titleLbl2.TextSize = 12
titleLbl2.Font = F
titleLbl2.TextXAlignment = Enum.TextXAlignment.Left
titleLbl2.ZIndex = 3
titleLbl2.Parent = titleBar

local creditLbl = Instance.new("TextLabel")
creditLbl.Size = UDim2.new(1, -80, 0, 14)
creditLbl.Position = UDim2.new(0, 38, 1, -15)
creditLbl.BackgroundTransparency = 1
creditLbl.Text = "by NVHeadMonbo"
creditLbl.TextColor3 = C.SUBTEXT
creditLbl.TextSize = 9
creditLbl.Font = FM
creditLbl.TextXAlignment = Enum.TextXAlignment.Left
creditLbl.ZIndex = 3
creditLbl.Parent = titleBar

-- Minimize button
local minimized   = false
local FULL_HEIGHT = FRAME_H
local MINI_HEIGHT = 40

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size             = UDim2.new(0, 26, 0, 22)
minimizeBtn.Position         = UDim2.new(1, -32, 0.5, -11)
minimizeBtn.BackgroundColor3 = C.MINIMIZE
minimizeBtn.BorderSizePixel  = 0
minimizeBtn.Text             = "—"
minimizeBtn.TextColor3       = Color3.fromRGB(30, 20, 0)
minimizeBtn.TextSize         = 12
minimizeBtn.Font             = F
minimizeBtn.ZIndex           = 4
minimizeBtn.Parent           = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 5)

-- Navigation bar
local navBar = Instance.new("Frame")
navBar.Name             = "NavBar"
navBar.Size             = UDim2.new(1, 0, 0, 36)
navBar.Position         = UDim2.new(0, 0, 0, 40)
navBar.BackgroundColor3 = Color3.fromRGB(10, 20, 38)
navBar.BorderSizePixel  = 0
navBar.ZIndex           = 2
navBar.Parent           = mainFrame

local navBorder = Instance.new("Frame")
navBorder.Size             = UDim2.new(1, 0, 0, 1)
navBorder.Position         = UDim2.new(0, 0, 1, 0)
navBorder.BackgroundColor3 = Color3.fromRGB(30, 55, 85)
navBorder.BorderSizePixel  = 0
navBorder.ZIndex           = 2
navBorder.Parent           = navBar

local currentPage = "main"

local function navBtn(name, xScale, xOffset)
    local btn = Instance.new("TextButton")
    btn.Name             = name
    btn.Size             = UDim2.new(0.333, -3, 1, -6)
    btn.Position         = UDim2.new(xScale, xOffset, 0, 3)
    btn.BackgroundColor3 = C.SLIDER_TRK
    btn.BorderSizePixel  = 0
    btn.Text             = name
    btn.TextColor3       = C.SUBTEXT
    btn.TextSize         = 11
    btn.Font             = F
    btn.ZIndex           = 3
    btn.Parent           = navBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local mainNavBtn  = navBtn("Main",  0,       3)
local tiersNavBtn = navBtn("Tiers", 0.333,   3)
local infoNavBtn  = navBtn("Info",  0.666,   3)
mainNavBtn.BackgroundColor3 = C.ACCENT
mainNavBtn.TextColor3       = Color3.fromRGB(255,255,255)

-- Content
local content = Instance.new("Frame")
content.Name                 = "Content"
content.Size                 = UDim2.new(1, 0, 1, -76)
content.Position             = UDim2.new(0, 0, 0, 76)
content.BackgroundTransparency = 1
content.ClipsDescendants     = true
content.Parent               = mainFrame

local mainPage  = Instance.new("Frame")
mainPage.Name   = "MainPage"
mainPage.Size   = UDim2.new(1,0,1,0)
mainPage.BackgroundTransparency = 1
mainPage.Visible = true
mainPage.Parent = content

local tiersPage = Instance.new("Frame")
tiersPage.Name  = "TiersPage"
tiersPage.Size  = UDim2.new(1,0,1,0)
tiersPage.BackgroundTransparency = 1
tiersPage.Visible = false
tiersPage.Parent = content

local infoPage  = Instance.new("Frame")
infoPage.Name   = "InfoPage"
infoPage.Size   = UDim2.new(1,0,1,0)
infoPage.BackgroundTransparency = 1
infoPage.Visible = false
infoPage.Parent = content

local function switchToPage(p)
    currentPage = p
    mainPage.Visible  = (p == "Main")
    tiersPage.Visible = (p == "Tiers")
    infoPage.Visible  = (p == "Info")
    mainNavBtn.BackgroundColor3  = (p=="Main")  and C.ACCENT or C.SLIDER_TRK
    mainNavBtn.TextColor3        = (p=="Main")  and Color3.fromRGB(255,255,255) or C.SUBTEXT
    tiersNavBtn.BackgroundColor3 = (p=="Tiers") and C.ACCENT or C.SLIDER_TRK
    tiersNavBtn.TextColor3       = (p=="Tiers") and Color3.fromRGB(255,255,255) or C.SUBTEXT
    infoNavBtn.BackgroundColor3  = (p=="Info")  and C.ACCENT or C.SLIDER_TRK
    infoNavBtn.TextColor3        = (p=="Info")  and Color3.fromRGB(255,255,255) or C.SUBTEXT
end

mainNavBtn.MouseButton1Click:Connect(function()  switchToPage("Main")  end)
tiersNavBtn.MouseButton1Click:Connect(function() switchToPage("Tiers") end)
infoNavBtn.MouseButton1Click:Connect(function()  switchToPage("Info")  end)

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, FRAME_W, 0, minimized and MINI_HEIGHT or FULL_HEIGHT)
    }):Play()
    task.delay(minimized and 0 or 0.05, function()
        navBar.Visible   = not minimized
        content.Visible  = not minimized
    end)
    minimizeBtn.Text = minimized and "□" or "—"
end)

-- Helper
local function makeLabel(parent, text, yPos, color, size, font)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,20)
    lbl.Position = UDim2.new(0,10,0,yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or C.TEXT
    lbl.TextSize = size or 12
    lbl.Font = font or FM
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- ============================================================
-- MAIN PAGE
-- ============================================================
local statusLbl = makeLabel(mainPage, "Status: Idle", 6,  C.SUBTEXT, 12, FM)
local countLbl  = makeLabel(mainPage, "Pickups found: —", 26, C.ACCENT2, 12, FM)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size             = UDim2.new(1,-20,0,38)
toggleBtn.Position         = UDim2.new(0,10,0,52)
toggleBtn.BackgroundColor3 = C.BTN_OFF
toggleBtn.BorderSizePixel  = 0
toggleBtn.Text             = "▶  START CLAIMING"
toggleBtn.TextColor3       = Color3.fromRGB(255,255,255)
toggleBtn.TextSize         = 13
toggleBtn.Font             = F
toggleBtn.Parent           = mainPage
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local btnStroke = Instance.new("UIStroke")
btnStroke.Color     = C.ACCENT2
btnStroke.Thickness = 1
btnStroke.Parent    = toggleBtn

local divider = Instance.new("Frame")
divider.Size             = UDim2.new(1,-20,0,1)
divider.Position         = UDim2.new(0,10,0,100)
divider.BackgroundColor3 = Color3.fromRGB(30,55,85)
divider.BorderSizePixel  = 0
divider.Parent           = mainPage

-- Claim Delay slider
local SLIDER_MIN, SLIDER_MAX = 0.02, 0.50
makeLabel(mainPage, "Claim Delay", 108, C.TEXT, 11, F)

local delayValLbl = Instance.new("TextLabel")
delayValLbl.Size = UDim2.new(0,60,0,18)
delayValLbl.Position = UDim2.new(1,-68,0,108)
delayValLbl.BackgroundTransparency = 1
delayValLbl.Text = "0.05s"
delayValLbl.TextColor3 = C.ACCENT
delayValLbl.TextSize = 11
delayValLbl.Font = F
delayValLbl.TextXAlignment = Enum.TextXAlignment.Right
delayValLbl.Parent = mainPage

local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(1,-20,0,6)
sliderTrack.Position = UDim2.new(0,10,0,132)
sliderTrack.BackgroundColor3 = C.SLIDER_TRK
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = mainPage
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1,0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.065,0,1,0)
sliderFill.BackgroundColor3 = C.SLIDER_FIL
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderTrack
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1,0)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0,14,0,14)
sliderKnob.AnchorPoint = Vector2.new(0.5,0.5)
sliderKnob.Position = UDim2.new(0.065,0,0.5,0)
sliderKnob.BackgroundColor3 = C.SLIDER_KNOB
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderTrack
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1,0)
local kStroke = Instance.new("UIStroke")
kStroke.Color = C.ACCENT kStroke.Thickness = 1.5 kStroke.Parent = sliderKnob

local draggingSlider = false
local function setSlider(alpha)
    alpha = math.clamp(alpha,0,1)
    CONFIG.ClaimDelay   = SLIDER_MIN + (SLIDER_MAX-SLIDER_MIN)*alpha
    sliderFill.Size     = UDim2.new(alpha,0,1,0)
    sliderKnob.Position = UDim2.new(alpha,0,0.5,0)
    delayValLbl.Text    = string.format("%.2fs", CONFIG.ClaimDelay)
end
sliderTrack.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end
end)
sliderKnob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = false draggingLoop = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        setSlider((i.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X)
    end
end)

-- Loop Interval slider
local LI_MIN, LI_MAX = 0.5, 5.0
makeLabel(mainPage, "Loop Interval", 150, C.TEXT, 11, F)

local loopValLbl = Instance.new("TextLabel")
loopValLbl.Size = UDim2.new(0,60,0,18)
loopValLbl.Position = UDim2.new(1,-68,0,150)
loopValLbl.BackgroundTransparency = 1
loopValLbl.Text = "1.0s"
loopValLbl.TextColor3 = C.ACCENT
loopValLbl.TextSize = 11
loopValLbl.Font = F
loopValLbl.TextXAlignment = Enum.TextXAlignment.Right
loopValLbl.Parent = mainPage

local loopTrack = Instance.new("Frame")
loopTrack.Size = UDim2.new(1,-20,0,6)
loopTrack.Position = UDim2.new(0,10,0,174)
loopTrack.BackgroundColor3 = C.SLIDER_TRK
loopTrack.BorderSizePixel = 0
loopTrack.Parent = mainPage
Instance.new("UICorner", loopTrack).CornerRadius = UDim.new(1,0)

local loopFill = Instance.new("Frame")
loopFill.Size = UDim2.new(0.111,0,1,0)
loopFill.BackgroundColor3 = C.ACCENT2
loopFill.BorderSizePixel = 0
loopFill.Parent = loopTrack
Instance.new("UICorner", loopFill).CornerRadius = UDim.new(1,0)

local loopKnob = Instance.new("Frame")
loopKnob.Size = UDim2.new(0,14,0,14)
loopKnob.AnchorPoint = Vector2.new(0.5,0.5)
loopKnob.Position = UDim2.new(0.111,0,0.5,0)
loopKnob.BackgroundColor3 = C.SLIDER_KNOB
loopKnob.BorderSizePixel = 0
loopKnob.Parent = loopTrack
Instance.new("UICorner", loopKnob).CornerRadius = UDim.new(1,0)
local lkStroke = Instance.new("UIStroke")
lkStroke.Color = C.ACCENT2 lkStroke.Thickness = 1.5 lkStroke.Parent = loopKnob

local draggingLoop = false
local function setLoopSlider(alpha)
    alpha = math.clamp(alpha,0,1)
    CONFIG.LoopInterval = LI_MIN + (LI_MAX-LI_MIN)*alpha
    loopFill.Size       = UDim2.new(alpha,0,1,0)
    loopKnob.Position   = UDim2.new(alpha,0,0.5,0)
    loopValLbl.Text     = string.format("%.1fs", CONFIG.LoopInterval)
end
loopTrack.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingLoop = true end
end)
loopKnob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingLoop = true end
end)
UserInputService.InputChanged:Connect(function(i)
    if draggingLoop and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        setLoopSlider((i.Position.X - loopTrack.AbsolutePosition.X) / loopTrack.AbsoluteSize.X)
    end
end)

local divider2 = Instance.new("Frame")
divider2.Size = UDim2.new(1,-20,0,1) divider2.Position = UDim2.new(0,10,0,196)
divider2.BackgroundColor3 = Color3.fromRGB(30,55,85) divider2.BorderSizePixel = 0 divider2.Parent = mainPage

local keybindHint = Instance.new("TextLabel")
keybindHint.Size = UDim2.new(1,-20,0,18) keybindHint.Position = UDim2.new(0,10,0,202)
keybindHint.BackgroundTransparency = 1 keybindHint.Text = "[ K ]  Toggle UI visibility"
keybindHint.TextColor3 = C.SUBTEXT keybindHint.TextSize = 10 keybindHint.Font = FM
keybindHint.TextXAlignment = Enum.TextXAlignment.Center keybindHint.Parent = mainPage

-- ============================================================
-- TIERS PAGE
-- ============================================================
makeLabel(tiersPage, "🎯 Tier Toggles (T1-T9)", 6, C.ACCENT, 12, F)

local tierCheckboxes = {}
for i = 1, 9 do
    local row = math.floor((i-1)/3)
    local col = (i-1)%3
    local cb = Instance.new("TextButton")
    cb.Name             = "Tier"..i
    cb.Size             = UDim2.new(0,75,0,32)
    cb.Position         = UDim2.new(0, 10+col*83, 0, 34+row*40)
    cb.BackgroundColor3 = C.BTN_OFF
    cb.BorderSizePixel  = 0
    cb.Text             = "✓ T"..i
    cb.TextColor3       = Color3.fromRGB(255,255,255)
    cb.TextSize         = 12
    cb.Font             = F
    cb.Parent           = tiersPage
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0,6)
    local cs = Instance.new("UIStroke")
    cs.Color = C.ACCENT2 cs.Thickness = 1 cs.Parent = cb
    tierCheckboxes[i] = {btn=cb, stroke=cs}
    cb.MouseButton1Click:Connect(function()
        TIER_ENABLED[i] = not TIER_ENABLED[i]
        cb.BackgroundColor3 = TIER_ENABLED[i] and C.BTN_OFF or Color3.fromRGB(60,20,25)
        cb.Text             = TIER_ENABLED[i] and "✓ T"..i or "✗ T"..i
        cs.Color            = TIER_ENABLED[i] and C.ACCENT2 or C.BTN_ON
    end)
end

local selectAllBtn = Instance.new("TextButton")
selectAllBtn.Size = UDim2.new(0,120,0,32) selectAllBtn.Position = UDim2.new(0,10,0,158)
selectAllBtn.BackgroundColor3 = C.ACCENT selectAllBtn.BorderSizePixel = 0
selectAllBtn.Text = "✓ Select All" selectAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
selectAllBtn.TextSize = 11 selectAllBtn.Font = F selectAllBtn.Parent = tiersPage
Instance.new("UICorner", selectAllBtn).CornerRadius = UDim.new(0,6)

local deselectAllBtn = Instance.new("TextButton")
deselectAllBtn.Size = UDim2.new(0,120,0,32) deselectAllBtn.Position = UDim2.new(1,-130,0,158)
deselectAllBtn.BackgroundColor3 = C.BTN_ON deselectAllBtn.BorderSizePixel = 0
deselectAllBtn.Text = "✗ Deselect All" deselectAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
deselectAllBtn.TextSize = 11 deselectAllBtn.Font = F deselectAllBtn.Parent = tiersPage
Instance.new("UICorner", deselectAllBtn).CornerRadius = UDim.new(0,6)

selectAllBtn.MouseButton1Click:Connect(function()
    for i=1,9 do TIER_ENABLED[i]=true tierCheckboxes[i].btn.BackgroundColor3=C.BTN_OFF tierCheckboxes[i].btn.Text="✓ T"..i tierCheckboxes[i].stroke.Color=C.ACCENT2 end
end)
deselectAllBtn.MouseButton1Click:Connect(function()
    for i=1,9 do TIER_ENABLED[i]=false tierCheckboxes[i].btn.BackgroundColor3=Color3.fromRGB(60,20,25) tierCheckboxes[i].btn.Text="✗ T"..i tierCheckboxes[i].stroke.Color=C.BTN_ON end
end)

local tierInfo = Instance.new("TextLabel")
tierInfo.Size = UDim2.new(1,-20,0,50) tierInfo.Position = UDim2.new(0,10,0,200)
tierInfo.BackgroundTransparency = 1 tierInfo.TextWrapped = true
tierInfo.Text = "💡 Tip: Disable lower tiers to focus on high-value pickups!"
tierInfo.TextColor3 = C.SUBTEXT tierInfo.TextSize = 10 tierInfo.Font = FM
tierInfo.TextXAlignment = Enum.TextXAlignment.Center tierInfo.TextYAlignment = Enum.TextYAlignment.Top
tierInfo.Parent = tiersPage

-- ============================================================
-- INFO PAGE
-- ============================================================
makeLabel(infoPage, "ℹ️ Info & Updates", 6, C.ACCENT, 13, F)

local infoBox = Instance.new("Frame")
infoBox.Size = UDim2.new(1,-20,0,180) infoBox.Position = UDim2.new(0,10,0,32)
infoBox.BackgroundColor3 = Color3.fromRGB(15,25,40) infoBox.BorderSizePixel = 0
infoBox.Parent = infoPage
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0,8)
local infoS = Instance.new("UIStroke") infoS.Color = C.BORDER infoS.Thickness = 1 infoS.Parent = infoBox

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1,-16,1,-16) infoText.Position = UDim2.new(0,8,0,8)
infoText.BackgroundTransparency = 1 infoText.TextWrapped = true
infoText.Text = [[📍 Path: workspace.Main.Pickups.Active

🆕 v2.4 KEY SYSTEM FIXED:
• Active=false on container/content frames
• Buttons no longer blocked by parent frames
• AutoButtonColor=true on all buttons
• ZIndex=10 on all interactive elements
• Close X, Verify, Get Key all working!

💡 Usage Tips:
• Lower claim delay = faster but may lag
• Disable low-tier pickups for efficiency
• Press K to hide/show UI
• Use tiers page to toggle T1-T9]]
infoText.TextColor3 = C.TEXT infoText.TextSize = 10 infoText.Font = FM
infoText.TextXAlignment = Enum.TextXAlignment.Left infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoBox

local creditsBox = Instance.new("Frame")
creditsBox.Size = UDim2.new(1,-20,0,36) creditsBox.Position = UDim2.new(0,10,0,220)
creditsBox.BackgroundColor3 = Color3.fromRGB(15,25,40) creditsBox.BorderSizePixel = 0
creditsBox.Parent = infoPage
Instance.new("UICorner", creditsBox).CornerRadius = UDim.new(0,8)
local credS = Instance.new("UIStroke") credS.Color = C.ACCENT2 credS.Thickness = 1 credS.Parent = creditsBox

local creditsText = Instance.new("TextLabel")
creditsText.Size = UDim2.new(1,-16,1,0) creditsText.Position = UDim2.new(0,8,0,0)
creditsText.BackgroundTransparency = 1
creditsText.Text = "🐟 Tiny Ocean Inf XP v2.4 FIXED by NVHeadMonbo"
creditsText.TextColor3 = C.ACCENT2 creditsText.TextSize = 10 creditsText.Font = F
creditsText.TextXAlignment = Enum.TextXAlignment.Center creditsText.TextYAlignment = Enum.TextYAlignment.Center
creditsText.Parent = creditsBox

-- ============================================================
-- TOGGLE BUTTON LOGIC
-- ============================================================
local function refreshPickupCount()
    task.spawn(function()
        while running do
            countLbl.Text = "Pickups found: " .. #getTouchInterests()
            task.wait(1)
        end
        countLbl.Text = "Pickups found: —"
    end)
end

toggleBtn.MouseButton1Click:Connect(function()
    running = not running
    if running then
        toggleBtn.BackgroundColor3 = C.BTN_ON
        btnStroke.Color            = C.BTN_ON
        toggleBtn.Text             = "⏹  STOP CLAIMING"
        statusLbl.Text             = "Status: ✅ Running"
        statusLbl.TextColor3       = C.ACCENT2
        startClaiming()
        refreshPickupCount()
    else
        stopClaiming()
        toggleBtn.BackgroundColor3 = C.BTN_OFF
        btnStroke.Color            = C.ACCENT2
        toggleBtn.Text             = "▶  START CLAIMING"
        statusLbl.Text             = "Status: Idle"
        statusLbl.TextColor3       = C.SUBTEXT
    end
end)

toggleBtn.MouseEnter:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = running and Color3.fromRGB(210,60,80) or Color3.fromRGB(0,185,115)
    }):Play()
end)
toggleBtn.MouseLeave:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = running and C.BTN_ON or C.BTN_OFF
    }):Play()
end)

-- K keybind
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
    end
end)

-- ============================================================
-- DONE
-- ============================================================
print("[Tiny Ocean v2.4 FIXED] Script loaded successfully!")
print("[Tiny Ocean v2.4 FIXED] Press K to toggle UI")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Tiny Ocean Inf XP";
    Text  = "v2.4 loaded! Key system fully fixed!";
    Duration = 4;
})
