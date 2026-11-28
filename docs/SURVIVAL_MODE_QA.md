# Hill Climb V2 — Survival Mode QA & Verification Report
## Food Obstacles, Warning Billboard Indicator, Health System & Game Over Flow

**Project:** Hill Climb V2 (Master Rebuild)  
**Date:** November 21, 2026  
**Document:** `docs/SURVIVAL_MODE_QA.md`  
**Git Branch:** `feature/hill-climb-complete-rebuild`  
**Engine:** Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf  
**Author:** Joel (Lead Developer & Obstacle Artist) with Bharath (Survival Controller Lead)

---

## 1. Executive Summary

Survival Mode provides an action-packed, hazard-evasion gameplay experience distinct from the open tourism of Indian Roads and the high-speed cruise of Endless Map. Players navigate through a storm of incoming regional Indian food obstacles (Chilli, Rice, Sweets, Vada Pav, Samosa) while managing vehicle momentum and reacting to screen-edge billboard warning indicators.

The mode was verified through automated testing in `tests/test_survival_obstacles.gd` and core scene navigation testing in `tests/test_core_architecture_and_navigation.gd`, demonstrating **100% PASS rate** across all obstacle scenes, debounced life deductions, warning clamping algorithms, and restart lifecycles.

---

## 2. Food Obstacles Inventory & Collision Calibration

All 5 food hazards were crafted as authentic stylized 2D regional delicacies, fully conforming to `docs/team/SHARED_GAME_INTERFACES.md`:

| Obstacle Name | Visual Theme | Scene Path | Collision Shape | Mass / Physics | Hazard Damage | Status |
|---|---|---|---|:---:|:---:|:---:|
| **Hot Red Chilli** | Spicy red pepper with green stem | `scenes/modes/survival/obstacles/ChilliObstacle.tscn` | CapsuleShape2D ($18 \times 44\text{ px}$) | Dynamic RigidBody2D | $1\text{ Life}$ | **VERIFIED PASS** |
| **Rice Bowl** | Steaming aromatic basmati rice bowl | `scenes/modes/survival/obstacles/RiceObstacle.tscn` | CircleShape2D ($r=28\text{ px}$) | Dynamic RigidBody2D | $1\text{ Life}$ | **VERIFIED PASS** |
| **Traditional Sweets** | Festive Laddu / Gulab Jamun plate | `scenes/modes/survival/obstacles/SweetsObstacle.tscn` | CircleShape2D ($r=26\text{ px}$) | Dynamic RigidBody2D | $1\text{ Life}$ | **VERIFIED PASS** |
| **Mumbai Vada Pav** | Spiced potato fritter in golden bun | `scenes/modes/survival/obstacles/VadaPavObstacle.tscn` | CircleShape2D ($r=30\text{ px}$) | Dynamic RigidBody2D | $1\text{ Life}$ | **VERIFIED PASS** |
| **Golden Samosa** | Crispy triangular pastry with peas | `scenes/modes/survival/obstacles/SamosaObstacle.tscn` | ConvexPolygonShape2D ($3\text{ vertices}$) | Dynamic RigidBody2D | $1\text{ Life}$ | **VERIFIED PASS** |

---

## 3. Warning Indicator Visual Billboard System

- **Scene Path:** `scenes/modes/survival/obstacles/WarningIndicator.tscn`
- **Behavior:**
  - Detects obstacles spawning ahead off-screen.
  - Clamps to the visible camera viewport edge with a $40\text{ px}$ inner safety margin.
  - Renders a pulsing red triangular danger emblem `[ ! ]` scaled inversely by distance to impact.
  - Features smooth alpha fade-in on detection and auto-fade out when the obstacle enters active gameplay view.

---

## 4. Gameplay Rules, Lives & Recovery

### 4.1 Starting Baseline & Debounced Damage
- Players begin the run with **3 Lives** (`current_lives = 3`).
- When a food obstacle collides with the vehicle chassis, the obstacle emits `hit_vehicle(obstacle, damage)`.
- A $1.2\text{s}$ damage debouncing window prevents multiple lives from being stripped by a single multi-bounce collision event.

### 4.2 Game Over & Victory Pacing
- On losing all 3 lives, `SurvivalController` halts obstacle spawners and triggers the Results Screen.
- Distance survived and total food hazards dodged are displayed on the mobile results card.
- Pressing `Restart` cleanly resets lives to 3, flushes active physics bodies, and restarts obstacle generation at distance $0\text{ m}$.

---

## 5. Automated Headless Test Results

### Suite: `tests/test_survival_obstacles.gd`
```
=================================================================
--- BEGIN SURVIVAL OBSTACLES & WARNINGS AUTOMATED TEST SUITE ---
=================================================================

-> [1/4] Verifying 5 Food Obstacle Scenes & Collision Shapes...
  ✓ All 5 Food Obstacles (Chilli, Rice, Sweets, Vada Pav, Samosa) instantiated with aligned shapes!
-> [2/4] Verifying WarningIndicator visual component...
  ✓ WarningIndicator conforms to SHARED_GAME_INTERFACES.md Section 6.2!
-> [3/4] Verifying FoodObstacle hit signal contract...
  ✓ FoodObstacle hit reporting signal contract verified!
-> [4/4] Verifying SurvivalController obstacle binding & 1-life loss...
  ✓ SurvivalController integration, debouncing, and 3-life baseline verified!

=================================================================
✓ ALL SURVIVAL OBSTACLES & WARNING TESTS COMPLETED WITH 100% SUCCESS!
=================================================================
```

---

## 6. Sign-Off & Status

- **Food Hazards & Art:** **VERIFIED COMPLETE**
- **Warning Indicator:** **VERIFIED COMPLETE**
- **Survival Controller Binding:** **VERIFIED COMPLETE**
- **Lives & Game Over Flow:** **VERIFIED COMPLETE**
