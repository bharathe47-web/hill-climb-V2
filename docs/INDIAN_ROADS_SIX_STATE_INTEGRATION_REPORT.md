# Indian Roads Six-State Integration & Architecture Report

**Author:** Joel (Senior Godot 4.7 Architect & Technical Artist)  
**Date:** November 14, 2026  
**Document:** `docs/INDIAN_ROADS_SIX_STATE_INTEGRATION_REPORT.md`  
**Target:** Version 1 Indian Roads Highway Mode (`scenes/modes/indian_roads/`, `scripts/modes/indian_roads/`)

---

## 1. Executive Summary

All six Version 1 Indian State Routes have been successfully integrated into a cohesive, modular highway driving experience powered by `IndianRoadsControllerV2` and `IndianRoadTerrainV2`. 

Each state features a visually unique, culturally authentic environment while sharing the robust, unified driving physics, vehicle registry, camera system, and progression persistence.

---

## 2. Six-State Technical & Environmental Specification

### 1. Tamil Nadu (`tamil_nadu`)
- **Route Corridor:** Kanyakumari → Madurai → Chennai (1,800m)
- **Environment Theme:** Coastal plains transitioning to Dravidian heritage centers.
- **Sky & Parallax:**
  - Sky: `res://assets/indian_locations/tamil_nadu/kanyakumari/backgrounds/sky/kanyakumari_sky_coastal.png`
  - Distant Horizon: `res://assets/indian_locations/tamil_nadu/kanyakumari/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png`
  - Village Layer: `res://assets/indian_locations/tamil_nadu/kanyakumari/backgrounds/village/tamil_village_row.png`
- **Terrain Tuning:** `road_surface_color`: `#2e333b`, `shoulder_color`: `#a67047` (South Indian red laterite), `stripe_color`: `#fae032` (Yellow), `wave_amp`: 1.0, `freq_mult`: 1.0.
- **Waypoints & Landmarks:**
  - 0m (START): `Kanyakumari Pier` (Unobstructed coastal horizon)
  - 350m (LANDMARK): `Thiruvalluvar Statue` & `Vivekananda Rock Memorial`
  - 750m (CHECKPOINT): `Madurai Checkpoint` (`meenakshi_amman_temple.png`)
  - 1150m (LANDMARK): `NH44 Highway Junction` (`dhaba_stall.png`)
  - 1450m (CHECKPOINT): `Coastal Toll Plaza` (`checkpoint_gate.png`)
  - 1800m (DESTINATION): `Chennai Marina Beach` (`marina_lighthouse.png` + `chennai_destination_arch.png`)

### 2. Goa (`goa`)
- **Route Corridor:** Panaji → Margao (1,600m)
- **Environment Theme:** Sun-drenched Indo-Portuguese coastal cruise.
- **Sky & Parallax:**
  - Sky: `res://assets/indian_locations/goa/backgrounds/sky/goa_tropical_sky.png`
  - Distant Ghats: `res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png` (Lush green rainforest, 0% snow)
  - Village Layer: `res://assets/indian_locations/goa/backgrounds/village/goa_portuguese_village_row.png` (Fontainhas Latin architecture)
- **Terrain Tuning:** `road_surface_color`: `#383b42`, `shoulder_color`: `#d9bf80` (Golden coastal sand), `stripe_color`: `#ffffff` (White), `wave_amp`: 0.8, `freq_mult`: 0.85.
- **Waypoints & Landmarks:**
  - 0m (START): `Panaji Waterfront` (`mandovi_riverfront.png`)
  - 400m (LANDMARK): `Calangute Beach Road` (`calangute_beach.png`)
  - 800m (CHECKPOINT): `Mandovi Bridge Toll` (`checkpoint_toll_booth.png`)
  - 1200m (LANDMARK): `Old Goa Heritage Site` (`basilica_of_bom_jesus.png`)
  - 1600m (DESTINATION): `Margao City` (`holy_spirit_church.png` + `finish_arch.png`)

### 3. Kerala (`kerala`)
- **Route Corridor:** Kochi → Munnar (2,000m)
- **Environment Theme:** Western Ghats mountain ascent through misty tea plantations and palm backwaters.
- **Sky & Parallax:** Coastal blue sky with lush Sahyadri mountain backdrops.
- **Terrain Tuning:** `road_surface_color`: `#292e33`, `shoulder_color`: `#734d29` (Western Ghats wet humus), `stripe_color`: `#fae032`, `wave_amp`: 1.25, `freq_mult`: 1.15 (Challenging winding hills).
- **Waypoints & Landmarks:**
  - 0m (START): `Kochi Harbour`
  - 500m (LANDMARK): `Alleppey Backwaters` (`alleppey_houseboat_backwaters.png`)
  - 1000m (CHECKPOINT): `Western Ghats Checkpoint` (`checkpoint_gate.png`)
  - 1500m (LANDMARK): `Munnar Tea Gardens` (`munnar_tea_plantations.png`)
  - 2000m (DESTINATION): `Munnar Hill Station` (Finish Arch)

