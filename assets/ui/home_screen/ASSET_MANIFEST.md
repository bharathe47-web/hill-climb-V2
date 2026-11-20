# Hill Climb 2D — Home Screen Environment Asset Collection Manifest

**Asset Collection Path:** `/home/johnwick/1level asset/enviroment-asset`  
**Checklist Source:** `/home/johnwick/Downloads/hill_climb_home_ui_environment_asset_todo.html`  
**Reference Target:** Countryside Landscape Reference (`reference_countryside_home_screen.png`)  
**Target Engine:** Godot Engine 4.x / GDScript & 2D Game Frameworks  
**Art Direction:** 2D cartoon, hand-painted countryside landscape style. Teal gradient sky, cream cumulus clouds, snow-capped rocky mountains, layered green hills, lush cartoon trees and conifers, rustic dark wooden fences, vibrant grass terrain with brown subsurface soil strata, carved wooden home navigation signboards with gold bevels and hanging rings, and cyan-accented sky exit button.  
**Licence:** CC0 Public Domain / Original Game Art  
**Total Checklist Items:** 36 / 36 Completed (100%)  
**Total RGBA PNG Assets:** 83 PNG files + Assembled Parallax Layers  

---

## Folder Structure Overview

```
enviroment-asset/
├── 01_sky_and_clouds/                   # Sky backdrop and cloud variations (9 files)
├── 02_mountains_and_distant_landscape/ # Snow peaks, ranges, rolling hills, textures (8 files)
├── 03_trees_and_vegetation/            # Large trees, pines, bushes, weeds, wildflowers (16 files)
├── 04_wooden_fences/                   # Rails, posts, corner joints, planks, wood textures (11 files)
├── 05_ground_and_foreground/           # Main grass strip, subsurface soil, pebbles, plants (12 files)
├── 06_navigation_and_home_ui_assets/   # 4 Destination signboards, icons, cyan quit button (16 files)
├── 07_assembled_layers_and_composites/ # Complete 1920x1080 parallax layers & composite (9 files)
├── hill_climb_home_ui_environment_asset_todo.html
├── home_screen_environment_composite_preview.png
├── reference_countryside_home_screen.png
└── ASSET_MANIFEST.md
```

---

## 1. Sky and Clouds (`01_sky_and_clouds/`)

| File Name | Resolution | Format | Visual Description & Usage |
|---|---|---|---|
| `sky_teal_gradient_1920x1080.png` | 1920 × 1080 | RGB PNG | Full HD countryside sky backdrop. Deep teal at top (`#377384`) transitioning to soft cyan-turquoise (`#629ea4`) and warm morning mist glow near horizon (`#daeee0`). |
| `sky_backdrop_tileable.png` | 512 × 1080 | RGB PNG | Seamless vertically-continuous sky strip for horizontal parallax wrapping and mobile viewport scaling. |
| `cloud_large_cream_01.png` | 650 × 240 | RGBA PNG | Large fluffy cream-white cumulus cloud formation with warm underside shadow and subtle rim highlights. |
| `cloud_large_cream_02.png` | 800 × 240 | RGBA PNG | Wide billowing cream cloud bank for sky volume and depth. |
| `cloud_distant_small_01.png` | 260 × 110 | RGBA PNG | Compact distant cloud cluster for horizon gaps. |
| `cloud_distant_small_02.png` | 220 × 95 | RGBA PNG | Slender horizontal cloud strand for low altitude. |
| `cloud_variant_puff_01.png` | 280 × 150 | RGBA PNG | 3-lobe puffy cloud variant for animated drifting. |
| `cloud_variant_puff_02.png` | 320 × 160 | RGBA PNG | Twin-lobe floating cloud variant for parallax variety. |
| `cloud_variant_wispy.png` | 400 × 90 | RGBA PNG | Feathered high-altitude cirrus cloud strand. |

---

## 2. Mountains and Distant Landscape (`02_mountains_and_distant_landscape/`)

