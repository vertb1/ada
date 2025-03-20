-- SimpleUI: A custom UI library for Roblox
local SimpleUI = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Constants
local ELEMENT_PADDING = 5
local TITLE_HEIGHT = 20
local DEFAULT_COLOR = Color3.fromRGB(80, 120, 255)
local BACKGROUND_COLOR = Color3.fromRGB(40, 40, 40)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local SECONDARY_COLOR = Color3.fromRGB(60, 60, 60)
local HOVER_COLOR = Color3.fromRGB(100, 100, 100)

-- Utility functions
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function makeDraggable(frame, dragArea)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragArea.InputBegan:Connect(function(input)
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

    dragArea.InputChanged:Connect(function(input)
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

-- Main UI class
local UI = {}
UI.__index = UI

function SimpleUI.new(title, options)
    options = options or {}
    
    -- Create the main ScreenGui
    local screenGui = createInstance("ScreenGui", {
        Name = "SimpleUI_" .. title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = options.parent or (game:GetService("CoreGui"):FindFirstChild("RobloxGui") or CoreGui)
    })
    
    -- Create the main frame
    local mainFrame = createInstance("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = BACKGROUND_COLOR,
        BorderSizePixel = 0,
        Position = options.position or UDim2.new(0.5, -200, 0.5, -150),
        Size = options.size or UDim2.new(0, 400, 0, 300),
        Parent = screenGui
    })
    
    -- Add corner radius
    local corner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = mainFrame
    })
    
    -- Create title bar
    local titleBar = createInstance("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = DEFAULT_COLOR,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, TITLE_HEIGHT),
        Parent = mainFrame
    })
    
    -- Add corner radius to title bar but only top corners
    local titleCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = titleBar
    })
    
    -- Make sure the bottom corners aren't rounded
    local titleBottomFrame = createInstance("Frame", {
        Name = "BottomFrame",
        BackgroundColor3 = DEFAULT_COLOR,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        Parent = titleBar
    })
    
    -- Title text
    local titleText = createInstance("TextLabel", {
        Name = "TitleText",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.SourceSansBold,
        Text = title,
        TextColor3 = TEXT_COLOR,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Close button
    local closeButton = createInstance("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 25, 1, 0),
        Font = Enum.Font.SourceSansBold,
        Text = "×",
        TextColor3 = TEXT_COLOR,
        TextSize = 24,
        Parent = titleBar
    })
    
    closeButton.MouseEnter:Connect(function()
        closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    end)
    
    closeButton.MouseLeave:Connect(function()
        closeButton.TextColor3 = TEXT_COLOR
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tab container
    local tabButtons = createInstance("Frame", {
        Name = "TabButtons",
        BackgroundColor3 = SECONDARY_COLOR,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, TITLE_HEIGHT),
        Size = UDim2.new(1, 0, 0, 30),
        Parent = mainFrame
    })
    
    -- Tab content container
    local tabContent = createInstance("Frame", {
        Name = "TabContent",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, TITLE_HEIGHT + 30),
        Size = UDim2.new(1, 0, 1, -(TITLE_HEIGHT + 30)),
        Parent = mainFrame
    })
    
    -- Tab button layout
    local tabButtonLayout = createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = tabButtons
    })
    
    -- Tab padding
    local tabButtonPadding = createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = tabButtons
    })
    
    -- Make the window draggable
    makeDraggable(mainFrame, titleBar)
    
    -- Create and return the UI object
    local self = setmetatable({
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TitleBar = titleBar,
        TabButtons = tabButtons,
        TabContent = tabContent,
        Tabs = {},
        CurrentTab = nil,
        AccentColor = DEFAULT_COLOR
    }, UI)
    
    return self
end

function UI:SetAccentColor(color)
    self.AccentColor = color
    self.TitleBar.BackgroundColor3 = color
    self.TitleBar.BottomFrame.BackgroundColor3 = color
    
    for _, tab in pairs(self.Tabs) do
        if tab.Selected then
            tab.Button.BackgroundColor3 = color
        end
    end
end

