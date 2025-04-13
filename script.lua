-- OrionLibの読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

-- ウィンドウ設定
local Window = OrionLib:MakeWindow({
    Name = "🚀 Stand Power Controller",
    HidePremium = false,
    SaveConfig = true,
    IntroText = "World of Stands Hack Panel",
    ConfigFolder = "WOS_Util"
})

-- サービス取得
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- タブ作成
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "rbxassetid://4483345998", PremiumOnly = false})

----------------------------------------------------
-- 🔹 無限ジャンプ
local JumpEnabled = true
UserInputService.JumpRequest:Connect(function()
    if JumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

----------------------------------------------------
-- 🔹 スピード調整
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

----------------------------------------------------
-- 🔹 空中テレポート
MainTab:AddButton({
    Name = "空中テレポート",
    Callback = function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame + Vector3.new(0, 5000, 0)
        end
    end
})

----------------------------------------------------
-- 🔹 体力回復ボタン
MainTab:AddButton({
    Name = "体力を回復",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
    end
})

----------------------------------------------------
-- 🔹 プレイヤー横にテレポート
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
                root.CFrame = CFrame.new(targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(5, 0, 0))
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

----------------------------------------------------
-- 🔹 テレポートキー割り当てと表示切替
local TeleportKeys = {
    ["T"] = Enum.KeyCode.T,
    ["Y"] = Enum.KeyCode.Y,
    ["H"] = Enum.KeyCode.H
}

local selectedTeleportKey = Enum.KeyCode.T
local teleportButtonVisible = true
local teleportButton

TeleportTab:AddDropdown({
    Name = "テレポートのキーを選択",
    Default = "T",
    Options = {"T", "Y", "H"},
    Callback = function(value)
        selectedTeleportKey = TeleportKeys[value]
    end
})

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and teleportButtonVisible and input.KeyCode == selectedTeleportKey then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame + Vector3.new(0, 5000, 0)
        end
    end
end)

----------------------------------------------------
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

local Window = OrionLib:MakeWindow({
    Name = "World of Stands | Auto Attack",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_AutoAttack"
})

local autoAttack = false
local selectedEnemy = "Corrupted Swordsman"
local standName = "Anubis"

local remote = game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Events")

local function attackEnemy(enemy, stand)
    remote:FireServer(enemy, stand, false, 20)
end

-- 自動攻撃ループ
task.spawn(function()
    while true do
        if autoAttack then
            attackEnemy(selectedEnemy, standName)
        end
        task.wait(0.5) -- 攻撃間隔
    end
end)

-- GUIタブ
local Tab = Window:MakeTab({
    Name = "Auto Attack",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddTextbox({
    Name = "Enemy Name",
    Default = selectedEnemy,
    TextDisappear = false,
    Callback = function(Value)
        selectedEnemy = Value
    end
})

Tab:AddTextbox({
    Name = "Stand Name",
    Default = standName,
    TextDisappear = false,
    Callback = function(Value)
        standName = Value
    end
})

Tab:AddButton({
    Name = "Attack Once",
    Callback = function()
        attackEnemy(selectedEnemy, standName)
    end
})

Tab:AddToggle({
    Name = "Auto Attack",
    Default = false,
    Callback = function(Value)
        autoAttack = Value
    end
})

OrionLib:Init()

----------------------------------------------------
-- Orion GUI起動
OrionLib:Init()
