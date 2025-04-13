--// Masashi Script : World of Stands Most Useful Script
--// Solara V3 Compatible | Author: Masashi
--// Feather Iconsなしバージョン（カスタムOrionLib）

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/masashihub/wos-most-useful-script/main/OrionLibNoIcons.lua"))()

--== Services ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--== Settings Save ==--
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

--== UI Window ==--
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

--== タブ・セクション定義 ==--
local MainTab = Window:MakeTab({ Name = "Main", Icon = "", PremiumOnly = false })
local TeleportTab = Window:MakeTab({ Name = "Teleport", Icon = "", PremiumOnly = false })
local UtilityTab = Window:MakeTab({ Name = "Utility", Icon = "", PremiumOnly = false })
local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = "", PremiumOnly = false })

--== 🔁 敵を選んでテレポート ==--
local function bringEnemy(enemyName)
    for _, enemy in pairs(workspace:GetDescendants()) do
        if enemy.Name == enemyName and enemy:FindFirstChild("HumanoidRootPart") then
            enemy.HumanoidRootPart.CFrame = humanoidRootPart.CFrame
        end
    end
end

MainTab:AddTextbox({
    Name = "敵の名前を入力してテレポート",
    Default = "",
    TextDisappear = false,
    Callback = function(enemy)
        bringEnemy(enemy)
    end
})

--== ❤️ HPを1に ==--
MainTab:AddButton({
    Name = "HPを1にする（コンボ用）",
    Callback = function()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Health = 1 end
    end
})

--== 👻 透明化 ==--
local function invisible()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = 1
        end
    end
end

MainTab:AddButton({
    Name = "透明化（敵に見えない）",
    Callback = invisible
})

--== ⚡ スピード調整 ==--
UtilityTab:AddSlider({
    Name = "WalkSpeed調整",
    Min = 16,
    Max = 45,
    Default = 16,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = value end
        settings["Speed"] = value
        saveSettings()
    end
})

--== 💨 無限ジャンプ ==--
local infiniteJumpEnabled = false
UIS.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        humanoidRootPart.Velocity = Vector3.new(0, 50, 0)
    end
end)

UtilityTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
        settings["InfiniteJump"] = state
        saveSettings()
    end
})

--== ✨ 光の柱表示 ==--
local function createBeam(pos, color)
    local beam = Instance.new("Part", workspace)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Size = Vector3.new(0.2, 50, 0.2)
    beam.Position = pos + Vector3.new(0, 25, 0)
    beam.Color = color
    beam.Material = Enum.Material.Neon
    beam.Name = "BeamMarker"
    return beam
end

MainTab:AddButton({
    Name = "現在地に光の柱設置",
    Callback = function()
        createBeam(humanoidRootPart.Position, Color3.new(1, 1, 0))
    end
})

--== 📍 場所保存とワープ ==--
local savedLocations = settings["SavedLocations"] or {}

TeleportTab:AddTextbox({
    Name = "保存名",
    Default = "Point1",
    TextDisappear = false,
    Callback = function(name)
        savedLocations[name] = humanoidRootPart.Position
        settings["SavedLocations"] = savedLocations
        saveSettings()
    end
})

TeleportTab:AddDropdown({
    Name = "保存済みの場所にワープ",
    Options = table.keys(savedLocations),
    Callback = function(name)
        if savedLocations[name] then
            humanoidRootPart.CFrame = CFrame.new(savedLocations[name])
        end
    end
})

--== 🧬 無敵化（ベータ） ==--
MainTab:AddToggle({
    Name = "無敵化（Beta）",
    Default = false,
    Callback = function(enabled)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, not enabled)
        end
    end
})

--== 📁 設定保存チェック ==--
SettingsTab:AddButton({
    Name = "設定を手動で保存",
    Callback = function()
        saveSettings()
        OrionLib:MakeNotification({
            Name = "保存完了",
            Content = "設定が保存されました。",
            Time = 4
        })
    end
})
