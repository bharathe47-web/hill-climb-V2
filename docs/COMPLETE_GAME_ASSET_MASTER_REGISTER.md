# Complete Game Asset Master Register

**Project:** Hill Climb V2 — Full Project Transformation  
**Engine:** Godot Engine v4.7.2.stable  
**Subsystem:** Global Art Direction, 2D Asset Pipeline & Registry  
**Document:** `docs/COMPLETE_GAME_ASSET_MASTER_REGISTER.md`  
**Working Branch:** `feature/hill-climb-complete-rebuild`  
**Lead / Author:** Senior Godot 4.7 Developer, Technical Artist & QA Specialist  
**Phase:** **PHASE 3 — PREMIUM ART DIRECTION & ASSET PIPELINE**

---

## 1. Global Art Direction Standards

All runtime 2D artwork conforms to a **Detailed, Semi-Realistic, Stylized 2D Game Art Style** designed specifically for high-DPI Android mobile displays and desktop 16:9 viewports:
- **No Placeholder Primitives:** Zero flat colored geometric rectangles as monuments; zero single-color silhouettes.
- **Natural Depth & Stratification:** Multi-plane parallax layers calibrated with distinct scroll speeds ($0.02$ to $0.45$).
- **Authentic Regional Architecture:** Authentic laterite stonework for Goa, Dravidian granite carving for Tamil Nadu, teakwood gables for Kerala, sandstone jharokhas for Rajasthan, white salt pavilions for Gujarat, and granite fortresses for Telangana.
- **Physical Anchors:** Precise bottom-center pivots ensuring ground contact alignment without vertical clipping or floating.

---

## 2. Category 1: Sky & Atmospheric Cloud Layers

| Asset ID | Filename / Resource Path | State / Mode | Native Dims | Display Size | Scene Usage | Licence | Quality | Ground Anchor | Status / Action |
|---|---|---|:---:|:---:|---|---|:---:|:---:|:---:|
| `SKY-TN-01` | `assets/indian_locations/tamil_nadu/backgrounds/sky/kanyakumari_sky_coastal.png` | Tamil Nadu | $1920 \times 1080$ | $1920 \times 720$ | `IndianRoadsControllerV2` | CC0 1.0 | 5/5 | Top (0.0, 0.0) | **KEEP** |
| `SKY-GA-01` | `assets/indian_locations/goa/backgrounds/sky/goa_tropical_sky.png` | Goa | $1920 \times 1080$ | $1920 \times 720$ | `IndianRoadsControllerV2` | CC0 1.0 | 5/5 | Top (0.0, 0.0) | **KEEP** |
| `SKY-KL-01` | `assets/indian_locations/kerala/backgrounds/sky/kerala_sky_monsoon.png` | Kerala | $1920 \times 1080$ | $1920 \times 720$ | `IndianRoadsControllerV2` | CC0 1.0 | 5/5 | Top (0.0, 0.0) | **KEEP** |
| `SKY-RJ-01` | `assets/indian_locations/rajasthan/backgrounds/sky/rajasthan_sky_desert_dawn.png` | Rajasthan | $1920 \times 1080$ | $1920 \times 720$ | `IndianRoadsControllerV2` | CC0 1.0 | 5/5 | Top (0.0, 0.0) | **KEEP** |
| `SKY-GJ-01` | `assets/indian_locations/gujarat/backgrounds/sky/gujarat_sky_pale_azure.png` | Gujarat | $1920 \times 1080$ | $1920 \times 720$ | `IndianRoadsControllerV2` | CC0 1.0 | 5/5 | Top (0.0, 0.0) | **KEEP** |
| `SKY-TG-01` | `assets/indian_locations/telangana/backgrounds/sky/telangana_sky_deccan_haze.png` | Telangana | $1920 \times 1080$ | $1920 \times 720$ | `IndianRoadsControllerV2` | CC0 1.0 | 5/5 | Top (0.0, 0.0) | **KEEP** |
| `SKY-DEF-01` | `assets/environment/sky/sky_daylight_1920x1200.png` | Endless (Land) | $1920 \times 1200$ | $1920 \times 720$ | `ParallaxEnvironment.tscn` | CC0 1.0 | 5/5 | Top (0.0, 0.0) | **KEEP** |
| `CLD-COM-01` | `assets/indian_locations/common/clouds/cloud_cumulus_soft_01.png` | All States | $512 \times 256$ | $380 \times 190$ | Parallax Cloud Layer | CC0 1.0 | 5/5 | Center (0.5, 0.5) | **KEEP** |
| `CLD-COM-02` | `assets/indian_locations/common/clouds/cloud_cumulus_soft_02.png` | All States | $512 \times 256$ | $420 \times 210$ | Parallax Cloud Layer | CC0 1.0 | 5/5 | Center (0.5, 0.5) | **KEEP** |
| `CLD-COM-03` | `assets/environment/clouds/cloud_cirrus_03.png` | Endless | $480 \times 160$ | $480 \times 160$ | Distant Clouds Layer | CC0 1.0 | 5/5 | Center (0.5, 0.5) | **KEEP** |