function UI:AddTab(name)
    -- Create tab button
    local tabButton = createInstance("TextButton", {
        Name = name .. "Button",
        BackgroundColor3 = self.CurrentTab == nil and self.AccentColor or SECONDARY_COLOR,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 100, 1, 0),
        Font = Enum.Font.SourceSansSemibold,
        Text = name,
        TextColor3 = TEXT_COLOR,
        TextSize = 16,
        Parent = self.TabButtons
    })
    
    -- Add corner radius
    local buttonCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = tabButton
    })
    
    -- Create tab container
    local tabContainer = createInstance("ScrollingFrame", {
        Name = name .. "Container",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        Visible = self.CurrentTab == nil,
        Parent = self.TabContent
    })
    
    -- Add padding
    local containerPadding = createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = tabContainer
    })
    
    -- Add layout
    local containerLayout = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = tabContainer
    })
    
    -- Update canvas size when elements are added
    containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, containerLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab object
    local tab = {
        Button = tabButton,
        Container = tabContainer,
        Elements = {},
        Selected = self.CurrentTab == nil,
        Name = name
    }
    
    -- Select tab function
    local function selectTab()
        for _, t in pairs(self.Tabs) do
            t.Selected = false
            t.Button.BackgroundColor3 = SECONDARY_COLOR
            t.Container.Visible = false
        end
        
        tab.Selected = true
        tab.Button.BackgroundColor3 = self.AccentColor
        tab.Container.Visible = true
        self.CurrentTab = tab
    end
    
    -- Connect button click
    tabButton.MouseButton1Click:Connect(selectTab)
    
    -- Add to tabs table
    self.Tabs[name] = tab
    if self.CurrentTab == nil then
        self.CurrentTab = tab
    end
    
    -- Tab methods
    local tabMethods = {}
    
    function tabMethods:AddSection(sectionName)
        -- Create section frame
        local sectionFrame = createInstance("Frame", {
            Name = sectionName .. "Section",
            BackgroundColor3 = SECONDARY_COLOR,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = tabContainer
        })
        
        -- Add corner radius
        local sectionCorner = createInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = sectionFrame
        })
        
        -- Section title
        local sectionTitle = createInstance("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 0, 30),
            Font = Enum.Font.SourceSansBold,
            Text = sectionName,
            TextColor3 = TEXT_COLOR,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sectionFrame
        })
        
        -- Section content
        local sectionContent = createInstance("Frame", {
            Name = "Content",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 30),
            Size = UDim2.new(1, -20, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = sectionFrame
        })
        
        -- Add layout
        local contentLayout = createInstance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = sectionContent
        })
        
        -- Update section size when elements are added
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sectionContent.Size = UDim2.new(1, -20, 0, contentLayout.AbsoluteContentSize.Y)
            sectionFrame.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 40)
        end)
        
        -- Section methods
        local sectionMethods = {}
        
        function sectionMethods:AddButton(config)
            config = config or {}
            local buttonText = config.Text or "Button"
            local callback = config.Callback or function() end
            
            -- Create button
            local buttonFrame = createInstance("TextButton", {
                Name = buttonText .. "Button",
                BackgroundColor3 = SECONDARY_COLOR,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.SourceSans,
                Text = "",
                AutoButtonColor = false,
                Parent = sectionContent
            })
            
            -- Add corner radius
            local buttonCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = buttonFrame
            })
            
            -- Button text
            local buttonLabel = createInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = buttonText,
                TextColor3 = TEXT_COLOR,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = buttonFrame
            })
            
            -- Button interactions
            buttonFrame.MouseEnter:Connect(function()
                buttonFrame.BackgroundColor3 = HOVER_COLOR
            end)
            
            buttonFrame.MouseLeave:Connect(function()
                buttonFrame.BackgroundColor3 = SECONDARY_COLOR
            end)
            
            buttonFrame.MouseButton1Click:Connect(callback)
            
            local buttonObj = {
                Frame = buttonFrame,
                Label = buttonLabel,
                Type = "Button"
            }
            
            table.insert(tab.Elements, buttonObj)
            return buttonObj
        end
        
        function sectionMethods:AddToggle(config)
            config = config or {}
            local toggleText = config.Text or "Toggle"
            local default = config.Default or false
            local callback = config.Callback or function() end
            
            -- Create toggle frame
            local toggleFrame = createInstance("Frame", {
                Name = toggleText .. "Toggle",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Parent = sectionContent
            })
            
            -- Toggle text
            local toggleLabel = createInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 30, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = toggleText,
                TextColor3 = TEXT_COLOR,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame
            })
            
            -- Toggle box
            local toggleBox = createInstance("Frame", {
                Name = "Box",
                BackgroundColor3 = default and DEFAULT_COLOR or SECONDARY_COLOR,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = toggleFrame
            })
            
            -- Add corner radius
            local boxCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = toggleBox
            })
            
            -- Toggle button overlay
            local toggleButton = createInstance("TextButton", {
                Name = "Button",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = toggleFrame
            })
            
            -- Toggle state
            local toggleState = default
            
            -- Toggle function
            local function updateToggle()
                toggleState = not toggleState
                toggleBox.BackgroundColor3 = toggleState and DEFAULT_COLOR or SECONDARY_COLOR
                callback(toggleState)
            end
            
            -- Connect button
            toggleButton.MouseButton1Click:Connect(updateToggle)
            
            local toggleObj = {
                Frame = toggleFrame,
                Label = toggleLabel,
                Box = toggleBox,
                Button = toggleButton,
                Value = toggleState,
                Toggle = updateToggle,
                Type = "Toggle",
                SetValue = function(self, value)
                    if value ~= toggleState then
                        updateToggle()
                    end
                end
            }
            
            table.insert(tab.Elements, toggleObj)
            return toggleObj
        end
        
        function sectionMethods:AddSlider(config)
            config = config or {}
            local sliderText = config.Text or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local callback = config.Callback or function() end
            
            -- Validate and adjust default value
            default = math.max(min, math.min(max, default))
            
            -- Create slider frame
            local sliderFrame = createInstance("Frame", {
                Name = sliderText .. "Slider",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 45),
                Parent = sectionContent
            })
            
            -- Slider text
            local sliderLabel = createInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 0, 20),
                Font = Enum.Font.SourceSans,
                Text = sliderText,
                TextColor3 = TEXT_COLOR,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sliderFrame
            })
            
            -- Slider value text
            local valueLabel = createInstance("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 0),
                Size = UDim2.new(0, 50, 0, 20),
                Font = Enum.Font.SourceSans,
                Text = tostring(default),
                TextColor3 = TEXT_COLOR,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = sliderFrame
            })
            
            -- Slider background
            local sliderBg = createInstance("Frame", {
                Name = "Background",
                BackgroundColor3 = SECONDARY_COLOR,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 10),
                Parent = sliderFrame
            })
            
            -- Add corner radius
            local bgCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = sliderBg
            })
            
            -- Slider fill
            local sliderFill = createInstance("Frame", {
                Name = "Fill",
                BackgroundColor3 = DEFAULT_COLOR,
                BorderSizePixel = 0,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                Parent = sliderBg
            })
            
            -- Add corner radius to fill
            local fillCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = sliderFill
            })
            
            -- Slider button
            local sliderButton = createInstance("TextButton", {
                Name = "Button",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = sliderBg
            })
            
            -- Current value
            local sliderValue = default
            
            -- Update slider function
            local function updateSlider(input)
                local sizeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                
                -- Calculate value based on min/max
                local calculatedValue = min + ((max - min) * sizeX)
                sliderValue = math.floor(calculatedValue)
                valueLabel.Text = tostring(sliderValue)
                
                callback(sliderValue)
            end
            
            -- Mouse held down
            local held = false
            
            -- Connect events
            sliderButton.MouseButton1Down:Connect(function(input)
                held = true
                updateSlider(input)
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    held = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if held and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            local sliderObj = {
                Frame = sliderFrame,
                Label = sliderLabel,
                Value = sliderValue,
                Background = sliderBg,
                Fill = sliderFill,
                Type = "Slider",
                SetValue = function(self, value)
                    value = math.max(min, math.min(max, value))
                    sliderValue = value
                    valueLabel.Text = tostring(value)
                    sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    callback(value)
                end
            }
            
            table.insert(tab.Elements, sliderObj)
            return sliderObj
        end
        
        function sectionMethods:AddDropdown(config)
            config = config or {}
            local dropdownText = config.Text or "Dropdown"
            local options = config.Options or {}
            local default = config.Default
            local callback = config.Callback or function() end
            
            -- Create dropdown frame
            local dropdownFrame = createInstance("Frame", {
                Name = dropdownText .. "Dropdown",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 55),
                ClipsDescendants = true,
                Parent = sectionContent
            })
            
            -- Dropdown text
            local dropdownLabel = createInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.SourceSans,
                Text = dropdownText,
                TextColor3 = TEXT_COLOR,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownFrame
            })
            
            -- Dropdown button
            local dropdownButton = createInstance("TextButton", {
                Name = "Button",
                BackgroundColor3 = SECONDARY_COLOR,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.SourceSans,
                Text = "",
                AutoButtonColor = false,
                Parent = dropdownFrame
            })
            
            -- Add corner radius
            local buttonCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = dropdownButton
            })
            
            -- Selected value text
            local selectedText = createInstance("TextLabel", {
                Name = "Selected",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = default or "Select...",
                TextColor3 = TEXT_COLOR,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownButton
            })
            
            -- Dropdown arrow
            local dropdownArrow = createInstance("ImageLabel", {
                Name = "Arrow",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://6031091004",
                ImageColor3 = TEXT_COLOR,
                Parent = dropdownButton
            })
            
            -- Dropdown items container
            local itemsContainer = createInstance("Frame", {
                Name = "Items",
                BackgroundColor3 = SECONDARY_COLOR,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 5),
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                Parent = dropdownButton
            })
            
            -- Add corner radius
            local containerCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = itemsContainer
            })
            
            -- Add layout for items
            local itemsLayout = createInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
                Parent = itemsContainer
            })
            
            -- Add padding
            local itemsPadding = createInstance("UIPadding", {
                PaddingTop = UDim.new(0, 2),
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                Parent = itemsContainer
            })
            
            -- Current state
            local isOpen = false
            local selectedOption = default
            
            -- Open/close function
            local function toggleDropdown()
                isOpen = not isOpen
                
                if isOpen then
                    itemsContainer.Visible = true
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 55 + itemsContainer.AbsoluteSize.Y)
                    dropdownArrow.Rotation = 180
                else
                    itemsContainer.Visible = false
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 55)
                    dropdownArrow.Rotation = 0
                end
            end
            
            -- Connect button
            dropdownButton.MouseButton1Click:Connect(toggleDropdown)
            
            -- Add options
            for i, option in pairs(options) do
                local itemButton = createInstance("TextButton", {
                    Name = option .. "Item",
                    BackgroundColor3 = option == default and DEFAULT_COLOR or SECONDARY_COLOR,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -4, 0, 24),
                    Font = Enum.Font.SourceSans,
                    Text = option,
                    TextColor3 = TEXT_COLOR,
                    TextSize = 14,
                    Parent = itemsContainer
                })
                
                -- Add corner radius
                local itemCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = itemButton
                })
                
                -- Item interactions
                itemButton.MouseEnter:Connect(function()
                    if option ~= selectedOption then
                        itemButton.BackgroundColor3 = HOVER_COLOR
                    end
                end)
                
                itemButton.MouseLeave:Connect(function()
                    if option ~= selectedOption then
                        itemButton.BackgroundColor3 = SECONDARY_COLOR
                    end
                end)
                
                itemButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    selectedText.Text = option
                    
                    -- Update item colors
                    for _, item in pairs(itemsContainer:GetChildren()) do
                        if item:IsA("TextButton") then
                            item.BackgroundColor3 = item.Text == option and DEFAULT_COLOR or SECONDARY_COLOR
                        end
                    end
                    
                    toggleDropdown()
                    callback(option)
                end)
            end
            
            -- Update container size based on content
            itemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                itemsContainer.Size = UDim2.new(1, 0, 0, itemsLayout.AbsoluteContentSize.Y + 4)
                
                if isOpen then
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 55 + itemsContainer.AbsoluteSize.Y)
                end
            end)
            
            local dropdownObj = {
                Frame = dropdownFrame,
                Label = dropdownLabel,
                Button = dropdownButton,
                Container = itemsContainer,
                Selected = selectedOption,
                Type = "Dropdown",
                SetValue = function(self, value)
                    -- Only set if the value exists in options
                    for _, option in pairs(options) do
                        if option == value then
                            selectedOption = value
                            selectedText.Text = value
                            
                            -- Update item colors
                            for _, item in pairs(itemsContainer:GetChildren()) do
                                if item:IsA("TextButton") then
                                    item.BackgroundColor3 = item.Text == value and DEFAULT_COLOR or SECONDARY_COLOR
                                end
                            end
                            
                            callback(value)
                            return
                        end
                    end
                end,
                AddOption = function(self, option)
                    -- Check if option already exists
                    for _, item in pairs(itemsContainer:GetChildren()) do
                        if item:IsA("TextButton") and item.Text == option then
                            return
                        end
                    end
                    
                    table.insert(options, option)
                    
                    local itemButton = createInstance("TextButton", {
                        Name = option .. "Item",
                        BackgroundColor3 = option == selectedOption and DEFAULT_COLOR or SECONDARY_COLOR,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -4, 0, 24),
                        Font = Enum.Font.SourceSans,
                        Text = option,
                        TextColor3 = TEXT_COLOR,
                        TextSize = 14,
                        Parent = itemsContainer
                    })
                    
                    -- Add corner radius
                    local itemCorner = createInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = itemButton
                    })
                    
                    -- Item interactions
                    itemButton.MouseEnter:Connect(function()
                        if option ~= selectedOption then
                            itemButton.BackgroundColor3 = HOVER_COLOR
                        end
                    end)
                    
                    itemButton.MouseLeave:Connect(function()
                        if option ~= selectedOption then
                            itemButton.BackgroundColor3 = SECONDARY_COLOR
                        end
                    end)
                    
                    itemButton.MouseButton1Click:Connect(function()
                        selectedOption = option
                        selectedText.Text = option
                        
                        -- Update item colors
                        for _, item in pairs(itemsContainer:GetChildren()) do
                            if item:IsA("TextButton") then
                                item.BackgroundColor3 = item.Text == option and DEFAULT_COLOR or SECONDARY_COLOR
                            end
                        end
                        
                        toggleDropdown()
                        callback(option)
                    end)
                end
            }
            
            table.insert(tab.Elements, dropdownObj)
            return dropdownObj
        end
        
        return sectionMethods
    end
    
    return tabMethods
