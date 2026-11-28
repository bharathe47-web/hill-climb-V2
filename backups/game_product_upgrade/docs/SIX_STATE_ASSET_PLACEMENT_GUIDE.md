# Six-State Roadside Asset Placement & World Layering Guide

**Project:** Godot 4.7 2D Mobile Driving Game — Indian Roads Mode  
**Document:** `docs/SIX_STATE_ASSET_PLACEMENT_GUIDE.md`  
**Author:** Joel (Senior Godot Environment Developer, Technical Artist, QA Lead)  
**Date:** November 14, 2026  
**Git Branch:** `feature/joel-roads-obstacles`  

---

## 1. Core World Layer Architecture

To prevent visual clutter, road obstruction, and scale mismatch, the Indian Roads mode utilizes a strict **6-tier 2D depth layer hierarchy**:

```
+----------------------------------------------------------------------------------------+
| LAYER 6: Celestial Sky & Atmospherics   (Z: -20, Parallax: 0.04)                       |
+----------------------------------------------------------------------------------------+
| LAYER 5: Distant Horizon & Mountain Silhouette (Z: -15, Parallax: 0.12)               |
+----------------------------------------------------------------------------------------+
| LAYER 4: Midground Scenery & Biome Landscapes  (Z: -10, Parallax: 0.22)               |
+----------------------------------------------------------------------------------------+
| LAYER 3: Near Village / Urban Architectural Facades (Z: -5, Parallax: 0.38)          |
+----------------------------------------------------------------------------------------+
| LAYER 2: Roadside Curated Landmarks & Waypoint Monuments (Z: -2, Parallax: 1.0)       |
+----------------------------------------------------------------------------------------+
| LAYER 1: Road Surface, Vehicle, Props, Milestones & HUD (Z: 0 to 15, Parallax: 1.0)    |
+----------------------------------------------------------------------------------------+
```

### Depth & Collision Separation Rules
1. **No Driveway Occlusion:** Monuments and buildings must never occlude the player vehicle or the drivable asphalt surface. All monuments are assigned `Z-index = -2` to `-5`, rendering behind the road surface (`Z = 0`) and the vehicle (`Z = 2`).
2. **Decoupled Milestone Signboards:** Rather than placing text banners over the monument artwork, `RoadsideLandmark.tscn` positions an official green-and-white NHAI highway signboard right at the roadside shoulder (`X = -80 px`, `Y = 0 px`, `Z = 5`).
3. **Ground Anchor Physics:** Monument sprites are bottom-aligned (`y_offset = -target_height * 0.5`) to rest precisely upon roadside stone plinths or terrain shoulders without floating or clipping into the road sub-base.

---

## 2. Highway Placement Rules by Asset Category

| Category | Typical Z-Index | Parallax Depth | Normalized Height (px) | Horizontal Anchor | Collision Layer | Purpose |
|---|---|---|---|---|---|---|
| **Hero Landmark** | `-2` | `1.0` (World 1:1) | 240 – 340 px | Roadside shoulder | None (Trigger area only) | Cultural centerpiece & visual destination |
| **Vernacular House** | `-5` | `0.38` (Village) | 160 – 220 px | Village setback (80px behind road) | None | Regional village/town atmosphere |
| **Indigenous Tree** | `-3` or `1` | `1.0` or `0.85` | 180 – 280 px | Roadside verge & verge-back | None | Natural roadside canopy & shade |
| **Roadside Prop** | `1` to `5` | `1.0` | 60 – 120 px | Direct highway curb | Static / Kinematic | Highway authenticity & speed warnings |
| **Checkpoint Gate** | `5` (Arch) / `0` (Posts) | `1.0` | 320 px | Spanning both road shoulders | Trigger Area2D | Coin rewards & stage time bonus |
| **Destination Arch** | `6` | `1.0` | 340 px | Spanning finish line | Trigger Area2D | Route completion & victory fanfare |

---

## 3. State Route Placement Schedules (Active World Positions)

### 3.1 State 1: Tamil Nadu Route (Kanyakumari -> Chennai, 1,800 m / 180,000 px)

