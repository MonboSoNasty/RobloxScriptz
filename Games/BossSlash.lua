-- ============================================================
-- MonboVerse Hub - Clicker Simulator
-- by NVHeadMonbo
-- v1.0 - DEV BUILD (Key System Disabled)
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
local KEY_SYSTEM_ENABLED = false  -- ⚠️ Change to true to enable key system

-- ============================================================
-- JUNKIE KEY SYSTEM (DISABLED DURING DEVELOPMENT)
-- ============================================================
if KEY_SYSTEM_ENABLED then
    print("[MonboVerse Hub] Loading Junkie Key System...")

    local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
    Junkie.service    = "Cuty"
    Junkie.identifier = "1037885"  -- ⚠️ REPLACE WITH YOUR JUNKIE IDENTIFIER
    Junkie.provider   = "MonboVerse Hub/Clicker Simulator"

    local options = {
        title       = "MonboVerse Hub",
        subtitle    = "by NVHeadMonbo",
        description = "Please complete key verification to use the script"
    }

    local function saveVerifiedKey(key)  pcall(function() writefile("monboverse_clicker_key.txt", key) end) end
    local function loadVerifiedKey()
        local ok, k = pcall(function() return readfile("monboverse_clicker_key.txt") end)
        return ok and k or nil
    end
    local function clearSavedKey() pcall(function() delfile("monboverse_clicker_key.txt") end) end

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

        container.Position = UDim2.new(0.5, 0, 0.5, 20)
        TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
    end

    function UI:createUI()
        self:buildUI()
        if not self.elements.closeButton then warn("[MonboVerse Hub] UI elements missing!") return end

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

    function UI:handleGetLink()
        local link = Junkie.get_key_link()
        if not link then
            self:updateStatus("System not initialized", KC.error, 3)
            return
        end

        local copied = false
        if setclipboard then
            pcall(function() setclipboard(link) copied = true end)
        end
        if not copied and Clipboard and Clipboard.set then
            pcall(function() Clipboard.set(link) copied = true end)
        end

        if copied then
            self:updateStatus("Link copied to clipboard!", KC.success, 3)
        else
            self:updateStatus("Could not copy — see console", KC.error, 5)
            print("[MonboVerse Hub] Get Key link: " .. link)
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

    getgenv().UI_CLOSED = false
    getgenv().SCRIPT_KEY = nil

    local ui = UI.new(options)
    ui:createUI()

    local savedKey = loadVerifiedKey()
    if savedKey then
        print("[MonboVerse Hub] Checking saved key...")
        local result = Junkie.check_key(savedKey)
        if result and result.valid then
            print("[MonboVerse Hub] ✓ Saved key verified!")
            getgenv().SCRIPT_KEY = savedKey
            ui:close()
        else
            print("[MonboVerse Hub] Saved key invalid, clearing...")
            clearSavedKey()
        end
    end

    if not getgenv().SCRIPT_KEY then
        print("[MonboVerse Hub] Waiting for key verification...")
        while not getgenv().UI_CLOSED do task.wait(0.1) end
    end

    if not getgenv().SCRIPT_KEY then
        warn("[MonboVerse Hub] ⚠ Key verification failed or cancelled")
        return
    end

    print("[MonboVerse Hub] ✓ Key verified! Loading main script...")
    task.wait(0.5)
else
    print("[MonboVerse Hub] ⚠ Key system is DISABLED (development mode)")
end

-- ============================================================
-- MAIN SCRIPT - Clicker Simulator
-- ============================================================

