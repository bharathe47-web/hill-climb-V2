# INDIAN MFD FILE — Master Concept, Map Control & Technical Architecture

> **Purpose:** Complete project concept, Indian Roads map control flow, physics/terrain architecture, route & landmark specifications, asset conventions, and guardrails for AI assistants (ChatGPT / coding agents) and developers working on this repository.

---

## 1. Project Identity & Runtime Configuration

- **Project Name:** Hill Climb (`Indian Roads` flagship mode + Endless Hill Climb + Survival mode)
- **Engine:** Godot `4.7.2.stable` (`config/features = ["4.7", "Mobile"]`, `renderer/rendering_method = "mobile"`, `textures/vram_compression/import_etc2_astc = true`)
- **Main Scene:** `res://scenes/main/Main.tscn` (`scripts/core/Main.gd`)
- **Viewport & Scaling:** `1280 × 720`, `stretch/mode = "canvas_items"`, `stretch/aspect = "expand"`, `sensor_landscape`, `pointing/emulate_touch_from_mouse = true`
- **World Scale Convention:**
  - **`1 meter = 100 pixels`** (`session_distance_m = (vehicle.global_position.x - start_x) * 0.01`).
  - Standard baseline road surface Y: `base_y = 382.0` (`Road` CollisionLayer = `1`, `Vehicle` = layer `2`, Pickups = layer `4`).
  - Gameplay Camera (`FollowCamera`): `zoom = Vector2(0.9, 0.9)`, giving an effective visible world window of **`~1,422 × 800 px`** (`~14.2 m` wide horizontally).

---

## 2. Top-Level Game Flow & Scene Control

```text
Main.tscn (MainController)
 ├── MainMenu.tscn ──► start_game_requested       ──► Game.tscn (Endless procedural terrain)
 │                 ├──► start_survival_requested   ──► Survival.tscn
 │                 ├──► open_garage_requested      ──► GarageMenu.tscn (Vehicle upgrades / selection)
 │                 └──► start_indian_roads_requested ──► IndianRoadsModeV2.tscn (IndianRoadsControllerV2)
 │                                                        │
 │                                                        ▼
 │                                             StateSelection.tscn (ModeState.SELECTION)
 │                                              ├─ India Map Pins (RJ, GJ, TG, GA, KL, TN)
 │                                              ├─ State Route Cards & Landmark Preview
 │                                              └─ DRIVE ROUTE ──► start_route(RouteData)
 │                                                                       │
 │                                                                       ▼
 │                                                            ModeState.PLAYING
 │                                                             ├─ ParallaxBackground (4 Layers)
 │                                                             ├─ IndianRoadTerrainV2 (+ Bridges/Chunks)
 │                                                             ├─ VehicleController (RigidBody2D)
 │                                                             ├─ FollowCamera (lookahead + damping)
 │                                                             └─ IndianRoadsHUD (TopBar + Touch + Popups)
 │                                                                 ├─ MapButton   ──► RouteMapOverlay.tscn
 │                                                                 ├─ PauseButton ──► PauseMenu.tscn
 │                                                                 └─ Destination ──► RouteCompleteScreen.tscn
```

### Mode State Machine (`IndianRoadsController.ModeState`)
| State | Meaning | Tree Pause | HUD Visible |
|---|---|---|---|
| `SELECTION` (`0`) | Displays `StateSelection.tscn` India Map & state cards; clears driving world | No | No |
| `PLAYING` (`1`) | Active driving simulation, telemetry tracking, zone/parallax switching | No | Yes |
| `PAUSED` (`2`) | Triggered by Pause button/key or Map button; disables active nitro | `get_tree().paused = true` | Yes |
| `COMPLETED` (`3`) | Destination reached; saves coins/progress, disables vehicle, shows `RouteCompleteScreen` after `1.2s` | No | Yes |

---

## 3. Player Input, Vehicle Physics & HUD Controls

