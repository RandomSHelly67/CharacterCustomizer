-- OutfitService.lua
local OutfitService = {}

OutfitService.CharacterService = nil
OutfitService.OUTFIT_FOLDER = "CharacterCustomizer/Outfits/"

local HttpService = game:GetService("HttpService")

-- Initialize with CharacterService
function OutfitService.Init(CharacterService)
    OutfitService.CharacterService = CharacterService
    
    -- Ensure folders exist
    if not isfolder("CharacterCustomizer") then
        makefolder("CharacterCustomizer")
    end
    if not isfolder(OutfitService.OUTFIT_FOLDER) then
        makefolder(OutfitService.OUTFIT_FOLDER)
    end
    
    print("[OutfitService] Initialized with CharacterService")
end

-- Save current outfit to JSON file
function OutfitService.SaveOutfit(name)
    local cs = OutfitService.CharacterService
    if not cs then 
        warn("[OutfitService] CharacterService not initialized")
        return false 
    end
    
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
    
    if success then
        print("[OutfitService] Saved outfit: " .. name)
    else
        warn("[OutfitService] Failed to save outfit: " .. tostring(err))
    end
    
    return success
end

-- Load outfit from JSON file and apply to character
function OutfitService.LoadOutfit(name)
    local cs = OutfitService.CharacterService
    if not cs then 
        warn("[OutfitService] CharacterService not initialized")
        return false 
    end
    
    local success, result = pcall(function()
        local json = readfile(OutfitService.OUTFIT_FOLDER .. name .. ".json")
        return HttpService:JSONDecode(json)
    end)
    
    if not success or not result then 
        warn("[OutfitService] Failed to load outfit: " .. name)
        return false 
    end
    
    -- Update CharacterService storage
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
        -- Clear existing accessories and clothing
        cs.ClearCharacter(character)
        
        task.wait(cs.Time)
        
        -- Apply head accessories
        for _, id in ipairs(cs.Head) do
            cs.AddAccessoryToCharacter(id, character.Head)
        end
        
        -- Apply torso accessories
        for _, id in ipairs(cs.Torso) do
            local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            if torso then
                cs.AddAccessoryToCharacter(id, torso)
            end
        end
        
        -- Apply face (use the stored Face ID, not FaceTextureId)
        if cs.Face then
            cs.ApplyFace(cs.Face, character)
        end
        
        -- Apply shirt (use the stored Shirt ID, not ShirtTemplateId)
        if cs.Shirt then
            cs.ApplyShirt(cs.Shirt, character)
        end
        
        -- Apply pants (use the stored Pants ID, not PantsTemplateId)
        if cs.Pants then
            cs.ApplyPants(cs.Pants, character)
        end
    end
    
    print("[OutfitService] Loaded outfit: " .. name)
    return true
end

-- Delete outfit file
function OutfitService.DeleteOutfit(name)
    local success = pcall(function()
        delfile(OutfitService.OUTFIT_FOLDER .. name .. ".json")
    end)
    
    if success then
        print("[OutfitService] Deleted outfit: " .. name)
    else
        warn("[OutfitService] Failed to delete outfit: " .. name)
    end
    
    return success
end

-- List all saved outfit names
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
