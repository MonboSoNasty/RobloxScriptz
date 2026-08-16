-- MonboVerse Library Hub :: Bootstrap :: entry point — assembles the hub, wires the flow, plays the intro
-- Run via: loadstring(game:HttpGet("https://raw.githubusercontent.com/MonboSoNasty/RobloxScriptz/main/robloxscripts/MonboVerse%20Library%20Hub/src/Bootstrap.lua"))()

local REPO_OWNER = "MonboSoNasty"
local REPO_NAME = "RobloxScriptz"
local REPO_BRANCH = "main"
local PATH_PREFIX = "robloxscripts/MonboVerse Library Hub/"

local function fetchSource(relPath)
	local ok, raw = pcall(function()
		local url = ("https://raw.githubusercontent.com/%s/%s/%s/%s"):format(REPO_OWNER, REPO_NAME, REPO_BRANCH, PATH_PREFIX .. relPath)
		return game:HttpGet(url:gsub(" ", "%%20"))
	end)
	if not ok or type(raw) ~= "string" or #raw == 0 then return nil end
	if raw:sub(1, 3) == "\239\187\191" then raw = raw:sub(4) end
	return raw
end

local function loadModule(relPath)
	local raw = fetchSource(relPath)
	if not raw then return nil end
	local chunk = loadstring(raw)
	if not chunk then return nil end
	local ok, mod = pcall(chunk)
	if not ok or type(mod) ~= "table" then return nil end
	return mod
end

local env = getgenv and getgenv() or _G

-- 1. Library core (fetch if not already present).
local Library = env.MonboVerse
if type(Library) ~= "table" or type(Library.Init) ~= "function" then
	Library = loadModule("src/Core/Library.lua")
end
if type(Library) ~= "table" then
	warn("[MonboVerse] Bootstrap: failed to load Library core")
	return
end

local okInit, initErr = Library.Init()
if not okInit then
	warn("[MonboVerse] Bootstrap: Library.Init failed:", initErr)
end

-- 2. UI modules.
local UI = loadModule("src/UI/UI.lua")
local LibraryUI = loadModule("src/UI/LibraryUI.lua")
local GameDetailsUI = loadModule("src/UI/GameDetailsUI.lua")
local KeyUI = loadModule("src/UI/KeyUI.lua")
local GalaxyIntro = loadModule("src/UI/GalaxyIntro.lua")

-- 3. Publish namespaces so modules resolve each other via getgenv().MonboVerse.
Library.UI = { UI = UI, LibraryUI = LibraryUI, GameDetailsUI = GameDetailsUI, KeyUI = KeyUI, GalaxyIntro = GalaxyIntro }
Library.Services = { JunkieConfig = Library.JunkieConfig, KeySystem = Library.KeySystem, GitHub = Library.GitHub, Metadata = Library.Metadata }
env.MonboVerse = Library

-- 4. Wire the flow: browse -> details -> load script -> key verification -> script.
if type(LibraryUI) == "table" and type(GameDetailsUI) == "table" then
	LibraryUI.OnSelect(function(entry, action)
		if action == "load" then
			Library.Select(entry)
			Library.LoadSelected()
		else
			GameDetailsUI.Show(entry)
		end
	end)
end
if type(GameDetailsUI) == "table" then
	GameDetailsUI.OnLoadRequested(function(entry)
		Library.Select(entry)
		Library.LoadSelected()
	end)
end

-- 5. Startup cinematic -> library reveal.
local function start()
	if type(LibraryUI) == "table" then
		LibraryUI.Show()
	end
end

if type(GalaxyIntro) == "table" then
	GalaxyIntro.Play(start)
else
	start()
end
