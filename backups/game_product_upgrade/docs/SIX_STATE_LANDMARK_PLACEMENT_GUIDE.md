# Six-State Landmark Placement & Technical Coordinate Guide

**Project:** Godot 4.7 2D Mobile Driving Game  
**Author / Technical Artist:** Joel (Senior Godot Developer, Technical Artist, Environment Designer)  
**Date:** November 14, 2026  
**Document:** `docs/SIX_STATE_LANDMARK_PLACEMENT_GUIDE.md`  
**Git Branch:** `feature/joel-roads-obstacles`  
**Target Engine:** Godot Engine 4.7 (Forward+ & Compatibility 2D)

---

## 1. Architectural Placement Principles & Coordinate Hierarchy

To avoid visual immersion defects—such as gigantic floating cutouts, occluded signboards, jarring terrain overlaps, or culturally misplaced monuments—all landmarks and waypoints in the Indian Roads mode are placed according to strict mathematical and geographic rules.

### Spatial Dimensions & World Coordinates
- **Coordinate System:** Standard Godot 2D ($+X$ is driving forward/East, $+Y$ is downward into the ground).
- **Scale Factor:** $100\text{ px} = 1\text{ meter}$. A 1,800m route spans $X = 0\text{ px}$ to $X = 180,000\text{ px}$.
- **Ground Anchoring:** The base of every landmark structure is anchored precisely to the dynamically computed terrain height $Y_{\text{ground}}(x)$ using bottom-center pivot offsets (`Vector2(0.5, 1.0)`).
- **Signboard Decoupling:** Signboards and nameplates are decoupled from the monument graphic and placed on roadside milestone posts at ground level, preventing large landmark sprites from obstructing roadway readability.

### Layer & Z-Index Allocation

| Layer Designation | Node Hierarchy | Parallax Factor (`motion_scale`) | Z-Index | Collision | Placement Rule |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Foreground Roadside** | `RoadsideProps` | `Vector2(1.0, 1.0)` | `1` to `3` | Optional Trigger | Interactive milestones, dhabas, tea stalls, barricades |
| **Roadside Landmark** | `Landmarks` | `Vector2(1.0, 1.0)` | `-2` to `-1` | Trigger (`Area2D`) | Primary waypoints, temple gopurams, fort gates, arches |
| **Midground Landscape**| `MidgroundLayer`| `Vector2(0.32, 0.0)` | `-5` | None | Waterlines, backwaters, dune ridges, tea plantation steps |
| **Distant Horizon** | `DistantLayer` | `Vector2(0.18, 0.0)` | `-10` | None | Mountain ranges, ocean horizon, skyline silhouettes |
| **Far Sky & Clouds** | `SkyLayer` / `Clouds`| `Vector2(0.04, 0.0)` / `0.08` | `-20` | None | Natural atmospheric gradients and soft cumulus clouds |

---

## 2. State 1: Tamil Nadu Landmark Placement & Coordinate Schedule

### Route Corridor: Kanyakumari Coast $\rightarrow$ Madurai Temple Town $\rightarrow$ Chennai Marina Coastal Destination (Total: 1,800m)

#### 1. Kanyakumari Pier (Start Waypoint)
- **Asset ID:** `LOC-TN-00`
- **Filename:** `assets/indian_locations/tamil_nadu/kanyakumari/landmarks/kanyakumari_pier.png`
- **Famous Place Name:** Kanyakumari Coastal Pier & Triveni Sangam
- **State & Region:** Tamil Nadu, Kanyakumari District
- **Real Geographical Location:** Cape Comorin, southernmost tip of mainland India ($8.0883^\circ\text{ N}, 77.5385^\circ\text{ E}$)
- **Visual Appearance:** Granite breakwater pier extending into turquoise sea with crashing foam and nautical flag post.
- **Why It Is Famous:** Geographic confluence of the Arabian Sea, Indian Ocean, and Bay of Bengal.
- **Asset Type:** 2D Vector Architectural Environment Node
- **Suggested Route Scene:** `scenes/modes/indian_roads/IndianRoadsModeV2.tscn` (Route: `tamil_nadu`)
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 0\text{ m} = 0\text{ px}, Y: Y_{\text{ground}}(0) - 20\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 12 seconds ($0\text{ m} \rightarrow 150\text{ m}$ at $15\text{ m/s}$)
- **Waypoint Role:** Start Location
- **Status:** **ACTIVE ON DISK** (`res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/`)
- **License & Provenance:** Original Team Vector Artwork (Pycairo), CC0 1.0 Universal. Full commercial rights. No attribution needed.

