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
local OutfitService = requireModule("OutfitService")

-- Save current character as "MyOutfit"
OutfitService.SaveOutfit("MyOutfit", {
    Head = CharacterService.Head,
    Torso = CharacterService.Torso,
    Face = CharacterService.Face,
    FaceTextureId = CharacterService.FaceTextureId,
    Shirt = CharacterService.Shirt,
    ShirtTemplateId = CharacterService.ShirtTemplateId,
    Pants = CharacterService.Pants,
    PantsTemplateId = CharacterService.PantsTemplateId
})

-- Load an outfit
local outfit = OutfitService.LoadOutfit("MyOutfit")
if outfit then
    CharacterService.Head = outfit.Head or {}
    CharacterService.Torso = outfit.Torso or {}
    CharacterService.Face = outfit.Face
    CharacterService.FaceTextureId = outfit.FaceTextureId
    CharacterService.Shirt = outfit.Shirt
    CharacterService.ShirtTemplateId = outfit.ShirtTemplateId
    CharacterService.Pants = outfit.Pants
    CharacterService.PantsTemplateId = outfit.PantsTemplateId

    -- Apply immediately
    if game.Players.LocalPlayer.Character then
        CharacterService.OnCharacterAdded(game.Players.LocalPlayer.Character)
    end
end
