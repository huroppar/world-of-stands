--// Script by Masashi

-- ライブラリとサービス
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- 状態変数
local airTPEnabled = false
local airTPButton = nil
local lastPosition = nil
local infiniteJumpEnabled = false
local speedEnabled = false
local currentSpeed = 30

-- GUI作成
local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Masashi GUI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Masashi_Config"
})

local MainTab = Window:MakeTab({Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- スピード制御
MainTab:AddToggle({
    Name = "スピード変更オン/オフ",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if not state then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 30
        end
    end
})

MainTab:AddSlider({
    Name = "速度スライダー (1〜500)",
    Min = 1,
    Max = 500,
    Default = 30,
    Increment = 1,
    Callback = function(value)
        if speedEnabled then
            currentSpeed = value
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
})

MainTab:AddTextbox({
    Name = "速度を手入力",
    Default = "30",
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and speedEnabled then
            currentSpeed = num
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = num
        end
    end
})

-- 無限ジャンプ
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

MainTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
    end
})

-- 空中TPボタン作成
airTPButton = Instance.new("TextButton")
airTPButton.Size = UDim2.new(0, 100, 0, 40)
airTPButton.Position = UDim2.new(0, 200, 0, 200)
airTPButton.Text = "空中TP"
airTPButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
airTPButton.TextColor3 = Color3.new(0, 0, 0)
airTPButton.Visible = false
airTPButton.Draggable = true
airTPButton.Parent = CoreGui

airTPButton.MouseButton1Click:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        if not lastPosition then
            lastPosition = root.Position
            root.Anchored = true
            root.CFrame = CFrame.new(root.Position.X, 10000, root.Position.Z)
        else
            root.CFrame = CFrame.new(lastPosition)
            root.Anchored = false
            lastPosition = nil
        end
    end
end)

MainTab:AddToggle({
    Name = "空中TPボタン表示",
    Default = false,
    Callback = function(state)
        airTPButton.Visible = state
        airTPEnabled = state
    end
})
