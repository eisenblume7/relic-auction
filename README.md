# Relic Auction

A lightweight, solo-first Roblox collectible auction prototype built with **Luau**, **Rojo**, and **Roblox Studio**.

The player studies partially revealed auction lots, estimates their value under uncertainty, competes in round-based bidding, reveals won collectibles, and eventually uses those collectibles to build a passive-income collection.

> **Current milestone:** MVP v0.1 Phase 3. The project now includes a server-authoritative auction state machine, preview, and three player bidding rounds. NPC bidders and winner resolution remain intentionally deferred.

## Core loop

```text
AUCTION LOT
    ↓
OBSERVE PARTIAL INFORMATION
    ↓
DECIDE VALUE
    ↓
BID AGAINST NPCs
    ↓
WIN / LOSE
    ↓
REVEAL ITEMS
    ↓
DISPLAY / SELL
    ↓
PASSIVE INCOME
    ↓
NEXT AUCTION
```

The loop is implemented through the player's three round-based `RAISE`/`PASS` decisions. NPC competition, winner resolution, reveal, collection, and income remain later phases.

## Current status

| Phase | Scope | Status |
|---|---|---|
| Phase 1 | Rojo structure, remotes, player session, starting Coins | Implemented and automatically tested |
| Phase 2 | Rarities, collectibles, weighted `LotGenerator`, redacted preview | Implemented, tested, and executed in Roblox Studio |
| Phase 3 | Auction state machine and round-based bidding | Implemented and automatically verified; Studio play test pending |
| Phase 4+ | NPC bidders, winner resolution, reveal, collection, income | Not started |

## Implemented features

- Partially managed Rojo workflow.
- Configurable starting balance of **2,000 Coins**.
- Server-owned player session and `leaderstats.Coins`.
- Four reserved `RemoteEvent` instances for future phases.
- Six configurable rarity tiers:
  - `COMMON`
  - `RARE`
  - `EPIC`
  - `LEGENDARY`
  - `MYTHICAL`
  - `BIBLICAL`
- Original 17-item collectible catalog.
- Weighted rarity selection using configurable basis-point weights.
- Exactly eight collectibles per generated lot.
- Exactly three visible and five hidden slots.
- Configurable starting-bid calculation based on visible value.
- Client-safe preview generation that redacts hidden identities and true total value.
- Complete server-only debug output for Studio testing.
- Deterministic Lune harness for repeatable local verification.
- Explicit `IDLE → PREVIEW → BIDDING → RESOLVING` auction state machine.
- Three configured bidding rounds with server-calculated `RAISE +50` and `PASS`.
- Server-side budget validation and rejection of client-submitted prices or payloads.
- Native Roblox auction UI with eight lot slots and phase-specific controls.

## Architecture

```text
src/
├── client/
│   ├── AuctionController.client.lua
│   └── README.md
├── shared/
│   ├── AuctionConfig.lua
│   ├── AuctionPresentation.lua
│   ├── Collectibles.lua
│   ├── EconomyConfig.lua
│   ├── LotGenerator.lua
│   ├── Rarities.lua
│   └── Types.lua
└── server/
    ├── AuctionRemoteHandler.lua
    ├── AuctionRuntime.server.lua
    ├── AuctionService.lua
    ├── AuctionStateMachine.lua
    ├── Bootstrap.server.lua
    ├── LotDebug.server.lua
    ├── LotDebugFormatter.lua
    └── PlayerSession.lua

tests/
├── auction_presentation.spec.luau
├── auction_remote_handler.spec.luau
├── auction_service.spec.luau
├── auction_state_machine_config.spec.luau
├── auction_state_machine_rounds.spec.luau
├── auction_state_machine_start.spec.luau
├── auction_state_machine_validation.spec.luau
├── lot_debug_formatter.spec.luau
├── lot_generator.spec.luau
└── player_session.spec.luau

scripts/
└── generate-example-lot.luau
```

### Ownership boundaries

**Server owns:**

- Coins and player session state;
- complete generated lot contents;
- hidden collectible identities;
- true lot value;
- rarity outcomes;
- starting bid.

**Client will own only:**

- input;
- UI presentation;
- animation;
- camera and local effects.

The Phase 3 remote accepts only action names. Raise values and player budgets are derived and validated on the server; arbitrary payloads are rejected.

## Toolchain

- Roblox Studio
- Luau
- Rojo 7.7.0
- Lune 0.10.5
- StyLua 2.5.2
- Selene 0.26.1 on Intel macOS
- Git

