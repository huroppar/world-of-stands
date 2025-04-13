-- OrionLibの読み込み（Pastebinを使用）
local OrionLib = loadstring(game:HttpGet(('https://pastebin.com/raw/WRUyYTdY')))()

-- ウィンドウ設定
local Window = OrionLib:MakeWindow({
    Name = "🚀 Stand Power Controller",
    HidePremium = false,
    SaveConfig = true,
    IntroText = "World of Stands Hack Panel",
    ConfigFolder = "WOS_Util"
})

-- サービスとプレイヤー取得
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- メインタブとテレポートタブ
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- 無限ジャンプ
local JumpEnabled = true
UserInputService.JumpRequest:Connect(function()
    if JumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- スピード調整
MainTab:AddTextbox({
    Name = "Speed",
    Default = "16",
    TextDisappear = false,
    Callback = function(value)
        local speed = tonumber(value)
        if speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
    end
})

-- 空中テレポート
MainTab:AddButton({
    Name = "空中テレポート",
    Callback = function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        root.CFrame = root.CFrame + Vector3.new(0, 5000, 0)
    end
})

-- 体力回復ボタン
MainTab:AddButton({
    Name = "体力を回復",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
    end
})

-- プレイヤー横にテレポート
local targetName = ""
TeleportTab:AddTextbox({
    Name = "テレポート先プレイヤー名",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        targetName = value
    end
})

TeleportTab:AddButton({
    Name = "そのプレイヤーの横にテレポート",
    Callback = function()
        local targetPlayer = Players:FindFirstChild(targetName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local targetPos = targetPlayer.Character.HumanoidRootPart.Position
                root.CFrame = CFrame.new(targetPos + Vector3.new(5, 0, 0))
            end
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "プレイヤーが見つかりませんでした！",
                Time = 3
            })
        end
    end
})

-- テレポートのキー割り当て
local TeleportKeys = {
    ["T"] = Enum.KeyCode.T,
    ["1"] = Enum.KeyCode.Y,
    ["H"] = Enum.KeyCode.H
}

local selectedTeleportKey = Enum.KeyCode.F

TeleportTab:AddDropdown({
    Name = "テレポートのキーを選択",
    Default = "T",
    Options = {"T", "Y", "H"},
    Callback = function(value)
        selectedTeleportKey = TeleportKeys[value]
    end
})

-- テレポートボタンの表示切り替え
local teleportButtonVisible = true
local teleportButton

TeleportTab:AddToggle({
    Name = "テレポートボタン表示切替",
    Default = true,
    Callback = function(value)
        teleportButtonVisible = value
        if teleportButton then
            teleportButton.Visible = value
        end
    end
})

teleportButton = TeleportTab:AddButton({
    Name = "キーでテレポート（上に移動）",
    Callback = function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame + Vector3.new(0, 5000, 0)
        end
    end
})

-- キー入力でテレポート実行
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == selectedTeleportKey and teleportButtonVisible then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame + Vector3.new(0, 5000, 0)
        end
    end
end)


local function teleportEnemyToPosition(enemyName, position)
    for _, enemy in pairs(game:GetService("Workspace"):GetDescendants()) do
        if enemy:IsA("Model") and enemy.Name == enemyName then
            local root = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
            if root then
                root.CFrame = CFrame.new(position)
                print(enemyName .. " をテレポートしました")
            end
        end
    end
end

-- 使用例
teleportEnemyToPosition("EnemyNameHere", Vector3.new(0, 100, 0))


MainTab:AddButton({
    Name = "近くの敵のHPを1にする",
    Callback = function()
        local success, err = pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local nearest
            local minDist = math.huge
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:FindFirstChild("Humanoid") and v ~= char then
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist < minDist then
                            nearest = v
                            minDist = dist
                        end
                    end
                end
            end

            if nearest then
                local humanoid = nearest:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Health = 1
                    print("HPを1にした！")
                end
            else
                warn("敵が見つかりませんでした")
            end
        end)

        if not success then
            warn("エラー:", err)
        end
    end
})


MainTab:AddButton({
    Name = "Remote一覧を表示する",
    Callback = function()
        local success, err = pcall(function()
            local found = {}
            for _, v in ipairs(getgc(true)) do
                if typeof(v) == "table" then
                    for k, value in pairs(v) do
                        if typeof(value) == "Instance" then
                            if value:IsA("RemoteEvent") or value:IsA("RemoteFunction") then
                                if not table.find(found, value:GetFullName()) then
                                    table.insert(found, value:GetFullName())
                                end
                            end
                        end
                    end
                end
            end

            if #found > 0 then
                print("=== Remote 一覧 ===")
                for _, remotePath in ipairs(found) do
                    print(remotePath)
                end
                OrionLib:MakeNotification({
                    Name = "成功",
                    Content = "Remote一覧をF9で確認してね！",
                    Time = 4
                })
            else
                OrionLib:MakeNotification({
                    Name = "結果なし",
                    Content = "Remoteが見つからなかったよ",
                    Time = 4
                })
            end
        end)

        if not success then
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "Remote探索中にエラーが発生しました",
                Time = 4
            })
            warn("Remote探索エラー: ", err)
        end
    end
})

-- OrionLib初期化
OrionLib:Init()
