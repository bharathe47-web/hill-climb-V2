# Endless Map — Deep Visual Failure Audit & Art-Direction Correction Plan

**Review input:** `Fault.zip` (17 PNG screenshots)  
**Review date:** 14 November 2026  
**Target:** Godot 4.7.2, 2D side-scrolling Hill Climb gameplay, 1280×720 target view  
**Decision:** **VISUAL QA FAIL — do not sign off the environment presentation yet**

---

## 1. Executive assessment

This is not a case where a few sprites need to be resized. The screenshots show recurring failures in the environment render stack, biome activation/visibility, terrain presentation, VFX alpha/blending, asset selection, and scene composition. Some of these problems appear in more than one milestone and more than one biome.

The most serious recurring symptoms are:

1. **Multiple environments appear at once.** Normal Land hills/forest, Heaven cloud/marble surfaces, and Hell volcanic/black terrain are simultaneously visible in several captures.
2. **Large cyan/turquoise horizontal slabs cover the gameplay view.** They obscure the road and scenery and recur at different vertical positions.
3. **Black rectangular VFX panels are visible.** Lightning/glow-like imagery is surrounded by opaque or nearly opaque black rectangles; smaller black square particles also appear.
4. **Terrain fill and track surfaces are not composed cleanly.** Huge dark fills, broad flat cyan surfaces, abrupt rectangular brown regions, and overlapping coloured rims appear at transitions/merges.
5. **Several character/scenery assets are visually unsuitable in their current role.** Oversized orange cartoon creatures clash with the painterly volcanic background, are clipped by the viewport, or compete with the vehicle.
6. **Heaven is over-fogged and low-contrast.** Architecture, angel/statue and background scenery lose definition behind pale translucent layers.
7. **Hell uses the wrong atmospheric particles in some captures.** White flakes read as snow, not ash or cinders.
8. **The vehicle/track relationship needs a targeted contact audit.** Some Hell/catch captures show wheels and suspension far below the body/road line. The screenshots alone cannot determine whether this is a suspension animation, a falling state, or a physics/render synchronization defect.
9. **Some visual evidence labels do not agree with the captured state.** For example, `phase2_outcome_heaven_3_active.png` shows a volcanic bridge/ Hell-like environment while its filename says Heaven. Some named merge captures still show old biome layers or unmerged terrain fills.

**Conclusion:** The game has promising source material, especially the volcanic panorama/bridge and the golden palace architecture, but the current runtime assembly is not coherent. Correct the rendering/scene system first, then selectively remove unsuitable runtime assets. Do not compensate for a broken layer stack by adding more assets.

## 2. Evidence inventory — all 17 images reviewed

### A. Live desktop captures

| File | Visible HUD distance | Findings |
|---|---:|---|
| `Screenshot From 2026-11-14 14-34-53.png` | 501 m | Large translucent cyan band across the upper gameplay view; oversized orange-dotted black obstacle/block near the vehicle; Hell-style dark ground remains under Normal Land hills; skeleton/character overlaps the left-side Nitro bottle area; ground is an excessively large dark slab with a thin orange top rim. A desktop notification also obscures the top-center game view, so this is not a clean acceptance capture. |
| `Screenshot From 2026-11-14 14-35-06.png` | approximately 686 m | Broad cyan overlay across the upper third; a large black rectangular lightning/glow panel on the left; Normal Land hills remain visible with an isolated tiny orange creature and Hell-like ground below. The scene does not read as a clean single biome. |
| `Screenshot From 2026-11-14 14-35-31.png` | 571 m | Very large black lightning-texture rectangles occupy the upper and central view; the wide cyan platform/band cuts through the scene; Heaven-like sky/sun, Normal Land hills and Hell-like black/orange ground are simultaneously visible. This is a clear layer/visibility failure, not merely a weak art asset. |

### B. Phase 2 outcome captures

