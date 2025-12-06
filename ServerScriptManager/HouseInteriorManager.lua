-- HOUSE INTERIOR SYSTEM
-- Allows players to enter their houses and decorate with furniture
print("🏠 Initializing House Interior System...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local interiorDataStore = DataStoreService:GetDataStore("HouseInteriors_v1")

-- Wait for RemoteEvents to be created
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEventsFolder then
	warn("❌ RemoteEvents not found!")
	return
end

-- Create new RemoteEvents for interior system
local enterHouseEvent = Instance.new("RemoteEvent")
enterHouseEvent.Name = "EnterHouse"
enterHouseEvent.Parent = remoteEventsFolder

local exitHouseEvent = Instance.new("RemoteEvent")
exitHouseEvent.Name = "ExitHouse"
exitHouseEvent.Parent = remoteEventsFolder

local placeFurnitureEvent = Instance.new("RemoteEvent")
placeFurnitureEvent.Name = "PlaceFurniture"
placeFurnitureEvent.Parent = remoteEventsFolder

local removeFurnitureEvent = Instance.new("RemoteEvent")
removeFurnitureEvent.Name = "RemoveFurniture"
removeFurnitureEvent.Parent = remoteEventsFolder

print("✅ Created Interior RemoteEvents")

-- ============================================
-- FURNITURE CATALOG
-- ============================================
local furnitureCatalog = {
	-- Beds
	{id = "bed_basic", name = "🛏️ Basic Bed", price = 100, size = Vector3.new(4, 2, 6), color = BrickColor.new("Bright blue")},
	{id = "bed_luxury", name = "👑 Luxury Bed", price = 500, size = Vector3.new(5, 3, 7), color = BrickColor.new("Gold")},
	
	-- Chairs
	{id = "chair_wood", name = "🪑 Wooden Chair", price = 50, size = Vector3.new(2, 2, 2), color = BrickColor.new("Dark oak")},
	{id = "chair_leather", name = "🪑 Leather Chair", price = 150, size = Vector3.new(2.5, 2.5, 2.5), color = BrickColor.new("Black")},
	
	-- Tables
	{id = "table_wood", name = "🪑 Wooden Table", price = 150, size = Vector3.new(4, 1, 2), color = BrickColor.new("Brown")},
	{id = "table_glass", name = "✨ Glass Table", price = 300, size = Vector3.new(4, 1, 2), color = BrickColor.new("Light blue")},
	
	-- Decorations
	{id = "lamp", name = "💡 Lamp", price = 75, size = Vector3.new(1, 2, 1), color = BrickColor.new("Bright yellow")},
	{id = "bookshelf", name = "📚 Bookshelf", price = 200, size = Vector3.new(2, 4, 1.5), color = BrickColor.new("Dark oak")},
	{id = "plant", name = "🌱 Plant", price = 60, size = Vector3.new(1, 2, 1), color = BrickColor.new("Dark green")},
	{id = "painting", name = "🎨 Painting", price = 120, size = Vector3.new(3, 2, 0.2), color = BrickColor.new("Light stone grey")},
	
	-- Rugs
	{id = "rug", name = "🧵 Rug", price = 80, size = Vector3.new(6, 0.2, 4), color = BrickColor.new("Bright red")},
}

-- ============================================
-- HOUSE INTERIOR DATA STRUCTURE
-- ============================================
local houseInteriors = {} -- {houseName = {furniture = {}, lastUpdated = time}}

local function loadHouseInterior(houseName)
	local success, data = pcall(function()
		return interiorDataStore:GetAsync(houseName)
	end)
	if success and data then
		houseInteriors[houseName] = data
		print("💾 Loaded interior for " .. houseName)
	else
		houseInteriors[houseName] = {furniture = {}}
		print("📝 Created new interior for " .. houseName)
	end
end

local function saveHouseInterior(houseName)
	pcall(function()
		interiorDataStore:SetAsync(houseName, houseInteriors[houseName])
	end)
end

-- ============================================
-- CREATE HOUSE INTERIOR ROOM
-- ============================================
local function createInteriorRoom(houseName)
	print("🏗️ Creating interior for " .. houseName)
	
	-- Create interior folder
	local interiorFolder = Instance.new("Folder")
	interiorFolder.Name = houseName .. "_Interior"
	interiorFolder.Parent = workspace
	
	-- Create floor
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(20, 1, 20)
	floor.Position = Vector3.new(0, 0, 0)
	floor.Anchored = true
	floor.BrickColor = BrickColor.new("Medium stone grey")
	floor.Material = Enum.Material.Wood
	floor.Parent = interiorFolder
	
	-- Create walls
	local wallColors = {
		BrickColor.new("Light stone grey"),
		BrickColor.new("Institutional white"),
		BrickColor.new("Light stone grey"),
		BrickColor.new("Institutional white")
	}
	
	local wallPositions = {
		Vector3.new(0, 5, 10),    -- Back wall
		Vector3.new(0, 5, -10),   -- Front wall
		Vector3.new(-10, 5, 0),   -- Left wall
		Vector3.new(10, 5, 0)     -- Right wall
	}
	
	local wallOrientations = {
		Vector3.new(0, 0, 0),
		Vector3.new(0, 0, 0),
		Vector3.new(0, 0, 0),
		Vector3.new(0, 0, 0)
	}
	
	for i = 1, 4 do
		local wall = Instance.new("Part")
		wall.Name = "Wall_" .. i
		wall.Size = Vector3.new(20, 10, 1)
		wall.Position = wallPositions[i]
		wall.Orientation = wallOrientations[i]
		wall.Anchored = true
		wall.BrickColor = wallColors[i]
		wall.Parent = interiorFolder
	end
	
	-- Create ceiling
	local ceiling = Instance.new("Part")
	ceiling.Name = "Ceiling"
	ceiling.Size = Vector3.new(20, 1, 20)
	ceiling.Position = Vector3.new(0, 10, 0)
	ceiling.Anchored = true
	ceiling.BrickColor = BrickColor.new("Institutional white")
	ceiling.Parent = interiorFolder
	
	-- Create exit door
	local exitDoor = Instance.new("Part")
	exitDoor.Name = "ExitDoor"
	exitDoor.Size = Vector3.new(5, 8, 0.5)
	exitDoor.Position = Vector3.new(0, 4, -9.75)
	exitDoor.Anchored = true
	exitDoor.BrickColor = BrickColor.new("Dark oak")
	exitDoor.Parent = interiorFolder
	
	local doorClickDetector = Instance.new("ClickDetector")
	doorClickDetector.MaxActivationDistance = 10
	doorClickDetector.Parent = exitDoor
	
	-- Furniture storage folder
	local furnitureFolder = Instance.new("Folder")
	furnitureFolder.Name = "Furniture"
	furnitureFolder.Parent = interiorFolder
	
	print("✅ Interior room created for " .. houseName)
	return interiorFolder
end

-- ============================================
-- LOAD EXISTING FURNITURE INTO ROOM
-- ============================================
local function loadFurnitureIntoRoom(houseName, interiorFolder)
	local interior = houseInteriors[houseName]
	if not interior or not interior.furniture then
		return
	end
	
	local furnitureFolder = interiorFolder:FindFirstChild("Furniture")
	if not furnitureFolder then return end
	
	for furnitureData in pairs(interior.furniture) do
		-- Parse furniture data
		local parts = string.split(furnitureData, "|")
		if #parts >= 3 then
			local furnitureId = parts[1]
			local posString = parts[2]
			local rotString = parts[3]
			
			-- Find furniture in catalog
			local furniture = nil
			for _, item in ipairs(furnitureCatalog) do
				if item.id == furnitureId then
					furniture = item
					break
				end
			end
			
			if furniture then
				-- Recreate furniture part
				local part = Instance.new("Part")
				part.Name = furniture.id
				part.Size = furniture.size
				part.BrickColor = furniture.color
				part.Anchored = true
				part.Parent = furnitureFolder
				
				-- Parse and set position/rotation (would need proper parsing)
				part.Position = Vector3.new(0, 1, 0) -- Default position
			end
		end
	end
end

-- ============================================
-- TELEPORT PLAYER INTO HOUSE
-- ============================================
local function teleportPlayerIntoHouse(player, houseName)
	print("🚪 Teleporting " .. player.Name .. " into " .. houseName)
	
	-- Load interior data if not already loaded
	if not houseInteriors[houseName] then
		loadHouseInterior(houseName)
	end
	
	-- Create or get interior room
	local interiorRoom = workspace:FindFirstChild(houseName .. "_Interior")
	if not interiorRoom then
		interiorRoom = createInteriorRoom(houseName)
		loadFurnitureIntoRoom(houseName, interiorRoom)
	end
	
	-- Store current position (to return later)
	local character = player.Character
	if not character then return end
	
	-- Store return position
	player:SetAttribute("ReturnPosition", character.HumanoidRootPart.Position)
	player:SetAttribute("CurrentHouse", houseName)
	
	-- Teleport player to interior spawn point
	local spawnPosition = Vector3.new(0, 1.5, 5)
	if character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = CFrame.new(spawnPosition)
		print("✅ " .. player.Name .. " entered " .. houseName)
	end
end

-- ============================================
-- TELEPORT PLAYER OUT OF HOUSE
-- ============================================
local function teleportPlayerOutOfHouse(player)
	print("🚪 Teleporting " .. player.Name .. " out of house")
	
	local character = player.Character
	if not character then return end
	
	local returnPos = player:GetAttribute("ReturnPosition")
	if returnPos then
		if character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = CFrame.new(returnPos)
			print("✅ " .. player.Name .. " exited house")
		end
	end
	
	player:SetAttribute("CurrentHouse", nil)
end

-- ============================================
-- HANDLE ENTER HOUSE REQUEST
-- ============================================
enterHouseEvent.OnServerEvent:Connect(function(player, houseName)
	print("📨 Enter house request from " .. player.Name .. " for " .. houseName)
	
	local house = workspace.Village:FindFirstChild(houseName)
	if not house then
		print("❌ House not found: " .. houseName)
		return
	end
	
	teleportPlayerIntoHouse(player, houseName)
end)

-- ============================================
-- HANDLE EXIT HOUSE REQUEST
-- ============================================
exitHouseEvent.OnServerEvent:Connect(function(player)
	teleportPlayerOutOfHouse(player)
end)

-- ============================================
-- HANDLE PLACE FURNITURE REQUEST
-- ============================================
placeFurnitureEvent.OnServerEvent:Connect(function(player, furnitureId, position)
	local houseName = player:GetAttribute("CurrentHouse")
	if not houseName then
		print("❌ Player not in a house!")
		return
	end
	
	-- Find furniture in catalog
	local furniture = nil
	for _, item in ipairs(furnitureCatalog) do
		if item.id == furnitureId then
			furniture = item
			break
		end
	end
	
	if not furniture then
		print("❌ Furniture not found: " .. furnitureId)
		return
	end
	
	print("🛋️ Placing " .. furniture.name .. " in " .. houseName)
	
	-- Store furniture data
	if not houseInteriors[houseName].furniture then
		houseInteriors[houseName].furniture = {}
	end
	
	local furnitureKey = furnitureId .. "_" .. tostring(position.X) .. "_" .. tostring(position.Y) .. "_" .. tostring(position.Z)
	houseInteriors[houseName].furniture[furnitureKey] = furnitureId .. "|" .. tostring(position) .. "|0"
	
	-- Create furniture part in interior
	local interiorRoom = workspace:FindFirstChild(houseName .. "_Interior")
	if interiorRoom then
		local furnitureFolder = interiorRoom:FindFirstChild("Furniture")
		if furnitureFolder then
			local part = Instance.new("Part")
			part.Name = furniture.id
			part.Size = furniture.size
			part.Position = position
			part.BrickColor = furniture.color
			part.Anchored = true
			part.CanCollide = true
			part.Parent = furnitureFolder
			
			-- Add click detector to move/delete
			local clickDetector = Instance.new("ClickDetector")
			clickDetector.MaxActivationDistance = 20
			clickDetector.Parent = part
			
			print("✅ Placed " .. furniture.name)
		end
	end
	
	saveHouseInterior(houseName)
end)

-- ============================================
-- HANDLE REMOVE FURNITURE REQUEST
-- ============================================
removeFurnitureEvent.OnServerEvent:Connect(function(player, furnitureId)
	local houseName = player:GetAttribute("CurrentHouse")
	if not houseName then return end
	
	print("🗑️ Removing " .. furnitureId .. " from " .. houseName)
	
	-- Remove from storage
	if houseInteriors[houseName].furniture then
		for key, data in pairs(houseInteriors[houseName].furniture) do
			if string.find(data, furnitureId) then
				houseInteriors[houseName].furniture[key] = nil
			end
		end
	end
	
	saveHouseInterior(houseName)
	print("✅ Removed furniture")
end)

-- ============================================
-- SETUP EXIT DOOR FUNCTIONALITY
-- ============================================
spawn(function()
	wait(2) -- Wait for interiors to be created
	
	local function setupExitDoors()
		for _, interiorFolder in pairs(workspace:GetChildren()) do
			if interiorFolder.Name:match("_Interior$") then
				local exitDoor = interiorFolder:FindFirstChild("ExitDoor")
				if exitDoor and exitDoor:FindFirstChild("ClickDetector") then
					exitDoor.ClickDetector.MouseClick:Connect(function(player)
						print("🚪 Player clicked exit door")
						teleportPlayerOutOfHouse(player)
					end)
				end
			end
		end
	end
	
	setupExitDoors()
	
	-- Periodically check for new interiors
	while true do
		wait(5)
		setupExitDoors()
	end
end)

print("✅ House Interior System Ready!")