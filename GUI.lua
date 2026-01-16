-- guiModule.lua
return function(CS, OS)
    print("[GUI] Initializing Character Customizer GUI...")

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local TOGGLE_KEY = Enum.KeyCode.RightShift -- example toggle key

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AccessoryManagerGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 580)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -290)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local UICorner_main = Instance.new("UICorner")
    UICorner_main.CornerRadius = UDim.new(0, 12)
    UICorner_main.Parent = mainFrame

    local UIStroke_main = Instance.new("UIStroke")
    UIStroke_main.Color = Color3.fromRGB(100, 100, 150)
    UIStroke_main.Thickness = 1
    UIStroke_main.Transparency = 0.5
    UIStroke_main.Parent = mainFrame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

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

    -- Minimize & Close buttons
    local function createButton(text, position, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 35, 0, 35)
        btn.Position = position
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 20
        btn.BorderSizePixel = 0
        btn.Parent = titleBar

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        return btn
    end

    local minimizeBtn = createButton("_", UDim2.new(1, -80, 0, 5), Color3.fromRGB(80, 80, 120))
    local closeBtn = createButton("×", UDim2.new(1, -40, 0, 5), Color3.fromRGB(220, 80, 80))

    -- Content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -55)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- Category buttons
    local categories = {"Head", "Torso", "Face", "Shirt", "Pants"}
    local categoryButtons = {}

    local function createCategoryButton(name, size, pos)
        local btn = Instance.new("TextButton")
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

        categoryButtons[name] = btn
        return btn
    end

    local selectedCategory = "Head"
    local function updateCategoryColors()
        for name, btn in pairs(categoryButtons) do
            if name == selectedCategory then
                btn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                btn.TextColor3 = Color3.fromRGB(200, 200, 220)
            end
        end
    end

    -- GUI logic (Apply/Clear items)
    local function applyItems(ids)
        local character = player.Character
        if not character then return end

        for _, id in ipairs(ids) do
            if selectedCategory == "Head" then
                CS.AddHead(id, character)
            elseif selectedCategory == "Torso" then
                CS.AddTorso(id, character)
            elseif selectedCategory == "Face" then
                CS.ApplyFace(id, character)
            elseif selectedCategory == "Shirt" then
                CS.ApplyShirt(id, character)
            elseif selectedCategory == "Pants" then
                CS.ApplyPants(id, character)
            end
        end
    end

    local function clearAll()
        CS.ClearCharacter(player.Character)
    end

    -- Outfit buttons
    local function saveOutfit(name)
        return OS.SaveOutfit(name, CS.GetCurrentCharacterState())
    end

    local function loadOutfit(name)
        local state = OS.LoadOutfit(name)
        if state then
            CS.ApplyState(state)
            return true
        end
        return false
    end

    local function deleteOutfit(name)
        return OS.DeleteOutfit(name)
    end

    -- Debug print
    print("[GUI] GUI initialized successfully!")

    -- Return GUI elements if needed
    return {
        MainFrame = mainFrame,
        ContentFrame = contentFrame,
        CategoryButtons = categoryButtons,
        ApplyItems = applyItems,
        ClearAll = clearAll,
        SaveOutfit = saveOutfit,
        LoadOutfit = loadOutfit,
        DeleteOutfit = deleteOutfit
    }
end
