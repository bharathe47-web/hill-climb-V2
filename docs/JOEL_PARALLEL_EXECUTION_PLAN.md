# Joel's Parallel Execution Plan & Multi-Workstream Orchestration

**Project:** Godot 4.7 2D Mobile Driving Game  
**Lead / Senior Architect:** Joel (Senior Godot Developer, Technical Artist, QA Lead)  
**Date:** November 14, 2026  
**Document:** `docs/JOEL_PARALLEL_EXECUTION_PLAN.md`  
**Git Branch:** `feature/joel-roads-obstacles`  
**Engine:** Godot 4.7.dev  

---

## 1. Parallel Execution Protocol & Safety Boundaries

To maximize development velocity without introducing merge collisions or instability, the remaining tasks are split across seven concurrent tracks.

### Parallel Execution Rules
1. **Isolated File Ownership:** Each workstream operates within explicit directory and file boundaries. No two tasks write to the same `.tscn`, `.gd`, `.tres`, or `.png` concurrently.
2. **Read-Only Inspection Across Shared Modules:** All workstreams may read shared controllers (`Main.gd`, `VehicleController.gd`, `GameManager.gd`) for interface verification, but modifications to shared files outside Joel's scope are strictly prohibited.
3. **Continuous Independent Progression:**
   - Asset documentation and cataloging (Track A) does not wait on route design approvals.
   - Survival obstacle component polish (Track D) executes independently of Indian Roads parallax work.
   - Route functional audits (Track B) proceed using test seams regardless of asset generation status.
4. **Single Source of Truth & Controlled Integration:** All route resources in `resources/routes/` and controllers in `scripts/modes/indian_roads/` adhere to verified interfaces before being marked `VERIFIED COMPLETE`.
5. **Zero-Destructive Operations:** Never execute `git reset --hard`, `git clean -fd`, or discard unstaged hooks.

---

## 2. Multi-Workstream Task Matrix

| Task ID | Workstream | Task Description | Priority | Owner | Files Involved | Dependencies | Independent? | Status | Test Criteria | Next Action |
|---|---|---|---|---|---|---|---|---|---|---|
| **WS-A01** | Track A: Assets | **150-Location Famous Place Catalogue** | HIGH | Joel | `docs/SIX_STATE_150_LOCATION_ASSET_CATALOGUE.md` | None (Research & Geospatial audit) | **YES** | **IN PROGRESS** | 25 distinct locations per state across all 6 states with visual & historical metadata. | Complete research & document catalog. |
| **WS-A02** | Track A: Assets | **Diverse Regional Asset Collections** | HIGH | Joel | `assets/indian_locations/*/`, `assets/indian_roads/` | WS-A01 | **YES** | **VERIFIED COMPLETE** | 65 production assets across 6 states; zero snow artifacts; transparent cutouts. | Maintain asset registry & checksums. |
| **WS-A03** | Track A: Assets | **Master Asset Register & Licensing** | HIGH | Joel | `docs/INDIAN_ROADS_FINAL_ASSET_REGISTER.md`, `docs/INDIAN_ROADS_FINAL_ASSET_LICENSES.md` | WS-A02 | **YES** | **VERIFIED COMPLETE** | Every asset has verified license (CC0 / CC-BY / Public Domain) & commercial rights. | Expand with 150-location entries. |
| **WS-B01** | Track B: Route Func | **Diagnosis of 3 Broken States (RJ, GJ, TS)** | CRITICAL | Joel | `scripts/modes/indian_roads/RouteRegistry.gd`, `SaveManager.gd` | None | **YES** | **VERIFIED COMPLETE** | Reproduce lock gating; bind genuine assets; add `dev_unlock_all_routes` test seam. | Enforce release progression flag. |
| **WS-B02** | Track B: Route Func | **State Selection & Audio Safety Guard** | HIGH | Joel | `scripts/modes/indian_roads/StateSelectionController.gd` | None | **YES** | **VERIFIED COMPLETE** | `is_inside_tree()` guard prevents audio playback crash during teardown. | Verified in `test_all_six_indian_roads_states.gd`. |
| **WS-B03** | Track B: Route Func | **Goa Route Geography Conflict Audit** | MEDIUM | Joel | `docs/GOA_ROUTE_GEOGRAPHY_AUDIT.md`, `RouteRegistry.gd` | Lead Art / Design review | **NO** | **BLOCKED BY APPROVAL** | Geographic contradiction (`Panaji → Margao` vs North Goa Calangute) documented. | Awaiting Bharath approval for Option A. |
| **WS-B04** | Track B: Route Func | **Route Functional Audit Document** | HIGH | Joel | `docs/INDIAN_ROADS_ROUTE_FUNCTIONAL_AUDIT.md` | WS-B01, WS-B02 | **YES** | **IN PROGRESS** | Route IDs, waypoints, milestone triggers, finish arch, and victory screens documented. | Draft comprehensive audit report. |
| **WS-C01** | Track C: Level Design | **Scenery Pacing & Repetition Reduction** | HIGH | Joel | `scripts/modes/indian_roads/IndianRoadTerrainV2.gd`, `IndianRoadsControllerV2.gd` | WS-A02 | **YES** | **IN PROGRESS** | 5–7 distinct scenery zones per state; elimination of continuous repeating houses. | Create Level Design Plan document. |
| **WS-C02** | Track C: Level Design | **Journey Length & Pacing Target (3–5 min)** | MEDIUM | Joel | `docs/INDIAN_ROADS_LEVEL_DESIGN_PLAN.md` | WS-C01 | **YES** | **IN PROGRESS** | Target driving time calibrated to ~3–5 mins per route (1600m–2200m game scale). | Calibrate vehicle speed and distance ratios. |
| **WS-D01** | Track D: Survival | **5 Food Obstacles Reusable Scenes & Collision** | HIGH | Joel | `scenes/modes/survival/obstacles/*.tscn`, `FoodObstacle.gd` | Interface contract | **YES** | **VERIFIED COMPLETE** | Chilli, Rice, Sweets, Vada Pav, Samosa have correct mass, fall speed, and collision shapes. | Passed `test_survival_obstacles.gd`. |
| **WS-D02** | Track D: Survival | **Warning / Landing Indicator Component** | HIGH | Joel | `scenes/modes/survival/obstacles/WarningIndicator.tscn`, `WarningIndicator.gd` | Interface contract | **YES** | **VERIFIED COMPLETE** | Flashes red billboard indicator over descending obstacles; tracks vehicle X. | Conforms to Section 6.2 interface. |
| **WS-D03** | Track D: Survival | **Joel Survival Component Report** | HIGH | Joel | `docs/JOEL_SURVIVAL_COMPONENT_REPORT.md` | WS-D01, WS-D02 | **YES** | **IN PROGRESS** | Complete report covering scenes, collision boundaries, and Bharath's controller interface. | Finalize component documentation. |
| **WS-E01** | Track E: Testing | **Six-State Continuous Test Suite** | CRITICAL | Joel | `tests/test_all_six_indian_roads_states.gd` | WS-B01 | **YES** | **VERIFIED COMPLETE** | 100% pass across Tamil Nadu, Goa, Kerala, Rajasthan, Gujarat, Telangana. | Re-run continuously after edits. |
| **WS-E02** | Track E: Testing | **Six-State Comprehensive QA Test Matrix** | HIGH | Joel | `docs/INDIAN_ROADS_SIX_STATE_TEST_MATRIX.md` | WS-E01 | **YES** | **VERIFIED COMPLETE** | All 12 criteria (Selection, Loading, Background, Landmarks, Checkpoints, etc.) PASS. | Maintain as regression baseline. |
| **WS-F01** | Track F: Regression | **Whole-Game Full Regression Audit** | CRITICAL | Joel | `docs/FULL_GAME_REGRESSION_REPORT.md`, `tests/*.gd` | All modules | **YES** | **VERIFIED COMPLETE** | 19 / 19 automated test suites pass (100% Green). Zero leaks. | Document findings across Sections A–G. |
| **WS-F02** | Track F: Regression | **Endless Mode Ramp Transitions Status** | MEDIUM | Daniel | `scenes/terrain/ProceduralTrack.tscn` | Daniel's branch merge | **NO** | **BLOCKED BY OTHER OWNER** | Base countryside passes 100%; Heaven/Hell ramps pending on `feature/daniel-endless`. | Report defect/status to Daniel. |
| **WS-G01** | Track G: Integration | **Product Quality & Known Issues Register** | HIGH | Joel | `docs/FINAL_KNOWN_ISSUES.md` | All tracks | **YES** | **VERIFIED COMPLETE** | Document KI-01 through KI-06 with workarounds, mobile scaling, and RAM profiles. | Finalize for release handoff. |
| **WS-G02** | Track G: Integration | **Master Project Progress & To-Do Tracker** | CRITICAL | Joel | `docs/MASTER_PROJECT_TODO.md` | All tracks | **YES** | **IN PROGRESS** | Unified progress tracker detailing every task, owner, priority, status, and test evidence. | Update with parallel execution outputs. |

