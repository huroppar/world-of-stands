-- GUI作成（OrionLib不要）
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WOS_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- タイトル
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "🌀 Stand Power Controller"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

-- Speed入力欄
local SpeedBox = Instance.new("TextBox")
SpeedBox.PlaceholderText = "Speedを入力"
SpeedBox.Size = UDim2.new(0.9, 0, 0, 30)
SpeedBox.Position = UDim2.new(0.05, 0, 0, 60)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.TextSize = 14
SpeedBox.Parent = Frame

-- 実行ボタン
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0.9, 0, 0, 30)
Button.Position = UDim2.new(0.05, 0, 0, 100)
Button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
Button.Text = "適用"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Button.Parent = Frame

-- ボタン押したときの処理
Button.MouseButton1Click:Connect(function()
    local inputSpeed = tonumber(SpeedBox.Text)
    if inputSpeed then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = inputSpeed
            print("Speed変更: " .. inputSpeed)
        end
    end
end)
