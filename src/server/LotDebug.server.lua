local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AuctionConfig = require(Shared.AuctionConfig)
local Collectibles = require(Shared.Collectibles)
local LotGenerator = require(Shared.LotGenerator)
local Rarities = require(Shared.Rarities)
local LotDebugFormatter = require(script.Parent.LotDebugFormatter)

local generator = LotGenerator.new(AuctionConfig, Rarities, Collectibles)
local random = Random.new(AuctionConfig.DEBUG_RANDOM_SEED)
local lot = generator:generate(AuctionConfig.DEBUG_LOT_ID, random)
local preview = generator:createPreview(lot)

print("[Relic Auction] Generated Phase 2 preview:\n" .. LotDebugFormatter.formatPreview(preview))
print("[Relic Auction] Generated Phase 2 server data:\n" .. LotDebugFormatter.formatServerLot(lot))
