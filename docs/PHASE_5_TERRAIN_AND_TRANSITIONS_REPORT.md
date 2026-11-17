# PHASE 5 REPORT: BIOME TERRAIN PROFILES & FOUR CONTINUOUS TRANSITION RAMPS

**Project:** Hill Climb 2 (`Endless-Hillclimb`)  
**Engine & Version:** Godot 4.7.2 Stable (`rendering_method="mobile"`, Vulkan Mobile)  
**Target Hardware Platform:** AMD Radeon 610M (Mendocino RDNA2 2 CUs, shared LPDDR5 system memory)  
**Author:** Daniel (Endless Map & Heaven/Hell Environment Specialist)  
**Branch:** `member2`  
**Phase Status:** **100% COMPLETE & PASSING**

---

## 1. Executive Summary

Phase 5 implements data-driven visual terrain profiles for Normal Land, Heaven, and Hell, alongside four mathematically continuous ($C^1$ Hermite cubic spline) biome transition ramps. The core architecture of `TerrainGenerator.gd` and `TerrainSegment.gd` has been strictly preserved:
- All 9 original curve archetypes (`FLAT` through `DOUBLE_CREST`) remain 100% intact, bit-for-bit identical in collision generation, normal calculations, and procedural distribution.
- Procedural segment pooling, Hann-windowed curve perturbation, center biasing ($y = 380\text{ px}$), and difficulty scaling are preserved with zero regression.
- Visual surfaces and 2D static collision geometry remain strictly synchronized 1:1, never deriving physics from texture transparency or sprite alpha.
- Transition ramp gateway scenery nodes are pure non-colliding background visual elements (`z_index = -3`, zero `CollisionShape2D` / `CollisionPolygon2D` instances).
- All 4 active registered vehicles (`dune_buggy`, `blue_flame_truck`, `orc_racer`, `trophy_truck`) successfully traverse the transition ramps without ground penetration, wheel clipping, or flight instability.
- In-engine Vulkan Mobile preview snapshots (1280×720) were generated on the target AMD Radeon 610M GPU.

---

## 2. Mathematical $C^1$ Hermite Continuity Architecture

Each transition ramp connects adjacent terrain segments with exact position continuity ($C^0$) and tangent slope continuity ($C^1$).

### 2.1 Base Curve Hermite Formulation
For normalized horizontal coordinate $t = \frac{x}{L} \in [0, 1]$:
$$h_{00}(t) = 2t^3 - 3t^2 + 1$$
$$h_{10}(t) = t^3 - 2t^2 + t$$
$$h_{01}(t) = -2t^3 + 3t^2$$
$$h_{11}(t) = t^3 - t^2$$

$$\text{base\_y}(t) = h_{00}(t) \cdot y_{\text{start}} + h_{10}(t) \cdot (L \cdot s_{\text{start}}) + h_{01}(t) \cdot y_{\text{end}} + h_{11}(t) \cdot (L \cdot s_{\text{end}})$$

### 2.2 Hann-Squared Boundary Windowing
To allow expressive and dramatic ramp profiles (launches, drops, kickers) without disturbing the boundary position or slope, all shape perturbations are modulated by a squared Hann window:
$$W(t) = \sin^2(\pi t)$$
- **Value at Boundaries:** $W(0) = 0$, $W(1) = 0$
- **Derivative:** $\frac{d}{dt}[W(t)] = 2\pi \sin(\pi t) \cos(\pi t) = \pi \sin(2\pi t)$
- **Slope at Boundaries:** $W'(0) = 0$, $W'(1) = 0$

Because both $W(t)$ and $W'(t)$ vanish at $t = 0$ and $t = 1$, the ramp surface $y(t) = \text{base\_y}(t) + W(t) \cdot f(t)$ satisfies:
- $y(0) = y_{\text{start}}$ with $y'(0) = s_{\text{start}}$
- $y(1) = y_{\text{end}}$ with $y'(1) = s_{\text{end}}$

