-- ItemEditorService.lua - Phase 2: Item Customization
local ItemEditorService = {}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

ItemEditorService.CharacterService = nil

-- Storage for item adjustments
ItemEditorService.Adjustments = {}
-- Format: [itemId] = { position = Vector3, scale = Vector3, rotation = Vector3 }

-- Initialize with CharacterService
function ItemEditorService.Init(CharacterService)
    ItemEditorService.CharacterService = CharacterService
    ItemEditorService.LoadAdjustments()
    print("[ItemEditorService] Initialized")
end

-- Find accessory on character by ID
local function findAccessoryById(character, accessoryId)
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshId:match(tostring(accessoryId)) then
                    return accessory, handle
                end
            end
        end
    end
    return nil, nil
end

-- Apply position offset to an accessory
function ItemEditorService.SetPosition(accessoryId, offset)
    local character = Players.LocalPlayer.Character
    if not character then return false end
    
    local id = tostring(accessoryId)
    
    -- Store adjustment
    if not ItemEditorService.Adjustments[id] then
        ItemEditorService.Adjustments[id] = {}
    end
    ItemEditorService.Adjustments[id].position = offset
    
    -- Apply to accessory
    local accessory, handle = findAccessoryById(character, accessoryId)
    if accessory and handle then
        local weld = handle:FindFirstChildOfClass("Weld")
        if weld then
            local originalC0 = weld.C0
            weld.C0 = originalC0 * CFrame.new(offset)
            print("[ItemEditor] Position set for " .. id .. ": " .. tostring(offset))
            return true
        end
    end
    
    return false
end

-- Adjust position incrementally
function ItemEditorService.AdjustPosition(accessoryId, delta)
    local id = tostring(accessoryId)
    local currentPos = ItemEditorService.Adjustments[id] and ItemEditorService.Adjustments[id].position or Vector3.new(0, 0, 0)
    local newPos = currentPos + delta
    return ItemEditorService.SetPosition(accessoryId, newPos)
end

-- Apply scale to an accessory
function ItemEditorService.SetScale(accessoryId, scale)
    local character = Players.LocalPlayer.Character
    if not character then return false end
    
    local id = tostring(accessoryId)
    
    -- Store adjustment
    if not ItemEditorService.Adjustments[id] then
        ItemEditorService.Adjustments[id] = {}
    end
    ItemEditorService.Adjustments[id].scale = scale
    
    -- Apply to accessory
    local accessory, handle = findAccessoryById(character, accessoryId)
    if accessory and handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            mesh.Scale = scale
            print("[ItemEditor] Scale set for " .. id .. ": " .. tostring(scale))
            return true
        end
    end
    
    return false
end

-- Adjust scale incrementally
function ItemEditorService.AdjustScale(accessoryId, delta)
    local id = tostring(accessoryId)
    local currentScale = ItemEditorService.Adjustments[id] and ItemEditorService.Adjustments[id].scale or Vector3.new(1, 1, 1)
    local newScale = currentScale + delta
    
    -- Prevent negative or zero scale
    newScale = Vector3.new(
        math.max(0.1, newScale.X),
        math.max(0.1, newScale.Y),
        math.max(0.1, newScale.Z)
    )
    
    return ItemEditorService.SetScale(accessoryId, newScale)
end

-- Apply rotation to an accessory
function ItemEditorService.SetRotation(accessoryId, rotation)
    local character = Players.LocalPlayer.Character
    if not character then return false end
    
    local id = tostring(accessoryId)
    
    -- Store adjustment
    if not ItemEditorService.Adjustments[id] then
        ItemEditorService.Adjustments[id] = {}
    end
    ItemEditorService.Adjustments[id].rotation = rotation
    
    -- Apply to accessory
    local accessory, handle = findAccessoryById(character, accessoryId)
    if accessory and handle then
        local weld = handle:FindFirstChildOfClass("Weld")
        if weld then
            local pos = ItemEditorService.Adjustments[id].position or Vector3.new(0, 0, 0)
            local rotCFrame = CFrame.Angles(
                math.rad(rotation.X),
                math.rad(rotation.Y),
                math.rad(rotation.Z)
            )
            weld.C0 = weld.C0 * CFrame.new(pos) * rotCFrame
            print("[ItemEditor] Rotation set for " .. id .. ": " .. tostring(rotation))
            return true
        end
    end
    
    return false
end

