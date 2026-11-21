# INDIAN ROADS ALL SIX MAPS UNLOCK REPORT
**Project:** Hill Climb V2 | Indian Roads 2D  
**Engine:** Godot 4.7.2.stable  
**Subsystems:** `RouteRegistry.gd`, `SaveManager.gd`, `StateSelectionController.gd`  
**Author:** State-Map Integration Specialist & Lead Gameplay Developer  
**Date:** November 21, 2026  
**Status:** IMPLEMENTED, MIGRATED & VERIFIED  

---

## 1. Executive Summary

In Hill Climb V2 Version 1.0, all six canonical Indian Roads states are unlocked, selectable, and playable from the initial game launch:
1. **Tamil Nadu** (Kanyakumari $\to$ Chennai, NH44)
2. **Goa** (Panaji $\to$ Margao, NH66)
3. **Kerala** (Kochi $\to$ Munnar, NH85)
4. **Rajasthan** (Jaipur $\to$ Jaisalmer, NH11)
5. **Gujarat** (Ahmedabad $\to$ Rann of Kutch, NH27)
6. **Telangana** (Hyderabad $\to$ Warangal, NH163)

No state is locked behind sequential progression gates. Players can choose to drive through any Indian state immediately.

---

## 2. Save Data Architecture & Safe Migration

### 2.1 Default Save Data
In `scripts/core/SaveManager.gd` line 18:
```gdscript
const DEFAULT_SAVE_DATA: Dictionary = {
    "version": 1,
    "best_distance": 0.0,
    "total_coins": 0,
    "runs_played": 0,
    "sound_volume": 1.0,
    "music_volume": 1.0,
    "selected_vehicle_id": "blue_flame_truck",
    "unlocked_vehicles": ["blue_flame_truck"],
    "unlocked_routes": ["tamil_nadu", "goa", "kerala", "rajasthan", "gujarat", "telangana"],
    "completed_routes": [],
    "discovered_landmarks": [],
    ...
}
```

### 2.2 Backward Compatibility & Automatic Migration
In `scripts/core/SaveManager.gd` line 67:
```gdscript
# Safe Migration: Ensure all 6 Version 1.0 routes are present in unlocked_routes without altering player progression
var unlocked_list: Array = merged.get("unlocked_routes", [])
var default_routes: Array = DEFAULT_SAVE_DATA["unlocked_routes"]
var migrated: bool = false
for r_id in default_routes:
    if not (r_id in unlocked_list):
        unlocked_list.append(r_id)
        migrated = true
merged["unlocked_routes"] = unlocked_list
if migrated:
    save_game(merged)
```

### 2.3 Migration Safety Guarantees
- **Player Coins:** Preserved with $100\%$ integrity.
- **Vehicle Unlocks & Upgrades:** Existing upgrades (Engine, Tires, Suspension, Fuel Tank, Nitro) are untouched.
- **Completed Routes & Landmarks:** Existing player accomplishments remain recorded in `completed_routes` and `discovered_landmarks`.
- **Silent Migration:** The save file on disk (`user://savegame.json`) is automatically updated on the first load without requiring user intervention.

---

## 3. Route Registry Verification

In `scripts/modes/indian_roads/RouteRegistry.gd` line 35:
```gdscript
static func is_state_unlocked(state_id: String) -> bool:
    if dev_unlock_all_routes:
        return true
    # In Version 1.0, all 6 canonical Indian Roads states are unlocked by default
    if state_id in STATE_ORDER:
        return true

    var data := SaveManager.load_save()
    var unlocked: Array = data.get("unlocked_routes", STATE_ORDER)
    return state_id in unlocked
```

Every route object generated via `RouteRegistry.get_all_routes()` has `r.is_unlocked = true`.

---

## 4. State Selection UI Verification

In `scripts/modes/indian_roads/StateSelectionController.gd`:
- **Map Pins:** All six state pins (`TN`, `GA`, `KL`, `RJ`, `GJ`, `TG`) render with active/unlocked blue style without the padlock (`🔒`) icon.
- **Route Cards:** All six state cards display their journey (`Start → Destination`), representative icons, and active `SELECT` / `ACTIVE` buttons.
- **Details Panel:** Displays state name, landmark preview, journey itinerary, and distance without "LOCKED" warnings.
- **Start Button:** Enabled (`disabled = false`) with text `"DRIVE ROUTE"`. Clicking the button emits `route_selected(selected_route)` to start the journey immediately.

---

## 5. Automated Verification Results

Executed via `tests/test_six_state_selection_and_unlock.gd`:
```
>>> TEST 1: Legacy Save Migration Test <<<
  Migrated unlocked_routes: ["tamil_nadu", "goa", "kerala", "rajasthan", "gujarat", "telangana"]
  [PASS] Legacy save successfully migrated to all 6 states while 100% preserving coins, upgrades, and player stats!

>>> TEST 2: RouteRegistry Unlock Statuses <<<
  State 'tamil_nadu' is_unlocked: true
  State 'goa' is_unlocked: true
  State 'kerala' is_unlocked: true
  State 'rajasthan' is_unlocked: true
  State 'gujarat' is_unlocked: true
  State 'telangana' is_unlocked: true
  [PASS] All 6 routes in RouteRegistry are unlocked.
```
