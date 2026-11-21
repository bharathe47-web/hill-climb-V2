# Kanyakumari & Tamil Nadu Landmark Placement & Offshore Integration Report

**Project:** Godot 4.7 2D Mobile Driving Game  
**Author / Developer:** Joel (Senior Godot Developer, Technical Artist, Level Designer, QA Engineer)  
**Date:** November 14, 2026  
**Document Path:** `docs/KANYAKUMARI_LANDMARK_PLACEMENT_REPORT.md`  
**Git Branch:** `feature/joel-roads-obstacles`  
**Target Engine:** Godot Engine 4.7.2 Stable  
**Status:** COMPLETED & VERIFIED

---

## 1. Overview of Tamil Nadu Route Progression

The Tamil Nadu route represents an authentic driving journey from the southernmost tip of India at **Kanyakumari** along **NH44** through the historic temple city of **Madurai** to the final destination at **Marina Beach, Chennai** ($1,800\text{m}$ total distance).

The landmark layout follows real Indian geography, positioning famous monuments beside the road in sequential order without repetitive housing clumping or signboard occlusion.

---

## 2. Detailed Landmark Sequence & Placement Registry

| Distance | Milestone / Landmark | ID | Placement Category | Z-Index | Dimensions / Scale | Offshore / Ground Anchor |
|---|---|---|---|---|---|---|
| **0m** | Kanyakumari Start Point | `tn_start` | `ROADSIDE_PROP` | `0` | Route Start Marker | Tarmac apron at Triveni Sangam |
| **100m** | Gandhi Memorial Mandapam | `LOC-TN-03` | `ROADSIDE_LANDMARK` | `-2` | $220\text{px} \times 240\text{px}$ | Ground anchor: $y = 0\text{px}$, roadside shoulder |
| **190m** | Kumari Amman Temple | `LOC-TN-04` | `ROADSIDE_LANDMARK` | `-2` | $270\text{px} \times 250\text{px}$ | Ground anchor: $y = 0\text{px}$, roadside shoulder |
| **270m** | Kanyakumari Glass Bridge | `LOC-TN-05` | `DRIVABLE_STRUCTURE` | `+2` / `0` | $180\text{px} \times 260\text{px}$ | Entrance portal arch; bridge elevates vehicle over ocean |
| **315m** | Vivekananda Rock Memorial | `LOC-TN-02` | `BACKGROUND_LANDMARK` | `-3` | $240\text{px} \times 300\text{px}$ | **Offshore Granite Rock Island:** 560px wide natural rock rising to $y=260\text{px}$ in the sea |
| **350m** | Ocean Crossing Milestone | `tn_thiruvalluvar` | `ROADSIDE_PROP` | `0` | Milestone Trigger | Raised glass deck between the two island platforms |
| **415m** | Thiruvalluvar Statue | `LOC-TN-01` | `BACKGROUND_LANDMARK` | `-3` | $360\text{px} \times 230\text{px}$ | **Offshore Stone Pedestal Island:** 460px wide 3-tier sculpted Dravidian stone pedestal rising to $y=220\text{px}$ |
| **450m** | Glass Bridge Exit Portal | — | `DRIVABLE_STRUCTURE` | `+2` | Gateway Arch | Vehicle transitions back to coastal highway |
| **550m** | Vattakottai Coastal Fort | `LOC-TN-06` | `ROADSIDE_LANDMARK` | `-2` | $230\text{px} \times 270\text{px}$ | Ground anchor: coastal stone ramparts |
| **650m** | Kamarajar Memorial Mandapam | `LOC-TN-07` | `ROADSIDE_LANDMARK` | `-2` | $220\text{px} \times 250\text{px}$ | Ground anchor: seaside memorial gardens |
| **750m** | Madurai Checkpoint Gate | `tn_madurai_cp` | `ROADSIDE_PROP` | `+1` | Checkpoint Gate | NH44 toll plaza crossing |
| **880m** | Meenakshi Amman Temple | `LOC-TN-14` | `ROADSIDE_LANDMARK` | `-2` | $360\text{px} \times 280\text{px}$ | Ground anchor: temple street plinth |
| **1020m** | Thirumalai Nayakkar Mahal | `LOC-TN-15` | `ROADSIDE_LANDMARK` | `-2` | $240\text{px} \times 290\text{px}$ | Ground anchor: royal courtyard terrace |
| **1150m** | NH44 Highway Junction Dhaba | `LOC-TN-16` | `ROADSIDE_PROP` | `-2` | $190\text{px} \times 220\text{px}$ | Ground anchor: roadside banyan tree rest area |
| **1450m** | Coastal Toll Plaza CP2 | `tn_coastal_cp` | `ROADSIDE_PROP` | `+1` | Checkpoint Gate | East Coast Road checkpoint |
| **1580m** | Kapaleeshwarar Temple | `LOC-TN-17` | `ROADSIDE_LANDMARK` | `-2` | $330\text{px} \times 270\text{px}$ | Ground anchor: Mylapore temple street |
| **1700m** | Marina Beach Lighthouse | `LOC-TN-22` | `ROADSIDE_LANDMARK` | `-2` | $320\text{px} \times 180\text{px}$ | Ground anchor: beach promenade |
| **1800m** | Chennai Marina Destination Arch | `tn_destination` | `ROADSIDE_PROP` | `+1` | Finish Arch | Route completion victory line |

