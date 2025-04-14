local player = game.Players.LocalPlayer  
local userInputService = game:GetService("UserInputService")  

-- 初期設定  
local speedMax = 900  
local speedToggle = false  
local infiniteJumpEnabled = false  
local wallPassEnabled = false  
local originalPosition = nil  

-- GUIを作成  
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

-- スピード切替ボタン  
local toggleSpeedButton = Instance.new("TextButton")  
toggleSpeedButton.Text = "Toggle Speed"  
toggleSpeedButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
toggleSpeedButton.Position = UDim2.new(0.25, 0, 0.22, 0)  
toggleSpeedButton.Parent = gui  

toggleSpeedButton.MouseButton1Click:Connect(function()  
    speedToggle = not speedToggle  
    if speedToggle then  
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
    infiniteJumpEnabled = not infiniteJumpEnabled  
    if infiniteJumpEnabled then  
        local conn  
        conn = userInputService.JumpRequest:Connect(function()  
            if infiniteJumpEnabled then  
                player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)  
            end  
        end)  
    end  
end)  

-- 空中テレポートボタン  
local teleportUpButton = Instance.new("TextButton")  
teleportUpButton.Text = "Teleport Up"  
teleportUpButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
teleportUpButton.Position = UDim2.new(0.25, 0, 0.46, 0)  
teleportUpButton.Parent = gui  

teleportUpButton.MouseButton1Click:Connect(function()  
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then  
        originalPosition = player.Character.HumanoidRootPart.Position  
        player.Character.HumanoidRootPart.Position = Vector3.new(originalPosition.X, 5000, originalPosition.Z)  
    end  
end)  

-- 戻るボタン  
local returnButton = Instance.new("TextButton")  
returnButton.Text = "Return"  
returnButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
returnButton.Position = UDim2.new(0.25, 0, 0.58, 0)  
returnButton.Parent = gui  

returnButton.MouseButton1Click:Connect(function()  
    if originalPosition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then  
        player.Character.HumanoidRootPart.Position = originalPosition  
    end  
end)  
-- 壁貫通ボタン  
local toggleWallPassButton = Instance.new("TextButton")  
toggleWallPassButton.Text = "Toggle Wall Pass"  
toggleWallPassButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
toggleWallPassButton.Position = UDim2.new(0.25, 0, 0.70, 0)  
toggleWallPassButton.Parent = gui  

toggleWallPassButton.MouseButton1Click:Connect(function()  
    wallPassEnabled = not wallPassEnabled  
    if wallPassEnabled then  
        player.Character.HumanoidRootPart.CanCollide = false -- 壁を貫通  
    else  
        player.Character.HumanoidRootPart.CanCollide = true -- 通常の衝突  
    end  
end)  

-- 透明化状態を管理  
local isTransparent = false  

-- 透明化ボタン  
local toggleTransparencyButton = Instance.new("TextButton")  
toggleTransparencyButton.Text = "Toggle Transparency"  
toggleTransparencyButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
toggleTransparencyButton.Position = UDim2.new(0.25, 0, 0.82, 0)  
toggleTransparencyButton.Parent = gui  

toggleTransparencyButton.MouseButton1Click:Connect(function()  
    local character = player.Character  
    if character then  
        isTransparent = not isTransparent  
        for _, part in pairs(character:GetChildren()) do  
            if part:IsA("BasePart") then  
                part.Transparency = isTransparent and 0.5 or 0 -- 透明化  
                part.CanCollide = not isTransparent -- 衝突性の設定  
            end  
        end  
        
        -- ダメージ無効化  
        local humanoid = character:FindFirstChildOfClass("Humanoid")  
        if humanoid then  
            if isTransparent then  
                humanoid.HealthChanged:Connect(function()  
                    humanoid.Health = humanoid.Health + 100 -- ダメージを無効化するための補正  
                end)  
            else  
                -- 接続を解除するためには、何らかの方法で保持した接続を管理する必要があります  
            end  
        end  
    end  
end)  
-- プレイヤー一覧表示ボタン  
local showPlayerListButton = Instance.new("TextButton")  
showPlayerListButton.Text = "Show Player List"  
showPlayerListButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
showPlayerListButton.Position = UDim2.new(0.25, 0, 0.94, 0)  
showPlayerListButton.Parent = gui  

showPlayerListButton.MouseButton1Click:Connect(function()  
    local playerListFrame = Instance.new("Frame")  
    playerListFrame.Size = UDim2.new(0.3, 0, 0.5, 0)  
    playerListFrame.Position = UDim2.new(0.35, 0, 0.1, 0)  
    playerListFrame.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)  
    playerListFrame.Parent = gui  

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do  
        if otherPlayer ~= player then  
            local button = Instance.new("TextButton")  
            button.Size = UDim2.new(1, 0, 0.1, 0)  
            button.Text = otherPlayer.Name  
            button.Parent = playerListFrame  
            
            button.MouseButton1Click:Connect(function()  
                if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then  
                    player.Character.HumanoidRootPart.Position = otherPlayer.Character.HumanoidRootPart.Position  
                end  
            end)  
        end  
    end  
end)  

-- GUI表示・非表示切替ボタン  
local toggleGUIVisibilityButton = Instance.new("TextButton")  
toggleGUIVisibilityButton.Text = "Toggle GUI Visibility"  
toggleGUIVisibilityButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
toggleGUIVisibilityButton.Position = UDim2.new(0.25, 0, 1.06, 0)  
toggleGUIVisibilityButton.Parent = gui  

toggleGUIVisibilityButton.MouseButton1Click:Connect(function()  
    gui.Visible = not gui.Visible  
end)  
