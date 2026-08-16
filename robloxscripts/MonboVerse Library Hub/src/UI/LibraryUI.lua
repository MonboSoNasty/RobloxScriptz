-- MonboVerse Library Hub :: LibraryUI :: hub browser window — nav, search, and scrollable game card list

local LibraryUI = {}

local FALLBACK_REGISTRY = {
	Version = "1.0.0",
	Games = {
		{
			Id = "moon-incremental",
			Name = "Moon Incremental",
			PlaceIds = {},
			Version = "2.0.0",
			Enabled = true,
			Status = "stable",
			Author = "NVHeadMonbo",
			Description = "Moon Incremental automation/features",
			Tags = { "incremental", "moon", "automation" },
			Icon = nil,
			UpdatedAt = "2026-08-16",
			Changelog = { "Improved UI", "Added library integration", "Centralized key system" }
		}
	}
}

-- ============ Module resolution ============
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

local function getEnv()
	local ok, env = pcall(getgenv)
	if ok and type(env) == "table" then return env end
	return nil
end

local function getRegistry()
	local env = getEnv()
	if env and env.MonboVerse and env.MonboVerse.ScriptRegistry then
		return env.MonboVerse.ScriptRegistry
	end
	return FALLBACK_REGISTRY
end

local function getGames()
	local reg = getRegistry()
	if type(reg.GetGames) == "function" then
		local ok, games = pcall(reg.GetGames)
		if ok and type(games) == "table" then return games end
	end
	if type(reg.Games) == "table" then return reg.Games end
	return {}
end

-- ============ Matching / status ============
local function matchesQuery(entry, q)
	if q == "" then return true end
	local fields = {
		entry.Name, tostring(entry.PlaceId or ""), entry.Description, entry.Author,
		entry.Version, entry.Status
	}
	if type(entry.Tags) == "table" then
		for _, t in ipairs(entry.Tags) do table.insert(fields, t) end
	end
	if type(entry.PlaceIds) == "table" then
		for _, pid in ipairs(entry.PlaceIds) do table.insert(fields, tostring(pid)) end
	end
	for _, f in ipairs(fields) do
		if type(f) == "string" and f:lower():find(q, 1, true) then return true end
	end
	return false
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

-- ============ Card builder ============
local function buildCard(entry)
	local C = UI.Theme
	local scroll = LibraryUI._Scroll
	local tracker = LibraryUI._Window.Tracker

	local card = UI.Panel(scroll, {
		Name = "GameCard",
		Color = C.CARD,
		Size = UDim2.new(1, 0, 0, 100),
		Radius = 8,
		StrokeColor = Color3.fromRGB(20, 45, 75)
	})

	-- icon
	local iconUrl = type(entry.Icon) == "string" and entry.Icon or nil
	local icon
	if iconUrl and (iconUrl:lower():find("^https?://") or iconUrl:lower():find("^rbxasset")) then
		icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Image = iconUrl
		icon.BackgroundColor3 = C.TITLE_BG
		icon.BackgroundTransparency = 0.35
		icon.ScaleType = Enum.ScaleType.Crop
		icon.Size = UDim2.fromOffset(48, 48)
		icon.Position = UDim2.fromOffset(12, 12)
		icon.Parent = card
		local ic = Instance.new("UICorner")
		ic.CornerRadius = UDim.new(0, 8)
		ic.Parent = icon
	else
		icon = UI.Label(card, {
			Name = "Icon", Text = "🌌", TextSize = 24, Font = UI.Fonts.Bold,
			Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(48, 48), XAlign = Enum.TextXAlignment.Center
		})
	end

	UI.Label(card, {
		Name = "Name", Text = entry.Name or "Unknown", TextSize = 15, Font = UI.Fonts.Bold,
		Position = UDim2.fromOffset(72, 10), Size = UDim2.new(0, 230, 0, 18), Truncate = Enum.TextTruncate.AtEnd
	})
	UI.Label(card, {
		Name = "Version", Text = "v" .. tostring(entry.Version or "0.0.0"), TextSize = 11, Color = C.SUBTEXT,
		Position = UDim2.fromOffset(72, 31), Size = UDim2.fromOffset(120, 14)
	})
	UI.Label(card, {
		Name = "Description", Text = entry.Description or "No description", TextSize = 12, Color = C.SUBTEXT,
		Position = UDim2.fromOffset(72, 49), Size = UDim2.new(1, -150, 0, 16), Truncate = Enum.TextTruncate.AtEnd
	})

	local status, sColor = statusOf(entry)
	UI.Badge(card, {
		Name = "StatusBadge", Text = status, Color = sColor, TextColor = badgeTextColor(sColor),
		Width = 92, Position = UDim2.new(1, -12, 0, 12), AnchorPoint = Vector2.new(1, 0)
	})

	local viewBtn = UI.Button(card, {
		Name = "View", Text = "View", TextSize = 12,
		Size = UDim2.fromOffset(56, 26), Position = UDim2.new(1, -12, 1, -10), AnchorPoint = Vector2.new(1, 1),
		Color = C.BTN_ON, Radius = 6
	})
	local loadBtn = UI.Button(card, {
		Name = "Load", Text = "Load", TextSize = 12,
		Size = UDim2.fromOffset(56, 26), Position = UDim2.new(1, -76, 1, -10), AnchorPoint = Vector2.new(1, 1),
		Color = C.ACCENT, TextColor = Color3.fromRGB(6, 14, 24), Radius = 6
	})

	tracker:track(viewBtn.MouseButton1Click:Connect(function()
		if LibraryUI._OnSelect then pcall(LibraryUI._OnSelect, entry, "view") end
	end))
	tracker:track(loadBtn.MouseButton1Click:Connect(function()
		if LibraryUI._OnSelect then pcall(LibraryUI._OnSelect, entry, "load") end
	end))

	return card
