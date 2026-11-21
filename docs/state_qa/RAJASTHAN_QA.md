# STATE QA REPORT: RAJASTHAN (THAR DESERT ROYAL SPEEDWAY)
**Project:** Hill Climb V2  
**Engine:** Godot 4.7 (`v4.7.2.stable.arch_linux.ed1daf0bf`)  
**Route:** Jaipur → Jaisalmer  
**Total Distance:** 1200m (120,000 px)  
**Inspector:** Joel (Gameplay Engineer & Environment Artist)  
**Status:** PASSED (All Acceptance Criteria Met)  

---

## 1. Route Configuration & Geography Verification

| Property | Value | Verification Status |
| :--- | :--- | :--- |
| **State Name** | Rajasthan | ✓ Confirmed in `RouteRegistry.gd` |
| **Start City** | Jaipur (The Pink City, Ajmeri Gate) | ✓ Verified |
| **Checkpoint 1** | Jodhpur Blue City Checkpoint (650m) | ✓ Verified |
| **Destination** | Jaisalmer Golden Fort & Thar Desert Dunes (1200m) | ✓ Verified |
| **Terrain Profile** | Sun-baked desert asphalt, sweeping golden sand dunes, arid desert shrubs | ✓ Verified |
| **Route Map Asset** | `res://assets/indian_locations/rajasthan_state_map.svg` | ✓ Verified |

---

## 2. Landmark & Component Inspection Matrix

| Landmark / Component | Type | Distance | Visual Asset | Scale & Dimensions | Z-Index Layering | Ground Alignment | Verification Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Hawa Mahal** | Palace of Winds | 100m | `hawa_mahal_vector.png` | 260px H × 260px W | `z_index = -2` | **0.00 px gap** (Flush with sand) | Pink sandstone honeycomb jharokhas grounded cleanly on desert roadside shoulder. |
| **Amber Fort Gateway** | Hill Fortress | 250m | `amber_fort_gateway.png` | 250px H × 280px W | `z_index = -2` | **0.00 px gap** | Maota Lake ramparts sit flush with road shoulder. |
| **Jal Mahal** | Water Palace | 420m | `jal_mahal_palace.png` | 210px H × 280px W | `z_index = -3` (Man Sagar Lake) | Waterline alignment | Submerged Rajput palace resting in lake pass behind road shoulder. |
| **Jodhpur Toll Checkpoint** | Desert Toll Plaza | 650m | `indian_checkpoint_gate.png` | 180px H | Booth (`-1`), Arm (`0`) | Grounded | Mechanical boom barrier arm rotates smoothly upward (-78°) on approach; Mehrangarh visible in background. |
| **Mehrangarh Fort** | Cliff Citadel | 750m | `mehrangarh_fort.png` | 250px H × 280px W | `z_index = -3` | Mountain rock foundation | Monumental cliff citadel rising from desert plateau behind highway. |
| **Jaisalmer Golden Fort** | Sonar Qila | 1020m | `jaisalmer_fort.png` | 250px H × 280px W | `z_index = -2` | **0.00 px gap** | Yellow sandstone bastions blend seamlessly into Thar Desert dune verges. |
| **Jaisalmer Finish Arch** | Finish Arch | 1200m | `indian_finish_arch.png` | 240px H archway | Arch (`-1`), Text (`+3`) | Grounded | Reaches Thar Desert oasis terminal; awards 350 coins and unlocks Gujarat route. |

---

## 3. Route Map Integration Check

- **State Map Asset:** Loaded from `res://assets/indian_locations/rajasthan_state_map.svg`.
- **Route Line:** Traversal vector connecting Jaipur $(0.68, 0.42) \to$ Amber Fort $(0.72, 0.38) \to$ Jodhpur CP $(0.46, 0.48) \to$ Jaisalmer $(0.18, 0.45)$.
- **Dynamic Waypoints:** Distinct green start, gold checkpoint, and red destination markers across Thar Desert geography.
- **Player Marker:** Real-time distance tracker accurately tracking progress across Rajasthan highway.

---

## 4. Vehicle Physics & Wheel Alignment

- **Desert High-Speed Roll:** Vehicle reaches 85 km/h on flat desert stretches with stable axle tracking.
- **Nitro on Sand Dunes:** Anti-wheelie stabilization eliminates bounce; both wheels track sand road smoothly.
- **Visual Flame Order:** Flames render behind vehicle body and tires at `z_index = -2`.

---

## 5. Visual QA Sign-Off

- **Status:** APPROVED & PRODUCTION READY
