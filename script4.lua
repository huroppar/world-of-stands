--== 無限ジャンプ オンオフ ==--
local InfiniteJumpEnabled = false
PlayerTab:AddToggle({
    Name = "🌕 無限ジャンプ",
    Default = false,
    Callback = function(value)
        InfiniteJumpEnabled = value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

--== スピード変更（制限付き）==--
local maxSpeed = 44
PlayerTab:AddSlider({
    Name = "🏃‍♂️ スピード変更 (最大45未満)",
    Min = 16,
    Max = maxSpeed,
    Default = 16,
    Increment = 1,
    Callback = function(speed)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
})

--== 透明化 オンオフ + キー設定 ==--
local invisEnabled = false
local invisKey = Enum.KeyCode.J

PlayerTab:AddBind({
    Name = "👻 透明化トグルキー",
    Default = invisKey,
    Hold = false,
    Callback = function()
        invisEnabled = not invisEnabled
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = invisEnabled and 1 or 0
                end
            end
        end
    end
})

--== 上空テレポート・復帰機能 ==--
local lastPosition = nil
TP_Tab:AddButton({
    Name = "⬆️ 上にテレポート",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if not lastPosition then
                lastPosition = hrp.Position
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 150, 0)
            else
                hrp.CFrame = CFrame.new(lastPosition)
                lastPosition = nil
            end
        end
    end
})

--== 場所保存・リスト表示・名前変更・削除・テレポート ==--
local savedPositions = {}

local function refreshSavedPositionsUI()
    TP_Tab:Clear()
    for i, pos in pairs(savedPositions) do
        TP_Tab:AddButton({
            Name = "📍 " .. pos.name,
            Callback = function()
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(pos.position)
                end
            end
        })

        TP_Tab:AddTextbox({
            Name = "✏️ 名前変更: " .. pos.name,
            Default = pos.name,
            Callback = function(newName)
                pos.name = newName
                refreshSavedPositionsUI()
            end
        })

        TP_Tab:AddButton({
            Name = "🗑️ 削除: " .. pos.name,
            Callback = function()
                table.remove(savedPositions, i)
                refreshSavedPositionsUI()
            end
        })
    end
end

TP_Tab:AddButton({
    Name = "💾 今の場所を保存",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            table.insert(savedPositions, {
                name = "場所" .. tostring(#savedPositions + 1),
                position = hrp.Position
            })
            refreshSavedPositionsUI()
        end
    end
})

--== 光の柱 オンオフ + 表示 ==--
local beamsEnabled = false
local beamFolder = Instance.new("Folder", game.Workspace)
beamFolder.Name = "MasashiBeams"

UtilityTab:AddToggle({
    Name = "🗼 光の柱表示",
    Default = false,
    Callback = function(value)
        beamsEnabled = value
        beamFolder:ClearAllChildren()
        if beamsEnabled then
            for _, pos in pairs(savedPositions) do
                local part = Instance.new("Part", beamFolder)
                part.Anchored = true
                part.CanCollide = false
                part.Size = Vector3.new(0.5, 500, 0.5)
                part.CFrame = CFrame.new(pos.position + Vector3.new(0, 250, 0))
                part.Color = Color3.fromRGB(0, 255, 255)
                part.Material = Enum.Material.Neon
                part.Transparency = 0.3
                part.Name = "Beam_" .. pos.name
            end
        end
    end
})
