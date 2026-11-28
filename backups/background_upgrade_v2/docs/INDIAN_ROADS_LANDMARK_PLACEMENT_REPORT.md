# Indian Roads Landmark Placement & Roadside Architecture Report

**Project:** Godot 4.7 2D Mobile Driving Simulation — Indian Roads Mode  
**Document:** `docs/INDIAN_ROADS_LANDMARK_PLACEMENT_REPORT.md`  
**Author:** Joel (Senior Godot Developer, Technical Artist, Level Designer)  
**Date:** November 14, 2026  
**Git Branch:** `feature/joel-roads-obstacles`  
**Engine:** Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf  

---

## 1. Architectural Vision & User Sketch Realization

The landmark integration architecture directly implements the user's hand-drawn roadside landmark sketch:
1. **One Continuous Highway:** The player drives continuously along a smoothly undulating road surface without scene resets or artificial teleports.
2. **Roadside Cultural Centerpieces:** Culturally famous Indian attractions (temples, forts, towers, palaces, and bridges) appear naturally beside the highway on dedicated ground plinths.
3. **Decoupled Highway Signboards:** To preserve the beauty of the landmark artwork, identification signboards are placed at the roadside shoulder edge ($x - 80\text{ px}$, $y$), styled after official green-and-white NHAI highway boards with reflective yellow borders.
4. **Natural Approach & Departure:** Landmarks enter the viewport from the right, grow in prominence as the player approaches, align alongside the player vehicle for detailed architectural inspection, and recede smoothly into the rear view.
5. **No Highway Occlusion:** Landmarks are rendered on background canvas layers (`Z-index: -2` to `-4`), ensuring the drivable asphalt, player vehicle (`Z-index: 2`), and HUD (`Z-index: 100`) are never obscured.

---

## 2. World Coordinate Calculation & Anchoring Mechanics

In `IndianRoadTerrainV2.gd`, landmark locations are calculated mathematically along the road spline:

```gdscript
var lm_dist_m: float = lm_data.get("distance_m", 0.0)
var lm_x: float = lm_dist_m * 100.0 # 1 meter = 100 pixels in world coordinates
var lm_y: float = _calculate_road_height(lm_x)

var lm: Node2D = RoadsideLandmarkScene.instantiate()
lm.global_position = Vector2(lm_x, lm_y)
```

In `RoadsideLandmark.gd`, the scale and ground anchor are computed proportionally:

```gdscript
var th := float(tex.get_height())
var tw := float(tex.get_width())

if th > 0.0:
    var s := target_height / th
    if target_width > 0.0 and tw > 0.0:
        s = minf(target_height / th, target_width / tw)
    monument_sprite.scale = Vector2(s, s)
    # Bottom alignment: Monument base rests squarely on the road shoulder
    monument_sprite.position = Vector2(0.0, ground_offset_y - (target_height * 0.5))
```

This guarantees:
- A $1024 \times 1024$ px master texture scaled to `target_height = 330.0` px displays with razor-sharp fidelity, towering realistically over the blue vehicle (height $\approx 75$ px).
- The base of the monument aligns with ground elevation $Y_{\text{ground}}(x)$, eliminating floating sprites and ground clipping.

---

## 3. Roadside Buffer & Anti-Clumping Rules

To ensure that major cultural landmarks remain visually dominant and are not crowded by generic houses or trees:
1. **$650\text{ px}$ Landmark Protection Zone:** `IndianRoadTerrainV2.gd` enforces a $\pm 650\text{ px}$ buffer around every roadside landmark ($x \pm 650\text{ px}$). Within this buffer, no procedural houses, shops, or dense trees are spawned.
2. **Negative Space & Horizon Breathing Room:** The negative space allows the player to view the full silhouette and architectural crest of the monument against the sky and distant mountain horizons.
3. **Settlement Zoning:** Procedural houses are concentrated primarily in the starting and ending settlement zones ($0.0 \le x \le 0.18$ and $0.85 \le x \le 1.0$), ensuring that the open highway is dominated by nature, scenery, and landmarks.

---

