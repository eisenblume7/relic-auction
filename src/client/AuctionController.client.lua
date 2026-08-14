local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Shared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local auctionAction = remotes:WaitForChild("AuctionAction")
local auctionState = remotes:WaitForChild("AuctionState")
local AuctionPresentation = require(shared:WaitForChild("AuctionPresentation"))

local COLORS = {
    background = Color3.fromRGB(10, 18, 32),
    panel = Color3.fromRGB(18, 29, 48),
    panelRaised = Color3.fromRGB(27, 42, 66),
    border = Color3.fromRGB(67, 87, 116),
    text = Color3.fromRGB(237, 241, 247),
    muted = Color3.fromRGB(162, 176, 197),
    orange = Color3.fromRGB(239, 115, 38),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RelicAuctionUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "AuctionPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.82, 0.82)
panel.BackgroundColor3 = COLORS.background
panel.BorderSizePixel = 0
panel.Parent = screenGui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(640, 480)
sizeConstraint.MaxSize = Vector2.new(980, 720)
sizeConstraint.Parent = panel

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = COLORS.border
panelStroke.Thickness = 1
panelStroke.Parent = panel

local heading = Instance.new("TextLabel")
heading.Name = "Heading"
heading.BackgroundTransparency = 1
heading.Position = UDim2.new(0, 28, 0, 20)
heading.Size = UDim2.new(0.55, 0, 0, 38)
heading.Font = Enum.Font.GothamBold
heading.Text = "Relic Auction"
heading.TextColor3 = COLORS.text
heading.TextSize = 28
heading.TextXAlignment = Enum.TextXAlignment.Left
heading.Parent = panel

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "Coins"
coinsLabel.BackgroundColor3 = COLORS.panelRaised
coinsLabel.Position = UDim2.new(1, -220, 0, 22)
coinsLabel.Size = UDim2.new(0, 190, 0, 36)
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.Text = "Coins: --"
coinsLabel.TextColor3 = COLORS.text
coinsLabel.TextSize = 16
coinsLabel.Parent = panel

local coinsCorner = Instance.new("UICorner")
coinsCorner.CornerRadius = UDim.new(0, 8)
coinsCorner.Parent = coinsLabel

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 28, 0, 66)
statusLabel.Size = UDim2.new(1, -56, 0, 28)
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Ready for a new lot"
statusLabel.TextColor3 = COLORS.muted
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = panel

local metaFrame = Instance.new("Frame")
metaFrame.Name = "AuctionMeta"
metaFrame.BackgroundColor3 = COLORS.panel
metaFrame.Position = UDim2.new(0, 28, 0, 106)
metaFrame.Size = UDim2.new(1, -56, 0, 62)
metaFrame.BorderSizePixel = 0
metaFrame.Parent = panel

local metaCorner = Instance.new("UICorner")
metaCorner.CornerRadius = UDim.new(0, 10)
metaCorner.Parent = metaFrame

local lotLabel = Instance.new("TextLabel")
lotLabel.Name = "LotId"
lotLabel.BackgroundTransparency = 1
lotLabel.Position = UDim2.new(0, 16, 0, 0)
lotLabel.Size = UDim2.new(0.34, 0, 1, 0)
lotLabel.Font = Enum.Font.GothamBold
lotLabel.Text = "No active lot"
lotLabel.TextColor3 = COLORS.text
lotLabel.TextSize = 16
lotLabel.TextXAlignment = Enum.TextXAlignment.Left
lotLabel.Parent = metaFrame

local bidLabel = Instance.new("TextLabel")
bidLabel.Name = "CurrentBid"
bidLabel.BackgroundTransparency = 1
bidLabel.Position = UDim2.new(0.34, 0, 0, 0)
bidLabel.Size = UDim2.new(0.38, 0, 1, 0)
bidLabel.Font = Enum.Font.GothamBold
bidLabel.Text = "Current Bid: 0 Coins"
bidLabel.TextColor3 = COLORS.text
bidLabel.TextSize = 16
bidLabel.Parent = metaFrame

local roundLabel = Instance.new("TextLabel")
roundLabel.Name = "Round"
roundLabel.BackgroundTransparency = 1
roundLabel.Position = UDim2.new(0.72, 0, 0, 0)
roundLabel.Size = UDim2.new(0.28, -16, 1, 0)
roundLabel.Font = Enum.Font.GothamBold
roundLabel.Text = "Round 0 / 0"
roundLabel.TextColor3 = COLORS.text
roundLabel.TextSize = 16
roundLabel.TextXAlignment = Enum.TextXAlignment.Right
roundLabel.Parent = metaFrame

