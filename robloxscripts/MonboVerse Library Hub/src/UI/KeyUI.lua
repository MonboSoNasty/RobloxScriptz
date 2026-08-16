-- MonboVerse Library Hub :: KeyUI :: Junkie verification windows — duration select, key entry, status, clipboard

local KeyUI = {}

local FALLBACK_DURATIONS = {
	{ Name = "1 Day", Value = "1d" },
	{ Name = "3 Days", Value = "3d" },
	{ Name = "7 Days", Value = "7d" },
	{ Name = "30 Days", Value = "30d" }
}
local FALLBACK_DEFAULTS = {
	Title = "MonboVerse Verification",
	Subtitle = "Powered by Junkie",
	Description = "Complete verification to load this script"
}

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

local function getDurations()
	local env = getEnv()
	if env and env.MonboVerse and env.MonboVerse.Services and env.MonboVerse.Services.JunkieConfig then
		local d = env.MonboVerse.Services.JunkieConfig.KeyDurations
		if type(d) == "table" and #d > 0 then return d end
	end
	return FALLBACK_DURATIONS
end

local function getDefaults()
	local env = getEnv()
	if env and env.MonboVerse and env.MonboVerse.Services and env.MonboVerse.Services.JunkieConfig then
		local d = env.MonboVerse.Services.JunkieConfig.Defaults
		if type(d) == "table" then return d end
	end
	return FALLBACK_DEFAULTS
end

local function getKeySystem()
	local env = getEnv()
	if env and env.MonboVerse and env.MonboVerse.Services then
		return env.MonboVerse.Services.KeySystem
	end
	return nil
end

local function copyToClipboard(text)
	local env = getEnv()
	if env and env.MonboVerse and env.MonboVerse.Utils and type(env.MonboVerse.Utils.setClipboard) == "function" then
		local ok, res = pcall(env.MonboVerse.Utils.setClipboard, text)
		return ok and res ~= false
	end
	local okSet, setFn = pcall(function() return setclipboard end)
	if okSet and type(setFn) == "function" then
		local ok2 = pcall(setFn, text)
		return ok2
	end
	local okClip, clip = pcall(function() return Clipboard end)
	if okClip and clip and type(clip.set) == "function" then
		local ok3 = pcall(clip.set, text)
		return ok3
	end
	return false
end

local Window = nil
local StatusLabel = nil
local verifyClosed = false
local selectedDuration = nil

function KeyUI.Close()
	if Window then
		local w = Window
		Window = nil
		pcall(function() w.Destroy() end)
	end
	StatusLabel = nil
	verifyClosed = true
end

function KeyUI.SetStatus(msg, color)
	if StatusLabel and StatusLabel.Parent then
		StatusLabel.Text = msg
		if color then StatusLabel.TextColor3 = color end
	end
end

function KeyUI.ShowDurationSelect(entry, onChosen)
	UI = ensureUI()
	if not UI then return end
	local C = UI.Theme
	KeyUI.Close()

	local win = UI.newWindow({ Title = "Select Duration", Subtitle = (entry and entry.Name) or "MonboVerse", Icon = "🔑", Width = 400, Height = 320, MinHeight = 44 })
	Window = win
	verifyClosed = false
	local body = win.Body
	local tracker = win.Tracker

	UI.Label(body, { Name = "Prompt", Text = "Choose your key duration", TextSize = 13, Font = UI.Fonts.Bold, Position = UDim2.fromOffset(16, 12), Size = UDim2.fromOffset(220, 18) })

	local durations = getDurations()
	local selected = 1
	local durationBtns = {}

	local function paint()
		for i, b in ipairs(durationBtns) do
			local active = i == selected
			b.BackgroundColor3 = active and C.ACCENT or C.SLIDER_TRK
			b.TextColor3 = active and Color3.fromRGB(6, 14, 24) or C.TEXT
		end
	end

	local y = 46
	for i, d in ipairs(durations) do
		local b = UI.Button(body, { Name = "Duration_" .. i, Text = tostring(d.Name) .. "   (" .. tostring(d.Value) .. ")", TextSize = 13, Size = UDim2.new(1, -32, 0, 36), Position = UDim2.fromOffset(16, y), Color = C.SLIDER_TRK, TextColor = C.TEXT, Radius = 8 })
		b.TextXAlignment = Enum.TextXAlignment.Center
		table.insert(durationBtns, b)
		tracker:track(b.MouseButton1Click:Connect(function()
			selected = i
			paint()
		end))
		y = y + 44
	end

	local cont = UI.Button(body, { Name = "Continue", Text = "Continue", TextSize = 14, Size = UDim2.fromOffset(140, 36), Position = UDim2.new(1, -16, 1, -14), AnchorPoint = Vector2.new(1, 1), Color = C.ACCENT2, TextColor = Color3.fromRGB(6, 14, 24), Radius = 8 })
	tracker:track(cont.MouseButton1Click:Connect(function()
		local chosen = durations[selected] or durations[1]
		selectedDuration = chosen and chosen.Value or "7d"
		KeyUI.Close()
		if onChosen then pcall(onChosen, selectedDuration) end
	end))

	paint()
	return win
end

