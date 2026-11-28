# KANYAKUMARI HILL CLIMB — ASSET LIST

This document provides the complete register of all graphical assets generated for **KANYAKUMARI HILL CLIMB**, matching the reference painted visual style (`reference_image.png`).

All assets are located under `res://art/`. No primitives (boxes, circles, triangles) are used in gameplay visuals.

---

## 1. Parallax Background Layers (`res://art/parallax/`)

| Filename | Dimensions | Type | Mirroring ($x$) | Description & Visual Target |
| :--- | :--- | :--- | :--- | :--- |
| `sky_seamless.png` | 2048 x 1080 | Seamless PNG | 2048 | Painted cyan-to-azure sky gradient with soft horizon haze. Zero vertical seams. |
| `clouds_seamless.png` | 2048 x 1080 | Transparent PNG | 2048 | Soft, fluffy cumulus clouds with gentle blue-grey underbelly shading. Horizontally seamless. |
| `sea_seamless.png` | 2048 x 1080 | Transparent PNG | 2048 | Deep royal blue & turquoise Indian Ocean with sparkling wave crest ripples. |
| `islands_vivekananda.png` | 2048 x 1080 | Transparent PNG | 2048 | Vivekananda Rock Memorial mandapam & Thiruvalluvar Statue on rocky pedestals with fishing boats. |
| `town_coastal.png` | 2048 x 512 | Transparent PNG | 2048 | Colourful coastal houses (terracotta, yellow, mint, pastel blue) interspersed with coconut palms. |
| `lighthouse.png` | 512 x 512 | Transparent PNG | N/A (Prop) | Red-and-white banded coastal lighthouse with lantern room and rocky base. |

---

## 2. Terrain & Cliff Cross-Section (`res://art/terrain/`)

| Filename | Dimensions | Type | Usage | Description |
| :--- | :--- | :--- | :--- | :--- |
| `cliff_rock_tile.png` | 512 x 512 | Seamless PNG | Polygon2D Texture | Layered sedimentary rock cross-section (ochre, brown, slate grey) with dark gradient at bottom. |
| `road_asphalt_pattern.png` | 256 x 64 | Seamless PNG | Line2D / Strip | Dark slate asphalt highway with crisp white edge barrier and golden yellow dashed center line. |
| `grass_tuft.png` | 128 x 64 | Transparent PNG | Decorative Edge Scatter | Coastal green grass blades and shrubs scattered along the upper road curb. |

---

## 3. Roadside Props (`res://art/props/`)

| Filename | Dimensions | Format | Description |
| :--- | :--- | :--- | :--- |
| `tea_shop.png` | 320 x 240 | Transparent PNG | Traditional South Indian tea stall ("Chai Kadai") with blue corrugated roof, brass samovar, flag. |
| `lamp_post.png` | 120 x 360 | Transparent PNG | Curved steel highway light post with concrete base and luminaire head. |
| `bollard.png` | 60 x 140 | Transparent PNG | Cylindrical concrete roadside milestone with high-contrast yellow-and-black hazard stripes. |
| `coconut_palm.png` | 260 x 420 | Transparent PNG | Tall curving coastal palm tree with coconut cluster and drooping green fronds. |
| `stone_wall.png` | 320 x 120 | Transparent PNG | Weathered granite masonry retaining wall along coastal curves. |
| `sign_kanyakumari.png` | 360 x 220 | Transparent PNG | Green national highway milestone board with bilingual English and Tamil text: "KANYAKUMARI / கன்னியாகுமரி". |

---

## 4. Vehicle Bodies and Wheels (`res://art/vehicles/`)

