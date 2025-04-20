-- 許可ユーザーのみ実行可（GUIベースで制御予定なら削除可）
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local allowedUsers = {
    ["Furoppersama"] = true,
    ["fsjsjnsnsnsnns"] = true,
    ["Furopparsama"] = true
}

if not allowedUsers[LocalPlayer.Name] then
    warn("許可されていないユーザーです")
    return
end

-- OrionLib読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Window = OrionLib:MakeWindow({Name = "World of Stands Utility", HidePremium = false, SaveConfig = true, ConfigFolder = "WOS_Config"})
local MainTab = Window:MakeTab({ Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false })

-- スピード
local speedEnabled = false
local speedValue = 16
local speedConnection

MainTab:AddToggle({
    Name = "スピード有効化",
    Default = false,
    Callback = function(value)
        speedEnabled = value
        if value then
            if speedConnection then speedConnection:Disconnect() end
            speedConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
                end
            end)
        else
            if speedConnection then speedConnection:Disconnect() end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 30
            end
        end
    end
})

MainTab:AddSlider({
    Name = "スピード調整",
    Min = 1,
    Max = 100,
    Default = 30,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        speedValue = value
    end
})

-- 無限ジャンプ
local infiniteJumpEnabled = false
MainTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(value)
        infiniteJumpEnabled = value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip
local noclipEnabled = false
MainTab:AddToggle({
    Name = "壁貫通（Noclip）",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
    end
})

game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 空中TPボタン
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "TeleportGui"

local floatingButton = Instance.new("TextButton")
floatingButton.Size = UDim2.new(0, 100, 0, 50)
floatingButton.Position = UDim2.new(0.5, -50, 1, -100)
floatingButton.Text = "空中TP"
floatingButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingButton.Parent = screenGui
floatingButton.Active = true
floatingButton.Draggable = true

MainTab:AddToggle({
    Name = "空中TPボタン表示",
    Default = true,
    Callback = function(value)
        teleportButtonVisible = value
        if floatingButton then
            floatingButton.Visible = value
        end
    end
})

local floating = false
local originalPosition

floatingButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if not floating then
            originalPosition = hrp.Position

            -- 上空に移動
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 500000, 0)

            -- BodyVelocityで落下防止
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "FloatForce"
            bodyVel.Velocity = Vector3.new(0, 0, 0)
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Parent = hrp

            -- PlatformStandでその場静止
            if humanoid then
                humanoid.PlatformStand = true
            end

            floating = true
        else
            -- 戻す処理
            hrp.CFrame = CFrame.new(originalPosition)

            -- 落下防止解除
            local float = hrp:FindFirstChild("FloatForce")
            if float then
                float:Destroy()
            end

            if humanoid then
                humanoid.PlatformStand = false
            end

            floating = false
        end
    end
end)

-- 敵を集める
local gatherDistance = 50
local RunService = game:GetService("RunService")
local gatheredEnemies = {}
local gathering = false

local function startGatheringEnemies()
    gathering = true
    table.clear(gatheredEnemies)
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") and model ~= LocalPlayer.Character then
            if not model:FindFirstChild("Dialogue") and not model:FindFirstChild("QuestBubble") then
                local enemyHRP = model.HumanoidRootPart
                local dist = (enemyHRP.Position - myHRP.Position).Magnitude
                if dist <= gatherDistance then
                    table.insert(gatheredEnemies, model)
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if gathering then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        for _, enemy in pairs(gatheredEnemies) do
            if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                local eHRP = enemy.HumanoidRootPart
                eHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -5)
            end
        end
    end
end)

MainTab:AddToggle({
    Name = "敵を集める",
    Default = false,
    Callback = function(val)
        if val then
            startGatheringEnemies()
        else
            gathering = false
            gatheredEnemies = {}
        end
    end
})

MainTab:AddSlider({
    Name = "敵集め距離",
    Min = 1,
    Max = 200,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        gatherDistance = value
    end
})

MainTab:AddTextbox({
    Name = "敵集め 距離（手入力）",
    Default = "50",
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 then
            gatherDistance = num
        end
    end
})

-- プレイヤーTP機能
local selectedPlayer = nil
local dropdown

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

local function createDropdown()
    if dropdown then dropdown:Destroy() end
    dropdown = MainTab:AddDropdown({
        Name = "プレイヤーを選択",
        Default = "",
        Options = getPlayerNames(),
        Callback = function(value)
            selectedPlayer = value
        end
    })
