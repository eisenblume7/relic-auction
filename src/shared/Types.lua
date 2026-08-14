export type Collectible = {
    id: string,
    name: string,
    rarity: string,
    value: number,
    incomePerHour: number,
    category: string,
}

export type RarityDefinition = {
    id: string,
    displayName: string,
    weight: number,
    order: number,
    colorHex: string,
}

export type ServerLot = {
    id: string,
    slots: { Collectible },
    visibleSlots: { number },
    startingBid: number,
    totalValue: number,
}

export type PreviewSlot = {
    visible: boolean,
    item: Collectible?,
}

export type LotPreview = {
    id: string,
    slots: { PreviewSlot },
    visibleSlots: { number },
    startingBid: number,
}

return {}
