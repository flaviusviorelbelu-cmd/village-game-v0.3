-- PlayerDataService.lua - Player data management (ModuleScript)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = {}
PlayerDataService.PlayerData = {}

-- Note: DataStoreService requires API access - disabled for Studio testing
local USE_DATASTORES = false -- Set to true when publishing

-- Default player data structure
local DEFAULT_DATA = {
	Currency = 1000,
	Level = 1,
	Experience = 0,
	Inventory = {},
	Stats = {
		Health = 100,
		MaxHealth = 100,
		Energy = 100,
		MaxEnergy = 100
	},
	Achievements = {},
	PlayTime = 0,
	LastLogin = 0
}

-- Initialize player data when they join
function PlayerDataService:InitializePlayer(player)
	print("?? Initializing data for:", player.Name)

	-- For Studio testing, always create new data
	self.PlayerData[player.UserId] = self:DeepCopy(DEFAULT_DATA)
	self.PlayerData[player.UserId].LastLogin = os.time()

	print("? Created data for:", player.Name)

	-- Send initial data to client
	wait(0.5) -- Small delay to ensure RemoteEvents exist
	self:SendPlayerDataToClient(player)
end

-- Save player data
function PlayerDataService:SavePlayerData(player)
	local playerData = self.PlayerData[player.UserId]
	if not playerData then return end

	playerData.LastLogin = os.time()

	if USE_DATASTORES then
		-- DataStore saving would go here for published games
		print("?? Would save data for:", player.Name)
	else
		print("?? Local data updated for:", player.Name)
	end
end

-- Get player data
function PlayerDataService:GetPlayerData(player)
	return self.PlayerData[player.UserId]
end

-- Update player currency
function PlayerDataService:UpdateCurrency(player, amount)
	local data = self.PlayerData[player.UserId]
	if not data then return false end

	data.Currency = data.Currency + amount
	if data.Currency < 0 then
		data.Currency = 0
	end

	-- Update client
	self:SendCurrencyUpdate(player, data.Currency)
	return true
end

-- Add experience and handle level ups
function PlayerDataService:AddExperience(player, amount)
	local data = self.PlayerData[player.UserId]
	if not data then return end

	data.Experience = data.Experience + amount

	-- Check for level up
	local requiredExp = data.Level * 100 -- 100 exp per level
	if data.Experience >= requiredExp then
		data.Level = data.Level + 1
		data.Experience = data.Experience - requiredExp

		-- Level up rewards
		data.Currency = data.Currency + (data.Level * 50) -- Bonus coins
		data.Stats.MaxHealth = data.Stats.MaxHealth + 10
		data.Stats.Health = data.Stats.MaxHealth

		-- Notify player
		self:SendLevelUpNotification(player, data.Level)
	end

	-- Update client
	self:SendPlayerDataToClient(player)
end

-- Add item to inventory
function PlayerDataService:AddToInventory(player, item, quantity)
	local data = self.PlayerData[player.UserId]
	if not data then return false end

	quantity = quantity or 1

	-- Check if item already exists
	local existingItem = nil
	for _, invItem in ipairs(data.Inventory) do
		if invItem.name == item.name then
			existingItem = invItem
			break
		end
	end

	if existingItem then
		existingItem.quantity = (existingItem.quantity or 1) + quantity
	else
		table.insert(data.Inventory, {
			name = item.name,
			description = item.description or "No description",
			quantity = quantity,
			type = item.type or "misc"
		})
	end

	-- Update client inventory
	self:SendInventoryUpdate(player, data.Inventory)
	return true
end

-- Remove item from inventory
function PlayerDataService:RemoveFromInventory(player, itemName, quantity)
	local data = self.PlayerData[player.UserId]
	if not data then return false end

	quantity = quantity or 1

	for i, item in ipairs(data.Inventory) do
		if item.name == itemName then
			if item.quantity <= quantity then
				table.remove(data.Inventory, i)
			else
				item.quantity = item.quantity - quantity
			end

			-- Update client inventory
			self:SendInventoryUpdate(player, data.Inventory)
			return true
		end
	end

	return false
end

-- Send player data to client
function PlayerDataService:SendPlayerDataToClient(player)
	local data = self.PlayerData[player.UserId]
	if not data then return end

	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remoteEvents then
		local updatePlayerData = remoteEvents:FindFirstChild("UpdatePlayerData")
		if updatePlayerData then
			updatePlayerData:FireClient(player, data)
		end
	end
end

-- Send currency update to client
function PlayerDataService:SendCurrencyUpdate(player, currency)
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remoteEvents then
		local updateCurrency = remoteEvents:FindFirstChild("UpdateCurrency")
		if updateCurrency then
			updateCurrency:FireClient(player, currency)
		end
	end
end

-- Send inventory update to client
function PlayerDataService:SendInventoryUpdate(player, inventory)
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remoteEvents then
		local updateInventory = remoteEvents:FindFirstChild("UpdateInventory")
		if updateInventory then
			updateInventory:FireClient(player, inventory)
		end
	end
end

-- Send level up notification
function PlayerDataService:SendLevelUpNotification(player, newLevel)
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if remoteEvents then
		local showMessage = remoteEvents:FindFirstChild("ShowMessage")
		if showMessage then
			showMessage:FireClient(player, "?? LEVEL UP! You are now level " .. newLevel .. "!")
		end
	end
end

-- Utility function for deep copying tables
function PlayerDataService:DeepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			copy[key] = self:DeepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

-- Auto-save system (runs when module is loaded)
spawn(function()
	while true do
		wait(300) -- 5 minutes
		for userId, _ in pairs(PlayerDataService.PlayerData) do
			local player = Players:GetPlayerByUserId(userId)
			if player then
				PlayerDataService:SavePlayerData(player)
			end
		end
	end
end)

return PlayerDataService
