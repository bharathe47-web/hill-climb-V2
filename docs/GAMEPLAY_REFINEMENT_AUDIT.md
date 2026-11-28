# GAMEPLAY REFINEMENT COMPLETE PROJECT AUDIT
## Comprehensive Analysis of Route Lengths, HUD, Route Map, Pause Flow & Asset Positioning
**Author:** Joel (Lead Senior Godot Developer, Gameplay Engineer & UI/UX Specialist)  
**Project:** Indian Roads Mode — Hill Climb V2  
**Date:** November 17, 2026  
**Status:** AUDIT COMPLETED & ROOT CAUSES IDENTIFIED  

---

## 1. Executive Summary

This audit evaluates the six target problems identified in the Indian Roads gameplay experience:
1. **Route lengths are too long:** Routes currently span 1600m to 2200m (Tamil Nadu 1800m, Kerala 2000m, Rajasthan 2200m, Gujarat 2000m, Telangana 1800m, Goa 1600m). Driving sessions feel overly stretched with repetitive filler between major attractions.
2. **Nitro button is oversized:** The nitro button uses a 400x400 source graphic scaled to $0.85$ ($340\text{px}$ on screen), occupying nearly half the vertical height of a 720p display and obstructing the roadside.
3. **Missing in-game route map:** Players have no in-run way to view the upcoming route, completed landmarks, or their current geographical progress across the selected Indian state.
4. **Pause freeze bug:** When the game is paused, `get_tree().paused = true` is set, but the pause overlay fails to display on the first invocation due to an indentation error in `IndianRoadsController.gd` (where `pause_menu.visible = true` was placed exclusively inside the `else:` branch). The entire game freezes with no visible resume button.
5. **Landmark signboard & asset positioning errors:** The landmark identification signboard was positioned at `(-110, -42)` with `z_index = 1`. Because the player vehicle is at `z_index = 0`, the signboard draws directly over the vehicle windshield and body when passing.
6. **Scenery clumping & overlaps:** Decorative props and trees were spawned with tight spacing ($320\text{px} - 520\text{px}$), causing visual clumping and overlapping adjacent objects.

---

## 2. Root Cause Analysis by Subsystem

### A. Route Length & Pacing (`RouteRegistry.gd`, `RoadsideLandmarkRegistry.gd`)
- **Current State:**
  - Tamil Nadu: 1800m (180,000 px)
  - Goa: 1600m (160,000 px)
  - Kerala: 2000m (200,000 px)
  - Rajasthan: 2200m (220,000 px)
  - Gujarat: 2000m (200,000 px)
  - Telangana: 1800m (180,000 px)
- **Problem:** Driving at average speeds of $35-45\text{m/s}$ requires 4 to 6 minutes per run. Players encounter long stretches of repetitive filler between the approved famous landmarks.
- **Solution:** Re-calibrate all 6 routes into the tight, engaging **950m – 1200m** target range:
  - Tamil Nadu: **1100m** (preserving 270m–450m Kanyakumari Glass Bridge ocean deck)
  - Goa: **950m** (Panaji -> Calangute -> Fort Aguada -> Old Goa -> Margao)
  - Kerala: **1050m** (Fort Kochi -> Alleppey -> Bekal -> Munnar)
  - Rajasthan: **1200m** (Jaipur -> Amber Fort -> Mehrangarh -> Jaisalmer)
  - Gujarat: **1150m** (Sabarmati -> Modhera -> Somnath -> Rann of Kutch)
  - Telangana: **1000m** (Charminar -> Golconda -> Hussain Sagar -> Warangal)
- All checkpoints, milestone milestones, fuel cans, coins, and famous landmarks will be proportionately re-mapped.

### B. Nitro Button Control (`IndianRoadsHUD.tscn`, `IndianRoadsHUD.gd`)
- **Current State:** Uses `res://assets/effects/nitro/nitro_bottle.png` (400x400 px) at scale $(0.85, 0.85)$ positioned at $(40, 420)$.
- **Problem:** Covers $340\text{px} \times 340\text{px}$ of screen space, occluding roadside scenery and approaching obstacles.
- **Solution:** Replace with a dedicated, professional 80x80 circular touch button:
  - Cyan circular base with glowing bezel and sleek boost flame/bolt icon.
  - Three distinct visual states: Normal (full glow), Pressed (active flame), Disabled / Empty (dim translucent).
  - Integrated circular / radial energy indicator or clean percentage gauge.
  - Position on left side at $(50, 460)$, safely above the Brake pedal at $(40, 560)$ with $30\text{px}$ safe gap and zero road occlusion.

