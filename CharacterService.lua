-- CharacterService.lua
local CharacterService = {}

-- Example: apply face
function CharacterService.ApplyFace(faceId)
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local head = char:FindFirstChild("Head")
    if not head then return end

    local face = head:FindFirstChildWhichIsA("Decal")
    if not face then
        face = Instance.new("Decal")
        face.Parent = head
        face.Face = Enum.NormalId.Front
    end

    face.Texture = faceId
end

-- Example: apply shirt
function CharacterService.ApplyShirt(shirtId)
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end

    local shirt = char:FindFirstChildOfClass("Shirt")
    if not shirt then
        shirt = Instance.new("Shirt")
        shirt.Parent = char
    end

    shirt.ShirtTemplate = shirtId
end

-- Example: apply pants
function CharacterService.ApplyPants(pantsId)
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()

    local pants = char:FindFirstChildOfClass("Pants")
    if not pants then
        pants = Instance.new("Pants")
        pants.Parent = char
    end

    pants.PantsTemplate = pantsId
end

return CharacterService
