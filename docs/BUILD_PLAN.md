# MAVALA build plan

The supplied project brief is the specification and explicitly requests immediate implementation. This is a new project; implement directly in this workspace, without additional design approval rounds. No existing source, callers, fixtures, or saved data exist.

## Scope and architecture

Godot 4.6.1, typed GDScript, Compatibility renderer, single-threaded WebAssembly export. Original procedural Maharashtra-inspired geometry; individually verified CC0 natural textures. User images guide composition, light, costume and typography; do not distribute the reference collages as game assets.

- `world/landscape.gd`: continuous collision terrain, fort, village, instanced vegetation, atmosphere.
- `characters/mavala.gd`, `characters/warrior_visual.gd`, `characters/horse.gd`: movement, camera, animated articulated costumes, riding.
- `gameplay/mission.gd`, `gameplay/patrol.gd`: staged quest, validated versioned saves, patrol/combat.
- `ui/interface.gd`: main/pause menus, objectives, journal, settings, credits.
- `core/game.gd`: scene composition and input wiring.
- `tests/smoke.gd`: live physics movement, jumping, crouching, riding, quest ordering, save validation, combat.
- `tools/serve.py`: static build server; `export_presets.cfg`: Web/Linux/Windows builds.

## Tasks

1. Write a failing smoke test for terrain, controller and mission contracts; implement the runnable foundation and validate imports/headless physics.
2. Build the original fort, village, terrain materials, foliage, wind and cinematic lighting; inspect actual browser output.
3. Implement First Oath dialogue, supply collection, riding, lookout, stealth patrol, fort completion, save/journal and combat; run regression assertions.
4. Export web and available desktop targets; verify browser input and measure FPS, loading, download size. Record limitations, credits, history sources and controls.

## Review focus

Invalid/missing saves must not crash or restore illegal stages. Quest actions out of order cannot skip stages. Fall recovery must restore a safe checkpoint. Dismount must use a clear grounded location. Pausing/dialogue must stop gameplay inputs. Browser output must use supported graphics features and no cross-origin isolation requirement.

## Progress

- Environment: empty directory, no usable Git metadata; Python/Node available; official Godot downloaded to `/tmp/godot`.
- Reference images: both inspected through shared ChatGPT page. No reference images redistributed.
- Asset research: Poly Haven Sparse Grass and Rock Face 03 individually CC0 verified. Kenney Nature Kit and Quaternius Ultimate Nature reviewed (CC0); not imported because original geometry better fits this brief. Poly Pizza reviewed, no asset selected; OpenGameArt timed out, no unverified asset imported.
- Tasks 1–3 implemented. Actual physics assertions cover input movement, jump, terrain riding, dismount clearance, detection cones, complete quest interactions, gate traversal, UI bounds and disk saves.
- Regression fixes: jump cancellation at floor; off-screen anchored HUD; raised courtyard blocking gateway; stranded horse after rider recovery; dodge motion during pause; false success notification on save failure.
- Independent read-only review completed. All three important findings reproduced and fixed with regression assertions.
- Task 4: Web/Linux/Windows exports generated. Browser scene visually rendered; browser automation/pointer-capture sessions proved unreliable. Browser now supports middle-button drag without pointer capture. Browser FPS, process memory, cold-load time and persistence remain uncertified; report these limits rather than invent measurements.