## 4. Complete Six-State Landmark Placement Schedules

### 4.1 State 1: Tamil Nadu Route (`1,800 m / 180,000 px`)
- **$x = 14,000\text{ px}$ (140 m):** `LOC-TN-03` Kanyakumari Sunrise Point ($h = 180\text{ px}$, $z = -2$) — Ocean pavilion rock plinth.
- **$x = 35,000\text{ px}$ (350 m):** `LOC-TN-01` Thiruvalluvar Statue ($h = 330\text{ px}$, $z = -2$) — Monolithic granite pedestal.
- **$x = 54,000\text{ px}$ (540 m):** `LOC-TN-02` Vivekananda Rock Memorial ($h = 230\text{ px}$, $z = -2$) — Island meditation mandapam.
- **$x = 75,000\text{ px}$ (750 m):** `LOC-TN-08` Suchindram Thanumalayan Temple ($h = 310\text{ px}$, $z = -2$) — Dravidian stepped gopuram.
- **$x = 95,000\text{ px}$ (950 m):** `LOC-TN-10` Padmanabhapuram Palace ($h = 220\text{ px}$, $z = -3$) — Kerala teakwood royal seat.
- **$x = 115,000\text{ px}$ (1,150 m):** `LOC-TN-11` Mathoor Hanging Aqueduct ($h = 210\text{ px}$, $z = -2$) — Tall valley concrete flume pillars.
- **$x = 132,000\text{ px}$ (1,320 m):** `LOC-TN-15` Thirumalai Nayakkar Mahal ($h = 230\text{ px}$, $z = -3$) — Nayak grand cylindrical pillars.
- **$x = 148,000\text{ px}$ (1,480 m):** `LOC-TN-14` Meenakshi Amman Temple ($h = 330\text{ px}$, $z = -2$) — Polychrome gopuram monument.
- **$x = 165,000\text{ px}$ (1,650 m):** `LOC-TN-22` Marina Lighthouse ($h = 300\text{ px}$, $z = -2$) — Red-and-white concrete tower curb.
- **$x = 180,000\text{ px}$ (1,800 m):** `LOC-TN-25` San Thome Basilica ($h = 280\text{ px}$, $z = -2$) — Neo-Gothic coastal cathedral finish.

### 4.2 State 2: Goa Route (`1,600 m / 160,000 px`)
- **$x = 13,000\text{ px}$ (130 m):** `LOC-GA-02` Fontainhas Latin Quarter ($h = 190\text{ px}$, $z = -3$) — Portuguese ochre & indigo streetscape.
- **$x = 32,000\text{ px}$ (320 m):** `LOC-GA-01` Our Lady of Conception Church ($h = 300\text{ px}$, $z = -2$) — White Baroque zigzag staircase.
- **$x = 52,000\text{ px}$ (520 m):** `LOC-GA-03` Mandovi Riverfront Promenade ($h = 210\text{ px}$, $z = -2$) — Riverside boulevard balustrade.
- **$x = 72,000\text{ px}$ (720 m):** `LOC-GA-08` Reis Magos Fort ($h = 220\text{ px}$, $z = -3$) — Red laterite coastal rampart.
- **$x = 92,000\text{ px}$ (920 m):** `LOC-GA-09` Fort Aguada & Lighthouse ($h = 280\text{ px}$, $z = -2$) — Circular laterite coastal beacon.
- **$x = 112,000\text{ px}$ (1,120 m):** `LOC-GA-11` Calangute Beach Road Promenade ($h = 200\text{ px}$, $z = -2$) — Thatched beach shack promenade.
- **$x = 120,000\text{ px}$ (1,200 m):** `LOC-GA-14` Chapora Fort Bastion ($h = 230\text{ px}$, $z = -3$) — Clifftop laterite fort wall.
- **$x = 128,000\text{ px}$ (1,280 m):** `LOC-GA-15` Basilica of Bom Jesus ($h = 290\text{ px}$, $z = -2$) — UNESCO laterite Baroque church.
- **$x = 142,000\text{ px}$ (1,420 m):** `LOC-GA-16` Se Cathedral ($h = 310\text{ px}$, $z = -2$) — Tuscan belfry cathedral square.
- **$x = 152,000\text{ px}$ (1,520 m):** `LOC-GA-22` Dudhsagar Waterfalls ($h = 300\text{ px}$, $z = -4$) — Western Ghats railway viaduct gorge.
- **$x = 160,000\text{ px}$ (1,600 m):** `LOC-GA-25` Holy Spirit Church ($h = 270\text{ px}$, $z = -2$) — Margao South Goa finish arch.

