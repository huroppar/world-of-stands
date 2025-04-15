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

local transparencyEnabled = false
local isInvisible = false
local originalCFrame = nil
local collisionPart = nil

-- トグル追加（GUIで透明化機能のオンオフ）
MainTab:AddToggle({
    Name = "透明化機能 On/Off",
    Default = false,
    Callback = function(state)
        transparencyEnabled = state
        if toggleTransparencyButton then
            toggleTransparencyButton.Visible = state
        end
        OrionLib:MakeNotification({
            Name = "透明化機能",
            Content = state and "透明化機能を有効化したよ！" or "透明化機能を無効化したよ！",
            Time = 3
        })
    end
})

local InvisTab = Window:MakeTab({
    Name = "Invisibility",
    Icon = "rbxassetid://1234567890", -- 適当でOK
    PremiumOnly = false
})

local showButton = false
local invisButton

InvisTab:AddToggle({
    Name = "透明化機能を有効にする",
    Default = false,
    Callback = function(value)
        showButton = value
        if value and not invisButton then
            invisButton = InvisTab:AddButton({
                Name = "透明ON / OFF",
                Callback = function()
                    invisible = not invisible
                    if invisible then
                        enableInvisibility()
                    else
                        disableInvisibility()
                    end
                end
            })
        elseif not value and invisButton then
            InvisTab:RemoveButton(invisButton)
            invisButton = nil
            if invisible then
                disableInvisibility()
                invisible = false
            end
        end
    end
})


-- 透明化ON/OFFの処理（スクリプトの一番下に貼ってOK）
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera
local char = player.Character or player.CharacterAdded:Wait()
local invisible = false
local originalCFrame = nil

local function enableInvisibility()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if hrp and head then
        originalCFrame = hrp.CFrame
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(0, 10000, 0)
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = head.CFrame + Vector3.new(0, 2, 5)
    end
end

local function disableInvisibility()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and originalCFrame then
        hrp.CFrame = originalCFrame
        hrp.Anchored = false
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = char:FindFirstChild("Humanoid")
    end
end

local InvisTab = Window:MakeTab({
    Name = "Invisibility",
    Icon = "rbxassetid://1234567890", -- 適当でOK
    PremiumOnly = false
})

local invisible = false
local originalCFrame = nil
local buttonVisible = false
local invisButtonObj

-- 透明化処理（関数はスクリプトの下でも上でもOK）
local function enableInvisibility()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local cam = workspace.CurrentCamera
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if hrp and head then
        originalCFrame = hrp.CFrame
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(0, 10000, 0)
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = head.CFrame + Vector3.new(0, 2, 5)
    end
end

local function disableInvisibility()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local cam = workspace.CurrentCamera
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and originalCFrame then
        hrp.CFrame = originalCFrame
        hrp.Anchored = false
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = char:FindFirstChild("Humanoid")
    end
end

-- 透明化ボタン（最初に作るけど非表示にしておく）
invisButtonObj = InvisTab:AddButton({
    Name = "透明ON / OFF",
    Callback = function()
        invisible = not invisible
        if invisible then
            enableInvisibility()
        else
            disableInvisibility()
        end
    end
})

-- ボタンを非表示にしておく
invisButtonObj:SetVisible(false)

-- トグルでONにしたらボタン表示、OFFにしたら非表示
InvisTab:AddToggle({
    Name = "透明化機能を有効にする",
    Default = false,
    Callback = function(state)
        buttonVisible = state
        invisButtonObj:SetVisible(state)
        if not state and invisible then
            disableInvisibility()
            invisible = false
        end
    end
})
