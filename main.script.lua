--[[
    World of Stands Most Useful Script - Rebuild
    Author: Masashi
    Key: Masashi0407
--]]

if not game:IsLoaded() then game.Loaded:Wait() end
if _G.__WOS_GUI_RUNNING then return end
_G.__WOS_GUI_RUNNING = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

--// Key System
local allowedUsers = {
    ["Furoppersama"] = true,
    ["Furopparsama"] = true
}
local correctKey = "Masashi0407"
if not allowedUsers[LocalPlayer.Name] then
    local inputKey = OrionLib:Prompt("Key Required", "Enter your key to use the script:")
    while inputKey ~= correctKey do
        OrionLib:Notify("Wrong Key", "Try again.", 3)
        inputKey = OrionLib:Prompt("Key Required", "Enter your key to use the script:")
    end
    OrionLib:Notify("Access Granted", "Welcome!", 3)
end

--// GUI Setup
local Window = OrionLib:MakeWindow({Name = "🌟 WOS | Masashi Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "MasashiWOS"})

--// Speed Control
local SpeedTab = Window:MakeTab({Name = "Speed", Icon = "rbxassetid://6026568198", PremiumOnly = false})
local speedValue = 16
local speedEnabled = false

SpeedTab:AddToggle({
    Name = "Speed Toggle",
    Default = false,
    Callback = function(v)
        speedEnabled = v
    end
})

SpeedTab:AddSlider({
    Name = "Speed (1~500)",
    Min = 1,
    Max = 500,
    Default = 16,
    Callback = function(v)
        speedValue = v
    end
})

SpeedTab:AddTextbox({
    Name = "Manual Speed Input",
    Default = tostring(speedValue),
    TextDisappear = false,
    Callback = function(v)
        local num = tonumber(v)
        if num then
            speedValue = math.clamp(num, 1, 500)
        end
    end
})

RunService.RenderStepped:Connect(function()
    pcall(function()
        if speedEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.WalkSpeed ~= speedValue then
                hum.WalkSpeed = speedValue
            end
        end
    end)
end)

--// Player List
local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "rbxassetid://6031094678", PremiumOnly = false})
local playerNames = {}

local function updatePlayers()
    table.clear(playerNames)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerNames, p.Name)
        end
    end
end

updatePlayers()
Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

TeleportTab:AddDropdown({
    Name = "Teleport to Player",
    Default = "",
    Options = playerNames,
    Callback = function(selected)
        local target = Players:FindFirstChild(selected)
        if target and target.Character then
            LocalPlayer.Character:PivotTo(target.Character:GetPivot() + Vector3.new(3, 0, 3))
        end
    end
})

--// Fly (Air TP) Button
local flyTab = Window:MakeTab({Name = "Air Tools", Icon = "rbxassetid://6031260795", PremiumOnly = false})
local flyBtn

flyTab:AddButton({
    Name = "Air Teleport",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local originalCFrame = root.CFrame
        root.Anchored = true
        root.CFrame = root.CFrame + Vector3.new(0, 10000, 0)
        wait(1)
        root.Anchored = false
        wait(0.5)
        root.CFrame = originalCFrame
    end
})

--// GUI Minimize
local toggle = false
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        toggle = not toggle
        Window.Enabled = toggle
    end
end)

OrionLib:Init()








-- キーシステム（※GUIで対応すべきなので一旦無効化）
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local allowedUsers = {
    ["Furoppersama"] = true,
    ["Furopparsama"] = true
}

if not allowedUsers[LocalPlayer.Name] then
    warn("許可されていないユーザーです")
    return
end

-- GUIライブラリの読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Window = OrionLib:MakeWindow({Name = "World of Stands Utility", HidePremium = false, SaveConfig = true, ConfigFolder = "WOS_Config"})
local MainTab = Window:MakeTab({ Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false })

-- スピード制御
local speedEnabled = false
local speedValue = 16
local speedConnection

