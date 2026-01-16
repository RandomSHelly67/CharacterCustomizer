-- CharacterService.lua
local CharacterService = {}
CharacterService.Head = {}
CharacterService.Torso = {}
CharacterService.Face = nil
CharacterService.FaceTextureId = nil
CharacterService.Shirt = nil
CharacterService.ShirtTemplateId = nil
CharacterService.Pants = nil
CharacterService.PantsTemplateId = nil
CharacterService.Time = 0.1

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Helper Functions
local function weldParts(part0, part1, c0, c1)
    local weld = Instance.new("Weld")
    weld.Part0 = part0
    weld.Part1 = part1
    weld.C0 = c0
    weld.C1 = c1
    weld.Parent = part0
    return weld
end

local function findAttachment(rootPart, name)
    for _, descendant in pairs(rootPart:GetDescendants()) do
        if descendant:IsA("Attachment") and descendant.Name == name then
            return descendant
        end
    end
end

function CharacterService:AddAccessory(accessoryId, parentPart)
    local success, accessory = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(accessoryId))[1]
    end)
    if not success or not accessory then
        warn("Failed to load accessory:", accessoryId)
        return false
    end

    local character = Players.LocalPlayer.Character
    accessory.Parent = workspace
    local handle = accessory:FindFirstChild("Handle")

    if handle then
        local attachment = handle:FindFirstChildOfClass("Attachment")
        if attachment then
            local parentAttachment = findAttachment(parentPart, attachment.Name)
            if parentAttachment then
                weldParts(parentPart, handle, parentAttachment.CFrame, attachment.CFrame)
            end
        else
            local parent = character:FindFirstChild(parentPart.Name)
            if parent then
                weldParts(parent, handle, CFrame.new(0, 0.5, 0), accessory.AttachmentPoint.CFrame)
            end
        end
    end
    accessory.Parent = character
    return true
end

-- Apply Face
function CharacterService:ApplyFace(faceId, character)
    local head = character:FindFirstChild("Head")
    if not head then return false end

    local textureId = faceId
    local success, _ = pcall(function()
        local loadedAsset = game:GetObjects("rbxassetid://" .. tostring(faceId))[1]
        if loadedAsset and loadedAsset:IsA("Decal") then
            textureId = loadedAsset.Texture:match("%d+") or faceId
            loadedAsset:Destroy()
        end
    end)

    self.Face = faceId
    self.FaceTextureId = textureId

    local existingFace = head:FindFirstChild("face")
    if existingFace and existingFace:IsA("Decal") then existingFace:Destroy() end

    local face = Instance.new("Decal")
    face.Name = "face"
    face.Texture = "rbxassetid://" .. tostring(textureId)
    face.Face = Enum.NormalId.Front
    face.Parent = head

    return true
end

-- Apply Shirt
function CharacterService:ApplyShirt(shirtId, character)
    local templateId = shirtId
    local success, _ = pcall(function()
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

-- Apply Pants
function CharacterService:ApplyPants(pantsId, character)
    local templateId = pantsId
    local success, _ = pcall(function()
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

-- Apply Outfit (used when loading)
function CharacterService:ApplyOutfit(outfit)
    local character = Players.LocalPlayer.Character
    if not character or not outfit then return end

    self.Head = outfit.Head or {}
    self.Torso = outfit.Torso or {}
    self.Face = outfit.Face
    self.FaceTextureId = outfit.FaceTextureId
    self.Shirt = outfit.Shirt
    self.ShirtTemplateId = outfit.ShirtTemplateId
    self.Pants = outfit.Pants
    self.PantsTemplateId = outfit.PantsTemplateId

    -- Clear existing accessories/clothes
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") then
            item:Destroy()
        end
    end

    task.wait(self.Time)

    for _, id in ipairs(self.Head) do self:AddAccessory(id, character.Head) end
    for _, id in ipairs(self.Torso) do
        self:AddAccessory(id, character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"))
    end
    if self.FaceTextureId then self:ApplyFace(self.FaceTextureId, character) end
    if self.ShirtTemplateId then self:ApplyShirt(self.ShirtTemplateId, character) end
    if self.PantsTemplateId then self:ApplyPants(self.PantsTemplateId, character) end
end

-- On Character Added
function CharacterService:OnCharacterAdded(character)
    task.wait(self.Time)
    self:ApplyOutfit({
        Head = self.Head,
        Torso = self.Torso,
        Face = self.Face,
        FaceTextureId = self.FaceTextureId,
        Shirt = self.Shirt,
        ShirtTemplateId = self.ShirtTemplateId,
        Pants = self.Pants,
        PantsTemplateId = self.PantsTemplateId
    })
end

return CharacterService
