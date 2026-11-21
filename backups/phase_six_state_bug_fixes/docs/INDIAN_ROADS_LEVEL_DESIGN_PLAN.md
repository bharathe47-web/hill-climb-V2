# Indian Roads Level Design & Scenery Progression Plan

**Project:** Godot 4.7 2D Mobile Driving Game  
**Author / Lead Level Designer:** Joel (Senior Godot Developer, Environment & Level Designer)  
**Date:** November 14, 2026  
**Document:** `docs/INDIAN_ROADS_LEVEL_DESIGN_PLAN.md`  
**Git Branch:** `feature/joel-roads-obstacles`  
**Target Journey Duration:** 3 to 5 Minutes per State Route  
**Target Game Scale:** 1,600m to 2,200m Game Distance (160,000 px to 220,000 px)  

---

## 1. Executive Summary & Design Critique

The initial prototype implementation suffered from two primary pacing defects:
1. **House & Tree Repetition:** Village house sprites and coconut trees were spawned in an uninterrupted, uniform pattern along the roadside, causing visual fatigue and making different states feel like the same track with different background colours.
2. **Excessive Empty Driving:** Large stretches of empty asphalt separated major checkpoints, diluting the sense of a cultural road journey across India.

### Core Level Design Objectives
- **5 to 7 Distinct Scenery Zones per State:** Break each route into distinct thematic micro-biomes (e.g., Coastal Departure → Coconut Groves → Heritage Village → High Ghats → Temple City → Modern Coastal Highway → Destination Arch).
- **Rhythmic Pacing (3 to 5 Minutes):** Calibrated to mobile driving session lengths. At average driving speeds (15–25 m/s), 1,600m–2,200m takes between **2.5 and 4.5 minutes** of focused driving with elevation challenges, potholes, and speed breakers.
- **Interspersed Optional Landmark Sightings:** Position optional famous places (from the 150-location catalogue) as roadside vistas, background silhouette monuments, and bridge crossings between primary checkpoints.

---

## 2. Six-State Scenery Zonation Blueprints

### 2.1. Tamil Nadu: Kanyakumari to Chennai (1,800m)
- **Zone 1: Kanyakumari Coastal Departure (`0m – 300m`)**
  - *Visual Theme:* Ocean horizon, breaking waves, salt-spray breeze, fishing catamarans on the shore.
  - *Props:* Decoupled kilometer milestone `KM 0`, low whitewashed sea wall, fishing nets.
- **Zone 2: Coastal Monolithic Monuments (`300m – 650m`)**
  - *Visual Theme:* Thiruvalluvar 133-ft stone statue (`350m`) and Vivekananda Rock Memorial (`700m`) standing on offshore rocky pedestals.
  - *Road Terrain:* Gentle sweeping coastal humps, yellow highway striping.
- **Zone 3: Rural Coromandel Village & Agricultural Belt (`650m – 1,000m`)**
  - *Visual Theme:* Traditional Tamil houses with red terracotta Mangalore tiles, kolam chalk floor patterns, roadside tender coconut stall (`elaneer`).
  - *Props:* Banyan trees with aerial roots, bullock cart silhouettes.
- **Zone 4: Madurai Temple Gateway Corridor (`1,000m – 1,350m`)**
  - *Visual Theme:* Soaring polychrome Meenakshi Temple gopuram (`1,050m`), roadside garland flower shops, brass temple bell stalls.
  - *Road Terrain:* Moderate elevation changes, road-widening divider.
- **Zone 5: Urban Marina Beach Drive (`1,350m – 1,650m`)**
  - *Visual Theme:* Marina Lighthouse (`1,400m`), coastal promenade with ornate lamp posts, snack shacks (`sundal`), broad asphalt avenue.
- **Zone 6: Chennai Heritage Destination (`1,650m – 1,800m`)**
  - *Visual Theme:* Fort St. George walls, San Thome Basilica white spire, Chennai Destination Finish Arch with triumphal bunting and confetti.

---

### 2.2. Goa: Panaji to Margao (1,600m)
- **Zone 1: Panaji Latin Quarter Departure (`0m – 350m`)**
  - *Visual Theme:* Fontainhas historic streets, vibrant ochre, cobalt blue, and terracotta Portuguese colonial villas, wrought-iron balconies.
- **Zone 2: Mandovi Riverfront & Coastal Groves (`350m – 700m`)**
  - *Visual Theme:* Palm-fringed estuary road, Atal Setu cable bridge pylons in the distant horizon, wooden fishing boats.
