# Verification and performance record

21 October 2026 · Godot 4.6.1 official · Compatibility renderer.

## Verified behavior

Two automated scene tests pass with no script errors. They exercise real terrain collision, WASD movement, jumping, UI bounds, quest ordering, invalid save rejection, all introductory interactions, physical horse travel along the ridge, clear-ground dismount, patrol field of view, the stealth completion trigger, actual gate traversal, delivery, disk persistence, rider/fall recovery, health/blocking/enemy defeat, frozen movement while paused and visible save failure handling.

The independent code review identified three defects (stranded horse, false save success, paused dodge movement). Each has a regression assertion and was fixed. Additional traversal checks caught and fixed a raised courtyard obstructing the gateway.

The web export was served over localhost and the actual 3D title scene and village gameplay were visually inspected in the Chromium-based Codex browser at a requested desktop test viewport of 1280×800. Terrain, sky shader, sunlight/shadows, mountains, fort, characters, flags and menus rendered. Fresh initial rendering had no engine console errors. An earlier session emitted a Chromium `UnknownError`; subsequent pointer-capture/browser interaction calls timed out. Preview servers attached to temporary command sessions also stopped, causing connection-refused pages; a detached localhost-only server was subsequently started. Browser camera control now supports middle-button drag without pointer capture.

**Full interactive browser playthrough, final-revision camera/input verification and browser storage round-trips are not certified.** The headless integration tests are not substitutes for those browser checks. The native Linux export starts headlessly; the Windows export has not been run on Windows.

## Measured build footprint

Before adding plain-text legal notices (rounded):

| Item | Size |
|---|---:|
| Browser bundle, uncompressed | 42.15 MB |
| Godot engine WebAssembly | 37.69 MB |
| Game PCK (code, textures, fonts, audio) | 4.10 MB |
| Browser bundle, gzip-equivalent calculation | 13.58 MB |
| Linux executable with embedded PCK | 75.15 MB |
| Windows executable with embedded PCK | 108.67 MB |

The gzip value is calculated locally from the files, **not a measured network transfer**. The Python development server serves uncompressed files. Real compressed delivery depends on production hosting configuration. Legal notices add approximately 0.2 MB before compression. `build/BUILD_SIZES.json` records final archive and directory sizes.

## Measurements still required

Sustained browser FPS, median/p95 frame time, total browser-process/GPU memory, and cold-cache time-to-play are **unmeasured**. No 30/60 FPS target is claimed. Headless fixed-FPS tests deliberately advance deterministic simulation and cannot benchmark graphics performance.

Press F3 during play for live Godot FPS, static engine allocations in MB and submitted draw calls. Engine static allocations do not include all browser, WebAssembly heap or GPU memory. For certification, run the village → lookout → gate route for 60 seconds on each preset, use browser Performance/Memory tools, disable cache for load tests, and record hardware/browser versions and transfer compression. Repeat on representative lower-end hardware and Firefox/Safari.

## Current cost controls

| Preset | 3D resolution scale | Grass instances | Grass cutoff | Shadows |
|---|---:|---:|---:|---|
| LOW | 65% | 2,400 | 45 m | Off |
| MEDIUM | 80% | 6,000 | 65 m | 75 m |
| HIGH | 90% | 10,500 | 85 m | 130 m |
| ULTRA | 100% | 14,000 | 110 m | 180 m |

Grass, rocks and tree parts use MultiMesh instancing. Trees have a distance cutoff; ordinary frustum culling is provided by Godot. The single connected region is loaded at startup. Fine-grained instance culling, chunk streaming, terrain LOD, lightmap baking and merged masonry are not implemented. Numerous individual architecture/character meshes may limit draw-call performance; richer visual quality and performance certification remain production work.

Export operations completed with exit code 0. Sandboxed editor/export runs printed denied debugger-listen socket messages; those are development-environment restrictions rather than GDScript compilation errors. Source gameplay tests and native startup do not require that debugger socket.

## Graphics update verification (21 October 2026)

Both scene suites pass after the material, animation and story changes. Added assertions cover joint counts, gallop blending, settled legs after stopping, bent running elbows, mounted knee posture, and the longest story dialogue fitting the viewport. Saves and quest event order remain unchanged.

The browser game PCK was rebuilt with Godot 4.6.1. The final revision rendered its title and village scenes in the in-app Chromium browser without reported console warnings or errors. The plaster/timber materials were visually checked after restarting the preview. The screenshot is saved as build/graphics-update.png. A full browser mission playthrough and sustained animation assessment were not performed. Export logs contain environment-related debugger socket/editor-settings errors after successful pack writing. Native executable exports remain unchanged.

The game pack is now approximately 13 MB uncompressed. The earlier build footprint table describes the original build only. FPS, GPU memory and cold-load time for the upgraded art remain unmeasured. Procedural characters are still visibly stylized. There is no skinned character asset, motion capture or terrain-aware hoof placement.
