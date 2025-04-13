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
