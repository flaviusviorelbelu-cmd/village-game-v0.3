-- VILLAGE GAME WITH HOUSE OWNERSHIP + SHOP SIGNS (FIXED & ENHANCED)
print("🏘️ Starting Village Game with Houses & Signs...")
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
print("✅ Created RemoteEvents")
wait(1)
-- House ownership data
local houseOwners = {}
-- ============================================
-- VILLAGE BUILDER WITH HOUSES & SHOP SIGNS
-- ============================================
local function buildVillage()
	print("🏗️ Building Village...")
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
	
	-- House colors (variety based on price)
	local houseColors = {
		BrickColor.new("Bright red"),
		BrickColor.new("Bright orange"),
		BrickColor.new("Bright yellow"),
		BrickColor.new("Lime green"),
		BrickColor.new("Bright blue"),
		BrickColor.new("Bright violet")
	}

	-- Create 12 Houses with ClickDetectors + ENHANCEMENTS
	for i = 1, 12 do
		local angle = (2 * math.pi / 12) * (i - 1)
		local x = math.cos(angle) * houseRadius
		local z = math.sin(angle) * houseRadius

		local house = Instance.new("Part")
		house.Name = "House_" .. i
		house.Size = Vector3.new(20, 15, 20)
		house.Position = Vector3.new(x, 7.5, z)
		house.Anchored = true
		house.BrickColor = houseColors[((i-1) % 6) + 1] -- Variety!
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
		
		-- Add Highlight effect (NEW!)
		local highlight = Instance.new("Highlight")
		highlight.Enabled = false
		highlight.FillColor = Color3.fromRGB(255, 255, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 215, 0)
		highlight.FillTransparency = 0.5
		highlight.Parent = house

		local roof = Instance.new("WedgePart")
		roof.Size = Vector3.new(20, 8, 22)
		roof.Position = Vector3.new(x, 19, z)
		roof.Anchored = true
		roof.BrickColor = BrickColor.new("Reddish brown")
		roof.Orientation = Vector3.new(0, 90, 0)
		roof.Parent = house
		
		-- Add Door (NEW!)
		local door = Instance.new("Part")
		door.Name = "Door"
		door.Size = Vector3.new(5, 10, 0.5)
		door.Position = Vector3.new(x, 5, z + 10)
		door.Anchored = true
		door.BrickColor = BrickColor.new("Dark oak")
		door.Parent = house
		
		-- Add Windows (NEW!)
		for w = 1, 2 do
			local window = Instance.new("Part")
			window.Size = Vector3.new(3, 4, 0.2)
			window.Position = Vector3.new(x + (w == 1 and -6 or 6), 10, z + 10)
			window.BrickColor = BrickColor.new("Light blue")
			window.Material = Enum.Material.Glass
			window.Transparency = 0.3
			window.Anchored = true
			window.Parent = house
		end

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
		
		-- Price Sign in front of house (NEW!)
		local priceSign = Instance.new("Part")
		priceSign.Name = "PriceSign"
		priceSign.Size = Vector3.new(8, 4, 0.5)
		priceSign.Position = Vector3.new(x, 4, z + 12)
		priceSign.Anchored = true
		priceSign.Transparency = 1
		priceSign.CanCollide = false
		priceSign.Parent = house

		local priceBillboard = Instance.new("BillboardGui")
		priceBillboard.Size = UDim2.new(0, 150, 0, 40)
		priceBillboard.AlwaysOnTop = true
		priceBillboard.Parent = priceSign

		local priceLabel = Instance.new("TextLabel")
		priceLabel.Name = "PriceLabel"
		priceLabel.Size = UDim2.new(1, 0, 1, 0)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Text = "🏠 " .. housePrices[i] .. " Coins"
		priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		priceLabel.TextSize = 18
		priceLabel.Font = Enum.Font.GothamBold
		priceLabel.TextStrokeTransparency = 0.5
		priceLabel.Parent = priceBillboard
	end
	print("🏘️ Created 12 houses with purchase system")
	
	-- Add Street Lamps (NEW!)
	for i = 1, 12 do
		local angle = (2 * math.pi / 12) * (i - 1)
		local x = math.cos(angle) * (houseRadius - 30)
		local z = math.sin(angle) * (houseRadius - 30)
		
		local lampPost = Instance.new("Part")
		lampPost.Size = Vector3.new(1, 12, 1)
		lampPost.Position = Vector3.new(x, 6, z)
		lampPost.Anchored = true
		lampPost.BrickColor = BrickColor.new("Black")
		lampPost.Material = Enum.Material.Metal
		lampPost.Parent = villageFolder
		
		local lampLight = Instance.new("Part")
		lampLight.Size = Vector3.new(3, 3, 3)
		lampLight.Position = Vector3.new(x, 13, z)
		lampLight.Anchored = true
		lampLight.BrickColor = BrickColor.new("Bright yellow")
		lampLight.Material = Enum.Material.Neon
		lampLight.Shape = Enum.PartType.Ball
		lampLight.Parent = lampPost
		
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 2
		pointLight.Range = 40
		pointLight.Color = Color3.fromRGB(255, 230, 150)
		pointLight.Parent = lampLight
	end
	print("💡 Added street lamps")

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
	print("🏪 Created 4 shops with name signs")

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

	print("✅ Village Created!")

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
		print("💾 Loaded house ownership data")
	else
		print("💾 No existing house data")
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
		-- Change house appearance when purchased (NEW!)
		if ownerName then
			house.BrickColor = BrickColor.new("Gold")
			-- Add sparkle effect
			if not house:FindFirstChild("Sparkles") then
				local sparkles = Instance.new("Sparkles")
				sparkles.Parent = house
			end
			-- Hide price sign
			local priceSign = house:FindFirstChild("PriceSign")
			if priceSign then
				local billboard = priceSign:FindFirstChild("BillboardGui")
				if billboard then
					local label = billboard:FindFirstChild("PriceLabel")
					if label then
						label.Visible = false
					end
				end
			end
		end
		
		local ownerSign = house:FindFirstChild("OwnerSign")
		if ownerSign then
			local billboardGui = ownerSign:FindFirstChild("BillboardGui")
			if billboardGui then
				local ownerLabel = billboardGui:FindFirstChild("OwnerLabel")
				if ownerLabel then
					if ownerName then
						ownerLabel.Text = "✨ OWNED BY " .. string.upper(ownerName) .. " ✨"
					else
						ownerLabel.Text = ""
					end
				end
			end
		end
	end
