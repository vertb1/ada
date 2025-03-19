local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Clear any previous ESP
for i,v in pairs(getgenv()) do
    if tostring(i):find("ESP") then
        getgenv()[i] = nil
    end
end

local SimpleESP = {}
SimpleESP.Objects = {}
SimpleESP.Settings = {
    Enabled = true,
    TeamCheck = false,  -- Set to false to show teammates
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowBox = true,
    ShowTracer = true,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    TracerThickness = 1,
    BoxThickness = 1,
    MaxDistance = 1000
}

function SimpleESP:CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {}
    
    -- Create visual elements
    esp.Name = Drawing.new("Text")
    esp.Name.Visible = false
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Size = SimpleESP.Settings.TextSize
    esp.Name.Color = SimpleESP.Settings.TextColor
    esp.Name.Font = 2
    
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Color = SimpleESP.Settings.BoxColor
    esp.Box.Thickness = SimpleESP.Settings.BoxThickness
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Visible = false
    esp.Tracer.Color = SimpleESP.Settings.TracerColor
    esp.Tracer.Thickness = SimpleESP.Settings.TracerThickness
    esp.Tracer.Transparency = 1
    
    SimpleESP.Objects[player] = esp
    print("Created ESP for: " .. player.Name)
    
    -- When player leaves
    player.CharacterRemoving:Connect(function()
        SimpleESP:RemoveESP(player)
    end)
    
    return esp
end

function SimpleESP:RemoveESP(player)
    local esp = SimpleESP.Objects[player]
    if not esp then return end
    
    -- Remove all drawings
    for _, drawing in pairs(esp) do
        if drawing.Remove then
            drawing:Remove()
        end
    end
    
    SimpleESP.Objects[player] = nil
    print("Removed ESP for: " .. player.Name)
end

function SimpleESP:UpdateESP()
    for player, esp in pairs(SimpleESP.Objects) do
        if not SimpleESP.Settings.Enabled then
            esp.Name.Visible = false
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            continue
        end
        
        local character = player.Character
        if not character then
            esp.Name.Visible = false
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            continue
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart or not humanoid then
            esp.Name.Visible = false
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            continue
        end
        
        -- Check if player is teammate
        if SimpleESP.Settings.TeamCheck and player.Team == LocalPlayer.Team then
            esp.Name.Visible = false
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            continue
        end
        
        -- Calculate distance
        local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
        if distance > SimpleESP.Settings.MaxDistance then
            esp.Name.Visible = false
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            continue
        end
        
        -- Get screen position
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if not onScreen then
            esp.Name.Visible = false
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            continue
        end
        
        -- Update name text
        if SimpleESP.Settings.ShowName then
            local text = player.Name
            if SimpleESP.Settings.ShowDistance then
                text = text .. " [" .. math.floor(distance) .. "]"
            end
            if SimpleESP.Settings.ShowHealth and humanoid then
                text = text .. " [" .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth) .. "]"
            end
            
            esp.Name.Text = text
            esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 40)
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        -- Update box
        if SimpleESP.Settings.ShowBox then
            local size = Vector2.new(2000 / distance, 3000 / distance)
            esp.Box.Size = size
            esp.Box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        -- Update tracer
        if SimpleESP.Settings.ShowTracer then
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            esp.Tracer.Visible = true
        else
            esp.Tracer.Visible = false
        end
    end
end

-- Create ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        SimpleESP:CreateESP(player)
    end
end

-- Create ESP for new players
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        SimpleESP:CreateESP(player)
    end
end)

-- Remove ESP when player leaves
Players.PlayerRemoving:Connect(function(player)
    SimpleESP:RemoveESP(player)
end)

-- Update ESP
RunService:BindToRenderStep("SimpleESP", 1, function()
    SimpleESP:UpdateESP()
end)

-- Toggle ESP
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightAlt then
        SimpleESP.Settings.Enabled = not SimpleESP.Settings.Enabled
        print("ESP " .. (SimpleESP.Settings.Enabled and "Enabled" or "Disabled"))
    end
end)

print("Simple ESP Loaded!")
return SimpleESP
