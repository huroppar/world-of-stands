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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- 初期キャラ取得
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- OrionLib で GUI 作成
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

local Window = OrionLib:MakeWindow({
    Name = "World of Stands - 透明化システム",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WOS_Invisible"
})

local MainTab = Window:MakeTab({
    Name = "ステルス",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local isInvisible = false
local savedParts = {}
local remoteHitboxPart = nil

-- キャラを透明にする関数
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

    -- 当たり判定を上空に退避させるヒットボックス（ダメージ回避）
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

-- 元に戻す関数
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

-- GUIトグル
MainTab:AddToggle({
    Name = "透明化 On/Off",
    Default = false,
    Callback = function(state)
        isInvisible = state
        if state then
            makeInvisible()
            OrionLib:MakeNotification({
                Name = "透明化ON",
                Content = "完全透明状態に切り替えたよ！",
                Time = 3
            })
        else
            revertVisibility()
            OrionLib:MakeNotification({
                Name = "透明化OFF",
                Content = "元に戻したよ！",
                Time = 3
            })
        end
    end
})

-- リスポーン検知で再適用
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    if isInvisible then
        wait(1)
        makeInvisible()
    end
end)


LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HRP = char:WaitForChild("HumanoidRootPart")
end)

    -- ヒットボックス削除
    if remoteHitboxPart and remoteHitboxPart.Parent then
        remoteHitboxPart:Destroy()
        remoteHitboxPart = nil
    end
    isInvisible = false
end

-- GUIにトグル追加
MainTab:AddToggle({
    Name = "透明化 On/Off",
    Default = false,
    Callback = function(state)
        if state and not isInvisible then
            makeInvisible()
            isInvisible = true
            OrionLib:MakeNotification({
                Name = "透明化",
                Content = "キャラを透明にして上空に退避させたよ！",
                Time = 3
            })
        elseif not state and isInvisible then
            revertVisibility()
            OrionLib:MakeNotification({
                Name = "透明解除",
                Content = "キャラを元に戻したよ！",
                Time = 3
            })
        end
    end
})
