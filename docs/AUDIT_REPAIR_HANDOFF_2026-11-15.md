# Endless Hill Climb — Visual/Code Audit & Repair Handoff

Date: 2026-11-15  
Project: Godot 4.7 / GDScript  
Scope: archive source, terrain generation, Normal Land / Heaven / Hell art, HUD, test expectations.

## Important verification boundary

The supplied ZIP was extracted and its project files, resources, scripts, scenes, tests, documentation, and included runtime screenshots were inspected. A Godot executable was not available in the audit environment (`godot` and `godot4` were not found), so this handoff does **not** claim a successful live launch, physical play-through, or new GPU screenshot. Static resource-path checks and source-level fixes were performed. The bundled earlier QA reports are historical claims and were not re-certified here.

## Confirmed findings from source + supplied screenshots

1. **Deep terrain material was drawn over the underground layer.** `TerrainSegment._apply_geometry()` assigned the complete deep collision polygon to `GroundPolygon`. `SubsoilPolygon` was drawn first and started only 45px below the surface, so the later full-depth ground polygon covered almost all of it. Heaven and Hell then repeated their 1920×99 road-strip textures through the full ~900px terrain depth. This matches the oversized flat slab seen in the captures.
2. **Terrain decoration slope math used the wrong normal components.** The normal is explicitly normalized upward (`normal.y < 0`), but `atan2(-normal.x, normal.y)` reports approximately ±180° on flat ground. The `< 24°` test that selects fences, signs and logs therefore never passed on a flat section. Sprites were also given a false large tilt.
3. **Hell used general countryside stones instead of the supplied volcanic rocks.** The Hell branch selected `assets/terrain/rocks/*` at 0.35–0.5 scale, making generic debris oversized and unrelated to the biome's curated volcanic assets.
4. **The Hell under-layer used a square lava tile as a 900px-deep subsoil texture.** The supplied capture consequently reads as a bright, repetitive block rather than layered dark volcanic ground.
5. **Heaven columns / angel were oversized and visually buried into the gameplay floor.** The 210×938 column texture at 0.5–0.55 scale is 469–516px tall; the 900×900 statue at 0.48 scale is 432px tall. Their centers/bottoms overlapped the road zone.
6. **Hell foreground columns were likewise too tall.** Its 210×938 basalt columns at 0.5–0.55 scale dominated the road horizon. The lava surface was a 256×256 square texture stretched to 2048×154px even though a dedicated transparent 128×32 lava strip exists.
7. **Nitro touch control displayed the bottle as the entire 140×140 button texture.** The provided control-button base and pressed textures were already declared in the HUD but unused by that button. This made the HUD show an oversized floating bottle without a conventional touch affordance.
8. **The normal profile did not use the existing grass-edge tile.** `grass_top_edge.png` was preloaded but unused; the profile used the plain soil tile, leaving the grass edge represented mostly by a thick line.
9. **Optional branching mode used inconsistent mode state for generation vs cleanup.** Generation read the controller live, but cleanup used only a cached exported boolean. A runtime switch back to the fixed cycle could leave stale branch encounter nodes attached.

## Applied repairs in this copy

- Split terrain visuals into a shallow biome top-crust polygon and a separate deep subsoil polygon. The collision polygon remains full-depth and unchanged, preserving vehicle physics and contact geometry.
- Surface band depth derives from the biome texture's native height and texture scale (clamped 30–104px; further capped for floating platforms). This keeps the Heaven marble / Hell basalt strip on the visible driving surface instead of tiling it through the world depth.
- Changed Normal Land's top material to the provided `grass_top_edge.png` with a near-neutral tint. All three profiles now use the available neutral `brown_soil_subsurface.png` tile for their lower layer, tinted separately per biome to read as earth, warm stone, or dark volcanic ash.
- Changed Hell subsoil to darkened volcanic earth, keeping lava as a separate atmospheric VFX rather than a giant ground fill.
- Corrected tangent angle to `atan2(normal.x, -normal.y)`, so flat ground is 0° and gentle slopes produce correct prop orientation / eligibility.
- Increased environmental dressing from three sparse placement zones to five measured zones per terrain segment.
- Switched Hell surface dressing to the three supplied `hell_volcanic_rock_*` assets, at restrained 0.16–0.22 scale and foreground z-index.
- Reduced Heaven palace columns, cloud platforms, angel statue, halo and flower scale so the architecture reads as a distant/middle-ground environment instead of an obstruction.
- Reduced Hell columns / portal / spike clusters / skeleton / demon sizes; swapped the stretched lava square for `lava_strip8.png`; populated previously-null shader parameters with the shader's declared defaults.
- Rebuilt Nitro touch control using the declared base/pressed control textures and a centered, mouse-ignoring bottle `TextureRect` child.
- Updated terrain/HUD regression tests to check the new layered-visual contract, while continuing to require full-depth collision and exact surface alignment.
- Made branching-mode selection read the controller live in both generation and culling. The exported flag remains a deliberate manual override instead of being overwritten during controller binding; stale encounter nodes are now queued for deletion when returning to the fixed schedule. Added regression coverage for toggling modes at runtime.

## What was not changed / not asserted

- The normal-to-Heaven / Hell fixed 5,150m cycle remains the default schedule. The separate branching encounter path remains an optional mode.
- Indian Roads remains clearly marked disabled / “ROADS (SOON)” in the menu; its no-op callback is not reachable through the disabled button.
- The `pass` callbacks for run-finished freeze and cycle rollover are not classified as bugs without a failing behavior trace; progression state updates elsewhere.
- Dark ring-like details in the Hell backdrop were not deleted: the zoomed source inspection suggests they are part of the volcanic rope-bridge artwork, not proven renderer artifacts.
- The supplied screenshots show the Nitro control as a large bottle shape; this audit replaces the full-bottle button with a framed touch control plus icon. The UI test was updated accordingly.

## Validation still required on the target machine

Run from the project root with Godot 4.7.2 installed:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/test_terrain_and_hud.gd
godot --headless --path . --script res://tests/test_phase5_terrain_and_ramps.gd
godot --headless --path . --script res://tests/test_phase2_branching_physics.gd
godot --headless --path . --script res://tests/test_ui_pickups_and_new_vehicles.gd
godot --path .
```

Then manually drive through Normal Land → Heaven → Normal return → Hell → Normal return at native 1280×720 and check: road continuity, tire contact, collectible clearance, mobile button presses, HUD overlap, visual parallax, no shader errors, and stable frame pacing. Capture new screenshots; do not reuse the old QA images as proof of the repaired build.

## AGY builder acceptance brief

Treat the repaired project as a candidate, not a final release. First import it in Godot and fix all parser/resource/import errors. Run the three targeted test scripts above, then the complete suite under `tests/`. Do not alter collision geometry to solve a rendering issue. Compare new Normal/Heaven/Hell screenshots against the old `correction/phase7_qa_*` captures. Keep Hell's Skeleton Knight and Demon/Goblin character animations in the environment (separate from the player driver); do not remove them as an optimization. Preserve GDScript-only implementation. Fix every test failure with evidence, regenerate captures, and return a file-by-file diff plus test logs and a final Android/desktop runtime check.
