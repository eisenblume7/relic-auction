local AuctionRemoteHandler = {}
AuctionRemoteHandler.__index = AuctionRemoteHandler

function AuctionRemoteHandler.new(service, publishState)
    assert(service ~= nil, "service is required")
    assert(type(publishState) == "function", "publishState is required")

    return setmetatable({
        _service = service,
        _publishState = publishState,
    }, AuctionRemoteHandler)
end

function AuctionRemoteHandler:handle(playerKey, action, payload)
    local succeeded, result = self._service:handleAction(playerKey, action, payload)
    if succeeded then
        self._publishState(playerKey, result)
        return true, result
    end

    local currentState = self._service:getSnapshot(playerKey) or {
        phase = "IDLE",
        round = 0,
    }
    local errorState = table.clone(currentState)
    errorState.error = result
    self._publishState(playerKey, errorState)

    return false, result
end

return AuctionRemoteHandler
