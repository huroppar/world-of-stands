--// Masashi Script : World of Stands Most Useful Script
--// Solara V3 Compatible | Author: Masashi

--== OrionLib (Solara対応) ==--
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

--== Services ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--== データ保存用 ==--
local saveFileName = "MasashiScriptSettings.json"
local settings = {}

local function saveSettings()
    writefile(saveFileName, HttpService:JSONEncode(settings))
end

local function loadSettings()
    if isfile(saveFileName) then
        settings = HttpService:JSONDecode(readfile(saveFileName))
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
--== キーシステム ==--
local validKey1 = "Masashi0305" -- 自分だけのキー
local validKey2 = os.date("%Y-%m-%d") -- 毎日変わるキー
local validKey3 = nil

-- Web取得キー（必要なら外部URLを使って設定できる）
pcall(function()
    local keyUrl = "https://pastebin.com/raw/xxxxxx" -- あればここにキーを置く
    validKey3 = game:HttpGet(keyUrl)
end)

local correctKey = false

--== GUIでキー入力 ==--
local KeyTab = Window:MakeTab({ Name = "🔑 KeySystem", Icon = "🔐", PremiumOnly = false })
KeyTab:AddTextbox({
    Name = "キーを入力してください",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        if value == validKey1 or value == validKey2 or value == validKey3 then
            OrionLib:MakeNotification({
                Name = "キー認証成功",
                Content = "アクセス許可されました。",
                Image = "rbxassetid://4483345998",
                Time = 4
            })
            correctKey = true
        else
            OrionLib:MakeNotification({
                Name = "キーエラー",
                Content = "キーが間違っています。",
                Image = "rbxassetid://4483345998",
                Time = 4
            })
        end
    end
})

--== 認証後に機能表示 ==--
local function waitForKey()
    repeat
        task.wait(0.5)
    until correctKey
end

waitForKey()

