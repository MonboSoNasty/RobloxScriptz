-- MonboVerse Library Hub :: Utils :: shared helpers (safeCall, semver, dates, clipboard, connections)

local Utils = {}

--- pcall wrapper that warns on error. Returns ok, result.
function Utils.safeCall(fn, ...)
	if type(fn) ~= "function" then
		warn("[MonboVerse] Utils.safeCall: fn is not a function")
		return false, "safeCall: fn is not a function"
	end
	local args = { ... }
	local ok, result = pcall(function()
		return fn(table.unpack(args))
	end)
	if not ok then
		warn("[MonboVerse] Utils.safeCall error:", result)
		return false, result
	end
	return true, result
end

local function parseSemver(v)
	if type(v) ~= "string" then return nil end
	v = v:gsub("^%s+", ""):gsub("%s+$", "")
	v = v:gsub("^[vV]", "")
	local parts = {}
	for part in v:gmatch("[^.]+") do
		local n = tonumber(part)
		if not n then return nil end
		table.insert(parts, n)
	end
	if #parts < 1 or #parts > 3 then return nil end
	while #parts < 3 do
		table.insert(parts, 0)
	end
	return parts[1], parts[2], parts[3]
end

function Utils.semverCompare(a, b)
	local aMajor, aMinor, aPatch = parseSemver(a)
	local bMajor, bMinor, bPatch = parseSemver(b)
	if not aMajor or not bMajor then return 0 end
	if aMajor ~= bMajor then return aMajor < bMajor and -1 or 1 end
	if aMinor ~= bMinor then return aMinor < bMinor and -1 or 1 end
	if aPatch ~= bPatch then return aPatch < bPatch and -1 or 1 end
	return 0
end

function Utils.isValidSemver(v)
	local major = parseSemver(v)
	return major ~= nil
end

function Utils.clone(t)
	if type(t) ~= "table" then return t end
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = v
	end
	return copy
end

function Utils.formatDate(isoOrUnix)
	local ok, formatted = pcall(function()
		if type(isoOrUnix) == "number" then
			return os.date("%b %d, %Y", isoOrUnix)
		end
		if type(isoOrUnix) == "string" then
			local year, month, day = isoOrUnix:match("(%d+)%-(%d+)%-(%d+)")
			if year then
				return os.date("%b %d, %Y", os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = 0, min = 0, sec = 0 }))
			end
			return tostring(isoOrUnix)
		end
		return "Unknown"
	end)
	if not ok or type(formatted) ~= "string" then return "Unknown" end
	return formatted
end

function Utils.getPlaceId()
	local ok, id = pcall(function() return game.PlaceId end)
	return (ok and type(id) == "number" and id) or 0
end

function Utils.getGameId()
	local ok, id = pcall(function() return game.GameId end)
	return ok and id or nil
end

function Utils.setClipboard(text)
	if type(text) ~= "string" then return false end
	if setclipboard then
		local ok = pcall(setclipboard, text)
		if ok then return true end
	end
	if Clipboard and type(Clipboard.set) == "function" then
		local ok = pcall(Clipboard.set, text)
		if ok then return true end
	end
	return false
end

local function createConnectionTracker()
	local state = { connections = {} }
	local tracker = {}
	function tracker.track(connection)
		if not connection then return nil end
		table.insert(state.connections, connection)
		return connection
	end
	function tracker.cleanup()
		local connections = state.connections
		for i = 1, #connections do
			local connection = connections[i]
			local ok = pcall(function()
				if type(connection) == "table" and type(connection.Disconnect) == "function" then
					connection:Disconnect()
				end
			end)
			if not ok then
				warn("[MonboVerse] ConnectionTracker: failed to disconnect a connection")
			end
		end
		state.connections = {}
	end
	return tracker
end

Utils.ConnectionTracker = createConnectionTracker()
Utils.ConnectionTracker.new = createConnectionTracker

return Utils
