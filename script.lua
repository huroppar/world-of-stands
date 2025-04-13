local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "🚀 Stand Power Controller",
    HidePremium = false,
    SaveConfig = true,
    IntroText = "World of Stands Hack Panel",
    ConfigFolder = "WOS_Util"
})

-- プレイヤー取得
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🔼 無限ジャンプ
local JumpEnabled = true
game:GetService("UserInputService").JumpRequest:Connect(function()
    if JumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 📐 タブとセクション
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- 🌀 スピード変更
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

-- 🛫 空中へテレポート（+5000）
MainTab:AddButton({
    Name = "空中テレポート",
    Callback = function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        root.CFrame = root.CFrame + Vector3.new(0, 5000, 0)
    end
})

-- 🎯 プレイヤー横にテレポート
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
                root.CFrame = CFrame.new(targetPos + Vector3.new(5, 0, 0)) -- 横に5
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

-- ✅ 初期化
OrionLib:Init()