### 4.3 State 3: Kerala Route (`2,000 m / 200,000 px`)
- **$x = 16,000\text{ px}$ (160 m):** `LOC-KL-09` Fort Kochi Chinese Fishing Nets ($h = 240\text{ px}$, $z = -2$) — Cantilevered teak spider lift nets.
- **$x = 38,000\text{ px}$ (380 m):** `LOC-KL-10` Mattancherry Dutch Palace ($h = 210\text{ px}$, $z = -3$) — Sloping tiled Nalukettu veranda.
- **$x = 60,000\text{ px}$ (600 m):** `LOC-KL-01` Alleppey Backwaters Houseboat ($h = 230\text{ px}$, $z = -2$) — Kettuvallam thatch canal boat.
- **$x = 100,000\text{ px}$ (1,000 m):** `LOC-KL-14` Athirappilly Waterfalls ($h = 270\text{ px}$, $z = -4$) — Chalakudy river rocky gorge cascade.
- **$x = 135,000\text{ px}$ (1,350 m):** `LOC-KL-04` Munnar Tea Plantations ($h = 240\text{ px}$, $z = -3$) — Undulating emerald tea terraces.
- **$x = 160,000\text{ px}$ (1,600 m):** `LOC-KL-17` Bekal Fort Keyhole Bastion ($h = 220\text{ px}$, $z = -3$) — Arabian sea stone observation tower.
- **$x = 185,000\text{ px}$ (1,850 m):** `LOC-KL-25` Padmanabhaswamy Temple ($h = 330\text{ px}$, $z = -2$) — 100-ft Dravidian-Kerala fusion vimana.

### 4.4 State 4: Rajasthan Route (`2,200 m / 220,000 px`)
- **$x = 18,000\text{ px}$ (180 m):** `LOC-RJ-02` Hawa Mahal "Palace of Winds" ($h = 330\text{ px}$, $z = -2$) — 953 jharokha honeycomb facade.
- **$x = 44,000\text{ px}$ (440 m):** `LOC-RJ-03` Jal Mahal Water Palace ($h = 210\text{ px}$, $z = -3$) — Man Sagar lake pleasure pavilion.
- **$x = 70,000\text{ px}$ (700 m):** `LOC-RJ-01` Amber Fort Gateway ($h = 270\text{ px}$, $z = -2$) — Yellow sandstone hilltop citadel.
- **$x = 100,000\text{ px}$ (1,000 m):** `LOC-RJ-10` Mehrangarh Fort Bastion ($h = 280\text{ px}$, $z = -3$) — 400-ft perpendicular rock cliff.
- **$x = 128,000\text{ px}$ (1,280 m):** `LOC-RJ-12` Umaid Bhawan Palace ($h = 260\text{ px}$, $z = -3$) — Golden Chittar sandstone dome.
- **$x = 145,000\text{ px}$ (1,450 m):** `LOC-RJ-19` Chittorgarh Vijay Stambha ($h = 290\text{ px}$, $z = -2$) — 9-story marble tower of victory.
- **$x = 165,000\text{ px}$ (1,650 m):** `LOC-RJ-18` Sam Sand Dunes Desert Camp ($h = 250\text{ px}$, $z = -3$) — Sweeping wind-sculpted sand dunes.
- **$x = 185,000\text{ px}$ (1,850 m):** `LOC-RJ-15` Jaisalmer Golden Fort ($h = 290\text{ px}$, $z = -2$) — "Sonar Qila" triple sandstone ramparts.

