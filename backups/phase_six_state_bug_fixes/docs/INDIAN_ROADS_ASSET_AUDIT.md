# Indian Roads Asset Audit & Architectural Analysis

**Project:** Hill Climb 2D — Indian Roads Mode  
**Document Owner:** Joel (Lead Indian Roads Specialist & Art Director)  
**Date:** 2026-11-13  
**Status:** Stage 1 Analysis Complete  

---

## 1. Executive Summary

This comprehensive audit inspects the current visual assets, scenes, scripts, and route data for the **Indian Roads** mode in Hill Climb 2D. 
While the underlying gameplay architecture, sequential unlocking, physics, and state selection are fully functional and verified across 15+ automated test suites, the current artwork consists largely of low-fidelity, rudimentary placeholder sprites, uncurated clipart, and missing regional representations for 5 out of 6 states.

Our objective is to elevate this mode to a **commercial, AAA-quality 2D mobile side-scrolling driving aesthetic** with authentic Indian regional landmarks, cohesive art direction, distinct parallax layers, and 100% verified CC0 / CC BY / Public Domain licenses.

---

## 2. Inventory of Current Assets

### 2.1 Location Assets (`assets/indian_locations/`)

| Filename | Format | Dimensions | File Size | Current Usage | Visual Quality & Notes |
|---|---|---|---|---|---|
| `india_map_states.png` | PNG | 720x800 | 381.9 KB | `StateSelection.tscn` (fallback) | Clean overview map of India with states; functional |
| `india_map_states.svg` | SVG | Vector | 311.7 KB | Vector master of India map | Clean SVG master data; good for UI |
| `tamil_nadu_state_map.svg` | SVG | Vector | 2.51 MB | `RouteRegistry.gd` (TN map) | Full India map with TN highlighted; very heavy (2.5MB) |
| `goa_state_map.svg` | SVG | Vector | 2.51 MB | `RouteRegistry.gd` (Goa map) | Full India map with Goa highlighted; heavy (2.5MB) |
| `kerala_state_map.svg` | SVG | Vector | 2.51 MB | `RouteRegistry.gd` (Kerala map) | Full India map with Kerala highlighted; heavy (2.5MB) |
| `rajasthan_state_map.svg` | SVG | Vector | 2.51 MB | `RouteRegistry.gd` (Rajasthan map)| Full India map with Rajasthan highlighted; heavy (2.5MB) |
| `gujarat_state_map.svg` | SVG | Vector | 2.51 MB | `RouteRegistry.gd` (Gujarat map)| Full India map with Gujarat highlighted; heavy (2.5MB) |
| `telangana_state_map.svg` | SVG | Vector | 1.64 MB | `RouteRegistry.gd` (Telangana map)| Full India map with Telangana highlighted |
| `state_select_tamil_nadu.png` | PNG | 400x440 | 113.2 KB | `StateSelection` card icon | Good quality stylized state card badge |
| `state_select_goa.png` | PNG | 400x440 | 112.8 KB | `StateSelection` card icon | Good quality stylized state card badge |
| `state_select_kerala.png` | PNG | 400x440 | 113.1 KB | `StateSelection` card icon | Good quality stylized state card badge |
| `state_select_rajasthan.png` | PNG | 400x440 | 114.0 KB | `StateSelection` card icon | Good quality stylized state card badge |
| `state_select_gujarat.png` | PNG | 400x440 | 113.5 KB | `StateSelection` card icon | Good quality stylized state card badge |
| `state_select_telangana.png` | PNG | 400x440 | 117.5 KB | `StateSelection` card icon | Good quality stylized state card badge |
| `tamil_nadu_kanyakumari_triveni_sangam.png` | PNG | 1920x1200 | 1.18 MB | Waypoint: Kanyakumari Start | High-res photographic/digital landscape |
| `tamil_nadu_thiruvalluvar_statue.png` | PNG | 200x300 | 27.8 KB | Waypoint: Thiruvalluvar | Stylized transparent monument cutout; good silhouette |
| `tamil_nadu_vivekananda_rock_memorial.png` | PNG | 300x260 | 16.0 KB | Extra TN landmark (unused in reg)| Good monument cutout; available as landmark |
| `tamil_nadu_madurai_meenakshi_temple.png` | PNG | 240x320 | 7.7 KB | Waypoint: Madurai Checkpoint | Low-detail gopuram cutout; needs AAA polish |
| `tamil_nadu_chennai_marina_lighthouse.png` | PNG | 160x320 | 8.3 KB | Waypoint: Chennai Destination | Low-detail lighthouse illustration; needs AAA polish |
| `tamil_nadu_chennai_destination_arch.png` | PNG | 240x220 | 770 bytes | Alternate TN finish arch | Rudimentary low-color placeholder |
| `tamil_nadu_kanyakumari_coastline.png` | PNG | 544x160 | 5.1 KB | Unused backdrop layer | Very low-resolution horizon slice |