| File Name | Resolution | Format | Visual Description & Usage |
|---|---|---|---|
| `mountain_snow_tipped_large_peak_01.png` | 900 × 560 | RGBA PNG | Majestic jagged mountain peak with brilliant white snowcap, slate-blue shadow facets, and misty base fade. |
| `mountain_snow_tipped_large_peak_02.png` | 850 × 520 | RGBA PNG | Asymmetrical secondary snow peak for ridge variety. |
| `mountain_layer_midground_range.png` | 1920 × 480 | RGBA PNG | Continuous midground mountain ridge with multi-faceted crags and soft atmospheric cyan haze base. |
| `mountain_ridge_medium_rocky.png` | 640 × 380 | RGBA PNG | Standalone rocky mountain peak for modular composition. |
| `hills_distant_green_silhouette.png` | 1920 × 360 | RGBA PNG | Full-width soft rolling meadow hills in painterly countryside greens (`#608e58`, `#507a4a`) with crest highlights. |
| `hills_rolling_soft_01.png` | 800 × 280 | RGBA PNG | Modular single rolling green hill piece for custom horizon curves. |
| `mountain_rock_texture_faceted.png` | 512 × 512 | RGBA PNG | Seamless faceted stone texture tile with stylized light and shadow rock facets. |
| `mountain_snow_highlight_overlay.png` | 512 × 512 | RGBA PNG | Transparent crystalline snow highlight overlay for shader blending. |

---

## 3. Trees and Vegetation (`03_trees_and_vegetation/`)

| File Name | Resolution | Format | Visual Description & Usage |
|---|---|---|---|
| `tree_leafy_large_left.png` | 520 × 680 | RGBA PNG | Grand cartoon oak tree for left screen framing; gnarly brown trunk with root flares, rich bark grain, and puffy lush foliage canopies with sunny rim highlights. |
| `tree_leafy_large_right.png` | 520 × 680 | RGBA PNG | Grand leafy tree for right screen framing; balanced organic canopy. |
| `tree_leafy_medium_01.png` | 360 × 480 | RGBA PNG | Midground rounded-crown countryside tree with branch details. |
| `tree_leafy_medium_02.png` | 340 × 460 | RGBA PNG | Taller slender deciduous tree with twin fork trunk. |
| `tree_pine_evergreen_01.png` | 320 × 580 | RGBA PNG | Alpine conifer pine tree with tiered dark needle clusters (`#1c4426`, `#306c3a`) and sunny ridge accents. |
| `tree_pine_evergreen_02.png` | 280 × 500 | RGBA PNG | Slender alpine spruce variant. |
| `bush_round_green_01.png` | 260 × 180 | RGBA PNG | Fluffy rounded countryside green shrub with layered leaf puffs. |
| `bush_dense_shrub_02.png` | 320 × 190 | RGBA PNG | Low spreading hedge shrub for ground coverage. |
| `bush_wide_hedgerow_cluster.png` | 480 × 210 | RGBA PNG | Multi-lobe hedgerow cluster for tree bases and fence lines. |
| `tree_distant_silhouette_strip.png` | 1200 × 120 | RGBA PNG | Continuous row of miniature soft tree puffs for mountain/hill horizon blending. |
| `tree_small_distant_cluster.png` | 280 × 180 | RGBA PNG | Clump of 3 distant stylized trees. |
| `plant_grass_weeds_01.png` | 160 × 180 | RGBA PNG | Tall wild grass stalks and curving weed sprigs. |
| `plant_grass_tufts_cluster.png` | 220 × 150 | RGBA PNG | Clump of vibrant green wild grass blades. |
| `wildflowers_yellow_buttercup.png` | 180 × 140 | RGBA PNG | Blossoming yellow countryside buttercup wildflowers. |
| `wildflowers_red_poppy.png` | 180 × 140 | RGBA PNG | Vivid crimson poppies with dark centers in grass sprigs. |
| `tiny_plants_clover_ground.png` | 150 × 110 | RGBA PNG | Foreground 3-leaf clover ground plant clusters. |

---

## 4. Wooden Fences (`04_wooden_fences/`)

| File Name | Resolution | Format | Visual Description & Usage |
|---|---|---|---|
| `fence_wooden_horizontal_rail_long.png` | 540 × 52 | RGBA PNG | Rustic weathered horizontal fence rail with dark wood grain, knot holes, and beveled edges. |
| `fence_wooden_horizontal_rail_short.png` | 320 × 48 | RGBA PNG | Short horizontal rail segment for modular fence spacing. |
| `fence_wooden_post_single.png` | 72 × 260 | RGBA PNG | Upright fence post with pointed top, woodgrain fibers, and metallic iron nail studs. |
| `fence_wooden_post_double.png` | 120 × 260 | RGBA PNG | Dual reinforced fence post for corners and joints. |
| `fence_wooden_corner_left.png` | 280 × 260 | RGBA PNG | Assembled left corner fence section with post and dual connecting rails. |
| `fence_wooden_corner_right.png` | 280 × 260 | RGBA PNG | Assembled right corner fence section. |
| `fence_wooden_plank_vertical.png` | 68 × 240 | RGBA PNG | Individual aged wooden plank with rounded ends for custom assembly. |
| `fence_wooden_plank_diagonal.png` | 220 × 180 | RGBA PNG | 35-degree angled cross-brace plank for sturdy fence aesthetics. |
| `wood_texture_dark_weathered.png` | 512 × 512 | RGBA PNG | Seamless tileable dark weathered wood texture (`#44240e`, `#6e3e1a`). |
| `wood_grain_plank_detail.png` | 480 × 80 | RGBA PNG | Detailed high-res woodgrain strip for trim and custom styling. |
| `fence_complete_countryside_segment.png` | 680 × 260 | RGBA PNG | Pre-assembled 4-post rustic fence unit ready for immediate drag-and-drop level placement. |