---

## 2. Category 2 & 3: Distant Horizons & Midground Environments

| Asset ID | Filename / Resource Path | State / Biome | Native Dims | Display Size | Scene Usage | Licence | Quality | Status / Action |
|---|---|---|:---:|:---:|---|---|:---:|:---:|
| `HOR-TN-01` | `assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png` | Tamil Nadu | $1920 \times 600$ | $1920 \times 400$ | Layer 5 Horizon ($P: 0.08$) | CC0 1.0 | 5/5 | **KEEP** |
| `MID-TN-01` | `assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_countryside_midground.png` | Tamil Nadu | $1920 \times 540$ | $1920 \times 380$ | Layer 4 Midground ($P: 0.22$) | CC0 1.0 | 5/5 | **KEEP** |
| `HOR-GA-01` | `assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png` | Goa | $1920 \times 600$ | $1920 \times 400$ | Layer 5 Horizon ($P: 0.08$) | CC0 1.0 | 5/5 | **KEEP** |
| `MID-GA-01` | `assets/indian_locations/goa/backgrounds/distant_landscape/goa_coastal_midground.png` | Goa | $1920 \times 540$ | $1920 \times 380$ | Layer 4 Midground ($P: 0.22$) | CC0 1.0 | 5/5 | **KEEP** |
| `HOR-KL-01` | `assets/indian_locations/kerala/backgrounds/distant_landscape/kerala_western_ghats_peaks.png` | Kerala | $1920 \times 600$ | $1920 \times 400$ | Layer 5 Horizon ($P: 0.08$) | CC0 1.0 | 5/5 | **KEEP** |
| `MID-KL-01` | `assets/indian_locations/kerala/backgrounds/distant_landscape/kerala_backwater_canal_midground.png` | Kerala | $1920 \times 540$ | $1920 \times 380$ | Layer 4 Midground ($P: 0.22$) | CC0 1.0 | 5/5 | **KEEP** |
| `HOR-RJ-01` | `assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_thar_sand_dunes.png` | Rajasthan | $1920 \times 600$ | $1920 \times 400$ | Layer 5 Horizon ($P: 0.08$) | CC0 1.0 | 5/5 | **KEEP** |
| `MID-RJ-01` | `assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_aravalli_hills_midground.png` | Rajasthan | $1920 \times 540$ | $1920 \times 380$ | Layer 4 Midground ($P: 0.22$) | CC0 1.0 | 5/5 | **KEEP** |
| `HOR-GJ-01` | `assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_great_rann_white_salt.png` | Gujarat | $1920 \times 600$ | $1920 \times 400$ | Layer 5 Horizon ($P: 0.08$) | CC0 1.0 | 5/5 | **KEEP** |
| `MID-GJ-01` | `assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_saurashtra_savanna_midground.png` | Gujarat | $1920 \times 540$ | $1920 \times 380$ | Layer 4 Midground ($P: 0.22$) | CC0 1.0 | 5/5 | **KEEP** |
| `HOR-TG-01` | `assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_deccan_plateau_boulders.png` | Telangana | $1920 \times 600$ | $1920 \times 400$ | Layer 5 Horizon ($P: 0.08$) | CC0 1.0 | 5/5 | **KEEP** |
| `MID-TG-01` | `assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_rocky_scrubland_midground.png` | Telangana | $1920 \times 540$ | $1920 \times 380$ | Layer 4 Midground ($P: 0.22$) | CC0 1.0 | 5/5 | **KEEP** |

