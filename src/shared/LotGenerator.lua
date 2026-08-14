local LotGenerator = {}
LotGenerator.__index = LotGenerator

local function groupCollectiblesByRarity(collectibles)
    local grouped = {}

    for _, collectible in collectibles do
        local pool = grouped[collectible.rarity]
        if not pool then
            pool = {}
            grouped[collectible.rarity] = pool
        end
        table.insert(pool, collectible)
    end

    return grouped
end

local function roundToIncrement(value, increment)
    return math.floor(value / increment + 0.5) * increment
end

function LotGenerator.new(config, rarities, collectibles)
    assert(config.LOT_SIZE > 0, "LOT_SIZE must be positive")
    assert(
        config.VISIBLE_SLOT_COUNT >= 0 and config.VISIBLE_SLOT_COUNT <= config.LOT_SIZE,
        "VISIBLE_SLOT_COUNT must fit inside LOT_SIZE"
    )
    assert(config.BID_INCREMENT > 0, "BID_INCREMENT must be positive")

    local collectiblePools = groupCollectiblesByRarity(collectibles)
    local totalWeight = 0

    for _, rarity in rarities do
        assert(rarity.weight > 0, `rarity {rarity.id} must have positive weight`)
        assert(
            collectiblePools[rarity.id] and #collectiblePools[rarity.id] > 0,
            `rarity {rarity.id} needs collectibles`
        )
        totalWeight += rarity.weight
    end

    return setmetatable({
        config = config,
        rarities = rarities,
        collectiblePools = collectiblePools,
        totalWeight = totalWeight,
    }, LotGenerator)
end

function LotGenerator:_selectRarity(random)
    local roll = random:NextNumber(0, self.totalWeight)
    local cumulativeWeight = 0

    for _, rarity in self.rarities do
        cumulativeWeight += rarity.weight
        if roll < cumulativeWeight then
            return rarity.id
        end
    end

    return self.rarities[#self.rarities].id
end

function LotGenerator:_selectCollectible(random)
    local rarityId = self:_selectRarity(random)
    local pool = self.collectiblePools[rarityId]
    return pool[random:NextInteger(1, #pool)]
end

function LotGenerator:_selectVisibleSlots(random)
    local candidates = {}
    for slotIndex = 1, self.config.LOT_SIZE do
        candidates[slotIndex] = slotIndex
    end

    local visibleSlots = {}
    for selectionIndex = 1, self.config.VISIBLE_SLOT_COUNT do
        local swapIndex = random:NextInteger(selectionIndex, #candidates)
        candidates[selectionIndex], candidates[swapIndex] = candidates[swapIndex], candidates[selectionIndex]
        visibleSlots[selectionIndex] = candidates[selectionIndex]
    end

    table.sort(visibleSlots)
    return visibleSlots
end

function LotGenerator:_calculateStartingBid(slots, visibleSlots)
    local visibleValue = 0
    for _, slotIndex in visibleSlots do
        visibleValue += slots[slotIndex].value
    end

    local rawStartingBid =
        math.max(self.config.MIN_STARTING_BID, visibleValue * self.config.VISIBLE_VALUE_STARTING_BID_MULTIPLIER)

    return roundToIncrement(rawStartingBid, self.config.BID_INCREMENT)
end

function LotGenerator:generate(lotId, random)
    assert(type(lotId) == "string" and lotId ~= "", "lotId is required")
    assert(random ~= nil, "random source is required")

    local slots = {}
    local totalValue = 0

    for slotIndex = 1, self.config.LOT_SIZE do
        local collectible = self:_selectCollectible(random)
        slots[slotIndex] = collectible
        totalValue += collectible.value
    end

    local visibleSlots = self:_selectVisibleSlots(random)

    return {
        id = lotId,
        slots = slots,
        visibleSlots = visibleSlots,
        startingBid = self:_calculateStartingBid(slots, visibleSlots),
        totalValue = totalValue,
    }
end

function LotGenerator:createPreview(lot)
    local visibleSet = {}
    for _, slotIndex in lot.visibleSlots do
        visibleSet[slotIndex] = true
    end

    local previewSlots = {}
    for slotIndex = 1, self.config.LOT_SIZE do
        if visibleSet[slotIndex] then
            previewSlots[slotIndex] = {
                visible = true,
                item = lot.slots[slotIndex],
            }
        else
            previewSlots[slotIndex] = {
                visible = false,
            }
        end
    end

    return {
        id = lot.id,
        slots = previewSlots,
        visibleSlots = table.clone(lot.visibleSlots),
        startingBid = lot.startingBid,
    }
end

return LotGenerator
