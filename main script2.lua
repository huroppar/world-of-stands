local player = game.Players.LocalPlayer  
local speedMax = 900  
local isSpeedEnabled = false  
local isInfiniteJumpEnabled = false  
local isWallPassEnabled = false  
local originalPosition = nil  
local isInAir = false  

local gui = Instance.new("ScreenGui")  
gui.Parent = player:WaitForChild("PlayerGui")  

-- スピード調整スライダー  
local speedSlider = Instance.new("Frame")  
speedSlider.Size = UDim2.new(0.5, 0, 0.1, 0)  
speedSlider.Position = UDim2.new(0.25, 0, 0.1, 0)  
speedSlider.BackgroundColor3 = Color3.new(1, 1, 1)  
speedSlider.Parent = gui  

local speedLabel = Instance.new("TextLabel")  
speedLabel.Size = UDim2.new(1, 0, 0.5, 0)  
speedLabel.Text = "Speed: 16"  
speedLabel.BackgroundColor3 = Color3.new(1, 0, 0)  
speedLabel.Parent = speedSlider  

local speedValue = Instance.new("TextBox")  
speedValue.Size = UDim2.new(0.5, 0, 0.5, 0)  
speedValue.Position = UDim2.new(0.25, 0, 0, 0)  
speedValue.Text = "16"  
speedValue.Parent = speedSlider  

-- スピード有効化ボタン  
local toggleSpeedButton = Instance.new("TextButton")  
toggleSpeedButton.Text = "Toggle Speed"  
toggleSpeedButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
toggleSpeedButton.Position = UDim2.new(0.25, 0, 0.22, 0)  
toggleSpeedButton.Parent = gui  

toggleSpeedButton.MouseButton1Click:Connect(function()  
    isSpeedEnabled = not isSpeedEnabled  
    if isSpeedEnabled then  
        player.Character.Humanoid.WalkSpeed = speedMax  
    else  
        player.Character.Humanoid.WalkSpeed = 16  
    end  
end)  

-- 無限ジャンプボタン  
local toggleJumpButton = Instance.new("TextButton")  
toggleJumpButton.Text = "Toggle Infinite Jump"  
toggleJumpButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
toggleJumpButton.Position = UDim2.new(0.25, 0, 0.34, 0)  
toggleJumpButton.Parent = gui  

toggleJumpButton.MouseButton1Click:Connect(function()  
    isInfiniteJumpEnabled = not isInfiniteJumpEnabled  
    if isInfiniteJumpEnabled then  
        local conn  
        conn = userInputService.JumpRequest:Connect(function()  
            if isInfiniteJumpEnabled then  
                player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)  
            end  
        end)  
    end  
end)  

-- 空中テレポート  
local teleportUpButton = Instance.new("TextButton")  
teleportUpButton.Text = "Teleport Up"  
teleportUpButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
teleportUpButton.Position = UDim2.new(0.25, 0, 0.46, 0)  
teleportUpButton.Parent = gui  

teleportUpButton.MouseButton1Click:Connect(function()  
    originalPosition = player.Character.HumanoidRootPart