### 2.2 Road & Prop Assets (`assets/indian_roads/`)

| Filename | Format | Dimensions | File Size | Current Usage | Visual Quality & Notes |
|---|---|---|---|---|---|
| `indian_sky_tropical.png` | PNG | 1280x720 | 5.3 KB | Parallax sky across all 6 states | Flat blue gradient; lacks clouds, atmospheric depth |
| `indian_parallax_rural_plains.png` | PNG | 544x160 | 5.1 KB | Parallax backdrop for 4 states | Low-res 544x160 repeating silhouette; blurry at 720p |
| `indian_parallax_western_ghats.png`| PNG | 272x160 | 1.4 KB | Parallax backdrop for Goa/Kerala | Extremely low-res 272x160 pixelated hill outline |
| `indian_road_asphalt_straight.png` | PNG | 128x128 | 193 bytes | Unused (terrain is drawn) | Ultra-basic 1-color tile; lacks asphalt texture/aggregate |
| `indian_road_asphalt_slope_up.png` | PNG | 128x128 | 2.5 KB | Unused | Low-res pre-baked slope |
| `indian_road_asphalt_slope_down.png`| PNG | 128x128 | 2.5 KB | Unused | Low-res pre-baked slope |
| `indian_road_shoulder_dirt.png` | PNG | 128x128 | 2.1 KB | Unused | Rudimentary dirt block |
| `indian_road_yellow_stripes.png` | PNG | 128x24 | 183 bytes | Unused | Single stripe sprite |
| `indian_road_highway_divider.png` | PNG | 128x24 | 182 bytes | Prop (unused in terrain) | 182 bytes flat gray bar |
| `indian_road_barricade_yellow_black.png`| PNG | 120x40 | 215 bytes | Construction hazard prop | Tiny 215-byte placeholder graphic |
| `indian_traffic_cone.png` | PNG | 45x44 | 666 bytes | Road work hazard prop | Small, acceptable cartoon cone |
| `indian_guardrail_concrete.png` | PNG | 210x62 | 576 bytes | Steep slope safety barrier | Rudimentary flat concrete block |
| `indian_roadside_auto_rickshaw.png`| PNG | 90x70 | 291 bytes | Roadside scenic prop | Tiny 291-byte graphic, lacks wheels and details |
| `indian_roadside_dhaba_stall.png` | PNG | 160x100 | 400 bytes | Roadside dhaba & landmark | Rudimentary low-color hut graphic |
| `indian_roadside_tea_stall.png` | PNG | 100x80 | 302 bytes | Roadside chai stall & landmark | Tiny 302-byte graphic |
| `indian_roadside_milestone_km.png`| PNG | 40x50 | 199 bytes | Milestone & landmark placeholder| Tiny 199-byte block |
| `indian_roadside_banyan_tree.png` | PNG | 214x212 | 3.4 KB | Roadside tree & landmark | Recognizable silhouette, low color depth |
| `indian_roadside_coconut_tree.png`| PNG | 140x200 | 19.4 KB | Roadside tree & landmark | Clean tropical coconut tree; acceptable |
| `indian_road_sign_nh44.png` | PNG | 80x100 | 357 bytes | Roadside NH44 highway sign | Minimal vector-rasterized sign |
| `indian_road_sign_speed_limit.png`| PNG | 64x100 | 339 bytes | Roadside speed limit sign | Minimal vector-rasterized sign |
| `indian_road_sign_speed_breaker.png`| PNG | 64x100 | 357 bytes | Speed breaker advance sign | Minimal vector-rasterized sign |
| `indian_road_sign_curve_ahead.png`| PNG | 64x100 | 342 bytes | Construction advance sign | Minimal vector-rasterized sign |
| `indian_checkpoint_gate.png` | PNG | 200x100 | 757 bytes | Toll plaza checkpoint | Flat red-and-white barrier pole |
| `indian_checkpoint_banner.png` | PNG | 300x50 | 275 bytes | Overhead toll banner | 275-byte yellow ribbon banner |
| `indian_checkpoint_toll_booth.png`| PNG | 180x120 | 484 bytes | Checkpoint toll booth | Rudimentary kiosk booth |
| `indian_finish_arch.png` | PNG | 240x160 | 625 bytes | Destination finish gate | Minimalist blue arch |
| `indian_marker_start.png` | PNG | 40x80 | 187 bytes | Start marker | Minimal flag pin |
| `indian_marker_destination.png` | PNG | 40x80 | 188 bytes | Destination marker | Minimal flag pin |

