# DANIEL — ENDLESS MAP + HEAVEN + HELL MASTER TODO

> **Purpose:** The single phase-by-phase work checklist for Daniel's part of the Hill-Climb project. Tick each task only after it has been completed and verified. Execute one phase at a time with Agy CLI; do not ask Agy to run the entire roadmap in one pass.

| Project detail | Value |
|---|---|
| Project | Hill-Climb / Endless-Hillclimb |
| Project root | `~/DUMB-SPOT/Hill-Climb/Endless-Hillclimb/` |
| Research/staging root | `~/Downloads/hill-climb-asset-research/` and `~/DUMB-SPOT/Hill-Climb/full_assets/` where present |
| Engine | Godot 4.7.2 Stable |
| Language | GDScript only |
| Renderer target | Godot Mobile / Vulkan |
| Target hardware | AMD Radeon 610M integrated GPU |
| Owner | Daniel |
| Expected working branch | `feature/endless-heaven-hell-integration` |
| Last user-reported commit | `7c2a801` |
| Current next phase | **Phase 4 — World-Cycle Configuration and Biome Progression** |
| Scope | Daniel's Normal Land, Endless Map, Heaven, Hell and their integration only |

---

## HOW TO USE THIS TODO

- [ ] Do not tick a task because Agy says it is done; require the file, test, preview or runtime evidence listed for it.
- [ ] Work in the order shown. A phase cannot start until its predecessor's exit gate passes.
- [ ] At the start of every phase, inspect Git status, branch, HEAD, Godot version and the last phase report.
- [ ] At the end of every phase, update this checklist, create the phase report, list changed files, run tests and stop for Daniel's review.
- [ ] Do not authorize a later phase automatically. Daniel approves each phase separately.
- [ ] Use the Agy prompt at the end of each phase. Copy only the prompt for the phase currently authorized.
- [ ] Mark a task `BLOCKED` in the Notes column or phase report when evidence is missing. Do not quietly skip it.

**Checkbox meanings**

- `[x]` Completed and verified with evidence.
- `[ ]` Not started or still pending.
- `BLOCKED` Work cannot proceed until a dependency or decision is resolved.
- `N/A` Not applicable, with a written reason.

---

# A. PROJECT SCOPE AND RULES

## A1. What Daniel is building

- [x] Preserve the already playable vehicle-based Endless Map as the base game.
- [ ] Renovate the existing Endless Map so one continuous drive passes through Normal Land, Heaven, Normal Land, Hell, and back into the repeating cycle.
- [ ] Keep the player driver seated in the selected vehicle. Do not create an independently controlled walking player character.
- [ ] Use the collected Heaven and Hell art, audio, VFX and characters to create distinct worlds.
- [ ] Preserve the current vehicle, wheel, suspension, fuel, coin, HUD, save, pause, results, crash and restart systems.
- [ ] Preserve the existing procedural terrain generator, its nine curve archetypes, collision generation, pooling and recycling.

## A2. Explicitly outside Daniel's scope

- [x] Do not take over or rebuild Garage, Survival, Indian Roads, main-menu mode selection or another teammate's independent feature.
- [x] Do not replace the existing procedural terrain generator with a second generator.
- [x] Do not replace vehicle physics or redesign the vehicle controller as part of environment work.
- [x] Do not create combat/weapon systems merely because character attack animations exist.
- [x] Do not create a new currency or fuel system for themed collectibles.
- [x] Do not restart broad asset collection for categories already collected and approved.

## A3. Team ownership and shared files

- [ ] Before changing a shared file, read `docs/team/SHARED_GAME_INTERFACES.md` and the current ownership contract.
- [ ] Keep changes inside Daniel-owned environment/Endless Map files wherever practical.
- [ ] For necessary shared integration changes (for example `Game.gd`, `Game.tscn`, `project.godot` or shared signals), document why, make the smallest change, inspect the diff and preserve existing APIs/signals.
- [ ] Coordinate with the relevant teammate before changing their owned files.

## A4. Git safety — required before every phase

Run from the project root:

```bash
cd ~/DUMB-SPOT/Hill-Climb/Endless-Hillclimb

git status --short --branch
git log -5 --oneline --decorate
git remote -v
godot --version
```

- [ ] Confirm the active branch is `feature/endless-heaven-hell-integration`, unless Daniel/team explicitly changed it.
- [ ] Confirm the working tree is clean, or record and preserve all existing changes before touching files.
- [ ] Never run `git reset --hard`, `git clean -fd`, destructive checkout/restore commands or force-push.
- [ ] Never delete/reclone the current project as a synchronization shortcut.
- [ ] Do not change `origin` or `bharath` remotes without approval.
- [ ] Do not push, open a PR or publish to either remote until Daniel confirms the exact team target/workflow.
- [ ] Do not create a commit unless Daniel explicitly approves a checkpoint commit.
- [ ] Keep full source archives/research packs outside the production project; keep only necessary runtime assets and source/licence records in the project.

## A5. Asset, licence and performance rules

- [ ] Preserve original downloaded files and raw animation frames.
- [ ] Preserve `MANIFEST.json`, `SOURCES.md`, `LICENSES.md` and required attribution.
- [ ] Verify the exact licence of each asset; never infer a whole pack's licence from the artist name.
- [ ] Do not overwrite or destructively recolour original artwork. Store any derivative as a new documented file.
- [ ] Do not add duplicate copies of textures/resources when an existing resource can be reused.
- [ ] Keep transparent overdraw, full-screen effects, lights and particle counts conservative for Radeon 610M.
- [ ] Cull off-screen animated characters and expensive VFX where appropriate.
- [ ] Treat prior VRAM figures as estimates until confirmed from actual imports/runtime profiling.
- [ ] A 60 FPS target means 16.67 ms per frame; report measured frame time and test conditions rather than promising FPS.

## A6. Required workflow for every phase

- [ ] R&D: inspect current files, dependencies, source/licence and platform limitations before coding.
- [ ] Logic: specify rules, calculations, transition boundaries and error conditions.
- [ ] State: define authoritative state, resets, signals and lifecycle behavior.
- [ ] Presentation: build resources, scenes, art, shader, audio, animation and VFX.
- [ ] Experience: test driving feel, clarity, fairness, mobile performance and restart behavior.
- [ ] Add/adjust focused tests without weakening existing tests.
- [ ] Run Godot 4.7.2 headless import/scan after resource changes.
- [ ] Run focused phase tests and relevant existing regressions.
- [ ] Perform manual editor/gameplay checks where headless tests cannot prove visual, audio or physics behavior.
- [ ] Produce a report with PASS / FAIL / BLOCKED, commands, exit codes, changed files, evidence and remaining risks.
- [ ] Stop and wait for Daniel's explicit approval before the next phase.

---

# B. CURRENT BASELINE — ALREADY COMPLETED

## B1. Existing project foundation

- [x] Existing Godot project located at `~/DUMB-SPOT/Hill-Climb/Endless-Hillclimb/`.
- [x] Existing game scenes, vehicle scenes, UI, pickups, terrain and automated tests retained.
- [x] Existing Normal Land terrain, terrain details, scenery, sky and countryside parallax already exist in the project.
- [x] Existing gold coin and fuel-can pickup art/scenes/logic already exist; do not recollect these.
- [x] Existing `TerrainGenerator.gd` and `TerrainSegment.gd` remain the foundation; do not create another generator.

## B2. Heaven and Hell asset collection / Phase 1

- [x] Heaven asset collection researched and approved.
- [x] Hell asset collection researched and approved, including skulls, terrain hazards, VFX and characters.
- [x] Heaven and Hell runtime assets ingested into `assets/environments/heaven/` and `assets/environments/hell/`.
- [x] Asset manifests, sources and licence records created.
- [x] Sixty raw dove frames preserved.
- [x] Dove atlas and metadata generated.
- [x] Godot 4.7.2 headless import reported successful for Phase 1 assets.
- [x] Phase 1 report created: `docs/PHASE_1_ENVIRONMENT_ASSET_INTEGRATION_REPORT.md`.
- [x] Phase 1 local commit reported: `4a77744`.

## B3. Team synchronization

