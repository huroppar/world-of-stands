-- 敵っぽい名前（必要ならカスタマイズしてね）
local enemyKeywords = {"Bandit", "Thug", "Enemy", "NPC"}

-- 距離チェック用
local function getNearestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local root = char.HumanoidRootPart
    local nearest, shortestDist = nil, math.huge

    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
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
    return nearest
end

-- 攻撃（Eキー押したときの動作を使う前提）
local function attack()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, "T", false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, "T", false, game)
end

-- 自動追尾 + 攻撃ループ
local farming = true
task.spawn(function()
    while farming do
        local enemy = getNearestEnemy()
        if enemy then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            if root and enemyRoot then
                -- 敵の近くに移動
                root.CFrame = CFrame.new(enemyRoot.Position + Vector3.new(0, 0, 3))
                attack()
            end
        end
        task.wait(0.3)
    end
end)