--== 各機能ページ定義 ==--
local MainTab = Window:MakeTab({ Name = "🏠 Main", Icon = "🏹", PremiumOnly = false })
local TP_Tab = Window:MakeTab({ Name = "🚀 Teleport", Icon = "🌍", PremiumOnly = false })
local PlayerTab = Window:MakeTab({ Name = "👤 Player", Icon = "⚡", PremiumOnly = false })
local QuestTab = Window:MakeTab({ Name = "📜 Quest", Icon = "📌", PremiumOnly = false })
local UtilityTab = Window:MakeTab({ Name = "🧰 Utility", Icon = "🛠️", PremiumOnly = false })
--== 無限ジャンプ オンオフ ==--
local InfiniteJumpEnabled = false
PlayerTab:AddToggle({
    Name = "🌕 無限ジャンプ",
    Default = false,
    Callback = function(value)
        InfiniteJumpEnabled = value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

--== スピード変更（制限付き）==--
local maxSpeed = 44
PlayerTab:AddSlider({
    Name = "🏃‍♂️ スピード変更 (最大45未満)",
    Min = 16,
    Max = maxSpeed,
    Default = 16,
    Increment = 1,
    Callback = function(speed)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
})

--== 透明化 オンオフ + キー設定 ==--
local invisEnabled = false
local invisKey = Enum.KeyCode.J

PlayerTab:AddBind({
    Name = "👻 透明化トグルキー",
    Default = invisKey,
    Hold = false,
    Callback = function()
        invisEnabled = not invisEnabled
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = invisEnabled and 1 or 0
                end
            end
        end
    end
})

--== 上空テレポート・復帰機能 ==--
local lastPosition = nil
TP_Tab:AddButton({
    Name = "⬆️ 上にテレポート",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if not lastPosition then
                lastPosition = hrp.Position
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 150, 0)
            else
                hrp.CFrame = CFrame.new(lastPosition)
                lastPosition = nil
            end
        end
    end
})

--== 場所保存・リスト表示・名前変更・削除・テレポート ==--
local savedPositions = {}

local function refreshSavedPositionsUI()
    TP_Tab:Clear()
    for i, pos in pairs(savedPositions) do
        TP_Tab:AddButton({
            Name = "📍 " .. pos.name,
            Callback = function()
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(pos.position)
                end
            end
        })

        TP_Tab:AddTextbox({
            Name = "✏️ 名前変更: " .. pos.name,
            Default = pos.name,
            Callback = function(newName)
                pos.name = newName
                refreshSavedPositionsUI()
            end
        })

        TP_Tab:AddButton({
            Name = "🗑️ 削除: " .. pos.name,
            Callback = function()
                table.remove(savedPositions, i)
                refreshSavedPositionsUI()
            end
        })
    end
end

TP_Tab:AddButton({
    Name = "💾 今の場所を保存",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            table.insert(savedPositions, {
                name = "場所" .. tostring(#savedPositions + 1),
                position = hrp.Position
            })
            refreshSavedPositionsUI()
        end
    end
})

--== 光の柱 オンオフ + 表示 ==--
local beamsEnabled = false
local beamFolder = Instance.new("Folder", game.Workspace)
beamFolder.Name = "MasashiBeams"

UtilityTab:AddToggle({
    Name = "🗼 光の柱表示",
    Default = false,
    Callback = function(value)
        beamsEnabled = value
        beamFolder:ClearAllChildren()
        if beamsEnabled then
            for _, pos in pairs(savedPositions) do
                local part = Instance.new("Part", beamFolder)
                part.Anchored = true
                part.CanCollide = false
                part.Size = Vector3.new(0.5, 500, 0.5)
                part.CFrame = CFrame.new(pos.position + Vector3.new(0, 250, 0))
                part.Color = Color3.fromRGB(0, 255, 255)
                part.Material = Enum.Material.Neon
                part.Transparency = 0.3
                part.Name = "Beam_" .. pos.name
            end
        end
    end
})
-- ▼▼ 場所保存・テレポート関連 ▼▼
local savedLocations = {}
local currentLocation = nil
local pillarFolder = Instance.new("Folder", workspace)
pillarFolder.Name = "TeleportPillars"

local function createPillar(pos, name)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(1, 200, 1)
    part.Position = pos + Vector3.new(0, 100, 0)
    part.Color = Color3.fromRGB(255, 255, 0)
    part.Material = Enum.Material.Neon
    part.Name = name
    part.Parent = pillarFolder
end

local function refreshPillars()
    pillarFolder:ClearAllChildren()
    if showPillars then
        for name, data in pairs(savedLocations) do
            createPillar(data.Position, name)
        end
    end
end

TeleportTab:AddTextbox({
    Name = "保存名を入力",
    Default = "Home",
    Callback = function(value)
        currentLocation = value
    end
})

TeleportTab:AddButton({
    Name = "現在地を保存",
    Callback = function()
        if currentLocation then
            savedLocations[currentLocation] = {
                Position = plr.Character.HumanoidRootPart.Position
            }
            OrionLib:MakeNotification({
                Name = "位置保存",
                Content = currentLocation .. " を保存しました！",
                Time = 3
            })
            refreshPillars()
        end
    end
})

TeleportTab:AddDropdown({
    Name = "保存した場所に移動",
    Options = {},
    Callback = function(selected)
        local loc = savedLocations[selected]
        if loc then
            plr.Character.HumanoidRootPart.CFrame = CFrame.new(loc.Position)
        end
    end
})

TeleportTab:AddButton({
    Name = "保存した場所をすべて更新",
    Callback = function()
        local dropdown = OrionLib:GetDropdown("保存した場所に移動")
        local keys = {}
        for name in pairs(savedLocations) do
            table.insert(keys, name)
        end
        dropdown:Refresh(keys)
    end
})

TeleportTab:AddToggle({
    Name = "光の柱を表示",
    Default = true,
    Callback = function(v)
        showPillars = v
        refreshPillars()
    end
})

-- ▼ 名前変更 / 削除 / プレイヤーの位置保存 ▼
TeleportTab:AddTextbox({
    Name = "変更対象の保存名",
    Default = "",
    Callback = function(v) selectedForEdit = v end
})

TeleportTab:AddTextbox({
    Name = "新しい名前",
    Default = "",
    Callback = function(v) newName = v end
})

TeleportTab:AddButton({
    Name = "名前変更",
    Callback = function()
        if selectedForEdit and newName and savedLocations[selectedForEdit] then
            savedLocations[newName] = savedLocations[selectedForEdit]
            savedLocations[selectedForEdit] = nil
            OrionLib:MakeNotification({ Name = "名前変更", Content = "成功！", Time = 2 })
            refreshPillars()
        end
    end
})

TeleportTab:AddButton({
    Name = "保存場所を削除",
    Callback = function()
        if selectedForEdit and savedLocations[selectedForEdit] then
            savedLocations[selectedForEdit] = nil
            OrionLib:MakeNotification({ Name = "削除完了", Content = "場所を削除しました", Time = 2 })
            refreshPillars()
        end
    end
})
teleportTab:AddTextbox({
    Name = "現在位置の名前",
    Default = "MySpot",
    TextDisappear = false,
    Callback = function(name)
        settings.SavedPositions[name] = humanoidRootPart.Position
        saveSettings()
        OrionLib:MakeNotification({Name = "保存完了", Content = name .. " の位置を保存しました。", Time = 3})
    end
})

teleportTab:AddDropdown({
    Name = "保存済みの場所",
    Options = table.keys(settings.SavedPositions),
    Callback = function(option)
        settings.SelectedPosition = option
        saveSettings()
    end
})

teleportTab:AddButton({
    Name = "選択した場所にテレポート",
    Callback = function()
        local pos = settings.SavedPositions[settings.SelectedPosition]
        if pos then
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

local function storeCurrentPosition()
    settings.LastLocation = humanoidRootPart.Position
    saveSettings()
end
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
local function verifyKey()
    local acceptedKeys = {
        Masashi0305 = true,
        ["DailyKey"] = tostring(os.date("%Y%m%d")),
        ["WebKey"] = tostring(game:HttpGet("https://pastebin.com/raw/YOUR_KEY_HERE"))
    }
    local inputKey = "Masashi0305" -- GUI入力に変更も可能

    if acceptedKeys[inputKey] == true or acceptedKeys["DailyKey"] == inputKey or acceptedKeys["WebKey"] == inputKey then
        return true
    else
        OrionLib:MakeNotification({Name = "キー無効", Content = "正しいキーを入力してください。", Time = 5})
        return false
    end
end

if not verifyKey() then return end
--== 保存済みの位置の削除機能 ==--
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
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "その名前の位置は存在しません。",
                Time = 3
            })
        end
    end
})

--== キー入力をGUIで行うように ==--
local keyTab = Window:MakeTab({
    Name = "キー認証",
    Icon = "rbxassetid://6031280882",
    PremiumOnly = false
})

keyTab:AddTextbox({
    Name = "キーを入力",
    Default = "",
    TextDisappear = true,
    Callback = function(input)
        local acceptedKeys = {
            Masashi0305 = true,
            [tostring(os.date("%Y%m%d"))] = true,
            ["WebKey"] = tostring(game:HttpGet("https://pastebin.com/raw/YOUR_KEY_HERE"))
        }

        if acceptedKeys[input] or acceptedKeys["WebKey"] == input then
            OrionLib:MakeNotification({Name = "認証成功", Content = "スクリプトが有効化されました！", Time = 5})
            -- 必要であればここで機能をアンロック
        else
            OrionLib:MakeNotification({Name = "認証失敗", Content = "キーが間違っています。", Time = 5})
        end
    end
})

--== GUI表示・非表示をF4キーで切り替え ==--
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F4 then
        OrionLib:ToggleUI()
    end
end)
