local AuctionStateMachine = {}
AuctionStateMachine.__index = AuctionStateMachine

function AuctionStateMachine.new(config, createPreview)
    assert(config ~= nil, "config is required")
    assert(
        type(config.BIDDING_ROUNDS) == "number" and config.BIDDING_ROUNDS > 0 and config.BIDDING_ROUNDS % 1 == 0,
        "BIDDING_ROUNDS must be a positive integer"
    )
    assert(
        type(config.MINIMUM_RAISE) == "number" and config.MINIMUM_RAISE > 0 and config.MINIMUM_RAISE < math.huge,
        "MINIMUM_RAISE must be positive and finite"
    )
    assert(type(createPreview) == "function", "createPreview is required")

    return setmetatable({
        _config = config,
        _createPreview = createPreview,
        _phase = "IDLE",
        _round = 0,
        _currentBid = 0,
        _lastAction = nil,
        _publicLot = nil,
        _serverLot = nil,
    }, AuctionStateMachine)
end

function AuctionStateMachine:snapshot()
    return {
        phase = self._phase,
        round = self._round,
        maxRounds = self._config.BIDDING_ROUNDS,
        currentBid = self._currentBid,
        minimumRaise = self._config.MINIMUM_RAISE,
        lastAction = self._lastAction,
        lot = self._publicLot,
    }
end

function AuctionStateMachine:getServerLot()
    return self._serverLot
end

function AuctionStateMachine:_advanceRound()
    if self._round >= self._config.BIDDING_ROUNDS then
        self._phase = "RESOLVING"
    else
        self._round += 1
    end
end

function AuctionStateMachine:beginBidding()
    if self._phase ~= "PREVIEW" then
        return false, "INVALID_STATE"
    end

    self._phase = "BIDDING"
    self._round = 1
    return true, self:snapshot()
end

function AuctionStateMachine:submitPlayerAction(action, budget)
    if self._phase ~= "BIDDING" then
        return false, "INVALID_STATE"
    end

    if action == "RAISE" then
        if type(budget) ~= "number" or budget < 0 or budget ~= budget then
            return false, "INVALID_BUDGET"
        end

        local nextBid = self._currentBid + self._config.MINIMUM_RAISE
        if budget < nextBid then
            return false, "INSUFFICIENT_FUNDS"
        end
        self._currentBid = nextBid
    elseif action ~= "PASS" then
        return false, "INVALID_ACTION"
    end

    self._lastAction = action
    self:_advanceRound()
    return true, self:snapshot()
end

function AuctionStateMachine:start(serverLot)
    if self._phase ~= "IDLE" then
        return false, "INVALID_STATE"
    end

    assert(serverLot ~= nil, "serverLot is required")

    self._serverLot = serverLot
    self._publicLot = self._createPreview(serverLot)
    self._phase = "PREVIEW"
    self._round = 0
    self._currentBid = serverLot.startingBid
    self._lastAction = nil

    return true, self:snapshot()
end

return AuctionStateMachine