- **Zone 3: North Coast Beach Road & Shacks (`700m – 1,000m`)**
  - *Visual Theme:* Calangute beach shacks with thatched canopies, surfboards, auto-rickshaws, red laterite road shoulder.
- **Zone 4: Old Goa Baroque Heritage (`1,000m – 1,350m`)**
  - *Visual Theme:* Basilica of Bom Jesus red laterite unplastered facade (`1,200m`), Se Cathedral white bell tower, Viceroy's Arch.
- **Zone 5: Western Ghats Spice Foothills (`1,350m – 1,500m`)**
  - *Visual Theme:* Lush semi-evergreen Western Ghats backdrop, betel nut palm clusters, roadside feni and spice stalls.
- **Zone 6: Margao Cultural Center Destination (`1,500m – 1,600m`)**
  - *Visual Theme:* Church of the Holy Spirit Baroque square, Margao Municipal garden plaza, checkered finish arch.

---

### 2.3. Kerala: Kochi to Munnar (2,000m)
- **Zone 1: Malabar Port & Chinese Fishing Nets (`0m – 400m`)**
  - *Visual Theme:* Cantilevered Chinese fishing nets along the waterfront, spice warehouses, colonial rain trees.
- **Zone 2: Alleppey Backwaters & Lagoons (`400m – 800m`)**
  - *Visual Theme:* Thatched Kettuvallam houseboats gliding past palm banks (`500m`), lotus wetlands, duck farms.
- **Zone 3: Lowland Rubber & Coconut Plantations (`800m – 1,200m`)**
  - *Visual Theme:* Dense green tropical rubber plantations, High Range Toll Booth (`1,000m`), roadside toddy and banana chip stalls.
- **Zone 4: Mountain Ghat Ascent & Waterfalls (`1,200m – 1,600m`)**
  - *Visual Theme:* Cheeyappara cascading waterfalls, steep winding mountain slopes, misty ravine overlooks.
  - *Road Terrain:* Challenging uphill climbs, tight hairpin crests requiring careful throttle management.
- **Zone 5: Munnar Emerald Tea Estates (`1,600m – 1,900m`)**
  - *Visual Theme:* Sculpted undulating emerald green tea bush contours (`1,500m`), tea pickers with baskets, eucalyptus windbreaks.
- **Zone 6: High Range Mountain Summit (`1,900m – 2,000m`)**
  - *Visual Theme:* Anamudi mountain backdrop, cool misty summit ridge, Munnar Hill Top Finish Arch.

---

### 2.4. Rajasthan: Jaipur to Jaisalmer (2,200m)
- **Zone 1: Pink City Royal Departure (`0m – 450m`)**
  - *Visual Theme:* Terracotta pink palace facades, arched city gates, camel carts, brass lantern street lamps.
- **Zone 2: Amber Fort & Aravalli Pass (`450m – 850m`)**
  - *Visual Theme:* Majestic yellow and pink sandstone Amber Fort (`550m`) rising above Maota Lake, defensive hill ramparts.
- **Zone 3: Marwar Arid Scrubland & Steppe (`850m – 1,250m`)**
  - *Visual Theme:* Khejri trees, dry thorn scrub, Mehrangarh Fort cliff rampart rising in the distance (`1,100m`), blue-painted houses.
- **Zone 4: Sandstone Oasis & Caravanserai (`1,250m – 1,650m`)**
  - *Visual Theme:* Jaisalmer Golden Fort "Sonar Qila" (`1,650m`), carved Patwon Ki Haveli balconies, Gadisar Lake chattris.
- **Zone 5: Thar Desert Shifting Sand Dunes (`1,650m – 2,050m`)**
  - *Visual Theme:* Sam Sand Dunes sweeping golden ridges, camel safari silhouettes, colorful Rajasthani turbans.
  - *Road Terrain:* Sandy dips, undulating dune crests with reduced tire traction.
- **Zone 6: Desert Fortress Sunset Destination (`2,050m – 2,200m`)**
  - *Visual Theme:* Sun setting orange over the Thar Desert horizon, traditional folk music camp tents, golden finish arch.

---

### 2.5. Gujarat: Ahmedabad to Rann of Kutch (2,000m)
- **Zone 1: Sabarmati Urban Heritage Departure (`0m – 400m`)**
  - *Visual Theme:* Sabarmati riverfront promenade, historic wooden pol house facades, Adalaj stepwell motifs.
- **Zone 2: Saurashtra Highway Corridor (`400m – 800m`)**
  - *Visual Theme:* Saurashtra Highway Dhaba (`500m`) with charpais and tandoor ovens, yellow highway dividers, truck art.
