# Complete Project Asset Inventory

**Project:** Hill Climb 2D  
**Asset Organization Structure:**  
- `assets/vehicles/` – Vehicle body sprites, front/rear wheels, and previews  
- `assets/wheels/` – Standard wheels, rims, and tire treads  
- `assets/garage/` – Garage showroom environment, platform, lighting, tool cabinets, and decorations  
- `assets/backgrounds/` – Parallax sky and terrain backdrops  
- `assets/ui/` – UI controls, HUD gauges, buttons, and mode cards  
- `assets/icons/` – Interactive UI icons (currency, trophy, crown, share, home, nitro)  
- `assets/effects/` – Curated gameplay effects (snowfall, coin sparkles)  

---

## Summary of Asset Categories

| Category | File Count | Primary Format | Transparency Status |
|---|---|---|---|
| **Audio SFX** | 12 | MP3 | All PNGs 32-bit Transparent |
| **Backgrounds** | 24 | PNG | All PNGs 32-bit Transparent |
| **Environment & Parallax** | 93 | PNG | All PNGs 32-bit Transparent |
| **Fonts** | 3 | TTF | All PNGs 32-bit Transparent |
| **Gameplay Effects** | 11 | PNG | All PNGs 32-bit Transparent |
| **Garage Audio** | 6 | WAV | All PNGs 32-bit Transparent |
| **Garage Decorations** | 14 | PNG | All PNGs 32-bit Transparent |
| **Garage Environment** | 8 | PNG | All PNGs 32-bit Transparent |
| **Garage Lighting** | 6 | PNG | All PNGs 32-bit Transparent |
| **Garage UI** | 14 | TTF | All PNGs 32-bit Transparent |
| **Garage Vehicle Showcase** | 16 | PNG | All PNGs 32-bit Transparent |
| **Pickups & Collectibles** | 30 | PNG | All PNGs 32-bit Transparent |
| **Survival Obstacles** | 15 | PNG | All PNGs 32-bit Transparent |
| **Terrain & Surfaces** | 29 | PNG | All PNGs 32-bit Transparent |
| **UI & HUD** | 66 | PNG | All PNGs 32-bit Transparent |
| **UI Icons** | 11 | PNG | All PNGs 32-bit Transparent |
| **Vehicles (Active Starters)** | 60 | PNG | All PNGs 32-bit Transparent |
| **Vehicles (Garage Collection)** | 89 | PNG | All PNGs 32-bit Transparent |
| **Wheels & Tires** | 7 | PNG | All PNGs 32-bit Transparent |

---

## Detailed Asset Catalog

### Audio SFX (12 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `background_music_happy_adventure.mp3` | 636925 B | MP3 | N/A | scenes/game/Game.tscn |
| `coin_collection_sound.wav` | 440 KB | WAV | N/A (Audio) | scenes/pickups/Coin.tscn |
| `fuel_collection_sound.wav` | 304 KB | WAV | N/A (Audio) | scenes/pickups/FuelPickup.tscn |
| `engine_acceleration_rev_high.wav` | 54 KB | WAV | N/A (Audio) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_10.tscn |
| `engine_acceleration_rev_low.wav` | 57 KB | WAV | N/A (Audio) | Unused / Repository Asset |
| `engine_acceleration_rev_med.wav` | 58 KB | WAV | N/A (Audio) | Unused / Repository Asset |
| `engine_idle_loop.wav` | 74 KB | WAV | N/A (Audio) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_10.tscn |
| `game_over_sound.wav` | 2954 KB | WAV | N/A (Audio) | scenes/ui/ResultsScreen.tscn |
| `ui_button_click.wav` | 58 KB | WAV | N/A (Audio) | scenes/ui/ResultsScreen.tscn, scripts/vehicle/VehicleController.gd |
| `tire_rolling_skid_loop.wav` | 843 KB | WAV | N/A (Audio) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_10.tscn |
| `vehicle_landing_thud.wav` | 50 KB | WAV | N/A (Audio) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_10.tscn |
| `countryside_wind_ambience.wav` | 729 KB | WAV | N/A (Audio) | scenes/game/Game.tscn |

