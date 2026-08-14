local AuctionConfig = require("../src/shared/AuctionConfig")
local AuctionStateMachine = require("../src/server/AuctionStateMachine")

local lot = {
    id = "LOT_ROUNDS",
    slots = {},
    visibleSlots = {},
    startingBid = 200,
    totalValue = 900,
}

local machine = AuctionStateMachine.new(AuctionConfig, function(serverLot)
    return {
        id = serverLot.id,
        slots = {},
        startingBid = serverLot.startingBid,
    }
end)

assert(machine:start(lot))

local began, roundOne = machine:beginBidding()
assert(began == true, "PREVIEW must advance to BIDDING")
assert(roundOne.phase == "BIDDING", "beginBidding must enter BIDDING")
assert(roundOne.round == 1, "bidding must begin at round one")
assert(roundOne.maxRounds == 3, "maximum rounds must come from configuration")
assert(roundOne.minimumRaise == 50, "minimum raise must come from configuration")

local raised, roundTwo = machine:submitPlayerAction("RAISE", 2_000)
assert(raised == true, "a funded raise must succeed")
assert(roundTwo.phase == "BIDDING", "round one action must continue bidding")
assert(roundTwo.round == 2, "round one action must advance to round two")
assert(roundTwo.currentBid == 250, "raise amount must be calculated by the server")
assert(roundTwo.lastAction == "RAISE", "snapshot must expose the resolved player action")

local passed, roundThree = machine:submitPlayerAction("PASS", 2_000)
assert(passed == true, "pass must be a valid round action")
assert(roundThree.phase == "BIDDING", "round two action must continue bidding")
assert(roundThree.round == 3, "round two action must advance to round three")
assert(roundThree.currentBid == 250, "pass must not change the bid")
assert(roundThree.lastAction == "PASS", "snapshot must expose pass")

local finalRaise, resolving = machine:submitPlayerAction("RAISE", 2_000)
assert(finalRaise == true, "final funded raise must succeed")
assert(resolving.phase == "RESOLVING", "the final configured round must transition to RESOLVING")
assert(resolving.round == 3, "resolved state must retain the final round number")
assert(resolving.currentBid == 300, "final raise must update the bid before resolving")

print("PASS auction_state_machine_rounds.spec")
