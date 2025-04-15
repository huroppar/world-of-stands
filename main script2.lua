local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Ultimate Tool",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_UltimateTool"
})

local MainTab = Window:MakeTab({
    Name = "機能一覧",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

------------------------------
-- Speedコントロール機能
------------------------------
local speedValue = 30
local speedEnabled = false

MainTab:AddToggle({
    Name = "Speed On/Off",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        Humanoid.WalkSpeed = state and speedValue or 30
    end
})

local speedSlider = MainTab:AddSlider({
    Name = "Speed Slider",
    Min = 1,
    Max = 500,
    Default = speedValue,
    Increment = 1,
    Callback = function(value)
        speedValue = value
        if speedEnabled then Humanoid.WalkSpeed = value end
    end
})

MainTab:AddTextbox({
    Name = "Speed数値入力",
    Default = tostring(speedValue),
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 and num <= 500 then
            speedValue = num
            speedSlider:Set(num)
            if speedEnabled then Humanoid.WalkSpeed = num end
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "1〜500の数字を入れてね！",
                Time = 3
            })
        end
    end
})

-- Speed維持ループ
task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if speedEnabled and Humanoid then
            Humanoid.WalkSpeed = speedValue
        end
    end
end)

------------------------------
-- 空中テレポート機能
------------------------------
local teleportKey = Enum.KeyCode.Y
local isInAir = false
local originalCFrame = nil
local airTeleportEnabled = true

MainTab:AddToggle({
    Name = "空中TP On/Off",
    Default = true,
    Callback = function(state)
        airTeleportEnabled = state
        OrionLib:MakeNotification({
            Name = "空中TP",
            Content = state and "空中TPを有効化したよ！" or "無効化したよ！",
            Time = 2
        })
    end
})

MainTab:AddDropdown({
    Name = "空中TPキー設定",
    Default = "Y",
    Options = {"Q","E","R","T","Y","U","I","O","P","Z","X","C","V","B","N","M"},
    Callback = function(key)
        teleportKey = Enum.KeyCode[key]
        OrionLib:MakeNotification({
            Name = "キー設定完了",
            Content = "空中TPキーを ["..key.."] にしたよ！",
            Time = 3
        })
    end
})

local function toggleAirTeleport()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not airTeleportEnabled or not root then return end

    if not isInAir then
        originalCFrame = root.CFrame
        root.Anchored = true
        root.CFrame = CFrame.new(root.Position.X, 10000, root.Position.Z)
        isInAir = true
    else
        root.CFrame = originalCFrame
        task.wait(0.1)
        root.Anchored = false
        isInAir = false
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == teleportKey then
        toggleAirTeleport()
    end
end)

-- 画面ボタン
local teleportButton = nil
MainTab:AddToggle({
    Name = "空中TPボタン表示",
    Default = false,
    Callback = function(state)
        if teleportButton then
            teleportButton.Visible = state
        end
    end
})

local function createTeleportButton()
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    gui.Name = "TeleportGui"
    gui.ResetOnSpawn = false

    teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(0, 140, 0, 40)
    teleportButton.Position = UDim2.new(0.5, -70, 0.85, 0)
    teleportButton.Text = "空中TP"
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.TextScaled = true
    teleportButton.Visible = false
    teleportButton.Draggable = true
    teleportButton.Parent = gui

    teleportButton.MouseButton1Click:Connect(toggleAirTeleport)
end

createTeleportButton()

------------------------------
-- 無限ジャンプ機能
------------------------------
local infiniteJumpEnabled = false

MainTab:AddToggle({
    Name = "無限ジャンプ On/Off",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
        OrionLib:MakeNotification({
            Name = "無限ジャンプ",
            Content = state and "ONにしたよ！" or "OFFにしたよ！",
            Time = 2
        })
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

------------------------------
-- 透明化機能
------------------------------
local isInvisible = false
local savedParts = {}
local remoteHitboxPart = nil

local function makeInvisible()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            savedParts[part] = part.Transparency
            part.Transparency = 1
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    local root = Character:FindFirstChild("HumanoidRootPart")
    if root then
        remoteHitboxPart = Instance.new("Part")
        remoteHitboxPart.Size = Vector3.new(2, 2, 1)
        remoteHitboxPart.Anchored = true
        remoteHitboxPart.CanCollide = false
        remoteHitboxPart.Transparency = 1
        remoteHitboxPart.Name = "InvisibleHitbox"
        remoteHitboxPart.Parent = workspace
        remoteHitboxPart.CFrame = CFrame.new(0, 10000, 0)

        root:BreakJoints()
        root.CFrame = remoteHitboxPart.CFrame
        root.Anchored = true
    end
end

local function revertVisibility()
    for part, transparency in pairs(savedParts) do
        if part and part:IsDescendantOf(Character) then
            part.Transparency = transparency
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    savedParts = {}

    local root = Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Anchored = false
        root.CFrame = CFrame.new(root.Position.X, 5, root.Position.Z)
    end

    if remoteHitboxPart then
        remoteHitboxPart:Destroy()
        remoteHitboxPart = nil
    end
end

MainTab:AddToggle({
    Name = "透明化 On/Off",
    Default = false,
    Callback = function(state)
        isInvisible = state
        if isInvisible then
            makeInvisible()
        else
            revertVisibility()
        end
        OrionLib:MakeNotification({
            Name = "透明化",
            Content = state and "キャラを透明にしたよ！" or "元に戻したよ！",
            Time = 3
        })
    end
})
