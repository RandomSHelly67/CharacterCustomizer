-- GuiService.lua - Modern GUI for Character Customizer
local GuiService = {}

GuiService.CharacterService = nil
GuiService.OutfitService = nil
GuiService.ItemEditorService = nil

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local TOGGLE_KEY = Enum.KeyCode.RightShift

local screenGui
local mainFrame
local equippedFrame

function GuiService.Init(CharacterService, OutfitService, ItemEditorService)
    GuiService.CharacterService = CharacterService
    GuiService.OutfitService = OutfitService
    GuiService.ItemEditorService = ItemEditorService
    
    GuiService.CreateGui()
    
    print("[GuiService] Initialized")
end

function GuiService.CreateGui()
    local playerGui = player:WaitForChild("PlayerGui")
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CharacterCustomizerGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    GuiService.CreateMainFrame()
    GuiService.CreateEquippedFrame()
    GuiService.SetupKeybind()
end

function GuiService.CreateMainFrame()
    -- Main Frame with glass effect
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 660)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -330)
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
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -55)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Item ID Input
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
    
    -- Category Buttons
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
        btn.Parent = contentFrame
        
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
    
    local headBtn = createCategoryButton("Head", {size = UDim2.new(0.48, 0, 0, 35), pos = UDim2.new(0, 0, 0, 94)})
    local torsoBtn = createCategoryButton("Torso", {size = UDim2.new(0.48, 0, 0, 35), pos = UDim2.new(0.52, 0, 0, 94)})
    local faceBtn = createCategoryButton("Face", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0, 0, 0, 139)})
    local shirtBtn = createCategoryButton("Shirt", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0.345, 0, 0, 139)})
    local pantsBtn = createCategoryButton("Pants", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0.69, 0, 0, 139)})
    
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
    
    -- Special Effects Section
    local specialLabel = Instance.new("TextLabel")
    specialLabel.Size = UDim2.new(1, 0, 0, 20)
    specialLabel.Position = UDim2.new(0, 0, 0, 239)
    specialLabel.BackgroundTransparency = 1
    specialLabel.Text = "🎭 Special Effects"
    specialLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    specialLabel.TextSize = 14
    specialLabel.Font = Enum.Font.GothamBold
    specialLabel.TextXAlignment = Enum.TextXAlignment.Left
    specialLabel.Parent = contentFrame
    
    local headlessBtn = createCategoryButton("Headless", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0, 0, 0, 263)})
    headlessBtn.Parent = contentFrame
    
    local korbloxRBtn = createCategoryButton("Korblox R", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0.345, 0, 0, 263)})
    korbloxRBtn.Parent = contentFrame
    
    local korbloxLBtn = createCategoryButton("Korblox L", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0.69, 0, 0, 263)})
    korbloxLBtn.Parent = contentFrame
    
    -- Clear and View Equipped Buttons
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.48, 0, 0, 35)
    clearBtn.Position = UDim2.new(0, 0, 0, 308)
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
    
    local viewEquippedBtn = Instance.new("TextButton")
    viewEquippedBtn.Size = UDim2.new(0.48, 0, 0, 35)
    viewEquippedBtn.Position = UDim2.new(0.52, 0, 0, 308)
    viewEquippedBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 180)
    viewEquippedBtn.BackgroundTransparency = 0.3
    viewEquippedBtn.BorderSizePixel = 0
    viewEquippedBtn.Text = "🎒 Equipped"
    viewEquippedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    viewEquippedBtn.TextSize = 14
    viewEquippedBtn.Font = Enum.Font.GothamBold
    viewEquippedBtn.Parent = contentFrame
    
    local viewEquippedBtnCorner = Instance.new("UICorner")
    viewEquippedBtnCorner.CornerRadius = UDim.new(0, 6)
    viewEquippedBtnCorner.Parent = viewEquippedBtn

    -- Undo and Favorites Buttons
    local undoBtn = Instance.new("TextButton")
    undoBtn.Size = UDim2.new(0.31, 0, 0, 35)
    undoBtn.Position = UDim2.new(0, 0, 0, 353)
    undoBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
    undoBtn.BackgroundTransparency = 0.3
    undoBtn.BorderSizePixel = 0
    undoBtn.Text = "↶ Undo"
    undoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    undoBtn.TextSize = 14
    undoBtn.Font = Enum.Font.GothamBold
    undoBtn.Parent = contentFrame
    
    local undoBtnCorner = Instance.new("UICorner")
    undoBtnCorner.CornerRadius = UDim.new(0, 6)
    undoBtnCorner.Parent = undoBtn
    
    local favoritesBtn = Instance.new("TextButton")
    favoritesBtn.Size = UDim2.new(0.31, 0, 0, 35)
    favoritesBtn.Position = UDim2.new(0.345, 0, 0, 353)
    favoritesBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    favoritesBtn.BackgroundTransparency = 0.3
    favoritesBtn.BorderSizePixel = 0
    favoritesBtn.Text = "⭐ Favorites"
    favoritesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    favoritesBtn.TextSize = 14
    favoritesBtn.Font = Enum.Font.GothamBold
    favoritesBtn.Parent = contentFrame
    
    local favoritesBtnCorner = Instance.new("UICorner")
    favoritesBtnCorner.CornerRadius = UDim.new(0, 6)
    favoritesBtnCorner.Parent = favoritesBtn
    
    local itemEditorBtn = Instance.new("TextButton")
    itemEditorBtn.Size = UDim2.new(0.31, 0, 0, 35)
    itemEditorBtn.Position = UDim2.new(0.69, 0, 0, 353)
    itemEditorBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 200)
    itemEditorBtn.BackgroundTransparency = 0.3
    itemEditorBtn.BorderSizePixel = 0
    itemEditorBtn.Text = "⚙️ Editor"
    itemEditorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemEditorBtn.TextSize = 14
    itemEditorBtn.Font = Enum.Font.GothamBold
    itemEditorBtn.Parent = contentFrame
    
    local itemEditorBtnCorner = Instance.new("UICorner")
    itemEditorBtnCorner.CornerRadius = UDim.new(0, 6)
    itemEditorBtnCorner.Parent = itemEditorBtn
    
    -- Outfit Management
    local outfitLabel = Instance.new("TextLabel")
    outfitLabel.Size = UDim2.new(1, 0, 0, 20)
    outfitLabel.Position = UDim2.new(0, 0, 0, 398)
    outfitLabel.BackgroundTransparency = 1
    outfitLabel.Text = "💾 Outfit Management"
    outfitLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    outfitLabel.TextSize = 14
    outfitLabel.Font = Enum.Font.GothamBold
    outfitLabel.TextXAlignment = Enum.TextXAlignment.Left
    outfitLabel.Parent = contentFrame
    
    local outfitInput = Instance.new("TextBox")
    outfitInput.Name = "OutfitInput"
    outfitInput.Size = UDim2.new(1, 0, 0, 35)
    outfitInput.Position = UDim2.new(0, 0, 0, 422)
    outfitInput.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    outfitInput.BackgroundTransparency = 0.3
    outfitInput.BorderSizePixel = 0
    outfitInput.PlaceholderText = "Outfit name..."
    outfitInput.Text = ""
    outfitInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    outfitInput.TextSize = 14
    outfitInput.Font = Enum.Font.Gotham
    outfitInput.ClearTextOnFocus = false
    outfitInput.Parent = contentFrame
    
    local outfitInputCorner = Instance.new("UICorner")
    outfitInputCorner.CornerRadius = UDim.new(0, 6)
    outfitInputCorner.Parent = outfitInput
    
    local outfitInputStroke = Instance.new("UIStroke")
    outfitInputStroke.Color = Color3.fromRGB(80, 80, 120)
    outfitInputStroke.Thickness = 1
    outfitInputStroke.Transparency = 0.6
    outfitInputStroke.Parent = outfitInput
    
    local saveOutfitBtn = createCategoryButton("Save", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0, 0, 0, 467)})
    saveOutfitBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 220)
    saveOutfitBtn.Parent = contentFrame
    
    local loadOutfitBtn = createCategoryButton("Load", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0.345, 0, 0, 467)})
    loadOutfitBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    loadOutfitBtn.Parent = contentFrame
    
    local deleteOutfitBtn = createCategoryButton("Delete", {size = UDim2.new(0.31, 0, 0, 35), pos = UDim2.new(0.69, 0, 0, 467)})
    deleteOutfitBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    deleteOutfitBtn.Parent = contentFrame
    
