local AuctionConfig = require("../src/shared/AuctionConfig")
local AuctionStateMachine = require("../src/server/AuctionStateMachine")

local serverLot = {
    id = "LOT_PHASE3",
    slots = {
        { id = "visible", name = "Visible Item", value = 100 },
        { id = "hidden", name = "Hidden Item", value = 900 },
    },
    visibleSlots = { 1 },
    startingBid = 200,
    totalValue = 1_000,
}

local function createPreview(lot)
    return {
        id = lot.id,
        startingBid = lot.startingBid,
        slots = {
            { visible = true, item = lot.slots[1] },
            { visible = false },
        },
    }
end

local machine = AuctionStateMachine.new(AuctionConfig, createPreview)
local initial = machine:snapshot()
assert(initial.phase == "IDLE", "new auction must begin in IDLE")
assert(initial.lot == nil, "IDLE snapshot must not contain a lot")

local started, preview = machine:start(serverLot)
assert(started == true, "IDLE auction must start successfully")
assert(preview.phase == "PREVIEW", "starting must transition IDLE to PREVIEW")
assert(preview.round == 0, "preview occurs before bidding round one")
assert(preview.currentBid == 200, "preview must expose the server starting bid")
assert(preview.lot.id == "LOT_PHASE3", "preview must expose the lot id")
assert(preview.lot.totalValue == nil, "public auction state must not expose true value")
assert(preview.lot.slots[2].item == nil, "public auction state must redact hidden identities")
assert(machine:getServerLot() == serverLot, "machine must retain the complete lot only on the server")

local startedAgain, startError = machine:start(serverLot)
assert(startedAgain == false, "an active auction must reject a second start")
assert(startError == "INVALID_STATE", "invalid start must return a stable error code")

print("PASS auction_state_machine_start.spec")
