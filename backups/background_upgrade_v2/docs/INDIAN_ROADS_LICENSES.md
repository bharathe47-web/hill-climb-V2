# Indian Roads Mode — Asset Licenses & Provenance Register

**Project:** Hill Climb 2D — Indian Roads Mode  
**Document Owner:** Joel (Lead Indian Roads Specialist & Art Director)  
**Date:** 2026-11-13  
**Status:** Stage 4 License Verification Completed  

---

## 1. Compliance Policy & Verification Standard

In strict accordance with project requirements, every asset evaluated, downloaded, and staged for the Indian Roads mode adheres to the following criteria:
1. **Commercially Compatible:** CC0 1.0 (Public Domain), CC BY 3.0 / 4.0, or CC BY-SA 3.0 / 4.0.
2. **Zero Non-Commercial Restrictions:** No CC-NC or Non-Commercial clauses.
3. **Zero Watermarks / Editorial Limitations:** Only clean, high-resolution original works without stock photo watermarks or editorial-only tags.
4. **Verified Author & Origin:** Direct provenance traced back to primary repositories (Kenney, OpenGameArt, Wikimedia Commons, Natural Earth).

---

## 2. Representative Sample Assets (Stage 3 & 4)

The table below lists the 5 representative sample assets currently staged under `assets/samples/indian_roads/`:

| Item Category | Sample Asset Filename | Dimensions & Format | Source Repository & URL | Original Author | License Type | Commercial Use | Modification Summary |
|---|---|---|---|---|---|---|---|
| **1. Road Texture** | `sample_road_asphalt_dark.png` | 1024x1024 PNG (831 KB) | [OpenGameArt: Asphalt Texture](https://opengameart.org/content/asphalt) | `p0ss` | **CC0 1.0 Universal** (Public Domain) | Permitted (No attribution required) | Staged directly; seamless horizontal aggregate pattern for procedural terrain mapping. |
| **2. Tamil Nadu Landmark** | `sample_thiruvalluvar_statue.png` | 529x720 Transparent PNG (384 KB) | [Wikimedia Commons: Thiruvalluvar Statue 02](https://commons.wikimedia.org/wiki/File:Thiruvalluvar_Statue_at_Kanyakumari_02.jpg) | Darisi sumanth | **CC BY-SA 3.0** | Permitted with attribution | Isolated background sky, keyed to alpha transparency, enhanced stone contrast for 2D side-view camera. |
| **3. Roadside Prop** | `sample_auto_rickshaw_prop.png` | 649x468 Transparent PNG (65 KB) | [Wikimedia Commons: Auto Rickshaw Symbol](https://commons.wikimedia.org/wiki/File:Auto_Rickshaw_Election_Symbol.svg) | Election Commission / Wikimedia contributors | **CC BY-SA 3.0** | Permitted with attribution | Rendered crisp SVG paths to transparent PNG with transparent cab interior for roadside prop placement. |
| **4. Parallax Background** | `mountain_full_background1.png` (+ layers: `sky_Background.png`, `LargeMountain.png`, `clouds.png`) | 1280x720 PNG (188 KB total) | [OpenGameArt: Parallax Mountain Background](https://opengameart.org/content/parallax-mountain-background) | GrumpyDiamond | **CC BY 3.0** | Permitted with attribution | Extracted multi-layer parallax pack matching native 1280x720 viewport resolution for Western Ghats / Kerala / Goa. |
| **5. State Map** | `sample_tamil_nadu_locator_map.svg` & `sample_tamil_nadu_map_card.png` | 1591x1975 SVG (223 KB) / 600x745 PNG (259 KB) | [Wikimedia Commons: Tamil Nadu Locator Map](https://commons.wikimedia.org/wiki/File:Tamil_Nadu_locator_map.svg) | PlaneMad (Arun) | **CC BY-SA 3.0** | Permitted with attribution | Dedicated Tamil Nadu regional boundary map; replaced 2.51 MB full-India bloated map; 91% file size reduction. |

---

## 3. License Texts & Attributions

### 3.1 Creative Commons Zero 1.0 (CC0)
- **Applicable Assets:** `sample_road_asphalt_dark.png`
- **Notice:** To the extent possible under law, the authors have dedicated all copyright and related and neighboring rights to this asset to the public domain worldwide. This work is published from the United States.

### 3.2 Creative Commons Attribution 3.0 Unported (CC BY 3.0)
- **Applicable Assets:** `parallax_western_ghats/` (`mountain_full_background1.png`, `sky_Background.png`, `LargeMountain.png`, `smallMountain.png`, `clouds.png`, `sun.png`)
- **Attribution Notice:** Parallax Mountain Background by GrumpyDiamond (https://opengameart.org/users/grumpydiamond), licensed under CC BY 3.0.

### 3.3 Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
- **Applicable Assets:**
  - `sample_thiruvalluvar_statue.png` (Source: Darisi sumanth via Wikimedia Commons, licensed under CC BY-SA 3.0).
  - `sample_auto_rickshaw_prop.png` (Source: Wikimedia Commons, licensed under CC BY-SA 3.0).
  - `sample_tamil_nadu_locator_map.svg` / `sample_tamil_nadu_map_card.png` (Source: PlaneMad via Wikimedia Commons, licensed under CC BY-SA 3.0).

---

## 4. Verification Checksum & Test Status

- **Engine Validation:** Tested in Godot 4.7 headless (`tests/test_sample_assets.gd`). All 5 assets loaded and rasterized cleanly into engine memory.
- **Engine Texture Types:**
  - Road Texture: `CompressedTexture2D` / `ImageTexture` (1024x1024)
  - Landmark Sprite: `CompressedTexture2D` (529x720 RGBA8)
  - Prop Sprite: `CompressedTexture2D` (649x468 RGBA8)
  - Parallax Sky & Mountains: `CompressedTexture2D` (1280x720 RGBA8)
  - State Map Vector/Card: `CompressedTexture2D` (SVG & 600x745 PNG)
- **Project Test Status:** 16/16 test suites PASSED with 0 errors.