-- Saved Outfits List
    local outfitListLabel = Instance.new("TextLabel")
    outfitListLabel.Size = UDim2.new(1, 0, 0, 18)
    outfitListLabel.Position = UDim2.new(0, 0, 0, 512)
    outfitListLabel.BackgroundTransparency = 1
    outfitListLabel.Text = "📁 Saved Outfits:"
    outfitListLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
    outfitListLabel.TextSize = 13
    outfitListLabel.Font = Enum.Font.Gotham
    outfitListLabel.TextXAlignment = Enum.TextXAlignment.Left
    outfitListLabel.Parent = contentFrame
    
    local outfitScrollFrame = Instance.new("ScrollingFrame")
    outfitScrollFrame.Name = "OutfitScrollFrame"
    outfitScrollFrame.Size = UDim2.new(1, 0, 0, 80)  -- FIXED: Changed from 105 to 80
    outfitScrollFrame.Position = UDim2.new(0, 0, 0, 534)
    outfitScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    outfitScrollFrame.BackgroundTransparency = 0.4
    outfitScrollFrame.BorderSizePixel = 0
    outfitScrollFrame.ScrollBarThickness = 4
    outfitScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    outfitScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    outfitScrollFrame.ClipsDescendants = true  -- ADDED: Prevents overflow
    outfitScrollFrame.Parent = contentFrame
    
    -- Setup Button Logic
    GuiService.SetupMainFrameLogic(contentFrame, idInput, addBtn, clearBtn, viewEquippedBtn, 
        headBtn, torsoBtn, faceBtn, shirtBtn, pantsBtn, 
        headlessBtn, korbloxRBtn, korbloxLBtn,
        outfitInput, saveOutfitBtn, loadOutfitBtn, deleteOutfitBtn, outfitScrollFrame)
    
    -- Minimize/Close Logic
    local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            contentFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 450, 0, 45)
            minimizeBtn.Text = "□"
        else
            contentFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 450, 0, 660)  -- Changed from 620
            minimizeBtn.Text = "_"
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    -- Make draggable
    GuiService.MakeDraggable(titleBar, mainFrame)
