-- CharacterService.lua
local CharacterService = {}
local HttpService = game:GetService("HttpService")

-- Module state
CharacterService.Time = 0.1
CharacterService.Head = {}
CharacterService.Torso = {}
CharacterService.Face = nil
CharacterService.FaceTextureId = nil
CharacterService.Shirt = nil
CharacterService.ShirtTemplateId = nil
CharacterService.Pants = nil
CharacterService.PantsTemplateId = nil

local OUTFIT_FOLDER = "CharacterCustomizer/Outfits/"

-- Ensure folder exists (for saving outfits)
if not isfolder("CharacterCustomizer") then
    makefolder("CharacterCustomizer")
end
if not isfolder(OUTFIT_FOLDER) then
    makefolder(OUTFIT_FOLDER)
end

-- Core utility functions
function CharacterService.WeldParts(part0, part1, c0, c1)
    local weld = Instance.new("Weld")
    weld.Part0 = part0
    weld.Part1 = part1
    weld.C0 = c0
    weld.C1 = c1
    weld.Parent = part0
    return weld
end

function CharacterService.FindAttachment(rootPart, name)
    for _, descendant in pairs(rootPart:GetDescendants()) do
        if descendant:IsA("Attachment") and descendant.Name == name then
            return descendant
        end
    end
end

function CharacterService.AddAccessoryToCharacter(accessoryId, parentPart)
    local success, accessory = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(accessoryId))[1]
    end)
    
    if not success then
        warn("Failed to load accessory: " .. tostring(accessoryId))
        return false
    end
    
    local character = game.Players.LocalPlayer.Character
    accessory.Parent = workspace
    local handle = accessory:FindFirstChild("Handle")
    
    if handle then
        local attachment = handle:FindFirstChildOfClass("Attachment")
        if attachment then
            local parentAttachment = CharacterService.FindAttachment(parentPart, attachment.Name)
            if parentAttachment then
                CharacterService.WeldParts(parentPart, handle, parentAttachment.CFrame, attachment.CFrame)
            end
        else
            local parent = character:FindFirstChild(parentPart.Name)
            if parent then
                local parentCFrame = CFrame.new(0,0.5,0)
                CharacterService.WeldParts(parent, handle, parentCFrame, accessory.AttachmentPoint.CFrame)
            end
        end
    end
    
    accessory.Parent = character
    return true
end

-- Outfit functions
function CharacterService.SaveOutfit(outfitName)
    local outfitData = {
        Head = CharacterService.Head,
        Torso = CharacterService.Torso,
        Face = CharacterService.Face,
        FaceTextureId = CharacterService.FaceTextureId,
        Shirt = CharacterService.Shirt,
        ShirtTemplateId = CharacterService.ShirtTemplateId,
        Pants = CharacterService.Pants,
        PantsTemplateId = CharacterService.PantsTemplateId
    }
    
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(outfitData)
        writefile(OUTFIT_FOLDER .. outfitName .. ".json", json)
    end)
    
    return success
end

function CharacterService.LoadOutfit(outfitName)
    local success, result = pcall(function()
        local json = readfile(OUTFIT_FOLDER .. outfitName .. ".json")
        return HttpService:JSONDecode(json)
    end)
    
    if success and result then
        CharacterService.Head = result.Head or {}
        CharacterService.Torso = result.Torso or {}
        CharacterService.Face = result.Face
        CharacterService.FaceTextureId = result.FaceTextureId
        CharacterService.Shirt = result.Shirt
        CharacterService.ShirtTemplateId = result.ShirtTemplateId
        CharacterService.Pants = result.Pants
        CharacterService.PantsTemplateId = result.PantsTemplateId
        
        local character = game.Players.LocalPlayer.Character
        if character then
            -- Clear existing
            for _, accessory in pairs(character:GetChildren()) do
                if accessory:IsA("Accessory") then
                    accessory:Destroy()
                end
            end
            
            local shirt = character:FindFirstChildOfClass("Shirt")
            if shirt then shirt:Destroy() end
            local pants = character:FindFirstChildOfClass("Pants")
            if pants then pants:Destroy() end
            
            task.wait(0.1)
            
            -- Add accessories
            for _, accessoryId in ipairs(CharacterService.Head) do
                CharacterService.AddAccessoryToCharacter(accessoryId, character.Head)
            end
            for _, accessoryId in ipairs(CharacterService.Torso) do
                CharacterService.AddAccessoryToCharacter(
                    accessoryId,
                    character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
                )
            end
            
            -- Apply face
            if CharacterService.FaceTextureId then
                CharacterService.ApplyFace(CharacterService.FaceTextureId, character)
            end
            
            -- Apply shirt/pants
            if CharacterService.ShirtTemplateId then
                CharacterService.ApplyShirt(CharacterService.ShirtTemplateId, character)
            end
            if CharacterService.PantsTemplateId then
                CharacterService.ApplyPants(CharacterService.PantsTemplateId, character)
            end
        end
        
        return true
    end
    
    return false
