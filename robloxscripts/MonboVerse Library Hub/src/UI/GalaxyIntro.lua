-- MonboVerse Library Hub :: GalaxyIntro :: skippable 6-phase cinematic startup (void -> universe -> explosion -> collapse -> MonboVerse -> reveal)

local GalaxyIntro = {}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local C = {
	BG = Color3.fromRGB(2, 4, 10),
	ACCENT = Color3.fromRGB(0, 200, 255),
	ACCENT2 = Color3.fromRGB(0, 255, 160),
	PURPLE = Color3.fromRGB(88, 101, 242),
	TEXT = Color3.fromRGB(210, 235, 255),
	YELLOW = Color3.fromRGB(255, 200, 90),
	WHITE = Color3.fromRGB(230, 240, 255)
}
local STAR_COLORS = { C.WHITE, C.ACCENT, C.ACCENT2, C.PURPLE, C.YELLOW }

local active = false
local done = false
local completeCb = nil
local gui = nil
local tweens = {}
local conns = {}
local createdBlur = nil

local function trackTween(tw)
	table.insert(tweens, tw)
	return tw
end

local function trackConn(c)
	table.insert(conns, c)
	return c
end

local function tween(obj, info, props)
	local tw = TweenService:Create(obj, info, props)
	trackTween(tw)
	tw:Play()
	return tw
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

local function getBlur()
	local b = Lighting:FindFirstChildOfClass("BlurEffect")
	if not b then
		b = Instance.new("BlurEffect")
		b.Size = 0
		b.Parent = Lighting
		createdBlur = b
	end
	return b
end

local function cleanup()
	for _, tw in ipairs(tweens) do pcall(function() tw:Cancel() end) end
	tweens = {}
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	conns = {}
	if gui then pcall(function() gui:Destroy() end) gui = nil end
	if createdBlur then pcall(function() createdBlur:Destroy() end) createdBlur = nil end
	active = false
end

local function finish()
	if done then return end
	done = true
	cleanup()
	local cb = completeCb
	completeCb = nil
	if cb then pcall(cb) end
end

