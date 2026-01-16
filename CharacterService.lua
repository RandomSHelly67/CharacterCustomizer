-- CharacterService.lua
local CharacterService = {}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Time between applying items
CharacterService.Time = 0.1

-- Storage
CharacterService.Head = {}
CharacterService.Torso = {}
CharacterService.Face = nil
CharacterService.FaceTextureId = nil
CharacterService.Shirt = nil
CharacterService.ShirtTemplateId = nil
CharacterService.Pants = nil
CharacterService.PantsTemplateId = nil

-- Functions
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
    if not success then return false end

    local character = Players.LocalPlayer.Character
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
                local attachmentPoint = accessory.AttachmentPoint
                CharacterService.WeldParts(parent, handle, CFrame.new(0,0.5,0), attachmentPoint.CFrame)
            end
        end
    end
    accessory.Parent = character
    return true
end

-- Apply Face
function CharacterService.ApplyFace(faceId, character)
    character = character or Players.LocalPlayer.Character
    local head = character:FindFirstChild("Head")
    if not head then return false end

    local textureId = faceId
    local success, result = pcall(function()
        local loadedAsset = game:GetObjects("rbxassetid://" .. tostring(faceId))[1]
        if loadedAsset and loadedAsset:IsA("Decal") then
            local texture = loadedAsset.Texture
            textureId = texture:match("%d+") or faceId
            loadedAsset:Destroy()
        elseif loadedAsset then
            loadedAsset:Destroy()
        end
    end)

    CharacterService.Face = faceId
    CharacterService.FaceTextureId = textureId

    local existingFace = head:FindFirstChild("face")
    if existingFace then existingFace:Destroy() end

    local face = Instance.new("Decal")
    face.Name = "face"
    face.Texture = "rbxassetid://" .. tostring(textureId)
    face.Face = Enum.NormalId.Front
    face.Parent = head
end

-- Apply Shirt
function CharacterService.ApplyShirt(shirtId, character)
    character = character or Players.LocalPlayer.Character
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
end

-- Apply Pants
function CharacterService.ApplyPants(pantsId, character)
    character = character or Players.LocalPlayer.Character
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
end

-- Apply Outfit to character
function CharacterService.OnCharacterAdded(character)
    task.wait(CharacterService.Time)
    for _, id in ipairs(CharacterService.Head) do
        CharacterService.AddAccessoryToCharacter(id, character.Head)
    end
    for _, id in ipairs(CharacterService.Torso) do
        CharacterService.AddAccessoryToCharacter(id, character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"))
    end
    if CharacterService.FaceTextureId then
        CharacterService.ApplyFace(CharacterService.Face, character)
    end
    if CharacterService.ShirtTemplateId then
        CharacterService.ApplyShirt(CharacterService.Shirt, character)
    end
    if CharacterService.PantsTemplateId then
        CharacterService.ApplyPants(CharacterService.Pants, character)
    end
end

return CharacterService
