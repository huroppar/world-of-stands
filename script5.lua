-- ▼▼ 場所保存・テレポート関連 ▼▼
local savedLocations = {}
local currentLocation = nil
local pillarFolder = Instance.new("Folder", workspace)
pillarFolder.Name = "TeleportPillars"

local function createPillar(pos, name)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(1, 200, 1)
    part.Position = pos + Vector3.new(0, 100, 0)
    part.Color = Color3.fromRGB(255, 255, 0)
    part.Material = Enum.Material.Neon
    part.Name = name
    part.Parent = pillarFolder
end

local function refreshPillars()
    pillarFolder:ClearAllChildren()
    if showPillars then
        for name, data in pairs(savedLocations) do
            createPillar(data.Position, name)
        end
    end
end

TeleportTab:AddTextbox({
    Name = "保存名を入力",
    Default = "Home",
    Callback = function(value)
        currentLocation = value
    end
})

TeleportTab:AddButton({
    Name = "現在地を保存",
    Callback = function()
        if currentLocation then
            savedLocations[currentLocation] = {
                Position = plr.Character.HumanoidRootPart.Position
            }
            OrionLib:MakeNotification({
                Name = "位置保存",
                Content = currentLocation .. " を保存しました！",
                Time = 3
            })
            refreshPillars()
        end
    end
})

TeleportTab:AddDropdown({
    Name = "保存した場所に移動",
    Options = {},
    Callback = function(selected)
        local loc = savedLocations[selected]
        if loc then
            plr.Character.HumanoidRootPart.CFrame = CFrame.new(loc.Position)
        end
    end
})

TeleportTab:AddButton({
    Name = "保存した場所をすべて更新",
    Callback = function()
        local dropdown = OrionLib:GetDropdown("保存した場所に移動")
        local keys = {}
        for name in pairs(savedLocations) do
            table.insert(keys, name)
        end
        dropdown:Refresh(keys)
    end
})

TeleportTab:AddToggle({
    Name = "光の柱を表示",
    Default = true,
    Callback = function(v)
        showPillars = v
        refreshPillars()
    end
})

-- ▼ 名前変更 / 削除 / プレイヤーの位置保存 ▼
TeleportTab:AddTextbox({
    Name = "変更対象の保存名",
    Default = "",
    Callback = function(v) selectedForEdit = v end
})

TeleportTab:AddTextbox({
    Name = "新しい名前",
    Default = "",
    Callback = function(v) newName = v end
})

TeleportTab:AddButton({
    Name = "名前変更",
    Callback = function()
        if selectedForEdit and newName and savedLocations[selectedForEdit] then
            savedLocations[newName] = savedLocations[selectedForEdit]
            savedLocations[selectedForEdit] = nil
            OrionLib:MakeNotification({ Name = "名前変更", Content = "成功！", Time = 2 })
            refreshPillars()
        end
    end
})

TeleportTab:AddButton({
    Name = "保存場所を削除",
    Callback = function()
        if selectedForEdit and savedLocations[selectedForEdit] then
            savedLocations[selectedForEdit] = nil
            OrionLib:MakeNotification({ Name = "削除完了", Content = "場所を削除しました", Time = 2 })
            refreshPillars()
        end
    end
})
