local AuctionConfig = require("../src/shared/AuctionConfig")
local AuctionStateMachine = require("../src/server/AuctionStateMachine")

local function createMachine(config)
    return AuctionStateMachine.new(config, function(lot)
        return lot
    end)
end

local function cloneConfig()
    local clone = {}
    for key, value in AuctionConfig do
        clone[key] = value
    end
    return clone
end

local invalidRounds = cloneConfig()
invalidRounds.BIDDING_ROUNDS = 0
local validRounds = pcall(createMachine, invalidRounds)
assert(validRounds == false, "BIDDING_ROUNDS must be a positive integer")

local fractionalRounds = cloneConfig()
fractionalRounds.BIDDING_ROUNDS = 2.5
local validFractionalRounds = pcall(createMachine, fractionalRounds)
assert(validFractionalRounds == false, "BIDDING_ROUNDS must not be fractional")

local invalidRaise = cloneConfig()
invalidRaise.MINIMUM_RAISE = math.huge
local validRaise = pcall(createMachine, invalidRaise)
assert(validRaise == false, "MINIMUM_RAISE must be finite")

print("PASS auction_state_machine_config.spec")