### Backgrounds (24 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `city_skyline_parallax_layer.png` | 480 × 320 | PNG | Transparent (RGBA) | Curated backgrounds library |
| `cloud_cirrus_03.png` | 129 × 71 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `cloud_cumulus_01.png` | 128 × 71 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `cloud_cumulus_02.png` | 129 × 71 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `damaged_buildings_parallax.png` | 480 × 320 | PNG | Transparent (RGBA) | Curated backgrounds library |
| `dark_cloud_layer_01.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `dark_cloud_layer_02.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Curated backgrounds library |
| `distant_city_silhouettes_wide.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Curated backgrounds library |
| `distant_damaged_building_silhouettes.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Curated backgrounds library |
| `distant_electrical_transmission_towers.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `distant_ruined_city_skyline.png` | 1120 × 800 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `distant_smoke_plumes_dense.png` | 1536 × 1279 | PNG | Transparent (RGBA) | Curated backgrounds library |
| `distant_smoke_plumes_strip.png` | 1280 × 768 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `dusty_atmospheric_haze_layer.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Curated backgrounds library |
| `layer_01_sky_backdrop.png` | 272 × 160 | PNG | Opaque (RGB) | Curated backgrounds library |
| `layer_02_distant_mountains.png` | 272 × 160 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `layer_03_distant_hills.png` | 544 × 160 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `layer_04_forest_silhouettes.png` | 160 × 224 | PNG | Transparent (RGBA) | Curated backgrounds library |
| `layer_05_midground_forest.png` | 544 × 160 | PNG | Transparent (RGBA) | Curated backgrounds library |
| `layer_06_foreground_scenery.png` | 544 × 160 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `orange_sunset_sky.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `sky_daylight_1920x1200.png` | 1920 × 1200 | PNG | Opaque (RGB) | scenes/environment/ParallaxEnvironment.tscn |
| `sunset_sky_vertical_parallax.png` | 480 × 800 | PNG | Transparent (RGBA) | Curated backgrounds library |
| `transmission_tower_single.png` | 460 × 336 | PNG | Transparent (RGBA) | Curated backgrounds library |

### Environment & Parallax (93 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `layer_01_sky_backdrop.png` | 272 × 160 | PNG | Opaque (RGB) | Unused / Repository Asset |
| `layer_02_distant_mountains.png` | 272 × 160 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `layer_03_distant_hills.png` | 544 × 160 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `layer_04_forest_silhouettes.png` | 160 × 224 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `layer_05_midground_forest.png` | 544 × 160 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `layer_06_foreground_scenery.png` | 544 × 160 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `collapsed_building_sections.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `destroyed_apartment_block_01.png` | 750 × 730 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `destroyed_apartment_buildings.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `damaged_commercial_office_buildings.png` | 1120 × 800 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `broken_facade_structures.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `broken_wall_facade_sections.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `exposed_structures_tileset.png` | 1024 × 512 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `concrete_rubble_columns.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `large_building_debris_piles.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `distant_smoke_effect.png` | 1280 × 768 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `dust_fog_overlay.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `floating_dust_particles_01.png` | 16 × 16 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `floating_dust_particles_02.png` | 16 × 16 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `ground_blowing_dust_effect.png` | 512 × 128 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wind_blown_dust_effect.png` | 512 × 256 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `warm_sunset_lighting_overlay.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `concrete_debris_chunk_01.png` | 600 × 380 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `concrete_debris_chunk_02.png` | 550 × 400 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `rubble_piles_variation_01.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `rubble_piles_variation_02.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `dirt_and_sand_patches.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `ground_crack_detail_01.png` | 650 × 180 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `ground_crack_detail_02.png` | 600 × 180 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `dusty_ground_with_objects.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `main_dusty_terrain_strip.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `survival_drivable_ground_strip.png` | 1920 × 512 | PNG | Transparent (RGBA) | scenes/modes/survival/Survival.tscn |
| `uneven_dusty_ground_variation.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `large_rock_01.png` | 533 × 459 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `large_rock_02.png` | 497 × 483 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `large_rock_03.png` | 526 × 380 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `small_stone_01.png` | 96 × 83 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `small_stone_02.png` | 96 × 93 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `small_stone_03.png` | 96 × 69 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `broken_asphalt_road_sections.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `cracked_road_overlay.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `distant_electrical_transmission_towers.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `transmission_tower_single.png` | 460 × 336 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `orange_sunset_sky.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `sunset_sky_vertical_parallax.png` | 480 × 800 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `dusty_atmospheric_haze_layer.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `city_skyline_parallax_layer.png` | 480 × 320 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `damaged_buildings_parallax.png` | 480 × 320 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `distant_city_silhouettes_wide.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `distant_damaged_building_silhouettes.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `distant_ruined_city_skyline.png` | 1120 × 800 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `dark_cloud_layer_01.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `dark_cloud_layer_02.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `distant_smoke_plumes_dense.png` | 1536 × 1279 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `distant_smoke_plumes_strip.png` | 1280 × 768 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `broken_electric_pole.png` | 460 × 336 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `damaged_transmission_structure.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `concrete_barrier_spritesheet.png` | 1280 × 1280 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `concrete_road_barrier_single.png` | 125 × 297 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `damaged_fence_chainlink.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `damaged_fence_metal.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `broken_traffic_sign.png` | 16 × 16 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `damaged_caution_sign.png` | 96 × 96 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `damaged_streetlight.png` | 379 × 501 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `fallen_tree_branch_01.png` | 234 × 234 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `fallen_tree_branch_02.png` | 208 × 218 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `dead_tree_01.png` | 400 × 225 | PNG | Transparent (RGBA) | scenes/environment/survival/destroyed_city_environment.tscn |
| `dead_tree_02.png` | 960 × 540 | PNG | Opaque (RGB) | Unused / Repository Asset |
| `dead_tree_tall_03.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hanging_electrical_cables.png` | 1920 × 1080 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `cloud_cirrus_03.png` | 129 × 71 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `cloud_cumulus_01.png` | 128 × 71 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `cloud_cumulus_02.png` | 129 × 71 | PNG | Transparent (RGBA) | scenes/environment/ParallaxEnvironment.tscn |
| `sky_daylight_1920x1200.png` | 1920 × 1200 | PNG | Opaque (RGB) | scenes/environment/ParallaxEnvironment.tscn |
| `sun_daylight_element.svg` | Vector | SVG | Vector (Transparent) | scenes/environment/ParallaxEnvironment.tscn |
| `wooden_fence_01.png` | 70 × 70 | PNG | Transparent (RGBA) | scenes/terrain/TestTrack.tscn, scripts/terrain/TerrainSegment.gd |
| `wooden_fence_broken.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `flower_purple.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `flower_yellow.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `grass_tuft_01.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `mushroom_brown.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `mushroom_red.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `sign_exit.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wooden_sign_arrow_left.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wooden_sign_arrow_right.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `wooden_signpost.png` | 70 × 70 | PNG | Transparent (RGBA) | scenes/terrain/TestTrack.tscn, scripts/terrain/TerrainSegment.gd |
| `large_tree_01.png` | 135 × 160 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `small_tree_01.png` | 111 × 160 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `bush_round_green.png` | 70 × 70 | PNG | Transparent (RGBA) | scenes/terrain/TestTrack.tscn, scripts/terrain/TerrainSegment.gd |
| `bush_shrub_01.png` | 196 × 125 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `bush_shrub_02.png` | 267 × 195 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `bush_shrub_03.png` | 366 × 243 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `fallen_log_01.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |

