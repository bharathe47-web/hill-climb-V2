# Indian Roads — Route Optimization & Distance Calibration Report
**Developer:** Joel (Indian Roads, HUD, Pickups, Routes, Level Design, QA)  
**Project:** Hill Climb V2 (Godot 4.7)  
**Branch:** `feature/joel-roads-obstacles`  
**Date:** November 17, 2026  

---

## 1. Executive Summary

In response to player feedback that previous routes were overly long (1600m – 2200m), causing repetitive fatigue and excessive driving times without proportional progression rewards, all six state routes in the Indian Roads mode have been recalibrated to compact, tightly paced journeys between **950m and 1200m**.

This reduction eliminates dead zones while preserving the full narrative progression, every famous roadside landmark, intermediate toll checkpoints, dhaba rest stops, and grand destination finish arches.

---

## 2. Before vs. After Distance Calibration

| State Route | Start City | Destination City | Previous Distance | Calibrated Distance | Reduction | Average Pacing |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Tamil Nadu** | Kanyakumari | Chennai | 1800 m | **1100 m** | -38.9% | Glass bridge at 270m, Thiruvalluvar at 415m, Madurai Toll at 600m, Dhaba at 850m, Marina at 1100m |
| **Goa** | Panaji | Margao | 1600 m | **950 m** | -40.6% | Calangute at 250m, Mandovi Toll at 500m, Old Goa at 750m, Margao at 950m |
| **Kerala** | Kochi | Munnar | 2000 m | **1050 m** | -47.5% | Backwaters at 280m, Ghats Toll at 550m, Munnar Tea at 820m, Finish at 1050m |
| **Rajasthan** | Jaipur | Jaisalmer | 2200 m | **1200 m** | -45.5% | Amber Fort at 300m, Thar Toll at 600m, Mehrangarh at 900m, Jaisalmer at 1200m |
| **Gujarat** | Ahmedabad | Rann of Kutch | 2000 m | **1150 m** | -42.5% | Saurashtra Dhaba at 300m, Kutch Toll at 600m, Flamingo Pass at 880m, Rann at 1150m |
| **Telangana** | Hyderabad | Warangal | 1800 m | **1000 m** | -44.4% | Golconda Fort at 260m, ORR Toll at 520m, Kakatiya Gate at 780m, Warangal at 1000m |
| **AVERAGE** | — | — | **1900 m** | **1075 m** | **-43.4%** | **Balanced 2.5 – 3.5 minute mobile session duration** |

---

## 3. Waypoint & Landmark Calibration Details

### 3.1 Tamil Nadu (1100m Total Distance)
- `0.0m` — **Kanyakumari Coast** (Start Point, Triveni Sangam)
- `90.0m` — **Gandhi Memorial Mandapam** (Roadside monument)
- `180.0m` — **Kumari Amman Temple** (Coastal temple)
- `270.0m` — **Kanyakumari Glass Bridge** (Playable oceanic driving bridge structure)
- `340.0m` — **Vivekananda Rock Memorial** (Offshore background monument)
- `415.0m` — **Thiruvalluvar Statue** (Colossal hero landmark)
- `510.0m` — **Vattakottai Coastal Fort** (Coastal ramparts)
- `570.0m` — **Kamarajar Memorial Mandapam** (Shoreline park)
- `600.0m` — **Madurai Checkpoint Toll Plaza** (Toll Gate, +120 Coins reward)
- `680.0m` — **Meenakshi Amman Temple** (Towering gopuram)
- `760.0m` — **Thirumalai Nayakkar Mahal** (Royal palace)
- `850.0m` — **NH44 Highway Junction Dhaba** (Traditional rest stop)
- `950.0m` — **Kapaleeshwarar Temple** (Urban Mylapore temple)
- `1030.0m` — **Marina Beach Lighthouse** (Coastal beacon)
- `1100.0m` — **Chennai Marina Beach Finish Arch** (Destination victory)

### 3.2 Goa (950m Total Distance)
- `0.0m` — **Panaji Waterfront** (Departure point)
- `100.0m` — **Fontainhas Latin Quarter** (Colourful heritage architecture)
- `180.0m` — **Our Lady of Immaculate Conception** (Church square)
- `250.0m` — **Calangute Beach Road** (Coastal promenade)
- `380.0m` — **Fort Aguada & 1864 Lighthouse** (Coastal bluff)
- `450.0m` — **Chapora Red Laterite Fort** (Hilltop bastion)
- `500.0m` — **Mandovi Bridge Toll Plaza** (Checkpoint 1, +120 Coins reward)
- `600.0m` — **Se Cathedral** (Old Goa UNESCO heritage)
- `680.0m` — **Church of St Francis of Assisi** (Historic church)
- `760.0m` — **Basilica of Bom Jesus** (Old Goa landmark)
- `870.0m` — **Holy Spirit Church** (Margao square)
- `950.0m` — **Margao City Finish Arch** (South Goa finish line)

