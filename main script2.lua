local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Solara v3用ライブラリを読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

-- GUIウィンドウの作成
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

-- 変数
local speedValue = 16
local speedEnabled = false
local speedSlider, speedBox

-- スピードのオンオフ切り替え
MainTab:AddToggle({
    Name = "Speed On/Off",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if speedEnabled then
            Humanoid.WalkSpeed = speedValue
        else
            Humanoid.WalkSpeed = 16 -- デフォルトに戻す
        end
    end
})

-- スピードスライダー
speedSlider = MainTab:AddSlider({
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
        if speedBox then
            speedBox:SetText(tostring(value))
        end
    end
})

-- 数値直接入力ボックス
speedBox = MainTab:AddTextbox({
    Name = "Speed Input",
    Default = tostring(speedValue),
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 and num <= 500 then
            speedValue = num
            speedSlider:Set(num)
            if speedEnabled then
                Humanoid.WalkSpeed = num
            end
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "1〜500の数値を入力してください！",
                Time = 2
            })
            speedBox:SetText(tostring(speedValue))
        end
    end
})