---

## 5. Ground and Foreground (`05_ground_and_foreground/`)

| File Name | Resolution | Format | Visual Description & Usage |
|---|---|---|---|
| `terrain_main_green_grass_strip.png` | 1920 × 360 | RGBA PNG | Continuous main ground strip with vibrant lush grass blades on crest and rich brown subsurface soil layer with pebbles. |
| `terrain_grass_surface_tileable.png` | 512 × 256 | RGBA PNG | Seamless tileable ground block with grass cap and earthen cross-section. |
| `foreground_dark_green_grass_strip.png` | 1920 × 160 | RGBA PNG | Rich dark green foreground silhouette grass layer (`#1c4422`) with distinct tall blades placed in front of main ground. |
| `foreground_grass_overhang_tufts.png` | 480 × 80 | RGBA PNG | Hanging grass blades that drape over road/cliff edges. |
| `terrain_brown_soil_subsurface.png` | 512 × 512 | RGBA PNG | Seamless earthen soil texture with organic strata, pebbles, and warm brown soil tones (`#5c361c`). |
| `dirt_earth_texture_tileable.png` | 512 × 256 | RGBA PNG | Tileable earthen cross-section for lower underground fills. |
| `grass_patch_tuft_01.png` | 140 × 110 | RGBA PNG | Standalone leafy grass tuft with sunny blade highlights. |
| `grass_patch_tuft_02.png` | 160 × 120 | RGBA PNG | Twin leafy grass tuft for ground detailing. |
| `stone_pebble_scatter_01.png` | 240 × 80 | RGBA PNG | Scatter of smooth grey countryside pebbles with cast shadows. |
| `rock_ground_detail_boulder.png` | 180 × 120 | RGBA PNG | Embedded ground rock with faceted planes and mossy green cap. |
| `ground_decorative_plants_weeds.png` | 220 × 140 | RGBA PNG | Foreground wild grass blades and woodland weeds. |
| `ground_clover_cluster.png` | 160 × 90 | RGBA PNG | Low-lying clover groundcover patch. |

---

## 6. Navigation and Home UI Assets (`06_navigation_and_home_ui_assets/`)

| File Name | Resolution | Format | Destination / Placement & Visual Description |
|---|---|---|---|
| `signboard_my_cars_garage.png` | 420 × 160 | RGBA PNG | **Right Side · Upper Position**. Carved wooden signboard with hanging rings, corner rivets, gold inner bevel, car icon, and bold carved text: "MY CARS / GARAGE & UPGRADES". |
| `signboard_my_cars_garage_with_post.png` | 420 × 300 | RGBA PNG | Same with dual wooden ground mounting posts attached. |
| `signboard_endless_map.png` | 420 × 160 | RGBA PNG | **Right Side · Lower Position**. Carved wooden signboard with infinity highway road icon and text: "ENDLESS MAP / DISTANCE CHALLENGE". |
| `signboard_endless_map_with_post.png` | 420 × 300 | RGBA PNG | Same with dual wooden ground mounting posts attached. |
| `signboard_indian_roads.png` | 420 × 160 | RGBA PNG | **Left Side · Upper Position**. Carved wooden signboard with Indian national highway route emblem and text: "INDIAN ROADS / HIGHWAY HIGHWAYS". |
| `signboard_indian_roads_with_post.png` | 420 × 300 | RGBA PNG | Same with dual wooden ground mounting posts attached. |
| `signboard_survival_map.png` | 420 × 160 | RGBA PNG | **Left Side · Lower Position**. Carved wooden signboard with hazard shield/skull emblem and text: "SURVIVAL MAP / FALLING ASTEROIDS". |
| `signboard_survival_map_with_post.png` | 420 × 300 | RGBA PNG | Same with dual wooden ground mounting posts attached. |
| `signboard_plate_blank.png` | 420 × 160 | RGBA PNG | Blank carved wooden signboard plate for customizable user text. |
| `signboard_plate_blank_with_post.png` | 420 × 300 | RGBA PNG | Blank plate with ground mounting posts. |
| `icon_nav_garage_car.png` | 180 × 180 | RGBA PNG | Standalone vintage sports car silhouette icon with gold chassis and dark wheels. |
| `icon_nav_endless_infinity.png` | 180 × 180 | RGBA PNG | Standalone infinity road highway ribbon icon with yellow dashed lane markings. |
| `icon_nav_indian_roads.png` | 180 × 180 | RGBA PNG | Standalone Indian national highway route shield with tricolor bands and Ashoka Chakra. |
| `icon_nav_survival_shield.png` | 180 × 180 | RGBA PNG | Standalone survival hazard emblem with danger triangle and skull silhouette. |
| `button_quit_sky_cyan.png` | 180 × 180 | RGBA PNG | **Sky Position · Cyan-marked Reference Location**. Circular wooden button featuring glowing cyan outer halo (`#00f0ff`), gold rim, and carved white/burnt-wood exit door/arrow glyph. |
| `icon_quit_exit_standalone.png` | 140 × 140 | RGBA PNG | Standalone white exit door and directional arrow glyph. |