- [x] Bharath remote added as secondary remote (`bharath`).
- [x] Bharath's `feature/gameplay-assets-update` fetched.
- [x] Bharath's team foundation merged into Daniel's feature branch.
- [x] Local merge commit reported: `3779e1e`.
- [x] Shared-foundation test UID tracked in commit `7c2a801`.
- [x] Existing 13 `tests/test_*.gd` scripts were run; their test assertions reported PASS.
- [x] `git status --short --branch` most recently showed the expected feature branch without pending files.
- [ ] At the next phase pre-flight, confirm the above Git state again; these are user-reported results, not a live check by this document.

**Known regression-test cleanup warnings:** Some tests printed `ObjectDB instances were leaked at exit` and `resources still in use at exit`. The functional assertions shown by the user passed, but these shutdown warnings are still a tracked investigation item for Phase 8 (or earlier if they block a current phase). Do not claim the entire test process is warning-free until proven.

---

# C. WORLD DESIGN — BASELINE SCHEDULE

Use one continuous Endless Map. The following schedule is the approved planning baseline from Daniel's integration plan. Keep distances in one configuration/resource, not scattered as magic numbers.

| Distance in one cycle | World/transition | Required experience |
|---:|---|---|
| 0–1,000 m | Normal Land | Countryside start |
| 1,000–1,150 m | Normal Land → Heaven | Launch ramp and Golden Palace gateway |
| 1,150–2,200 m | Heaven | Celestial palace, clouds and gardens |
| 2,200–2,350 m | Heaven → Normal Land | Cloud-slide return ramp |
| 2,350–3,500 m | Normal Land | Expert slopes and dips |
| 3,500–3,650 m | Normal Land → Hell | Volcanic chasm plunge and Dragon Skull portal |
| 3,650–5,000 m | Hell | Volcanic basalt and magma caverns |
| 5,000–5,150 m | Hell → Normal Land | Magma geyser escape ramp back to sunlight |
| 5,150 m onward | Repeating cycle | Repeat schedule with validated difficulty progression |

- [ ] Validate the schedule against the current game's speed, terrain segment size and expected run length.
- [ ] Keep progression schedule boundaries separate from the physical length/shape of ramp geometry; the schedule's 150 m transition window does not prove a 150 m physical ramp is required.
- [ ] The prior `+0.15` difficulty increase per completed 5,150 m cycle is a proposal to validate against the existing difficulty model, not a final constant. Do not implement until the generator's current scaling behavior is understood and tested.
- [ ] Use the existing authoritative run-distance value; do not add a second distance counter that can diverge from HUD/save telemetry.

---

# PHASE 0 — PREFLIGHT AND BASELINE RECHECK

**Status:** Previously completed as part of merge/test work; re-run the short checks before Phase 2 and at each major phase boundary.

## TODO checklist

- [ ] Open the correct project root: `~/DUMB-SPOT/Hill-Climb/Endless-Hillclimb/`.
- [ ] Confirm branch: `feature/endless-heaven-hell-integration`.
- [ ] Confirm latest HEAD and remotes; preserve both `origin` and `bharath`.
- [ ] Confirm no unexplained working-tree changes exist.
- [ ] Confirm Godot version is 4.7.2 Stable.
- [ ] Read `docs/team/SHARED_GAME_INTERFACES.md` and Daniel's assigned ownership boundaries.
- [ ] Confirm Phase 1 Heaven/Hell folders, manifests, licence files and dove atlas exist.
- [ ] Confirm the previous regression baseline and known shutdown warnings are documented.
- [ ] Create/update `docs/PHASE_0_BASELINE_REPORT.md` only if the baseline has changed or a new verification record is needed.

## Phase 0 exit gate

- [ ] Correct project, branch, Godot version and team boundary confirmed.
- [ ] Working tree clean or changes explicitly preserved/documented.
- [ ] Phase 1 assets are present and not damaged.
- [ ] No unresolved blocker prevents Phase 2.

## Agy CLI prompt — Phase 0

```text
Run Phase 0 preflight only for Daniel's Endless Map Heaven/Hell work.
Project: ~/DUMB-SPOT/Hill-Climb/Endless-Hillclimb/
Expected branch: feature/endless-heaven-hell-integration
Godot: 4.7.2 Stable.

Inspect Git status, HEAD, history and both remotes; verify the Phase 1 asset folders/manifests/report; read the shared team interface contract; verify Godot version and the current test baseline. Note the known ObjectDB/resource shutdown warnings accurately.
Do not edit project files, switch branches, fetch, merge, commit, push, reset, clean or delete anything. Create/update docs/PHASE_0_BASELINE_REPORT.md only if required. Report PASS/FAIL/BLOCKED and stop.
```

---

# PHASE 1 — HEAVEN / HELL ASSET INGESTION AND ATLAS PACKING

**Status: COMPLETE — DO NOT REPEAT.**

## Historical completion checklist

- [x] Copy approved Heaven assets into `assets/environments/heaven/`.
- [x] Copy approved Hell assets into `assets/environments/hell/`.
- [x] Preserve source, licence and manifest documentation.
- [x] Preserve the 60 raw dove frames.
- [x] Build the 2048×2048 runtime dove atlas and metadata.
- [x] Preserve the 3200×3200 higher-resolution atlas where included in the report.
- [x] Run Godot 4.7.2 headless import; Phase 1 report states PASS.
- [x] Keep production gameplay scripts/scenes and `project.godot` untouched during ingestion.
- [x] Create `docs/PHASE_1_ENVIRONMENT_ASSET_INTEGRATION_REPORT.md`.

## Phase 1 closeout

- [x] Phase 1 is committed locally in the Daniel feature branch.
- [x] Do not download, recollect, recopy or rebuild the atlas unless a later validation finds a specific defect.

---

# TEAM SYNCHRONIZATION — BHARATH FOUNDATION

**Status: COMPLETE LOCALLY — DO NOT REPEAT WITHOUT A NEW TEAM UPDATE.**

## Historical completion checklist

- [x] Preserve Daniel's Phase 1 work in local commit `4a77744`.
- [x] Add Bharath's repo as `bharath` without changing `origin`.
- [x] Fetch `bharath/feature/gameplay-assets-update`.
- [x] Merge Bharath's branch; reported merge commit `3779e1e`.
- [x] Run Godot 4.7.2 headless editor import.
- [x] Run `tests/test_phase2_shared_foundation.gd`; all five assertions reported PASS.
- [x] Track `tests/test_phase2_shared_foundation.gd.uid` in commit `7c2a801`.
- [x] Run all 13 existing test scripts; all visible test assertions reported PASS.
- [ ] Investigate shutdown cleanup warnings during Phase 8; do not hide them.
- [ ] Confirm publication/push destination with Bharath before any push.

---

# PHASE 2 — SHADERS, AUDIO BUSES AND SPRITEFRAMES

**Status: COMPLETE — READY FOR PHASE 3.**

**Goal:** Turn the collected artwork, audio and animation frames into reusable Godot 4.7.2 runtime resources. Do not yet implement biome progression or live environment switching.

## 2A. Preflight and inventory

- [x] Confirm Phase 0 passes and working tree is clean/understood.
- [x] Read `docs/PHASE_1_ENVIRONMENT_ASSET_INTEGRATION_REPORT.md`.
- [x] Inspect both environment `MANIFEST.json`, `SOURCES.md` and `LICENSES.md` files.
- [x] Inspect current Heaven/Hell folder tree; use actual names rather than assuming paths.
- [x] Inspect the current Hell `heat_distortion_shimmer.gdshader` before creating another shader.
- [x] Inspect dove atlas metadata and verify the atlas layout before building SpriteFrames.
- [x] Record exact source image/frame dimensions, animation ordering and any source-specified FPS.

## 2B. Heaven shader resources

- [x] Decide which effects genuinely need shaders; prefer artwork/particles when a shader adds no value.
- [x] Create a restrained golden atmospheric glow shader/material if needed.
- [x] Create/prepare palace or window light treatment if needed.
- [x] Create a lightweight soft-ray or mask treatment only if the existing masks can support it.
- [x] Prepare a subtle cloud transition blend/overlay shader if needed for later phases.
- [x] Keep sparkle/magic particles lightweight; do not make unnecessary shaders for every particle texture.
- [x] Expose documented uniforms with safe default values (for example tint, intensity, speed or blend amount where applicable).

