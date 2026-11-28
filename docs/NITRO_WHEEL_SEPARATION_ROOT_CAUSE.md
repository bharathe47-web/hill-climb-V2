# NITRO WHEEL SEPARATION ROOT CAUSE REPORT
**Project:** Hill Climb V2 | Indian Roads 2D  
**Engine:** Godot 4.7.2.stable  
**Subsystem:** Vehicle Physics & Nitro Controller  
**Author:** Vehicle Physics & Gameplay Lead  
**Date:** November 21, 2026  
**Status:** FULLY DIAGNOSED & REPRODUCED  

---

## 1. Executive Summary

During gameplay, when activating **Nitro Boost**, vehicle tyres exhibited severe physical and visual separation from the vehicle chassis. Under extreme operating conditions—specifically mid-air jumps, nose-down airborne pitch, high-speed impact landings, and continuous boost—the front and rear wheels separated by up to **13.90 pixels** from their chassis suspension mounts.

This report provides the exhaustive mathematical, architectural, and diagnostic root cause analysis demonstrating why the separation occurred and how it was successfully reproduced in Godot 4.7.

---

## 2. Quantitative Reproduction Findings

An automated diagnostic test runner (`tests/reproduce_nitro_wheel_separation.gd` and `tests/trace_dunebuggy_landing.gd`) was executed across all registered vehicles:
- **Blue Flame Truck** ($10.0\text{ kg}$)
- **Orc Racer** ($7.5\text{ kg}$)
- **Trophy Truck** ($9.0\text{ kg}$)
- **Dune Buggy** ($6.0\text{ kg}$)

### Wheel Displacement Matrix Prior to Fix (Worst Case Displacements)

| Test Scenario | Blue Flame Truck | Orc Racer | Trophy Truck | Dune Buggy | Status |
|---|---|---|---|---|---|
| 1. Start Route (Settled) | $0.67\text{ px}$ | $0.61\text{ px}$ | $0.55\text{ px}$ | $0.36\text{ px}$ | PASS |
| 2. Normal Acceleration | $0.98\text{ px}$ | $1.13\text{ px}$ | $0.65\text{ px}$ | $0.43\text{ px}$ | PASS |
| 3. Nitro Boost Engaged | $1.29\text{ px}$ | $0.42\text{ px}$ | $0.67\text{ px}$ | $0.55\text{ px}$ | PASS |
| 4. Continuous Nitro Hold | $1.27\text{ px}$ | $0.68\text{ px}$ | $1.33\text{ px}$ | $0.60\text{ px}$ | PASS |
| 6. Repeat Rapid Nitro Bursts | $1.12\text{ px}$ | $0.38\text{ px}$ | $1.78\text{ px}$ | $2.03\text{ px}$ | PASS |
| 8. Downhill Nitro Sprint | $1.87\text{ px}$ | $0.99\text{ px}$ | $2.17\text{ px}$ | $2.38\text{ px}$ | PASS |
| 9. Mid-Air Nitro Jump | $0.21\text{ px}$ | $0.22\text{ px}$ | $0.22\text{ px}$ | $0.04\text{ px}$ | PASS |
| **10. Impact Landing with Nitro** | $0.24\text{ px}$ | $0.09\text{ px}$ | $0.49\text{ px}$ | **13.90 px** | **CRITICAL FAIL (DETACHED)** |
| 11. Rollover (Inverted) | $0.66\text{ px}$ | $0.03\text{ px}$ | $2.10\text{ px}$ | $2.26\text{ px}$ | PASS |
| 12. Recovery Triggered | $0.00\text{ px}$ | $0.00\text{ px}$ | $0.00\text{ px}$ | $0.00\text{ px}$ | PASS |

On the **Dune Buggy** ($6.0\text{ kg}$ chassis), Scenario 10 produced a catastrophic wheel detachment of **13.90 px**, causing the front wheel to float visibly detached from the body.

---

## 3. Root Cause 1: Excessive Nitro Boost Force Magnitude

In `scripts/vehicle/VehicleController.gd` line 83:
```gdscript
@export var nitro_boost_force: float = 18000.0
```

