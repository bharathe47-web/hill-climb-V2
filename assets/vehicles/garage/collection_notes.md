# Garage Vehicle Asset Collection Notes

**Role:** Garage vehicle asset collector (Nagatheran)
**Target Folder:** `assets/vehicles/garage/`
**Reviewer:** Bharath (Core / Garage lead)
**Status:** Ready for Bharath's review
**Total Vehicles Collected:** 25 (100% Vector / High-Resolution — Zero Pixel Art)

---

## 1. Overview

This collection provides a comprehensive library of **25 vehicles** for the **My Cars (Garage)** feature.
Per the updated design requirements:
- **Pixel art assets have been completely removed** and replaced with crisp, high-resolution vector illustrations.
- **Cycles / Bicycles** are now represented by clean vector models (modern road bicycle, mountain sport bicycle, and a classic high-wheel penny-farthing roadster).
- **Every vehicle is pre-separated** into independent `body.png` and `wheel.png` sprites for Godot wheel rotation, suspension physics, and custom tire modifications.
- **Direction & Perspective:** All 25 vehicles face to the **right** in pure 2D side-view.

---

## 2. Complete Vehicle Roster (25 Vector Vehicles)

| Asset ID | Vehicle Name / Class | Full Sprite | Separated Body (`body.png`) | Separated Wheel (`wheel.png`) | Source / Creator | License |
|---|---|---|---|---|---|---|
| `car_01` | Cartoon Red Hatchback (Starter) | 471 × 319 | 470 × 259 | 105 × 105 | Itch.io / overcrafted | Free Game License |
| `car_02` | Mini Compact City Car | 558 × 351 | 558 × 327 | 123 × 126 | Itch.io / overcrafted | Free Game License |
| `car_03` | Off-Road Racing Pickup (Dodge Ram style) | 691 × 257 | 691 × 194 | 120 × 119 | Itch.io / overcrafted | Free Game License |
| `car_04` | SWAT Armored Heavy Van | 1791 × 939 | 1791 × 800 | 282 × 282 | Itch.io / overcrafted | Free Game License |
| `car_05` | School Bus (Long Chassis) | 954 × 265 | 950 × 222 | 85 × 86 | Itch.io / overcrafted | Free Game License |
| `car_06` | Ice Cream Van (Novelty) | 870 × 1059 | 830 × 973 | 217 × 211 | Itch.io / overcrafted | Free Game License |
| `car_07` | **Cartoon Emergency Ambulance** | 740 × 336 | 740 × 336 | 84 × 84 | OpenGameArt / MedicineStorm | CC0 1.0 (Public Domain) |
| `car_08` | **Bigfoot 4x4 Heavy Monster Truck** | 2258 × 1310 | 2258 × 1310 | 630 × 610 | OpenGameArt / Snabisch | CC0 1.0 (Public Domain) |
| `car_09` | **Mustang GT Widebody Boost Mod Beast** | 2390 × 738 | 2391 × 632 | 371 × 371 | Itch.io / overcrafted | Free Game License |
| `car_10` | **Combat Armored Humvee with Turret** | 759 × 433 | 759 × 376 | 171 × 170 | Itch.io / overcrafted | Free Game License |
| `car_11` | **HillClimb 4x4 Monster Beast Trucker** | 642 × 499 | 641 × 399 | 241 × 240 | OpenGameArt / pzUH | CC0 1.0 (Public Domain) |
| `car_12` | **Modern Road / City Commuter Bicycle (Cycle)** | 738 × 581 | 293 × 451 | 154 × 154 | Wikimedia / Amada44 | Public Domain |
| `car_13` | **Sport / Mountain Trail Bicycle (Cycle)** | 1000 × 639 | 924 × 583 | 320 × 320 | Wikimedia / OpenClipart | CC0 1.0 (Public Domain) |
| `car_14` | **Super Sport Racing Superbike** | 855 × 477 | 796 × 422 | 256 × 255 | Itch.io / overcrafted | Free Game License |
| `car_15` | **Custom Chopper Beast Motorcycle** | 996 × 455 | 972 × 396 | 265 × 266 | Itch.io / overcrafted | Free Game License |
| `car_16` | **Off-Road Motocross Dirt Bike** | 787 × 474 | 721 × 367 | 275 × 277 | Itch.io / overcrafted | Free Game License |
| `car_17` | **Streetfighter Naked Performance Bike** | 887 × 498 | 839 × 421 | 255 × 257 | Itch.io / overcrafted | Free Game License |
| `car_18` | **Convertible Roadster Open-Top Mini** | 560 × 274 | 560 × 250 | 123 × 126 | Itch.io / overcrafted | Free Game License |
| `car_19` | **Off-Road Spiked Beast Buggy** | 636 × 300 | 636 × 220 | 187 × 187 | OpenGameArt / pzUH | CC0 1.0 (Public Domain) |
| `car_20` | **Classic Blown Hotrod Coupe** | 599 × 263 | 599 × 209 | 118 × 119 | OpenGameArt / pzUH | CC0 1.0 (Public Domain) |
| `car_21` | **Enduro Adventure Dual-Sport Bike** | 793 × 486 | 716 × 410 | 228 × 228 | Itch.io / overcrafted | Free Game License |
| `car_22` | **Heavy 4x4 Off-Road Monster Truck** | 400 × 243 | 400 × 144 | 200 × 199 | OpenGameArt / Bonsaiheldin | CC0 1.0 (Public Domain) |
| `car_23` | **Antique High-Wheel Roadster Cycle (Penny-Farthing)** | 1200 × 1115 | 834 × 1100 | 650 × 850 | Wikimedia / Public Domain | Public Domain |
| `car_24` | **Highway Touring Cruiser Motorcycle** | 879 × 578 | 854 × 511 | 217 × 216 | Itch.io / overcrafted | Free Game License |
| `car_25` | **Urban City Commuter Motorcycle** | 899 × 396 | 841 × 348 | 241 × 240 | Itch.io / overcrafted | Free Game License |

