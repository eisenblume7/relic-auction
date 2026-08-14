local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local AuctionConfig = require(Shared:WaitForChild("AuctionConfig"))
local Collectibles = require(Shared:WaitForChild("Collectibles"))
local LotGenerator = require(Shared:WaitForChild("LotGenerator"))
local Rarities = require(Shared:WaitForChild("Rarities"))

local AuctionRemoteHandler = require(script.Parent:WaitForChild("AuctionRemoteHandler"))
local AuctionService = require(script.Parent:WaitForChild("AuctionService"))
local AuctionStateMachine = require(script.Parent:WaitForChild("AuctionStateMachine"))
local PlayerSession = require(script.Parent:WaitForChild("PlayerSession"))

local auctionAction = Remotes:WaitForChild("AuctionAction")
local auctionState = Remotes:WaitForChild("AuctionState")
local lotGenerator = LotGenerator.new(AuctionConfig, Rarities, Collectibles)

local service = AuctionService.new({
    config = AuctionConfig,
    lotGenerator = lotGenerator,
    randomFactory = function()
        return Random.new()
    end,
    machineFactory = function(createPreview)
        return AuctionStateMachine.new(AuctionConfig, createPreview)
    end,
    getPlayerBudget = function(player)
        local session = PlayerSession.get(player)
        return session and session.coins or nil
    end,
})

local handler = AuctionRemoteHandler.new(service, function(player, state)
    auctionState:FireClient(player, state)
end)

auctionAction.OnServerEvent:Connect(function(player, action, payload)
    handler:handle(player, action, payload)
end)

Players.PlayerRemoving:Connect(function(player)
    service:removePlayer(player)
end)