### InputMap (`project.godot`)
| Action Name | Keyboard Bindings | Mobile Touch Control (`IndianRoadsHUD`) | Gameplay Effect |
|---|---|---|---|
| `accelerate` | `Right Arrow`, `D` | `%GasButton` (`TouchScreenButton`) | Applies forward wheel torque & consumes fuel |
| `brake_reverse` | `Left Arrow`, `A` | `%BrakeButton` (`TouchScreenButton`) | Applies reverse/brake torque |
| `tilt_left` | `Left Arrow`, `A` | `%BrakeButton` | Counter-clockwise rotational torque (`air_tilt_torque`) while airborne |
| `tilt_right` | `Right Arrow`, `D` | `%GasButton` | Clockwise rotational torque (`air_tilt_torque`) while airborne |
| `nitro` | `Space`, `Shift` | `%NitroButton` (`TouchScreenButton`) | Boosts thrust (`nitro_boost_force`), torque (`×1.6`), speed (`×1.35`), and traction (`+0.5`) |
| `pause` | `Esc`, `P` | `%PauseButton` | Opens/closes `PauseMenu` (also `M` / cancel closes `RouteMapOverlay`) |
| `restart` | `R` | Pause/Victory Replay button | Restarts current route |

### Vehicle Architecture (`VehicleController.gd` + `VehicleRegistry.gd`)
Available selectable/upgradable vehicles in `VehicleRegistry.ORDERED_IDS`:
1. `blue_flame_truck` (`BlueFlameTruck.tscn`, default unlocked, mass `10.0`)
2. `orc_racer` (`OrcRacer.tscn`, cost `350`, mass `7.5`)
3. `trophy_truck` (`TrophyTruck.tscn`, cost `500`, mass `9.0`)
4. `dune_buggy` (`DuneBuggy.tscn`, cost `450`, mass `6.0`)

Key mechanics in `VehicleController.gd`:
- Chassis (`RigidBody2D`) coupled cleanly to `RearWheel` & `FrontWheel` (`RigidBody2D`) via `RearJoint` & `FrontJoint` (`PinJoint2D`), visually rendered with struts (`RearStrutVisual` / `FrontStrutVisual`).
- `_enforce_wheel_attachment_safety()` keeps wheel joint separation tightly bounded (verified `< 3 px` across bridges & bumps).
- **Upside-Down / Crash Recovery:** `CrashDetector` (`Area2D`) emits `crashed`; `IndianRoadsController._on_vehicle_crashed()` calls `recover_vehicle(Vector2(x, terrain.get_height_at(x) - 45.0))`, uprighting the vehicle and continuing gameplay seamlessly.
- **Discovery Zone Nitro Safety:** When within `±450 px` of a checkpoint or destination waypoint (`IndianRoadsController._process`), active nitro is automatically disabled and `%NitroButton` dims (`alpha = 0.4`) so players cleanly experience major monuments without overshooting.

### HUD Layout (`scenes/modes/indian_roads/IndianRoadsHUD.tscn`)
- **Top Bar (`85 px` tall):**
  - `%RouteTitleLabel` (`STATE: START → DEST`), `%RouteProgressBar`, `%DistanceLabel` (`DIST: Xm / TOTALm`), `%NextWaypointLabel`, and `%SectionBadgeLabel` (used dynamically on **Goa** & **Kerala** to display the active region/landmark zone).
  - `%CoinsLabel`, `%FuelBar`/`%FuelLabel`, `%NitroBar`/`%NitroLabel`, `%MapButton`, `%PauseButton`.
- **Popups (Non-blocking):**
  - `%ToastPanel`: Auto-dismissing zone/checkpoint/petrol announcement toast centered below the TopBar (`y ~ 90+ px`).
  - `%LandmarkInfoPanel`: Bottom informational card (`title`, `location`, `description`, `why_famous`) showing heritage facts when discovering a roadside landmark.

---

## 4. Indian Roads Map Control System (How Maps, Pins, Zones & Overlays Work)

The "Indian Roads map control" spans four synchronized layers:

### 4.1 National India Map Hub (`StateSelectionController.gd` & `RouteRegistry.gd`)
- `RouteRegistry.STATE_ORDER` defines all 6 canonical routes (all unlocked in Version 1.0 by `is_state_unlocked`):
  1. `tamil_nadu` (`1,200 m`): Kanyakumari → Chennai
  2. `goa` (`1,200 m`): North Goa → South Goa
  3. `kerala` (`1,800 m`): Kochi → Munnar
  4. `rajasthan` (`1,200 m`): Jaipur → Jaisalmer
  5. `gujarat` (`1,150 m`): Ahmedabad → Rann of Kutch
  6. `telangana` (`1,000 m`): Hyderabad → Warangal
