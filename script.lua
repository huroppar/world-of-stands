-- 許可ユーザーのみ実行可（GUIベースで制御予定なら削除可）
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local allowedUsers = {
    ["Furoppersama"] = true,
    ["fsjsjnsnsnsnns"] = true,
    ["Furopparsama"] = true
}

if not allowedUsers[LocalPlayer.Name] then
    warn("許可されていないユーザーです")
    return
end

-- OrionLib読み込み
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local Window = OrionLib:MakeWindow({Name = "World of Stands Utility", HidePremium = false, SaveConfig = true, ConfigFolder = "WOS_Config"})
local MainTab = Window:MakeTab({ Name = "メイン", Icon = "rbxassetid://4483345998", PremiumOnly = false })

-- ScreenGuiを作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirbyScreenGui"
ScreenGui.Parent = game:GetService("CoreGui") -- CoreGuiに入れる（今度はOK！）

-- カービィボタンを作成
local KirbyButton = Instance.new("ImageButton")
KirbyButton.Name = "KirbyButton"
KirbyButton.Size = UDim2.new(0, 50, 0, 50)
KirbyButton.Position = UDim2.new(0, 10, 0, 10) -- 左上に表示
KirbyButton.BackgroundTransparency = 1
KirbyButton.Image = "rbxassetid://77339698" -- ニコニコカービィ
KirbyButton.Parent = ScreenGui -- ←今度はScreenGuiに入れる
KirbyButton.Active = true
KirbyButton.Draggable = true

-- 最初はWindowを非表示にする
Window.Enabled = false

-- カービィ押したらGUI表示
KirbyButton.MouseButton1Click:Connect(function()
    Window.Enabled = true
    KirbyButton.Visible = false
end)

-- スピード
local speedEnabled = false
local speedValue = 16
local speedConnection

MainTab:AddToggle({
    Name = "スピード有効化",
    Default = false,
    Callback = function(value)
        speedEnabled = value
        if value then
            if speedConnection then speedConnection:Disconnect() end
            speedConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
                end
            end)
        else
            if speedConnection then speedConnection:Disconnect() end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 30
            end
        end
    end
})

MainTab:AddSlider({
    Name = "スピード調整",
    Min = 1,
    Max = 100,
    Default = 30,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        speedValue = value
    end
})

-- 無限ジャンプ
local infiniteJumpEnabled = false
MainTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(value)
        infiniteJumpEnabled = value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip
local noclipEnabled = false
MainTab:AddToggle({
    Name = "壁貫通（Noclip）",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
    end
})

game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 空中TPボタン
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "TeleportGui"

local floatingButton = Instance.new("TextButton")
floatingButton.Size = UDim2.new(0, 100, 0, 50)
floatingButton.Position = UDim2.new(0.5, -50, 1, -100)
floatingButton.Text = "空中TP"
floatingButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingButton.Parent = screenGui
floatingButton.Active = true
floatingButton.Draggable = true

MainTab:AddToggle({
    Name = "空中TPボタン表示",
    Default = true,
    Callback = function(value)
        teleportButtonVisible = value
        if floatingButton then
            floatingButton.Visible = value
        end
    end
})

local floating = false
local originalPosition

floatingButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if not floating then
            originalPosition = hrp.Position

            -- 上空に移動
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 500000, 0)

            -- BodyVelocityで落下防止
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "FloatForce"
            bodyVel.Velocity = Vector3.new(0, 0, 0)
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Parent = hrp

            -- PlatformStandでその場静止
            if humanoid then
                humanoid.PlatformStand = true
            end

            -- 足場作成
            local ground = Instance.new("Part")
            ground.Size = Vector3.new(10, 1, 10)
            ground.Position = hrp.Position - Vector3.new(0, 5, 0)
            ground.Anchored = true
            ground.CanCollide = true
            ground.Parent = workspace

            floating = true
        else
            -- 戻す処理
            hrp.CFrame = CFrame.new(originalPosition)

            -- 落下防止解除
            local float = hrp:FindFirstChild("FloatForce")
            if float then
                float:Destroy()
            end

            if humanoid then
                humanoid.PlatformStand = false
            end

            floating = false
        end
    end
end)


-- 敵を集める
local gatherDistance = 50
local RunService = game:GetService("RunService")
local gatheredEnemies = {}
local gathering = false

