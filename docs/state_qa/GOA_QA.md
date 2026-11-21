# STATE QA REPORT: GOA (KONKAN COASTAL CRUISE)
**Project:** Hill Climb V2  
**Engine:** Godot 4.7 (`v4.7.2.stable.arch_linux.ed1daf0bf`)  
**Route:** Panaji → Margao  
**Total Distance:** 950m (95,000 px)  
**Inspector:** Joel (Gameplay Engineer & Environment Artist)  
**Status:** PASSED (All Acceptance Criteria Met)  

---

## 1. Route Configuration & Geography Verification

| Property | Value | Verification Status |
| :--- | :--- | :--- |
| **State Name** | Goa | ✓ Confirmed in `RouteRegistry.gd` |
| **Start City** | Panaji (Capital of Goa, Fontainhas colonial quarter) | ✓ Verified |
| **Checkpoint 1** | Mandovi River Bridge Checkpoint (480m) | ✓ Verified |
| **Destination** | Margao Railway Terminal & Coastal Palm Promenade (950m) | ✓ Verified |
| **Terrain Profile** | Golden coastal sands, gentle beach road undulations, coconut groves | ✓ Verified |
| **Route Map Asset** | `res://assets/indian_locations/goa_state_map.svg` | ✓ Verified |

---

## 2. Landmark & Component Inspection Matrix

| Landmark / Component | Type | Distance | Visual Asset | Scale & Dimensions | Z-Index Layering | Ground Alignment | Verification Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Church of Our Lady** | Colonial Church | 90m | `our_lady_immaculate_conception_vector.png` | 230px H × 250px W | `z_index = -2` | **0.00 px gap** (Flush with sand) | White baroque zig-zag stairs rest naturally on the golden sandy roadside verge. |
| **Fort Aguada Lighthouse** | Coastal Fort | 210m | `aguada_fort_lighthouse.png` | 240px H × 220px W | `z_index = -2` | **0.00 px gap** | Portuguese stone masonry grounded on coastal laterite headland. |
| **Mandovi River Bridge** | River Structure | 380m | `mandovi_bridge_vector.png` | 180px H × 280px W | `z_index = -2` | Grounded piers | Spans mangrove estuary with clean road connection. |
| **Mandovi Toll Plaza** | Checkpoint Gate | 480m | `indian_checkpoint_gate.png` | 180px H | Booth (`-1`), Arm (`0`) | Grounded | Mechanical boom barrier arm rotates smoothly upward (-78°) on vehicle entry; booth stays grounded. |
| **Basilica of Bom Jesus** | UNESCO Heritage | 520m | `basilica_bom_jesus_vector.png` | 250px H × 270px W | `z_index = -2` | **0.00 px gap** | Red laterite facade grounded cleanly with authentic Goan architectural proportions. |
| **Se Cathedral** | Cathedral | 700m | `se_cathedral_goa.png` | 240px H × 280px W | `z_index = -2` | **0.00 px gap** | Portuguese Manueline facade sits behind road shoulder without vehicle clipping. |
| **Margao Finish Arch** | Finish Arch | 950m | `indian_finish_arch.png` | 240px H archway | Arch (`-1`), Text (`+3`) | Grounded | Vehicle crosses finish line; rewards 300 coins and unlocks Kerala highway. |

---

## 3. Route Map Integration Check

- **State Map Asset:** Loaded from `res://assets/indian_locations/goa_state_map.svg`.
- **Route Line:** Traversal vector connecting Panaji $(0.38, 0.32) \to$ Calangute $(0.28, 0.26) \to$ Mandovi CP $(0.44, 0.42) \to$ Margao $(0.55, 0.74)$.
- **Dynamic Waypoints:** Distinct green start, gold checkpoint, and red destination markers.
- **Player Marker:** Real-time distance tracker showing progress along Goan coastal highway.

---

## 4. Vehicle Physics & Wheel Alignment

- **Settled Deflection:** $3.43\text{ px}$.
- **Driving on Sand Terrain:** Smooth roll without wheel sinking; suspension tracks dips seamlessly.
- **Nitro Acceleration:** Wheel alignment preserved at $< 3.2\text{ px}$ delta; flame effects emerge behind wheels.

---

## 5. Visual QA Sign-Off

- **Status:** APPROVED & PRODUCTION READY