local lotGrid = Instance.new("Frame")
lotGrid.Name = "LotGrid"
lotGrid.BackgroundTransparency = 1
lotGrid.Position = UDim2.new(0, 28, 0, 184)
lotGrid.Size = UDim2.new(1, -56, 1, -290)
lotGrid.Parent = panel

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.CellSize = UDim2.new(0.25, -8, 0.5, -5)
gridLayout.FillDirectionMaxCells = 4
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
gridLayout.Parent = lotGrid

local slotLabels = {}
for slotIndex = 1, 8 do
    local slot = Instance.new("TextLabel")
    slot.Name = string.format("Slot%d", slotIndex)
    slot.LayoutOrder = slotIndex
    slot.BackgroundColor3 = COLORS.panel
    slot.BorderSizePixel = 0
    slot.Font = Enum.Font.GothamBold
    slot.Text = "—"
    slot.TextColor3 = COLORS.muted
    slot.TextSize = 14
    slot.TextWrapped = true
    slot.Parent = lotGrid

    local slotCorner = Instance.new("UICorner")
    slotCorner.CornerRadius = UDim.new(0, 10)
    slotCorner.Parent = slot

    local slotStroke = Instance.new("UIStroke")
    slotStroke.Color = COLORS.border
    slotStroke.Thickness = 1
    slotStroke.Parent = slot

    slotLabels[slotIndex] = slot
end

local controls = Instance.new("Frame")
controls.Name = "Controls"
controls.BackgroundTransparency = 1
controls.Position = UDim2.new(0, 28, 1, -84)
controls.Size = UDim2.new(1, -56, 0, 54)
controls.Parent = panel

local controlLayout = Instance.new("UIListLayout")
controlLayout.FillDirection = Enum.FillDirection.Horizontal
controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
controlLayout.Padding = UDim.new(0, 12)
controlLayout.SortOrder = Enum.SortOrder.LayoutOrder
controlLayout.Parent = controls

local function createButton(name, text, layoutOrder)
    local button = Instance.new("TextButton")
    button.Name = name
    button.LayoutOrder = layoutOrder
    button.Size = UDim2.new(0, 190, 1, 0)
    button.BackgroundColor3 = COLORS.orange
    button.AutoButtonColor = true
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = COLORS.text
    button.TextSize = 16
    button.Parent = controls

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    return button
end

local startAuctionButton = createButton("StartAuction", "Start Auction", 1)
local startBiddingButton = createButton("StartBidding", "Start Bidding", 2)
local raiseButton = createButton("Raise", "Raise", 3)
local passButton = createButton("Pass", "Pass", 4)
passButton.BackgroundColor3 = COLORS.panelRaised

local actionPending = false

local function setButtonState(button, visible)
    button.Visible = visible
    button.Active = visible and not actionPending
    button.AutoButtonColor = visible and not actionPending
end

local function render(state)
    actionPending = false
    local view = AuctionPresentation.create(state)

    heading.Text = view.heading
    statusLabel.Text = view.status
    lotLabel.Text = view.lotId
    bidLabel.Text = view.bidText
    roundLabel.Text = view.roundText
    raiseButton.Text = view.raiseText

    for slotIndex = 1, 8 do
        local slotText = view.slotTexts[slotIndex]
        slotLabels[slotIndex].Text = slotText or "—"
        slotLabels[slotIndex].TextColor3 = slotText and COLORS.text or COLORS.muted
    end

    setButtonState(startAuctionButton, view.controls.startAuction)
    setButtonState(startBiddingButton, view.controls.startBidding)
    setButtonState(raiseButton, view.controls.raise)
    setButtonState(passButton, view.controls.pass)
end

local function sendAction(action)
    if actionPending then
        return
    end

    actionPending = true
    setButtonState(startAuctionButton, startAuctionButton.Visible)
    setButtonState(startBiddingButton, startBiddingButton.Visible)
    setButtonState(raiseButton, raiseButton.Visible)
    setButtonState(passButton, passButton.Visible)
    auctionAction:FireServer(action)
end

startAuctionButton.Activated:Connect(function()
    sendAction("START_AUCTION")
end)

startBiddingButton.Activated:Connect(function()
    sendAction("START_BIDDING")
end)

raiseButton.Activated:Connect(function()
    sendAction("RAISE")
end)

passButton.Activated:Connect(function()
    sendAction("PASS")
end)

auctionState.OnClientEvent:Connect(function(state)
    if type(state) == "table" then
        render(state)
    end
end)

render({ phase = "IDLE", round = 0 })

local leaderstats = player:WaitForChild("leaderstats")
local coins = leaderstats:WaitForChild("Coins")
local function updateCoins()
    coinsLabel.Text = string.format("Coins: %d", coins.Value)
end

coins:GetPropertyChangedSignal("Value"):Connect(updateCoins)
updateCoins()