| World Distance ($x$) | Asset ID | Monument / Scenery Name | Category | Target Height | Z-Index | Placement Anchor |
|---|---|---|---|---|---|---|
| **0 m** (0 px) | `TN-START` | Kanyakumari Triveni Sangam | Start Line | 200 px | `0` | Coastal fishing village verge |
| **140 m** (14,000 px) | `LOC-TN-03` | Kanyakumari Sunrise Point | Landmark | 180 px | `-2` | Ocean pavilion rock plinth |
| **350 m** (35,000 px) | `LOC-TN-01` | Thiruvalluvar Statue | Hero Monument | 330 px | `-2` | Monolithic granite rock pedestal |
| **540 m** (54,000 px) | `LOC-TN-02` | Vivekananda Rock Memorial | Hero Monument | 230 px | `-2` | Sea rock platform |
| **750 m** (75,000 px) | `LOC-TN-08` | Suchindram Temple | Temple | 310 px | `-2` | Dravidian stepped gopuram plinth |
| **950 m** (95,000 px) | `LOC-TN-10` | Padmanabhapuram Palace | Palace | 220 px | `-3` | Teakwood gabled courtyard plinth |
| **1,150 m** (115,000 px) | `LOC-TN-11` | Mathoor Hanging Aqueduct | Aqueduct | 210 px | `-2` | Concrete flume pillars valley bridge |
| **1,320 m** (132,000 px) | `LOC-TN-15` | Thirumalai Nayakkar Mahal | Palace | 230 px | `-3` | Cylindrical pillar arcade |
| **1,480 m** (148,000 px) | `LOC-TN-14` | Meenakshi Amman Temple | Hero Temple | 330 px | `-2` | Multi-tier polychrome gopuram plinth |
| **1,650 m** (165,000 px) | `LOC-TN-22` | Marina Lighthouse | Lighthouse | 300 px | `-2` | Red-and-white concrete tower curb |
| **1,800 m** (180,000 px) | `LOC-TN-25` | San Thome Basilica & Finish | Finish Arch | 280 px | `-2` | Neo-Gothic cathedral avenue arch |

### 3.2 State 2: Goa Route (Panaji -> Margao, 1,600 m / 160,000 px)

| World Distance ($x$) | Asset ID | Monument / Scenery Name | Category | Target Height | Z-Index | Placement Anchor |
|---|---|---|---|---|---|---|
| **0 m** (0 px) | `GA-START` | Panaji Church Square | Start Line | 200 px | `0` | Mosaic Portuguese cobbled square |
| **130 m** (13,000 px) | `LOC-GA-02` | Fontainhas Latin Quarter | Heritage Scenery | 190 px | `-3` | Ochre & blue tiled townhouse row |
| **320 m** (32,000 px) | `LOC-GA-01` | Church of Our Lady of Conception | Hero Church | 300 px | `-2` | White Baroque zigzag staircase plinth |
| **520 m** (52,000 px) | `LOC-GA-03` | Mandovi Riverfront Promenade | Scenery | 210 px | `-2` | River boulevard balustrade |
| **720 m** (72,000 px) | `LOC-GA-08` | Reis Magos Fort | Fort Bastion | 220 px | `-3` | Red laterite coastal rampart |
| **920 m** (92,000 px) | `LOC-GA-09` | Fort Aguada & Lighthouse | Hero Fortress | 280 px | `-2` | Circular laterite fort tower |
| **1,120 m** (112,000 px) | `LOC-GA-11` | Calangute Beach Promenade | Coastal Shacks | 200 px | `-2` | Thatched beach shack promenade |
| **1,200 m** (120,000 px) | `LOC-GA-14` | Chapora Fort Bastion | Fort Ruins | 230 px | `-3` | Vagator clifftop stone wall |
| **1,280 m** (128,000 px) | `LOC-GA-15` | Basilica of Bom Jesus | Hero UNESCO | 290 px | `-2` | Weathered laterite Baroque plinth |
| **1,420 m** (142,000 px) | `LOC-GA-16` | Se Cathedral | Cathedral | 310 px | `-2` | Tuscan belfry square plinth |
| **1,520 m** (152,000 px) | `LOC-GA-22` | Dudhsagar Waterfalls | Waterfall | 300 px | `-4` | Western Ghats railway viaduct gorge |
| **1,600 m** (160,000 px) | `LOC-GA-25` | Margao Municipal Arch & Finish | Finish Arch | 270 px | `-2` | South Goa ceremonial gateway |

### 3.3 State 3: Kerala Route (Kochi -> Munnar, 2,000 m / 200,000 px)

