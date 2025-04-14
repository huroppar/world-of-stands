-- 最初にこれを入れる（Windowがすでにあるかチェック）
if _G.__WOS_GUI_RUNNING then return end
_G.__WOS_GUI_RUNNING = true--// Masashi Script : World of Stands Most Useful Script
--// Solara V3 Compatible | Author: Masashi

local UIS = game:GetService("UserInputService")

--== OrionLib (Feather Icons 対策済み) 読み込み ==--
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()


--== GUI 初期化 ==--
local Window = OrionLib:MakeWindow({
    Name = "🌟 WOS Most Useful Script",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "MasashiWOS",
    IntroText = "By Masashi",
    IntroIcon = "rbxassetid://4483345998",
    CloseCallback = function()
        Window.Enabled = false -- 完全削除じゃなく非表示にするだけ
    end
})
_G.__WOS_Window = Window -- ⭐ 再表示に使う
--== サービス取得 ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

--== 浮遊用の変数と関数 ==--
local floating = false
local floatPosition = nil

local function startFloating()
    settings.LastLocation = humanoidRootPart.Position
    floatPosition = humanoidRootPart.Position + Vector3.new(0, 100, 0)
    humanoidRootPart.CFrame = CFrame.new(floatPosition)

    floating = true
    OrionLib:MakeNotification({
        Name = "浮遊モード",
        Content = "空中に浮かび続けます。",
        Time = 3
    })

    task.spawn(function()
        while floating do
            wait(2)
            if character and humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(floatPosition)
            end
        end
    end)
end

local function stopFloating()
    floating = false
    if settings.LastLocation then
        humanoidRootPart.CFrame = CFrame.new(settings.LastLocation)
        OrionLib:MakeNotification({
            Name = "復帰完了",
            Content = "元の場所に戻りました。",
            Time = 3
        })
    end
end

--== データ保存用 ==--
local saveFileName = "MasashiScriptSettings.json"
local settings = {
    SavedPositions = {},
    SelectedPosition = nil,
    Speed = 16,
    InfiniteJump = false,
    KeySystem = "None",
    LastLocation = nil,
    Transparency = false,
    TeleportKey = Enum.KeyCode.T.Name,
    SpeedLimit = 900,
    WebKey = "",
    DailyKey = "",
    ShowTeleport = true,
    ShowRecovery = true
}

--== 設定の保存と読み込み ==--
local function saveSettings()
    writefile(saveFileName, HttpService:JSONEncode(settings))
end

local function loadSettings()
    if isfile(saveFileName) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(saveFileName))
        end)
        if success and type(decoded) == "table" then
            settings = decoded
        end
    end
end
--== 表示設定タブ ==--
local viewTab = Window:MakeTab({
    Name = "表示設定",
    Icon = "rbxassetid://6031071058",
    PremiumOnly = false
})
local teleportDropdown

-- 先に teleportTab を作成（ここが超重要）
local teleportTab = Window:MakeTab({
    Name = "テレポート管理",
    Icon = "map-pin",
    PremiumOnly = false
})

-- ドロップダウンに使うキー一覧取得関数
local function getTableKeys(tbl)
    local keyset = {}
    for key, _ in pairs(tbl) do
        table.insert(keyset, key)
    end
    return keyset
end

-- ドロップダウンを更新する関数
function refreshTeleportDropdown()
    -- ← ここで nil チェックして初期化
    settings.SavedPositions = settings.SavedPositions or {}

    local options = {}
    for name, _ in pairs(settings.SavedPositions) do
        table.insert(options, name)
    end

    if teleportDropdown then
        teleportDropdown:Refresh(options, true)
    else
        teleportDropdown = teleportTab:AddDropdown({
            Name = "保存済みの場所",
            Options = options,
            Callback = function(option)
                settings.SelectedPosition = option
                saveSettings()
            end
        })
    end
end
-- GUI 構築後に呼び出す
refreshTeleportDropdown()

-- 最後に初期化として呼び出す（GUI構築後）
refreshTeleportDropdown()

viewTab:AddToggle({
    Name = "テレポート機能表示",
    Default = settings.ShowTeleport,
    Callback = function(value)
        settings.ShowTeleport = true
        saveSettings()
    end
})

viewTab:AddToggle({
    Name = "回復GUI表示",
    Default = settings.ShowRecovery,
    Callback = function(value)
        settings.ShowRecovery = value
        saveSettings()
    end
})