### Physics Impact:
- Chassis mass for `DuneBuggy` is $6.0\text{ kg}$.
- By Newton's second law ($F = m \cdot a$):
  $$a = \frac{18000\text{ N}}{6.0\text{ kg}} = 3000\text{ px/s}^2 \approx 30.6\text{ G}$$
- An acceleration of over $30\text{ Gs}$ on a light vehicle is disproportionate for 2D rigid-body constraint solvers. When this thrust encounters ground friction or collision restitution, instantaneous constraint reaction forces exceeded the solver's compliance limits.

---

## 4. Root Cause 2: Airborne Nose-Down Pitch Shearing

In `scripts/vehicle/VehicleController.gd` line 424:
```gdscript
if is_nitro_active:
    apply_central_force(transform.x * nitro_boost_force)
```

### Frame-by-Frame Diagnostic Trace (Frame 11 of Impact Landing):
1. **Airborne State:** Vehicle jumped off a hill crest, rotating forward into a nose-down angle ($\theta \approx 76^\circ = 1.32\text{ rad}$).
2. **Directional Vector:**
   $$\text{transform.x} = (\cos 76^\circ, \sin 76^\circ) \approx (0.24, 0.97)$$
3. **Downward Impulse:** The $18,000\text{ N}$ force was directed almost vertically downward into the road ($F_y \approx 17,460\text{ N}$).
4. **Collision Velocity:** The vehicle reached a vertical descent velocity of $v_y = 1260.4\text{ px/s}$.
5. **Impact Reaction:** The front wheel impacted the ground colliders while the $18,000\text{ N}$ engine force drove the chassis downward into the wheel, shearing the `PinJoint2D` anchor.

---

## 5. Root Cause 3: PinJoint2D Softness (Constraint Compliance)

In `scenes/vehicle/*.tscn`, `PinJoint2D` nodes were assigned:
```ini
softness = 0.05
```

### Godot 2D Physics Joint Compliance:
- In Godot 4's 2D physics solver, `PinJoint2D.softness` defines the elastic compliance ($C = \text{softness}$). Effective stiffness is inversely proportional ($k \approx 1/\text{softness} = 20$).
- At $0.05$, the joint allows significant elongation under high forces. Under impact impulses of $> 15,000\text{ N}\cdot\text{s}$, the joint elongated beyond $10\text{ px}$, causing the visible gap between chassis mount and wheel hub.
- Tuning softness to $0.01$ raises stiffness 5-fold ($k = 100$), holding the anchor firmly attached under identical impact loads.

---

## 6. Root Cause 4: Upgrade Recalculation Overriding Scene Changes

In `scripts/vehicle/VehicleController.gd` line 606:
```gdscript
var eff_softness: float = maxf(0.01, base_suspension_softness - (suspension_level - 1) * 0.008)
if rear_joint:
    rear_joint.softness = eff_softness
if front_joint:
    front_joint.softness = eff_softness
```

- When `base_suspension_softness` was initialized to $0.05$, any attempt to harden `PinJoint2D.softness` in the `.tscn` file was overwritten during `_ready()` when `_recalculate_upgrades()` executed.
- At Level 1 suspension upgrades, `eff_softness` reverted back to $0.05$, reintroducing the elasticity.

---

## 7. Root Cause 5: Lack of Wheel Joint Drift Clamping

- Prior to this fix, there was no runtime safety check in `_physics_process()` to clamp solver drift if extreme multi-body collision impulses pushed bodies apart.
- Without an explicit maximum displacement clamp, solver drift could accumulate over several consecutive physics frames if the vehicle was wedged into a sharp pothole or steep rock angle under continuous Nitro boost.

---

## 8. Conclusion

The nitro wheel separation was caused by the compound effect of:
1. $18,000\text{ N}$ unscaled nitro force producing up to $30\text{ Gs}$ on lightweight chassis.
2. Unmitigated vertical downward thrust during airborne nose-down attitudes.
3. High joint softness compliance ($0.05$).
4. Dynamic upgrade recalculation resetting scene parameters.
5. Absence of a runtime physics displacement clamp.

All 5 root causes are comprehensively solved by the implementations described in `docs/VEHICLE_PHYSICS_FINAL_FIX.md`.
