local EthrinHub = {}
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local coreGui = game:GetService("CoreGui")
local localPlayer = players.LocalPlayer

-- Constants and settings
local FONT = Enum.Font.SourceSansBold
local TITLE_FONT = Enum.Font.GothamBold
local PRIMARY_COLOR = Color3.fromRGB(64, 64, 93)
local SECONDARY_COLOR = Color3.fromRGB(32, 32, 46)
local ACCENT_COLOR = Color3.fromRGB(114, 111, 255)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local TOGGLE_ON_COLOR = Color3.fromRGB(114, 111, 255)
local TOGGLE_OFF_COLOR = Color3.fromRGB(60, 60, 80)
local DARK_BLUE_BG = Color3.fromRGB(20, 20, 35)
local SLIDER_BAR_COLOR = Color3.fromRGB(114, 111, 255)

-- Utility functions
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function createDraggable(frame, dragRegion)
    local dragging, dragInput, dragStart, startPos
    
    dragRegion.InputBegan:Connect(function(input)
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
    
    dragRegion.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main GUI creation
function EthrinHub:CreateWindow(title)
    -- Check if already exists
    if coreGui:FindFirstChild("EthrinHub") then
        coreGui:FindFirstChild("EthrinHub"):Destroy()
    end
    
    -- Create main GUI components
    local mainGui = createInstance("ScreenGui", {
        Name = "EthrinHub",
        Parent = coreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    local mainFrame = createInstance("Frame", {
        Name = "MainFrame",
        Parent = mainGui,
        BackgroundColor3 = DARK_BLUE_BG,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true
    })
    
    local cornerRadius = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = mainFrame
    })
    
    local topBar = createInstance("Frame", {
        Name = "TopBar",
        Parent = mainFrame,
        BackgroundColor3 = SECONDARY_COLOR,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    local topBarCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = topBar
    })
    
    local titleLabel = createInstance("TextLabel", {
        Name = "Title",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = TITLE_FONT,
        Text = "ETHRIN",
        TextColor3 = TEXT_COLOR,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local searchBar = createInstance("Frame", {
        Name = "SearchBar",
        Parent = topBar,
        BackgroundColor3 = PRIMARY_COLOR,
        Position = UDim2.new(0.5, -100, 0.5, -12),
        Size = UDim2.new(0, 200, 0, 24),
        BorderSizePixel = 0
    })
    
    local searchCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = searchBar
    })
    
    local searchBox = createInstance("TextBox", {
        Name = "SearchBox",
        Parent = searchBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = FONT,
        PlaceholderText = "Search",
        Text = "",
        TextColor3 = TEXT_COLOR,
        TextSize = 14
    })
    
    local searchIcon = createInstance("ImageLabel", {
        Name = "SearchIcon",
        Parent = searchBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -22, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36)
    })
    
    -- Player avatar in top right
    local playerAvatarFrame = createInstance("Frame", {
        Name = "PlayerAvatarFrame",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0.5, -16),
        Size = UDim2.new(0, 32, 0, 32)
    })
    
    local playerAvatar = createInstance("ImageLabel", {
        Name = "PlayerAvatar",
        Parent = playerAvatarFrame,
        BackgroundTransparency =.5,
        BackgroundColor3 = SECONDARY_COLOR,
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. localPlayer.UserId .. "&w=48&h=48"
    })
    
    local playerAvatarCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = playerAvatar
    })
    
    -- Sidebar and content container
    local sidebarFrame = createInstance("Frame", {
        Name = "Sidebar",
        Parent = mainFrame,
        BackgroundColor3 = SECONDARY_COLOR,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 150, 1, -35)
    })
    
    local contentContainer = createInstance("Frame", {
        Name = "ContentContainer",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 35),
        Size = UDim2.new(1, -150, 1, -35),
        ClipsDescendants = true
    })
    
    -- Make the main window draggable
    createDraggable(mainFrame, topBar)
    
    -- Create tab system
    local tabButtons = {}
    local tabPages = {}
    local selectedTab = nil
    
    local tabFunctions = {}
    
    function tabFunctions:CreateTab(tabName, iconId, iconRectOffset, iconRectSize)
        -- Create tab button for sidebar
        local tabButton = createInstance("TextButton", {
            Name = tabName .. "Button",
            Parent = sidebarFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, #tabButtons * 40),
            Size = UDim2.new(1, 0, 0, 40),
            Font = FONT,
            Text = tabName,
            TextColor3 = TEXT_COLOR,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local padding = createInstance("UIPadding", {
            Parent = tabButton,
            PaddingLeft = UDim.new(0, 40)
        })
        
        local icon = nil
        if iconId then
            icon = createInstance("ImageLabel", {
                Name = "Icon",
                Parent = tabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = iconId
            })
            
            if iconRectOffset and iconRectSize then
                icon.ImageRectOffset = iconRectOffset
                icon.ImageRectSize = iconRectSize
            end
        end
        
        local tabIndicator = createInstance("Frame", {
            Name = "TabIndicator",
            Parent = tabButton,
            BackgroundColor3 = ACCENT_COLOR,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 3, 1, 0),
            Visible = false
        })
        
        -- Create page for tab content
        local tabPage = createInstance("ScrollingFrame", {
            Name = tabName .. "Page",
            Parent = contentContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = ACCENT_COLOR,
            Visible = false
        })
        
        local elementsContainer = createInstance("Frame", {
            Name = "ElementsContainer",
            Parent = tabPage,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -10, 1, 0),
        })
        
        local uiListLayout = createInstance("UIListLayout", {
            Parent = elementsContainer,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local padding = createInstance("UIPadding", {
            Parent = elementsContainer,
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        -- Add to tab collections
        table.insert(tabButtons, tabButton)
        tabPages[tabButton] = tabPage
        
        -- Tab selection handling
        tabButton.MouseButton1Click:Connect(function()
            if selectedTab then
                selectedTab.TabIndicator.Visible = false
                tabPages[selectedTab].Visible = false
            end
            
            selectedTab = tabButton
            tabIndicator.Visible = true
            tabPage.Visible = true
        end)
        
        -- Automatically select first tab
        if #tabButtons == 1 then
            selectedTab = tabButton
            tabIndicator.Visible = true
            tabPage.Visible = true
        end
        
        -- Tab-specific element functions
        local elements = {}
        
        -- Create toggle switch
        function elements:CreateToggle(title, description, default, callback)
            local toggleContainer = createInstance("Frame", {
                Name = title .. "Container",
                Parent = elementsContainer,
                BackgroundColor3 = SECONDARY_COLOR,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -30, 0, 60)
            })
            
            local containerCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = toggleContainer
            })
            
            local toggleTitle = createInstance("TextLabel", {
                Name = "Title",
                Parent = toggleContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -70, 0, 20),
                Font = FONT,
                Text = title,
                TextColor3 = TEXT_COLOR,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local toggleDescription = createInstance("TextLabel", {
                Name = "Description",
                Parent = toggleContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 25),
                Size = UDim2.new(1, -70, 0, 20),
                Font = FONT,
                Text = description,
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local toggleButton = createInstance("Frame", {
                Name = "ToggleButton",
                Parent = toggleContainer,
                BackgroundColor3 = default and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR,
                Position = UDim2.new(1, -60, 0.5, -10),
                Size = UDim2.new(0, 50, 0, 24),
                BorderSizePixel = 0
            })
            
            local toggleCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleButton
            })
            
            local toggleCircle = createInstance("Frame", {
                Name = "ToggleCircle",
                Parent = toggleButton,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = default and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                Size = UDim2.new(0, 18, 0, 18),
                BorderSizePixel = 0
            })
            
            local circleCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleCircle
            })
            
            local toggled = default or false
            
            local function updateToggle()
                toggled = not toggled
                local targetPos = toggled and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                local targetColor = toggled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
                
                tweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = targetPos}):Play()
                tweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                
                if callback then
                    callback(toggled)
                end
            end
            
            toggleButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateToggle()
                end
            end)
            
            return {
                Instance = toggleContainer,
                SetValue = function(value)
                    if toggled ~= value then
                        updateToggle()
                    end
                end,
                GetValue = function()
                    return toggled
                end
            }
        end
        
        -- Create slider
        function elements:CreateSlider(title, description, min, max, default, callback)
            local sliderContainer = createInstance("Frame", {
                Name = title .. "Container",
                Parent = elementsContainer,
                BackgroundColor3 = SECONDARY_COLOR,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -30, 0, 70)
            })
            
            local containerCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = sliderContainer
            })
            
            local sliderTitle = createInstance("TextLabel", {
                Name = "Title",
                Parent = sliderContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(0.7, 0, 0, 20),
                Font = FONT,
                Text = title,
                TextColor3 = TEXT_COLOR,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sliderValue = createInstance("TextLabel", {
                Name = "Value",
                Parent = sliderContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.7, 0, 0, 5),
                Size = UDim2.new(0.3, -10, 0, 20),
                Font = FONT,
                Text = tostring(default),
                TextColor3 = TEXT_COLOR,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local sliderDescription = createInstance("TextLabel", {
                Name = "Description",
                Parent = sliderContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 25),
                Size = UDim2.new(1, -20, 0, 20),
                Font = FONT,
                Text = description,
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sliderBackground = createInstance("Frame", {
                Name = "SliderBackground",
                Parent = sliderContainer,
                BackgroundColor3 = PRIMARY_COLOR,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 50),
                Size = UDim2.new(1, -20, 0, 6)
            })
            
            local backgroundCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderBackground
            })
            
            local sliderFill = createInstance("Frame", {
                Name = "SliderFill",
                Parent = sliderBackground,
                BackgroundColor3 = SLIDER_BAR_COLOR,
                BorderSizePixel = 0,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            })
            
            local fillCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderFill
            })
            
            local sliderKnob = createInstance("Frame", {
                Name = "SliderKnob",
                Parent = sliderFill,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14),
                ZIndex = 2
            })
            
            local knobCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderKnob
            })
            
            local value = default
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
                local newValue = math.floor(min + (max - min) * pos + 0.5)
                
                if newValue ~= value then
                    value = newValue
                    sliderValue.Text = tostring(value)
                    sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    
                    if callback then
                        callback(value)
                    end
                end
            end
            
            sliderBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateSlider(input)
                    
                    local dragging = true
                    
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                    
                    while dragging and runService.RenderStepped:Wait() do
                        updateSlider({Position = userInputService:GetMouseLocation()})
                    end
                end
            end)
            
            return {
                Instance = sliderContainer,
                SetValue = function(newValue)
                    value = math.clamp(newValue, min, max)
                    sliderValue.Text = tostring(value)
                    sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    
                    if callback then
                        callback(value)
                    end
                end,
                GetValue = function()
                    return value
                end
            }
        end
        
        -- Create dropdown
        function elements:CreateDropdown(title, description, options, default, callback)
            local dropdownContainer = createInstance("Frame", {
                Name = title .. "Container",
                Parent = elementsContainer,
                BackgroundColor3 = SECONDARY_COLOR,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -30, 0, 60),
                ClipsDescendants = true
            })
            
            local containerCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = dropdownContainer
            })
            
            local dropdownTitle = createInstance("TextLabel", {
                Name = "Title",
                Parent = dropdownContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = FONT,
                Text = title,
                TextColor3 = TEXT_COLOR,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local dropdownDescription = createInstance("TextLabel", {
                Name = "Description",
                Parent = dropdownContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 25),
                Size = UDim2.new(1, -20, 0, 20),
                Font = FONT,
                Text = description,
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local dropdownButton = createInstance("TextButton", {
                Name = "DropdownButton",
                Parent = dropdownContainer,
                BackgroundColor3 = PRIMARY_COLOR,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 50),
                Size = UDim2.new(1, -20, 0, 30),
                Font = FONT,
                Text = default or "Select Option",
                TextColor3 = TEXT_COLOR,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local buttonPadding = createInstance("UIPadding", {
                Parent = dropdownButton,
                PaddingLeft = UDim.new(0, 10)
            })
            
            local buttonCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = dropdownButton
            })
            
            local dropdownArrow = createInstance("ImageLabel", {
                Name = "DropdownArrow",
                Parent = dropdownButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://6031091004",
                Rotation = 0
            })
            
            local optionsContainer = createInstance("Frame", {
                Name = "OptionsContainer",
                Parent = dropdownContainer,
                BackgroundColor3 = PRIMARY_COLOR,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 85),
                Size = UDim2.new(1, -20, 0, 0),
                Visible = false
            })
            
            local optionsCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = optionsContainer
            })
            
            local optionsList = createInstance("ScrollingFrame", {
                Name = "OptionsList",
                Parent = optionsContainer,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, #options * 30),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = ACCENT_COLOR
            })
            
            local listLayout = createInstance("UIListLayout", {
                Parent = optionsList,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            local selected = default
            local dropdownOpen = false
            
            local function toggleDropdown()
                dropdownOpen = not dropdownOpen
                
                local targetSize = dropdownOpen and UDim2.new(1, -20, 0, math.min(150, #options * 30)) or UDim2.new(1, -20, 0, 0)
                local targetRotation = dropdownOpen and 180 or 0
                
                tweenService:Create(dropdownContainer, TweenInfo.new(0.2), {Size = UDim2.new(1, -30, 0, dropdownOpen and (110 + math.min(150, #options * 30)) or 60)}):Play()
                tweenService:Create(optionsContainer, TweenInfo.new(0.2), {Size = targetSize}):Play()
                tweenService:Create(dropdownArrow, TweenInfo.new(0.2), {Rotation = targetRotation}):Play()
                
                optionsContainer.Visible = dropdownOpen
            end
            
            -- Create option buttons
            for i, option in pairs(options) do
                local optionButton = createInstance("TextButton", {
                    Name = option .. "Button",
                    Parent = optionsList,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = FONT,
                    Text = option,
                    TextColor3 = TEXT_COLOR,
                    TextSize = 14
                })
                
                optionButton.MouseButton1Click:Connect(function()
                    selected = option
                    dropdownButton.Text = option
                    toggleDropdown()
                    
                    if callback then
                        callback(option)
                    end
                end)
            end
            
            dropdownButton.MouseButton1Click:Connect(toggleDropdown)
            
            return {
                Instance = dropdownContainer,
                SetValue = function(option)
                    if table.find(options, option) then
                        selected = option
                        dropdownButton.Text = option
                        
                        if callback then
                            callback(option)
                        end
                    end
                end,
                GetValue = function()
                    return selected
                end,
                Refresh = function(newOptions, keepSelected)
                    -- Clear old options
                    for _, child in pairs(optionsList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Add new options
                    for i, option in pairs(newOptions) do
                        local optionButton = createInstance("TextButton", {
                            Name = option .. "Button",
                            Parent = optionsList,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 30),
                            Font = FONT,
                            Text = option,
                            TextColor3 = TEXT_COLOR,
                            TextSize = 14
                        })
                        
                        optionButton.MouseButton1Click:Connect(function()
                            selected = option
                            dropdownButton.Text = option
                            toggleDropdown()
                            
                            if callback then
                                callback(option)
                            end
                        end)
                    end
                    
                    optionsList.CanvasSize = UDim2.new(0, 0, 0, #newOptions * 30)
                    
                    -- Update selected
                    if not keepSelected or not table.find(newOptions, selected) then
                        selected = newOptions[1]
                        dropdownButton.Text = selected
                        
                        if callback then
                            callback(selected)
                        end
                    end
                    
                    options = newOptions
                end
            }
        end
        
        -- Create color picker
        function elements:CreateColorPicker(title, default, callback)
            local pickerContainer = createInstance("Frame", {
                Name = title .. "Container",
                Parent = elementsContainer,
                BackgroundColor3 = SECONDARY_COLOR,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -30, 0, 60)
            })
            
            local containerCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = pickerContainer
            })
            
            local pickerTitle = createInstance("TextLabel", {
                Name = "Title",
                Parent = pickerContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -80, 1, 0),
                Font = FONT,
                Text = title,
                TextColor3 = TEXT_COLOR,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center
            })
            
            local colorDisplay = createInstance("Frame", {
                Name = "ColorDisplay",
                Parent = pickerContainer,
                BackgroundColor3 = default or Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -60, 0.5, -20),
                Size = UDim2.new(0, 40, 0, 40)
            })
            
            local displayCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = colorDisplay
            })
            
            -- Simplified color picker - in a real implementation you would add a full HSV picker
            local currentColor = default or Color3.fromRGB(255, 255, 255)
            
            colorDisplay.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- In a real implementation, you would open a proper color picker here
                    -- This is simplified for the demo
                    local r = math.random(0, 255)
                    local g = math.random(0, 255)
                    local b = math.random(0, 255)
                    currentColor = Color3.fromRGB(r, g, b)
                    
                    colorDisplay.BackgroundColor3 = currentColor
                    
                    if callback then
                        callback(currentColor)
                    end
                end
            end)
            
            return {
                Instance = pickerContainer,
                SetValue = function(color)
                    currentColor = color
                    colorDisplay.BackgroundColor3 = color
                    
                    if callback then
                        callback(color)
                    end
                end,
                GetValue = function()
                    return currentColor
                end
            }
        end
        
        -- Create key picker
        function elements:CreateKeybind(title, default, callback)
            local keybindContainer = createInstance("Frame", {
                Name = title .. "Container",
                Parent = elementsContainer,
                BackgroundColor3 = SECONDARY_COLOR,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -30, 0, 60)
            })
            
            local containerCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = keybindContainer
            })
            
            local keybindTitle = createInstance("TextLabel", {
                Name = "Title",
                Parent = keybindContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -100, 1, 0),
                Font = FONT,
                Text = title,
                TextColor3 = TEXT_COLOR,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center
            })
            
            local keybindButton = createInstance("TextButton", {
                Name = "KeybindButton",
                Parent = keybindContainer,
                BackgroundColor3 = PRIMARY_COLOR,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -90, 0.5, -15),
                Size = UDim2.new(0, 80, 0, 30),
                Font = FONT,
                Text = default and default.Name or "None",
                TextColor3 = TEXT_COLOR,
                TextSize = 14
            })
            
            local buttonCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = keybindButton
            })
            
            local currentKey = default
            local listening = false
            
            keybindButton.MouseButton1Click:Connect(function()
                if listening then return end
                
                listening = true
                keybindButton.Text = "..."
                
                local connection
                connection = userInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keybindButton.Text = currentKey.Name
                        
                        if callback then
                            callback(currentKey)
                        end
                        
                        listening = false
                        connection:Disconnect()
                    end
                end)
            end)
            
            return {
                Instance = keybindContainer,
                SetValue = function(key)
                    currentKey = key
                    keybindButton.Text = key and key.Name or "None"
                    
                    if callback then
                        callback(key)
                    end
                end,
                GetValue = function()
                    return currentKey
                end
            }
        end
        
        -- Return all tab element creation functions
        return elements
    end
    
    -- Load configuration system
    local configs = {}
    
    function tabFunctions:SaveConfig(name)
        local config = {}
        
        -- Logic to save all values from UI elements
        -- This would be more complex in a real implementation
        
        configs[name] = config
        return config
    end
    
    function tabFunctions:LoadConfig(name)
        local config = configs[name]
        if not config then return false end
        
        -- Logic to load values into UI elements
        -- This would be more complex in a real implementation
        
        return true
    end
    
    -- Return window manipulation and tab functions
    return tabFunctions
end

-- Return the library
return EthrinHub
