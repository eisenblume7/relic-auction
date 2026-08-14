local AuctionConfig = require("../src/shared/AuctionConfig")
local Collectibles = require("../src/shared/Collectibles")
local LotGenerator = require("../src/shared/LotGenerator")
local Rarities = require("../src/shared/Rarities")

local HighRollRandom = {}
HighRollRandom.__index = HighRollRandom

function HighRollRandom.new()
    return setmetatable({}, HighRollRandom)
end

function HighRollRandom:NextNumber(_minimum: number, maximum: number): number
    return maximum - 0.001
end

function HighRollRandom:NextInteger(minimum: number, _maximum: number): number
    return minimum
end

local totalWeight = 0
for _, rarity in Rarities do
    totalWeight += rarity.weight
end
assert(totalWeight == 10_000, "rarity weights must total 10,000 basis points")

local rarityIds = {}
for _, rarity in Rarities do
    rarityIds[rarity.id] = true
end
for _, collectible in Collectibles do
    assert(rarityIds[collectible.rarity], `unknown rarity for {collectible.id}`)
    assert(collectible.value > 0, `collectible {collectible.id} must have positive value`)
    assert(collectible.incomePerHour >= 0, `collectible {collectible.id} must have non-negative income`)
end

local generator = LotGenerator.new(AuctionConfig, Rarities, Collectibles)
local lot = generator:generate("LOT_TEST", HighRollRandom.new())
assert(lot.id == "LOT_TEST", "generator must preserve the supplied lot id")
assert(#lot.slots == AuctionConfig.LOT_SIZE, "lot must contain exactly the configured slot count")
assert(#lot.visibleSlots == AuctionConfig.VISIBLE_SLOT_COUNT, "lot must expose exactly the configured visible count")
assert(lot.totalValue > 0, "server lot must retain its true total value")

local visibleSet = {}
for _, slotIndex in lot.visibleSlots do
    assert(not visibleSet[slotIndex], "visible slots must be unique")
    assert(slotIndex >= 1 and slotIndex <= AuctionConfig.LOT_SIZE, "visible slot index must be in range")
    visibleSet[slotIndex] = true
end

for _, collectible in lot.slots do
    assert(collectible.rarity == "BIBLICAL", "a highest weighted roll must be able to produce Biblical rarity")
end

local visibleValue = 0
for _, slotIndex in lot.visibleSlots do
    visibleValue += lot.slots[slotIndex].value
end
local rawStartingBid =
    math.max(AuctionConfig.MIN_STARTING_BID, visibleValue * AuctionConfig.VISIBLE_VALUE_STARTING_BID_MULTIPLIER)
local expectedStartingBid = math.floor(rawStartingBid / AuctionConfig.BID_INCREMENT + 0.5) * AuctionConfig.BID_INCREMENT
assert(lot.startingBid == expectedStartingBid, "starting bid must use configurable visible-value rules")

local preview = generator:createPreview(lot)
assert(preview.totalValue == nil, "client preview must not expose true lot value")
assert(#preview.slots == AuctionConfig.LOT_SIZE, "preview must preserve slot positions")
for slotIndex, slot in preview.slots do
    if visibleSet[slotIndex] then
        assert(slot.visible == true, "configured visible slot must be marked visible")
        assert(slot.item ~= nil, "visible slot must include its collectible")
    else
        assert(slot.visible == false, "hidden slot must be marked hidden")
        assert(slot.item == nil, "hidden slot must redact its collectible")
    end
end

print("PASS lot_generator.spec")