function GalaxyIntro.Play(onComplete)
	if active then cleanup() end
	active = true
	done = false
	completeCb = onComplete

	gui = Instance.new("ScreenGui")
	gui.Name = "MonboVerseIntro"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 100
	gui.Parent = safeGuiParent()

	local bg = Instance.new("Frame")
	bg.Name = "BG"
	bg.BackgroundColor3 = C.BG
	bg.BorderSizePixel = 0
	bg.Size = UDim2.fromScale(1, 1)
	bg.ZIndex = 0
	bg.Parent = gui

	local dot = Instance.new("TextLabel")
	dot.Name = "Spark"
	dot.Text = "✦"
	dot.Font = Enum.Font.GothamBold
	dot.TextSize = 18
	dot.TextColor3 = C.ACCENT
	dot.BackgroundTransparency = 1
	dot.Size = UDim2.fromOffset(28, 28)
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Position = UDim2.fromScale(0.5, 0.5)
	dot.Transparency = 1
	dot.TextTransparency = 1
	dot.ZIndex = 3
	dot.Parent = gui

	local stars = {}
	for i = 1, 40 do
		local s = Instance.new("TextLabel")
		s.Name = "Star" .. i
		s.Text = "✦"
		s.Font = Enum.Font.Gotham
		s.TextSize = 8 + (i % 3) * 4
		s.TextColor3 = STAR_COLORS[i % #STAR_COLORS + 1]
		s.BackgroundTransparency = 1
		s.AnchorPoint = Vector2.new(0.5, 0.5)
		s.Position = UDim2.fromScale(0.5, 0.5)
		s.Transparency = 1
		s.TextTransparency = 1
		s.ZIndex = 2
		s.Parent = gui
		local angle = (i / 40) * math.pi * 2 + (i % 7) * 0.11
		local radius = 0.16 + ((i * 37) % 100) / 100 * 0.32
		stars[i] = { Label = s, Angle = angle, Radius = radius, Base = radius * 0.35 }
	end

	local orbiters = {}
	for i = 1, 8 do
		local f = Instance.new("Frame")
		f.Name = "Orbit" .. i
		f.BackgroundColor3 = STAR_COLORS[i % #STAR_COLORS + 1]
		f.BorderSizePixel = 0
		f.Size = UDim2.fromOffset(5 + (i % 3) * 2, 5 + (i % 3) * 2)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = UDim2.fromScale(0.5, 0.5)
		f.Transparency = 1
		f.ZIndex = 2
		f.Parent = gui
		local cor = Instance.new("UICorner")
		cor.CornerRadius = UDim.new(1, 0)
		cor.Parent = f
		orbiters[i] = { Frame = f, Radius = 0.09 + (i % 5) * 0.035, Speed = (1.2 + (i % 4) * 0.5) * (i % 2 == 0 and 1 or -1), Angle = (i / 8) * math.pi * 2 }
	end

	local function makeCloud(rot)
		local f = Instance.new("Frame")
		f.Name = "Nebula"
		f.BackgroundTransparency = 1
		f.BorderSizePixel = 0
		f.Size = UDim2.fromOffset(300, 300)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = UDim2.fromScale(0.5, 0.5)
		f.Rotation = rot
		f.Transparency = 1
		f.ZIndex = 1
		f.Parent = gui
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.ACCENT), ColorSequenceKeypoint.new(0.5, C.PURPLE), ColorSequenceKeypoint.new(1, C.ACCENT) })
		g.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.45, 0.62), NumberSequenceKeypoint.new(0.55, 0.58), NumberSequenceKeypoint.new(1, 1) })
		g.Parent = f
		return f
	end
	local neb1 = makeCloud(25)
	local neb2 = makeCloud(-35)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Text = "MONBOVERSE"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 44
	title.TextColor3 = C.TEXT
	title.BackgroundTransparency = 1
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.46)
	title.Transparency = 1
	title.TextTransparency = 1
	title.ZIndex = 4
	title.Parent = gui
	local sub = Instance.new("TextLabel")
	sub.Name = "Subtitle"
	sub.Text = "LIBRARY  HUB"
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 20
	sub.TextColor3 = C.ACCENT
	sub.BackgroundTransparency = 1
	sub.AnchorPoint = Vector2.new(0.5, 0.5)
	sub.Position = UDim2.fromScale(0.5, 0.56)
	sub.Transparency = 1
	sub.TextTransparency = 1
	sub.ZIndex = 4
	sub.Parent = gui

	local skipBtn = Instance.new("TextButton")
	skipBtn.Name = "Skip"
	skipBtn.Text = "SKIP ▸"
	skipBtn.Font = Enum.Font.GothamBold
	skipBtn.TextSize = 12
	skipBtn.TextColor3 = C.TEXT
	skipBtn.TextTransparency = 0.4
	skipBtn.BackgroundTransparency = 1
	skipBtn.AnchorPoint = Vector2.new(1, 1)
	skipBtn.Position = UDim2.new(1, -18, 1, -14)
	skipBtn.Size = UDim2.fromOffset(70, 24)
	skipBtn.ZIndex = 5
	skipBtn.Parent = gui
	trackConn(skipBtn.MouseButton1Click:Connect(function() GalaxyIntro.Skip() end))

	trackConn(RunService.Heartbeat:Connect(function(dt)
		if not active then return end
		for _, ob in ipairs(orbiters) do
			ob.Angle = ob.Angle + dt * ob.Speed
			local r = ob.Radius
			ob.Frame.Position = UDim2.new(0.5 + math.cos(ob.Angle) * r, 0, 0.5 + math.sin(ob.Angle) * r, 0)
		end
	end))

	local blur = getBlur()
	local easeQuad = Enum.EasingStyle.Quad
	local easeBack = Enum.EasingStyle.Back
	local easeInOut = Enum.EasingDirection.InOut
	local easeOut = Enum.EasingDirection.Out
	local easeIn = Enum.EasingDirection.In

	task.spawn(function()
		tween(dot, TweenInfo.new(0.8, easeQuad, easeOut), { Transparency = 0.15, TextTransparency = 0.15, TextSize = 34 })
		for _, s in ipairs(stars) do
			tween(s.Label, TweenInfo.new(0.7 + (s.Angle % 0.5), easeQuad, easeOut), { Transparency = 0.45, TextTransparency = 0.45, Position = UDim2.fromScale(0.5 + math.cos(s.Angle) * s.Base, 0.5 + math.sin(s.Angle) * s.Base) })
		end
		task.wait(0.9)
		if not active then return end

		tween(dot, TweenInfo.new(1.4, easeQuad, easeOut), { TextSize = 64, TextColor3 = C.ACCENT2 })
		for _, s in ipairs(stars) do
			tween(s.Label, TweenInfo.new(1.2, easeQuad, easeOut), { Transparency = 0.08, TextTransparency = 0.08, TextSize = s.Label.TextSize + 6 })
		end
		tween(neb1, TweenInfo.new(1.4, easeQuad, easeOut), { Transparency = 0.35, Size = UDim2.fromOffset(460, 460) })
		tween(neb2, TweenInfo.new(1.6, easeQuad, easeOut), { Transparency = 0.4, Size = UDim2.fromOffset(420, 420) })
		for _, ob in ipairs(orbiters) do
			tween(ob.Frame, TweenInfo.new(1.2, easeQuad, easeOut), { Transparency = 0.1 })
		end
		task.wait(1.6)
		if not active then return end

		for _, s in ipairs(stars) do
			tween(s.Label, TweenInfo.new(1.3, easeQuad, easeOut), { Position = UDim2.fromScale(0.5 + math.cos(s.Angle) * s.Radius, 0.5 + math.sin(s.Angle) * s.Radius) })
		end
		tween(neb1, TweenInfo.new(1.3, easeQuad, easeOut), { Transparency = 0.6, Size = UDim2.fromOffset(900, 900) })
		tween(neb2, TweenInfo.new(1.3, easeQuad, easeOut), { Transparency = 0.65, Size = UDim2.fromOffset(840, 840) })
		tween(blur, TweenInfo.new(1.3, easeQuad, easeOut), { Size = 16 })
		for _, ob in ipairs(orbiters) do ob.Radius = ob.Radius * 1.8 end
		task.wait(1.3)
		if not active then return end

		for _, s in ipairs(stars) do
			tween(s.Label, TweenInfo.new(1.3, easeQuad, easeInOut), { Position = UDim2.fromScale(0.5 + math.cos(s.Angle) * s.Base * 0.6, 0.5 + math.sin(s.Angle) * s.Base * 0.6) })
		end
		tween(neb1, TweenInfo.new(1.3, easeQuad, easeInOut), { Transparency = 0.45, Size = UDim2.fromOffset(420, 420) })
		tween(neb2, TweenInfo.new(1.3, easeQuad, easeInOut), { Transparency = 0.5, Size = UDim2.fromOffset(380, 380) })
		tween(blur, TweenInfo.new(1.3, easeQuad, easeInOut), { Size = 6 })
		for _, ob in ipairs(orbiters) do ob.Radius = ob.Radius / 1.8 end
		task.wait(1.3)
		if not active then return end

		for _, s in ipairs(stars) do
			tween(s.Label, TweenInfo.new(0.6, easeQuad, easeOut), { Transparency = 1, TextTransparency = 1 })
		end
		tween(dot, TweenInfo.new(0.6, easeQuad, easeOut), { Transparency = 1, TextTransparency = 1 })
		tween(title, TweenInfo.new(0.9, easeBack, easeOut), { TextTransparency = 0, TextSize = 52 })
		task.wait(0.55)
		if not active then return end
		tween(sub, TweenInfo.new(0.7, easeBack, easeOut), { TextTransparency = 0, TextSize = 24 })
		tween(neb1, TweenInfo.new(0.9, easeQuad, easeOut), { Transparency = 0.7 })
		tween(neb2, TweenInfo.new(0.9, easeQuad, easeOut), { Transparency = 0.75 })
		task.wait(1.15)
		if not active then return end

		tween(title, TweenInfo.new(0.8, easeQuad, easeIn), { TextTransparency = 1, TextSize = 40 })
		tween(sub, TweenInfo.new(0.8, easeQuad, easeIn), { TextTransparency = 1 })
		tween(bg, TweenInfo.new(0.8, easeQuad, easeIn), { BackgroundTransparency = 1 })
		tween(blur, TweenInfo.new(0.8, easeQuad, easeIn), { Size = 0 })
		task.wait(0.85)
		finish()
	end)

	return gui
end

function GalaxyIntro.Skip()
	if active and not done then
		finish()
	end
end

return GalaxyIntro