#### 2. Thiruvalluvar Statue & Vivekananda Rock Memorial (Waypoint 1)
- **Asset ID:** `LOC-TN-01` & `LOC-TN-02`
- **Filename:** `assets/indian_locations/tamil_nadu_thiruvalluvar_statue.png` & `assets/indian_locations/tamil_nadu_vivekananda_rock_memorial.png`
- **Famous Place Name:** Thiruvalluvar Statue & Vivekananda Rock Memorial
- **State & Region:** Tamil Nadu, Kanyakumari Coast
- **Real Geographical Location:** Offshore rocky islands 400m from Kanyakumari shoreline ($8.0780^\circ\text{ N}, 77.5550^\circ\text{ E}$)
- **Visual Appearance:** 133-ft monolithic stone statue holding 3 fingers upward beside red-and-white stone memorial mandapam perched on granite sea rock.
- **Why It Is Famous:** Memorializes ancient poet Valluvar (133 Tirukkural chapters) and Swami Vivekananda's 1892 meditation site.
- **Asset Type:** 2D Vector Clean Heritage Monument (Decoupled Milestone)
- **Suggested Route Scene:** `LandmarkV2.tscn` instantiated dynamically
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-1`)
- **Suggested World Position:** $(X: 350\text{ m} = 35,000\text{ px}, Y: Y_{\text{ground}}(35000) - 40\text{ px})$
- **Recommended Scale:** `Vector2(0.80, 0.80)`
- **Suggested Visibility Duration:** 16 seconds ($250\text{ m} \rightarrow 450\text{ m}$)
- **Waypoint Role:** Major Intermediate Waypoint 1 (HUD Milestone Trigger)
- **Status:** **ACTIVE ON DISK & REPLACED** (Vector upgrade eliminates legacy photo cutout defect).
- **License & Provenance:** CC-BY-SA 4.0 (Wikimedia Commons remediation & Vector re-draw). Attribution in credits.

#### 3. Madurai Meenakshi Amman Temple Gopuram (Waypoint 2)
- **Asset ID:** `LOC-TN-11`
- **Filename:** `assets/indian_locations/tamil_nadu_madurai_meenakshi_temple.png`
- **Famous Place Name:** Meenakshi Sundareswarar Temple South Gopuram
- **State & Region:** Tamil Nadu, Madurai District (Pandya Heartland)
- **Real Geographical Location:** Historic Madurai Old City ($9.9195^\circ\text{ N}, 78.1193^\circ\text{ E}$)
- **Visual Appearance:** Towering multi-tiered Dravidian gopuram adorned with thousands of polychromatic stucco sculptures, kalashams, and ornamental niches.
- **Why It Is Famous:** Masterpiece of Dravidian architecture; central spiritual hub of Madurai with roots spanning 2,500 years.
- **Asset Type:** 2D High-Resolution Vector Architectural Tower
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 850\text{ m} = 85,000\text{ px}, Y: Y_{\text{ground}}(85000) - 60\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)` (Normalized height $\approx 360\text{ px}$)
- **Suggested Visibility Duration:** 18 seconds ($720\text{ m} \rightarrow 980\text{ m}$)
- **Waypoint Role:** Major Intermediate Waypoint 2
- **Status:** **ACTIVE ON DISK & REPLACED** (Clean anti-aliased vector alpha; zero jagged white halo).
- **License & Provenance:** CC-BY-SA 4.0 / Original Vector Work. Full commercial permissions.

#### 4. Thanjavur Brihadeeswarar Temple Vimana (Waypoint 3)
- **Asset ID:** `LOC-TN-15`
- **Filename:** `assets/indian_locations/tamil_nadu/thanjavur_brihadeeswarar_temple.png`
- **Famous Place Name:** Brihadisvara Temple (Peruvudaiyar Kovil) Great Chola Vimana
- **State & Region:** Tamil Nadu, Thanjavur District (Cauvery Delta)
- **Real Geographical Location:** Thanjavur City ($10.7828^\circ\text{ N}, 79.1318^\circ\text{ E}$)
- **Visual Appearance:** 216-ft monolithic granite shikhara crowned with an 80-tonne single granite kumbam cupola.
- **Why It Is Famous:** UNESCO World Heritage Great Living Chola Temple built in 1010 CE by Emperor Raja Raja Chola I.
- **Asset Type:** 2D Vector Architectural Landmark
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 1,350\text{ m} = 135,000\text{ px}, Y: Y_{\text{ground}}(135000) - 50\text{ px})$
- **Recommended Scale:** `Vector2(0.80, 0.80)`
- **Suggested Visibility Duration:** 15 seconds ($1,250\text{ m} \rightarrow 1,450\text{ m}$)
- **Waypoint Role:** Major Intermediate Waypoint 3
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0. Full commercial permissions.

#### 5. Chennai Marina Lighthouse & Coastal Promenade (Destination Arch)
- **Asset ID:** `LOC-TN-21`
- **Filename:** `assets/indian_locations/tamil_nadu_chennai_marina_lighthouse.png`
- **Famous Place Name:** Chennai Marina Beach Promenade & Lighthouse
- **State & Region:** Tamil Nadu, Chennai Metropolitan City
- **Real Geographical Location:** Marina Beach, Bay of Bengal Coast ($13.0400^\circ\text{ N}, 80.2800^\circ\text{ E}$)
- **Visual Appearance:** Cylindrical red-and-white banded maritime lighthouse with radar dome, palm promenade, and victory finish banner arch.
- **Why It Is Famous:** India's second-longest urban beach; the only lighthouse in India within city limits with an elevator viewing deck.
- **Asset Type:** Finish Arch & Destination Monument (`FinishArchV2.tscn`)
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 1: Roadside Foreground` (Z-Index: `2`)
- **Suggested World Position:** $(X: 1,800\text{ m} = 180,000\text{ px}, Y: Y_{\text{ground}}(180000))$
- **Recommended Scale:** `Vector2(0.90, 0.90)`
- **Suggested Visibility Duration:** Permanent upon arrival (triggers Route Complete Victory Screen)
- **Waypoint Role:** Final Destination Arch & Level Completion Trigger
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Original Vector. Full commercial rights.

---

## 3. State 2: Goa Landmark Placement & Coordinate Schedule

### Route Corridor: Panaji Fontainhas $\rightarrow$ Calangute Coastal Road $\rightarrow$ Old Goa Churches $\rightarrow$ Margao Heritage Terminus (Total: 1,600m)

#### 1. Panaji Fontainhas Latin Quarter (Start Waypoint)
- **Asset ID:** `LOC-GA-01`
- **Filename:** `assets/indian_locations/goa/panaji/landmarks/panaji_fontainhas_street.png`
- **Famous Place Name:** Fontainhas Latin Quarter & Ourem Creek
- **State & Region:** Goa, North Goa (Tiswadi Taluka)
- **Real Geographical Location:** Panaji City ($15.4989^\circ\text{ N}, 73.8278^\circ\text{ E}$)
- **Visual Appearance:** Vibrant ochre, indigo, and terracotta colonial Portuguese houses with wrought-iron balconies and red tiled roofs.
- **Why It Is Famous:** UNESCO heritage conservation zone; oldest Latin Quarter in Asia preserving Mediterranean ambiance.
- **Asset Type:** 2D Architectural Facade & Roadway Start Portal
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn` (Route: `goa`)
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 0\text{ m} = 0\text{ px}, Y: Y_{\text{ground}}(0) - 20\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 12 seconds ($0\text{ m} \rightarrow 150\text{ m}$)
- **Waypoint Role:** Start Location
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork (Pycairo), CC0 1.0 Universal.

