--// OrionLib 読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

--// GUI 初期化
local Window = OrionLib:MakeWindow({Name = "Masashi式スクリプト", HidePremium = false, SaveConfig = true, ConfigFolder = "MasashiTools"})
local Tab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// 共通変数
local speedValue = 16
local speedEnabled = false
local infiniteJump = false
local wallWalk = false
local highlightEnabled = false
local airTPEnabled = false
local showTPButton = true
local airTPInUse = false
local savedPosition = nil

--// スピード機能
Tab:AddToggle({
    Name = "スピード変更 ON/OFF",
    Default = false,
    Callback = function(v)
        speedEnabled = v
    end
})

Tab:AddSlider({
    Name = "スピード調整",
    Min = 1,
    Max = 500,
    Default = 16,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(v)
        speedValue = v
    end
})

Tab:AddTextbox({
    Name = "スピード手入力",
    Default = tostring(speedValue),
    TextDisappear = false,
    Callback = function(v)
        local num = tonumber(v)
        if num then
            speedValue = math.clamp(num, 1, 500)
        end
    end
})

-- スピード反映ループ
RunService.RenderStepped:Connect(function()
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
    end
end)

--// 無限ジャンプ
Tab:AddToggle({
    Name = "無限ジャンプ ON/OFF",
    Default = false,
    Callback = function(v)
        infiniteJump = v
    end
})

-- 無限ジャンプ処理
local UserInputService = game:GetService("UserInputService")
UserInputService.JumpRequest:Connect(function()
    if infiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character:ChangeState("Jumping")
    end
end)

--// 空中TP 機能
Tab:AddToggle({
    Name = "空中TP ON/OFF",
    Default = false,
    Callback = function(v)
        airTPEnabled = v
    end
})

Tab:AddToggle({
    Name = "空中TPボタン 表示/非表示",
    Default = true,
    Callback = function(v)
        showTPButton = v
        if TPButton then TPButton.Visible = v end
    end
})

-- 空中TPボタン作成
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local TPButton = Instance.new("TextButton")
TPButton.Size = UDim2.new(0, 200, 0, 50)
TPButton.Position = UDim2.new(0.5, -100, 1, -100)
TPButton.Text = "空中TP"
TPButton.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
TPButton.TextColor3 = Color3.new(1, 1, 1)
TPButton.Draggable = true
TPButton.Active = true
TPButton.Visible = true
TPButton.Parent = ScreenGui

TPButton.MouseButton1Click:Connect(function()
    if not airTPEnabled then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if not airTPInUse then
            savedPosition = hrp.Position
            hrp.CFrame = CFrame.new(hrp.Position.X, 10000, hrp.Position.Z)
            airTPInUse = true
        else
            hrp.CFrame = CFrame.new(savedPosition)
            airTPInUse = false
        end
    end
end)

--// キャラクターハイライト
Tab:AddToggle({
    Name = "ハイライト（自分+敵） ON/OFF",
    Default = false,
    Callback = function(v)
        highlightEnabled = v

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Highlight") and (v.Name == "PlayerHL" or v.Name == "EnemyHL") then
                v:Destroy()
            end
        end

        if v then
            -- 自分
            local hl = Instance.new("Highlight")
            hl.Name = "PlayerHL"
            hl.FillColor = Color3.fromRGB(0, 255, 0)
            hl.OutlineColor = Color3.fromRGB(0, 100, 0)
            hl.Adornee = LocalPlayer.Character
            hl.Parent = LocalPlayer.Character

            -- 敵（Humanoid付き）
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v ~= LocalPlayer.Character and v:FindFirstChild("Humanoid") then
                    local ehl = Instance.new("Highlight")
                    ehl.Name = "EnemyHL"
                    ehl.FillColor = Color3.fromRGB(255, 0, 0)
                    ehl.OutlineColor = Color3.fromRGB(100, 0, 0)
                    ehl.Adornee = v
                    ehl.Parent = v
                end
            end
        end
    end
})

--// 壁貫通（Noclip）
Tab:AddToggle({
    Name = "壁貫通 ON/OFF",
    Default = false,
    Callback = function(v)
        wallWalk = v
    end
})

-- Noclip処理
RunService.Stepped:Connect(function()
    if wallWalk and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- GUI起動通知
OrionLib:MakeNotification({
    Name = "Masashiツール起動",
    Content = "すべての機能が有効です！",
    Image = "rbxassetid://4483345998",
    Time = 5
})