### 3.3 Kerala (1050m Total Distance)
- `0.0m` — **Kochi Harbour** (Arabian sea starting point)
- `100.0m` — **Fort Kochi Chinese Fishing Nets** (Shoreline icon)
- `200.0m` — **Mattancherry Dutch Palace** (Heritage palace)
- `280.0m` — **Alleppey Backwaters** (Houseboat canals)
- `450.0m` — **Bekal Fort Coastal Bastion** (Keyhole fort)
- `550.0m` — **Western Ghats Mountain Pass Toll** (Checkpoint 1, +140 Coins reward)
- `680.0m` — **Athirappilly Waterfalls Viewpoint** (River gorge)
- `820.0m` — **Munnar Tea Gardens** (High elevation plantations)
- `920.0m` — **Padmanabhaswamy Temple Gopuram** (Distant gopuram)
- `1050.0m` — **Munnar Hill Station Finish Arch** (Anamudi finish line)

### 3.4 Rajasthan (1200m Total Distance)
- `0.0m` — **Jaipur Pink City** (Hawa Mahal boulevard)
- `100.0m` — **Hawa Mahal (Palace of Winds)** (Pink sandstone facade)
- `210.0m` — **Jal Mahal Water Palace** (Lake palace)
- `300.0m` — **Amber Fort Gateway** (Hilltop citadel)
- `480.0m` — **Jaswant Thada Marble Cenotaph** (Royal grounds)
- `600.0m` — **Thar Expressway Toll Plaza** (Checkpoint 1, +160 Coins reward)
- `820.0m` — **Mehrangarh Fort Cliff Bastion** (Jodhpur ridge)
- `1050.0m` — **Patwon Ki Haveli Jharokhas** (Carved stonework)
- `1200.0m` — **Jaisalmer Golden Fort Finish Arch** (Sonar Qila finish line)

### 3.5 Gujarat (1150m Total Distance)
- `0.0m` — **Ahmedabad Riverfront** (Sabarmati departure)
- `100.0m` — **Sabarmati Ashram Hriday Kunj** (Historical residence)
- `220.0m` — **Adalaj Stepwell (Vav)** (Subterranean architecture)
- `300.0m` — **Saurashtra Highway Dhaba** (Kathiyawadi oasis)
- `450.0m` — **Modhera Sun Temple Surya Kund** (Stepped temple tank)
- `600.0m` — **Kutch Border Toll Plaza** (Checkpoint 1, +180 Coins reward)
- `750.0m` — **Somnath Temple Jyotirlinga Shrine** (Coastline shrine)
- `880.0m` — **Flamingo Sanctuary Pass** (Great Rann natural passage)
- `1020.0m` — **Statue of Unity Colossus** (Monumental figure)
- `1150.0m` — **White Desert Rann of Kutch Finish Arch** (Great Rann finish line)

### 3.6 Telangana (1000m Total Distance)
- `0.0m` — **Hyderabad Charminar** (Monument starting point)
- `90.0m` — **Charminar 4-Minaret Monument** (Historic monument)
- `180.0m` — **Chowmahalla Palace Courtyard** (Nizam's palace)
- `260.0m` — **Golconda Fort Bastion** (Ancient citadel)
- `420.0m` — **Hussain Sagar Monolithic Buddha** (Lake monument)
- `520.0m` — **Outer Ring Road Toll Plaza** (Checkpoint 1, +180 Coins reward)
- `680.0m` — **Birla Mandir White Marble Temple** (Hilltop temple)
- `780.0m` — **Kakatiya Dynasty Torana** (Warangal stone arch)
- `890.0m` — **Ramappa Temple (Rudreshwara)** (UNESCO temple)
- `1000.0m` — **Thousand Pillar Temple Finish Arch** (Warangal finish line)

---

## 4. Pickup & Fuel Economy Recalibration

With total road length adjusted to 95,000 – 120,000 px:
- **Fuel Canister Spacing:** Initialized at `6500.0 px` (`65 m`), then spaced every `6500 – 8500 px` (`65 – 85 m`).
  - Total canisters per route: **12 – 15 canisters**.
  - Provides a rewarding tension/relief cycle: players cannot coast carelessly on full throttle without grabbing canisters, but careful driving will never result in an unfair "dry tank" failure.
- **Coin Pickup Patterns:** Generated every `300 – 450 px` in straight sequences or parabolic hill crest arcs.
  - Average coins collected per full route: **280 – 420 Coins** from road pickups + checkpoint bonuses + route completion rewards.

---

## 5. Summary & Verification

All route configurations have been validated in engine across `RouteRegistry.gd` and `RoadsideLandmarkRegistry.gd`. Automated tests confirm:
1. Zero skipped landmarks due to distance truncation.
2. Checkpoint and destination events trigger reliably at the exact calibrated distances.
3. Total play session per state averages 2.5 to 3.5 minutes on mobile, aligning with optimal mobile driving game session length.