| File | Visible HUD distance | Findings |
|---|---:|---|
| `phase2_outcome_heaven_2_landing.png` | 509 m | Multiple translucent background sets overlap; a broad cyan platform fills the middle; Hell-like orange/black terrain remains at the bottom while countryside hills remain behind it. Vehicle boost VFX is very bright and competes with the vehicle. Does not read as a clean Heaven landing. |
| `phase2_outcome_heaven_3_active.png` | 552 m | The filename says Heaven, but the visible environment is clearly volcanic/Hell-like: lava bridge, magma background, orange columns and skeleton. A huge cyan platform overlays the scene; black/brown chunks and a thick bottom Hell fill remain. This is both a visual failure and a screenshot-label/state verification issue. |
| `phase2_outcome_heaven_4_merge.png` | 1,000 m | Normal Land background returns, but a large flat brown rectangular terrain region and a separate black/orange ground fill remain below the green track. This suggests stacked or stale terrain visuals at the merge. |
| `phase2_outcome_hell_1_miss.png` | 1,000 m | Normal Land hills and trees are visible while a Hell-like black/orange ground and a large cyan slab remain. The frame does not visually prove a clean Hell route. |
| `phase2_outcome_hell_2_catch.png` | 1,000 m | Multiple biome backgrounds are ghosted together; cyan overhead band, volcanic bridge, countryside hills, dark ground and a large pale creature shape overlap. One wheel appears visually separated from the vehicle body/road relationship; investigate contact/suspension state. |
| `phase2_outcome_hell_3_active.png` | 1,000 m | Hell bridge and skeleton are visible, but a wide cyan slab still crosses the upper edge; a large pale horned creature intrudes into the driving area; orange dotted blocks and oversized dark terrain dominate. The active environment is not composed cleanly. |
| `phase2_outcome_hell_4_merge.png` | 1,000 m | Normal Land background and green track coexist with a large abrupt brown rectangle and black/orange lower terrain. The biome return is not visually clean. |

### C. Phase 3 Heaven captures

| File | Visible HUD distance | Findings |
|---|---:|---|
| `phase3_heaven_1_entry.png` | 509 m | Large rectangular black lightning panel at left; translucent palace/statue/cloud layers overlap; Normal Land hills/forest remain visible behind Heaven; broad cyan slab covers much of the lower-middle view. Heaven entry is not a controlled reveal. |
| `phase3_heaven_2_terrace_monument.png` | 641 m | Golden arch and columns are the strongest Heaven assets and can be retained. However, the left black lightning panel is severe; the sky/cloud layer is overexposed; a massive flat cyan road/platform covers the lower half; another offset platform/background strip appears below it; small dark square VFX tiles appear near architecture. |
| `phase3_heaven_3_mid_palace_doves.png` | 951 m | Palace columns/arch remain visible but the angel/dove presentation is not clearly readable; a large black square panel blocks the left; multiple cloud/sky layers ghost through each other; the cyan roadway is too tall and flat; duplicated lower platform strip is visible. |
| `phase3_heaven_4_exit_descent_slide.png` | 976 m | Heaven and Normal Land are overlaid; an orange/black Hell-like track remains at the bottom; giant cyan platform still obscures the central scene; pale fog washes out the palace, angel and gate. The exit is not a clear, staged Heaven-to-Normal transition. |

### D. Phase 4 Hell captures

| File | Visible HUD distance | Findings |
|---|---:|---|
| `phase4_hell_1_catch_portal.png` | 512 m | Volcanic cavern background has potential, but black lightning panels and translucent Normal/Heaven layers remain; a large orange column cuts through the composition; the broad black/orange track fill is visually empty and too dominant. |
| `phase4_hell_2_chasm_goblin.png` | 690 m | Strong volcanic bridge/lava background, but a very large flat orange goblin is cropped/poorly integrated; a black lightning rectangle overlaps the car/scene; orange dotted rectangular objects look like placeholders or broken texture mapping; the vehicle wheel/suspension relationship looks abnormal and must be checked in motion. |
| `phase4_hell_3_horned_fiend.png` | 800 m | Oversized flat orange character is cropped at the top and competes with the vehicle; another small orange creature appears nearby at a different scale; black lightning panel and orange dotted blocks remain; large orange columns/bridge supports dominate the foreground; wheel/suspension visual separation is prominent. |

---

## 3. Confirmed visual defects vs. root-cause hypotheses

The screenshots prove the symptoms below. They do **not** prove the exact node/resource responsible. The next audit must map each symptom to the exact `.tscn` node, `.tres` resource, texture path, shader and script before changing it.

