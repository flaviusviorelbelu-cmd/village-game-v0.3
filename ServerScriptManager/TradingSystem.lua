-- TradingSystem.lua - Extended trading functionality
-- Now integrates with EconomySystem for all wallet operations

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TradingSystem = {}

-- All shop item data is now defined in EconomySystem
-- This module provides additional trading features

function TradingSystem:Initialize()
	print("🔄 Initializing Trading System...")
	
	-- Wait for RemoteEvents created by EconomySystem
	local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
	
	-- Verify all required events exist
	local requiredEvents = {
		"ShopInteraction",
		"PurchaseItem",
		"SellItem",
		"UpdateCurrency",
		"UpdateInventory",
		"ShowMessage"
	}
	
	for _, eventName in ipairs(requiredEvents) do
		local event = remoteEventsFolder:WaitForChild(eventName)
		print("✅ Found RemoteEvent: " .. eventName)
	end
	
	print("✅ Trading System Ready! (Economy integration complete)")
end

-- Optional: Get shop items definition for reference
function TradingSystem:GetShopItems()
	return {
		GeneralStore = {
			{name = "Wooden Pickaxe", price = 50, description = "Basic mining tool"},
			{name = "Health Potion", price = 25, description = "Restores 50 HP"},
			{name = "Rope", price = 15, description = "Useful for climbing"},
			{name = "Lantern", price = 30, description = "Lights up dark areas"}
		},
		WeaponShop = {
			{name = "Iron Sword", price = 150, description = "Sharp iron blade"},
			{name = "Wooden Shield", price = 100, description = "Basic protection"},
			{name = "Steel Dagger", price = 75, description = "Fast attack weapon"},
			{name = "Bow", price = 120, description = "Ranged weapon"}
		},
		FoodStore = {
			{name = "Bread", price = 10, description = "Restores hunger"},
			{name = "Apple", price = 5, description = "Fresh fruit"},
			{name = "Cooked Fish", price = 20, description = "Nutritious meal"},
			{name = "Water Bottle", price = 8, description = "Quenches thirst"}
		},
		ClothingShop = {
			{name = "Leather Boots", price = 60, description = "Comfortable footwear"},
			{name = "Cotton Shirt", price = 40, description = "Basic clothing"},
			{name = "Wool Cloak", price = 80, description = "Warm outerwear"},
			{name = "Leather Gloves", price = 35, description = "Hand protection"}
		}
	}
end

-- Optional: Add custom trading features here
function TradingSystem:ProcessPlayerTrade(player1, player2, item, amount, price)
	-- This could be extended for player-to-player trading
	print("🤝 Trading system ready for custom trades")
end

return TradingSystem
