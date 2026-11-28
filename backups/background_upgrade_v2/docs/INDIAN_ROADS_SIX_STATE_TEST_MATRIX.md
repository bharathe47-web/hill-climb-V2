# Indian Roads Six-State Formal QA Test Matrix

**Author:** Joel (Senior Godot 4.7 QA Architect & Integration Lead)  
**Date:** November 14, 2026  
**Document:** `docs/INDIAN_ROADS_SIX_STATE_TEST_MATRIX.md`  
**Engine:** Godot Engine 4.7.2 Stable (Linux x86_64 Headless & Viewport QA)  
**Target Suite:** `tests/test_all_six_indian_roads_states.gd`

---

## 1. Formal Six-State Test Matrix

| Verification Dimension | Tamil Nadu | Goa | Kerala | Rajasthan | Gujarat | Telangana |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **State Selection** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Scene Loading** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Route Resource Integrity** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Background / Parallax** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Landmark Asset Loading** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Vehicle Spawn & Mounting** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Road Scrolling & Physics** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Checkpoint Order** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Checkpoint Activation** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Destination Reachability** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Completion Screen Trigger** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Restart Cycle (Safe Reset)** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |
| **Exit to Hub / Main Menu** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** | **PASS** |

**Matrix Result: 13 / 13 Test Dimensions Passed across all 6 States (78 / 78 Passing Criteria).**

---

## 2. Individual State Test Logs & Operational Metrics

### 1. Tamil Nadu (`tamil_nadu`)
- **State Selection Result:** Card displays `state_select_tamil_nadu.png`, active by default.
- **Scene Load Result:** `IndianRoadsModeV2.tscn` instantiates cleanly.
- **Route Data Result:** 1,800m, 6 waypoints (0m, 350m, 750m, 1150m, 1450m, 1800m).
- **Environment Background:** Azure coastal sky, ocean horizon, Tamil red-tiled village row.
- **Landmark Loading:** Thiruvalluvar Statue, Meenakshi Gopuram, Marina Lighthouse loaded at native dimensions without blur.
- **Vehicle Spawn:** `BlueFlameTruck` spawned on road at `(0.0, 342.60)`.
- **Road Scrolling:** Physics tick 60Hz stable, smooth camera follow.
- **Checkpoint Behavior:** Madurai Checkpoint (750m) and Coastal Toll (1450m) award coins and increment count.
- **Destination:** Marina Beach finish arch triggers victory and coin banking.

### 2. Goa (`goa`)
- **State Selection Result:** Card active upon TN completion (or via `dev_unlock_all_routes`).
- **Scene Load Result:** Instantiates with tropical shader parameters.
- **Route Data Result:** 1,600m, 5 waypoints.
- **Environment Background:** Tropical sky, lush Western Ghats (0% snow), Portuguese Fontainhas village row.
- **Landmark Loading:** Basilica of Bom Jesus, Our Lady of Immaculate Conception Church, Calangute Beach loaded cleanly.
- **Vehicle Spawn:** Verified at `(0.0, 342.60)`.
- **Road Scrolling:** Smooth cruising along golden sand shoulders.
- **Checkpoint Behavior:** Mandovi Bridge Toll (800m) triggers cleanly.
- **Destination:** Margao City finish arch triggers victory cleanly.

### 3. Kerala (`kerala`)
- **State Selection Result:** Active upon Goa completion.
- **Scene Load Result:** Instantiates with steep hill climb parameters.
- **Route Data Result:** 2,000m, 5 waypoints.
- **Environment Background:** Misty Western Ghats backwaters and tea hills.
- **Landmark Loading:** Alleppey Kettuvallam Houseboat and Munnar Tea Plantation terraces loaded cleanly.
- **Vehicle Spawn:** Verified at `(0.0, 342.60)`.
- **Road Scrolling:** High elevation curves (`wave_amp = 1.25`) challenge suspension properly.
- **Checkpoint Behavior:** Ghats Checkpoint (1000m) awards 140 coins.
- **Destination:** Munnar Hill Station finish arch triggers cleanly.

### 4. Rajasthan (`rajasthan`)
- **State Selection Result:** Active upon Kerala completion.
- **Scene Load Result:** Instantiates with desert speedway parameters.
- **Route Data Result:** 2,200m, 5 waypoints.
- **Environment Background:** Thar desert golden sands and dunes.
- **Landmark Loading:** Amber Fort sandstone citadel, Mehrangarh cliff bastion, and Jaisalmer Golden Fort.
- **Vehicle Spawn:** Verified at `(0.0, 342.60)`.
- **Road Scrolling:** Low amplitude rolling dunes (`wave_amp = 0.65`) allow high top speed.
- **Checkpoint Behavior:** Thar Expressway Toll (1100m) triggers cleanly.
- **Destination:** Jaisalmer finish arch triggers cleanly.

### 5. Gujarat (`gujarat`)
- **State Selection Result:** Active upon Rajasthan completion.
- **Scene Load Result:** Instantiates with Rann salt flat parameters.
- **Route Data Result:** 2,000m, 5 waypoints.
- **Environment Background:** White Rann salt flats and Stepwell oasis.
- **Landmark Loading:** Saurashtra Stepwell Oasis, Flamingo Sanctuary flock, White Rann Bhunga huts.
- **Vehicle Spawn:** Verified at `(0.0, 342.60)`.
- **Road Scrolling:** Wide salt plain driving with pale clay shoulder.
- **Checkpoint Behavior:** Kutch Border Gate (1000m) triggers cleanly.
- **Destination:** Great Rann finish arch triggers cleanly.

### 6. Telangana (`telangana`)
- **State Selection Result:** Active upon Gujarat completion.
- **Scene Load Result:** Instantiates with Deccan plateau rolling hills.
- **Route Data Result:** 1,800m, 5 waypoints.
- **Environment Background:** Balancing boulders and dark granite outcrops.
- **Landmark Loading:** Golconda Fort Balahisar Gate, Kakatiya Dynasty Kirti Torana, Thousand Pillar Temple.
- **Vehicle Spawn:** Verified at `(0.0, 342.60)`.
- **Road Scrolling:** Granite rolling terrain with red grit shoulder.
- **Checkpoint Behavior:** Outer Ring Road Toll (900m) triggers cleanly.
- **Destination:** Warangal finish arch triggers cleanly.