end

function GuiService.SetupMainFrameLogic(contentFrame, idInput, addBtn, clearBtn, viewEquippedBtn,
    headBtn, torsoBtn, faceBtn, shirtBtn, pantsBtn,
    headlessBtn, korbloxRBtn, korbloxLBtn,
    outfitInput, saveOutfitBtn, loadOutfitBtn, deleteOutfitBtn, outfitScrollFrame)
    
    local cs = GuiService.CharacterService
    local os = GuiService.OutfitService
    
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
    
    -- Category Selection
    headBtn.MouseButton1Click:Connect(function()
        selectedCategory = "Head"
        updateButtonColors()
    end)
    
    torsoBtn.MouseButton1Click:Connect(function()
        selectedCategory = "Torso"
        updateButtonColors()
    end)
    
    faceBtn.MouseButton1Click:Connect(function()
        selectedCategory = "Face"
        updateButtonColors()
    end)
    
    shirtBtn.MouseButton1Click:Connect(function()
        selectedCategory = "Shirt"
        updateButtonColors()
    end)
    
    pantsBtn.MouseButton1Click:Connect(function()
        selectedCategory = "Pants"
        updateButtonColors()
    end)
    
    -- Apply Items with Batch Support
    addBtn.MouseButton1Click:Connect(function()
        local input = idInput.Text:gsub("%s+", "")
        local ids = {}
        
        for id in input:gmatch("[^,]+") do
            local numId = tonumber(id)
            if numId then
                table.insert(ids, numId)
            end
        end
        
        if #ids == 0 then
            addBtn.Text = "Invalid ID!"
            addBtn.BackgroundColor3 = Color3.fromRGB(220, 100, 100)
            task.wait(0.5)
            addBtn.Text = "✓ Apply Item(s)"
            addBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
            return
        end
        
        for _, id in ipairs(ids) do
            cs.AddAccessory(id, selectedCategory)
        end
        
        idInput.Text = ""
        addBtn.Text = #ids > 1 and ("Applied " .. #ids .. " items!") or "Applied!"
        addBtn.BackgroundColor3 = Color3.fromRGB(100, 220, 150)
        task.wait(0.5)
        addBtn.Text = "✓ Apply Item(s)"
        addBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
    end)
    
    -- Special Effects Buttons
    local headlessActive = false
    headlessBtn.MouseButton1Click:Connect(function()
        headlessActive = not headlessActive
        cs.ApplyHeadless(headlessActive)
        
        if headlessActive then
            headlessBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            headlessBtn.Text = "✓ Headless"
        else
            headlessBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            headlessBtn.Text = "Headless"
        end
    end)
    
    local korbloxRActive = false
    korbloxRBtn.MouseButton1Click:Connect(function()
        korbloxRActive = not korbloxRActive
        cs.ApplyKorblox(korbloxRActive, "Right")
        
        if korbloxRActive then
            korbloxRBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            korbloxRBtn.Text = "✓ Korblox R"
        else
            korbloxRBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            korbloxRBtn.Text = "Korblox R"
        end
    end)
    
    local korbloxLActive = false
    korbloxLBtn.MouseButton1Click:Connect(function()
        korbloxLActive = not korbloxLActive
        cs.ApplyKorblox(korbloxLActive, "Left")
        
        if korbloxLActive then
            korbloxLBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            korbloxLBtn.Text = "✓ Korblox L"
        else
            korbloxLBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            korbloxLBtn.Text = "Korblox L"
        end
    end)
    
    -- Clear All
    clearBtn.MouseButton1Click:Connect(function()
        cs.ClearAll()
        headlessActive = false
        korbloxRActive = false
        korbloxLActive = false
        headlessBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        headlessBtn.Text = "Headless"
        korbloxRBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        korbloxRBtn.Text = "Korblox R"
        korbloxLBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        korbloxLBtn.Text = "Korblox L"
        
        clearBtn.Text = "Cleared!"
        task.wait(0.5)
        clearBtn.Text = "✕ Clear All"
    end)
    
    -- View Equipped
    viewEquippedBtn.MouseButton1Click:Connect(function()
        if equippedFrame then
            equippedFrame.Visible = true
            GuiService.UpdateEquippedItems()
        end
    end)
    
    -- Outfit Management
    local function updateOutfitList()
        for _, child in pairs(outfitScrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local outfits = os.ListOutfits()
        
        for i, outfitName in ipairs(outfits) do
            local outfitBtn = Instance.new("TextButton")
            outfitBtn.Name = outfitName
            outfitBtn.Size = UDim2.new(1, -10, 0, 30)
            outfitBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
            outfitBtn.BackgroundTransparency = 0.3
            outfitBtn.BorderSizePixel = 0
            outfitBtn.Text = "📦 " .. outfitName
            outfitBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
            outfitBtn.TextSize = 13
            outfitBtn.Font = Enum.Font.Gotham
            outfitBtn.TextXAlignment = Enum.TextXAlignment.Left
            outfitBtn.TextTruncate = Enum.TextTruncate.AtEnd
            outfitBtn.Parent = outfitScrollFrame
            
            local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = outfitBtn
        local btnPadding = Instance.new("UIPadding")
        btnPadding.PaddingLeft = UDim.new(0, 10)
        btnPadding.Parent = outfitBtn
        
        outfitBtn.MouseButton1Click:Connect(function()
            local success = os.LoadOutfit(outfitName)
            if success then
                -- Update special effects button states
                if cs.Headless then
                    headlessActive = true
                    headlessBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                    headlessBtn.Text = "✓ Headless"
                end
                if cs.KorbloxRight then
                    korbloxRActive = true
                    korbloxRBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                    korbloxRBtn.Text = "✓ Korblox R"
                end
                if cs.KorbloxLeft then
                    korbloxLActive = true
                    korbloxLBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                    korbloxLBtn.Text = "✓ Korblox L"
                end
                
                outfitBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
                task.wait(0.3)
                outfitBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
            end
        end)
    end
    
    outfitScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #outfits * 35)
end

saveOutfitBtn.MouseButton1Click:Connect(function()
    local outfitName = outfitInput.Text:gsub("%s+", "_")
    if outfitName ~= "" then
        local success = os.SaveOutfit(outfitName)
        if success then
            saveOutfitBtn.Text = "Saved!"
            saveOutfitBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 150)
            updateOutfitList()
        else
            saveOutfitBtn.Text = "Failed!"
            saveOutfitBtn.BackgroundColor3 = Color3.fromRGB(220, 100, 100)
        end
        task.wait(0.5)
        saveOutfitBtn.Text = "Save"
        saveOutfitBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 220)
    end