### P0 — biome render-stack / visibility leakage

**Observed:** Heaven, Hell and Normal Land visuals coexist in the same frames. This appears in the live desktop captures, Heaven entries/exits, Hell catches and merge frames.

**High-probability causes to test:**
- Environment root opacity/visibility is being changed while child CanvasItems are separated by non-CanvasItem nodes or independent `CanvasLayer` nodes.
- `CanvasLayer` children are still visible because each layer has its own visibility/draw order and is not controlled by the intended parent fade.
- Old environment instances are not freed/hidden when route state changes.
- Crossfade completion is not setting the inactive environment to fully hidden/disabled.
- Environment instances are duplicated by repeated entry/exit activation.

**Required inspection:** print the runtime tree and all CanvasLayer indices/visibility for Normal, Heaven and Hell at 480m, 520m, 750m, 976m and 1,005m. Record each environment root, CanvasLayer and major CanvasItem `visible`, `modulate.a`, `self_modulate.a`, `z_index`, `top_level`, `show_behind_parent`, and current alpha. Verify the state after the crossfade has completed, not only while it is active.

**Acceptance:** when Heaven is active, Hell and Normal-specific background layers are fully absent except intentionally shared elements; same rule for Hell and Normal. No inactive full-width platforms or terrain fills remain visible. Crossfades may overlap only during the defined transition window and must terminate cleanly.

### P0 — giant cyan platform/slab and stacked terrain fills

**Observed:** a very wide turquoise rectangle/platform crosses the gameplay area in numerous screenshots. At merges, a large brown rectangular fill and black/orange fill remain under the green Normal Land surface.

**High-probability causes to test:**
- A Heaven marble/cloud floor Sprite2D/Polygon2D is scaled or positioned as a screen-wide slab instead of a road surface.
- A visual `Polygon2D`/terrain fill is drawn as a rectangle or is closed against a fixed bottom point that produces a huge block.
- Terrain segments generated under one biome profile remain after the profile switches; pooled segments may retain stale visual data/profile/material.
- The environment's scenic platform is being drawn as a second physical/visual road instead of a background ledge.
- A transition platform is not removed after the vehicle leaves it.

**Required inspection:** identify every node drawing the cyan slab and every Polygon2D/Line2D/StaticBody2D/CollisionPolygon2D used by each branch. Compare visual polygon points and collision polygon points in the same coordinate space. Log segment ID, biome profile, world X range, fill polygon bounds and pool lifecycle before/after branch entry and merge.

**Acceptance:** one continuous, correctly shaped playable road per route; exactly one active terrain visual fill under the current road; collision and visible surface coincide; no full-screen or unbounded slab; no rectangular terrain blocks at merge.

### P0 — black lightning/glow rectangles and dark square tiles

**Observed:** large black panels containing orange/gold lightning-like patterns, plus small black square particles around Heaven architecture. They recur in both Heaven and Hell captures.

**High-probability causes to test:**
- Source texture has opaque black background instead of transparency.
- Alpha channel is missing/flattened during source export or import.
- Shader outputs alpha incorrectly, or `blend_disabled`/wrong blend mode is used.
- A glow/mask texture intended for a shader/light is drawn directly as a normal sprite.
- A texture atlas region/UV is sampling the wrong area or showing unused atlas cells.

**Required inspection:** for every visible black panel/tile, log exact texture path and resource. Inspect source PNG alpha at corners and full alpha histogram; check imported texture alpha preservation, region/atlas coordinates, shader render mode and CanvasItemMaterial blend mode. Compare with the original source image outside Godot.

**Policy:** immediately disable the offending VFX node from runtime while the audit is in progress. Do not leave a black rectangle visible just to keep an effect. Only re-enable if the source alpha, shader and blend mode produce a clean transparent result in-game.

**Acceptance:** no black rectangles or black square particles at any distance. Glow must illuminate/soften the environment without showing its rectangular source bounds.

### P1 — asset art-style mismatch and bad composition

**Observed:** the painterly volcanic background/bridge is combined with enormous flat orange goblin/fiend cartoons, a different-looking skeleton sprite, large orange columns and tiny unrelated creatures. Some characters are clipped by the viewport or overlap the vehicle.

