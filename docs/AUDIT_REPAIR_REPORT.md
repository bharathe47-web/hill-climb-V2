# Endless Hill Climb — Deep Audit and Source Repair

**Audit date:** 15 November 2026  
**Project:** Godot 4.7 / Mobile renderer, 1280×720 landscape target  
**Scope:** Uploaded `Endless-Hillclimb.zip`; original `.git` repository restored into this repaired copy.  
**Status:** Source fixes applied; static validation completed; Godot runtime verification still required.

## 1. Verdict and rating

The supplied gameplay captures do not support the earlier blanket “visual approved” claims. The game has a reasonable underlying structure—procedural terrain, biome profiles, a deterministic world cycle, multiple vehicles, pickups, HUD, and a sizeable automated-test collection—but the visible build is held back by terrain rendering, underused environmental assets, scale hierarchy, and a misleading Nitro touch control.

**Provisional rating of the submitted build, based on its supplied captures and source: 4.4/10.** This is not a live-play score because the game could not be launched in this environment.

| Area | Provisional score | Reason |
|---|---:|---|
| Normal Land visual presentation | 3.5/10 | Deep uniform ground slab, sparse roadside dressing, and missing visible fence/sign variation on flat sections |
| Heaven visual presentation | 4.5/10 | Attractive asset set, but oversized columns/statue and a broad floor strip dominate the driving view |
| Hell visual presentation | 3.5/10 | Repeated dark ground, oversized columns/props, and lava treatment that reads as a stretched tile |
| HUD / touch affordance | 5/10 | The Nitro bottle looked like a floating oversized control rather than an icon inside a touch button |
| Code / architecture | 6.5/10 | Reusable terrain, profiles, world progression, vehicles and tests are present; runtime stability is not re-certified |

A rating for the repaired candidate is deliberately withheld until AGY imports it, runs the tests, and produces fresh screenshots and a gameplay recording.

## 2. Archive inventory and static validation

The original archive contains 4,241 entries, including its Git metadata and generated/import-related material. The clean project working copy excludes the regenerable `.godot` cache but **preserves the original `.git` repository and `member2` branch**. The original working tree already contains user changes and untracked project reports; AGY must preserve those and must not run `git reset --hard`, `git clean`, or overwrite unrelated modifications. The source project tree contains:

- 80 GDScript files
- 31 Godot scenes (`.tscn`)
- 11 text resources (`.tres`)
- 5 shaders (`.gdshader`)
- 27 test scripts
- 620 PNG, 3 JPEG, 1 GIF, 20 SVG, 11 WAV, 4 OGG, 3 MP3 and 3 TTF assets
- 664 Godot import sidecars

Checks completed against the repaired project copy:

- 951 quoted `res://` source references checked (450 unique paths): **0 missing**
- Scene/resource `ext_resource` paths: **0 missing**
- Duplicate external-resource IDs in scenes/resources: **0**
- Import sidecars checked against their `source_file` entries: **664 / 664 resolved**
- Raster images decoded by Pillow: **624 / 624 valid**
- SVG files parsed as XML: **20 / 20 valid**
- Audio files probed with FFprobe: **18 / 18 decoded**
- The 3 bundled TTF fonts were recognized as TrueType fonts

A SHA-256 manifest of every project file (excluding `.git`, the regenerable `.godot` cache, and the manifest itself) is included at `docs/PROJECT_FILE_MANIFEST.csv`. These checks validate source references and file integrity. They do not replace Godot's own import, parser, shader compiler, physics, scene-tree, or rendering checks.

## 3. Confirmed defects and repairs applied

### P0 — Terrain visual body hid its own subsoil

**Cause:** `TerrainSegment._apply_geometry()` gave the entire deep polygon to `GroundPolygon`. `SubsoilPolygon` was drawn first and began only a short distance below the surface, then the later full-depth ground polygon covered most of it. Heaven/Hell 1920×99 road-strip textures were consequently repeated through nearly the whole terrain depth.

**Repair:** `GroundPolygon` now represents a shallow visible surface crust derived from the biome texture height and scale (clamped to 30–104 px and capped for floating platforms). `SubsoilPolygon` begins immediately below it and fills the remaining depth. The collision polygon remains full-depth and unchanged. The three profiles use `brown_soil_subsurface.png` for the lower layer, with a different tint for each biome.

### P0 — Flat-ground decoration slope test was mathematically wrong

**Cause:** The surface normal is oriented upward (`normal.y < 0`), but the decoration angle used `atan2(-normal.x, normal.y)`. A flat surface therefore produced approximately ±180° rather than 0°, preventing the `< 24°` flat-ground fence/sign/log branch from being selected.

**Repair:** The angle is now `atan2(normal.x, -normal.y)`. Flat ground returns 0° and gentle slopes receive the correct small rotation. Decoration layout also uses five measured zones instead of three sparse slots.

### P1 — Normal Land was under-dressed

**Cause:** The Normal profile used a plain soil tile while an existing grass-edge tile was already available. Combined with the slope-angle defect, this made the scenery feel empty and suppressed fence/sign variation.

**Repair:** Normal Land now uses `grass_top_edge.png` on the visible surface crust, a neutral lower-soil texture, a thinner grass contour, and the corrected dressing math. Bushes, flowers/tufts and level-ground wooden props can now be distributed across five zones per segment.

### P1 — Heaven scale hierarchy competed with gameplay

