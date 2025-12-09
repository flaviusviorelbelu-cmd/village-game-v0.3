-- ECONOMY SYSTEM
-- Manages player currency, wallets, and economic transactions
print("💰 Initializing Economy System...")

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create RemoteEvents for economy
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

-- CORE ECONOMY EVENTS
local updateCurrencyEvent = Instance.new("RemoteEvent")
updateCurrencyEvent.Name = "UpdateCurrency"
updateCurrencyEvent.Parent = remoteEventsFolder

local getCurrencyEvent = Instance.new("RemoteEvent")
getCurrencyEvent.Name = "GetCurrency"
getCurrencyEvent.Parent = remoteEventsFolder

local transactionEvent = Instance.new("RemoteEvent")
transactionEvent.Name = "ProcessTransaction"
transactionEvent.Parent = remoteEventsFolder

-- SHOP EVENTS (for TradingSystem integration)
local shopInteractionEvent = Instance.new("RemoteEvent")
shopInteractionEvent.Name = "ShopInteraction"
shopInteractionEvent.Parent = remoteEventsFolder

local purchaseItemEvent = Instance.new("RemoteEvent")
purchaseItemEvent.Name = "PurchaseItem"
purchaseItemEvent.Parent = remoteEventsFolder

local sellItemEvent = Instance.new("RemoteEvent")
sellItemEvent.Name = "SellItem"
sellItemEvent.Parent = remoteEventsFolder

local showShopEvent = Instance.new("RemoteEvent")
showShopEvent.Name = "ShowShop"
showShopEvent.Parent = remoteEventsFolder

local updateInventoryEvent = Instance.new("RemoteEvent")
updateInventoryEvent.Name = "UpdateInventory"
updateInventoryEvent.Parent = remoteEventsFolder

local showMessageEvent = Instance.new("RemoteEvent")
showMessageEvent.Name = "ShowMessage"
showMessageEvent.Parent = remoteEventsFolder

print("✅ Created Economy & Shop RemoteEvents")

-- ============================================
-- ECONOMY MANAGER
-- ============================================
local EconomyManager = {}
EconomyManager.playerWallets = {} -- Store player currencies
EconomyManager.playerInventories = {} -- Store player inventories
EconomyManager.transactionHistory = {} -- Track all transactions

-- Currency types
local CURRENCY_TYPES = {
	GOLD = {
		name = "Gold",
		emoji = "GOLD_COIN",
		description = "Main currency earned from trading and quests"
	},
	SILVER = {
		name = "Silver",
		emoji = "SILVER_COIN",
		description = "Secondary currency for rare items"
	},
	GEMS = {
		name = "Gems",
		emoji = "GEM",
		description = "Premium currency for special purchases"
	}
}

-- Initialize player wallet
function EconomyManager:InitializeWallet(player)
	local userId = player.UserId
	
	-- Set default currency
	self.playerWallets[userId] = {
		gold = 100, -- Starting gold
		silver = 10, -- Starting silver
		gems = 0,   -- No starting gems (premium)
		lastUpdated = os.time()
	}
	
	-- Initialize player inventory
	self.playerInventories[userId] = {}
	
	-- Initialize transaction history
	self.transactionHistory[userId] = {}
	
	print("💰 " .. player.Name .. " wallet initialized")
	print("  Gold: " .. self.playerWallets[userId].gold)
	print("  Silver: " .. self.playerWallets[userId].silver)
	return self.playerWallets[userId]
end

-- Get player balance
function EconomyManager:GetBalance(player)
	local userId = player.UserId
	if not self.playerWallets[userId] then
		self:InitializeWallet(player)
	end
	return self.playerWallets[userId]
end

-- Get player inventory
function EconomyManager:GetInventory(player)
	local userId = player.UserId
	if not self.playerInventories[userId] then
		self.playerInventories[userId] = {}
	end
	return self.playerInventories[userId]
end

-- Add currency to player
function EconomyManager:AddCurrency(player, currencyType, amount, reason)
	local userId = player.UserId
	local wallet = self:GetBalance(player)
	
	local currencyKey = string.lower(currencyType)
	if wallet[currencyKey] then
		wallet[currencyKey] = wallet[currencyKey] + amount
		wallet.lastUpdated = os.time()
		
		-- Log transaction
		table.insert(self.transactionHistory[userId], {
			type = "add",
			currency = currencyType,
			amount = amount,
			reason = reason or "Unknown",
			timestamp = os.time()
		})
		
		print("✅ Added " .. amount .. " " .. currencyType .. " to " .. player.Name .. " (" .. reason .. ")")
		
		-- Notify client
		updateCurrencyEvent:FireClient(player, wallet)
		return true
	else
		warn("Invalid currency type: " .. currencyType)
		return false
	end
