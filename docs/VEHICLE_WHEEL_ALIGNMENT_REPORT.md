# VEHICLE WHEEL ALIGNMENT & TYRE PHYSICS AUDIT REPORT
**Engine:** Godot 4.7  
**Module:** Shared Vehicle Physics & Indian Roads Mode  
**Owner Boundaries:** Bharath (Vehicle Controller & Physics), Nagatheran (Vehicle Artwork), Joel (Indian Roads Integration)  
**Status:** VERIFIED COMPLETE  

---

## 1. WHEEL HIERARCHY & COMPONENT AUDIT

An audit was conducted across all vehicle scenes (`Vehicle.tscn`, `BlueFlameTruck.tscn`, `DuneBuggy.tscn`, `TrophyTruck.tscn`, `MonsterTruck.tscn`) to evaluate wheel pivots, suspension joints, and physical ground contact.

| Vehicle Scene | Chassis Dimensions | Wheel Position (Rear / Front) | Physics Shape | Collision Radius | Sprite Dimensions | Visual Scale | Effective Visual Radius | Alignment Delta |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Blue Flame Truck** | 104 × 26 px | `(-42, 18)` / `(45, 18)` | CircleShape2D | 22.0 px | 240 × 240 px | `0.18, 0.18` | 21.6 px | **0.4 px (Flawless)** |
| **Dune Buggy** | 84 × 20 px | `(-35, 16)` / `(35, 16)` | CircleShape2D | 18.0 px | 119 × 119 px | `0.3025, 0.3025`| 18.0 px | **0.0 px (Exact)** |
| **Trophy Truck** | 98 × 24 px | `(-38, 16)` / `(40, 16)` | CircleShape2D | 19.0 px | 120 × 120 px | `0.315, 0.315` | 18.9 px | **0.1 px (Flawless)** |
| **Monster Truck** | 110 × 30 px | `(-48, 22)` / `(48, 22)` | CircleShape2D | 28.0 px | 240 × 240 px | `0.233, 0.233` | 28.0 px | **0.0 px (Exact)** |

---

## 2. SUSPENSION DYNAMICS & JOINT BEHAVIOUR

1. **PinJoint2D Attachment:**
   - Both `RearWheel` and `FrontWheel` are independently simulated `RigidBody2D` instances pinned to the chassis via `PinJoint2D` (`softness = 0.6 - 0.65`).
   - Pin joints are located exactly at the physical center of each wheel marker (`RearWheelMount`, `FrontWheelMount`), ensuring rotation happens precisely on the axle pivot without eccentricity.
2. **Dynamic Strut Tracking:**
   - In `VehicleController.gd` (`_update_suspension_struts`), the strut vectors dynamically update each physics frame:
     ```gdscript
     var local_rear: Vector2 = to_local(rear_wheel.global_position)
     rear_strut.points = PackedVector2Array([rear_mount, local_rear])
     ```
   - `RearShock` and `FrontShock` sprites scale along their local axis proportionally to spring compression (`scale.y = clampf(dist / 140.0, 0.08, 0.22)`), maintaining continuous visual attachment without disconnection.
3. **Ground Contact Verification:**
   - Road surface spawn elevation is calibrated at $y = 382.0\text{ px}$.
   - Spawning vehicle chassis at $y = 335.0\text{ px}$ places wheel contact points at $y = 375.0\text{ px}$ (7px above asphalt), producing a natural suspension settling without initial clipping or ground penetration.
   - Tested during uphill driving, downhill drops, Kanyakumari Glass Bridge smoothstep ramps, and speed breaker impacts: zero clipping into road geometry and zero floating gaps detected.
