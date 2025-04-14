local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Solara v3互換ライブラリ
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Speed Control",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_SpeedControl"
})

local MainTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- 初期値
local speedValue = 16
local speedEnabled = false

-- オンオフ切替
MainTab:AddToggle({
    Name = "Speed On/Off",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if speedEnabled then
            Humanoid.WalkSpeed = speedValue
        else
            Humanoid.WalkSpeed = 16
        end
    end
})

-- スピードスライダー
local speedSlider = MainTab:AddSlider({
    Name = "Speed Slider",
    Min = 1,
    Max = 500,
    Default = speedValue,
    Increment = 1,
    Callback = function(value)
        speedValue = value
        if speedEnabled then
            Humanoid.WalkSpeed = value
        end
    end
})

-- 数値入力ボックス（ここが手動入力部分！）
MainTab:AddTextbox({
    Name = "Speed Input (手動入力)",
    Default = tostring(speedValue),
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 and num <= 500 then
            speedValue = num
            speedSlider:Set(num) -- スライダーと同期
            if speedEnabled then
                Humanoid.WalkSpeed = num
            end
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "1〜500の数字を入力してね！",
                Time = 3
            })
        end
    end
})

-- スピード維持ループ（非表示でもちゃんと効く！）
task.spawn(function()
    while true do
        task.wait(0.5) -- 0.5秒おきにチェック（過負荷防止）
        if speedEnabled and Humanoid.WalkSpeed ~= speedValue then
            Humanoid.WalkSpeed = speedValue
        end
    end
end)