end

-- Remove currency from player
function EconomyManager:RemoveCurrency(player, currencyType, amount, reason)
	local userId = player.UserId
	local wallet = self:GetBalance(player)
	
	local currencyKey = string.lower(currencyType)
	if wallet[currencyKey] then
		if wallet[currencyKey] >= amount then
			wallet[currencyKey] = wallet[currencyKey] - amount
			wallet.lastUpdated = os.time()
			
			-- Log transaction
			table.insert(self.transactionHistory[userId], {
				type = "remove",
				currency = currencyType,
				amount = amount,
				reason = reason or "Unknown",
				timestamp = os.time()
			})
			
			print("✅ Removed " .. amount .. " " .. currencyType .. " from " .. player.Name .. " (" .. reason .. ")")
			
			-- Notify client
			updateCurrencyEvent:FireClient(player, wallet)
			return true
		else
			warn(player.Name .. " doesn't have enough " .. currencyType)
			return false
		end
	else
		warn("Invalid currency type: " .. currencyType)
		return false
	end
end

-- Transfer currency between players
function EconomyManager:Transfer(fromPlayer, toPlayer, currencyType, amount, reason)
	local fromUserId = fromPlayer.UserId
	local toUserId = toPlayer.UserId
	
	local fromWallet = self:GetBalance(fromPlayer)
	local currencyKey = string.lower(currencyType)
	
	if fromWallet[currencyKey] and fromWallet[currencyKey] >= amount then
		-- Remove from sender
		fromWallet[currencyKey] = fromWallet[currencyKey] - amount
		
		-- Add to receiver
		local toWallet = self:GetBalance(toPlayer)
		toWallet[currencyKey] = toWallet[currencyKey] + amount
		
		fromWallet.lastUpdated = os.time()
		toWallet.lastUpdated = os.time()
		
		-- Log transactions
		table.insert(self.transactionHistory[fromUserId], {
			type = "transfer_sent",
			currency = currencyType,
			amount = amount,
			to = toPlayer.Name,
			reason = reason or "Unknown",
			timestamp = os.time()
		})
		
		table.insert(self.transactionHistory[toUserId], {
			type = "transfer_received",
			currency = currencyType,
			amount = amount,
			from = fromPlayer.Name,
			reason = reason or "Unknown",
			timestamp = os.time()
		})
		
		print("💰 " .. fromPlayer.Name .. " transferred " .. amount .. " " .. currencyType .. " to " .. toPlayer.Name)
		
		-- Notify clients
		updateCurrencyEvent:FireClient(fromPlayer, fromWallet)
		updateCurrencyEvent:FireClient(toPlayer, toWallet)
		return true
	else
		warn(fromPlayer.Name .. " doesn't have enough " .. currencyType)
		return false
	end
end

-- Add item to inventory
function EconomyManager:AddItemToInventory(player, itemName, itemData)
	local userId = player.UserId
	local inventory = self:GetInventory(player)
	
	-- Check if item already exists
	for _, invItem in ipairs(inventory) do
		if invItem.name == itemName then
			invItem.quantity = (invItem.quantity or 1) + 1
			updateInventoryEvent:FireClient(player, inventory)
			return
		end
	end
	
	-- Add new item
	table.insert(inventory, {
		name = itemName,
		description = itemData.description or "",
		price = itemData.price or 0,
		quantity = 1
	})
	
	updateInventoryEvent:FireClient(player, inventory)
end