end

-- Create a notification system
function UI:Notify(title, text, duration)
    duration = duration or 3
    
    -- Create notification
    local notification = createInstance("Frame", {
        Name = "Notification",
        BackgroundColor3 = BACKGROUND_COLOR,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -20, 1, -20),
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(0, 250, 0, 80),
        Parent = self.ScreenGui
    })
    
    -- Add corner radius
    local notifCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notification
    })
    
    -- Add shadow
    local shadow = createInstance("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 24, 1, 24),
        ZIndex = -1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = notification
    })
    
    -- Title
    local titleLabel = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -30, 0, 22),
        Font = Enum.Font.SourceSansBold,
        Text = title,
        TextColor3 = self.AccentColor,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    -- Text
    local textLabel = createInstance("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 36),
        Size = UDim2.new(1, -30, 0, 34),
        Font = Enum.Font.SourceSans,
        Text = text,
        TextColor3 = TEXT_COLOR,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notification
    })
    
    -- Progress bar
    local progressBar = createInstance("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = self.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = notification
    })
    
    -- Animation
    notification.Position = UDim2.new(1, 300, 1, -20)
    local showTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 1, -20)})
    showTween:Play()
    
    -- Progress bar animation
    local barTween = TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)})
    barTween:Play()
    
    -- Close animation
    local function closeNotif()
        local hideTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, 300, 1, -20)})
        hideTween:Play()
        hideTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end
    
    -- Close after duration
    delay(duration, closeNotif)
    
    return notification
