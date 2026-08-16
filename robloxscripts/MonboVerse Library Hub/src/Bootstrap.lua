-- MonboVerse Library Hub :: Bootstrap :: entry point — assembles the hub, wires the flow, plays the intro
-- Run via: loadstring(game:HttpGet("https://raw.githubusercontent.com/MonboSoNasty/RobloxScriptz/main/robloxscripts/MonboVerse%20Library%20Hub/src/Bootstrap.lua"))()

local REPO_OWNER = "MonboSoNasty"
local REPO_NAME = "RobloxScriptz"
local REPO_BRANCH = "main"
local PATH_PREFIX = "robloxscripts/MonboVerse Library Hub/"

local UIS = game:GetService("UserInputService")

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

-- 3. Publish namespaces. IMPORTANT: getgenv().MonboVerse.UI MUST be the
--    design-system module (that is what each UI module's ensureUI() reads for
--    .Theme / .newWindow / .toast). Submodules are attached onto it so
--    KeySystem/KeyUI can find them via MonboVerse.UI.KeyUI etc.
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

-- 4. K keybind — toggles the LIBRARY until a script is loaded; then the loaded
--    script owns K (handler is disconnected, so no duplicate functions).
local libraryActive = true
local kConn = UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode ~= Enum.KeyCode.K then return end
	-- Don't toggle while the user is typing in a TextBox (search / key input).
	if UIS.GetFocusedTextBox then
		local ok, focused = pcall(function() return UIS:GetFocusedTextBox() end)
		if ok and focused ~= nil then return end
	end
	if libraryActive and type(LibraryUI) == "table" then
		LibraryUI.ToggleVisible()
	end
end)

-- 5. Single verified->load path (registered once): hand K to the script, close
--    the hub windows, then load the selected script.
if type(Library.KeySystem) == "table" and type(Library.KeySystem.OnVerified) == "function" then
	Library.KeySystem.OnVerified(function(entry)
		libraryActive = false
		pcall(function() kConn:Disconnect() end)
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

-- 6. Wire the flow: browse -> details -> load script -> key verification -> script.
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

-- 7. Startup cinematic -> library reveal.
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