---

## 3. Workstream Dependency Graph

```
[WS-A01: 150-Location Research] ──────► [WS-A02: Production Assets] ──► [WS-A03: Asset Register & Licenses]
                                                   │
                                                   ▼
[WS-B01: 3-State Bug Diagnosis] ──────► [WS-C01: Scenery Zonation]  ──► [WS-C02: Journey Length Pacing]
             │                                     │
             ▼                                     ▼
[WS-B02: State Selection Safety]        [WS-B04: Route Audit]        ──► [WS-B03: Goa Geography Review]
             │
             ▼
[WS-D01: 5 Food Obstacles] ───────────► [WS-D02: Warning Indicator] ──► [WS-D03: Survival Component Report]
                                                   │
                                                   ▼
[WS-E01: Six-State Automated Test] ───► [WS-E02: Test Matrix]       ──► [WS-F01: Whole-Game Regression]
                                                                                   │
                                                                                   ▼
                                                                        [WS-G01: Known Issues Register]
                                                                                   │
                                                                                   ▼
                                                                        [WS-G02: Master Project To-Do]
```

---

## 4. Execution Roadmap & Interleaving Schedule

1. **Step 1 (Track A):** Create the comprehensive `docs/SIX_STATE_150_LOCATION_ASSET_CATALOGUE.md` covering 25 curated locations per state (150 total) across Tamil Nadu, Goa, Kerala, Rajasthan, Gujarat, and Telangana.
2. **Step 2 (Track B):** Produce `docs/INDIAN_ROADS_ROUTE_FUNCTIONAL_AUDIT.md` verifying state selection, route loading, vehicle spawning, distance tracking, checkpoints, finish arch, and victory screen.
3. **Step 3 (Track C):** Produce `docs/INDIAN_ROADS_LEVEL_DESIGN_PLAN.md` detailing the 5–7 distinct scenery zones per state and the 3–5 minute pacing calibration.
4. **Step 4 (Track D):** Produce `docs/JOEL_SURVIVAL_COMPONENT_REPORT.md` verifying the 5 food obstacle scenes, collision shapes, warning indicator, and interface compatibility.
5. **Step 5 (Track E & F):** Run continuous verification on all test suites and ensure all regression criteria remain 100% green.
6. **Step 6 (Track G):** Synchronize `docs/MASTER_PROJECT_TODO.md` with every verified deliverable and present the final status to the user.
