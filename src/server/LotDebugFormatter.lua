local LotDebugFormatter = {}

function LotDebugFormatter.formatPreview(preview)
    local lines = {
        `LOT {preview.id}`,
        `Starting Bid: {preview.startingBid}`,
    }

    for slotIndex, slot in preview.slots do
        if slot.visible then
            table.insert(lines, `Slot {slotIndex}: {slot.item.name} | {slot.item.rarity} | VISIBLE`)
        else
            table.insert(lines, `Slot {slotIndex}: ??? | HIDDEN`)
        end
    end

    return table.concat(lines, "\n")
end

function LotDebugFormatter.formatServerLot(lot)
    local lines = {
        `[SERVER-ONLY] {lot.id} COMPLETE CONTENTS`,
        `Starting Bid: {lot.startingBid}`,
        `True Value: {lot.totalValue}`,
    }

    for slotIndex, item in lot.slots do
        table.insert(
            lines,
            `Slot {slotIndex}: {item.name} | {item.rarity} | Value {item.value} | Income {item.incomePerHour}/hour`
        )
    end

    return table.concat(lines, "\n")
end

return LotDebugFormatter