## 2C. Hell shader resources

- [x] Validate/reuse `heat_distortion_shimmer.gdshader` for Godot 4.7.2 Mobile renderer.
- [x] Create or reuse a low-cost lava shimmer treatment where needed.
- [x] Create or reuse a subtle magma glow treatment where needed.
- [x] Reuse approved ash/ember artwork; do not create duplicate visual assets.
- [x] Avoid costly screen-texture reads/full-screen effects unless tested and justified.
- [x] Add shader comments explaining uniforms and performance-sensitive operations.

## 2D. Audio bus layout

- [x] Inspect the project's current audio bus layout and project settings.
- [x] Create/confirm buses: `Master`, `Music`, `Ambience`, `SFX`, `UI`.
- [x] Route all child buses to `Master`.
- [x] Plan Heaven music (`heavenly_loop.ogg`) on `Music`.
- [x] Plan Heaven wind/chimes on `Ambience` or `SFX` according to intended behavior (document choice).
- [x] Plan Hell music (`hell_insistent_loop.ogg`) on `Music`.
- [x] Plan Hell fire/dark ambience on `Ambience`.
- [x] Keep vehicle/pickup/impact sounds on `SFX` and interface sounds on `UI`.
- [x] Preserve audio import loop settings already created in Phase 1.
- [x] Add only the minimum `project.godot` audio-layout reference required by Godot; inspect and explain its exact diff.
- [x] Do not write biome-based music-switching logic yet; that belongs to Phase 6.

## 2E. SpriteFrames resources — Heaven

- [x] Create a dove `SpriteFrames` resource from the 2048×2048 runtime atlas and metadata.
- [x] Include exactly 60 populated cells; exclude the four unused cells from the 8×8 grid.
- [x] Verify each atlas region is inside texture bounds and has the correct 256×256 cell coordinates unless metadata specifies otherwise.
- [x] Set 24 FPS only if confirmed by the source animation metadata; otherwise document the proposed value as provisional.
- [x] Preserve the raw 60 PNG frames and original atlases unchanged.

## 2F. SpriteFrames resources — Hell

- [x] Skeleton Knight: idle — exactly 10 frames.
- [x] Skeleton Knight: walk — exactly 10 frames.
- [x] Skeleton Knight: attack1 — exactly 10 frames.
- [x] Skeleton Knight: attack2 — exactly 10 frames.
- [x] Skeleton Knight: dead — exactly 7 frames.
- [x] Ground Demon Goblin: idle — exactly 8 frames.
- [x] Ground Demon Goblin: walk — exactly 43 frames.
- [x] Horned Fiend: walk — exactly 13 frames.
- [x] Flying Hell Dragon: fly — exactly 4 frames.
- [x] Fire: exactly 25 frames; inspect the 5×5 sheet and exclude no populated frame or include unused cells by assumption.
- [x] Verify all frame order, consistent dimensions, transparency and character alignment.
- [x] Use documented/source FPS when available; otherwise record provisional playback timing for later visual review.
- [x] Do not create combat gameplay from the attack/dead clips; they are animation resources only.

## 2G. Resource tests and report

- [x] Create `tests/test_phase2_environment_resources.gd` and its `.uid`.
- [x] Assert every SpriteFrames resource loads.
- [x] Assert required animation names exist.
- [x] Assert exact frame counts for every animation above.
- [x] Assert every texture/atlas resource exists and loads.
- [x] Assert dove regions stay within atlas bounds and exactly 60 frames are used.
- [x] Assert audio buses exist and route to `Master` as intended.
- [x] Assert looping audio settings remain enabled for the intended loops.
- [x] Validate shader parsing/compilation in Godot 4.7.2 Mobile-compatible context.
- [x] Run `godot --headless --editor --quit`.
- [x] Run the new Phase 2 test and relevant existing regression tests.
- [x] Record exact test commands, exit codes, warnings and errors.
- [x] Create `docs/PHASE_2_RESOURCE_CONSTRUCTION_REPORT.md`.

## Phase 2 exit gate — all must pass

- [x] All required shader resources load/compile.
- [x] Audio bus layout and routes are correct.
- [x] Every SpriteFrames resource loads and has correct animation/frame counts.
- [x] No missing texture, atlas or audio references.
- [x] No unexpected modifications to terrain, vehicle, main-menu or teammate-owned systems.
- [x] Headless import and focused tests pass.
- [x] Relevant previous regressions remain passing.
- [x] Report and changed-file inventory are complete.
- [ ] Daniel reviews the report and explicitly authorizes Phase 3.

## Agy CLI prompt — Phase 2

```text
AUTHORIZATION: Execute Phase 2 ONLY — Shaders, Audio Buses and SpriteFrames.
Project: ~/DUMB-SPOT/Hill-Climb/Endless-Hillclimb/
Branch: feature/endless-heaven-hell-integration
Engine: Godot 4.7.2 Stable; GDScript; Mobile/Vulkan target.

Read this TODO's entire Phase 2 section and docs/PHASE_1_ENVIRONMENT_ASSET_INTEGRATION_REPORT.md first. Verify Git status/branch/HEAD and stop if unexpected modifications exist.

Inspect current Heaven/Hell assets, manifests, licence records, the existing heat shimmer shader, dove atlas and metadata. Do not repeat Phase 1 ingestion or recollect assets.

Complete all Phase 2 checkboxes: build/validate only necessary lightweight Heaven/Hell shaders; create Master/Music/Ambience/SFX/UI bus layout with correct routing; make only the minimum required project.godot audio-layout reference change; create SpriteFrames resources with exact frame counts for dove (60), skeleton knight (10/10/10/10/7), goblin (8/43), horned fiend (13), flying dragon (4), and fire (25). Use the source frame ordering and metadata; do not invent FPS values.

Create tests/test_phase2_environment_resources.gd and its UID. Validate resources, names, frame counts, atlas bounds, audio routes, loops and shaders. Run Godot headless import, focused tests and relevant regressions. Record actual commands, exit codes, warnings, errors and changed files.

Do not implement biome switching, environment scenes, transition ramps or live gameplay changes. Do not modify TerrainGenerator.gd, TerrainSegment.gd, VehicleController.gd, menus or teammate modes. Do not commit or push.

Create docs/PHASE_2_RESOURCE_CONSTRUCTION_REPORT.md, update this TODO's Phase 2 status, then STOP and wait for Daniel's Phase 3 approval.
```

---

# PHASE 3 — HEAVEN AND HELL ENVIRONMENT SCENES

**Status: COMPLETE — READY FOR PHASE 4.**

**Goal:** Assemble reusable Heaven and Hell 2D environment scenes that can later be activated by the biome controller. Do not yet connect them to distance progression.

## 3A. Shared scene structure

- [x] Inspect the current `ParallaxEnvironment.tscn` and script; reuse the established camera/parallax conventions.
- [x] Define a consistent environment root contract for Heaven and Hell.
- [x] Keep background, far/mid/near decorations, architecture, characters/wildlife and VFX in separate intentional layers.
- [x] Keep physical driving terrain outside the environment background roots.
- [x] Avoid empty unused nodes and duplicate parallax controllers.

## 3B. Heaven environment scene

- [x] Create `scenes/environment/heaven/HeavenEnvironment.tscn`.
- [x] Add the selected puffy blue sky background.
- [x] Compose golden palace archway/gateway, columns, windows, ceiling/floor elements as scenery.
- [x] Add flowers and angel statue at suitable depth/scale.
- [x] Add the dove SpriteFrames actor using the Phase 2 resource.
- [x] Add restrained clouds, golden glow and sparkle VFX.
- [x] Establish far/mid/near parallax depth and speed factors.
- [x] Ensure architecture and VFX do not cover the driving lane or obscure upcoming ground.

## 3C. Hell environment scene

