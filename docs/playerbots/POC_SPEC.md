# Chipa PlayerBot V2 - POC Specification

Status: **Architecture v0.1 execution gate**  
Target: **World of Warcraft Mists of Pandaria 5.4.8 Build 18414**  
Runtime repository: `hilch1981-prog/MOP_V2_Repack`  
Runtime baseline branch: `repack-main`  
Runtime baseline commit: `0739d072f8f1f42523f04cca4b2607d88a01def4`  
POC branch: `playerbot-v2-poc`

## 1. Purpose

이 문서는 PlayerBot V2 Architecture v0.1이 실제 Chipa MoP 5.4.8 runtime에서 성립하는지 검증하기 위한 **정식 POC Gate 문서**다.

POC의 목표는 PlayerBot 전체 기능을 완성하는 것이 아니다. 다음 구조가 실제로 작동함을 증명하는 것이 목표다.

```text
Chipa Core
  -> Generic Module Infrastructure
  -> Module Integration / Compatibility Boundary
  -> PlayerBot AI entry path
  -> SelfBot
  -> MoP Windwalker minimal rotation
```

POC가 성공했다는 것은 **Core 최소 수정 + Generic Module + Adapter/Integration + AI Engine + MoP Rotation** 구조가 치파팩에서 성립한다는 의미다.

## 2. Source-of-truth and donor policy

- Final runtime source of truth: `hilch1981-prog/MOP_V2_Repack`
- Primary MoP implementation donor: `DigiD702/mod-playerbots`
- Primary MoP Core bridge reference: `DigiD702/skyfire_548_playerbots`
- Generic AI/feature reference: `mod-playerbots/mod-playerbots`
- Historical MoP reference: Legends of Azeroth PR #389
- External repositories are imported feature-by-feature only.
- No whole-repository merge/cherry-pick is accepted as a POC shortcut.
- All imported code must preserve provenance and pass architecture/build/runtime/regression gates.

Detailed frozen source baselines are recorded in `docs/playerbots/SOURCE_BASELINE.md`.

## 3. Verification state model

POC evidence uses the Architecture v0.1 verification states.

| State | Meaning |
|---|---|
| V0 | NOT_PRESENT |
| V1 | SOURCE_PRESENT |
| V2 | PORTED |
| V3 | STATIC_PASS |
| V4 | BUILD_PASS |
| V5 | BOOT_PASS |
| V6 | RUNTIME_PASS |
| V7 | GAME_PASS |
| V8 | REGRESSION_PASS |
| V9 | RELEASE_VERIFIED |

A feature is not considered complete merely because source code exists.

## 4. Evidence rules

Each Gate result must record at least:

- Gate ID
- Runtime commit SHA
- Module commit SHA when applicable
- Toolchain / generator / build configuration
- Configuration flags
- Steps executed
- Expected result
- Actual result
- PASS / FAIL / BLOCKED classification
- Relevant compiler output, server log, screenshot, video, combat log, DB result, or crash information

For this POC, `BUILD PASS` means the **whole Chipa runtime target** builds, not only a PlayerBot translation unit.

## 5. Architecture rejection rules

A Gate must be rejected even if the feature appears to work when any of the following occurs:

- Core `game` target gains a PlayerBot source/header dependency.
- PlayerBot AI/rotation/policy is moved into Chipa Core.
- `WorldSession` owns `PlayerbotAI` or other AI policy state.
- Module Loader becomes PlayerBot-specific.
- External AzerothCore/Digi Core files replace Chipa Core wholesale.
- WotLK spell/talent/opcode/data is accepted without MoP validation.
- Human-player behavior regresses.

## 6. Canonical POC Gate sequence

The canonical Architecture v0.1 POC sequence is:

```text
POC-G0  Baseline
  -> POC-G1  Generic Module Infrastructure
  -> POC-G2  PlayerScript Bridge
  -> POC-G3  SelfBot Attach / Detach
  -> POC-G4  SelfBot Control Ownership
  -> POC-G5  Windwalker Minimal Rotation
  -> POC-G6  Human Regression
  -> POC-G7  Disable / Remove
```

A minimal Compatibility/Integration layer may be introduced as needed during G2-G5, but it is **not a separate numbered Gate in this v0.1 specification**. This numbering is the canonical reference for future PR descriptions and test records.