---

## 3. Analysis & Problem Classification

### 3.1 Low-Resolution & Rudimentary Assets (Under 1 KB)
The following 16 assets are sub-kilobyte placeholders with severe lack of texture detail:
- `indian_checkpoint_banner.png` (275 B)
- `indian_checkpoint_gate.png` (757 B)
- `indian_checkpoint_toll_booth.png` (484 B)
- `indian_finish_arch.png` (625 B)
- `indian_guardrail_concrete.png` (576 B)
- `indian_marker_destination.png` (188 B)
- `indian_marker_start.png` (187 B)
- `indian_road_asphalt_straight.png` (193 B)
- `indian_road_barricade_yellow_black.png` (215 B)
- `indian_road_highway_divider.png` (182 B)
- `indian_road_yellow_stripes.png` (183 B)
- `indian_roadside_auto_rickshaw.png` (291 B)
- `indian_roadside_dhaba_stall.png` (400 B)
- `indian_roadside_milestone_km.png` (199 B)
- `indian_roadside_tea_stall.png` (302 B)
- `tamil_nadu_chennai_destination_arch.png` (770 B)

### 3.2 Duplicate & Placeholder Landmark Usage
In `RouteRegistry.gd`, 5 of the 6 state routes are forced to reuse generic road props as their iconic historical landmarks:
- **Goa:**
  - *Calangute Beach* reuses `indian_roadside_coconut_tree.png`.
  - *Mandovi Bridge Toll* reuses `indian_checkpoint_toll_booth.png`.
  - *Old Goa Basilica of Bom Jesus* reuses `indian_roadside_tea_stall.png`.
- **Kerala:**
  - *Alleppey Backwaters* reuses `indian_roadside_coconut_tree.png`.
  - *Western Ghats Toll* reuses `indian_checkpoint_gate.png`.
  - *Munnar Tea Gardens* reuses `indian_roadside_banyan_tree.png`.
- **Rajasthan:**
  - *Amber Fort Gateway* reuses `indian_roadside_dhaba_stall.png`.
  - *Thar Expressway Toll* reuses `indian_checkpoint_gate.png`.
  - *Mehrangarh Fort Vista* reuses `indian_roadside_milestone_km.png`.
- **Gujarat:**
  - *Saurashtra Highway Dhaba* reuses `indian_roadside_dhaba_stall.png`.
  - *Kutch Border Gate* reuses `indian_checkpoint_gate.png`.
  - *Flamingo Sanctuary Pass* reuses `indian_roadside_milestone_km.png`.
- **Telangana:**
  - *Golconda Fort Bastion* reuses `indian_roadside_banyan_tree.png`.
  - *Outer Ring Road Toll* reuses `indian_checkpoint_gate.png`.
  - *Kakatiya Dynasty Torana* reuses `indian_roadside_milestone_km.png`.

### 3.3 Missing State Parallax Backgrounds
All 6 routes currently share only **2 backdrops**:
- `indian_sky_tropical.png` (applied to all 6 states)
- `indian_parallax_rural_plains.png` (applied to TN, Rajasthan, Gujarat, Telangana)
- `indian_parallax_western_ghats.png` (applied to Goa and Kerala)

