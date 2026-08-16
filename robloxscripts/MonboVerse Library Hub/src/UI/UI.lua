-- MonboVerse Library Hub :: UI :: shared design system — Tiny Ocean windows, rainbow borders, drag, minimize, cards, sliders, toasts, nav, blur

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local UI = {}

local C = {}
C.BG = Color3.fromRGB(8, 16, 30)
C.TITLE_BG = Color3.fromRGB(12, 24, 46)
C.ACCENT = Color3.fromRGB(0, 200, 255)
C.ACCENT2 = Color3.fromRGB(0, 255, 160)
C.PURPLE = Color3.fromRGB(88, 101, 242)
C.TEXT = Color3.fromRGB(210, 235, 255)
C.SUBTEXT = Color3.fromRGB(110, 155, 190)
C.BTN_ON = Color3.fromRGB(88, 101, 242)
C.BTN_OFF = Color3.fromRGB(40, 42, 50)
C.SLIDER_TRK = Color3.fromRGB(20, 40, 65)
C.SLIDER_FIL = Color3.fromRGB(0, 200, 255)
C.INTENSITY = Color3.fromRGB(255, 107, 107)
C.BORDER = Color3.fromRGB(0, 180, 230)
C.MINIMIZE = Color3.fromRGB(255, 180, 0)
C.CARD = Color3.fromRGB(14, 26, 46)
UI.Theme = C

local KC = {}
KC.background = Color3.fromRGB(13, 17, 23)
KC.surface = Color3.fromRGB(22, 27, 34)
KC.surfaceLight = Color3.fromRGB(30, 36, 44)
KC.primary = Color3.fromRGB(88, 166, 255)
KC.success = Color3.fromRGB(63, 185, 80)
KC.error = Color3.fromRGB(248, 81, 73)
KC.textPrimary = Color3.fromRGB(230, 237, 243)
KC.textSecondary = Color3.fromRGB(139, 148, 158)
KC.border = Color3.fromRGB(48, 54, 61)
C.KC = KC
UI.KC = KC

UI.Fonts = { Bold = Enum.Font.GothamBold, Medium = Enum.Font.Gotham }

local CARD_STROKE = Color3.fromRGB(20, 45, 75)
local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 71, 87)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 160, 60)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 236, 60)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 255, 120)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(60, 180, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(150, 100, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 71, 87))
})

local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

local function newTracker()
	local t = { _list = {} }
	function t:track(c)
		if c and c.Connect then table.insert(self._list, c) end
		return c
	end
	function t:cleanup()
		for _, c in ipairs(self._list) do
			pcall(function() c:Disconnect() end)
		end
		self._list = {}
	end
	return t
end
UI.newTracker = newTracker

local DefaultTracker = newTracker()
local CurrentTracker = nil

local function track(c)
	local t = CurrentTracker or DefaultTracker
	return t:track(c)
end

local function safeGuiParent()
	local ok, hui = pcall(gethui)
	if ok and hui then return hui end
	local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and cg then return cg end
	local ok3, pg = pcall(function()
		local lp = Players.LocalPlayer
		if lp then return lp:WaitForChild("PlayerGui", 2) end
		return nil
	end)
	if ok3 and pg then return pg end
	return nil
end

function UI.Stroke(frame, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(255, 255, 255)
	s.Thickness = thickness or 1
	s.Transparency = 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = frame
	return s
end

function UI.Label(parent, o)
	o = o or {}
	local l = Instance.new("TextLabel")
	l.Name = o.Name or "Label"
	l.BackgroundTransparency = 1
	l.Text = o.Text or ""
	l.Font = o.Font or UI.Fonts.Medium
	l.TextSize = o.TextSize or 13
	l.TextColor3 = o.Color or C.TEXT
	l.TextXAlignment = o.XAlign or Enum.TextXAlignment.Left
	l.TextYAlignment = o.YAlign or Enum.TextYAlignment.Center
	l.TextWrapped = o.Wrap == true
	l.TextTruncate = o.Truncate or Enum.TextTruncate.None
	l.Size = o.Size or UDim2.fromOffset(100, 20)
	l.Position = o.Position or UDim2.fromOffset(0, 0)
	l.AnchorPoint = o.Anchor or Vector2.zero
	l.ZIndex = o.ZIndex or 2
	l.Parent = parent
	return l
end

function UI.Button(parent, o)
	o = o or {}
	local b = Instance.new("TextButton")
	b.Name = o.Name or "Button"
	b.BackgroundColor3 = o.Color or C.BTN_ON
	b.Text = o.Text or ""
	b.Font = o.Font or UI.Fonts.Bold
	b.TextSize = o.TextSize or 13
	b.TextColor3 = o.TextColor or Color3.fromRGB(255, 255, 255)
	b.TextXAlignment = o.XAlign or Enum.TextXAlignment.Center
	b.AutoButtonColor = o.Hover ~= false
	b.Size = o.Size or UDim2.fromOffset(100, 30)
	b.Position = o.Position or UDim2.fromOffset(0, 0)
	b.AnchorPoint = o.Anchor or Vector2.zero
	b.ZIndex = o.ZIndex or 2
	b.Parent = parent
	if o.Radius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, o.Radius)
		corner.Parent = b
	end
	if o.StrokeColor then UI.Stroke(b, o.StrokeColor, o.StrokeThickness or 1) end
	return b
