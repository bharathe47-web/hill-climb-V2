# Shared Game Interfaces & Architecture Contract

**Version:** 1.0.0 (Phase 2 Baseline)
**Author:** Bharath (Team Leader & Core Foundation)
**Date:** 2026-11-13
**Status:** Official Team Contract

---

## 1. Purpose & Scope

This document establishes the official integration contract between **Bharath** (Core Systems, Garage, Survival Controller), **Daniel** (Endless Map), **Joel** (Indian Roads, Survival Obstacle Components), and **Nagatheran** (Garage Car Assets).

Every teammate must adhere to these contracts to prevent merge conflicts, duplicate managers, and broken game loops.

To maintain strict architectural honesty, every API is categorized as one of the following:
- `[IMPLEMENTED & VERIFIED]`: Backed by active code, signals, and tests in the repository.
- `[PROPOSED CONTRACT]`: Defined by Bharath for upcoming module integration; teammates must code against this specification.
- `[PENDING TEAMMATE DEPENDENCY]`: A deliverable expected from Daniel, Joel, or Nagatheran.
- `[PENDING TEAM DECISION]`: A design choice awaiting final team consensus before implementation.

---

## 2. Scene Navigation & Boot Flow

### 2.1 Master Scene Switcher `[IMPLEMENTED & VERIFIED]`
The root scene is `res://scenes/main/Main.tscn` controlled by `MainController` ([Main.gd](file:///home/johnwick/2d-game/cloneeee/hill-climb-2/scripts/core/Main.gd)).
- Hosts a `SceneContainer` node.
- Dynamically swaps active root scenes:
  ```gdscript
  func load_menu() -> void
  func load_game() -> void
  func _switch_scene(new_scene: PackedScene) -> void
  ```
- **Contract for Mode Scenes:** Any mode returning to the menu must emit `return_to_main_menu_requested`, which `MainController` catches to call `load_menu()`.
- **Rule:** Do NOT add a second global SceneManager. All top-level mode routing flows through `MainController`.

---

## 3. Mode Lifecycle & Run State Machine

### 3.1 Run State Ownership `[IMPLEMENTED & VERIFIED]`
`GameManager` ([GameManager.gd](file:///home/johnwick/2d-game/cloneeee/hill-climb-2/scripts/core/GameManager.gd)) is the authoritative source for run states and telemetry:
```gdscript
enum RunState {
    READY,
    PLAYING,
    PAUSED,
    FINISHED
}
```
**Core Signals:**
- `signal run_started`
- `signal run_paused(is_paused: bool)`
- `signal run_finished(final_distance: float, coins: int, reason: String)`
- `signal run_restarted`
- `signal distance_updated(new_distance: float)`
- `signal fuel_updated(current: float, max_fuel: float)`
- `signal coins_updated(count: int)`

### 3.2 Common Mode Lifecycle Contract `[PROPOSED CONTRACT]`
All game modes (Endless Map, Indian Roads, Survival) must interface with run states following these lifecycle methods:
1. `start_mode()`: Initializes mode-specific entities, spawns the shared vehicle, resets counters, and transitions state to `RunState.PLAYING`.
2. `pause_mode(is_paused: bool)`: Toggles process mode and pauses physics without clearing run state.
3. `finish_mode(reason: String)`: Stops vehicle input, preserves final distance/coins, and displays results/game over screen.
4. `restart_mode()`: Cleans up obstacles/segments, resets vehicle to spawn position, resets session fuel/coins, and starts a fresh run.

---

## 4. Shared Vehicle System

### 4.1 Selected Vehicle Source of Truth `[IMPLEMENTED & VERIFIED]`
- **Persistence:** Stored in `user://savegame.json` under key `"selected_vehicle_id"`.
- **Query Method:** `SaveManager.get_selected_vehicle_id() -> String`
- **Fallback:** Defaults to `"blue_flame_truck"`.
- **Rule:** There is exactly ONE selected vehicle for the entire game. Endless Map, Indian Roads, and Survival must all query `SaveManager.get_selected_vehicle_id()`.

### 4.2 Vehicle Catalog & Instantiation `[IMPLEMENTED & VERIFIED]`
`VehicleRegistry` ([VehicleRegistry.gd](file:///home/johnwick/2d-game/cloneeee/hill-climb-2/scripts/vehicle/VehicleRegistry.gd)) manages vehicle metadata and dynamic factory instantiation:
```gdscript
static func get_vehicle_ids() -> Array[String]
# Returns active: ["blue_flame_truck", "orc_racer", "trophy_truck", "dune_buggy"]

static func get_vehicle(id: String) -> Dictionary
static func instantiate_vehicle(id: String) -> VehicleController
```

### 4.3 Vehicle Continuity Protocol for Endless Map `[PROPOSED CONTRACT - DANIEL]`
When the vehicle transitions between Normal Land, Heaven, and Hell:
1. The `VehicleController` instance MUST NOT be freed or re-instantiated.
2. The vehicle’s `global_position` should be smoothly translated or launched via the jump ramp.
3. Existing momentum (`linear_velocity`, `angular_velocity`), remaining `current_fuel`, and active `current_nitro` MUST be preserved.
4. `FollowCamera` will naturally follow the vehicle without camera-target re-binding.

---

## 5. HUD & Telemetry Contract

### 5.1 Telemetry Display `[IMPLEMENTED & VERIFIED]`
`HUDController` ([HUDController.gd](file:///home/johnwick/2d-game/cloneeee/hill-climb-2/scripts/ui/HUDController.gd)) binds directly to `GameManager` and `VehicleController`:
- Automatically receives distance, coins, fuel updates, and nitro energy.
- Renders mobile controls (gas, brake, nitro, pause).

### 5.2 Survival Lives HUD Extension `[PROPOSED CONTRACT - BHARATH]`
For Survival mode, the HUD introduces heart life indicators:
- `signal lives_changed(current_lives: int, max_lives: int)`
- Uses `res://assets/ui/hud/hud_heart_full.png` and `res://assets/ui/hud/hud_heart_empty.png`.
- Renders up to 3 heart containers by default.

---

## 6. Survival Mode Component Contracts

### 6.1 Obstacle Collision Contract `[PROPOSED CONTRACT - JOEL DEPENDENCY]`
Joel creates reusable food obstacle scenes under `scenes/modes/survival/obstacles/` (e.g. Chilli, Rice, Sweets, Vada Pav).
- **Collision Layering:**
  - Obstacles must be `Area2D` or `RigidBody2D` with an `Area2D` hit-box.
  - Collision Layer: `Layer 4 (Hazards)` or dedicated `Area2D` detecting `Layer 2 (Vehicles)`.
- **Hit Reporting Protocol:**
  Obstacles MUST NOT decrement lives, manage game states, or award coins.
  When an obstacle hits the vehicle, it reports the hit by emitting a signal or calling the Survival controller:
  ```gdscript
  # On Obstacle Area2D:
  signal obstacle_hit(obstacle_id: String, hit_position: Vector2)
  ```
- **Controller Authority & Debounce:**
  Bharath's `SurvivalController` catches the hit:
  - Validates that the run is in `RunState.PLAYING`.
  - Checks an invulnerability window (e.g. `0.8s` cooldown) so that chassis + front wheel + rear wheel hitting the same food item in the same frame will only remove **EXACTLY 1 LIFE**.
  - Decrements life: `current_lives -= 1`.
  - Destroys or plays shatter particle animation on the obstacle.
  - If `current_lives == 0`, invokes the extra-life offer or triggers Game Over.

### 6.2 Warning Indicator Contract `[PROPOSED CONTRACT - JOEL DEPENDENCY]`
- Joel creates the visual warning indicator scene under `scenes/modes/survival/obstacles/WarningIndicator.tscn`.
- Visual specification: Ground shadow/marker showing falling food impact location.
- **Controller-Side Spawner Contract:**
  Bharath's `SurvivalController` instantiates the warning at the projected ground `X, Y` coordinate `T` seconds before spawning the falling obstacle.
  Joel's warning scene exposes:
  ```gdscript
  func start_warning(duration: float) -> void
  ```

---

## 7. Rewarded-Ad Seam & Reward Verification

### 7.1 Decoupled Reward Provider Interface `[PROPOSED CONTRACT]`
To allow offline testing and decouple the project from specific third-party ad SDKs:
```gdscript
class_name RewardProvider
extends RefCounted

## Requests a rewarded ad action. Invokes callback with {"success": bool, "reward_type": String}
func request_reward(reward_type: String, callback: Callable) -> void:
    # Overridden by specific provider or mock test seam
    pass
```

### 7.2 Strict Reward Grant Rules:
1. An extra life is granted IF AND ONLY IF `result.get("success", false) == true`.
2. Skipped, closed, cancelled, or failed ads grant **0 lives**.
3. Extra life offer is limited to **exactly 1 use per run**:
   - `extra_life_used: bool = false` at start of run.
   - When 3 lives are lost and an ad is verified: `current_lives = 1`, `extra_life_used = true`.
   - If that 1 extra life is lost, Game Over is immediate. No second ad offer is permitted in that run.
   - `extra_life_used` resets ONLY when starting a fresh run.

---

## 8. Team File Ownership Boundaries

```text
===============================================================================
DIRECTORY / FILE                             OWNER      PERMISSION
===============================================================================
project.godot                                Bharath    Core settings & input
scenes/main/                                 Bharath    Main entry & menus
scripts/core/                                Bharath    Game, Save, Main, Camera
scripts/vehicle/                             Bharath    Vehicle physics & registry
scenes/ui/ & scripts/ui/                     Bharath    HUD & UI systems
scenes/modes/garage/                         Bharath    Garage programming
scenes/modes/survival/survival.tscn          Bharath    Survival mode controller
scripts/modes/survival/                      Bharath    Survival game logic
docs/team/                                   Bharath    Team interfaces & docs
tests/                                       Bharath    Test suites & regressions
-------------------------------------------------------------------------------
scenes/modes/endless_map/                    Daniel     Endless Map scenes
scripts/modes/endless_map/                   Daniel     Endless Map logic
assets/environments/                         Daniel     Heaven & Hell art
-------------------------------------------------------------------------------
scenes/modes/indian_roads/                   Joel       Indian Roads scenes
scripts/modes/indian_roads/                  Joel       Indian Roads logic
resources/routes/                            Joel       Route data & checkpoints
assets/indian_locations/                     Joel       Location landmarks
scenes/modes/survival/obstacles/             Joel       Food obstacles & warning
scripts/components/survival_obstacles/       Joel       Obstacle components
assets/obstacles/                            Joel       Food obstacle art
-------------------------------------------------------------------------------
assets/vehicles/garage/                      Nagatheran 2D Side-view car images
===============================================================================
```

---

## 9. Unresolved Decisions & Blockers

| Item | Status | Impact / Next Action |
|---|---|---|
| **Vehicle Unlock Economy** | `[PENDING TEAM DECISION]` | Are cars unlocked via Coins, Rewarded Ads, or Distance Milestones? (Default in Phase 2: keep all registered cars selectable or marked in development). |
| **Rewarded Ad SDK** | `[PENDING TEAM DECISION]` | AdMob, Unity Ads, or open-source plugin? (Phase 2 uses internal decoupled mock seam). |
| **Joel's Obstacle Scenes** | `[PENDING TEAMMATE DEPENDENCY]` | Joel must deliver obstacle scenes to `scenes/modes/survival/obstacles/`. Phase 2 uses a test double. |
| **Daniel's Multi-Environment Ramps** | `[PENDING TEAMMATE DEPENDENCY]` | Daniel must deliver Heaven/Hell transition segments. Phase 2 keeps existing procedural countryside intact. |
| **Nagatheran's Garage Car Assets** | `[PENDING TEAMMATE DEPENDENCY]` | Nagatheran must submit car images with `source.txt` licenses. |
