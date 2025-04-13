--== キーシステム ==--
local validKey1 = "Masashi0305" -- 自分だけのキー
local validKey2 = os.date("%Y-%m-%d") -- 毎日変わるキー
local validKey3 = nil

-- Web取得キー（必要なら外部URLを使って設定できる）
pcall(function()
    local keyUrl = "https://pastebin.com/raw/xxxxxx" -- あればここにキーを置く
    validKey3 = game:HttpGet(keyUrl)
end)

local correctKey = false

--== GUIでキー入力 ==--
local KeyTab = Window:MakeTab({ Name = "🔑 KeySystem", Icon = "🔐", PremiumOnly = false })
KeyTab:AddTextbox({
    Name = "キーを入力してください",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        if value == validKey1 or value == validKey2 or value == validKey3 then
            OrionLib:MakeNotification({
                Name = "キー認証成功",
                Content = "アクセス許可されました。",
                Image = "rbxassetid://4483345998",
                Time = 4
            })
            correctKey = true
        else
            OrionLib:MakeNotification({
                Name = "キーエラー",
                Content = "キーが間違っています。",
                Image = "rbxassetid://4483345998",
                Time = 4
            })
        end
    end
})

--== 認証後に機能表示 ==--
local function waitForKey()
    repeat
        task.wait(0.5)
    until correctKey
end

waitForKey()

--== 各機能ページ定義 ==--
local MainTab = Window:MakeTab({ Name = "🏠 Main", Icon = "🏹", PremiumOnly = false })
local TP_Tab = Window:MakeTab({ Name = "🚀 Teleport", Icon = "🌍", PremiumOnly = false })
local PlayerTab = Window:MakeTab({ Name = "👤 Player", Icon = "⚡", PremiumOnly = false })
local QuestTab = Window:MakeTab({ Name = "📜 Quest", Icon = "📌", PremiumOnly = false })
local UtilityTab = Window:MakeTab({ Name = "🧰 Utility", Icon = "🛠️", PremiumOnly = false })
