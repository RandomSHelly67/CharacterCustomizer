-- bootstrap.lua
local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"
local Loaded = {}

local function requireModule(name)
    local src = game:HttpGet(BASE_URL .. name .. ".lua")
    local fn = loadstring(src)
    local result = fn()
    Loaded[name] = result
    return result
end

-- Load modules
local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")
local State = requireModule("State") -- optional if you want global states

-- Connect character added
if game.Players.LocalPlayer.Character then
    CharacterService:OnCharacterAdded(game.Players.LocalPlayer.Character)
end
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    CharacterService:OnCharacterAdded(char)
end)

print("[Bootstrap] CharacterCustomizer loaded successfully")
