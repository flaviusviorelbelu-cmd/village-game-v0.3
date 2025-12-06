-- INTERIOR UI CLIENT SCRIPT
-- Handles UI for entering houses and placing furniture
print("🏠 Initializing Interior UI...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEventsFolder then
	warn("❌ RemoteEvents not found!")
	return
end

local enterHouseEvent = remoteEventsFolder:WaitForChild("EnterHouse")
local exitHouseEvent = remoteEventsFolder:WaitForChild("ExitHouse")
local placeFurnitureEvent = remoteEventsFolder:WaitForChild("PlaceFurniture")
local removeFurnitureEvent = remoteEventsFolder:WaitForChild("RemoveFurniture")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ============================================
-- CREATE INTERIOR UI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InteriorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Interior UI Panel (initially hidden)
local interiorPanel = Instance.new("Frame")
interiorPanel.Name = "InteriorPanel"
interiorPanel.Size = UDim2.new(0.3, 0, 0.8, 0)
interiorPanel.Position = UDim2.new(0.02, 0, 0.1, 0)
interiorPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
interiorPanel.BorderSizePixel = 0
interiorPanel.Visible = false
interiorPanel.Parent = screenGui

-- Add corner radius via UICorner
local cornerRadius = Instance.new("UICorner")
cornerRadius.CornerRadius = UDim.new(0, 8)
cornerRadius.Parent = interiorPanel

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "🏠 House Interior"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = interiorPanel

-- Furniture Catalog Label
local catalogLabel = Instance.new("TextLabel")
catalogLabel.Name = "CatalogLabel"
catalogLabel.Size = UDim2.new(1, -10, 0.08, 0)
catalogLabel.Position = UDim2.new(0, 5, 0.12, 0)
catalogLabel.BackgroundTransparency = 1
catalogLabel.BorderSizePixel = 0
catalogLabel.Text = "🛋️ Furniture Catalog"
catalogLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
catalogLabel.TextSize = 14
catalogLabel.Font = Enum.Font.GothamBold
catalogLabel.TextXAlignment = Enum.TextXAlignment.Left
catalogLabel.Parent = interiorPanel

-- Furniture List (ScrollingFrame)
local furnitureList = Instance.new("ScrollingFrame")
furnitureList.Name = "FurnitureList"
furnitureList.Size = UDim2.new(1, -10, 0.7, 0)
furnitureList.Position = UDim2.new(0, 5, 0.22, 0)
furnitureList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
furnitureList.BorderColor3 = Color3.fromRGB(60, 60, 60)
furnitureList.BorderSizePixel = 1
furnitureList.ScrollBarThickness = 6
furnitureList.CanvasSize = UDim2.new(1, 0, 0, 0)
furnitureList.Parent = interiorPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = furnitureList

listLayout.Changed:Connect(function()
	furnitureList.CanvasSize = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

-- Exit Button
local exitButton = Instance.new("TextButton")
exitButton.Name = "ExitButton"
exitButton.Size = UDim2.new(1, -10, 0.08, 0)
exitButton.Position = UDim2.new(0, 5, 0.94, 0)
exitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
exitButton.BorderSizePixel = 0
exitButton.Text = "🚪 Exit House"
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.TextSize = 14
exitButton.Font = Enum.Font.GothamBold
exitButton.Parent = interiorPanel

-- ============================================
-- FURNITURE ITEM TEMPLATE
-- ============================================
local function createFurnitureButton(furnitureId, furnitureName, price)
	local button = Instance.new("TextButton")
	button.Name = furnitureId
	button.Size = UDim2.new(1, -4, 0, 50)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.BorderColor3 = Color3.fromRGB(100, 150, 200)
	button.BorderSizePixel = 1
	button.Text = furnitureName .. " - " .. tostring(price) .. " 💰"
	button.TextColor3 = Color3.fromRGB(200, 200, 200)
	button.TextSize = 12
	button.Font = Enum.Font.Gotham
	button.Parent = furnitureList
	
	button.MouseButton1Click:Connect(function()
		print("🛋️ Selected " .. furnitureName)
		-- Show placement guide
		local infoLabel = Instance.new("TextLabel")
		infoLabel.Name = "PlacementInfo"
		infoLabel.Size = UDim2.new(1, 0, 0.06, 0)
		infoLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		infoLabel.BorderSizePixel = 0
		infoLabel.Text = "🔍 Click in the room to place this furniture!"
		infoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		infoLabel.TextSize = 12
		infoLabel.Font = Enum.Font.Gotham
		
		-- Remove old info label if exists
		local oldInfo = interiorPanel:FindFirstChild("PlacementInfo")
		if oldInfo then oldInfo:Destroy() end
		
		infoLabel.Parent = interiorPanel
		infoLabel.Position = UDim2.new(0, 0, 0.88, 0)
	end)
	
	return button
end

-- ============================================
-- POPULATE FURNITURE CATALOG
-- ============================================
local function populateFurnitureCatalog()
	-- This data mirrors the server-side catalog
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
		createFurnitureButton(item.id, item.name, item.price)
	end
end

populateFurnitureCatalog()

-- ============================================
-- DETECT HOUSE CLICKS & ENTER
-- ============================================
local function setupHouseClickDetection()
	print("🔍 Setting up house click detection...")
	
	for _, house in pairs(workspace.Village:GetChildren()) do
		if house.Name:match("^House_") and house:FindFirstChild("ClickDetector") then
			local originalMouseClick = house.ClickDetector.MouseClick
			
			-- Override with custom handling
			local touchConnection
			touchConnection = house.Touched:Connect(function(hit)
				if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
					if hit.Parent.Parent:IsDescendantOf(player.Character) then
						-- Player is touching the house
						-- Show enter button
					end
				end
			end)
		end
	end
end

wait(1) -- Wait for village to load
setupHouseClickDetection()

-- ============================================
-- KEYBOARD SHORTCUTS
-- ============================================
local interiorOpen = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Press 'I' to open interior UI
	if input.KeyCode == Enum.KeyCode.I then
		local currentHouse = player:GetAttribute("CurrentHouse")
		if currentHouse then
			interiorOpen = not interiorOpen
			interiorPanel.Visible = interiorOpen
			print(interiorOpen and "🏠 Interior UI opened" or "🏠 Interior UI closed")
		end
	end
	-- Press 'E' to enter a nearby house
	elseif input.KeyCode == Enum.KeyCode.E then
		print("🧐 Looking for nearby houses...")
		-- Check for nearby houses
		for _, house in pairs(workspace.Village:GetChildren()) do
			if house.Name:match("^House_") then
				local distance = (house.Position - humanoidRootPart.Position).Magnitude
				if distance < 20 then
					print("💫 Entering " .. house.Name .. " (distance: " .. tostring(math.floor(distance)) .. ")")
					enterHouseEvent:FireServer(house.Name)
					interiorOpen = true
					interiorPanel.Visible = true
					break
			end
			end
		end
	end
end)

-- ============================================
-- EXIT BUTTON HANDLER
-- ============================================
exitButton.MouseButton1Click:Connect(function()
	print("🚪 Exiting house...")
	exitHouseEvent:FireServer()
	interiorOpen = false
	interiorPanel.Visible = false
end)

-- ============================================
-- PLACE FURNITURE ON MOUSE CLICK (WHEN IN HOUSE)
-- ============================================
local selectedFurniture = nil

for _, button in pairs(furnitureList:GetChildren()) do
	if button:IsA("TextButton") then
		button.MouseButton1Click:Connect(function()
			selectedFurniture = button.Name -- Store furniture ID
			print("✍️ Furniture selected for placement: " .. selectedFurniture)
		end)
	end
end

-- Listen for mouse clicks in the interior
local UserInputService = game:GetService("UserInputService")
local Mouse = player:GetMouse()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not selectedFurniture then return end
	
	local currentHouse = player:GetAttribute("CurrentHouse")
	if not currentHouse then return end
	
	-- Right click to place furniture
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		local targetPos = Mouse.Hit.Position + Vector3.new(0, 1, 0)
		print("💫 Placing furniture at " .. tostring(targetPos))
		placeFurnitureEvent:FireServer(selectedFurniture, targetPos)
		selectedFurniture = nil
	end
end)

print("✅ Interior UI Ready!")
print("🕜 Controls:")
print("  E - Enter nearby house")
print("  I - Open/close interior UI")
print("  Right Click - Place selected furniture")