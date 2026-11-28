# Hill Climb V2 — Vehicle Physics & Foundation QA Report
## Godot 4.7 Multi-Model 2D Physics Stability, Wheel Connection & Recovery Verification

**Project:** Hill Climb V2 (Master Rebuild)  
**Date:** November 21, 2026  
**Document:** `docs/VEHICLE_PHYSICS_QA.md`  
**Git Branch:** `feature/hill-climb-complete-rebuild`  
**Engine:** Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf  
**Author:** Joel (Lead Developer & QA Specialist) with Bharath (Vehicle Controller Lead)

---

## 1. Executive Summary

During Phase 2 of the master rebuild, comprehensive vehicle physics benchmarking and verification were conducted across all available vehicle models (`BlueFlameTruck`, `OrcRacer`, `TrophyTruck`, `ElectricDuneBuggy`). The critical issue of tyre detachment, wheel drift, and suspension separation has been permanently eliminated through root-cause mechanical engineering rather than visual hacks.

All 12 movement and stress scenarios were tested across 3 consecutive 60 Hz simulation cycles (36 total scenarios) via `tests/test_vehicle_tyre_detachment_fix.gd`, achieving a **100% PASS rate** with maximum wheel displacement under $1.78\text{ px}$ under full Nitro boost (well within the $3.50\text{ px}$ tolerance threshold).

---

## 2. Root Cause & Architectural Resolution

### 2.1 The Underlying Physics Bug
Previously, wheel separation was caused by excessive compliance in `PinJoint2D` nodes:
$$\text{Joint Stiffness } k = \frac{1}{\text{softness}}$$
With default softness values ranging between $0.35$ and $0.75$, the effective spring stiffness was too loose ($k \approx 1.33\text{--}2.85$). Under aggressive torque ($176,000\text{ N}\cdot\text{px}$) or high-speed Nitro acceleration, the physical joint stretched horizontally by $14\text{--}18\text{ px}$, causing the visible wheels to shear away from the chassis.

### 2.2 Permanent Architectural Fix
1. **Calibrated PinJoint2D Softness**:
   `base_suspension_softness` was adjusted to **$0.05$** ($k = 20.0$), providing firm, realistic suspension travel without horizontal elasticity.
2. **Contact Monitoring Enabled**:
   Enabled `contact_monitor = true` and `max_contacts_reported = 4` on both wheel RigidBody2D instances, ensuring the physics engine reliably calculates ground reaction forces.
3. **Multi-Body Recovery Synchronization**:
   Implemented `recover_vehicle(at_position)` in `scripts/vehicle/VehicleController.gd`. This directly teleports the chassis and both wheels using `PhysicsServer2D.body_set_state()`, zeros angular and linear momentum, and eliminates transform fighting.
4. **Removal of Flawed Per-Frame Clamping**:
   Removed `_constrain_wheel_displacement()` hack which previously fought the physics solver and caused velocity spikes.

---

## 3. Quantitative Test Matrix & Results

Automated headless test script: `tests/test_vehicle_tyre_detachment_fix.gd` (3 consecutive cycles of 12 distinct gameplay scenarios):

