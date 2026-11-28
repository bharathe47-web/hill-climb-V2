# Garage, Vehicle Selection & Economy Progression Report

**Project:** Hill Climb V2  
**Engine:** Godot Engine v4.7.2.stable  
**Subsystem:** Vehicle Showroom, Garage Upgrades & Player Economy  
**Document:** `docs/GARAGE_AND_PROGRESSION_REPORT.md`  
**Working Branch:** `feature/hill-climb-complete-rebuild`  
**Lead / Author:** Senior Godot 4.7 Gameplay Engineer & UI Specialist  
**Collaborators:** Bharath (Shared Progression Lead), Nagatheran (Lead Vehicle Artist)  
**Status:** **PHASE 1 IMPLEMENTED & VERIFIED**

---

## 1. Overview & Objectives

In previous project iterations, two conflicting Garage implementations existed:
1. An inline vehicle selection carousel inside [MainMenu.tscn](file:///home/joel/Documents/game/hill-climb-V2/scenes/main/MainMenu.tscn).
2. A legacy standalone [GarageMenu.tscn](file:///home/joel/Documents/game/hill-climb-V2/scenes/ui/GarageMenu.tscn) referencing non-existent vehicle textures and communicating with an unregistered singleton (`GameState`).

In Phase 1, the Garage architecture was completely consolidated into a unified showroom pipeline:
- [GarageMenu.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/ui/GarageMenu.gd) was rewritten to query [VehicleRegistry.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/vehicle/VehicleRegistry.gd) and persist to [SaveManager.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/core/SaveManager.gd).
- The main menu mode card "Garage" and button "Change Vehicle" both seamlessly connect to this unified system.
- Selected vehicles and upgrade levels persist across game restarts and properly instantiate in all modes.

---

## 2. Vehicle Catalog & Specification

All four playable vehicles are registered in [VehicleRegistry.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/vehicle/VehicleRegistry.gd) with verified textures and scenes:

| Vehicle ID | Display Name | Unlock Cost | Mass | Scene Path | Preview Texture | Role & Handling Characteristic |
|---|---|:---:|:---:|---|---|---|
| `blue_flame_truck` | **Blue Flame Truck** | 0 Coins (Default) | 10.0 | [scenes/vehicle/BlueFlameTruck.tscn](file:///home/joel/Documents/game/hill-climb-V2/scenes/vehicle/BlueFlameTruck.tscn) | [vehicle_assembled_preview.png](file:///home/joel/Documents/game/hill-climb-V2/assets/vehicles/blue_flame_truck/vehicle_assembled_preview.png) | Heavy all-rounder powerhouse. Excellent traction and stability on steep rolling inclines. |
| `orc_racer` | **Orc Racer** | 350 Coins | 7.5 | [scenes/vehicle/OrcRacer.tscn](file:///home/joel/Documents/game/hill-climb-V2/scenes/vehicle/OrcRacer.tscn) | [body.png](file:///home/joel/Documents/game/hill-climb-V2/assets/vehicles/orc_racer/body.png) | High-revving, agile sprint buggy. Fast rotational recovery for airborne flips and stunts. |
| `trophy_truck` | **Trophy Truck** | 500 Coins | 9.0 | [scenes/vehicle/TrophyTruck.tscn](file:///home/joel/Documents/game/hill-climb-V2/scenes/vehicle/TrophyTruck.tscn) | [assembled.png](file:///home/joel/Documents/game/hill-climb-V2/assets/vehicles/trophy_truck/assembled.png) | Rugged desert baja truck. Long suspension travel and high fuel capacity. |
| `dune_buggy` | **Electric Dune Buggy** | 450 Coins | 6.0 | [scenes/vehicle/DuneBuggy.tscn](file:///home/joel/Documents/game/hill-climb-V2/scenes/vehicle/DuneBuggy.tscn) | [body.png](file:///home/joel/Documents/game/hill-climb-V2/assets/vehicles/alternate/girl_buggy/body.png) | Ultralight tubular roll-cage racer. Rapid acceleration and nimble handling. |

---

## 3. Stat Upgrades & Progression Mechanics

Each vehicle supports 5 upgradeable performance attributes. Stat upgrades are purchased using collected coins and scale linearly with diminishing costs:

| Upgrade Tier | Coin Cost | Torque Multiplier (Engine) | Friction Multiplier (Tires) | Joint Softness (Suspension) | Fuel Tank Multiplier |
|:---:|:---:|:---:|:---:|:---:|:---:|
| **Level 1** | Baseline (0) | $1.00\times$ | $1.00\times$ | $0.050$ | $1.00\times$ |
| **Level 2** | 50 Coins | $1.15\times$ | $1.12\times$ | $0.042$ | $1.20\times$ |
| **Level 3** | 120 Coins | $1.30\times$ | $1.24\times$ | $0.034$ | $1.40\times$ |
| **Level 4** | 250 Coins | $1.45\times$ | $1.36\times$ | $0.026$ | $1.60\times$ |
| **Level 5 (MAX)** | 500 Coins | $1.60\times$ | $1.48\times$ | $0.018$ | $1.80\times$ |

### Mathematical Application in Gameplay:
Upon vehicle instantiation in [VehicleController.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/vehicle/VehicleController.gd):
```gdscript
func _recalculate_upgrades() -> void:
    # 1. Engine torque scaling
    motor_torque = base_motor_torque * (1.0 + (engine_level - 1) * 0.15)
    # 2. Tire grip scaling
    var eff_friction: float = base_wheel_friction * (1.0 + (tires_level - 1) * 0.12)
    # 3. Suspension firmness tightening
    var eff_softness: float = maxf(0.01, base_suspension_softness - (suspension_level - 1) * 0.008)
    rear_joint.softness = eff_softness
    front_joint.softness = eff_softness
    # 4. Fuel capacity expansion
    max_fuel = base_max_fuel * (1.0 + (fuel_tank_level - 1) * 0.20)
```

---

## 4. Verification Evidence

Automated headless verification suite [tests/test_core_architecture_and_navigation.gd](file:///home/joel/Documents/game/hill-climb-V2/tests/test_core_architecture_and_navigation.gd) executed and passed 100%:
1. `GarageMenu` correctly displays total coins from `SaveManager`.
2. Upgrading engine increments level and reduces bank balance by the exact cost (e.g. 50 coins).
3. Purchasing locked vehicle (`orc_racer`, 350 coins) marks `is_vehicle_unlocked("orc_racer") = true` and updates `SaveManager.selected_vehicle_id = "orc_racer"`.
4. Gameplay instantiation in Endless and Indian Roads instantiates the updated selected vehicle with its upgraded physics values.