---

# POC-G0 - Chipa Baseline

## Goal

PlayerBot changes are judged against a known-good Chipa runtime baseline.

## Required evidence

At frozen baseline `0739d072f8f1f42523f04cca4b2607d88a01def4`:

- Full configure/build succeeds.
- `worldserver` boots to normal ready state.
- Human character login succeeds.
- Basic human movement succeeds.
- Basic human combat succeeds.

## PASS condition

All baseline checks are recorded before regression claims are made.

---

# POC-G1 - Generic Module Infrastructure

## Goal

Prove that Chipa can discover, compile, link and invoke an optional module **without a Core -> PlayerBot source dependency**.

This is the current Gate for Draft PR #1.

## Frozen POC module input

- Module repository: `hilch1981-prog/mod-playerbots`
- Module branch: `mop-5.4.8-v2`
- Pinned submodule commit: `78bc93512f8c3b26175321e98eb0bede42917ce6`
- Manifest: `chipa_module.cmake`
- Explicit POC source: `src/chipa/ModuleBootstrap.cpp`
- Loader symbol: `Addmod_playerbotsScripts()`

`ModuleBootstrap.cpp` is intentionally empty of AI/session/database/game policy. It exists only to prove module discovery, compilation, linking and loader invocation.

## G1 static architecture checks

Must all be true:

- `modules/` is generic and not PlayerBot-specific.
- A module is compiled only when it contains `chipa_module.cmake`.
- Manifest lists sources explicitly.
- Untouched upstream `src/` is not globbed into the Chipa build.
- Generated `AddModulesScripts()` aggregates module loaders.
- Core scripts run before optional module scripts.
- `modules` links to `game`; `game` does not link to PlayerBot.
- No PlayerBot header is required by Chipa Core source.
- `MODULES=0` removes module compilation from the runtime build path.

## G1-B1 - Modules OFF build

Configuration:

```text
SERVERS=1
MODULES=0
```

Use a **clean build directory** and the same compiler/generator/toolchain used for the Chipa baseline.

Required result:

- Configure succeeds.
- `modules/` is not configured/built.
- PlayerBot submodule code is not compiled.
- Whole Chipa server build succeeds.
- `worldserver` links successfully.

Evidence to record:

- Configure command / preset / generator
- Build command
- Build directory identity
- Final build result
- Relevant final linker output

## G1-B2 - Modules ON build

Precondition:

- Submodules initialized and synchronized.
- `modules/mod-playerbots` resolves exactly to `78bc93512f8c3b26175321e98eb0bede42917ce6`.

Configuration:

```text
SERVERS=1
MODULES=1
```

Use a **separate clean build directory** from G1-B1.

Required configure evidence:

```text
* Configuring Chipa modules
  + module: mod-playerbots
* Configured 1 Chipa module(s)
```

Required build result:

- Only manifest-approved POC module source is compiled from `mod-playerbots`.
- Generated `ModulesLoader.cpp` is produced.
- `AddModulesScripts()` resolves successfully.
- `Addmod_playerbotsScripts()` resolves successfully.
- Whole Chipa server build succeeds.
- `worldserver` links successfully.

## G1-B3 - Worldserver boot

Using the G1-B2 build and the existing known-good Chipa server configuration/database:

Required result:

- Process starts without loader/link/runtime symbol failure.
- Core scripts initialize normally.
- Module script bridge executes without crash.
- Empty `Addmod_playerbotsScripts()` invocation does not alter normal world initialization.
- Server reaches the same normal ready state used by G0.

Because the G1 bootstrap loader is intentionally empty, **absence of PlayerBot gameplay functionality is expected** at this Gate.

## G1 regression check

After modules-on boot:

- Human login still succeeds.
- Basic movement still succeeds.
- Basic combat still succeeds.

This is a smoke regression check only; full POC human regression is G6.

## G1 PASS condition

G1 is PASS only when all of the following are true:

- Static architecture checks: PASS
- G1-B1 `MODULES=0` clean build: PASS
- G1-B2 `MODULES=1` clean build: PASS
- G1-B3 worldserver boot: PASS
- Human smoke regression: PASS

