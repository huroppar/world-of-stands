--// Hide the sky! GUI by Masashi

local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local speedEnabled = false
local airTPEnabled = false
local infiniteJumpEnabled = false
local velocityForce = nil
local lastPosition = nil

-- GUI
local Window = OrionLib:MakeWindow({
    Name = "Hide the sky!",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "HideTheSky_Config"
})

local MainTab = Window:MakeTab({Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- スピード
local currentSpeed = 30
local speedSlider, speedBox

MainTab:AddToggle({
    Name = "スピード変更 有効化",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if not state and velocityForce then
            velocityForce:Destroy()
            velocityForce = nil
            Humanoid.WalkSpeed = 30
        end
    end
})

speedSlider = MainTab:AddSlider({
    Name = "速度スライダー",
    Min = 1,
    Max = 500,
    Default = 30,
    Increment = 1,
    Callback = function(value)
        currentSpeed = value
        if speedEnabled then
            if not velocityForce then
                velocityForce = Instance.new("BodyVelocity")
                velocityForce.MaxForce = Vector3.new(1e9, 0, 1e9)
                velocityForce.Velocity = Vector3.zero
                velocityForce.Parent = HumanoidRootPart
            end
        end
    end
})

speedBox = MainTab:AddTextbox({
    Name = "速度を直接入力",
    Default = "30",
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num then
            currentSpeed = num
            speedSlider:Set(num)
        end
    end
})

-- 毎フレーム移動反映
RunService.RenderStepped:Connect(function()
    if speedEnabled and velocityForce and LocalPlayer.Character then
        local moveDir = Humanoid.MoveDirection
        velocityForce.Velocity = moveDir * currentSpeed
    end
end)

-- 無限ジャンプ
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        Humanoid:ChangeState("Jumping")
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
local airTPKey = Enum.KeyCode.T
local airTPButton = Instance.new("TextButton")
airTPButton.Text = "空中TP"
airTPButton.Size = UDim2.new(0, 100, 0, 40)
airTPButton.Position = UDim2.new(0, 200, 0, 200)
airTPButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
airTPButton.Visible = false
airTPButton.Draggable = true
airTPButton.Parent = game:GetService("CoreGui")

local function airTeleport()
    if not airTPEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if lastPosition == nil then
        lastPosition = root.CFrame
        root.Anchored = true
        root.CFrame = CFrame.new(root.Position.X, 10000, root.Position.Z)
    else
        root.CFrame = lastPosition
        root.Anchored = false
        lastPosition = nil
    end
end

airTPButton.MouseButton1Click:Connect(airTeleport)

MainTab:AddToggle({
    Name = "空中TP有効化",
    Default = false,
    Callback = function(Value)
        airTPEnabled = Value
    end
})

MainTab:AddBind({
    Name = "空中TPキー",
    Default = airTPKey,
    Hold = false,
    Callback = function(Key)
        airTPKey = Key
    end
})

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and airTPEnabled and input.KeyCode == airTPKey then
        airTeleport()
    end
end)

MainTab:AddToggle({
    Name = "空中TPボタン表示",
    Default = false,
    Callback = function(Value)
        airTPButton.Visible = Value
    end
})