| World Distance ($x$) | Asset ID | Monument / Scenery Name | Category | Target Height | Z-Index | Placement Anchor |
|---|---|---|---|---|---|---|
| **0 m** (0 px) | `KL-START` | Fort Kochi Harbour | Start Line | 200 px | `0` | Malabar colonial quay |
| **160 m** (16,000 px) | `LOC-KL-09` | Fort Kochi Chinese Fishing Nets | Hero Waterfront | 240 px | `-2` | Cantilevered teak shore nets |
| **380 m** (38,000 px) | `LOC-KL-10` | Mattancherry Dutch Palace | Palace | 210 px | `-3` | Nalukettu gabled veranda plinth |
| **600 m** (60,000 px) | `LOC-KL-01` | Alleppey Backwaters Houseboat | Waterway | 230 px | `-2` | Coconut canal bank jetty |
| **1,000 m** (100,000 px) | `LOC-KL-14` | Athirappilly Waterfalls | Waterfall | 270 px | `-4` | Chalakudy rocky river cataract |
| **1,350 m** (135,000 px) | `LOC-KL-04` | Munnar Tea Plantations | Hero Hills | 240 px | `-3` | Emerald tea estate contour terraces |
| **1,600 m** (160,000 px) | `LOC-KL-17` | Bekal Fort Keyhole Bastion | Coastal Fort | 220 px | `-3` | Arabian sea stone bastion |
| **1,850 m** (185,000 px) | `LOC-KL-25` | Padmanabhaswamy Temple | Hero Temple | 330 px | `-2` | Dravidian-Kerala fusion vimana plinth |
| **2,000 m** (200,000 px) | `KL-FINISH` | Munnar High Range Arch | Finish Arch | 320 px | `-2` | Hill station timber destination arch |

### 3.4 State 4: Rajasthan Route (Jaipur -> Jaisalmer, 2,200 m / 220,000 px)

| World Distance ($x$) | Asset ID | Monument / Scenery Name | Category | Target Height | Z-Index | Placement Anchor |
|---|---|---|---|---|---|---|
| **0 m** (0 px) | `RJ-START` | Jaipur Pink City Gates | Start Line | 200 px | `0` | Triple-arched rose sandstone gateway |
| **180 m** (18,000 px) | `LOC-RJ-02` | Hawa Mahal "Palace of Winds" | Hero Palace | 330 px | `-2` | 953 jharokha honeycomb street plinth |
| **440 m** (44,000 px) | `LOC-RJ-03` | Jal Mahal Water Palace | Lake Pavilion | 210 px | `-3` | Man Sagar lake stone water base |
| **700 m** (70,000 px) | `LOC-RJ-01` | Amber Fort Gateway | Hero Fortress | 270 px | `-2` | Yellow sandstone ramparts ridge |
| **1,000 m** (100,000 px) | `LOC-RJ-10` | Mehrangarh Fort Bastion | Hero Fortress | 280 px | `-3` | 400-ft perpendicular rock cliff |
| **1,280 m** (128,000 px) | `LOC-RJ-12` | Umaid Bhawan Palace | Royal Palace | 260 px | `-3` | Golden Chittar sandstone dome |
| **1,450 m** (145,000 px) | `LOC-RJ-19` | Chittorgarh Vijay Stambha | Tower of Fame | 290 px | `-2` | 9-story carved marble tower base |
| **1,650 m** (165,000 px) | `LOC-RJ-18` | Sam Sand Dunes Desert Camp | Desert Oasis | 250 px | `-3` | Sweeping wind-blown sand dunes |
| **1,850 m** (185,000 px) | `LOC-RJ-15` | Jaisalmer Golden Fort | Living Fortress | 290 px | `-2` | Thar triple golden-sandstone ramparts |
| **2,200 m** (220,000 px) | `RJ-FINISH` | Thar Desert Oasis Destination | Finish Arch | 320 px | `-2` | Carved sandstone ceremonial gate |

### 3.5 State 5: Gujarat Route (Ahmedabad -> Rann of Kutch, 2,000 m / 200,000 px)

