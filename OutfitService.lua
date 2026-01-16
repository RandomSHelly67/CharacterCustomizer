-- CharacterService.lua
local CharacterService = {}
CharacterService.Time = 0.1

-- Storage for accessories and clothing
CharacterService.Head = {}
CharacterService.Torso = {}
CharacterService.Face = nil
CharacterService.FaceTextureId = nil
CharacterService.Shirt = nil
CharacterService.ShirtTemplateId = nil
CharacterService.Pants = nil
CharacterService.PantsTemplateId = nil

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Core helper functions
function CharacterService:WeldParts(part0, part1, c0, c1)
    local weld = Instance.new("Weld")
    weld.Part0 = part0
    weld.Part1 = part1
    weld.C0 = c0
    weld.C1 = c1
    weld.Parent = part0
    return weld
end

function CharacterService:FindAttachment(rootPart, name)
    for _, descendant in pairs(rootPart:GetDescendants()) do
        if descendant:IsA("Attachment") and descendant.Name == name then
            return descendant
        end
    end
end

function CharacterService:AddAccessoryToCharacter(accessoryId, parentPart)
    local success, accessory = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(accessoryId))[1]
    end)
    
    if not success or not accessory then
        warn("Failed to load accessory: " .. tostring(accessoryId))
        return false
    end
    
    local character = Players.LocalPlayer.Character
    if not character then return false end

    accessory.Parent = workspace
    local handle = accessory:FindFirstChild("Handle")
    
    if handle then
        local attachment = handle:FindFirstChildOfClass("Attachment")
        if attachment then
            local parentAttachment = self:FindAttachment(parentPart, attachment.Name)
            if parentAttachment then
                self:WeldParts(parentPart, handle, parentAttachment.CFrame, attachment.CFrame)
            end
        else
            local parent = character:FindFirstChild(parentPart.Name)
            if parent then
                local attachmentPoint = accessory.AttachmentPoint
                self:WeldParts(parent, handle, CFrame.new(0, 0.5, 0), attachmentPoint.CFrame)
            end
        end
    end
    
    accessory.Parent = character
    return true
end

-- Apply face
function CharacterService:ApplyFace(faceId, character)
    character = character or Players.LocalPlayer.Character
    if not character then return false end

    local head = character:FindFirstChild("Head")
    if not head then return false end

    local textureId = faceId
    local success, result = pcall(function()
        local loadedAsset = game:GetObjects("rbxassetid://" .. tostring(faceId))[1]
        if loadedAsset and loadedAsset:IsA("Decal") then
            textureId = loadedAsset.Texture:match("%d+") or faceId
            loadedAsset:Destroy()
        end
    end)
    
    self.Face = faceId
    self.FaceTextureId = textureId

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

-- Apply shirt
function CharacterService:ApplyShirt(shirtId, character)
    character = character or Players.LocalPlayer.Character
    if not character then return false end

    local templateId = shirtId
    pcall(function()
        local loadedShirt = game:GetObjects("rbxassetid://" .. tostring(shirtId))[1]
        if loadedShirt and loadedShirt:IsA("Shirt") then
            templateId = loadedShirt.ShirtTemplate:match("%d+") or shirtId
            loadedShirt:Destroy()
        end
    end)

    self.Shirt = shirtId
    self.ShirtTemplateId = templateId

    local existingShirt = character:FindFirstChildOfClass("Shirt")
    if existingShirt then existingShirt:Destroy() end

    local shirt = Instance.new("Shirt")
    shirt.ShirtTemplate = "rbxassetid://" .. tostring(templateId)
    shirt.Parent = character

    return true
end

-- Apply pants
function CharacterService:ApplyPants(pantsId, character)
    character = character or Players.LocalPlayer.Character
    if not character then return false end

    local templateId = pantsId
    pcall(function()
        local loadedPants = game:GetObjects("rbxassetid://" .. tostring(pantsId))[1]
        if loadedPants and loadedPants:IsA("Pants") then
            templateId = loadedPants.PantsTemplate:match("%d+") or pantsId
            loadedPants:Destroy()
        end
    end)

    self.Pants = pantsId
    self.PantsTemplateId = templateId

    local existingPants = character:FindFirstChildOfClass("Pants")
    if existingPants then existingPants:Destroy() end

    local pants = Instance.new("Pants")
    pants.PantsTemplate = "rbxassetid://" .. tostring(templateId)
    pants.Parent = character

    return true
end

-- On character added
function CharacterService:OnCharacterAdded(character)
    task.wait(self.Time)

    for _, accessoryId in ipairs(self.Head) do
        self:AddAccessoryToCharacter(accessoryId, character.Head)
    end

    for _, accessoryId in ipairs(self.Torso) do
        local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        self:AddAccessoryToCharacter(accessoryId, torso)
    end

    if self.FaceTextureId then
        self:ApplyFace(self.FaceTextureId, character)
    end

    if self.ShirtTemplateId then
        self:ApplyShirt(self.ShirtTemplateId, character)
    end

    if self.PantsTemplateId then
        self:ApplyPants(self.PantsTemplateId, character)
    end
end

-- Get asset info (optional)
function CharacterService:GetAssetInfo(assetId)
    local success, result = pcall(function()
        local url = "https://economy.roblox.com/v2/assets/" .. tostring(assetId) .. "/details"
        local response = HttpService:GetAsync(url)
        return HttpService:JSONDecode(response)
    end)
    return success and result or nil
end

return CharacterService