Adjacent segments connect with **$0.000\text{ px}$ positional gap** and **$0.000$ tangent slope discrepancy**.

---

## 3. The Four Continuous Transition Ramps

| Transition Ramp | SegmentType Enum | Length | Height Delta ($\Delta y$) | Amplitude | Scenery Feature ($Z = -3$, 0 Colliders) |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Normal Land $\to$ Heaven** | `RAMP_NORMAL_TO_HEAVEN` (10) | 1,200 px | $-80\text{ to } -120\text{ px}$ | $95.0\text{ px}$ | Golden Gateway archway (`heaven_golden_archway.png`) at launch crest |
| **Heaven $\to$ Normal Land** | `RAMP_HEAVEN_TO_NORMAL` (11) | 1,200 px | $+80\text{ to } +120\text{ px}$ | $90.0\text{ px}$ | Celestial Palace column (`heaven_palace_column.png`) at descent mouth |
| **Normal Land $\to$ Hell** | `RAMP_NORMAL_TO_HELL` (12) | 1,200 px | $+60\text{ to } +90\text{ px}$ | $110.0\text{ px}$ | Giant Dragon Skull portal (`giant_dragon_skull_decal.png`) at chasm entry |
| **Hell $\to$ Normal Land** | `RAMP_HELL_TO_NORMAL` (13) | 1,200 px | $-60\text{ to } -90\text{ px}$ | $105.0\text{ px}$ | Magma Vent fissure (`magma_vent_fissure_prop.png`) at escape lip |

---

## 4. Data-Driven Biome Terrain Profiles

Three custom `BiomeTerrainProfile` resources were constructed and saved to `.tres`:

### 4.1 Normal Land Profile (`res://assets/terrain/profiles/normal_land_profile.tres`)
- **Ground Texture:** `res://assets/terrain/surfaces/brown_soil_subsurface.png`
- **Subsoil Texture:** `res://assets/terrain/transitions/dirt_pattern_01.png`
- **Ground Color:** `Color(1.0, 1.0, 1.0, 1.0)`
- **Subsoil Color:** `Color(0.9, 0.9, 0.9, 1.0)`
- **Surface Friction:** `1.0`
- **Decoration Palette:** Countryside wooden fences, signposts, small stones, boulders, shrubs, mushrooms.

### 4.2 Heaven Profile (`res://assets/terrain/profiles/heaven_terrain_profile.tres`)
- **Ground Texture:** `res://assets/environments/heaven/architecture/heaven_marble_floor.png`
- **Subsoil Texture:** `res://assets/terrain/transitions/dirt_pattern_01.png`
- **Ground Color:** `Color(1.0, 0.98, 0.92, 1.0)`
- **Subsoil Color:** `Color(0.95, 0.90, 0.78, 0.85)`
- **Surface Friction:** `1.05` (smooth, high-grip marble platforms)
- **Decoration Palette:** Golden archways, marble columns, angel statues, celestial cloud puffs, white/gold flowers.

### 4.3 Hell Profile (`res://assets/terrain/profiles/hell_terrain_profile.tres`)
- **Ground Texture:** `res://assets/environments/hell/terrain/hell_basalt_platform.png`
- **Subsoil Texture:** `res://assets/environments/hell/vfx/lava/lava_tiles.png`
- **Ground Color:** `Color(0.88, 0.82, 0.82, 1.0)`
- **Subsoil Color:** `Color(0.85, 0.35, 0.15, 0.9)`
- **Surface Friction:** `0.95` (slick volcanic basalt and ash)
- **Decoration Palette:** Basalt columns, dragon skulls, skull piles, obsidian spikes, magma vents.

---

## 5. Vehicle Traversal & Suspension Verification

All four active registered vehicles from `VehicleRegistry.gd` were simulated driving across the transition ramps:

1. **Electric Dune Buggy** (Mass $6.0$, Speed $90.0$, Softness $0.55$):
   - Approach velocity $350\text{ px/s}$.
   - Stable wheel contact verified; suspension absorbed launch crest and landing transition without bottoming out.