end)

loadOutfitBtn.MouseButton1Click:Connect(function()
    local outfitName = outfitInput.Text:gsub("%s+", "_")
    if outfitName ~= "" then
        local success = os.LoadOutfit(outfitName)
        if success then
            loadOutfitBtn.Text = "Loaded!"
            loadOutfitBtn.BackgroundColor3 = Color3.fromRGB(150, 220, 150)
        else
            loadOutfitBtn.Text = "Not found!"
            loadOutfitBtn.BackgroundColor3 = Color3.fromRGB(220, 100, 100)
        end
        task.wait(0.5)
        loadOutfitBtn.Text = "Load"
        loadOutfitBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    end
end)

deleteOutfitBtn.MouseButton1Click:Connect(function()
    local outfitName = outfitInput.Text:gsub("%s+", "_")
    if outfitName ~= "" then
        local success = os.DeleteOutfit(outfitName)
        if success then
            deleteOutfitBtn.Text = "Deleted!"
            deleteOutfitBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            updateOutfitList()
        else
            deleteOutfitBtn.Text = "Not found!"
            deleteOutfitBtn.BackgroundColor3 = Color3.fromRGB(220, 100, 100)
        end
        task.wait(0.5)
        deleteOutfitBtn.Text = "Delete"
        deleteOutfitBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    end
end)

