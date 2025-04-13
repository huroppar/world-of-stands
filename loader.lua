loadstring(game:HttpGet("https://raw.githubusercontent.com/huroppar/world-of-stands/main/script.lua"))()

local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/huroppar/world-of-stands/main/script.lua"))()
end)

if not success then
    warn("スクリプトの読み込みに失敗しました:", result)
end