- [x] Create `scenes/environment/hell/HellEnvironment.tscn`.
- [x] Choose and document the volcanic background variant(s) for the main Hell zone.
- [x] Compose basalt columns, volcanic rocks/crags, skull decorations and dragon-skull portal scenery.
- [x] Add lava artwork, fire effects, embers/cinders, ash/smoke and restrained heat shimmer.
- [x] Prepare skeleton/demon/dragon actor placement using Phase 2 SpriteFrames.
- [x] Establish far/mid/near parallax depth and speed factors.
- [x] Ensure background decorations do not create accidental physics colliders.
- [x] Keep the active vehicle/tire corridor clear and readable.

## 3D. Visual and performance review

- [x] Use actual game camera/world coordinates; do not copy preview mockup pixel coordinates blindly.
- [x] Check scene scale against the existing vehicle and wheel size.
- [x] Check palette/style consistency with Normal Land.
- [x] Check background looping/repeating seams.
- [x] Add culling/visibility handling for off-screen animated actors and VFX.
- [x] Keep node counts, transparent overlays and active animations within a measured budget.
- [x] Generate actual in-engine scene previews for review.

## 3E. Tests and report

- [x] Create tests that load each environment scene independently.
- [x] Assert expected root/layer nodes and referenced resources exist.
- [x] Check there are no missing resource references.
- [x] Check decorative environment layers do not own unintended terrain/vehicle collision.
- [x] Run headless import and relevant regressions.
- [x] Manually open/run both scenes in Godot and inspect framing/draw order.
- [x] Create `docs/PHASE_3_ENVIRONMENT_SCENES_REPORT.md` with previews and changed-file list.

## Phase 3 exit gate

- [x] Heaven scene loads and visually composes correctly.
- [x] Hell scene loads and visually composes correctly.
- [x] Correct parallax layering and camera alignment verified.
- [x] Driving corridor remains unobstructed.
- [x] No accidental physics/collision from background decoration.
- [x] Culling/performance approach documented.
- [x] Tests/import pass; report complete.
- [ ] Daniel explicitly authorizes Phase 4.

## Agy CLI prompt — Phase 3

```text
AUTHORIZATION: Execute Phase 3 ONLY — reusable Heaven and Hell environment scenes.
Read this TODO's Phase 3, Phase 2 report, Phase 1 report, manifests and licences first. Verify Phase 2 PASS and inspect Git state.

Create scenes/environment/heaven/HeavenEnvironment.tscn and scenes/environment/hell/HellEnvironment.tscn using the existing camera/parallax conventions. Heaven: sky, golden palace architecture, flowers, angel statue, dove, clouds and restrained glow/sparkles. Hell: volcanic background, basalt/crags, skulls, lava, fire, embers/ash, heat shimmer and prepared character layers. Use Phase 2 resources and only approved ingested assets.

Separate background/depth/architecture/character/VFX layers. Do not place physical driving terrain in these environment roots. Do not add accidental colliders. Keep actual game driving lane and vehicle silhouette visible. Use real world coordinates, add culling for off-screen animation/VFX, and create actual in-engine previews.

Do not implement biome progression, distance triggers, transition ramps or live Game.tscn switching. Do not edit terrain generation/physics, vehicle physics, menus or teammate modes. Do not commit or push.

Test independent scene loading, resource references, layer organization, collision isolation and headless import. Run relevant regressions. Create docs/PHASE_3_ENVIRONMENT_SCENES_REPORT.md, update this TODO and STOP for Daniel's Phase 4 approval.
```

---

# PHASE 4 — WORLD-CYCLE CONFIGURATION AND BIOME PROGRESSION

**Status: NOT STARTED — depends on Phase 3 PASS.**

**Goal:** Add one authoritative, testable world schedule and biome-state controller. Do not yet change terrain geometry or switch the live environment scenes.

## 4A. World schedule resource/config

- [ ] Define one typed resource/configuration for the 5,150 m cycle shown in Section C.
- [ ] Store range start/end, biome or transition ID, scene/profile key and transition ID in one place.
- [ ] Validate ranges are ordered, contiguous, non-overlapping and cover the full cycle.
- [ ] Store schedule distances as configurable data, not repeated magic numbers across scripts.
- [ ] Represent repeating cycles using cycle index plus distance-within-cycle (or an equivalent tested approach).
- [ ] Document all boundary inclusivity rules (which state owns an exact boundary value).

## 4B. Biome progression controller

- [ ] Inspect the authoritative existing distance source (`GameManager`/current run interface) before coding.
- [ ] Consume the existing distance; do not maintain an independent drifting counter.
- [ ] Resolve current world region and transition state from schedule data.
- [ ] Emit one clear signal when biome/transition state changes.
- [ ] Expose normalized transition progress only if later presentation requires it.
- [ ] Handle a large distance jump crossing multiple boundaries in one update.
- [ ] Reset cycle index/state cleanly on run restart.
- [ ] Handle pause/resume without duplicating transition events.
- [ ] Keep controller separate from terrain geometry and rendering.

## 4C. Difficulty progression decision

- [ ] Inspect the current difficulty-scaling formula in `TerrainGenerator.gd`.
- [ ] Determine whether `+0.15` per completed cycle is compatible and fair.
- [ ] Decide maximum/minimum difficulty bounds with evidence.
- [ ] Ensure difficulty increments exactly once per completed cycle, not per frame/segment.
- [ ] Verify restart semantics and whether persistent run state should reset difficulty.
- [ ] Document the final rule before implementation; leave it disabled if not approved.

## 4D. Tests and report

- [ ] Create `tests/test_biome_progression.gd`.
- [ ] Test just before, exactly at and just after each boundary.
- [ ] Test all four transition ranges and all biome ranges.
- [ ] Test large multi-boundary distance jumps.
- [ ] Test repeated cycle calculation beyond 5,150 m and beyond 10,300 m.
- [ ] Test pause/resume, restart and no repeated signal spam.
- [ ] Test no gaps/overlaps and floating-point boundary behavior.
- [ ] Create `docs/PHASE_4_BIOME_PROGRESSION_REPORT.md` including the actual state transition table.

## Phase 4 exit gate

- [ ] Schedule config validates as continuous and non-overlapping.
- [ ] Correct biome/transition resolves at every boundary.
- [ ] Multi-cycle progression is correct.
- [ ] Restart and pause/resume are correct.
- [ ] Signal emission is deterministic and not duplicated.
- [ ] Difficulty behavior is verified or explicitly deferred.
- [ ] No terrain geometry or live environment integration was introduced prematurely.
- [ ] Tests/report pass and Daniel authorizes Phase 5.

## Agy CLI prompt — Phase 4

```text
AUTHORIZATION: Execute Phase 4 ONLY — world-cycle configuration and biome progression.
Read this TODO's Section C and Phase 4. Verify Phase 3 PASS. Inspect current GameManager/run-distance/reset APIs and TerrainGenerator difficulty logic before coding.

Create one typed world-cycle configuration for the 5,150 m schedule and a focused BiomeProgressionController that consumes the existing authoritative run distance. Implement deterministic biome/transition resolution, cycle index, transition progress if needed, one-shot state-change signals, large-distance-jump handling and clean restart/pause behavior. Keep schedule data separate from visuals and terrain geometry.

Treat +0.15 difficulty per cycle as proposed only: inspect the current formula, justify bounds, and implement only if compatible and approved by existing project rules. Otherwise report it as deferred; do not invent a replacement scaling system.

Create tests/test_biome_progression.gd for every boundary, multi-boundary jumps, multi-cycle repetition, restart, pause/resume and duplicate-signal prevention. Run headless import and regressions. Do not modify TerrainGenerator.gd/TerrainSegment.gd geometry, create ramps or switch environment scenes in this phase. Do not change vehicles, menus or teammate modes. No commit/push.

Create docs/PHASE_4_BIOME_PROGRESSION_REPORT.md with schedule table, state model, APIs, changed files and test evidence. Update this TODO and STOP for Phase 5 approval.
```

---

# PHASE 5 — BIOME TERRAIN PROFILES AND FOUR CONTINUOUS RAMPS

**Status: NOT STARTED — depends on Phase 4 PASS.**

**Goal:** Apply Normal Land/Heaven/Hell visual terrain profiles and build four physically continuous transitions while preserving the existing generator.

