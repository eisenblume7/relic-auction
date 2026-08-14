local AuctionConfig = require("../src/shared/AuctionConfig")
local AuctionStateMachine = require("../src/server/AuctionStateMachine")

local machine = AuctionStateMachine.new(AuctionConfig, function(serverLot)
    return {
        id = serverLot.id,
        slots = {},
        startingBid = serverLot.startingBid,
    }
end)

assert(machine:start({
    id = "LOT_VALIDATION",
    slots = {},
    visibleSlots = {},
    startingBid = 200,
    totalValue = 500,
}))
assert(machine:beginBidding())

local raised, budgetError = machine:submitPlayerAction("RAISE", 249)
assert(raised == false, "raise above the player budget must be rejected")
assert(budgetError == "INSUFFICIENT_FUNDS", "insufficient budget must return a stable error")
local afterBudgetError = machine:snapshot()
assert(afterBudgetError.round == 1, "rejected raise must not consume a round")
assert(afterBudgetError.currentBid == 200, "rejected raise must not mutate current bid")

local arbitrary, actionError = machine:submitPlayerAction("RAISE_TO_9999", 20_000)
assert(arbitrary == false, "arbitrary client bid actions must be rejected")
assert(actionError == "INVALID_ACTION", "arbitrary action must return a stable error")
assert(machine:snapshot().round == 1, "invalid action must not consume a round")

local malformed, budgetTypeError = machine:submitPlayerAction("RAISE", nil)
assert(malformed == false, "malformed budget input must not throw")
assert(budgetTypeError == "INVALID_BUDGET", "malformed budget must return a stable error")
assert(machine:snapshot().round == 1, "malformed action must not consume a round")

print("PASS auction_state_machine_validation.spec")
