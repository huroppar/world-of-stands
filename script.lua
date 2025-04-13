local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.8, 0)
button.Text = "空中浮遊！"
button.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
button.TextScaled = true

button.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    game:GetService("RunService").RenderStepped:Connect(function()
        hrp.Velocity = Vector3.new(0, 50, 0) -- 上方向に速度を加える
    end)
end)
