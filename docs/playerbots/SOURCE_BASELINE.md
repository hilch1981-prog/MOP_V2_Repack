# Chipa PlayerBot V2 - Source Baseline

Status: Architecture v0.1 implementation baseline
Target: World of Warcraft Mists of Pandaria 5.4.8 Build 18414

## S0 - Final runtime core

- Repository: `hilch1981-prog/MOP_V2_Repack`
- Branch: `repack-main`
- Frozen baseline commit: `0739d072f8f1f42523f04cca4b2607d88a01def4`
- POC branch: `playerbot-v2-poc`
- Role: final source of truth. External PlayerBot projects must adapt to this core, not the reverse.

## S1 - MoP PlayerBot module donor

- Repository: `DigiD702/mod-playerbots`
- Branch: `main`
- Frozen baseline commit: `13bc0ffa93c6b6625ed28fe2a03e0c071215ff48`
- Role: primary MoP 5.4.8 donor for SelfBot, class/spec rotations, Monk, AI engine behavior and MoP-specific implementation patterns.
- Integration rule: selective port through Chipa compatibility boundaries. Do not merge blindly.

## S2 - Existing user fork of official PlayerBots

- Repository: `hilch1981-prog/mod-playerbots`
- Default branch: `master`
- Fork parent: `mod-playerbots/mod-playerbots`
- Role: official AzerothCore PlayerBots reference fork only.
- Important: this repository is NOT a fork of `DigiD702/mod-playerbots` and must not be treated as the MoP module baseline.

## S3 - Official PlayerBots module

- Repository: `mod-playerbots/mod-playerbots`
- Role: generic Strategy / Trigger / Action / Value, world AI, dungeon/raid features and long-term upstream feature reference.
- Rule: WotLK-specific code, spell IDs, talents, opcodes and data require MoP conversion or rejection.

## S4 - DigiD702 SkyFire core donor

- Repository: `DigiD702/skyfire_548_playerbots`
- Role: reference for Socketless WorldSession, bot login, teleport completion and other MoP core bridge requirements.
- Rule: do not replace Chipa core with this repository; only compare and port the minimum missing bridge.

## S5 - Legends of Azeroth PR #389

- Repository/PR: `Legends-of-Azeroth/Legends-of-Azeroth-Pandaria-5.4.8#389`
- Role: historical MoP PlayerBot port evidence, Strategy/Action implementation reference and DB/core-hook comparison source.
- Rule: not a runtime base. Data is not automatically considered MoP-validated.

## Baseline policy

1. Never record only `main`, `master` or another moving branch as a reproducible baseline; pin a commit SHA.
2. `MOP_V2_Repack` is the final runtime source of truth.
3. DigiD702 is the primary MoP implementation donor.
4. Official PlayerBots is the primary generic feature/AI donor.
5. PR #389 is a reference and evidence source, not a merge target.
6. External changes are imported feature-by-feature and must pass architecture, build, runtime and regression gates.
7. A new upstream review must create a new candidate baseline; do not silently overwrite this baseline.
