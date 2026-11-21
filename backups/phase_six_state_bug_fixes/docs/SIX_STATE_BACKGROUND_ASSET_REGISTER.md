# SIX-STATE BACKGROUND ASSET REGISTER
## Complete Inventory of Realistic Painted Background & Atmospheric Assets
**Author:** Joel (Lead Senior Godot Developer & Environment Artist)  
**Project:** Indian Roads Driving Experience (Godot 4.7)  
**Date:** November 17, 2026  

---

### 1. Common Atmospheric Cloud Assets

| Asset Name | Resolution | Format | Layer | Description | License |
|---|---|---|---|---|---|
| `cloud_cumulus_soft_01.png` | 1920x450 | PNG (RGBA32) | Layer 2 | Painterly wide cumulus bank with feathered radial alpha falloff, illuminated upper crests, and cool ambient bounce. | CC0 / Joel Original |
| `cloud_cumulus_soft_02.png` | 1920x450 | PNG (RGBA32) | Layer 2 | Low-altitude drifting cumulus bank with natural asymmetric puff density and soft edges. | CC0 / Joel Original |
| `cloud_cirrus_wispy.png` | 1920x350 | PNG (RGBA32) | Layer 2 | High-altitude wispy mares' tail cirrus brush streaks with soft gradient falloffs. | CC0 / Joel Original |
| `cloud_stratus_horizon.png` | 1920x250 | PNG (RGBA32) | Layer 2 | Soft horizontal horizon haze band simulating morning humidity and distance dissipation. | CC0 / Joel Original |

---

### 2. State-Specific Background Layers

#### A. Tamil Nadu (Route: Kanyakumari to Chennai)
- **Sky:** `res://assets/indian_locations/tamil_nadu/backgrounds/sky/kanyakumari_sky_coastal.png` (1920x720)  
  *Description:* Deep oceanic sapphire zenith blending through azure to warm morning amber horizon with diffused coastal sun glow.
- **Far Background:** `res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png` (1920x720)  
  *Description:* Cape Comorin headland cliffs, Triveni Sangam ocean swell, delicate wave ripples, and distant silhouettes of Vivekananda Rock Memorial and Thiruvalluvar pedestal.
- **Midground:** `res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_countryside_midground.png` (1920x720)  
  *Description:* Rolling emerald-and-golden paddy fields, blue irrigation canal ribbon, authentic curved-trunk palmyra palm clusters.

#### B. Goa (Route: Panaji to Margao)
- **Sky:** `res://assets/indian_locations/goa/backgrounds/sky/goa_tropical_sky.png` (1920x720)  
  *Description:* Warm cobalt blue tropical sky transitioning to golden-peach horizon with afternoon sun flare.
- **Far Background:** `res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png` (1920x720)  
  *Description:* Three-tier forested Western Ghats mountain ridges with morning valley mist bands.
- **Midground:** `res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_coastal_midground.png` (1920x720)  
  *Description:* Red laterite coastal bluffs, leaning coconut palms, and Portuguese-Goan colonial villas with mangalore-tiled pitched roofs.

#### C. Kerala (Route: Kochi to Munnar)
- **Sky:** `res://assets/indian_locations/kerala/backgrounds/sky/kerala_sky_monsoon.png` (1920x720)  
  *Description:* Slate-teal monsoon zenith fading into diffused silver-turquoise and humid mountain mist.
- **Far Background:** `res://assets/indian_locations/kerala/backgrounds/distant_landscape/kerala_western_ghats_peaks.png` (1920x720)  
  *Description:* Jagged Anamudi mountain peaks, flowing monsoon mist veils, and Athirappilly waterfall vapor streams.
- **Midground:** `res://assets/indian_locations/kerala/backgrounds/distant_landscape/kerala_backwater_canal_midground.png` (1920x720)  
  *Description:* Terraced Munnar tea plantation slopes with contour lines, traditional kettuvallam houseboats, and Chinese fishing nets.

#### D. Rajasthan (Route: Jaipur to Jaisalmer)
- **Sky:** `res://assets/indian_locations/rajasthan/backgrounds/sky/rajasthan_sky_desert_dawn.png` (1920x720)  
  *Description:* Twilight plum-indigo blending into desert dawn crimson, terracotta amber, and luminous gold with low desert sun.
- **Far Background:** `res://assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_thar_sand_dunes.png` (1920x720)  
  *Description:* Multi-tiered sweeping Thar golden sand dunes with wind-ripple shading, Jaisalmer fort ramparts, and camel caravan silhouettes.
- **Midground:** `res://assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_aravalli_hills_midground.png` (1920x720)  
  *Description:* Rugged Aravalli sandstone hills, havelis with carved jharokha balconies and chhatri domes, thorny khejri trees.

#### E. Gujarat (Route: Ahmedabad to Rann of Kutch)
- **Sky:** `res://assets/indian_locations/gujarat/backgrounds/sky/gujarat_sky_pale_azure.png` (1920x720)  
  *Description:* Crisp high-sky azure fading into pale shimmering white horizon.
- **Far Background:** `res://assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_great_rann_white_salt.png` (1920x720)  
  *Description:* Kalo Dungar distant hill contour, heat mirage shimmer, infinite crystalline white salt flats with salt polygon cracks, wading Greater Flamingos.
- **Midground:** `res://assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_saurashtra_savanna_midground.png` (1920x720)  
  *Description:* Dry savanna grasslands, umbrella thorn acacia trees, and traditional circular mud bhunga huts with conical thatched roofs.

#### F. Telangana (Route: Hyderabad to Warangal)
- **Sky:** `res://assets/indian_locations/telangana/backgrounds/sky/telangana_sky_deccan_twilight.png` (1920x720)  
  *Description:* Royal indigo zenith fading into violet dusk, warm Deccan terracotta, and golden amber horizon.
- **Far Background:** `res://assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_granite_boulder_ridges.png` (1920x720)  
  *Description:* Precambrian granite hill ridges with iconic balancing boulders, monolith tors, and Golconda Fort stone bastions.
- **Midground:** `res://assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_plateau_countryside_midground.png` (1920x720)  
  *Description:* Undulating granite plateau, flowering scarlet gulmohar trees, rocky Deccan lakes, and Kakatiya Kirti Toranas (stone archways).

---

### 3. Fallback & Shared Assets Synchronized

- `res://assets/indian_roads/visual_upgrade_v2/indian_sky_tropical.png` -> Updated from Tamil Nadu Sky
- `res://assets/indian_roads/visual_upgrade_v2/indian_parallax_tamil_nadu_coast.png` -> Updated from Tamil Nadu Ocean
- `res://assets/indian_roads/indian_parallax_thar_desert.png` -> Updated from Rajasthan Thar Dunes
- `res://assets/indian_roads/indian_parallax_rann_kutch.png` -> Updated from Gujarat Rann Salt Flats
- `res://assets/indian_roads/indian_parallax_deccan_plateau.png` -> Updated from Telangana Granite Tors
- `res://assets/indian_roads/indian_parallax_tamil_nadu_coast.png` -> Updated from Tamil Nadu Ocean
- `res://assets/indian_roads/indian_parallax_rural_plains.png` -> Updated from Tamil Nadu Midground Paddy
