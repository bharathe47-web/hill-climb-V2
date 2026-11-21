# Indian Roads — Landmark Integration Report
## Authoritative Landmark Registry, Scaling, Depth Planes & Asset Mapping

**Project:** Godot 4.7 2D Mobile Driving Game  
**Lead / Author:** Joel (Senior Godot 4.7 Developer, 2D Environment Specialist, QA Lead)  
**Date:** November 14, 2026  
**Document:** `docs/INDIAN_ROADS_LANDMARK_INTEGRATION_REPORT.md`  
**Git Branch:** `feature/joel-roads-obstacles`  
**Engine:** Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf  

---

## 1. Unified Landmark Architecture Overview

In accordance with the Master Task requirements, the game now operates on a **Unified Landmark Placement Architecture**. All landmark occurrences derive from `RoadsideLandmarkRegistry.gd`, eliminating duplicate scene instances, overlapping checkpoint gates, and colliding roadside signposts.

```
       [UNIFIED LANDMARK LAYER HIERARCHY]
  Layer +1 (z_index =  1) : Decoupled Indian Highway Signboards & Milestone Posts
  Layer  0 (z_index =  0) : Road Surface, Vehicle, and Active Driving Plane
  Layer -2 (z_index = -2) : Roadside Monuments (Temples, Forts, Palaces, Towers)
  Layer -3 (z_index = -3) : Offshore Monuments (Rock Islands, Water Palaces, Fort Citadels)
  Layer -4 (z_index = -4) : Distant Geographic Horizon Elements
```

### Key Engineering Features:
1. **Dynamic Aspect Ratio Preservation:** Source vector and high-resolution textures (from 512px up to 1500px) are scaled dynamically to target bounding boxes (200px to 360px height) without stretching.
2. **True Ground Anchoring:** The base bounding edge of every monument sprite aligns with the roadside shoulder (`ground_offset_y = 0.0`), preventing floating or sunken geometry.
3. **Offshore Realization:** Attractions surrounded by water (`is_offshore = true`) are positioned at `z_index = -3` in the coastal horizon layer, while the informational highway signboard is anchored to the roadside shoulder at `z_index = 1`.
4. **Milestone Decoupling:** Signboards are offset horizontally (`x = -110px`, `y = -42px`) so that the green highway board never occludes the monument artwork.

---

## 2. Complete Six-State Landmark Register & Asset Mapping

### 2.1 Tamil Nadu (Route: Kanyakumari → Madurai → Chennai, 1,800m)
| ID | Place Name | Region / District | Distance | Target Size | Depth | Classification | Asset Reference |
|---|---|---|:---:|:---:|:---:|:---:|---|
| `LOC-TN-03` | Gandhi Memorial Mandapam | Kanyakumari Coast | 100m | 240x220 | `z = -2` | Secondary | `res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/gandhi_memorial/gandhi_memorial.png` |
| `LOC-TN-04` | Kumari Amman Temple | Cape Comorin Shore | 190m | 250x270 | `z = -2` | Secondary | `res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/kumari_amman_temple/kumari_amman_temple.png` |
| `LOC-TN-05` | Kanyakumari Glass Bridge | Laccadive Sea Promenade | 270m | 260x180 | `z = -2` | Coastal | `res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/glass_bridge/kanyakumari_glass_bridge.png` |
| `LOC-TN-01` | Thiruvalluvar Statue | Kanyakumari Offshore Rock | 350m | 220x340 | `z = -3` (Offshore) | Hero | `res://assets/indian_locations/tamil_nadu/landmarks/thiruvalluvar_statue_vector.png` |
| `LOC-TN-02` | Vivekananda Rock Memorial | Indian Ocean Island | 440m | 280x230 | `z = -3` (Offshore) | Hero | `res://assets/indian_locations/tamil_nadu/landmarks/vivekananda_rock_memorial_vector.png` |
| `LOC-TN-06` | Vattakottai Coastal Fort | Coastal Ramparts | 550m | 270x230 | `z = -2` | Secondary | `res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/vattakottai_fort/vattakottai_fort.png` |
| `LOC-TN-07` | Kamarajar Memorial Mandapam | Shoreline Park | 650m | 250x220 | `z = -2` | Secondary | `res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/kamarajar_memorial/kamarajar_memorial.png` |
| `TN-CP-01` | Madurai Checkpoint Toll | NH44 Highway Gate | 750m | 280x160 | `z = 0` | Checkpoint Gate | `res://assets/indian_roads/visual_upgrade_v2/indian_checkpoint_gate.png` |
| `LOC-TN-14` | Meenakshi Amman Temple | Madurai Temple City | 880m | 280x360 | `z = -2` | Hero | `res://assets/indian_locations/tamil_nadu/landmarks/meenakshi_amman_temple_vector.png` |
| `LOC-TN-15` | Thirumalai Nayakkar Mahal | Madurai Royal Palace | 1020m | 290x240 | `z = -2` | Hero | `res://assets/indian_locations/tamil_nadu/madurai/landmarks/thirumalai_nayakkar_mahal.png` |
| `LOC-TN-16` | NH44 Highway Junction Dhaba | Tamil Countryside | 1150m | 220x190 | `z = -2` | Countryside | `res://assets/indian_roads/indian_roadside_dhaba_stall.png` |
| `TN-CP-02` | Coastal Toll Plaza | East Coast Road Gate | 1450m | 280x160 | `z = 0` | Checkpoint Gate | `res://assets/indian_roads/visual_upgrade_v2/indian_checkpoint_gate.png` |
| `LOC-TN-17` | Kapaleeshwarar Temple | Mylapore, Chennai | 1580m | 270x330 | `z = -2` | Hero | `res://assets/indian_locations/tamil_nadu/chennai/landmarks/kapaleeshwarar_temple.png` |
| `LOC-TN-22` | Marina Beach Lighthouse | Marina Beach, Chennai | 1700m | 180x320 | `z = -2` | Hero | `res://assets/indian_locations/tamil_nadu/landmarks/chennai_marina_lighthouse_vector.png` |
| `TN-DEST` | Chennai Marina Destination Arch | Marina Beach Boulevard | 1800m | 360x220 | `z = 0` | Destination Arch | `res://assets/indian_roads/visual_upgrade_v2/indian_finish_arch.png` |