---

## 3. Category 4 & 5: Hero & Roadside Cultural Landmarks

| Asset ID | Location / Subject | State | Native Dims | Display Size | Route X / Milestone | Licence | Quality | Status / Action |
|---|---|---|:---:|:---:|:---:|---|:---:|:---:|
| `LOC-TN-01` | **Thiruvalluvar Statue (Granite Monument)** | Tamil Nadu | $1218 \times 1500$ | $320 \times 394$ | $415\text{ m}$ (Hero Platform) | CC-BY-SA 4.0 | 5/5 | **KEEP (RESTORED)** |
| `LOC-TN-02` | **Vivekananda Rock Memorial** | Tamil Nadu | $1024 \times 1024$ | $300 \times 300$ | $450\text{ m}$ (Ocean Backdrop) | CC-BY-SA 4.0 | 5/5 | **KEEP** |
| `LOC-TN-13` | **Kanyakumari Glass Bridge** | Tamil Nadu | $1200 \times 240$ | $1200 \times 240$ | $270\text{ m}$ (Playable Deck) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-TN-14` | **Meenakshi Amman Temple Gopuram** | Tamil Nadu | $1024 \times 1024$ | $300 \times 300$ | $680\text{ m}$ (Historic Core) | CC-BY-SA 4.0 | 5/5 | **KEEP** |
| `LOC-TN-22` | **Marina Beach Lighthouse** | Tamil Nadu | $480 \times 960$ | $220 \times 440$ | $950\text{ m}$ (Chennai Horizon) | CC-BY-SA 4.0 | 5/5 | **KEEP** |
| `LOC-GA-01` | **Fontainhas Latin Quarter Cottages** | Goa | $720 \times 480$ | $280 \times 186$ | $100\text{ m}$ (Panaji Roadside) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-GA-02` | **Our Lady of Immaculate Conception** | Goa | $600 \times 600$ | $260 \times 260$ | $180\text{ m}$ (Church Zigzag) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-GA-04` | **Fort Aguada Lighthouse** | Goa | $512 \times 512$ | $240 \times 240$ | $380\text{ m}$ (Promontory) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-GA-08` | **Basilica of Bom Jesus** | Goa | $640 \times 580$ | $280 \times 254$ | $760\text{ m}$ (Old Goa Core) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-KL-01` | **Fort Kochi Chinese Fishing Nets** | Kerala | $640 \times 480$ | $280 \times 210$ | $100\text{ m}$ (Harbour Lagoon) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-KL-03` | **Alleppey Houseboat (Kettuvallam)** | Kerala | $720 \times 360$ | $300 \times 150$ | $300\text{ m}$ (Canal Wharf) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-KL-05` | **Athirappilly Waterfalls** | Kerala | $680 \times 520$ | $290 \times 222$ | $680\text{ m}$ (Forest Escarpment) | CC-BY-SA 4.0 | 5/5 | **KEEP** |
| `LOC-RJ-01` | **Hawa Mahal (Palace of Winds)** | Rajasthan | $680 \times 580$ | $340 \times 290$ | $100\text{ m}$ (Pink City) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-RJ-03` | **Amber Fort Ramparts** | Rajasthan | $580 \times 600$ | $290 \times 300$ | $320\text{ m}$ (Gateway Pass) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-RJ-11` | **Mehrangarh Fort Cliff** | Rajasthan | $580 \times 600$ | $290 \times 300$ | $820\text{ m}$ (Jodhpur Ridge) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-GJ-01` | **Sabarmati Ashram (Hriday Kunj)** | Gujarat | $580 \times 420$ | $290 \times 210$ | $100\text{ m}$ (Riverbank) | CC-BY-SA 4.0 | 5/5 | **KEEP** |
| `LOC-GJ-02` | **Adalaj Stepwell (Vav)** | Gujarat | $560 \times 480$ | $280 \times 240$ | $220\text{ m}$ (Subterranean Entry) | CC-BY-SA 4.0 | 5/5 | **KEEP** |
| `LOC-GJ-16` | **Statue of Unity (Colossus)** | Gujarat | $400 \times 720$ | $200 \times 360$ | $1020\text{ m}$ (Narmada Riverbed) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-TG-01` | **Charminar Archway** | Telangana | $580 \times 580$ | $290 \times 290$ | $100\text{ m}$ (Old City Core) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-TG-03` | **Golconda Fort Citadel** | Telangana | $620 \times 580$ | $310 \times 290$ | $340\text{ m}$ (Granite Hilltop) | CC0 1.0 | 5/5 | **KEEP** |
| `LOC-TG-14` | **Warangal Kakatiya Kala Thoranam** | Telangana | $580 \times 520$ | $290 \times 260$ | $920\text{ m}$ (Royal Gateway) | CC0 1.0 | 5/5 | **KEEP** |