**Asset decisions:**
- **Keep as candidates:** volcanic panorama/bridge, basalt/rock art after texture-scale repair, Golden Palace arch/columns, cloud sky assets, angel statue, dove animation, skeleton knight as a distant environmental silhouette.
- **Disable from runtime pending review:** oversized flat orange Demon Goblin/Horned Fiend presentations, any creature instance cropped by the viewport, oversized orange-dotted blocks that have no readable gameplay purpose, and any decorative sprite that competes with the vehicle.
- **Do not delete source files:** preserve them in the asset library and manifest. Removing from runtime scenes is sufficient. If an asset cannot be made visually compatible with scale, colour, outline and lighting adjustments, leave it unused.
- **Do not force a style match by adding filters to everything.** First establish a coherent chosen art direction for this game: clean, readable 2D illustrated/cartoon vehicle gameplay with atmospheric painterly backgrounds. Background detail may be richer, but foreground entities must share a coherent scale, contrast and silhouette language.

**Acceptance:** vehicle remains the primary focus; environmental characters are small/medium background set pieces, placed on ledges, never on the driving surface, never clipped, never hidden by HUD, and never larger than the architectural landmark unless intentionally designed as a distant giant silhouette.

### P1 — Heaven is overexposed and lacks hierarchy

**Observed:** white fog/cloud overlays flatten the palace and statue; the main golden arch is readable in one screenshot but other frames are washed out. The angel is faint; doves/flowers do not read clearly; multiple columns are placed without a composed focal point.

**Required direction:**
- Use a clear blue/white sky gradient with controlled cloud groups, not full-screen fog.
- Keep the palace gateway as the landmark focal point; use fewer, intentionally arranged columns.
- Give the angel statue a readable silhouette and a defined, restrained halo.
- Use doves as a small moving flock in open sky space, not as tiny dark atlas squares.
- Keep lilies/flowers near platform edges, not as clutter.
- Marble/cloud road should have a narrow road top, a controlled thickness/underside and visible edge treatment; it must not be a giant cyan rectangle.
- Limit white fog to a distant atmospheric layer with subtle opacity; never wash out the vehicle or landmark.

### P1 — Hell is visually heavy, inconsistent and too flat

**Observed:** the volcanic panorama and bridge have a strong identity, but the road is a nearly solid black slab, orange border is excessively thick, columns obstruct the scene, white particles resemble snow, and cartoon monsters are poorly scaled.

**Required direction:**
- Retain the volcanic panorama and bridge only after correct placement/depth and parallax.
- Make the driveable basalt surface textured but readable; reduce empty black fill and avoid excessive repeated cracks.
- Use a controlled molten seam/glow along selected terrain edges, not a thick continuous orange outline that dominates the vehicle.
- Use ash drifting sideways/upward, occasional glowing cinders, and rare sparks. Remove snow-like white flakes in Hell.
- Use skull portals and environmental characters as landmarks; do not stack several large foreground props in one screen.
- Keep lava below/behind the road with depth cues; do not cover the driveable lane.

### P1 — vehicle contact / suspension visual validation

**Observed:** in some Hell catch/chasm images, one or more wheels appear far below the vehicle body/road surface, with long visible suspension struts. This could be a fall/catch animation or a real pose/synchronization issue; screenshots cannot determine which.

**Required inspection:** record `RigidBody2D` vehicle body transform, each wheel/axle transform, suspension extension, contact state, raycast/collider hit position and visible road profile in the same frame. Capture a 60fps short video or frame sequence through catch/landing, not only a still.

**Acceptance:** wheels remain visually attached within the designed suspension travel; when falling, the pose is intentional and brief; at landing the vehicle settles onto the correct collision surface without wheel/body separation or a visual/physics mismatch.

### P2 — HUD and screen-space clutter

**Observed:** the large Nitro bottle illustration is pinned over the lower-left playfield in every screenshot; milestone banners still appear in multiple frames well after the shown distance has passed 500m; desktop screenshot notification obscures one capture.

**Required direction:**
- Keep the actual fuel/Nitro gauges and boost control readable.
- Remove the permanently oversized floating Nitro-bottle overlay, or make it a short-lived contextual prompt that appears only near the ramp decision and fades out.
- Ensure milestone banners animate in, remain briefly, then disappear. Never leave a 500m banner visible at 641m/951m unless the design explicitly calls for a persistent mission marker.
- Capture evidence without desktop notifications or editor overlays.