local Config = {
    UIVisible = true,
    Main = {
        Attack      = { Enabled = false, Intensity = 1, LastRun = 0, Delay = 0.1 },
        ClaimChest  = { Enabled = false, LastRun = 0, Delay = 1 }
    },
    Upgrades = {
        Weapon   = { Enabled = false, LastRun = 0, Delay = 1 },
        Speed    = { Enabled = false, LastRun = 0, Delay = 1 },
        CritC    = { Enabled = false, LastRun = 0, Delay = 1 },
        CritD    = { Enabled = false, LastRun = 0, Delay = 1 }
    },
    Rebirth = {
        AutoRebirth = { Enabled = false, LastRun = 0, Delay = 5 }
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
}
local F  = Enum.Font.GothamBold
local FM = Enum.Font.Gotham

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "MonboVerseHubGUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 99
ScreenGui.Parent         = PlayerGui

local FRAME_W, FRAME_H = 420, 540

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
rainbowStroke.Thickness = 4
rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rainbowStroke.Transparency = 0
rainbowStroke.Parent = MainFrame

local rainbowGrad = Instance.new("UIGradient")
rainbowGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,   0,   0)),
    ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 127,   0)),
    ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 255,   0)),
    ColorSequenceKeypoint.new(0.42, Color3.fromRGB(  0, 255,   0)),
    ColorSequenceKeypoint.new(0.57, Color3.fromRGB(  0, 255, 255)),
    ColorSequenceKeypoint.new(0.71, Color3.fromRGB(  0,   0, 255)),
    ColorSequenceKeypoint.new(0.85, Color3.fromRGB(138,  43, 226)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,   0,   0)),
})
rainbowGrad.Parent = rainbowStroke

task.spawn(function()
    local rot = 0
    while true do
        rot = (rot + 4) % 360
        rainbowGrad.Rotation = rot
        task.wait(0.03)
    end
end)

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
iconLbl.BackgroundTransparency = 1 iconLbl.Text = "⚔️"
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
CreditLbl.BackgroundTransparency = 1 CreditLbl.Text = "Clicker Simulator v1.0"
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

local mainBtn     = makeNavBtn("Main",     0,     3)
local upgradesBtn = makeNavBtn("Upgrades", 0.333, 3)
local rebirthBtn  = makeNavBtn("Rebirth",  0.666, 3)

mainBtn.BackgroundColor3 = C.ACCENT
mainBtn.TextColor3       = Color3.fromRGB(255, 255, 255)

local ContentArea = Instance.new("Frame")
ContentArea.Name                 = "ContentArea"
ContentArea.Size                 = UDim2.new(1, 0, 1, -78)
ContentArea.Position             = UDim2.new(0, 0, 0, 78)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants     = true
ContentArea.Parent               = MainFrame

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
MainLayout.Padding   = UDim.new(0, 8)
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainLayout.Parent    = MainPage

local MainPadding = Instance.new("UIPadding")
MainPadding.PaddingLeft   = UDim.new(0, 10)
MainPadding.PaddingRight  = UDim.new(0, 10)
MainPadding.PaddingTop    = UDim.new(0, 8)
MainPadding.PaddingBottom = UDim.new(0, 8)
MainPadding.Parent        = MainPage

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

local RebirthPage = Instance.new("Frame")
RebirthPage.Name                  = "RebirthPage"
RebirthPage.Size                  = UDim2.new(1, 0, 1, 0)
RebirthPage.BackgroundTransparency = 1
RebirthPage.Visible               = false
RebirthPage.Parent                = ContentArea

local function switchPage(page)
    MainPage.Visible     = (page == "Main")
    UpgradesPage.Visible = (page == "Upgrades")
    RebirthPage.Visible  = (page == "Rebirth")
    
    mainBtn.BackgroundColor3     = (page=="Main") and C.ACCENT or Color3.fromRGB(20,40,65)
    mainBtn.TextColor3           = (page=="Main") and Color3.fromRGB(255,255,255) or C.SUBTEXT
    
    upgradesBtn.BackgroundColor3 = (page=="Upgrades") and C.ACCENT or Color3.fromRGB(20,40,65)
    upgradesBtn.TextColor3       = (page=="Upgrades") and Color3.fromRGB(255,255,255) or C.SUBTEXT
    
    rebirthBtn.BackgroundColor3  = (page=="Rebirth") and C.ACCENT or Color3.fromRGB(20,40,65)
    rebirthBtn.TextColor3        = (page=="Rebirth") and Color3.fromRGB(255,255,255) or C.SUBTEXT
