-- OrionLibの読み込み
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

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