end
local function initializeHouseSystem()
	print("🏠 Initializing House System...")
	loadHouseOwnership()
	
	-- CRITICAL FIX: Wait for Village folder to exist
	local villageFolder = workspace:WaitForChild("Village", 10)
	if not villageFolder then
		warn("❌ Village folder not found! Cannot initialize house system.")
		return
	end
	print("✅ Village folder found")

	-- Update all house signs from saved data
	for houseName, ownerName in pairs(houseOwners) do
		updateHouseSign(houseName, ownerName)
	end

	local buyHouseEvent = remoteEventsFolder:WaitForChild("BuyHouse")
	local showHousePurchaseEvent = remoteEventsFolder:WaitForChild("ShowHousePurchase")
	local updateCurrencyEvent = remoteEventsFolder:WaitForChild("UpdateCurrency")
	local showMessageEvent = remoteEventsFolder:WaitForChild("ShowMessage")

	-- CRITICAL FIX: House click handlers (now runs AFTER village is built)
	local houseCount = 0
	for _, house in pairs(villageFolder:GetChildren()) do
		if house.Name:match("^House_") and house:FindFirstChild("ClickDetector") then
			houseCount = houseCount + 1
			
			-- Add hover highlight (NEW!)
			local highlight = house:FindFirstChild("Highlight")
			if highlight then
				house.ClickDetector.MouseHoverEnter:Connect(function()
					highlight.Enabled = true
				end)
				house.ClickDetector.MouseHoverLeave:Connect(function()
					highlight.Enabled = false
				end)
			end
			
			-- Click to purchase
			house.ClickDetector.MouseClick:Connect(function(player)
				local price = house:FindFirstChild("Price")
				if price then
					local owner = houseOwners[house.Name]
					print("🖱️ Player " .. player.Name .. " clicked " .. house.Name .. " (Price: " .. price.Value .. ")")
					showHousePurchaseEvent:FireClient(player, house.Name, price.Value, owner)
				end
			end)
			print("✅ Added click handler for " .. house.Name)
		end
	end
	print("✅ Initialized " .. houseCount .. " house click detectors")

	-- Buy house handler
	buyHouseEvent.OnServerEvent:Connect(function(player, houseName)
		print("🏠 Player " .. player.Name .. " attempting to buy " .. houseName)
		local house = workspace.Village:FindFirstChild(houseName)
		if not house then 
			print("❌ House not found: " .. houseName)
			return 
		end

		local price = house:FindFirstChild("Price")
		if not price then 
			print("❌ Price not found for " .. houseName)
			return 
		end

		-- Check if already owned
		if houseOwners[houseName] then
			print("❌ House already owned by " .. houseOwners[houseName])
			showMessageEvent:FireClient(player, "❌ This house is already owned!", "error")
			return
		end

		local leaderstats = player:FindFirstChild("leaderstats")
		if not leaderstats then 
			print("❌ No leaderstats for " .. player.Name)
			return 
		end
		local coins = leaderstats:FindFirstChild("Coins")
		if not coins then 
			print("❌ No coins for " .. player.Name)
			return 
		end

		if coins.Value >= price.Value then
			coins.Value = coins.Value - price.Value
			houseOwners[houseName] = player.Name

			updateHouseSign(houseName, player.Name)
			saveHouseOwnership()

			updateCurrencyEvent:FireClient(player, coins.Value)
			showMessageEvent:FireClient(player, "✅ Purchased " .. houseName .. "!", "success")
			print("✅ " .. player.Name .. " successfully purchased " .. houseName)
		else
			print("❌ " .. player.Name .. " has insufficient funds (" .. coins.Value .. "/" .. price.Value .. ")")
			showMessageEvent:FireClient(player, "❌ Not enough coins! Need " .. price.Value, "error")
		end
	end)

	print("✅ House System Ready!")

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
	print("🛒 Initializing Trading...")
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
			showMessageEvent:FireClient(player, "✅ Purchased " .. itemName .. "!", "success")
		else
			showMessageEvent:FireClient(player, "❌ Not enough coins!", "error")
		end
	end)

	print("✅ Trading Ready!")

end
-- ============================================
-- PLAYER MANAGEMENT
-- ============================================
local function setupPlayer(player)
	print("👤 Setting up player: " .. player.Name)
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
	print("✅ Player " .. player.Name .. " setup complete")

end
-- ============================================
-- INITIALIZE
-- ============================================
print("🚀 Starting initialization sequence...")
buildVillage()
print("✅ Village built, now initializing systems...")
initializeHouseSystem()
initializeTradingSystem()
game.Players.PlayerAdded:Connect(setupPlayer)
print("✅ Game Ready with Houses & Shop Signs!")
print("📊 Debug: Village has " .. #workspace.Village:GetChildren() .. " objects")
-- Auto-save house ownership every 5 minutes
spawn(function()
	while true do
		wait(300)
		saveHouseOwnership()
		print("💾 Auto-saved house ownership")
	end
end)