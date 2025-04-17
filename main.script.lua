-- OrionLib 読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

-- プレイヤー名とキー認証
local allowedUsers = {
    Furoppersama = true,
    Furopparsama = true,
    BNVGUE2 = true
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not allowedUsers[LocalPlayer.Name] then
    local verified = false
    while not verified do
        local keyInput = OrionLib:MakeWindow({
            Name = "🔐 キー認証",
            HidePremium = false,
            SaveConfig = false,
            ConfigFolder = "KeySystem"
        })

        local correctKey = "Masashi0407"

        keyInput:MakeTab({Name = "キー入力", Icon = "rbxassetid://4483345998", PremiumOnly = false})
            :AddTextbox({
                Name = "キーを入力してください",
                Default = "",
                TextDisappear = false,
                Callback = function(input)
                    if input == correctKey then
                        verified = true
                        OrionLib:MakeNotification({
                            Name = "キー認証成功",
                            Content = "ようこそ、" .. LocalPlayer.Name .. "！",
                            Image = "rbxassetid://4483345998",
                            Time = 5
                        })
                    else
                        OrionLib:MakeNotification({
                            Name = "認証失敗",
                            Content = "キーが間違っています。もう一度入力してください。",
                            Image = "rbxassetid://4483345998",
                            Time = 5
                        })
                    end
                end
            })

        repeat wait() until verified
        keyInput.Enabled = false
    end
end

-- ↓ ここにあなたのメインスクリプトを貼り付けて使用してください
-- 上のコードと組み合わせ済みです
