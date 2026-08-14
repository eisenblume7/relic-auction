local AuctionRemoteHandler = require("../src/server/AuctionRemoteHandler")

local calls = {}
local fakeService = {
    handleAction = function(_self, playerKey, action, payload)
        table.insert(calls, { playerKey = playerKey, action = action, payload = payload })
        if action == "FAIL" then
            return false, "INVALID_ACTION"
        end
        return true, { phase = "PREVIEW", round = 0 }
    end,
    getSnapshot = function(_self, _playerKey)
        return { phase = "IDLE", round = 0 }
    end,
}

local published = {}
local handler = AuctionRemoteHandler.new(fakeService, function(playerKey, state)
    table.insert(published, { playerKey = playerKey, state = state })
end)

local succeeded = handler:handle(55, "START_AUCTION")
assert(succeeded == true, "successful service action must be reported")
assert(#calls == 1 and calls[1].playerKey == 55, "handler must route action to the player's server session")
assert(published[1].state.phase == "PREVIEW", "handler must publish successful state")

local failed, errorCode = handler:handle(55, "FAIL", { arbitrary = true })
assert(failed == false and errorCode == "INVALID_ACTION", "service rejection must propagate")
assert(published[2].state.phase == "IDLE", "rejection must publish the current safe state")
assert(published[2].state.error == "INVALID_ACTION", "rejection payload must include a stable error code")
assert(published[2].state.arbitrary == nil, "client payload must never be reflected back into state")

print("PASS auction_remote_handler.spec")