- `StateSelectionController` renders clickable pin buttons (`STATE_PIN_CONFIGS`) over `%MapTextureRect` (`RJ`, `GJ`, `TG`, `GA`, `KL`, `TN`) synced 1:1 with scrollable `%RouteCardsContainer` cards.
- Selecting a pin/card updates `%StateTitleLabel`, `%RouteDescLabel`, `%LandmarkPreviewRect`, and highlights the active pin in gold (`★ KL`). Clicking `DRIVE ROUTE` emits `route_selected(RouteData)`.

### 4.2 In-Game Live Route Map Modal (`RouteMapOverlay.gd`)
- Opened via `%MapButton`, pauses the game (`PROCESS_MODE_ALWAYS`), displays the state's SVG route map (`route.state_map_path`), and draws:
  - Normalized polyline route coordinates from `STATE_ROUTE_GEOMETRY[state_id]` (array of `{"pos": Vector2(0..1, 0..1), "dist_m": float, "label": String}`).
  - Completed green route segment vs. remaining dashed segment.
  - Real-time interpolated vehicle GPS marker at `current_dist_m`.
  - Scrollable milestone status cards (Cleared / Upcoming).

### 4.3 Route Progression Controller (`IndianRoadsController.gd` & `IndianRoadsControllerV2.gd`)
`IndianRoadsControllerV2` extends `IndianRoadsController` and coordinates map runtime behavior:
1. **Route Spawn (`start_route`):**
   - Instantiates `IndianRoadTerrainV2` inside `$WorldContainer/TerrainSlot` and runs `generate_route(active_route)`.
   - Spawns selected vehicle at `(0.0, 335.0)` inside `$WorldContainer/VehicleSlot`.
   - Configures 4-layer `ParallaxBackground`: `SkyLayer`, `CloudsLayer`, `PlainsLayer` (distant hills/coast), `MidgroundLayer` (trees/estates/skyline).
2. **Real-Time Map Distance & Environment Zone Switching (`_process`):**
   - Computes `session_distance_m = clampf((vehicle.global_position.x - start_x) * 0.01, 0.0, total_distance_m)`.
   - State-specific dynamic environment managers update Parallax Sky, Distant Hills, Midground, Soil/Topsoil colors, HUD `%SectionBadgeLabel`, and entry announcements without reloading the scene:
     - **Tamil Nadu:** `_update_tamil_nadu_environment_zones()` transitions across 13 cities (`kanyakumari` → `chennai`).
     - **Goa:** `_update_goa_environment_zones()` transitions across 4 distinct regions (`north_goa`, `central_goa`, `east_goa`, `south_goa`).
     - **Kerala:** `_update_kerala_environment_zones()` paired with `KeralaLocationManager` transitions across 9 exact locations (`kochi` → `muvattupuzha` → `kothamangalam` → `neriamangalam` → `valara` → `cheeyappara` → `adimali` → `pallivasal` → `munnar`).

### 4.4 Roadside Landmarks & Waypoints (`RoadsideLandmarkRegistry.gd`, `LandmarkCatalogueData.gd`, `RoadsideLandmark.gd`)
- Two complementary object types populate every route:
  - **Waypoints (`WaypointData` in `RouteRegistry.gd`):** `START`, `CHECKPOINT` (`CheckpointV2.tscn`), and `DESTINATION` (`FinishArchV2.tscn`). Clear events award bonus coins and unlock sequential progression markers.
  - **Cultural/Natural Landmarks (`RoadsideLandmarkRegistry.get_landmarks_for_state(state_id)`):** Spawned as `RoadsideLandmark.tscn` (`Area2D` + `MonumentSprite` + highway `Signboard`). Triggering `landmark_discovered` awards coins, shows a toast banner, and populates `LandmarkInfoPanel` using historical copy from `LandmarkCatalogueData.gd`.

---

## 5. Terrain, Parallax Positioning & Physics Architecture

