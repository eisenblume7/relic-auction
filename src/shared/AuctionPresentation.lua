local AuctionPresentation = {}

local function formatSlot(slot)
    if not slot.visible then
        return "???\nHIDDEN"
    end

    return string.format("%s\n%s", slot.item.name, slot.item.rarity)
end

function AuctionPresentation.create(state)
    local phase = state.phase or "IDLE"
    local controls = {
        startAuction = phase == "IDLE",
        startBidding = phase == "PREVIEW",
        raise = phase == "BIDDING",
        pass = phase == "BIDDING",
    }

    local status
    if state.error then
        status = string.format("Action rejected: %s", state.error)
    elseif phase == "IDLE" then
        status = "Ready for a new lot"
    elseif phase == "PREVIEW" then
        status = "Inspect the visible collectibles"
    elseif phase == "BIDDING" then
        status = "Choose RAISE or PASS"
    elseif phase == "RESOLVING" then
        status = "Three rounds complete"
    else
        status = phase
    end

    local slotTexts = {}
    if state.lot and state.lot.slots then
        for slotIndex, slot in state.lot.slots do
            slotTexts[slotIndex] = formatSlot(slot)
        end
    end

    return {
        heading = "Relic Auction",
        status = status,
        lotId = state.lot and state.lot.id or "No active lot",
        bidText = string.format("Current Bid: %d Coins", state.currentBid or 0),
        roundText = string.format("Round %d / %d", state.round or 0, state.maxRounds or 0),
        raiseText = string.format("Raise +%d", state.minimumRaise or 0),
        slotTexts = slotTexts,
        controls = controls,
    }
end

return AuctionPresentation
