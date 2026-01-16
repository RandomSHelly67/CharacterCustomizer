-- bootstrap.lua
local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"
local Loaded = {}

-- Helper to print with a prefix
local function log(msg)
    print("[Bootstrap] " .. msg)
end

-- Load a module from GitHub
local function requireModule(name)
    local url = BASE_URL .. name .. ".lua"
    log("Fetching module: " .. name .. " | URL: " .. url)

    local success, src = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        error("[Bootstrap] Failed to fetch module: " .. name .. "\nError: " .. tostring(src))
    end
    log("Module source fetched: " .. name)

    local fn, err = loadstring(src)
    if not fn then
        error("[Bootstrap] Failed to load module: " .. name .. "\nError: " .. tostring(err))
    end
    log("Module compiled successfully: " .. name)

    local result
    local ok, runErr = pcall(function()
        result = fn()
    end)
    if not ok then
        error("[Bootstrap] Error running module: " .. name .. "\nError: " .. tostring(runErr))
    end

    if not result then
        error("[Bootstrap] Module " .. name .. " did not return anything")
    end

    Loaded[name] = result
    log("Module loaded successfully: " .. name)
    return result
end

-- MAIN
log("Starting bootstrap...")

local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")

log("Initializing OutfitService with CharacterService...")
local success, err = pcall(function()
    OutfitService.Init(CharacterService)
end)
if not success then
    error("[Bootstrap] Failed to initialize OutfitService\nError: " .. tostring(err))
end
log("OutfitService initialized successfully")

log("All modules loaded successfully! Ready to use.")

-- Optional: return modules for executor
return {
    CharacterService = CharacterService,
    OutfitService = OutfitService
}
