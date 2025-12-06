-- HOUSE INTERIOR SYSTEM
-- Creates interior spaces for owned houses with teleportation
print("🏠 Initializing House Interior System...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

print("✅ Created RemoteEvents")

-- ============================================
-- BEDROCK SUPPORT LAYER
-- ============================================
local function createBedrockSupport()
	local bedrockFolder = Instance.new("Folder")
	bedrockFolder.Name = "IslandSupport"
	bedrockFolder.Parent = workspace
	
	-- Create a bedrock layer at Y=180 to catch any falling islands
	local bedrock = Instance.new("Part")
	bedrock.Name = "Bedrock"
	bedrock.Shape = Enum.PartType.Block
	bedrock.Size = Vector3.new(1000, 5, 1000)
	bedrock.Position = Vector3.new(250, 177, 250)
	bedrock.Color = Color3.fromRGB(50, 50, 50)
	bedrock.Material = Enum.Material.Concrete
	bedrock.CanCollide = true
	bedrock.TopSurface = Enum.SurfaceType.Smooth
	bedrock.BottomSurface = Enum.SurfaceType.Smooth
	bedrock.Anchored = true
	bedrock.Parent = bedrockFolder
	
	print("🗑️ Created bedrock support layer at Y=177")
	return bedrockFolder
end

createBedrockSupport()

-- ============================================
-- HOUSE INTERIOR MANAGER
-- ============================================
local HouseInteriorManager = {}
HouseInteriorManager.interiors = {} -- Store all interiors by house name
HouseInteriorManager.playerHouses = {} -- Track which interior each player is in
HouseInteriorManager.houseDoors = {} -- Track door positions for each house
HouseInteriorManager.doorCooldown = {} -- Prevent spam

-- Create unique position for each house interior (separate islands)
local function getInteriorPosition(houseNumber)
	-- Create a grid of islands: 3 rows, 4 columns, spaced 100 studs apart
	-- ALL at Y=200 for consistent height
	local row = math.floor((houseNumber - 1) / 4)
	local col = (houseNumber - 1) % 4
	
	local x = col * 100 + 250
	local y = 200 -- FIXED HEIGHT - HIGH UP
	local z = row * 100 + 250
	
	return Vector3.new(x, y, z)
end

-- Create a house interior (LAZY LOADED - only when player enters)
function HouseInteriorManager:CreateInterior(houseName, owner)
	-- Check if already created
	if self.interiors[houseName] then
		return self.interiors[houseName].folder
	end
	
	local houseNumber = tonumber(houseName:match("House_(%d+)")) or 1
	local basePosition = getInteriorPosition(houseNumber)
	
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
	
	-- Create floor at island position
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Shape = Enum.PartType.Block
	floor.Size = Vector3.new(40, 1, 40)
	floor.Position = basePosition
	floor.Color = Color3.fromRGB(139, 90, 43)
	floor.Material = Enum.Material.Wood
	floor.CanCollide = true
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.BottomSurface = Enum.SurfaceType.Smooth
	floor.Anchored = true -- ANCHOR TO PREVENT FALLING
	floor.Parent = interior
	
	-- Create support pillar under floor (invisible foundation)
	local pillar = Instance.new("Part")
	pillar.Name = "Pillar"
	pillar.Shape = Enum.PartType.Block
	pillar.Size = Vector3.new(40, 200, 40)
	pillar.Position = basePosition - Vector3.new(0, 101, 0)
	pillar.Color = Color3.fromRGB(100, 100, 100)
	pillar.Material = Enum.Material.Concrete
	pillar.CanCollide = false -- Invisible support
	pillar.TopSurface = Enum.SurfaceType.Smooth
	pillar.BottomSurface = Enum.SurfaceType.Smooth
	pillar.Anchored = true
	pillar.Transparency = 1 -- Invisible
	pillar.Parent = interior
	
	-- Create walls
	local wallPositions = {
		basePosition + Vector3.new(0, 10, 20),  -- Back wall
		basePosition + Vector3.new(0, 10, -20), -- Front wall
		basePosition + Vector3.new(20, 10, 0),  -- Right wall
		basePosition + Vector3.new(-20, 10, 0)  -- Left wall
	}
	
	local wallSizes = {
		Vector3.new(40, 20, 1),
		Vector3.new(40, 20, 1),
		Vector3.new(1, 20, 40),
		Vector3.new(1, 20, 40)
	}
	
	for i = 1, 4 do
		local wall = Instance.new("Part")
		wall.Name = "Wall_" .. i
		wall.Shape = Enum.PartType.Block
		wall.Size = wallSizes[i]
		wall.Position = wallPositions[i]
		wall.Color = Color3.fromRGB(200, 180, 160)
		wall.Material = Enum.Material.Brick
		wall.CanCollide = true
		wall.TopSurface = Enum.SurfaceType.Smooth
		wall.BottomSurface = Enum.SurfaceType.Smooth
		wall.Anchored = true -- ANCHOR
		wall.Parent = interior
	end
	
	-- Create ceiling
	local ceiling = Instance.new("Part")
	ceiling.Name = "Ceiling"
	ceiling.Shape = Enum.PartType.Block
	ceiling.Size = Vector3.new(40, 1, 40)
	ceiling.Position = basePosition + Vector3.new(0, 20, 0)
	ceiling.Color = Color3.fromRGB(220, 220, 220)
	ceiling.Material = Enum.Material.Brick
	ceiling.CanCollide = true
	ceiling.TopSurface = Enum.SurfaceType.Smooth
	ceiling.BottomSurface = Enum.SurfaceType.Smooth
	ceiling.Anchored = true -- ANCHOR
	ceiling.Parent = interior
	
	-- Create EXIT PORTAL (BLUE DOOR)
	local exitPortal = Instance.new("Part")
	exitPortal.Name = "ExitPortal"
	exitPortal.Shape = Enum.PartType.Block
	exitPortal.Size = Vector3.new(3, 4, 0.5)
	exitPortal.Position = basePosition + Vector3.new(0, 2, -20)
	exitPortal.Color = Color3.fromRGB(100, 200, 255)
	exitPortal.Material = Enum.Material.Neon
	exitPortal.CanCollide = false
	exitPortal.Transparency = 0.2
	exitPortal.Anchored = true -- ANCHOR
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
	labelText.Text = "🚪 EXIT"
	labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
	labelText.Parent = portalLabel
	
	print("🚪 Created EXIT PORTAL in " .. houseName .. " at position " .. tostring(basePosition))
	
	-- Exit portal touch detection
	exitPortal.Touched:Connect(function(hit)
		if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
			local player = Players:FindFirstChild(hit.Parent.Name)
			if player then
				print("🚪 " .. player.Name .. " touched exit portal")
				self:ExitHouse(player)
			end
		end
	end)
	
	-- Store interior in manager
	self.interiors[houseName] = {
		folder = interior,
		owner = owner,
		spawnPoint = basePosition + Vector3.new(0, 2, 0), -- Center of island
	}
	
	print("✅ Created interior for " .. houseName .. " at Y=" .. basePosition.Y .. " (Position: " .. tostring(basePosition) .. ")")
	return interior
end

-- Add white door to a house in the village
function HouseInteriorManager:AddDoorToHouse(house, houseName)
	if house:FindFirstChild("HouseDoor") then
		print("⚠️ Door already exists for " .. houseName)
		return
	end
	
	local door = Instance.new("Part")
	door.Name = "HouseDoor"
	door.Shape = Enum.PartType.Block
	door.Size = Vector3.new(2, 3, 0.3)
	door.Color = Color3.fromRGB(255, 255, 255)
	door.Material = Enum.Material.Wood
	door.CanCollide = true
	door.TopSurface = Enum.SurfaceType.Smooth
	door.BottomSurface = Enum.SurfaceType.Smooth
	door.Anchored = false -- Let it be part of house collision
	door.Position = house.Position + Vector3.new(0, 1.5, -3)
	door.Parent = house
	
	-- Add label
	local doorLabel = Instance.new("BillboardGui")
	doorLabel.Size = UDim2.new(3, 0, 1.5, 0)
	doorLabel.MaxDistance = 50
	doorLabel.Parent = door
	
	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(1, 0, 1, 0)
	labelText.BackgroundTransparency = 0.3
	labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	labelText.TextScaled = true
	labelText.Text = "🚪 ENTER"
	labelText.TextColor3 = Color3.fromRGB(0, 0, 0)
	labelText.Parent = doorLabel
	
	-- Handle door touch with debounce
	door.Touched:Connect(function(hit)
		if not hit.Parent or not hit.Parent:FindFirstChild("Humanoid") then
			return
		end
		
		local character = hit.Parent
		local player = Players:FindFirstChild(character.Name)
		
		if not player then return end
		
		-- Debounce: 2 second cooldown per player
		local key = player.UserId .. "_" .. houseName
		if self.doorCooldown[key] and (tick() - self.doorCooldown[key]) < 2 then
			return
		end
		self.doorCooldown[key] = tick()
		
		local ownerValue = house:FindFirstChild("Owner")
		local owner = ownerValue and ownerValue.Value or "Admin"
		
		print("🚪 " .. player.Name .. " (owner: " .. owner .. ") trying to enter " .. houseName)
		
		-- Allow owner and admin to enter
		if owner == player.Name or owner == "Admin" then
			self:EnterHouse(player, houseName)
		else
			print("🚫 Access denied")
		end
	end)
	
	-- Store door position
	self.houseDoors[houseName] = door.Position
	
	print("🚪 Added white door to " .. houseName)
end

-- Teleport player into house
function HouseInteriorManager:EnterHouse(player, houseName)
	-- Create interior if it doesn't exist yet
	if not self.interiors[houseName] then
		local house = workspace.Village:FindFirstChild(houseName)
		if not house then
			warn("House not found: " .. houseName)
			return false
		end
		
		local ownerValue = house:FindFirstChild("Owner")
		local owner = ownerValue and ownerValue.Value or "Admin"
		
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
	
	-- Teleport into house (spawn above floor)
	humanoidRootPart.CFrame = CFrame.new(houseData.spawnPoint + Vector3.new(0, 3, 0))
	
	-- Mark player as being in house
	self.playerHouses[player.UserId] = houseName
	player:SetAttribute("CurrentHouse", houseName)
	
	print("✅ " .. player.Name .. " entered " .. houseName)
	return true
end

-- Teleport player out of house
function HouseInteriorManager:ExitHouse(player)
	local character = player.Character
	if not character then return false end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return false end
	
	local houseName = player:GetAttribute("CurrentHouse")
	if houseName then
		local doorPos = self.houseDoors[houseName]
		if doorPos then
			humanoidRootPart.CFrame = CFrame.new(doorPos + Vector3.new(0, 0, 2))
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

print("✅ Created Interior RemoteEvents")

-- ============================================
-- REMOTE EVENT HANDLERS
-- ============================================

enterHouseEvent.OnServerEvent:Connect(function(player, houseName)
	print("🏠 " .. player.Name .. " requested entry to " .. houseName)
	HouseInteriorManager:EnterHouse(player, houseName)
end)

exitHouseEvent.OnServerEvent:Connect(function(player)
	print("🚪 " .. player.Name .. " requested exit")
	HouseInteriorManager:ExitHouse(player)
end)

-- ============================================
-- INITIALIZE HOUSE DOORS
-- ============================================
local function initializeHouseDoors()
	wait(2)
	
	local villageFolder = workspace:FindFirstChild("Village")
	if not villageFolder then
		warn("Village folder not found")
		return
	end
	
	print("🚪 Starting door initialization...")
	for _, house in pairs(villageFolder:GetChildren()) do
		if house.Name:match("^House_") then
			HouseInteriorManager:AddDoorToHouse(house, house.Name)
		end
	end
	
	print("🚪 House Door System Ready!")
end

initializeHouseDoors()

-- Handle new players
local function onPlayerAdded(player)
	local character = player.Character or player.CharacterAdded:Wait()
	
	player.CharacterAdded:Connect(function(newCharacter)
		HouseInteriorManager:ExitHouse(player)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	HouseInteriorManager.playerHouses[player.UserId] = nil
end)

print("🎉 House Interior System Ready!")