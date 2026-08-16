-- MonboVerse Library Hub :: KeySystem :: shared centralized Junkie key verification — the ONLY verification entry point (no key UI in game scripts)

local KeySystem = {}

local Junkie = nil
local verifiedKey = nil
local onVerifiedCallbacks = {}
local JunkieConfig = nil

local function resolveConfig()
	if JunkieConfig ~= nil then return JunkieConfig end
	local ok, env = pcall(getgenv)
	if ok and type(env) == "table" then
		local hub = env.MonboVerse
		if type(hub) == "table" then
			local services = hub.Services
			if type(services) == "table" and type(services.JunkieConfig) == "table" then
				JunkieConfig = services.JunkieConfig
			elseif type(hub.JunkieConfig) == "table" then
				JunkieConfig = hub.JunkieConfig
			end
		end
	end
	return JunkieConfig
end

local function resolveKeyUI()
	local ok, env = pcall(getgenv)
	if not ok or type(env) ~= "table" then return nil end
	local hub = env.MonboVerse
	if type(hub) ~= "table" or type(hub.UI) ~= "table" then return nil end
	local keyUI = hub.UI.KeyUI
	if type(keyUI) ~= "table" then return nil end
	return keyUI
end

local function setVerified(key)
	verifiedKey = key
end

local function fireVerified(entry, key)
	for _, callback in ipairs(onVerifiedCallbacks) do
		pcall(callback, entry, key)
	end
end

local function trySavedKey(entry)
	local saved = KeySystem.LoadSavedKey(entry)
	if saved ~= nil and type(saved.Key) == "string" and saved.Key ~= "" then
		setVerified(saved.Key)
		fireVerified(entry, saved.Key)
		return true
	end
	return false
end

function KeySystem.Init()
	local config = resolveConfig()
	if config == nil then
		warn("[MonboVerse] KeySystem.Init failed: JunkieConfig not available")
		return false
	end

	local ok, sdk = pcall(function()
		local compiled = loadstring(game:HttpGet(config.SDKUrl))
		if type(compiled) ~= "function" then error("Junkie SDK failed to compile") end
		return compiled()
	end)
	if not ok or type(sdk) ~= "table" then
		Junkie = nil
		warn("[MonboVerse] KeySystem.Init failed: could not load Junkie SDK")
		return false
	end

	Junkie = sdk
	local okConfig = pcall(function()
		Junkie.service = config.Service
		Junkie.identifier = config.Identifier
		Junkie.provider = config.JunkieSDKProvider
	end)
	if not okConfig then
		Junkie = nil
		warn("[MonboVerse] KeySystem.Init failed: could not configure Junkie SDK")
		return false
	end

	return true
end

function KeySystem.GetKeyLink(durationValue)
	if Junkie == nil then return nil end
	-- Prefer a duration-aware call; fall back to the no-arg call (SDK signature varies).
	local ok, link = pcall(function()
		return Junkie.get_key_link(durationValue)
	end)
	if ok and type(link) == "string" and link ~= "" then return link end
	local ok2, link2 = pcall(function()
		return Junkie.get_key_link()
	end)
	if ok2 and type(link2) == "string" and link2 ~= "" then return link2 end
	return nil
end

function KeySystem.CheckKey(key)
	if Junkie == nil or type(key) ~= "string" then return nil end
	local ok, result = pcall(function() return Junkie.check_key(key) end)
	if not ok then return nil end
	if type(result) == "table" then return { valid = not not result.valid } end
	if type(result) == "boolean" then return { valid = result } end
	return nil
end

function KeySystem.SaveKey(key, entry)
	if type(key) ~= "string" or key == "" then return false end
	local payload = { Key = key, VerifiedAt = os.time(), ScriptId = entry and entry.Id or nil }
	local saved = pcall(function()
		local json = game:GetService("HttpService"):JSONEncode(payload)
		writefile("monboverse_key.json", json)
	end)
	return saved
end

function KeySystem.LoadSavedKey(entry)
	local okRead, raw = pcall(readfile, "monboverse_key.json")
	if not okRead or type(raw) ~= "string" or raw == "" then return nil end
	local okDecode, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(raw)
	end)
	if not okDecode or type(data) ~= "table" then return nil end
	if type(data.Key) ~= "string" or data.Key == "" then return nil end
	if entry ~= nil and entry.Id ~= nil and data.ScriptId ~= nil and data.ScriptId ~= entry.Id then return nil end
	if Junkie == nil then return nil end
	local check = KeySystem.CheckKey(data.Key)
	if check == nil or not check.valid then
		KeySystem.ClearSavedKey()
		return nil
	end
	return data
end

function KeySystem.ClearSavedKey()
	return pcall(delfile, "monboverse_key.json")
end

function KeySystem.IsVerified()
	return verifiedKey ~= nil
end

function KeySystem.GetVerifiedKey()
	return verifiedKey
end

function KeySystem.RequestVerification(entry)
	if trySavedKey(entry) then return true end

	local keyUI = resolveKeyUI()
	if keyUI == nil then
		local link = KeySystem.GetKeyLink(entry and entry.KeyDuration or "1d")
		if link ~= nil then
			warn("[MonboVerse] KeyUI not found — verification link: " .. link .. " (verify via KeySystem.CheckKey)")
		end
		return false
	end

	local function onSuccess(key)
		if type(key) == "table" then key = key.Key end
		if type(key) ~= "string" or key == "" then return end
		local check = KeySystem.CheckKey(key)
		if check == nil or not check.valid then return end
		setVerified(key)
		KeySystem.SaveKey(key, entry)
		fireVerified(entry, key)
	end

	local function onCancel() end

	pcall(function()
		keyUI.ShowDurationSelect(entry, function()
			keyUI.ShowVerification(entry, onSuccess, onCancel)
		end)
	end)

	return true
end

function KeySystem.Show()
	pcall(function()
		local keyUI = resolveKeyUI()
		if keyUI ~= nil and type(keyUI.Show) == "function" then keyUI.Show() end
	end)
end

function KeySystem.Hide()
	pcall(function()
		local keyUI = resolveKeyUI()
		if keyUI == nil then return end
		if type(keyUI.Hide) == "function" then keyUI.Hide() elseif type(keyUI.Close) == "function" then keyUI.Close() end
	end)
end

function KeySystem.OnVerified(callback)
	if type(callback) ~= "function" then return end
	table.insert(onVerifiedCallbacks, callback)
end

return KeySystem
