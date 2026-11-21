# Joel's Survival Obstacle & Warning Component Report

**Project:** Godot 4.7 2D Mobile Driving Game  
**Author / Component Author:** Joel (Senior Godot Developer, Component Artist)  
**Date:** November 14, 2026  
**Document:** `docs/JOEL_SURVIVAL_COMPONENT_REPORT.md`  
**Git Branch:** `feature/joel-roads-obstacles`  
**Integration Partner:** Bharath (Lead Architect, Owner of Survival Mode Controller)  
**Test Suite:** `tests/test_survival_obstacles.gd` (Passed 100% Green)  

---

## 1. Scope, Ownership Boundaries & Interface Contract

This document provides the definitive architectural specification for Joel's deliverable components in **Survival Mode**, establishing clear boundaries with Bharath's gameplay systems in accordance with [SHARED_GAME_INTERFACES.md](file:///home/joel/Documents/game/hill-climb-V2/docs/team/SHARED_GAME_INTERFACES.md).

### Ownership Division
- **Joel (Visual & Physical Component Ownership):**
  - Reusable food obstacle scenes: `scenes/modes/survival/obstacles/*.tscn`
  - Obstacle script component: `scripts/components/survival_obstacles/FoodObstacle.gd`
  - Overhead warning indicator component: `scenes/modes/survival/obstacles/WarningIndicator.tscn` & `WarningIndicator.gd`
  - High-resolution obstacle sprite artwork: `assets/obstacles/` and `assets/warnings/`
  - Collision shape configuration, scaling, transparent alpha trim, and physical fall parameters.
  - Standalone component unit testing: `tests/test_survival_obstacles.gd`.
- **Bharath (Survival Controller & Rule Ownership):**
  - Mode lifecycle: `scenes/modes/survival/Survival.tscn` & `scripts/modes/survival/SurvivalController.gd`.
  - Player 3-life baseline, invulnerability debouncing (1.0s window), and game over evaluation.
  - Obstacle spawn intervals, trajectory calculations, and difficulty curve progression.
  - Score accumulation, distance multiplier, and rewarded ad extra-life flow.

---

## 2. Food Obstacle Component Specifications

Each food obstacle is implemented as an independent `Area2D` scene extending [FoodObstacle.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/components/survival_obstacles/FoodObstacle.gd).

### 2.1. The 5 Authentic Indian Food Obstacles

| Obstacle ID | Scene Path | Sprite Asset Path | Collision Shape | Physical Behavior | Gameplay Role |
|---|---|---|---|---|---|
| `chilli` | `scenes/modes/survival/obstacles/ChilliObstacle.tscn` | `assets/obstacles/chilli.png` | `CapsuleShape2D` (Radius: 12, Height: 44) | High fall velocity (`460.0 px/s`), slight rotational spin (`1.8 rad/s`) | Fast descending projectile requiring quick braking |
| `rice` | `scenes/modes/survival/obstacles/RiceObstacle.tscn` | `assets/obstacles/rice.png` | `CircleShape2D` (Radius: 28) | Medium fall (`320.0 px/s`), horizontal aerodynamic drift (`45.0 px/s`) | Floating obstacle that tracks across player lane |
| `sweets` | `scenes/modes/survival/obstacles/SweetsObstacle.tscn` | `assets/obstacles/sweets.png` | `CircleShape2D` (Radius: 22) | Standard vertical drop (`380.0 px/s`), zero drift | Classic vertical hazard |
| `vada_pav` | `scenes/modes/survival/obstacles/VadaPavObstacle.tscn` | `assets/obstacles/vada_pav.png` | `RectangleShape2D` (Size: 48 x 36) | Heavy fall (`520.0 px/s`), heavy ground thud impact | Fast heavy hazard with wide collision box |
| `samosa` | `scenes/modes/survival/obstacles/SamosaObstacle.tscn` | `assets/obstacles/samosa.png` | `ConvexPolygonShape2D` (Triangular profile) | Medium fall (`400.0 px/s`), tumbling angular wobble | Angular hazard that clips roofs if jumped prematurely |

### 2.2. Interface Signal Contract
When an obstacle's `Area2D` intersects with the player vehicle (`body_entered`), it emits:
```gdscript
signal obstacle_hit(obstacle_id: String, impact_position: Vector2)
```
Upon emission, the obstacle plays a visual burst/crumble effect and calls `queue_free()`.

---

## 3. Overhead Warning Indicator Component

The [WarningIndicator.tscn](file:///home/joel/Documents/game/hill-climb-V2/scenes/modes/survival/obstacles/WarningIndicator.tscn) visual component provides player telegraphing prior to projectile descent, in compliance with Section 6.2 of the project interface specification.

### Technical Details
- **Node Type:** `Node2D` with billboard `Sprite2D` and `AnimationPlayer`.
- **Sprite:** `assets/warnings/warning_hazard_icon.png` (Flashing red exclamation triangle).
- **Positioning:** Clamped to the top edge of the camera viewport (`y = 65.0 px`), dynamically matching the target obstacle's falling `x` coordinate.
- **Telegraph Duration:** Configurable warning window (`0.8s` default), flashing at 6 Hz before fading out as the obstacle enters the visible screen frame.
- **Safety Cleanup:** Automatically self-destructs if target obstacle is invalidated.

---

## 4. Automated QA & Test Evidence

The component test suite [tests/test_survival_obstacles.gd](file:///home/joel/Documents/game/hill-climb-V2/tests/test_survival_obstacles.gd) executes 4 rigorous validation phases:

```
=================================================================
--- BEGIN SURVIVAL OBSTACLES & WARNINGS AUTOMATED TEST SUITE ---
=================================================================

-> [1/4] Verifying 5 Food Obstacle Scenes & Collision Shapes...
  ✓ Chilli: CapsuleShape2D verified, fall_speed=460.0, rotation active.
  ✓ Rice: CircleShape2D verified, horizontal drift active.
  ✓ Sweets: CircleShape2D verified, standard fall verified.
  ✓ Vada Pav: RectangleShape2D verified, heavy mass fall_speed=520.0.
  ✓ Samosa: Triangular shape verified, tumbling wobble active.
  ✓ All 5 Food Obstacles instantiated with cleanly aligned shapes!

-> [2/4] Verifying WarningIndicator visual component...
  ✓ WarningIndicator conforms to SHARED_GAME_INTERFACES.md Section 6.2!
  ✓ Viewport top clamping and target X tracking verified.

-> [3/4] Verifying FoodObstacle hit signal contract...
  ✓ FoodObstacle hit reporting signal emitted on vehicle contact.
  ✓ Payload matches (obstacle_id: String, impact_position: Vector2).

-> [4/4] Verifying SurvivalController obstacle binding & 1-life loss...
  ✓ SurvivalController 3-life baseline confirmed.
  ✓ Single life lost on collision (3 -> 2).
  ✓ 1.0s invulnerability window successfully debounces multi-frame contacts.

=================================================================
✓ ALL SURVIVAL OBSTACLES & WARNING TESTS COMPLETED WITH 100% SUCCESS!
=================================================================
```

---

## 5. Handoff Status & Sign-Off

- **Component Deliverables:** **100% VERIFIED COMPLETE**
- **Collision Setup:** Cleanly trimmed PNG sprites with pixel-perfect shapes.
- **Controller Decoupling:** Fully compliant; zero edits to Bharath's controller logic.
- **Readiness:** Production ready for release build.
