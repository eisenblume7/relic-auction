# Phase 1–2 Implementation Report

Date: 2026-08-14

## Status

Phase 1 and Phase 2 source implementation and automated verification are complete. The Phase 2 server scripts have also executed successfully in Roblox Studio, producing an eight-slot preview with exactly three visible and five hidden entries plus complete server-only data. Phase 3 has not started.

## Files and responsibilities

### Project/tooling

- `default.project.json` — partially managed Rojo mapping and reserved remotes.
- `rokit.toml` — pins Rojo, Lune, StyLua, and Intel-compatible Selene.
- `selene.toml`, `selene-lune.toml`, `stylua.toml` — lint/format policy.

### Shared

- `src/shared/EconomyConfig.lua` — configurable starting balance.
- `src/shared/AuctionConfig.lua` — lot size, visible count, starting-bid rules, and debug seed/id.
- `src/shared/Rarities.lua` — six rarity tiers and configurable basis-point weights.
- `src/shared/Collectibles.lua` — original collectible definitions and balancing data.
- `src/shared/Types.lua` — core Luau data shapes.
- `src/shared/LotGenerator.lua` — weighted selection, visibility selection, starting bid, true server lot, and redacted preview.

### Server

- `src/server/Bootstrap.server.lua` — joins/removals and initial player setup.
- `src/server/PlayerSession.lua` — authoritative in-session balance and `leaderstats.Coins` adapter.
- `src/server/LotDebug.server.lua` — deterministic Studio startup generation and Output logging.
- `src/server/LotDebugFormatter.lua` — redacted preview and complete server-only debug formatting.

### Tests and scripts

- `tests/player_session.spec.luau`
- `tests/lot_generator.spec.luau`
- `tests/lot_debug_formatter.spec.luau`
- `scripts/generate-example-lot.luau`

## Architecture summary

- Roblox Studio owns the map, placeholder models, UI preview, and play testing.
- Rojo owns scripts, configuration, and the remote hierarchy.
- Player Coins and complete generated lots are server-owned.
- `LotGenerator` receives config/data dependencies and a random source, which keeps generation deterministic in tests and avoids a framework dependency.
- `createPreview` returns only visible collectible data. Hidden slots have `{ visible = false }`, and `totalValue` is excluded.
- No bidding, NPC, reveal, inventory, display, passive-income, persistence, or monetization behavior has been implemented.

## Automated verification

```text
player_session.spec ........ PASS
lot_generator.spec ......... PASS
lot_debug_formatter.spec ... PASS
Selene src ................ 0 errors, 0 warnings
Selene tests/scripts ...... 0 errors, 0 warnings
StyLua check ............... PASS
Rojo build ................. PASS
```

Build artifact: `build/RelicAuction.rbxlx` (ignored by Git and reproducible with Rojo).

## Roblox Studio runtime evidence

The user completed a Studio play test and supplied the server Output. The observed lot had:

- starting bid `200`;
- exactly 8 preview slots;
- visible slots `3`, `5`, and `7`;
- exactly 3 visible and 5 hidden entries;
- complete server-only contents for all 8 slots;
- true value `775`.

The visible preview identities matched the corresponding server-only slot identities. Hidden identities appeared only in the server block.

## Generated example lot

This is the actual output from `lune run scripts/generate-example-lot.luau` with debug seed `10824`:

```text
LOT LOT_001
Starting Bid: 100
Slot 1: Worn Travel Journal | COMMON | VISIBLE
Slot 2: ??? | HIDDEN
Slot 3: ??? | HIDDEN
Slot 4: ??? | HIDDEN
Slot 5: ??? | HIDDEN
Slot 6: Worn Travel Journal | COMMON | VISIBLE
Slot 7: Bronze Sparrow Statue | COMMON | VISIBLE
Slot 8: ??? | HIDDEN

[SERVER-ONLY] LOT_001 COMPLETE CONTENTS
Starting Bid: 100
True Value: 3640
Slot 1: Worn Travel Journal | COMMON | Value 45 | Income 3/hour
Slot 2: Bronze Sparrow Statue | COMMON | Value 60 | Income 4/hour
Slot 3: Old Clay Vase | COMMON | Value 35 | Income 2/hour
Slot 4: Old Clay Vase | COMMON | Value 35 | Income 2/hour
Slot 5: Tideglass Chalice | RARE | Value 260 | Income 19/hour
Slot 6: Worn Travel Journal | COMMON | Value 45 | Income 3/hour
Slot 7: Bronze Sparrow Statue | COMMON | Value 60 | Income 4/hour
Slot 8: Astral Signet Ring | LEGENDARY | Value 3100 | Income 230/hour
```

The Studio `Random` implementation may produce a different deterministic sequence from the Lune harness, but both use the same weights, catalog, slot count, visibility count, and bid rules.

## Errors encountered

1. Selene 0.31.0 installed an ARM64 macOS artifact on this Intel Mac and failed with `Bad CPU type in executable (os error 86)`. Investigation found 0.26.1 is the latest verified x86_64 artifact, so `rokit.toml` pins that version.
2. Roblox Studio 0.734.0.7340915 remained in startup/plugin initialization when the generated `.rbxlx` was opened during a cold automatic launch. Launching Studio normally and connecting through the intended Rojo workflow subsequently succeeded and produced valid server Output.

## Remaining manual check

The supplied Output verifies Phase 2 runtime behavior. Before beginning Phase 3, visually confirm that the local player has `leaderstats > Coins = 2000`; the starting-balance behavior already passes its automated specification.

## Remaining for Phase 3

After the remaining Coins check:

- explicit auction state machine;
- IDLE → PREVIEW → BIDDING → RESOLVING transitions needed by the phase;
- auction start action;
- configured three-round progression;
- client-safe auction state payloads;
- server validation for future Raise/Pass actions.

NPC bidder behavior remains Phase 4 and must not be pulled into Phase 3 prematurely.