## 5A. Preserve existing terrain behavior

- [ ] Read all of `TerrainGenerator.gd`, `TerrainSegment.gd` and their current tests before editing.
- [ ] Record the nine existing curve archetypes and expected continuity/collision invariants.
- [ ] Preserve the current curve generation, Hann-windowed behavior, center bias, pooling/recycling and difficulty semantics.
- [ ] Preserve public interfaces used by Game, pickups, HUD, camera and tests.
- [ ] Extend through small profile/configuration hooks; do not create a second generator.

## 5B. Biome terrain visual profiles

- [ ] Create data-driven Normal Land visual profile using current grass/soil/cliff/decoration artwork.
- [ ] Create Heaven profile using marble/golden platform treatment and appropriate cloud/gold edge presentation.
- [ ] Create Hell profile using basalt, volcanic rock and magma seam/edge presentation.
- [ ] Separate terrain visuals from collision geometry; never derive physics from sprite alpha.
- [ ] Ensure the collision surface is generated explicitly and stays synchronized with the visible drive surface.
- [ ] Use normal ground decoration/side art without covering wheel contact or hiding slope contours.

## 5C. Transition 1 — Normal Land to Heaven

- [ ] Build the launch-ramp profile/segment.
- [ ] Compose the Golden Palace gateway/portal as visual scenery.
- [ ] Define ramp start/end position and tangent continuity.
- [ ] Match visible ramp surface to actual collision surface.
- [ ] Test ascent, launch, vehicle rotation and landing clearance.

## 5D. Transition 2 — Heaven to Normal Land

- [ ] Build the cloud-slide return-ramp profile/segment.
- [ ] Compose cloud/white/gold transition visuals.
- [ ] Define start/end position and tangent continuity.
- [ ] Match visible ramp surface to actual collision surface.
- [ ] Test descent, landing, wheel contact and return to Normal Land ground style.

## 5E. Transition 3 — Normal Land to Hell

- [ ] Build the volcanic chasm plunge transition profile/segment.
- [ ] Compose Dragon Skull portal and volcanic atmosphere as decoration.
- [ ] Define safe approach, descent/launch and landing geometry.
- [ ] Match visible surface to collision geometry.
- [ ] Test wheel contact, suspension and return to stable ground.

## 5F. Transition 4 — Hell to Normal Land

- [ ] Build the magma geyser escape-ramp profile/segment.
- [ ] Compose magma geyser / sunlight exit transition visuals.
- [ ] Define safe ramp start/end and tangent continuity.
- [ ] Match visible surface to collision geometry.
- [ ] Test escape ramp, airborne phase and sunlight-side landing.

## 5G. Physics and pickup safety

- [ ] Confirm each segment seam has no gaps or unexpected overlap.
- [ ] Confirm tire contact does not sink through or float above the visible surface.
- [ ] Test suspension travel and vehicle angle through each ramp.
- [ ] Test approach speeds and landing states for Blue Flame Truck, Dune Buggy, Orc Racer and Trophy Truck (plus any vehicle retained in the active registry).
- [ ] Confirm the existing nine terrain archetypes still pass.
- [ ] Confirm pooling/recycling stays bounded.
- [ ] Confirm coins/fuel are above ground and not inside hazards or inaccessible gaps.
- [ ] Keep spikes/vents decorative unless a separate hazard design and approval exists.

## 5H. Tests and report

- [ ] Add dedicated transition continuity/physics tests.
- [ ] Update terrain tests only to add coverage; do not weaken existing assertions.
- [ ] Capture actual in-engine previews or short recordings of each ramp.
- [ ] Create `docs/PHASE_5_TERRAIN_AND_TRANSITIONS_REPORT.md` with geometry, collision, vehicle and test evidence.

## Phase 5 exit gate

- [ ] All original nine archetypes remain valid.
- [ ] Three biome visual profiles load and match the correct surfaces.
- [ ] Four transitions have continuous visuals and collision.
- [ ] Representative vehicles pass approach, ramp, air and landing tests.
- [ ] No wheel sinking, severe bounce, collision gap or underground pickup regression.
- [ ] Pooling/recycling remains stable.
- [ ] Report and actual previews complete; Daniel authorizes Phase 6.

## Agy CLI prompt — Phase 5

```text
AUTHORIZATION: Execute Phase 5 ONLY — biome terrain profiles and four continuous transition ramps.
Read this TODO Phase 5, Phase 4 report, current terrain scripts/scenes, terrain tests and collision decisions. Verify Phase 4 PASS.

Preserve TerrainGenerator.gd/TerrainSegment.gd architecture, all nine curve archetypes, Hann-windowed behavior, pooling/recycling, current public APIs and synchronized collision generation. Do not create a second generator or change vehicle physics to mask terrain defects.

Implement data-driven Normal Land, Heaven and Hell visual terrain profiles. Build four transitions: Normal→Heaven Golden Palace launch ramp; Heaven→Normal cloud-slide return; Normal→Hell volcanic chasm/Dragon Skull portal; Hell→Normal magma geyser escape. The schedule's 150 m transition windows are progression regions, not proof of physical ramp length; design geometry from vehicle/surface continuity.

For every ramp define endpoints/tangents, visual/collision matching, tire approach, airtime and landing envelope. Test representative active vehicles, all nine legacy archetypes, seam gaps, wheel contact, suspension, pickup clearance and restart. Decorations must not create colliders; no new active hazards without separate approval.

Add focused tests and actual in-engine previews. Run existing regressions. Create docs/PHASE_5_TERRAIN_AND_TRANSITIONS_REPORT.md with measured evidence and changed-file list. No menu/team-mode changes, no push/commit. Update this TODO and STOP for Phase 6 approval.
```

---

# PHASE 6 — LIVE BIOME SWITCHING, PARALLAX, AUDIO AND VFX

**Status: NOT STARTED — depends on Phase 5 PASS.**

**Goal:** Connect biome progression and terrain profiles to a single continuous runtime drive. No scene reload between worlds.

## 6A. Environment host/controller

- [ ] Design one environment host that manages Normal Land, Heaven and Hell roots.
- [ ] Connect Phase 4 biome state signals to the host.
- [ ] Connect Phase 5 biome terrain profiles to the active terrain presentation.
- [ ] Activate/prepare the next biome before its visible transition where needed.
- [ ] Avoid repeatedly instantiating/freeing entire environments every frame.
- [ ] Keep only appropriate worlds/VFX active; release or pool resources safely.
- [ ] Provide a safe Normal Land/neutral visual fallback if cosmetic resource loading fails.
- [ ] Ensure resource failure never removes driving collision or stops the run.

## 6B. Parallax/background switching

- [ ] Reuse the existing tested Normal Land `ParallaxEnvironment` system.
- [ ] Add compatible Heaven parallax layers.
- [ ] Add compatible Hell parallax layers.
- [ ] Ensure all systems use the same camera reference and world coordinates.
- [ ] Avoid duplicate parallax controllers moving against each other.
- [ ] Blend/replace the active background without visible seams or abrupt pops.
- [ ] Verify background repeat/loop alignment through all four transitions.

## 6C. Audio switching

- [ ] Use Phase 2 Music and Ambience buses.
- [ ] Crossfade Normal Land → Heaven music/ambience.
- [ ] Crossfade Heaven → Normal Land.
- [ ] Crossfade Normal Land → Hell.
- [ ] Crossfade Hell → Normal Land.
- [ ] Keep SFX and UI buses independent from world music changes.
- [ ] Prevent duplicate music/ambience players during boundary changes.
- [ ] Ensure pause/resume preserves the correct track and fade state.
- [ ] Ensure restart returns to the correct Normal Land audio state.

## 6D. VFX switching

- [ ] Activate Heaven cloud, light, dove and sparkle effects only in the intended regions.
- [ ] Activate Hell fire, lava, ember, cinder, ash and heat shimmer effects only in intended regions.
- [ ] Reduce/stop inactive-world emitters.
- [ ] Cull offscreen or non-visible animated/VFX nodes.
- [ ] Keep intense VFX away from the driving lane and vehicle silhouette.
- [ ] Verify no noticeable stutter during VFX/environment changes.

