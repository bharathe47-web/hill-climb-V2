# Six-State Landmark Placement & Classification Audit

**Project:** Godot 4.7 2D Mobile Driving Game  
**Author / Developer:** Joel (Senior Godot Developer, Technical Artist, Level Designer, QA Engineer)  
**Date:** November 14, 2026  
**Document Path:** `docs/SIX_STATE_LANDMARK_PLACEMENT_AUDIT.md`  
**Git Branch:** `feature/joel-roads-obstacles`  
**Target Engine:** Godot Engine 4.7.2 Stable  
**Status:** 44/44 LANDMARKS AUDITED, CATEGORIZED, AND 100% OPERATIONAL

---

## 1. Executive Summary

This document provides the authoritative audit and catalog of all **44 famous Indian landmarks** across all six playable state routes in the game:
1. **Tamil Nadu** (12 landmarks)
2. **Goa** (9 landmarks)
3. **Kerala** (6 landmarks)
4. **Rajasthan** (6 landmarks)
5. **Gujarat** (5 landmarks)
6. **Telangana** (6 landmarks)

Every landmark is registered in `scripts/modes/indian_roads/RoadsideLandmarkRegistry.gd` and classified under the strict **5-Tier Landmark Placement Hierarchy**:
- `DRIVABLE_STRUCTURE`: Physical structures the player vehicle drives across or through with custom road collision and bridge geometry.
- `ROADSIDE_LANDMARK`: Historic monuments, temples, forts, and palaces anchored directly to the roadside shoulder.
- `BACKGROUND_LANDMARK`: Offshore island monuments, lake palaces, hilltop bastions, and monumental colossi set back in depth.
- `NATURAL_ATTRACTION`: Scenic coastal promenades, backwaters, river gorges, waterfalls, and cultural fishing points.
- `ROADSIDE_PROP`: Minor cultural elements, waypoints, and traditional roadside service dhabas.

---

## 2. Complete State-by-State Landmark Register

### 2.1 State 1: Tamil Nadu (Kanyakumari $\to$ Chennai, 1,800m)

| ID | Landmark Name | Dist | Placement Category | Target Size | Z-Idx | Offshore | Asset Path |
|---|---|---|---|---|---|---|---|
| `LOC-TN-03` | Gandhi Memorial Mandapam | 100m | `ROADSIDE_LANDMARK` | $220\times 240$ | `-2` | No | `res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/gandhi_memorial/gandhi_memorial.png` |
| `LOC-TN-04` | Kumari Amman Temple | 190m | `ROADSIDE_LANDMARK` | $270\times 250$ | `-2` | No | `res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/kumari_amman_temple/kumari_amman_temple.png` |
| `LOC-TN-05` | Kanyakumari Glass Bridge | 270m | `DRIVABLE_STRUCTURE` | $180\times 260$ | `+2`/`0` | No | `res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/glass_bridge/kanyakumari_glass_bridge.png` |
| `LOC-TN-02` | Vivekananda Rock Memorial | 315m | `BACKGROUND_LANDMARK` | $240\times 300$ | `-3` | **Yes** (Granite Island) | `res://assets/indian_locations/tamil_nadu/landmarks/vivekananda_rock_memorial_vector.png` |
| `LOC-TN-01` | Thiruvalluvar Statue | 415m | `BACKGROUND_LANDMARK` | $360\times 230$ | `-3` | **Yes** (Stone Pedestal Island) | `res://assets/indian_locations/tamil_nadu/landmarks/thiruvalluvar_statue_vector.png` |
| `LOC-TN-06` | Vattakottai Coastal Fort | 550m | `ROADSIDE_LANDMARK` | $230\times 270$ | `-2` | No | `res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/vattakottai_fort/vattakottai_fort.png` |
| `LOC-TN-07` | Kamarajar Memorial Mandapam | 650m | `ROADSIDE_LANDMARK` | $220\times 250$ | `-2` | No | `res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/kamarajar_memorial/kamarajar_memorial.png` |
| `LOC-TN-14` | Meenakshi Amman Temple | 880m | `ROADSIDE_LANDMARK` | $360\times 280$ | `-2` | No | `res://assets/indian_locations/tamil_nadu/landmarks/meenakshi_amman_temple_vector.png` |
| `LOC-TN-15` | Thirumalai Nayakkar Mahal | 1020m | `ROADSIDE_LANDMARK` | $240\times 290$ | `-2` | No | `res://assets/indian_locations/tamil_nadu/madurai/landmarks/thirumalai_nayakkar_mahal.png` |
| `LOC-TN-16` | NH44 Highway Junction Dhaba | 1150m | `ROADSIDE_PROP` | $190\times 220$ | `-2` | No | `res://assets/indian_roads/indian_roadside_dhaba_stall.png` |
| `LOC-TN-17` | Kapaleeshwarar Temple | 1580m | `ROADSIDE_LANDMARK` | $330\times 270$ | `-2` | No | `res://assets/indian_locations/tamil_nadu/chennai/landmarks/kapaleeshwarar_temple.png` |
| `LOC-TN-22` | Marina Beach Lighthouse | 1700m | `ROADSIDE_LANDMARK` | $320\times 180$ | `-2` | No | `res://assets/indian_locations/tamil_nadu/landmarks/chennai_marina_lighthouse_vector.png` |

