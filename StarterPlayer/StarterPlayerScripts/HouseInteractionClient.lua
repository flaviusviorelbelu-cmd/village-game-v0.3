-- HOUSE INTERACTION CLIENT SCRIPT
-- Handles entering/exiting houses and furniture placement
print("🏠 Initializing House Interaction Client...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetMouse()

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Wait for RemoteEvents
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEventsFolder then
	warn("❌ RemoteEvents folder not found!")
	return
end

local enterHouseEvent = remoteEventsFolder:WaitForChild("EnterHouse")
local exitHouseEvent = remoteEventsFolder:WaitForChild("ExitHouse")
local placeFurnitureEvent = remoteEventsFolder:WaitForChild("PlaceFurniture")
local removeFurnitureEvent = remoteEventsFolder:WaitForChild("RemoveFurniture")

print("✅ Connected to RemoteEvents")

-- ============================================
-- HOUSE INTERACTION UI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HouseInteractionUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Prompt label (shows when near house)
local promptLabel = Instance.new("TextLabel")
promptLabel.Name = "PromptLabel"
promptLabel.Size = UDim2.new(0.3, 0, 0.08, 0)
promptLabel.Position = UDim2.new(0.35, 0, 0.85, 0)
promptLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
promptLabel.BackgroundTransparency = 0.3
promptLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
promptLabel.TextSize = 16
promptLabel.Font = Enum.Font.GothamBold
promptLabel.Text = "✅ Press E to enter house"
promptLabel.Visible = false
promptLabel.Parent = screenGui

-- Add UICorner for rounded look
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = promptLabel

-- Exit button (shown when inside house)
local exitPanel = Instance.new("TextButton")
exitPanel.Name = "ExitPanel"
exitPanel.Size = UDim2.new(0.15, 0, 0.06, 0)
exitPanel.Position = UDim2.new(0.425, 0, 0.05, 0)
exitPanel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
exitPanel.TextColor3 = Color3.fromRGB(255, 255, 255)
exitPanel.TextSize = 14
exitPanel.Font = Enum.Font.GothamBold
exitPanel.Text = "🚪 Exit (E)"
exitPanel.Visible = false
exitPanel.Parent = screenGui

local exitCorner = Instance.new("UICorner")
exitCorner.CornerRadius = UDim.new(0, 6)
exitCorner.Parent = exitPanel

-- Furniture list (shown when inside house)
local furniturePanel = Instance.new("Frame")
furniturePanel.Name = "FurniturePanel"
furniturePanel.Size = UDim2.new(0.2, 0, 0.6, 0)
furniturePanel.Position = UDim2.new(0.02, 0, 0.2, 0)
furniturePanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
furniturePanel.Visible = false
furniturePanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = furniturePanel

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "🛋️ Furniture"
titleLabel.Parent = furniturePanel

-- Furniture list scroll
local furnitureList = Instance.new("ScrollingFrame")
furnitureList.Name = "FurnitureList"
furnitureList.Size = UDim2.new(1, 0, 0.9, 0)
furnitureList.Position = UDim2.new(0, 0, 0.1, 0)
furnitureList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
furnitureList.ScrollBarThickness = 4
furnitureList.CanvasSize = UDim2.new(1, 0, 0, 0)
furnitureList.Parent = furniturePanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = furnitureList

listLayout.Changed:Connect(function()
	furnitureList.CanvasSize = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

-- ============================================
-- HOUSE DETECTION
-- ============================================
local nearbyHouse = nil
local isInHouse = false
local selectedFurniture = nil

local function checkNearbyHouses()
	local villageFolder = workspace:FindFirstChild("Village")
	if not villageFolder then return end
	
	nearbyHouse = nil
	local closestDistance = 15
	
	for _, house in pairs(villageFolder:GetChildren()) do
		if house.Name:match("^House_") then
			local distance = (house.Position - humanoidRootPart.Position).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				nearbyHouse = house
			end
		end
	end
	
	-- Show/hide prompt
	if nearbyHouse and not isInHouse then
		promptLabel.Visible = true
		promptLabel.Text = "✅ Press E to enter " .. nearbyHouse.Name
	else
		promptLabel.Visible = false
	end
end

-- ============================================
-- INPUT HANDLING
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Press E to enter/exit house
	if input.KeyCode == Enum.KeyCode.E then
		if isInHouse then
			-- Exit house
			print("🚪 Exiting house...")
			exitHouseEvent:FireServer()
			isInHouse = false
			exitPanel.Visible = false
			furniturePanel.Visible = false
			selectedFurniture = nil
		elseif nearbyHouse then
			-- Enter house
			local ownerValue = nearbyHouse:FindFirstChild("Owner")
			local owner = ownerValue and ownerValue.Value or "Admin"
			
			-- Only house owner can fully enter
			if owner == player.Name or owner == "Admin" then
				print("🏠 Entering " .. nearbyHouse.Name .. "...")
				enterHouseEvent:FireServer(nearbyHouse.Name)
				isInHouse = true
				exitPanel.Visible = true
				furniturePanel.Visible = true
				updateFurnitureList()
			else
				print("❌ You don't own this house!")
			end
		end
	end
end)

-- Click to place furniture
Mouse.Button2Down:Connect(function()
	if isInHouse and selectedFurniture then
		local targetPos = Mouse.Hit.Position
		print("💫 Placing " .. selectedFurniture .. " at " .. tostring(targetPos))
		placeFurnitureEvent:FireServer(selectedFurniture, targetPos)
		selectedFurniture = nil
		
		-- Clear highlight
		for _, button in pairs(furnitureList:GetChildren()) do
			if button:IsA("TextButton") then
				button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			end
		end
	end
end)

-- ============================================
-- FURNITURE CATALOG
-- ============================================
local function updateFurnitureList()
	-- Clear old buttons
	for _, child in pairs(furnitureList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	local furniture = {
		{id = "bed_basic", name = "🛏️ Basic Bed", price = 100},
		{id = "bed_luxury", name = "👑 Luxury Bed", price = 500},
		{id = "chair_wood", name = "🪑 Wooden Chair", price = 50},
		{id = "chair_leather", name = "🪑 Leather Chair", price = 150},
		{id = "table_wood", name = "🪑 Wooden Table", price = 150},
		{id = "table_glass", name = "✨ Glass Table", price = 300},
		{id = "lamp", name = "💡 Lamp", price = 75},
		{id = "bookshelf", name = "📚 Bookshelf", price = 200},
		{id = "plant", name = "🌱 Plant", price = 60},
		{id = "painting", name = "🎨 Painting", price = 120},
		{id = "rug", name = "🧵 Rug", price = 80},
	}
	
	for _, item in ipairs(furniture) do
		local button = Instance.new("TextButton")
		button.Name = item.id
		button.Size = UDim2.new(1, -4, 0, 40)
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		button.TextColor3 = Color3.fromRGB(200, 200, 200)
		button.TextSize = 11
		button.Font = Enum.Font.Gotham
		button.Text = item.name .. " (" .. item.price .. ")"
		button.Parent = furnitureList
		
		button.MouseButton1Click:Connect(function()
			selectedFurniture = item.id
			
			-- Highlight selected
			for _, btn in pairs(furnitureList:GetChildren()) do
				if btn:IsA("TextButton") then
					btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				end
			end
			button.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
			
			print("✍️ Selected: " .. item.name .. " - Right click to place")
		end)
	end
end

-- ============================================
-- PERIODIC UPDATES
-- ============================================
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	if not isInHouse then
		checkNearbyHouses()
	end
	
	-- Update character reference
	if player.Character and not character or character.Parent == nil then
		character = player.Character
		humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	end
end)

-- Exit house on character died
player.CharacterAdded:Connect(function(newCharacter)
	isInHouse = false
	exitPanel.Visible = false
	furniturePanel.Visible = false
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("✅ House Interaction Client Ready!")
print("🕜 Controls:")
print("  E - Enter/exit nearby house")
print("  Right Click - Place selected furniture")