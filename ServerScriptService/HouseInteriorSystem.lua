-- HOUSE INTERIOR SYSTEM
-- Creates interior spaces for owned houses with teleportation
-- Interiors are created on-demand (lazy loading) to avoid overlapping with village
print("🏠 Initializing House Interior System...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- Create RemoteEvents folder if it doesn't exist
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

-- Create RemoteEvents for house interactions
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

print("✅ Created RemoteEvents")

-- ============================================
-- HOUSE INTERIOR MANAGER
-- ============================================
local HouseInteriorManager = {}
HouseInteriorManager.interiors = {} -- Store all interiors by house name
HouseInteriorManager.playerHouses = {} -- Track which interior each player is in
HouseInteriorManager.houseDoors = {} -- Track door positions for each house
HouseInteriorManager.INTERIOR_Y_OFFSET = 100 -- Interiors at Y+100 to avoid collision

-- Furniture catalog with models
HouseInteriorManager.furnitureCatalog = {
	bed_basic = { name = "🛏️ Basic Bed", price = 100, size = Vector3.new(3, 2, 3) },
	bed_luxury = { name = "👑 Luxury Bed", price = 500, size = Vector3.new(4, 2.5, 4) },
	chair_wood = { name = "🪑 Wooden Chair", price = 50, size = Vector3.new(1, 1.5, 1) },
	chair_leather = { name = "🪑 Leather Chair", price = 150, size = Vector3.new(1.2, 1.5, 1.2) },
	table_wood = { name = "🪑 Wooden Table", price = 150, size = Vector3.new(2, 1, 2) },
	table_glass = { name = "✨ Glass Table", price = 300, size = Vector3.new(2.5, 1, 2.5) },
	lamp = { name = "💡 Lamp", price = 75, size = Vector3.new(0.5, 2, 0.5) },
	bookshelf = { name = "📚 Bookshelf", price = 200, size = Vector3.new(1, 3, 0.5) },
	plant = { name = "🌱 Plant", price = 60, size = Vector3.new(1, 1.5, 1) },
	painting = { name = "🎨 Painting", price = 120, size = Vector3.new(2, 2, 0.2) },
	rug = { name = "🧵 Rug", price = 80, size = Vector3.new(3, 0.1, 3) },
}

-- Create a house interior (LAZY LOADED - only when player enters)
function HouseInteriorManager:CreateInterior(houseName, owner)
	-- Check if already created
	if self.interiors[houseName] then
		return self.interiors[houseName].folder
	end
	
	local interior = Instance.new("Folder")
	interior.Name = houseName .. "_Interior"
	interior.Parent = workspace
	
	-- Store metadata
	local metadata = Instance.new("Folder")
	metadata.Name = "Metadata"
	metadata.Parent = interior
	
	local ownerValue = Instance.new("StringValue")
	ownerValue.Name = "Owner"
	ownerValue.Value = owner
	ownerValue.Parent = metadata
	
	-- Create floor at elevated Y position to avoid village collision
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Shape = Enum.PartType.Block
	floor.Size = Vector3.new(30, 1, 30)
	floor.Position = Vector3.new(0, self.INTERIOR_Y_OFFSET, 0)
	floor.Color = Color3.fromRGB(139, 90, 43)
	floor.Material = Enum.Material.Wood
	floor.CanCollide = true
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.BottomSurface = Enum.SurfaceType.Smooth
	floor.Parent = interior
	
	-- Create walls
	local wallColors = {
		Color3.fromRGB(200, 180, 160), -- cream
		Color3.fromRGB(200, 180, 160),
		Color3.fromRGB(200, 180, 160),
		Color3.fromRGB(200, 180, 160)
	}
	
	local wallPositions = {
		Vector3.new(0, self.INTERIOR_Y_OFFSET + 8, 15),      -- back
		Vector3.new(0, self.INTERIOR_Y_OFFSET + 8, -15),     -- front
		Vector3.new(15, self.INTERIOR_Y_OFFSET + 8, 0),      -- right
		Vector3.new(-15, self.INTERIOR_Y_OFFSET + 8, 0)      -- left
	}
	
	local wallSizes = {
		Vector3.new(30, 16, 1),     -- back
		Vector3.new(30, 16, 1),     -- front
		Vector3.new(1, 16, 30),     -- right
		Vector3.new(1, 16, 30)      -- left
	}
	
	for i = 1, 4 do
		local wall = Instance.new("Part")
		wall.Name = "Wall_" .. i
		wall.Shape = Enum.PartType.Block
		wall.Size = wallSizes[i]
		wall.Position = wallPositions[i]
		wall.Color = wallColors[i]
		wall.Material = Enum.Material.Brick
		wall.CanCollide = true
		wall.TopSurface = Enum.SurfaceType.Smooth
		wall.BottomSurface = Enum.SurfaceType.Smooth
		wall.Parent = interior
	end
	
	-- Create ceiling
	local ceiling = Instance.new("Part")
	ceiling.Name = "Ceiling"
	ceiling.Shape = Enum.PartType.Block
	ceiling.Size = Vector3.new(30, 1, 30)
	ceiling.Position = Vector3.new(0, self.INTERIOR_Y_OFFSET + 16, 0)
	ceiling.Color = Color3.fromRGB(220, 220, 220)
	ceiling.Material = Enum.Material.Brick
	ceiling.CanCollide = true
	ceiling.TopSurface = Enum.SurfaceType.Smooth
	ceiling.BottomSurface = Enum.SurfaceType.Smooth
	ceiling.Parent = interior
	
	-- Create EXIT PORTAL (blue door inside house)
	local exitPortal = Instance.new("Part")
	exitPortal.Name = "ExitPortal"
	exitPortal.Shape = Enum.PartType.Block
	exitPortal.Size = Vector3.new(3, 4, 0.5)
	exitPortal.Position = Vector3.new(0, self.INTERIOR_Y_OFFSET + 2, -14.5)
	exitPortal.Color = Color3.fromRGB(100, 200, 255)
	exitPortal.Material = Enum.Material.Neon
	exitPortal.CanCollide = false
	exitPortal.Transparency = 0.2
	exitPortal.Parent = interior
	
	-- Add label to exit portal
	local portalLabel = Instance.new("BillboardGui")
	portalLabel.Size = UDim2.new(4, 0, 2, 0)
	portalLabel.MaxDistance = 100
	portalLabel.Parent = exitPortal
	
	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(1, 0, 1, 0)
	labelText.BackgroundTransparency = 0.5
	labelText.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
	labelText.TextScaled = true
	labelText.Text = "🚪 Exit"
	labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
	labelText.Parent = portalLabel
	
	local touchConnection
	touchConnection = exitPortal.Touched:Connect(function(hit)
		if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
			local character = hit.Parent
			local player = Players:FindFirstChild(character.Name) or game.Players:FindFirstChild(character.Name)
			
			if player then
				self:ExitHouse(player)
			end
		end
	end)
	
	-- Store furniture folder
	local furnitureFolder = Instance.new("Folder")
	furnitureFolder.Name = "Furniture"
	furnitureFolder.Parent = interior
	
	-- Store interior in manager
	self.interiors[houseName] = {
		folder = interior,
		owner = owner,
		spawnPoint = Vector3.new(0, self.INTERIOR_Y_OFFSET + 2, 0),
		furniture = {}
	}
	
	print("✅ Created interior for " .. houseName .. " (Y=" .. self.INTERIOR_Y_OFFSET .. ")")
	return interior
end

-- Add white door to a house in the village
function HouseInteriorManager:AddDoorToHouse(house, houseName)
	if house:FindFirstChild("HouseDoor") then
		return -- Door already exists
	end
	
	local door = Instance.new("Part")
	door.Name = "HouseDoor"
	door.Shape = Enum.PartType.Block
	door.Size = Vector3.new(2, 3, 0.3)
	door.Color = Color3.fromRGB(255, 255, 255)  -- White
	door.Material = Enum.Material.Wood
	door.CanCollide = true
	door.TopSurface = Enum.SurfaceType.Smooth
	door.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Position door at front of house
	door.Position = house.Position + Vector3.new(0, 1.5, -3)
	door.Parent = house
	
	-- Add click detector for enter prompt
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 30
	clickDetector.Parent = door
	
	-- Add label to door
	local doorLabel = Instance.new("BillboardGui")
	doorLabel.Size = UDim2.new(3, 0, 1.5, 0)
	doorLabel.MaxDistance = 50
	doorLabel.Parent = door
	
	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(1, 0, 1, 0)
	labelText.BackgroundTransparency = 0.3
	labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	labelText.TextScaled = true
	labelText.Text = "🚪 Enter Home"
	labelText.TextColor3 = Color3.fromRGB(0, 0, 0)
	labelText.Parent = doorLabel
	
	-- Handle door touch (teleport into house)
	local touchConnection
	touchConnection = door.Touched:Connect(function(hit)
		if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
			local character = hit.Parent
			local player = Players:FindFirstChild(character.Name) or game.Players:FindFirstChild(character.Name)
			
			if player then
				local ownerValue = house:FindFirstChild("Owner")
				local owner = ownerValue and ownerValue.Value or "Admin"
				
				-- Allow owner and admin to enter
				if owner == player.Name or owner == "Admin" then
					print("🚪 " .. player.Name .. " walking into " .. houseName)
					self:EnterHouse(player, houseName)
				end
			end
		end
	end)
	
	-- Store door position
	self.houseDoors[houseName] = door.Position
	
	print("✅ Added white door to " .. houseName)
end

-- Teleport player into house (creates interior on first entry)
function HouseInteriorManager:EnterHouse(player, houseName)
	-- Create interior if it doesn't exist yet (lazy loading)
	if not self.interiors[houseName] then
		local house = workspace.Village:FindFirstChild(houseName)
		if not house then
			warn("House not found: " .. houseName)
			return false
		end
		
		local ownerValue = house:FindFirstChild("Owner")
		local owner = ownerValue and ownerValue.Value or "Admin"
		
		-- Create interior now
		self:CreateInterior(houseName, owner)
	end
	
	local houseData = self.interiors[houseName]
	if not houseData then
		warn("House interior not found: " .. houseName)
		return false
	end
	
	local character = player.Character
	if not character then return false end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return false end
	
	-- Store player's previous position (for exit)
	if not player:GetAttribute("PreviousPosition") then
		player:SetAttribute("PreviousPosition", humanoidRootPart.CFrame)
	end
	
	-- Teleport into house
	humanoidRootPart.CFrame = CFrame.new(houseData.spawnPoint + Vector3.new(0, 3, 0))
	
	-- Mark player as being in house
	self.playerHouses[player.UserId] = houseName
	player:SetAttribute("CurrentHouse", houseName)
	
	print("✅ " .. player.Name .. " entered " .. houseName .. " (Y=" .. self.INTERIOR_Y_OFFSET .. ")")
	return true
end

-- Teleport player out of house
function HouseInteriorManager:ExitHouse(player)
	local character = player.Character
	if not character then return false end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return false end
	
	-- Teleport to house location in village
	local houseName = player:GetAttribute("CurrentHouse")
	if houseName then
		local doorPos = self.houseDoors[houseName]
		if doorPos then
			humanoidRootPart.CFrame = CFrame.new(doorPos + Vector3.new(0, 0, 2))  -- Outside door
		else
			local houseInVillage = workspace.Village:FindFirstChild(houseName)
			if houseInVillage then
				humanoidRootPart.CFrame = CFrame.new(houseInVillage.Position + Vector3.new(0, 5, 0))
			end
		end
	end
	
	-- Clear house data
	self.playerHouses[player.UserId] = nil
	player:SetAttribute("CurrentHouse", nil)
	
	print("✅ " .. player.Name .. " exited house")
	return true
end

-- Create furniture in interior
function HouseInteriorManager:PlaceFurniture(player, houseName, furnitureId, position)
	local houseData = self.interiors[houseName]
	if not houseData then
		warn("House not found")
		return false
	end
	
	-- Check if player owns the house
	if houseData.owner ~= player.Name then
		warn("Player does not own this house")
		return false
	end
	
	local furnitureTemplate = self.furnitureCatalog[furnitureId]
	if not furnitureTemplate then
		warn("Furniture not found: " .. furnitureId)
		return false
	end
	
	-- Create furniture part
	local furniture = Instance.new("Part")
	furniture.Name = furnitureId
	furniture.Shape = Enum.PartType.Block
	furniture.Size = furnitureTemplate.size
	furniture.Position = position
	furniture.Color = Color3.fromRGB(math.random(50, 200), math.random(50, 200), math.random(50, 200))
	furniture.Material = Enum.Material.Wood
	furniture.CanCollide = true
	furniture.Anchored = true
	furniture.TopSurface = Enum.SurfaceType.Smooth
	furniture.BottomSurface = Enum.SurfaceType.Smooth
	furniture.Parent = houseData.folder:FindFirstChild("Furniture")
	
	-- Add label
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(3, 0, 1, 0)
	billboardGui.Parent = furniture
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 0.3
	textLabel.TextScaled = true
	textLabel.Text = furnitureTemplate.name
	textLabel.Parent = billboardGui
	
	-- Store in furniture list
	table.insert(houseData.furniture, {
		id = furnitureId,
		part = furniture,
		position = position
	})
	
	print("✅ Placed " .. furnitureTemplate.name .. " in " .. houseName)
	return true
end

print("✅ Created Interior RemoteEvents")

-- ============================================
-- REMOTE EVENT HANDLERS
-- ============================================

enterHouseEvent.OnServerEvent:Connect(function(player, houseName)
	print("🏠 " .. player.Name .. " trying to enter " .. houseName)
	HouseInteriorManager:EnterHouse(player, houseName)
end)

exitHouseEvent.OnServerEvent:Connect(function(player)
	print("🚪 " .. player.Name .. " trying to exit house")
	HouseInteriorManager:ExitHouse(player)
end)

placeFurnitureEvent.OnServerEvent:Connect(function(player, furnitureId, position)
	local houseName = player:GetAttribute("CurrentHouse")
	if houseName then
		HouseInteriorManager:PlaceFurniture(player, houseName, furnitureId, position)
	end
end)

-- ============================================
-- INITIALIZE HOUSE DOORS (but NOT interiors)
-- ============================================
local function initializeHouseDoors()
	wait(2) -- Wait for village to load
	
	local villageFolder = workspace:FindFirstChild("Village")
	if not villageFolder then
		warn("Village folder not found")
		return
	end
	
	-- Only add doors, DON'T create interiors yet
	for _, house in pairs(villageFolder:GetChildren()) do
		if house.Name:match("^House_") then
			-- Add white door to house
			HouseInteriorManager:AddDoorToHouse(house, house.Name)
		end
	end
	
	print("✅ House Door System Ready! (Interiors lazy-loaded on entry)")
end

initializeHouseDoors()

-- Handle new players entering
local function onPlayerAdded(player)
	local character = player.Character or player.CharacterAdded:Wait()
	
	-- Reset house attribute on spawn
	player.CharacterAdded:Connect(function(newCharacter)
		HouseInteriorManager:ExitHouse(player)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle player disconnect
Players.PlayerRemoving:Connect(function(player)
	HouseInteriorManager.playerHouses[player.UserId] = nil
end)

print("🎉 House Interior System Initialized! (Lazy-loaded, Y=" .. HouseInteriorManager.INTERIOR_Y_OFFSET .. ")")