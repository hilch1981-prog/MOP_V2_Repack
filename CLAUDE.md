# Claude Code review instructions — Chipa MoP 5.4.8 PlayerBot V2

This repository is the runtime core for Chipa MoP 5.4.8 PlayerBot V2.

## Role

Claude acts as a **read-only independent reviewer** for pull requests. ChatGPT/Codex remains the implementation/orchestration path. Claude must not directly edit, merge, or mark a gate PASS during automated review.

## Source hierarchy

Use this precedence when evaluating design or ports:

1. Chipa runtime core: `hilch1981-prog/MOP_V2_Repack`, base `repack-main`
2. DigiD702 MoP 5.4.8 module/core references
3. Official mod-playerbots / AzerothCore Playerbot references
4. Legends-of-Azeroth PR #389 only as historical MoP-port evidence

Do not prefer newer upstream behavior when it conflicts with the actual Chipa MoP 5.4.8 core contract.

## Architecture invariants

- Core minimal modification.
- Generic module infrastructure only in Core where required.
- PlayerBot AI, policy, strategies, rotations, quest/travel/random/LFG/PvP behavior remain module-owned.
- Use a compatibility-adapter layer for API differences before adding Core hooks.
- Do not insert class/spec rotations into `Player.cpp`, `WorldSession`, Group, or other generic Core ownership points.
- Existing generic script hooks should be reused rather than duplicating PlayerBot-specific Core paths.
- A passing compile is not enough for runtime or game PASS.

## Canonical gates

Review against these gates in order:

- G1 Generic Module Infrastructure
- G2 `PlayerScript::OnUpdate` bridge
- G3 SelfBot attach/detach
- G4 human movement + AI combat ownership
- G5 Windwalker minimal MoP rotation
- G6 human regression
- G7 disable/remove
- ManagedBot session/login/teleport/logout
- AI engine + Monk 3 specs
- remaining 34 specs
- gameplay/group/quest/loot/vendor/mount
- PlayerBot DB / RandomBot
- MoP Travel
- LFG / Dungeon / LFR / Raid
- PvP
- performance / RC

## Review requirements

For every PR, focus on defects that can affect correctness, buildability, runtime safety, regression risk, ownership boundaries, or source provenance.

Specifically check:

- whether a change is genuinely required for PlayerBot or accidentally repairs unrelated legacy Core code;
- whether MODULES=0 preserves the existing runtime;
- whether MODULES=1 discovers and links the module without creating reverse Core dependency on PlayerBot;
- whether submodule/source SHAs are pinned and provenance is recorded;
- whether Linux/Windows conditional code is properly scoped;
- whether bot-only paths can alter normal human sessions;
- whether the implementation claims a gate PASS without build/runtime/regression evidence;
- whether external-source code was copied without recording origin and adaptation rationale.

## Automated review behavior

- Read the full PR diff and relevant surrounding code.
- Leave actionable inline comments on concrete defects.
- Do not edit files.
- Do not approve merely because CI is green.
- Do not request speculative refactors unrelated to the current gate.
- If no material issue is found, say so explicitly and state which evidence remains outside static review.

The final truth for any gate is repository state plus build/runtime/regression evidence, not an AI review verdict.