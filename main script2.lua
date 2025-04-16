--// Script by Masashi

-- ライブラリとサービス
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

-- 状態
local speedEnabled = false
local currentSpeed = 30
local infiniteJumpEnabled = false
local airTPEnabled = false
local airTPKey = Enum.KeyCode.T
local airTPButtonVisible = false
local savedTPPosition = nil
local airTPButton

-- GUI初期化
local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Masashi GUI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Masashi_Config"
})

local MainTab = Window:MakeTab({Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- スピード変更
MainTab:AddToggle({
    Name = "スピード変更 有効化",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if not state then
            currentSpeed = 30
            Humanoid.WalkSpeed = 30
        else
            Humanoid.WalkSpeed = currentSpeed
        end
    end
})

MainTab:AddSlider({
    Name = "スピードスライダー",
    Min = 1,
    Max = 500,
    Default = 30,
    Increment = 1,
    Callback = function(value)
        currentSpeed = value
        if speedEnabled then
            Humanoid.WalkSpeed = value
        end
    end
})

MainTab:AddTextbox({
    Name = "スピードを手入力",
    Default = "30",
    TextDisappear = false,
    Callback = function(input)
        local num = tonumber(input)
        if num then
            currentSpeed = num
            if speedEnabled then
                Humanoid.WalkSpeed = num
            end
        end
    end
})

-- スピード維持
RunService.Stepped:Connect(function()
    if speedEnabled and Humanoid then
        Humanoid.WalkSpeed = currentSpeed
    end
end)

-- 無限ジャンプ
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

MainTab:AddToggle({
    Name = "無限ジャンプ 有効化",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
    end
})

-- 空中TP処理
local function teleportAir()
    if not Root then return end
    if not savedTPPosition then
        savedTPPosition = Root.Position
        Root.Anchored = true
        Root.CFrame = CFrame.new(Root.Position.X, 10000, Root.Position.Z)
    else
        Root.CFrame = CFrame.new(savedTPPosition)
        Root.Anchored = false
        savedTPPosition = nil
    end
end

-- キー割当
MainTab:AddBind({
    Name = "空中TPキー",
    Default = airTPKey,
    Hold = false,
    Callback = function(key)
        airTPKey = key
    end
})

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == airTPKey and airTPEnabled then
        teleportAir()
    end
end)

-- 空中TPボタン作成
airTPButton = Instance.new("TextButton")
airTPButton.Text = "空中TP"
airTPButton.Size = UDim2.new(0, 100, 0, 40)
airTPButton.Position = UDim2.new(0, 200, 0, 300)
airTPButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
airTPButton.Visible = false
airTPButton.Draggable = true
airTPButton.Parent = CoreGui

airTPButton.MouseButton1Click:Connect(function()
    if airTPEnabled then
        teleportAir()
    end
end)

MainTab:AddToggle({
    Name = "空中TPボタン 表示",
    Default = false,
    Callback = function(state)
        airTPButtonVisible = state
        airTPButton.Visible = state
    end
})

MainTab:AddToggle({
    Name = "空中TP機能 オンオフ",
    Default = false,
    Callback = function(state)
        airTPEnabled = state
    end
})