#### 2. Calangute & Baga Coastal Beach Road (Waypoint 1)
- **Asset ID:** `LOC-GA-07`
- **Filename:** `assets/indian_locations/goa/north_goa/landmarks/calangute_beach_road.png`
- **Famous Place Name:** Calangute Beach Coastal Strip
- **State & Region:** Goa, Bardez Taluka, North Goa
- **Real Geographical Location:** Calangute Coast ($15.5442^\circ\text{ N}, 73.7554^\circ\text{ E}$)
- **Visual Appearance:** Golden sandy coastline, thatched shack restaurants, wooden fishing canoes, and swaying coconut palm groves.
- **Why It Is Famous:** "Queen of Beaches"; iconic tourism coastline of North Goa.
- **Asset Type:** 2D Vector Environmental Roadside Waypoint
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-1`)
- **Suggested World Position:** $(X: 400\text{ m} = 40,000\text{ px}, Y: Y_{\text{ground}}(40000) - 30\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 15 seconds ($300\text{ m} \rightarrow 500\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 1
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork, CC0.

#### 3. Basilica of Bom Jesus & Old Goa Churches (Waypoint 2)
- **Asset ID:** `LOC-GA-04`
- **Filename:** `assets/indian_locations/goa/old_goa/landmarks/basilica_of_bom_jesus.png`
- **Famous Place Name:** Basilica of Bom Jesus
- **State & Region:** Goa, Old Goa (Velha Goa)
- **Real Geographical Location:** Old Goa Road ($15.5008^\circ\text{ N}, 73.9116^\circ\text{ E}$)
- **Visual Appearance:** Baroque exposed reddish-brown laterite facade with carved basalt portals, Doric pilasters, and historic belfry.
- **Why It Is Famous:** UNESCO World Heritage Site housing the sacred relic casket of St. Francis Xavier; landmark of Baroque architecture.
- **Asset Type:** 2D Heritage Vector Monument
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 850\text{ m} = 85,000\text{ px}, Y: Y_{\text{ground}}(85000) - 50\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 16 seconds ($750\text{ m} \rightarrow 950\text{ m}$)
- **Waypoint Role:** Major Intermediate Waypoint 2
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 (Wikimedia / Team Vector redraw). Full commercial permissions.

#### 4. Fort Aguada Portuguese Lighthouse (Waypoint 3)
- **Asset ID:** `LOC-GA-10`
- **Filename:** `assets/indian_locations/goa/north_goa/landmarks/fort_aguada_lighthouse.png`
- **Famous Place Name:** Fort Aguada Coastal Bastion & 1864 Lighthouse
- **State & Region:** Goa, Candolim Peninsula, Sinquerim
- **Real Geographical Location:** Mouth of Mandovi River ($15.4925^\circ\text{ N}, 73.7736^\circ\text{ E}$)
- **Visual Appearance:** Formidable weathered laterite fort ramparts perched over crashing Arabian Sea surf with white 4-storey circular lighthouse.
- **Why It Is Famous:** 1612 Portuguese fortress built to guard against Dutch fleets; legendary freshwater spring ("Aguada").
- **Asset Type:** 2D Vector Fortified Bastion
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 1,250\text{ m} = 125,000\text{ px}, Y: Y_{\text{ground}}(125000) - 45\text{ px})$
- **Recommended Scale:** `Vector2(0.80, 0.80)`
- **Suggested Visibility Duration:** 16 seconds ($1,150\text{ m} \rightarrow 1,350\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 3
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Original Vector.

#### 5. Margao Heritage Cultural Gateway (Destination Arch)
- **Asset ID:** `LOC-GA-21`
- **Filename:** `assets/indian_locations/goa/south_goa/landmarks/margao_heritage_gate.png`
- **Famous Place Name:** Margao Historic Municipal Arch & Heritage Center
- **State & Region:** Goa, Salcete Taluka, South Goa
- **Real Geographical Location:** Margao City Center ($15.2736^\circ\text{ N}, 73.9581^\circ\text{ E}$)
- **Visual Appearance:** Grand celebratory arch featuring Goan Portuguese Manueline pediments, tiled azulejos, and flower garland decorations.
- **Why It Is Famous:** Commercial and cultural capital of South Goa; southern terminus of the Konkan heritage corridor.
- **Asset Type:** Finish Arch & Destination Portal (`FinishArchV2.tscn`)
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 1: Roadside Foreground` (Z-Index: `2`)
- **Suggested World Position:** $(X: 1,600\text{ m} = 160,000\text{ px}, Y: Y_{\text{ground}}(160000))$
- **Recommended Scale:** `Vector2(0.90, 0.90)`
- **Suggested Visibility Duration:** Permanent upon arrival
- **Waypoint Role:** Final Destination Arch & Level Completion Trigger
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork, CC0.