Tools are managed with [Rokit](https://github.com/rojo-rbx/rokit):

```bash
rokit install
```

> Selene is pinned to `0.26.1` because newer macOS release artifacts tested during development were ARM64-only and could not run on the Intel development machine.

## Getting started

### 1. Install project tools

```bash
cd /Users/macbookair/Documents/project/relic-auction
rokit install
```

### 2. Start Rojo

```bash
rojo serve default.project.json
```

Rojo serves on:

```text
localhost:34872
```

### 3. Connect Roblox Studio

1. Launch Roblox Studio normally and wait for startup/plugin initialization to finish.
2. Open or create a Baseplate place that owns the map and placeholder models.
3. Open the Rojo Studio plugin.
4. Connect to `localhost:34872`.
5. Start a server play test.

### 4. Verify Phase 1–3

In Explorer, check:

```text
Player
└── leaderstats
    └── Coins = 2000
```

In Output, check for:

```text
[Relic Auction] Generated Phase 2 preview
[Relic Auction] Generated Phase 2 server data
```

The preview must contain eight slots with three visible and five hidden entries. The server-only block must contain all eight collectible identities and the true value.

## Verified Studio output

The Phase 2 scripts have executed successfully in Roblox Studio. One observed generated lot produced:

```text
LOT LOT_001
Starting Bid: 200
Slot 1: ??? | HIDDEN
Slot 2: ??? | HIDDEN
Slot 3: Tideglass Chalice | RARE | VISIBLE
Slot 4: ??? | HIDDEN
Slot 5: Old Clay Vase | COMMON | VISIBLE
Slot 6: ??? | HIDDEN
Slot 7: Old Clay Vase | COMMON | VISIBLE
Slot 8: ??? | HIDDEN
```

The corresponding server-only data contained all eight items and a true value of `775`. This confirms that Studio executes the generator, preserves slot positions, exposes exactly three collectibles, and retains hidden contents on the server.

## Automated verification

Run all current behavior checks:

```bash
lune run tests/player_session.spec.luau
lune run tests/lot_generator.spec.luau
lune run tests/lot_debug_formatter.spec.luau
lune run tests/auction_state_machine_start.spec.luau
lune run tests/auction_state_machine_rounds.spec.luau
lune run tests/auction_state_machine_validation.spec.luau
lune run tests/auction_service.spec.luau
lune run tests/auction_remote_handler.spec.luau
lune run tests/auction_presentation.spec.luau
lune run tests/auction_state_machine_config.spec.luau
selene src
selene --config selene-lune.toml tests scripts
stylua --check src tests scripts
rojo build default.project.json --output build/RelicAuction.rbxlx
lune run scripts/generate-example-lot.luau
```

Expected result:

```text
10 behavior specs pass
Selene reports 0 errors and 0 warnings
StyLua check passes
Rojo build succeeds
Generated preview has 8 slots, 3 visible, and 5 hidden
```

## Configuration

Balancing values are kept outside gameplay logic:

| File | Responsibility |
|---|---|
| `src/shared/EconomyConfig.lua` | Starting Coins |
| `src/shared/AuctionConfig.lua` | Lot size, visible count, bid calculation, rounds, raise increment, debug seed |
| `src/shared/Rarities.lua` | Rarity names and weights |
| `src/shared/Collectibles.lua` | Item names, rarity, value, income, category |

Current rarity weights:

| Rarity | Weight |
|---|---:|
| Common | 55% |
| Rare | 25% |
| Epic | 12% |
| Legendary | 6% |
| Mythical | 1.8% |
| Biblical | 0.2% |

## Development constraints

The prototype intentionally avoids:

- large frameworks;
- per-frame economy loops;
- unnecessary physics;
- complex humanoid NPCs;
- persistence and offline income;
- monetization;
- trading or multiplayer PvP auctions;
- final UI, VFX, sound, meshes, or generated 3D assets.

Roblox Studio remains responsible for the map, placeholder models, UI preview, and play testing. The filesystem remains responsible for scripts and configuration.

## Phase 3 Studio checklist

1. Start a play test and verify the auction panel appears.
2. Select **Start Auction** and confirm an eight-slot preview with three visible entries.
3. Select **Start Bidding** and confirm `Round 1 / 3`.
4. Use any sequence of **Raise +50** and **Pass** for three rounds.
5. Confirm each accepted action advances exactly one round.
6. Confirm a raise changes the server-owned bid by exactly 50 Coins and a pass leaves it unchanged.
7. Confirm the final action enters `RESOLVING` and disables bidding controls.
8. Confirm no hidden identity or true lot value appears in client UI or client-visible state.

## Next milestone: Phase 4

After the Phase 3 Studio checklist passes, Phase 4 adds the Scholar, Merchant, and Collector bidder personalities. Winner resolution remains Phase 5.

## Documentation

- [`docs/PHASE-1-2.md`](docs/PHASE-1-2.md) — implementation report, verification evidence, generated lots, and known tooling notes.
- [`docs/PHASE-3.md`](docs/PHASE-3.md) — state machine, remote protocol, security boundaries, and Studio checklist.
- The original development brief is kept as a local Hermes attachment and is intentionally excluded from Git.