end

function CharacterService.DeleteOutfit(outfitName)
    local success = pcall(function()
        delfile(OUTFIT_FOLDER .. outfitName .. ".json")
    end)
    return success
end

function CharacterService.ListOutfits()
    local outfits = {}
    local success, files = pcall(function()
        return listfiles(OUTFIT_FOLDER)
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

-- Apply functions
function CharacterService.ApplyFace(faceId, character)
    character = character or game.Players.LocalPlayer.Character
    local head = character:FindFirstChild("Head")
    if not head then return false end
    
    local textureId = faceId
    local success, result = pcall(function()
        local loadedAsset = game:GetObjects("rbxassetid://" .. tostring(faceId))[1]
        if loadedAsset and loadedAsset:IsA("Decal") then
            textureId = loadedAsset.Texture:match("%d+") or faceId
            loadedAsset:Destroy()
        elseif loadedAsset then
            loadedAsset:Destroy()
        end
    end)
    
    CharacterService.Face = faceId
    CharacterService.FaceTextureId = textureId
    
    local existingFace = head:FindFirstChild("face")
    if existingFace and existingFace:IsA("Decal") then
        existingFace:Destroy()
    end
    
    local face = Instance.new("Decal")
    face.Name = "face"
    face.Texture = "rbxassetid://" .. tostring(textureId)
    face.Face = Enum.NormalId.Front
    face.Parent = head
    
    return true
end

function CharacterService.ApplyShirt(shirtId, character)
    character = character or game.Players.LocalPlayer.Character
    local templateId = shirtId
    local success, result = pcall(function()
        local loadedShirt = game:GetObjects("rbxassetid://" .. tostring(shirtId))[1]
        if loadedShirt and loadedShirt:IsA("Shirt") then
            templateId = loadedShirt.ShirtTemplate:match("%d+") or shirtId
            loadedShirt:Destroy()
        elseif loadedShirt then
            loadedShirt:Destroy()
        end
    end)
    
    CharacterService.Shirt = shirtId
    CharacterService.ShirtTemplateId = templateId
    
    local existingShirt = character:FindFirstChildOfClass("Shirt")
    if existingShirt then existingShirt:Destroy() end
    
    local shirt = Instance.new("Shirt")
    shirt.ShirtTemplate = "rbxassetid://" .. tostring(templateId)
    shirt.Parent = character
    
    return true
end

function CharacterService.ApplyPants(pantsId, character)
    character = character or game.Players.LocalPlayer.Character
    local templateId = pantsId
    local success, result = pcall(function()
        local loadedPants = game:GetObjects("rbxassetid://" .. tostring(pantsId))[1]
        if loadedPants and loadedPants:IsA("Pants") then
            templateId = loadedPants.PantsTemplate:match("%d+") or pantsId
            loadedPants:Destroy()
        elseif loadedPants then
            loadedPants:Destroy()
        end
    end)
    
    CharacterService.Pants = pantsId
    CharacterService.PantsTemplateId = templateId
    
    local existingPants = character:FindFirstChildOfClass("Pants")
    if existingPants then existingPants:Destroy() end
    
    local pants = Instance.new("Pants")
    pants.PantsTemplate = "rbxassetid://" .. tostring(templateId)
    pants.Parent = character
    
    return true
end

-- On character spawn
function CharacterService.OnCharacterAdded(character)
    task.wait(CharacterService.Time)
    
    for _, accessoryId in ipairs(CharacterService.Head) do
        CharacterService.AddAccessoryToCharacter(accessoryId, character.Head)
    end
    for _, accessoryId in ipairs(CharacterService.Torso) do
        CharacterService.AddAccessoryToCharacter(
            accessoryId,
            character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        )
    end
    
    if CharacterService.FaceTextureId then
        CharacterService.ApplyFace(CharacterService.FaceTextureId, character)
    end
    if CharacterService.ShirtTemplateId then
        CharacterService.ApplyShirt(CharacterService.ShirtTemplateId, character)
    end
    if CharacterService.PantsTemplateId then
        CharacterService.ApplyPants(CharacterService.PantsTemplateId, character)
    end
end

-- Connect to character spawn
game.Players.LocalPlayer.CharacterAdded:Connect(CharacterService.OnCharacterAdded)
if game.Players.LocalPlayer.Character then
    CharacterService.OnCharacterAdded(game.Players.LocalPlayer.Character)
end

return CharacterService