end

mainBtn.MouseButton1Click:Connect(function() switchPage("Main") end)
upgradesBtn.MouseButton1Click:Connect(function() switchPage("Upgrades") end)
rebirthBtn.MouseButton1Click:Connect(function() switchPage("Rebirth") end)

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
-- ATTACK CARD WITH INTENSITY
-- ============================================================
local function CreateAttackCard()
    local Card = Instance.new("Frame")
    Card.Name             = "AttackCard"
    Card.Size             = UDim2.new(1, 0, 0, 118)
    Card.BackgroundColor3 = C.CARD
    Card.BorderSizePixel  = 0
    Card.Parent           = MainPage
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(20,45,75) cardStroke.Thickness = 1 cardStroke.Parent = Card

    local NameLbl = Instance.new("TextLabel")
    NameLbl.Size = UDim2.new(1,-80,0,20) NameLbl.Position = UDim2.new(0,12,0,10)
    NameLbl.BackgroundTransparency = 1 NameLbl.Text = "Auto Attack"
    NameLbl.TextColor3 = C.TEXT NameLbl.TextSize = 13
    NameLbl.Font = F NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.Parent = Card

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

    local delayLabel = Instance.new("TextLabel")
    delayLabel.Size = UDim2.new(0.5,-8,0,16) delayLabel.Position = UDim2.new(0,12,0,38)
    delayLabel.BackgroundTransparency = 1 delayLabel.Text = "Delay"
    delayLabel.TextColor3 = C.SUBTEXT delayLabel.TextSize = 10
    delayLabel.Font = FM delayLabel.TextXAlignment = Enum.TextXAlignment.Left
    delayLabel.Parent = Card

    local DelayValue = Instance.new("TextLabel")
    DelayValue.Size = UDim2.new(0.5,-8,0,16) DelayValue.Position = UDim2.new(0.5,4,0,38)
    DelayValue.BackgroundTransparency = 1 DelayValue.Text = "0.10s"
    DelayValue.TextColor3 = C.ACCENT DelayValue.TextSize = 10
    DelayValue.Font = F DelayValue.TextXAlignment = Enum.TextXAlignment.Right
    DelayValue.Parent = Card

    local DelaySlider = Instance.new("Frame")
    DelaySlider.Size = UDim2.new(1,-24,0,4) DelaySlider.Position = UDim2.new(0,12,0,58)
    DelaySlider.BackgroundColor3 = Color3.fromRGB(20, 40, 65) DelaySlider.BorderSizePixel = 0
    DelaySlider.Parent = Card
    Instance.new("UICorner", DelaySlider).CornerRadius = UDim.new(1,0)

    local DelayFill = Instance.new("Frame")
    DelayFill.Size = UDim2.new(0.01,0,1,0) DelayFill.BackgroundColor3 = C.ACCENT
    DelayFill.BorderSizePixel = 0 DelayFill.Parent = DelaySlider
    Instance.new("UICorner", DelayFill).CornerRadius = UDim.new(1,0)

    local DelayButton = Instance.new("TextButton")
    DelayButton.Size = UDim2.new(1,0,1,12) DelayButton.Position = UDim2.new(0,0,0,-6)
    DelayButton.BackgroundTransparency = 1 DelayButton.Text = ""
    DelayButton.Parent = DelaySlider

    -- Intensity
    local intensityLabel = Instance.new("TextLabel")
    intensityLabel.Size = UDim2.new(0.5,-8,0,16) intensityLabel.Position = UDim2.new(0,12,0,72)
    intensityLabel.BackgroundTransparency = 1 intensityLabel.Text = "Intensity"
    intensityLabel.TextColor3 = C.SUBTEXT intensityLabel.TextSize = 10
    intensityLabel.Font = FM intensityLabel.TextXAlignment = Enum.TextXAlignment.Left
    intensityLabel.Parent = Card

    local IntensityValue = Instance.new("TextLabel")
    IntensityValue.Size = UDim2.new(0.5,-8,0,16) IntensityValue.Position = UDim2.new(0.5,4,0,72)
    IntensityValue.BackgroundTransparency = 1 IntensityValue.Text = "1x"
    IntensityValue.TextColor3 = C.PURPLE IntensityValue.TextSize = 10
    IntensityValue.Font = F IntensityValue.TextXAlignment = Enum.TextXAlignment.Right
    IntensityValue.Parent = Card

    local IntensitySlider = Instance.new("Frame")
    IntensitySlider.Size = UDim2.new(1,-24,0,4) IntensitySlider.Position = UDim2.new(0,12,0,92)
    IntensitySlider.BackgroundColor3 = Color3.fromRGB(20, 40, 65) IntensitySlider.BorderSizePixel = 0
    IntensitySlider.Parent = Card
    Instance.new("UICorner", IntensitySlider).CornerRadius = UDim.new(1,0)

    local IntensityFill = Instance.new("Frame")
    IntensityFill.Size = UDim2.new(0,0,1,0) IntensityFill.BackgroundColor3 = C.PURPLE
    IntensityFill.BorderSizePixel = 0 IntensityFill.Parent = IntensitySlider
    Instance.new("UICorner", IntensityFill).CornerRadius = UDim.new(1,0)

    local IntensityButton = Instance.new("TextButton")
    IntensityButton.Size = UDim2.new(1,0,1,12) IntensityButton.Position = UDim2.new(0,0,0,-6)
    IntensityButton.BackgroundTransparency = 1 IntensityButton.Text = ""
    IntensityButton.Parent = IntensitySlider

    return {
        Card = Card,
        ToggleButton = ToggleBtn,
        DelaySlider = DelaySlider,
        DelayFill = DelayFill,
        DelayButton = DelayButton,
        DelayValue = DelayValue,
        IntensitySlider = IntensitySlider,
        IntensityFill = IntensityFill,
        IntensityButton = IntensityButton,
        IntensityValue = IntensityValue,
    }
