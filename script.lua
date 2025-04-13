local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HumanoidRootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")

local Window = OrionLib:MakeWindow({Name = "World of Stands | All-in-One", HidePremium = false, SaveConfig = true, ConfigFolder = "WOSConfig"})

-- 無限ジャンプ
game:GetService("UserInputService").JumpRequest:Connect(function()
    if LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- スピード調整
local speedValue = 16
Window:MakeTab({Name = "Speed", Icon = "rbxassetid://4483345998", PremiumOnly = false})
:AddTextbox({
    Name = "WalkSpeed",
    Default = "16",
    TextDisappear = true,
    Callback = function(Value)
        speedValue = tonumber(Value)
        LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = speedValue
    end
})

-- プレイヤー横テレポート
Window:MakeTab({Name = "Teleport", Icon = "rbxassetid://4483345998", PremiumOnly = false})
:AddTextbox({
    Name = "Player Name",
    Default = "",
    TextDisappear = true,
    Callback = function(playerName)
        local target = Players:FindFirstChild(playerName)
        if target and target.Character then
            HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
        end
    end
})

-- 上方向テレポート
local upKey = Enum.KeyCode.T
Window:MakeTab({Name = "Upward Teleport", Icon = "rbxassetid://4483345998", PremiumOnly = false})
:AddBind({
    Name = "Up Key",
    Default = upKey,
    Hold = false,
    Callback = function()
        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 20, 0)
    end
})
:AddButton({
    Name = "上にテレポート",
    Callback = function()
        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 20, 0)
    end
})

-- 透明化
local invisKey = Enum.KeyCode.V
local isInvisible = false
Window:MakeTab({Name = "Invisibility", Icon = "rbxassetid://4483345998", PremiumOnly = false})
:AddBind({
    Name = "透明化キー",
    Default = invisKey,
    Hold = false,
    Callback = function()
        isInvisible = not isInvisible
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = isInvisible and 1 or 0
                if part:FindFirstChild("face") then part.face.Transparency = isInvisible and 1 or 0 end
            end
        end
    end
})
:AddButton({
    Name = "透明化 / 非透明化",
    Callback = function()
        isInvisible = not isInvisible
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = isInvisible and 1 or 0
                if part:FindFirstChild("face") then part.face.Transparency = isInvisible and 1 or 0 end
            end
        end
    end
})

-- HP回復
Window:MakeTab({Name = "Recovery", Icon = "rbxassetid://4483345998", PremiumOnly = false})
:AddButton({
    Name = "回復",
    Callback = function()
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end
})

-- 敵を指定位置にテレポート
Window:MakeTab({Name = "Enemy Control", Icon = "rbxassetid://4483345998", PremiumOnly = false})
:AddTextbox({
    Name = "敵の名前",
    Default = "Dummy",
    TextDisappear = false,
    Callback = function(enemyName)
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find(enemyName:lower()) and v:FindFirstChild("HumanoidRootPart") then
                v.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(5, 0, 0)
            end
        end
    end
})

local previousPosition = nil

Window:MakeTab({Name = "空中移動＆戻る", Icon = "rbxassetid://4483345998", PremiumOnly = false})
:AddButton({
    Name = "空中へ / 元に戻る",
    Callback = function()
        if previousPosition == nil then
            previousPosition = HumanoidRootPart.CFrame
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 100, 0)
            OrionLib:MakeNotification({Name = "テレポート", Content = "空中に移動しました！", Time = 2})
        else
            HumanoidRootPart.CFrame = previousPosition
            previousPosition = nil
            OrionLib:MakeNotification({Name = "テレポート", Content = "元の位置に戻りました！", Time = 2})
        end
    end
})