--== テレポート管理 ==--
if settings.ShowTeleport then
    local teleportTab = Window:MakeTab({
        Name = "テレポート管理",
        Icon = "rbxassetid://6035067836",
        PremiumOnly = false
    })

    teleportTab:AddTextbox({
        Name = "現在位置の名前",
        Default = "MySpot",
        TextDisappear = false,
        Callback = function(name)
            settings.SavedPositions[name] = humanoidRootPart.Position
            saveSettings()
            OrionLib:MakeNotification({Name = "保存完了", Content = name .. " の位置を保存しました。", Time = 3})
            refreshTeleportDropdown()
        end
    })

    -- ドロップダウンもここに
    local teleportDropdown
    function refreshTeleportDropdown()
        settings.SavedPositions = settings.SavedPositions or {}
        local options = {}
        for name, _ in pairs(settings.SavedPositions) do
            table.insert(options, name)
        end

        if teleportDropdown then
            teleportDropdown:Refresh(options, true)
        else
            teleportDropdown = teleportTab:AddDropdown({
                Name = "保存済みの場所",
                Options = options,
                Callback = function(option)
                    settings.SelectedPosition = option
                    saveSettings()
                end
            })
        end
    end
    refreshTeleportDropdown()
end

--== 空中テレポート（上昇）＋戻る機能 ==--
teleportTab:AddButton({
    Name = "空中にテレポート",
    Callback = function()
        if humanoidRootPart then
            -- 現在の位置を保存
            settings.LastLocation = humanoidRootPart.Position
            -- 上空へ移動
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 5000, 0)
            OrionLib:MakeNotification({
                Name = "空中テレポート",
                Content = "空中に移動しました。",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "HumanoidRootPartが見つかりません。",
                Time = 3
            })
        end
    end
})

teleportTab:AddButton({
    Name = "元の場所に戻る",
    Callback = function()
        if settings.LastLocation and humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(settings.LastLocation)
            OrionLib:MakeNotification({
                Name = "テレポート",
                Content = "元の場所に戻りました。",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "保存された場所が見つかりません。",
                Time = 3
            })
        end
    end
})

local teleportDropdown

function refreshTeleportDropdown()
    -- nil チェックと初期化（超重要）
    settings.SavedPositions = settings.SavedPositions or {}

    local options = {}
    for name, _ in pairs(settings.SavedPositions) do
        table.insert(options, name)
    end

    if teleportDropdown then
        teleportDropdown:Refresh(options, true)
    else
        teleportDropdown = teleportTab:AddDropdown({
            Name = "保存済みの場所",
            Options = options,
            Callback = function(option)
                settings.SelectedPosition = option
                saveSettings()
            end
        })
    end
end
refreshTeleportDropdown()

teleportTab:AddButton({
    Name = "保存一覧を更新",
    Callback = function()
        refreshTeleportDropdown()
        OrionLib:MakeNotification({
            Name = "更新完了",
            Content = "保存済みの場所リストを更新しました。",
            Time = 3
        })
    end
})

teleportTab:AddButton({
    Name = "選択した場所にテレポート",
    Callback = function()
        local pos = settings.SavedPositions[settings.SelectedPosition]
        if pos then
            settings.LastLocation = humanoidRootPart.Position
            humanoidRootPart.CFrame = CFrame.new(pos)
        end
    end
})

teleportTab:AddButton({
    Name = "現在の場所に戻る（復元）",
    Callback = function()
        if settings.LastLocation then
            humanoidRootPart.CFrame = CFrame.new(settings.LastLocation)
            OrionLib:MakeNotification({
                Name = "復元完了",
                Content = "元の場所に戻りました。",
                Time = 3
            })
        end
    end
})

teleportTab:AddTextbox({
    Name = "削除したい位置名",
    Default = "",
    TextDisappear = true,
    Callback = function(name)
        if settings.SavedPositions[name] then
            settings.SavedPositions[name] = nil
            saveSettings()
            OrionLib:MakeNotification({
                Name = "削除完了",
                Content = name .. " を削除しました。",
                Time = 3
            })
            refreshTeleportDropdown()
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "その名前の位置は存在しません。",
                Time = 3
            })
        end
    end
})

teleportTab:AddLabel("現在位置: 初期化中...")
local positionLabel = teleportTab:AddLabel("")
RunService.RenderStepped:Connect(function()
    local pos = humanoidRootPart.Position
    positionLabel:Set("現在位置: X=" .. math.floor(pos.X) .. ", Y=" .. math.floor(pos.Y) .. ", Z=" .. math.floor(pos.Z))
end)

--== ユーティリティ機能 ==--
local utilityTab = Window:MakeTab({
    Name = "ユーティリティ",
    Icon = "rbxassetid://6031215984",
    PremiumOnly = false
})

utilityTab:AddToggle({
    Name = "無限ジャンプ",
    Default = settings.InfiniteJump,
    Callback = function(value)
        settings.InfiniteJump = value
        saveSettings()
    end
})
utilityTab:AddSlider({
    Name = "スピード調整",
    Min = 16,
    Max = settings.SpeedLimit,
    Default = settings.Speed,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        settings.Speed = value
        humanoid.WalkSpeed = value
        saveSettings()
    end
})

local selectedPlayer = nil
local playerDropdown -- 後で更新用に変数化