updateOutfitList()
end
function GuiService.CreateEquippedFrame()
equippedFrame = Instance.new("Frame")
equippedFrame.Name = "EquippedFrame"
equippedFrame.Size = UDim2.new(0, 350, 0, 400)
equippedFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
equippedFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
equippedFrame.BackgroundTransparency = 0.15
equippedFrame.BorderSizePixel = 0
equippedFrame.Visible = false
equippedFrame.Parent = screenGui
local equippedFrameCorner = Instance.new("UICorner")
equippedFrameCorner.CornerRadius = UDim.new(0, 12)
equippedFrameCorner.Parent = equippedFrame

local equippedFrameStroke = Instance.new("UIStroke")
equippedFrameStroke.Color = Color3.fromRGB(100, 100, 150)
equippedFrameStroke.Thickness = 1
equippedFrameStroke.Transparency = 0.5
equippedFrameStroke.Parent = equippedFrame

-- Title Bar
local equippedTitleBar = Instance.new("Frame")
equippedTitleBar.Size = UDim2.new(1, 0, 0, 45)
equippedTitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
equippedTitleBar.BackgroundTransparency = 0.2
equippedTitleBar.BorderSizePixel = 0
equippedTitleBar.Parent = equippedFrame

local equippedTitleBarCorner = Instance.new("UICorner")
equippedTitleBarCorner.CornerRadius = UDim.new(0, 12)
equippedTitleBarCorner.Parent = equippedTitleBar

local equippedTitleBarBottom = Instance.new("Frame")
equippedTitleBarBottom.Size = UDim2.new(1, 0, 0, 12)
equippedTitleBarBottom.Position = UDim2.new(0, 0, 1, -12)
equippedTitleBarBottom.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
equippedTitleBarBottom.BackgroundTransparency = 0.2
equippedTitleBarBottom.BorderSizePixel = 0
equippedTitleBarBottom.Parent = equippedTitleBar

local equippedTitle = Instance.new("TextLabel")
equippedTitle.Size = UDim2.new(1, -50, 1, 0)
equippedTitle.Position = UDim2.new(0, 15, 0, 0)
equippedTitle.BackgroundTransparency = 1
equippedTitle.Text = "🎒 Equipped Items"
equippedTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
equippedTitle.TextSize = 18
equippedTitle.Font = Enum.Font.GothamBold
equippedTitle.TextXAlignment = Enum.TextXAlignment.Left
equippedTitle.Parent = equippedTitleBar

local equippedCloseBtn = Instance.new("TextButton")
equippedCloseBtn.Size = UDim2.new(0, 35, 0, 35)
equippedCloseBtn.Position = UDim2.new(1, -40, 0, 5)
equippedCloseBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
equippedCloseBtn.BackgroundTransparency = 0.2
equippedCloseBtn.BorderSizePixel = 0
equippedCloseBtn.Text = "×"
equippedCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
equippedCloseBtn.TextSize = 24
equippedCloseBtn.Font = Enum.Font.GothamBold
equippedCloseBtn.Parent = equippedTitleBar

local equippedCloseBtnCorner = Instance.new("UICorner")
equippedCloseBtnCorner.CornerRadius = UDim.new(0, 6)
equippedCloseBtnCorner.Parent = equippedCloseBtn

-- Scrolling Frame
local equippedScrollFrame = Instance.new("ScrollingFrame")
equippedScrollFrame.Name = "EquippedScrollFrame"
equippedScrollFrame.Size = UDim2.new(1, -20, 1, -65)
equippedScrollFrame.Position = UDim2.new(0, 10, 0, 55)
equippedScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
equippedScrollFrame.BackgroundTransparency = 0.4
equippedScrollFrame.BorderSizePixel = 0
equippedScrollFrame.ScrollBarThickness = 4
equippedScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
equippedScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
equippedScrollFrame.Parent = equippedFrame

