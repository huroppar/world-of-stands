loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Float GUI (World of Stands)",
    HidePremium = false,
    SaveConfig = false,
    IntroText = "WOS Toolkit",
})

-- ✅ 無限ジャンプ
local infJumpEnabled = true
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

UIS.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ✅ テレポート
local function teleportUp()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    -- 一度アンカーして落下を防ぐ
    root.Anchored = true

    -- 高さを調整（1000くらいずつ試してみて）
    root.CFrame = root.CFrame + Vector3.new(0, 5000, 0)

    -- 少し待ってからアンカー解除
    task.wait(1) -- 1秒後に解除
    root.Anchored = false
end
-- 🎛️ タブとセクション
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})

MainTab:AddButton({
    Name = "空中にテレポート",
    Callback = teleportUp
})

MainTab:AddToggle({
    Name = "無限ジャンプ",
    Default = true,
    Callback = function(Value)
        infJumpEnabled = Value
    end
})

-- 完了メッセージ
OrionLib:MakeNotification({
    Name = "GUI起動成功",
    Content = "ワンボタン空中浮遊 & 無限ジャンプが起動しました！",
    Image = "rbxassetid://4483345998",
    Time = 5
})
