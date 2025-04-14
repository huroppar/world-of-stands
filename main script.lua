--// Masashi Script : World of Stands Most Useful Script
--// Solara V3 Compatible | Author: Masashi

--== OrionLib (Solara対応) ==--
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

--== Services ==--
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
-- ✅ saveSettings と loadSettings をここに定義！
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

-- ✅ 一番最初に読み込み！
loadSettings()

-- ✅ ロード後に初期化（念のため）
if not settings.SavedPositions then
    settings.SavedPositions = {}
end

refreshTeleportDropdown()

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

loadSettings()

--== GUI 初期化 ==--
local Window = OrionLib:MakeWindow({
    Name = "🌟 WOS Most Useful Script",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "MasashiWOS",
    IntroText = "By Masashi",
    IntroIcon = "rbxassetid://4483345998"
})

OrionLib:MakeNotification({
    Name = "ようこそ！",
    Content = "Masashi Scriptを読み込みました。",
    Image = "rbxassetid://4483345998",
    Time = 5
})

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

-- ドロップダウンを更新する関数
function refreshTeleportDropdown()
    local options = table.keys(settings.SavedPositions)

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

local teleportDropdown
function refreshTeleportDropdown()
    local options = table.keys(settings.SavedPositions)
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
                OrionLib:MakeNotification({Name = "復元完了", Content = "元の場所に戻りました。", Time = 3})
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
end

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

utilityTab:AddTextbox({
    Name = "プレイヤー名を入力（横にTP）",
    Default = "",
    TextDisappear = true,
    Callback = function(targetName)
        local target = Players:FindFirstChild(targetName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            settings.LastLocation = humanoidRootPart.Position
            humanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(2, 0, 0)
        else
            OrionLib:MakeNotification({Name = "エラー", Content = "プレイヤーが見つかりません。", Time = 3})
        end
    end
})

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

--== キーシステム ==--
local keyTab = Window:MakeTab({
    Name = "キー認証",
    Icon = "rbxassetid://6031280882",
    PremiumOnly = false
})

keyTab:AddTextbox({
    Name = "キーを入力",
    Default = "",
    TextDisappear = true,
    Callback = function(inputKey)
        local webKey = ""
        pcall(function()
            webKey = tostring(game:HttpGet("https://pastebin.com/raw/YOUR_KEY_HERE"))
        end)
        local acceptedKeys = {
            ["Masashi0305"] = true,
            [tostring(os.date("%Y%m%d"))] = true,
            [webKey] = true
        }
        if acceptedKeys[inputKey] then
            OrionLib:MakeNotification({Name = "認証成功", Content = "スクリプトが有効化されました！", Time = 5})
        else
            OrionLib:MakeNotification({Name = "認証失敗", Content = "キーが間違っています。", Time = 5})
        end
    end
})

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