---

## 4. Art direction target — what the final game should look like

### Normal Land

A clean, readable countryside road with a green grass edge, warm soil/earth fill, natural hill silhouettes, layered forest/mountain depth, and sparse trees/bushes/fences placed along the surface. The road must be the visual anchor. No Heaven marble bands, no Hell black slab, no unrelated VFX.

### Heaven

A bright but controlled celestial landscape: blue sky, distinct white cloud layers, one or two strong golden palace landmarks, clear ivory angel statue, small dove flock, a few lilies, and a narrow marble/cloud road whose contour follows the real terrain. White/gold palette must preserve contrast around the vehicle. The vehicle must remain fully readable against clouds and architecture.

### Hell

A deep volcanic underworld: warm lava-lit cavern panorama, basalt ledges and rock layers, controlled orange magma seams, a recognizable skull gate or bridge landmark, skeleton/demon silhouettes on background ledges, dark ember/ash atmosphere, and a textured but readable road. Keep the foreground calm enough that the vehicle and road remain unmistakable.

### Transition language

- **Heaven ascent:** visible ramp → Nitro cue → vehicle launches → clouds move past camera → gold/white portal reveal → land on a clearly shaped upper route.
- **Hell descent:** missed/insufficient launch → deliberate falling camera follow → sky darkens → magma glow rises → enter volcanic portal → land on a distinct lower basalt route.
- **Return:** Heaven exits through cloud/sunlight; Hell exits through a magma geyser/vent. Each transition must end by removing the previous biome layers and presenting one clean Normal Land scene.

---

## 5. Required technical investigation order

Do not start by changing many art values at once. Work in this order so each root cause is isolated.

### Step 1 — Freeze a clean baseline

- Create a named local Git checkpoint/branch only after reporting the current `git status` and current HEAD.
- Do not reset, clean, force checkout, rebase, push or overwrite user changes.
- Capture one reproducible screenshot at the same 1280×720 viewport before changes.
- Record Godot version, renderer, active route, distance, active biome ID and exact runtime scene tree.

### Step 2 — Build a render/scene inventory

For Normal, Heaven and Hell, produce a table containing:
- Scene path and root node path.
- Every CanvasLayer name, numeric `layer`, `visible`, transform and follow-viewport settings.
- Every full-screen or large-area Sprite2D/TextureRect/Polygon2D/ColorRect.
- Every terrain fill/outline node and corresponding collision node.
- Every particle node, source texture, material, blend mode and emission state.
- Every shader and texture resource path.
- Node count and duplicate instance count after repeated route transitions.

### Step 3 — Solve visibility and canvas ordering

- Do not rely on fading an arbitrary parent Node2D if child CanvasItems are separated by non-CanvasItem nodes or CanvasLayers.
- Explicitly control visibility for each CanvasLayer and its environment children.
- Ensure CanvasLayer layer indices are deterministic and unique where needed; do not rely on ambiguous same-layer ordering.
- During crossfade, fade only the intended background layers. Keep gameplay road/terrain rendering under one authoritative owner.
- Once transition finishes, assert old biome layers are hidden and no old biome terrain visual survives outside a deliberate transition segment.

### Step 4 — Solve terrain visual/collision ownership

- Keep one authoritative terrain generator and one current active terrain profile per live segment.
- Decide whether existing pooled segments are regenerated/reprofiled when biome changes; do not leave stale profile meshes in the pool.
- Visual surface, terrain fill, collision shape, road-edge line and texture UV must use the same generated curve/profile.
- Ensure fill polygons close below the screen/road intentionally without exposing rectangular side edges inside the camera view.
- Do not draw a separate scenery platform over the active road unless it is a deliberate branch platform with its own matching collision.
- Check that merge generation removes the prior route fill and creates one continuous Normal Land segment.

### Step 5 — Audit every offending texture and shader

