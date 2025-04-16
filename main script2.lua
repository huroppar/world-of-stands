--// Script by Masashi

-- ライブラリ読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- 状態管理変数
local speedEnabled = false
local infiniteJumpEnabled = false
local airTPEnabled = false
local airTPButtonVisible = false
local airTPKey = Enum.KeyCode.T
local lastPosition = nil
local savedSpeed = 30

-- GUIウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Masashi GUI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Masashi_Config"
})

-- タブ作成
local MainTab = Window:MakeTab({Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- スピード制御（Velocity式）
RunService.RenderStepped:Connect(function()
    if speedEnabled then
        Humanoid.WalkSpeed = 30 -- サーバー検知回避用に固定
        HumanoidRootPart.Velocity = HumanoidRootPart.CFrame.lookVector * savedSpeed
    else
        Humanoid.WalkSpeed = 30
    end
end)

-- スピードスライダーと手入力
MainTab:AddToggle({
    Name = "スピード有効化",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if not state then
            HumanoidRootPart.Velocity = Vector3.zero
            Humanoid.WalkSpeed = 30
        end
    end
})

local speedSlider
speedSlider = MainTab:AddSlider({
    Name = "速度スライダー",
    Min = 1,
    Max = 45,
    Default = 30,
    Increment = 1,
    Callback = function(value)
        savedSpeed = value
    end
})

MainTab:AddTextbox({
    Name = "速度を手入力",
    Default = "30",
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num <= 45 then
            savedSpeed = num
            speedSlider:Set(num)
        end
    end
})

-- 無限ジャンプ
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

MainTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(Value)
        infiniteJumpEnabled = Value
    end
})

-- 空中TP処理
local function teleportToAir()
    if not airTPEnabled then return end
    if not lastPosition then
        lastPosition = HumanoidRootPart.Position
        HumanoidRootPart.Anchored = true
        HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position.X, 10000, HumanoidRootPart.Position.Z)
    else
        HumanoidRootPart.CFrame = CFrame.new(lastPosition)
        HumanoidRootPart.Anchored = false
        lastPosition = nil
    end
end

-- 空中TPキー設定
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == airTPKey and airTPEnabled then
        teleportToAir()
    end
end)

MainTab:AddBind({
    Name = "空中TPキー設定",
    Default = airTPKey,
    Hold = false,
    Callback = function(Key)
        airTPKey = Key
    end
})

MainTab:AddToggle({
    Name = "空中TP機能オン/オフ",
    Default = false,
    Callback = function(Value)
        airTPEnabled = Value
    end
})

-- 空中TPボタン表示
local airTPButton = Instance.new("TextButton")
airTPButton.Text = "空中TP"
airTPButton.Size = UDim2.new(0, 100, 0, 40)
airTPButton.Position = UDim2.new(0, 200, 0, 200)
airTPButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
airTPButton.Visible = false
airTPButton.Draggable = true
airTPButton.Parent = game:GetService("CoreGui")

airTPButton.MouseButton1Click:Connect(teleportToAir)

MainTab:AddToggle({
    Name = "空中TPボタン表示切替",
    Default = false,
    Callback = function(Value)
        airTPButton.Visible = Value
    end
})
