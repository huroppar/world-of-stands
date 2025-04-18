-- キーシステム
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local allowedUsers = {
    ["Furoppersama"] = true,
    ["Furopparsama"] = true
}

if not allowedUsers[LocalPlayer.Name] then
    local userInputService = game:GetService("UserInputService")
    local keyCorrect = false
    while not keyCorrect do
        local input = userInputService:GetString("キーを入力してください：")
        if input == "Masashi0407" then
            keyCorrect = true
        else
            print("キーが間違っています。再試行してください。")
        end
    end
end

-- GUIライブラリの読み込み（OrionLibを使用）
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({Name = "World of Stands Utility", HidePremium = false, SaveConfig = true, ConfigFolder = "WOS_Config"})

-- メインタブの作成
local MainTab = Window:MakeTab({
    Name = "メイン",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- スピード制御
local speedEnabled = false
local speedValue = 16

MainTab:AddToggle({
    Name = "スピード有効化",
    Default = false,
    Callback = function(value)
        speedEnabled = value
        if speedEnabled then
            game:GetService("RunService").RenderStepped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
                end
            end)
        end
    end
})

MainTab:AddSlider({
    Name = "スピード調整",
    Min = 1,
    Max = 100,
    Default = 16,
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

-- 壁貫通（Noclip）
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
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- 空中TPボタン
local floatingButton = Instance.new("TextButton")
floatingButton.Size = UDim2.new(0, 100, 0, 50)
floatingButton.Position = UDim2.new(0.5, -50, 1, -60)
floatingButton.Text = "空中TP"
floatingButton.BackgroundColor3 = Color3.new(0, 0, 0)
floatingButton.TextColor3 = Color3.new(1, 1, 1)
floatingButton.Parent = game:GetService("CoreGui")
floatingButton.Active = true
floatingButton.Draggable = true

local floating = false
local originalPosition

floatingButton.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if not floating then
            originalPosition = hrp.Position
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0)
            floating = true
        else
            hrp.CFrame = CFrame.new(originalPosition)
            floating = false
        end
    end
end)

-- 敵BOT集め機能
local function gatherEnemies()
    for _, enemy in pairs(workspace:GetDescendants()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            local hrp = enemy.HumanoidRootPart
            hrp.Anchored = true
            hrp.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
            enemy.Humanoid.WalkSpeed = 0
            enemy.Humanoid.JumpPower = 0
            if enemy:FindFirstChild("Target") then
                enemy.Target.Value = nil
            end
            for _, s in pairs(enemy:GetChildren()) do
                if s:IsA("Script") then s.Disabled = true end
            end
        end
    end
end

MainTab:AddButton({
    Name = "敵を集める",
    Callback = function()
        gatherEnemies()
    end
})

-- プレイヤー一覧表示
local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr
::contentReference[oaicite:0]{index=0}
         if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

local selectedPlayer = nil

MainTab:AddDropdown({
    Name = "プレイヤーを選択",
    Default = "",
    Options = getPlayerNames(),
    Callback = function(value)
        selectedPlayer = value
    end
})

MainTab:AddButton({
    Name = "選択したプレイヤーの近くにテレポート",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 2)
        end
    end
})

-- プレイヤーリストを更新するボタン
MainTab:AddButton({
    Name = "プレイヤーリストを更新",
    Callback = function()
        local options = getPlayerNames()
        OrionLib:MakeNotification({
            Name = "更新完了",
            Content = "プレイヤー一覧を更新しました！",
            Time = 3
        })
    end
})

-- スクリプト終了通知
OrionLib:MakeNotification({
    Name = "WOSユーティリティ",
    Content = "スクリプトの読み込みが完了しました！ - by Masashi",
    Time = 5
})
