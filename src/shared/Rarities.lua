local Rarities = {
    {
        id = "COMMON",
        displayName = "Common",
        weight = 5_500,
        order = 1,
        colorHex = "#A8ADB5",
    },
    {
        id = "RARE",
        displayName = "Rare",
        weight = 2_500,
        order = 2,
        colorHex = "#4E8DFF",
    },
    {
        id = "EPIC",
        displayName = "Epic",
        weight = 1_200,
        order = 3,
        colorHex = "#9A5CFF",
    },
    {
        id = "LEGENDARY",
        displayName = "Legendary",
        weight = 600,
        order = 4,
        colorHex = "#FF9F2F",
    },
    {
        id = "MYTHICAL",
        displayName = "Mythical",
        weight = 180,
        order = 5,
        colorHex = "#F14668",
    },
    {
        id = "BIBLICAL",
        displayName = "Biblical",
        weight = 20,
        order = 6,
        colorHex = "#FFD65A",
    },
}

for _, rarity in Rarities do
    table.freeze(rarity)
end

table.freeze(Rarities)

return Rarities
