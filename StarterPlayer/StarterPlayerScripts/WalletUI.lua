-- WALLET & NPC INTERACTION UI (Client)
-- Displays player wallet and manages NPC interactions
print("💰 Initializing Wallet UI...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Get RemoteEvents
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local updateCurrencyEvent = remoteEventsFolder:WaitForChild("UpdateCurrency")
local getCurrencyEvent = remoteEventsFolder:WaitForChild("GetCurrency")
local interactNPCEvent = remoteEventsFolder:WaitForChild("InteractNPC")
local getDialogueEvent = remoteEventsFolder:WaitForChild("GetDialogue")

local playerGui = player:WaitForChild("PlayerGui")

-- Create Wallet UI
local walletGui = Instance.new("ScreenGui")
walletGui.Name = "WalletGui"
walletGui.ResetOnSpawn = false
walletGui.Parent = playerGui

-- Wallet Frame (Top right corner)
local walletFrame = Instance.new("Frame")
walletFrame.Name = "WalletFrame"
walletFrame.Size = UDim2.new(0, 300, 0, 120)
walletFrame.Position = UDim2.new(1, -320, 0, 20)
walletFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
walletFrame.BorderSizePixel = 0
walletFrame.BackgroundTransparency = 0.2
walletFrame.Parent = walletGui

-- Add rounded corners effect
local walletCorner = Instance.new("UICorner")
walletCorner.CornerRadius = UDim.new(0, 12)
walletCorner.Parent = walletFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.TextScaled = true
titleLabel.Text = "💰 Wallet"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = walletFrame

-- Gold display
local goldLabel = Instance.new("TextLabel")
goldLabel.Name = "Gold"
goldLabel.Size = UDim2.new(1, -20, 0, 25)
goldLabel.Position = UDim2.new(0, 10, 0, 35)
goldLabel.BackgroundTransparency = 1
goldLabel.TextScaled = true
goldLabel.TextXAlignment = Enum.TextXAlignment.Left
goldLabel.Text = "🟡 Gold: 0"
goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
goldLabel.Font = Enum.Font.Gotham
goldLabel.Parent = walletFrame

-- Silver display
local silverLabel = Instance.new("TextLabel")
silverLabel.Name = "Silver"
silverLabel.Size = UDim2.new(1, -20, 0, 25)
silverLabel.Position = UDim2.new(0, 10, 0, 60)
silverLabel.BackgroundTransparency = 1
silverLabel.TextScaled = true
silverLabel.TextXAlignment = Enum.TextXAlignment.Left
silverLabel.Text = "🔘 Silver: 0"
silverLabel.TextColor3 = Color3.fromRGB(192, 192, 192)
silverLabel.Font = Enum.Font.Gotham
silverLabel.Parent = walletFrame

-- Gems display
local gemsLabel = Instance.new("TextLabel")
gemsLabel.Name = "Gems"
gemsLabel.Size = UDim2.new(1, -20, 0, 25)
gemsLabel.Position = UDim2.new(0, 10, 0, 85)
gemsLabel.BackgroundTransparency = 1
gemsLabel.TextScaled = true
gemsLabel.TextXAlignment = Enum.TextXAlignment.Left
gemsLabel.Text = "💎 Gems: 0"
gemsLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
gemsLabel.Font = Enum.Font.Gotham
gemsLabel.Parent = walletFrame

-- Create NPC Interaction Dialog
local dialogueGui = Instance.new("ScreenGui")
dialogueGui.Name = "DialogueGui"
dialogueGui.ResetOnSpawn = false
dialogueGui.Parent = playerGui

-- Dialogue Frame (Bottom center)
local dialogueFrame = Instance.new("Frame")
dialogueFrame.Name = "DialogueFrame"
dialogueFrame.Size = UDim2.new(0, 500, 0, 150)
dialogueFrame.Position = UDim2.new(0.5, -250, 1, -170)
dialogueFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
dialogueFrame.BorderSizePixel = 0
dialogueFrame.BackgroundTransparency = 0.15
dialogueFrame.Visible = false
dialogueFrame.Parent = dialogueGui

-- Dialogue corner
local dialogueCorner = Instance.new("UICorner")
dialogueCorner.CornerRadius = UDim.new(0, 12)
dialogueCorner.Parent = dialogueFrame

-- NPC Name
local npcNameLabel = Instance.new("TextLabel")
npcNameLabel.Name = "NPCName"
npcNameLabel.Size = UDim2.new(1, -20, 0, 30)
npcNameLabel.Position = UDim2.new(0, 10, 0, 10)
npcNameLabel.BackgroundTransparency = 1
npcNameLabel.TextScaled = true
npcNameLabel.TextXAlignment = Enum.TextXAlignment.Left
npcNameLabel.Text = "NPC Name"
npcNameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
npcNameLabel.Font = Enum.Font.GothamBold
npcNameLabel.Parent = dialogueFrame

-- Dialogue text
local dialogueText = Instance.new("TextLabel")
dialogueText.Name = "Text"
dialogueText.Size = UDim2.new(1, -20, 0, 80)
dialogueText.Position = UDim2.new(0, 10, 0, 45)
dialogueText.BackgroundTransparency = 1
dialogueText.TextScaled = true
dialogueText.TextWrapped = true
dialogueText.TextXAlignment = Enum.TextXAlignment.Left
dialogueText.TextYAlignment = Enum.TextYAlignment.Top
dialogueText.Text = "Greetings, traveler!"
dialogueText.TextColor3 = Color3.fromRGB(220, 220, 220)
dialogueText.Font = Enum.Font.Gotham
dialogueText.Parent = dialogueFrame

print("✅ Wallet UI Created")

-- ============================================
-- FUNCTIONS
-- ============================================

local function updateWalletDisplay(balance)
	if not balance then return end
	
	goldLabel.Text = "🟡 Gold: " .. tostring(balance.gold or 0)
	silverLabel.Text = "🔘 Silver: " .. tostring(balance.silver or 0)
	gemsLabel.Text = "💎 Gems: " .. tostring(balance.gems or 0)
end

local function showNPCDialogue(npcName, dialogue)
	npcNameLabel.Text = npcName
	dialogueText.Text = dialogue
	dialogueFrame.Visible = true
	
	-- Auto-hide after 5 seconds
	game:GetService("Debris"):AddItem(Instance.new("Part"), 5)
	wait(5)
	dialogueFrame.Visible = false
end

-- ============================================
-- EVENT HANDLERS
-- ============================================

-- Update wallet when currency changes
updateCurrencyEvent.OnClientEvent:Connect(function(balance)
	updateWalletDisplay(balance)
end)

-- Dialogue received from NPC
getDialogueEvent.OnClientEvent:Connect(function(npcName, dialogue)
	showNPCDialogue(npcName, dialogue)
end)

-- Get initial balance
getCurrencyEvent:FireServer()

-- ============================================
-- NPC INTERACTION (Raycasting)
-- ============================================

local function getNPCInFront(distance)
	distance = distance or 50
	local character = player.Character
	if not character then return nil end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end
	
	local rayOrigin = humanoidRootPart.Position
	local rayDirection = humanoidRootPart.CFrame.LookVector * distance
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {character}
	
	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	
	if result then
		local hitModel = result.Instance.Parent
		if hitModel and hitModel:FindFirstChild("Humanoid") then
			return hitModel
		end
	end
	
	return nil
end

-- Handle NPC interaction with E key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		local npc = getNPCInFront(30)
		if npc then
			local npcName = npc.Name
			print("Interacting with: " .. npcName)
			
			-- Send interaction event to server
			interactNPCEvent:FireServer(npcName)
			
			-- Request dialogue
			getDialogueEvent:FireServer(npcName, "greeting")
		end
	end
end)

print("✅ Wallet UI System Ready!")