-- Get transaction history
function EconomyManager:GetTransactionHistory(player, limit)
	local userId = player.UserId
	limit = limit or 10
	
	local history = self.transactionHistory[userId] or {}
	local recentHistory = {}
	
	-- Get last N transactions
	for i = math.max(1, #history - limit + 1), #history do
		table.insert(recentHistory, history[i])
	end
	
	return recentHistory
end

-- Process daily income (optional game mechanic)
function EconomyManager:ProcessDailyIncome(player)
	self:AddCurrency(player, "GOLD", 50, "Daily Income")
	self:AddCurrency(player, "SILVER", 5, "Daily Income")
end

-- ============================================
-- REMOTE EVENT HANDLERS
-- ============================================

getCurrencyEvent.OnServerEvent:Connect(function(player)
	local balance = EconomyManager:GetBalance(player)
	getCurrencyEvent:FireClient(player, balance)
end)

transactionEvent.OnServerEvent:Connect(function(player, action, ...)
	local args = {...}
	
	if action == "transfer" then
		local toPlayerId, currencyType, amount, reason = args[1], args[2], args[3], args[4]
		local toPlayer = Players:FindFirstChild(toPlayerId)
		if toPlayer then
			EconomyManager:Transfer(player, toPlayer, currencyType, amount, reason)
		end
	
	elseif action == "add" then
		-- Usually handled by server, but exposed for admin commands
		local currencyType, amount, reason = args[1], args[2], args[3]
		EconomyManager:AddCurrency(player, currencyType, amount, reason)
	
	elseif action == "daily_income" then
		EconomyManager:ProcessDailyIncome(player)
	end
end)

-- ============================================
-- SHOP/TRADING EVENTS
-- ============================================

-- Define shop items
local SHOP_ITEMS = {
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

-- Helper function to find item in shop
local function findShopItem(shopName, itemName)
	local shop = SHOP_ITEMS[shopName]
	if not shop then return nil end
	
	for _, item in ipairs(shop) do
		if item.name == itemName then
			return item
		end
	end
	return nil
end

-- Shop interaction event
shopInteractionEvent.OnServerEvent:Connect(function(player, shopName)
	local shopItems = SHOP_ITEMS[shopName]
	if not shopItems then
		print("❌ Shop not found: " .. shopName)
		return
	end
	
	-- Send shop data to client
	showShopEvent:FireClient(player, shopName, shopItems)
	print("🏪 Opened " .. shopName .. " for " .. player.Name)
end)

-- Purchase item event
purchaseItemEvent.OnServerEvent:Connect(function(player, shopName, itemName)
	local item = findShopItem(shopName, itemName)
	if not item then
		print("❌ Item not found: " .. itemName)
		return
	end
	
	-- Get player currency
	local wallet = EconomyManager:GetBalance(player)
	
	-- Check if player has enough gold
	if wallet.gold < item.price then
		showMessageEvent:FireClient(player, "❌ Not enough coins! Need " .. item.price .. " gold. You have " .. wallet.gold)
		return
	end
	
	-- Process purchase
	wallet.gold = wallet.gold - item.price
	wallet.lastUpdated = os.time()
	
	-- Log transaction
	local userId = player.UserId
	table.insert(EconomyManager.transactionHistory[userId], {
		type = "purchase",
		shop = shopName,
		item = itemName,
		price = item.price,
		timestamp = os.time()
	})
	
	-- Add item to inventory
	EconomyManager:AddItemToInventory(player, itemName, item)
	
	-- Notify player
	showMessageEvent:FireClient(player, "✅ Purchased " .. itemName .. " for " .. item.price .. " gold!")
	updateCurrencyEvent:FireClient(player, wallet)
	
	print("🛍️  " .. player.Name .. " purchased " .. itemName .. " for " .. item.price .. " gold")
end)

-- Sell item event
sellItemEvent.OnServerEvent:Connect(function(player, itemName, quantity)
	local inventory = EconomyManager:GetInventory(player)
	quantity = quantity or 1
	
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
		showMessageEvent:FireClient(player, "❌ Not enough " .. itemName .. " to sell!")
		return
	end
	
	-- Calculate sell price (50% of buy price)
	local sellPrice = math.floor(inventoryItem.price * 0.5) * quantity
	
	-- Process sale
	inventoryItem.quantity = inventoryItem.quantity - quantity
	if inventoryItem.quantity <= 0 then
		table.remove(inventory, itemIndex)
	end
	
	-- Add currency
	local wallet = EconomyManager:GetBalance(player)
	wallet.gold = wallet.gold + sellPrice
	wallet.lastUpdated = os.time()
	
	-- Log transaction
	local userId = player.UserId
	table.insert(EconomyManager.transactionHistory[userId], {
		type = "sell",
		item = itemName,
		quantity = quantity,
		price = sellPrice,
		timestamp = os.time()
	})
	
	-- Update client
	updateInventoryEvent:FireClient(player, inventory)
	updateCurrencyEvent:FireClient(player, wallet)
	
	-- Notify player
	showMessageEvent:FireClient(player, "✅ Sold " .. quantity .. "x " .. itemName .. " for " .. sellPrice .. " gold!")
	
	print("💰 " .. player.Name .. " sold " .. quantity .. "x " .. itemName .. " for " .. sellPrice .. " gold")
end)

-- ============================================
-- PLAYER LIFECYCLE
-- ============================================

-- Initialize when players join
local function onPlayerAdded(player)
	wait(1)
	EconomyManager:InitializeWallet(player)
	
	-- Send initial balance
	local balance = EconomyManager:GetBalance(player)
	updateCurrencyEvent:FireClient(player, balance)
	
	-- Send initial inventory
	local inventory = EconomyManager:GetInventory(player)
	updateInventoryEvent:FireClient(player, inventory)
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Cleanup on player leave
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	EconomyManager.playerWallets[userId] = nil
	EconomyManager.playerInventories[userId] = nil
	EconomyManager.transactionHistory[userId] = nil
end)

print("✅ Economy System Ready!")
