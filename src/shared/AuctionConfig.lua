local AuctionConfig = {
    LOT_SIZE = 8,
    VISIBLE_SLOT_COUNT = 3,
    MIN_STARTING_BID = 100,
    VISIBLE_VALUE_STARTING_BID_MULTIPLIER = 0.6,
    BID_INCREMENT = 25,
    BIDDING_ROUNDS = 3,
    MINIMUM_RAISE = 50,
    DEBUG_RANDOM_SEED = 10_824,
    DEBUG_LOT_ID = "LOT_001",
}

table.freeze(AuctionConfig)

return AuctionConfig