**Cause:** Columns were 469–516 px tall at their previous scale, and the 900×900 angel statue was about 432 px tall. They intruded into the driving band and dominated the composition.

**Repair:** Distant and middle columns were reduced to 0.22–0.26 scale, the angel statue to 0.30, the halo to 0.32, and foreground flowers/cloud platforms were reduced. The marble road is now only the shallow top crust rather than a full-depth slab.

### P1 — Hell ground, lava and props were oversized/repetitive

**Cause:** A square lava tile was being stretched into a wide stream, the lower ground used a bright/repeating tile, and large basalt columns/portal/spikes/characters crowded the gameplay band. Generic countryside stones were selected for Hell instead of the supplied volcanic rock art.

**Repair:** Hell uses the basalt platform strip on the surface crust, neutral dark-tinted soil below, a dedicated transparent lava strip for the lava ribbon, three supplied volcanic rock assets for roadside rubble, and smaller architecture/character props. Null shader parameter entries were replaced with their declared values. Skeleton Knight and Demon/Goblin characters remain part of the environment.

### P1 — Nitro touch control lacked a clear button affordance

**Cause:** The Nitro bottle itself was the full TextureButton artwork, making the control visually oversized and inconsistent with the accelerator/brake buttons.

**Repair:** The button now uses the already-declared base/pressed control textures. The Nitro bottle is a centered 80×80 child icon with mouse filtering set to Ignore, so the parent button retains the touch target.

### P2 — Branching-mode state could get stale

**Cause:** Terrain generation checked the controller's current mode, while encounter cleanup checked only a cached exported boolean. Runtime switching back to the fixed schedule could therefore leave obsolete encounter nodes alive.

**Repair:** Both paths now call `_is_branching_mode_enabled()`. The controller mode is read live; the exported boolean remains a deliberate manual override. Culling always reconciles active encounters and queues obsolete ones for deletion when branching is disabled. A regression check was added to the branching physics test.

## 4. Findings intentionally not labelled as bugs

- The default route remains the fixed **5,150 m** cycle: Normal Land → Heaven → Normal Land → Hell → Normal Land. Branching encounters are a separate optional schedule.
- “ROADS (SOON)” is visibly disabled in the menu; its no-op callback is not currently reachable through that disabled control.
- Run-finished freeze and cycle-rollover callbacks that contain `pass` were not changed without a failing trace; progression/environment state is driven elsewhere.
- The Hell capture's dark ring-like detail was not removed because the source suggests it is part of the rope-bridge artwork, not a confirmed rendering defect.

## 5. Runtime verification limitation

No `godot` or `godot4` executable is installed in this audit environment. Network access needed to obtain the engine was unavailable. Therefore **I could not launch, play, or take new runtime screenshots of the patched game, and I did not run the 27 Godot test scripts**. The old bundled QA screenshots are not evidence that this repaired source has passed.

## 6. Required AGY verification

From the project root, with the project-required Godot 4.7.x build installed:

```bash
godot --version
godot --headless --path . --editor --quit

for test_file in tests/test_*.gd; do
  echo "===== $test_file ====="
  godot --headless --path . --script "res://${test_file#./}" || exit 1
done

godot --path .
```

AGY must then manually drive two fixed 5,150 m cycles and separately test branching mode if enabled. It must capture new 1280×720 screenshots for Normal Land, Heaven, Hell, both transitions, both return merges, and the touch HUD; verify wheel contact and collision after the visual polygon split; test accelerate/brake/nitro, pickups, fuel depletion, crash, pause/resume, restart, vehicle selection and save persistence; and return actual logs, screenshots and a file-by-file diff.

Do not accept a “100% pass” report without the command, count, output, and fresh capture for each claim. Treat this repaired project as a candidate pending those runtime results.

## 7. Files directly amended for this repair

The repair-specific source/test edits are limited to these files; the rest of the original project source/assets remain present:

- `scripts/terrain/TerrainSegment.gd`
- `scripts/terrain/TerrainGenerator.gd`
- `assets/terrain/profiles/normal_land_profile.tres`
- `assets/terrain/profiles/heaven_terrain_profile.tres`
- `assets/terrain/profiles/hell_terrain_profile.tres`
- `scenes/environment/heaven/HeavenEnvironment.tscn`
- `scenes/environment/hell/HellEnvironment.tscn`
- `scenes/ui/HUD.tscn`
- `tests/test_phase2_branching_physics.gd`
- `tests/test_phase5_terrain_and_ramps.gd`
- `tests/test_terrain_and_hud.gd`
- `tests/test_ui_pickups_and_new_vehicles.gd`

The accompanying instructions and evidence are `AGY_BUILD_GUIDANCE.md`, this report, `docs/AUDIT_REPAIR_HANDOFF_2026-11-15.md`, and `docs/PROJECT_FILE_MANIFEST.csv`. The Git worktree includes pre-existing local edits from the uploaded archive; Git's total dirty-file count must not be interpreted as the count of files changed by this repair.

## 8. Source-tree preservation check

Compared against the uploaded ZIP, all **1,617 original non-Git, non-`.godot` project files** are present in the repaired copy. There are **zero missing original files**. The six additional files are this repair's reports, AGY instructions, handoff and SHA-256 manifest. The `.godot` cache is omitted because Godot regenerates it during import; `.git` is preserved on branch `member2`.
