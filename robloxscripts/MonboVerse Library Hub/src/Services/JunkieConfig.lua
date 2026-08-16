-- MonboVerse Library Hub :: JunkieConfig :: single source of truth for Junkie config (with optional gitignored secret overrides)

-- NOTE: This is the ONLY module allowed to hold Junkie service/identifier/provider values.
-- Real secrets live in config/secrets.json (gitignored) and are shallow-merged below at load time.
-- No other module may duplicate these credentials.

local KeyConfig = {
	Provider = "TimePicker",
	Service = "TimePicker",
	Identifier = "1037885",
	JunkieSDKProvider = "YouPickTime",
	SDKUrl = "https://jnkie.com/sdk/library.lua",
	KeyDurations = {
		{ Name = "1 Day", Value = "1d" },
		{ Name = "3 Days", Value = "3d" },
		{ Name = "7 Days", Value = "7d" },
		{ Name = "30 Days", Value = "30d" },
	},
	Defaults = {
		Title = "MonboVerse Verification",
		Subtitle = "Powered by Junkie",
		Description = "Complete verification to load this script",
	},
}

-- Merge optional overrides from config/secrets.json so real secrets never live in committed code.
-- Wrapped fully in pcall: if the file is missing, unreadable, or not valid JSON, defaults win.
pcall(function()
	local okRead, raw = pcall(readfile, "config/secrets.json")
	if not okRead or type(raw) ~= "string" or raw == "" then
		return
	end
	local okDecode, decoded = pcall(function()
		return game:GetService("HttpService"):JSONDecode(raw)
	end)
	if not okDecode or type(decoded) ~= "table" then
		return
	end
	for key, value in pairs(decoded) do
		KeyConfig[key] = value
	end
end)

return KeyConfig
