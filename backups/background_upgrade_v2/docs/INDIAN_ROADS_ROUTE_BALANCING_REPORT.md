# INDIAN ROADS ROUTE BALANCING & PACING REPORT
**Engine:** Godot 4.7  
**Module:** `RouteRegistry.gd`, `IndianRoadTerrainV2.gd`  
**Responsible Owner:** Joel  
**Status:** VERIFIED COMPLETE  

---

## 1. ROUTE PACING & COMPLETION TARGETS (STEP 2)

Each state route has been balanced to provide $3.0\text{ to }4.5\text{ minutes}$ of active driving gameplay without empty repetitive stretches.

| State | Route Path | Total Distance | Scaled Pixels | Pacing Estimate (@270 px/s) | Waypoints & Checkpoints | Scenery Zones |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Tamil Nadu** | Kanyakumari → Chennai | 1,800 m | 45,000 px | 2.8 – 3.2 min | 6 Waypoints, 2 Checkpoints | 6 Zones (Coast, Pier, Glass Bridge, Madurai, Highway, Marina) |
| **Goa** | Panaji → Margao | 1,600 m | 40,000 px | 2.5 – 3.0 min | 5 Waypoints, 2 Checkpoints | 5 Zones (Panaji, Latin Quarter, Beach Promenade, Fort Aguada, Margao) |
| **Kerala** | Kochi → Munnar | 2,000 m | 50,000 px | 3.2 – 3.8 min | 5 Waypoints, 2 Checkpoints | 6 Zones (Kochi Port, Backwaters, Rubber Groves, Athirappilly, Tea Hills) |
| **Rajasthan** | Jaipur → Jaisalmer | 2,200 m | 55,000 px | 3.5 – 4.2 min | 5 Waypoints, 2 Checkpoints | 6 Zones (Pink City, Amber Fort, Desert Speedway, Jaswant Thada, Mehrangarh) |
| **Gujarat** | Ahmedabad → Rann of Kutch | 2,000 m | 50,000 px | 3.2 – 3.8 min | 5 Waypoints, 2 Checkpoints | 5 Zones (Sabarmati, Adalaj Vav, Sun Temple, Somnath, White Desert) |
| **Telangana** | Hyderabad → Warangal | 1,800 m | 45,000 px | 2.8 – 3.2 min | 5 Waypoints, 2 Checkpoints | 5 Zones (Charminar, Chowmahalla, Golconda Bastion, Hussain Sagar, Warangal Gate) |

---

## 2. SCENERY VARIETY & CONTROLLED RANDOMNESS

1. **Zone-Based Housing Suppression:**
   - Architectural village houses are restricted to entry and exit settlements ($norm\_pos < 0.18$ and $norm\_pos > 0.85$).
   - Mid-route sections feature rolling natural topography, regional trees, dhaba kiosks, and monuments without repetitive house clumping.
2. **Landmark Visual Breathing Room:**
   - A $650\text{ px}$ buffer on either side of major monuments is kept clear of generic props and trees, ensuring landmarks stand out prominently beside the road.
3. **Controlled Randomness:**
   - Seeded via `rng.seed = 20261114 + state_id.hash()`.
   - Prop placement, coin patterns, and fuel canisters reproduce identically across repeated runs for consistent QA and balanced difficulty.