end

-- Create the SimpleUI object
function SimpleUI:Initialize()
    return SimpleUI.new
end

-- Example usage:
local MyUI = SimpleUI:Initialize()("My Awesome UI")

-- Main tab
local MainTab = MyUI:AddTab("Main")
local MainSection = MainTab:AddSection("Game Settings")

-- Add toggle
MainSection:AddToggle({
    Text = "Enable Walkspeed",
    Default = false,
    Callback = function(value)
        print("Walkspeed enabled:", value)
        -- Set walkspeed code would go here
    end
})

-- Add slider
MainSection:AddSlider({
    Text = "Walkspeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(value)
        print("Setting walkspeed to:", value)
        -- Set walkspeed value code would go here
    end
})

-- Visual tab
local VisualTab = MyUI:AddTab("Visuals")
local ESPSection = VisualTab:AddSection("ESP Settings")

ESPSection:AddToggle({
    Text = "Enable ESP",
    Default = false,
    Callback = function(value)
        print("ESP enabled:", value)
    end
})

ESPSection:AddToggle({
    Text = "Show Names",
    Default = true,
    Callback = function(value)
        print("ESP names enabled:", value)
    end
})

-- Players tab
local PlayersTab = MyUI:AddTab("Players")
local PlayerSection = PlayersTab:AddSection("Player Selection")

