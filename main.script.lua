-- OrionLibの読み込み（GitHubエラー対応版）
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

-- ユーザー情報
local LocalPlayer = game.Players.LocalPlayer
local username = LocalPlayer.Name

-- オーナーリスト（無条件起動）
local AuthorizedUsers = {
    ["Masashi"] = true,
    ["Furoppersama"] = true
}

-- 正しいキー
local ValidKey = "Masashi0407"

-- オーナー判定
if AuthorizedUsers[username] then
    -- 自動で起動
    OrionLib:MakeNotification({
        Name = "認証成功",
        Content = "ようこそ " .. username .. " さん！スクリプトを開始します。",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
    loadstring(game:HttpGet('https://raw.githubusercontent.com/wploits/critclhub/refs/heads/main/bluelockrivals.lua'))()
else
    -- キー入力GUI
    local Window = OrionLib:MakeWindow({Name = "Key System", HidePremium = false, SaveConfig = true, ConfigFolder = "KeyConfig"})

    local KeyTab = Window:MakeTab({
        Name = "キー入力",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    KeyTab:AddTextbox({
        Name = "キーを入力してください",
        Default = "",
        TextDisappear = true,
        Callback = function(input)
            if input == ValidKey then
                OrionLib:MakeNotification({
                    Name = "認証成功",
                    Content = "キーが正しいです。スクリプトを開始します。",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
                wait(1)
                loadstring(game:HttpGet('https://raw.githubusercontent.com/wploits/critclhub/refs/heads/main/bluelockrivals.lua'))()
            else
                OrionLib:MakeNotification({
                    Name = "エラー",
                    Content = "キーが間違っています。",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
            end
        end
    })
end
-- OrionLibの読み込み（GitHubエラー対応版）
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

-- ウィンドウ初期化
local Window = OrionLib:MakeWindow({Name = "🎯 スタンド厳選BOT", HidePremium = false, SaveConfig = true, ConfigFolder = "StandGachaGUI"})

-- UI状態保存
_G.StandGachaRunning = false
_G.TargetStand = "Star Platinum"

-- セクション作成
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

-- ガチャループ処理
function startGachaLoop()
	spawn(function()
		local ArrowList = {"Legendary Arrow", "Shiny Arrow", "Stand Arrow"}
		local player = game.Players.LocalPlayer

		local function getCurrentStand()
			-- スタンド名の正確な保存先に合わせて修正（仮：StandName）
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

-- GUI起動通知
OrionLib:MakeNotification({
	Name = "Gacha BOT Ready!",
	Content = "Masashi式ガチャスクリプト 起動完了！",
	Image = "rbxassetid://4483345998",
	Time = 5
})