- **Zone 3: Arid Banni Grasslands & Bhunga Villages (`800m – 1,200m`)**
  - *Visual Theme:* Circular mud-block thatched bhungas decorated with mirror lipan craft, cattle herds, acacia thorn trees.
- **Zone 4: Flamingo Sanctuary Wetland Pass (`1,200m – 1,550m`)**
  - *Visual Theme:* Shimmering salt marshes dotted with thousands of pink flamingos (`1,000m`), elevated causeway over water.
- **Zone 5: White Desert of Kutch Expanses (`1,550m – 1,900m`)**
  - *Visual Theme:* Blinding white crystalline salt crust stretching to infinity (`1,500m`), Rann Utsav festive tent cities.
- **Zone 6: Dhordo Sunset Mirage Destination (`1,900m – 2,000m`)**
  - *Visual Theme:* Sunset over the salt desert reflecting violet and crimson, illuminated handicraft archway, destination finish banner.

---

### 2.6. Telangana: Hyderabad to Warangal (1,800m)
- **Zone 1: Nizam City Gateway Departure (`0m – 350m`)**
  - *Visual Theme:* Charminar minaret silhouettes, granite city archways, pearl market shops, Irani chai cafes.
- **Zone 2: Golconda Granite Fortress Pass (`350m – 700m`)**
  - *Visual Theme:* Cyclopean Golconda Fort bastions (`450m`), ancient acoustic Balahissar gateway, rocky boulder ravines.
- **Zone 3: Deccan Plateau Boulder Landscape (`700m – 1,050m`)**
  - *Visual Theme:* Iconic Deccan balancing rock formations, dry deciduous scrub, rustic stone milestones.
- **Zone 4: Kakatiya Royal Heritage Corridor (`1,050m – 1,450m`)**
  - *Visual Theme:* Monolithic Kakatiya Dynasty Kala Thoranam gateways (`900m`), Thousand Pillar Temple basalt pillars (`1,350m`).
- **Zone 5: Rural Tank Irrigation & Paddy Fields (`1,450m – 1,700m`)**
  - *Visual Theme:* Sprawling agricultural lake bunds, palm toddy trees, lush green rice paddies, bullock carts.
- **Zone 6: Warangal Heritage Citadel Destination (`1,700m – 1,800m`)**
  - *Visual Theme:* Ramappa Temple stone carvings, Warangal Fort inner earthen ramparts, royal victory finish arch.

---

## 3. Pacing & Journey Length Verification

| State Route | Game Distance | Average Vehicle Speed | Estimated Active Driving Time | Scenery Zones | Pacing Assessment |
|---|---|---|---|---|---|
| **Tamil Nadu** | 1,800m | 18 m/s (~65 km/h) | **3m 15s** | 6 Zones | Optimal mobile driving length; high visual variety |
| **Goa** | 1,600m | 17 m/s (~60 km/h) | **2m 55s** | 6 Zones | Fast-paced coastal sprint with rich architecture |
| **Kerala** | 2,000m | 15 m/s (~54 km/h) | **3m 40s** | 6 Zones | Slower mountain climb with steep hairpins |
| **Rajasthan** | 2,200m | 20 m/s (~72 km/h) | **3m 35s** | 6 Zones | Long desert straights with undulating dune jumps |
| **Gujarat** | 2,000m | 19 m/s (~68 km/h) | **3m 25s** | 6 Zones | Wide open salt flat driving with wetland bridges |
| **Telangana** | 1,800m | 18 m/s (~65 km/h) | **3m 20s** | 6 Zones | Varied plateau terrain with rocky technical sections |

---

## 4. Implementation Guidelines for Technical Artists

1. **Zone Switching via Distance Modulo:**
   In [IndianRoadTerrainV2.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/modes/indian_roads/IndianRoadTerrainV2.gd), modulate the prop spawner weight table based on current segment `x` coordinates:
   ```gdscript
   var current_zone: int = int(segment_x / (route_total_x / 6.0))
   ```
2. **Dynamic Density Scaling:**
   - Zone 1 & 6 (Urban / Departure / Arrival): High building density (every 120px), low tree density.
   - Zone 2 & 5 (Suburban / Natural): Balanced mix of trees, roadside signs, and occasional shops.
   - Zone 3 & 4 (Rural / Wilderness): Zero buildings; rich terrain contouring, natural vegetation, and landmark monuments.
3. **Elimination of House Clumping:**
   Ensure a minimum separation of `450 px` between repeating building facade variations to prevent unnatural duplication.
