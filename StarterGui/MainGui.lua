-- MAIN GUI WITH HOUSE PURCHASE SYSTEM
print("?? Main GUI with Houses starting...")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
wait(0.5)
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local updateCurrencyEvent = remoteEventsFolder:WaitForChild("UpdateCurrency")
local showMessageEvent = remoteEventsFolder:WaitForChild("ShowMessage")
local showShopEvent = remoteEventsFolder:WaitForChild("ShowShop")
local buyEvent = remoteEventsFolder:WaitForChild("BuyItem")
local showHousePurchaseEvent = remoteEventsFolder:WaitForChild("ShowHousePurchase")
local buyHouseEvent = remoteEventsFolder:WaitForChild("BuyHouse")
-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VillageGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
-- Currency Display
local currencyFrame = Instance.new("Frame")
currencyFrame.Size = UDim2.new(0, 200, 0, 50)
currencyFrame.Position = UDim2.new(0, 10, 0, 10)
currencyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
currencyFrame.Parent = screenGui
local currencyLabel = Instance.new("TextLabel")
currencyLabel.Size = UDim2.new(1, 0, 1, 0)
currencyLabel.BackgroundTransparency = 1
currencyLabel.Text = "?? Coins: 3000"
currencyLabel.TextColor3 = Color3.new(1, 1, 1)
currencyLabel.TextSize = 20
currencyLabel.Font = Enum.Font.GothamBold
currencyLabel.Parent = currencyFrame
-- Level Display
local levelFrame = Instance.new("Frame")
levelFrame.Size = UDim2.new(0, 200, 0, 50)
levelFrame.Position = UDim2.new(0, 220, 0, 10)
levelFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
levelFrame.Parent = screenGui
local levelLabel = Instance.new("TextLabel")
levelLabel.Size = UDim2.new(1, 0, 1, 0)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "? Level: 1"
levelLabel.TextColor3 = Color3.new(1, 1, 1)
levelLabel.TextSize = 20
levelLabel.Font = Enum.Font.GothamBold
levelLabel.Parent = levelFrame
-- Shop Frame
local shopFrame = Instance.new("Frame")
shopFrame.Size = UDim2.new(0, 600, 0, 400)
shopFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
shopFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
shopFrame.Visible = false
shopFrame.Parent = screenGui
local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, 0, 0, 50)
shopTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
shopTitle.Text = "?? Shop"
shopTitle.TextColor3 = Color3.new(1, 1, 1)
shopTitle.TextSize = 24
shopTitle.Font = Enum.Font.GothamBold
shopTitle.Parent = shopFrame
local shopCloseButton = Instance.new("TextButton")
shopCloseButton.Size = UDim2.new(0, 40, 0, 40)
shopCloseButton.Position = UDim2.new(1, -45, 0, 5)
shopCloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
shopCloseButton.Text = "?"
shopCloseButton.TextColor3 = Color3.new(1, 1, 1)
shopCloseButton.TextSize = 24
shopCloseButton.Font = Enum.Font.GothamBold
shopCloseButton.Parent = shopTitle
shopCloseButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = false
end)
local itemsScroll = Instance.new("ScrollingFrame")
itemsScroll.Size = UDim2.new(1, -20, 1, -70)
itemsScroll.Position = UDim2.new(0, 10, 0, 60)
itemsScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
itemsScroll.BorderSizePixel = 0
itemsScroll.ScrollBarThickness = 10
itemsScroll.Parent = shopFrame
-- HOUSE PURCHASE FRAME
local housePurchaseFrame = Instance.new("Frame")
housePurchaseFrame.Size = UDim2.new(0, 400, 0, 200)
housePurchaseFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
housePurchaseFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
housePurchaseFrame.Visible = false
housePurchaseFrame.Parent = screenGui
local houseTitle = Instance.new("TextLabel")
houseTitle.Size = UDim2.new(1, 0, 0, 50)
houseTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
houseTitle.Text = "?? House Purchase"
houseTitle.TextColor3 = Color3.new(1, 1, 1)
houseTitle.TextSize = 24
houseTitle.Font = Enum.Font.GothamBold
houseTitle.Parent = housePurchaseFrame
local houseInfoLabel = Instance.new("TextLabel")
houseInfoLabel.Size = UDim2.new(1, -20, 0, 80)
houseInfoLabel.Position = UDim2.new(0, 10, 0, 60)
houseInfoLabel.BackgroundTransparency = 1
houseInfoLabel.Text = ""
houseInfoLabel.TextColor3 = Color3.new(1, 1, 1)
houseInfoLabel.TextSize = 18
houseInfoLabel.Font = Enum.Font.Gotham
houseInfoLabel.TextWrapped = true
houseInfoLabel.Parent = housePurchaseFrame
local houseBuyButton = Instance.new("TextButton")
houseBuyButton.Size = UDim2.new(0, 150, 0, 40)
houseBuyButton.Position = UDim2.new(0.5, -155, 1, -50)
houseBuyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
houseBuyButton.Text = "BUY HOUSE"
houseBuyButton.TextColor3 = Color3.new(1, 1, 1)
houseBuyButton.TextSize = 16
houseBuyButton.Font = Enum.Font.GothamBold
houseBuyButton.Parent = housePurchaseFrame
local houseCancelButton = Instance.new("TextButton")
houseCancelButton.Size = UDim2.new(0, 150, 0, 40)
houseCancelButton.Position = UDim2.new(0.5, 5, 1, -50)
houseCancelButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
houseCancelButton.Text = "CANCEL"
houseCancelButton.TextColor3 = Color3.new(1, 1, 1)
houseCancelButton.TextSize = 16
houseCancelButton.Font = Enum.Font.GothamBold
houseCancelButton.Parent = housePurchaseFrame
houseCancelButton.MouseButton1Click:Connect(function()
	housePurchaseFrame.Visible = false
end)
local currentHouseName = nil
-- Shop display
local function displayShopItems(shopName, items)
	for _, child in pairs(itemsScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	shopTitle.Text = "?? " .. shopName
	shopFrame.Visible = true

	for i, item in ipairs(items) do
		local itemFrame = Instance.new("Frame")
		itemFrame.Size = UDim2.new(1, -10, 0, 60)
		itemFrame.Position = UDim2.new(0, 5, 0, (i - 1) * 65)
		itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		itemFrame.Parent = itemsScroll

		local itemNameLabel = Instance.new("TextLabel")
		itemNameLabel.Size = UDim2.new(0, 300, 1, 0)
		itemNameLabel.Position = UDim2.new(0, 10, 0, 0)
		itemNameLabel.BackgroundTransparency = 1
		itemNameLabel.Text = item.name
		itemNameLabel.TextColor3 = Color3.new(1, 1, 1)
		itemNameLabel.TextSize = 18
		itemNameLabel.Font = Enum.Font.Gotham
		itemNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		itemNameLabel.Parent = itemFrame

		local priceLabel = Instance.new("TextLabel")
		priceLabel.Size = UDim2.new(0, 100, 1, 0)
		priceLabel.Position = UDim2.new(0, 320, 0, 0)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Text = "?? " .. item.price
		priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		priceLabel.TextSize = 16
		priceLabel.Font = Enum.Font.GothamBold
		priceLabel.Parent = itemFrame

		local buyButton = Instance.new("TextButton")
		buyButton.Size = UDim2.new(0, 100, 0, 40)
		buyButton.Position = UDim2.new(1, -110, 0.5, -20)
		buyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		buyButton.Text = "BUY"
		buyButton.TextColor3 = Color3.new(1, 1, 1)
		buyButton.TextSize = 16
		buyButton.Font = Enum.Font.GothamBold
		buyButton.Parent = itemFrame

		buyButton.MouseButton1Click:Connect(function()
			buyEvent:FireServer(shopName, item.name, item.price)
		end)
	end

	itemsScroll.CanvasSize = UDim2.new(0, 0, 0, #items * 65)

end
-- House purchase display
showHousePurchaseEvent.OnClientEvent:Connect(function(houseName, price, owner)
	currentHouseName = houseName
	if owner then
		houseInfoLabel.Text = "This house is already owned by " .. owner .. "!"
		houseBuyButton.Visible = false
	else
		houseInfoLabel.Text = "Purchase " .. houseName .. " for " .. price .. " coins?"
		houseBuyButton.Visible = true
	end

	housePurchaseFrame.Visible = true

end)
houseBuyButton.MouseButton1Click:Connect(function()
	if currentHouseName then
		buyHouseEvent:FireServer(currentHouseName)
		housePurchaseFrame.Visible = false
	end
end)
-- Event connections
updateCurrencyEvent.OnClientEvent:Connect(function(coins)
	currencyLabel.Text = "?? Coins: " .. coins
end)
showShopEvent.OnClientEvent:Connect(function(shopName, items)
	displayShopItems(shopName, items)
end)
showMessageEvent.OnClientEvent:Connect(function(message, msgType)
	print(message)
end)
print("? GUI with Houses Ready!")
