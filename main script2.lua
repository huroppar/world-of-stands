-- World of Stands Most Useful Script 完全版 by Masashi

-- OrionLib 読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

-- GUI 初期化
local Window = OrionLib:MakeWindow({Name = "World of Stands GUI", HidePremium = false, SaveConfig = true, ConfigFolder = "WOS_Config"})

-- 共通変数
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local HumanoidRootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local speedEnabled = false
local speedValue = 30
local infiniteJumpEnabled = false
local teleportKey = Enum.KeyCode.T
local flyPos = nil
local buttonVisible = true
local transparencyEnabled = false

-- 通知機能
local function Notify(title, text)
    OrionLib:MakeNotification({Name = title, Content = text, Time = 5})
end

-- スピード切り替え
local function toggleSpeed(enabled, value)
    speedEnabled = enabled
    speedValue = value or 30
    if not speedEnabled then
        LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 30
    end
end

RunService.Stepped:Connect(function()
    if speedEnabled then
        pcall(function()
            LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = speedValue
        end)
    end
end)

-- 無限ジャンプ
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        pcall(function()
            LocalPlayer.Character:WaitForChild("Humanoid"):ChangeState("Jumping")
        end)
    end
end)

-- 空中テレポート
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == teleportKey and flyPos then
        HumanoidRootPart.CFrame = CFrame.new(flyPos)
    end
end)

-- GUIタブと要素
local MainTab = Window:MakeTab({Name = "メイン機能", Icon = "rbxassetid://4483345998", PremiumOnly = false})

MainTab:AddSlider({
    Name = "移動スピード",
    Min = 1,
    Max = 500,
    Default = 30,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        speedValue = value
    end
})

MainTab:AddToggle({
    Name = "スピード変更ON/OFF",
    Default = false,
    Callback = function(value)
        toggleSpeed(value, speedValue)
    end
})

MainTab:AddToggle({
    Name = "無限ジャンプON/OFF",
    Default = false,
    Callback = function(value)
        infiniteJumpEnabled = value
    end
})

MainTab:AddTextbox({
    Name = "空中テレポートキー変更",
    Default = "T",
    TextDisappear = true,
    Callback = function(keyStr)
        local foundKey = Enum.KeyCode[keyStr:upper()]
        if foundKey then
            teleportKey = foundKey
            Notify("キー設定", "空中TPキーを " .. keyStr:upper() .. " に設定しました")
        else
            Notify("エラー", "指定されたキーは無効です")
        end
    end
})

MainTab:AddButton({
    Name = "空中位置を保存",
    Callback = function()
        flyPos = HumanoidRootPart.Position + Vector3.new(0, 10000, 0)
        Notify("位置保存", "空中テレポート位置を保存しました")
    end
})

MainTab:AddToggle({
    Name = "空中TPボタン表示切替",
    Default = true,
    Callback = function(value)
        buttonVisible = value
        if airTpButton then
            airTpButton.Visible = value
        end
    end
})

MainTab:AddToggle({
    Name = "透明化ボタン表示切替",
    Default = true,
    Callback = function(value)
        if invisButton then
            invisButton.Visible = value
        end
    end
})

-- 空中TPボタン
local airTpButton = Instance.new("TextButton")
airTpButton.Size = UDim2.new(0, 120, 0, 50)
airTpButton.Position = UDim2.new(0, 100, 0, 100)
airTpButton.Text = "空中TP"
airTpButton.Parent = game:GetService("CoreGui")
airTpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
airTpButton.TextColor3 = Color3.new(1, 1, 1)
airTpButton.Visible = buttonVisible

airTpButton.MouseButton1Click:Connect(function()
    if flyPos then
        HumanoidRootPart.CFrame = CFrame.new(flyPos)
    end
end)

-- ドラッグ機能（空中TPボタン）
local dragging, offset
airTpButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        offset = input.Position - airTpButton.AbsolutePosition
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        airTpButton.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- 透明化機能 + ボタン
local invisButton = Instance.new("TextButton")
invisButton.Size = UDim2.new(0, 120, 0, 50)
invisButton.Position = UDim2.new(0, 100, 0, 160)
invisButton.Text = "透明化切替"
invisButton.Parent = game:GetService("CoreGui")
invisButton.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
invisButton.TextColor3 = Color3.new(1, 1, 1)
invisButton.Visible = true

invisButton.MouseButton1Click:Connect(function()
    transparencyEnabled = not transparencyEnabled
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = transparencyEnabled and 1 or 0
        end
    end
    Notify("透明化", transparencyEnabled and "透明になりました" or "透明を解除しました")
end)

-- ドラッグ機能（透明化ボタン）
local dragging2, offset2
invisButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging2 = true
        offset2 = input.Position - invisButton.AbsolutePosition
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging2 and input.UserInputType == Enum.UserInputType.MouseMovement then
        invisButton.Position = UDim2.new(0, input.Position.X - offset2.X, 0, input.Position.Y - offset2.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging2 = false
    end
end)

-- 起動通知
Notify("Masashiスクリプト", "World of Stands GUIが起動しました")
