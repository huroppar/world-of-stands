local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

-- メインウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "✨ Masashi Neon GUI ✨",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MasashiNeon"
})

-- メインタブ作成
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- スピード制御用変数
local speedValue = 16
local speedEnabled = true  -- 最初からONにしておく
local humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")

-- スピードスライダー
MainTab:AddSlider({
    Name = "Speed",
    Min = 1,
    Max = 500,
    Default = speedValue,
    Increment = 1,
    Callback = function(value)
        speedValue = value
        if speedEnabled and humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

-- ラベル追加
MainTab:AddLabel("こんにちは！Masashi Neon GUIへようこそ ✨")

-- ボタン追加
MainTab:AddButton({
    Name = "通知を表示するボタン",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "クリック成功！",
            Content = "ボタンがちゃんと動いてるよ！",
            Time = 3
        })
    end
})

-- GUIを起動
OrionLib:Init()
