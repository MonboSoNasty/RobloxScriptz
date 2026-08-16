-- MonboVerse Library Hub :: GitHub :: raw GitHub fetchers + library registry + update checks

local GitHub = {
	Repo = {
		Owner = "MonboSoNasty",
		Name = "RobloxScriptz",
		Branch = "main",
	},
}

function GitHub.RawUrl(path)
	local repo = GitHub.Repo
	return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", repo.Owner, repo.Name, repo.Branch, tostring(path or ""))
end

function GitHub.FetchRaw(path)
	local ok, body = pcall(function()
		return game:HttpGet(GitHub.RawUrl(path))
	end)
	if not ok or type(body) ~= "string" then
		return nil, "FetchRaw failed for " .. tostring(path)
	end
	if string.sub(body, 1, 3) == "\239\187\191" then body = string.sub(body, 4) end
	return body, nil
end

function GitHub.FetchJson(path)
	local body, err = GitHub.FetchRaw(path)
	if body == nil then return nil, err end
	local ok, decoded = pcall(function()
		return game:GetService("HttpService"):JSONDecode(body)
	end)
	if not ok or type(decoded) ~= "table" then
		return nil, "FetchJson decode failed for " .. tostring(path)
	end
	return decoded, nil
end

function GitHub.FetchRegistry()
	return GitHub.FetchJson("robloxscripts/MonboVerse Library Hub/config/library.json")
end

function GitHub.CheckForUpdates(entry)
	local result = {
		Current = (type(entry) == "table") and entry.Version or nil,
		Latest = nil,
		UpdateAvailable = false,
	}
	if type(entry) ~= "table" or entry.Id == nil then return result end
	local registry = GitHub.FetchRegistry()
	if registry == nil or type(registry.games) ~= "table" then return result end
	for _, gameEntry in ipairs(registry.games) do
		if type(gameEntry) == "table" and gameEntry.id == entry.Id then
			result.Latest = gameEntry.version
			break
		end
	end
	if result.Latest ~= nil and result.Current ~= nil then
		result.UpdateAvailable = (result.Latest ~= result.Current)
	end
	return result
end

return GitHub