end

-- ============================================================
-- SIMPLE TOGGLE CARD
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
        DelayValue.Size = UDim2.new(0.5,-8,0,16) DelayValue.Position = UDim2.new(0.5,4,0,38)
        DelayValue.BackgroundTransparency = 1 DelayValue.Text = "1.0s"
        DelayValue.TextColor3 = C.ACCENT DelayValue.TextSize = 10
        DelayValue.Font = F DelayValue.TextXAlignment = Enum.TextXAlignment.Right
        DelayValue.Parent = Card

        DelaySlider = Instance.new("Frame")
        DelaySlider.Size = UDim2.new(1,-24,0,4) DelaySlider.Position = UDim2.new(0,12,0,58)
        DelaySlider.BackgroundColor3 = Color3.fromRGB(20, 40, 65) DelaySlider.BorderSizePixel = 0
        DelaySlider.Parent = Card
        Instance.new("UICorner", DelaySlider).CornerRadius = UDim.new(1,0)

        DelayFill = Instance.new("Frame")
        DelayFill.Size = UDim2.new(0.1,0,1,0) DelayFill.BackgroundColor3 = C.ACCENT
        DelayFill.BorderSizePixel = 0 DelayFill.Parent = DelaySlider
        Instance.new("UICorner", DelayFill).CornerRadius = UDim.new(1,0)

        DelayButton = Instance.new("TextButton")
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

-- Build cards
local AttackCard      = CreateAttackCard()
local ClaimChestCard  = CreateToggleCard("Claim Chest", MainPage, Config.Main.ClaimChest, true)

local WeaponCard = CreateToggleCard("Weapon Upgrade", UpgradesPage, Config.Upgrades.Weapon, true)
local SpeedCard  = CreateToggleCard("Speed Upgrade",  UpgradesPage, Config.Upgrades.Speed,  true)
local CritCCard  = CreateToggleCard("Critical % Upgrade", UpgradesPage, Config.Upgrades.CritC, true)
local CritDCard  = CreateToggleCard("Critical Damage Upgrade", UpgradesPage, Config.Upgrades.CritD, true)