| World Distance ($x$) | Asset ID | Monument / Scenery Name | Category | Target Height | Z-Index | Placement Anchor |
|---|---|---|---|---|---|---|
| **0 m** (0 px) | `GJ-START` | Ahmedabad Heritage Gateway | Start Line | 200 px | `0` | Pol carved wooden gateway |
| **180 m** (18,000 px) | `LOC-GJ-04` | Sabarmati Ashram (Hriday Kunj) | Memorial | 190 px | `-3` | Whitewashed cottage garden verge |
| **350 m** (35,000 px) | `LOC-GJ-10` | Teen Darwaza Royal Gateway | Triumphal Gate | 220 px | `-2` | Triple-arched royal stone gate |
| **680 m** (68,000 px) | `LOC-GJ-08` | Modhera Sun Temple | Hero Temple | 270 px | `-2` | Surya Kund stepped reservoir plinth |
| **900 m** (90,000 px) | `LOC-GJ-12` | Rani Ki Vav Stepwell Pavilion | UNESCO Stepwell | 240 px | `-2` | Inverted subterranean carved pavilion |
| **1,100 m** (110,000 px) | `LOC-GJ-01` | Saurashtra Highway Oasis & Dhaba | Rest Stop | 190 px | `1` | Roadside charpai & tandoor shelter |
| **1,350 m** (135,000 px) | `LOC-GJ-02` | Flamingo Sanctuary Pass | Salt Marshes | 220 px | `-3` | Wetland salt bank wildlife pass |
| **1,550 m** (155,000 px) | `LOC-GJ-03` | White Desert of Kutch | Hero Salt Flat | 210 px | `-3` | Shimmering white crystalline salt crust |
| **1,750 m** (175,000 px) | `LOC-GJ-21` | Dwarkadhish Temple (Jagat Mandir) | Hero Temple | 310 px | `-2` | 72-pillar limestone shikhara plinth |
| **1,920 m** (192,000 px) | `LOC-GJ-24` | Statue of Unity | Colossal Statue | 340 px | `-3` | Narmada river valley concrete pedestal |
| **2,000 m** (200,000 px) | `GJ-FINISH` | Great Rann Salt Gateway | Finish Arch | 320 px | `-2` | White salt crystal ceremonial arch |

### 3.6 State 6: Telangana Route (Hyderabad -> Warangal, 1,800 m / 180,000 px)

| World Distance ($x$) | Asset ID | Monument / Scenery Name | Category | Target Height | Z-Index | Placement Anchor |
|---|---|---|---|---|---|---|
| **0 m** (0 px) | `TS-START` | Old City Charminar Boulevard | Start Line | 200 px | `0` | Granite cobbled avenue |
| **180 m** (18,000 px) | `LOC-TS-04` | Charminar Monument | Hero Colossus | 330 px | `-2` | 4 fluted minarets square granite plinth |
| **420 m** (42,000 px) | `LOC-TS-06` | Chowmahalla Palace Khilwat | Royal Palace | 220 px | `-3` | Neoclassical pillared palace terrace |
| **680 m** (68,000 px) | `LOC-TS-01` | Golconda Fort Bastion | Hero Citadel | 280 px | `-3` | Acoustic Balahissar cyclopean rampart |
| **920 m** (92,000 px) | `LOC-TS-08` | Hussain Sagar Buddha Statue | Monolithic Icon | 310 px | `-2` | Gibraltar rock island plinth |
| **1,150 m** (115,000 px) | `LOC-TS-09` | Birla Mandir Temple | Hill Temple | 280 px | `-3` | Naubat Pahad granite peak plinth |
| **1,360 m** (136,000 px) | `LOC-TS-02` | Kakatiya Kala Thoranam | Hero Torana | 250 px | `-2` | Monolithic swan-carved granite arch |
| **1,550 m** (155,000 px) | `LOC-TS-03` | Thousand Pillar Temple | Star Temple | 240 px | `-2` | Trikuta black basalt Nandi courtyard |
| **1,680 m** (168,000 px) | `LOC-TS-18` | Laknavaram Suspension Bridge | Cable Bridge | 220 px | `-2` | Green lake island pedestrian bridge |
| **1,780 m** (178,000 px) | `LOC-TS-15` | Ramappa Temple (Rudreswara) | UNESCO Temple | 290 px | `-2` | Floating brick sandbox foundation plinth |
| **1,800 m** (180,000 px) | `TS-FINISH` | Warangal Royal Torana Destination | Finish Arch | 320 px | `-2` | Kakatiya dynasty ceremonial finish arch |

---

## 4. Normalization and Scaling Math in Engine

In `scripts/modes/indian_roads/RoadsideLandmark.gd`, the scaling logic ensures that high-resolution master textures (e.g., $1024 \times 1024$ px) are proportionally normalized without distortion:

```gdscript
var th := float(tex.get_height())
var tw := float(tex.get_width())

if th > 0.0:
    var s := target_height / th
    if target_width > 0.0 and tw > 0.0:
        s = minf(target_height / th, target_width / tw)
    monument_sprite.scale = Vector2(s, s)
    monument_sprite.position = Vector2(0.0, ground_offset_y - (target_height * 0.5))
```

This guarantees that:
- A $1024 \times 1024$ Meenakshi Amman Temple rendered at `target_height = 330.0` receives scale $0.322$, towering realistically over the blue vehicle (vehicle height $\approx 75$ px).
- Roadside signboards remain consistently at height $80$ px with high-contrast readable typography regardless of the monument's physical size.
- Vehicle collision and driving clearance are never obstructed.
