local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = OrionLib:MakeWindow({Name = "World of Stands", HidePremium = false, SaveConfig = false, IntroText = "Welcome!"})

local MainTab = Window:MakeTab({
	Name = "メイン",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local targetName = ""

MainTab:AddTextbox({
	Name = "プレイヤー名",
	Default = "",
	TextDisappear = false,
	Callback = function(value)
		targetName = value
	end
})

MainTab:AddButton({
	Name = "プレイヤーの近くにテレポート",
	Callback = function()
		local targetPlayer = Players:FindFirstChild(targetName)
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local myChar = LocalPlayer.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") then
				myChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
				OrionLib:MakeNotification({
					Name = "成功",
					Content = targetName .. " の近くにテレポートしました！",
					Image = "rbxassetid://4483345998",
					Time = 3
				})
			end
		else
			OrionLib:MakeNotification({
				Name = "エラー",
				Content = "プレイヤーが見つからないよ",
				Image = "rbxassetid://4483345998",
				Time = 3
			})
		end
	end
})

local FarmTab = Window:MakeTab({
    Name = "AutoFarm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local farming = false
local targetEnemyName = ""

FarmTab:AddTextbox({
    Name = "敵の名前を入力",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        targetEnemyName = value
    end
})

FarmTab:AddToggle({
    Name = "オート攻撃開始/停止",
    Default = false,
    Callback = function(state)
        farming = state
    end
})

task.spawn(function()
    while true do
        if farming and targetEnemyName ~= "" then
            local closestEnemy = nil
            local shortestDistance = math.huge
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if myRoot then
                for _, enemy in pairs(workspace:GetDescendants()) do
                    if enemy.Name == targetEnemyName and enemy:FindFirstChild("HumanoidRootPart") then
                        local distance = (myRoot.Position - enemy.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then
                            closestEnemy = enemy
                            shortestDistance = distance
                        end
                    end
                end

                if closestEnemy then
                    myRoot.CFrame = closestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    -- ここに攻撃イベントあれば追加
                end
            end
        end
        task.wait(1.5) -- 実行間隔：重すぎる場合はもっと増やしてもOK
    end
end)

local JumpEnabled = true
game:GetService("UserInputService").JumpRequest:Connect(function()
    if JumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

MainTab:AddTextbox({
    Name = "Speed",
    Default = "16",
    TextDisappear = false,
    Callback = function(value)
        local speed = tonumber(value)
        if speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
    end
})

task.spawn(function()
    while true do
        task.wait(0.5)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end)

-- 🔁 必要なサービス
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🧭 テレポート先プレイヤー名 & キー保存用
local targetName = ""
local teleportKey = Enum.KeyCode.T -- 初期キーをTに設定（GUIから変更可能）

-- 🪄 テレポート関数
local function teleportToPlayer()
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local targetPos = targetPlayer.Character.HumanoidRootPart.Position
            root.CFrame = CFrame.new(targetPos + Vector3.new(5, 0, 0)) -- 横に5
        end
    else
        OrionLib:MakeNotification({
            Name = "エラー",
            Content = "プレイヤーが見つかりませんでした！",
            Time = 3
        })
    end
end

-- 🧱 テレポートセクション
local teleportSection = TeleportTab:AddSection({Name = "テレポート機能"})

-- ✍️ 名前入力
teleportSection:AddTextbox({
    Name = "テレポート先プレイヤー名",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        targetName = value
    end
})

-- 🖱️ ボタンテレポート
teleportSection:AddButton({
    Name = "そのプレイヤーの横にテレポート",
    Callback = teleportToPlayer
})

-- 🎹 キー入力で割り当て
teleportSection:AddBind({
    Name = "テレポートキー設定",
    Default = Enum.KeyCode.T,
    Hold = false,
    Callback = function(key)
        teleportKey = key
    end
})

-- ⌨️ 実際のキー入力チェック
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == teleportKey then
        teleportToPlayer()
    end
end)

-- 👁️ 表示・非表示切り替えトグル
TeleportTab:AddToggle({
    Name = "テレポート機能を表示/非表示",
    Default = true,
    Callback = function(state)
        if teleportSection then
            for _, element in pairs(teleportSection["Items"] or {}) do
                element.Visible = state
            end
        end
    end
})
