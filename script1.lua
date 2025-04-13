--// Masashi Script : World of Stands Most Useful Script
--// Solara V3 Compatible | Author: Masashi

--== OrionLib (Feather Icons エラー回避版) ==--
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/3j5EzfEV"))()
pcall(function() OrionLib.FeatherIcons = {} end)

--== Services ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--== データ保存 ==--
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

--== スピード調整 ==--
local SpeedTab = Window:MakeTab({Name = "⚡ 移動系", Icon = "", PremiumOnly = false})
SpeedTab:AddSlider({
    Name = "移動スピード調整 (最大45)",
    Min = 16,
    Max = 45,
    Default = 16,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        if character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
})

--== 無限ジャンプ ==--
local InfiniteJumpEnabled = false
SpeedTab:AddToggle({
    Name = "💨 無限ジャンプ",
    Default = false,
    Callback = function(val)
        InfiniteJumpEnabled = val
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

--== テレポート機能 ==--
local TeleportTab = Window:MakeTab({Name = "📍 テレポート", Icon = "", PremiumOnly = false})

TeleportTab:AddButton({
    Name = "プレイヤー位置を保存",
    Callback = function()
        local pos = humanoidRootPart.Position
        settings.savedPosition = {x = pos.X, y = pos.Y, z = pos.Z}
        saveSettings()
        OrionLib:MakeNotification({Name = "保存完了", Content = "現在地を保存しました", Time = 3})
    end
})

TeleportTab:AddButton({
    Name = "保存位置にテレポート",
    Callback = function()
        local pos = settings.savedPosition
        if pos then
            humanoidRootPart.CFrame = CFrame.new(pos.x, pos.y, pos.z)
        else
            OrionLib:MakeNotification({Name = "エラー", Content = "保存された位置がありません", Time = 3})
        end
    end
})

--== 敵自動テレポート（指定名） ==--
local EnemyName = ""
TeleportTab:AddTextbox({
    Name = "敵の名前を入力",
    Default = "",
    TextDisappear = false,
    Callback = function(txt)
        EnemyName = txt
    end
})

TeleportTab:AddButton({
    Name = "🔁 敵を自分の所へテレポート",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v.Name:lower():find(EnemyName:lower()) then
                v:MoveTo(humanoidRootPart.Position)
            end
        end
    end
})

--== 自動HP1化 ==--
local AutoHP1 = false
SpeedTab:AddToggle({
    Name = "❤️ HPを1に固定",
    Default = false,
    Callback = function(val)
        AutoHP1 = val
    end
})

RunService.RenderStepped:Connect(function()
    if AutoHP1 and character and character:FindFirstChild("Humanoid") then
        character.Humanoid.Health = 1
    end
end)

--== 敵・プレイヤーの光の柱と名前表示 ==--
local VisualTab = Window:MakeTab({Name = "✨ 可視化", Icon = "", PremiumOnly = false})

VisualTab:AddButton({
    Name = "光の柱＋名前表示",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local part = Instance.new("Part", workspace)
                part.Anchored = true
                part.CanCollide = false
                part.Size = Vector3.new(0.5, 100, 0.5)
                part.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0)
                part.BrickColor = BrickColor.new("Bright yellow")
                part.Material = Enum.Material.Neon

                local nameBillboard = Instance.new("BillboardGui", part)
                nameBillboard.Size = UDim2.new(0, 100, 0, 40)
                nameBillboard.Adornee = part
                nameBillboard.AlwaysOnTop = true
                local label = Instance.new("TextLabel", nameBillboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.Text = plr.Name
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.new(1, 1, 0)
                label.TextScaled = true
            end
        end
    end
})

--== 無敵化・キック防止（ベータ）==--
SpeedTab:AddButton({
    Name = "🧬 無敵＆キック防止（テスト）",
    Callback = function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local namecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if tostring(method) == "Kick" then
                return
            end
            return namecall(self, ...)
        end)
        setreadonly(mt, true)
        OrionLib:MakeNotification({Name = "成功", Content = "Kick防止を有効化しました", Time = 3})
    end
})

--== GUIの表示非表示切り替え ==--
OrionLib:Init()
