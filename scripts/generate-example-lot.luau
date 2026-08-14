local AuctionConfig = require("../src/shared/AuctionConfig")
local Collectibles = require("../src/shared/Collectibles")
local LotGenerator = require("../src/shared/LotGenerator")
local Rarities = require("../src/shared/Rarities")
local LotDebugFormatter = require("../src/server/LotDebugFormatter")

local DeterministicRandom = {}
DeterministicRandom.__index = DeterministicRandom

function DeterministicRandom.new(seed: number)
    return setmetatable({ state = seed }, DeterministicRandom)
end

function DeterministicRandom:_nextUnit(): number
    self.state = (self.state * 48_271) % 2_147_483_647
    return (self.state - 1) / 2_147_483_646
end

function DeterministicRandom:NextNumber(minimum: number, maximum: number): number
    return minimum + (maximum - minimum) * self:_nextUnit()
end

function DeterministicRandom:NextInteger(minimum: number, maximum: number): number
    return math.floor(self:NextNumber(0, 1) * (maximum - minimum + 1)) + minimum
end

local generator = LotGenerator.new(AuctionConfig, Rarities, Collectibles)
local random = DeterministicRandom.new(AuctionConfig.DEBUG_RANDOM_SEED)
local lot = generator:generate(AuctionConfig.DEBUG_LOT_ID, random)
local preview = generator:createPreview(lot)

print(LotDebugFormatter.formatPreview(preview))
print("")
print(LotDebugFormatter.formatServerLot(lot))