local function startGatheringEnemies()
    gathering = true
    table.clear(gatheredEnemies)
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") and model ~= LocalPlayer.Character then
            if not model:FindFirstChild("Dialogue") and not model:FindFirstChild("QuestBubble") then
                local enemyHRP = model.HumanoidRootPart
                local dist = (enemyHRP.Position - myHRP.Position).Magnitude
                if dist <= gatherDistance then
                    table.insert(gatheredEnemies, model)
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if gathering then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        for _, enemy in pairs(gatheredEnemies) do
            if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                local eHRP = enemy.HumanoidRootPart
                eHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -5)
            end
        end
    end
end)

MainTab:AddToggle({
    Name = "敵を集める",
    Default = false,
    Callback = function(val)
        if val then
            startGatheringEnemies()
        else
            gathering = false
            gatheredEnemies = {}
        end
    end
})

MainTab:AddSlider({
    Name = "敵集め距離",
    Min = 1,
    Max = 200,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        gatherDistance = value
    end
})

MainTab:AddTextbox({
    Name = "敵集め 距離（手入力）",
    Default = "50",
    TextDisappear = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 then
            gatherDistance = num
        end
    end
})

local CollectEnemies = false

-- メインタブにトグル追加
MainTab:AddToggle({
    Name = "連続で敵を集める",
    Default = false,
    Callback = function(Value)
        CollectEnemies = Value
        if CollectEnemies then
            -- ONになったらループ開始
            task.spawn(function()
                while CollectEnemies do
                    startGatheringEnemies() -- ← ここをGatherEnemies()じゃなくてstartGatheringEnemies()に！
                    task.wait(0.5) -- 0.5秒待つ
                end
            end)
        end
    end
})

local selectedPlayer = nil
local dropdown
local following = false
local connection = nil
local savedCFrame = nil

-- プレイヤー取得
local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- ドロップダウンリフレッシュ
local function refreshDropdownOptions()
    if dropdown and dropdown.Refresh then
        dropdown:Refresh(getPlayerNames(), true)
    end
end

-- ドロップダウン作成
local function createDropdown()
    dropdown = MainTab:AddDropdown({
        Name = "プレイヤーを選択",
        Default = "",
        Options = getPlayerNames(),
        Callback = function(value)
            selectedPlayer = value
        end
    })
end

-- 自動でプレイヤーリスト更新 (例: 5秒ごと)
task.spawn(function()
    while true do
        task.wait(5)
        refreshDropdownOptions()
    end
end)

createDropdown()

-- テレポートボタン
MainTab:AddButton({
    Name = "選択したプレイヤーの近くにテレポート",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 2)
        end
    end
})

-- リスト手動更新ボタン
MainTab:AddButton({
    Name = "プレイヤーリストを手動更新",
    Callback = function()
        refreshDropdownOptions()
        OrionLib:MakeNotification({
            Name = "更新完了",
            Content = "プレイヤー一覧を更新しました！",
            Time = 3
        })
    end
})

-- 密着追尾ON/OFFトグル
MainTab:AddToggle({
    Name = "密着追尾(オン/オフ)",
    Default = false,
    Callback = function(state)
        following = state
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if following then
            if myHRP then
                savedCFrame = myHRP.CFrame
            end

            connection = game:GetService("RunService").Heartbeat:Connect(function()
                local target = Players:FindFirstChild(selectedPlayer)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = target.Character.HumanoidRootPart
                    local targetPos = targetHRP.Position

                    if myHRP then
                        local offsetCFrame = targetHRP.CFrame * CFrame.new(0, 0, 7) -- 後ろ1.5スタッド
                        myHRP.CFrame = CFrame.new(offsetCFrame.Position, targetPos)
                    end
                end
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
            if savedCFrame and myHRP then
                myHRP.CFrame = savedCFrame
            end
        end
    end
})


local viewing = false
local originalCameraCFrame = nil
local originalCharacterCFrame = nil
local originalCameraType = nil
local humanoidConnection = nil

MainTab:AddButton({
    Name = "選択中のプレイヤー先に視点移動 (ジャンプで戻る)",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "選択したプレイヤーが見つかりません！",
                Time = 3
            })
            return
        end

        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")

        if not myHRP or not humanoid then
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "自分のキャラクター情報が取得できません！",
                Time = 3
            })
            return
        end

        if viewing then
            return
        end

        originalCameraCFrame = workspace.CurrentCamera.CFrame
        originalCharacterCFrame = myHRP.CFrame
        originalCameraType = workspace.CurrentCamera.CameraType

        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        workspace.CurrentCamera.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, -10)

        -- キャラクターの位置は変更しない
        myHRP.CFrame = originalCharacterCFrame  -- この部分を変更せずそのままにしておく

        viewing = true

        humanoidConnection = humanoid.StateChanged:Connect(function(_, newState)
            if viewing and newState == Enum.HumanoidStateType.Jumping then
                -- 視点を元に戻す
                if myHRP and originalCharacterCFrame then
                    myHRP.CFrame = originalCharacterCFrame
                end
                if originalCameraCFrame then
                    workspace.CurrentCamera.CFrame = originalCameraCFrame
                end
                if originalCameraType then
                    workspace.CurrentCamera.CameraType = originalCameraType
                end

                -- リセット
                viewing = false
                if humanoidConnection then
                    humanoidConnection:Disconnect()
                    humanoidConnection = nil
                end
            end
        end)
    end
})




