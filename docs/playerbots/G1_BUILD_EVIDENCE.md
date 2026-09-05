# PlayerBot V2 G1 build evidence

Gate: **G1 - Generic Module Infrastructure**

This file records build evidence only. It does **not** mark G1 PASS.

## Evidence from workflow run 33550496039

- Triggered head SHA: `65bda731c448a36f57698f9748b272711077ec5b`.
- Pull-request checkout/merge SHA recorded by the workflow: `bf3696eba5aea42465a4978616a987856ea1d9c3`.
- PlayerBot submodule SHA: `78bc93512f8c3b26175321e98eb0bede42917ce6`.
- `MODULES=0`: configure succeeded; full build reached `1122/1316` before Ninja stopped on the first fatal source error.
- `MODULES=1`: module discovery succeeded; full build reached `1123/1320` before Ninja stopped on the same fatal source error.
- Both modes reported C++ list-initialization narrowing failures in `src/server/scripts/Events/hallows_end.cpp` because legacy flattened position tables attempted to initialize nested `Position` objects that have a user-provided constructor.
- No `worldserver` output verification was reached in that run.

## Corrective change

Commit `f88e7585fc8e47ec752360e3f6778841a0a1cd58` keeps the legacy table scalar data unchanged while introducing an aggregate-compatible local position adapter that converts to `Position` at existing call sites. The temporary one-shot mutation workflow removed itself in the same commit.

## Remaining G1 evidence

G1 remains pending until both `MODULES=0` and `MODULES=1` complete clean builds, `worldserver` output/boot evidence is collected, and the required human regression/smoke evidence is available.