MainTab:AddToggle({
    Name = "スピード有効化",
    Default = false,
    Callback = function(value)
        speedEnabled = value
        if value then
            if speedConnection then speedConnection:Disconnect() end
            speedConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
                end
            end)
        else
            if speedConnection then speedConnection:Disconnect() end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

MainTab:AddSlider({
    Name = "スピード調整",
    Min = 1,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        speedValue = value
    end
})

-- 無限ジャンプ
local infiniteJumpEnabled = false

MainTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(value)
        infiniteJumpEnabled = value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 壁貫通（Noclip）
local noclipEnabled = false

MainTab:AddToggle({
    Name = "壁貫通（Noclip）",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
    end
})

game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 空中TPボタン
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "TeleportGui"

local floatingButton = Instance.new("TextButton")
floatingButton.Size = UDim2.new(0, 100, 0, 50)
floatingButton.Position = UDim2.new(0.5, -50, 1, -100)
floatingButton.Text = "空中TP"
floatingButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingButton.Parent = screenGui
floatingButton.Active = true
floatingButton.Draggable = true
floatingButton.Visible = teleportButtonVisible

MainTab:AddToggle({  -- ← GUIの表示切り替え
    Name = "空中TPボタン表示",
    Default = true,
    Callback = function(value)
        teleportButtonVisible = value
        if floatingButton then
            floatingButton.Visible = value
        end
    end
})

local floating = false
local originalPosition

floatingButton.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if not floating then
            originalPosition = hrp.Position
            hrp.Anchored = true -- ← 落下防止
            hrp.CFrame = hrp.CFrame + Vector3.new(0, -5000, 0)
            floating = true
        else
            hrp.Anchored = false -- ← 元に戻す
            hrp.CFrame = CFrame.new(originalPosition)
            floating = false
        end
    end
end)


-- 敵BOT集め機能
local function gatherEnemies()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, enemy in pairs(workspace:GetDescendants()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            local hrp = enemy.HumanoidRootPart
            local distance = (root.Position - hrp.Position).Magnitude
            if distance <= gatherDistance then
                hrp.Anchored = true
                hrp.CFrame = root.CFrame * CFrame.new(0, 0, -5)
                enemy.Humanoid.WalkSpeed = 0
                enemy.Humanoid.JumpPower = 0
                if enemy:FindFirstChild("Target") then
                    enemy.Target.Value = nil
                end
                for _, s in pairs(enemy:GetChildren()) do
                    if s:IsA("Script") then s.Disabled = true end
                end
            end
        end
    end
end


MainTab:AddButton({
    Name = "敵を集める",
    Callback = function()
        gatherEnemies()
    end
})

local gatherDistance = 50

MainTab:AddSlider({
    Name = "敵集め 距離（スライダー）",
    Min = 10,
    Max = 500,
    Default = 50,
    Increment = 10,
    ValueName = "Studs",
    Callback = function(value)
        gatherDistance = value
    end
})

MainTab:AddTextbox({
    Name = "敵集め 距離（手入力）",
    Default = "50",
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 then
            gatherDistance = num
        end
    end
})

-- プレイヤー一覧
local selectedPlayer = nil
local dropdown

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

local function createDropdown()
    if dropdown then dropdown:Destroy() end
    dropdown = MainTab:AddDropdown({
        Name = "プレイヤーを選択",
        Default = "",
        Options = getPlayerNames(),
        Callback = function(value)
            selectedPlayer = value
        end
    })
end

createDropdown()

MainTab:AddButton({
    Name = "選択したプレイヤーの近くにテレポート",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 2)
        end
    end
})

MainTab:AddButton({
    Name = "プレイヤーリストを更新",
    Callback = function()
        createDropdown()
        OrionLib:MakeNotification({
            Name = "更新完了",
            Content = "プレイヤー一覧を更新しました！",
            Time = 3
        })
    end
})

-- スクリプト完了通知
OrionLib:MakeNotification({
    Name = "WOSユーティリティ",
    Content = "スクリプトの読み込みが完了しました！ - by Masashi",
    Time = 5
})
