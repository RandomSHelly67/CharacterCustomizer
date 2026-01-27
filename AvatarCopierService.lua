-- AvatarCopierService.lua - Avatar Copying System
local AvatarCopierService = {}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

AvatarCopierService.CharacterService = nil
AvatarCopierService.Cache = {} -- Cache avatars to avoid repeated API calls

function AvatarCopierService.Init(CharacterService)
    AvatarCopierService.CharacterService = CharacterService
    print("[AvatarCopierService] Initialized")
end

-- Get HumanoidDescription from user ID
local function getHumanoidDescription(userId)
    if AvatarCopierService.Cache[userId] then
        print("[AvatarCopierService] Using cached data for user " .. userId)
        return AvatarCopierService.Cache[userId]
    end
    
    local success, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if success and desc then
        AvatarCopierService.Cache[userId] = desc
        return desc
    end
    
    return nil
end

-- Extract all items from character appearance
local function extractAvatarItems(userId)
    local success, characterModel = pcall(function()
        return Players:GetCharacterAppearanceAsync(userId)
    end)
    
    if not success or not characterModel then
        warn("[AvatarCopierService] Failed to get character appearance for user " .. userId)
        return nil
    end
    
    local avatarData = {
        Accessories = {},
        Face = nil,
        Shirt = nil,
        Pants = nil,
        HeadAccessories = {},
        TorsoAccessories = {}
    }
    
    -- Extract items from the model
    for _, item in ipairs(characterModel:GetChildren()) do
        if item:IsA("Accessory") then
            local handle = item:FindFirstChild("Handle")
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshId then
                    -- Extract asset ID from MeshId
                    local assetId = mesh.MeshId:match("%d+")
                    if assetId then
                        local accessoryType = item.AccessoryType
                        
                        -- Categorize by attachment
                        if accessoryType == Enum.AccessoryType.Hat or 
                           accessoryType == Enum.AccessoryType.Hair or 
                           accessoryType == Enum.AccessoryType.Face then
                            table.insert(avatarData.HeadAccessories, tonumber(assetId))
                        elseif accessoryType == Enum.AccessoryType.Back or 
                               accessoryType == Enum.AccessoryType.Waist or 
                               accessoryType == Enum.AccessoryType.Shoulder then
                            table.insert(avatarData.TorsoAccessories, tonumber(assetId))
                        else
                            -- Default to head if unknown
                            table.insert(avatarData.HeadAccessories, tonumber(assetId))
                        end
                        
                        table.insert(avatarData.Accessories, {
                            id = tonumber(assetId),
                            type = accessoryType,
                            name = item.Name
                        })
                    end
                end
            end
        elseif item:IsA("Shirt") then
            local shirtId = item.ShirtTemplate:match("%d+")
            if shirtId then
                avatarData.Shirt = tonumber(shirtId)
            end
        elseif item:IsA("Pants") then
            local pantsId = item.PantsTemplate:match("%d+")
            if pantsId then
                avatarData.Pants = tonumber(pantsId)
            end
        elseif item:IsA("Decal") and item.Name == "face" then
            local faceId = item.Texture:match("%d+")
            if faceId then
                avatarData.Face = tonumber(faceId)
            end
        end
    end
    
    -- Also check the Head for face
    local head = characterModel:FindFirstChild("Head")
    if head then
        local face = head:FindFirstChild("face")
        if face and face:IsA("Decal") then
            local faceId = face.Texture:match("%d+")
            if faceId then
                avatarData.Face = tonumber(faceId)
            end
        end
    end
    
    characterModel:Destroy()
    
    return avatarData
end

-- Check if user has Korblox
local function hasKorblox(userId)
    local desc = getHumanoidDescription(userId)
    if not desc then return false, false end
    
    -- Korblox Right Leg ID: 139607718
    -- Korblox Left Leg ID: 139607673
    local rightLegId = tostring(desc.RightLeg)
    local leftLegId = tostring(desc.LeftLeg)
    
    local hasRight = rightLegId:find("139607718") ~= nil
    local hasLeft = leftLegId:find("139607673") ~= nil
    
    return hasRight, hasLeft
