# Indian Roads Asset Placement & Technical Environment Guide

**Author:** Joel (Senior Godot 4.7 Architect, 2D Environment Artist)  
**Date:** November 14, 2026  
**Document:** `docs/INDIAN_ROADS_ASSET_PLACEMENT_GUIDE.md`  
**Target Engine:** Godot Engine 4.7 (Compatibility & Forward+ 2D)

---

## 1. Overview & Parallax Layer Architecture

To prevent the visual defect of flat rectangular wallpapers and floating props, the Indian Roads mode utilizes a multi-tiered 2D world layout structured across 10 distinct depth planes:

```
[FAR DEPTH] -----------------------------------------------------> [NEAR DEPTH]
Layer 1       Layer 2       Layer 3        Layer 4         Layer 5-7      Layer 8-10
Coastal Sky   Distant Ghats Ocean Horizon  Village/Houseline Props/Landmarks Road & Vehicle
(Scale: 0.04) (Scale: 0.12) (Scale: 0.22)  (Scale: 0.38)   (Scale: 1.0)   (Phys & Camera)
```

### Depth & Parallax Motion Configuration Table

| Layer # | Node Name | Parallax `motion_scale` | `motion_mirroring` | Z-Index | Visual Contents & Role |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | `SkyLayer` | `Vector2(0.04, 0.0)` | `Vector2(1920, 0)` | -100 | Sky gradient, soft cumulus clouds, warm morning sun |
| **2** | `DistantGhatsLayer`| `Vector2(0.12, 0.0)` | `Vector2(1920, 0)` | -80 | Deep emerald Western Ghats mountain silhouettes (0% snow) |
| **3** | `HorizonLayer` | `Vector2(0.22, 0.0)` | `Vector2(1920, 0)` | -60 | Ocean waterline, sea foam, offshore granitic rock stacks |
| **4** | `VillageLayer` | `Vector2(0.38, 0.0)` | `Vector2(1920, 0)` | -40 | Terracotta tiled village homes, palm tree crowns, chapels |
| **5** | `Landmarks` | `Vector2(1.0, 1.0)` (World) | None (Single spawn)| -10 | Major cultural monuments (Thiruvalluvar, Meenakshi, Forts) |
| **6** | `RoadsideProps`| `Vector2(1.0, 1.0)` (World) | None (Procedural) | -5 | Tea stalls, coconut trees, auto-rickshaws, highway signs |
| **7** | `RoadSurface` | `Vector2(1.0, 1.0)` (World) | Chunked 2D Mesh | 0 | Multi-tiered asphalt, reflective yellow stripes, laterite shoulder |
| **8** | `Vehicle` | `Vector2(1.0, 1.0)` (World) | Dynamic RigidBody | +10 | Player vehicle (Blue Flame Truck, Super Jeep, etc.) |
| **9** | `ForegroundFoliage`| `Vector2(1.15, 0.0)` | Dynamic / Chunked | +20 | Occasional foreground grass blurs, road barriers, milestone posts |
| **10**| `CanvasLayer (HUD)`| Viewport Fixed | None | +100 | Speedometer, milestone progress, distance odometer, coin counter |

---

## 2. Sprite Scaling, Proportion & Perspective Matrix

To ensure realistic scale relative to the player vehicle (nominal vehicle dimensions: `160 × 75 px`):

| Asset Category | Target World Height | In-Game Scale (`scale`) | Vertical Offset (`position.y`) | Placement Rule |
| :--- | :--- | :--- | :--- | :--- |
| **Major Monuments** (e.g. Thiruvalluvar, Meenakshi) | `380 – 480 px` | `0.30 – 0.45` | `-180 px` above road | Placed in background (`z_index = -10`) behind driving line. Never occludes vehicle! |
| **Medium Landmarks** (e.g. Glass Bridge, Forts) | `260 – 340 px` | `0.40 – 0.55` | `-140 px` above road | Placed behind road shoulder with 60px clearance. |
| **Village Props** (Dhaba stall, Tea stall) | `110 – 140 px` | `0.65 – 0.85` | `-55 px` above road | Sits directly on road shoulder gravel (`z_index = -5`). |
| **Flora: Coconut Palms** | `260 – 320 px` | `0.70 – 0.90` | `-120 px` above road | Curved trunks root into earth shoulder; fronds arch above camera. |
| **Flora: Banyan Trees** | `220 – 280 px` | `0.60 – 0.80` | `-100 px` above road | Broad canopy provides shade without obscuring road surface. |
| **Highway Signs (NH44, Speed)** | `100 – 130 px` | `0.60 – 0.75` | `-55 px` above road | Placed 80–120m in advance of upcoming checkpoints. |
| **Waypoint Milestone Posts** | `50 – 70 px` | `0.50 – 0.65` | `-25 px` above road | Yellow/white concrete milestone markers placed every 250m. |

---

## 3. Road Clearance & Non-Occlusion Guarantees

1. **Driving Line Integrity:**
   - The asphalt surface plane is rendered at road level (`road_points[i].y`).
   - All monument sprites (`MonumentSprite` on `IndianLandmarkV2`) are anchored with bottom plinths at `Vector2(0, -60)`, ensuring the monument base sits naturally behind the highway shoulder.
2. **Decoupled Milestone Signboards:**
   - Signboards on waypoints are positioned with a lateral offset of `Vector2(-130, -55)`.
   - This ensures the milestone title and distance announcement are immediately readable to the driver without overlapping the monument artwork or player vehicle.
3. **Collision Safety:**
   - Landmark and checkpoint nodes use `Area2D` triggers strictly for detection (`monitoring = true`, `monitorable = false`).
   - No landmark sprite has solid physics collision (`CollisionShape2D` on layer 1 is prohibited for scenery) preventing vehicle stopping or physics jams.

---

## 4. Regional Highway Biome Themes

### A. Tamil Nadu Coastal & Plains Highway
- **Asphalt Color:** `Color(0.18, 0.20, 0.23)` (Dark weathered asphalt)
- **Shoulder Color:** `Color(0.65, 0.44, 0.28)` (South Indian red laterite earth)
- **Stripe Color:** `Color(0.98, 0.85, 0.15)` (Reflective highway yellow)
- **Flora Density:** 0.65 (Predominantly coconut palms, palmyra trees, and neem bushes).

### B. Goa Tropical Highway
- **Asphalt Color:** `Color(0.22, 0.23, 0.26)`
- **Shoulder Color:** `Color(0.85, 0.75, 0.50)` (Warm golden coastal sand & laterite grit)
- **Stripe Color:** `Color(1.0, 1.0, 1.0)` (Crisp white coastal markings)
- **Flora Density:** 0.80 (Dense areca palms, cashew trees, tropical roadside shrubbery).

### C. Kerala Western Ghats Highway
- **Asphalt Color:** `Color(0.16, 0.18, 0.20)` (Rain-washed dark tarmac)
- **Shoulder Color:** `Color(0.45, 0.30, 0.16)` (Humus-rich dark forest soil)
- **Stripe Color:** `Color(0.98, 0.85, 0.15)`
- **Flora Density:** 0.90 (Lush tea plantations, bamboo groves, silver oak shade trees).

### D. Rajasthan Thar Desert Highway
- **Asphalt Color:** `Color(0.26, 0.27, 0.28)` (Sun-bleached highway)
- **Shoulder Color:** `Color(0.86, 0.72, 0.44)` (Fine golden Thar sand)
- **Stripe Color:** `Color(0.95, 0.80, 0.15)`
- **Flora Density:** 0.25 (Sparse desert acacia, thorny scrub, stone milestones).