- For every black/cyan/ghost rectangle, identify exact file and node.
- Inspect source PNG/JPG dimensions, mode, alpha presence, alpha extrema, corner alpha values and alpha histogram.
- Compare the original source with the imported Godot resource.
- Verify atlas region/UV bounds and that unused cells are not sampled.
- Verify shader alpha output and `render_mode`.
- Use additive blending only for effects designed for additive compositing; do not use additive blending as a blanket fix for opaque black textures.
- Disable any asset that still shows a rectangular boundary after a correct alpha/material fix.

### Step 6 — Curate runtime assets

For each visual asset, assign one status:
- `KEEP`: visually compatible and renders correctly.
- `KEEP_AFTER_FIX`: useful source, but scale/alpha/placement/material needs repair.
- `DISABLE_RUNTIME`: does not fit the selected art direction or still shows obvious defects.
- `REPLACE_LATER`: source is unsuitable; remove its scene instance now and record the gap without collecting assets during this correction.

Preserve all original source files and license records. Remove/disable nodes in scenes, not files in the asset library.

### Step 7 — Compose and review one biome at a time

1. Normal Land baseline first.
2. Heaven only after Normal is clean.
3. Hell only after Heaven is clean.
4. Heaven transition and rejoin.
5. Hell transition and rejoin.
6. Continuous 5,000m run.

Use a screenshot comparison after every step. Do not make Heaven, Hell and Normal changes simultaneously.

---

## 6. Visual acceptance checklist

### Every scene
- [ ] No opaque black or white rectangles unless explicitly designed as world geometry.
- [ ] No full-width cyan slabs or unrelated platform bands.
- [ ] No inactive biome scenery visible after crossfade completion.
- [ ] No unexplained square particle tiles or atlas-cell artifacts.
- [ ] No visible hard rectangular texture bounds in fog, glow, smoke or lightning effects.
- [ ] No large unintentional terrain fill rectangles.
- [ ] No mismatched foreground scale or clipped character sprites.
- [ ] Vehicle, wheels and active road remain readable and visually connected.
- [ ] HUD safe areas remain free of environmental props.
- [ ] All decorative scenery is non-colliding unless explicitly designed as a hazard/platform.

### Heaven
- [ ] Palace gate and columns form one deliberate composition.
- [ ] Angel statue silhouette is readable.
- [ ] Doves are visibly animated in open sky space.
- [ ] Cloud/fog opacity preserves depth and contrast.
- [ ] Marble/cloud road has believable thickness and clear surface contour.
- [ ] No Hell/Normal background or terrain fill remains after transition.

### Hell
- [ ] Volcanic panorama and bridge read as one coherent environment.
- [ ] Basalt road is textured, readable and not mostly empty black fill.
- [ ] Lava is visible but does not obscure the driveable route.
- [ ] Ash/cinders replace snow-like white particles.
- [ ] Characters are scaled as background set pieces and do not overlap the vehicle.
- [ ] No oversized/cropped cartoon creature remains in active gameplay unless redesigned and approved.
- [ ] No Heaven/Normal background or terrain fill remains after transition.

### Transitions and merges
- [ ] Heaven and Hell route choice comes from actual gameplay outcome, not a forced visual state.
- [ ] Transition effect is brief, readable and camera-composed.
- [ ] Branch-specific road and collision match throughout the route.
- [ ] Both branches merge to one Normal Land surface with no jump, gap, block, duplicate road or old biome layer.
- [ ] Repeated cycles do not accumulate duplicate CanvasLayers, particles, sprites or terrain segments.

---

## 7. Evidence required for sign-off

Capture these exact states at 1280×720 from the actual running game. Use the actual HUD distance and include active biome ID and route outcome in a JSON sidecar. A filename alone does not prove the biome.

1. Normal Land approach before the gate.
2. Ramp decision window, showing the Nitro cue.
3. Heaven branch after upper-route landing.
4. Heaven mid-route with palace/angel/doves visible.
5. Heaven exit and clean Normal Land merge.
6. Hell catch landing after a missed/insufficient launch.
7. Hell mid-route with basalt/lava/skull/ambient character composition.
8. Hell exit and clean Normal Land merge.
9. A full 5,000m+ run proving no layers or segments accumulate.

For every capture record:
- actual displayed distance and simulation distance;
- route outcome (`HEAVEN` or `HELL`);
- active biome ID;
- active environment scene and visible CanvasLayers;
- active terrain profile and live segment IDs;
- vehicle body/wheel contact state;
- screenshot path.

