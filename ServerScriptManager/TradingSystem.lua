-- TradingSystem.lua - Trading and economy system (ModuleScript)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TradingSystem = {}
TradingSystem.PlayerInventories = {}
TradingSystem.PlayerCurrency = {}
TradingSystem.ShopItems = {}

-- Initialize trading system
function TradingSystem:Initialize()
	print("?? Initializing Trading System...")

	-- Setup shop inventories
	self:SetupShopItems()

	-- Setup remote events for trading (they should already exist)
	self:SetupRemoteEvents()

	print("? Trading System Ready!")
end

-- Setup shop items and prices
function TradingSystem:SetupShopItems()
	self.ShopItems = {
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

	print("?? Shop inventories loaded")
end

-- Setup remote events for client-server communication
function TradingSystem:SetupRemoteEvents()
	-- Wait for RemoteEvents folder
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

	-- Get the events
	local shopInteraction = remoteEvents:WaitForChild("ShopInteraction")
	local purchaseItem = remoteEvents:WaitForChild("PurchaseItem")
	local sellItem = remoteEvents:WaitForChild("SellItem")

	-- Connect events
	shopInteraction.OnServerEvent:Connect(function(player, shopName)
		self:OpenShop(player, shopName)
	end)

	purchaseItem.OnServerEvent:Connect(function(player, shopName, itemName)
		self:PurchaseItem(player, shopName, itemName)
	end)

	sellItem.OnServerEvent:Connect(function(player, itemName, quantity)
		self:SellItem(player, itemName, quantity)
	end)

	print("?? Remote events connected")
end

-- Open shop for player
function TradingSystem:OpenShop(player, shopName)
	local shopItems = self.ShopItems[shopName]
	if not shopItems then
		print("? Shop not found:", shopName)
		return
	end

	-- Send shop data to client
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remoteEvents then
		local showShop = remoteEvents:FindFirstChild("ShowShop")
		if showShop then
			showShop:FireClient(player, shopName, shopItems)
			print("?? Opened", shopName, "for", player.Name)
		end
	end
end

-- Handle item purchase
function TradingSystem:PurchaseItem(player, shopName, itemName)
	local shopItems = self.ShopItems[shopName]
	if not shopItems then return end

	-- Find the item
	local item = nil
	for _, shopItem in ipairs(shopItems) do
		if shopItem.name == itemName then
			item = shopItem
			break
		end
	end

	if not item then
		print("? Item not found:", itemName)
		return
	end

	-- Get player currency
	local playerCurrency = self:GetPlayerCurrency(player)

	-- Check if player has enough currency
	if playerCurrency < item.price then
		self:SendMessage(player, "? Not enough coins! Need " .. item.price .. " coins.")
		return
	end

	-- Process purchase
	self:SetPlayerCurrency(player, playerCurrency - item.price)
	self:AddItemToInventory(player, item)

	-- Notify player
	self:SendMessage(player, "? Purchased " .. item.name .. " for " .. item.price .. " coins!")

	-- Update client currency display
	self:UpdateClientCurrency(player)

	print("??", player.Name, "purchased", item.name, "for", item.price, "coins")
end

-- Get player currency
function TradingSystem:GetPlayerCurrency(player)
	if not self.PlayerCurrency[player.UserId] then
		self.PlayerCurrency[player.UserId] = 1000 -- Starting currency
	end
	return self.PlayerCurrency[player.UserId]
end

-- Set player currency
function TradingSystem:SetPlayerCurrency(player, amount)
	self.PlayerCurrency[player.UserId] = math.max(0, amount)
end

-- Update client currency display
function TradingSystem:UpdateClientCurrency(player)
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remoteEvents then
		local updateCurrency = remoteEvents:FindFirstChild("UpdateCurrency")
		if updateCurrency then
			updateCurrency:FireClient(player, self.PlayerCurrency[player.UserId])
		end
	end
end

-- Add item to player inventory
function TradingSystem:AddItemToInventory(player, item)
	if not self.PlayerInventories[player.UserId] then
		self.PlayerInventories[player.UserId] = {}
	end

	local inventory = self.PlayerInventories[player.UserId]

	-- Check if item already exists in inventory
	local existingItem = nil
	for _, invItem in ipairs(inventory) do
		if invItem.name == item.name then
			existingItem = invItem
			break
		end
	end

	if existingItem then
		existingItem.quantity = (existingItem.quantity or 1) + 1
	else
		table.insert(inventory, {
			name = item.name,
			description = item.description,
			quantity = 1
		})
	end

	-- Update client inventory
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remoteEvents then
		local updateInventory = remoteEvents:FindFirstChild("UpdateInventory")
		if updateInventory then
			updateInventory:FireClient(player, inventory)
		end
	end
end

-- Send message to player
function TradingSystem:SendMessage(player, message)
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remoteEvents then
		local showMessage = remoteEvents:FindFirstChild("ShowMessage")
		if showMessage then
			showMessage:FireClient(player, message)
		end
	end
end

-- Sell item from inventory
function TradingSystem:SellItem(player, itemName, quantity)
	local inventory = self.PlayerInventories[player.UserId]
	if not inventory then 
		self:SendMessage(player, "? No inventory found!")
		return 
	end

	-- Find item in inventory
	local itemIndex = nil
	local inventoryItem = nil
	for i, invItem in ipairs(inventory) do
		if invItem.name == itemName then
			itemIndex = i
			inventoryItem = invItem
			break
		end
	end

	if not inventoryItem or inventoryItem.quantity < quantity then
		self:SendMessage(player, "? Not enough " .. itemName .. " to sell!")
		return
	end

	-- Calculate sell price (50% of buy price)
	local sellPrice = math.floor(self:GetItemPrice(itemName) * 0.5) * quantity

	-- Process sale
	inventoryItem.quantity = inventoryItem.quantity - quantity
	if inventoryItem.quantity <= 0 then
		table.remove(inventory, itemIndex)
	end

	-- Add currency
	local currentCurrency = self:GetPlayerCurrency(player)
	self:SetPlayerCurrency(player, currentCurrency + sellPrice)

	-- Update client
	self:UpdateClientCurrency(player)

	-- Notify player
	self:SendMessage(player, "? Sold " .. quantity .. "x " .. itemName .. " for " .. sellPrice .. " coins!")

	print("??", player.Name, "sold", quantity .. "x", itemName, "for", sellPrice, "coins")
end

-- Get item price from shops
function TradingSystem:GetItemPrice(itemName)
	for shopName, items in pairs(self.ShopItems) do
		for _, item in ipairs(items) do
			if item.name == itemName then
				return item.price
			end
		end
	end
	return 10 -- Default price
end

return TradingSystem