---

### 2.2 State 2: Goa (Panaji $\to$ Margao, 1,600m)

| ID | Landmark Name | Dist | Placement Category | Target Size | Z-Idx | Offshore | Asset Path |
|---|---|---|---|---|---|---|---|
| `LOC-GA-02` | Fontainhas Latin Quarter | 120m | `ROADSIDE_LANDMARK` | $220\times 270$ | `-2` | No | `res://assets/indian_locations/goa/panaji/fontainhas_colourful_houses.png` |
| `LOC-GA-01` | Our Lady of Immaculate Conception | 260m | `ROADSIDE_LANDMARK` | $310\times 280$ | `-2` | No | `res://assets/indian_locations/goa/landmarks/our_lady_immaculate_conception_vector.png` |
| `LOC-GA-11` | Calangute Beach Road Promenade | 400m | `NATURAL_ATTRACTION` | $200\times 260$ | `-2` | No | `res://assets/indian_locations/goa/north_goa/calangute_beach.png` |
| `LOC-GA-09` | Fort Aguada & 1864 Lighthouse | 560m | `ROADSIDE_LANDMARK` | $280\times 270$ | `-2` | No | `res://assets/indian_locations/goa/landmarks/fort_aguada_lighthouse_vector.png` |
| `LOC-GA-14` | Chapora Red Laterite Fort | 680m | `ROADSIDE_LANDMARK` | $220\times 280$ | `-2` | No | `res://assets/indian_locations/goa/north_goa/chapora_fort.png` |
| `LOC-GA-16` | Se Cathedral | 960m | `ROADSIDE_LANDMARK` | $290\times 290$ | `-2` | No | `res://assets/indian_locations/goa/old_goa/se_cathedral.png` |
| `LOC-GA-17` | Church of St Francis of Assisi | 1080m | `ROADSIDE_LANDMARK` | $270\times 270$ | `-2` | No | `res://assets/indian_locations/goa/old_goa/church_of_st_francis_of_assisi.png` |
| `LOC-GA-15` | Basilica of Bom Jesus | 1200m | `ROADSIDE_LANDMARK` | $280\times 310$ | `-2` | No | `res://assets/indian_locations/goa/landmarks/basilica_of_bom_jesus_vector.png` |
| `LOC-GA-22` | Holy Spirit Church | 1420m | `ROADSIDE_LANDMARK` | $270\times 280$ | `-2` | No | `res://assets/indian_locations/goa/south_goa/holy_spirit_church.png` |

