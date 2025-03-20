-- CypherLib.lua
-- UI Library based on Cypher design

local CypherLib = {}
CypherLib.__index = CypherLib

-- UI colors and styling
CypherLib.Colors = {
    Background = Color3.fromRGB(20, 20, 30),
    DarkBackground = Color3.fromRGB(15, 15, 25),
    Accent = Color3.fromRGB(90, 90, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(180, 180, 180),
    TabBackground = Color3.fromRGB(25, 25, 35),
    Toggle = Color3.fromRGB(60, 60, 80),
    ToggleEnabled = Color3.fromRGB(90, 90, 255),
    SliderBackground = Color3.fromRGB(40, 40, 50),
    SliderFill = Color3.fromRGB(90, 90, 255)
}

-- Configuration system
local ConfigSystem = {}

function ConfigSystem:SaveConfig(name)
    if not name then name = "default" end
    
    local config = {}
    for tabName, tab in pairs(self.Tabs) do
        config[tabName] = {}
        for _, element in pairs(tab.Elements) do
            if element.Type and element.Flag then
                config[tabName][element.Flag] = element.Value
            end
        end
    end
    
    writefile("CypherConfigs/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(config))
    return config
end

function ConfigSystem:LoadConfig(name)
    if not name then name = "default" end
    
    if not isfile("CypherConfigs/" .. name .. ".json") then
        return false
    end
    
    local config = game:GetService("HttpService"):JSONDecode(readfile("CypherConfigs/" .. name .. ".json"))
    
    for tabName, tabConfig in pairs(config) do
        if self.Tabs[tabName] then
            for flag, value in pairs(tabConfig) do
                for _, element in pairs(self.Tabs[tabName].Elements) do
                    if element.Flag == flag then
                        element:SetValue(value)
                    end
                end
            end
        end
    end
    
    return true
end

-- Create a new UI instance
function CypherLib.new(title)
    local self = setmetatable({}, CypherLib)
    
    -- Initialize properties
    self.Title = title or "CYPHER"
    self.Tabs = {}
    self.ActiveTab = nil
    
    -- Create main UI
    self:CreateMainUI()
    
    -- Add config system
    setmetatable(self, {__index = ConfigSystem})
    
    if not isfolder("CypherConfigs") then
        makefolder("CypherConfigs")
    end
    
    return self
end

function CypherLib:CreateMainUI()
    -- Main screen gui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CypherLib"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Dark background for drag detection
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 600, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.MainFrame.BackgroundColor3 = self.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    -- Make UI draggable
    self:MakeDraggable(self.MainFrame)
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = self.Colors.DarkBackground
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    -- Title text
    self.TitleText = Instance.new("TextLabel")
    self.TitleText.Name = "TitleText"
    self.TitleText.Size = UDim2.new(1, -10, 1, 0)
    self.TitleText.Position = UDim2.new(0, 10, 0, 0)
    self.TitleText.BackgroundTransparency = 1
    self.TitleText.TextColor3 = self.Colors.Text
    self.TitleText.TextSize = 18
    self.TitleText.Font = Enum.Font.SourceSansBold
    self.TitleText.Text = self.Title
    self.TitleText.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleText.Parent = self.TitleBar
    
    -- Close button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 24, 0, 24)
    self.CloseButton.Position = UDim2.new(1, -27, 0, 3)
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.TextColor3 = self.Colors.Text
    self.CloseButton.TextSize = 18
    self.CloseButton.Font = Enum.Font.SourceSansBold
    self.CloseButton.Text = "X"
    self.CloseButton.Parent = self.TitleBar
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)
    
    -- Tab container (left side)
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, -30)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundColor3 = self.Colors.TabBackground
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    
    -- Tab button list
    self.TabButtonList = Instance.new("ScrollingFrame")
    self.TabButtonList.Name = "TabButtonList"
    self.TabButtonList.Size = UDim2.new(1, 0, 1, 0)
    self.TabButtonList.BackgroundTransparency = 1
    self.TabButtonList.BorderSizePixel = 0
    self.TabButtonList.ScrollBarThickness = 0
    self.TabButtonList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.TabButtonList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabButtonList.Parent = self.TabContainer
    
    -- Tab content container (right side)
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -150, 1, -30)
    self.ContentContainer.Position = UDim2.new(0, 150, 0, 30)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.MainFrame
    
    -- Add search bar at the top
    self.SearchBar = Instance.new("TextBox")
    self.SearchBar.Name = "SearchBar"
    self.SearchBar.Size = UDim2.new(0.5, 0, 0, 24)
    self.SearchBar.Position = UDim2.new(0.25, 0, 0, 10)
    self.SearchBar.BackgroundColor3 = self.Colors.DarkBackground
    self.SearchBar.BorderSizePixel = 0
    self.SearchBar.TextColor3 = self.Colors.Text
    self.SearchBar.PlaceholderText = "Search"
    self.SearchBar.Text = ""
    self.SearchBar.TextSize = 14
    self.SearchBar.Font = Enum.Font.SourceSans
    self.SearchBar.Parent = self.ContentContainer
    
    -- Search icon
    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.Size = UDim2.new(0, 16, 0, 16)
    SearchIcon.Position = UDim2.new(1, -18, 0.5, -8)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxassetid://3926305904"
    SearchIcon.ImageRectOffset = Vector2.new(964, 324)
    SearchIcon.ImageRectSize = Vector2.new(36, 36)
    SearchIcon.Parent = self.SearchBar
    
    -- Parent the ScreenGui
    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = game.CoreGui
    elseif gethui then
        self.ScreenGui.Parent = gethui()
    else
        self.ScreenGui.Parent = game.CoreGui
    end
    
    return self