**Missing distinct environments:**
- **Thar Desert Background:** Golden sand dunes, desert horizon, warm sunset gradient for Rajasthan.
- **Rann of Kutch White Salt Flats:** Crystalline white salt horizon with pale atmospheric haze for Gujarat.
- **Deccan Plateau Granite Formations:** Ancient boulder hills, rocky outcroppings, semi-arid plateau for Telangana.
- **Misty Western Ghats Tea Valley:** Multi-layered lush green tea-covered mountain terraces with cloud mist for Kerala.
- **Konkan Coastal Palms & Ocean:** Azure coastal sea horizon with palm fringes for Goa.

### 3.4 Missing Licensing & Provenance Records
None of the assets under `assets/indian_locations/` or `assets/indian_roads/` have explicit provenance URLs or individual license records in `docs/ASSET_LICENSES.md`. Every newly acquired asset must be thoroughly documented with Author, Source URL, License (CC0, CC BY, Public Domain), and Modifications.

---

## 4. Retained vs. Upgraded Asset Classification

### Assets to Retain
- `state_select_*.png` (All 6 state selection UI cards): Stylized, high-quality, perfectly suited for the cards container.
- `india_map_states.png` and `.svg`: Clean, accurate geographical outline of India with state boundaries.
- `tamil_nadu_thiruvalluvar_statue.png`: Clean cutout, excellent scale and recognizability.
- `tamil_nadu_kanyakumari_triveni_sangam.png`: High-resolution start banner.
- `tamil_nadu_vivekananda_rock_memorial.png`: Good secondary landmark asset.
- `indian_traffic_cone.png`: Acceptable stylized hazard prop.
- `indian_roadside_coconut_tree.png`: Clean tropical palm asset.

### Assets to Upgrade
1. **Road Surfaces & Textures:** Dark textured highway asphalt with aggregate grit, seamless horizontal tiling, and authentic red-brown/golden sand/laterite roadside shoulders.
2. **Roadside Props:** Detailed Auto-Rickshaw (with driver and yellow-green chassis), traditional wooden Highway Chai Stall, authentic Highway Dhaba with charpai cots, accurate stone Milestone pillars (with yellow/white top and green NH markers), and sturdy concrete guardrails.
3. **Checkpoints & Arches:** Professional Indian Toll Plaza structure with electronic toll collection (FASTag) signage, barrier arms, and a celebratory destination Finish Arch.
4. **State-Specific Parallax Backgrounds:** 5 distinct multi-layered seamless parallax sets (Thar Desert, White Rann, Deccan Plateau, Western Ghats Tea Mountains, Coastal Goa).
5. **Iconic Regional Landmarks:**
   - **Tamil Nadu:** Upgraded Meenakshi Temple gopuram, Chennai Marina Lighthouse.
   - **Goa:** Basilica of Bom Jesus, Calangute coastal beach shack.
   - **Kerala:** Alleppey Kettuvallam (Houseboat) & Chinese fishing net, Munnar tea plantation terraces.
   - **Rajasthan:** Amber Fort / Hawa Mahal facade, Jaisalmer Golden Fort.
   - **Gujarat:** Traditional stepwell / Kathiyawadi structure, White Rann monument.
   - **Telangana:** Charminar silhouette, Kakatiya Kala Thoranam (Warangal gate).

---

## 5. Architectural Non-Negotiables for Integration

1. **Draw-Based Highway Geometry Preserved:**  
   The road is dynamically generated via `IndianRoadTerrain.gd` using smoothstep curves, physical speed breakers, and collision polygons. Any new road textures must tile seamlessly along `draw_colored_polygon` or `draw_polyline` / `Line2D` textures without breaking vehicle tire friction or suspension geometry.
2. **Vehicle Grounding Safe:**  
   Vehicle spawn height `y = 335.0` and starting road apron $x = -1200.0$ must remain untouched so tires never clip underground.
3. **RouteRegistry Interface Kept Intact:**  
   `RouteData` properties (`state_id`, `state_name`, `start_city`, `destination_city`, `total_distance_m`, `waypoints`) and methods remain unchanged; only visual texture paths will be updated to point to high-fidelity assets.
