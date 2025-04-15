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

-- 完全透明化機能
local isInvisible = false
local originalCFrame = nil
local dummyPart = nil

local function makeInvisible()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    originalCFrame = character:GetPrimaryPartCFrame()

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
            if part:FindFirstChildOfClass("Decal") then
                for _, decal in ipairs(part:GetChildren()) do
                    if decal:IsA("Decal") then
                        decal.Transparency = 1
                    end
                end
            end
        elseif part:IsA("Accessory") then
            part:Destroy()
        end
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        dummyPart = Instance.new("Part")
        dummyPart.Name = "HiddenHitbox"
        dummyPart.Size = Vector3.new(4, 4, 1)
        dummyPart.Anchored = true
        dummyPart.Transparency = 1
        dummyPart.CanCollide = false
        dummyPart.CFrame = CFrame.new(0, 10000, 0)
        dummyPart.Parent = workspace

       -- 擬似的に当たり判定だけ遠くに逃がす
local fakeRoot = root:Clone()
fakeRoot.Name = "FakeHitbox"
fakeRoot.Anchored = true
fakeRoot.Transparency = 1
fakeRoot.CanCollide = false
fakeRoot.CFrame = CFrame.new(0, 10000, 0)
fakeRoot.Parent = workspace

-- 元のHumanoidRootPartを無効化しておく（安全）
root.CanCollide = false
root.Transparency = 1
root.Massless = true
    end

    isInvisible = true
end

local function revertInvisible()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.CanCollide = true
        elseif part:IsA("Decal") then
            part.Transparency = 0
        end
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if root and originalCFrame then
        root.CFrame = originalCFrame
        root.Anchored = false
    end

    if dummyPart then
        dummyPart:Destroy()
        dummyPart = nil
    end

    isInvisible = false
end

MainTab:AddToggle({
    Name = "完全透明化（他人にも不可視＋無敵）",
    Default = false,
    Callback = function(state)
        if state then
            makeInvisible()
            OrionLib:MakeNotification({
                Name = "透明化ON",
                Content = "透明＆当たり判定解除したよ！",
                Time = 3
            })
        else
            revertInvisible()
            OrionLib:MakeNotification({
                Name = "透明化OFF",
                Content = "元に戻したよ！",
                Time = 3
            })
        end
    end
})

if workspace:FindFirstChild("FakeHitbox") then
    workspace:FindFirstChild("FakeHitbox"):Destroy()
end
-- 空中テレポート機能
local teleportKey = Enum.KeyCode.Y
local isInAir = false
local airTeleportEnabled = true
local airTeleportOriginalCFrame = nil

MainTab:AddToggle({
    Name = "空中TP On/Off",
    Default = true,
    Callback = function(state)
        airTeleportEnabled = state
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
        airTeleportOriginalCFrame = root.CFrame
        root.Anchored = true
        root.CFrame = CFrame.new(root.Position.X, 10000, root.Position.Z)
        isInAir = true
    else
        root.CFrame = airTeleportOriginalCFrame
        task.wait(0.1)
        root.Anchored = false
        isInAir = false
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == teleportKey then
        toggleAirTeleport()
    end
end)

-- 空中TPボタン
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

-- スピード設定
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

task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if speedEnabled and Humanoid then
            Humanoid.WalkSpeed = speedValue
        end
    end
end)

-- 無限ジャンプ機能
local infiniteJumpEnabled = false

MainTab:AddToggle({
    Name = "無限ジャンプ On/Off",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
