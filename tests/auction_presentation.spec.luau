local AuctionPresentation = require("../src/shared/AuctionPresentation")

local idle = AuctionPresentation.create({ phase = "IDLE", round = 0 })
assert(idle.heading == "Relic Auction", "idle heading must identify the game")
assert(idle.status == "Ready for a new lot", "idle state must explain the next action")
assert(idle.controls.startAuction == true, "idle state must expose Start Auction")
assert(idle.controls.startBidding == false, "idle state must hide bidding controls")

local preview = AuctionPresentation.create({
    phase = "PREVIEW",
    round = 0,
    currentBid = 200,
    minimumRaise = 50,
    lot = {
        id = "LOT_001",
        slots = {
            {
                visible = true,
                item = { name = "Tideglass Chalice", rarity = "RARE" },
            },
            { visible = false },
        },
    },
})
assert(preview.lotId == "LOT_001", "preview must display the server lot id")
assert(preview.bidText == "Current Bid: 200 Coins", "preview must display current bid")
assert(preview.slotTexts[1] == "Tideglass Chalice\nRARE", "visible slot must display safe collectible data")
assert(preview.slotTexts[2] == "???\nHIDDEN", "hidden slot must remain redacted")
assert(preview.controls.startBidding == true, "preview must expose Start Bidding")
assert(preview.controls.raise == false, "preview must not expose round actions")

local bidding = AuctionPresentation.create({
    phase = "BIDDING",
    round = 2,
    maxRounds = 3,
    currentBid = 250,
    minimumRaise = 50,
    lastAction = "RAISE",
    lot = preview and {
        id = "LOT_001",
        slots = {},
    },
})
assert(bidding.roundText == "Round 2 / 3", "bidding must display configured round progress")
assert(bidding.raiseText == "Raise +50", "raise control must show the server increment")
assert(bidding.controls.raise == true and bidding.controls.pass == true, "bidding must expose both round actions")

local resolving = AuctionPresentation.create({
    phase = "RESOLVING",
    round = 3,
    maxRounds = 3,
    currentBid = 300,
    minimumRaise = 50,
    lastAction = "RAISE",
    lot = { id = "LOT_001", slots = {} },
})
assert(resolving.status == "Three rounds complete", "resolving must describe the Phase 3 stopping point")
assert(resolving.controls.raise == false and resolving.controls.pass == false, "resolving must disable input")

print("PASS auction_presentation.spec")
