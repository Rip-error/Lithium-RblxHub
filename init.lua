if not game:IsLoaded() then game.Loaded:Wait() end

local Core = script.Parent
local function load(rel)
    local node = Core
    for part in string.gmatch(rel, "[^/]+") do
        node = node:WaitForChild(part)
    end
    return require(node)
end

_G.LITHIUM = _G.LITHIUM or {}
_G.LITHIUM.Version = "1.0.0"
_G.LITHIUM.Flags = {}
_G.LITHIUM.Connections = {}

local Hook   = load("core/hook")
local Config = load("core/config")
local Remote = load("core/remote")

_G.LITHIUM.Config = Config
_G.LITHIUM.Remote = Remote

Hook.install()

local LIB_URL = "https://raw.githubusercontent.com/YOUR_REPO/YOUR_BRANCH/main/libs/Library.lua"
local THEME_URL = "https://raw.githubusercontent.com/YOUR_REPO/YOUR_BRANCH/main/libs/ThemeManager.lua"
local SAVE_URL  = "https://raw.githubusercontent.com/YOUR_REPO/YOUR_BRANCH/main/libs/SaveManager.lua"

local Library      = loadstring(game:HttpGet(LIB_URL))()
local ThemeManager = loadstring(game:HttpGet(THEME_URL))()
local SaveManager  = loadstring(game:HttpGet(SAVE_URL))()

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true
Library.NotifySide = "Right"

_G.LITHIUM.Library      = Library
_G.LITHIUM.ThemeManager = ThemeManager
_G.LITHIUM.SaveManager  = SaveManager

local Window = Library:CreateWindow({
    Title             = "Lithium",
    Footer            = "lithium | dsc.gg/JDpsqbnH8",
    NotifySide        = "Right",
    ShowCustomCursor  = false,
    Compact           = true,
    AutoShow          = true,
    MobileButtonsSide = "Left",
})

_G.LITHIUM.Window = Window
_G.LITHIUM.Tabs = {
    Main      = Window:AddTab('Main',        'target'),
    Player    = Window:AddTab('Player',      'users'),
    Visual    = Window:AddTab('Visual',      'eye'),
    Character = Window:AddTab('Character',   'user'),
    Misc      = Window:AddTab('Misc',        'heart'),
    Settings  = Window:AddTab('UI Settings', 'settings'),
}

load("core/helpers")
load("core/desync")

load("features/aim")
load("features/aim_loop")
load("features/aim_hud")
load("features/hit_effects")
load("features/killaura")
load("features/gun_mods")
load("features/hitbox")
load("features/legit")
load("features/movement")
load("features/auto_buy")
load("features/trolling")
load("features/misc")
load("features/esp")
load("features/visual")
load("features/world")
load("features/player")
load("features/animation")
load("features/anti_aim")

load("ui/settings")
load("ui/watermark")
load("ui/theme")

warn("[Lithium] loaded")