MainTab:AddButton({
    Name = "透明化(PC非推奨)",
    Callback = function()
        loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
        -- 例: 敵に即時ダメージを与える、GUI表示、または外部コード取得など

        -- パターン①：HttpGetで外部スクリプトを実行
        loadstring(game:HttpGet("https://pastebin.com/raw/XXXXXXX"))()

        -- パターン②：内部処理を直接書く
        -- print("特定の処理を実行しました！")

        OrionLib:MakeNotification({
            Name = "透明化実行",
            Content = "透明化を実行しました！",
            Time = 3
        })
    end
})

-- OrionLibを取得してる前提
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local playerHighlights = {}
local highlightEnabled = true

-- ハイライト適用処理
local function applyHighlight(player)
	local character = player.Character
	if not character then return end

	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end

	local isTimeErasing = character:FindFirstChild("TimeErase") and character.TimeErase.Value

	-- ハイライト有効かつTimeErase中じゃないときだけ表示
	if highlightEnabled and not isTimeErasing then
		-- 再スポーン後でキャラが変わったときにも対応
		local existingHighlight = playerHighlights[player]
		if not existingHighlight or existingHighlight.Adornee ~= character then
			if existingHighlight then
				existingHighlight:Destroy()
			end

			local highlight = Instance.new("Highlight")
			highlight.Name = "PlayerHighlight"
			highlight.FillColor = Color3.fromRGB(255, 255, 0)
			highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0
			highlight.Adornee = character
			highlight.Parent = character
			playerHighlights[player] = highlight
		end
	else
		if playerHighlights[player] then
			playerHighlights[player]:Destroy()
			playerHighlights[player] = nil
		end
	end
end


-- 全プレイヤーのハイライトを更新
local function updatePlayerHighlights()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			applyHighlight(player)
		end
	end
end

-- GUIトグル
MainTab:AddToggle({
	Name = "プレイヤーハイライト",
	Default = true,
	Callback = function(value)
		highlightEnabled = value
		updatePlayerHighlights()
	end
})

-- 新しく入ったプレイヤー／復活時にも処理
local function setupCharacterListener(player)
	player.CharacterAdded:Connect(function()
		task.wait(1) -- 少し待機してから適用
		applyHighlight(player)
	end)
end

-- 初期プレイヤー設定
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		setupCharacterListener(player)
		applyHighlight(player)
	end
end

-- 新しいプレイヤー
Players.PlayerAdded:Connect(function(player)
	if player ~= LocalPlayer then
		setupCharacterListener(player)
	end
end)

-- 定期チェック（TimeErase対策含む）
while true do
	task.wait(1)
	updatePlayerHighlights()
end

-- リセットボタン作成
MainTab:AddButton({
    Name = "キャラクターリセット",  -- ボタンのラベル名
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()

        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0  -- 強制的にキャラクターをリセット
        end
    end
})


-- 最後に通知
OrionLib:MakeNotification({
    Name = "WOSユーティリティ",
    Content = "スクリプトの読み込みが完了しました！ - by Masashi",
    Time = 5
})
