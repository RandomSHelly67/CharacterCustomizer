local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"
local Loaded = {}

local function requireModule(name)
    local url = BASE_URL .. name .. ".lua"
    local fn = loadstring(game:HttpGet(url))()
    Loaded[name] = fn
    return fn
end

local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")
OutfitService.Init(CharacterService)
return { CharacterService = CharacterService, OutfitService = OutfitService }
