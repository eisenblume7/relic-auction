local EconomyConfig = require("../src/shared/EconomyConfig")
local PlayerSession = require("../src/server/PlayerSession")

local created = {}
local function fakeInstanceFactory(className)
    local instance = {
        ClassName = className,
    }
    table.insert(created, instance)
    return instance
end

local player = {
    Name = "TestPlayer",
}

local session = PlayerSession.initialize(player, fakeInstanceFactory, EconomyConfig.STARTING_COINS)

assert(session.coins == 2_000, "new player session must start with 2,000 configured Coins")
assert(PlayerSession.get(player) == session, "server must retain the authoritative session")
assert(created[1].ClassName == "Folder", "leaderstats must be a Folder")
assert(created[1].Name == "leaderstats", "leaderstats folder must use Roblox's expected name")
assert(created[1].Parent == player, "leaderstats must be parented to the player")
assert(created[2].ClassName == "IntValue", "Coins must be represented by an IntValue")
assert(created[2].Name == "Coins", "the balance value must be named Coins")
assert(created[2].Value == 2_000, "the Coins IntValue must mirror the configured starting balance")
assert(created[2].Parent == created[1], "Coins must be parented to leaderstats")

PlayerSession.remove(player)
assert(PlayerSession.get(player) == nil, "removed players must not retain server session state")

print("PASS player_session.spec")