function KeyUI.ShowVerification(entry, onSuccess, onCancel)
	UI = ensureUI()
	if not UI then return end
	local C = UI.Theme
	local KC = C.KC or UI.KC
	KeyUI.Close()
	verifyClosed = false

	local defaults = getDefaults()
	local win = UI.newWindow({ Title = defaults.Title or FALLBACK_DEFAULTS.Title, Subtitle = defaults.Subtitle or FALLBACK_DEFAULTS.Subtitle, Icon = "🔑", Width = 420, Height = 380, MinHeight = 44 })
	Window = win
	local body = win.Body
	local tracker = win.Tracker

	UI.Label(body, { Name = "Description", Text = defaults.Description or FALLBACK_DEFAULTS.Description, TextSize = 12, Color = C.SUBTEXT, Wrap = true, YAlign = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(20, 12), Size = UDim2.new(1, -40, 0, 36) })

	local keyBox = Instance.new("TextBox")
	keyBox.Name = "KeyBox"
	keyBox.PlaceholderText = "Enter your key..."
	keyBox.Text = ""
	keyBox.ClearTextOnFocus = false
	keyBox.BackgroundColor3 = C.TITLE_BG
	keyBox.TextColor3 = C.TEXT
	keyBox.PlaceholderColor3 = C.SUBTEXT
	keyBox.Font = UI.Fonts.Medium
	keyBox.TextSize = 14
	keyBox.Position = UDim2.fromOffset(20, 58)
	keyBox.Size = UDim2.new(1, -40, 0, 36)
	keyBox.Parent = body
	local keyCorner = Instance.new("UICorner")
	keyCorner.CornerRadius = UDim.new(0, 8)
	keyCorner.Parent = keyBox
	UI.Stroke(keyBox, Color3.fromRGB(20, 45, 75), 1)

	local verifyBtn = UI.Button(body, { Name = "VerifyKey", Text = "Verify Key", TextSize = 14, Size = UDim2.new(0.5, -26, 0, 38), Position = UDim2.fromOffset(20, 108), Radius = 8, Color = KC.primary, TextColor = Color3.fromRGB(255, 255, 255) })
	local getBtn = UI.Button(body, { Name = "GetKey", Text = "Get Key", TextSize = 14, Size = UDim2.new(0.5, -26, 0, 38), Position = UDim2.new(1, -20, 0, 108), AnchorPoint = Vector2.new(1, 0), Radius = 8, Color = KC.surfaceLight, TextColor = KC.textPrimary })

	local status = UI.Label(body, { Name = "Status", Text = "", TextSize = 13, Font = UI.Fonts.Bold, Position = UDim2.fromOffset(20, 162), Size = UDim2.new(1, -40, 0, 20), XAlign = Enum.TextXAlignment.Center })
	StatusLabel = status

	UI.Label(body, { Name = "Hint", Text = "No key yet? Press Get Key to open the key page.", TextSize = 11, Color = C.SUBTEXT, Position = UDim2.fromOffset(20, 196), Size = UDim2.new(1, -40, 0, 16), XAlign = Enum.TextXAlignment.Center })

	KeyUI.SetStatus("Initializing Verification...", KC.textSecondary)
	task.delay(0.5, function()
		if StatusLabel and StatusLabel.Parent and not verifyClosed then
			KeyUI.SetStatus("Enter your key to continue", KC.textSecondary)
		end
	end)

	local fired = false

	tracker:track(win.Close.MouseButton1Click:Connect(function()
		verifyClosed = true
		if onCancel and not fired then pcall(onCancel) end
	end))

	tracker:track(verifyBtn.MouseButton1Click:Connect(function()
		if fired then return end
		local key = keyBox.Text
		if key == "" then
			KeyUI.SetStatus("Please enter a key", KC.textSecondary)
			UI.toast("Enter a key first", KC.error, 2)
			return
		end
		KeyUI.SetStatus("Verifying Key...", KC.textPrimary)
		local ks = getKeySystem()
		if not ks or type(ks.CheckKey) ~= "function" then
			KeyUI.SetStatus("⚠ Verification Unavailable", KC.error)
			UI.toast("⚠ Verification Unavailable", KC.error, 2.5)
			return
		end
		local result = nil
		local ok, r = pcall(function() return ks.CheckKey(key) end)
		if ok then result = r end
		if result and result.valid then
			fired = true
			KeyUI.SetStatus("✓ Access Granted", KC.success)
			UI.toast("Access Granted", KC.success, 2)
			task.delay(0.8, function()
				if not verifyClosed then
					KeyUI.Close()
					if onSuccess then pcall(onSuccess, key) end
				end
			end)
		else
			KeyUI.SetStatus("✕ Invalid Key", KC.error)
			UI.toast("✕ Invalid Key", KC.error, 2.5)
		end
	end))

	tracker:track(getBtn.MouseButton1Click:Connect(function()
		KeyUI.SetStatus("Generating Key Link...", KC.textPrimary)
		local ks = getKeySystem()
		local link = nil
		if ks and type(ks.GetKeyLink) == "function" then
			local ok, r = pcall(function() return ks.GetKeyLink() end)
			if ok and type(r) == "string" and r ~= "" then
				link = r
			elseif selectedDuration then
				local ok2, r2 = pcall(function() return ks.GetKeyLink(selectedDuration) end)
				if ok2 and type(r2) == "string" and r2 ~= "" then link = r2 end
			end
		end
		if not link then
			KeyUI.SetStatus("⚠ Could not generate key link", KC.error)
			UI.toast("⚠ Could not generate key link", KC.error, 2.5)
			return
		end
		local copied = copyToClipboard(link)
		KeyUI.SetStatus(copied and "✓ Key link copied to clipboard!" or "Key link generated", KC.success)
		UI.toast(copied and "Key link copied — open it to get your key" or "Open the key link to get your key", KC.success, 3)
	end))

	return win
end

return KeyUI
