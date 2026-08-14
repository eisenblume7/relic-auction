export type Session = {
    coins: number,
}

export type InstanceFactory = (className: string) -> any

local PlayerSession = {}
local sessions: { [any]: Session } = {}

function PlayerSession.initialize(player: any, instanceFactory: InstanceFactory, startingCoins: number): Session
    assert(player ~= nil, "player is required")
    assert(type(instanceFactory) == "function", "instanceFactory is required")
    assert(type(startingCoins) == "number" and startingCoins >= 0, "startingCoins must be non-negative")

    local existingSession = sessions[player]
    if existingSession then
        return existingSession
    end

    local session: Session = {
        coins = startingCoins,
    }
    sessions[player] = session

    local leaderstats = instanceFactory("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = instanceFactory("IntValue")
    coins.Name = "Coins"
    coins.Value = session.coins
    coins.Parent = leaderstats

    return session
end

function PlayerSession.get(player: any): Session?
    return sessions[player]
end

function PlayerSession.remove(player: any)
    sessions[player] = nil
end

return PlayerSession