---

## 7. Assembled Parallax Layers & Composites (`07_assembled_layers_and_composites/`)

| File Name | Resolution | Format | Layer Index & Usage |
|---|---|---|---|
| `layer_01_sky.png` | 1920 × 1080 | RGB PNG | **Z-Index: -70**. Full teal sky gradient with atmospheric mist glow. |
| `layer_02_clouds.png` | 1920 × 1080 | RGBA PNG | **Z-Index: -60**. Cream cumulus and cirrus clouds positioned across the sky. |
| `layer_03_distant_mountains.png` | 1920 × 1080 | RGBA PNG | **Z-Index: -50**. Distant snow-capped mountain peaks and craggy midground ridge. |
| `layer_04_midground_hills_forest.png` | 1920 × 1080 | RGBA PNG | **Z-Index: -40**. Rolling pasture hills with distant tree silhouettes and midground pines. |
| `layer_05_wooden_fence.png` | 1920 × 1080 | RGBA PNG | **Z-Index: -30**. Countryside wooden fence line flanked by large framing leafy trees and bushes. |
| `layer_06_main_grass_terrain.png` | 1920 × 1080 | RGBA PNG | **Z-Index: -20**. Continuous main green grass ground strip and subsurface soil. |
| `layer_07_foreground_plants.png` | 1920 × 1080 | RGBA PNG | **Z-Index: -10**. Foreground dark green silhouette grass, pebbles, boulder, and wildflowers. |
| `layer_08_home_signboards_and_ui.png` | 1920 × 1080 | RGBA PNG | **Z-Index: 0**. All 4 destination signboards in exact reference positions + cyan-glow Quit button in top sky. |
| `home_screen_complete_environment_composite.png` | 1920 × 1080 | RGBA PNG | Complete flattened composite preview reproducing the full reference home screen environment. |

---

## Godot 4.x Parallax2D Integration Guide

In your Godot 4.x Home Scene (`HomeScreen.tscn`):

```gdscript
extends Node2D

@onready var parallax_sky = $ParallaxBackground/SkyLayer
@onready var parallax_clouds = $ParallaxBackground/CloudLayer
@onready var parallax_mountains = $ParallaxBackground/MountainLayer
@onready var parallax_hills = $ParallaxBackground/HillsLayer

func _process(delta: float) -> void:
    # Gentle home screen ambient cloud drift
    $ParallaxBackground/CloudLayer.motion_offset.x += 12.0 * delta
```

Recommended Parallax Motion Scale factors:
- `Layer 01 (Sky)`: `motion_scale = Vector2(0.0, 0.0)`
- `Layer 02 (Clouds)`: `motion_scale = Vector2(0.05, 0.0)` (with slow autoscroll)
- `Layer 03 (Distant Mountains)`: `motion_scale = Vector2(0.12, 0.05)`
- `Layer 04 (Midground Hills)`: `motion_scale = Vector2(0.30, 0.15)`
- `Layer 05 (Wooden Fence & Trees)`: `motion_scale = Vector2(0.65, 0.35)`
- `Layer 06 (Main Terrain)`: `motion_scale = Vector2(1.0, 1.0)`
- `Layer 07 (Foreground Details)`: `motion_scale = Vector2(1.15, 1.0)`
- `Layer 08 (Home UI Signboards)`: CanvasLayer or static Node2D overlay