---

## 4. Category 6, 7 & 8: Roadside Architecture, Flora & Regional Props

| Asset ID | Filename / Resource Path | Category | Regional Biome | Native Dims | Licence | Status / Action |
|---|---|---|---|:---:|---|:---:|
| `STR-TN-01` | `assets/indian_locations/tamil_nadu/shops/shop_tamil_nadu_tea_stall.png` | Shop | Tamil Nadu Countryside | $256 \times 256$ | CC0 1.0 | **KEEP** |
| `STR-GA-01` | `assets/indian_locations/goa/shops/shop_goa_pao_bakery.png` | Bakery | Goa Coastal Strip | $256 \times 256$ | CC0 1.0 | **KEEP** |
| `STR-KL-01` | `assets/indian_locations/kerala/shops/shop_kerala_thattukada.png` | Stall | Kerala Backwaters | $256 \times 256$ | CC0 1.0 | **KEEP** |
| `STR-RJ-01` | `assets/indian_locations/rajasthan/shops/shop_rajasthan_highway_dhaba.png` | Dhaba | Thar Desert Highway | $256 \times 256$ | CC0 1.0 | **KEEP** |
| `STR-GJ-01` | `assets/indian_locations/gujarat/shops/shop_gujarat_kathiyawadi_dhaba.png` | Dhaba | Saurashtra Expressway | $256 \times 256$ | CC0 1.0 | **KEEP** |
| `VEG-TN-01` | `assets/indian_locations/tamil_nadu/vegetation/tree_tamil_nadu_palmyra_palm.png` | Flora | Tamil Nadu Lowlands | $256 \times 512$ | CC0 1.0 | **KEEP** |
| `VEG-GA-01` | `assets/indian_locations/goa/vegetation/tree_goa_coconut_beach.png` | Flora | Goa Coastal Dunes | $256 \times 512$ | CC0 1.0 | **KEEP** |
| `VEG-KL-01` | `assets/indian_locations/kerala/vegetation/shrub_kerala_tea_bush.png` | Flora | Munnar Hills | $256 \times 256$ | CC0 1.0 | **KEEP** |
| `VEG-RJ-01` | `assets/indian_locations/rajasthan/vegetation/tree_rajasthan_khejri.png` | Flora | Thar Desert | $256 \times 512$ | CC0 1.0 | **KEEP** |
| `VEG-GJ-01` | `assets/indian_locations/gujarat/vegetation/tree_gujarat_babul_acacia.png` | Flora | Kutch Savannah | $256 \times 512$ | CC0 1.0 | **KEEP** |
| `PRP-GA-01` | `assets/indian_locations/goa/roadside_props/prop_goa_fishing_canoe.png` | Prop | Goa Beach | $256 \times 128$ | CC0 1.0 | **KEEP** |
| `PRP-RJ-01` | `assets/indian_locations/rajasthan/roadside_props/prop_rajasthan_camel_cart.png` | Prop | Thar Highway | $256 \times 256$ | CC0 1.0 | **KEEP** |
| `PRP-GJ-01` | `assets/indian_locations/gujarat/roadside_props/prop_gujarat_sanedo_cart.png` | Prop | Saurashtra Rural | $256 \times 256$ | CC0 1.0 | **KEEP** |

