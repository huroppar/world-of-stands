local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

humanoid.WalkSpeed = 100

print("✅ Speed変更されたよ！")
