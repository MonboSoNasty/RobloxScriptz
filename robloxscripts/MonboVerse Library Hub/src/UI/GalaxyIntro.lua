-- MonboVerse Library Hub :: GalaxyIntro :: skippable 6-phase rainbow-stardust cinematic
-- Particles are 4-point sparkle "stars" in a rainbow palette with a soft rainbow
-- nebula, so the intro reads as galaxy stardust rather than plain circles.

local GalaxyIntro = {}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local C = {
	BG = Color3.fromRGB(2, 4, 10),
	ACCENT = Color3.fromRGB(0, 200, 255),
	ACCENT2 = Color3.fromRGB(0, 255, 160),
	TEXT = Color3.fromRGB(210, 235, 255),
	WHITE = Color3.fromRGB(240, 246, 255),
}
local RAINBOW = {
	Color3.fromRGB(255, 71, 87),
	Color3.fromRGB(255, 160, 60),
	Color3.fromRGB(255, 236, 60),
	Color3.fromRGB(60, 255, 120),
	Color3.fromRGB(60, 180, 255),
	Color3.fromRGB(150, 100, 255),
	Color3.fromRGB(255, 110, 220),
}

-- ============ State ============
local active = false
local done = false
local completeCb = nil
local gui = nil
local tweens = {}
local conns = {}
local createdBlur = nil

local function trackTween(tw) table.insert(tweens, tw) return tw end
local function trackConn(c) table.insert(conns, c) return c end

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

-- 4-point sparkle star: two crossed rounded bars inside a centered container frame.
local function makeStar(parent, size, color, zIndex)
	local f = Instance.new("Frame")
	f.Size = UDim2.fromOffset(size, size)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromScale(0.5, 0.5)
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.Transparency = 1
	f.ZIndex = zIndex or 2
	f.Parent = parent

	local bar = math.max(2, math.floor(size * 0.30))

	local hb = Instance.new("Frame")
	hb.Size = UDim2.new(1, 0, 0, bar)
	hb.AnchorPoint = Vector2.new(0.5, 0.5)
	hb.Position = UDim2.fromScale(0.5, 0.5)
	hb.BackgroundColor3 = color
	hb.BorderSizePixel = 0
	hb.Parent = f
	local hc = Instance.new("UICorner")
	hc.CornerRadius = UDim.new(1, 0)
	hc.Parent = hb

	local vb = Instance.new("Frame")
	vb.Size = UDim2.new(0, bar, 1, 0)
	vb.AnchorPoint = Vector2.new(0.5, 0.5)
	vb.Position = UDim2.fromScale(0.5, 0.5)
	vb.BackgroundColor3 = color
	vb.BorderSizePixel = 0
	vb.Parent = f
	local vc = Instance.new("UICorner")
	vc.CornerRadius = UDim.new(1, 0)
	vc.Parent = vb

	return f
end