-- Adjust rotation incrementally (in degrees)
function ItemEditorService.AdjustRotation(accessoryId, delta)
    local id = tostring(accessoryId)
    local currentRot = ItemEditorService.Adjustments[id] and ItemEditorService.Adjustments[id].rotation or Vector3.new(0, 0, 0)
    local newRot = currentRot + delta
    return ItemEditorService.SetRotation(accessoryId, newRot)
end

-- Reset all adjustments for an item
function ItemEditorService.ResetAdjustments(accessoryId)
    local id = tostring(accessoryId)
    
    if ItemEditorService.Adjustments[id] then
        ItemEditorService.Adjustments[id] = nil
        
        -- Reapply the accessory without adjustments
        local character = Players.LocalPlayer.Character
        if character then
            local accessory = findAccessoryById(character, accessoryId)
            if accessory then
                accessory:Destroy()
            end
            
            -- Get category from CharacterService
            local cs = ItemEditorService.CharacterService
            if cs then
                task.wait(0.1)
                cs.AddAccessoryToCharacter(tonumber(accessoryId), character.Head)
            end
        end
        
        print("[ItemEditor] Reset adjustments for " .. id)
        return true
    end
    
    return false
end

-- Apply all stored adjustments to current character
function ItemEditorService.ApplyAllAdjustments()
    local character = Players.LocalPlayer.Character
    if not character then return false end
    
    for accessoryId, adjustments in pairs(ItemEditorService.Adjustments) do
        local id = tonumber(accessoryId)
        
        if adjustments.position then
            ItemEditorService.SetPosition(id, adjustments.position)
        end
        
        if adjustments.scale then
            ItemEditorService.SetScale(id, adjustments.scale)
        end
        
        if adjustments.rotation then
            ItemEditorService.SetRotation(id, adjustments.rotation)
        end
    end
    
    print("[ItemEditor] Applied all adjustments")
    return true
end

-- Get adjustments for a specific item
function ItemEditorService.GetAdjustments(accessoryId)
    local id = tostring(accessoryId)
    return ItemEditorService.Adjustments[id] or {
        position = Vector3.new(0, 0, 0),
        scale = Vector3.new(1, 1, 1),
        rotation = Vector3.new(0, 0, 0)
    }
end

-- List all items with adjustments
function ItemEditorService.ListAdjustments()
    print("\n=== Item Adjustments ===")
    local count = 0
    
    for id, adj in pairs(ItemEditorService.Adjustments) do
        count = count + 1
        print("\n[" .. count .. "] Item ID: " .. id)
        
        if adj.position then
            print("  Position: " .. tostring(adj.position))
        end
        
        if adj.scale then
            print("  Scale: " .. tostring(adj.scale))
        end
        
        if adj.rotation then
            print("  Rotation: " .. tostring(adj.rotation))
        end
    end
    
    if count == 0 then
        print("  No adjustments yet!")
    end
    
    print("========================\n")
end

-- Save adjustments to file
function ItemEditorService.SaveAdjustments()
    if not isfolder("CharacterCustomizer") then
        makefolder("CharacterCustomizer")
    end
    
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(ItemEditorService.Adjustments)
        writefile("CharacterCustomizer/Adjustments.json", json)
    end)
    
    if success then
        print("[ItemEditor] Adjustments saved")
    else
        warn("[ItemEditor] Failed to save adjustments: " .. tostring(err))
    end
    
    return success
end

-- Load adjustments from file
function ItemEditorService.LoadAdjustments()
    local success, result = pcall(function()
        local json = readfile("CharacterCustomizer/Adjustments.json")
        return HttpService:JSONDecode(json)
    end)
    
    if success and result then
        -- Convert Vector3 tables back to Vector3 objects
        for id, adj in pairs(result) do
            if adj.position then
                adj.position = Vector3.new(adj.position.X, adj.position.Y, adj.position.Z)
            end
            if adj.scale then
                adj.scale = Vector3.new(adj.scale.X, adj.scale.Y, adj.scale.Z)
            end
            if adj.rotation then
                adj.rotation = Vector3.new(adj.rotation.X, adj.rotation.Y, adj.rotation.Z)
            end
        end
        
        ItemEditorService.Adjustments = result
        print("[ItemEditor] Adjustments loaded")
        return true
    end
    
    return false
end

-- Clear all adjustments
function ItemEditorService.ClearAllAdjustments()
    ItemEditorService.Adjustments = {}
    print("[ItemEditor] All adjustments cleared")
end

return ItemEditorService
