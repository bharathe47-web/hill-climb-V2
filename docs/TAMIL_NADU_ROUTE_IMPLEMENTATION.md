# Tamil Nadu Indian Roads Route Implementation
## 13 Locations | 12 Road Segments | Complete South-to-North Journey

**Project:** Hill Climb V2 – Indian Roads Mode  
**Engine:** Godot 4.7  
**Branch:** `feature/hill-climb-complete-rebuild`  
**Author / Developer:** Joel (Lead Implementation)  
**Status:** VERIFIED COMPLETE  

---

## 1. Executive Summary

The Tamil Nadu Indian Roads route has been completely transformed into a continuous, visually rich, 13-location journey spanning from the southern tip of India at Kanyakumari to the northern Coromandel coast at Chennai.

The route conforms strictly to the exact sequence specified by the design requirements, featuring 13 distinct environment zones connected by 12 drivable road segments.

```
Kanyakumari (TN-01) → Nagercoil (TN-02) → Tirunelveli (TN-03) → Kovilpatti (TN-04) → 
Virudhunagar (TN-05) → Madurai (TN-06) → Melur (TN-07) → Tiruchirappalli (TN-08) → 
Perambalur (TN-09) → Villupuram (TN-10) → Tindivanam (TN-11) → Chengalpattu (TN-12) → Chennai (TN-13)
```

---

## 2. Route Architecture and Specifications

### A. Distance and Physical Calibration
- **Total Route Distance:** $1,200.0\text{ m}$ ($120,000\text{ px}$ in physics coordinates, at $1\text{ m} = 100\text{ px}$).
- **Segment Length:** Exactly $100.0\text{ m}$ ($10,000\text{ px}$) per connecting section.
- **Elevation System:** Procedural highway profile with rolling waves, smoothstep transitions, speed bumps, and gentle potholes.
- **Glass Skywalk Ocean Span:** Calibrated strictly within the coastal Kanyakumari zone ($25\text{ m} - 85\text{ m}$, $2,500\text{ px} - 8,500\text{ px}$), ensuring that inland sections (Kovilpatti, Virudhunagar, Madurai, etc.) reflect genuine terrestrial, agricultural, and urban topographies.

### B. Master Location Table

| ID | Location | Route Distance | Waypoint Type | Landmark Asset | Cultural / Regional Focus |
|---|---|---|---|---|---|
| **TN-01** | Kanyakumari | $0.0\text{ m}$ ($0\text{ px}$) | START | `tamil_nadu_thiruvalluvar_statue.png` | Cape Comorin, Triveni Sangam, Ocean Glass Bridge, Vivekananda Rock |
| **TN-02** | Nagercoil | $100.0\text{ m}$ ($10,000\text{ px}$) | LANDMARK | `tamil_nadu_padmanabhapuram_palace.png` | Padmanabhapuram Wooden Palace, Coconut Groves, Thirparappu Falls detour |
| **TN-03** | Tirunelveli | $200.0\text{ m}$ ($20,000\text{ px}$) | CHECKPOINT 1 | `tamil_nadu_nellaiappar_temple.png` | Nellaiappar Temple Gopuram, Musical Pillars, Courtallam Falls detour |
| **TN-04** | Kovilpatti | $300.0\text{ m}$ ($30,000\text{ px}$) | LANDMARK | `indian_roadside_dhaba_stall.png` | Kadalai Mittai Candy Junction, Palmyra Belt, Black Soil Basin |
| **TN-05** | Virudhunagar | $400.0\text{ m}$ ($40,000\text{ px}$) | LANDMARK | `tamil_nadu_srivilliputhur_andal_temple.png` | Srivilliputhur Andal Temple (192ft State Emblem Gopuram) |
| **TN-06** | Madurai | $500.0\text{ m}$ ($50,000\text{ px}$) | CHECKPOINT 2 | `tamil_nadu_meenakshi_gopuram_vector.png` | Meenakshi Amman Temple, Thirumalai Nayak Palace, Flower Bazaars |
| **TN-07** | Melur | $600.0\text{ m}$ ($60,000\text{ px}$) | LANDMARK | `tamil_nadu_samanar_hills.png` | Samanar Malai Ancient Jain Caves, Granite Hills Transition |
| **TN-08** | Tiruchirappalli | $700.0\text{ m}$ ($70,000\text{ px}$) | CHECKPOINT 3 | `tamil_nadu_rockfort_trichy.png` | Billion-Year-Old Rockfort, Srirangam Ranganathaswamy Island Gopuram |
| **TN-09** | Perambalur | $800.0\text{ m}$ ($80,000\text{ px}$) | LANDMARK | `indian_road_sign_nh44.png` | Agricultural Maize Corridor, Ammonite Petrified Wood Fossil Basin |
| **TN-10** | Villupuram | $900.0\text{ m}$ ($90,000\text{ px}$) | CHECKPOINT 4 | `tamil_nadu_villupuram_gopuram.png` | Grand Southern Trunk (NH45), Whitewashed Dravidian Gopuram |
| **TN-11** | Tindivanam | $1,000.0\text{ m}$ ($100,000\text{ px}$) | LANDMARK | `indian_roadside_dhaba_stall.png` | Tamarind Groves, Puducherry Coastal Junction, Highway Dhabas |
| **TN-12** | Chengalpattu | $1,100.0\text{ m}$ ($110,000\text{ px}$) | CHECKPOINT 5 | `tamil_nadu_mahabalipuram_shore_temple.png` | Mahabalipuram Shore Temple Gateway, Lakes, Suburban Transition |
| **TN-13** | Chennai | $1,200.0\text{ m}$ ($120,000\text{ px}$) | DESTINATION | `tamil_nadu_san_thome_basilica.png` | San Thome Basilica, Fort St. George, Marina Lighthouse, Finish Arch |