-- ドロップダウン：現在のプレイヤー一覧
playerDropdown = utilityTab:AddDropdown({
    Name = "プレイヤーを選択",
    Options = {}, -- 初期は空、後で更新
    Callback = function(value)
        selectedPlayer = value
    end
})

-- プレイヤーの横にテレポートするボタン
utilityTab:AddButton({
    Name = "選択したプレイヤーの横にTP",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            settings.LastLocation = humanoidRootPart.Position
            humanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(2, 0, 0)
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "プレイヤーが見つかりません。",
                Time = 3
            })
        end
    end
})

-- ドロップダウンのオプションを更新する関数
local function updatePlayerDropdown()
    local options = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(options, player.Name)
        end
    end
    if playerDropdown then
        playerDropdown:Refresh(options, true)
    end
end

-- 初回実行
updatePlayerDropdown()

-- プレイヤー参加/退出時に自動更新
Players.PlayerAdded:Connect(updatePlayerDropdown)
Players.PlayerRemoving:Connect(updatePlayerDropdown)

utilityTab:AddButton({
    Name = "空中に浮いて停止（ループ）",
    Callback = startFloating
})

utilityTab:AddButton({
    Name = "元の場所に戻る（浮遊終了）",
    Callback = stopFloating
})

utilityTab:AddToggle({
    Name = "透明化（自身）",
    Default = settings.Transparency,
    Callback = function(value)
        settings.Transparency = value
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = value and 0.7 or 0
            end
        end
        saveSettings()
    end
})

UIS.JumpRequest:Connect(function()
    if settings.InfiniteJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)


-- テレポートキー設定
utilityTab:AddLabel("テレポートキー割り当て")
utilityTab:AddBind({
    Name = "テレポートキー",
    Default = Enum.KeyCode[settings.TeleportKey] or Enum.KeyCode.T,
    Hold = false,
    Callback = function(key)
        settings.TeleportKey = key.Name
        saveSettings()
        OrionLib:MakeNotification({
            Name = "キー設定完了",
            Content = "テレポートキーを [" .. key.Name .. "] に設定しました。",
            Time = 3
        })
    end
})
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode.Name == settings.TeleportKey then
        local pos = settings.SavedPositions[settings.SelectedPosition]
        if pos then
            settings.LastLocation = humanoidRootPart.Position
            humanoidRootPart.CFrame = CFrame.new(pos)
            OrionLib:MakeNotification({
                Name = "テレポート",
                Content = "保存先にテレポートしました。",
                Time = 2
            })
        end
    end
end)


UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F4 then
        if OrionLib and OrionLib.Gui then
            OrionLib.Gui.Enabled = not OrionLib.Gui.Enabled
        end
    end
end)
--== 通知 ==--
OrionLib:MakeNotification({
    Name = "設定復元完了",
    Content = "前回の状態が読み込まれました。",
    Image = "rbxassetid://4483345998",
    Time = 5
})

OrionLib:MakeNotification({
    Name = "🛠️ アップデート情報",
    Content = "スクリプトが最新バージョンに更新されました！",
    Image = "rbxassetid://4483345998",
    Time = 6
})

--== 🔥 今後のアップデート候補 (実装予定) ==--
--[[
✅ 自動クエスト処理：クエスト対象の敵自動討伐・NPC自動テレポート・ステータス＆完了通知
✅ プレイヤー位置保存＆復元
✅ キーシステム：日替わり、Web認証、自己キー、保存対応
✅ GUI表示切り替え（F4）
✅ 高速移動制限対策（45以下制限）
✅ 無限ジャンプ・体力回復・無敵モード
✅ 敵の体力を自動で1に
✅ プレイヤー横へのテレポート
🟡 テレポートのGUIボタン表示/非表示切り替え
🟡 回復のGUI表示機能
🟡 クエストステータスのリアルタイム表示と自動完了検出
🟡 光の柱マーカー表示
🟡 自動ドロップ取得のON/OFF
🟡 攻撃BOT自動討伐機能
]]

--== GUI再表示ボタン（ドラッグ移動付き）==--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MasashiGUIButton"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:WaitForChild("CoreGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 160, 0, 40)
button.Position = UDim2.new(0.5, -80, 1, -60)
button.AnchorPoint = Vector2.new(0.5, 1)
button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "🌟 GUIを再表示"
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.Parent = ScreenGui
button.Active = true

--== ドラッグ機能 ==--
local dragging = false
local dragStart, startPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = button.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
-- F4キーでGUI表示/非表示切り替え
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F4 and not gameProcessed then
        if OrionLib and OrionLib.Gui then
            OrionLib.Gui.Enabled = not OrionLib.Gui.Enabled
        end
    end
end)

-- ボタン押下で GUI を再表示
button.MouseButton1Click:Connect(function()
    if OrionLib and OrionLib.Gui then
        OrionLib.Gui.Enabled = true
    end
end)