end

function UI.Panel(parent, o)
	o = o or {}
	local f = Instance.new("Frame")
	f.Name = o.Name or "Panel"
	f.BackgroundColor3 = o.Color or C.CARD
	f.Size = o.Size or UDim2.fromOffset(100, 60)
	f.Position = o.Position or UDim2.fromOffset(0, 0)
	f.AnchorPoint = o.Anchor or Vector2.zero
	f.BorderSizePixel = 0
	f.ZIndex = o.ZIndex or 1
	f.Parent = parent
	if o.Radius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, o.Radius)
		corner.Parent = f
	end
	if o.StrokeThickness ~= 0 then
		UI.Stroke(f, o.StrokeColor or CARD_STROKE, o.StrokeThickness or 1)
	end
	return f
end

function UI.Badge(parent, o)
	o = o or {}
	local w, h = o.Width or 88, o.Height or 20
	local b = UI.Panel(parent, { Name = o.Name or "Badge", Color = o.Color or C.ACCENT, Size = UDim2.fromOffset(w, h), Position = o.Position or UDim2.fromOffset(0, 0), AnchorPoint = o.Anchor or Vector2.zero, Radius = math.floor(h / 2), StrokeThickness = 0 })
	local l = UI.Label(b, { Text = o.Text or "", TextSize = o.TextSize or 11, Font = UI.Fonts.Bold, Color = o.TextColor or Color3.fromRGB(6, 14, 24), Size = UDim2.new(1, -8, 1, 0), Position = UDim2.fromOffset(4, 0) })
	l.TextXAlignment = Enum.TextXAlignment.Center
	return b
end

