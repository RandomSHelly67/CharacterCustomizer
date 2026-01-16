-- CharacterService.lua - Phase 1 Complete
local CharacterService = {}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Settings
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

-- Advanced Storage
CharacterService.ItemMetadata = {} -- Tracks when items were added
CharacterService.History = {} -- For undo functionality
CharacterService.MaxHistorySize = 50
CharacterService.Favorites = {} -- Favorite items with names

-- Internal
CharacterService._characterConnection = nil

--[[ UTILITY FUNCTIONS ]]--

local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function saveToHistory()
    local state = {
        Head = deepCopy(CharacterService.Head),
        Torso = deepCopy(CharacterService.Torso),
        Face = CharacterService.Face,
        FaceTextureId = CharacterService.FaceTextureId,
        Shirt = CharacterService.Shirt,
        ShirtTemplateId = CharacterService.ShirtTemplateId,
        Pants = CharacterService.Pants,
        PantsTemplateId = CharacterService.PantsTemplateId,
        ItemMetadata = deepCopy(CharacterService.ItemMetadata)
    }
    
    table.insert(CharacterService.History, state)
    
    -- Limit history size
    if #CharacterService.History > CharacterService.MaxHistorySize then
        table.remove(CharacterService.History, 1)
    end
end

--[[ CORE FUNCTIONS ]]--

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
        warn("[CharacterService] Failed to load accessory: " .. tostring(accessoryId))
        return false 
    end

    local character = Players.LocalPlayer.Character
    if not character then return false end
    
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
                CharacterService.WeldParts(parent, handle, CFrame.new(0,0.5,0), attachmentPoint)
            end
        end
    end
    
    accessory.Parent = character
    return true
end

