-- OutfitService.lua
local OutfitService = {}
local HttpService = game:GetService("HttpService")
local OUTFIT_FOLDER = "CharacterCustomizer/Outfits/"

-- Ensure folder exists
if not isfolder("CharacterCustomizer") then makefolder("CharacterCustomizer") end
if not isfolder(OUTFIT_FOLDER) then makefolder(OUTFIT_FOLDER) end

-- Save Outfit
function OutfitService:SaveOutfit(name, outfit)
    local success, _ = pcall(function()
        writefile(OUTFIT_FOLDER .. name .. ".json", HttpService:JSONEncode(outfit))
    end)
    return success
end

-- Load Outfit
function OutfitService:LoadOutfit(name)
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(OUTFIT_FOLDER .. name .. ".json"))
    end)
    if success then return result end
    return nil
end

-- Delete Outfit
function OutfitService:DeleteOutfit(name)
    local success, _ = pcall(function() delfile(OUTFIT_FOLDER .. name .. ".json") end)
    return success
end

-- List Outfits
function OutfitService:ListOutfits()
    local outfits = {}
    local success, files = pcall(function() return listfiles(OUTFIT_FOLDER) end)
    if success and files then
        for _, file in ipairs(files) do
            local fname = file:match("([^/\\]+)%.json$")
            if fname then table.insert(outfits, fname) end
        end
    end
    return outfits
end

return OutfitService
