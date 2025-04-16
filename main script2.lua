--// Script by Masashi

-- ライブラリ読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- 状態変数
local speedEnabled = false
local speedValue = 30
local infiniteJumpEnabled = false
local airTPEnabled = false
local lastPosition = nil
local airTPKey = Enum.KeyCode.T

-- GUI作成
local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Masashi GUI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Masashi_Config"
})
local MainTab = Window:MakeTab({Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- スピード変更
local function applySpeed()
    if Humanoid then
        Humanoid.WalkSpeed = speedEnabled and speedValue or 30
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    Humanoid = char:WaitForChild("Humanoid")
    task.wait(0.1)
    applySpeed()
end)

MainTab:AddToggle({
    Name = "スピード有効化",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        applySpeed()
    end
})

MainTab:AddSlider({
    Name = "スピード調整",
    Min = 1,
    Max = 500,
    Default = 30,
    Increment = 1,
    Callback = function(value)
        speedValue = value
        applySpeed()
    end
})

MainTab:AddTextbox({
    Name = "スピード数値入力",
    Default = "30",
    TextDisappear = false,
    Callback = function(text)
        local number = tonumber(text)
        if number and number >= 1 and number <= 500 then
            speedValue = number
            applySpeed()
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
    Callback = function(Value)
        infiniteJumpEnabled = Value
    end
})

-- 空中TP処理
local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function teleportToAir()
    local root = getRoot()
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

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == airTPKey and airTPEnabled then
        teleportToAir()
    end
end)

MainTab:AddToggle({
    Name = "空中TP有効化",
    Default = false,
    Callback = function(Value)
        airTPEnabled = Value
    end
})

MainTab:AddBind({
    Name = "空中TPキー設定",
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
    Name = "空中TPボタン表示",
    Default = false,
    Callback = function(Value)
        airTPButton.Visible = Value
    end
})