local RebirthCard = CreateToggleCard("Auto Rebirth", RebirthPage, Config.Rebirth.AutoRebirth, true)

-- ============================================================
-- SLIDER SETUP FUNCTIONS
-- ============================================================
local function SetupDelaySlider(sliderFrame, fillFrame, valueLabel, config, property)
    local button = sliderFrame:FindFirstChild("Button")
    local draggingSlider = false

    local function updateSlider(input)
        local sizeX = sliderFrame.AbsoluteSize.X
        local posX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sizeX)
        local percent = posX / sizeX
        fillFrame.Size = UDim2.new(percent, 0, 1, 0)
        local v = 0.1 + percent * 9.9
        config[property] = math.floor(v * 10) / 10
        valueLabel.Text = string.format("%.1fs", config[property])
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

local function SetupAttackDelaySlider(sliderFrame, fillFrame, valueLabel, config, property)
    local button = sliderFrame:FindFirstChild("Button")
    local draggingSlider = false

    local function updateSlider(input)
        local sizeX = sliderFrame.AbsoluteSize.X
        local posX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sizeX)
        local percent = posX / sizeX
        fillFrame.Size = UDim2.new(percent, 0, 1, 0)
        local v = 0.01 + percent * 0.99
        config[property] = math.floor(v * 100) / 100
        valueLabel.Text = string.format("%.2fs", config[property])
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
    local button = sliderFrame:FindFirstChild("Button")
    local draggingSlider = false

    local function updateSlider(input)
        local sizeX = sliderFrame.AbsoluteSize.X
        local posX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sizeX)
        local percent = posX / sizeX
        fillFrame.Size = UDim2.new(percent, 0, 1, 0)
        local v = math.max(1, math.floor(1 + percent * 24))
        config.Intensity = v
        valueLabel.Text = v .. "x"
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

-- Setup sliders
SetupAttackDelaySlider(AttackCard.DelaySlider, AttackCard.DelayFill, AttackCard.DelayValue, Config.Main.Attack, "Delay")
SetupIntensitySlider(AttackCard.IntensitySlider, AttackCard.IntensityFill, AttackCard.IntensityValue, Config.Main.Attack)

SetupDelaySlider(ClaimChestCard.DelaySlider, ClaimChestCard.DelayFill, ClaimChestCard.DelayValue, Config.Main.ClaimChest, "Delay")

SetupDelaySlider(WeaponCard.DelaySlider, WeaponCard.DelayFill, WeaponCard.DelayValue, Config.Upgrades.Weapon, "Delay")
SetupDelaySlider(SpeedCard.DelaySlider, SpeedCard.DelayFill, SpeedCard.DelayValue, Config.Upgrades.Speed, "Delay")
SetupDelaySlider(CritCCard.DelaySlider, CritCCard.DelayFill, CritCCard.DelayValue, Config.Upgrades.CritC, "Delay")
SetupDelaySlider(CritDCard.DelaySlider, CritDCard.DelayFill, CritDCard.DelayValue, Config.Upgrades.CritD, "Delay")

SetupDelaySlider(RebirthCard.DelaySlider, RebirthCard.DelayFill, RebirthCard.DelayValue, Config.Rebirth.AutoRebirth, "Delay")

-- ============================================================
-- TOGGLE BUTTONS
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

