-- FULLY FIXED CLIENT MANAGER
-- Fixes: Escape key to close shop
print("?? Client Manager starting...")
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
wait(0.5)
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
-- Wait for GUI
local playerGui = player:WaitForChild("PlayerGui")
local villageGui = playerGui:WaitForChild("VillageGui")
local shopFrame = villageGui:WaitForChild("Frame")
-- ESCAPE KEY HANDLER - FIXED!
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Escape then
		if shopFrame.Visible then
			shopFrame.Visible = false
			print("?? Shop closed with Escape")
		end
	end

end)
print("? Client Manager Ready!")