---

## 3. Vehicle Categories & Feature Breakdown

### A. Cycles / Bicycles (`car_12`, `car_13`, `car_23`)
- **`car_12` (Modern Road Bicycle):** High-res vector diamond frame with circular road wheels.
- **`car_13` (Sport Mountain Bicycle):** Heavy trail frame with wide off-road bicycle tires.
- **`car_23` (Antique High-Wheel Penny-Farthing):** Iconic antique high-wheel bicycle featuring an oversized front wheel and high saddle. Extremely distinctive novelty vehicle for gameplay challenges.

### B. Motorcycles (`car_14` – `car_17`, `car_21`, `car_24`, `car_25`)
- Full spectrum of 2-wheelers: Super Sport, Custom Chopper, Motocross Dirt Bike, Streetfighter Naked, Enduro Adventure, Touring Cruiser, and City Commuter.

### C. Monster Trucks & Beast Vehicles (`car_08`, `car_10`, `car_11`, `car_19`, `car_22`)
- Bigfoot 4x4 Monster Truck, Bonsaiheldin Heavy Monster Truck, HillClimb Monster Trucker, Spiked Off-Road Buggy, and Armored Humvee with Gun Turret.

### D. Boost Mod & Attractive Road Cars (`car_01` – `car_07`, `car_09`, `car_18`, `car_20`)
- Mustang GT Widebody Boost Mod, Open-Top Convertible Mini Roadster, Blown Hotrod Coupe, Cartoon Ambulance, SWAT Van, School Bus, Ice Cream Van, and Cartoon Hatchback.

---

## 4. Technical Quality Standards

- **100% Vector Quality:** Crisp outlines with zero low-res pixelation.
- **Independent Body & Wheels:** Pre-split `body.png` and `wheel.png` in every folder for seamless integration into Godot physics scenes.
- **Consistent Orientation:** Every vehicle faces **right**.
- **Confirmed Commercial Licensing:** All assets are either CC0 Public Domain or Creator-granted Free Game Asset licenses.
