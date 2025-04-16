-- // Script by Masashi

-- ライブラリ読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- 状態変数
local speedEnabled = false
local infiniteJumpEnabled = false
local airTPEnabled = false
local airTPKey = Enum.KeyCode.T
local airTPButtonVisible = false
local lastAirTPPosition = nil

-- GUIウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Masashi GUI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Masashi_Config"
})

-- タブ
local MainTab = Window:MakeTab({Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- スピード機能
MainTab:AddToggle({
    Name = "スピード変更 有効化",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if not state then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 30
        end
    end
})

local SpeedSlider = MainTab:AddSlider({
    Name = "スピード調整",
    Min = 1,
    Max = 500,
    Default = 30,
    Increment = 1,
    Callback = function(value)
        if speedEnabled then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
})

MainTab:AddTextbox({
    Name = "スピードを手入力",
    Default = "30",
    TextDisappear = false,
    Callback = function(input)
        local speed = tonumber(input)
        if speed and speedEnabled then
            SpeedSlider:Set(speed)
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
        end
    end
})

-- 無限ジャンプ
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

MainTab:AddToggle({
    Name = "無限ジャンプ 有効化",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
    end
})

-- 空中TPキー設定
MainTab:AddBind({
    Name = "空中TPキー設定",
    Default = airTPKey,
    Hold = false,
    Callback = function(key)
        airTPKey = key
    end
})

-- 空中TP ON/OFFトグル
MainTab:AddToggle({
    Name = "空中TP 有効化",
    Default = false,
    Callback = function(state)
        airTPEnabled = state
    end
})

-- 空中TP関数
local function teleportToAir()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if not lastAirTPPosition then
        lastAirTPPosition = root.CFrame
        root.Anchored = true
        root.CFrame = CFrame.new(root.Position.X, 10000, root.Position.Z)
    else
        root.CFrame = lastAirTPPosition
        root.Anchored = false
        lastAirTPPosition = nil
    end
end

-- 空中TPキー入力で実行
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if airTPEnabled and input.KeyCode == airTPKey then
        teleportToAir()
    end
end)

-- 空中TPボタン
local CoreGui = game:GetService("CoreGui")
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "AirTPGui"

local airTPButton = Instance.new("TextButton")
airTPButton.Name = "AirTPButton"
airTPButton.Text = "空中TP"
airTPButton.Size = UDim2.new(0, 100, 0, 40)
airTPButton.Position = UDim2.new(0, 300, 0, 300)
airTPButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
airTPButton.Visible = false
airTPButton.Draggable = true
airTPButton.Parent = screenGui

airTPButton.MouseButton1Click:Connect(function()
    if airTPEnabled then
        teleportToAir()
    end
end)

MainTab:AddToggle({
    Name = "空中TPボタン 表示",
    Default = false,
    Callback = function(state)
        airTPButton.Visible = state
    end
})