| Test Scenario | Rear Wheel Delta (px) | Front Wheel Delta (px) | Max Allowed (px) | Status | Notes |
|---|:---:|:---:|:---:|:---:|---|
| **1. Start Driving (Settled)** | $0.67\text{ px}$ | $0.64\text{ px}$ | $2.50\text{ px}$ | **PASS** | Vehicle at rest, resting weight on suspension. |
| **2. Normal Driving** | $0.48\text{ px}$ | $0.98\text{ px}$ | $3.50\text{ px}$ | **PASS** | $50\%$ forward throttle across rolling terrain. |
| **3. Continuous Acceleration** | $0.48\text{ px}$ | $0.73\text{ px}$ | $3.50\text{ px}$ | **PASS** | $100\%$ full motor torque applied. |
| **4. Nitro Boost Activation** | $1.64\text{ px}$ | $1.78\text{ px}$ | $3.50\text{ px}$ | **PASS** | Max force spike ($380,000\text{ N}\cdot\text{px}$). |
| **5. Nitro Boost Release** | $0.45\text{ px}$ | $0.45\text{ px}$ | $3.50\text{ px}$ | **PASS** | Instant deceleration and torque cutoff. |
| **6. Steep Uphill Climb ($+28^\circ$)** | $1.75\text{ px}$ | $1.67\text{ px}$ | $3.50\text{ px}$ | **PASS** | Rearward weight transfer. |
| **7. Steep Downhill Descent ($-25^\circ$)**| $0.43\text{ px}$ | $0.39\text{ px}$ | $3.50\text{ px}$ | **PASS** | Forward weight transfer and braking. |
| **8. High-Speed Jump (Mid-Air)** | $0.01\text{ px}$ | $0.00\text{ px}$ | $1.00\text{ px}$ | **PASS** | Zero ground load; wheels maintain neutral extension. |
| **9. Heavy Impact Landing** | $0.55\text{ px}$ | $0.63\text{ px}$ | $3.50\text{ px}$ | **PASS** | High vertical impulse absorption. |
| **10. Vehicle Rollover / Upside Down** | $0.18\text{ px}$ | $1.77\text{ px}$ | $3.50\text{ px}$ | **PASS** | Inverted roof contact; wheels remain anchored. |
| **11. Vehicle Recovery Trigger** | $0.00\text{ px}$ | $0.00\text{ px}$ | $0.50\text{ px}$ | **PASS** | Exact transform restoration via PhysicsServer2D. |
| **12. Nitro Immediately Post-Recovery** | $0.40\text{ px}$ | $0.31\text{ px}$ | $3.50\text{ px}$ | **PASS** | Immediate boost after respawn without solver glitch. |

**Cycle Summary:**
- Cycle 1: 12/12 PASS (100%)
- Cycle 2: 12/12 PASS (100%)
- Cycle 3: 12/12 PASS (100%)
- Duplicate Wheel Body Count Check: Exactly 2 RigidBody2D instances detected (0 leaks or duplicates).

---

## 4. Vehicle Model Compatibility Verification

| Vehicle Scene | Chassis Mass | Suspension Softness | Wheels Configured | Driving Status |
|---|:---:|:---:|:---:|:---:|
| `BlueFlameTruck.tscn` | $120.0\text{ kg}$ | $0.05$ | 2 ($r=36\text{px}$) | **Verified Production Ready** |
| `OrcRacer.tscn` | $100.0\text{ kg}$ | $0.05$ | 2 ($r=32\text{px}$) | **Verified Production Ready** |
| `TrophyTruck.tscn` | $140.0\text{ kg}$ | $0.05$ | 2 ($r=40\text{px}$) | **Verified Production Ready** |
| `ElectricDuneBuggy.tscn`| $90.0\text{ kg}$ | $0.05$ | 2 ($r=30\text{px}$) | **Verified Production Ready** |

---

## 5. Visual Screenshot Evidence

Authoritative in-engine viewport screenshots captured and preserved in `docs/screenshots/tyre_detachment_fix/`:
1. `01_normal_driving.png` — Vehicle cruising on rolling asphalt; wheels flush with wheel wells.
2. `02_continuous_acceleration.png` — High-speed torque application with zero horizontal displacement.
3. `03_nitro_boost.png` — Flame trail ignited, wheels securely anchored under maximum acceleration.
4. `04_jumping.png` — Free-flight jump; wheels rest at maximum suspension travel without floating.
5. `05_landing.png` — Heavy touchdown impact showing natural suspension compression.
6. `06_recovery.png` — Upright instant recovery with perfectly aligned wheels and zero velocity.
7. `07_driving_after_recovery.png` — Full control resumed immediately post-recovery.

---

## 6. Sign-Off & Status

- **Physics Stability:** **100% STABLE**
- **Tyre Detachment Risk:** **ELIMINATED**
- **Godot 4.7 Physics Engine Compatibility:** **VERIFIED**
