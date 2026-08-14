# Relic Auction

Roblox/Luau prototype for a solo-first collectible auction game. This repository currently implements only **MVP v0.1 Phase 1–2** from the supplied development brief.

## Implemented

- Partially managed Rojo project with four reserved `RemoteEvent` instances.
- Server-owned player session with configurable 2,000 starting Coins and `leaderstats.Coins`.
- Six configurable rarity tiers and an original 17-item collectible catalog.
- Server-side weighted generation of eight-item lots with three visible slots.
- Starting bids derived from visible value using configurable rules.
- Redacted client-safe lot previews plus complete server-only Studio Output logs.

Auction bidding, NPCs, reveal, collection actions, and passive income are intentionally deferred to later phases.

See [`docs/PHASE-1-2.md`](docs/PHASE-1-2.md) for the implementation report, generated example lot, known tooling issue, and the required Studio play-test checklist.

## Toolchain

Managed through [Rokit](https://github.com/rojo-rbx/rokit):

```bash
rokit install
```

## Verify Phase 1–2

```bash
lune run tests/player_session.spec.luau
lune run tests/lot_generator.spec.luau
lune run tests/lot_debug_formatter.spec.luau
selene src
selene --config selene-lune.toml tests scripts
stylua --check src tests scripts
rojo build default.project.json --output build/RelicAuction.rbxlx
lune run scripts/generate-example-lot.luau
```

## Roblox Studio

> Manual Studio runtime verification is still pending. A cold automatic launch stalled in Studio's update/plugin startup, so launch Studio normally and wait until it is ready before following these steps.

1. Open or create the Studio place that owns the map and placeholder models.
2. From this directory run `rojo serve default.project.json`.
3. Connect the Rojo Studio plugin to `localhost:34872`.
4. Start a server play test.
5. Verify the player receives `leaderstats.Coins = 2000` and Studio Output shows a redacted preview followed by clearly marked server-only complete lot data.

The source tree intentionally leaves map, placeholder model, and UI-preview ownership in Studio.