### 5.1 Parallax Layer Coordinate Standard (`FollowCamera.zoom = 0.9`)
For overhauled **Goa** and **Kerala** `v3` parallax art (`1920×720` skies, `1920×230` clouds, `1920×440` distant horizon, `1920×420` midground), `IndianRoadsControllerV2` keeps `scale = Vector2.ONE` and aligns vertical origins carefully so zero sky gaps ever appear below hills or above road valleys:
- **`SkyLayer` (`motion_scale = (0.01, 0)`):** centered at `(w * 0.5, h * 0.5)`.
- **`CloudsLayer` (`motion_scale = (0.05, 0)`):** positioned at `(w * 0.5, 88.0 + h * 0.5)` so clouds sit cleanly beneath the `85 px` HUD TopBar.
- **`PlainsLayer` (`motion_scale = (0.11, 0)`):** positioned at `(w * 0.5, 595.0 - h * 0.5)` so solid landmass extends well past terrain dips.
- **`MidgroundLayer` (`motion_scale = (0.24, 0)`):** positioned at `(w * 0.5, 610.0 - h * 0.5)` via `_apply_goa_midground_layout()`.

### 5.2 Terrain Generation & Drivable Structures (`IndianRoadTerrain` -> `IndianRoadTerrainV2`)
`generate_route(route)` executes deterministically:
1. `_apply_state_theme(state_id)` — Road surface, topsoil, gravel, stripe colors, and wave multipliers.
2. `_plan_road_features()` — Places speed breakers, curve/hazard zones, and potholes while avoiding landmarks, waypoints, and bridges.
3. `_generate_highway_profile()` — Evaluates `_calculate_road_height(x)` (`40 px` step on Goa & Kerala for ultra-smooth bridge/hill suspension). Section wave amplitudes blend via `smoothstep()` + `lerpf()` to guarantee **`max_slope < 0.25`** everywhere (no sudden vertical jumps).
4. `_build_collision()` — Populates `$StaticBody2D/CollisionPolygon2D` directly from `road_points` top vertices down to `base_y + bottom_depth + 500`.
5. `_spawn_waypoints()` — Places Start, Checkpoints, and custom state Finish Arches (e.g., Goa arch, Munnar Kerala arch).
6. `_spawn_roadside_props()` — Spawns all `RoadsideLandmark` items, custom state bridges, zone vegetation/houses/foreground verge props, and `_populate_pickups_and_coins()`.

#### Playable Bridges Integrated Directly into Highway Collision
| State | Landmark Bridge | X Span (px / m) | Architecture & Special Notes |
|---|---|---|---|
| **Tamil Nadu** | Kanyakumari Glass Bridge | `2,500–8,500 px` (`25m–85m`) | `KanyakumariGlassBridge.tscn` + `KanyakumariGlassBridge.gd` interactive transparent ocean span |
| **Goa** | East Goa Mollem Forest Bridge | `74,800–78,200 px` (`748m–782m`) | `GoaTerrainHelper.gd` split laterite embankment revealing mountain stream beneath piers |
| **Kerala** | Neriamangalam Periyar Arch Bridge | `66,500–74,500 px` (`665m–745m`) | `KeralaTerrainHelper.gd` (`KeralaBridgeCanvas`) 10 stone-concrete arches, cutwaters & parapets over Periyar River |

---

## 6. Deep Dive: State Implementations (Including Recent Overhauls)

### 6.1 Kerala — Complete Kochi to Munnar Overhaul (`1,800 m`, State of the Art Reference)
Kerala serves as the project's most advanced showcase for dynamic 9-location streaming and spatial rendering optimization:

