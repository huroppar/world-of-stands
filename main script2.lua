local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Solara v3互換ライブラリ
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

local Window = OrionLib:MakeWindow({
    Name = "World of Stands - Speed Control",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_SpeedControl"
})

local MainTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local speedValue = 30
local speedEnabled = false

-- オンオフ切替
MainTab:AddToggle({
    Name = "Speed On/Off",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if speedEnabled then
            Humanoid.WalkSpeed = speedValue
        else
            Humanoid.WalkSpeed = 30
        end
    end
})

-- スライダー
local speedSlider = MainTab:AddSlider({
    Name = "Speed Slider",
    Min = 1,
    Max = 500,
    Default = speedValue,
    Increment = 1,
    Callback = function(value)
        speedValue = value
        if speedEnabled then
            Humanoid.WalkSpeed = value
        end
    end
})

-- 数値入力
MainTab:AddTextbox({
    Name = "Speed Input (手動入力)",
    Default = tostring(speedValue),
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 and num <= 500 then
            speedValue = num
            speedSlider:Set(num)
            if speedEnabled then
                Humanoid.WalkSpeed = num
            end
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "1〜500の数字を入力してね！",
                Time = 3
            })
        end
    end
})

-- Speed維持ループ（頻度爆上げ & 技に打ち勝つ）
task.spawn(function()
    while true do
        game:GetService("RunService").RenderStepped:Wait()
        if speedEnabled and Humanoid then
            Humanoid.WalkSpeed = speedValue
        end
    end
end)

local airTeleportEnabled = true -- デフォルトはON

MainTab:AddToggle({
    Name = "空中TP機能 On/Off",
    Default = true,
    Callback = function(state)
        airTeleportEnabled = state
        OrionLib:MakeNotification({
            Name = "空中TP",
            Content = state and "空中TPを有効化したよ！" or "空中TPを無効化したよ！",
            Time = 3
        })
    end
})

-- 空中テレポート用変数（← ここはループの外！）
local teleportKey = Enum.KeyCode.Y
local isInAir = false
local originalCFrame = nil


-- 空中テレポート関数
local function toggleAirTeleport()
    if not airTeleportEnabled then return end
    
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

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

-- キー入力で実行
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == teleportKey then
        toggleAirTeleport()
    end
end)

-- GUIにボタンとキー設定追加
MainTab:AddToggle({
    Name = "空中TPボタン表示",
    Default = false,
    Callback = function(state)
        if teleportButton then
            teleportButton.Visible = state
        end
    end
})

local keyList = {"Q", "E", "R", "T", "Y", "U", "I", "O", "P", "Z", "X", "C", "V", "B", "N", "M"}
MainTab:AddDropdown({
    Name = "空中TPキー設定",
    Default = "Y",
    Options = keyList,
    Callback = function(key)
        teleportKey = Enum.KeyCode[key]
        OrionLib:MakeNotification({
            Name = "キー変更完了",
            Content = "空中TPのキーが「" .. key .. "」に設定されたよ！",
            Time = 3
        })
    end
})

-- 空中TPボタンを画面に表示する処理
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

-- 無限ジャンプ用変数
local infiniteJumpEnabled = false

-- 無限ジャンプ本体処理
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- GUIにトグル追加
MainTab:AddToggle({
    Name = "無限ジャンプ On/Off",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
        OrionLib:MakeNotification({
            Name = "無限ジャンプ",
            Content = state and "無限ジャンプをONにしたよ！" or "無限ジャンプをOFFにしたよ！",
            Time = 3
        })
    end
})

-- 状態管理
local transparencyButton = nil
local dragging = false
local offset = Vector2.zero
local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- 透明化状態
local isInvisible = false
local originalCFrame = nil

-- 透明化の関数
local function enableInvisibility()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        originalCFrame = hrp.CFrame
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(0, 10000, 0)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 0.5
            end
        end
    end
end

local function disableInvisibility()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and originalCFrame then
        hrp.CFrame = originalCFrame
        hrp.Anchored = false
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 0
            end
        end
    end
end

-- ボタン作成関数
local function createFloatingButton()
    if transparencyButton then return end

    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    screenGui.Name = "TransparencyButtonGui"

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 40)
    button.Position = UDim2.new(0.5, -50, 0.8, 0)
    button.BackgroundColor3 = Color3.new(0, 0.5, 1)
    button.Text = "透明 ON/OFF"
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.Parent = screenGui

    -- ボタンクリックで透明化ON/OFF切替
    button.MouseButton1Click:Connect(function()
        isInvisible = not isInvisible
        if isInvisible then
            enableInvisibility()
        else
            disableInvisibility()
        end
    end)

    -- ドラッグ機能（マウス or タッチ）
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            offset = Vector2.new(input.Position.X - button.AbsolutePosition.X, input.Position.Y - button.AbsolutePosition.Y)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local newPosition = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
            button.Position = newPosition
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    transparencyButton = screenGui
end

-- ボタン削除
local function removeFloatingButton()
    if transparencyButton then
        transparencyButton:Destroy()
        transparencyButton = nil
    end
end

-- GUIトグルに追加（OrionLib）
local InvisTab = Window:MakeTab({
    Name = "Invisibility",
    Icon = "rbxassetid://1234567890",
    PremiumOnly = false
})

InvisTab:AddToggle({
    Name = "透明化機能ON/OFFスイッチ",
    Default = false,
    Callback = function(state)
        if state then
            createFloatingButton()
        else
            if isInvisible then
                disableInvisibility()
                isInvisible = false
            end
            removeFloatingButton()
        end
    end
})
