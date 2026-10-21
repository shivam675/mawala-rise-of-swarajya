# MAVALA: Rise of Swarajya

A playable Godot 4.6.1 prototype set in a fictional village and hill-fort region inspired by Maval and Torna, circa 1646. The supplied images guide the warm light, fort silhouettes, saffron accents and quiet typography. This is an early procedural-art game, not a finished cinematic production or an exact historical reconstruction.

## Play

The generated browser build is in `build/web`. From this directory:

```sh
python3 tools/serve.py
```

Open <http://127.0.0.1:8060>. WebAssembly and WebGL 2 are required. Serve over HTTP locally or HTTPS in production; opening `index.html` as a filesystem file does not work. No engine installation is required to play the browser export.

Native exports: `build/linux/mavala.x86_64` and `build/windows/Mavala.exe`. Linux was started headlessly; Windows was exported but not run on Windows. The source project opens with `project.godot` in Godot 4.6.1. No add-ons, paid tools, external runtime services or API keys are needed.

## Controls

| Input | Action |
|---|---|
| WASD | Walk; ride while mounted |
| Mouse | Orbit on desktop; **hold the middle mouse button and drag in the browser** |
| Mouse wheel / V | Zoom / toggle shoulder camera |
| Shift | Sprint; gallop while riding |
| Space / C | Jump / toggle crouch |
| E | Talk, collect, mount, dismount, observe or climb a low ledge |
| Q | Equip / stow sword |
| Left / right mouse button | Sword attack / hold block |
| Alt | Dodge |
| J / Esc | Journal / pause |
| F3 | FPS, engine memory and draw calls |

Click the game to focus keyboard input. Browser camera dragging avoids depending on pointer-lock permission. Settings include four graphics presets, sensitivity, shoulder camera and environmental audio.

## The First Oath

1. Speak with Keshav in the village and finish his dialogue with E.
2. Collect the grain and bandages beside the store.
3. Mount Badal. Ride north along the winding ridge to the saffron lookout flag.
4. Interact at the lookout, dismount, then observe the route.
5. Crouch and pass the patrol when it faces away. Keep your distance and reach the northern ridge quietly. Suspicion fades when you break sight.
6. Speak with Jiva at the gate, walk through the arch, then deliver the supplies to Suryaji in the courtyard.
7. The next objective points towards the western water route; that follow-on mission is not implemented. You can explore the fort and cistern.

Successful stages save automatically to `user://first_oath.json`. Continue restores a safe stage checkpoint rather than exact position, combat state or horse location. Native saves are under the normal Godot application-data directory. Browser saves use Godot's browser filesystem/IndexedDB, depend on the origin and browser storage policy, and may be cleared by private browsing or storage eviction. Local disk save round-trips are tested; browser persistence across reloads remains unverified. New Game asks before replacing an existing save. Save errors are shown without reporting success or returning to title.

## Build and test

Install the official **Godot 4.6.1 standard editor** and its matching export templates using Editor → Manage Export Templates. Compatibility rendering is configured in the project. Paths to the temporary development engine are not embedded in export presets.

```sh
godot --headless --editor --path . --import --quit
bash tools/test.sh godot
mkdir -p build/web build/linux build/windows
godot --headless --path . --export-release Web
godot --headless --path . --export-release Linux
godot --headless --path . --export-release Windows
```

Use `godot4` or an absolute executable path where appropriate. The test runner requires Bash and ripgrep, isolates no user data by itself, and creates test progress: use a test `XDG_DATA_HOME` on Linux to keep it separate from your game saves:

```sh
XDG_DATA_HOME=/tmp/mavala-tests bash tools/test.sh godot
```

The assertions instantiate the actual scene and run physics, input, interaction, quest, detection, collision, save and UI checks. The wrapper rejects script errors and missing PASS markers because Godot assertions alone do not reliably produce a nonzero process exit.

## Source map

`core/` composes the scene and interactions; `characters/` contains walking/riding and articulated animation; `world/` builds terrain, architecture and instanced vegetation; `gameplay/` owns quest/save logic and patrol AI; `ui/` contains menus and navigation; `data/` contains quest stages; `localization/` contains English dialogue and draft Marathi translations. `art/` contains original shaders and licensed textures/fonts; `audio/` contains original synthesized wind/birds.

Procedural world generation uses seed 1646. Landscape height sampling is shared by terrain, NPC placement and checkpoints. Static architecture and near-path rocks collide; background mountain meshes and trees are decorative. The camera uses a collision spring arm. Animation articulates limbs, tunic torso and horse legs in code; there is no imported skeleton or motion-capture library.

## Hosting

Upload the **contents of `build/web`** to a static HTTPS host. Keep the HTML, JS, WASM, PCK, icons, audio worklet files, legal notices and fonts notices together. Serve `.wasm` as `application/wasm` and enable ordinary gzip/Brotli transfer compression, especially for WASM. This export is single-threaded and does not require SharedArrayBuffer or COOP/COEP. Do not add cross-origin isolation headers without a reason. No public deployment was performed.

Godot's [web export documentation](https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_web.html) explains WebGL 2, storage and browser limitations.

## Status and remaining work

Implemented: a connected terrain region, original fort/village, articulated Mavala and horse, walking/sprint/jump/crouch/low-ledge climb, camera collision, eight quest transitions, journal, supplies, checkpoint saving, basic melee/block/dodge, patrol cones/chase, four graphics presets, wind animation, water, ambient audio and desktop export presets.

The art remains visibly procedural and simpler than the supplied images. Baked lighting, detailed costume/skinning, terrain LOD/chunk streaming, optimized masonry batches, foliage collision, native-only enhanced rendering, broad NPC navigation/schedules, full Marathi UI, controller/touch support, voice acting, and subsequent missions are not implemented. The fort layout and period clothing need specialist historical review.

See [PERFORMANCE.md](PERFORMANCE.md), [ASSET_CREDITS.md](ASSET_CREDITS.md), [HISTORY_REFERENCES.md](HISTORY_REFERENCES.md), and [docs/ROADMAP.md](docs/ROADMAP.md). Source and original assets are MIT licensed; third-party textures/fonts retain their licenses.
