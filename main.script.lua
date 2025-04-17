-- OrionLibの読み込み（GitHubエラー対応版）
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

-- ユーザー名と認証キー設定
local BypassUsers = {
	["Furoppersama"] = true,
	["BNVGUE2"] = true,
	["Furopparsama"] = true
}
local CorrectKey = "Masashi0407"
local playerName = game.Players.LocalPlayer.Name

-- GUIウィンドウの初期化（仮置き）
local Window

-- 認証成功後にGUI作成
local function initGUI()
	Window = OrionLib:MakeWindow({Name = "🎯 スタンド厳選BOT", HidePremium = false, SaveConfig = true, ConfigFolder = "StandGachaGUI"})

	-- UI状態保存
	_G.StandGachaRunning = false
	_G.TargetStand = "Star Platinum"

	local Tab = Window:MakeTab({
		Name = "Main",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	Tab:AddTextbox({
		Name = "目当てのスタンド名",
		Default = "Star Platinum",
		TextDisappear = false,
		Callback = function(Value)
			_G.TargetStand = Value
		end
	})

	Tab:AddToggle({
		Name = "自動ガチャ ON/OFF",
		Default = false,
		Callback = function(Value)
			_G.StandGachaRunning = Value
			if Value then
				startGachaLoop()
			end
		end
	})

	-- GUI起動通知
	OrionLib:MakeNotification({
		Name = "Gacha BOT Ready!",
		Content = "Masashi式ガチャスクリプト 起動完了！",
		Image = "rbxassetid://4483345998",
		Time = 5
	})
end

-- ガチャループ処理
function startGachaLoop()
	spawn(function()
		local ArrowList = {"Legendary Arrow", "Shiny Arrow", "Stand Arrow"}
		local player = game.Players.LocalPlayer

		local function getCurrentStand()
			local s = player:FindFirstChild("StandName") or player:FindFirstChild("Data") and player.Data:FindFirstChild("Stand")
			return s and s.Value or "Unknown"
		end

		local function useTool(name)
			local tool = player.Backpack:FindFirstChild(name)
			if tool then
				tool.Parent = player.Character
				wait(0.2)
				tool:Activate()
				return true
			end
			return false
		end

		while _G.StandGachaRunning do
			local usedArrow = false
			for _, arrow in ipairs(ArrowList) do
				if useTool(arrow) then
					usedArrow = true
					break
				end
			end

			if not usedArrow then
				OrionLib:MakeNotification({
					Name = "矢切れ！",
					Content = "矢がなくなったので停止しました。",
					Image = "rbxassetid://4483345998",
					Time = 5
				})
				_G.StandGachaRunning = false
				break
			end

			wait(3)

			if getCurrentStand() == _G.TargetStand then
				OrionLib:MakeNotification({
					Name = "成功！",
					Content = "目当ての [" .. _G.TargetStand .. "] を引き当てたぞ！",
					Image = "rbxassetid://4483345998",
					Time = 8
				})
				_G.StandGachaRunning = false
				break
			else
				if not useTool("Rokakaka") then
					OrionLib:MakeNotification({
						Name = "ロカカカ切れ！",
						Content = "リセットできないので停止します。",
						Image = "rbxassetid://4483345998",
						Time = 5
					})
					_G.StandGachaRunning = false
					break
				end
				wait(3)
			end
		end
	end)
end

-- 認証処理
if BypassUsers[playerName] then
	initGUI()
else
	local inputKey = ""
	local AuthTab = OrionLib:MakeWindow({Name = "🔐 認証が必要です", HidePremium = false}):MakeTab({
		Name = "Key認証",
		Icon = "rbxassetid://6031071053",
		PremiumOnly = false
	})

	AuthTab:AddTextbox({
		Name = "キーを入力してください",
		Default = "",
		TextDisappear = false,
		Callback = function(Value)
			inputKey = Value
		end
	})

	AuthTab:AddButton({
		Name = "キー認証",
		Callback = function()
			if inputKey == CorrectKey then
				OrionLib:MakeNotification({
					Name = "認証成功！",
					Content = "ようこそ、" .. playerName .. "！",
					Image = "rbxassetid://4483345998",
					Time = 5
				})
				wait(0.5)
				initGUI()
			else
				OrionLib:MakeNotification({
					Name = "認証失敗",
					Content = "キーが間違っています。",
					Image = "rbxassetid://7733960981",
					Time = 5
				})
			end
		end
	})
end