Also submit raw test logs, current Git diff, and a list of assets marked `DISABLE_RUNTIME` or `REPLACE_LATER`.

---

## 8. Agy execution prompt — audit first, then fix in controlled stages

```text
ENDLESS MAP — DEEP VISUAL FAILURE AUDIT & ART-DIRECTION REMEDIATION

PRIORITY: P0 — VISUAL QA IS NOT APPROVED
ENGINE: Godot 4.7.2, GDScript only
TARGET: 1280x720, Forward Mobile, AMD Radeon 610M
SCOPE: Daniel-owned Endless Map and assets/environments only

I supplied Fault.zip containing 17 screenshots. Review all of them.
Do not ignore any file. The screenshots repeatedly show:
- Normal, Heaven and Hell layers visible together;
- giant cyan/turquoise horizontal slabs;
- large black lightning/glow rectangles and small black tiles;
- overlapping/ghosted clouds, palace, volcanic bridge and hills;
- brown rectangular terrain fills at branch merges;
- oversized/cropped orange goblin/fiend sprites;
- Heaven overexposure/fog and unreadable statue/doves;
- Hell snow-like particles and visually empty black road fill;
- questionable vehicle wheel/suspension alignment in Hell catch frames.

IMPORTANT: The screenshots establish visible symptoms, not exact source paths.
Map every defect to the exact scene node, resource, texture, material and script before editing.
Do not guess filenames or claim an exact root cause without inspecting the project.

PHASE A — AUDIT ONLY (NO MODIFICATIONS)
1. Report current Git status and HEAD. Do not reset, clean, push, rebase or discard changes.
2. Inspect all environment scenes, terrain scenes/scripts, biome host/controller, CanvasLayers, particles, shaders and texture resources.
3. Build a render inventory with node paths, CanvasLayer indices, visibility, alpha/modulate, Z index, texture, material/blend mode and shader.
4. Identify exact nodes producing the cyan slab, black lightning panels, small black tiles, giant orange-dotted blocks, brown terrain rectangles and lower black/orange fill.
5. Trace scene activation/crossfade and prove whether inactive biome CanvasLayers remain visible after transitions.
6. Inspect terrain segment pooling/profile changes and prove whether stale segment visuals survive a biome switch or merge.
7. Inspect source/imported alpha for every rectangle-producing texture; inspect shader alpha and atlas UVs.
8. Inspect vehicle body, wheel, suspension and contact state during the Hell catch sequence.
9. Produce an asset disposition table: KEEP / KEEP_AFTER_FIX / DISABLE_RUNTIME / REPLACE_LATER.
10. Produce a prioritized root-cause report with direct evidence and confidence level.
STOP and request review after the audit. Do not edit files in Phase A.

PHASE B — RENDER/GEOMETRY FIXES (ONLY AFTER PHASE A REVIEW)
1. Fix environment visibility and CanvasLayer ordering first.
2. Ensure inactive biome layers are actually hidden, not merely faded through an unrelated parent.
3. Ensure exactly one active road/terrain visual fill per live segment.
4. Fix segment profile/pooling lifecycle so branch merges do not retain old fills.
5. Align visual road, texture, terrain fill and collision geometry.
6. Remove all cyan slabs that are not intentional, shaped route platforms with matching collision.
7. Disable black-panel lightning/glow VFX until alpha, shader and blend mode render correctly.
8. Fix atlas UVs and alpha where proven.
9. Disable unsuitable oversized/cropped orange character instances from gameplay. Preserve source assets; do not delete originals.
10. Replace Hell snow-like particles with existing suitable ash/cinder assets only after confirming those textures render cleanly.
11. Reduce Heaven fog/overexposure; make palace/angel/doves readable.
12. Improve Hell basalt surface and reduce excessive orange contour thickness.
13. Validate vehicle wheel/suspension presentation through actual landing/fall footage.
14. Remove or contextualize the giant persistent Nitro bottle overlay and make milestone messages time out.

ART-DIRECTION POLICY
- Vehicle remains the focal point.
- Backgrounds may be detailed, but foreground assets must share coherent scale, contrast and style.
- Keep only assets that improve the scene. Disable unsuitable assets from runtime if they cannot be made coherent.
- Never delete originals or license manifests.
- Do not collect/download new assets during this correction.
- Do not cover the problem with extra fog, glow, tint or arbitrary scaling.

STRICT GAMEPLAY PROTECTION
Do not change Nitro route logic, the 500m branch cadence, Heaven/Hell route geometry, the 1,000m Normal merge, vehicle physics, controls, HUD functionality, save/pause/restart, pickup logic, or the authoritative distance counter except when a confirmed visual/physics synchronization bug requires a narrowly scoped fix. Any such gameplay fix must be reported separately and tested.
Preserve one terrain generator and all existing terrain archetypes.
Do not modify Garage, Survival, Indian Roads, main menu, other team-owned game modes or shared vehicle systems beyond necessary reviewed integration.

VALIDATION
- Run all existing tests unchanged first; record raw output and exit codes.
- Add targeted render/visibility/merge tests only where needed.
- Capture 1280x720 screenshots for Normal, Heaven, Hell, both returns and 5,000m+ continuous progression.
- Record active biome ID, visible CanvasLayers, terrain profile and vehicle contact telemetry for every screenshot.
- Measure performance using the same method for all scenes; explain outliers instead of selectively reporting the best frame.
- Do not call visual QA PASS until screenshots show one coherent biome, one correct road, no opaque rectangles and no stale environment layers.

EXECUTION CONTROL
Do only Phase A now. Do not start Phase B before review. Provide exact source paths, evidence, confidence levels and the complete asset disposition table. Stop.
```

