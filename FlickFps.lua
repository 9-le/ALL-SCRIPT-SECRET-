-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Main Window
local Window = Rayfield:CreateWindow({
   Name = "Rt hub | by 9.le",
   LoadingTitle = "Loading Rt hub...",
   LoadingSubtitle = "by 9.le",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, 
      FileName = "Rthub"
   },
   Discord = {
      Enabled = true,
      Invite = "UScTdfCCs", 
      RememberJoins = true 
   },
   KeySystem = false
})

-- Core Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Control Variables
local AimbotEnabled = false
local ShowPOV = false
local POVSize = 100
local WallCheck = false
local ESPEnabled = false

-- POV (FOV) Circle Setup
local POVCircle = Drawing.new("Circle")
POVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
POVCircle.Radius = POVSize
POVCircle.Filled = false
POVCircle.Color = Color3.fromRGB(255, 255, 255)
POVCircle.Visible = false
POVCircle.Thickness = 1.5

---------------------------------------------------------
-- TAB 1: AIMBOT
---------------------------------------------------------
local AimbotTab = Window:CreateTab("Aimbot", 4483362458) 

AimbotTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
        AimbotEnabled = Value
   end,
})

AimbotTab:CreateToggle({
   Name = "Show POV",
   CurrentValue = false,
   Flag = "POVToggle",
   Callback = function(Value)
        ShowPOV = Value
   end,
})

AimbotTab:CreateSlider({
   Name = "POV Size",
   Range = {10, 800},
   Increment = 1,
   Suffix = "Radius",
   CurrentValue = 100,
   Flag = "POVSlider",
   Callback = function(Value)
        POVSize = Value
   end,
})

AimbotTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = false,
   Flag = "WallCheckToggle",
   Callback = function(Value)
        WallCheck = Value
   end,
})

---------------------------------------------------------
-- TAB 2: ESP
---------------------------------------------------------
local ESPTab = Window:CreateTab("ESP", 4483362458) 

ESPTab:CreateToggle({
   Name = "Enable ESP (Red Highlight)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
        ESPEnabled = Value
        
        -- Clear ESP immediately if toggled off
        if not ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Highlight_ESP") then
                    player.Character.Highlight_ESP:Destroy()
                end
            end
        end
   end,
})

---------------------------------------------------------
-- TAB 3: DISCORD
---------------------------------------------------------
local DiscordTab = Window:CreateTab("Discord", 4483362458) 

DiscordTab:CreateButton({
   Name = "Copy Discord Link",
   Callback = function()
        -- Copy the link to clipboard
        if setclipboard then
            setclipboard("https://discord.gg/UScTdfCCs")
            
            -- Show notification using Rayfield
            Rayfield:Notify({
               Title = "Discord Link Copied!",
               Content = "The invite link has been copied to your clipboard.",
               Duration = 5,
               Image = 4483362458,
            })
        else
            Rayfield:Notify({
               Title = "Error",
               Content = "Your executor does not support clipboard copying.",
               Duration = 5,
               Image = 4483362458,
            })
        end
   end,
})

---------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------

-- Wall Check Function
local function isVisible(targetPart)
    if not WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 2000
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, raycastParams)
    
    if result and result.Instance then
        if result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
    end
    return false
end

-- Get Closest Player in POV
local function getClosestPlayerInPOV()
    local closestPlayer = nil
    local shortestDistance = POVSize

    for i, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                
                if magnitude < shortestDistance then
                    if isVisible(v.Character.Head) then
                        closestPlayer = v
                        shortestDistance = magnitude
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Handle ESP Updates
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if ESPEnabled then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
                    local highlight = player.Character:FindFirstChild("Highlight_ESP")
                    
                    if not highlight then
                        -- Create Red Highlight
                        highlight = Instance.new("Highlight")
                        highlight.Name = "Highlight_ESP"
                        highlight.Parent = player.Character
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Makes it visible through walls
                    end
                end
            else
                -- Remove Highlight if ESP is off
                if player.Character and player.Character:FindFirstChild("Highlight_ESP") then
                    player.Character.Highlight_ESP:Destroy()
                end
            end
        end
    end
end

---------------------------------------------------------
-- MAIN LOOP
---------------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- Update POV Circle
    POVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    POVCircle.Radius = POVSize
    POVCircle.Visible = ShowPOV

    -- Run Aimbot
    if AimbotEnabled then
        local target = getClosestPlayerInPOV()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
    
    -- Run ESP
    updateESP()
end)
