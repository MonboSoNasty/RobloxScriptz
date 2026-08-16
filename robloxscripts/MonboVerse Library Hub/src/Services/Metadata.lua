-- MonboVerse Library Hub :: Metadata :: metadata manifest loader + cached Roblox game-icon lookup

local Metadata = {}

local iconCache = {}

function Metadata.Get(entry)
	local path = (type(entry) == "table") and entry.Metadata or nil
	if type(path) ~= "string" or path == "" then return {} end
	local okRead, raw = pcall(readfile, path)
	if not okRead or type(raw) ~= "string" or raw == "" then return {} end
	local okDecode, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(raw)
	end)
	if not okDecode or type(data) ~= "table" then return {} end
	return data
end

function Metadata.GetGameMetaFromRoblox(placeId)
	if type(placeId) ~= "number" and type(placeId) ~= "string" then return nil end
	local url = "https://thumbnails.roblox.com/v1/places/gameicons?placeIds=" .. tostring(placeId) .. "&size=256x256&format=Png&isCircular=false"
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if not ok or type(body) ~= "string" then return nil end
	local okDecode, data = pcall(function() return game:GetService("HttpService"):JSONDecode(body) end)
	if not okDecode or type(data) ~= "table" then return nil end
	return data
end

function Metadata.GetGameIcon(entry)
	local placeId = nil
	if type(entry) == "table" and type(entry.PlaceIds) == "table" then placeId = entry.PlaceIds[1] end
	if placeId ~= nil then
		local cached = iconCache[placeId]
		if cached ~= nil then
			if cached ~= false then return cached end
		else
			local icon = nil
			local ok, meta = pcall(Metadata.GetGameMetaFromRoblox, placeId)
			if ok and type(meta) == "table" and type(meta.data) == "table" then
				local first = meta.data[1]
				if type(first) == "table" and type(first.imageUrl) == "string" and first.imageUrl ~= "" then icon = first.imageUrl end
			end
			iconCache[placeId] = icon or false
			if icon ~= nil then return icon end
		end
	end
	if type(entry) == "table" and type(entry.Icon) == "string" and entry.Icon ~= "" then return entry.Icon end
	return nil
end

function Metadata.ClearCache()
	iconCache = {}
end

return Metadata
