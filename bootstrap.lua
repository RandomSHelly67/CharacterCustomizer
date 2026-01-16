-- bootstrap.lua
local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"
local Loaded = {}

local function requireModule(name)
    print("[Bootstrap] Loading module:", name)

    local src = game:HttpGet(BASE_URL .. name .. ".lua")
    print("[Bootstrap] Source loaded for", name)

    local fn = loadstring(src)
    local result = fn()

    if not result then
        error("[Bootstrap] Module " .. name .. " did not return anything")
    end

    Loaded[name] = result
    print("[Bootstrap] Module loaded:", name)

    return result
end

local State = requireModule("State")
local CharacterService = requireModule("CharacterService")
-- later: OutfitService, UI

print("[Bootstrap] Finished successfully")
