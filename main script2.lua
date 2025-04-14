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
local speedValue = 30
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
            Humanoid.WalkSpeed = 30
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

-- スピード維持ループ（全自動でHumanoidの再取得も含む）
task.spawn(function()
    while true do
        task.wait(0.1)

        if speedEnabled then
            local currentChar = player.Character
            if currentChar then
                local currentHumanoid = currentChar:FindFirstChildWhichIsA("Humanoid")
                if currentHumanoid then
                    if currentHumanoid.WalkSpeed ~= speedValue then
                        currentHumanoid.WalkSpeed = speedValue
                    end
                end
            end
        end
    end
end)

-- キャラがリセットされたときも対応
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    humanoid = newChar:WaitForChild("Humanoid")
    if speedEnabled then
        humanoid.WalkSpeed = speedValue
    end
end)
