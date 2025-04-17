-- OrionLib 読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

-- プレイヤー名とキー認証
local allowedUsers = {
    Furoppersama = true,
    Furopparsama = true,
    BNVGUE2 = true
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not allowedUsers[LocalPlayer.Name] then
    local verified = false
    while not verified do
        local keyInput = OrionLib:MakeWindow({
            Name = "🔐 キー認証",
            HidePremium = false,
            SaveConfig = false,
            ConfigFolder = "KeySystem"
        })

        local correctKey = "Masashi0407"

        keyInput:MakeTab({Name = "キー入力", Icon = "rbxassetid://4483345998", PremiumOnly = false})
            :AddTextbox({
                Name = "キーを入力してください",
                Default = "",
                TextDisappear = false,
                Callback = function(input)
                    if input == correctKey then
                        verified = true
                        OrionLib:MakeNotification({
                            Name = "キー認証成功",
                            Content = "ようこそ、" .. LocalPlayer.Name .. "！",
                            Image = "rbxassetid://4483345998",
                            Time = 5
                        })
                    else
                        OrionLib:MakeNotification({
                            Name = "認証失敗",
                            Content = "キーが間違っています。もう一度入力してください。",
                            Image = "rbxassetid://4483345998",
                            Time = 5
                        })
                    end
                end
            })

        repeat wait() until verified
        keyInput.Enabled = false
    end
end

-- GUI ウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "💫 Masashi式ユーティリティ",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MasashiGUI"
})

-- 値の初期化
local speedEnabled = false
local speedValue = 30
local jumpEnabled = false
local wallHackEnabled = false
local highlightEnabled = false
local highlightInstances = {}
local originalPosition = nil
local tpButtonVisible = false

-- セクション
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- スピード変更
MainTab:AddToggle({
    Name = "スピード変更 ON/OFF",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = state and speedValue or 30
    end
})

MainTab:AddSlider({
    Name = "スピード",
    Min = 1,
    Max = 500,
    Default = 30,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(val)
        speedValue = val
        if speedEnabled then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end
})

MainTab:AddTextbox({
    Name = "スピード数値入力",
    Default = "30",
    TextDisappear = false,
    Callback = function(val)
        local num = tonumber(val)
        if num and num >= 1 and num <= 500 then
            speedValue = num
            if speedEnabled then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = num
            end
        end
    end
})

-- 無限ジャンプ
game:GetService("UserInputService").JumpRequest:Connect(function()
    if jumpEnabled and game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

MainTab:AddToggle({
    Name = "無限ジャンプ ON/OFF",
    Default = false,
    Callback = function(state)
        jumpEnabled = state
    end
})

-- 空中TPボタン
local btn = Instance.new("TextButton")
btn.Text = "空中TP"
btn.Size = UDim2.new(0, 150, 0, 50)
btn.Position = UDim2.new(0.5, -75, 1, -60)
btn.AnchorPoint = Vector2.new(0.5, 1)
btn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Visible = false
btn.Parent = game.CoreGui

-- ボタンのドラッグ
local dragging, dragInput, dragStart, startPos
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

btn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                 startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

btn.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if not originalPosition then
        originalPosition = char.HumanoidRootPart.CFrame
        char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position.X, 10000, char.HumanoidRootPart.Position.Z)
    else
        char.HumanoidRootPart.CFrame = originalPosition
        originalPosition = nil
    end
end)

MainTab:AddToggle({
    Name = "空中TP機能 ON/OFF",
    Default = false,
    Callback = function(state)
        tpButtonVisible = state
        btn.Visible = state
    end
})

MainTab:AddToggle({
    Name = "空中TPボタン表示切替",
    Default = false,
    Callback = function(state)
        btn.Visible = state
    end
})

-- ハイライト（他プレイヤー）
local function updateHighlights()
    for _, h in pairs(highlightInstances) do h:Destroy() end
    table.clear(highlightInstances)
    if highlightEnabled then
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = player.Character
                highlight.Parent = game.CoreGui
                table.insert(highlightInstances, highlight)
            end
        end
    end
end

game.Players.PlayerAdded:Connect(updateHighlights)
game.Players.PlayerRemoving:Connect(updateHighlights)

MainTab:AddToggle({
    Name = "他プレイヤーのハイライト表示",
    Default = false,
    Callback = function(state)
        highlightEnabled = state
        updateHighlights()
    end
})

-- 壁貫通
MainTab:AddToggle({
    Name = "壁貫通 ON/OFF",
    Default = false,
    Callback = function(state)
        wallHackEnabled = state
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not state
                end
            end
        end
    end
})

-- 起動通知
OrionLib:MakeNotification({
    Name = "Masashi式スクリプト",
    Content = "起動完了！スーパーユーティリティが使えるぞ💪",
    Image = "rbxassetid://4483345998",
    Time = 5
})