## 6E. Runtime and lifecycle tests

- [ ] Test entering/leaving each biome at exact distance boundaries.
- [ ] Test crossing multiple boundaries in one large simulation step.
- [ ] Test no scene reload and no pause/freeze during the drive.
- [ ] Test audio player count and crossfade behavior.
- [ ] Test VFX activation/deactivation and culling.
- [ ] Test pause/resume at each biome and transition.
- [ ] Test restart from Heaven, Hell and each transition returns to a clean Normal Land start.
- [ ] Test missing cosmetic resource fallback without breaking physics.
- [ ] Confirm HUD, camera, fuel, pickups and results behavior remain intact.
- [ ] Create `docs/PHASE_6_RUNTIME_ENVIRONMENT_INTEGRATION_REPORT.md`.

## Phase 6 exit gate

- [ ] One continuous run crosses all four transitions without a scene reload.
- [ ] Correct biome visuals/parallax are active at correct distances.
- [ ] Audio crossfades smoothly, with no duplicate players.
- [ ] VFX activate only where intended and inactive VFX are culled.
- [ ] Pause/resume/restart are clean in every biome.
- [ ] Missing visual asset fallback keeps the game playable.
- [ ] Existing gameplay regressions pass; report completed; Daniel authorizes Phase 7.

## Agy CLI prompt — Phase 6

```text
AUTHORIZATION: Execute Phase 6 ONLY — live biome/environment switching, parallax, music/ambience and VFX.
Read this TODO Phase 6 and the approved Phase 2–5 reports. Verify Phase 5 PASS and inspect current Game/GameManager/Parallax interfaces plus shared team contracts.

Implement a minimal environment host connecting the Phase 4 progression controller, Phase 5 terrain profiles and Phase 3 Heaven/Hell scenes. Keep one continuous Endless Map run; do not reload the game scene between worlds. Reuse the existing Normal Land parallax system and consistent camera/world coordinates. Blend backgrounds smoothly and avoid duplicate parallax controllers.

Crossfade Music and Ambience independently using Phase 2 buses/assets. Keep SFX/UI stable. Prevent duplicate audio players. Activate Heaven/Hell VFX by biome, cull inactive/offscreen effects and add a safe cosmetic-resource fallback that never removes terrain collision or interrupts driving.

Test exact boundaries, multi-boundary jumps, no reload, no audio duplication, VFX lifecycle, pause/resume, restart from every biome/transition and missing-resource fallback. Run regressions. Modify shared Game files only when essential; document minimal diffs and preserve existing APIs. Do not modify menus, Survival, Garage, Indian Roads or vehicle physics. No push/commit.

Create docs/PHASE_6_RUNTIME_ENVIRONMENT_INTEGRATION_REPORT.md, update this TODO and STOP for Phase 7 approval.
```

---

# PHASE 7 — CHARACTERS, SCENERY, HAZARDS AND COLLECTIBLE PRESENTATION

**Status: NOT STARTED — depends on Phase 6 PASS.**

**Goal:** Add final world dressing and approved character presentation after world switching is stable.

## 7A. Hell characters

- [ ] Add Skeleton Knight with idle/walk loops.
- [ ] Keep attack1/attack2/dead animations available but do not invent combat behavior.
- [ ] Add Ground Demon Goblin with idle/walk loops.
- [ ] Add Horned Fiend only as an optional variant if it improves the scene.
- [ ] Add Flying Hell Dragon as a distant/aerial ambient actor.
- [ ] Use actual world/camera coordinates and scale; do not copy preview mockup Y pixels blindly.
- [ ] Keep actors on safe upper shelves/platforms/background layers outside tire/vehicle corridor.
- [ ] If a walk patrol is used, bound it to a safe platform and prevent it entering the road or falling off a ledge.
- [ ] Default actors to non-colliding scenery unless a gameplay role is explicitly approved.
- [ ] Add `VisibleOnScreenNotifier2D` or an appropriate visibility strategy to pause/cull offscreen animation.
- [ ] Limit simultaneous animated actors to a performance-tested count.

## 7B. Heaven wildlife and scenery

- [ ] Add the dove flight loop using its SpriteFrames resource.
- [ ] Place 8 collected garden flowers with intentional variety/scale.
- [ ] Place angel statue and golden palace architecture with parallax depth.
- [ ] Add cloud banks and restrained golden sparkle/light effects.
- [ ] Keep dove as ambient wildlife, not a physics actor.
- [ ] Cull offscreen dove/particles and avoid excessive light overdraw.

## 7C. Normal Land scenery completion

- [ ] Inspect existing Normal Land forest/parallax silhouettes that were present but not instanced.
- [ ] Add suitable existing trees, bushes, rocks, fences and plants to the correct layers.
- [ ] Preserve the established countryside style.
- [ ] Use deterministic/seeded placement so tests and repeated runs are reproducible.
- [ ] Vary repeated segments without obstructing the road or hiding upcoming terrain contours.
- [ ] Do not collect new Normal Land assets unless a genuine blocker is documented and separately approved.

## 7D. Hell scenery and hazards

- [ ] Add skull piles, dragon skulls, basalt crags/columns, magma vents and fire as scene decorations.
- [ ] Classify every object as decorative, terrain visual or active gameplay hazard before adding collision.
- [ ] Keep broken-platform, obsidian-spike and magma-vent artwork decorative unless hazard behavior is explicitly designed and approved.
- [ ] If a hazard is approved, define collision layer/mask, warning cue, approach visibility, vehicle response, fairness and pickup exclusion.
- [ ] Test each active hazard with all supported vehicles.
- [ ] Do not turn every collected prop into a collider.

## 7E. Themed collectible visuals

- [ ] Reuse existing `Coin.tscn`, `Coin.gd`, `FuelPickup.tscn` and `FuelPickup.gd`.
- [ ] Optionally use a Heaven gold halo/relic skin for the existing coin/reward.
- [ ] Optionally use a Hell fire ruby/ember skin for the existing coin/reward.
- [ ] Keep collision size, pickup clearance, collection signals, save behavior and reward values unchanged unless separately approved.
- [ ] Keep fuel as the existing fuel can/refuel mechanic; do not create themed fuel logic or another currency.
- [ ] Do not add optional skins if they delay or destabilize core biome integration.

## 7F. Tests and report

- [ ] Test character animation names, frame counts and loop playback.
- [ ] Test spawn/placement boundaries and no intrusion into active driving corridor.
- [ ] Test culling and actor-count limits.
- [ ] Test no unintended vehicle collisions from decoration.
- [ ] Test any approved active hazard's warning/collision/fairness behavior.
- [ ] Test coins/fuel stay above ground and use existing collection logic.
- [ ] Test restart and pooled segment reuse do not duplicate actors/props.
- [ ] Capture actual in-engine Heaven/Hell/Normal Land previews.
- [ ] Create `docs/PHASE_7_WORLD_DRESSING_REPORT.md`.

## Phase 7 exit gate

- [ ] Required character animations play correctly.
- [ ] Characters and scenery do not obstruct/stabilize/alter the vehicle.
- [ ] Any active hazards are approved and physics-tested; others remain decorative.
- [ ] Existing pickups and rewards remain unchanged functionally.
- [ ] Deterministic placement and culling work.
- [ ] In-engine previews, tests and report pass; Daniel authorizes Phase 8.

## Agy CLI prompt — Phase 7

