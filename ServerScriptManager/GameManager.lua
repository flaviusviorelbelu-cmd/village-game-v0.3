-- VILLAGE GAME WITH HOUSE OWNERSHIP + SHOP SIGNS
print("?? Starting Village Game with Houses & Signs...")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local houseDataStore = DataStoreService:GetDataStore("HouseOwnership_v1")
-- Create RemoteEvents
local remoteEventsFolder = Instance.new("Folder")
remoteEventsFolder.Name = "RemoteEvents"
remoteEventsFolder.Parent = ReplicatedStorage
local remoteEvents = {"BuyItem", "SellItem", "ShowShop", "UpdateCurrency", "ShowMessage", "UpdatePlayerData", "BuyHouse", "ShowHousePurchase"}
for _, eventName in ipairs(remoteEvents) do
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = eventName
	remoteEvent.Parent = remoteEventsFolder
end
print("? Created RemoteEvents")
wait(1)
-- House ownership data
local houseOwners = {}
-- ============================================
-- VILLAGE BUILDER WITH HOUSES & SHOP SIGNS
-- ============================================
local function buildVillage()
	print("??? Building Village...")
	local workspace = game.Workspace
	-- Ground
	local baseplate = Instance.new("Part")
	baseplate.Name = "Baseplate"
	baseplate.Size = Vector3.new(500, 2, 500)
	baseplate.Position = Vector3.new(0, -1, 0)
	baseplate.Anchored = true
	baseplate.BrickColor = BrickColor.new("Bright green")
	baseplate.Material = Enum.Material.Grass
	baseplate.Parent = workspace

	local villageFolder = Instance.new("Folder")
	villageFolder.Name = "Village"
	villageFolder.Parent = workspace

	local houseRadius = 150
	local shopRadius = 90
	local marketRadius = 40

	-- House prices (varied)
	local housePrices = {500, 750, 1000, 500, 1250, 750, 1500, 1000, 2000, 1250, 1500, 750}

	-- Create 12 Houses with ClickDetectors
	for i = 1, 12 do
		local angle = (2 * math.pi / 12) * (i - 1)
		local x = math.cos(angle) * houseRadius
		local z = math.sin(angle) * houseRadius

		local house = Instance.new("Part")
		house.Name = "House_" .. i
		house.Size = Vector3.new(20, 15, 20)
		house.Position = Vector3.new(x, 7.5, z)
		house.Anchored = true
		house.BrickColor = BrickColor.new("Bright red")
		house.Parent = villageFolder

		-- Store price in house
		local priceValue = Instance.new("IntValue")
		priceValue.Name = "Price"
		priceValue.Value = housePrices[i]
		priceValue.Parent = house

		-- Add ClickDetector for purchase
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 15
		clickDetector.Parent = house

		local roof = Instance.new("WedgePart")
		roof.Size = Vector3.new(20, 8, 22)
		roof.Position = Vector3.new(x, 19, z)
		roof.Anchored = true
		roof.BrickColor = BrickColor.new("Reddish brown")
		roof.Orientation = Vector3.new(0, 90, 0)
		roof.Parent = house

		-- Owner sign (initially hidden)
		local signPart = Instance.new("Part")
		signPart.Name = "OwnerSign"
		signPart.Size = Vector3.new(15, 3, 0.5)
		signPart.Position = Vector3.new(x, 27, z)
		signPart.Anchored = true
		signPart.Transparency = 1
		signPart.CanCollide = false
		signPart.Parent = house

		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.new(0, 200, 0, 50)
		billboardGui.StudsOffset = Vector3.new(0, 3, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.Parent = signPart

		local ownerLabel = Instance.new("TextLabel")
		ownerLabel.Name = "OwnerLabel"
		ownerLabel.Size = UDim2.new(1, 0, 1, 0)
		ownerLabel.BackgroundTransparency = 1
		ownerLabel.Text = ""
		ownerLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		ownerLabel.TextSize = 18
		ownerLabel.Font = Enum.Font.GothamBold
		ownerLabel.TextStrokeTransparency = 0.5
		ownerLabel.Parent = billboardGui
	end
	print("?? Created 12 houses with purchase system")

	-- Create 4 Shops WITH SIGNS
	local shops = {
		{name = "General Store", color = "Bright blue", angle = 0, textColor = Color3.fromRGB(100, 150, 255)},
		{name = "Weapon Shop", color = "Bright red", angle = math.pi/2, textColor = Color3.fromRGB(255, 100, 100)},
		{name = "Food Store", color = "Bright green", angle = math.pi, textColor = Color3.fromRGB(100, 255, 100)},
		{name = "Clothing Shop", color = "Bright violet", angle = 3*math.pi/2, textColor = Color3.fromRGB(200, 100, 255)}
	}

	for _, shopData in ipairs(shops) do
		local x = math.cos(shopData.angle) * shopRadius
		local z = math.sin(shopData.angle) * shopRadius

		local shop = Instance.new("Part")
		shop.Name = shopData.name
		shop.Size = Vector3.new(25, 20, 25)
		shop.Position = Vector3.new(x, 10, z)
		shop.Anchored = true
		shop.BrickColor = BrickColor.new(shopData.color)
		shop.Parent = villageFolder

		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 15
		clickDetector.Parent = shop

		-- SHOP NAME SIGN
		local signPart = Instance.new("Part")
		signPart.Name = "ShopSign"
		signPart.Size = Vector3.new(20, 5, 0.5)
		signPart.Position = Vector3.new(x, 32, z)
		signPart.Anchored = true
		signPart.Transparency = 1
		signPart.CanCollide = false
		signPart.Parent = shop

		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.new(0, 250, 0, 60)
		billboardGui.StudsOffset = Vector3.new(0, 0, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.Parent = signPart

		local shopLabel = Instance.new("TextLabel")
		shopLabel.Size = UDim2.new(1, 0, 1, 0)
		shopLabel.BackgroundTransparency = 1
		shopLabel.Text = string.upper(shopData.name)
		shopLabel.TextColor3 = shopData.textColor
		shopLabel.TextSize = 24
		shopLabel.Font = Enum.Font.GothamBold
		shopLabel.TextStrokeTransparency = 0.3
		shopLabel.Parent = billboardGui
	end
	print("?? Created 4 shops with name signs")

	-- Market Stalls
	for i = 1, 6 do
		local angle = (2 * math.pi / 6) * (i - 1)
		local x = math.cos(angle) * marketRadius
		local z = math.sin(angle) * marketRadius

		local platform = Instance.new("Part")
		platform.Name = "MarketStall_" .. i
		platform.Size = Vector3.new(10, 1, 10)
		platform.Position = Vector3.new(x, 0.5, z)
		platform.Anchored = true
		platform.BrickColor = BrickColor.new("Dark oak")
		platform.Parent = villageFolder
	end

	-- Roads
	local roadH = Instance.new("Part")
	roadH.Size = Vector3.new(400, 0.5, 20)
	roadH.Position = Vector3.new(0, 0.25, 0)
	roadH.Anchored = true
	roadH.BrickColor = BrickColor.new("Dark stone grey")
	roadH.Material = Enum.Material.Concrete
	roadH.Parent = villageFolder

	local roadV = Instance.new("Part")
	roadV.Size = Vector3.new(20, 0.5, 400)
	roadV.Position = Vector3.new(0, 0.25, 0)
	roadV.Anchored = true
	roadV.BrickColor = BrickColor.new("Dark stone grey")
	roadV.Material = Enum.Material.Concrete
	roadV.Parent = villageFolder

	-- Fountain
	local fountain = Instance.new("Part")
	fountain.Size = Vector3.new(12, 8, 12)
	fountain.Position = Vector3.new(0, 4, 0)
	fountain.Anchored = true
	fountain.BrickColor = BrickColor.new("Medium blue")
	fountain.Shape = Enum.PartType.Cylinder
	fountain.Orientation = Vector3.new(0, 0, 90)
	fountain.Parent = villageFolder

	-- Trees
	for i = 1, 20 do
		local angle = (2 * math.pi / 20) * (i - 1)
		local x = math.cos(angle) * 180
		local z = math.sin(angle) * 180

		local trunk = Instance.new("Part")
		trunk.Size = Vector3.new(3, 12, 3)
		trunk.Position = Vector3.new(x, 6, z)
		trunk.Anchored = true
		trunk.BrickColor = BrickColor.new("Dark oak")
		trunk.Parent = villageFolder

		local foliage = Instance.new("Part")
		foliage.Size = Vector3.new(10, 10, 10)
		foliage.Position = Vector3.new(x, 15, z)
		foliage.Anchored = true
		foliage.BrickColor = BrickColor.new("Dark green")
		foliage.Shape = Enum.PartType.Ball
		foliage.Parent = trunk
	end

	-- Spawn
	local spawn = Instance.new("SpawnLocation")
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Vector3.new(0, 0.5, -15)
	spawn.Anchored = true
	spawn.Transparency = 0.5
	spawn.BrickColor = BrickColor.new("Bright green")
	spawn.CanCollide = false
	spawn.Parent = villageFolder

	print("? Village Created!")

end
-- ============================================
-- HOUSE OWNERSHIP SYSTEM
-- ============================================
local function loadHouseOwnership()
	local success, data = pcall(function()
		return houseDataStore:GetAsync("AllHouses")
	end)
	if success and data then
		houseOwners = data
		print("?? Loaded house ownership data")
	else
		print("?? No existing house data")
	end

end
local function saveHouseOwnership()
	pcall(function()
		houseDataStore:SetAsync("AllHouses", houseOwners)
	end)
end
local function updateHouseSign(houseName, ownerName)
	local house = workspace.Village:FindFirstChild(houseName)
	if house then
		local ownerSign = house:FindFirstChild("OwnerSign")
		if ownerSign then
			local billboardGui = ownerSign:FindFirstChild("BillboardGui")
			if billboardGui then
				local ownerLabel = billboardGui:FindFirstChild("OwnerLabel")
				if ownerLabel then
					if ownerName then
						ownerLabel.Text = "OWNED BY " .. string.upper(ownerName)
					else
						ownerLabel.Text = ""
					end
				end
			end
		end
	end
end
local function initializeHouseSystem()
	print("?? Initializing House System...")
	loadHouseOwnership()

	-- Update all house signs
	for houseName, ownerName in pairs(houseOwners) do
		updateHouseSign(houseName, ownerName)
	end

	local buyHouseEvent = remoteEventsFolder:WaitForChild("BuyHouse")
	local showHousePurchaseEvent = remoteEventsFolder:WaitForChild("ShowHousePurchase")
	local updateCurrencyEvent = remoteEventsFolder:WaitForChild("UpdateCurrency")
	local showMessageEvent = remoteEventsFolder:WaitForChild("ShowMessage")

	-- House click handlers
	wait(1) -- Wait for village to be fully created
	for _, house in pairs(workspace.Village:GetChildren()) do
		if house.Name:match("^House_") and house:FindFirstChild("ClickDetector") then
			house.ClickDetector.MouseClick:Connect(function(player)
				local price = house:FindFirstChild("Price")
				if price then
					local owner = houseOwners[house.Name]
					print("?? Player clicked " .. house.Name .. " (Price: " .. price.Value .. ")")
					showHousePurchaseEvent:FireClient(player, house.Name, price.Value, owner)
				end
			end)
		end
	end

	-- Buy house handler
	buyHouseEvent.OnServerEvent:Connect(function(player, houseName)
		local house = workspace.Village:FindFirstChild(houseName)
		if not house then return end

		local price = house:FindFirstChild("Price")
		if not price then return end

		-- Check if already owned
		if houseOwners[houseName] then
			showMessageEvent:FireClient(player, "? This house is already owned!", "error")
			return
		end

		local leaderstats = player:FindFirstChild("leaderstats")
		if not leaderstats then return end
		local coins = leaderstats:FindFirstChild("Coins")
		if not coins then return end

		if coins.Value >= price.Value then
			coins.Value = coins.Value - price.Value
			houseOwners[houseName] = player.Name

			updateHouseSign(houseName, player.Name)
			saveHouseOwnership()

			updateCurrencyEvent:FireClient(player, coins.Value)
			showMessageEvent:FireClient(player, "? Purchased " .. houseName .. "!", "success")
		else
			showMessageEvent:FireClient(player, "? Not enough coins! Need " .. price.Value, "error")
		end
	end)

	print("? House System Ready!")

end
-- ============================================
-- TRADING SYSTEM
-- ============================================
local shopInventories = {
	["General Store"] = {
		{name = "Health Potion", price = 50},
		{name = "Rope", price = 20},
		{name = "Torch", price = 15},
		{name = "Backpack", price = 100}
	},
	["Weapon Shop"] = {
		{name = "Wooden Sword", price = 150},
		{name = "Iron Sword", price = 300},
		{name = "Bow", price = 200},
		{name = "Shield", price = 250}
	},
	["Food Store"] = {
		{name = "Bread", price = 10},
		{name = "Apple", price = 5},
		{name = "Cooked Meat", price = 25},
		{name = "Water", price = 3}
	},
	["Clothing Shop"] = {
		{name = "Leather Armor", price = 200},
		{name = "Iron Helmet", price = 150},
		{name = "Boots", price = 75},
		{name = "Cloak", price = 100}
	}
}
local function initializeTradingSystem()
	print("?? Initializing Trading...")
	local buyEvent = remoteEventsFolder:WaitForChild("BuyItem")
	local showShopEvent = remoteEventsFolder:WaitForChild("ShowShop")
	local updateCurrencyEvent = remoteEventsFolder:WaitForChild("UpdateCurrency")
	local showMessageEvent = remoteEventsFolder:WaitForChild("ShowMessage")

	for _, shop in pairs(workspace.Village:GetChildren()) do
		if shop:IsA("Part") and shop:FindFirstChild("ClickDetector") and shopInventories[shop.Name] then
			shop.ClickDetector.MouseClick:Connect(function(player)
				showShopEvent:FireClient(player, shop.Name, shopInventories[shop.Name])
			end)
		end
	end

	buyEvent.OnServerEvent:Connect(function(player, shopName, itemName, price)
		local leaderstats = player:FindFirstChild("leaderstats")
		if not leaderstats then return end
		local coins = leaderstats:FindFirstChild("Coins")
		if not coins then return end

		if coins.Value >= price then
			coins.Value = coins.Value - price

			local inventory = player:FindFirstChild("Inventory")
			if not inventory then
				inventory = Instance.new("Folder")
				inventory.Name = "Inventory"
				inventory.Parent = player
			end

			local item = Instance.new("StringValue")
			item.Name = itemName
			item.Value = shopName
			item.Parent = inventory

			updateCurrencyEvent:FireClient(player, coins.Value)
			showMessageEvent:FireClient(player, "? Purchased " .. itemName .. "!", "success")
		else
			showMessageEvent:FireClient(player, "? Not enough coins!", "error")
		end
	end)

	print("? Trading Ready!")

end
-- ============================================
-- PLAYER MANAGEMENT
-- ============================================
local function setupPlayer(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 3000  -- More coins to buy houses!
	coins.Parent = leaderstats

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = 1
	level.Parent = leaderstats

	wait(1)
	remoteEventsFolder.UpdateCurrency:FireClient(player, 3000)

end
-- ============================================
-- INITIALIZE
-- ============================================
buildVillage()
initializeHouseSystem()
initializeTradingSystem()
game.Players.PlayerAdded:Connect(setupPlayer)
print("? Game Ready with Houses & Shop Signs!")
-- Auto-save house ownership every 5 minutes
spawn(function()
	while true do
		wait(300)
		saveHouseOwnership()
		print("?? Auto-saved house ownership")
	end
end)
