-- bootstrap.lua
local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"
local Loaded = {}

local function requireModule(name)
    local url = BASE_URL .. name .. ".lua"
    print("[Bootstrap] Fetching module:", name)

    local success, src = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        error("[Bootstrap] Failed to fetch module: " .. name .. " | URL: " .. url)
    end

    local fn, err = loadstring(src)
    if not fn then
        error("[Bootstrap] Failed to load module: " .. name .. "\n" .. err)
    end

    local result = fn()
    if not result then
        error("[Bootstrap] Module " .. name .. " did not return anything")
    end

    Loaded[name] = result
    print("[Bootstrap] Module loaded:", name)
    return result
end

-- Load modules
local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")

print("[Bootstrap] All modules loaded successfully")

-- Optionally return modules for executor
return {
    CharacterService = CharacterService,
    OutfitService = OutfitService
}
