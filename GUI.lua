--//------------------------------------------------------------------------------------------\\--
-- GUI CREATION
--//------------------------------------------------------------------------------------------\\--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Require modules from bootstrap system
local BASE_URL = "https://raw.githubusercontent.com/RandomSHelly67/CharacterCustomizer/main/"
local function requireModule(name)
    local src = game:HttpGet(BASE_URL .. name .. ".lua")
    local fn = loadstring(src)
    local result = fn()
    return result
end

local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccessoryManagerGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame with glass effect
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

-- Category Label
local categoryLabel = Instance.new("TextLabel")
categoryLabel.Size = UDim2.new(1, 0, 0, 18)
categoryLabel.Position = UDim2.new(0, 0, 0, 72)
categoryLabel.BackgroundTransparency = 1
categoryLabel.Text = "Category:"
categoryLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
categoryLabel.TextSize = 13
categoryLabel.Font = Enum.Font.Gotham
categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
categoryLabel.Parent = contentFrame

-- Category Buttons Container
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

-- Apply Button
local addBtn = Instance.new("TextButton")
addBtn.Name = "AddButton"
addBtn.Size = UDim2.new(1, 0, 0, 45)
addBtn.Position = UDim2.new(0, 0, 0, 184)
addBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
addBtn.BackgroundTransparency = 0.2
addBtn.BorderSizePixel = 0
addBtn.Text = "✓ Apply Item(s)"
addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addBtn.TextSize = 16
addBtn.Font = Enum.Font.GothamBold
addBtn.Parent = contentFrame

local addBtnCorner = Instance.new("UICorner")
addBtnCorner.CornerRadius = UDim.new(0, 6)
addBtnCorner.Parent = addBtn

-- Clear Button
local clearBtn = Instance.new("TextButton")
clearBtn.Name = "ClearButton"
clearBtn.Size = UDim2.new(1, 0, 0, 35)
clearBtn.Position = UDim2.new(0, 0, 0, 239)
clearBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
clearBtn.BackgroundTransparency = 0.3
clearBtn.BorderSizePixel = 0
clearBtn.Text = "✕ Clear All"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.TextSize = 14
clearBtn.Font = Enum.Font.GothamBold
clearBtn.Parent = contentFrame

local clearBtnCorner = Instance.new("UICorner")
clearBtnCorner.CornerRadius = UDim.new(0, 6)
clearBtnCorner.Parent = clearBtn