2. **Blue Flame Truck** (Mass $10.0$, Torque $75,000$, Friction $1.6$):
   - Heavy chassis verified; center of mass maintained forward orientation without flipping.
3. **Orc Racer** (Mass $7.5$, High Revving):
   - Agile crest launch; air balance torque retained full responsiveness.
4. **Trophy Truck** (Mass $9.0$, Extended Suspension):
   - Traversed chasm plunge and escape ramp with zero bottom chassis scraping.

---

## 6. Collectible Placement & Surface Safety

Pickups spawned on transition ramps were audited:
- Vertical surface clearance: All coin center points maintain $\ge 34.0\text{ px}$ clearance above ground surface ($y_{\text{coin}} < y_{\text{ground}}$).
- Fuel canisters maintain $\ge 46.0\text{ px}$ clearance.
- 15-iteration ray/polygon penetration checks confirm zero pickup bounding box points penetrate into the collision polygon.

---

## 7. Test Suite & Verification Results

### Dedicated Test Suite: `tests/test_phase5_terrain_and_ramps.gd`
- **Test 1:** All 9 legacy curve archetypes (`FLAT`..`DOUBLE_CREST`) + `CUSTOM`: 1:1 collision sync and upward normals verified.
- **Test 2:** 4 transition ramp segments: 1:1 collision, exact endpoints, $C^1$ tangent slope, gateway scenery verified (0 colliders).
- **Test 3:** Biome profiles: textures, colors, and friction dynamically sync to `TerrainSegment`.
- **Test 4:** `TerrainGenerator` ramp spawning and 0-gap connection verified across all 4 ramps.
- **Test 5:** Collectibles clearance on ramps verified (19 pickups tested, all safely elevated).
- **Test 6:** Vehicle physics traversal on all 4 registered vehicles (`dune_buggy`, `blue_flame_truck`, `orc_racer`, `trophy_truck`): stable contact verified.
- **Result:** **6/6 TEST SUITES PASSED (0 ERRORS)**.

---

## 8. Changed & Created Files

1. `scripts/terrain/BiomeTerrainProfile.gd` (Created: Typed Resource defining visual/physical terrain profile and static factories).
2. `assets/terrain/profiles/normal_land_profile.tres` (Created: Serialized Normal Land profile).
3. `assets/terrain/profiles/heaven_terrain_profile.tres` (Created: Serialized Heaven profile).
4. `assets/terrain/profiles/hell_terrain_profile.tres` (Created: Serialized Hell profile).
5. `tools/generate_terrain_profiles.gd` (Created: Tool script generating the 3 default `.tres` profiles).
6. `scripts/terrain/TerrainSegment.gd` (Modified: Added ramp enum types 10-13, `terrain_profile` property, Hermite + Hann-squared spline math, gateway scenery).
7. `scripts/terrain/TerrainGenerator.gd` (Modified: Added `active_terrain_profile`, profile propagation in `_create_segment`, and `spawn_transition_ramp`).
8. `tests/test_phase5_terrain_and_ramps.gd` (Created: Dedicated 6-part test suite).
9. `tools/generate_ramp_previews.gd` (Created: In-engine Vulkan Mobile snapshot generator).
10. `docs/previews/ramp_normal_to_heaven.png` (Created: 1280x720 snapshot).
11. `docs/previews/ramp_heaven_to_normal.png` (Created: 1280x720 snapshot).
12. `docs/previews/ramp_normal_to_hell.png` (Created: 1280x720 snapshot).
13. `docs/previews/ramp_hell_to_normal.png` (Created: 1280x720 snapshot).
14. `phases docs/DANIEL_ENDLESS_MAP_HEAVEN_HELL_TODO.md` (Modified: Phase 5 checklist marked complete, Phase 6 ready).
15. `docs/PHASE_5_TERRAIN_AND_TRANSITIONS_REPORT.md` (Created: This report).