function UI.newWindow(cfg)
	cfg = cfg or {}
	local width = cfg.Width or 460
	local height = cfg.Height or 560
	local minHeight = cfg.MinHeight or 44
	local rainbow = cfg.RainbowBorder ~= false

	local tracker = newTracker()
	local prevTracker = CurrentTracker
	CurrentTracker = tracker

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MonboVerseHubWindow"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 20
	screenGui.Parent = safeGuiParent()

	local frame = Instance.new("Frame")
	frame.Name = "MainFrame"
	frame.Size = UDim2.fromOffset(width, height)
	frame.Position = UDim2.fromScale(0.5, 0.56)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = C.BG
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.Parent = screenGui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local stroke, grad
	if rainbow then
		stroke = UI.Stroke(frame, Color3.fromRGB(255, 255, 255), 3)
		grad = Instance.new("UIGradient")
		grad.Color = RAINBOW
		grad.Parent = stroke
		tracker:track(RunService.Heartbeat:Connect(function(dt)
			grad.Rotation = (grad.Rotation + dt * 40) % 360
		end))
	end

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 44)
	titleBar.BackgroundColor3 = C.TITLE_BG
	titleBar.BorderSizePixel = 0
	titleBar.Active = true
	titleBar.Parent = frame
	UI.Stroke(titleBar, Color3.fromRGB(16, 38, 66), 1)

	local iconLabel = UI.Label(titleBar, { Name = "Icon", Text = cfg.Icon or "🌌", TextSize = 20, Font = UI.Fonts.Bold, Position = UDim2.fromOffset(10, 2), Size = UDim2.fromOffset(40, 40), XAlign = Enum.TextXAlignment.Center })
	local titleLabel = UI.Label(titleBar, { Name = "Title", Text = cfg.Title or "MonboVerse", TextSize = 15, Font = UI.Fonts.Bold, Position = UDim2.fromOffset(54, 5), Size = UDim2.new(0, 320, 0, 18), Truncate = Enum.TextTruncate.AtEnd })
	local subtitleLabel = UI.Label(titleBar, { Name = "Subtitle", Text = cfg.Subtitle or "", TextSize = 10, Color = C.SUBTEXT, Position = UDim2.fromOffset(54, 24), Size = UDim2.new(0, 320, 0, 13), Truncate = Enum.TextTruncate.AtEnd })

	local minimizeBtn = UI.Button(titleBar, { Name = "Minimize", Text = "—", TextSize = 14, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -38, 0, 8), AnchorPoint = Vector2.new(1, 0), Color = C.TITLE_BG, TextColor = C.MINIMIZE, Radius = 6 })
	local closeBtn = UI.Button(titleBar, { Name = "Close", Text = "×", TextSize = 16, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -6, 0, 8), AnchorPoint = Vector2.new(1, 0), Color = C.TITLE_BG, TextColor = Color3.fromRGB(255, 120, 120), Radius = 6 })

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Position = UDim2.new(0, 0, 0, 44)
	body.Size = UDim2.new(1, 0, 1, -44)
	body.BackgroundColor3 = C.BG
	body.BorderSizePixel = 0
	body.Parent = frame

	local dragging = false
	local dragStart, startPos
	tracker:track(titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end))
	tracker:track(UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))
	tracker:track(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	local entrance = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
	entrance:Play()

	local minimized = false
	tracker:track(minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		local target = minimized and UDim2.fromOffset(width, minHeight) or UDim2.fromOffset(width, height)
		local tw = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = target })
		tw:Play()
		body.Visible = not minimized
		minimizeBtn.Text = minimized and "□" or "—"
	end))

	local win = {}
	win.Gui = screenGui
	win.Frame = frame
	win.TitleBar = titleBar
	win.Body = body
	win.Minimize = minimizeBtn
	win.Close = closeBtn
	win.Tracker = tracker

	function win.Destroy()
		tracker:cleanup()
		if CurrentTracker == tracker then CurrentTracker = prevTracker end
		if UI._RootGui == screenGui then UI._RootGui = nil end
		pcall(function() screenGui:Destroy() end)
	end

	tracker:track(closeBtn.MouseButton1Click:Connect(function()
		win.Destroy()
	end))

	UI._RootGui = screenGui
	return win
end

function UI.toast(message, color, duration)
	local c = color or C.ACCENT
	local dur = duration or 2.5
	local gui = UI._RootGui
	local owned = false
	if not gui or not gui.Parent then
		gui = Instance.new("ScreenGui")
		gui.Name = "MonboVerseToast"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 50
		gui.Parent = safeGuiParent()
		owned = true
	end
	local frame = Instance.new("Frame")
	frame.Name = "Toast"
	frame.Size = UDim2.fromOffset(320, 44)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, -50)
	frame.BackgroundColor3 = c
	frame.BorderSizePixel = 0
	frame.ZIndex = 5
	frame.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	local stroke = UI.Stroke(frame, Color3.fromRGB(0, 0, 0), 2)
	stroke.Transparency = 0.4
	local label = UI.Label(frame, { Text = message, TextSize = 14, Font = UI.Fonts.Bold, Color = Color3.fromRGB(255, 255, 255), Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), XAlign = Enum.TextXAlignment.Center })
	label.TextStrokeTransparency = 0.25
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, 14) }):Play()
	task.delay(dur, function()
		local ok = pcall(function()
			local outT = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 0, -50) })
			outT.Completed:Connect(function()
				pcall(function() frame:Destroy() end)
				if owned then pcall(function() gui:Destroy() end) end
			end)
			outT:Play()
		end)
		if not ok then
			pcall(function() frame:Destroy() end)
			if owned then pcall(function() gui:Destroy() end) end
		end
	end)
	return frame
end

