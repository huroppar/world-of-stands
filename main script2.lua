--// Script by Masashi

local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- 状態管理
local speedEnabled = false
local infiniteJumpEnabled = false
local airTPEnabled = false
local invisibilityEnabled = false
local lastPosition = nil
local airTPKey = Enum.KeyCode.T

-- Util
local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- GUI作成
local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Masashi GUI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Masashi_Config"
})

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

MainTab:AddSlider({
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

MainTab:AddTextbox({
    Name = "速度を直接入力",
    Default = "30",
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and speedEnabled then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = num
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
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(Value)
        infiniteJumpEnabled = Value
    end
})

-- 空中TP機能本体
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

UserInputService.InputBegan:Connect(function(input, gpe)
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

-- ボタン（後から作成することで安全に参照できる）
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
        airTPEnabled = Value
    end
})

-- 透明化ボタン
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
