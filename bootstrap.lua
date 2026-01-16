-- bootstrap.lua
local HttpService = game:GetService("HttpService")

local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"

local Loaded = {}

local function requireModule(name)
    if Loaded[name] then
        return Loaded[name]
    end

    local src = game:HttpGet(BASE_URL .. name .. ".lua")
    local fn = loadstring(src)
    local result = fn()

    Loaded[name] = result
    return result
end

-- Load main systems
local State = requireModule("State")
local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")
local UI = requireModule("UI")

-- Initialize UI
UI.Init({
    State = State,
    CharacterService = CharacterService,
    OutfitService = OutfitService
})
