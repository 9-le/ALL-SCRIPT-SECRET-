--[[
    Script: One Tap FPS | V2
    Created by: 9.le
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "One Tap FPS | V2",
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "by 9.le",
   Theme = "Default",
   KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local AimbotEnabled, WallCheckEnabled, ESPEnabled = false, false, false
local FOVRadius = 100

-- POV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- ESP Function
local function applyESP(player)
    if player == LocalPlayer then return end
    local function createHighlight()
        if player.Character then
            if player.Character:FindFirstChild("9le_ESP") then player.Character["9le_ESP"]:Destroy() end
            local h = Instance.new("Highlight", player.Character)
            h.Name = "9le_ESP"
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.2
            h.OutlineTransparency = 0
            h.Adornee = player.Character
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
    createHighlight()
    player.CharacterAdded:Connect(function() task.wait(0.5) if ESPEnabled then createHighlight() end end)
end

-- Tabs
local TabAimbot = Window:CreateTab("Aimbot", "crosshair")
local TabESP = Window:CreateTab("ESP", "eye")
local TabDiscord = Window:CreateTab("Discord", "link")

-- Aimbot Tab
TabAimbot:CreateToggle({Name = "Enable Aimbot", CurrentValue = false, Callback = function(v) AimbotEnabled = v end})
TabAimbot:CreateToggle({Name = "Show POV", CurrentValue = false, Callback = function(v) FOVCircle.Visible = v end})
TabAimbot:CreateSlider({Name = "POV Size", Range = {10, 800}, Increment = 10, CurrentValue = 100, Callback = function(v) FOVRadius = v FOVCircle.Radius = v end})
TabAimbot:CreateToggle({Name = "Wall Check", CurrentValue = false, Callback = function(v) WallCheckEnabled = v end})

-- ESP Tab
TabESP:CreateToggle({
   Name = "Enable ESP",
   CurrentValue = false,
   Callback = function(v)
      ESPEnabled = v
      for _, p in pairs(Players:GetPlayers()) do
         if v then applyESP(p) else if p.Character and p.Character:FindFirstChild("9le_ESP") then p.Character["9le_ESP"]:Destroy() end end
      end
   end
})

-- Discord Tab
TabDiscord:CreateParagraph({Title = "Discord Server", Content = "Join our community for updates and support:\nhttps://discord.gg/hQNsp6MzR"})
TabDiscord:CreateButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/hQNsp6MzR")
        Rayfield:Notify({Title = "Copied", Content = "Discord link copied to clipboard!", Duration = 3})
    end
})

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local closest, dist = nil, math.huge
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local pos, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if on and d < FOVRadius then
                    if WallCheckEnabled then
                        local ray = Ray.new(Camera.CFrame.Position, (p.Character.Head.Position - Camera.CFrame.Position).Unit * 1000)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                        if hit and hit:IsDescendantOf(p.Character) and d < dist then dist = d closest = p end
                    elseif d < dist then dist = d closest = p end
                end
            end
        end
        if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position) end
    end
end)

