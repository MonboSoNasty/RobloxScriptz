-- MonboVerse Library Hub :: ScriptRegistry :: authorized game/script registry with lookup helpers

local ScriptRegistry = {
	Version = "1.0.0",
	Games = {
		{
			Id = "moon-incremental",
			Name = "Moon Incremental",
			PlaceIds = {}, -- TODO: add real PlaceId
			UniverseId = nil,
			Script = "scripts/MoonIncremental.lua",
			Metadata = "metadata/MoonIncremental.json",
			Version = "2.0.0",
			Enabled = true,
			Description = "Moon Incremental automation/features",
			Author = "NVHeadMonbo",
			Tags = { "incremental", "moon", "automation" },
			Status = "stable",
			Icon = nil,
			Thumbnail = nil,
			UpdatedAt = "2026-08-16",
			Changelog = { "Improved UI", "Added library integration", "Centralized key system" },
		},
	},
}

function ScriptRegistry.GetGames()
	return ScriptRegistry.Games
end

function ScriptRegistry.GetById(id)
	if type(id) ~= "string" then return nil end
	for _, entry in ipairs(ScriptRegistry.Games) do
		if entry.Id == id then return entry end
	end
	return nil
end

function ScriptRegistry.FindByPlaceId(placeId)
	if type(placeId) ~= "number" then return nil end
	for _, entry in ipairs(ScriptRegistry.Games) do
		local placeIds = entry.PlaceIds or {}
		for _, pid in ipairs(placeIds) do
			if pid == placeId then return entry end
		end
	end
	return nil
end

function ScriptRegistry.AddGame(entry)
	if type(entry) ~= "table" or type(entry.Id) ~= "string" then return false end
	if ScriptRegistry.GetById(entry.Id) then return false end
	table.insert(ScriptRegistry.Games, entry)
	return true
end

function ScriptRegistry.RemoveGame(id)
	if type(id) ~= "string" then return false end
	for i, entry in ipairs(ScriptRegistry.Games) do
		if entry.Id == id then
			table.remove(ScriptRegistry.Games, i)
			return true
		end
	end
	return false
end

return ScriptRegistry