end

-- Make an object draggable
function CypherLib:MakeDraggable(frame)
    local dragToggle, dragInput, dragStart, startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
end

-- Create a new tab
function CypherLib:AddTab(name, icon)
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Button"
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.Position = UDim2.new(0, 0, 0, #self.Tabs * 40)
    tabButton.BackgroundTransparency = 1
    tabButton.BorderSizePixel = 0
    tabButton.TextColor3 = self.Colors.Text
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.SourceSans
    tabButton.Text = "   " .. name
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.Parent = self.TabButtonList
    
    -- Tab icon
    if icon then
        local iconImage = Instance.new("ImageLabel")
        iconImage.Name = "Icon"
        iconImage.Size = UDim2.new(0, 20, 0, 20)
        iconImage.Position = UDim2.new(0, 10, 0.5, -10)
        iconImage.BackgroundTransparency = 1
        iconImage.Image = icon
        iconImage.Parent = tabButton
        
        -- Adjust text position
        tabButton.Text = "      " .. name
    end
    
    -- Tab indicator
    local tabIndicator = Instance.new("Frame")
    tabIndicator.Name = "Indicator"
    tabIndicator.Size = UDim2.new(0, 2, 1, 0)
    tabIndicator.BackgroundColor3 = self.Colors.Accent
    tabIndicator.BorderSizePixel = 0
    tabIndicator.Visible = false
    tabIndicator.Parent = tabButton
    
    -- Tab content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, -50)
    tabContent.Position = UDim2.new(0, 0, 0, 50)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 2
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.Parent = self.ContentContainer
    tabContent.Visible = false
    
    -- Create tab padding and layout
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingLeft = UDim.new(0, 10)
    uiPadding.PaddingRight = UDim.new(0, 10)
    uiPadding.PaddingTop = UDim.new(0, 10)
    uiPadding.PaddingBottom = UDim.new(0, 10)
    uiPadding.Parent = tabContent
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0, 8)
    uiListLayout.Parent = tabContent
    
    -- Tab data
    local tab = {
        Name = name,
        Button = tabButton,
        Content = tabContent,
        Indicator = tabIndicator,
        Elements = {}
    }
    
    -- Add tab to tabs table
    self.Tabs[name] = tab
    
    -- Tab button click event
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    -- Select this tab if it's the first one
    if #self.Tabs == 1 then
        self:SelectTab(name)
    end
    
    -- Create element creation functions
    local elementFuncs = {}
    
    -- Create a toggle
    function elementFuncs:AddToggle(options)
        options = options or {}
        options.Name = options.Name or "Toggle"
        options.Flag = options.Flag or options.Name
        options.Default = options.Default or false
        
        -- Toggle container
        local toggleContainer = Instance.new("Frame")
        toggleContainer.Name = options.Name .. "Container"
        toggleContainer.Size = UDim2.new(1, 0, 0, 30)
        toggleContainer.BackgroundTransparency = 1
        toggleContainer.Parent = tabContent
        
        -- Toggle name
        local toggleName = Instance.new("TextLabel")
        toggleName.Name = "Name"
        toggleName.Size = UDim2.new(1, -50, 1, 0)
        toggleName.BackgroundTransparency = 1
        toggleName.TextColor3 = self.Colors.Text
        toggleName.TextSize = 14
        toggleName.Font = Enum.Font.SourceSans
        toggleName.Text = options.Name
        toggleName.TextXAlignment = Enum.TextXAlignment.Left
        toggleName.Parent = toggleContainer
        
        -- Toggle background
        local toggleBackground = Instance.new("Frame")
        toggleBackground.Name = "Background"
        toggleBackground.Size = UDim2.new(0, 40, 0, 20)
        toggleBackground.Position = UDim2.new(1, -45, 0.5, -10)
        toggleBackground.BackgroundColor3 = self.Colors.Toggle
        toggleBackground.BorderSizePixel = 0
        toggleBackground.Parent = toggleContainer
        
        -- Make corners round
        local cornerRadius = Instance.new("UICorner")
        cornerRadius.CornerRadius = UDim.new(1, 0)
        cornerRadius.Parent = toggleBackground
        
        -- Toggle indicator
        local toggleIndicator = Instance.new("Frame")
        toggleIndicator.Name = "Indicator"
        toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
        toggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
        toggleIndicator.BackgroundColor3 = self.Colors.Text
        toggleIndicator.BorderSizePixel = 0
        toggleIndicator.Parent = toggleBackground
        
        -- Make indicator round
        local indicatorRadius = Instance.new("UICorner")
        indicatorRadius.CornerRadius = UDim.new(1, 0)
        indicatorRadius.Parent = toggleIndicator
        
        -- Toggle functionality
        local toggle = {
            Type = "Toggle",
            Name = options.Name,
            Flag = options.Flag,
            Value = options.Default,
            Callback = options.Callback or function() end
        }
        
        -- Set initial state
        local function updateToggleVisual()
            if toggle.Value then
                toggleBackground.BackgroundColor3 = self.Colors.ToggleEnabled
                toggleIndicator:TweenPosition(UDim2.new(1, -18, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            else
                toggleBackground.BackgroundColor3 = self.Colors.Toggle
                toggleIndicator:TweenPosition(UDim2.new(0, 2, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            end
        end
        
        function toggle:SetValue(value)
            self.Value = value
            updateToggleVisual()
            self.Callback(value)
        end
        
        -- Toggle click event
        toggleBackground.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                toggle:SetValue(not toggle.Value)
            end
        end)
        
        -- Set initial state
        toggle:SetValue(options.Default)
        
        -- Add to elements
        tab.Elements[options.Name] = toggle
        
        return toggle
    end
    
    -- Create a slider
    function elementFuncs:AddSlider(options)
        options = options or {}
        options.Name = options.Name or "Slider"
        options.Flag = options.Flag or options.Name
        options.Min = options.Min or 0
        options.Max = options.Max or 100
        options.Default = options.Default or options.Min
        options.Increment = options.Increment or 1
        options.ValueName = options.ValueName or ""
        
        -- Slider container
        local sliderContainer = Instance.new("Frame")
        sliderContainer.Name = options.Name .. "Container"
        sliderContainer.Size = UDim2.new(1, 0, 0, 45)
        sliderContainer.BackgroundTransparency = 1
        sliderContainer.Parent = tabContent
        
        -- Slider name
        local sliderName = Instance.new("TextLabel")
        sliderName.Name = "Name"
        sliderName.Size = UDim2.new(1, 0, 0, 20)
        sliderName.BackgroundTransparency = 1
        sliderName.TextColor3 = self.Colors.Text
        sliderName.TextSize = 14
        sliderName.Font = Enum.Font.SourceSans
        sliderName.Text = options.Name
        sliderName.TextXAlignment = Enum.TextXAlignment.Left
        sliderName.Parent = sliderContainer
        
        -- Slider value
        local sliderValue = Instance.new("TextLabel")
        sliderValue.Name = "Value"
        sliderValue.Size = UDim2.new(0, 50, 0, 20)
        sliderValue.Position = UDim2.new(1, -50, 0, 0)
        sliderValue.BackgroundTransparency = 1
        sliderValue.TextColor3 = self.Colors.Text
        sliderValue.TextSize = 14
        sliderValue.Font = Enum.Font.SourceSans
        sliderValue.Text = tostring(options.Default) .. options.ValueName
        sliderValue.TextXAlignment = Enum.TextXAlignment.Right
        sliderValue.Parent = sliderContainer
        
        -- Slider background
        local sliderBackground = Instance.new("Frame")
        sliderBackground.Name = "Background"
        sliderBackground.Size = UDim2.new(1, 0, 0, 8)
        sliderBackground.Position = UDim2.new(0, 0, 0, 25)
        sliderBackground.BackgroundColor3 = self.Colors.SliderBackground
        sliderBackground.BorderSizePixel = 0
        sliderBackground.Parent = sliderContainer
        
        -- Make corners round
        local cornerRadius = Instance.new("UICorner")
        cornerRadius.CornerRadius = UDim.new(1, 0)
        cornerRadius.Parent = sliderBackground
        
        -- Slider fill
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "Fill"
        sliderFill.Size = UDim2.new(0, 0, 1, 0)
        sliderFill.BackgroundColor3 = self.Colors.SliderFill
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBackground
        
        -- Make fill corners round
        local fillRadius = Instance.new("UICorner")
        fillRadius.CornerRadius = UDim.new(1, 0)
        fillRadius.Parent = sliderFill
        
        -- Slider functionality
        local slider = {
            Type = "Slider",
            Name = options.Name,
            Flag = options.Flag,
            Value = options.Default,
            Min = options.Min,
            Max = options.Max,
            Increment = options.Increment,
            ValueName = options.ValueName,
            Callback = options.Callback or function() end
        }
        
        -- Function to update slider visuals
        local function updateSliderVisual()
            local percent = (slider.Value - slider.Min) / (slider.Max - slider.Min)
            sliderFill:TweenSize(UDim2.new(percent, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            sliderValue.Text = tostring(slider.Value) .. slider.ValueName
        end
        
        -- Set slider value
        function slider:SetValue(value)
            -- Clamp and round value
            value = math.clamp(value, self.Min, self.Max)
            value = math.floor(value / self.Increment + 0.5) * self.Increment
            
            self.Value = value
            updateSliderVisual()
            self.Callback(value)
        end
        
        -- Slider interaction
        sliderBackground.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local percent = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
                slider:SetValue(slider.Min + (slider.Max - slider.Min) * percent)
                
                -- Drag functionality
                local connection
                connection = game:GetService("UserInputService").InputChanged:Connect(function(dragInput)
                    if dragInput.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((dragInput.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
                        slider:SetValue(slider.Min + (slider.Max - slider.Min) * percent)
                    end
                end)
                
                game:GetService("UserInputService").InputEnded:Connect(function(dragEnd)
                    if dragEnd.UserInputType == Enum.UserInputType.MouseButton1 then
                        connection:Disconnect()
                    end
                end)
            end
        end)
        
        -- Set initial state
        slider:SetValue(options.Default)
        
        -- Add to elements
        tab.Elements[options.Name] = slider
        
        return slider
    end
    
    -- Create a dropdown
    function elementFuncs:AddDropdown(options)
        options = options or {}
        options.Name = options.Name or "Dropdown"
        options.Flag = options.Flag or options.Name
        options.Options = options.Options or {}
        options.Default = options.Default or (options.Options[1] or "")
        options.Callback = options.Callback or function() end
        
        -- Dropdown container
        local dropdownContainer = Instance.new("Frame")
        dropdownContainer.Name = options.Name .. "Container"
        dropdownContainer.Size = UDim2.new(1, 0, 0, 55)
        dropdownContainer.BackgroundTransparency = 1
        dropdownContainer.ClipsDescendants = true
        dropdownContainer.Parent = tabContent
        
        -- Dropdown name
        local dropdownName = Instance.new("TextLabel")
        dropdownName.Name = "Name"
        dropdownName.Size = UDim2.new(1, 0, 0, 20)
        dropdownName.BackgroundTransparency = 1
        dropdownName.TextColor3 = self.Colors.Text
        dropdownName.TextSize = 14
        dropdownName.Font = Enum.Font.SourceSans
        dropdownName.Text = options.Name
        dropdownName.TextXAlignment = Enum.TextXAlignment.Left
        dropdownName.Parent = dropdownContainer
        
        -- Dropdown button
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Name = "Button"
        dropdownButton.Size = UDim2.new(1, 0, 0, 30)
        dropdownButton.Position = UDim2.new(0, 0, 0, 25)
        dropdownButton.BackgroundColor3 = self.Colors.SliderBackground
        dropdownButton.BorderSizePixel = 0
        dropdownButton.TextColor3 = self.Colors.Text
        dropdownButton.TextSize = 14
        dropdownButton.Font = Enum.Font.SourceSans
        dropdownButton.Text = options.Default
        dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
        dropdownButton.TextTruncate = Enum.TextTruncate.AtEnd
        dropdownButton.Parent = dropdownContainer
        
        -- Add padding to button text
        local buttonPadding = Instance.new("UIPadding")
        buttonPadding.PaddingLeft = UDim.new(0, 10)
        buttonPadding.Parent = dropdownButton
        
        -- Dropdown arrow
        local dropdownArrow = Instance.new("TextLabel")
        dropdownArrow.Name = "Arrow"
        dropdownArrow.Size = UDim2.new(0, 20, 0, 20)
        dropdownArrow.Position = UDim2.new(1, -25, 0.5, -10)
        dropdownArrow.BackgroundTransparency = 1
        dropdownArrow.TextColor3 = self.Colors.Text
        dropdownArrow.TextSize = 14
        dropdownArrow.Font = Enum.Font.SourceSansBold
        dropdownArrow.Text = "▼"
        dropdownArrow.Parent = dropdownButton
        
        -- Dropdown list
        local dropdownList = Instance.new("Frame")
        dropdownList.Name = "List"
        dropdownList.Size = UDim2.new(1, 0, 0, 0)
        dropdownList.Position = UDim2.new(0, 0, 0, 55)
        dropdownList.BackgroundColor3 = self.Colors.SliderBackground
        dropdownList.BorderSizePixel = 0
        dropdownList.ClipsDescendants = true
        dropdownList.Visible = false
        dropdownList.Parent = dropdownContainer
        
        -- List layout
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = dropdownList
        
        -- Dropdown functionality
        local dropdown = {
            Type = "Dropdown",
            Name = options.Name,
            Flag = options.Flag,
            Value = options.Default,
            Options = options.Options,
            Callback = options.Callback,
            Open = false
        }
        
        -- Toggle dropdown
        function dropdown:Toggle()
            self.Open = not self.Open
            
            if self.Open then
                dropdownList.Visible = true
                dropdownContainer:TweenSize(UDim2.new(1, 0, 0, 55 + listLayout.AbsoluteContentSize.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
                dropdownList:TweenSize(UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
                dropdownArrow.Text = "▲"
            else
                dropdownContainer:TweenSize(UDim2.new(1, 0, 0, 55), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
                dropdownList:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true, function()
                    dropdownList.Visible = false
                end)
                dropdownArrow.Text = "▼"
            end
        end
        
        -- Set dropdown value
        function dropdown:SetValue(value)
            self.Value = value
            dropdownButton.Text = value
            self.Callback(value)
        end
        
        -- Create dropdown items
        function dropdown:RefreshOptions(options)
            -- Clear existing options
            for _, child in pairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Set new options
            self.Options = options or self.Options
            
            -- Create new option buttons
            for i, option in pairs(self.Options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = option
                optionButton.Size = UDim2.new(1, 0, 0, 25)
                optionButton.BackgroundTransparency = 1
                optionButton.TextColor3 = self.Colors.Text
                optionButton.TextSize = 14
                optionButton.Font = Enum.Font.SourceSans
                optionButton.Text = option
                optionButton.TextXAlignment = Enum.TextXAlignment.Left
                optionButton.Parent = dropdownList
                
                -- Add padding to option text
                local optionPadding = Instance.new("UIPadding")
                optionPadding.PaddingLeft = UDim.new(0, 10)
                optionPadding.Parent = optionButton
                
                -- Option button click event
                optionButton.MouseButton1Click:Connect(function()
                    dropdown:SetValue(option)
                    dropdown:Toggle()
                end)
            end
            
            -- Update dropdown list size if open
            if self.Open then
                dropdownContainer:TweenSize(UDim2.new(1, 0, 0, 55 + listLayout.AbsoluteContentSize.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
                dropdownList:TweenSize(UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            end
        end
        
        -- Dropdown button click event
        dropdownButton.MouseButton1Click:Connect(function()
            dropdown:Toggle()
        end)
        
        -- Initial options
        dropdown:RefreshOptions(options.Options)
        
        -- Set initial value
        dropdown:SetValue(options.Default)
        
        -- Add to elements
        tab.Elements[options.Name] = dropdown
        
        return dropdown
    end
    
    -- Create element creation functions
    return elementFuncs
end

-- Select a tab
function CypherLib:SelectTab(name)
    -- Deselect current tab
    if self.ActiveTab then
        self.Tabs[self.ActiveTab].Indicator.Visible = false
        self.Tabs[self.ActiveTab].Content.Visible = false
        self.Tabs[self.ActiveTab].Button.TextColor3 = self.Colors.Text
    end
    
    -- Select new tab
    self.ActiveTab = name
    self.Tabs[name].Indicator.Visible = true
    self.Tabs[name].Content.Visible = true
    self.Tabs[name].Button.TextColor3 = self.Colors.Accent
end

-- Return the UI library
return CypherLib 
