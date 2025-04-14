local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "✨ Masashi Neon GUI ✨",
    HidePremium = false,
    SaveConfig = false
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddLabel("これはラベルです")

Tab:AddButton({
    Name = "押してみて！",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "通知テスト",
            Content = "ちゃんと動いてるよ！",
            Time = 3
        })
    end
})
