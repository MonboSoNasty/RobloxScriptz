-- MonboVerse Library Hub :: GameDetector :: detects the current game and matches registry entries

local GameDetector = {}

local ScriptRegistry = nil

function GameDetector.SetRegistry(registry)
	ScriptRegistry = registry
end

local function getRegistry()
	if ScriptRegistry then return ScriptRegistry end
	local env = getgenv and getgenv() or {}
	local mv = env.MonboVerse
	if mv and type(mv.ScriptRegistry) == "table" then
		return mv.ScriptRegistry
	end
	return nil
end

function GameDetector.FindEntry(placeId)
	if type(placeId) ~= "number" then return nil end
	local registry = getRegistry()
	if registry and type(registry.FindByPlaceId) == "function" then
		local ok, entry = pcall(registry.FindByPlaceId, registry, placeId)
		if ok then return entry end
	end
	return nil
end

function GameDetector.Detect()
	local placeId = 0
	local okPlace, rawPlaceId = pcall(function() return game.PlaceId end)
	if okPlace and type(rawPlaceId) == "number" then placeId = rawPlaceId end

	local gameId = nil
	local okGame, rawGameId = pcall(function() return game.GameId end)
	if okGame and type(rawGameId) == "number" then gameId = rawGameId end

	local entry = GameDetector.FindEntry(placeId)

	local detected = { PlaceId = placeId, GameId = gameId, Experience = "Unknown", Found = false, Entry = nil }
	if entry then
		detected.Found = true
		detected.Entry = entry
		detected.Experience = entry.Name or "Unknown"
	end
	return detected
end

function GameDetector.GetStatus(entry)
	if type(entry) ~= "table" then
		return entry == nil and "unavailable" or "unknown"
	end
	if entry.Enabled == false then return "disabled" end
	return "compatible"
end

return GameDetector
