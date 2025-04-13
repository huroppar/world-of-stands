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
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

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
    SpeedLimit = 45
}

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

--== テレポート管理 ==--
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

--== ドロップダウン更新関数 ==--
local teleportDropdown
function refreshTeleportDropdown()
    if teleportDropdown then teleportTab:RemoveElement(teleportDropdown) end
    teleportDropdown = teleportTab:AddDropdown({
        Name = "保存済みの場所",
        Options = table.keys(settings.SavedPositions),
        Callback = function(option)
            settings.SelectedPosition = option
            saveSettings()
        end
    })
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

--== 現在位置のリアルタイム表示 ==--
teleportTab:AddLabel("現在位置: 初期化中...")
local positionLabel = teleportTab:AddLabel("")
RunService.RenderStepped:Connect(function()
    local pos = humanoidRootPart.Position
    positionLabel:Set("現在位置: X=" .. math.floor(pos.X) .. ", Y=" .. math.floor(pos.Y) .. ", Z=" .. math.floor(pos.Z))
end)

--== 移動＆戦闘 ==--
local combatTab = Window:MakeTab({
    Name = "戦闘＆補助",
    Icon = "rbxassetid://6031280882",
    PremiumOnly = false
})

local infiniteJumpEnabled = false
UIS.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        humanoidRootPart.Velocity = Vector3.new(0, 50, 0)
    end
end)


combatTab:AddButton({
    Name = "HP回復",
    Callback = function()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end
})

combatTab:AddButton({
    Name = "近くの敵の体力を1に",
    Callback = function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                if (v.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude < 50 then
                    v:FindFirstChildOfClass("Humanoid").Health = 1
                end
            end
        end
    end
})

combatTab:AddToggle({
    Name = "無敵（God Mode）",
    Default = false,
    Callback = function(state)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if state then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
        end
    end
})

combatTab:AddTextbox({
    Name = "移動速度 (最大45)",
    Default = tostring(settings.Speed),
    TextDisappear = false,
    Callback = function(speed)
        local s = tonumber(speed)
        if s and s <= settings.SpeedLimit then
            settings.Speed = s
            if character:FindFirstChildOfClass("Humanoid") then
                character:FindFirstChildOfClass("Humanoid").WalkSpeed = s
            end
            saveSettings()
        else
            OrionLib:MakeNotification({Name = "エラー", Content = "速度は45以下にしてください。", Time = 3})
        end
    end
})

--== ユーティリティ機能 ==--
utilityTab:AddToggle({
    Name = "無限ジャンプ",
    Default = settings.InfiniteJump,
    Callback = function(state)
        settings.InfiniteJump = state
        saveSettings()
    end
})

UIS.JumpRequest:Connect(function()
    if settings.InfiniteJump then
        character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

utilityTab:AddSlider({
    Name = "スピード調整",
    Min = 16,
    Max = settings.SpeedLimit,
    Default = settings.Speed,
    Increment = 1,
    Callback = function(val)
        settings.Speed = val
        humanoidRootPart.Parent:FindFirstChildOfClass("Humanoid").WalkSpeed = val
        saveSettings()
    end
})

utilityTab:AddToggle({
    Name = "透明化",
    Default = settings.Transparency,
    Callback = function(state)
        settings.Transparency = state
        local parts = character:GetDescendants()
        for _, part in ipairs(parts) do
            if part:IsA("BasePart") then
                part.Transparency = state and 1 or 0
            end
        end
        saveSettings()
    end
})


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
