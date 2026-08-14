local LotDebugFormatter = require("../src/server/LotDebugFormatter")

local visibleItem = {
    id = "visible_vase",
    name = "Visible Vase",
    rarity = "COMMON",
    value = 35,
    incomePerHour = 2,
    category = "Vase",
}
local hiddenItem = {
    id = "hidden_book",
    name = "Hidden Book",
    rarity = "RARE",
    value = 180,
    incomePerHour = 14,
    category = "Book",
}
local lot = {
    id = "LOT_TEST",
    slots = { visibleItem, hiddenItem },
    visibleSlots = { 1 },
    startingBid = 100,
    totalValue = 215,
}
local preview = {
    id = "LOT_TEST",
    slots = {
        { visible = true, item = visibleItem },
        { visible = false },
    },
    visibleSlots = { 1 },
    startingBid = 100,
}

local previewOutput = LotDebugFormatter.formatPreview(preview)
assert(string.find(previewOutput, "Slot 1: Visible Vase | COMMON | VISIBLE", 1, true), "preview must show visible item")
assert(string.find(previewOutput, "Slot 2: ??? | HIDDEN", 1, true), "preview must redact hidden item")
assert(not string.find(previewOutput, "Hidden Book", 1, true), "preview must not leak hidden identity")

local serverOutput = LotDebugFormatter.formatServerLot(lot)
assert(string.find(serverOutput, "SERVER-ONLY", 1, true), "complete output must be marked server-only")
assert(
    string.find(serverOutput, "Slot 2: Hidden Book | RARE | Value 180 | Income 14/hour", 1, true),
    "server output must include complete data"
)
assert(string.find(serverOutput, "True Value: 215", 1, true), "server output must include true total for debugging")

print("PASS lot_debug_formatter.spec")