```text
AUTHORIZATION: Execute Phase 7 ONLY — world dressing, environmental characters, scenery, approved hazards and optional pickup skins.
Read this TODO Phase 7 and the approved Phase 2–6 reports, character manifests/licences and existing pickup interfaces. Verify Phase 6 PASS.

Integrate Skeleton Knight (idle/walk), Ground Demon Goblin (idle/walk), optional Horned Fiend (walk), Flying Hell Dragon (fly), Heaven dove, flowers/statue/palace and Hell skull/basalt/lava/fire decorations. Use exact SpriteFrames resources. Player driver remains seated in the vehicle and is not part of this work.

Place animated Hell characters on safe shelves/background layers outside the actual driving/tire corridor. Use bounded patrol only where appropriate; default to non-colliding ambient inhabitants. Keep attack/death resources unused unless later combat design is separately approved. Add visibility culling and actor limits. Reuse existing Normal Land scenery/parallax artwork that is already in the project.

Classify spikes/vents/broken platforms as decoration or actual hazard before adding collision. No new hazard mechanics without explicit approval. Reuse existing Coin/FuelPickup scenes and reward logic for any optional theme skins; do not add currencies or alter refuel behavior.

Test animation playback, placement bounds, no lane intrusion, culling, collision isolation, pickup clearance and restart/pool behavior. Capture actual previews. Run regressions. Create docs/PHASE_7_WORLD_DRESSING_REPORT.md. No unrelated UI/team-mode/vehicle-physics changes; no push/commit. Update this TODO and STOP for Phase 8 approval.
```

---

# PHASE 8 — END-TO-END GAMEPLAY, REGRESSION AND PERFORMANCE QA

**Status: NOT STARTED — depends on Phase 7 PASS.**

**Goal:** Prove the completed world cycle works as one fair, stable, readable Endless Map on desktop and target hardware.

## 8A. Functional world-cycle tests

- [ ] Test Normal Land starting region.
- [ ] Test Normal Land → Heaven transition.
- [ ] Test Heaven main region.
- [ ] Test Heaven → Normal Land return.
- [ ] Test Normal Land expert region.
- [ ] Test Normal Land → Hell transition.
- [ ] Test Hell main region.
- [ ] Test Hell → Normal Land return.
- [ ] Test repeated cycle beyond 5,150 m.
- [ ] Test at least through 10,300 m (two cycles) or an equivalent deterministic simulation.
- [ ] Confirm difficulty increments once per cycle according to the verified rule.
- [ ] Confirm no state, signal, audio or VFX duplication at boundaries.

## 8B. Existing gameplay regression

- [ ] Run all `tests/test_*.gd` scripts and record each exit code.
- [ ] Run all new Phase 2–7 tests.
- [ ] Recheck original nine terrain archetypes.
- [ ] Recheck segment seams, pooling and recycling after long-distance runs.
- [ ] Recheck all active vehicles through representative terrain and transition ramps.
- [ ] Recheck coins/fuel collection, clearance and save results.
- [ ] Recheck fuel depletion, crash, pause, resume and restart.
- [ ] Recheck HUD distance/coin/fuel display and camera follow.
- [ ] Recheck main-menu launch/return and teammate modes remain untouched/functioning.

## 8C. Physics, readability and fairness

- [ ] Test low, medium and high approach speeds at every ramp.
- [ ] Test airborne rotation, landing and suspension travel.
- [ ] Confirm no wheel sinking, unexpected collision gaps or severe bounce.
- [ ] Confirm upcoming road contours remain visible against each biome background.
- [ ] Confirm no scenery/character/VFX blocks the player's view of the driving surface.
- [ ] Confirm any active hazards have visible warning and fair reaction time.
- [ ] Confirm coins/fuel are collectible and not placed inside hazards or behind inaccessible geometry.

## 8D. Visual/audio QA

- [ ] Inspect all three biomes at actual gameplay scale.
- [ ] Inspect all four transition visuals in motion.
- [ ] Check parallax seams, repeated pattern visibility and camera alignment.
- [ ] Check music/ambience fades, volume balance, loop seams and no duplicate tracks.
- [ ] Check particle/shader overdraw and visual clarity.
- [ ] Check animation frame timing, loop continuity and actor culling.

## 8E. Performance QA — Radeon 610M

- [ ] Measure frame time in Normal Land, Heaven, Hell and peak transition overlap.
- [ ] Measure average and worst/95th percentile frame times where tooling allows.
- [ ] Record rendering resolution, renderer, driver, test scene and run duration.
- [ ] Measure memory/texture use with actual imported and active assets; do not quote theoretical estimates as measured values.
- [ ] Profile peak crossfade where two environments overlap.
- [ ] Check particles, transparent overdraw, PointLight2D and shader sampling.
- [ ] Check texture duplication and unnecessary 3200 atlas loading; keep high-resolution atlas out of active runtime unless needed.
- [ ] Reduce effect density/texture size only with visual comparison and documented changes.
- [ ] Do not claim locked 60 FPS unless repeated measurements prove it.

## 8F. Investigate test cleanup warnings

- [ ] Re-run tests that emitted `ObjectDB instances were leaked` and `resources still in use at exit` with verbose diagnostics.
- [ ] Identify exact objects/resources and which owning test/subsystem retains them.
- [ ] Classify as test teardown, intentionally retained resource, singleton lifecycle or true leak.
- [ ] Fix confirmed Daniel-scope teardown defects with focused changes and regression coverage.
- [ ] Coordinate fixes in another teammate's subsystem with its owner.
- [ ] Do not suppress logs, call `queue_free()` blindly or alter runtime gameplay just to silence test cleanup.
- [ ] If a warning is accepted as non-blocking, document why with evidence and owner.

## 8G. Report and exit gate

- [ ] Create `docs/PHASE_8_END_TO_END_QA_REPORT.md`.
- [ ] Include exact commands, exit codes, counts, warnings, errors and test evidence.
- [ ] Include actual gameplay screenshots/recordings of the full cycle.
- [ ] Include hardware/performance measurements and test conditions.
- [ ] List all unresolved bugs by severity and owner.
- [ ] Mark READY or BLOCKED for Android validation.

## Phase 8 exit gate

- [ ] All existing and new tests pass or have a reviewed exception.
- [ ] All four transitions are physically safe and visually continuous.
- [ ] Long-distance/repeat-cycle behavior is stable.
- [ ] Fuel, coins, save, pause, crash, restart and HUD remain correct.
- [ ] Performance is measured and acceptable or has a team-approved optimization plan.
- [ ] Cleanup warnings are explained/resolved or explicitly accepted with evidence.
- [ ] Daniel approves Phase 9.

## Agy CLI prompt — Phase 8

```text
AUTHORIZATION: Execute Phase 8 ONLY — end-to-end gameplay, regression and performance QA.
Read this TODO Phase 8 and all approved Phase 2–7 reports. Verify Phase 7 PASS and inspect Git status before changing anything.

First run tests without modifying code. Run every tests/test_*.gd plus all new environment tests and capture per-test exit codes. Simulate a continuous drive through at least one full 5,150 m cycle plus repeat (target >=10,300 m) and exercise all four transitions. Test all active vehicles on ramps; pause/resume/restart/crash/out-of-fuel, coins, fuel, save/results, HUD and camera. Verify state/audio/VFX are not duplicated and long-distance pooling remains bounded.

Perform actual visual/audio review and profile on AMD Radeon 610M where available. Record renderer, resolution, driver, scene, duration, frame-time distribution and memory methodology. Do not claim unmeasured 60 FPS or VRAM figures. Investigate ObjectDB/resource cleanup warnings with verbose evidence; do not suppress logs or weaken tests.

Fix only confirmed Daniel-scope blockers with focused regression coverage. Coordinate shared/team-owned fixes. Create docs/PHASE_8_END_TO_END_QA_REPORT.md with exact commands, exit codes, measurements, evidence, warnings and READY/BLOCKED decision. No unrelated refactors, no push/commit. Update this TODO and STOP for Phase 9 approval.
```

---

# PHASE 9 — ANDROID BUILD VALIDATION AND TEAM HANDOFF

**Status: NOT STARTED — depends on Phase 8 READY.**

**Goal:** Validate the Daniel-owned Endless Map renovation in an Android build and prepare a reviewable team handoff.

## 9A. Android export preflight

- [ ] Confirm Godot 4.7.2 export templates are installed.
- [ ] Inspect Android SDK/JDK/export tooling versions required by the current project.
- [ ] Inspect existing export presets; preserve team-owned settings.
- [ ] Confirm package/application ID with the team.
- [ ] Confirm portrait/landscape orientation and stretch/safe-area behavior based on the existing game design.
- [ ] Confirm Android texture compression/import settings are supported by target devices.
- [ ] Verify audio buses, looping tracks, SpriteFrames, shaders and particles in an exported build.
- [ ] Keep keystore files/passwords/signing secrets outside Git and Markdown.