end

-- ============ Public API ============
function LibraryUI.Show()
	UI = ensureUI()
	if not UI then return end
	local C = UI.Theme

	if LibraryUI._Window then
		pcall(function() LibraryUI._Window.Destroy() end)
		LibraryUI._Window = nil
	end

	local win = UI.newWindow({
		Title = "🌌 MonboVerse Library",
		Subtitle = "by NVHeadMonbo",
		Icon = "🌌",
		Width = 560,
		Height = 540,
		MinHeight = 44
	})
	LibraryUI._Window = win
	LibraryUI._UI = UI
	local body = win.Body
	local tracker = win.Tracker

	-- nav bar
	local navBar = UI.Panel(body, {
		Name = "NavBar", Color = C.TITLE_BG, Size = UDim2.new(1, 0, 0, 40),
		Radius = 0, StrokeColor = Color3.fromRGB(16, 38, 66)
	})
	local libBtn = UI.Button(navBar, {
		Name = "NavLibrary", Text = "Library", TextSize = 12,
		Size = UDim2.fromOffset(104, 28), Position = UDim2.fromOffset(8, 6), Radius = 6,
		Color = C.SLIDER_TRK, TextColor = C.SUBTEXT
	})
	local upBtn = UI.Button(navBar, {
		Name = "NavUpdates", Text = "Updates", TextSize = 12,
		Size = UDim2.fromOffset(104, 28), Position = UDim2.fromOffset(118, 6), Radius = 6,
		Color = C.SLIDER_TRK, TextColor = C.SUBTEXT
	})
	local setBtn = UI.Button(navBar, {
		Name = "NavSettings", Text = "Settings", TextSize = 12,
		Size = UDim2.fromOffset(104, 28), Position = UDim2.fromOffset(228, 6), Radius = 6,
		Color = C.SLIDER_TRK, TextColor = C.SUBTEXT
	})

	-- pages container
	local pages = Instance.new("Frame")
	pages.Name = "Pages"
	pages.BackgroundColor3 = C.BG
	pages.BorderSizePixel = 0
	pages.Position = UDim2.fromOffset(0, 40)
	pages.Size = UDim2.new(1, 0, 1, -40)
	pages.Parent = body

	-- Library page
	local libPage = Instance.new("Frame")
	libPage.Name = "LibraryPage"
	libPage.BackgroundTransparency = 1
	libPage.BorderSizePixel = 0
	libPage.Size = UDim2.new(1, 0, 1, 0)
	libPage.Parent = pages

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.PlaceholderText = "🔎 Search games..."
	searchBox.Text = ""
	searchBox.ClearTextOnFocus = false
	searchBox.BackgroundColor3 = C.TITLE_BG
	searchBox.TextColor3 = C.TEXT
	searchBox.PlaceholderColor3 = C.SUBTEXT
	searchBox.Font = UI.Fonts.Medium
	searchBox.TextSize = 13
	searchBox.Size = UDim2.new(1, -24, 0, 32)
	searchBox.Position = UDim2.fromOffset(12, 10)
	searchBox.Parent = libPage
	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 8)
	searchCorner.Parent = searchBox
	UI.Stroke(searchBox, Color3.fromRGB(20, 45, 75), 1)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "GameList"
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Position = UDim2.fromOffset(0, 50)
	scroll.Size = UDim2.new(1, 0, 1, -54)
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = C.BORDER
	scroll.CanvasSize = UDim2.fromOffset(0, 8)
	scroll.Parent = libPage
	LibraryUI._Scroll = scroll
	local layout = Instance.new("UIListLayout")
	layout.Name = "CardLayout"
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll
	local padding = Instance.new("UIPadding")
	padding.Name = "CardPadding"
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = scroll

	-- debounced search (token-based; no Heartbeat spam)
	local searchToken = 0
	tracker:track(searchBox.TextChanged:Connect(function()
		local my = searchToken + 1
		searchToken = my
		task.delay(0.15, function()
			if searchToken == my and LibraryUI._Window then
				LibraryUI.Refresh(searchBox.Text)
			end
		end)
	end))
	tracker:track(searchBox.FocusLost:Connect(function()
		LibraryUI.Refresh(searchBox.Text)
	end))

	-- Updates page
	local updatesPage = Instance.new("Frame")
	updatesPage.Name = "UpdatesPage"
	updatesPage.BackgroundTransparency = 1
	updatesPage.BorderSizePixel = 0
	updatesPage.Size = UDim2.new(1, 0, 1, 0)
	updatesPage.Visible = false
	updatesPage.Parent = pages
	UI.Label(updatesPage, {
		Name = "UpdatesTitle", Text = "Updates", TextSize = 20, Font = UI.Fonts.Bold,
		Position = UDim2.new(0.5, -80, 0, 60), Size = UDim2.fromOffset(160, 26), XAlign = Enum.TextXAlignment.Center
	})
	UI.Label(updatesPage, {
		Name = "UpdatesNone", Text = "No updates available — all scripts are up to date.", TextSize = 12, Color = C.SUBTEXT,
		Position = UDim2.new(0.5, -200, 0, 100), Size = UDim2.fromOffset(400, 18), XAlign = Enum.TextXAlignment.Center
	})

	-- Settings page
	local settingsPage = Instance.new("Frame")
	settingsPage.Name = "SettingsPage"
	settingsPage.BackgroundTransparency = 1
	settingsPage.BorderSizePixel = 0
	settingsPage.Size = UDim2.new(1, 0, 1, 0)
	settingsPage.Visible = false
	settingsPage.Parent = pages
	UI.Label(settingsPage, {
		Name = "SettingsTitle", Text = "Settings", TextSize = 20, Font = UI.Fonts.Bold,
		Position = UDim2.new(0.5, -80, 0, 60), Size = UDim2.fromOffset(160, 26), XAlign = Enum.TextXAlignment.Center
	})
	local blurBtn = UI.Button(settingsPage, {
		Name = "BlurToggle", Text = "Blur: OFF", TextSize = 13,
		Size = UDim2.fromOffset(140, 32), Position = UDim2.new(0.5, -70, 0, 110), Radius = 8,
		Color = C.BTN_OFF, TextColor = C.SUBTEXT
	})
	local blurOn = false
	tracker:track(blurBtn.MouseButton1Click:Connect(function()
		blurOn = not blurOn
		UI.blur(blurOn)
		blurBtn.Text = blurOn and "Blur: ON" or "Blur: OFF"
		blurBtn.BackgroundColor3 = blurOn and C.BTN_ON or C.BTN_OFF
		blurBtn.TextColor3 = blurOn and Color3.fromRGB(255, 255, 255) or C.SUBTEXT
	end))

	-- nav switching
	local function switchPage(_, idx)
		libPage.Visible = idx == 1
		updatesPage.Visible = idx == 2
		settingsPage.Visible = idx == 3
	end
	local navApi = UI.nav({ libBtn, upBtn, setBtn }, switchPage)
	navApi.Select(1)
	LibraryUI._Nav = navApi

	LibraryUI.Refresh("")
	return win