---

## 9. What can and cannot be concluded from Fault.zip

### Confirmed from the screenshots
- The cyan slabs, black panels, mixed biome layers, overexposed Heaven presentation, oversized character sprites, terrain blocks and clutter are visible defects.
- The same defect patterns recur across multiple captures, so they need systemic investigation.
- At least one image filename (`phase2_outcome_heaven_3_active.png`) does not match the environment visibly shown in that image.

### Not confirmed without project source/runtime inspection
- The exact PNG/TRES/GDScript node responsible for each rectangle.
- Whether black panels are opaque source textures, an alpha-import issue, a shader output issue or incorrect blend mode.
- Whether cyan slabs are oversized scenery sprites, CanvasLayer artifacts, terrain fills or platform meshes.
- Whether terrain blocks come from polygon closure, stale pooled segments or duplicate terrain owners.
- Whether the wheel/suspension appearance is a physics error or a transient falling/catch animation.
- Whether Agy's reported test counts/performance numbers are valid; this ZIP contains screenshots, not raw logs or benchmark JSON.

Do not convert any of these unknowns into asserted root causes. Phase A must prove them from exact scene/resource/runtime evidence.

---

## 10. Godot technical references used for the audit

These official Godot references explain why the audit must inspect CanvasItem inheritance, CanvasLayer ordering and material blend modes instead of changing only sprite positions:

- [CanvasItem (Godot 4.7)](https://docs.godotengine.org/en/4.7/classes/class_canvasitem.html) — CanvasItem visibility/modulation/Z behaviour; the documentation notes that transform, modulation and visibility propagation is limited to direct CanvasItem children, and non-CanvasItem nodes between items can create independent chains.
- [CanvasLayer (Godot 4.7)](https://docs.godotengine.org/en/4.7/classes/class_canvaslayer.html) — independent rendering layers and numeric draw order; a CanvasLayer's layer order is separate from CanvasItem `z_index`.
- [CanvasItemMaterial (Godot 4.7)](https://docs.godotengine.org/en/4.7/classes/class_canvasitemmaterial.html) — Mix, Add, Subtract, Multiply and Premultiplied Alpha blend modes.
- [CanvasItem shaders (Godot 4.7)](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/canvas_item_shader.html) — canvas shader blend modes including `blend_mix`, `blend_add` and `blend_disabled`.
- [Parallax2D (Godot latest)](https://docs.godotengine.org/en/latest/classes/class_parallax2d.html) — repeating texture offsets and repeat size for seamless scrolling; confirm the project uses the node type/properties appropriate to its current implementation.

These references are diagnostic guidance, not proof that a specific project node is responsible. The project tree and resource data must identify the actual cause.