### C. In-Game Route Map System (`IndianRoadsHUD.tscn`, `RouteMapOverlay.gd`)
- **Current State:** No map button exists in the HUD during gameplay.
- **Solution:**
  - Add a compact `MapButton` $(44 \times 44\text{px})$ in `TopBar/Margin/HBox` next to `PauseButton`.
  - Create `RouteMapOverlay.tscn` (Modal dialog) displaying:
    - State title and route path (e.g. "KANYAKUMARI → CHENNAI")
    - Scaled SVG vector state map outline from `assets/indian_locations/`
    - Horizontal milestone track with icons for completed landmarks (green), current player location (pulsing gold pin), and upcoming landmarks/checkpoints (slate)
    - Real-time distance traveled and distance remaining
    - Close button (X) and background tap to dismiss
  - Opening the map cleanly pauses or overlays without affecting vehicle momentum, position, coins, or active rewards.

### D. Pause Button Freeze Bug (`IndianRoadsController.gd`, `PauseMenuController.gd`)
- **Root Cause Identified:**
  In `IndianRoadsController.gd` lines 355–365:
  ```gdscript
  if not is_instance_valid(pause_menu):
      pause_menu = PauseMenuScene.instantiate()
      ui_layer.add_child(pause_menu)
      # ... signal connections ...
  else:
      pause_menu.visible = true
  ```
  `PauseMenuController._ready()` initializes with `visible = false`. When first instantiated, `pause_menu.visible = true` was in the `else:` branch! Consequently, `get_tree().paused = true` was executed while `pause_menu` remained invisible. The game froze with no clickable interface.
- **Solution:**
  1. Ensure `pause_menu.visible = true` is executed on every pause request.
  2. Set `IndianRoadsController.process_mode = Node.PROCESS_MODE_ALWAYS` so controller callbacks are never halted by tree pause.
  3. Support the `"pause"` action in `IndianRoadsHUD._unhandled_input()`.
  4. Ensure vehicle inputs (throttle, brake, nitro) are immediately deactivated when paused so no input buffering occurs.
  5. Ensure resume, restart, and exit cleanly restore `get_tree().paused = false`.

### E. Landmark Signboard & Asset Overlaps (`RoadsideLandmark.gd`, `IndianRoadTerrainV2.gd`)
- **Root Cause Identified:**
  1. In `RoadsideLandmark.gd`, `signboard.z_index = 1` placed the green signboard in front of the vehicle (`z_index = 0`), appearing directly over the car body.
  2. The signboard was at `(-110, -42)`, directly in the driving lane.
  3. In `IndianRoadTerrainV2.gd`, roadside props, milestones, and warning signs were assigned `z_index = 1`.
  4. Roadside vegetation and shops had tight spacing ($320\text{px} - 520\text{px}$), causing visual clumping.
- **Solution:**
  1. Change signboard `z_index` to `-1` (behind vehicle).
  2. Move signboard position to `Vector2(-140.0, -75.0)` with a dedicated ground post anchored cleanly to the shoulder.
  3. Set all roadside scenery, milestones, and vegetation to `z_index = -1` or `-2` (behind vehicle).
  4. Increase roadside prop spacing to $650\text{px} - 1100\text{px}$ to give landmarks maximum visual prominence.

---

## 3. Implementation Plan & File Touch Matrix

| Subsystem | Target Files | Nature of Change |
|---|---|---|
| **Route Calibration** | `scripts/modes/indian_roads/RouteRegistry.gd`, `resources/routes/*.tres`, `RoadsideLandmarkRegistry.gd` | Calibrate distances to 950m–1200m and adjust waypoints |
| **Nitro Button** | `assets/ui/controls/nitro_*.png`, `scenes/modes/indian_roads/IndianRoadsHUD.tscn`, `IndianRoadsHUD.gd` | Redesign compact 80x80 button with gauge & visual states |
| **Route Map** | `scenes/modes/indian_roads/RouteMapOverlay.tscn`, `scripts/modes/indian_roads/RouteMapOverlay.gd`, `IndianRoadsHUD.tscn` | Add MapButton, modal overlay, and route progress visualization |
| **Pause Bug Fix** | `scripts/modes/indian_roads/IndianRoadsController.gd`, `IndianRoadsHUD.gd` | Fix visibility logic, input unhandled pass, and process modes |
| **Asset Positioning** | `scripts/modes/indian_roads/RoadsideLandmark.gd`, `IndianRoadTerrainV2.gd`, `RoadsideLandmarkRegistry.gd` | Fix signboard z-index, ground anchoring, and prop spacing |
