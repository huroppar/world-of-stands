--// OrionLib 読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

--// GUIウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "✨ Masashi Neon GUI ✨",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MasashiNeonConfig"
})

--// メインタブ
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998", -- 好きなアイコンに変えてOK
    PremiumOnly = false
})

--// 変数と関数定義
local player = game.Players.LocalPlayer
local speedValue = 16
local speedEnabled = false

--// Humanoidを安全に取得する関数
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

--// スピードスライダー
local speedValue = 16 -- デフォルトのスピード
local speedSlider, speedBox
local speedEnabled = false -- Speedオン/オフの状態

speedSlider = MainTab:AddSlider({
    Name = "Speed",
    Min = 1,
    Max = 500,
    Default = speedValue,
    Increment = 1,
    Callback = function(value)
        speedValue = value
        if speedEnabled and humanoid then
            humanoid.WalkSpeed = value
        end
        speedBox:SetText(tostring(value)) -- テキストボックスに反映
    end
})

speedBox = MainTab:AddTextbox({
    Name = "Speed値を手入力",
    Default = tostring(speedValue),
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 and num <= 500 then
            speedSlider:Set(num)
        end
    end
})

MainTab:AddToggle({
    Name = "Speedオン/オフ",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if state and humanoid then
            humanoid.WalkSpeed = speedValue
        else
            humanoid.WalkSpeed = 16 -- オフ時はデフォルトに戻す
        end
    end
})

--// スピードオン/オフトグル
MainTab:AddToggle({
    Name = "Speed オン/オフ",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if speedEnabled then
            getHumanoid().WalkSpeed = speedValue
        else
            getHumanoid().WalkSpeed = 16
        end
    end
})
--// 基本変数
local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

--// テレポート状態管理
local isInAir = false
local originalPosition = nil
local teleportKey = Enum.KeyCode.Y -- 初期キー（Yキー）

--// GUIボタン生成
local teleportButtonVisible = false
local function createTeleportButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TeleportGui"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    teleportButton = Instance.new("TextButton")
    teleportButton.Text = "空中テレポート"
    teleportButton.Size = UDim2.new(0, 140, 0, 40)
    teleportButton.Position = UDim2.new(0.5, -70, 0.8, 0)
    teleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.TextScaled = true
    teleportButton.Visible = false
    teleportButton.Active = true
    teleportButton.Draggable = true
    teleportButton.Parent = gui

    teleportButton.MouseButton1Click:Connect(function()
        toggleTeleport()
    end)
end

-- 最初に呼び出す！
createTeleportButton()

--// 空中TP機能
local function toggleTeleport()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")

    if not isInAir then
        originalPosition = root.CFrame
        root.Anchored = true
        root.CFrame = CFrame.new(root.Position.X, 10000, root.Position.Z)
        isInAir = true
    else
        root.CFrame = originalPosition
        task.wait(0.1)
        root.Anchored = false
        isInAir = false
    end
end

--// キー入力処理
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == teleportKey then
        toggleTeleport()
    end
end)

--// ボタンクリック処理
teleportButton.MouseButton1Click:Connect(function()
    toggleTeleport()
end)

--// GUI切り替え（NeonのToggleに組み込み）
MainTab:AddToggle({
    Name = "空中テレポートボタン表示",
    Default = false,
    Callback = function(state)
        teleportButtonVisible = state
        teleportButton.Visible = state
    end
})

--// キー選択機能（ドロップダウン）
local keyList = {"Q","E","R","T","Y","U","I","O","P","Z","X","C","V","B","N","M"}
MainTab:AddDropdown({
    Name = "空中TPキー設定",
    Default = "Y",
    Options = keyList,
    Callback = function(selected)
        teleportKey = Enum.KeyCode[selected]
        OrionLib:MakeNotification({
            Name = "キー変更完了",
            Content = "空中TPキーが「" .. selected .. "」になったよ！",
            Time = 3
        })
    end
})
