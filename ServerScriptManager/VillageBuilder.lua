-- VillageBuilder.lua - Creates village map (ModuleScript)
local Workspace = game:GetService("Workspace")

local VillageBuilder = {}

-- Village configuration
local VILLAGE_CONFIG = {
	CENTER = Vector3.new(0, 0, 0),
	HOUSE_COUNT = 12,
	ROAD_WIDTH = 8,
	HOUSE_SIZE = Vector3.new(20, 15, 20),
	SHOP_SIZE = Vector3.new(30, 20, 25)
}

-- Create the main village
function VillageBuilder:CreateVillage()
	print("??? Building Epic Village...")

	-- Clear any existing village
	local existingVillage = Workspace:FindFirstChild("Village")
	if existingVillage then
		existingVillage:Destroy()
	end

	-- Create village folder
	local villageFolder = Instance.new("Folder")
	villageFolder.Name = "Village"
	villageFolder.Parent = Workspace

	-- Build terrain base
	self:CreateTerrain(villageFolder)

	-- Create roads
	self:CreateRoads(villageFolder)

	-- Build houses
	self:CreateHouses(villageFolder)

	-- Create market area
	self:CreateMarketArea(villageFolder)

	-- Add shops
	self:CreateShops(villageFolder)

	-- Add decorations
	self:AddDecorations(villageFolder)

	print("? Epic Village Created!")
end

-- Create terrain base
function VillageBuilder:CreateTerrain(parent)
	-- Create grass base
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(300, 2, 300)
	ground.Position = Vector3.new(0, -1, 0)
	ground.Anchored = true
	ground.BrickColor = BrickColor.new("Bright green")
	ground.Material = Enum.Material.Grass
	ground.Parent = parent

	-- Add corner markers for visibility
	for x = -1, 1, 2 do
		for z = -1, 1, 2 do
			local marker = Instance.new("Part")
			marker.Name = "CornerMarker"
			marker.Size = Vector3.new(4, 4, 4)
			marker.Position = Vector3.new(x * 140, 2, z * 140)
			marker.Anchored = true
			marker.BrickColor = BrickColor.new("Bright yellow")
			marker.Shape = Enum.PartType.Ball
			marker.Parent = parent
		end
	end
end

-- Create road system
function VillageBuilder:CreateRoads(parent)
	local roadsFolder = Instance.new("Folder")
	roadsFolder.Name = "Roads"
	roadsFolder.Parent = parent

	-- Main cross roads
	local mainRoadH = Instance.new("Part")
	mainRoadH.Name = "MainRoadHorizontal"
	mainRoadH.Size = Vector3.new(200, 0.5, VILLAGE_CONFIG.ROAD_WIDTH)
	mainRoadH.Position = Vector3.new(0, 0.25, 0)
	mainRoadH.Anchored = true
	mainRoadH.BrickColor = BrickColor.new("Dark stone grey")
	mainRoadH.Material = Enum.Material.Concrete
	mainRoadH.Parent = roadsFolder

	local mainRoadV = Instance.new("Part")
	mainRoadV.Name = "MainRoadVertical"
	mainRoadV.Size = Vector3.new(VILLAGE_CONFIG.ROAD_WIDTH, 0.5, 200)
	mainRoadV.Position = Vector3.new(0, 0.25, 0)
	mainRoadV.Anchored = true
	mainRoadV.BrickColor = BrickColor.new("Dark stone grey")
	mainRoadV.Material = Enum.Material.Concrete
	mainRoadV.Parent = roadsFolder

	print("??? Roads created")
end

