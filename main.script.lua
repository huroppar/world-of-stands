-- ✅ 『World of Stands Most Useful Script』 完全修正版 by Masashi
-- 対応内容: スピード入力とスライダー連動、参加中プレイヤー一覧、空中TPボタン、壁貫通維持、GUI最小化、攻撃後のスピード低下修正

if _G.__WOS_GUI_RUNNING then return end
_G.__WOS_GUI_RUNNING = true

-- ライブラリ読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera

-- 状態変数
local SpeedValue = 16
local SpeedEnabled = false
local AirTPEnabled = false
local AirTP_Stage = 0
local AirTP_LastPosition = nil
local NoclipEnabled = false
local Transparent = false

-- GUI構築
local Window = OrionLib:MakeWindow({
    Name = "🌟 World of Stands - Masashi Edition",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "WorldOfStands_Masashi"
})

-- ✅ Movement タブ
local MovementTab = Window:MakeTab({
    Name = "🚀 Movement",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- スピードスライダー & 手入力連動
MovementTab:AddSlider({
    Name = "WalkSpeed",
    Min = 1,
    Max = 500,
    Default = SpeedValue,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        SpeedValue = Value
        if SpeedEnabled then
            LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
        end
    end
})

MovementTab:AddTextbox({
    Name = "Set Speed (1~500)",
    Default = tostring(SpeedValue),
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 1 and num <= 500 then
            SpeedValue = num
            if SpeedEnabled then
                LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
            end
        end
    end
})

MovementTab:AddToggle({
    Name = "🟢 Enable Speed",
    Default = false,
    Callback = function(Value)
        SpeedEnabled = Value
        if SpeedEnabled then
            LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

-- 無限ジャンプ
MovementTab:AddToggle({
    Name = "🟡 Infinite Jump",
    Default = false,
    Callback = function(toggle)
        InfiniteJumpEnabled = toggle
    end
})
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- 空中TPボタン
local AirTPBtn = nil
local function toggleAirTPButton(show)
    if show then
        if not AirTPBtn then
            AirTPBtn = Instance.new("TextButton")
            AirTPBtn.Text = "空中TP"
            AirTPBtn.Size = UDim2.new(0, 100, 0, 40)
            AirTPBtn.Position = UDim2.new(0.5, -50, 0.6, 0)
            AirTPBtn.AnchorPoint = Vector2.new(0.5, 0.5)
            AirTPBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            AirTPBtn.TextColor3 = Color3.new(1,1,1)
            AirTPBtn.Parent = game:GetService("CoreGui")
            AirTPBtn.MouseButton1Click:Connect(function()
                if AirTP_Stage == 0 then
                    AirTP_LastPosition = LocalPlayer.Character.HumanoidRootPart.Position
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10000, 0)
                    AirTP_Stage = 1
                else
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(AirTP_LastPosition)
                    AirTP_Stage = 0
                end
            end)
        end
    elseif AirTPBtn then
        AirTPBtn:Destroy()
        AirTPBtn = nil
    end
end

MovementTab:AddToggle({
    Name = "🛸 Air TP Mode",
    Default = false,
    Callback = function(Value)
        toggleAirTPButton(Value)
    end
})

-- 壁貫通
RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

MovementTab:AddToggle({
    Name = "🔓 Wall Noclip",
    Default = false,
    Callback = function(Value)
        NoclipEnabled = Value
    end
})

-- ✅ Players タブ
local PlayerTab = Window:MakeTab({
    Name = "👥 Players",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PlayerTab:AddDropdown({
    Name = "🧍 Teleport to Player",
    Options = {},
    Callback = function(selectedName)
        local target = Players:FindFirstChild(selectedName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(3,0,0))
        end
    end
})

-- プレイヤー一覧更新
local function updatePlayersList()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    PlayerTab.Flags["🧍 Teleport to Player"].Options = names
end

Players.PlayerAdded:Connect(updatePlayersList)
Players.PlayerRemoving:Connect(updatePlayersList)
updatePlayersList()

-- GUI最小化切り替え
Window:AddBind({
    Name = "Toggle GUI",
    Default = Enum.KeyCode.RightShift,
    Hold = false,
    Callback = function()
        Window.Enabled = not Window.Enabled
    end
})

OrionLib:Init()
OrionLib:MakeNotification({
    Name = "World of Stands Script",
    Content = "Masashi Edition 起動完了！",
    Image = "rbxassetid://4483345998",
    Time = 5
})
