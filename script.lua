local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1iseeyou/OrionLib/main/source.lua"))()

-- ウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "🛠️ Stand Power Controller",
    HidePremium = false,
    SaveConfig = true,
    IntroText = "World of Stands Hack Panel",
    ConfigFolder = "WOS_Util"
})

-- セクションと通知のテスト
OrionLib:MakeNotification({
    Name = "成功！",
    Content = "OrionLib 読み込み成功しました！",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- タブ作成
local Tab = Window:MakeTab({
    Name = "メイン",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ラベル追加
Tab:AddLabel("準備完了！ここから機能追加していこう💪")
