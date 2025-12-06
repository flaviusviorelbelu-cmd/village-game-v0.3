-- BASE GAME SETUP
-- Creates the base world with lighting and ground
print("🌟 Initializing Base Game Setup...")

local Lighting = game:GetService("Lighting")

-- Setup lighting
Lighting.Ambient = Color3.fromRGB(200, 200, 200)
Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
Lighting.Brightness = 1

-- Create main baseplate (village area) - SMALLER SIZE to not block roads
local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Shape = Enum.PartType.Block
baseplate.Size = Vector3.new(256, 0.5, 256)  -- Smaller than village area
baseplate.Position = Vector3.new(0, 0, 0)
baseplate.Color = Color3.fromRGB(0, 180, 0)
baseplate.Material = Enum.Material.Grass
baseplate.CanCollide = true
baseplate.TopSurface = Enum.SurfaceType.Smooth
baseplate.BottomSurface = Enum.SurfaceType.Smooth
baseplate.Anchored = true
baseplate.Parent = workspace

print("✅ Created main baseplate (village ground) - 256x256")

-- Create second island below main island (same dimensions)
local secondIsland = Instance.new("Part")
secondIsland.Name = "SecondIsland"
secondIsland.Shape = Enum.PartType.Block
secondIsland.Size = Vector3.new(256, 0.5, 256)  -- Same size as main baseplate
secondIsland.Position = Vector3.new(0, -50, 0)  -- Below main island
secondIsland.Color = Color3.fromRGB(120, 80, 40)  -- Different color (stone/brown)
secondIsland.Material = Enum.Material.Rock
secondIsland.CanCollide = true
secondIsland.TopSurface = Enum.SurfaceType.Smooth
secondIsland.BottomSurface = Enum.SurfaceType.Smooth
secondIsland.Anchored = true
secondIsland.Parent = workspace

print("✅ Created second island below main island at Y=-50")

-- Create bedrock layer FAR BELOW (not visible, just safety net)
local bedrockFolder = Instance.new("Folder")
bedrockFolder.Name = "BedrockLayer"
bedrockFolder.Parent = workspace

local bedrock = Instance.new("Part")
bedrock.Name = "Bedrock"
bedrock.Shape = Enum.PartType.Block
bedrock.Size = Vector3.new(1000, 5, 1000)
bedrock.Position = Vector3.new(250, -100, 250)  -- Below everything
bedrock.Color = Color3.fromRGB(50, 50, 50)
bedrock.Material = Enum.Material.Concrete
bedrock.CanCollide = true
bedrock.TopSurface = Enum.SurfaceType.Smooth
bedrock.BottomSurface = Enum.SurfaceType.Smooth
bedrock.Anchored = true
bedrock.Parent = bedrockFolder

print("🗑️ Created bedrock safety layer at Y=-100 (underground)")

-- Remove default sky to avoid blocking
if Lighting:FindFirstChildOfClass("Sky") then
	Lighting:FindFirstChildOfClass("Sky"):Destroy()
end

print("✅ Base Game Setup Complete!")