---

## 3. Offshore Platform Separation & Composition

### 3.1 Thiruvalluvar Statue Pedestal Island
- **Real Geography:** The $133\text{-foot}$ stone statue of poet-philosopher Thiruvalluvar stands on a dedicated $38\text{-foot}$ stone pedestal on a small rock island $400\text{m}$ offshore in the Laccadive Sea.
- **In-Engine Implementation:**
  - Sits on its own custom procedural **Dravidian stone pedestal island** (`IslandPlatformsPass`, `z_index = -4`).
  - Island dimensions: $460\text{px}$ wide, 3 distinct stone masonry tiers, decorative cornice moldings.
  - The statue (`z_index = -3`) is rendered complete from head to base without being cut off by the highway or buried in dirt.
  - The road does not run over the statue; instead, the player drives across the raised glass bridge deck beside the island.
  - The signboard is positioned cleanly on the bridge observation platform ($x = -110\text{px}, y = -42\text{px}, \text{z\_index} = 1$), leaving the monument $100\%$ uncovered.

### 3.2 Vivekananda Rock Memorial Island
- **Real Geography:** Sits on a large natural granite rock island approximately $500\text{m}$ offshore, adjacent to the Thiruvalluvar island.
- **In-Engine Implementation:**
  - Sits on its own custom procedural **granite rock island** (`IslandPlatformsPass`, `z_index = -4`).
  - Island dimensions: $560\text{px}$ wide, layered dark brown/grey sea-weathered granite strata with surrounding wave foam collars.
  - Vivekananda Memorial temple (`z_index = -3`) rests directly on the rock plateau.
  - Connected to the Thiruvalluvar island via the raised arched glass bridge deck ($295\text{m} - 425\text{m}$).

---

## 4. Visual Quality & Absence of Occlusion

1. **Signboard Decoupling:** Every signboard across all landmarks is strictly offset by $110\text{px}$ to the side at the road shoulder line. The artwork of every temple, statue, fort, and palace is fully visible to the player.
2. **Breathing Room:** The procedural prop generator enforces a **minimum $650\text{px}$ exclusion radius** around all 12 landmarks. No generic village houses, repetitive palms, or roadside tea stalls crowd the famous monuments.
3. **Scale Clamping:** Monument heights are strictly clamped between $220\text{px}$ and $360\text{px}$, matching mobile viewport proportions without towering off-screen.