## 9B. Build and device testing

- [ ] Produce a local debug/test APK or build using the project's approved export profile.
- [ ] Confirm app installs and launches.
- [ ] Test the Endless Map start flow.
- [ ] Test touch accelerator/brake controls.
- [ ] Test each biome and all four transitions.
- [ ] Test audio, pause/resume and app background/foreground.
- [ ] Check HUD, text and safe areas on the device screen.
- [ ] Run a long enough session to check heating, stutter and memory growth.
- [ ] Check restart after crash/out-of-fuel and after returning from app background.
- [ ] Record device model, Android version, resolution and test build hash.
- [ ] If no physical Android device is available, mark device validation `NOT TESTED`; do not call desktop export validation a device PASS.

## 9C. Documentation and PR handoff

- [ ] Update `docs/DEVELOPMENT_PROGRESS.md`.
- [ ] Update Daniel's master checklist with verified completion states.
- [ ] Create `docs/PHASE_9_ANDROID_HANDOFF_REPORT.md`.
- [ ] Ensure all asset source/licence/attribution files are present.
- [ ] Summarize environment scenes, biome schedule, four ramps, audio/VFX and performance.
- [ ] List files changed and tests run.
- [ ] List known limitations and untested Android behaviors.
- [ ] Prepare a PR description for Bharath/team review.
- [ ] Confirm with Bharath the exact destination remote/branch and PR workflow.
- [ ] Wait for Daniel's explicit authorization before pushing or opening a PR.

## Phase 9 exit gate

- [ ] Export succeeds using approved Godot/Android toolchain.
- [ ] Android device tests pass, or unavailable tests are clearly identified.
- [ ] No signing secrets or temporary build artifacts are committed.
- [ ] Documentation and licence attribution are complete.
- [ ] Regression/performance evidence is attached.
- [ ] PR/handoff is prepared and team publishing target is confirmed.
- [ ] Daniel approves any final push/PR separately.

## Agy CLI prompt — Phase 9

```text
AUTHORIZATION: Execute Phase 9 ONLY — Android build validation and Daniel's Endless Map handoff.
Read this TODO Phase 9, Phase 8 QA report, all previous phase reports and current team export/publishing instructions. Verify Phase 8 READY.

Inspect Godot 4.7.2 export templates, Android toolchain, project export presets and package settings. Preserve shared/team-owned configuration. Build a local test package only with the approved preset. Verify app installation/start, touch controls, all three biomes/four transitions, audio, pause/resume, background/foreground, HUD safe areas, restart and long-run stability on a physical device if available.

Record device/build/environment details. If no device is available, mark device QA NOT TESTED, not PASS. Never expose or commit keystore/password/signing secrets.

Update docs/DEVELOPMENT_PROGRESS.md and Daniel's checklist; create docs/PHASE_9_ANDROID_HANDOFF_REPORT.md; prepare a PR summary including changed files, tests, performance, licences and limitations. Confirm the intended publishing remote/branch with Daniel/Bharath. Do not push, commit or open a PR without Daniel's explicit authorization.

Update this TODO and STOP with the handoff report.
```

---

# D. GLOBAL DEFINITION OF DONE

## Gameplay and world flow

- [ ] The original Normal Land Endless Map remains playable.
- [ ] The player stays seated in the selected vehicle; no separate walking player controller was introduced.
- [ ] One continuous run drives through Normal Land → Heaven → Normal Land → Hell → Normal Land.
- [ ] All four ramps are smooth visually and physically.
- [ ] The cycle repeats past 5,150 m with validated difficulty behavior.
- [ ] Restart resets world state, cycle state, audio and effects correctly.
- [ ] Existing fuel, coins, pickups, HUD, save/results, crash and pause behavior remain correct.

## Environment and presentation

- [ ] Normal Land uses existing assets and remains stylistically consistent.
- [ ] Heaven is visually distinct, readable and complete.
- [ ] Hell is visually distinct, readable and complete.
- [ ] Parallax and backgrounds transition without gaps or pops.
- [ ] Music/ambience crossfade without duplicate playback.
- [ ] Characters, wildlife and VFX animate/cull correctly.
- [ ] Hell characters and hazards do not unfairly obstruct the active driving corridor.
- [ ] All active hazard behaviors are intentional, warned and tested.

## Engineering and release

- [ ] Existing nine terrain archetypes and pooling/recycling are preserved.
- [ ] Collision geometry matches visible terrain.
- [ ] Godot 4.7.2 imports all project resources without missing dependencies.
- [ ] New and existing tests pass or approved exceptions are documented.
- [ ] ObjectDB/resource cleanup warnings are explained/resolved or accepted with evidence.
- [ ] Radeon 610M performance is measured under defined conditions.
- [ ] Android export/device status is accurately reported.
- [ ] All asset licences, sources and attributions are retained.
- [ ] Team boundaries are respected and publishing is separately authorized.

---

# E. MASTER PROGRESS TRACKER

Update only after the phase report exists and the exit gate has been reviewed.

| Phase | Work | Current status | Report / evidence | Daniel approval |
|---:|---|---|---|---|
| 0 | Baseline/Git/team preflight | Previously verified; recheck before Phase 2 | `docs/PHASE_0_BASELINE_REPORT.md` if created | Recheck |
| 1 | Asset ingestion and dove atlas | **COMPLETE** | `docs/PHASE_1_ENVIRONMENT_ASSET_INTEGRATION_REPORT.md` | Complete |
| Sync | Bharath foundation merge + regression baseline | **COMPLETE LOCALLY** | Git history + 13 test-script output | Complete locally; no push |
| 2 | Shaders, audio buses, SpriteFrames | **COMPLETE** | `docs/PHASE_2_RESOURCE_CONSTRUCTION_REPORT.md` | Complete |
| 3 | Heaven/Hell environment scenes | **COMPLETE** | `docs/PHASE_3_ENVIRONMENT_SCENES_REPORT.md` | Complete; pending Phase 4 auth |
| 4 | World cycle and biome progression | **NEXT — NOT STARTED** | `docs/PHASE_4_BIOME_PROGRESSION_REPORT.md` | Pending Phase 3 review |
| 5 | Terrain profiles and four ramps | Not started | `docs/PHASE_5_TERRAIN_AND_TRANSITIONS_REPORT.md` | Pending Phase 4 |
| 6 | Live environment switching/audio/VFX | Not started | `docs/PHASE_6_RUNTIME_ENVIRONMENT_INTEGRATION_REPORT.md` | Pending Phase 5 |
| 7 | Characters, scenery, hazards, pickup visuals | Not started | `docs/PHASE_7_WORLD_DRESSING_REPORT.md` | Pending Phase 6 |
| 8 | End-to-end regression and performance QA | Not started | `docs/PHASE_8_END_TO_END_QA_REPORT.md` | Pending Phase 7 |
| 9 | Android build and team handoff | Not started | `docs/PHASE_9_ANDROID_HANDOFF_REPORT.md` | Pending Phase 8 |

---

# F. DANIEL'S NEXT ACTION

1. [ ] Save this file in the parent planning folder or project `docs/` as the active master checklist. Recommended project copy: `docs/DANIEL_ENDLESS_MAP_HEAVEN_HELL_TODO.md`.
2. [ ] Run the Phase 0 preflight commands from Section A4.
3. [ ] Confirm the working tree is clean and branch is correct.
4. [ ] Give Agy only the **Phase 2 prompt** from this document.
5. [ ] Review `docs/PHASE_2_RESOURCE_CONSTRUCTION_REPORT.md` and the actual test evidence.
6. [ ] Tick Phase 2 tasks only after verification.
7. [ ] Authorize Phase 3 separately. Repeat this approval cycle through Phase 9.

**Important:** Asset research and Phase 1 ingestion are finished. Do not start another general asset search. The remaining work is implementation, integration, testing and release validation.

---

# CHANGE LOG

| Date | Update |
|---|---|
| 2026-11-13 | Converted Daniel's narrative master roadmap into a phase-by-phase actionable TODO, retaining the reported project baseline, world schedule, phase dependencies, Agy prompts, test gates and Git/team safety rules. |