### Fonts (3 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `Boxy-Bold.ttf` | 14 KB | TTF | N/A (Font) | scenes/pickups/Coin.tscn, scenes/pickups/FuelPickup.tscn |
| `Kenney_Future.ttf` | 33 KB | TTF | N/A (Font) | scenes/main/MainMenu.tscn, scenes/modes/garage/VintageCarGarage.tscn |
| `Kenney_Future_Narrow.ttf` | 33 KB | TTF | N/A (Font) | scenes/main/MainMenu.tscn, scenes/modes/garage/VintageCarGarage.tscn |

### Gameplay Effects (11 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `nitro_boost.png` | 256 × 256 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `nitro_bottle.png` | 400 × 400 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `nitro_flame.png` | 320 × 140 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleController.gd |
| `nitro_flame_01.png` | 105 × 105 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn, scripts/vehicle/VehicleController.gd |
| `nitro_flame_02.png` | 105 × 105 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleController.gd |
| `nitro_flame_03.png` | 105 × 105 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleController.gd |
| `nitro_flame_burst.png` | 360 × 180 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleController.gd, scripts/vehicle/VehicleController.gd |
| `nitro_particle_spark.png` | 64 × 64 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleController.gd |
| `fog_overlay.png` | 1920 × 400 | PNG | Transparent (RGBA) | scenes/environment/SnowfallManager.tscn |
| `snowflake_01.png` | 64 × 64 | PNG | Transparent (RGBA) | scenes/environment/SnowfallManager.tscn |
| `snowstorm_overlay.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/environment/SnowfallManager.tscn |

### Garage Audio (6 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `sfx_button_click.wav` | 58 KB | WAV | N/A (Audio) | scripts/modes/garage/VintageCarGarageController.gd, scripts/modes/garage/VintageCarGarageController.gd |
| `sfx_coin_reward.wav` | 440 KB | WAV | N/A (Audio) | Unused / Repository Asset |
| `sfx_nav_feedback.wav` | 61 KB | WAV | N/A (Audio) | scripts/modes/garage/VintageCarGarageController.gd, scripts/vehicle/VehicleController.gd |
| `sfx_vehicle_selection.wav` | 58 KB | WAV | N/A (Audio) | scripts/modes/garage/VintageCarGarageController.gd |
| `sfx_garage_ambience.ogg` | 2427 KB | OGG | N/A (Audio) | scenes/modes/garage/VintageCarGarage.tscn |
| `sfx_garage_ambience.wav` | 5168 KB | WAV | N/A (Audio) | Unused / Repository Asset |

### Garage Decorations (14 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `gear_large_side.png` | 200 × 200 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `gear_small_side.png` | 240 × 180 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `industrial_machinery_details.png` | 120 × 180 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `pipe_vertical_left.png` | 40 × 580 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `pipe_vertical_right.png` | 40 × 580 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `pipes_horizontal_brackets.png` | 180 × 60 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `pipes_vertical_metal.png` | 100 × 580 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `shelf_supports_brackets.png` | 40 × 65 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `tire_stack_left.png` | 260 × 160 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `tire_stack_right.png` | 260 × 160 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `tire_stacks_black.png` | 542 × 145 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `tool_cabinet_tall.png` | 180 × 340 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `tool_cabinet_workshop.png` | 240 × 300 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `workshop_environment.png` | 640 × 340 | PNG | Transparent (RGBA) | Unused / Repository Asset |

### Garage Environment (8 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `dark_brick_wall_background.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `garage_floor_dark.png` | 1672 × 191 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `pillar_left_brick.png` | 140 × 941 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `pillar_right_brick.png` | 142 × 941 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `shelf_lower_metal.png` | 1390 × 30 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `shelf_upper_metal.png` | 1390 × 30 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `vehicle_display_platform.png` | 800 × 140 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `wall_details_brick_variation.png` | 240 × 120 | PNG | Transparent (RGBA) | Unused / Repository Asset |

