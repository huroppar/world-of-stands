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
    savedLocations = {},
    speed = 16,
    infJump = false
}

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

--== プレイヤー位置保存・テレポート ==--
local teleportTab = Window:MakeTab({
    Name = "テレポート",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

teleportTab:AddTextbox({
    Name = "保存名入力",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        settings.tempName = value
    end
})

teleportTab:AddButton({
    Name = "現在地を保存",
    Callback = function()
        if settings.tempName and settings.tempName ~= "" then
            local pos = humanoidRootPart.Position
            settings.savedLocations[settings.tempName] = {x = pos.X, y = pos.Y, z = pos.Z}
            OrionLib:MakeNotification({Name = "保存完了", Content = settings.tempName .. " を保存しました。", Time = 3})
            saveSettings()
        end
    end
})

teleportTab:AddDropdown({
    Name = "保存された場所",
    Options = table.keys(settings.savedLocations),
    Callback = function(value)
        settings.lastSelected = value
    end
})

teleportTab:AddButton({
    Name = "選択場所にテレポート",
    Callback = function()
        local loc = settings.savedLocations[settings.lastSelected]
        if loc then
            humanoidRootPart.CFrame = CFrame.new(loc.x, loc.y, loc.z)
        end
    end
})

teleportTab:AddButton({
    Name = "すべての保存場所を削除",
    Callback = function()
        settings.savedLocations = {}
        OrionLib:MakeNotification({Name = "削除完了", Content = "全ての場所を削除しました。", Time = 3})
        saveSettings()
    end
})

--== 無限ジャンプ ==--
UIS.JumpRequest:Connect(function()
    if settings.infJump then
        humanoidRootPart.Velocity = Vector3.new(0, 50, 0)
    end
end)

local funcTab = Window:MakeTab({
    Name = "基本機能",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

funcTab:AddToggle({
    Name = "無限ジャンプ",
    Default = settings.infJump,
    Callback = function(state)
        settings.infJump = state
        saveSettings()
    end
})

funcTab:AddSlider({
    Name = "移動スピード",
    Min = 16,
    Max = 45,
    Default = settings.speed,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        settings.speed = value
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
        saveSettings()
    end
})

--== 終了時に設定保存 ==--
game:BindToClose(function()
    saveSettings()
end)

OrionLib:Init()