---

### 2.3 State 3: Kerala (Kochi $\to$ Munnar, 2,000m)

| ID | Landmark Name | Dist | Placement Category | Target Size | Z-Idx | Offshore | Asset Path |
|---|---|---|---|---|---|---|---|
| `LOC-KL-01` | Fort Kochi Chinese Fishing Nets | 100m | `NATURAL_ATTRACTION` | $270\times 290$ | `-2` | No | `res://assets/indian_locations/kerala/landmarks/chinese_fishing_nets_vector.png` |
| `LOC-KL-02` | Mattancherry Dutch Palace | 280m | `ROADSIDE_LANDMARK` | $240\times 290$ | `-2` | No | `res://assets/indian_locations/kerala/landmarks/mattancherry_palace.png` |
| `LOC-KL-06` | Alleppey Backwater Houseboat Wharf | 500m | `NATURAL_ATTRACTION` | $210\times 290$ | `-2` | No | `res://assets/indian_locations/kerala/landmarks/alleppey_houseboat_vector.png` |
| `LOC-KL-09` | Bekal Fort Coastal Bastion | 750m | `ROADSIDE_LANDMARK` | $230\times 280$ | `-2` | No | `res://assets/indian_locations/kerala/landmarks/bekal_fort_bastion.png` |
| `LOC-KL-11` | Athirappilly Waterfalls Viewpoint | 1240m | `NATURAL_ATTRACTION` | $280\times 280$ | `-2` | No | `res://assets/indian_locations/kerala/landmarks/athirappilly_waterfalls.png` |
| `LOC-KL-14` | Padmanabhaswamy Temple Gopuram | 1740m | `ROADSIDE_LANDMARK` | $340\times 270$ | `-2` | No | `res://assets/indian_locations/kerala/landmarks/padmanabhaswamy_temple.png` |

---

### 2.4 State 4: Rajasthan (Jaipur $\to$ Jaisalmer, 2,200m)

| ID | Landmark Name | Dist | Placement Category | Target Size | Z-Idx | Offshore | Asset Path |
|---|---|---|---|---|---|---|---|
| `LOC-RJ-01` | Hawa Mahal (Palace of Winds) | 120m | `ROADSIDE_LANDMARK` | $340\times 290$ | `-2` | No | `res://assets/indian_locations/rajasthan/landmarks/hawa_mahal_vector.png` |
| `LOC-RJ-02` | Jal Mahal Water Palace | 340m | `BACKGROUND_LANDMARK` | $230\times 300$ | `-3` | **Yes** (Man Sagar Lake) | `res://assets/indian_locations/rajasthan/landmarks/jal_mahal_palace.png` |
| `LOC-RJ-03` | Amber Fort Ramparts & Gateway | 550m | `ROADSIDE_LANDMARK` | $290\times 300$ | `-2` | No | `res://assets/indian_locations/rajasthan/landmarks/amber_fort_ramparts_vector.png` |
| `LOC-RJ-08` | Jaswant Thada Marble Cenotaph | 820m | `ROADSIDE_LANDMARK` | $250\times 280$ | `-2` | No | `res://assets/indian_locations/rajasthan/landmarks/jaswant_thada_marble.png` |
| `LOC-RJ-11` | Mehrangarh Fort Cliff Bastion | 1350m | `BACKGROUND_LANDMARK` | $290\times 300$ | `-3` | No (Towering Cliff) | `res://assets/indian_locations/rajasthan/mehrangarh_fort_vista.png` |
| `LOC-RJ-15` | Patwon Ki Haveli Jharokhas | 1920m | `ROADSIDE_LANDMARK` | $270\times 280$ | `-2` | No | `res://assets/indian_locations/rajasthan/landmarks/patwon_ki_haveli.png` |

---

### 2.5 State 5: Gujarat (Ahmedabad $\to$ Rann of Kutch, 2,000m)

