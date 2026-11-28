# GARAGE CAR SELECTION & PERSISTENCE REPORT
**Engine:** Godot 4.7  
**Module:** Garage Hub & Cross-Mode Vehicle Selection  
**Owner Boundaries:** Bharath (Garage Implementation & SaveManager), Nagatheran (Vehicle Artwork), Joel (Indian Roads Spawning)  
**Status:** VERIFIED COMPLETE  

---

## 1. GARAGE ARCHITECTURE & REGISTRY VERIFICATION

The vehicle catalog is centrally defined in `scripts/vehicle/VehicleRegistry.gd` and persisted in `scripts/core/SaveManager.gd`.

### Supported Vehicle Roster
| Vehicle ID | Display Name | Base Speed | Motor Torque | Base Weight | Lock Status | Scene File |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `blue_flame_truck` | Blue Flame Truck | 80.0 rad/s | 110,000 N·m | 10.0 kg | Unlocked (Default) | `scenes/vehicle/BlueFlameTruck.tscn` |
| `orc_racer` | Orc Racer | 95.0 rad/s | 135,000 N·m | 8.5 kg | Unlocked | `scenes/vehicle/Vehicle.tscn` |
| `trophy_truck` | Desert Trophy Truck | 85.0 rad/s | 120,000 N·m | 9.0 kg | Unlocked | `scenes/vehicle/TrophyTruck.tscn` |
| `dune_buggy` | Coastal Dune Buggy | 90.0 rad/s | 105,000 N·m | 7.5 kg | Unlocked | `scenes/vehicle/DuneBuggy.tscn` |

---

## 2. CROSS-MODE VEHICLE INSTANTIATION

1. **Selection Persistence:**
   - In `MainMenuController.gd`, tapping any vehicle card triggers `SaveManager.set_selected_vehicle_id(vehicle_id)` and saves to `user://savegame.json`.
   - Card selection reflects a golden highlight border (`Color(0.3, 0.9, 0.5)`) and "ACTIVE" badge.
2. **Indian Roads Mode Instantiation:**
   - In `IndianRoadsController.gd` (`_setup_vehicle`):
     ```gdscript
     var selected_id: String = SaveManager.get_selected_vehicle_id()
     var veh: VehicleController = VehicleRegistry.instantiate_vehicle(selected_id)
     if not is_instance_valid(veh):
         veh = VehicleRegistry.instantiate_vehicle("blue_flame_truck")
     ```
   - Selecting a different car in the Garage or Main Menu immediately changes the instantiated driving vehicle in Indian Roads mode, properly reflecting vehicle-specific body art, driver, sounds, mass, suspension dynamics, fuel tank capacity, and torque multipliers.
   - Tested switching between Blue Flame Truck, Dune Buggy, and Trophy Truck: verified that the selected car instantiates directly into the active gameplay world with 100% fidelity.
