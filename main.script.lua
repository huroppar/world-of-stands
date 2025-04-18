--[[
    World of Stands Most Useful Script - Rebuild
    Author: Masashi
    Key: Masashi0407
--]]

if not game:IsLoaded() then game.Loaded:Wait() end
if _G.__WOS_GUI_RUNNING then return end
_G.__WOS_GUI_RUNNING = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()

--// Key System
local allowedUsers = {
    ["Furoppersama"] = true,
    ["Furopparsama"] = true
}
local correctKey = "Masashi0407"
if not allowedUsers[LocalPlayer.Name] then
    local inputKey = OrionLib:Prompt("Key Required", "Enter your key to use the script:")
    while inputKey ~= correctKey do
        OrionLib:Notify("Wrong Key", "Try again.", 3)
        inputKey = OrionLib:Prompt("Key Required", "Enter your key to use the script:")
    end
    OrionLib:Notify("Access Granted", "Welcome!", 3)
end

--// GUI Setup
local Window = OrionLib:MakeWindow({Name = "🌟 WOS | Masashi Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "MasashiWOS"})

--// Speed Control
local SpeedTab = Window:MakeTab({Name = "Speed", Icon = "rbxassetid://6026568198", PremiumOnly = false})
local speedValue = 16
local speedEnabled = false

SpeedTab:AddToggle({
    Name = "Speed Toggle",
    Default = false,
    Callback = function(v)
        speedEnabled = v
    end
})

SpeedTab:AddSlider({
    Name = "Speed (1~500)",
    Min = 1,
    Max = 500,
    Default = 16,
    Callback = function(v)
        speedValue = v
    end
})

SpeedTab:AddTextbox({
    Name = "Manual Speed Input",
    Default = tostring(speedValue),
    TextDisappear = false,
    Callback = function(v)
        local num = tonumber(v)
        if num then
            speedValue = math.clamp(num, 1, 500)
        end
    end
})

RunService.RenderStepped:Connect(function()
    pcall(function()
        if speedEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.WalkSpeed ~= speedValue then
                hum.WalkSpeed = speedValue
            end
        end
    end)
end)

--// Player List
local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "rbxassetid://6031094678", PremiumOnly = false})
local playerNames = {}

local function updatePlayers()
    table.clear(playerNames)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerNames, p.Name)
        end
    end
end

updatePlayers()
Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

TeleportTab:AddDropdown({
    Name = "Teleport to Player",
    Default = "",
    Options = playerNames,
    Callback = function(selected)
        local target = Players:FindFirstChild(selected)
        if target and target.Character then
            LocalPlayer.Character:PivotTo(target.Character:GetPivot() + Vector3.new(3, 0, 3))
        end
    end
})

--// Fly (Air TP) Button
local flyTab = Window:MakeTab({Name = "Air Tools", Icon = "rbxassetid://6031260795", PremiumOnly = false})
local flyBtn

flyTab:AddButton({
    Name = "Air Teleport",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local originalCFrame = root.CFrame
        root.Anchored = true
        root.CFrame = root.CFrame + Vector3.new(0, 10000, 0)
        wait(1)
        root.Anchored = false
        wait(0.5)
        root.CFrame = originalCFrame
    end
})

--// GUI Minimize
local toggle = false
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        toggle = not toggle
        Window.Enabled = toggle
    end
end)

OrionLib:Init()