-- Create houses around the village
function VillageBuilder:CreateHouses(parent)
	local housesFolder = Instance.new("Folder")
	housesFolder.Name = "Houses"
	housesFolder.Parent = parent

	-- House positions in a circle around center
	local housePositions = {
		Vector3.new(40, 0, 40),   Vector3.new(-40, 0, 40),
		Vector3.new(40, 0, -40),  Vector3.new(-40, 0, -40),
		Vector3.new(60, 0, 0),    Vector3.new(-60, 0, 0),
		Vector3.new(0, 0, 60),    Vector3.new(0, 0, -60),
		Vector3.new(70, 0, 30),   Vector3.new(-70, 0, 30),
		Vector3.new(70, 0, -30),  Vector3.new(-70, 0, -30)
	}

	for i, position in ipairs(housePositions) do
		self:CreateHouse(housesFolder, position, i)
	end

	print("?? Created " .. #housePositions .. " houses")
end

-- Create individual house
function VillageBuilder:CreateHouse(parent, position, houseNumber)
	local houseFolder = Instance.new("Folder")
	houseFolder.Name = "House_" .. houseNumber
	houseFolder.Parent = parent

	-- House base
	local houseBase = Instance.new("Part")
	houseBase.Name = "Base"
	houseBase.Size = VILLAGE_CONFIG.HOUSE_SIZE
	houseBase.Position = position + Vector3.new(0, VILLAGE_CONFIG.HOUSE_SIZE.Y/2, 0)
	houseBase.Anchored = true
	houseBase.BrickColor = BrickColor.new("Brick yellow")
	houseBase.Material = Enum.Material.Brick
	houseBase.Parent = houseFolder

	-- Roof
	local roof = Instance.new("WedgePart")
	roof.Name = "Roof"
	roof.Size = Vector3.new(VILLAGE_CONFIG.HOUSE_SIZE.X + 4, 8, VILLAGE_CONFIG.HOUSE_SIZE.Z + 4)
	roof.Position = position + Vector3.new(0, VILLAGE_CONFIG.HOUSE_SIZE.Y + 4, 0)
	roof.Anchored = true
	roof.BrickColor = BrickColor.new("Really red")
	roof.Material = Enum.Material.Neon
	roof.Parent = houseFolder

	-- Door
	local door = Instance.new("Part")
	door.Name = "Door"
	door.Size = Vector3.new(1, 8, 4)
	door.Position = position + Vector3.new(0, 4, VILLAGE_CONFIG.HOUSE_SIZE.Z/2)
	door.Anchored = true
	door.BrickColor = BrickColor.new("Dark orange")
	door.Material = Enum.Material.Wood
	door.Parent = houseFolder
end

-- Create market area
function VillageBuilder:CreateMarketArea(parent)
	local marketFolder = Instance.new("Folder")
	marketFolder.Name = "Market"
	marketFolder.Parent = parent

	-- Market platform
	local marketPlatform = Instance.new("Part")
	marketPlatform.Name = "MarketPlatform"
	marketPlatform.Size = Vector3.new(50, 2, 50)
	marketPlatform.Position = Vector3.new(0, 1, -80)
	marketPlatform.Anchored = true
	marketPlatform.BrickColor = BrickColor.new("Light stone grey")
	marketPlatform.Material = Enum.Material.Concrete
	marketPlatform.Parent = marketFolder

	-- Market stalls
	for i = 1, 6 do
		local angle = (i - 1) * (math.pi * 2 / 6)
		local stallPos = Vector3.new(
			math.cos(angle) * 20,
			3,
			-80 + math.sin(angle) * 20
		)

		local stall = Instance.new("Part")
		stall.Name = "MarketStall_" .. i
		stall.Size = Vector3.new(8, 4, 8)
		stall.Position = stallPos
		stall.Anchored = true
		stall.BrickColor = BrickColor.new("Brown")
		stall.Material = Enum.Material.Wood
		stall.Parent = marketFolder
	end

	print("?? Market area created")
end

-- Create shops
function VillageBuilder:CreateShops(parent)
	local shopsFolder = Instance.new("Folder")
	shopsFolder.Name = "Shops"
	shopsFolder.Parent = parent

	-- Shop types and positions
	local shops = {
		{name = "GeneralStore", position = Vector3.new(-80, 0, 0), color = "Bright blue"},
		{name = "WeaponShop", position = Vector3.new(80, 0, 0), color = "Really red"},
		{name = "FoodStore", position = Vector3.new(0, 0, 80), color = "Bright green"},
		{name = "ClothingShop", position = Vector3.new(-50, 0, -50), color = "Light reddish violet"}
	}

	for _, shopData in ipairs(shops) do
		self:CreateShop(shopsFolder, shopData.position, shopData.name, shopData.color)
	end

	print("?? Created " .. #shops .. " shops")
end

-- Create individual shop
function VillageBuilder:CreateShop(parent, position, shopName, color)
	local shopFolder = Instance.new("Folder")
	shopFolder.Name = shopName
	shopFolder.Parent = parent

	-- Shop building
	local shopBase = Instance.new("Part")
	shopBase.Name = "Base"
	shopBase.Size = VILLAGE_CONFIG.SHOP_SIZE
	shopBase.Position = position + Vector3.new(0, VILLAGE_CONFIG.SHOP_SIZE.Y/2, 0)
	shopBase.Anchored = true
	shopBase.BrickColor = BrickColor.new(color)
	shopBase.Material = Enum.Material.Plastic
	shopBase.Parent = shopFolder

	-- Shop sign
	local sign = Instance.new("Part")
	sign.Name = "Sign"
	sign.Size = Vector3.new(12, 4, 1)
	sign.Position = position + Vector3.new(0, VILLAGE_CONFIG.SHOP_SIZE.Y + 2, VILLAGE_CONFIG.SHOP_SIZE.Z/2 + 1)
	sign.Anchored = true
	sign.BrickColor = BrickColor.new("Really black")
	sign.Parent = shopFolder

	-- Add shop interaction (ClickDetector)
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.Parent = shopBase
	clickDetector.MaxActivationDistance = 25

	print("?? Created shop:", shopName)
end

-- Add decorative elements
function VillageBuilder:AddDecorations(parent)
	local decorFolder = Instance.new("Folder")
	decorFolder.Name = "Decorations"
	decorFolder.Parent = parent

	-- Fountain in center
	local fountain = Instance.new("Part")
	fountain.Name = "Fountain"
	fountain.Size = Vector3.new(12, 8, 12)
	fountain.Position = Vector3.new(0, 4, 0)
	fountain.Shape = Enum.PartType.Cylinder
	fountain.Anchored = true
	fountain.BrickColor = BrickColor.new("Light blue")
	fountain.Material = Enum.Material.Neon
	fountain.Parent = decorFolder

	-- Trees around village
	for i = 1, 20 do
		local angle = i * (math.pi * 2 / 20)
		local treePos = Vector3.new(
			math.cos(angle) * 100,
			0,
			math.sin(angle) * 100
		)

		self:CreateTree(decorFolder, treePos, i)
	end

	print("?? Added decorations and trees")
end

-- Create tree decoration
function VillageBuilder:CreateTree(parent, position, treeNumber)
	local treeFolder = Instance.new("Folder")
	treeFolder.Name = "Tree_" .. treeNumber
	treeFolder.Parent = parent

	-- Tree trunk
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = Vector3.new(2, 12, 2)
	trunk.Position = position + Vector3.new(0, 6, 0)
	trunk.Anchored = true
	trunk.BrickColor = BrickColor.new("Brown")
	trunk.Material = Enum.Material.Wood
	trunk.Parent = treeFolder

	-- Tree leaves
	local leaves = Instance.new("Part")
	leaves.Name = "Leaves"
	leaves.Size = Vector3.new(8, 8, 8)
	leaves.Position = position + Vector3.new(0, 16, 0)
	leaves.Shape = Enum.PartType.Ball
	leaves.Anchored = true
	leaves.BrickColor = BrickColor.new("Bright green")
	leaves.Material = Enum.Material.Grass
	leaves.Parent = treeFolder
end

return VillageBuilder
