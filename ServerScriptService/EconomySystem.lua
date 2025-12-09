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

local updateCurrencyEvent = Instance.new("RemoteEvent")
updateCurrencyEvent.Name = "UpdateCurrency"
updateCurrencyEvent.Parent = remoteEventsFolder

local getCurrencyEvent = Instance.new("RemoteEvent")
getCurrencyEvent.Name = "GetCurrency"
getCurrencyEvent.Parent = remoteEventsFolder

local transactionEvent = Instance.new("RemoteEvent")
transactionEvent.Name = "ProcessTransaction"
transactionEvent.Parent = remoteEventsFolder

print("✅ Created Economy RemoteEvents")

-- ============================================
-- ECONOMY MANAGER
-- ============================================
local EconomyManager = {}
EconomyManager.playerWallets = {} -- Store player currencies
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

-- Initialize when players join
local function onPlayerAdded(player)
	wait(1)
	EconomyManager:InitializeWallet(player)
	
	-- Send initial balance
	local balance = EconomyManager:GetBalance(player)
	updateCurrencyEvent:FireClient(player, balance)
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Cleanup on player leave
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	EconomyManager.playerWallets[userId] = nil
	EconomyManager.transactionHistory[userId] = nil
end)

print("✅ Economy System Ready!")