end

-- Check if user has Headless
local function hasHeadless(userId)
    local desc = getHumanoidDescription(userId)
    if not desc then return false end
    
    -- Headless Head ID: 134082579
    local headId = tostring(desc.Head)
    return headId:find("134082579") ~= nil
end

-- Main function to copy avatar
function AvatarCopierService.CopyAvatar(userId, statusCallback)
    local cs = AvatarCopierService.CharacterService
    if not cs then
        warn("[AvatarCopierService] CharacterService not initialized")
        return false
    end
    
    userId = tonumber(userId)
    if not userId then
        warn("[AvatarCopierService] Invalid user ID")
        if statusCallback then statusCallback("Invalid user ID!") end
        return false
    end
    
    if statusCallback then statusCallback("Fetching avatar...") end
    
    -- Clear current avatar
    cs.ClearAll()
    task.wait(0.2)
    
    -- Get avatar data
    local avatarData = extractAvatarItems(userId)
    if not avatarData then
        warn("[AvatarCopierService] Failed to extract avatar data")
        if statusCallback then statusCallback("Failed to load avatar!") end
        return false
    end
    
    if statusCallback then statusCallback("Applying items...") end
    
    -- Apply Face
    if avatarData.Face then
        cs.AddAccessory(avatarData.Face, "Face")
        task.wait(0.1)
    end
    
    -- Apply Shirt
    if avatarData.Shirt then
        cs.AddAccessory(avatarData.Shirt, "Shirt")
        task.wait(0.1)
    end
    
    -- Apply Pants
    if avatarData.Pants then
        cs.AddAccessory(avatarData.Pants, "Pants")
        task.wait(0.1)
    end
    
    -- Apply Head Accessories
    for _, accessoryId in ipairs(avatarData.HeadAccessories) do
        cs.AddAccessory(accessoryId, "Head")
        task.wait(0.05)
    end
    
    -- Apply Torso Accessories
    for _, accessoryId in ipairs(avatarData.TorsoAccessories) do
        cs.AddAccessory(accessoryId, "Torso")
        task.wait(0.05)
    end
    
    if statusCallback then statusCallback("Checking special items...") end
    
    -- Check and apply Headless
    local isHeadless = hasHeadless(userId)
    if isHeadless then
        task.wait(0.2)
        cs.ApplyHeadless(true)
    end
    
    -- Check and apply Korblox
    local hasKorbloxRight, hasKorbloxLeft = hasKorblox(userId)
    if hasKorbloxRight then
        task.wait(0.2)
        cs.ApplyKorblox(true, "Right")
    end
    if hasKorbloxLeft then
        task.wait(0.2)
        cs.ApplyKorblox(true, "Left")
    end
    
    if statusCallback then statusCallback("Avatar copied!") end
    
    print("[AvatarCopierService] Successfully copied avatar from user " .. userId)
    print("  - Accessories: " .. #avatarData.Accessories)
    print("  - Face: " .. tostring(avatarData.Face or "None"))
    print("  - Shirt: " .. tostring(avatarData.Shirt or "None"))
    print("  - Pants: " .. tostring(avatarData.Pants or "None"))
    print("  - Headless: " .. tostring(isHeadless))
    print("  - Korblox: R=" .. tostring(hasKorbloxRight) .. " L=" .. tostring(hasKorbloxLeft))
    
    return true
end

-- Get username from user ID
function AvatarCopierService.GetUsername(userId)
    local success, username = pcall(function()
        return Players:GetNameFromUserIdAsync(userId)
    end)
    
    if success then
        return username
    end
    
    return "Unknown"
end

-- Clear cache for a specific user or all
function AvatarCopierService.ClearCache(userId)
    if userId then
        AvatarCopierService.Cache[userId] = nil
    else
        AvatarCopierService.Cache = {}
    end
end

return AvatarCopierService
