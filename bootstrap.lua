-- bootstrap.lua
if _G.CharacterCustomizerLoaded then
    warn("[Bootstrap] Already loaded! Use _G.Modules to access.")
    return _G.Modules
end

local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"

local function log(msg)
    print("[Bootstrap] " .. msg)
end

local function requireModule(name)
    local cacheBust = "?v=" .. tostring(math.random(100000, 999999))
    local url = BASE_URL .. name .. ".lua" .. cacheBust
    log("Fetching module: " .. name)
    
    local src = game:HttpGet(url)
    log("Module source fetched: " .. name)
    
    local fn = loadstring(src)
    log("Module compiled successfully: " .. name)
    
    local result = fn()
    log("Module loaded successfully: " .. name)
    
    return result
end

log("Starting bootstrap...")

-- Load modules
local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")
local ItemEditorService = requireModule("ItemEditorService")

-- Initialize ONLY CharacterService first to test
log("Initializing CharacterService...")
CharacterService.Init()
log("CharacterService initialized successfully")

-- COMMENT OUT THESE FOR NOW TO TEST:
-- log("Initializing OutfitService...")
-- OutfitService.Init(CharacterService)
-- log("OutfitService initialized successfully")

-- log("Initializing ItemEditorService...")
-- ItemEditorService.Init(CharacterService)
-- log("ItemEditorService initialized successfully")

log("Bootstrap complete!")

_G.CharacterCustomizerLoaded = true
_G.Modules = {
    CharacterService = CharacterService,
    OutfitService = OutfitService,
    ItemEditorService = ItemEditorService
}

return _G.Modules
