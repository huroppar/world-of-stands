--// OrionLib 読み込み（GitHub版）
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

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
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

--// 基本変数
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

--// スピード設定
local speedValue = 16
local speedEnabled = false
local speedSlider, speedBox

speedSlider = MainTab:AddSlider({
    Name = "Speed",
    Min = 1,
    Max = 500,
    Default = speedValue,
    Increment = 1,
    Callback = function(value)
        speedValue = value
        if speedEnabled then
            humanoid.WalkSpeed = value
        end
        speedBox:SetText(tostring(value))
    end
})

MainTab:AddLabel("これは表示される？")
MainTab:AddButton({
    Name = "テストボタン",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "クリックされた！",
            Content = "ボタンはちゃんと動いてるよ！",
            Time = 2
        })
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
        if state then
            humanoid.WalkSpeed = speedValue
        else
            humanoid.WalkSpeed = 16
        end
    end
})

--// 空中テレポート機能
local isInAir = false
local originalPosition = nil
local teleportKey = Enum.KeyCode.Y
local teleportButton = nil

local function toggleTeleport()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

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

--// ボタン生成
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

    teleportButton.MouseButton1Click:Connect(toggleTeleport)
end
createTeleportButton()

--// キー入力で空中テレポート
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == teleportKey then
        toggleTeleport()
    end
end)

--// ボタン表示トグル
MainTab:AddToggle({
    Name = "空中テレポートボタン表示",
    Default = false,
    Callback = function(state)
        if teleportButton then
            teleportButton.Visible = state
        end
    end
})

--// キー設定ドロップダウン
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
