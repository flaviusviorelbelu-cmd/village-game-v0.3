-- HOUSE INTERACTION CLIENT SCRIPT
-- Handles entering/exiting houses and furniture placement
print("🏠 Initializing House Interaction Client...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Wait for RemoteEvents
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEventsFolder then
	warn("❌ RemoteEvents folder not found!")
	return
end

local enterHouseEvent = remoteEventsFolder:WaitForChild("EnterHouse")
local exitHouseEvent = remoteEventsFolder:WaitForChild("ExitHouse")
local placeFurnitureEvent = remoteEventsFolder:WaitForChild("PlaceFurniture")

print("✅ Connected to RemoteEvents")

-- ============================================
-- STATE VARIABLES
-- ============================================
local isInHouse = false
local currentHouseName = nil

print("✅ House Interaction Client Ready!")
print("🕜 Controls:")
print("  Walk into white door - Enter your house")
print("  Walk through blue portal inside - Exit house")

-- ============================================
-- LISTEN FOR HOUSE ENTRY FEEDBACK
-- ============================================
exitHouseEvent.OnClientEvent:Connect(function()
	print("🚪 Exiting house...")
	isInHouse = false
	currentHouseName = nil
end)