#### 9 Sequential Geography Zones (`KeralaLocationManager.ZONES`)
1. **Kochi (`0–200 m`)**: Coastal harbour sky (`sky_kerala_coastal.png`), Arabian Sea ships & palms (`dist_01_kochi`, `mid_01_kochi`), Chinese Fishing Nets (`38 m`), Mattancherry Dutch Palace (`82 m`), Paradesi Synagogue (`122 m`), St. Francis CSI Church (`160 m`), Santa Cruz Basilica (`190 m`).
2. **Muvattupuzha (`200–400 m`)**: Checkpost (`210 m`), rubber plantations, banana groves, Tharavadu houses, Hill Palace Museum (`255 m`), Sree Poornathrayeesa Temple (`308 m`), Chottanikkara Bhagavathy Temple (`362 m`).
3. **Kothamangalam (`400–600 m`)**: Bamboo clusters & foothill forests, Temple Padippura Gateway (`424 m`), Aluva Mahadeva River Temple (`476 m`), Mar Thoma Syrian Church (`528 m`), St. George Forane Church (`576 m`).
4. **Neriamangalam (`600–800 m`)**: Transitions sky to `sky_kerala_highlands.png`, Forest Checkpost (`615 m`), Periyar River rainforest gorge + **Playable Neriamangalam 10-Arch Bridge** (`665–745 m`).
5. **Valara Waterfalls (`800–1,000 m`)**: Forested Western Ghats cliffs (`dist_05_valara`, `mid_05_valara`), Valara Waterfalls showcase (`895 m`) + soft radial `CPUParticles2D` water spray mist.
6. **Cheeyappara Waterfalls (`1,000–1,200 m`)**: 7-tiered stepped rocky waterfall (`1,095 m`) + plunge spray mist particles.
7. **Adimali (`1,200–1,400 m`)**: High-Range Gate (`1,215 m`), Cardamom & Spice Gardens (`1,315 m`), spice cottages & stalls.
8. **Pallivasal (`1,400–1,600 m`)**: Rolling curved tea terraces, continuous sculpted roadside tea hedges (`bush_kerala_tea_row.png`), eucalyptus trees, valley mist wisps.
9. **Munnar (`1,600–1,800 m`)**: Munnar Colonial Tea Factory (`1,675 m`), drifting misty peaks (`dist_09_munnar`, `mid_09_munnar`), and the Munnar Finish Arch (`WELCOME TO MUNNAR` / `KOCHI → MUNNAR` at `1,800 m`).

#### Kerala Performance Architecture
- **Spatial Chunk Culling (`KeralaTerrainHelper.gd`):** Splits road vertices, earth strata, batched `draw_polyline`/`draw_multiline` markings, roadside props, tea hedges, foreground ferns/rocks, particle emitters, and reparented `Coin`/`FuelPickup` items into **`4,000 px` chunks** (`CHUNK_WIDTH = 4000.0`). Only the **`3` active chunks** around the vehicle (`center_chunk ± 1`) stay `visible = true` and `PROCESS_MODE_INHERIT`; off-screen chunks disable visibility and processing cleanly in O(1) time.
- **Asynchronous Background Preloading (`KeralaLocationManager.gd`):** Triggers `ResourceLoader.load_threaded_request()` `95 m` ahead of each upcoming zone boundary, keeps `[active_index ± 1]` zones cached in VRAM, and safely evicts older zones `≥ 2` behind.
- **Verified Measured Performance Impact (`1280×720` `opengl3` benchmark across all 9 zones):**
  - Avg Frame Time: **`33.97 ms` → `16.42 ms`** (60 FPS vsync-locked)
  - Max Zone Transition Spike: **`460.54 ms` → `23.24 ms`** (`-95.0%`)
  - Avg Draw Calls / Frame: **`2,648.4` → `144.6`** (`-94.5%`)
  - Avg Primitives / Frame: **`371,139.4` → `9,223.0`** (`-97.5%`)
  - Route Load Time: **`1,506.54 ms` → `967.38 ms`**