| ID | Landmark Name | Dist | Placement Category | Target Size | Z-Idx | Offshore | Asset Path |
|---|---|---|---|---|---|---|---|
| `LOC-GJ-01` | Sabarmati Ashram Hriday Kunj | 120m | `ROADSIDE_LANDMARK` | $210\times 290$ | `-2` | No | `res://assets/indian_locations/gujarat/landmarks/sabarmati_ashram.png` |
| `LOC-GJ-02` | Adalaj Stepwell (Vav) | 320m | `ROADSIDE_LANDMARK` | $240\times 280$ | `-2` | No | `res://assets/indian_locations/gujarat/landmarks/adalaj_stepwell.png` |
| `LOC-GJ-07` | Modhera Sun Temple Surya Kund | 740m | `ROADSIDE_LANDMARK` | $280\times 290$ | `-2` | No | `res://assets/indian_locations/gujarat/landmarks/modhera_sun_temple.png` |
| `LOC-GJ-11` | Somnath Temple Jyotirlinga Shrine | 1260m | `ROADSIDE_LANDMARK` | $340\times 280$ | `-2` | No | `res://assets/indian_locations/gujarat/landmarks/somnath_temple.png` |
| `LOC-GJ-16` | Statue of Unity Grand Colossus | 1750m | `BACKGROUND_LANDMARK` | $360\times 200$ | `-3` | **Yes** (Sadhu Bet Island) | `res://assets/indian_locations/gujarat/landmarks/statue_of_unity_vector.png` |

---

### 2.6 State 6: Telangana (Hyderabad $\to$ Warangal, 1,800m)

| ID | Landmark Name | Dist | Placement Category | Target Size | Z-Idx | Offshore | Asset Path |
|---|---|---|---|---|---|---|---|
| `LOC-TG-01` | Iconic Charminar 4-Minaret Monument | 100m | `ROADSIDE_LANDMARK` | $340\times 290$ | `-2` | No | `res://assets/indian_locations/telangana/landmarks/charminar_monument_vector.png` |
| `LOC-TG-02` | Chowmahalla Palace Courtyard | 280m | `ROADSIDE_LANDMARK` | $220\times 290$ | `-2` | No | `res://assets/indian_locations/telangana/landmarks/chowmahalla_palace.png` |
| `LOC-TG-03` | Golconda Fort Bastion | 450m | `ROADSIDE_LANDMARK` | $280\times 290$ | `-2` | No | `res://assets/indian_locations/telangana/golconda_fort_bastion.png` |
| `LOC-TG-06` | Hussain Sagar Monolithic Buddha | 680m | `BACKGROUND_LANDMARK` | $330\times 210$ | `-3` | **Yes** (Gibraltar Rock Island) | `res://assets/indian_locations/telangana/landmarks/hussain_sagar_buddha.png` |
| `LOC-TG-08` | Birla Mandir White Marble Temple | 1120m | `BACKGROUND_LANDMARK` | $280\times 280$ | `-3` | No (Naubat Pahad Hill) | `res://assets/indian_locations/telangana/landmarks/birla_mandir.png` |
| `LOC-TG-14` | Ramappa Temple (Rudreshwara) | 1580m | `ROADSIDE_LANDMARK` | $280\times 280$ | `-2` | No | `res://assets/indian_locations/telangana/landmarks/ramappa_temple.png` |

---

## 3. Placement Audit Verification Summary

- **Total Landmarks Checked:** 44
- **Asset Integrity:** 44/44 textures exist on disk and load with 0 errors.
- **Zero Signboard Occlusion:** All signboards are offset to $x = -110\text{px}$, leaving monuments $100\%$ visible.
- **Scale Normalization:** Heights strictly clamped between $180\text{px}$ and $360\text{px}$.
- **Zero Collision Overlap:** $650\text{px}$ procedural buffer eliminates repetitive housing and sprite clumping around all landmarks.
