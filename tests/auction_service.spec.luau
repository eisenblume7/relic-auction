local AuctionConfig = require("../src/shared/AuctionConfig")
local AuctionStateMachine = require("../src/server/AuctionStateMachine")
local AuctionService = require("../src/server/AuctionService")

local generatedLot = {
    id = "",
    slots = {
        { id = "visible", name = "Visible Item", value = 100 },
        { id = "hidden", name = "Hidden Item", value = 900 },
    },
    visibleSlots = { 1 },
    startingBid = 200,
    totalValue = 1_000,
}

local fakeGenerator = {}
function fakeGenerator:generate(lotId, _random)
    generatedLot.id = lotId
    return generatedLot
end

function fakeGenerator:createPreview(lot)
    return {
        id = lot.id,
        startingBid = lot.startingBid,
        slots = {
            { visible = true, item = lot.slots[1] },
            { visible = false },
        },
    }
end

local service = AuctionService.new({
    config = AuctionConfig,
    lotGenerator = fakeGenerator,
    randomFactory = function()
        return {}
    end,
    machineFactory = function(createPreview)
        return AuctionStateMachine.new(AuctionConfig, createPreview)
    end,
    getPlayerBudget = function(_playerKey)
        return 2_000
    end,
})

local started, preview = service:handleAction(101, "START_AUCTION")
assert(started == true, "server must accept START_AUCTION from an idle player")
assert(preview.phase == "PREVIEW", "start action must publish PREVIEW")
assert(preview.lot.id == "LOT_001", "service must assign server-owned lot ids")
assert(preview.lot.slots[2].item == nil, "service must publish only a redacted lot")
for key in preview.lot.slots[2] do
    assert(key == "visible", "hidden public slots must contain no fields except visibility")
end

local began, roundOne = service:handleAction(101, "START_BIDDING")
assert(began == true, "server must accept START_BIDDING during PREVIEW")
assert(roundOne.phase == "BIDDING" and roundOne.round == 1, "bidding must begin at round one")

local payloadAccepted, payloadError = service:handleAction(101, "RAISE", { amount = 9_999 })
assert(payloadAccepted == false, "client-supplied prices must be rejected")
assert(payloadError == "PAYLOAD_NOT_ALLOWED", "price payload rejection must use a stable error")
assert(service:getSnapshot(101).round == 1, "rejected payload must not consume a round")
assert(service:getSnapshot(101).currentBid == 200, "rejected payload must not alter the bid")

local raised, roundTwo = service:handleAction(101, "RAISE")
assert(raised == true, "server-calculated raise must succeed")
assert(roundTwo.currentBid == 250, "service must use the configured server increment")
assert(roundTwo.round == 2, "valid action must advance exactly one round")

local unknown, unknownError = service:handleAction(101, "SET_BID")
assert(unknown == false, "unknown remote actions must be rejected")
assert(unknownError == "INVALID_ACTION", "unknown action must use a stable error")

print("PASS auction_service.spec")
