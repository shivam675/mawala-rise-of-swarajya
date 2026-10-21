# Asset credits and provenance

Verified 21 October 2026 from the original asset pages before import. No ripped, commercial-game, paid or unclear-license asset is included.

| Asset | Author | Original source | License | Changes | Redistribution |
|---|---|---|---|---|---|
| Sparse Grass, 1K diffuse | Amal Kumar | https://polyhaven.com/a/sparse_grass | CC0 1.0 | Original JPG retained; shader tint, tiling and terrain blending | Yes, including commercial redistribution |
| Rock Face 03, 1K diffuse | Dario Barresi (photography), Rico Cilliers (processing) | https://polyhaven.com/a/rock_face_03 | CC0 1.0 | Original JPG retained; terrain/stone tint and triplanar mapping | Yes, including commercial redistribution |
| Cormorant Garamond variable font | Cormorant Project Authors / Christian Thalmann | https://github.com/google/fonts/tree/main/ofl/cormorantgaramond | SIL OFL 1.1 | Unmodified font; Godot imports font data | Yes, retain OFL; do not sell font by itself |
| DejaVu Sans | DejaVu Fonts contributors; based on Bitstream Vera | https://dejavu-fonts.github.io/ | Bitstream Vera / DejaVu terms | Unmodified local distribution font | Yes, retain bundled license notices |
| Noto Sans Devanagari Regular | Noto Project Authors | https://github.com/notofonts/devanagari | SIL OFL 1.1 | Unmodified local distribution font, used as fallback | Yes, retain bundled license notices |
| Character, turban, angarkha-inspired tunic, shield, sword | MAVALA contributors | `characters/warrior_visual.gd` | MIT | Original procedural geometry and articulated animation | Yes, retain MIT notice |
| Badal, horse and saddle | MAVALA contributors | `characters/horse.gd` | MIT | Original procedural geometry and gait | Yes, retain MIT notice |
| Fort, arch, bastions, banners, houses, props, landscape, foliage | MAVALA contributors | `world/landscape.gd`, `art/` shaders | MIT | Original procedural geometry; CC0 texture application | Yes, retain MIT notice and asset licenses |
| Valley wind and bird chirps | MAVALA contributors | `audio/valley.wav` | MIT | Original deterministic mathematical audio synthesis, no sampled recordings | Yes, retain MIT notice |

Poly Haven's [asset license](https://polyhaven.com/license) explicitly permits redistribution. Each imported asset page separately identifies CC0. Only the actual diffuse textures were downloaded; preview renders, logos and website screenshots were not imported.

Font licenses are bundled under `art/fonts/OFL.txt`, `DejaVu-LICENSE.txt`, and `Noto-LICENSE.txt`. `ASSET_MANIFEST.json` records local file sizes and SHA-256 digests.

The [two user-supplied reference images](https://chatgpt.com/s/m_6ad845adbd148191b22f9d5497ac9747) were viewed as art-direction references. Their collages and text are not redistributed in the game. No historical quote in them was adopted as a documented quotation.

Other requested sources reviewed: [Kenney Nature Kit](https://kenney.nl/assets/nature-kit) and [Quaternius Ultimate Nature](https://quaternius.com/packs/ultimatenature.html) individually identify CC0, but their models were not imported. [Poly Pizza](https://poly.pizza/) was reviewed without selecting an asset, and OpenGameArt timed out. No license was inferred for an entire marketplace.

Godot Engine is MIT licensed. Its copyright notice is included in `GODOT_LICENSE.txt`; third-party engine notices are included in `GODOT_COPYRIGHT.txt` from [Godot's copyright listing](https://github.com/godotengine/godot/blob/4.6.1-stable/COPYRIGHT.txt). Both accompany packaged distributions.

## Material upgrade, 21 October 2026

All added maps are 1K JPEG originals from Poly Haven under [CC0](https://polyhaven.com/license). They are stored locally and need no runtime network access.

- `rock_normal.jpg`, `rock_roughness.jpg`: [Rock Face 03](https://polyhaven.com/a/rock_face_03), Dario Barresi and Rico Cilliers.
- `cloth_normal.jpg`: [Fabric Pattern 07](https://polyhaven.com/a/fabric_pattern_07), Rob Tuytel. Only the weave normal map is used, retaining the original costume colours.
- `plaster_color.jpg`, `plaster_normal.jpg`: [Plastered Wall](https://polyhaven.com/a/plastered_wall), Amal Kumar.
- `wood_color.jpg`, `wood_normal.jpg`: [Weathered Brown Planks](https://polyhaven.com/a/weathered_brown_planks), Dimitrios Savva and Rico Cilliers.

ASSET_MANIFEST.json records sizes and SHA-256 hashes. Character and horse geometry remain original procedural work. No Assassin’s Creed assets are included.