---

## 4. State 3: Kerala Landmark Placement & Coordinate Schedule

### Route Corridor: Fort Kochi Heritage $\rightarrow$ Alleppey Backwaters $\rightarrow$ Athirappilly Falls $\rightarrow$ Munnar Tea Country (Total: 2,000m)

#### 1. Fort Kochi Chinese Fishing Nets (Start Waypoint)
- **Asset ID:** `LOC-KL-01`
- **Filename:** `assets/indian_locations/kerala/fort_kochi_chinese_fishing_nets.png`
- **Famous Place Name:** Fort Kochi Chinese Fishing Nets (Cheena Vala)
- **State & Region:** Kerala, Ernakulam District
- **Real Geographical Location:** Fort Kochi Harbor Beach ($9.9674^\circ\text{ N}, 76.2427^\circ\text{ E}$)
- **Visual Appearance:** Cantilevered bamboo and teak mechanical fishing nets suspended gracefully over backwater harbor waters.
- **Why It Is Famous:** Iconic 14th-century fishing technology introduced by Chinese explorer Zheng He's court; signature postcard of Kerala.
- **Asset Type:** 2D Heritage Landmark
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn` (Route: `kerala`)
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 0\text{ m} = 0\text{ px}, Y: Y_{\text{ground}}(0) - 20\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 12 seconds
- **Waypoint Role:** Start Location
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Original Vector.

#### 2. Alleppey Backwaters & Kettuvallam Houseboat (Waypoint 1)
- **Asset ID:** `LOC-KL-03`
- **Filename:** `assets/indian_locations/kerala/alleppey_backwaters_houseboat.png`
- **Famous Place Name:** Alappuzha Backwaters & Traditional Kettuvallam Houseboat
- **State & Region:** Kerala, Alappuzha District
- **Real Geographical Location:** Punnamada Lake, Alleppey ($9.4981^\circ\text{ N}, 76.3388^\circ\text{ E}$)
- **Visual Appearance:** Wooden thatched houseboat with coir roof drifting gently along palm-fringed emerald lagoons and water hyacinths.
- **Why It Is Famous:** "Venice of the East"; legendary network of brackish canals, rivers, and lakes hosting Nehru Trophy Boat Race.
- **Asset Type:** 2D Scenic Landmark Node
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-1`)
- **Suggested World Position:** $(X: 500\text{ m} = 50,000\text{ px}, Y: Y_{\text{ground}}(50000) - 30\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 16 seconds ($400\text{ m} \rightarrow 600\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 1
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 3. Athirappilly Waterfalls (Waypoint 2)
- **Asset ID:** `LOC-KL-06`
- **Filename:** `assets/indian_locations/kerala/athirappilly_waterfalls.png`
- **Famous Place Name:** Athirappilly Cascading Waterfalls
- **State & Region:** Kerala, Thrissur District (Chalakudy River)
- **Real Geographical Location:** Western Ghats Gorge ($10.2851^\circ\text{ N}, 76.5698^\circ\text{ E}$)
- **Visual Appearance:** 80-ft wide roaring waterfall tumbling over tiered granite rocks amidst dense tropical rainforest spray.
- **Why It Is Famous:** "The Niagara of South India"; featured in major Indian motion pictures (Bahubali, Dil Se).
- **Asset Type:** 2D Natural Wonder Environment Sprite
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 1,000\text{ m} = 100,000\text{ px}, Y: Y_{\text{ground}}(100000) - 50\text{ px})$
- **Recommended Scale:** `Vector2(0.90, 0.90)`
- **Suggested Visibility Duration:** 18 seconds ($900\text{ m} \rightarrow 1,100\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 2
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 4. Padmanabhaswamy Temple Gopuram (Waypoint 3)
- **Asset ID:** `LOC-KL-08`
- **Filename:** `assets/indian_locations/kerala/padmanabhaswamy_temple.png`
- **Famous Place Name:** Sree Padmanabhaswamy Temple 7-Tier Gopuram
- **State & Region:** Kerala, Thiruvananthapuram
- **Real Geographical Location:** East Fort, Trivandrum ($8.4831^\circ\text{ N}, 76.9436^\circ\text{ E}$)
- **Visual Appearance:** 100-ft 7-tier gopuram showcasing intricate Chera-Pandya Dravidian stone carvings over sacred lotus tank.
- **Why It Is Famous:** One of 108 Divya Desams; widely known as the wealthiest religious institution in recorded history.
- **Asset Type:** 2D Temple Heritage Landmark
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 1,500\text{ m} = 150,000\text{ px}, Y: Y_{\text{ground}}(150000) - 45\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 15 seconds ($1,400\text{ m} \rightarrow 1,600\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 3
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 5. Munnar Misty Tea Estate Destination (Destination Arch)
- **Asset ID:** `LOC-KL-11`
- **Filename:** `assets/indian_locations/kerala/munnar_tea_estate_arch.png`
- **Famous Place Name:** Munnar High Range Tea Gardens & Western Ghats Gateway
- **State & Region:** Kerala, Idukki District
- **Real Geographical Location:** Munnar Hill Station ($10.0889^\circ\text{ N}, 77.0595^\circ\text{ E}$)
- **Visual Appearance:** Contoured terraced bright emerald tea bushes rolling across misty hill slopes beneath a wooden floral arch.
- **Why It Is Famous:** South India's premier tea plantation haven located at 1,600m elevation near Anamudi peak.
- **Asset Type:** Finish Arch & High Range Destination (`FinishArchV2.tscn`)
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 1: Roadside Foreground` (Z-Index: `2`)
- **Suggested World Position:** $(X: 2,000\text{ m} = 200,000\text{ px}, Y: Y_{\text{ground}}(200000))$
- **Recommended Scale:** `Vector2(0.90, 0.90)`
- **Suggested Visibility Duration:** Permanent upon arrival
- **Waypoint Role:** Final Destination Arch & Level Completion Trigger
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork, CC0.

---

## 5. State 4: Rajasthan Landmark Placement & Coordinate Schedule

### Route Corridor: Jaipur Pink City $\rightarrow$ Amber Fort $\rightarrow$ Jodhpur Blue City $\rightarrow$ Jaisalmer Thar Golden Dunes (Total: 2,200m)

#### 1. Jaipur Pink City Tri-Polia Gate (Start Waypoint)
- **Asset ID:** `LOC-RJ-00`
- **Filename:** `assets/indian_locations/rajasthan/jaipur_pink_city_gate.png`
- **Famous Place Name:** Jaipur Old Pink City Gateway (Tripolia Bazaar)
- **State & Region:** Rajasthan, Jaipur District
- **Real Geographical Location:** Jaipur City Center ($26.9239^\circ\text{ N}, 75.8267^\circ\text{ E}$)
- **Visual Appearance:** Terracotta-pink lime plastered triple archway with traditional Rajasthani chhatris and brass studded wooden gates.
- **Why It Is Famous:** UNESCO World Heritage planned royal city founded in 1727 by Maharaja Sawai Jai Singh II.
- **Asset Type:** 2D Vector Royal City Gate
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn` (Route: `rajasthan`)
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 0\text{ m} = 0\text{ px}, Y: Y_{\text{ground}}(0) - 20\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 12 seconds
- **Waypoint Role:** Start Location
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork, CC0.

#### 2. Amber Fort Gateway (Waypoint 1)
- **Asset ID:** `LOC-RJ-01`
- **Filename:** `assets/indian_locations/rajasthan/amber_fort_gateway.png`
- **Famous Place Name:** Amer Fort Suraj Pol (Sun Gate)
- **State & Region:** Rajasthan, Jaipur District
- **Real Geographical Location:** Amer Hillock above Maota Lake ($26.9855^\circ\text{ N}, 75.8513^\circ\text{ E}$)
- **Visual Appearance:** Towering yellow and pink sandstone bastion with ornate jharokha lattice windows and elephant gateway.
- **Why It Is Famous:** UNESCO Hill Fort of Rajasthan blending Rajput and Mughal architecture; houses Sheesh Mahal.
- **Asset Type:** 2D Fortified Royal Gateway
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 550\text{ m} = 55,000\text{ px}, Y: Y_{\text{ground}}(55000) - 50\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 16 seconds ($450\text{ m} \rightarrow 650\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 1
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 3. Jaipur Hawa Mahal Palace of Winds (Waypoint 2)
- **Asset ID:** `LOC-RJ-03`
- **Filename:** `assets/indian_locations/rajasthan/hawa_mahal_palace_of_winds.png`
- **Famous Place Name:** Hawa Mahal (Palace of Winds)
- **State & Region:** Rajasthan, Jaipur District
- **Real Geographical Location:** Badi Choupad, Jaipur ($26.9239^\circ\text{ N}, 75.8267^\circ\text{ E}$)
- **Visual Appearance:** Five-storey pyramidal pink and red sandstone honeycomb facade with 953 intricately carved jharokha casements.
- **Why It Is Famous:** Built in 1799 by Maharaja Sawai Pratap Singh resembling Lord Krishna's crown; natural Venturi breeze cooling.
- **Asset Type:** 2D Palace Facade Landmark
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 1,100\text{ m} = 110,000\text{ px}, Y: Y_{\text{ground}}(110000) - 40\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 18 seconds ($1,000\text{ m} \rightarrow 1,200\text{ m}$)
- **Waypoint Role:** Major Intermediate Waypoint 2
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 4. Jodhpur Mehrangarh Fort Monolith (Waypoint 3)
- **Asset ID:** `LOC-RJ-07`
- **Filename:** `assets/indian_locations/rajasthan/jodhpur_mehrangarh_fort.png`
- **Famous Place Name:** Mehrangarh Fort Imposing Bastions
- **State & Region:** Rajasthan, Jodhpur District (Marwar)
- **Real Geographical Location:** 410-ft perpendicular cliff above Jodhpur ($26.2978^\circ\text{ N}, 73.0185^\circ\text{ E}$)
- **Visual Appearance:** Colossal burnished red sandstone ramparts fusing seamlessly into the natural rocky crags above indigo blue houses.
- **Why It Is Famous:** One of India's largest and most impregnable forts, built in 1459 by Rao Jodha; Rudyard Kipling called it "the work of giants."
- **Asset Type:** 2D Rocky Citadel Landmark
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 1,650\text{ m} = 165,000\text{ px}, Y: Y_{\text{ground}}(165000) - 55\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 16 seconds ($1,550\text{ m} \rightarrow 1,750\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 3
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 5. Jaisalmer Golden Sand Dunes & Fort Arch (Destination Arch)
- **Asset ID:** `LOC-RJ-14`
- **Filename:** `assets/indian_locations/rajasthan/jaisalmer_sam_sand_dunes_arch.png`
- **Famous Place Name:** Jaisalmer Thar Desert Sam Dunes & Sonar Qila
- **State & Region:** Rajasthan, Jaisalmer District (Thar Desert)
- **Real Geographical Location:** Sam Sand Dunes ($26.8310^\circ\text{ N}, 70.5100^\circ\text{ E}$)
- **Visual Appearance:** Undulating golden sand ripples, camel silhouettes under desert sunset, and a carved yellow sandstone torana arch.
- **Why It Is Famous:** Living golden fort city of the Great Indian Desert and legendary Silk Road desert trade post.
- **Asset Type:** Finish Arch & Desert Destination (`FinishArchV2.tscn`)
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 1: Roadside Foreground` (Z-Index: `2`)
- **Suggested World Position:** $(X: 2,200\text{ m} = 220,000\text{ px}, Y: Y_{\text{ground}}(220000))$
- **Recommended Scale:** `Vector2(0.90, 0.90)`
- **Suggested Visibility Duration:** Permanent upon arrival
- **Waypoint Role:** Final Destination Arch & Level Completion Trigger
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork, CC0.

---

## 6. State 5: Gujarat Landmark Placement & Coordinate Schedule

### Route Corridor: Ahmedabad Pols $\rightarrow$ Saurashtra Oasis $\rightarrow$ Modhera Sun Temple $\rightarrow$ Great Rann of Kutch (Total: 2,000m)

#### 1. Ahmedabad Old City Teen Darwaza (Start Waypoint)
- **Asset ID:** `LOC-GJ-00`
- **Filename:** `assets/indian_locations/gujarat/ahmedabad_teen_darwaza.png`
- **Famous Place Name:** Ahmedabad Historic Teen Darwaza Gateway
- **State & Region:** Gujarat, Ahmedabad District
- **Real Geographical Location:** Bhadra Fort complex, Ahmedabad ($23.0245^\circ\text{ N}, 72.5850^\circ\text{ E}$)
- **Visual Appearance:** Triple arched historical stone gateway built in 1415 with ornate semicircular arches and jali stone tracery.
- **Why It Is Famous:** India's first UNESCO World Heritage City; royal entrance to the historic Maidan Shah.
- **Asset Type:** 2D Heritage Gateway
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn` (Route: `gujarat`)
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 0\text{ m} = 0\text{ px}, Y: Y_{\text{ground}}(0) - 20\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 12 seconds
- **Waypoint Role:** Start Location
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork, CC0.

#### 2. Saurashtra Highway Oasis & Dhaba (Waypoint 1)
- **Asset ID:** `LOC-GJ-01`
- **Filename:** `assets/indian_locations/gujarat/saurashtra_rann_oasis.png`
- **Famous Place Name:** Saurashtra Highway Rest Oasis & Kathiyawadi Dhaba
- **State & Region:** Gujarat, Surendranagar / Rajkot Highway NH27
- **Real Geographical Location:** Saurashtra corridor ($22.3039^\circ\text{ N}, 70.8022^\circ\text{ E}$)
- **Visual Appearance:** Highway roadhouse with traditional wooden charpai cots, clay tandoor oven, and colourful Gujarati textile canopy.
- **Why It Is Famous:** Cultural rest stop for long-distance truckers and travellers traversing the arid Kathiawar peninsula.
- **Asset Type:** 2D Roadside Interactive Environment Node
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-1`)
- **Suggested World Position:** $(X: 500\text{ m} = 50,000\text{ px}, Y: Y_{\text{ground}}(50000) - 30\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 15 seconds ($400\text{ m} \rightarrow 600\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 1
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork, CC0.

#### 3. Modhera Sun Temple Stepwell Kund (Waypoint 2)
- **Asset ID:** `LOC-GJ-05`
- **Filename:** `assets/indian_locations/gujarat/modhera_sun_temple.png`
- **Famous Place Name:** Modhera Sun Temple & Surya Kund
- **State & Region:** Gujarat, Mehsana District (Pushpavati River)
- **Real Geographical Location:** Modhera Village ($23.5835^\circ\text{ N}, 72.1330^\circ\text{ E}$)
- **Visual Appearance:** Solanki-style sandstone temple sanctuary overlooking an intricate stepped water tank with 108 miniature shrines.
- **Why It Is Famous:** 1026 CE Chalukyan architectural marvel designed so the equinox sun illuminates the sanctum deity.
- **Asset Type:** 2D Stepwell Heritage Landmark
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 1,000\text{ m} = 100,000\text{ px}, Y: Y_{\text{ground}}(100000) - 45\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 16 seconds ($900\text{ m} \rightarrow 1,100\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 2
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 4. Rani ki Vav Stepwell (Waypoint 3)
- **Asset ID:** `LOC-GJ-08`
- **Filename:** `assets/indian_locations/gujarat/rani_ki_vav_stepwell.png`
- **Famous Place Name:** Rani ki Vav (Queen's Stepwell)
- **State & Region:** Gujarat, Patan District (Saraswati River)
- **Real Geographical Location:** Patan Town ($23.8589^\circ\text{ N}, 72.1017^\circ\text{ E}$)
- **Visual Appearance:** Subterranean multi-storey stepped corridor with over 500 sculpted panels depicting the Dashavatara of Vishnu.
- **Why It Is Famous:** UNESCO World Heritage subterranean masterpiece built in 1063 CE by Queen Udayamati; featured on the ₹100 banknote.
- **Asset Type:** 2D Monumental Stepwell Landmark
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 1,500\text{ m} = 150,000\text{ px}, Y: Y_{\text{ground}}(150000) - 50\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 16 seconds ($1,400\text{ m} \rightarrow 1,600\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 3
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 5. Great Rann of Kutch Salt Desert Arch (Destination Arch)
- **Asset ID:** `LOC-GJ-15`
- **Filename:** `assets/indian_locations/gujarat/kutch_white_rann_arch.png`
- **Famous Place Name:** Great Rann of Kutch White Salt Desert & Bhunga Portal
- **State & Region:** Gujarat, Kutch District (Indo-Pak Border)
- **Real Geographical Location:** Dhordo White Rann ($23.8340^\circ\text{ N}, 69.5100^\circ\text{ E}$)
- **Visual Appearance:** Infinite shimmering white salt crust stretching to the horizon beneath full moon sky with mud bhunga huts and torana gate.
- **Why It Is Famous:** World's largest salt desert; home to Rann Utsav and extraordinary desert biodiversity.
- **Asset Type:** Finish Arch & Salt Flat Destination (`FinishArchV2.tscn`)
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 1: Roadside Foreground` (Z-Index: `2`)
- **Suggested World Position:** $(X: 2,000\text{ m} = 200,000\text{ px}, Y: Y_{\text{ground}}(200000))$
- **Recommended Scale:** `Vector2(0.90, 0.90)`
- **Suggested Visibility Duration:** Permanent upon arrival
- **Waypoint Role:** Final Destination Arch & Level Completion Trigger
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork, CC0.

---

## 7. State 6: Telangana Landmark Placement & Coordinate Schedule

### Route Corridor: Old Hyderabad $\rightarrow$ Golconda Fort $\rightarrow$ Kakatiya Toranam $\rightarrow$ Thousand Pillar Temple $\rightarrow$ Warangal Heritage (Total: 1,800m)

#### 1. Hyderabad Charminar Old City (Start Waypoint)
- **Asset ID:** `LOC-TS-04`
- **Filename:** `assets/indian_locations/telangana/hyderabad_charminar_gate.png`
- **Famous Place Name:** Charminar Monumental Archway
- **State & Region:** Telangana, Hyderabad District
- **Real Geographical Location:** Center of Old City, Hyderabad ($17.3616^\circ\text{ N}, 78.4747^\circ\text{ E}$)
- **Visual Appearance:** 184-ft square granite triumphal monument with 4 fluted minarets, pointed arches, and vibrant pearl bazaars.
- **Why It Is Famous:** Built in 1591 by Muhammad Quli Qutb Shah; global emblem of Hyderabad and Deccan Islamic architecture.
- **Asset Type:** 2D Heritage City Gateway
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn` (Route: `telangana`)
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 0\text{ m} = 0\text{ px}, Y: Y_{\text{ground}}(0) - 20\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 12 seconds
- **Waypoint Role:** Start Location
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork, CC0.

#### 2. Golconda Fort Bastion & Balahissar (Waypoint 1)
- **Asset ID:** `LOC-TS-01`
- **Filename:** `assets/indian_locations/telangana/golconda_fort_bastion.png`
- **Famous Place Name:** Golconda Fort Granite Citadel & Balahissar Gate
- **State & Region:** Telangana, Hyderabad West
- **Real Geographical Location:** Golconda Hillock ($17.3833^\circ\text{ N}, 78.4011^\circ\text{ E}$)
- **Visual Appearance:** Cyclopean granite ramparts, acoustic Balahissar gateway, and cannon embrasures atop granite boulders.
- **Why It Is Famous:** Medieval diamond capital of the world; origin of the Koh-i-Noor, Hope, and Daria-i-Noor diamonds.
- **Asset Type:** 2D Fortified Hill Citadel Landmark
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 450\text{ m} = 45,000\text{ px}, Y: Y_{\text{ground}}(45000) - 45\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 16 seconds ($350\text{ m} \rightarrow 550\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 1
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 3. Kakatiya Dynasty Kala Thoranam Gateway (Waypoint 2)
- **Asset ID:** `LOC-TS-02`
- **Filename:** `assets/indian_locations/telangana/kakatiya_dynasty_torana.png`
- **Famous Place Name:** Kakatiya Kala Thoranam (Warangal Gate)
- **State & Region:** Telangana, Warangal Urban District
- **Real Geographical Location:** Warangal Fort Ruins ($17.9547^\circ\text{ N}, 79.6167^\circ\text{ E}$)
- **Visual Appearance:** Monolithic carved black granite ornamental gateway with mythical Hamsa swans, lotuses, and makara gargoyles.
- **Why It Is Famous:** Official emblem of the State of Telangana; symbol of 12th-century Kakatiya sovereign architecture.
- **Asset Type:** 2D Monolithic Gateway Landmark
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-1`)
- **Suggested World Position:** $(X: 900\text{ m} = 90,000\text{ px}, Y: Y_{\text{ground}}(90000) - 35\text{ px})$
- **Recommended Scale:** `Vector2(0.85, 0.85)`
- **Suggested Visibility Duration:** 16 seconds ($800\text{ m} \rightarrow 1,000\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 2
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 4. Thousand Pillar Temple (Waypoint 3)
- **Asset ID:** `LOC-TS-03`
- **Filename:** `assets/indian_locations/telangana/thousand_pillar_temple.png`
- **Famous Place Name:** Thousand Pillar Temple (Rudreswara Swamy)
- **State & Region:** Telangana, Hanamkonda, Warangal
- **Real Geographical Location:** Hanamkonda Highway ($17.9972^\circ\text{ N}, 79.5744^\circ\text{ E}$)
- **Visual Appearance:** Star-shaped trikuta stone temple dedicated to Shiva, Vishnu, and Surya with monolithic carved black basalt Nandi bull.
- **Why It Is Famous:** Masterpiece built in 1163 CE by King Rudradeva featuring rock-cut acoustic stone columns and intricate ceiling reliefs.
- **Asset Type:** 2D Heritage Temple Landmark
- **Suggested Route Scene:** `LandmarkV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 2: Roadside Landmark` (Z-Index: `-2`)
- **Suggested World Position:** $(X: 1,350\text{ m} = 135,000\text{ px}, Y: Y_{\text{ground}}(135000) - 45\text{ px})$
- **Recommended Scale:** `Vector2(0.80, 0.80)`
- **Suggested Visibility Duration:** 15 seconds ($1,250\text{ m} \rightarrow 1,450\text{ m}$)
- **Waypoint Role:** Intermediate Waypoint 3
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** CC-BY-SA 4.0 / Team Vector Artwork.

#### 5. Warangal Heritage Royal Arch (Destination Arch)
- **Asset ID:** `LOC-TS-15`
- **Filename:** `assets/indian_locations/telangana/warangal_heritage_gate.png`
- **Famous Place Name:** Warangal Royal Durbar Arch & Heritage Terminus
- **State & Region:** Telangana, Warangal District
- **Real Geographical Location:** Kakatiya Citadel ($17.9689^\circ\text{ N}, 79.6000^\circ\text{ E}$)
- **Visual Appearance:** Regal ceremonial arch carved with Kakatiya royal insignia, yellow marigold garlands, and victory banner.
- **Why It Is Famous:** Commemorates Queen Rudrama Devi's historic Kakatiya capital and landmark driving terminus.
- **Asset Type:** Finish Arch & Heritage Destination (`FinishArchV2.tscn`)
- **Suggested Route Scene:** `IndianRoadsModeV2.tscn`
- **Suggested Layer & Z-Index:** `Layer 1: Roadside Foreground` (Z-Index: `2`)
- **Suggested World Position:** $(X: 1,800\text{ m} = 180,000\text{ px}, Y: Y_{\text{ground}}(180000))$
- **Recommended Scale:** `Vector2(0.90, 0.90)`
- **Suggested Visibility Duration:** Permanent upon arrival
- **Waypoint Role:** Final Destination Arch & Level Completion Trigger
- **Status:** **ACTIVE ON DISK**
- **License & Provenance:** Original Team Vector Artwork, CC0.

---

## 8. Summary of Placement Parameters Across All 6 Routes

| State Route | Start Position | Waypoint 1 (X) | Waypoint 2 (X) | Waypoint 3 (X) | Destination Arch (X) | Total Route Length | Normal Driving Time |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Tamil Nadu** | $0\text{ m}$ (Pier) | $350\text{ m}$ (Thiruvalluvar) | $850\text{ m}$ (Meenakshi) | $1,350\text{ m}$ (Brihadeeswarar) | $1,800\text{ m}$ (Chennai) | $1,800\text{ m}$ ($180,000\text{ px}$) | $3.2\text{ min}$ |
| **Goa** | $0\text{ m}$ (Fontainhas) | $400\text{ m}$ (Calangute) | $850\text{ m}$ (Bom Jesus) | $1,250\text{ m}$ (Fort Aguada) | $1,600\text{ m}$ (Margao) | $1,600\text{ m}$ ($160,000\text{ px}$) | $2.8\text{ min}$ |
| **Kerala** | $0\text{ m}$ (Fort Kochi) | $500\text{ m}$ (Backwaters) | $1,000\text{ m}$ (Athirappilly) | $1,500\text{ m}$ (Padmanabhaswamy)| $2,000\text{ m}$ (Munnar) | $2,000\text{ m}$ ($200,000\text{ px}$) | $3.6\text{ min}$ |
| **Rajasthan** | $0\text{ m}$ (Jaipur Gate) | $550\text{ m}$ (Amber Fort) | $1,100\text{ m}$ (Hawa Mahal) | $1,650\text{ m}$ (Mehrangarh) | $2,200\text{ m}$ (Jaisalmer) | $2,200\text{ m}$ ($220,000\text{ px}$) | $3.9\text{ min}$ |
| **Gujarat** | $0\text{ m}$ (Teen Darwaza)| $500\text{ m}$ (Saurashtra Dhaba)| $1,000\text{ m}$ (Modhera Sun) | $1,500\text{ m}$ (Rani ki Vav) | $2,000\text{ m}$ (Rann of Kutch)| $2,000\text{ m}$ ($200,000\text{ px}$) | $3.5\text{ min}$ |
| **Telangana** | $0\text{ m}$ (Charminar) | $450\text{ m}$ (Golconda Fort) | $900\text{ m}$ (Kala Thoranam) | $1,350\text{ m}$ (Thousand Pillar)| $1,800\text{ m}$ (Warangal) | $1,800\text{ m}$ ($180,000\text{ px}$) | $3.1\text{ min}$ |

All landmarks conform strictly to real-world regional geography, anti-aliased alpha transparency, proper $Z$-indexing, and non-occluding roadside placement.