-- Add dropdown
local playerDropdown = PlayerSection:AddDropdown({
    Text = "Select Player",
    Options = {},
    Callback = function(selected)
        print("Selected player:", selected)
    end
})

-- Update player list
local function UpdatePlayerList()
    -- Get all players
    local players = {}
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    
    -- Add players to dropdown
    for _, playerName in pairs(players) do
        playerDropdown:AddOption(playerName)
    end
end

-- Initial update
UpdatePlayerList()

-- Add buttons
PlayerSection:AddButton({
    Text = "Teleport to Player",
    Callback = function()
        if playerDropdown.Selected then
            print("Teleporting to:", playerDropdown.Selected)
            -- Teleport code would go here
        end
    end
})

PlayerSection:AddButton({
    Text = "Spectate Player",
    Callback = function()
        if playerDropdown.Selected then
            print("Spectating:", playerDropdown.Selected)
            -- Spectate code would go here
        end
    end
})

-- Settings tab
local SettingsTab = MyUI:AddTab("Settings")
local UISettings = SettingsTab:AddSection("UI Settings")

-- Color picker (implemented as buttons for simplicity)
UISettings:AddButton({
    Text = "UI Color: Blue",
    Callback = function()
        MyUI:SetAccentColor(Color3.fromRGB(80, 120, 255))
        MyUI:Notify("Color Changed", "UI color set to Blue", 2)
    end
})

