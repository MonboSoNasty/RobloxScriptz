-- MonboVerse Library Hub :: Bootstrap :: entry point — teardown old instance, assemble hub, wire flow, play intro
-- Run via: loadstring(game:HttpGet("https://raw.githubusercontent.com/MonboSoNasty/RobloxScriptz/main/robloxscripts/MonboVerse%20Library%20Hub/src/Bootstrap.lua"))()

local REPO_OWNER = "MonboSoNasty"
local REPO_NAME = "RobloxScriptz"
local REPO_BRANCH = "main"
local PATH_PREFIX = "robloxscripts/MonboVerse Library Hub/"

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

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

-- ============ 0. Teardown any previous instance (reload instead of stack) ============
local function sweepGui(parent)
	if not parent then return end
	local ok, kids = pcall(function() return parent:GetChildren() end)
	if not ok then return end
	for _, child in ipairs(kids) do
		if type(child) == "userdata" and type(child.Name) == "string"
			and child.Name:sub(1, 10) == "MonboVerse" and child:IsA("GuiObject") then
			pcall(function() child:Destroy() end)
		end
	end
end

local prevHub = env.MonboVerse
if type(prevHub) == "table" then
	if prevHub._kConn then pcall(function() prevHub._kConn:Disconnect() end) end
	prevHub._kConn = nil
	if type(prevHub._skipIntro) == "function" then pcall(prevHub._skipIntro) end
	prevHub._skipIntro = nil
end
do
	local okHui, hui = pcall(gethui)
	if okHui and hui then sweepGui(hui) end
	pcall(function() sweepGui(game:GetService("CoreGui")) end)
	pcall(function()
		local lp = Players.LocalPlayer
		if lp then sweepGui(lp:WaitForChild("PlayerGui", 2)) end
	end)
end

-- ============ 1. Library core ============
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

-- ============ 2. UI modules ============
local UI = loadModule("src/UI/UI.lua")
local LibraryUI = loadModule("src/UI/LibraryUI.lua")
local GameDetailsUI = loadModule("src/UI/GameDetailsUI.lua")
local KeyUI = loadModule("src/UI/KeyUI.lua")
local GalaxyIntro = loadModule("src/UI/GalaxyIntro.lua")

-- ============ 3. Publish namespaces + inject dependencies (no getgenv lookup needed at render) ============
if type(UI) == "table" then
	UI.LibraryUI = LibraryUI
	UI.GameDetailsUI = GameDetailsUI
	UI.KeyUI = KeyUI
	UI.GalaxyIntro = GalaxyIntro
end
Library.UI = UI
Library.Services = {
	JunkieConfig = Library.JunkieConfig,
	KeySystem = Library.KeySystem,
	GitHub = Library.GitHub,
	Metadata = Library.Metadata,
}
env.MonboVerse = Library

if type(LibraryUI) == "table" then
	if type(LibraryUI.SetUI) == "function" then LibraryUI.SetUI(UI) end
	if type(LibraryUI.SetRegistry) == "function" then LibraryUI.SetRegistry(Library.ScriptRegistry) end
end
if type(GameDetailsUI) == "table" and type(GameDetailsUI.SetUI) == "function" then
	GameDetailsUI.SetUI(UI)
end
if type(KeyUI) == "table" then
	if type(KeyUI.SetUI) == "function" then KeyUI.SetUI(UI) end
	if type(KeyUI.SetKeySystem) == "function" then KeyUI.SetKeySystem(Library.KeySystem) end
	if type(KeyUI.SetConfig) == "function" then KeyUI.SetConfig(Library.JunkieConfig) end
end

-- ============ 4. K keybind (toggle library; hand off to script on load) ============
local libraryActive = true
local kConn = UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode ~= Enum.KeyCode.K then return end
	if UIS.GetFocusedTextBox then
		local okF, focused = pcall(function() return UIS:GetFocusedTextBox() end)
		if okF and focused ~= nil then return end
	end
	if libraryActive and type(LibraryUI) == "table" then
		LibraryUI.ToggleVisible()
	end
end)
Library._kConn = kConn

-- ============ 5. Verified -> load path (registered once) ============
if type(Library.KeySystem) == "table" and type(Library.KeySystem.OnVerified) == "function" then
	Library.KeySystem.OnVerified(function(entry)
		libraryActive = false
		pcall(function() kConn:Disconnect() end)
		Library._kConn = nil
		if type(LibraryUI) == "table" then pcall(LibraryUI.Hide) end
		if type(GameDetailsUI) == "table" then pcall(GameDetailsUI.Hide) end
		local target = entry or Library.GetSelected()
		if type(Library.ScriptLoader) == "table" then
			Library.ScriptLoader.Load(target)
		end
	end)
end

local function onLoadScript(entry)
	Library.Select(entry)
	if type(Library.KeySystem) == "table" and type(Library.KeySystem.RequestVerification) == "function" then
		Library.KeySystem.RequestVerification(entry)
	elseif type(Library.ScriptLoader) == "table" then
		Library.ScriptLoader.Load(entry)
	end
end

-- ============ 6. Wire the flow: browse -> details -> load -> verify -> script ============
if type(LibraryUI) == "table" then
	LibraryUI.OnSelect(function(entry, action)
		if action == "load" then
			onLoadScript(entry)
		elseif type(GameDetailsUI) == "table" then
			GameDetailsUI.Show(entry)
		end
	end)
end
if type(GameDetailsUI) == "table" then
	GameDetailsUI.OnLoadRequested(onLoadScript)
end

-- ============ 7. Startup cinematic -> library reveal ============
local function start()
	if type(LibraryUI) == "table" then
		LibraryUI.Show()
	end
end

if type(GalaxyIntro) == "table" then
	Library._skipIntro = GalaxyIntro.Skip
	GalaxyIntro.Play(start)
else
	start()
end