---

### 2.2 Goa (Route: Panaji → Margao, 1,600m)
| ID | Place Name | Region / District | Distance | Target Size | Depth | Classification | Asset Reference |
|---|---|---|:---:|:---:|:---:|:---:|---|
| `LOC-GA-02` | Fontainhas Latin Quarter | Panaji Heritage Quarter | 120m | 270x220 | `z = -2` | Hero | `res://assets/indian_locations/goa/panaji/fontainhas_colourful_houses.png` |
| `LOC-GA-01` | Our Lady of Immaculate Conception | Panaji Church Square | 260m | 280x310 | `z = -2` | Hero | `res://assets/indian_locations/goa/landmarks/our_lady_immaculate_conception_vector.png` |
| `LOC-GA-11` | Calangute Beach Road Promenade | Bardez Coastal Strip | 400m | 260x200 | `z = -2` | Hero | `res://assets/indian_locations/goa/north_goa/calangute_beach.png` |
| `LOC-GA-09` | Fort Aguada & 1864 Lighthouse | Sinquerim Coastal Bluff | 560m | 270x280 | `z = -2` | Hero | `res://assets/indian_locations/goa/landmarks/fort_aguada_lighthouse_vector.png` |
| `LOC-GA-14` | Chapora Red Laterite Fort | Vagator Hilltop | 680m | 280x220 | `z = -2` | Secondary | `res://assets/indian_locations/goa/north_goa/chapora_fort.png` |
| `GA-CP-01` | Mandovi Bridge Toll Plaza | NH66 Coastal Highway Gate | 800m | 280x160 | `z = 0` | Checkpoint Gate | `res://assets/indian_roads/visual_upgrade_v2/indian_checkpoint_gate.png` |
| `LOC-GA-16` | Se Cathedral | Old Goa UNESCO Heritage | 960m | 290x290 | `z = -2` | Hero | `res://assets/indian_locations/goa/old_goa/se_cathedral.png` |
| `LOC-GA-17` | Church of St Francis of Assisi | Old Goa UNESCO Heritage | 1080m | 270x270 | `z = -2` | Secondary | `res://assets/indian_locations/goa/old_goa/church_of_st_francis_of_assisi.png` |
| `LOC-GA-15` | Basilica of Bom Jesus | Old Goa UNESCO Heritage | 1200m | 310x280 | `z = -2` | Hero | `res://assets/indian_locations/goa/landmarks/basilica_of_bom_jesus_vector.png` |
| `LOC-GA-22` | Holy Spirit Church | Margao Heritage Square | 1420m | 280x270 | `z = -2` | Hero | `res://assets/indian_locations/goa/south_goa/holy_spirit_church.png` |
| `GA-DEST` | Margao Victory Destination Arch | South Goa Town Square | 1600m | 360x220 | `z = 0` | Destination Arch | `res://assets/indian_roads/visual_upgrade_v2/indian_finish_arch.png` |

---

