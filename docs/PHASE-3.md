# Phase 3 Implementation Report

Date: 2026-08-14

## Status

Phase 3 source implementation and targeted automated verification are complete. Roblox Studio interaction verification is pending. NPC behavior is not implemented and remains Phase 4.

## Scope delivered

- explicit auction state machine;
- `IDLE → PREVIEW → BIDDING → RESOLVING` progression;
- server-created auction lots and lot IDs;
- client-safe preview state;
- configurable three-round bidding;
- player `RAISE` and `PASS` decisions;
- server-calculated raise increment;
- server-owned balance validation;
- validated RemoteEvent protocol;
- minimal native Roblox auction UI.

## State machine

`AuctionStateMachine` begins in `IDLE`.

```text
START_AUCTION
IDLE → PREVIEW

START_BIDDING
PREVIEW → BIDDING (Round 1)

RAISE / PASS
Round 1 → Round 2 → Round 3

Final round action
BIDDING → RESOLVING
```

Phase 3 intentionally stops at `RESOLVING`. It does not select a winner, deduct Coins, or transfer the lot.

## Remote protocol

The client sends only one of these action strings through `AuctionAction`:

```text
START_AUCTION
START_BIDDING
RAISE
PASS
```

No action accepts a client-supplied price. Any payload is rejected with `PAYLOAD_NOT_ALLOWED`. Unknown action strings are rejected with `INVALID_ACTION`. Invalid phase transitions return `INVALID_STATE`.

A raise is calculated on the server:

```text
nextBid = currentBid + AuctionConfig.MINIMUM_RAISE
```

The server compares `nextBid` with the player's server-owned session balance. A rejected raise does not change the bid or consume a round.

## Security boundaries

- Complete lots stay inside server modules.
- `LotGenerator:createPreview` remains the only source for the public lot payload.
- Hidden slots contain no `item` field.
- True lot value is omitted.
- The client cannot choose the lot ID, starting bid, current bid, increment, round, phase, or budget.
- Remote rejection state is constructed from server state and never reflects arbitrary client payload data.
- Phase 3 does not charge the player; payment remains Phase 5 winner resolution.

## Files added

### Shared

- `src/shared/AuctionPresentation.lua`

### Server

- `src/server/AuctionStateMachine.lua`
- `src/server/AuctionService.lua`
- `src/server/AuctionRemoteHandler.lua`
- `src/server/AuctionRuntime.server.lua`

### Client

- `src/client/AuctionController.client.lua`

### Tests

- `tests/auction_state_machine_start.spec.luau`
- `tests/auction_state_machine_config.spec.luau`
- `tests/auction_state_machine_rounds.spec.luau`
- `tests/auction_state_machine_validation.spec.luau`
- `tests/auction_service.spec.luau`
- `tests/auction_remote_handler.spec.luau`
- `tests/auction_presentation.spec.luau`

## Configuration added

```lua
BIDDING_ROUNDS = 3
MINIMUM_RAISE = 50
```

Both values live in `AuctionConfig`; state logic and presentation do not hardcode the increment or round limit.

## Ad-hoc verification evidence

A focused temporary verification script was created under the OS temporary directory, executed, and removed. It verified:

```text
auction_state_machine_start.spec ......... PASS
auction_state_machine_config.spec ........ PASS
auction_state_machine_rounds.spec ........ PASS
auction_state_machine_validation.spec .... PASS
auction_service.spec ..................... PASS
auction_remote_handler.spec .............. PASS
auction_presentation.spec ................ PASS
Selene source ............................ 0 errors, 0 warnings
Selene tests/scripts ..................... 0 errors, 0 warnings
StyLua check ............................. PASS
Rojo build ............................... PASS
Required Phase 3 build nodes ............. PRESENT
```

This is targeted ad-hoc verification, not yet Roblox Studio interaction evidence.

## Roblox Studio checklist

1. Run `rojo serve default.project.json` and connect Studio.
2. Start a server play test.
3. Confirm the native auction panel appears and Coins displays `2000`.
4. Select **Start Auction**.
5. Confirm the preview contains eight slots with exactly three visible items.
6. Confirm hidden slots display only `??? / HIDDEN`.
7. Select **Start Bidding** and confirm `Round 1 / 3`.
8. Complete three decisions using **Raise +50** and **Pass**.
9. Confirm each action advances exactly one round.
10. Confirm Raise increases the bid by 50 and Pass does not change it.
11. Confirm the third action enters `RESOLVING` and removes bidding controls.
12. Confirm Studio Output has no red project-script errors.

## Remaining for Phase 4

Only after this checklist passes:

- Scholar evaluation personality;
- Merchant evaluation personality;
- Collector evaluation personality;
- imperfect perceived-value calculations;
- controlled randomness and per-NPC budgets;
- NPC decisions integrated into each bidding round.

Winner resolution and payment remain Phase 5.
