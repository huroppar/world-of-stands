local player = game.Players.LocalPlayer  
local gui = Instance.new("ScreenGui")  
gui.Parent = player:WaitForChild("PlayerGui")  

-- 初期設定  
local speedMax = 900  
local speedToggle = false  
local infiniteJumpEnabled = false  
local wallPassEnabled = false  
local originalPosition = nil  

-- メインフレーム  
local mainFrame = Instance.new("Frame")  
mainFrame.Size = UDim2.new(0.5, 0, 0.5, 0)  
mainFrame.Position = UDim2.new(0.25, 0, 0.25, 0)  
mainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)  
mainFrame.Parent = gui  

-- タブのフレーム  
local tabFrame = Instance.new("Frame")  
tabFrame.Size = UDim2.new(1, 0, 0.1, 0)  
tabFrame.Position = UDim2.new(0, 0, 0, 0)  
tabFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)  
tabFrame.Parent = mainFrame  

-- タブを管理  
local tabs = {"Settings", "Visuals", "Players"}  

for i, tabName in ipairs(tabs) do  
    local tabButton = Instance.new("TextButton")  
    tabButton.Size = UDim2.new(1 / #tabs, 0, 1, 0)  
    tabButton.Position = UDim2.new((i - 1) / #tabs, 0, 0, 0)  
    tabButton.Text = tabName  
    tabButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)  
    tabButton.Parent = tabFrame  
    
    tabButton.MouseButton1Click:Connect(function()  
    -- タブを表示する処理  
    for j, button in ipairs(tabFrame:GetChildren()) do  
        if button:IsA("TextButton") then  
            button.BackgroundColor3 = (button.Text == tabName) and Color3.new(0.6, 0.6, 0.6) or Color3.new(0.4, 0.4, 0.4)  
        end  
    end  
    
    -- ContentFrame表示/非表示の処理を追加  
    for i, content in ipairs(mainFrame:GetChildren()) do  
        if content:IsA("Frame") then  
            content.Visible = false  -- すべて非表示にする  
        end  
    end  
    
    local contentFrame = mainFrame:FindFirstChild(tabName) or Instance.new("Frame", mainFrame)  
    contentFrame.Name = tabName  
    contentFrame.Size = UDim2.new(1, 0, 0.9, 0)  
    contentFrame.Position = UDim2.new(0, 0, 0.1, 0)  
    contentFrame.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)  
    contentFrame.Visible = true  -- 現在のタブのコンテンツを表示  
end)
    
        -- 各タブの内容を設定  
        if tabName == "Settings" then  
            -- スピード調整  
            local speedLabel = Instance.new("TextLabel", contentFrame)  
            speedLabel.Size = UDim2.new(0.5, 0, 0.1, 0)  
            speedLabel.Position = UDim2.new(0.05, 0, 0.1, 0)  
            speedLabel.Text = "Speed Max:"  
            speedLabel.BackgroundColor3 = Color3.new(0.6, 0.6, 0.6)  

            local speedBox = Instance.new("TextBox", contentFrame)  
            speedBox.Size = UDim2.new(0.4, 0, 0.1, 0)  
            speedBox.Position = UDim2.new(0.55, 0, 0.1, 0)  
            speedBox.PlaceholderText = tostring(speedMax)  
-- スピード切替ボタン  
            local toggleSpeedButton = Instance.new("TextButton", contentFrame)  
            toggleSpeedButton.Text = "Toggle Speed"  
            toggleSpeedButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
            toggleSpeedButton.Position = UDim2.new(0.25, 0, 0.22, 0)  

            toggleSpeedButton.MouseButton1Click:Connect(function()  
                speedToggle = not speedToggle  
                if speedToggle then  
                    player.Character.Humanoid.WalkSpeed = speedMax  
                else  
                    player.Character.Humanoid.WalkSpeed = 16  
                end  
            end)  

            -- 無限ジャンプボタン  
            local toggleJumpButton = Instance.new("TextButton", contentFrame)  
            toggleJumpButton.Text = "Toggle Infinite Jump"  
            toggleJumpButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
            toggleJumpButton.Position = UDim2.new(0.25, 0, 0.34, 0)  

            toggleJumpButton.MouseButton1Click:Connect(function()  
                infiniteJumpEnabled = not infiniteJumpEnabled  
                if infiniteJumpEnabled then  
                    local conn  
                    conn = game:GetService("UserInputService").JumpRequest:Connect(function()  
                        if infiniteJumpEnabled then  
                            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)  
                        end  
                    end)  
                end  
            end)  

            -- 空中テレポートボタン  
            local teleportUpButton = Instance.new("TextButton", contentFrame)  
            teleportUpButton.Text = "Teleport Up"  
            teleportUpButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
            teleportUpButton.Position = UDim2.new(0.25, 0, 0.46, 0)  

            teleportUpButton.MouseButton1Click:Connect(function()  
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then  
                    originalPosition = player.Character.HumanoidRootPart.Position  
                    player.Character.HumanoidRootPart.Position = Vector3.new(originalPosition.X, 5000, originalPosition.Z)  
                end  
            end)  

            -- 戻るボタン  
            local returnButton = Instance.new("TextButton", contentFrame)  
            returnButton.Text = "Return"  
            returnButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
            returnButton.Position = UDim2.new(0.25, 0, 0.58, 0)  

            returnButton.MouseButton1Click:Connect(function()  
                if originalPosition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then  
                    player.Character.HumanoidRootPart.Position = originalPosition  
                end  
            end)  

            -- 壁貫通ボタン  
            local toggleWallPassButton = Instance.new("TextButton", contentFrame)  
            toggleWallPassButton.Text = "Toggle Wall Pass"  
            toggleWallPassButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
            toggleWallPassButton.Position = UDim2.new(0.25, 0, 0.70, 0)  

            toggleWallPassButton.MouseButton1Click:Connect(function()  
                wallPassEnabled = not wallPassEnabled  
                if wallPassEnabled then  
                    player.Character.HumanoidRootPart.CanCollide = false -- 壁を貫通  
                else  
                    player.Character.HumanoidRootPart.CanCollide = true -- 通常の衝突  
                end  
            end)  

            -- 透明化ボタン  
            local toggleTransparencyButton = Instance.new("TextButton", contentFrame)  
            toggleTransparencyButton.Text = "Toggle Transparency"  
            toggleTransparencyButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
            toggleTransparencyButton.Position = UDim2.new(0.25, 0, 0.82, 0)  

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
            local showPlayerListButton = Instance.new("TextButton", contentFrame)  
            showPlayerListButton.Text = "Show Player List"  
            showPlayerListButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
            showPlayerListButton.Position = UDim2.new(0.25, 0, 0.94, 0)  

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
            local toggleGUIVisibilityButton = Instance.new("TextButton", contentFrame)  
            toggleGUIVisibilityButton.Text = "Toggle GUI Visibility"  
            toggleGUIVisibilityButton.Size = UDim2.new(0.5, 0, 0.1, 0)  
            toggleGUIVisibilityButton.Position = UDim2.new(0.25, 0, 1.06, 0)  

            toggleGUIVisibilityButton.MouseButton1Click:Connect(function()  
                gui.Visible = not gui.Visible  
            end)  
        end  
    end  
end