### 2.3 Kerala (Route: Kochi → Munnar, 2,000m)
| ID | Place Name | Region / District | Distance | Target Size | Depth | Classification | Asset Reference |
|---|---|---|:---:|:---:|:---:|:---:|---|
| `LOC-KL-01` | Fort Kochi Chinese Fishing Nets | Kochi Harbor Waterfront | 100m | 290x270 | `z = -2` | Hero | `res://assets/indian_locations/kerala/landmarks/chinese_fishing_nets_vector.png` |
| `LOC-KL-02` | Mattancherry Dutch Palace | Jew Town, Kochi | 280m | 290x240 | `z = -2` | Hero | `res://assets/indian_locations/kerala/landmarks/mattancherry_palace.png` |
| `LOC-KL-06` | Alleppey Houseboat Wharf | Vembanad Lake | 500m | 290x210 | `z = -2` | Hero | `res://assets/indian_locations/kerala/landmarks/alleppey_houseboat_vector.png` |
| `LOC-KL-09` | Bekal Fort Coastal Bastion | Kasaragod Ramparts | 750m | 280x230 | `z = -2` | Secondary | `res://assets/indian_locations/kerala/landmarks/bekal_fort_bastion.png` |
| `KL-CP-01` | Western Ghats Forest Checkpoint | High Range Pass | 1000m | 280x160 | `z = 0` | Checkpoint Gate | `res://assets/indian_roads/visual_upgrade_v2/indian_checkpoint_gate.png` |
| `LOC-KL-11` | Athirappilly Waterfalls Viewpoint | Chalakudy River Gorge | 1240m | 280x280 | `z = -2` | Hero | `res://assets/indian_locations/kerala/landmarks/athirappilly_waterfalls.png` |
| `LOC-KL-14` | Padmanabhaswamy Temple Gopuram | Thiruvananthapuram | 1740m | 270x340 | `z = -2` | Hero | `res://assets/indian_locations/kerala/landmarks/padmanabhaswamy_temple.png` |
| `KL-DEST` | Munnar Highlands Destination Arch | Tea Estate Gap Road | 2000m | 360x220 | `z = 0` | Destination Arch | `res://assets/indian_roads/visual_upgrade_v2/indian_finish_arch.png` |

---

### 2.4 Rajasthan (Route: Jaipur → Jaisalmer, 2,200m)
| ID | Place Name | Region / District | Distance | Target Size | Depth | Classification | Asset Reference |
|---|---|---|:---:|:---:|:---:|:---:|---|
| `LOC-RJ-01` | Hawa Mahal (Palace of Winds) | Badi Choupad, Jaipur | 120m | 290x340 | `z = -2` | Hero | `res://assets/indian_locations/rajasthan/landmarks/hawa_mahal_vector.png` |
| `LOC-RJ-02` | Jal Mahal Water Palace | Man Sagar Lake | 340m | 300x230 | `z = -3` (Water) | Hero | `res://assets/indian_locations/rajasthan/landmarks/jal_mahal_palace.png` |
| `LOC-RJ-03` | Amber Fort Ramparts & Gateway | Amer Valley Citadel | 550m | 300x290 | `z = -2` | Hero | `res://assets/indian_locations/rajasthan/landmarks/amber_fort_ramparts_vector.png` |
| `LOC-RJ-08` | Jaswant Thada Cenotaph | Jodhpur Royal Grounds | 820m | 280x250 | `z = -2` | Hero | `res://assets/indian_locations/rajasthan/landmarks/jaswant_thada_marble.png` |
| `RJ-CP-01` | Thar Desert Border Checkpoint | Marwar Highway Gate | 1100m | 280x160 | `z = 0` | Checkpoint Gate | `res://assets/indian_roads/visual_upgrade_v2/indian_checkpoint_gate.png` |
| `LOC-RJ-11` | Mehrangarh Fort Cliff Bastion | Jodhpur Ridge | 1350m | 300x290 | `z = -2` | Hero | `res://assets/indian_locations/rajasthan/mehrangarh_fort_vista.png` |
| `LOC-RJ-15` | Patwon Ki Haveli Jharokhas | Jaisalmer Golden City | 1920m | 280x270 | `z = -2` | Hero | `res://assets/indian_locations/rajasthan/landmarks/patwon_ki_haveli.png` |
| `RJ-DEST` | Jaisalmer Golden Fort Arch | Desert Citadel Gate | 2200m | 360x220 | `z = 0` | Destination Arch | `res://assets/indian_roads/visual_upgrade_v2/indian_finish_arch.png` |

---

