--//------------------------------------------------------------------------------------------\\--
-- GUI CREATION & LOGIC (with CharacterService / OutfitService)
--//------------------------------------------------------------------------------------------\\--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Make sure modules are loaded first
local Modules = loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/bootstrap.lua"))()
local CS = Modules.CharacterService
local OS = Modules.OutfitService

local TOGGLE_KEY = Enum.KeyCode.RightShift

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccessoryManagerGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 580)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -290)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 12)
mainFrameCorner.Parent = mainFrame

local mainFrameStroke = Instance.new("UIStroke")
mainFrameStroke.Color = Color3.fromRGB(100, 100, 150)
mainFrameStroke.Thickness = 1
mainFrameStroke.Transparency = 0.5
mainFrameStroke.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 12)
titleBarCorner.Parent = titleBar

local titleBarBottom = Instance.new("Frame")
titleBarBottom.Size = UDim2.new(1, 0, 0, 12)
titleBarBottom.Position = UDim2.new(0, 0, 1, -12)
titleBarBottom.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
titleBarBottom.BackgroundTransparency = 0.2
titleBarBottom.BorderSizePixel = 0
titleBarBottom.Parent = titleBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✨ Character Customizer"
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeButton"
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -80, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
minimizeBtn.BackgroundTransparency = 0.3
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minimizeBtnCorner = Instance.new("UICorner")
minimizeBtnCorner.CornerRadius = UDim.new(0, 6)
minimizeBtnCorner.Parent = minimizeBtn

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
closeBtn.BackgroundTransparency = 0.2
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 24
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

-- Content Container
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -55)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Item ID Input Section
local idLabel = Instance.new("TextLabel")
idLabel.Size = UDim2.new(1, 0, 0, 18)
idLabel.BackgroundTransparency = 1
idLabel.Text = "Item ID (or comma-separated IDs):"
idLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
idLabel.TextSize = 13
idLabel.Font = Enum.Font.Gotham
idLabel.TextXAlignment = Enum.TextXAlignment.Left
idLabel.Parent = contentFrame

local idInput = Instance.new("TextBox")
idInput.Name = "IdInput"
idInput.Size = UDim2.new(1, 0, 0, 40)
idInput.Position = UDim2.new(0, 0, 0, 22)
idInput.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
idInput.BackgroundTransparency = 0.3
idInput.BorderSizePixel = 0
idInput.PlaceholderText = "e.g., 123456 or 123456,789012,345678"
idInput.Text = ""
idInput.TextColor3 = Color3.fromRGB(255, 255, 255)
idInput.TextSize = 14
idInput.Font = Enum.Font.Gotham
idInput.ClearTextOnFocus = false
idInput.Parent = contentFrame

local idInputCorner = Instance.new("UICorner")
idInputCorner.CornerRadius = UDim.new(0, 6)
idInputCorner.Parent = idInput

local idInputStroke = Instance.new("UIStroke")
idInputStroke.Color = Color3.fromRGB(80, 80, 120)
idInputStroke.Thickness = 1
idInputStroke.Transparency = 0.6
idInputStroke.Parent = idInput

-- Category Buttons
local categoryContainer = Instance.new("Frame")
categoryContainer.Size = UDim2.new(1, 0, 0, 80)
categoryContainer.Position = UDim2.new(0, 0, 0, 94)
categoryContainer.BackgroundTransparency = 1
categoryContainer.Parent = contentFrame

local function createCategoryButton(name, position)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Button"
    btn.Size = position.size
    btn.Position = position.pos
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = categoryContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 120)
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = btn
    
    return btn
end

local headBtn = createCategoryButton("Head", {size = UDim2.new(0.48, 0, 0, 35), pos = UDim2.new(0, 0, 0, 0)})
local torsoBtn = createCategoryButton("Torso", {size = UDim2.new(0.48, 0, 0, 35), pos = UDim2.new(0.52, 0, 0, 0)})
local faceBtn = createCategoryButton("Face", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0, 0, 0, 45)})
local shirtBtn = createCategoryButton("Shirt", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0.345, 0, 0, 45)})
local pantsBtn = createCategoryButton("Pants", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0.69, 0, 0, 45)})

local selectedCategory = "Head"
local categoryButtons = {
    Head = headBtn,
    Torso = torsoBtn,
    Face = faceBtn,
    Shirt = shirtBtn,
    Pants = pantsBtn
}

local function updateButtonColors()
    for category, button in pairs(categoryButtons) do
        if category == selectedCategory then
            button.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            button.TextColor3 = Color3.fromRGB(200, 200, 220)
        end
    end
end

updateButtonColors()

for category, btn in pairs(categoryButtons) do
    btn.MouseButton1Click:Connect(function()
        selectedCategory = category
        updateButtonColors()
    end)
end

--//------------------------------------------------------------------------------------------\\--
-- APPLY / CLEAR / OUTFIT BUTTON LOGIC
--//------------------------------------------------------------------------------------------\\--

-- Helper function to parse IDs (comma-separated or single)
local function parseIDs(input)
    local ids = {}
    for id in string.gmatch(input, "%d+") do
        table.insert(ids, tonumber(id))
    end
    return ids
end

-- Apply Button
local applyBtn = Instance.new("TextButton")
applyBtn.Name = "ApplyButton"
applyBtn.Size = UDim2.new(1, 0, 0, 40)
applyBtn.Position = UDim2.new(0, 0, 0, 140)
applyBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
applyBtn.Text = "Apply"
applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 16
applyBtn.Parent = contentFrame