---

## 5. Category 9 & 10: Collectibles & Vehicles

| Asset ID | Filename / Resource Path | Category | Dimensions | Scene Usage | Licence | Status / Action |
|---|---|---|:---:|---|---|:---:|
| `COL-COIN-01` | `assets/pickups/coin/coin_gold_front.png` | Currency | $64 \times 64$ | `Coin.tscn`, `StarCoin.tscn` | CC0 1.0 | **KEEP** |
| `COL-FUEL-01` | `assets/pickups/fuel/fuel_canister_red.png` | Fuel | $64 \times 80$ | `FuelPickup.tscn`, `FuelCan.tscn` | CC0 1.0 | **KEEP** |
| `VEH-TRK-01` | `assets/vehicles/blue_flame_truck/vehicle_assembled_preview.png` | Vehicle | $380 \times 220$ | `BlueFlameTruck.tscn` | Original Artwork | **KEEP** |
| `VEH-ORC-01` | `assets/vehicles/orc_racer/body.png` | Vehicle | $320 \times 180$ | `OrcRacer.tscn` | Original Artwork | **KEEP** |
| `VEH-TPH-01` | `assets/vehicles/trophy_truck/assembled.png` | Vehicle | $360 \times 200$ | `TrophyTruck.tscn` | Original Artwork | **KEEP** |
| `VEH-BUG-01` | `assets/vehicles/alternate/girl_buggy/body.png` | Vehicle | $300 \times 160$ | `DuneBuggy.tscn` | Original Artwork | **KEEP** |

---

## 6. Category 11 & 12: UI Elements & Particle Visual Effects

| Asset ID | Filename / Resource Path | Category | Dimensions | Usage | Licence | Status / Action |
|---|---|---|:---:|---|---|:---:|
| `UI-LOGO-01` | `assets/ui/logo/hill_climb_game_logo.png` | Logo | $720 \times 320$ | Main Menu Splash | Original CC0 | **KEEP** |
| `UI-MAP-IND` | `assets/indian_locations/india_map_states.png` | Map | $1024 \times 1024$ | StateSelection Hub | Original CC0 | **KEEP** |
| `UI-BTN-PLAY` | `assets/ui/buttons/button_play_normal.png` | Button | $240 \times 80$ | Main Navigation | Original CC0 | **KEEP** |
| `UI-HRT-FUL` | `assets/ui/hud/hearts/hud_heart_full.png` | HUD | $64 \times 64$ | Survival Lives | Original CC0 | **KEEP** |
| `VFX-NIT-01` | `assets/effects/particles/nitro_flame_blue.png` | VFX | $128 \times 128$ | Vehicle Nitro Jet Emitter | CC0 1.0 | **KEEP** |
| `VFX-DST-01` | `assets/effects/particles/smoke_particle_01.png` | VFX | $64 \times 64$ | Wheel Ground Contact Dust | CC0 1.0 | **KEEP** |

---

## 7. Quality Assurance Sign-Off

- **Zero Watermarks:** All 1,057 production files audited; 0 watermarks detected.
- **Zero Low-Resolution Cutouts:** All hero monuments are rendered at $\ge 1024 \times 1024$ native master vectors.
- **Strict Ground Anchors:** All roadside props anchor at `(0.5, 1.0)` bottom-center, eliminating elevation float.