### 2.5 Gujarat (Route: Ahmedabad → Rann of Kutch, 2,000m)
| ID | Place Name | Region / District | Distance | Target Size | Depth | Classification | Asset Reference |
|---|---|---|:---:|:---:|:---:|:---:|---|
| `LOC-GJ-01` | Sabarmati Ashram Hriday Kunj | Ahmedabad Sabarmati Bank | 120m | 290x210 | `z = -2` | Hero | `res://assets/indian_locations/gujarat/landmarks/sabarmati_ashram.png` |
| `LOC-GJ-02` | Adalaj Stepwell (Vav) | Gandhinagar Subterranean | 320m | 280x240 | `z = -2` | Hero | `res://assets/indian_locations/gujarat/landmarks/adalaj_stepwell.png` |
| `LOC-GJ-07` | Modhera Sun Temple Surya Kund | Mehsana Heritage | 740m | 290x280 | `z = -2` | Hero | `res://assets/indian_locations/gujarat/landmarks/modhera_sun_temple.png` |
| `GJ-CP-01` | Kutch Border Checkpoint Toll | Saurashtra Highway Gate | 1000m | 280x160 | `z = 0` | Checkpoint Gate | `res://assets/indian_roads/visual_upgrade_v2/indian_checkpoint_gate.png` |
| `LOC-GJ-11` | Somnath Temple Jyotirlinga Shrine | Prabhas Patan Coast | 1260m | 280x340 | `z = -2` | Hero | `res://assets/indian_locations/gujarat/landmarks/somnath_temple.png` |
| `LOC-GJ-16` | Statue of Unity Grand Colossus | Narmada Riverfront | 1750m | 200x360 | `z = -2` | Hero | `res://assets/indian_locations/gujarat/landmarks/statue_of_unity_vector.png` |
| `GJ-DEST` | White Rann Salt Desert Arch | Dhordo Desert Gate | 2000m | 360x220 | `z = 0` | Destination Arch | `res://assets/indian_roads/visual_upgrade_v2/indian_finish_arch.png` |

---

### 2.6 Telangana (Route: Hyderabad → Warangal, 1,800m)
| ID | Place Name | Region / District | Distance | Target Size | Depth | Classification | Asset Reference |
|---|---|---|:---:|:---:|:---:|:---:|---|
| `LOC-TG-01` | Iconic Charminar 4-Minaret Gate | Old City, Hyderabad | 100m | 290x340 | `z = -2` | Hero | `res://assets/indian_locations/telangana/landmarks/charminar_monument_vector.png` |
| `LOC-TG-02` | Chowmahalla Palace Courtyard | Khilwat, Hyderabad | 280m | 290x220 | `z = -2` | Hero | `res://assets/indian_locations/telangana/landmarks/chowmahalla_palace.png` |
| `LOC-TG-03` | Golconda Fort Bastion | Golconda Citadel | 450m | 290x280 | `z = -2` | Hero | `res://assets/indian_locations/telangana/golconda_fort_bastion.png` |
| `LOC-TG-06` | Hussain Sagar Monolithic Buddha | Hussain Sagar Lake | 680m | 210x330 | `z = -3` (Water) | Hero | `res://assets/indian_locations/telangana/landmarks/hussain_sagar_buddha.png` |
| `TG-CP-01` | Deccan Highway Checkpoint Toll | Warangal Highway Gate | 900m | 280x160 | `z = 0` | Checkpoint Gate | `res://assets/indian_roads/visual_upgrade_v2/indian_checkpoint_gate.png` |
| `LOC-TG-08` | Birla Mandir White Marble Temple | Naubat Pahad Hilltop | 1120m | 280x280 | `z = -2` | Hero | `res://assets/indian_locations/telangana/landmarks/birla_mandir.png` |
| `LOC-TG-14` | Ramappa Temple (Rudreshwara) | Palampet, Mulugu | 1580m | 280x280 | `z = -2` | Hero | `res://assets/indian_locations/telangana/landmarks/ramappa_temple.png` |
| `TG-DEST` | Warangal Fort Victory Arch | Thousand Pillar City | 1800m | 360x220 | `z = 0` | Destination Arch | `res://assets/indian_roads/visual_upgrade_v2/indian_finish_arch.png` |

---

## 3. Resolution of Duplicate Landmark Flaws

1. **Root Cause Analysis:** Previously, `IndianRoadTerrainV2._spawn_waypoints()` instantiated `LandmarkV2Scene` for every landmark waypoint, while `IndianRoadTerrainV2._spawn_roadside_props()` independently instantiated `RoadsideLandmarkScene` at the same meter distance, causing two overlapping visual sprites, two signboards, and duplicate labels.
2. **Architectural Fix:** 
   - `RoadsideLandmarkRegistry.gd` holds all calibrated coordinates.
   - `RoadsideLandmark` in `props_container` is the sole visual rendering component.
   - `LandmarkV2` in `waypoints_container` acts as a lean trigger zone for HUD tracking and emits the milestone signal without duplicating sprites.
3. **Verification:** Automated tests verify that `waypoints_container` contains exactly the expected milestone triggers, and `props_container` contains non-overlapping roadside landmarks with ±650px exclusion zones.