local applyCorner = Instance.new("UICorner")
applyCorner.CornerRadius = UDim.new(0, 6)
applyCorner.Parent = applyBtn

applyBtn.MouseButton1Click:Connect(function()
    local ids = parseIDs(idInput.Text)
    if #ids == 0 then
        warn("[GUI] No valid IDs entered!")
        return
    end

    local success = false
    local character = player.Character or player.CharacterAdded:Wait()

    if selectedCategory == "Head" or selectedCategory == "Torso" then
        for _, id in ipairs(ids) do
            success = CS:AddAccessory(selectedCategory, id)
            print("[GUI] Added accessory ID " .. id .. " to " .. selectedCategory .. ":", success)
        end
    elseif selectedCategory == "Face" then
        success = CS:ApplyFace(ids[1])
        print("[GUI] Applied Face ID " .. ids[1] .. ":", success)
    elseif selectedCategory == "Shirt" then
        success = CS:ApplyShirt(ids[1])
        print("[GUI] Applied Shirt ID " .. ids[1] .. ":", success)
    elseif selectedCategory == "Pants" then
        success = CS:ApplyPants(ids[1])
        print("[GUI] Applied Pants ID " .. ids[1] .. ":", success)
    end
end)

-- Clear Button
local clearBtn = Instance.new("TextButton")
clearBtn.Name = "ClearButton"
clearBtn.Size = UDim2.new(1, 0, 0, 40)
clearBtn.Position = UDim2.new(0, 0, 0, 190)
clearBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
clearBtn.Text = "Clear"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 16
clearBtn.Parent = contentFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = clearBtn

clearBtn.MouseButton1Click:Connect(function()
    local character = player.Character or player.CharacterAdded:Wait()
    if selectedCategory == "Head" or selectedCategory == "Torso" then
        CS:ClearAccessories(selectedCategory)
        print("[GUI] Cleared " .. selectedCategory .. " accessories")
    elseif selectedCategory == "Face" then
        CS:ClearFace()
        print("[GUI] Cleared Face")
    elseif selectedCategory == "Shirt" then
        CS:ClearShirt()
        print("[GUI] Cleared Shirt")
    elseif selectedCategory == "Pants" then
        CS:ClearPants()
        print("[GUI] Cleared Pants")
    end
end)

-- Outfit Buttons Container
local outfitFrame = Instance.new("Frame")
outfitFrame.Size = UDim2.new(1, 0, 0, 120)
outfitFrame.Position = UDim2.new(0, 0, 0, 250)
outfitFrame.BackgroundTransparency = 1
outfitFrame.Parent = contentFrame

-- Save Outfit
local saveBtn = Instance.new("TextButton")
saveBtn.Name = "SaveButton"
saveBtn.Size = UDim2.new(0.48, 0, 0, 40)
saveBtn.Position = UDim2.new(0, 0, 0, 0)
saveBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
saveBtn.Text = "Save Outfit"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 14
saveBtn.Parent = outfitFrame

local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 6)
saveCorner.Parent = saveBtn

saveBtn.MouseButton1Click:Connect(function()
    local outfitName = idInput.Text
    if outfitName == "" then
        warn("[GUI] Outfit name cannot be empty!")
        return
    end
    local success = OS:SaveOutfit(outfitName)
    print("[GUI] Save outfit '" .. outfitName .. "':", success)
end)

-- Load Outfit
local loadBtn = Instance.new("TextButton")
loadBtn.Name = "LoadButton"
loadBtn.Size = UDim2.new(0.48, 0, 0, 40)
loadBtn.Position = UDim2.new(0.52, 0, 0, 0)
loadBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 120)
loadBtn.Text = "Load Outfit"
loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 14
loadBtn.Parent = outfitFrame

local loadCorner = Instance.new("UICorner")
loadCorner.CornerRadius = UDim.new(0, 6)
loadCorner.Parent = loadBtn

loadBtn.MouseButton1Click:Connect(function()
    local outfitName = idInput.Text
    if outfitName == "" then
        warn("[GUI] Outfit name cannot be empty!")
        return
    end
    local outfit = OS:LoadOutfit(outfitName)
    if outfit then
        print("[GUI] Loaded outfit '" .. outfitName .. "' successfully")
    else
        warn("[GUI] Failed to load outfit '" .. outfitName .. "'")
    end
end)

-- Delete Outfit
local deleteBtn = Instance.new("TextButton")
deleteBtn.Name = "DeleteButton"
deleteBtn.Size = UDim2.new(1, 0, 0, 40)
deleteBtn.Position = UDim2.new(0, 0, 0, 70)
deleteBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
deleteBtn.Text = "Delete Outfit"
deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteBtn.Font = Enum.Font.GothamBold
deleteBtn.TextSize = 14
deleteBtn.Parent = outfitFrame

local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 6)
deleteCorner.Parent = deleteBtn

deleteBtn.MouseButton1Click:Connect(function()
    local outfitName = idInput.Text
    if outfitName == "" then
        warn("[GUI] Outfit name cannot be empty!")
        return
    end
    local success = OS:DeleteOutfit(outfitName)
    print("[GUI] Delete outfit '" .. outfitName .. "':", success)
end)
