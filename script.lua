local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FloatGUI"

-- テレポートボタン
local teleportBtn = Instance.new("TextButton", gui)
teleportBtn.Size = UDim2.new(0, 200, 0, 50)
teleportBtn.Position = UDim2.new(0.5, -100, 0.75, 0)
teleportBtn.Text = "空中テレポート"
teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.TextScaled = true
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.BorderSizePixel = 0
teleportBtn.AutoButtonColor = true
teleportBtn.BackgroundTransparency = 0.1
teleportBtn.ZIndex = 2
teleportBtn.Active = true

-- 無限ジャンプボタン
local infJumpBtn = Instance.new("TextButton", gui)
infJumpBtn.Size = UDim2.new(0, 200, 0, 50)
infJumpBtn.Position = UDim2.new(0.5, -100, 0.85, 0)
infJumpBtn.Text = "無限ジャンプ ON"
infJumpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
infJumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
infJumpBtn.TextScaled = true
infJumpBtn.Font = Enum.Font.GothamBold
infJumpBtn.BorderSizePixel = 0
infJumpBtn.AutoButtonColor = true
infJumpBtn.BackgroundTransparency = 0.1
infJumpBtn.ZIndex = 2
infJumpBtn.Active = true

-- 📦 機能：空中テレポート
teleportBtn.MouseButton1Click:Connect(function()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.CFrame = hrp.CFrame + Vector3.new(0, 100, 0) -- 100スタッド上にテレポート
end)

-- 📦 機能：無限ジャンプ
local infJumpEnabled = true
local userInput = game:GetService("UserInputService")

userInput.JumpRequest:Connect(function()
    if infJumpEnabled then
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

infJumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        infJumpBtn.Text = "無限ジャンプ ON"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        infJumpBtn.Text = "無限ジャンプ OFF"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)
