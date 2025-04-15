--// Script by Masashi

-- ライブラリ読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- 状態管理変数
local savedPosition = nil
local speedEnabled = false
local infiniteJumpEnabled = false
local transparencyEnabled = false
local teleportBackPosition = nil
local airTeleporting = false

-- GUIウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Masashi GUI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Masashi_Config"
})

-- タブ作成
local MainTab = Window:MakeTab({Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TogglesTab = Window:MakeTab({Name = "表示切替", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- スピード機能
local SpeedSlider
local SpeedBox
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
SpeedSlider = MainTab:AddSlider({
    Name = "速度スライダー",
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
SpeedBox = MainTab:AddTextbox({
    Name = "速度を直接入力",
    Default = "30",
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and speedEnabled then
            SpeedSlider:Set(num)
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = num
        end
    end
})
'''

-- 無限ジャンプ
local uis = game:GetService("UserInputService")
local infiniteJumpEnabled = false
uis.JumpRequest:Connect(function()
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

-- 空中TP
local airTPEnabled = false
local lastPosition = nil
local airTPKey = Enum.KeyCode.T
local airTPButtonVisible = false

local function teleportToAir()
    if not airTPEnabled then return end
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

uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == airTPKey and airTPEnabled then
        teleportToAir()
    end
end)

MainTab:AddBind({
    Name = "空中TPキー",
    Default = airTPKey,
    Hold = false,
    Callback = function(Key)
        airTPKey = Key
    end
})

MainTab:AddToggle({
    Name = "空中TPボタン表示",
    Default = false,
    Callback = function(Value)
        airTPButton.Visible = Value
        airTPEnabled = Value
    end
})

-- 空中TPボタン作成
local airTPButton = Instance.new("TextButton")
airTPButton.Text = "空中TP"
airTPButton.Size = UDim2.new(0, 100, 0, 40)
airTPButton.Position = UDim2.new(0, 200, 0, 200)
airTPButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
airTPButton.Visible = false
airTPButton.Draggable = true
airTPButton.Parent = game:GetService("CoreGui")

airTPButton.MouseButton1Click:Connect(teleportToAir)

-- 透明化
local invisibilityEnabled = false
local invisButton = Instance.new("TextButton")
invisButton.Text = "透明化"
invisButton.Size = UDim2.new(0, 100, 0, 40)
invisButton.Position = UDim2.new(0, 200, 0, 250)
invisButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
invisButton.Visible = false
invisButton.Draggable = true
invisButton.Parent = game:GetService("CoreGui")

invisButton.MouseButton1Click:Connect(function()
    invisibilityEnabled = not invisibilityEnabled
    local character = LocalPlayer.Character
    if character then
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.Transparency = invisibilityEnabled and 1 or 0
                if v:IsA("BasePart") then
                    v.CanCollide = not invisibilityEnabled
                end
            end
        end
    end
end)

MainTab:AddToggle({
    Name = "透明化ボタン表示",
    Default = false,
    Callback = function(Value)
        invisButton.Visible = Value
    end
})