UISettings:AddButton({
    Text = "UI Color: Green",
    Callback = function()
        MyUI:SetAccentColor(Color3.fromRGB(80, 255, 120))
        MyUI:Notify("Color Changed", "UI color set to Green", 2)
    end
})

UISettings:AddButton({
    Text = "UI Color: Red",
    Callback = function()
        MyUI:SetAccentColor(Color3.fromRGB(255, 80, 80))
        MyUI:Notify("Color Changed", "UI color set to Red", 2)
    end
})

-- Close UI button
UISettings:AddButton({
    Text = "Close UI",
    Callback = function()
        MyUI.ScreenGui:Destroy()
    end
})

-- Show a notification
MyUI:Notify("Welcome", "UI has been loaded successfully!", 3)

-- Load the SimpleUI library from GitHub
local SimpleUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/vertb1/ada/refs/heads/main/cypher.lua"))():Initialize()

-- Create a modernized UI
local ModernUI = SimpleUI("Modern Hub", {
    size = UDim2.new(0, 500, 0, 350) -- Larger UI for better appearance
})

-- Set a modern purple accent color
ModernUI:SetAccentColor(Color3.fromRGB(131, 81, 255))

-- Create Main tab
local MainTab = ModernUI:AddTab("Main")
local MovementSection = MainTab:AddSection("Movement")
local CombatSection = MainTab:AddSection("Combat")

-- Create a keybind system
local keybinds = {}

-- Function to handle keybinds
local function setupKeybind(name, defaultKey, callback)
    keybinds[name] = {
        key = defaultKey,
        enabled = false,
        callback = callback
    }
    
    -- Monitor key presses
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode.Name == keybinds[name].key and keybinds[name].enabled then
            keybinds[name].callback()
        end
    end)
    
    return keybinds[name]
