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

-- オート攻撃ループ
task.spawn(function()
    while true do
        if farming and targetEnemyName ~= "" then
            for _, enemy in pairs(workspace:GetDescendants()) do
                if enemy.Name == targetEnemyName and enemy:FindFirstChild("HumanoidRootPart") then
                    -- 攻撃処理（ここをゲームに合わせてチューニングできる）
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) -- 敵の近くに移動
                        -- 攻撃イベントがあればここに書く（例: fireclickdetector, RemoteEvent, etc）
                    end
                end
            end
        end
        task.wait(0.5) -- 実行間隔調整（重くなったらここを1以上に）
    end
end)
