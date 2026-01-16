-- OutfitService.lua
local OutfitService = {}
local HttpService = game:GetService("HttpService")

local OUTFIT_FOLDER = "CharacterCustomizer/Outfits/"

-- Ensure folder exists
if not isfolder("CharacterCustomizer") then
    makefolder("CharacterCustomizer")
end
if not isfolder(OUTFIT_FOLDER) then
    makefolder(OUTFIT_FOLDER)
end

-- Save an outfit
function OutfitService.SaveOutfit(outfitName, outfitData)
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(outfitData)
        writefile(OUTFIT_FOLDER .. outfitName .. ".json", json)
    end)
    if not success then
        warn("Failed to save outfit:", err)
    end
    return success
end

-- Load an outfit
function OutfitService.LoadOutfit(outfitName)
    local success, result = pcall(function()
        local json = readfile(OUTFIT_FOLDER .. outfitName .. ".json")
        return HttpService:JSONDecode(json)
    end)
    if success then
        return result
    else
        warn("Failed to load outfit:", result)
        return nil
    end
end

-- Delete an outfit
function OutfitService.DeleteOutfit(outfitName)
    local success = pcall(function()
        delfile(OUTFIT_FOLDER .. outfitName .. ".json")
    end)
    if not success then
        warn("Failed to delete outfit:", outfitName)
    end
    return success
end

-- List all outfits
function OutfitService.ListOutfits()
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

return OutfitService
