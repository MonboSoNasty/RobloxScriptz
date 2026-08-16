-- MonboVerse Library Hub :: Library :: orchestrates modules (init, detection, selection, load)

local Library = {}

local REPO_OWNER = "MonboSoNasty"
local REPO_NAME = "RobloxScriptz"
local REPO_BRANCH = "main"
local PATH_PREFIX = "robloxscripts/MonboVerse Library Hub/"

local CORE_MODULES = {
	Utils = "src/Utils.lua",
	ScriptRegistry = "src/Core/ScriptRegistry.lua",
	GameDetector = "src/Core/GameDetector.lua",
	ScriptLoader = "src/Core/ScriptLoader.lua",
}

local SERVICE_MODULES = {
	JunkieConfig = "src/Services/JunkieConfig.lua",
	KeySystem = "src/Services/KeySystem.lua",
	GitHub = "src/Services/GitHub.lua",
	Metadata = "src/Services/Metadata.lua",
}

local function fetchModule(relPath)
	local ok, raw = pcall(function()
		local url = "https://raw.githubusercontent.com/" .. REPO_OWNER .. "/" .. REPO_NAME .. "/" .. REPO_BRANCH .. "/" .. PATH_PREFIX .. relPath
		return game:HttpGet(url:gsub(" ", "%%20"))
	end)
	if not ok or type(raw) ~= "string" or #raw == 0 then return nil end
	if raw:sub(1, 3) == "\239\187\191" then raw = raw:sub(4) end
	local chunk = loadstring(raw)
	if not chunk then return nil end
	local chunkOk, mod = pcall(chunk)
	if not chunkOk or type(mod) ~= "table" then return nil end
	return mod
end

local function resolveModule(name, path)
	if Library[name] ~= nil then return Library[name] end
	local env = getgenv and getgenv() or {}
	if env.MonboVerse and type(env.MonboVerse[name]) == "table" then return env.MonboVerse[name] end
	return fetchModule(path)
end

function Library.Init()
	local ok, err = pcall(function()
		local env = getgenv and getgenv() or {}
		env.MonboVerse = env.MonboVerse or Library

		for name, path in pairs(CORE_MODULES) do
			local mod = resolveModule(name, path)
			if type(mod) ~= "table" then error("Library.Init: failed to load core module '" .. name .. "'", 0) end
			Library[name] = mod
		end

		if type(Library.GameDetector.SetRegistry) == "function" then
			Library.GameDetector.SetRegistry(Library.ScriptRegistry)
		end

		for name, path in pairs(SERVICE_MODULES) do
			local okSvc, mod = pcall(resolveModule, name, path)
			if okSvc and type(mod) == "table" then Library[name] = mod else warn("[MonboVerse] Service not available:", name) end
		end

		-- Publish the services namespace (UI modules resolve via getgenv().MonboVerse.Services).
		Library.Services = {
			JunkieConfig = Library.JunkieConfig,
			KeySystem = Library.KeySystem,
			GitHub = Library.GitHub,
			Metadata = Library.Metadata,
		}

		if type(Library.KeySystem) == "table" and type(Library.KeySystem.Init) == "function" then
			local okKs, ksErr = pcall(Library.KeySystem.Init)
			if not okKs then warn("[MonboVerse] KeySystem.Init failed:", ksErr) end
		end

		Library._detected = Library.GameDetector.Detect()
		if Library._selected == nil then Library._selected = Library._detected.Entry end

		if type(env.MonboVerse) == "table" and env.MonboVerse ~= Library then
			for key, value in pairs(env.MonboVerse) do
				if Library[key] == nil then Library[key] = value end
			end
		end
		env.MonboVerse = Library
	end)
	if ok then return true, nil end
	return nil, err
end

function Library.GetDetected()
	return Library._detected
end

function Library.GetSelected()
	return Library._selected
end

function Library.Select(entry)
	Library._selected = entry
	return entry
end

function Library.GetRegistry()
	if Library.ScriptRegistry and type(Library.ScriptRegistry.Games) == "table" then return Library.ScriptRegistry.Games end
	return {}
end

function Library.LoadSelected()
	local ok, err = pcall(function()
		local selected = Library.GetSelected()
		if not selected then error("LoadSelected: no script selected", 0) end

		if type(Library.KeySystem) == "table" and type(Library.KeySystem.RequestVerification) == "function" then
			-- Register the verified->load callback exactly once to avoid stale duplicate callbacks.
			if not Library._verifWired then
				Library._verifWired = true
				Library.KeySystem.OnVerified(function(entry)
					local target = entry or Library.GetSelected()
					return Library.ScriptLoader.Load(target)
				end)
			end
			Library.KeySystem.RequestVerification(selected)
			return
		end

		Library.ScriptLoader.Load(selected)
	end)
	if ok then return true, nil end
	return false, err
end

return Library
