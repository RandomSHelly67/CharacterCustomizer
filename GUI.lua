-- GUI.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local CharacterService = requireModule("CharacterService")
local OutfitService = requireModule("OutfitService")

local GUI = {}
GUI.__index = GUI

function GUI.new()
    local self = setmetatable({}, GUI)
    
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- ===== SCREEN GUI =====
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AccessoryManagerGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    self.screenGui = screenGui

    -- ===== MAIN FRAME =====
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 580)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -290)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    self.mainFrame = mainFrame

    local mainFrameCorner = Instance.new("UICorner")
    mainFrameCorner.CornerRadius = UDim.new(0, 12)
    mainFrameCorner.Parent = mainFrame

    -- ===== TITLE BAR =====
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    self.titleBar = titleBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "✨ Character Customizer"
    title.TextColor3 = Color3.fromRGB(200, 200, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- ===== MINIMIZE & CLOSE BUTTONS =====
    local minimizeBtn = Instance.new("TextButton")
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
    self.minimizeBtn = minimizeBtn

    local closeBtn = Instance.new("TextButton")
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
    self.closeBtn = closeBtn

    -- ===== CONTENT FRAME =====
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -55)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    self.contentFrame = contentFrame

    -- ===== CATEGORY BUTTONS =====
    self.selectedCategory = "Head"
    self.categoryButtons = {}

    local function createCategoryButton(name, size, pos)
        local btn = Instance.new("TextButton")
        btn.Name = name .. "Button"
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 200, 220)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.Parent = contentFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        self.categoryButtons[name] = btn
        btn.MouseButton1Click:Connect(function()
            self.selectedCategory = name
            self:updateButtonColors()
        end)
        return btn
    end

    createCategoryButton("Head", UDim2.new(0.48,0,0,35), UDim2.new(0,0,0,0))
    createCategoryButton("Torso", UDim2.new(0.48,0,0,35), UDim2.new(0.52,0,0,0))
    createCategoryButton("Face", UDim2.new(0.31,0,0,35), UDim2.new(0,0,0,45))
    createCategoryButton("Shirt", UDim2.new(0.31,0,0,35), UDim2.new(0.345,0,0,45))
    createCategoryButton("Pants", UDim2.new(0.31,0,0,35), UDim2.new(0.69,0,0,45))

    -- ===== MINIMIZE & CLOSE LOGIC =====
    local isMinimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        contentFrame.Visible = not isMinimized
        mainFrame.Size = isMinimized and UDim2.new(0,450,0,45) or UDim2.new(0,450,0,580)
        minimizeBtn.Text = isMinimized and "□" or "_"
    end)
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    return self
end

function GUI:updateButtonColors()
    for name, btn in pairs(self.categoryButtons) do
        if name == self.selectedCategory then
            btn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.TextColor3 = Color3.fromRGB(200, 200, 220)
        end
    end
end

return GUI
