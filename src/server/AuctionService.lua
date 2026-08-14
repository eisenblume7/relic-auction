local AuctionService = {}
AuctionService.__index = AuctionService

local VALID_ACTIONS = {
    START_AUCTION = true,
    START_BIDDING = true,
    RAISE = true,
    PASS = true,
}

function AuctionService.new(dependencies)
    assert(dependencies ~= nil, "dependencies are required")
    assert(dependencies.config ~= nil, "config is required")
    assert(dependencies.lotGenerator ~= nil, "lotGenerator is required")
    assert(type(dependencies.randomFactory) == "function", "randomFactory is required")
    assert(type(dependencies.machineFactory) == "function", "machineFactory is required")
    assert(type(dependencies.getPlayerBudget) == "function", "getPlayerBudget is required")

    return setmetatable({
        _config = dependencies.config,
        _lotGenerator = dependencies.lotGenerator,
        _randomFactory = dependencies.randomFactory,
        _machineFactory = dependencies.machineFactory,
        _getPlayerBudget = dependencies.getPlayerBudget,
        _machines = {},
        _lotSequence = 0,
    }, AuctionService)
end

function AuctionService:_nextLotId()
    self._lotSequence += 1
    return string.format("LOT_%03d", self._lotSequence)
end

function AuctionService:_createMachine()
    local lotGenerator = self._lotGenerator
    return self._machineFactory(function(lot)
        return lotGenerator:createPreview(lot)
    end)
end

function AuctionService:getSnapshot(playerKey)
    local machine = self._machines[playerKey]
    if not machine then
        return nil
    end
    return machine:snapshot()
end

function AuctionService:removePlayer(playerKey)
    self._machines[playerKey] = nil
end

function AuctionService:handleAction(playerKey, action, payload)
    if type(action) ~= "string" or not VALID_ACTIONS[action] then
        return false, "INVALID_ACTION"
    end

    if payload ~= nil then
        return false, "PAYLOAD_NOT_ALLOWED"
    end

    local machine = self._machines[playerKey]

    if action == "START_AUCTION" then
        if machine then
            return false, "INVALID_STATE"
        end

        machine = self:_createMachine()
        self._machines[playerKey] = machine

        local lot = self._lotGenerator:generate(self:_nextLotId(), self._randomFactory())
        return machine:start(lot)
    end

    if not machine then
        return false, "INVALID_STATE"
    end

    if action == "START_BIDDING" then
        return machine:beginBidding()
    end

    return machine:submitPlayerAction(action, self._getPlayerBudget(playerKey))
end

return AuctionService
