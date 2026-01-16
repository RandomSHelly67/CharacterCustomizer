-- OutfitService.lua
local OutfitService = {}
OutfitService.CharacterService = nil  -- Will be set in Init
OutfitService.OUTFIT_FOLDER = "CharacterCustomizer/Outfits/"

local HttpService = game:GetService("HttpService")

-- Initialize with CharacterService
function OutfitService.Init(CharacterService)
    OutfitService.CharacterService = CharacterService

    -- Ensure folder exists
    if not isfolder("CharacterCustomizer") then
        makefolder("CharacterCustomizer")
    end
    if not isfolder(OutfitService.OUTFIT_FOLDER) then
        makefolder(OutfitService.OUTFIT_FOLDER)
    end
end

-- Save an outfit
function OutfitService.SaveOutfit(name)
    local cs = OutfitService.CharacterService
    if not cs then return false end

    local outfitData = {
        Head = cs.Head,
        Torso = cs.Torso,
        Face = cs.Face,
        FaceTextureId = cs.FaceTextureId,
        Shirt = cs.Shirt,
        ShirtTemplateId = cs.ShirtTemplateId,
        Pants = cs.Pants,
        PantsTemplateId = cs.PantsTemplateId
    }

    local success, err = pcall(function()
        local json = HttpService:JSONEncode(outfitData)
        writefile(OutfitService.OUTFIT_FOLDER .. name .. ".json", json)
    end)

    return success
end

-- Load an outfit
function OutfitService.LoadOutfit(name)
    local cs = OutfitService.CharacterService
    if not cs then return false end

    local success, result = pcall(function()
        local json = readfile(OutfitService.OUTFIT_FOLDER .. name .. ".json")
        return HttpService:JSONDecode(json)
    end)

    if not success or not result then return false end

    cs.Head = result.Head or {}
    cs.Torso = result.Torso or {}
    cs.Face = result.Face
    cs.FaceTextureId = result.FaceTextureId
    cs.Shirt = result.Shirt
    cs.ShirtTemplateId = result.ShirtTemplateId
    cs.Pants = result.Pants
    cs.PantsTemplateId = result.PantsTemplateId

    local character = game.Players.LocalPlayer.Character
    if character then
        -- Clear old accessories
        for _, accessory in pairs(character:GetChildren()) do
            if accessory:IsA("Accessory") then
                accessory:Destroy()
            end
        end
        -- Clear old clothing
        local shirt = character:FindFirstChildOfClass("Shirt")
        if shirt then shirt:Destroy() end
        local pants = character:FindFirstChildOfClass("Pants")
        if pants then pants:Destroy() end

        task.wait(cs.Time)

        -- Apply accessories
        for _, id in ipairs(cs.Head) do
            cs:AddAccessoryToCharacter(id, character.Head)
        end
        for _, id in ipairs(cs.Torso) do
            local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            cs:AddAccessoryToCharacter(id, torso)
        end

        -- Apply face/clothing
        if cs.FaceTextureId then cs:ApplyFace(cs.FaceTextureId, character) end
        if cs.ShirtTemplateId then cs:ApplyShirt(cs.ShirtTemplateId, character) end
        if cs.PantsTemplateId then cs:ApplyPants(cs.PantsTemplateId, character) end
    end

    return true
end

-- Delete an outfit
function OutfitService.DeleteOutfit(name)
    local success = pcall(function()
        delfile(OutfitService.OUTFIT_FOLDER .. name .. ".json")
    end)
    return success
end

-- List all saved outfits
function OutfitService.ListOutfits()
    local outfits = {}
    local success, files = pcall(function()
        return listfiles(OutfitService.OUTFIT_FOLDER)
    end)

    if success and files then
        for _, filePath in ipairs(files) do
            local fileName = filePath:match("([^/\\]+)%.json$")
            if fileName then
                table.insert(outfits, fileName)
            end
        end
    end

    return outfits
end

return OutfitService
