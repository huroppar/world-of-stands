--// Masashi Script : World of Stands Most Useful Script
--// Solara V3 Compatible | Author: Masashi

--== OrionLib (Feather Icons 対策済み) 読み込み ==--
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()


--== GUI 初期化 ==--
local Window = OrionLib:MakeWindow({
    Name = "🌟 WOS Most Useful Script",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "MasashiWOS",
    IntroText = "By Masashi",
    IntroIcon = "rbxassetid://4483345998"
})

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
    SpeedLimit = 45,
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
        settings.ShowTeleport = value
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
    settings.SavedPositions = settings.SavedPositions or {} -- ← ここが大事！

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
            if name and name ~= "" then
                settings.SavedPositions[name] = humanoidRootPart.Position
                saveSettings()
                OrionLib:MakeNotification({
                    Name = "保存完了",
                    Content = name .. " の位置を保存しました。",
                    Time = 3
                })
                refreshTeleportDropdown()
            else
                OrionLib:MakeNotification({
                    Name = "エラー",
                    Content = "名前が空です。",
                    Time = 3
                })
            end
        end
    })
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


--== GUI切り替え ==--
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F4 then
        OrionLib:ToggleUI()
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

-- GUI全体を囲む Frame を変数にしておく
local mainGui = ScreenGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("🌟 WOS Most Useful Script")  -- ここはGUI名に変更してね

-- 表示・非表示切り替え
function toggleMainGui()
    if mainGui then
        mainGui.Enabled = not mainGui.Enabled
    end
end

-- 再表示用の小さなボタンを右上に作成
local reopenButton = Instance.new("TextButton")
reopenButton.Name = "ReopenGUI"
reopenButton.Text = "📂"
reopenButton.Size = UDim2.new(0, 40, 0, 40)
reopenButton.Position = UDim2.new(1, -50, 0, 10) -- 右上に配置
reopenButton.AnchorPoint = Vector2.new(1, 0)
reopenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
reopenButton.TextColor3 = Color3.new(1, 1, 1)
reopenButton.BorderSizePixel = 0
reopenButton.BackgroundTransparency = 0.2
reopenButton.Parent = game:GetService("CoreGui")

-- ボタン押下時にメインGUIの表示切り替え
reopenButton.MouseButton1Click:Connect(toggleMainGui)
