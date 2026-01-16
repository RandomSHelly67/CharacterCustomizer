-- OutfitService.lua
local OutfitService = {}
local HttpService = game:GetService("HttpService")

local OUTFIT_FOLDER = "CharacterCustomizer/Outfits/"

-- Ensure folder exists
if not isfolder("CharacterCustomizer") then makefolder("CharacterCustomizer") end
if not isfolder(OUTFIT_FOLDER) then makefolder(OUTFIT_FOLDER) end

-- Module will receive CharacterService from bootstrap
function OutfitService.Init(characterServiceModule)
    OutfitService.CharacterService = characterServiceModule
end

function OutfitService.SaveOutfit(name)
    local cs = OutfitService.CharacterService
    local data = {
        Head = cs.Head,
        Torso = cs.Torso,
        Face = cs.Face,
        FaceTextureId = cs.FaceTextureId,
        Shirt = cs.Shirt,
        ShirtTemplateId = cs.ShirtTemplateId,
        Pants = cs.Pants,
        PantsTemplateId = cs.PantsTemplateId
    }
    local success, _ = pcall(function()
        writefile(OUTFIT_FOLDER .. name .. ".json", HttpService:JSONEncode(data))
    end)
    return success
end

function OutfitService.LoadOutfit(name)
    local cs = OutfitService.CharacterService
    local success, data = pcall(function()
        local json = readfile(OUTFIT_FOLDER .. name .. ".json")
        return HttpService:JSONDecode(json)
    end)
    if success and data then
        cs.Head = data.Head or {}
        cs.Torso = data.Torso or {}
        cs.Face = data.Face
        cs.FaceTextureId = data.FaceTextureId
        cs.Shirt = data.Shirt
        cs.ShirtTemplateId = data.ShirtTemplateId
        cs.Pants = data.Pants
        cs.PantsTemplateId = data.PantsTemplateId

        local character = game.Players.LocalPlayer.Character
        if character then
            cs.OnCharacterAdded(character)
        end
        return true
    end
    return false
end

function OutfitService.DeleteOutfit(name)
    local success = pcall(function()
        delfile(OUTFIT_FOLDER .. name .. ".json")
    end)
    return success
end

function OutfitService.ListOutfits()
    local files = listfiles(OUTFIT_FOLDER)
    local outfits = {}
    for _, file in ipairs(files) do
        local filename = file:match("([^/\\]+)%.json$")
        if filename then table.insert(outfits, filename) end
    end
    return outfits
end

return OutfitService
