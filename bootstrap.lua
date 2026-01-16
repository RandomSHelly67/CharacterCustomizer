-- bootstrap.lua
-- Prevent multiple loads
if _G.CharacterCustomizerLoaded then
    warn("[Bootstrap] Already loaded! Returning cached modules.")
    return _G.CharacterCustomizerModules
end

local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"
local Loaded = {}

local function log(msg)
    print("[Bootstrap] " .. msg)
end

local function requireModule(name)
    local cacheBust = "?v=" .. tostring(math.random(100000, 999999))
    local url = BASE_URL .. name .. ".lua" .. cacheBust
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

log("Starting bootstrap...")

-- Load modules
local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")
local ItemEditorService = requireModule("ItemEditorService")

-- Initialize CharacterService
log("Initializing CharacterService...")
local success, err = pcall(function()
    CharacterService.Init()
end)
if not success then
    error("[Bootstrap] Failed to initialize CharacterService\nError: " .. tostring(err))
end
log("CharacterService initialized successfully")

-- Initialize OutfitService
log("Initializing OutfitService with CharacterService...")
success, err = pcall(function()
    OutfitService.Init(CharacterService)
end)
if not success then
    error("[Bootstrap] Failed to initialize OutfitService\nError: " .. tostring(err))
end
log("OutfitService initialized successfully")

-- Initialize ItemEditorService
log("Initializing ItemEditorService with CharacterService...")
success, err = pcall(function()
    ItemEditorService.Init(CharacterService)
end)
if not success then
    error("[Bootstrap] Failed to initialize ItemEditorService\nError: " .. tostring(err))
end
log("ItemEditorService initialized successfully")

log("All modules loaded successfully! Ready to use.")

-- Store in global to prevent re-loading
_G.CharacterCustomizerLoaded = true
_G.CharacterCustomizerModules = {
    CharacterService = CharacterService,
    OutfitService = OutfitService,
    ItemEditorService = ItemEditorService
}

return _G.CharacterCustomizerModules