local equippedScrollCorner = Instance.new("UICorner")
equippedScrollCorner.CornerRadius = UDim.new(0, 6)
equippedScrollCorner.Parent = equippedScrollFrame

local equippedListLayout = Instance.new("UIListLayout")
equippedListLayout.SortOrder = Enum.SortOrder.LayoutOrder
equippedListLayout.Padding = UDim.new(0, 5)
equippedListLayout.Parent = equippedScrollFrame

equippedCloseBtn.MouseButton1Click:Connect(function()
    equippedFrame.Visible = false
end)

GuiService.MakeDraggable(equippedTitleBar, equippedFrame)
end
function GuiService.UpdateEquippedItems()
    local cs = GuiService.CharacterService
    local equippedScrollFrame = equippedFrame:FindFirstChild("EquippedScrollFrame")
    if not equippedScrollFrame then return end
    
    for _, child in pairs(equippedScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local function createItemFrame(text, itemId, bodyPart)
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -10, 0, 35)
        itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
        itemFrame.BackgroundTransparency = 0.3
        itemFrame.BorderSizePixel = 0
        itemFrame.Parent = equippedScrollFrame
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 6)
        itemCorner.Parent = itemFrame
        
        local itemLabel = Instance.new("TextLabel")
        itemLabel.Size = UDim2.new(1, -50, 1, 0)
        itemLabel.Position = UDim2.new(0, 10, 0, 0)
        itemLabel.BackgroundTransparency = 1
        itemLabel.Text = text
        itemLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
        itemLabel.TextSize = 13
        itemLabel.Font = Enum.Font.Gotham
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        itemLabel.Parent = itemFrame
        
        if itemId and bodyPart then
            local removeBtn = Instance.new("TextButton")
            removeBtn.Size = UDim2.new(0, 30, 0, 25)
            removeBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
            removeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
            removeBtn.BackgroundTransparency = 0.2
            removeBtn.BorderSizePixel = 0
            removeBtn.Text = "✕"
            removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            removeBtn.TextSize = 16
            removeBtn.Font = Enum.Font.GothamBold
            removeBtn.Parent = itemFrame
            
            local removeBtnCorner = Instance.new("UICorner")
            removeBtnCorner.CornerRadius = UDim.new(0, 4)
            removeBtnCorner.Parent = removeBtn
            
            removeBtn.MouseButton1Click:Connect(function()
                cs.RemoveAccessory(itemId, bodyPart)
                -- Refresh the equipped items display after removal
                task.wait(0.1)
                GuiService.UpdateEquippedItems()
            end)
        end
        
        return itemFrame
    end

    local yOffset = 0

    -- Head accessories
    for _, id in ipairs(cs.Head) do
        createItemFrame("🎩 Head: " .. tostring(id), id, "Head")
        yOffset = yOffset + 40
    end

    -- Torso accessories
    for _, id in ipairs(cs.Torso) do
        createItemFrame("👕 Torso: " .. tostring(id), id, "Torso")
        yOffset = yOffset + 40
    end

    -- Face/Shirt/Pants
    if cs.Face then
        createItemFrame("😊 Face: " .. tostring(cs.Face))
        yOffset = yOffset + 40
    end

    if cs.Shirt then
        createItemFrame("👔 Shirt: " .. tostring(cs.Shirt))
        yOffset = yOffset + 40
    end

    if cs.Pants then
        createItemFrame("👖 Pants: " .. tostring(cs.Pants))
        yOffset = yOffset + 40
    end

    -- Special effects
    if cs.Headless then
        createItemFrame("👻 Headless: Active")
        yOffset = yOffset + 40
    end

    if cs.KorbloxRight then
        createItemFrame("🦴 Korblox Right: Active")
        yOffset = yOffset + 40
    end

    if cs.KorbloxLeft then
        createItemFrame("🦴 Korblox Left: Active")
        yOffset = yOffset + 40
    end

    equippedScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end
function GuiService.MakeDraggable(handle, frame)
local dragging
local dragInput
local dragStart
local startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

handle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
end
function GuiService.SetupKeybind()
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if not gameProcessed and input.KeyCode == TOGGLE_KEY then
if mainFrame then
mainFrame.Visible = not mainFrame.Visible
end
end
end)
end
return GuiService
