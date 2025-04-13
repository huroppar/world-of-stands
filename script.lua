local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- 敵の名前に含まれそうなワード
local enemyKeywords = {"Bandit", "Thug", "Enemy", "NPC"}

local function getNearestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local root = char.HumanoidRootPart
    local nearest, shortestDist = nil, math.huge

    for _, model in pairs(workspace:GetDescendants()) do
        if model and model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
            if model.Name then
                for _, keyword in ipairs(enemyKeywords) do
                    if model.Name:lower():find(keyword:lower()) then
                        local dist = (model.HumanoidRootPart.Position - root.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            nearest = model
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local function attack()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, "E", false, game)
end

-- 自動攻撃ループ
local farming = true
task.spawn(function()
    while farming do
        local enemy = getNearestEnemy()
        if enemy then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            if root and enemyRoot then
                root.CFrame = CFrame.new(enemyRoot.Position + Vector3.new(0, 0, 3))
                attack()
            end
        end
        task.wait(0.3)
    end
end)
