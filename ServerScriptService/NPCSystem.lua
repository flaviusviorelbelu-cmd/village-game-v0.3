-- NPC SYSTEM
-- Manages all NPCs in the village with dialogue, quests, and trading
print("🧑 Initializing NPC System...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Create RemoteEvents for NPC interactions
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

local interactNPCEvent = Instance.new("RemoteEvent")
interactNPCEvent.Name = "InteractNPC"
interactNPCEvent.Parent = remoteEventsFolder

local getDialogueEvent = Instance.new("RemoteEvent")
getDialogueEvent.Name = "GetDialogue"
getDialogueEvent.Parent = remoteEventsFolder

local tradeWithNPCEvent = Instance.new("RemoteEvent")
tradeWithNPCEvent.Name = "TradeWithNPC"
tradeWithNPCEvent.Parent = remoteEventsFolder

print("✅ Created NPC RemoteEvents")

-- ============================================
-- NPC MANAGER
-- ============================================
local NPCManager = {}
NPCManager.npcs = {} -- Store all NPCs
NPCManager.npcData = {} -- NPC metadata

-- Define NPC types and their properties
local NPC_TYPES = {
	MERCHANT = {
		name = "Merchant",
		color = Color3.fromRGB(200, 150, 50),
		emoji = "MERCHANT",
		roleSuffix = "the Merchant"
	},
	QUEST_GIVER = {
		name = "Quest Giver",
		color = Color3.fromRGB(100, 200, 100),
		emoji = "QUEST_GIVER",
		roleSuffix = "the Quest Giver"
	},
	BLACKSMITH = {
		name = "Blacksmith",
		color = Color3.fromRGB(150, 100, 100),
		emoji = "BLACKSMITH",
		roleSuffix = "the Blacksmith"
	},
	HEALER = {
		name = "Healer",
		color = Color3.fromRGB(200, 100, 200),
		emoji = "HEALER",
		roleSuffix = "the Healer"
	},
	BARTENDER = {
		name = "Bartender",
		color = Color3.fromRGB(100, 100, 200),
		emoji = "BARTENDER",
		roleSuffix = "the Bartender"
	}
}

-- NPC dialogue presets
local DIALOGUES = {
	MERCHANT = {
		greeting = "Welcome to my shop! Browse my wares or ask about my inventory.",
		trade = "What can I help you find today?",
		farewell = "Come back soon!"
	},
	QUEST_GIVER = {
		greeting = "Adventurer! I have important tasks for those brave enough to help.",
		trade = "Would you like to accept a quest?",
		farewell = "Return when you've completed the task!"
	},
	BLACKSMITH = {
		greeting = "*clinks hammer on anvil* Ah, a visitor! Need any repairs or upgrades?",
		trade = "I can upgrade your gear or repair broken items.",
		farewell = "Keep your equipment well-maintained!"
	},
	HEALER = {
		greeting = "Welcome. I sense you may need healing or herbs.",
		trade = "I have potions and remedies for all ailments.",
		farewell = "Stay healthy, friend."
	},
	BARTENDER = {
		greeting = "*slides drink across bar* What brings you in today?",
		trade = "First round's on the house if you share your stories!",
		farewell = "Come back for a drink soon!"
	}
}

-- Create a unique NPC in the village
function NPCManager:CreateNPC(npcConfig)
	local npcType = npcConfig.type or "MERCHANT"
	local typeData = NPC_TYPES[npcType]
	
	if not typeData then
		warn("Invalid NPC type: " .. tostring(npcType))
		return nil
	end
	
	local npcName = npcConfig.name or (npcConfig.customName or "Unknown")
	local position = npcConfig.position or Vector3.new(0, 3, 0)
	
	-- Create NPC model (simple humanoid)
	local npc = Instance.new("Model")
	npc.Name = npcName
	npc.PrimaryPart = nil -- Will be set to humanoidRootPart
	npc.Parent = workspace
	
	-- Create humanoid root part
	local humanoidRootPart = Instance.new("Part")
	humanoidRootPart.Name = "HumanoidRootPart"
	humanoidRootPart.Shape = Enum.PartType.Ball
	humanoidRootPart.Size = Vector3.new(2, 2, 1)
	humanoidRootPart.Position = position
	humanoidRootPart.CanCollide = true
	humanoidRootPart.Transparency = 0
	humanoidRootPart.Color = typeData.color
	humanoidRootPart.TopSurface = Enum.SurfaceType.Smooth
	humanoidRootPart.BottomSurface = Enum.SurfaceType.Smooth
	humanoidRootPart.Parent = npc
	
	-- Create humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = npc
	humanoid.Health = 100
	humanoid.MaxHealth = 100
	
	-- Set primary part
	npc.PrimaryPart = humanoidRootPart
	
	-- Add nameplate above NPC
	local nameplate = Instance.new("BillboardGui")
	nameplate.Size = UDim2.new(6, 0, 2, 0)
	nameplate.MaxDistance = 100
	nameplate.Parent = humanoidRootPart
	
	local nameText = Instance.new("TextLabel")
	nameText.Size = UDim2.new(1, 0, 0.5, 0)
	nameText.BackgroundTransparency = 0.3
	nameText.BackgroundColor3 = typeData.color
	nameText.TextScaled = true
	nameText.Text = npcName
	nameText.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameText.Font = Enum.Font.GothamBold
	nameText.Parent = nameplate
	
	local roleText = Instance.new("TextLabel")
	roleText.Size = UDim2.new(1, 0, 0.5, 0)
	roleText.Position = UDim2.new(0, 0, 0.5, 0)
	roleText.BackgroundTransparency = 1
	roleText.TextScaled = true
	roleText.Text = typeData.roleSuffix
	roleText.TextColor3 = Color3.fromRGB(200, 200, 200)
	roleText.Font = Enum.Font.Gotham
	roleText.Parent = nameplate
	
	-- Add interaction prompt
	local promptGui = Instance.new("BillboardGui")
	prompGui.Size = UDim2.new(4, 0, 1.5, 0)
	prompGui.MaxDistance = 50
	prompGui.Position = UDim2.new(0, 0, -1.5, 0)
	prompGui.Parent = humanoidRootPart
	
	local promptText = Instance.new("TextLabel")
	prompText.Size = UDim2.new(1, 0, 1, 0)
	prompText.BackgroundTransparency = 0.5
	prompText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	prompText.TextScaled = true
	prompText.Text = "[E] Interact"
	prompText.TextColor3 = Color3.fromRGB(100, 255, 100)
	prompText.Font = Enum.Font.GothamBold
	prompText.Parent = promptGui
	
	-- Store NPC data
	self.npcs[npcName] = npc
	self.npcData[npcName] = {
		type = npcType,
		typeData = typeData,
		position = position,
		inventory = npcConfig.inventory or {},
		quests = npcConfig.quests or {},
		dialogue = DIALOGUES[npcType] or DIALOGUES.MERCHANT,
		tradeValue = npcConfig.tradeValue or 1.0,
		humanoid = humanoid
	}
	
	-- Make NPC clickable for interaction
	humanoidRootPart.Touched:Connect(function(hit)
		if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
			local player = Players:FindFirstChild(hit.Parent.Name)
			if player then
				-- Handled by client interaction
			end
		end
	end)
	
	print("🧑 Created NPC: " .. npcName .. " at " .. tostring(position))
	return npc
end

-- Get NPC dialogue
function NPCManager:GetDialogue(npcName, dialogueType)
	local npcData = self.npcData[npcName]
	if not npcData then return "Hello there!" end
	
	local dialogue = npcData.dialogue[dialogueType] or "Hello!"
	return dialogue
end

-- Trade with NPC
function NPCManager:TradeWithNPC(player, npcName, itemGiven, quantityGiven)
	local npcData = self.npcData[npcName]
	if not npcData then
		return false, "NPC not found"
	end
	
	-- Calculate trade value
	local baseValue = quantityGiven * 10 -- Base: 10 currency per item
	local finalValue = math.floor(baseValue * npcData.tradeValue)
	
	print("💰 " .. player.Name .. " traded with " .. npcName .. ": " .. quantityGiven .. "x " .. itemGiven .. " for " .. finalValue .. " currency")
	return true, finalValue
end

-- Initialize village NPCs
local function initializeVillageNPCs()
	wait(3) -- Wait for village to load
	
	print("🧑 Initializing Village NPCs...")
	
	-- Merchant near the market
	NPCManager:CreateNPC({
		type = "MERCHANT",
		customName = "Elara",
		position = Vector3.new(50, 3, 0),
		inventory = {"Bread", "Fish", "Herbs", "Tools"},
		tradeValue = 1.0
	})
	
	-- Quest Giver at town center
	NPCManager:CreateNPC({
		type = "QUEST_GIVER",
		customName = "Marcus",
		position = Vector3.new(0, 3, -50),
		quests = {"Collect 5 herbs", "Deliver letters", "Scout the forest"},
		tradeValue = 1.2
	})
	
	-- Blacksmith (for upgrades)
	NPCManager:CreateNPC({
		type = "BLACKSMITH",
		customName = "Gareth",
		position = Vector3.new(-50, 3, 50),
		inventory = {"Iron Ore", "Tools", "Weapons"},
		tradeValue = 1.3
	})
	
	-- Healer (for potions)
	NPCManager:CreateNPC({
		type = "HEALER",
		customName = "Lydia",
		position = Vector3.new(50, 3, 50),
		inventory = {"Health Potion", "Mana Potion", "Antidote"},
		tradeValue = 1.4
	})
	
	-- Bartender (for information)
	NPCManager:CreateNPC({
		type = "BARTENDER",
		customName = "Bronn",
		position = Vector3.new(-50, 3, -50),
		inventory = {"Ale", "Wine", "Cider"},
		tradeValue = 1.0
	})
	
	print("✅ Village NPCs initialized (5 NPCs created)")
end

-- ============================================
-- REMOTE EVENT HANDLERS
-- ============================================

interactNPCEvent.OnServerEvent:Connect(function(player, npcName)
	print("🧑 " .. player.Name .. " is interacting with " .. npcName)
	-- Trigger dialogue and UI on client
end)

getDialogueEvent.OnServerEvent:Connect(function(player, npcName, dialogueType)
	local dialogue = NPCManager:GetDialogue(npcName, dialogueType)
	getDialogueEvent:FireClient(player, npcName, dialogue)
end)

tradeWithNPCEvent.OnServerEvent:Connect(function(player, npcName, itemGiven, quantity)
	local success, value = NPCManager:TradeWithNPC(player, npcName, itemGiven, quantity)
	if success then
		-- Add currency to player (handled by economy system)
		tradeWithNPCEvent:FireClient(player, success, value)
	end
end)

initializeVillageNPCs()

print("✅ NPC System Ready!")
