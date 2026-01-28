-- bootstrap.lua - UPDATED
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
    log("Fetching module: " .. name)
    
    local success, src = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        error("[Bootstrap] Failed to fetch module: " .. name .. "\nError: " .. tostring(src))
    end
    
    local fn, err = loadstring(src)
    if not fn then
        error("[Bootstrap] Failed to load module: " .. name .. "\nError: " .. tostring(err))
    end
    
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

log("Starting bootstrap... | v2.6-7 Outfit Copier2")

-- Load modules
local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")
local ItemEditorService = requireModule("ItemEditorService")
local AvatarCopierService = requireModule("AvatarCopierService")
local GuiService = requireModule("GuiService")

-- Initialize CharacterService
log("Initializing CharacterService...")
CharacterService.Init()

-- Initialize OutfitService
log("Initializing OutfitService...")
OutfitService.Init(CharacterService, ItemEditorService)

-- Initialize ItemEditorService
log("Initializing ItemEditorService...")
ItemEditorService.Init(CharacterService)

-- Initialize AvatarCopierService (NEW)
log("Initializing AvatarCopierService...")
AvatarCopierService.Init(CharacterService)

-- Initialize GuiService
log("Initializing GuiService...")
GuiService.Init(CharacterService, OutfitService, ItemEditorService, AvatarCopierService)

log("All modules loaded successfully! Press Right Shift to toggle GUI.")

_G.CharacterCustomizerModules = {
    CharacterService = CharacterService,
    OutfitService = OutfitService,
    ItemEditorService = ItemEditorService,
    AvatarCopierService = AvatarCopierService,
    GuiService = GuiService
}

return _G.CharacterCustomizerModules