---

## 3. Core File Modifications

1. `scripts/modes/indian_roads/RouteRegistry.gd`
   - Refactored `get_tamil_nadu_route()` to return all 13 ordered stops with unique IDs (`tn_01_kanyakumari`..`tn_13_chennai`), titles, subtitles, milestone distances, coin rewards, and asset paths.
   - Set `total_distance_m = 1200.0`.
2. `scripts/modes/indian_roads/RouteMapOverlay.gd`
   - Defined `STATE_ROUTE_GEOMETRY["tamil_nadu"]` containing all 13 locations with accurate normalized coordinates $(x, y)$ tracing the genuine NH44 / NH45 corridor from $(0.42, 0.94)$ up to $(0.78, 0.16)$.
   - Each pin displays numbered markers (1 to 13) and geographical labels.
3. `scripts/modes/indian_roads/RoadsideLandmarkRegistry.gd`
   - Registered 20 curated attractions and regional detour features for `tamil_nadu` without collisions or overlapping transforms.
4. `scripts/modes/indian_roads/LandmarkCatalogueData.gd`
   - Added rich historical, cultural, and factual narratives for all 13 locations and monuments to supply the dedicated bottom information card.
5. `scripts/modes/indian_roads/KanyakumariGlassBridge.gd` & `IndianRoadTerrain.gd` & `IndianRoadTerrainV2.gd`
   - Re-anchored the Glass Bridge elevation profile to $25\text{ m} - 85\text{ m}$ ($2,500\text{ px} - 8,500\text{ px}$) within Kanyakumari, preserving the ocean aesthetic where Vivekananda and Thiruvalluvar reside, while allowing inland towns (Kovilpatti, Virudhunagar, etc.) to feature authentic agricultural landscapes.
   - Implemented zone-based environment prop filtering in `IndianRoadTerrainV2.gd` for distinct regional scenery across all 13 zones.
6. `scripts/modes/indian_roads/FinishArch.gd` & `FinishArchV2.gd`
   - Configured the destination arch to prominently display: `CHENNAI — JOURNEY COMPLETED`.
7. `scripts/modes/indian_roads/IndianRoadsController.gd`
   - Connected checkpoint clears and destination arrival to `LandmarkCatalogueData` and `hud.show_landmark_info()` so every passed location presents its cultural history card.

---

## 4. Verification and Quality Assurance

- **Automated Tests:** `tests/test_tamil_nadu_13_locations.gd` executes 8 comprehensive verification checks (route loading, exact sequence, distance monotonicity, route map overlay geometry, catalogue registry, asset disk existence, roadside registry, and procedural terrain generation). All 8/8 tests pass with zero errors.
- **In-Engine Screenshots:** Generated 14 real runtime captures spanning all 13 locations and the interactive Route Map Overlay via `scripts/capture_tamil_nadu_13_locations_evidence.gd`.