-- ============ Cinematic ============
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

	local spark = makeStar(gui, 20, C.WHITE, 3)

	local stars = {}
	for i = 1, 44 do
		local size = 9 + (i % 5) * 4
		local s = makeStar(gui, size, RAINBOW[i % #RAINBOW + 1], 2)
		s.Rotation = ((i * 29) % 360)
		local angle = (i / 44) * math.pi * 2 + (i % 7) * 0.11
		local radius = 0.16 + ((i * 37) % 100) / 100 * 0.32
		stars[i] = { Obj = s, Angle = angle, Radius = radius, Base = radius * 0.35, Size = size, Rot = s.Rotation }
	end

	local orbiters = {}
	for i = 1, 9 do
		local f = makeStar(gui, 8 + (i % 3) * 3, RAINBOW[i % #RAINBOW + 1], 2)
		f.Rotation = ((i * 40) % 360)
		orbiters[i] = {
			Frame = f,
			Radius = 0.09 + (i % 5) * 0.035,
			Speed = (1.2 + (i % 4) * 0.5) * (i % 2 == 0 and 1 or -1),
			Angle = (i / 9) * math.pi * 2
		}
	end

	local function makeNebula(rot)
		local f = Instance.new("Frame")
		f.Name = "Nebula"
		f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		f.BackgroundTransparency = 0.6
		f.BorderSizePixel = 0
		f.Size = UDim2.fromOffset(300, 300)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = UDim2.fromScale(0.5, 0.5)
		f.Transparency = 1
		f.ZIndex = 1
		f.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = f
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, RAINBOW[1]),
			ColorSequenceKeypoint.new(0.25, RAINBOW[3]),
			ColorSequenceKeypoint.new(0.5, RAINBOW[5]),
			ColorSequenceKeypoint.new(0.75, RAINBOW[6]),
			ColorSequenceKeypoint.new(1, RAINBOW[1]),
		})
		g.Rotation = rot
		g.Parent = f
		return f
	end
	local neb1 = makeNebula(25)
	local neb2 = makeNebula(-35)

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
		-- Phase 1 — Void: spark appears, stars twinkle in
		tween(spark, TweenInfo.new(0.8, easeQuad, easeOut), { Transparency = 0.15, Size = UDim2.fromOffset(34, 34), Rotation = 45 })
		for _, s in ipairs(stars) do
			tween(s.Obj, TweenInfo.new(0.7 + (s.Angle % 0.5), easeQuad, easeOut), {
				Transparency = 0.5,
				Position = UDim2.fromScale(0.5 + math.cos(s.Angle) * s.Base, 0.5 + math.sin(s.Angle) * s.Base),
			})
		end
		task.wait(0.9)
		if not active then return end

		-- Phase 2 — Universe formation: spark grows, stars brighten, nebula blooms
		tween(spark, TweenInfo.new(1.4, easeQuad, easeOut), { Size = UDim2.fromOffset(64, 64), Rotation = 90, BackgroundColor3 = C.ACCENT2 })
		for _, s in ipairs(stars) do
			tween(s.Obj, TweenInfo.new(1.2, easeQuad, easeOut), { Transparency = 0.05, Size = UDim2.fromOffset(s.Size + 5, s.Size + 5) })
		end
		tween(neb1, TweenInfo.new(1.4, easeQuad, easeOut), { Transparency = 0.35, Size = UDim2.fromOffset(460, 460) })
		tween(neb2, TweenInfo.new(1.6, easeQuad, easeOut), { Transparency = 0.4, Size = UDim2.fromOffset(420, 420) })
		for _, ob in ipairs(orbiters) do
			tween(ob.Frame, TweenInfo.new(1.2, easeQuad, easeOut), { Transparency = 0.1 })
		end
		task.wait(1.6)
		if not active then return end

		-- Phase 3 — Galaxy explosion: radial burst, blur peaks
		for _, s in ipairs(stars) do
			tween(s.Obj, TweenInfo.new(1.3, easeQuad, easeOut), {
				Position = UDim2.fromScale(0.5 + math.cos(s.Angle) * s.Radius, 0.5 + math.sin(s.Angle) * s.Radius),
				Rotation = s.Rot + 90,
			})
		end
		tween(neb1, TweenInfo.new(1.3, easeQuad, easeOut), { Transparency = 0.6, Size = UDim2.fromOffset(900, 900) })
		tween(neb2, TweenInfo.new(1.3, easeQuad, easeOut), { Transparency = 0.65, Size = UDim2.fromOffset(840, 840) })
		tween(blur, TweenInfo.new(1.3, easeQuad, easeOut), { Size = 16 })
		for _, ob in ipairs(orbiters) do ob.Radius = ob.Radius * 1.8 end
		task.wait(1.3)
		if not active then return end

		-- Phase 4 — Reverse collapse
		for _, s in ipairs(stars) do
			tween(s.Obj, TweenInfo.new(1.3, easeQuad, easeInOut), {
				Position = UDim2.fromScale(0.5 + math.cos(s.Angle) * s.Base * 0.6, 0.5 + math.sin(s.Angle) * s.Base * 0.6),
			})
		end
		tween(neb1, TweenInfo.new(1.3, easeQuad, easeInOut), { Transparency = 0.45, Size = UDim2.fromOffset(420, 420) })
		tween(neb2, TweenInfo.new(1.3, easeQuad, easeInOut), { Transparency = 0.5, Size = UDim2.fromOffset(380, 380) })
		tween(blur, TweenInfo.new(1.3, easeQuad, easeInOut), { Size = 6 })
		for _, ob in ipairs(orbiters) do ob.Radius = ob.Radius / 1.8 end
		task.wait(1.3)
		if not active then return end

		-- Phase 5 — MonboVerse formation
		for _, s in ipairs(stars) do
			tween(s.Obj, TweenInfo.new(0.6, easeQuad, easeOut), { Transparency = 1 })
		end
		tween(spark, TweenInfo.new(0.6, easeQuad, easeOut), { Transparency = 1 })
		tween(title, TweenInfo.new(0.9, easeBack, easeOut), { TextTransparency = 0, TextSize = 52 })
		task.wait(0.55)
		if not active then return end
		tween(sub, TweenInfo.new(0.7, easeBack, easeOut), { TextTransparency = 0, TextSize = 24 })
		tween(neb1, TweenInfo.new(0.9, easeQuad, easeOut), { Transparency = 0.7 })
		tween(neb2, TweenInfo.new(0.9, easeQuad, easeOut), { Transparency = 0.75 })
		task.wait(1.15)
		if not active then return end

		-- Phase 6 — Library reveal: fade/scale out, hand off
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
