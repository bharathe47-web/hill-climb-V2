# Indian Roads — Gameplay Refinement QA & Verification Report
**Developer:** Joel (Indian Roads, HUD, Pickups, Routes, Level Design, QA)  
**Project:** Hill Climb V2 (Godot 4.7)  
**Branch:** `feature/joel-roads-obstacles`  
**Date:** November 17, 2026  

---

## 1. Test Scope & Acceptance Criteria

This QA report validates the successful resolution of all 6 problems identified in the Gameplay Refinement Master Task:
1. **Route Length Optimization:** Routes reduced from 1600m–2200m to 950m–1200m with balanced pacing.
2. **Compact Nitro Button:** 80x80 circular touch button replacement above brake with dynamic feedback.
3. **In-Game Route Map:** Functional modal dialog with state SVG map, waypoint milestones, and progress telemetry without resetting game progress.
4. **Pause Menu Freeze Bug:** Full resolution of pause freeze defect; reliable pause/resume/restart execution.
5. **Asset Positioning & Z-Index:** Landmark signboards moved behind vehicle (`z_index = -1`), grounded posts.
6. **Scenery Clumping Elimination:** Spacing increased to 650–1100px; all roadside props set to `z_index = -1`.

---

## 2. Automated Test Suite Execution Results

### 2.1 Test 1: `tests/test_all_landmarks_instantiation.gd`
- **Result:** **PASSED (44 / 44 Landmarks)**
- **Verification Details:**
  - Tamil Nadu: 12 landmarks loaded and verified.
  - Goa: 9 landmarks loaded and verified.
  - Kerala: 6 landmarks loaded and verified.
  - Rajasthan: 6 landmarks loaded and verified.
  - Gujarat: 5 landmarks loaded and verified.
  - Telangana: 6 landmarks loaded and verified.
  - Zero missing textures, zero instantiation failures.

### 2.2 Test 2: `tests/test_glass_bridge_traversal.gd`
- **Result:** **PASSED (100% Success)**
- **Verification Details:**
  - 74 vehicle physics telemetry samples collected across 22,000 px bridge span (x = 27000 to 45000).
  - Peak deck elevation verified at y = 242.0.
  - Max collision gap = 0.00 px (zero clipping, continuous traversal).

### 2.3 Test 3: `tests/test_all_six_indian_roads_states.gd`
- **Result:** **PASSED (6 / 6 States)**
- **Verification Details:**
  - Tamil Nadu: 1100m, 6 waypoints, next milestone Glass Bridge (270m).
  - Goa: 950m, 5 waypoints, next milestone Calangute Beach (250m).
  - Kerala: 1050m, 5 waypoints, next milestone Alleppey Backwaters (280m).
  - Rajasthan: 1200m, 5 waypoints, next milestone Amber Fort (300m).
  - Gujarat: 1150m, 5 waypoints, next milestone Saurashtra Dhaba (300m).
  - Telangana: 1000m, 5 waypoints, next milestone Golconda Fort (260m).
  - StateSelection UI hub integration verified with 6/6 states unlocked.

### 2.4 Test 4: `tests/test_gameplay_refinement.gd`
- **Result:** **PASSED (4 / 4 Suites)**
- **Verification Details:**
  - Initial state: `PLAYING`, tree unpaused.
  - Pause freeze bug fix: First pause request opens visible menu (`pause_menu.visible == true`), tree paused.
  - Resume functionality: Tree unpaused, menu hidden, state restored to `PLAYING`.
  - Repeated pause/resume: 5 consecutive cycles verified without error.
  - Route Map modal: Opens cleanly, displays waypoints, preserves vehicle telemetry and 350m distance without resetting.
  - Compact Nitro button: Confirmed at `(50, 460)`, modulate updates on charge/discharge.

---

## 3. Photographic Screenshot Evidence (12 Real In-Engine Viewports)

All 12 screenshots captured on live AMD Radeon 610M hardware environment (`DISPLAY=:0`) and archived in `docs/screenshots/gameplay_refinement/`:

| # | Filename | Description | File Size |
| :- | :--- | :--- | :--- |
| 1 | `tn_start_gameplay.png` | Tamil Nadu Start: Vehicle, HUD, Compact Nitro & Map Buttons | 333 KB |
| 2 | `goa_gameplay.png` | Goa Coastal Highway: Calangute Beach & Fort Aguada | 285 KB |
| 3 | `kerala_gameplay.png` | Kerala Backwaters: Alleppey Wharf & Palm Scenery | 262 KB |
| 4 | `rajasthan_gameplay.png` | Rajasthan Highway: Amber Fort Gateway & Desert Terrain | 144 KB |
| 5 | `gujarat_gameplay.png` | Gujarat Highway: Saurashtra Oasis & Savanna | 75 KB |
| 6 | `telangana_gameplay.png` | Telangana Highway: Golconda Fort Bastion & Deccan Rocks | 237 KB |
| 7 | `compact_nitro_button.png` | Compact 80x80 Nitro Button & HUD Controls | 286 KB |
| 8 | `route_map_opened.png` | In-Game Tourism Route Map Modal with SVG State Map & Waypoints | 168 KB |
| 9 | `pause_menu_active.png` | Pause Menu Active Overlay with Resume/Restart/Main Menu | 159 KB |
| 10 | `resume_gameplay.png` | Seamless Gameplay Resumed Post-Pause without Reset | 288 KB |
| 11 | `correct_landmark_positioning.png` | Landmark & Signboard Correctly Positioned Behind Car (`z_index = -1`) | 347 KB |
| 12 | `destination_completion.png` | Destination Finish Arch & Victory Celebration Screen | 326 KB |

---

## 4. Defect Closure Matrix

| Bug / Refinement ID | Description | Status | Verification Method |
| :--- | :--- | :--- | :--- |
| **REF-01** | Route length excessive (1600–2200m) | **RESOLVED** | All 6 routes calibrated to 950–1200m in `RouteRegistry.gd` & `RoadsideLandmarkRegistry.gd`. |
| **REF-02** | Nitro button oversized (340px) | **RESOLVED** | Compact 80x80 circular touch button created and integrated at `(50, 460)`. |
| **REF-03** | Missing in-game route map | **RESOLVED** | `RouteMapOverlay.tscn` implemented with SVG map and progress tracking. |
| **REF-04** | Pause button causes freeze | **RESOLVED** | `pause_menu.visible = true` called unconditionally; vehicle nitro cleared on pause. |
| **REF-05** | Landmark signboards occlude car | **RESOLVED** | `z_index = -1`, elevated to `(-140, -75)` with grounded signpost. |
| **REF-06** | Roadside scenery clumping | **RESOLVED** | Prop spacing increased to 650–1100px; all prop Z-indices normalized to `-1`. |
