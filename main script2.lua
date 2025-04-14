--// OrionLib 読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

--// GUIウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "✨ Masashi Neon GUI ✨",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MasashiNeonConfig"
})

--// メインタブ
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998", -- 好きなアイコンに変えてOK
    PremiumOnly = false
})

--// 変数と関数定義
local player = game.Players.LocalPlayer
local speedValue = 16
local speedEnabled = false

--// Humanoidを安全に取得する関数
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

--// スピードスライダー
MainTab:AddSlider({
    Name = "Speed",
    Min = 1,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 150),
    Increment = 1,
    ValueName = "速度",
    Callback = function(value)
        speedValue = value
        if speedEnabled then
            getHumanoid().WalkSpeed = speedValue
        end
    end
})

--// スピードオン/オフトグル
MainTab:AddToggle({
    Name = "Speed オン/オフ",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if speedEnabled then
            getHumanoid().WalkSpeed = speedValue
        else
            getHumanoid().WalkSpeed = 16
        end
    end
})
