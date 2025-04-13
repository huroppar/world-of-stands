print("👋 Hello from working script.lua with OrionLib!")

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1iseeyou/OrionLib/main/source.lua"))()

OrionLib:MakeNotification({
    Name = "成功！",
    Content = "OrionLib 読み込めたよ！",
    Image = "rbxassetid://4483345998",
    Time = 5
})