SetupToggleButton(AttackCard.ToggleButton, Config.Main.Attack)
SetupToggleButton(ClaimChestCard.ToggleButton, Config.Main.ClaimChest)
SetupToggleButton(WeaponCard.ToggleButton, Config.Upgrades.Weapon)
SetupToggleButton(SpeedCard.ToggleButton, Config.Upgrades.Speed)
SetupToggleButton(CritCCard.ToggleButton, Config.Upgrades.CritC)
SetupToggleButton(CritDCard.ToggleButton, Config.Upgrades.CritD)
SetupToggleButton(RebirthCard.ToggleButton, Config.Rebirth.AutoRebirth)

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
-- HEARTBEAT (Game Logic)
-- ============================================================
RunService.Heartbeat:Connect(function()
    local t = tick()

    -- Auto Attack with Intensity
    if Config.Main.Attack.Enabled then
        if t - Config.Main.Attack.LastRun >= Config.Main.Attack.Delay then
            Config.Main.Attack.LastRun = t
            for i = 1, Config.Main.Attack.Intensity do
                task.spawn(function()
                    pcall(function()
                        local args = { true }
                        ReplicatedStorage:WaitForChild("Events"):WaitForChild("Tap"):FireServer(unpack(args))
                    end)
                end)
                if i < Config.Main.Attack.Intensity then
                    task.wait(0.01)
                end
            end
        end
    end

    -- Claim Chest
    if Config.Main.ClaimChest.Enabled then
        if t - Config.Main.ClaimChest.LastRun >= Config.Main.ClaimChest.Delay then
            Config.Main.ClaimChest.LastRun = t
            task.spawn(function()
                pcall(function()
                    ReplicatedStorage:WaitForChild("Events"):WaitForChild("ClaimChest"):FireServer()
                end)
            end)
        end
    end

    -- Weapon Upgrade
    if Config.Upgrades.Weapon.Enabled then
        if t - Config.Upgrades.Weapon.LastRun >= Config.Upgrades.Weapon.Delay then
            Config.Upgrades.Weapon.LastRun = t
            task.spawn(function()
                pcall(function()
                    local args = { "Weapon", -1 }
                    ReplicatedStorage:WaitForChild("Events"):WaitForChild("Upgrade"):FireServer(unpack(args))
                end)
            end)
        end
    end

    -- Speed Upgrade
    if Config.Upgrades.Speed.Enabled then
        if t - Config.Upgrades.Speed.LastRun >= Config.Upgrades.Speed.Delay then
            Config.Upgrades.Speed.LastRun = t
            task.spawn(function()
                pcall(function()
                    local args = { "Speed", -1 }
                    ReplicatedStorage:WaitForChild("Events"):WaitForChild("Upgrade"):FireServer(unpack(args))
                end)
            end)
        end
    end

    -- Critical % Upgrade
    if Config.Upgrades.CritC.Enabled then
        if t - Config.Upgrades.CritC.LastRun >= Config.Upgrades.CritC.Delay then
            Config.Upgrades.CritC.LastRun = t
            task.spawn(function()
                pcall(function()
                    local args = { "CritC", -1 }
                    ReplicatedStorage:WaitForChild("Events"):WaitForChild("Upgrade"):FireServer(unpack(args))
                end)
            end)
        end
    end

    -- Critical Damage Upgrade
    if Config.Upgrades.CritD.Enabled then
        if t - Config.Upgrades.CritD.LastRun >= Config.Upgrades.CritD.Delay then
            Config.Upgrades.CritD.LastRun = t
            task.spawn(function()
                pcall(function()
                    local args = { "CritD", -1 }
                    ReplicatedStorage:WaitForChild("Events"):WaitForChild("Upgrade"):FireServer(unpack(args))
                end)
            end)
        end
    end

    -- Auto Rebirth
    if Config.Rebirth.AutoRebirth.Enabled then
        if t - Config.Rebirth.AutoRebirth.LastRun >= Config.Rebirth.AutoRebirth.Delay then
            Config.Rebirth.AutoRebirth.LastRun = t
            task.spawn(function()
                pcall(function()
                    ReplicatedStorage:WaitForChild("Events"):WaitForChild("Prestige"):FireServer()
                end)
            end)
        end
    end
end)

print("[MonboVerse Hub - Clicker Simulator v1.0] ✅ Loaded!")
print("⚔️ Auto Attack with Intensity (1x-25x)")
print("📦 Claim Chest Auto")
print("⬆️ 4 Auto Upgrades (Weapon, Speed, Crit%, CritDMG)")
print("♻️ Auto Rebirth")
print("Press K to toggle UI")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title    = "MonboVerse Hub";
    Text     = "Clicker Simulator v1.0 Loaded!";
    Duration = 5;
})