### Garage Lighting (6 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `ambient_vignette_overlay.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `car_shadow_soft_dark_oval.png` | 850 × 220 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `ceiling_workshop_lamp.png` | 160 × 100 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `floor_glow_yellow_soft.png` | 1000 × 320 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `spotlight_beam_yellow.png` | 1920 × 1080 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `vehicle_selection_marker.png` | 950 × 320 | PNG | Transparent (RGBA) | Unused / Repository Asset |

### Garage UI (14 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `Kenney_Future.ttf` | 33 KB | TTF | N/A (Font) | scenes/main/MainMenu.tscn, scenes/modes/garage/VintageCarGarage.tscn |
| `Kenney_Future_Narrow.ttf` | 33 KB | TTF | N/A (Font) | scenes/main/MainMenu.tscn, scenes/modes/garage/VintageCarGarage.tscn |
| `icon_crown.png` | 79 × 58 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `icon_gold_coin.png` | 50 × 50 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `icon_home.png` | 77 × 66 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `icon_share.png` | 58 × 58 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `icon_trophy.png` | 62 × 62 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `button_hover_state.png` | 140 × 100 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_pressed_state.png` | 140 × 100 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `banner_center_coin_wood.png` | 447 × 95 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `banner_center_coin_wood_empty.png` | 447 × 95 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `panel_borders_inner_backing.png` | 130 × 95 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `panel_left_orange_wood.png` | 312 × 130 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `panel_right_orange_wood.png` | 291 × 131 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |

### Garage Vehicle Showcase (16 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `vintage_car_complete.png` | 690 × 570 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `bumper_front_chrome.png` | 265 × 75 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `car_decals_stars.png` | 65 × 20 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `grille_front_dark.png` | 145 × 75 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `headlight_left.png` | 60 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `headlight_right.png` | 60 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `headlights_sprite.png` | 140 × 80 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `number_plate_orange.png` | 70 × 53 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `rim_front.png` | 50 × 60 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `rim_rear.png` | 42 × 48 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `side_mirror_sprite.png` | 80 × 80 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wheel_front.png` | 100 × 100 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_front_rear_sprites.png` | 200 × 110 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wheel_rear.png` | 80 × 80 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `wheel_rim_sprites.png` | 120 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `window_glass_details.png` | 380 × 245 | PNG | Transparent (RGBA) | Unused / Repository Asset |

