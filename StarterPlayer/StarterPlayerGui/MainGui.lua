-- MAIN GUI - Village GUI System
print("🌨️ Main GUI with Houses starting...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents with timeout
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEventsFolder then
	warn("❌ RemoteEvents folder not found!")
	return
end

-- Get events if they exist (with fallback)
local buyHouseEvent = remoteEventsFolder:FindFirstChild("BuyHouse")
local enterHouseEvent = remoteEventsFolder:FindFirstChild("EnterHouse")
local updateCurrencyEvent = remoteEventsFolder:FindFirstChild("UpdateCurrency")

if not buyHouseEvent then
	warn("⚠️ BuyHouse event not found")
end

if not updateCurrencyEvent then
	warn("⚠️ UpdateCurrency event not found - currency updates may not display")
end

print("✅ GUI with Houses Ready!")