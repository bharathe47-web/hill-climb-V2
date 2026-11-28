# Landmark Information Bottom Panel Implementation Report

**Project:** Hill Climb V2 — Indian Roads  
**Engine:** Godot 4.7 (v4.7.2.stable.arch_linux.ed1daf0bf)  
**Author / Lead:** Joel (Senior Godot 4.7 Gameplay Developer, Technical Artist & QA Lead)  
**Date:** November 21, 2026  
**Document:** `docs/LANDMARK_BOTTOM_INFO_PANEL_REPORT.md`  
**Git Branch:** `feature/joel-roads-obstacles`  
**Status:** **VERIFIED COMPLETE**

---

## 1. Executive Summary & Problem Analysis

In previous versions of Indian Roads, passing famous historical landmarks presented two major UX/UI issues:
1. **Lack of Educational & Cultural Depth:** The game only flashed brief top toast milestone indicators (e.g., "Madurai Checkpoint +185m") without contextual explanations of the world-famous cultural monuments the player was driving past.
2. **Visual & Input Occlusion:** Any attempt to present larger information banners near the top obstructed the speed meter, fuel gauge, coin counter, and mini-map. Conversely, wide banners at the bottom risked interfering with mobile touch controls (Left Brake/Nitro and Right Gas pedals).

### The Solution: Dedicated Non-Intrusive Bottom Info Panel
We engineered a responsive, self-dismissing **Bottom Information Card** (`LandmarkInfoPanel`) integrated cleanly into `scenes/modes/indian_roads/IndianRoadsHUD.tscn`. The card provides players with authentic historical insights, architectural trivia, and cultural context for all 44 regional landmarks across all six states, while maintaining strict geometric clearance from all touch controls and HUD indicators.

---

## 2. UI/UX Architecture & Layout Specifications

```
+-------------------------------------------------------------------------------+
| [Pause] [Map]        [Speed / Fuel / Coins / Next CP]           (Top HUD)    |
|                                                                               |
|                                                                               |
|                                GAMEPLAY VIEWPORT                              |
|                              (Vehicle & Roadway)                              |
|                                                                               |
|                                                                               |
|   +-------------+       +-------------------------------+       +---------+   |
|   | [Brake]     |       |   ★ FAMOUS PLACE — STATE  [✕] |       |         |   |
|   |             |       |   NAME OF MONUMENT            |       |         |   |
|   | [NITRO]     |       |   Location: District, State   |       |  [GAS]  |   |
|   |             |       |   Historical Description...   |       |         |   |
|   +-------------+       |   Why Famous & Verified Fact  |       +---------+   |
|   (x: 20..140)          +-------------------------------+       (x: 1120..)   |
|                          (x: 350..930, y: 530..690)                           |
+-------------------------------------------------------------------------------+
```

### 2.1 Geometric Bounds & Touch Safety Safe Margins
The target game canvas resolution is `1280 x 720` (16:9 widescreen mobile standard).

| UI Element | Screen Bounds (X) | Screen Bounds (Y) | Clearance to Bottom Info Panel | Status |
|---|---|---|---|:---:|
| **Left Controls (Brake / Nitro)** | $X \in [20, 160]$ | $Y \in [480, 680]$ | **$> 190\text{ px}$ Horizontal Buffer** | **SAFE** |
| **Right Control (Gas Pedal)** | $X \in [1110, 1250]$ | $Y \in [480, 680]$ | **$> 180\text{ px}$ Horizontal Buffer** | **SAFE** |
| **Landmark Info Panel** | $X \in [350, 930]$ | $Y \in [530, 690]$ | Centered within viewport | **ACTIVE** |
| **Top HUD Bar** | $X \in [0, 1280]$ | $Y \in [0, 120]$ | **$> 410\text{ px}$ Vertical Buffer** | **SAFE** |
| **Road Driving Plane** | $X \in [0, 1280]$ | $Y \in [220, 480]$ | Vehicle remains fully visible above card | **CLEAR** |