### Pickups & Collectibles (30 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `fuel_collection_feedback_flash.png` | 550 × 496 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `sparkle_star_coin_1.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `sparkle_star_coin_2.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `sparkle_star_coin_3.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `sparkle_star_coin_4.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `sparkle_star_coin_5.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `sparkle_star_coin_6.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `fuel_can_static.png` | 128 × 144 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `fuel_can_frame_01.png` | 128 × 144 | PNG | Transparent (RGBA) | scenes/pickups/FuelPickup.tscn |
| `fuel_can_frame_02.png` | 128 × 144 | PNG | Transparent (RGBA) | scenes/pickups/FuelPickup.tscn |
| `fuel_can_frame_03.png` | 128 × 144 | PNG | Transparent (RGBA) | scenes/pickups/FuelPickup.tscn |
| `fuel_can_frame_04.png` | 128 × 144 | PNG | Transparent (RGBA) | scenes/pickups/FuelPickup.tscn |
| `fuel_can_frame_05.png` | 128 × 144 | PNG | Transparent (RGBA) | scenes/pickups/FuelPickup.tscn |
| `fuel_can_frame_06.png` | 128 × 144 | PNG | Transparent (RGBA) | scenes/pickups/FuelPickup.tscn |
| `coin_bronze_static.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `coin_gold_static.png` | 70 × 70 | PNG | Transparent (RGBA) | scenes/pickups/Coin.tscn |
| `coin_silver_static.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_normal.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_1.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_2.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_3.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_4.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_5.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_6.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_rotate_1.png` | 2233 × 2243 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_rotate_2.png` | 1957 × 2242 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_rotate_3.png` | 1057 × 2242 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_rotate_4.png` | 339 × 2242 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_rotate_5.png` | 1057 × 2242 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `star_coin_rotate_6.png` | 1957 × 2242 | PNG | Transparent (RGBA) | Unused / Repository Asset |

### Survival Obstacles (15 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `murukku.png` | 256 × 256 | PNG | Transparent (RGBA) | scenes/modes/survival/obstacles/murukku_obstacle.tscn |
| `pani_puri.png` | 256 × 256 | PNG | Transparent (RGBA) | scenes/modes/survival/obstacles/pani_puri_obstacle.tscn |
| `pani_puri_cluster.png` | 320 × 260 | PNG | Transparent (RGBA) | scenes/modes/survival/obstacles/pani_puri_obstacle.tscn |
| `jalebi.png` | 256 × 256 | PNG | Transparent (RGBA) | scenes/modes/survival/obstacles/jalebi_obstacle.tscn |
| `dosa.png` | 384 × 275 | PNG | Transparent (RGBA) | scenes/modes/survival/obstacles/dosa_obstacle.tscn |
| `idli.png` | 256 × 256 | PNG | Transparent (RGBA) | scenes/modes/survival/obstacles/idli_obstacle.tscn |
| `vada.png` | 256 × 256 | PNG | Transparent (RGBA) | scenes/modes/survival/obstacles/vada_obstacle.tscn |
| `samosa.png` | 256 × 256 | PNG | Transparent (RGBA) | scenes/modes/survival/obstacles/samosa_obstacle.tscn |
| `coconut.png` | 256 × 248 | PNG | Transparent (RGBA) | scenes/modes/survival/obstacles/coconut_obstacle.tscn |
| `obstacle_warning_indicator.png` | 128 × 128 | PNG | Transparent (RGBA) | scenes/modes/survival/warnings/obstacle_warning.tscn |
| `warning_marker_ground_ring.png` | 192 × 192 | PNG | Transparent (RGBA) | scenes/modes/survival/warnings/obstacle_warning.tscn |
| `generic_collision_impact_effect.png` | 365 × 354 | PNG | Transparent (RGBA) | scripts/components/survival_obstacles/food_obstacle.gd |
| `ground_contact_impact_burst.png` | 1024 × 1024 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `obstacle_shadow.png` | 180 × 60 | PNG | Transparent (RGBA) | scenes/modes/survival/obstacles/samosa_obstacle.tscn, scenes/modes/survival/obstacles/murukku_obstacle.tscn |
| `small_dust_impact_particles.png` | 16 × 16 | PNG | Transparent (RGBA) | Unused / Repository Asset |

### Terrain & Surfaces (29 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `ground_dirt_patch.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `ground_grass_patch.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `ground_stone_patch.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `brown_soil_subsurface.png` | 70 × 70 | PNG | Transparent (RGBA) | scenes/terrain/TestTrack.tscn, scripts/terrain/TerrainSegment.gd |
| `country_platform_tileset.png` | 176 × 160 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `grass_ground_surface.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `grass_top_edge.png` | 70 × 70 | PNG | Transparent (RGBA) | scenes/terrain/TestTrack.tscn, scripts/terrain/TerrainSegment.gd |
| `cliff_transition_left.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `cliff_transition_right.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `dirt_cliff_left.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `dirt_cliff_right.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `dirt_pattern_01.png` | 70 × 70 | PNG | Transparent (RGBA) | scenes/terrain/TestTrack.tscn, scripts/terrain/TerrainSegment.gd |
| `dirt_pattern_02.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `ground_edge_left.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `ground_edge_right.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `large_rock_boulder_01.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `rock_hill_slope_left.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `rock_hill_slope_right.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `small_stones_pebbles.png` | 70 × 70 | PNG | Transparent (RGBA) | scripts/terrain/TerrainSegment.gd |
| `dirt_slope_downhill.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `dirt_slope_uphill.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hill_curve_crest.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hill_curve_valley.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `slope_downhill_gentle.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `slope_downhill_steep.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `slope_uphill_gentle.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `slope_uphill_steep.png` | 70 × 70 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `terrain_bump_left.png` | 5 × 24 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `terrain_bump_right.png` | 5 × 24 | PNG | Transparent (RGBA) | Unused / Repository Asset |