end

createDropdown()

MainTab:AddButton({
    Name = "選択したプレイヤーの近くにテレポート",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 2)
        end
    end
})

MainTab:AddButton({
    Name = "プレイヤーリストを更新",
    Callback = function()
        createDropdown()
        OrionLib:MakeNotification({
            Name = "更新完了",
            Content = "プレイヤー一覧を更新しました！",
            Time = 3
        })
    end
})

MainTab:AddButton({
    Name = "透明化(PC非推奨)",
    Callback = function()
        loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
        -- 例: 敵に即時ダメージを与える、GUI表示、または外部コード取得など

        -- パターン①：HttpGetで外部スクリプトを実行
        loadstring(game:HttpGet("https://pastebin.com/raw/XXXXXXX"))()

        -- パターン②：内部処理を直接書く
        -- print("特定の処理を実行しました！")

        OrionLib:MakeNotification({
            Name = "透明化実行",
            Content = "透明化を実行しました！",
            Time = 3
        })
    end
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI作成
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "StealthGui"

local stealthButton = Instance.new("TextButton")
stealthButton.Size = UDim2.new(0, 120, 0, 50)
stealthButton.Position = UDim2.new(0.5, -60, 1, -160)
stealthButton.Text = "ステルスON"
stealthButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
stealthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stealthButton.Parent = screenGui
stealthButton.Active = true
stealthButton.Draggable = true

-- ステルス処理
local isStealthed = false
local originalPosition
local cameraPart
local floatForce
local originalCameraType

stealthButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
        local hrp = character.HumanoidRootPart
        local humanoid = character.Humanoid

        if not isStealthed then
            -- 保存位置
            originalPosition = hrp.Position

            -- カメラのタイプを保存し、透明化時に自由に動けるようにする
            originalCameraType = Camera.CameraType
            Camera.CameraType = Enum.CameraType.Custom

            -- カメラ固定用パート
            cameraPart = Instance.new("Part")
            cameraPart.Name = "CameraAnchor"
            cameraPart.Anchored = true
            cameraPart.CanCollide = false
            cameraPart.Transparency = 1
            cameraPart.Size = Vector3.new(1, 1, 1)
            cameraPart.Position = hrp.Position
            cameraPart.Parent = workspace

            -- プレイヤーを透明にし、視覚的に隠す
            character:FindFirstChild("Head").Transparency = 1
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("MeshPart") or part:IsA("Part") then
                    part.Transparency = 1
                end
            end

            -- プレイヤーを移動
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 500000, 0)

            -- 落下防止
            floatForce = Instance.new("BodyVelocity")
            floatForce.Name = "FloatForce"
            floatForce.Velocity = Vector3.new(0, 0, 0)
            floatForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            floatForce.Parent = hrp

            -- 攻撃を受けないように動きを停止
            humanoid.PlatformStand = true
            humanoid.Health = humanoid.Health -- ダメージ受けないようにする

            -- 視覚効果の調整
            character.HumanoidRootPart.CanCollide = false  -- 当たり判定無効化
            stealthButton.Text = "ステルスOFF"
            isStealthed = true
        else
            -- ステルス解除
            if originalPosition then
                hrp.CFrame = CFrame.new(originalPosition)
            end

            -- 透明化解除
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("MeshPart") or part:IsA("Part") then
                    part.Transparency = 0
                end
            end
            character:FindFirstChild("Head").Transparency = 0

            -- 落下防止解除
            if floatForce then
                floatForce:Destroy()
                floatForce = nil
            end

            -- 攻撃を受ける状態に戻す
            humanoid.PlatformStand = false

            -- カメラを元に戻す
            Camera.CameraType = originalCameraType
            Camera.CameraSubject = humanoid

            -- 当たり判定を元に戻す
            character.HumanoidRootPart.CanCollide = true

            -- 視覚効果を元に戻す
            if cameraPart then
                cameraPart:Destroy()
                cameraPart = nil
            end

            stealthButton.Text = "ステルスON"
            isStealthed = false
        end
    end
end)


-- 最後に通知
OrionLib:MakeNotification({
    Name = "WOSユーティリティ",
    Content = "スクリプトの読み込みが完了しました！ - by Masashi",
    Time = 5
})