end

function LibraryUI.Refresh(query)
	if not LibraryUI._Window or not LibraryUI._Scroll then return end
	UI = LibraryUI._UI or ensureUI()
	if not UI then return end

	local q = tostring(query or ""):lower()
	q = q:gsub("^%s+", ""):gsub("%s+$", "")

	-- clear existing cards
	for _, child in ipairs(LibraryUI._Scroll:GetChildren()) do
		if child.Name == "GameCard" or child.Name == "EmptyLabel" then
			child:Destroy()
		end
	end

	local games = getGames()
	local matches = {}
	for _, entry in ipairs(games) do
		if matchesQuery(entry, q) then table.insert(matches, entry) end
	end
	table.sort(matches, function(a, b) return tostring(a.Name) < tostring(b.Name) end)

	for i, entry in ipairs(matches) do
		local card = buildCard(entry)
		card.LayoutOrder = i
	end

	if #matches == 0 then
		local empty = UI.Label(LibraryUI._Scroll, {
			Name = "EmptyLabel",
			Text = "No games match \"" .. tostring(query or "") .. "\"",
			TextSize = 13, Color = UI.Theme.SUBTEXT,
			Position = UDim2.fromOffset(0, 8), Size = UDim2.new(1, 0, 0, 40), XAlign = Enum.TextXAlignment.Center
		})
		empty.LayoutOrder = 1
		LibraryUI._Scroll.CanvasSize = UDim2.fromOffset(0, 56)
	else
		LibraryUI._Scroll.CanvasSize = UDim2.fromOffset(0, 8 + #matches * 110)
	end
end

function LibraryUI.OnSelect(callback)
	LibraryUI._OnSelect = callback
end

function LibraryUI.Hide()
	if LibraryUI._Window then
		local w = LibraryUI._Window
		LibraryUI._Window = nil
		pcall(function() w.Destroy() end)
	end
end

function LibraryUI.IsVisible()
	return LibraryUI._Window ~= nil
		and LibraryUI._Window.Gui ~= nil
		and LibraryUI._Window.Gui.Parent ~= nil
end

function LibraryUI.ToggleVisible()
	if LibraryUI.IsVisible() then
		LibraryUI.Hide()
	else
		LibraryUI.Show()
	end
end

return LibraryUI
