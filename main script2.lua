--// Script by Masashi

-- ライブラリ読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- 状態管理変数
local speedEnabled = false
local infiniteJumpEnabled = false
local airTPEnabled = false
local lastPosition = nil
local airTPKey = Enum.KeyCode.T
local airTPButtonVisible = false
local currentSpeed = 30

-- GUIウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Masashi GUI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Masashi_Config"
})

-- タブ作成
local MainTab = Window:MakeTab({Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- スピード制御
local speedSlider

MainTab:AddToggle({
    Name = "スピード変更オン/オフ",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if not state then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 30
        else
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = currentSpeed
        end
    end
})

speedSlider = MainTab:AddSlider({
    Name = "速度スライダー (1〜500)",
    Min = 1,
    Max = 500,
    Default = 30,
    Increment = 1,
    Callback = function(value)
        currentSpeed = value
        if speedEnabled then
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
            speedSlider:Set(num)
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = num
        end
    end
})

task.spawn(function()
    while true do
        task.wait(0.2)
        if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum.WalkSpeed ~= currentSpeed then
                hum.WalkSpeed = currentSpeed
            end
        end
    end
end)

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
    Name = "無限ジャンプ オン/オフ",
    Default = false,
    Callback = function(Value)
        infiniteJumpEnabled = Value
    end
})

-- 空中TP関数
local function teleportToAir()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
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

-- 空中TPキー
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == airTPKey and airTPEnabled then
        teleportToAir()
    end
end)

MainTab:AddBind({
    Name = "空中TPキー割当",
    Default = airTPKey,
    Hold = false,
    Callback = function(Key)
        airTPKey = Key
    end
})

-- 空中TPボタン
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
    Name = "空中TPボタン 表示/非表示",
    Default = false,
    Callback = function(Value)
        airTPButton.Visible = Value
        airTPEnabled = Value
    end
})
