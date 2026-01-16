local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"
local Loaded = {}

local function requireModule(name)
    if Loaded[name] then return Loaded[name] end
    local src = game:HttpGet(BASE_URL .. name .. ".lua")
    local fn = loadstring(src)
    local result = fn()
    Loaded[name] = result
    return result
end

-- Load core modules
local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")
local State = requireModule("State")

-- Load GUI
local GUI = requireModule("GUI")
local gui = GUI.new()
