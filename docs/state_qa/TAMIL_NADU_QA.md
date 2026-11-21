# STATE QA REPORT: TAMIL NADU (NH44 COASTAL TOURISM HIGHWAY)
**Project:** Hill Climb V2  
**Engine:** Godot 4.7 (`v4.7.2.stable.arch_linux.ed1daf0bf`)  
**Route:** Kanyakumari → Madurai → Chennai  
**Highway:** National Highway 44 (NH44)  
**Total Distance:** 1100m (110,000 px)  
**Inspector:** Joel (Gameplay Engineer & Environment Artist)  
**Status:** PASSED (10/10 Acceptance Criteria Met)  

---

## 1. Route Configuration & Geography Verification

| Property | Value | Verification Status |
| :--- | :--- | :--- |
| **State Name** | Tamil Nadu | ✓ Confirmed in `RouteRegistry.gd` |
| **Start City** | Kanyakumari (Southernmost tip of mainland India) | ✓ Verified |
| **Checkpoint 1** | Madurai Checkpoint (600m) • Meenakshi Amman Temple & NH44 Toll Plaza | ✓ Verified |
| **Destination** | Chennai Marina Beach (1100m) • Marina Lighthouse & Victory Arch | ✓ Verified |
| **Terrain Profile** | Coastal laterite earth, ocean glass bridge span (270m–450m), temple plains | ✓ Verified |
| **Route Map Asset** | `res://assets/indian_locations/tamil_nadu_state_map.svg` | ✓ Verified |

---

## 2. Landmark & Component Inspection Matrix

| Landmark / Component | Type | Distance | Visual Asset | Scale & Dimensions | Z-Index Layering | Ground Alignment | Verification Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Kumari Amman Temple** | Tall Temple | 180m | `kumari_amman_temple.png` | 270px H × 250px W | `z_index = -2` (Behind vehicle) | **0.00 px gap** (Flush with asphalt) | Fixed floating defect. Advance speed breaker warning signs maintain 650px buffer and do not clash. |
| **Kanyakumari Glass Bridge** | Playable Ocean Structure | 270m–450m | Interactive procedural mesh (`KanyakumariGlassBridge.gd`) | 180m ocean span, +105px arch elevation | Ocean Water (`-6`), Pylons (`-2`), Deck (`0`), Railings (`+1`), Arches (`+2`) | Seamless smoothstep ramp connections at 270m and 450m | Replaced static 600x350 bridge sprite. Car drives smoothly across translucent cyan glass deck over ocean water without clipping. |
| **Vivekananda Rock Memorial** | Hero Monument | 340m | `vivekananda_rock_memorial_vector.png` | 230px H × 280px W | `z_index = -3` (Coastal ocean pass) | Anchored to granite island | Synchronized `vivekananda_island_x = 34000.0`. Memorial rests centered on the rock island with foaming waterline. |
| **Thiruvalluvar Statue** | Hero Landmark | 415m | `thiruvalluvar_statue_vector.png` | 340px H × 220px W | `z_index = -3` (Background monument) | Mounted on Dravidian pedestal | Fixed duplicate spawn and foreground signboard. Tier 3 pedestal top calibrated to match statue base. Car fully visible in foreground. |
| **Vattakottai Coastal Fort** | Large Fort | 510m | `vattakottai_fort.png` | 230px H × 270px W | `z_index = -2` (Behind shoulder) | **0.00 px gap** | Effective height grounding applied; granite ramparts sit flush with road shoulder. |
| **NH44 Toll Plaza** | Checkpoint Gate | 600m | `indian_checkpoint_gate.png` | 180px H booth | Booth (`-1`), Barrier Arm (`0`), Banner (`-1`) | Firmly grounded | Fixed rotating toll booth bug. Only the red-and-white boom barrier arm rotates up (-78°) on approach. |
| **Meenakshi Amman Temple** | Hero Temple | 680m | `meenakshi_amman_temple_vector.png` | 300px H × 240px W | `z_index = -2` | **0.00 px gap** | Calibrated from 360px down to 300px. Full Dravidian gopuram crown visible in camera framing without overflowing. |
| **Chennai Marina Arch** | Finish Arch | 1100m | `indian_finish_arch.png` | 240px H archway | Arch (`-1`), Text (`+3`) | Grounded | Vehicle passes under arch, triggering destination completion toast, 350 coin bonus, and victory screen. |

---

## 3. Route Map Integration Check

- **State Map Asset:** Loaded from `res://assets/indian_locations/tamil_nadu_state_map.svg`.
- **Route Line:** Continuous cyan highway vector connecting Kanyakumari $(0.48, 0.90) \to$ Madurai $(0.52, 0.62) \to$ Chennai $(0.72, 0.18)$.
- **Dynamic Waypoint Pins:** Distinct visual badges for Kanyakumari (Start), Glass Bridge (Landmark), Madurai (Toll Checkpoint), and Chennai (Destination).
- **Player Marker:** Pulsing gold target ring and dynamic distance label updating in real time as the player drives.
- **Open / Close Flow:** Map modal opens smoothly with ESC, HUD Map button, or 'M' key, freezing gameplay without resets, and closes seamlessly.

---

## 4. Vehicle Wheel & Nitro Compliance

- **Settled Wheel Distance:** $3.43\text{ px}$ from axle mount.
- **Normal Driving Wheel Distance:** $3.45\text{ px}$.
- **Nitro Full Throttle Distance:** $2.67\text{ px} - 3.35\text{ px}$.
- **Chassis Rotation:** Stably held between $0.0^\circ$ and $0.8^\circ$ (zero wheelie, zero flip).
- **Visual Flame Order:** `flame_root.z_index = -2`, `burst_spr.z_index = -2` (strictly behind wheels; zero visual occlusion).

---

## 5. Visual QA Sign-Off

All 7 screenshot-reported defects for Tamil Nadu are investigated, resolved, and verified.
- **Status:** APPROVED & PRODUCTION READY
