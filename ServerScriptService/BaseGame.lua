-- BASE GAME SETUP
-- Creates the base world with lighting and ground
print("🌟 Initializing Base Game Setup...")

local Lighting = game:GetService("Lighting")

-- Setup lighting
Lighting.Ambient = Color3.fromRGB(200, 200, 200)
Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
Lighting.Brightness = 1

-- Create main baseplate (village area)
local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Shape = Enum.PartType.Block
baseplate.Size = Vector3.new(512, 1, 512)
baseplate.Position = Vector3.new(0, 0, 0)
baseplate.Color = Color3.fromRGB(0, 180, 0)
baseplate.Material = Enum.Material.Grass
baseplate.CanCollide = true
baseplate.TopSurface = Enum.SurfaceType.Smooth
baseplate.BottomSurface = Enum.SurfaceType.Smooth
baseplate.Anchored = true
baseplate.Parent = workspace

print("✅ Created main baseplate (village ground)")

-- Create sky (optional)
local sky = Instance.new("Sky")
sky.Parent = Lighting

print("✅ Base Game Setup Complete!")