### 4. Rajasthan (`rajasthan`)
- **Route Corridor:** Jaipur → Jaisalmer (2,200m)
- **Environment Theme:** Sun-baked desert speedway across the Thar sands.
- **Sky & Parallax:**
  - Distant Horizon: `res://assets/indian_roads/indian_parallax_thar_desert.png` (Golden sand dunes)
- **Terrain Tuning:** `road_surface_color`: `#424547`, `shoulder_color`: `#dbb870` (Thar Desert golden sand), `stripe_color`: `#f2cc26`, `wave_amp`: 0.65, `freq_mult`: 0.65 (Long rolling desert stretches).
- **Waypoints & Landmarks:**
  - 0m (START): `Jaipur Pink City` (Hawa Mahal Boulevard)
  - 550m (LANDMARK): `Amber Fort Gateway` (`amber_fort_gateway.png`)
  - 1100m (CHECKPOINT): `Thar Expressway Toll` (`checkpoint_gate.png`)
  - 1650m (LANDMARK): `Mehrangarh Fort Vista` (`mehrangarh_fort_vista.png`)
  - 2200m (DESTINATION): `Jaisalmer Golden Fort` (`jaisalmer_golden_fort.png` + Finish Arch)

### 5. Gujarat (`gujarat`)
- **Route Corridor:** Ahmedabad → Rann of Kutch (2,000m)
- **Environment Theme:** Salt-crusted flats and Saurashtra oasis landscapes.
- **Sky & Parallax:**
  - Distant Horizon: `res://assets/indian_roads/indian_parallax_rann_kutch.png` (Endless white salt desert)
- **Terrain Tuning:** `road_surface_color`: `#36383d`, `shoulder_color`: `#c7c2b8` (Rann salt-crusted pale clay), `stripe_color`: `#fae032`, `wave_amp`: 0.60, `freq_mult`: 0.75.
- **Waypoints & Landmarks:**
  - 0m (START): `Ahmedabad Riverfront` (Sabarmati promenade)
  - 500m (LANDMARK): `Saurashtra Highway Oasis` (`saurashtra_rann_oasis.png`)
  - 1000m (CHECKPOINT): `Kutch Border Gate` (`checkpoint_gate.png`)
  - 1500m (LANDMARK): `Flamingo Sanctuary Pass` (`flamingo_sanctuary_pass.png`)
  - 2000m (DESTINATION): `White Desert Rann of Kutch` (`white_desert_rann_kutch.png` + Finish Arch)

### 6. Telangana (`telangana`)
- **Route Corridor:** Hyderabad → Warangal (1,800m)
- **Environment Theme:** Deccan plateau granite rolling hills and Kakatiya dynasty monuments.
- **Sky & Parallax:**
  - Distant Horizon: `res://assets/indian_roads/indian_parallax_deccan_plateau.png` (Deccan rocky balancing boulders)
- **Terrain Tuning:** `road_surface_color`: `#33363b`, `shoulder_color`: `#857566` (Granite grit & red soil), `stripe_color`: `#fae032`, `wave_amp`: 1.10, `freq_mult`: 1.05.
- **Waypoints & Landmarks:**
  - 0m (START): `Hyderabad Charminar`
  - 450m (LANDMARK): `Golconda Fort Bastion` (`golconda_fort_bastion.png`)
  - 900m (CHECKPOINT): `Outer Ring Road Toll` (`checkpoint_gate.png`)
  - 1350m (LANDMARK): `Kakatiya Dynasty Torana` (`kakatiya_dynasty_torana.png`)
  - 1800m (DESTINATION): `Thousand Pillar Temple` (`thousand_pillar_temple.png` + Finish Arch)

---

## 3. Resolution of the 3 Broken States

1. **Sequential Lock Bypass Seam:** Implemented `RouteRegistry.dev_unlock_all_routes` flag. When active, all states are selectable without requiring prior route completion, unblocking QA and level review.
2. **Elimination of Placeholder Sprites:** Created dedicated high-res 2D assets for all milestones, ensuring zero generic tree/dhaba/milestone fallbacks in States 3–6.
3. **Save Compatibility:** Standard player progression persists seamlessly via `SaveManager.load_save()` and `RouteRegistry.complete_route(state_id)`.