end

-- Create a color picker function (using dropdown + buttons to simulate a color picker)
local function createColorPicker(section, name, defaultColor, callback)
    local colorOptions = {
        "Red", "Green", "Blue", "Purple", "Pink", 
        "Orange", "Yellow", "Cyan", "White", "Black"
    }
    
    local colorValues = {
        Red = Color3.fromRGB(255, 0, 0),
        Green = Color3.fromRGB(0, 255, 0),
        Blue = Color3.fromRGB(0, 0, 255),
        Purple = Color3.fromRGB(131, 81, 255),
        Pink = Color3.fromRGB(255, 0, 255),
        Orange = Color3.fromRGB(255, 165, 0),
        Yellow = Color3.fromRGB(255, 255, 0),
        Cyan = Color3.fromRGB(0, 255, 255),
        White = Color3.fromRGB(255, 255, 255),
        Black = Color3.fromRGB(0, 0, 0)
    }
    
    local selectedColor = defaultColor
    
    -- Add the color picker section
    local colorFrame = section:AddDropdown({
        Text = name,
        Options = colorOptions,
        Callback = function(selectedOption)
            selectedColor = colorValues[selectedOption]
            callback(selectedColor)
            ModernUI:Notify("Color Changed", "Set to " .. selectedOption, 1.5)
        end
    })
    
    return {
        SetColor = function(color)
            -- Find closest named color
            local closestName = "Red"
            local closestDistance = math.huge
            
            for name, value in pairs(colorValues) do
                local dist = (value.R - color.R)^2 + (value.G - color.G)^2 + (value.B - color.B)^2
                if dist < closestDistance then
                    closestDistance = dist
                    closestName = name
                end
            end
            
            colorFrame:SetValue(closestName)
            callback(colorValues[closestName])
        end
    }
end

-- Create a key picker function
local function createKeyPicker(section, name, defaultKey, callback)
    local keyPickerToggle = section:AddToggle({
        Text = name .. " [" .. defaultKey .. "]",
        Default = false,
        Callback = function(value)
            keybinds[name].enabled = value
            callback(value)
        end
    })
    
    -- Add a button to change the key
    section:AddButton({
        Text = "Change " .. name .. " Key",
        Callback = function()
            keyPickerToggle.Label.Text = name .. " [Press any key...]"
            
            local connection
            connection = game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local keyName = input.KeyCode.Name
                    keybinds[name].key = keyName
                    keyPickerToggle.Label.Text = name .. " [" .. keyName .. "]"
                    ModernUI:Notify("Keybind Changed", name .. " is now bound to " .. keyName, 2)
                    connection:Disconnect()
                end
            end)
        end
    })
    
    -- Set up the keybind
    setupKeybind(name, defaultKey, function()
        -- This function will be called when the key is pressed
        print(name .. " keybind activated")
    end)
    
    return keyPickerToggle
end

-- Movement settings
MovementSection:AddToggle({
    Text = "Speed Hack",
    Default = false,
    Callback = function(value)
        -- Add speed hack functionality
        ModernUI:Notify("Speed Hack", value and "Enabled" or "Disabled", 2)
    end
})

-- Create a slider for speed
local speedSlider = MovementSection:AddSlider({
    Text = "Speed Value",
    Min = 16,
    Max = 150,
    Default = 16,
    Callback = function(value)
        -- Speed functionality
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

-- Create a keybind for speed toggle
createKeyPicker(MovementSection, "Speed Toggle", "LeftShift", function(enabled)
    -- This gets called when the toggle is clicked
    if enabled then
        ModernUI:Notify("Speed Keybind", "Activated with LeftShift", 2)
    else
        ModernUI:Notify("Speed Keybind", "Deactivated", 2)
    end
})

-- Create a keybind for jump
createKeyPicker(MovementSection, "Super Jump", "Space", function(enabled)
    if enabled then
        ModernUI:Notify("Super Jump", "Activated with Space", 2)
    else
        ModernUI:Notify("Super Jump", "Deactivated", 2)
    end
})

-- Combat settings
CombatSection:AddToggle({
    Text = "Aimbot",
    Default = false,
    Callback = function(value)
        ModernUI:Notify("Aimbot", value and "Enabled" or "Disabled", 2)
    end
})

