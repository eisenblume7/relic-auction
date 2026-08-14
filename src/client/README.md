# Client source

Phase 3 introduces `AuctionController.client.lua`, a lightweight native Roblox UI adapter.

The client:

- renders the server's redacted lot preview;
- displays Coins, current bid, phase, and round;
- sends action names only: `START_AUCTION`, `START_BIDDING`, `RAISE`, and `PASS`;
- never sends a bid amount, budget, lot identity, rarity result, or economic state;
- disables controls while waiting for the next server state.

Presentation text and control visibility are derived by the testable shared `AuctionPresentation` module. Final visual polish remains outside MVP Phase 3.
