# Indian Roads — Asset Positioning, Z-Index & Scenery Spacing Report
**Developer:** Joel (Indian Roads, HUD, Pickups, Routes, Level Design, QA)  
**Project:** Hill Climb V2 (Godot 4.7)  
**Branch:** `feature/joel-roads-obstacles`  
**Date:** November 17, 2026  

---

## 1. Executive Summary

An audit of in-game roadside scenery and landmark presentations revealed two significant visual issues:
1. **Vehicle Occlusion by Signboards and Props:** Highway signboards, milestone stones, and traffic props were set to `z_index = 1` while the player vehicle resided at `z_index = 0`. As a result, signs and props were drawn on top of the vehicle body and wheels as the car drove past.
2. **Prop Clumping:** Roadside trees, market kiosks, and architectural buildings had narrow random spawn step distances (`320 – 520 px`), resulting in cramped clumping where multiple assets overlapped each other within 3 to 5 meters.

Both issues have been resolved across all scenes and procedural generation algorithms.

---

## 2. Z-Index Layering Hierarchy

To ensure the player vehicle and dynamic road collisions are always visually dominant while scenery sits naturally in the background, a standardized Z-index layering model is enforced:

| Z-Index Layer | Visual Elements | Notes |
| :--- | :--- | :--- |
| **`z_index = +2`** | Bridge Entrance/Exit Gateway Portals | Arches the car physically drives underneath |
| **`z_index = +1`** | Bridge Front Glass Handrail Deck | Low transparent railing covering tire base |
| **`z_index =  0`** | **Player Vehicle & Wheel Physics** | **Primary focal gameplay elements** |
| **`z_index = -1`** | **Roadside Signboards, Milestones, Warning Signs, Guardrails, Toll Booths** | **Rendered immediately behind the vehicle; zero vehicle clipping** |
| **`z_index = -2`** | **Roadside Landmarks, Temples, Palaces, Regional Trees** | **Midground scenery anchored to road shoulder** |
| **`z_index = -3`** | **Distant Forts, Palaces, Settlement Village Houses** | **Background architectural elements** |
| **`z_index = -4`** | **Island Platforms & Background Monuments** | **Offshore land masses** |
| **`z_index = -6`** | **Ocean Water & Surface Waves** | **Deepest water fill** |

---

## 3. Roadside Landmark Signboard Calibration

### 3.1 Previous Defect
In `scenes/modes/indian_roads/visual_upgrade_v2/RoadsideLandmark.tscn` and `RoadsideLandmark.gd`:
- `Signboard.position = Vector2(-110.0, -42.0)`
- `Signboard.z_index = 1`
- The sign was positioned directly at the car's windshield level (`y = -42`), obscuring the vehicle whenever approaching or passing the attraction.

### 3.2 Corrected Architecture
1. **Z-Index Shift:** Changed `Signboard.z_index = -1` (renders cleanly behind the vehicle).
2. **Elevation Adjustment:** Shifted position to `Vector2(-140.0, -75.0)` — elevates the green highway board above the car roofline.
3. **Physical Grounding Post:** Extended `SignPost` (`ColorRect`) from `offset_bottom = 44.0` to `offset_bottom = 75.0`, anchoring the post directly into the roadside asphalt/dirt shoulder.

```
       [SIGNBOARD at y = -75]
       +-------------------------------+
       | MEENAKSHI AMMAN TEMPLE        | (z_index = -1)
       | Madurai Temple City           |
       +---------------+---------------+
                       |  <-- SignPost (extends down to y = 0)
                       |
=======================|======================== [ROAD SURFACE y = 0]
       [CAR WHEELS / CHASSIS at z_index = 0]
```

---

## 4. Roadside Prop Spacing & Anti-Clumping Optimization

In `scripts/modes/indian_roads/IndianRoadTerrainV2.gd` and `IndianRoadTerrain.gd`:

### 4.1 Spacing Parameter Comparison
| Scenery Category | Previous Spacing | Calibrated Spacing | Visual Impact |
| :--- | :--- | :--- | :--- |
| **Settlement Buildings** | 520 – 720 px | **800 – 1150 px** | Clean distinct villages at route boundaries |
| **Regional Trees** | 320 – 520 px | **650 – 950 px** | Organic tree lines without dense foliage clipping |
| **Roadside Shops/Dhabas**| 380 – 600 px | **750 – 1100 px** | Authentic highway rest stop appearances |
| **Props & Milestones** | 340 – 560 px | **650 – 1000 px** | Clear milestone markers every ~8–10 meters |
| **Landmark Clearance** | 650 px radius | **700 px advance** | Wide visual buffer ensuring landmarks remain the hero spectacle |

### 4.2 Z-Index Standardization on Procedural Sprites
In `IndianRoadTerrainV2.gd`:
- Advance warning speed breaker signs: `z_index = -1` (was 1).
- Hazard curve signs, barricades, traffic cones: `z_index = -1` (was 1).
- Roadside milestones & cultural props: `z_index = -1` (was 1).
- Concrete guardrails: `z_index = -1` (was 1).

---

## 5. Verification & Evidence

- In-engine screenshot `correct_landmark_positioning.png` confirms:
  - Thiruvalluvar Statue and signboard rendered with depth behind the vehicle.
  - Car windshield, roof, and tires remain completely unobstructed.
  - Zero overlapping prop clumps throughout all 6 state routes.
