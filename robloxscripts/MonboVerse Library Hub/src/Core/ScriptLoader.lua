-- MonboVerse Library Hub :: ScriptLoader :: fetches and executes registered scripts safely

local ScriptLoader = {}

local REPO_OWNER = "MonboSoNasty"
local REPO_NAME = "RobloxScriptz"
local REPO_BRANCH = "main"
local PATH_PREFIX = "robloxscripts/MonboVerse Library Hub/"

local function encodeUrl(url)
	return url:gsub(" ", "%%20")
end

local function stripBom(source)
	if type(source) == "string" and #source >= 3 and source:sub(1, 3) == "\239\187\191" then
		return source:sub(4)
	end
	return source
end

function ScriptLoader.FetchSource(entry)
	local ok, source = pcall(function()
		if type(entry) ~= "table" or type(entry.Script) ~= "string" then
			error("FetchSource: invalid entry (missing Script path)", 0)
		end
		local relPath = entry.Script
		if relPath:sub(1, 1) == "/" then relPath = relPath:sub(2) end
		local fullPath = PATH_PREFIX .. relPath

		local env = getgenv and getgenv() or {}
		local mv = env.MonboVerse
		if mv and mv.GitHub and type(mv.GitHub.FetchRaw) == "function" then
			local raw, fetchErr = mv.GitHub.FetchRaw(fullPath)
			if type(raw) == "string" and #raw > 0 then return raw end
			error("FetchSource: GitHub.FetchRaw failed: " .. tostring(fetchErr), 0)
		end

		local url = "https://raw.githubusercontent.com/" .. REPO_OWNER .. "/" .. REPO_NAME .. "/" .. REPO_BRANCH .. "/" .. fullPath
		return game:HttpGet(encodeUrl(url))
	end)
	if not ok then return nil, "FetchSource: " .. tostring(source) end
	if type(source) ~= "string" or #source == 0 then return nil, "FetchSource: empty response" end
	return stripBom(source), nil
end

function ScriptLoader.Load(entry)
	local ok, err = pcall(function()
		if type(entry) ~= "table" or type(entry.Id) ~= "string" then
			error("Load: invalid entry (missing Id)", 0)
		end
		local env = getgenv and getgenv() or {}
		local mv = env.MonboVerse
		local registry = mv and mv.ScriptRegistry or nil
		if not registry or type(registry.GetById) ~= "function" then
			error("Load: ScriptRegistry unavailable — cannot authorize entry", 0)
		end
		if not registry.GetById(entry.Id) then
			error("Load: entry '" .. tostring(entry.Id) .. "' is not registered/authorized", 0)
		end
		local source, fetchErr = ScriptLoader.FetchSource(entry)
		if not source then error("Load: fetch failed: " .. tostring(fetchErr), 0) end
		local chunk, compileErr = loadstring(source)
		if not chunk then error("Load: loadstring failed: " .. tostring(compileErr), 0) end
		local runOk, runErr = pcall(chunk)
		if not runOk then error("Load: script execution error: " .. tostring(runErr), 0) end
	end)
	if ok then return true, nil end
	return false, err
end

return ScriptLoader
