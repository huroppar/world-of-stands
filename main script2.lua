-- OrionLibの読み込み（ミラーリンク使用）
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

-- ウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "✨ Masashi Neon GUI ✨",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MasashiNeon"
})

-- タブ作成
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- スピード設定変数
local SpeedEnabled = false
local SpeedValue = 16

-- スピード切り替えトグル
MainTab:AddToggle({
    Name = "スピード変更ON/OFF",
    Default = false,
    Callback = function(state)
        SpeedEnabled = state
        if SpeedEnabled then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

-- スピードスライダー（1〜500）
MainTab:AddSlider({
    Name = "スピード調整",
    Min = 1,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 140),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        SpeedValue = value
        if SpeedEnabled then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
        end
    end
})
