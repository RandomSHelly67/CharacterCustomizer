-- OutfitService.lua
local OutfitService = {}
local HttpService = game:GetService("HttpService")
local CharacterService = require(game:GetService("Players").LocalPlayer:WaitForChild("Character"))

local OUTFIT_FOLDER = "CharacterCustomizer/Outfits/"

-- Ensure folder exists
if not isfolder("CharacterCustomizer") then makefolder("CharacterCustomizer") end
if not isfolder(OUTFIT_FOLDER) then makefolder(OUTFIT_FOLDER) end

function OutfitService.SaveOutfit(name)
    local data = {
        Head = CharacterService.Head,
        Torso = CharacterService.Torso,
        Face = CharacterService.Face,
        FaceTextureId = CharacterService.FaceTextureId,
        Shirt = CharacterService.Shirt,
        ShirtTemplateId = CharacterService.ShirtTemplateId,
        Pants = CharacterService.Pants,
        PantsTemplateId = CharacterService.PantsTemplateId
    }
    local success, _ = pcall(function()
        writefile(OUTFIT_FOLDER .. name .. ".json", HttpService:JSONEncode(data))
    end)
    return success
end

function OutfitService.LoadOutfit(name)
    local success, data = pcall(function()
        local json = readfile(OUTFIT_FOLDER .. name .. ".json")
        return HttpService:JSONDecode(json)
    end)
    if success and data then
        CharacterService.Head = data.Head or {}
        CharacterService.Torso = data.Torso or {}
        CharacterService.Face = data.Face
        CharacterService.FaceTextureId = data.FaceTextureId
        CharacterService.Shirt = data.Shirt
        CharacterService.ShirtTemplateId = data.ShirtTemplateId
        CharacterService.Pants = data.Pants
        CharacterService.PantsTemplateId = data.PantsTemplateId

        local character = game.Players.LocalPlayer.Character
        if character then
            CharacterService.OnCharacterAdded(character)
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
