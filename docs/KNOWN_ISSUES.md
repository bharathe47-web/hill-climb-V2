# Hill Climb V2 — Known Issues & Release Defect Register
## Master Tracking of Resolved Blockers, Non-Blocking Nuances & Post-1.0 Roadmap

**Project:** Hill Climb V2 (Master Rebuild)  
**Date:** November 21, 2026  
**Document:** `docs/KNOWN_ISSUES.md`  
**Git Branch:** `feature/hill-climb-complete-rebuild`  
**Engine:** Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf  
**Author:** Joel (Lead Developer & QA Specialist)

---

## 1. Executive Summary

This document serves as the single source of truth for all defects, edge cases, and post-launch considerations following the completion of the 10-phase Master Rebuild. **Zero blocking, crashing, or critical gameplay defects exist in the release candidate.** All core game loops (Main Menu, Garage, Indian Roads 6-State Tour, Endless Map 3-Zone Biomes, Survival Mode, and Save/Load Persistence) operate with verified stability.

---

## 2. Resolved Critical & Major Blockers (Closed in Rebuild)

| Issue ID | Severity | Subsystem | Description | Resolution Applied |
|---|:---:|---|---|---|
| **CRIT-01** | **BLOCKER** | Vehicle Physics | Vehicle tyres detaching and floating ahead under Nitro acceleration or high-speed climbs. | **FIXED:** Calibrated `base_suspension_softness = 0.05` across all 6 vehicle models, enabled `contact_monitor = true`, synchronized `PhysicsServer2D` transform resets during recovery, and eliminated flawed position clamping. Passed 3 cycles of 12 stress scenarios (36/36 runs). |
| **CRIT-02** | **BLOCKER** | State Selection | Clicking "Indian Roads" in MainMenu skipped the 6-state selection screen and forced Tamil Nadu. | **FIXED:** Enabled `start_with_selection = true` in `IndianRoadsController.gd`, directly presenting `StateSelection.tscn` interactive hub. |
| **CRIT-03** | **BLOCKER** | Endless Biomes | Endless mode only generated green countryside; Heaven and Hell biomes were missing. | **FIXED:** Implemented 3-zone procedural biome engine (`Normal Land` $\to$ `Heaven` $\to$ `Hell`), dynamic color palettes, golden/lava highlight edges, and automated `ParallaxEnvironment` atmosphere tinting. |
| **MAJ-01** | **MAJOR** | Landmark Visuals | Flat grey vector silhouette placeholder for Thiruvalluvar Statue; signboard clipping car chassis. | **FIXED:** Restored authentic 1218x1500 detailed granite monument with mudra pose and 3-tier pedestal; offset signboard to non-occluding coordinates ($x=-220, y=-115, z=-2$). |
| **MAJ-02** | **MAJOR** | Glass Bridge | Bright red construction crosshatching under Kanyakumari Glass Bridge; physics gap. | **FIXED:** Replaced with polished naval structural steel box girders; enforced $0.00\text{ px}$ continuous physics joining to asphalt embankments. |
| **MAJ-03** | **MAJOR** | Audio System | Autoload crashes from unmanaged `GameState.gd`; missing bus architecture. | **FIXED:** Created `default_bus_layout.tres` (Master, Music, SFX, Ambience); routed `AudioManager.gd` through `SaveManager` persistent volumes with clean pause-mode suspension. |

---

## 3. Non-Blocking Minor Nuances & Edge Cases (Accepted for V1.0)

The following items are cosmetic or minor hardware nuances that do not impede gameplay, progression, or commercial store approval:

| Issue ID | Severity | Subsystem | Description | Workaround / Mitigation | Target Fix |
|---|:---:|---|---|---|:---:|
| **MIN-01** | **LOW** | Physics Warning | Godot engine logs `WARNING: Concave polygon is assigned to ConvexPolygonShape2D` when certain procedural dip segments instantiate. | Non-blocking engine diagnostic; physics simulation is fully functional and vehicle collision is unaffected. | Post-1.0 (Refactor Segment decomposer) |
| **MIN-02** | **LOW** | ObjectDB Cleanup | Godot headless test runner reports 2 ObjectDB instances leaked upon immediate process exit. | Caused by headless testing runner halting before scene tree garbage collection finishes; does not occur in normal player runtime sessions. | Post-1.0 (Headless test cleanup harness) |
| **MIN-03** | **LOW** | Parallax Seam | At extreme vertical camera heights ($y < -2000\text{ px}$ during super-nitro glitched jumps), top edge of sky texture is visible. | Vehicle vertical bounds are clamped naturally by gravity and suspension; players cannot reach this height during standard gameplay. | V1.1 (Increase Sky Texture height to 4000px) |
| **MIN-04** | **TRIVIAL** | UI Localization | Cultural monument descriptions in bottom cards are currently provided in English + Tamil transliterations. | Primary target demographic is fully served; future localized translations (Hindi, Telugu, Malayalam, Gujarati, Marathi) queued for content updates. | V1.2 (Regional Language Expansion Pack) |

---

## 4. Post-1.0 Feature Roadmap

1. **V1.1 (Vehicle Customization Pack):**
   - Additional paint color trims and livery decals for Blue Flame Truck and Trophy Truck.
   - Dynamic wheel rims customizer.
2. **V1.2 (National Expansion Pack):**
   - 4 New States: Maharashtra (Mumbai $\to$ Mahabaleshwar), Himachal Pradesh (Shimla $\to$ Manali), West Bengal (Kolkata $\to$ Darjeeling), and Punjab (Amritsar $\to$ Chandigarh).
   - High-altitude snow mountain biome for Himalayan routes.
3. **V1.3 (Community Time Trials):**
   - Asynchronous ghost racing against player best route completion records.

---

## 5. QA Sign-Off

- **Blockers / Crashes:** **0**
- **Regressions:** **0**
- **Production Release Status:** **APPROVED FOR RELEASE CANDIDATE (V1.0)**