function CharacterService.ApplyFace(faceId, character)
    character = character or Players.LocalPlayer.Character
    if not character then return false end
    
    local head = character:FindFirstChild("Head")
    if not head then return false end

    local textureId = faceId
    pcall(function()
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
    if existingFace then existingFace:Destroy() end

    local face = Instance.new("Decal")
    face.Name = "face"
    face.Texture = "rbxassetid://" .. tostring(textureId)
    face.Face = Enum.NormalId.Front
    face.Parent = head
    
    return true
end

function CharacterService.ApplyShirt(shirtId, character)
    character = character or Players.LocalPlayer.Character
    if not character then return false end
    
    local templateId = shirtId
    pcall(function()
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
    character = character or Players.LocalPlayer.Character
    if not character then return false end
    
    local templateId = pantsId
    pcall(function()
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

--[[ NEW FEATURES - PHASE 1 ]]--

-- Add accessory with metadata tracking
function CharacterService.AddAccessory(accessoryId, category)
    saveToHistory()
    
    category = category or "Head"
    local id = tonumber(accessoryId)
    
    if not id then
        warn("[CharacterService] Invalid accessory ID: " .. tostring(accessoryId))
        return false
    end
    
    local character = Players.LocalPlayer.Character
    if not character then return false end
    
    -- Add to storage
    if category == "Head" then
        table.insert(CharacterService.Head, id)
        local success = CharacterService.AddAccessoryToCharacter(id, character.Head)
        if success then
            CharacterService.ItemMetadata[tostring(id)] = {
                category = "Head",
                addedAt = os.time(),
                name = "Accessory " .. id
            }
            print("[CharacterService] Added head accessory: " .. id)
        end
        return success
        
    elseif category == "Torso" then
        table.insert(CharacterService.Torso, id)
        local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        local success = CharacterService.AddAccessoryToCharacter(id, torso)
        if success then
            CharacterService.ItemMetadata[tostring(id)] = {
                category = "Torso",
                addedAt = os.time(),
                name = "Accessory " .. id
            }
            print("[CharacterService] Added torso accessory: " .. id)
        end
        return success
        
    elseif category == "Face" then
        CharacterService.ApplyFace(id, character)
        CharacterService.ItemMetadata[tostring(id)] = {
            category = "Face",
            addedAt = os.time(),
            name = "Face " .. id
        }
        print("[CharacterService] Applied face: " .. id)
        return true
        
    elseif category == "Shirt" then
        CharacterService.ApplyShirt(id, character)
        CharacterService.ItemMetadata[tostring(id)] = {
            category = "Shirt",
            addedAt = os.time(),
            name = "Shirt " .. id
        }
        print("[CharacterService] Applied shirt: " .. id)
        return true
        
    elseif category == "Pants" then
        CharacterService.ApplyPants(id, character)
        CharacterService.ItemMetadata[tostring(id)] = {
            category = "Pants",
            addedAt = os.time(),
            name = "Pants " .. id
        }
        print("[CharacterService] Applied pants: " .. id)
        return true
    end
    
    return false
end

-- Remove specific accessory by ID
function CharacterService.RemoveAccessory(accessoryId, category)
    saveToHistory()
    
    local id = tonumber(accessoryId)
    if not id then return false end
    
    local character = Players.LocalPlayer.Character
    if not character then return false end
    
    local metadata = CharacterService.ItemMetadata[tostring(id)]
    category = category or (metadata and metadata.category) or "Head"
    
    -- Remove from storage
    if category == "Head" then
        for i, itemId in ipairs(CharacterService.Head) do
            if itemId == id then
                table.remove(CharacterService.Head, i)
                break
            end
        end
    elseif category == "Torso" then
        for i, itemId in ipairs(CharacterService.Torso) do
            if itemId == id then
                table.remove(CharacterService.Torso, i)
                break
            end
        end
    end
    
    -- Remove from character
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle then
                local meshId = handle:FindFirstChildOfClass("SpecialMesh")?.MeshId or ""
                if meshId:match(tostring(id)) then
                    accessory:Destroy()
                    CharacterService.ItemMetadata[tostring(id)] = nil
                    print("[CharacterService] Removed accessory: " .. id)
                    return true
                end
            end
        end
    end
    
    return false
end

-- Clear specific categories
function CharacterService.ClearHead()
    saveToHistory()
    
    local character = Players.LocalPlayer.Character
    if character then
        for _, accessory in pairs(character:GetChildren()) do
            if accessory:IsA("Accessory") then
                local handle = accessory:FindFirstChild("Handle")
                if handle then
                    local attachment = handle:FindFirstChildOfClass("Attachment")
                    if attachment and attachment.Name:match("Hat") or attachment.Name:match("Hair") or attachment.Name:match("Face") then
                        accessory:Destroy()
                    end
                end
            end
        end
    end
    
    -- Clear metadata
    for _, id in ipairs(CharacterService.Head) do
        CharacterService.ItemMetadata[tostring(id)] = nil
    end
    
    CharacterService.Head = {}
    print("[CharacterService] Cleared all head accessories")
end

function CharacterService.ClearTorso()
    saveToHistory()
    
    local character = Players.LocalPlayer.Character
    if character then
        for _, accessory in pairs(character:GetChildren()) do
            if accessory:IsA("Accessory") then
                local handle = accessory:FindFirstChild("Handle")
                if handle then
                    local attachment = handle:FindFirstChildOfClass("Attachment")
                    if attachment and (attachment.Name:match("Torso") or attachment.Name:match("Waist") or attachment.Name:match("Back")) then
                        accessory:Destroy()
                    end
                end
            end
        end
    end
    
    for _, id in ipairs(CharacterService.Torso) do
        CharacterService.ItemMetadata[tostring(id)] = nil
    end
    
    CharacterService.Torso = {}
    print("[CharacterService] Cleared all torso accessories")
end

function CharacterService.ClearClothing()
    saveToHistory()
    
    local character = Players.LocalPlayer.Character
    if character then
        local shirt = character:FindFirstChildOfClass("Shirt")
        if shirt then shirt:Destroy() end
        
        local pants = character:FindFirstChildOfClass("Pants")
        if pants then pants:Destroy() end
        
        local head = character:FindFirstChild("Head")
        if head then
            local face = head:FindFirstChild("face")
            if face then
                face.Texture = "rbxasset://textures/face.png"
            end
        end
    end
    
    if CharacterService.Face then
        CharacterService.ItemMetadata[tostring(CharacterService.Face)] = nil
    end
    if CharacterService.Shirt then
        CharacterService.ItemMetadata[tostring(CharacterService.Shirt)] = nil
    end
    if CharacterService.Pants then
        CharacterService.ItemMetadata[tostring(CharacterService.Pants)] = nil
    end
    
    CharacterService.Face = nil
    CharacterService.FaceTextureId = nil
    CharacterService.Shirt = nil
    CharacterService.ShirtTemplateId = nil
    CharacterService.Pants = nil
    CharacterService.PantsTemplateId = nil
    
    print("[CharacterService] Cleared all clothing")
end

function CharacterService.ClearAll()
    saveToHistory()
    
    CharacterService.ClearHead()
    CharacterService.ClearTorso()
    CharacterService.ClearClothing()
    CharacterService.ItemMetadata = {}
    
    print("[CharacterService] Cleared everything")
end

-- Get current outfit info
function CharacterService.GetCurrentOutfit()
    print("\n=== Current Outfit ===")
    
    print("\nHead Accessories (" .. #CharacterService.Head .. "):")
    for i, id in ipairs(CharacterService.Head) do
        local meta = CharacterService.ItemMetadata[tostring(id)]
        print("  [" .. i .. "] ID: " .. id .. (meta and " (" .. meta.name .. ")" or ""))
    end
    
    print("\nTorso Accessories (" .. #CharacterService.Torso .. "):")
    for i, id in ipairs(CharacterService.Torso) do
        local meta = CharacterService.ItemMetadata[tostring(id)]
        print("  [" .. i .. "] ID: " .. id .. (meta and " (" .. meta.name .. ")" or ""))
    end
    
    print("\nClothing:")
    print("  Face: " .. (CharacterService.Face or "None"))
    print("  Shirt: " .. (CharacterService.Shirt or "None"))
    print("  Pants: " .. (CharacterService.Pants or "None"))
    
    print("\n=====================\n")
    
    return {
        Head = CharacterService.Head,
        Torso = CharacterService.Torso,
        Face = CharacterService.Face,
        Shirt = CharacterService.Shirt,
        Pants = CharacterService.Pants
    }
end

-- Undo system
function CharacterService.Undo()
    if #CharacterService.History == 0 then
        print("[CharacterService] Nothing to undo")
        return false
    end
    
    local previousState = table.remove(CharacterService.History)
    
    -- Restore state
    CharacterService.Head = previousState.Head
    CharacterService.Torso = previousState.Torso
    CharacterService.Face = previousState.Face
    CharacterService.FaceTextureId = previousState.FaceTextureId
    CharacterService.Shirt = previousState.Shirt
    CharacterService.ShirtTemplateId = previousState.ShirtTemplateId
    CharacterService.Pants = previousState.Pants
    CharacterService.PantsTemplateId = previousState.PantsTemplateId
    CharacterService.ItemMetadata = previousState.ItemMetadata
    
    -- Reapply to character
    local character = Players.LocalPlayer.Character
    if character then
        -- Clear everything first
        for _, accessory in pairs(character:GetChildren()) do
            if accessory:IsA("Accessory") then
                accessory:Destroy()
            end
        end
        
        local shirt = character:FindFirstChildOfClass("Shirt")
        if shirt then shirt:Destroy() end
        
        local pants = character:FindFirstChildOfClass("Pants")
        if pants then pants:Destroy() end
        
        -- Reapply
        CharacterService.OnCharacterAdded(character)
    end
    
    print("[CharacterService] Undone! History size: " .. #CharacterService.History)
    return true
end

-- Favorites system
function CharacterService.AddToFavorites(itemId, name)
    local id = tostring(itemId)
    CharacterService.Favorites[id] = {
        id = tonumber(itemId),
        name = name or ("Item " .. itemId),
        addedAt = os.time()
    }
    print("[CharacterService] Added to favorites: " .. (name or itemId))
end

function CharacterService.RemoveFromFavorites(itemId)
    local id = tostring(itemId)
    if CharacterService.Favorites[id] then
        CharacterService.Favorites[id] = nil
        print("[CharacterService] Removed from favorites: " .. itemId)
        return true
    end
    return false
end

function CharacterService.GetFavorites()
    print("\n=== Favorites ===")
    local count = 0
    for id, data in pairs(CharacterService.Favorites) do
        count = count + 1
        print("  [" .. count .. "] " .. data.name .. " (ID: " .. data.id .. ")")
    end
    if count == 0 then
        print("  No favorites yet!")
    end
    print("=================\n")
    return CharacterService.Favorites
end

function CharacterService.SaveFavorites()
    if not isfolder("CharacterCustomizer") then
        makefolder("CharacterCustomizer")
    end
    
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(CharacterService.Favorites)
        writefile("CharacterCustomizer/Favorites.json", json)
    end)
    
    if success then
        print("[CharacterService] Favorites saved")
    else
        warn("[CharacterService] Failed to save favorites: " .. tostring(err))
    end
    
    return success
end

function CharacterService.LoadFavorites()
    local success, result = pcall(function()
        local json = readfile("CharacterCustomizer/Favorites.json")
        return HttpService:JSONDecode(json)
    end)
    
    if success and result then
        CharacterService.Favorites = result
        print("[CharacterService] Favorites loaded")
        return true
    end
    
    return false
end

--[[ CHARACTER MANAGEMENT ]]--

function CharacterService.ClearCharacter(character)
    character = character or Players.LocalPlayer.Character
    if not character then return false end
    
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            accessory:Destroy()
        end
    end
    
    local shirt = character:FindFirstChildOfClass("Shirt")
    if shirt then shirt:Destroy() end
    
    local pants = character:FindFirstChildOfClass("Pants")
    if pants then pants:Destroy() end
    
    return true
end

function CharacterService.OnCharacterAdded(character)
    task.wait(CharacterService.Time)
    
    for _, id in ipairs(CharacterService.Head) do
        CharacterService.AddAccessoryToCharacter(id, character.Head)
    end
    
    for _, id in ipairs(CharacterService.Torso) do
        local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if torso then
            CharacterService.AddAccessoryToCharacter(id, torso)
        end
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

function CharacterService.Init()
    local player = Players.LocalPlayer
    
    if CharacterService._characterConnection then
        CharacterService._characterConnection:Disconnect()
    end
    
    CharacterService._characterConnection = player.CharacterAdded:Connect(CharacterService.OnCharacterAdded)
    
    if player.Character then
        CharacterService.OnCharacterAdded(player.Character)
    end
    
    -- Try to load favorites
    CharacterService.LoadFavorites()
    
    print("[CharacterService] Initialized - Phase 1 Complete!")
    print("Commands: AddAccessory, RemoveAccessory, ClearHead, ClearTorso, ClearClothing, ClearAll")
    print("          GetCurrentOutfit, Undo, AddToFavorites, GetFavorites, SaveFavorites")
end

return CharacterService
