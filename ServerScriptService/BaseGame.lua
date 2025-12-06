-- BASE GAME SETUP
-- Creates the base world with lighting and ground
print("🌟 Initializing Base Game Setup...")

local Lighting = game:GetService("Lighting")

-- Setup lighting
Lighting.Ambient = Color3.fromRGB(200, 200, 200)
Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
Lighting.Brightness = 1

-- NOTE: Baseplate is now created by GameManager (roads)
-- Removed grass baseplate to prevent flickering with road textures
print("✅ Baseplate managed by GameManager (roads)")

-- Create bedrock layer FAR BELOW (not visible, just safety net)
local bedrockFolder = Instance.new("Folder")
bedrockFolder.Name = "BedrockLayer"
bedrockFolder.Parent = workspace

local bedrock = Instance.new("Part")
bedrock.Name = "Bedrock"
bedrock.Shape = Enum.PartType.Block
bedrock.Size = Vector3.new(1000, 5, 1000)
bedrock.Position = Vector3.new(250, -100, 250)  -- MOVED TO Y=-100 (below everything)
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
