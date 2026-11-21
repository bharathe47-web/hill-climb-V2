# TOUCH CONTROLS & NITRO STRATEGIC SYSTEM REPORT
**Engine:** Godot 4.7  
**Module:** `IndianRoadsHUD.tscn` & `VehicleController.gd`  
**Responsible Owner:** Joel (Indian Roads HUD) & Bharath (Vehicle Controller)  
**Status:** VERIFIED COMPLETE  

---

## 1. TOUCH CONTROLS RESTRUCTURING (STEP 3)

### Layout Specification
- **Brake Control:** Positioned on the lower-left at `Vector2(40, 560)` (scale 0.9, 0.9), with touch hint `[A / ←] BRAKE` at `(30, 675)`.
- **Nitro Boost Control:** Relocated from bottom-right (`980, 590`) to the **left side above brake** at `Vector2(40, 420)` (scale 0.85, 0.85), with hint `[SPACE] BOOST` at `(30, 395)`.
- **Gas Pedal Control:** Kept on the lower-right at `Vector2(1110, 560)` (scale 0.9, 0.9), with hint `[D / →] GAS` at `(1100, 675)`.

### Hitbox & Safe Area Analysis
- **Vertical Spacing:**
  - Nitro button bounds: Y = 420 to 505 px.
  - Brake button bounds: Y = 560 to 650 px.
  - Clearance between controls: **55 px separation buffer**, completely preventing unintended simultaneous presses on mobile capacitive screens.
- **Left/Right Thumb Separation:** Left thumb controls Brake + Boost; right thumb controls Throttle. Desktop keyboard bindings (`Space`, `A`/`D`, `Left`/`Right`) remain 100% active.

---

## 2. NITRO ENERGY LIMIT & RECHARGE DYNAMICS (STEP 9)

### Physical Tuning Parameters
- `max_nitro = 100.0`
- `nitro_consumption_rate = 25.0 / sec` (4.0 seconds continuous full boost).
- `nitro_recharge_rate = 14.0 / sec` (7.1 seconds for full recharge from zero).
- `nitro_min_activation_energy = 8.0` (prevents jittery micro-pulsing when nearly empty).
- `nitro_boost_force = 18000.0 N` with `nitro_torque_multiplier = 1.6` and `nitro_max_speed_multiplier = 1.35`.

---

## 3. LANDMARK DISCOVERY ZONE IMPLEMENTATION

To eliminate the exploit of skipping major cultural monuments using unlimited boost:
1. **Approach Detection:** `IndianRoadsController._process()` continuously monitors vehicle distance to waypoints.
2. **Speed Restriction Zone:** When the vehicle is within $\pm 450\text{ px}$ of a major landmark, the vehicle enters a Discovery Zone.
3. **Boost Lockout:** `veh.set_nitro_active(false)` is enforced, and the HUD Nitro button visually dims (`modulate = Color(0.5, 0.5, 0.5, 0.4)`).
4. **Resumption:** Normal vehicle driving throttle remains 100% responsive. As soon as the vehicle clears the $450\text{ px}$ exit boundary, nitro boost becomes fully re-enabled.

---

## 4. SCREENSHOT VERIFICATION
- `docs/screenshots/gameplay_tamil_nadu.png` — Proves left-side Nitro button layout above Brake.
- `docs/screenshots/nitro_active.png` — Proves active cyan flame, particle burst, and draining nitro meter.
- `docs/screenshots/nitro_empty.png` — Proves exhausted nitro meter, cooldown state, and recharge progression.
- `docs/screenshots/landmark_discovery.png` — Proves landmark discovery banner, disabled nitro button state, and highway cruising.