function UI.createCard(displayName, cfg)
	cfg = cfg or {}
	local hasIntensity = cfg.Intensity == true
	local h = hasIntensity and 118 or 84
	local card = UI.Panel(cfg.Parent, { Name = "Card_" .. tostring(displayName), Color = C.CARD, Size = cfg.Size or UDim2.new(1, 0, 0, h), Position = cfg.Position or UDim2.fromOffset(0, 0), Radius = 8, StrokeColor = CARD_STROKE })

	local nameLabel = UI.Label(card, { Name = "Name", Text = displayName, TextSize = 14, Font = UI.Fonts.Bold, Position = UDim2.fromOffset(14, 10), Size = UDim2.new(0, 260, 0, 20), Truncate = Enum.TextTruncate.AtEnd })

	local toggle = UI.Button(card, { Name = "ToggleButton", Text = "OFF", TextSize = 12, Size = UDim2.fromOffset(60, 24), Position = UDim2.new(1, -14, 0, 8), AnchorPoint = Vector2.new(1, 0), Radius = 6, Color = C.BTN_OFF, TextColor = C.SUBTEXT })

	local isDelay = cfg.Delay == true
	UI.Label(card, { Name = "SpeedLabel", Text = isDelay and "Delay" or "Speed", TextSize = 11, Color = C.SUBTEXT, Position = UDim2.fromOffset(16, 42), Size = UDim2.fromOffset(64, 14) })
	local speedValue = UI.Label(card, { Name = "SpeedValue", Text = "", TextSize = 11, Font = UI.Fonts.Bold, Color = C.ACCENT, Position = UDim2.new(1, -16, 0, 42), AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(64, 14), XAlign = Enum.TextXAlignment.Right })
	local track = Instance.new("Frame")
	track.Name = "SpeedSlider"
	track.BackgroundColor3 = C.SLIDER_TRK
	track.BorderSizePixel = 0
	track.Size = UDim2.new(1, -160, 0, 4)
	track.Position = UDim2.fromOffset(88, 47)
	track.Parent = card
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 2)
	trackCorner.Parent = track
	local fill = Instance.new("Frame")
	fill.Name = "SpeedFill"
	fill.BackgroundColor3 = C.SLIDER_FIL
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(0.5, 0, 1, 0)
	fill.Parent = track
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 2)
	fillCorner.Parent = fill
	local handle = Instance.new("TextButton")
	handle.Name = "Handle"
	handle.BackgroundColor3 = Color3.fromRGB(232, 246, 255)
	handle.Text = ""
	handle.AutoButtonColor = false
	handle.Size = UDim2.fromOffset(14, 14)
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.Position = UDim2.new(0.5, 0, 0.5, 0)
	handle.Parent = track
	local handleCorner = Instance.new("UICorner")
	handleCorner.CornerRadius = UDim.new(1, 0)
	handleCorner.Parent = handle

	local intensityTrack, intensityFill, intensityValue
	if hasIntensity then
		UI.Label(card, { Name = "IntensityLabel", Text = "Intensity", TextSize = 11, Color = C.SUBTEXT, Position = UDim2.fromOffset(16, 74), Size = UDim2.fromOffset(64, 14) })
		intensityValue = UI.Label(card, { Name = "IntensityValue", Text = "", TextSize = 11, Font = UI.Fonts.Bold, Color = C.INTENSITY, Position = UDim2.new(1, -16, 0, 74), AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(64, 14), XAlign = Enum.TextXAlignment.Right })
		intensityTrack = Instance.new("Frame")
		intensityTrack.Name = "IntensitySlider"
		intensityTrack.BackgroundColor3 = C.SLIDER_TRK
		intensityTrack.BorderSizePixel = 0
		intensityTrack.Size = UDim2.new(1, -160, 0, 4)
		intensityTrack.Position = UDim2.fromOffset(88, 79)
		intensityTrack.Parent = card
		local itc = Instance.new("UICorner")
		itc.CornerRadius = UDim.new(0, 2)
		itc.Parent = intensityTrack
		intensityFill = Instance.new("Frame")
		intensityFill.Name = "IntensityFill"
		intensityFill.BackgroundColor3 = C.INTENSITY
		intensityFill.BorderSizePixel = 0
		intensityFill.Size = UDim2.new(0.5, 0, 1, 0)
		intensityFill.Parent = intensityTrack
		local ifc = Instance.new("UICorner")
		ifc.CornerRadius = UDim.new(0, 2)
		ifc.Parent = intensityFill
		local iHandle = Instance.new("TextButton")
		iHandle.Name = "Handle"
		iHandle.BackgroundColor3 = Color3.fromRGB(255, 220, 220)
		iHandle.Text = ""
		iHandle.AutoButtonColor = false
		iHandle.Size = UDim2.fromOffset(14, 14)
		iHandle.AnchorPoint = Vector2.new(0.5, 0.5)
		iHandle.Position = UDim2.new(0.5, 0, 0.5, 0)
		iHandle.Parent = intensityTrack
		local ihc = Instance.new("UICorner")
		ihc.CornerRadius = UDim.new(1, 0)
		ihc.Parent = iHandle
	end

	UI.setupSlider(track, fill, speedValue, cfg, isDelay and "Delay" or "Speed", isDelay)
	if hasIntensity then
		UI.setupIntensitySlider(intensityTrack, intensityFill, intensityValue, cfg)
	end
	UI.setupToggle(toggle, cfg)

	return { Card = card, ToggleButton = toggle, SpeedSlider = track, SpeedFill = fill, SpeedButton = handle, SpeedValue = speedValue, IntensitySlider = intensityTrack, IntensityFill = intensityFill, IntensityValue = intensityValue }