### 6.2 Goa (`1,200 m`)
- Dedicated helper [GoaTerrainHelper.gd](file:///home/joel/Documents/game/old%20indian/hill-climb-V2/scripts/modes/indian_roads/GoaTerrainHelper.gd) + `assets/indian_locations/goa/v3/` across 4 zones (`North Goa`, `Central Goa`, `East Goa`, `South Goa`), 13 landmarks (`GOA-01..GOA-13`), playable Mollem Forest bridge (`748–782 m`), and coastal-to-laterite topsoil transitions. *(Do not alter when editing Kerala or other states.)*

### 6.3 Other 4 State Routes
- **Tamil Nadu (`1,200 m`, 13 zone transitions / 20 landmarks `LOC-TN-01..20`):** Kanyakumari Glass Bridge → Nagercoil → Madurai → Trichy → Chennai Marina Beach.
- **Rajasthan (`1,200 m`, `LOC-RJ-*`):** Jaipur Hawa Mahal → Amber Fort → Thar Expressway → Jodhpur Mehrangarh → Jaisalmer.
- **Gujarat (`1,150 m`, `LOC-GJ-*`):** Ahmedabad → Saurashtra → Kutch Border → Flamingo Pass → White Desert Rann of Kutch.
- **Telangana (`1,000 m`, `LOC-TL-*`):** Hyderabad Charminar → Golconda Fort → ORR Toll → Kakatiya Torana → Warangal.

---

## 7. Key Repository File Map

| Layer / Role | File Path |
|---|---|
| App entry & scene switching | `scripts/core/Main.gd`, `scripts/core/SaveManager.gd`, `scripts/core/FollowCamera.gd` |
| Vehicle physics & catalog | `scripts/vehicle/VehicleController.gd`, `scripts/vehicle/VehicleRegistry.gd` |
| India Map & Route Hub | `scripts/modes/indian_roads/StateSelectionController.gd`, `scripts/modes/indian_roads/RouteRegistry.gd` |
| Route Map Modal (GPS) | `scripts/modes/indian_roads/RouteMapOverlay.gd`, `scenes/modes/indian_roads/RouteMapOverlay.tscn` |
| Mode Controllers | `scripts/modes/indian_roads/IndianRoadsController.gd`, `scripts/modes/indian_roads/IndianRoadsControllerV2.gd` |
| HUD & Info Popups | `scripts/modes/indian_roads/IndianRoadsHUD.gd`, `scenes/modes/indian_roads/IndianRoadsHUD.tscn` |
| Terrain & Waypoints | `scripts/modes/indian_roads/IndianRoadTerrain.gd`, `IndianRoadTerrainV2.gd`, `RoadsideLandmark.gd` |
| State-Specific Terrain Helpers | `scripts/modes/indian_roads/GoaTerrainHelper.gd`, `KeralaTerrainHelper.gd`, `KeralaLocationManager.gd`, `KanyakumariGlassBridge.gd` |
| Landmark Metadata | `scripts/modes/indian_roads/RoadsideLandmarkRegistry.gd`, `scripts/modes/indian_roads/LandmarkCatalogueData.gd` |
| Asset Pipelines | `scripts/generation/generate_goa_overhaul_assets.py`, `generate_kerala_overhaul_assets.py`, `optimize_kerala_attached_assets.py` |
| Pickups | `scripts/pickups/Coin.gd`, `scripts/pickups/FuelPickup.gd` |

---

## 8. Crucial Engineering Guardrails & Test Commands

When modifying or extending any Indian Roads map, **always preserve these invariants**:
1. **State Isolation:** Changes to Kerala or another state's terrain/parallax/routes must remain strictly scoped (`state_id == "..."`) so existing maps (`tamil_nadu`, `goa`, `kerala`, `rajasthan`, `gujarat`, `telangana`) never regress.
2. **Smooth Slope Continuity:** Never use unblended `if/elif` wave amplitude jumps inside `_calculate_road_height(x)`. Always interpolate with `smoothstep(...)` and keep `max_slope < 0.25`.
3. **Ground-Flush Transparent PNGs:** `RoadsideLandmark.gd` anchors sprites at `ground_offset_y - effective_height * 0.5`. Crop excess transparent bottom margin down to `~4 px` before importing so landmarks do not float above the highway.
4. **Never Re-Tessellate Giant Terrain Meshes During Driving:** Use spatial chunks (`KeralaRoadChunk` pattern) + async lookahead `ResourceLoader.load_threaded_request()` rather than calling synchronous `load()` or full-route `queue_redraw()` on zone transitions.
5. **Re-import Before Running Headless:** Whenever adding or updating PNGs via Python scripts, run `godot --headless --path . --import --quit` before executing tests.

### Automated Verification Suite
```bash
godot --headless --path . -s tests/test_all_landmarks_instantiation.gd
godot --headless --path . -s tests/test_all_six_routes_gameplay.gd
godot --headless --path . -s tests/test_six_state_selection_and_unlock.gd
godot --headless --path . -s tests/test_game_loop.gd
```
