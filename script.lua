print("✅ Hello from script.lua!")

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
print("✅ OrionLib Loaded!")

local Window = OrionLib:MakeWindow({
    Name = "🌀 Stand Power Controller",
    HidePremium = false,
    SaveConfig = true,
    IntroText = "World of Stands Hack Panel",
    ConfigFolder = "WOS_Util"
})

print("✅ Window created!")