Until then Draft PR #1 must remain **Draft / DO NOT MERGE**.

---

# POC-G2 - PlayerScript Bridge

## Goal

Validate the runtime path:

```text
PlayerScript::OnUpdate
  -> module integration
  -> PlayerbotMgr
```

## PASS conditions

- Chipa Core uses its existing PlayerScript update capability.
- No new PlayerBot-specific AI tick is injected into `Player.cpp`.
- Human players not registered as bots return immediately from PlayerBot handling.
- AI update can be throttled by the module.
- G1 architecture remains intact.

---

# POC-G3 - SelfBot Attach / Detach

## Goal

Attach PlayerBot AI to an already logged-in human `Player` without replacing the real client `WorldSession`.

## Required tests

- Attach
- Duplicate attach protection
- Detach
- Relog
- Logout
- Death
- Map change

## PASS conditions

- Existing client session remains authoritative.
- No socketless login path is required.
- AI lifecycle is owned by the module.
- Detach leaves the human character normal and playable.

---

# POC-G4 - SelfBot Control Ownership

## Goal

Validate initial SelfBot ownership policy:

```text
Human -> movement / jump / normal client control
AI    -> combat cast decisions
```

## PASS conditions

- AI does not forcibly move the player in initial cast-only mode.
- Human movement and jumping remain responsive.
- Human can change target manually.
- AI uses normal Core spell-cast paths.
- AI does not directly inject damage, aura, power or cooldown state.

---

# POC-G5 - Windwalker Minimal Rotation

## Goal

Prove the complete path:

```text
AI Engine
  -> MoP Windwalker decision
  -> Spell Service / Compat
  -> Chipa normal Core cast path
```

The first POC does not target optimal DPS.

## Minimum checks

- Monk specialization detection
- Known-spell validation
- Valid target
- Energy
- Chi
- GCD
- Range
- Facing
- Cooldown
- Buff/debuff checks
- No illegal cast

Initial priority evidence should cover the validated MoP donor flow including, where available to the test character:

- Rising Sun Kick
- Tiger Palm
- Fists of Fury
- Blackout Kick
- Jab

## PASS condition

The chain works through normal Chipa spell validation without bypassing Core game rules.

---

# POC-G6 - Human Regression

## Goal

Prove that a human player with no SelfBot attached behaves as before PlayerBot integration.

## Required checks

- Login
- Logout
- Movement
- Teleport
- Combat
- Group
- Quest basic flow

Any confirmed human regression fails the POC regardless of PlayerBot feature success.

---

# POC-G7 - Disable / Remove

## Goal

Prove PlayerBot remains optional and removable.

## Required configurations

### Runtime disable

```text
Playerbots.Enable=0
```

When the runtime option exists, disabling PlayerBot must leave normal Chipa behavior intact.

### Compile-time disable

```text
MODULES=0
```

The whole Chipa server must build/boot without module code.

## PASS condition

PlayerBot can be disabled/removed without making the Core unusable or requiring PlayerBot source headers in Core.

---

# 7. POC completion rule

The Architecture v0.1 POC is considered successful only after G0-G7 are all evidence-backed PASS.

POC success does **not** mean ManagedBot, RandomBot, Travel, LFG/LFR, Raid, BG/Arena or all 34 specializations are complete.

The immediate post-POC implementation order is determined only after the POC result is written and reviewed.

# 8. Post-POC Gate direction

After G0-G7:

1. ManagedBot socketless WorldSession
2. Server-side character login
3. Near/Far teleport completion
4. Repeated login/logout lifecycle
5. Human + ManagedBot group flow
6. Small RandomBot pool
7. L100 and later performance gates

These are not prerequisites for the first SelfBot architecture POC.

# 9. Current execution status

As of the creation of this document:

| Gate | Status |
|---|---|
| G0 | Evidence not yet attached to this document |
| G1 static/source integration | PASS at source inspection level |
| G1-B1 modules off build | PENDING |
| G1-B2 modules on build | PENDING |
| G1-B3 worldserver boot | PENDING |
| G2-G7 | NOT STARTED |

Draft PR #1 remains the active implementation PR for G1 and must not be merged until the G1 PASS condition is satisfied.
