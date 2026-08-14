local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.Shared.EconomyConfig)
local PlayerSession = require(script.Parent.PlayerSession)

local function initializePlayer(player: Player)
    PlayerSession.initialize(player, Instance.new, EconomyConfig.STARTING_COINS)
end

Players.PlayerAdded:Connect(initializePlayer)
Players.PlayerRemoving:Connect(PlayerSession.remove)

for _, player in Players:GetPlayers() do
    initializePlayer(player)
end
