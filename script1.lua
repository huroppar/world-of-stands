--// Masashi Script : World of Stands Most Useful Script
--// Solara V3 Compatible | Author: Masashi

--== OrionLib (Solara対応) ==--
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

--== Services ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

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
    LastLocation = nil
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

--== プレイヤー位置保存＆テレポート ==--
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

--== 移動前の位置を保存（自動） ==--
local function storeCurrentPosition()
    settings.LastLocation = humanoidRootPart.Position
    saveSettings()
end

--== キーシステム（GUI入力式） ==--
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
        local acceptedKeys = {
            Masashi0305 = true,
            [tostring(os.date("%Y%m%d"))] = true,
            WebKey = tostring(game:HttpGet("https://pastebin.com/raw/YOUR_KEY_HERE"))
        }

        if acceptedKeys[inputKey] or acceptedKeys.WebKey == inputKey then
            OrionLib:MakeNotification({Name = "認証成功", Content = "スクリプトが有効化されました！", Time = 5})
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

--== 初期化通知 ==--
OrionLib:MakeNotification({
    Name = "設定復元完了",
    Content = "前回の状態が読み込まれました。",
    Image = "rbxassetid://4483345998",
    Time = 5
})