end

function UI.setupSlider(sliderFrame, fillFrame, valueLabel, cfg, property, isDelay)
	cfg = cfg or {}
	local handle = sliderFrame:FindFirstChild("Handle")
	local dragging = false

	local function apply(p)
		p = clamp(p, 0, 1)
		fillFrame.Size = UDim2.new(p, 0, 1, 0)
		if handle then handle.Position = UDim2.new(p, 0, 0.5, 0) end
		local value
		if isDelay then
			value = 0.1 + p * 9.9
			if valueLabel then valueLabel.Text = string.format("%.1fs", value) end
		else
			value = 0.01 + p * 0.99
			if valueLabel then valueLabel.Text = string.format("%.2fs", value) end
		end
		if property then
			cfg[property] = value
			cfg[property .. "Pct"] = p
		end
	end
	apply(cfg[property .. "Pct"] or 0.5)

	local function localPercent(input)
		local sizeX = sliderFrame.AbsoluteSize.X
		if sizeX <= 0 then return 0 end
		return (input.Position.X - sliderFrame.AbsolutePosition.X) / sizeX
	end

	track(sliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			apply(localPercent(input))
		end
	end))
	track(UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			apply(localPercent(input))
		end
	end))
	track(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
end

function UI.setupIntensitySlider(sliderFrame, fillFrame, valueLabel, cfg)
	cfg = cfg or {}
	local handle = sliderFrame:FindFirstChild("Handle")
	local dragging = false

	local function apply(p)
		p = clamp(p, 0, 1)
		fillFrame.Size = UDim2.new(p, 0, 1, 0)
		if handle then handle.Position = UDim2.new(p, 0, 0.5, 0) end
		local value = 1 + math.floor(p * 9)
		if valueLabel then valueLabel.Text = value .. "x" end
		cfg.Intensity = value
		cfg.IntensityPct = p
	end
	apply(cfg.IntensityPct or 0.5)

	local function localPercent(input)
		local sizeX = sliderFrame.AbsoluteSize.X
		if sizeX <= 0 then return 0 end
		return (input.Position.X - sliderFrame.AbsolutePosition.X) / sizeX
	end

	track(sliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			apply(localPercent(input))
		end
	end))
	track(UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			apply(localPercent(input))
		end
	end))
	track(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
end

function UI.setupToggle(button, cfg)
	cfg = cfg or {}
	local function apply(on)
		cfg.On = on
		local tw = TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = on and C.BTN_ON or C.BTN_OFF })
		tw:Play()
		button.Text = on and "ON" or "OFF"
		button.TextColor3 = on and Color3.fromRGB(255, 255, 255) or C.SUBTEXT
	end
	apply(cfg.On == true)
	track(button.MouseButton1Click:Connect(function()
		apply(not cfg.On)
		if cfg.OnToggle then pcall(cfg.OnToggle, cfg.On) end
	end))
end

function UI.nav(buttons, switchFn)
	buttons = buttons or {}
	local function setActive(button, active)
		button.BackgroundColor3 = active and C.ACCENT or C.SLIDER_TRK
		button.TextColor3 = active and Color3.fromRGB(6, 14, 24) or C.SUBTEXT
	end
	for i, button in ipairs(buttons) do
		track(button.MouseButton1Click:Connect(function()
			for j, b in ipairs(buttons) do setActive(b, j == i) end
			if switchFn then pcall(switchFn, button, i) end
		end))
	end
	local api = {}
	function api.Select(i)
		i = clamp(i, 1, #buttons)
		for j, b in ipairs(buttons) do setActive(b, j == i) end
	end
	return api
end

local blurFx = nil
local blurTween = nil
function UI.blur(enabled)
	if not blurFx then
		blurFx = Lighting:FindFirstChildOfClass("BlurEffect")
		if not blurFx then
			blurFx = Instance.new("BlurEffect")
			blurFx.Size = 0
			blurFx.Parent = Lighting
		end
	end
	if blurTween then pcall(function() blurTween:Cancel() end) end
	blurTween = TweenService:Create(blurFx, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = enabled and 24 or 0 })
	blurTween:Play()
end

function UI.cleanupAll()
	DefaultTracker:cleanup()
end

return UI
