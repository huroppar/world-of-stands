--// Script by Masashi - Hide the sky!

local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Masashi GUI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Masashi_Config"
})

local MainTab = Window:MakeTab({Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TogglesTab = Window:MakeTab({Name = "表示切替", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- 状態変数
local speedEnabled = false
local currentSpeed = 30
local infiniteJumpEnabled = false
local airTPEnabled = false
local teleportBackPosition = nil

-- スピード管理
local SpeedSlider, SpeedBox
MainTab:AddToggle({
    Name = "スピード有効化",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if not state then
            Humanoid.WalkSpeed = 30
        end
    end
})
SpeedSlider = MainTab:AddSlider({
    Name = "速度スライダー",
    Min = 1, Max = 500, Default = 30, Increment = 1,
    Callback = function(value)
        currentSpeed = value
        if speedEnabled then
            Humanoid.WalkSpeed = value
        end
    end
})
SpeedBox = MainTab:AddTextbox({
    Name = "速度を直接入力",
    Default = "30",
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 and num <= 500 then
            currentSpeed = num
            SpeedSlider:Set(num)
            if speedEnabled then
                Humanoid.WalkSpeed = num
            end
        end
    end
})
RunService.Heartbeat:Connect(function()
    if speedEnabled and Humanoid.WalkSpeed ~= currentSpeed then
        Humanoid.WalkSpeed = currentSpeed
    end
end)

-- 無限ジャンプ
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
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

-- 空中TP
local airTPButton = Instance.new("TextButton")
airTPButton.Text = "空中TP"
airTPButton.Size = UDim2.new(0, 100, 0, 40)
airTPButton.Position = UDim2.new(0, 200, 0, 200)
airTPButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
airTPButton.Visible = false
airTPButton.Draggable = true
airTPButton.Parent = game:GetService("CoreGui")

local function teleportToAir()
    if not HumanoidRootPart then return end
    if not teleportBackPosition then
        teleportBackPosition = HumanoidRootPart.CFrame
        HumanoidRootPart.Anchored = true
        HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position.X, 10000, HumanoidRootPart.Position.Z)
    else
        HumanoidRootPart.CFrame = teleportBackPosition
        HumanoidRootPart.Anchored = false
        teleportBackPosition = nil
    end
end

airTPButton.MouseButton1Click:Connect(teleportToAir)

MainTab:AddToggle({
    Name = "空中TPボタン表示",
    Default = false,
    Callback = function(state)
        airTPButton.Visible = state
    end
})

MainTab:AddToggle({
    Name = "空中TPオン/オフ",
    Default = false,
    Callback = function(state)
        airTPEnabled = state
    end
})

local airTPKey = Enum.KeyCode.T
MainTab:AddBind({
    Name = "空中TPキー設定",
    Default = airTPKey,
    Hold = false,
    Callback = function(Key)
        airTPKey = Key
    end
})

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == airTPKey and airTPEnabled then
        teleportToAir()
    end
end)
