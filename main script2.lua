-- OrionLib 読み込み（GitHub対応）
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local window = OrionLib:MakeWindow({Name="World of Stands Utility", HidePremium=false, SaveConfig=true, ConfigFolder="WOS_Config"})

-- 状態管理変数
local speedEnabled = false
local infiniteJumpEnabled = false
local invisible = false
local airTPEnabled = false
local storedPosition = nil
local airTPKey = Enum.KeyCode.T
local dragEnabled = false

-- スピード設定
local currentSpeed = 30

-- UI初期設定
local mainTab = window:MakeTab({Name="Main", Icon="rbxassetid://4483345998", PremiumOnly=false})

-- スピード機能
mainTab:AddToggle({
    Name="Speed ON/OFF",
    Default=false,
    Callback=function(value)
        speedEnabled = value
        if not value then humanoid.WalkSpeed = 30 end
    end
})

mainTab:AddSlider({
    Name="Speed",
    Min=1,
    Max=500,
    Default=30,
    Increment=1,
    Callback=function(value)
        currentSpeed = value
        if speedEnabled then humanoid.WalkSpeed = value end
    end
})

mainTab:AddTextbox({
    Name="Speed Input",
    Default="30",
    TextDisappear=true,
    Callback=function(text)
        local num = tonumber(text)
        if num then
            currentSpeed = math.clamp(num, 1, 500)
            if speedEnabled then humanoid.WalkSpeed = currentSpeed end
        end
    end
})

-- 無限ジャンプ機能
mainTab:AddToggle({
    Name="Infinite Jump",
    Default=false,
    Callback=function(state)
        infiniteJumpEnabled = state
    end
})

-- 完全透明化用のボタン（表示/非表示）
mainTab:AddToggle({
    Name="透明ボタンを表示",
    Default=false,
    Callback=function(show)
        invisibleButton.Visible = show
    end
})

-- 空中TPボタン表示切替
mainTab:AddToggle({
    Name="空中TPボタンを表示",
    Default=false,
    Callback=function(show)
        airTPButton.Visible = show
    end
})

-- 空中TPキー設定
mainTab:AddTextbox({
    Name="空中TPキー（例: T）",
    Default="T",
    TextDisappear=true,
    Callback=function(input)
        local kc = Enum.KeyCode[input:upper()]
        if kc then airTPKey = kc end
    end
})

-- 無限ジャンプ処理
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        humanoid:ChangeState("Jumping")
    end
end)

-- スピード常時更新処理
RunService.Heartbeat:Connect(function()
    if speedEnabled then
        humanoid.WalkSpeed = currentSpeed
    end
end)

-- 空中TP処理
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == airTPKey then
        if not airTPEnabled then
            storedPosition = hrp.Position
            hrp.Anchored = true
            hrp.CFrame = CFrame.new(hrp.Position.X, 10000, hrp.Position.Z)
            airTPEnabled = true
        else
            hrp.CFrame = CFrame.new(storedPosition)
            task.wait(0.1)
            hrp.Anchored = false
            airTPEnabled = false
        end
    end
end)

-- ドラッグ可能な透明ボタン生成
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "Masashi_TransparentButtons"
local function createDraggableButton(name, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = UDim2.new(0.5, -60, 0.5, 0)
    btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.Parent = ScreenGui
    btn.Visible = false

    btn.MouseButton1Down:Connect(function()
        dragEnabled = true
    end)
    btn.MouseButton1Up:Connect(function()
        dragEnabled = false
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragEnabled and input.UserInputType == Enum.UserInputType.MouseMovement then
            btn.Position = UDim2.new(0, input.Position.X, 0, input.Position.Y)
        end
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 空中TPボタン（ドラッグ可）
airTPButton = createDraggableButton("AirTP", "空中TP", function()
    if not airTPEnabled then
        storedPosition = hrp.Position
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(hrp.Position.X, 10000, hrp.Position.Z)
        airTPEnabled = true
    else
        hrp.CFrame = CFrame.new(storedPosition)
        task.wait(0.1)
        hrp.Anchored = false
        airTPEnabled = false
    end
end)

-- 透明化ボタン（ドラッグ可）
invisibleButton = createDraggableButton("Invisible", "透明化", function()
    invisible = not invisible
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.LocalTransparencyModifier = invisible and 1 or 0
        end
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not invisible
        end
    end
end)
