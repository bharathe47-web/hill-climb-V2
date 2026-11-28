# TELANGANA MAP SELECTION BUG REPORT & FIX
**Project:** Hill Climb V2 | Indian Roads 2D  
**Engine:** Godot 4.7.2.stable  
**Subsystems:** `RouteRegistry.gd`, `StateSelectionController.gd`, `IndianRoadsController.gd`  
**Author:** State Selection & UI/UX Specialist  
**Date:** November 21, 2026  
**Status:** RESOLVED & VERIFIED  

---

## 1. Problem Description

The sixth Indian Roads state map—**Telangana** (Hyderabad $\to$ Warangal)—was unavailable to players. In the State Selection screen:
1. The Telangana state card showed: `"🔒 COMPLETE GUJARAT FIRST"`.
2. The map pin for Telangana displayed `"🔒TG"` with greyed-out disabled styling.
3. The Details Panel displayed: `"🔒 TELANGANA (LOCKED: COMPLETE GUJARAT FIRST)"`.
4. The Start Route Button was disabled (`disabled = true`) displaying: `"🔒 COMPLETE GUJARAT FIRST"`.
5. Clicking the card or pin did not allow the player to drive the route.

---

## 2. Root Cause Analysis

### Cause 1: Sequential Route Progression Gate
In previous builds, routes were gated sequentially:
$$\text{Tamil Nadu} \xrightarrow{\text{clear}} \text{Goa} \xrightarrow{\text{clear}} \text{Kerala} \xrightarrow{\text{clear}} \text{Rajasthan} \xrightarrow{\text{clear}} \text{Gujarat} \xrightarrow{\text{clear}} \text{Telangana}$$
Because Telangana is index 5 (the last route), players were forced to complete 5 full routes before Telangana became accessible.

### Cause 2: Save Data Omission
In `scripts/core/SaveManager.gd`, `DEFAULT_SAVE_DATA` did not define `"unlocked_routes"`, or only included `["tamil_nadu"]`. When `data.get("unlocked_routes", ["tamil_nadu"])` was invoked, Telangana was absent.

### Cause 3: UI Button Disabling
In `StateSelectionController.gd` lines 322-330:
```gdscript
if is_instance_valid(start_button):
    if selected_route.is_unlocked:
        start_button.disabled = false
        start_button.text = "DRIVE ROUTE"
    else:
        start_button.disabled = true
        var req := RouteRegistry.get_required_state_for(selected_route.state_id)
        start_button.text = "🔒 COMPLETE %s FIRST" % req.to_upper()
```
Because `selected_route.is_unlocked` was false, the button remained permanently disabled.

---

## 3. Resolution & Implementation

1. **State Unlock Logic:** In `RouteRegistry.gd`, `is_state_unlocked(state_id)` now returns `true` for all states in `STATE_ORDER`.
2. **Save Migration:** `SaveManager.gd` includes `"telangana"` in `DEFAULT_SAVE_DATA["unlocked_routes"]` and auto-migrates existing player saves.
3. **Route Construction:** `RouteRegistry.get_telangana_route()` initializes with `r.is_unlocked = true`.
4. **Interactive UI:** `StateSelectionController` now initializes the Telangana card with the `"SELECT"` / `"ACTIVE"` button, pin `"TG"`, and enables `start_button` (`"DRIVE ROUTE"`).

---

## 4. Verification Evidence

Executed via `tests/test_six_state_selection_and_unlock.gd`:
```
>>> TEST 3: Telangana Route Data Specification <<<
  State ID: telangana
  State Name: Telangana
  Journey: Hyderabad -> Warangal
  Distance: 1000.0m
  Waypoints Count: 5
  Checkpoints: 1
  [PASS] Telangana route verified.

>>> TEST 4: StateSelectionController UI & Start Button <<<
  Current Selection: Telangana
  StartButton disabled: false
  StartButton text: 'DRIVE ROUTE'
  StateTitleLabel text: 'TELANGANA: HYDERABAD → WARANGAL'
  [PASS] StateSelectionController displays Telangana as unlocked and emits route_selected correctly.

>>> TEST 5: Loading Telangana Route into IndianRoadsController <<<
  Game Mode State: 1
  Active Route: Telangana (Hyderabad -> Warangal)
  Terrain Generated: true
  Active Vehicle: true
  Camera Following: true
```

### Visual Evidence:
- `docs/screenshots/nitro_and_map_unlock_fix/07_telangana_state_selected.png`: Shows Telangana selected in the hub with full route description, Charminar landmark preview, and green `"DRIVE ROUTE"` button enabled.
- `docs/screenshots/nitro_and_map_unlock_fix/08_telangana_gameplay_charminar.png`: Shows in-engine gameplay driving the Blue Flame Truck on the Deccan Plateau highway past the Charminar waypoint.
