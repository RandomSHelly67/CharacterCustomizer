-- bootstrap.lua (DEBUG)

local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"
local Loaded = {}

local function requireModule(name)
    print("[Bootstrap] Loading module:", name)

    local success, src = pcall(function()
        return game:HttpGet(BASE_URL .. name .. ".lua")
    end)

    if not success then
        error("[Bootstrap] HttpGet failed for " .. name)
    end

    print("[Bootstrap] Source loaded for", name)

    local fn, err = loadstring(src)
    if not fn then
        error("[Bootstrap] loadstring failed for " .. name .. ": " .. tostring(err))
    end

    local ok, result = pcall(fn)
    if not ok then
        error("[Bootstrap] Module runtime error in " .. name .. ": " .. tostring(result))
    end

    if result == nil then
        error("[Bootstrap] Module " .. name .. " did not return anything")
    end

    Loaded[name] = result
    print("[Bootstrap] Module loaded:", name)

    return result
end

-- TEMP: only load State for now
local State = requireModule("State")

print("[Bootstrap] Finished successfully")