### UI & HUD (66 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `accelerator_pedal_normal.png` | 140 × 140 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `accelerator_pedal_pressed.png` | 140 × 140 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `brake_pedal_normal.png` | 140 × 140 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `brake_pedal_pressed.png` | 140 × 140 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `control_button_base.png` | 128 × 128 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `control_button_highlight.png` | 128 × 128 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `pause_button_normal.png` | 64 × 64 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `hill_climb_game_logo.png` | 600 × 180 | PNG | Transparent (RGBA) | scenes/main/MainMenu.tscn |
| `button_home.png` | 192 × 192 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_home_pressed.png` | 192 × 192 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_pause.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_pause_pressed.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_play_icon.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_play_normal.png` | 192 × 64 | PNG | Transparent (RGBA) | scenes/main/MainMenu.tscn |
| `button_play_pressed.png` | 192 × 64 | PNG | Transparent (RGBA) | scenes/main/MainMenu.tscn |
| `button_restart.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_restart_pressed.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_resume_normal.png` | 192 × 64 | PNG | Transparent (RGBA) | scenes/ui/PauseMenu.tscn |
| `button_resume_pressed.png` | 192 × 64 | PNG | Transparent (RGBA) | scenes/ui/PauseMenu.tscn |
| `button_retry_normal.png` | 192 × 64 | PNG | Transparent (RGBA) | scenes/ui/PauseMenu.tscn, scenes/ui/ResultsScreen.tscn |
| `button_retry_pressed.png` | 192 × 64 | PNG | Transparent (RGBA) | scenes/ui/PauseMenu.tscn, scenes/ui/ResultsScreen.tscn |
| `button_settings_audio_mute.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_settings_audio_unmute.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_settings_gear.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `button_settings_gear_pressed.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `coin_counter_display_panel.png` | 220 × 52 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `coin_icon.png` | 47 × 47 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `distance_display_banner.png` | 220 × 52 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_number_0.png` | 30 × 38 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_number_1.png` | 26 × 37 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_number_2.png` | 32 × 38 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_number_3.png` | 28 × 38 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_number_4.png` | 29 × 38 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_number_5.png` | 28 × 38 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_number_6.png` | 30 × 38 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_number_7.png` | 32 × 39 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_number_8.png` | 32 × 40 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_number_9.png` | 32 × 39 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_symbol_x.png` | 30 × 28 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `hud_heart_empty.png` | 125 × 125 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn, scripts/modes/survival/SurvivalController.gd |
| `hud_heart_full.png` | 125 × 125 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn, scripts/modes/survival/SurvivalController.gd |
| `fuel_bar_background.png` | 260 × 38 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `fuel_bar_fill.png` | 252 × 30 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `fuel_bar_fill_warning.png` | 252 × 30 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `fuel_bar_frame.png` | 260 × 38 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `fuel_icon.png` | 128 × 144 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `rpm_gauge_dial_background.png` | 483 × 483 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `rpm_gauge_frame.png` | 483 × 483 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `rpm_gauge_needle.png` | 24 × 200 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `speedometer_background.png` | 512 × 512 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `speedometer_needle.png` | 32 × 240 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `speedometer_needle.svg` | Vector | SVG | Vector (Transparent) | Unused / Repository Asset |
| `speedometer_needle_centered.png` | 512 × 512 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `speedometer_needle_centered.svg` | Vector | SVG | Vector (Transparent) | Unused / Repository Asset |
| `speedometer_preview.png` | 512 × 512 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `speedometer_racing_background.png` | 512 × 512 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `main_menu_background.png` | 1920 × 1200 | PNG | Opaque (RGB) | scenes/main/MainMenu.tscn |
| `screen_transition_circle_mask.png` | 512 × 512 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `mode_endless.png` | 400 × 240 | PNG | Transparent (RGBA) | scenes/main/MainMenu.tscn |
| `mode_garage.png` | 400 × 240 | PNG | Transparent (RGBA) | scenes/main/MainMenu.tscn |
| `mode_indian_roads.png` | 400 × 240 | PNG | Transparent (RGBA) | scenes/main/MainMenu.tscn |
| `mode_survival.png` | 400 × 240 | PNG | Transparent (RGBA) | scenes/main/MainMenu.tscn |
| `collected_coins_result_display.png` | 360 × 72 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `final_distance_result_display.png` | 360 × 72 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `game_over_panel_background.png` | 480 × 420 | PNG | Transparent (RGBA) | scenes/ui/ResultsScreen.tscn |
| `pause_panel_background.png` | 480 × 360 | PNG | Transparent (RGBA) | scenes/ui/PauseMenu.tscn |

### UI Icons (11 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `coin_counter_display_panel.png` | 220 × 52 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `coin_icon.png` | 47 × 47 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `hud_heart_empty.png` | 125 × 125 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn, scripts/modes/survival/SurvivalController.gd |
| `hud_heart_full.png` | 125 × 125 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn, scripts/modes/survival/SurvivalController.gd |
| `icon_crown.png` | 79 × 58 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `icon_gold_coin.png` | 50 × 50 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `icon_home.png` | 77 × 66 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `icon_share.png` | 58 × 58 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `icon_trophy.png` | 62 × 62 | PNG | Transparent (RGBA) | scenes/modes/garage/VintageCarGarage.tscn |
| `nitro_boost.png` | 256 × 256 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |
| `nitro_bottle.png` | 400 × 400 | PNG | Transparent (RGBA) | scenes/ui/HUD.tscn |

### Vehicles (Active Starters) (60 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `assembled.png` | 691 × 257 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `body.png` | 691 × 194 | PNG | Transparent (RGBA) | scenes/vehicle/TrophyTruck.tscn, scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 120 × 119 | PNG | Transparent (RGBA) | scenes/vehicle/TrophyTruck.tscn, scripts/vehicle/VehicleRegistry.gd |
| `wheel_front.png` | 120 × 119 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 120 × 119 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `exhaust_pipe.png` | 160 × 100 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `exhaust_pipe.svg` | Vector | SVG | Vector (Transparent) | Unused / Repository Asset |
| `mechanical_chassis_bracket.png` | 64 × 64 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `mechanical_chassis_bracket.svg` | Vector | SVG | Vector (Transparent) | Unused / Repository Asset |
| `assembled_preview.png` | 636 × 315 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `body.png` | 636 × 220 | PNG | Transparent (RGBA) | scenes/vehicle/OrcRacer.tscn, scripts/vehicle/VehicleRegistry.gd |
| `driver.png` | 313 × 246 | PNG | Transparent (RGBA) | scenes/vehicle/OrcRacer.tscn |
| `wheel_front.png` | 187 × 187 | PNG | Transparent (RGBA) | scenes/vehicle/OrcRacer.tscn |
| `wheel_rear.png` | 187 × 187 | PNG | Transparent (RGBA) | scenes/vehicle/OrcRacer.tscn, scripts/vehicle/VehicleRegistry.gd |
| `exhaust_smoke_particle_01.png` | 362 × 336 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_10.tscn |
| `ground_dust_01.png` | 381 × 346 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_10.tscn |
| `suspension_shock_absorber.png` | 80 × 160 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `wheel_front.png` | 240 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/MonsterTruck.tscn |
| `wheel_rear.png` | 240 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/MonsterTruck.tscn |
| `wheel_tire_tread.png` | 240 × 240 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wheel_rim_hub.png` | 140 × 140 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wheel_rim_hub_aligned.png` | 240 × 240 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wheel_rim_hub_detailed.png` | 140 × 140 | PNG | Transparent (RGBA) | scenes/vehicle/MonsterTruck.tscn |
| `wheel_rim_hub_detailed.svg` | Vector | SVG | Vector (Transparent) | Unused / Repository Asset |
| `body.png` | 641 × 399 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_10.tscn |
| `driver_sprite.png` | 300 × 261 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/TrophyTruck.tscn |
| `vehicle_assembled_preview.png` | 641 × 440 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `vehicle_body_truck_side.png` | 641 × 399 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scripts/vehicle/VehicleRegistry.gd |
| `vehicle_layer_breakdown_preview.png` | 1200 × 800 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wheel_front.png` | 240 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn |
| `wheel_rear.png` | 240 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scripts/vehicle/VehicleRegistry.gd |
| `wheel_rim_hub.png` | 140 × 140 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wheel_rim_hub_aligned.png` | 240 × 240 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `wheel_rim_hub_detailed.png` | 140 × 140 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn |
| `wheel_rim_hub_detailed.svg` | Vector | SVG | Vector (Transparent) | Unused / Repository Asset |
| `wheel_tire_tread.png` | 240 × 240 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `driver_sprite.png` | 300 × 261 | PNG | Transparent (RGBA) | scenes/vehicle/MonsterTruck.tscn |
| `vehicle_body_truck_side.png` | 641 × 399 | PNG | Transparent (RGBA) | scenes/vehicle/MonsterTruck.tscn |
| `one_wheel_scooter.png` | 540 × 200 | PNG | Transparent (RGBA) | Unused / Repository Asset |
| `one_wheel_scooter_body.png` | 540 × 200 | PNG | Transparent (RGBA) | scenes/vehicle/OneWheelScooter.tscn |
| `one_wheel_scooter_body.svg` | Vector | SVG | Vector (Transparent) | Unused / Repository Asset |
| `one_wheel_scooter_wheel.png` | 200 × 200 | PNG | Transparent (RGBA) | scenes/vehicle/OneWheelScooter.tscn |
| `one_wheel_scooter_wheel.svg` | Vector | SVG | Vector (Transparent) | Unused / Repository Asset |
| `assembled_preview.png` | 599 × 209 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd, scripts/vehicle/VehicleRegistry.gd |
| `body.png` | 599 × 209 | PNG | Transparent (RGBA) | scenes/vehicle/DuneBuggy.tscn, scenes/vehicle/Vehicle.tscn |
| `driver.png` | 422 × 303 | PNG | Transparent (RGBA) | scenes/vehicle/DuneBuggy.tscn, scenes/vehicle/Vehicle.tscn |
| `wheel_front.png` | 119 × 119 | PNG | Transparent (RGBA) | scenes/vehicle/DuneBuggy.tscn, scenes/vehicle/Vehicle.tscn |
| `wheel_rear.png` | 118 × 119 | PNG | Transparent (RGBA) | scenes/vehicle/DuneBuggy.tscn, scenes/vehicle/Vehicle.tscn |
| `assembled.png` | 691 × 257 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `body.png` | 691 × 194 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_10.tscn |
| `wheel.png` | 120 × 119 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_14.tscn |
| `body.png` | 636 × 220 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_10.tscn |
| `driver.png` | 313 × 246 | PNG | Transparent (RGBA) | scenes/vehicle/DuneBuggy.tscn, scenes/vehicle/OrcRacer.tscn |
| `wheel_front.png` | 187 × 187 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 187 × 187 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `assembled_preview.png` | 599 × 230 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `body.png` | 599 × 209 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_10.tscn |
| `driver.png` | 422 × 303 | PNG | Transparent (RGBA) | scenes/vehicle/DuneBuggy.tscn, scenes/vehicle/OrcRacer.tscn |
| `wheel_front.png` | 119 × 119 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 118 × 119 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |

