-- MonboVerse Library Hub :: GameDetailsUI :: game details panel — back, icon, info, changelog, load button

local GameDetailsUI = {}

local UI
local function ensureUI()
	if UI then return UI end
	local ok, env = pcall(getgenv)
	if ok and env and env.MonboVerse and env.MonboVerse.UI then
		UI = env.MonboVerse.UI
		return UI
	end
	local ok2, src = pcall(function() return readfile("MonboVerse Library Hub/src/UI/UI.lua") end)
	if ok2 and type(src) == "string" then
		local ok3, chunk = pcall(loadstring, src)
		if ok3 and chunk then
			local ok4, mod = pcall(chunk)
			if ok4 and type(mod) == "table" then UI = mod end
		end
	end
	return UI
end

local function statusOf(entry)
	local C = UI.Theme
	local disabled = entry.Enabled == false or entry.Status == "disabled" or entry.Status == "Disabled"
	if disabled then return "Disabled", C.BTN_OFF end
	if entry.Status == "stable" or entry.Status == "compatible" or entry.Status == "Compatible" then
		return "Compatible", C.ACCENT2
	end
	return "Unavailable", C.INTENSITY
end

local function badgeTextColor(c)
	local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
	if lum > 0.55 then return Color3.fromRGB(6, 14, 24) end
	return Color3.fromRGB(255, 255, 255)
end

function GameDetailsUI.Show(entry)
	UI = ensureUI()
	if not UI then return end
	local C = UI.Theme

	if GameDetailsUI._Window then
		pcall(function() GameDetailsUI._Window.Destroy() end)
		GameDetailsUI._Window = nil
	end

	entry = entry or {}
	local win = UI.newWindow({ Title = "Game Details", Subtitle = entry.Name or "Unknown Game", Icon = "🌌", Width = 460, Height = 520, MinHeight = 44 })
	GameDetailsUI._Window = win
	GameDetailsUI._UI = UI
	local body = win.Body
	local tracker = win.Tracker

	UI.toast("Loading Metadata...", C.ACCENT, 1.4)

	local backBtn = UI.Button(body, { Name = "Back", Text = "← Back", TextSize = 12, Size = UDim2.fromOffset(84, 28), Position = UDim2.fromOffset(12, 10), Radius = 6, Color = C.SLIDER_TRK, TextColor = C.TEXT })
	tracker:track(backBtn.MouseButton1Click:Connect(function()
		GameDetailsUI.Hide()
	end))

	local iconUrl = type(entry.Icon) == "string" and entry.Icon or nil
	if iconUrl and (iconUrl:lower():find("^https?://") or iconUrl:lower():find("^rbxasset")) then
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Image = iconUrl
		icon.BackgroundColor3 = C.TITLE_BG
		icon.BackgroundTransparency = 0.35
		icon.ScaleType = Enum.ScaleType.Crop
		icon.Size = UDim2.fromOffset(72, 72)
		icon.Position = UDim2.new(0.5, -36, 0, 56)
		icon.Parent = body
		local ic = Instance.new("UICorner")
		ic.CornerRadius = UDim.new(0, 10)
		ic.Parent = icon
	else
		UI.Label(body, { Name = "Icon", Text = "🌌", TextSize = 34, Font = UI.Fonts.Bold, Position = UDim2.new(0.5, -36, 0, 56), Size = UDim2.fromOffset(72, 72), XAlign = Enum.TextXAlignment.Center })
	end

	UI.Label(body, { Name = "Name", Text = entry.Name or "Unknown Game", TextSize = 20, Font = UI.Fonts.Bold, Position = UDim2.new(0.5, -170, 0, 138), Size = UDim2.fromOffset(340, 26), XAlign = Enum.TextXAlignment.Center })

	local status, sColor = statusOf(entry)
	UI.Label(body, { Name = "VersionStatus", Text = "v" .. tostring(entry.Version or "0.0.0") .. "   ·   " .. status, TextSize = 12, Font = UI.Fonts.Bold, Color = sColor, Position = UDim2.new(0.5, -170, 0, 168), Size = UDim2.fromOffset(340, 18), XAlign = Enum.TextXAlignment.Center })

	UI.Label(body, { Name = "Author", Text = "by " .. tostring(entry.Author or "Unknown"), TextSize = 12, Color = C.SUBTEXT, Position = UDim2.new(0.5, -170, 0, 190), Size = UDim2.fromOffset(340, 16), XAlign = Enum.TextXAlignment.Center })

	UI.Label(body, { Name = "Description", Text = entry.Description or "No description provided.", TextSize = 12, Color = C.TEXT, Wrap = true, YAlign = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(24, 216), Size = UDim2.new(1, -48, 0, 64) })

	UI.Label(body, { Name = "ChangelogHeader", Text = "Changelog", TextSize = 13, Font = UI.Fonts.Bold, Position = UDim2.fromOffset(24, 292), Size = UDim2.fromOffset(200, 18) })
	local logScroll = Instance.new("ScrollingFrame")
	logScroll.Name = "ChangelogList"
	logScroll.BackgroundTransparency = 1
	logScroll.BorderSizePixel = 0
	logScroll.Position = UDim2.fromOffset(24, 314)
	logScroll.Size = UDim2.new(1, -48, 0, 118)
	logScroll.ScrollBarThickness = 4
	logScroll.ScrollBarImageColor3 = C.BORDER
	logScroll.CanvasSize = UDim2.fromOffset(0, 4)
	logScroll.Parent = body
	local logLayout = Instance.new("UIListLayout")
	logLayout.Padding = UDim.new(0, 4)
	logLayout.SortOrder = Enum.SortOrder.LayoutOrder
	logLayout.Parent = logScroll
	local logPadding = Instance.new("UIPadding")
	logPadding.PaddingTop = UDim.new(0, 2)
	logPadding.Parent = logScroll

	local changelog = type(entry.Changelog) == "table" and entry.Changelog or {}
	if #changelog == 0 then changelog = { "No changelog available." } end
	for i, line in ipairs(changelog) do
		local l = UI.Label(logScroll, { Name = "Log" .. i, Text = "• " .. tostring(line), TextSize = 12, Color = C.SUBTEXT, Wrap = true, YAlign = Enum.TextYAlignment.Top, Size = UDim2.new(1, -8, 0, 16), LayoutOrder = i })
		if #tostring(line) > 52 then
			local lines = math.ceil(#tostring(line) / 52)
			l.Size = UDim2.new(1, -8, 0, 16 * lines)
		end
	end
	logScroll.CanvasSize = UDim2.fromOffset(0, 6 + #changelog * 20)

	local loadBtn = UI.Button(body, { Name = "LoadScript", Text = "Load Script", TextSize = 15, Size = UDim2.fromOffset(220, 38), Position = UDim2.new(0.5, -110, 1, -16), AnchorPoint = Vector2.new(0.5, 1), Color = C.ACCENT, TextColor = Color3.fromRGB(6, 14, 24), Radius = 8 })
	tracker:track(loadBtn.MouseButton1Click:Connect(function()
		UI.toast("Loading Script...", C.ACCENT2, 2)
		if GameDetailsUI._OnLoad then pcall(GameDetailsUI._OnLoad, entry) end
	end))

	return win
end

function GameDetailsUI.Hide()
	if GameDetailsUI._Window then
		local w = GameDetailsUI._Window
		GameDetailsUI._Window = nil
		pcall(function() w.Destroy() end)
	end
end

function GameDetailsUI.OnLoadRequested(callback)
	GameDetailsUI._OnLoad = callback
end

return GameDetailsUI
