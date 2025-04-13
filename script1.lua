--// Masashi Script : World of Stands Most Useful Script
--// Solara V3 Compatible | Author: Masashi

--== OrionLib (Solara対応) ==--
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

--== Services ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--== データ保存用 ==--
local saveFileName = "MasashiScriptSettings.json"
local settings = {}

local function saveSettings()
    writefile(saveFileName, HttpService:JSONEncode(settings))
end

local function loadSettings()
    if isfile(saveFileName) then
        settings = HttpService:JSONDecode(readfile(saveFileName))
    end
end

loadSettings()

--== GUI 初期化 ==--
local Window = OrionLib:MakeWindow({
    Name = "🌟 WOS Most Useful Script",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "MasashiWOS",
    IntroText = "By Masashi",
    IntroIcon = "rbxassetid://4483345998"
})

OrionLib:MakeNotification({
    Name = "ようこそ！",
    Content = "Masashi Scriptを読み込みました。",
    Image = "rbxassetid://4483345998",
    Time = 5
})
