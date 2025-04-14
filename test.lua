local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/WRUyYTdY"))()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--== データ保存用 ==--
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local DataStoreKey = "WOS_SavePositions"

local function loadSettings()
    local data = getgenv().WOS_Settings or {}
    data.SavedPositions = data.SavedPositions or {}
    data.SelectedPosition = data.SelectedPosition or nil
    data.ShowTeleport = data.ShowTeleport ~= false
    getgenv().WOS_Settings = data
    return data
end

local function saveSettings()
    getgenv().WOS_Settings = settings
end

local settings = loadSettings()

--== ウィンドウ作成 ==--
local Window = OrionLib:MakeWindow({
    Name = "World of Stands Most Useful Script",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "WOS_Config"
})

--== 表示切替タブ ==--
local viewTab = Window:MakeTab({
    Name = "表示設定",
    Icon = "rbxassetid://6031265989",
    PremiumOnly = false
})

--== テレポート管理タブ（常に生成し、表示切り替えで管理） ==--
local teleportTab = Window:MakeTab({
    Name = "テレポート管理",
    Icon = "rbxassetid://6035067836",
    PremiumOnly = false
})
teleportTab.Visible = settings.ShowTeleport

--== ドロップダウンを一括管理 ==--
local teleportDropdown

--== ドロップダウン更新関数 ==--
local function refreshTeleportDropdown()
    settings.SavedPositions = settings.SavedPositions or {}
    local options = {}
    for name, _ in pairs(settings.SavedPositions) do
        table.insert(options, name)
    end

    if teleportDropdown then
        teleportDropdown:Refresh(options, true)
    else
        teleportDropdown = teleportTab:AddDropdown({
            Name = "保存済みの場所",
            Options = options,
            Callback = function(option)
                settings.SelectedPosition = option
                saveSettings()
            end
        })
    end
end

--== 表示トグルの処理 ==--
viewTab:AddToggle({
    Name = "テレポート機能表示",
    Default = settings.ShowTeleport,
    Callback = function(value)
        settings.ShowTeleport = value
        teleportTab.Visible = value
        saveSettings()
    end
})

--== 位置保存機能 ==--
teleportTab:AddTextbox({
    Name = "現在位置の名前",
    Default = "MySpot",
    TextDisappear = false,
    Callback = function(name)
        settings.SavedPositions[name] = humanoidRootPart.Position
        saveSettings()
        OrionLib:MakeNotification({
            Name = "保存完了",
            Content = name .. " の位置を保存しました。",
            Time = 3
        })
        refreshTeleportDropdown()
    end
})

--== テレポート実行ボタン ==--
teleportTab:AddButton({
    Name = "保存先にテレポート",
    Callback = function()
        local pos = settings.SavedPositions[settings.SelectedPosition]
        if pos then
            humanoidRootPart.CFrame = CFrame.new(pos)
            OrionLib:MakeNotification({
                Name = "テレポート成功",
                Content = settings.SelectedPosition .. " に移動しました。",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "エラー",
                Content = "保存された場所が選択されていません。",
                Time = 3
            })
        end
    end
})

--== 名前変更ボタン ==--
teleportTab:AddTextbox({
    Name = "新しい名前（現在選択中の場所）",
    Default = "",
    TextDisappear = true,
    Callback = function(newName)
        local oldName = settings.SelectedPosition
        if oldName and settings.SavedPositions[oldName] then
            settings.SavedPositions[newName] = settings.SavedPositions[oldName]
            settings.SavedPositions[oldName] = nil
            settings.SelectedPosition = newName
            saveSettings()
            OrionLib:MakeNotification({
                Name = "名前変更",
                Content = oldName .. " を " .. newName .. " に変更しました。",
                Time = 3
            })
            refreshTeleportDropdown()
        end
    end
})

--== 削除ボタン ==--
teleportTab:AddButton({
    Name = "選択中の場所を削除",
    Callback = function()
        local selected = settings.SelectedPosition
        if selected and settings.SavedPositions[selected] then
            settings.SavedPositions[selected] = nil
            settings.SelectedPosition = nil
            saveSettings()
            OrionLib:MakeNotification({
                Name = "削除完了",
                Content = selected .. " を削除しました。",
                Time = 3
            })
            refreshTeleportDropdown()
        end
    end
})

--== 初期ドロップダウン描画 ==--
refreshTeleportDropdown()

--== GUI起動通知 ==--
OrionLib:MakeNotification({
    Name = "起動完了",
    Content = "保存テレポートGUIを読み込みました - Masashi",
    Time = 4
})

local toggleKey = Enum.KeyCode.P -- 初期値（あとで変更可能）

local SettingsTab = Window:MakeTab({
	Name = "設定",
	Icon = "rbxassetid://6034509993", -- 歯車アイコンなどお好みで
	PremiumOnly = false
})

SettingsTab:AddTextbox({
	Name = "GUI表示切替キー（例: P や RightShift）",
	Default = "P",
	TextDisappear = false,
	Callback = function(value)
		local success, result = pcall(function()
			local newKey = Enum.KeyCode[value]
			if newKey then
				toggleKey = newKey
				OrionLib:MakeNotification({
					Name = "キー設定完了",
					Content = "GUI表示切替キーを [" .. value .. "] に設定しました。",
					Time = 3
				})
			else
				OrionLib:MakeNotification({
					Name = "エラー",
					Content = "無効なキー名です。",
					Time = 3
				})
			end
		end)
	end
})

OrionLib:Init()
-- GUI再表示用のボタンとキー設定
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 小さな再表示ボタンを作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ReopenButtonGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 40, 0, 40)
Button.Position = UDim2.new(1, -60, 1, -60) -- 右下
Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Button.Text = "M" -- ボタンの見た目
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 20
Button.BorderSizePixel = 0
Button.BackgroundTransparency = 0.3
Button.Parent = ScreenGui

-- ドラッグ対応（スマホ＋PC）
local dragging = false
local dragStart, startPos

local function update(input)
	if dragging and input then
		local delta = input.Position - dragStart
		Button.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end

Button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Button.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Button.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		input.Changed:Connect(function()
			update(input)
		end)
	end
end)

-- ボタン押したらGUIの表示/非表示トグル
Button.MouseButton1Click:Connect(function()
	if Window then
		Window.Enabled = not Window.Enabled
	end
end)

-- 任意キーでGUIをトグル（ここでキー指定）
local toggleKey = Enum.KeyCode.P  -- ← 好きなキーに変更OK！

UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == toggleKey then
		if Window then
			Window.Enabled = not Window.Enabled
		end
	end
end)