-- Visual tab
local VisualTab = ModernUI:AddTab("Visuals")
local ESPSection = VisualTab:AddSection("ESP Settings")
local WorldSection = VisualTab:AddSection("World Visuals")

-- ESP settings
local espToggle = ESPSection:AddToggle({
    Text = "ESP Master Toggle",
    Default = false,
    Callback = function(value)
        ModernUI:Notify("ESP", value and "Enabled" or "Disabled", 2)
    end
})

ESPSection:AddToggle({
    Text = "Show Names",
    Default = true,
    Callback = function(value)
        -- Names ESP functionality
    end
})

ESPSection:AddToggle({
    Text = "Show Boxes",
    Default = true,
    Callback = function(value)
        -- Box ESP functionality
    end
})

ESPSection:AddToggle({
    Text = "Show Health",
    Default = true,
    Callback = function(value)
        -- Health ESP functionality
    end
})

-- Color picker for ESP
createColorPicker(ESPSection, "ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    -- Update ESP color
    print("ESP color set to", tostring(color))
})

-- World settings
WorldSection:AddToggle({
    Text = "Fullbright",
    Default = false,
    Callback = function(value)
        if value then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").GlobalShadows = false
        else
            game:GetService("Lighting").Brightness = 1
            game:GetService("Lighting").GlobalShadows = true
        end
    end
})

-- Color picker for UI theme
createColorPicker(WorldSection, "UI Theme Color", Color3.fromRGB(131, 81, 255), function(color)
    ModernUI:SetAccentColor(color)
end)

-- Players tab
local PlayersTab = ModernUI:AddTab("Players")
local PlayerSection = PlayersTab:AddSection("Player Selection")

-- Add dropdown
local playerDropdown = PlayerSection:AddDropdown({
    Text = "Select Player",
    Options = {},
    Callback = function(selected)
        ModernUI:Notify("Player Selected", selected, 2)
    end
})

-- Update player list
local function UpdatePlayerList()
    -- Get all players
    local players = {}
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    
    -- Add players to dropdown
    for _, playerName in pairs(players) do
        playerDropdown:AddOption(playerName)
    end
end

-- Initial update
UpdatePlayerList()

-- Add player actions
PlayerSection:AddButton({
    Text = "Teleport to Player",
    Callback = function()
        if playerDropdown.Selected then
            local targetPlayer = game:GetService("Players"):FindFirstChild(playerDropdown.Selected)
            if targetPlayer and targetPlayer.Character then
                game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(
                    targetPlayer.Character.PrimaryPart.CFrame
                )
                ModernUI:Notify("Teleported", "Teleported to " .. playerDropdown.Selected, 2)
            end
        else
            ModernUI:Notify("Error", "No player selected", 2)
        end
    end
})

PlayerSection:AddButton({
    Text = "Spectate Player",
    Callback = function()
        if playerDropdown.Selected then
            ModernUI:Notify("Spectating", "Now spectating " .. playerDropdown.Selected, 2)
            -- Spectate code would go here
        else
            ModernUI:Notify("Error", "No player selected", 2)
        end
    end
})

-- Settings tab
local SettingsTab = ModernUI:AddTab("Settings")
local UISettings = SettingsTab:AddSection("UI Settings")

-- Add toggles for UI settings
UISettings:AddToggle({
    Text = "Show Keybind List",
    Default = true,
    Callback = function(value)
        -- Toggle keybind list visibility
        ModernUI:Notify("Keybind List", value and "Shown" or "Hidden", 2)
    end
})

UISettings:AddToggle({
    Text = "Show Watermark",
    Default = true,
    Callback = function(value)
        -- Toggle watermark visibility
        ModernUI:Notify("Watermark", value and "Shown" or "Hidden", 2)
    end
})

UISettings:AddButton({
    Text = "Reset All Settings",
    Callback = function()
        ModernUI:Notify("Settings Reset", "All settings have been reset to default", 3)
        -- Reset all settings
    end
})

-- Show a welcome notification
ModernUI:Notify("Modern UI Loaded", "Welcome to the enhanced UI experience!", 3)