### Vehicles (Garage Collection) (89 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `body.png` | 796 × 422 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_14.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_14.png` | 863 × 483 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 256 × 255 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_14.tscn, scenes/vehicle/garage/car_14.tscn |
| `wheel_front.png` | 256 × 255 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 256 × 255 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 972 × 396 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_15.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_15.png` | 1016 × 482 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 265 × 266 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_15.tscn, scenes/vehicle/garage/car_15.tscn |
| `wheel_front.png` | 265 × 266 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 265 × 266 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 839 × 421 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_17.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_17.png` | 871 × 503 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 255 × 257 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_17.tscn, scenes/vehicle/garage/car_17.tscn |
| `wheel_front.png` | 255 × 257 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 255 × 257 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 2258 × 1310 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_08.tscn, scripts/vehicle/VehicleRegistry.gd |
| `body_burnt.png` | 2258 × 1310 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `car_08.png` | 2258 × 1310 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd, scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 512 × 512 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_08.tscn, scenes/vehicle/garage/car_08.tscn |
| `wheel_burnt.png` | 512 × 512 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel_front.png` | 512 × 512 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 512 × 512 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 854 × 511 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_24.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_24.png` | 881 × 579 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 217 × 216 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_24.tscn, scenes/vehicle/garage/car_24.tscn |
| `wheel_front.png` | 217 × 216 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 217 × 216 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 740 × 336 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_07.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_07.png` | 740 × 336 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 88 × 88 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_07.tscn, scenes/vehicle/garage/car_07.tscn |
| `wheel_back.png` | 88 × 88 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_front.png` | 88 × 88 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 88 × 88 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 1791 × 800 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_04.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_04.png` | 1791 × 931 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 282 × 282 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd, scripts/vehicle/VehicleRegistry.gd |
| `wheel_back.png` | 282 × 282 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_04.tscn |
| `wheel_front.png` | 282 × 282 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_04.tscn |
| `wheel_rear.png` | 282 × 282 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 558 × 327 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_02.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_02.png` | 558 × 350 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 123 × 126 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd, scripts/vehicle/VehicleRegistry.gd |
| `wheel_back.png` | 123 × 126 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_02.tscn |
| `wheel_front.png` | 123 × 126 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_02.tscn |
| `wheel_rear.png` | 123 × 126 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 759 × 376 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_10.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_10.png` | 759 × 433 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 171 × 170 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_10.tscn, scenes/vehicle/garage/car_10.tscn |
| `wheel_front.png` | 171 × 170 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 171 × 170 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 470 × 259 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_01.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_01.png` | 470 × 319 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 105 × 105 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_01.tscn, scenes/vehicle/garage/car_01.tscn |
| `wheel_front.png` | 105 × 105 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 105 × 105 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 636 × 220 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_19.png` | 636 × 307 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 187 × 187 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd, scripts/vehicle/VehicleRegistry.gd |
| `wheel_back.png` | 187 × 187 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn |
| `wheel_front.png` | 187 × 187 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn |
| `wheel_rear.png` | 187 × 187 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 560 × 250 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_18.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_18.png` | 560 × 273 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 123 × 126 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd, scripts/vehicle/VehicleRegistry.gd |
| `wheel_back.png` | 123 × 126 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_18.tscn |
| `wheel_front.png` | 123 × 126 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_18.tscn |
| `wheel_rear.png` | 123 × 126 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 721 × 367 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_16.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_16.png` | 776 × 476 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 275 × 277 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_16.tscn, scenes/vehicle/garage/car_16.tscn |
| `wheel_front.png` | 275 × 277 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 275 × 277 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 830 × 973 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_06.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_06.png` | 830 × 1052 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 217 × 211 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd, scripts/vehicle/VehicleRegistry.gd |
| `wheel_back.png` | 217 × 211 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_06.tscn |
| `wheel_front.png` | 217 × 211 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_06.tscn |
| `wheel_rear.png` | 217 × 211 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 641 × 399 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_11.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_11.png` | 642 × 500 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 241 × 240 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd, scripts/vehicle/VehicleRegistry.gd |
| `wheel_back.png` | 240 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_11.tscn |
| `wheel_front.png` | 241 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 240 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `body.png` | 841 × 348 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_25.tscn, scripts/vehicle/VehicleRegistry.gd |
| `car_25.png` | 889 × 401 | PNG | Transparent (RGBA) | scripts/vehicle/VehicleRegistry.gd |
| `wheel.png` | 241 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_25.tscn, scenes/vehicle/garage/car_25.tscn |
| `wheel_front.png` | 241 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 241 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |

### Wheels & Tires (7 files)

| Asset Filename | Dimensions | Format | Transparency | Current Usage in Project |
|---|---|---|---|---|
| `wheel_front.png` | 240 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/garage/car_19.tscn, scenes/vehicle/garage/car_11.tscn |
| `wheel_rear.png` | 240 × 240 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/DuneBuggy.tscn |
| `wheel_tire_tread.png` | 240 × 240 | PNG | Transparent (RGBA) | Standard wheels library (runtime & future vehicle support) |
| `wheel_rim_hub.png` | 140 × 140 | PNG | Transparent (RGBA) | Standard wheels library (runtime & future vehicle support) |
| `wheel_rim_hub_aligned.png` | 240 × 240 | PNG | Transparent (RGBA) | Standard wheels library (runtime & future vehicle support) |
| `wheel_rim_hub_detailed.png` | 140 × 140 | PNG | Transparent (RGBA) | scenes/vehicle/BlueFlameTruck.tscn, scenes/vehicle/MonsterTruck.tscn |
| `wheel_rim_hub_detailed.svg` | Vector | SVG | Vector (Transparent) | Standard wheels library (runtime & future vehicle support) |