| Filename | Dimensions | Format | Vehicle | Description |
| :--- | :--- | :--- | :--- | :--- |
| `jeep_body.png` | 320 x 160 | Transparent PNG | Red Jeep | Classic red 4x4 open-top Jeep chassis with roll bar, front bumper, headlights, spare tire. |
| `jeep_wheel.png` | 96 x 96 | Transparent PNG | Red Jeep | Heavy-duty rubber off-road tire with 5-spoke silver alloy rim. |
| `driver.png` | 90 x 110 | Transparent PNG | Shared | Visible driver with red cap, sunglasses, blue shirt, hands on steering wheel. |
| `rickshaw_body.png` | 300 x 180 | Transparent PNG | Auto Rickshaw | Iconic yellow and emerald green 3-wheeler body with open cabin. |
| `rickshaw_wheel.png` | 80 x 80 | Transparent PNG | Auto Rickshaw | Compact scooter/rickshaw steel rim wheel. |
| `tractor_body.png` | 340 x 200 | Transparent PNG | Tractor | Agricultural tractor body with green engine cowl and vertical exhaust stack. |
| `tractor_wheel_rear.png` | 130 x 130 | Transparent PNG | Tractor | Giant rear tractor tire with aggressive mud lugs and yellow rim. |
| `tractor_wheel_front.png`| 75 x 75 | Transparent PNG | Tractor | Smaller front steering tire with yellow rim. |
| `mini_truck_body.png` | 360 x 170 | Transparent PNG | Mini Truck | Commercial pickup cab with open blue cargo bed. |
| `truck_wheel.png` | 90 x 90 | Transparent PNG | Mini Truck | Heavy-duty steel commercial rim wheel. |
| `rally_jeep_body.png` | 330 x 150 | Transparent PNG | Rally Jeep | Tuned aerodynamic off-road racing truck with orange paint and spoiler. |
| `rally_wheel.png` | 96 x 96 | Transparent PNG | Rally Jeep | Gold-beadlock high-speed rally racing tire. |

---

## 5. Pickups & Collectibles (`res://art/pickups/`)

| Filename | Dimensions | Format | Description |
| :--- | :--- | :--- | :--- |
| `coin_star.png` | 80 x 80 | Transparent PNG | Gleaming 5-pointed gold star coin floating along highway hill crests. |
| `fuel_can.png` | 90 x 110 | Transparent PNG | Red steel jerrycan with yellow FUEL text, carry handle, and filler cap. |

---

## 6. HUD & On-Screen Mobile Controls (`res://art/ui/`)

| Filename | Dimensions | Format | Description |
| :--- | :--- | :--- | :--- |
| `pedal_brake.png` | 160 x 200 | Transparent PNG | Bottom-left heavy grey rubber brake pedal with horizontal traction treads. |
| `pedal_gas.png` | 140 x 260 | Transparent PNG | Bottom-right tall ergonomic grey rubber accelerator pedal with vertical grip ribs. |
| `gauge_dial.png` | 200 x 200 | Transparent PNG | Bottom-center analog fuel gauge face with chrome bezel and E (Red) / F (Green) markings. |
| `gauge_needle.png` | 30 x 110 | Transparent PNG | Bright red analog meter needle rotating around pivot center. |
| `nitro_button.png` | 120 x 120 | Transparent PNG | Cyan/blue circular nitro boost button with flame insignia. |
| `pause_button.png` | 90 x 90 | Transparent PNG | Round top-right pause button with clean white pause bars. |
| `fuel_icon.png` | 64 x 64 | Transparent PNG | Top-left fuel jerrycan symbol for horizontal HUD bar. |
| `coin_pill.png` | 220 x 70 | Transparent PNG | Translucent pill container background for coin counter. |

---

## 7. Visual Effects (`res://art/fx/`)

| Filename | Dimensions | Format | Description |
| :--- | :--- | :--- | :--- |
| `dust_puff.png` | 64 x 64 | Transparent PNG | Soft radial dust particle kicked up by tires. |
| `nitro_flame.png` | 96 x 96 | Transparent PNG | Glowing cyan and orange rocket boost particle. |
| `spark.png` | 48 x 48 | Transparent PNG | Golden-orange collision and landing impact spark. |