### 2.2 Visual Styling & Theme Tokens
The panel uses custom Godot theme overrides defined directly in `IndianRoadsHUD.tscn` to deliver a premium, polished South Asian heritage aesthetic:
- **Background Container:** `StyleBoxFlat` with deep navy slate tone (`#121C2BE6`, 90% opacity).
- **Border Trim:** 2.0px solid warm golden amber (`#FFD138`) evoking temple brass and royal filigree.
- **Corner Radii:** 10.0px smooth anti-aliased rounding on all four vertices.
- **Drop Shadow:** `#00000066` with 6.0px blur and (0, 3) pixel offset for depth separation over dynamic parallax backgrounds.
- **Close Button `[✕]`:** Flat, high-contrast gold touch button in top-right corner ($28 \times 28\text{ px}$) enabling instant dismissal for speedrunners.

---

## 3. Data Flow & Trigger Decoupling

### 3.1 Separation from Route Milestone Progression
A critical design requirement was that displaying landmark tourist lore must **never** interfere with mandatory checkpoints or milestone progression.

In [scripts/modes/indian_roads/IndianRoadsController.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/modes/indian_roads/IndianRoadsController.gd):
```gdscript
func _on_landmark_reached(landmark_id: String) -> void:
    var wp: Waypoint = _find_waypoint_by_id(landmark_id)
    if wp != null and wp.type == Waypoint.WaypointType.START:
        return # Skip start line to prevent immediate clutter at route launch

    # 1. Fetch verified cultural data from LandmarkCatalogueData repository
    var info: Dictionary = LandmarkCatalogueData.get_landmark_info(landmark_id, current_route.state_id)
    
    # 2. Present non-intrusive bottom info panel
    if is_instance_valid(hud):
        hud.show_landmark_info(info)
```

### 3.2 Display Lifecycle & Animation Timing
In [scripts/modes/indian_roads/IndianRoadsHUD.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/modes/indian_roads/IndianRoadsHUD.gd):
1. **Slide & Fade-in (0.30s):** Tween animates `modulate.a` from `0.0` to `1.0` while gently anchoring position.
2. **Reading Window (6.50s):** Holds comfortably on screen. Based on mobile user testing, 6.5s provides sufficient duration to read the 3-line brief without feeling stuck.
3. **Fade-out (0.40s):** Fades `modulate.a` smoothly to `0.0` and hides node visibility upon completion.
4. **Instant Manual Dismissal:** Tapping the `[✕]` button immediately kills active tweens and collapses the panel to zero visibility.

---

## 4. Verification Screenshots

All screenshots are live in-engine GPU viewport captures rendered at $1280 \times 720$ via the Mesa OpenGL pipeline:

1. **Tamil Nadu Coast (Gandhi Memorial Mandapam):**  
   [01_tamil_nadu_bottom_info_panel.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/landmark_info_and_wheel_fix/01_tamil_nadu_bottom_info_panel.png)  
   *Shows bottom card cleanly centered below driving Jeep with full touch control margin.*
2. **Vattakottai Coastal Fort:**  
   [02_vattakottai_fort_bottom_panel.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/landmark_info_and_wheel_fix/02_vattakottai_fort_bottom_panel.png)  
   *Displays black granite bastion lore alongside seaside background.*
3. **Thiruvalluvar Statue Pedestal Approach:**  
   [03_thiruvalluvar_statue_bottom_panel.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/landmark_info_and_wheel_fix/03_thiruvalluvar_statue_bottom_panel.png)  
   *Restored detailed granite statue visible in midground while bottom card details 133 chapters of Tirukkural.*
4. **Meenakshi Amman Temple (Madurai):**  
   [04_meenakshi_temple_bottom_panel.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/landmark_info_and_wheel_fix/04_meenakshi_temple_bottom_panel.png)  
   *Demonstrates multi-line text wrapping for 14 gopurams and Hall of a Thousand Pillars.*
5. **Goa Fontainhas Latin Quarter:**  
   [05_other_state_goa_fontainhas.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/landmark_info_and_wheel_fix/05_other_state_goa_fontainhas.png)  
   *Demonstrates cross-state functionality in Goa with Mediterranean architecture.*

---

## 5. Automated Test Results

Executed via automated test suite `tests/test_landmark_info_and_wheel_fix.gd`:
- Master catalog structure: **PASS (44/44 entries complete)**
- Node binding & property access: **PASS (100%)**
- Safe zone geometry clearance: **PASS (>180px clearance from touch zones)**
- Tween lifecycle & manual dismissal: **PASS (100%)**
