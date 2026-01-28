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
    -- First, get HumanoidDescription which has the actual accessory IDs
    local desc = getHumanoidDescription(userId)
    if not desc then
        warn("[AvatarCopierService] Failed to get HumanoidDescription")
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
    
    -- Get face from HumanoidDescription
    if desc.Face and desc.Face ~= 0 then
        avatarData.Face = desc.Face
    end
    
    -- Get shirt from HumanoidDescription
    if desc.Shirt and desc.Shirt ~= 0 then
        avatarData.Shirt = desc.Shirt
    end
    
    -- Get pants from HumanoidDescription
    if desc.Pants and desc.Pants ~= 0 then
        avatarData.Pants = desc.Pants
    end
    
    -- Get all accessories from HumanoidDescription
    local function addAccessoriesFromString(accessoryString, category)
        if not accessoryString or accessoryString == "" then return end
        
        -- AccessoryBlob format: "id1,id2,id3" or just "id"
        for idStr in string.gmatch(accessoryString, "[^,]+") do
            local id = tonumber(idStr)
            if id and id ~= 0 then
                table.insert(avatarData.Accessories, {
                    id = id,
                    category = category
                })
                
                if category == "Head" then
                    table.insert(avatarData.HeadAccessories, id)
                elseif category == "Torso" then
                    table.insert(avatarData.TorsoAccessories, id)
                end
            end
        end
    end
    
    -- HumanoidDescription accessory properties
    -- These contain the actual accessory asset IDs we need
    if desc.HatAccessory then
        addAccessoriesFromString(desc.HatAccessory, "Head")
    end
    if desc.HairAccessory then
        addAccessoriesFromString(desc.HairAccessory, "Head")
    end
    if desc.FaceAccessory then
        addAccessoriesFromString(desc.FaceAccessory, "Head")
    end
    if desc.NeckAccessory then
        addAccessoriesFromString(desc.NeckAccessory, "Head")
    end
    if desc.ShoulderAccessory then
        addAccessoriesFromString(desc.ShoulderAccessory, "Torso")
    end
    if desc.FrontAccessory then
        addAccessoriesFromString(desc.FrontAccessory, "Torso")
    end
    if desc.BackAccessory then
        addAccessoriesFromString(desc.BackAccessory, "Torso")
    end
    if desc.WaistAccessory then
        addAccessoriesFromString(desc.WaistAccessory, "Torso")
    end
    
    print("[AvatarCopierService] Extracted avatar data:")
    print("  - Face: " .. tostring(avatarData.Face))
    print("  - Shirt: " .. tostring(avatarData.Shirt))
    print("  - Pants: " .. tostring(avatarData.Pants))
    print("  - Head Accessories: " .. #avatarData.HeadAccessories)
    print("  - Torso Accessories: " .. #avatarData.TorsoAccessories)
    
    return avatarData
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
