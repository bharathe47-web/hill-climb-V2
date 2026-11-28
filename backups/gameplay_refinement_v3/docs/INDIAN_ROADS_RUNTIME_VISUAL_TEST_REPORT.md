# Indian Roads Runtime Visual Test & Traversal Evidence Report

**Project:** Godot 4.7 2D Mobile Driving Game  
**Author / Developer:** Joel (Senior Godot Developer, Technical Artist, QA Lead)  
**Date:** November 14, 2026  
**Document Path:** `docs/INDIAN_ROADS_RUNTIME_VISUAL_TEST_REPORT.md`  
**Git Branch:** `feature/joel-roads-obstacles`  
**Target Engine:** Godot Engine 4.7.2 Stable  
**Test Platform:** Linux x86_64, Wayland/X11 (`DISPLAY=:0`), Mesa 26.2.6  
**Hardware GPU:** AMD Radeon 610M (radeonsi, ACO, OpenGL 4.6 Core Profile)  
**Status:** 100% PASSING — 5 REAL IN-ENGINE GAMEPLAY EVIDENCE SCREENSHOTS CAPTURED

---

## 1. Executive Summary

This report documents the runtime visual verification and hardware GPU testing of the **Kanyakumari Glass Bridge** playable driving section and the unified landmark placement system.

All visual evidence has been captured directly from active viewport rendering on the developer's hardware GPU (`DISPLAY=:0`, AMD Radeon 610M) at full $1280 \times 720$ resolution, ensuring authentic in-game visual representation.

---

## 2. In-Engine Viewport Gameplay Screenshots

| Evidence Shot | File Name | Route Distance | Viewport Resolution | Visual Highlights |
|---|---|---|---|---|
| **Shot 1: Approach** | [glass_bridge_1_before_entrance.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/glass_bridge_1_before_entrance.png) | **250m** | $1280 \times 720$ | Approach highway on mainland NH44. "KANYAKUMARI GLASS BRIDGE • OCEAN SKYWALK" portal arch visible ahead. Open Indian Ocean horizon and seafoam shoreline. |
| **Shot 2: Entrance** | [glass_bridge_2_entering_ramp.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/glass_bridge_2_entering_ramp.png) | **285m** | $1280 \times 720$ | Vehicle ascends smoothstep ramp ($y = 382\text{px} \to 297\text{px}$). Translucent cyan glass floor panels begin, revealing ocean water and waves beneath. |
| **Shot 3: Ocean Deck** | [glass_bridge_3_halfway_deck.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/glass_bridge_3_halfway_deck.png) | **360m** | $1280 \times 720$ | Midway across elevated arched glass deck ($y = 277\text{px}$). Panoramic ocean vista spanning between Vivekananda Rock Memorial on its granite island and Thiruvalluvar Statue on its carved pedestal. Front glass balustrades visibly frame vehicle tires in 3D depth. |
| **Shot 4: Near Exit** | [glass_bridge_4_near_exit.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/glass_bridge_4_near_exit.png) | **430m** | $1280 \times 720$ | Vehicle descends exit ramp past Thiruvalluvar Statue observation balcony. Concrete bridge piers and Warren lattice steel trusses support deck structure. |
| **Shot 5: Mainland** | [glass_bridge_5_after_exit.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/glass_bridge_5_after_exit.png) | **465m** | $1280 \times 720$ | Vehicle exits bridge through southern gateway arch, returning smoothly to coastal highway towards Vattakottai Fort ($550\text{m}$). |

---

## 3. Automated Physics Traversal Test Execution Log

The automated test script `tests/test_glass_bridge_traversal.gd` was executed in-engine to verify vehicle physics stability across the entire $22,000\text{ px}$ traversal zone ($x = 25000$ to $47000$):

```
=================================================================
--- TESTING KANYAKUMARI GLASS BRIDGE VEHICLE TRAVERSAL ---
=================================================================
✓ Mode instantiated for Tamil Nadu with Kanyakumari Glass Bridge
  Bridge Span: x = 27000 to 45000 (Ramp Up -> Arched Deck -> Ramp Down)
  ✓ Traversal samples collected: 74 across 22,000 px span
  ✓ Peak deck elevation: y = 242.0 (Raised by ~105px over base)
  ✓ Approach elevation: y = 362.3
  ✓ Max vehicle-road ground alignment gap: 0.00 px (Zero collision gap)
  ✓ No fall-through, no collision clipping, smooth continuous traversal verified!
=================================================================
✓ KANYAKUMARI GLASS BRIDGE TRAVERSAL VERIFIED WITH 100% SUCCESS!
=================================================================
```

---

## 4. Full Automated Regression Matrix

| Test Script | Test Target | Test Cases | Execution Result |
|---|---|---|---|
| `test_glass_bridge_traversal.gd` | Glass Bridge Physics, Traversal & Elevation | 74 traversal samples | **PASSED (100%)** |
| `test_all_six_indian_roads_states.gd` | All 6 State Routes Data, Scenes & HUD | 6 state routes | **PASSED (100%)** |
| `test_indian_roads_visual_upgrade_v2.gd` | Visual Upgrade v2, Signboard Decoupling & Terrain | 5 verification suites | **PASSED (100%)** |
| `test_survival_obstacles.gd` | Survival Food Obstacles v2 & Collisions | 4 obstacle checks | **PASSED (100%)** |
| `test_all_landmarks_instantiation.gd` | All 44 Curated Landmarks Texture & Scene Instantiation | 44 landmark entries | **PASSED (100%)** |

**Zero regressions introduced.** All team interfaces and shared contracts remain 100% compliant.
