# GAME PRODUCT UPGRADE — SYSTEM & ARCHITECTURE AUDIT
**Date:** November 2026  
**Developer:** Joel (Indian Roads & Survival Obstacle Specialist)  
**Target Engine:** Godot 4.7 (Arch Linux / AMD Radeon 610M GPU)  
**Branch:** `feature/joel-roads-obstacles`

---

## 1. PROJECT AUDIT SUMMARY

Before implementing changes for the Master Implementation Phase, a full repository inspection and baseline audit were conducted across the active codebase.

| Category | Status | Details |
| :--- | :--- | :--- |
| **Project Root** | Verified | `/home/joel/Documents/game/hill-climb-V2` |
| **Git Branch** | Verified | `feature/joel-roads-obstacles` (Preserved without destructive resets) |
| **Backup Archive** | Active | `backups/game_product_upgrade/` created containing scripts, scenes, resources, docs, tests |
| **Display Server** | Verified | Hardware accelerated X11 / Wayland on AMD Radeon 610M GPU (`DISPLAY=:0`) |
| **Baseline Tests** | Passing | 44/44 Landmarks instantiated without errors; 6/6 State Routes functional; Glass Bridge traversal verified |

---

## 2. SUBSYSTEM & ARCHITECTURE INSPECTION

### A. Active Scene Architecture
- **Main Entry:** `scenes/main/Main.tscn` / `scripts/core/Main.gd` coordinates top-level mode switching (`load_game`, `load_survival`, `load_indian_roads`).
- **Main Menu:** `scenes/main/MainMenu.tscn` / `scripts/core/MainMenuController.gd` displays mode cards and vehicle selection carousel.
- **Indian Roads Mode:** `scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn` powered by `IndianRoadsControllerV2.gd` and `IndianRoadTerrainV2.gd`.
- **State Selection Hub:** `scenes/modes/indian_roads/StateSelection.tscn` / `StateSelectionController.gd`.

### B. Shared Managers (Bharath Ownership)
- **`SaveManager.gd`**: Autoload handling high scores, unlocked states, selected vehicle ID, and lifetime coin balances.
- **`CurrencyManager.gd`**: Autoload managing session and wallet coin transactions.
- **`VehicleRegistry.gd`**: Global registry mapping vehicle IDs (`blue_flame_truck`, `orc_racer`, `trophy_truck`, `dune_buggy`) to their respective `.tscn` scenes, base stats, and preview artwork.

### C. Active Vehicle Controller & Wheel Visuals (Bharath & Nagatheran Ownership)
- **Script:** `scripts/vehicle/VehicleController.gd`.
- **RigidBody2D Wheels:** `RearWheel` and `FrontWheel` connected via `PinJoint2D` with softness `0.6 - 0.65`.
- **Dynamic Suspension:** `_update_suspension_struts()` dynamically computes local wheel offsets and updates `Line2D` struts and `RearShock`/`FrontShock` sprites.
- **Physics Shapes:** Circular collision shapes (`CircleShape2D`) with radius 18px–22px closely match tire sprite visual radii (21.6px in Blue Flame Truck, 18.0px in Dune Buggy). Zero ground-contact clipping.

### D. Shared HUD & Controls Inspection
- **Shared HUD:** `scenes/ui/HUD.tscn` (used in Endless Mode) already positioned `NitroButton` on the bottom-left above the brake pedal.
- **Indian Roads HUD:** `scenes/modes/indian_roads/IndianRoadsHUD.tscn` placed `NitroButton` at `Vector2(980, 590)` (lower right).
- **Required Action:** Relocate `NitroButton` in `IndianRoadsHUD.tscn` to `Vector2(40, 420)` with `NitroHint` at `Vector2(30, 395)`, ensuring an ergonomic vertical layout on the left side above `BrakeButton` at `Vector2(40, 560)` with zero hitbox overlap.

### E. Pause Menu & Freeze Bug Inspection
- **Script:** `scripts/ui/PauseMenuController.gd`.
- **Defect Identified:** `PauseMenuController.gd` lacked declarations for `resume_pressed`, `restart_pressed`, and `main_menu_pressed`.
- **Failure Chain:** In Indian Roads mode, `game_manager_ref` is null. When Resume was clicked, `PauseMenuController` hid the UI and called `get_tree().paused = false`, but did NOT emit `resume_pressed`. As a result, `IndianRoadsController.current_state` remained stuck in `ModeState.PAUSED` forever, causing vehicle physics and camera processing to freeze indefinitely.
- **Resolution Plan:** Declare and emit `resume_pressed`, `restart_pressed`, `main_menu_pressed` in `PauseMenuController.gd`, and set `ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS`.

### F. Pink Placeholder Object Audit
- **Asset Identified:** `assets/indian_locations/tamil_nadu/vegetation/shrub_tamil_bougainvillea_pink.png`.
- **Origin:** Generated in `scripts/generation/gen_tamil_nadu.py` lines 464–475 as 7 hardcoded magenta circles (`rgb(0.92, 0.15, 0.55)`).
- **Resolution Plan:** Replaced with an organic tropical green shrub texture featuring multi-layer leafy canopies and natural woody branches. Zero neon circles.

### G. Currency & Fuel System Audit
- **Coin Pickup:** `scenes/pickups/Coin.tscn` / `scripts/pickups/Coin.gd` (Area2D layer 4/mask 2, bobbing animation, sound, popup).
- **Fuel Pickup:** `scenes/pickups/FuelPickup.tscn` / `scripts/pickups/FuelPickup.gd` (Area2D layer 4/mask 2, 6-frame animated canister, vapor particles, calls `refuel(35.0)`).
- **Vehicle Fuel Logic:** `VehicleController.gd` already implements fuel consumption, fuel burn rate, sputtering warnings, and empty fuel power cutoff.
- **Integration Plan:** Enable `consumes_fuel = true` in `IndianRoadsController.gd`. Add `FuelBar` and `NitroBar` to `IndianRoadsHUD.tscn`. Spawn coin patterns and fuel canisters along `IndianRoadTerrainV2.gd`.