### 4.5 State 5: Gujarat Route (`2,000 m / 200,000 px`)
- **$x = 18,000\text{ px}$ (180 m):** `LOC-GJ-04` Sabarmati Ashram ($h = 190\text{ px}$, $z = -3$) — Whitewashed tile-roofed cottage.
- **$x = 35,000\text{ px}$ (350 m):** `LOC-GJ-10` Teen Darwaza Royal Gateway ($h = 220\text{ px}$, $z = -2$) — Triple-arched royal avenue gate.
- **$x = 68,000\text{ px}$ (680 m):** `LOC-GJ-08` Modhera Sun Temple ($h = 270\text{ px}$, $z = -2$) — Surya Kund stepped reservoir sanctum.
- **$x = 90,000\text{ px}$ (900 m):** `LOC-GJ-12` Rani Ki Vav Stepwell Pavilion ($h = 240\text{ px}$, $z = -2$) — Subterranean carved Solanki pavilion.
- **$x = 110,000\text{ px}$ (1,100 m):** `LOC-GJ-01` Saurashtra Highway Oasis & Dhaba ($h = 190\text{ px}$, $z = 1$) — Highway charpai rest stop shelter.
- **$x = 135,000\text{ px}$ (1,350 m):** `LOC-GJ-02` Flamingo Sanctuary Pass ($h = 220\text{ px}$, $z = -3$) — Kutch salt marsh pink flamingos.
- **$x = 155,000\text{ px}$ (1,550 m):** `LOC-GJ-03` White Desert of Kutch ($h = 210\text{ px}$, $z = -3$) — Shimmering white crystalline salt crust.
- **$x = 175,000\text{ px}$ (1,750 m):** `LOC-GJ-21` Dwarkadhish Temple ($h = 310\text{ px}$, $z = -2$) — 72-pillar limestone Jagat Mandir.
- **$x = 192,000\text{ px}$ (1,920 m):** `LOC-GJ-24` Statue of Unity ($h = 340\text{ px}$, $z = -3$) — Colossal bronze-clad Patel statue.

### 4.6 State 6: Telangana Route (`1,800 m / 180,000 px`)
- **$x = 18,000\text{ px}$ (180 m):** `LOC-TS-04` Charminar Monument ($h = 330\text{ px}$, $z = -2$) — 4 fluted minarets square granite plinth.
- **$x = 42,000\text{ px}$ (420 m):** `LOC-TS-06` Chowmahalla Palace Khilwat ($h = 220\text{ px}$, $z = -3$) — Neoclassical Nizam coronation terrace.
- **$x = 68,000\text{ px}$ (680 m):** `LOC-TS-01` Golconda Fort Bastion ($h = 280\text{ px}$, $z = -3$) — Balahissar cyclopean granite ramparts.
- **$x = 92,000\text{ px}$ (920 m):** `LOC-TS-08` Hussain Sagar Buddha Statue ($h = 310\text{ px}$, $z = -2$) — Gibraltar rock monolithic standing Buddha.
- **$x = 115,000\text{ px}$ (1,150 m):** `LOC-TS-09` Birla Mandir Temple ($h = 280\text{ px}$, $z = -3$) — Naubat Pahad Makrana marble peak.
- **$x = 136,000\text{ px}$ (1,360 m):** `LOC-TS-02` Kakatiya Kala Thoranam ($h = 250\text{ px}$, $z = -2$) — Monolithic swan & lotus torana arch.
- **$x = 155,000\text{ px}$ (1,550 m):** `LOC-TS-03` Thousand Pillar Temple ($h = 240\text{ px}$, $z = -2$) — Star-shaped trikuta black basalt shrine.
- **$x = 168,000\text{ px}$ (1,680 m):** `LOC-TS-18` Laknavaram Suspension Bridge ($h = 220\text{ px}$, $z = -2$) — Green lake island pedestrian cable bridge.
- **$x = 178,000\text{ px}$ (1,780 m):** `LOC-TS-15` Ramappa Temple ($h = 290\text{ px}$, $z = -2$) — UNESCO lightweight floating brick sanctum.
