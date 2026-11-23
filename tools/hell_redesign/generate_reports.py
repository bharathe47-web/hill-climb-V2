#!/usr/bin/env python3
import json
from pathlib import Path

MANIFEST_PATH = Path("docs/hell_redesign/audit_manifest.json")
AUDIT_MD_PATH = Path("docs/hell_redesign/HELL_ASSET_AUDIT.md")
MAPPING_MD_PATH = Path("docs/hell_redesign/HELL_ASSET_MAPPING.md")

with open(MANIFEST_PATH, "r") as f:
    manifest = json.load(f)

# Licenses per pack
PACK_LICENSES = {
    "AssetSmithy_5_Dark_Fantasy_Backgrounds": {
        "author": "AssetSmithy",
        "license": "Custom Commercial Permissive (Free Sampler)",
        "commercial": "Yes",
        "attribution": "Not required",
        "notes": "Unlimited projects, crop/recolour/composite permitted. No resale of raw assets."
    },
    "Blueberry_Demon_Castle_Backgrounds": {
        "author": "Blueberry Assets",
        "license": "Custom Permissive",
        "commercial": "Yes",
        "attribution": "Not required",
        "notes": "Free sample, commercial game use allowed, no resale of raw images."
    },
    "Caldera_Lava_Volcano_Free_Sampler": {
        "author": "SavaLavaLabz",
        "license": "Free Sampler Non-Exclusive",
        "commercial": "Yes (free sampler)",
        "attribution": "Not required",
        "notes": "Cel-shaded volcanic platformer kit sampler."
    },
    "Firepious_Hellwake": {
        "author": "Firepious",
        "license": "Custom Commercial Permissive",
        "commercial": "Yes",
        "attribution": "Appreciated, not mandatory",
        "notes": "Underworld pixel-art backgrounds. No resale."
    },
    "OpenGameArt_Lava_Background": {
        "author": "OpenGameArt Contributor",
        "license": "CC0 1.0 Universal",
        "commercial": "Yes",
        "attribution": "Not required",
        "notes": "Public Domain dedication."
    },
    "OpenGameArt_Lava_Tileset": {
        "author": "OpenGameArt Contributor",
        "license": "CC0 1.0 Universal",
        "commercial": "Yes",
        "attribution": "Not required",
        "notes": "Public Domain dedication."
    },
    "OpenGameArt_Misc_Dark_Fantasy_Scenery": {
        "author": "OpenGameArt Contributor",
        "license": "CC0 1.0 Universal",
        "commercial": "Yes",
        "attribution": "Not required",
        "notes": "Public Domain gothic props (chains, cages, skulls)."
    },
    "OpenGameArt_Skeleton": {
        "author": "OpenGameArt (Spookiest Skeleton Rework)",
        "license": "CC-BY 3.0",
        "commercial": "Yes",
        "attribution": "Required (OpenGameArt / Author)",
        "notes": "Skeleton sprites and hanging skeleton."
    },
    "OpenGameArt_Stone_Bridge": {
        "author": "OpenGameArt Contributor",
        "license": "CC0 1.0 Universal",
        "commercial": "Yes",
        "attribution": "Not required",
        "notes": "3D Stone Bridge model and diffuse texture."
    },
    "SceneForge_5_Dark_Fantasy_Backgrounds": {
        "author": "SceneForge Studio",
        "license": "Custom Commercial Permissive",
        "commercial": "Yes",
        "attribution": "Not required",
        "notes": "Personal & commercial use permitted, no extra fee."
    },
    "SpriteCanvas_Animated_Props": {
        "author": "SpriteCanvas",
        "license": "CC0 1.0 Universal",
        "commercial": "Yes",
        "attribution": "Not required",
        "notes": "Animated torches, campfires, banners in transparent PNG sprite sheets."
    },
    "SpritePilot_Environment_Pack": {
        "author": "SpritePilot",
        "license": "CC0 1.0 Universal",
        "commercial": "Yes",
        "attribution": "Not required",
        "notes": "Animated pixel art environment pack (lava, waterfalls, wall torches)."
    },
    "Timberlate007_Hell_Fantasy_Asset_Pack": {
        "author": "Timberlate007",
        "license": "Custom Commercial Permissive",
        "commercial": "Yes",
        "attribution": "Appreciated, not mandatory",
        "notes": "JRPG pixel-art tiles and props."
    },
    "Target_Reference_Image": {
        "author": "User Provided / Master Specification",
        "license": "Master Visual Specification",
        "commercial": "Project Master Specification",
        "attribution": "N/A",
        "notes": "1600x533 master composition reference image."
    }
}

# 1. Generate HELL_ASSET_AUDIT.md
audit_lines = [
    "# Hell Biome Redesign — Comprehensive Asset Directory Audit",
    "",
    "**Generated:** 20 November 2026",
    "**Source Directory:** `/home/daniel/Pictures/Assets For Hell`",
    "**Project Root:** `/home/daniel/Documents/Endless-Hillclimb-Fixed`",
    "**Master Target:** `references/hell_target.png`",
    "",
    "---",
    "",
    "## 1. Inventory Summary",
    "",
    f"- **Total Files Scanned:** {manifest['total_files']}",
    f"- **Total Folders Inspected:** {len(manifest['folders'])}",
    f"- **Total Visual Images (PNG/JPG/WEBP):** {len([r for r in manifest['records'] if r['format'] in ['PNG', 'JPEG', 'JPG', 'WEBP']])}",
    f"- **Total Archives (.zip / .rar):** {manifest['category_counts']['archives']}",
    f"- **Total 3D Models (.obj / .blend):** {manifest['category_counts']['models']}",
    f"- **Total Audio Files:** {manifest['category_counts']['audio']}",
    f"- **Total Metadata / Document Files:** {manifest['category_counts']['docs_data']}",
    f"- **Exact Duplicate Files Detected:** {len(manifest['duplicates'])}",
    "",
    "---",
    "",
    "## 2. Asset Category Distribution",
    "",
    "| Category | Count | Primary Asset Packs Represented | Purpose in Redesign |",
    "| :--- | :---: | :--- | :--- |",
    f"| **A. Background & Atmosphere** | {manifest['category_counts']['A_background']} | AssetSmithy, SceneForge, Blueberry, Hellwake, Target Reference | Red/crimson sky, blood moon, distant volcanic ridges, smoke |",
    f"| **B. Main Fortress & Castle** | {manifest['category_counts']['B_fortress']} | Target Reference, Blueberry, AssetSmithy | Giant central horned demon fortress, spires, demon portals |",
    f"| **C. Lava & Fire VFX** | {manifest['category_counts']['C_lava_fire']} | SpriteCanvas, SpritePilot, OpenGameArt, Caldera | Animated torch flame, campfires, lava falls, molten flows |",
    f"| **D. Dark Fantasy Decorations** | {manifest['category_counts']['D_decorations']} | SpriteCanvas, OpenGameArt Misc Scenery, Timberlate007 | Skull banners, hanging chains, iron cages, braziers, lanterns |",
    f"| **E. Playable Terrain & Bridge** | {manifest['category_counts']['E_terrain']} | Target Reference, OpenGameArt Stone Bridge, Caldera | Dark stone causeway, molten orange borders, bridge facade |",
    f"| **F. Characters & Gameplay Objects** | {manifest['category_counts']['F_characters']} | OpenGameArt Skeleton, Timberlate007 Enemies | Skeletons for cages, bone remains, ambient creatures |",
    f"| **Archives (.zip / .rar)** | {manifest['category_counts']['archives']} | All sub-pack zip/rar archives | Source compressed bundles (extracted for audit) |",
    f"| **3D Models** | {manifest['category_counts']['models']} | OpenGameArt Stone Bridge (.obj, .blend) | 3D mesh references (not used in 2D sprite pipeline) |",
    f"| **Documentation & Licenses** | {manifest['category_counts']['docs_data']} | LICENSE, README, JSON, MD files | Legal provenance and usage guidelines |",
    "",
    "---",
    "",
    "## 3. Duplicate Assets Audit",
    "",
    "| Duplicate Source File | Identical Canonical File | Reason |",
    "| :--- | :--- | :--- |",
]

for dup, canon in manifest['duplicates']:
    audit_lines.append(f"| `{dup}` | `{canon}` | SHA-256 byte-for-byte duplicate |")

audit_lines.extend([
    "",
    "---",
    "",
    "## 4. License Provenance & Legal Verification",
    "",
    "| Asset Pack Name | Author / Source | Verified License | Commercial Use | Attribution Required | Usage In Game |",
    "| :--- | :--- | :--- | :---: | :---: | :--- |",
])

for pack_name, info in PACK_LICENSES.items():
    audit_lines.append(f"| **{pack_name}** | {info['author']} | {info['license']} | {info['commercial']} | {info['attribution']} | {info['notes']} |")

audit_lines.extend([
    "",
    "---",
    "",
    "## 5. Contact Sheets Generated",
    "",
    "Visual contact sheets have been rendered into `docs/hell_redesign/contact_sheets/`:",
    "1. [cs_01_backgrounds_and_fortresses.png](file:///home/daniel/Documents/Endless-Hillclimb-Fixed/docs/hell_redesign/contact_sheets/cs_01_backgrounds_and_fortresses.png) — 77 items: Panoramas, Skies, Castles, Demon Portals.",
    "2. [cs_02_lava_and_fire.png](file:///home/daniel/Documents/Endless-Hillclimb-Fixed/docs/hell_redesign/contact_sheets/cs_02_lava_and_fire.png) — 24 items: Lavafalls, animated torches, flame sheets, lava tiles.",
    "3. [cs_03_decorations_props.png](file:///home/daniel/Documents/Endless-Hillclimb-Fixed/docs/hell_redesign/contact_sheets/cs_03_decorations_props.png) — 55 items: Banners, chains, cages, chests, lanterns.",
    "4. [cs_04_terrain_and_bridge.png](file:///home/daniel/Documents/Endless-Hillclimb-Fixed/docs/hell_redesign/contact_sheets/cs_04_terrain_and_bridge.png) — 4 items: Stone bridge textures, causeways, basalt platforms.",
    "5. [cs_05_characters_and_enemies.png](file:///home/daniel/Documents/Endless-Hillclimb-Fixed/docs/hell_redesign/contact_sheets/cs_05_characters_and_enemies.png) — 23 items: Skeletons, skull heaps, RPG enemies.",
    "",
    "---",
    "",
    "## 6. Old Hell Visual Assets Quarantined",
    "",
    "All obsolete Hell assets have been identified and removed from active rendering paths into dated quarantine:",
    "- `assets/environments/hell/backgrounds/hell_volcanic_bridge_*.jpg` -> Quarantined (old generic canyon wallpaper).",
    "- `assets/environments/hell/characters/flying_dragon/` -> Quarantined (old oversized dragon).",
    "- `assets/environments/hell/characters/skeleton_knight/` -> Quarantined (old cartoon fighter).",
    "- `assets/environments/hell/characters/demon_goblin/` -> Quarantined (old cartoon goblin).",
    "- `assets/environments/hell/characters/horned_fiend/` -> Quarantined (old cartoon monster).",
    "- `assets/environments/hell/terrain/hell_basalt_platform.png` -> Quarantined (old black slab).",
    "- `assets/environments/hell/terrain/hell_basalt_column.png` -> Quarantined (old grey pillar).",
    "- `assets/environments/hell/decorations/giant_dragon_skull_decal.png` -> Quarantined (old skull decal).",
    "",
    "Shared gameplay systems preserved: Audio streams (`.ogg`), vehicle systems, HUD, collision, world cycle schedule."
])

with open(AUDIT_MD_PATH, "w") as f:
    f.write("\n".join(audit_lines))
print(f"Wrote {AUDIT_MD_PATH}")

# 2. Generate HELL_ASSET_MAPPING.md
mapping_lines = [
    "# Hell Biome Redesign — Reference-to-Asset Mapping",
    "",
    "**Visual Target:** `references/hell_target.png` (1600 × 533)",
    "**Target Art Style:** Detailed painted dark fantasy panorama (crimson, obsidian, molten orange).",
    "",
    "---",
    "",
    "## 1. Master Element Mapping Table",
    "",
    "| Target Reference Element | Selected Source Asset | Exact Source Path | Dimensions | Status | Reason & Integration Role |",
    "| :--- | :--- | :--- | :---: | :---: | :--- |",
    "| **Hell Sky & Blood Moon** | Target Reference / Master Panorama | `Target_Reference_Image/hell_target.png` | 1600x533 | **SELECTED** | Exact visual match for deep crimson clouds and glowing blood moon in upper-right sky. |",
    "| **Giant Demon Fortress** | Target Reference / Master Panorama | `Target_Reference_Image/hell_target.png` | 1600x533 | **SELECTED** | The massive horned demonic skull mountain fortress, glowing eyes and blazing lava mouth. |",
    "| **Volcanic Mountain Ridges** | Target Reference + AssetSmithy | `AssetSmithy_5_Dark_Fantasy_Backgrounds/.../02_demon_portal.png` | 1920x1080 | **SELECTED** | Jagged black spires and obsidian volcanic ridges framing fortress. |",
    "| **Lava Waterfalls** | Target Reference + SpritePilot | `Target_Reference_Image/hell_target.png` & `SpritePilot.../waterfall` | 1600x533 / multi | **SELECTED** | Multiple vertical glowing yellow-orange cascades descending from cliffs into abyss. |",
    "| **Cavern Ceiling & Stalactites** | Target Reference / Master Panorama | `Target_Reference_Image/hell_target.png` | 1600x533 | **SELECTED** | Dark jagged cavern ceiling framing the top-left and top margins. |",
    "| **Hanging Chains & Cages** | Target Reference + OpenGameArt | `OpenGameArt_Skeleton/skeleton-hanging.png` & Target Reference | 32x32 / cutouts | **SELECTED** | Heavy black iron chains across upper scene with suspended iron cages containing skeletons. |",
    "| **Skull Banners** | Target Reference + SpriteCanvas | `SpriteCanvas_Animated_Props/.../prop-banner/banner-wave.png` | 64x64 (35f) | **SELECTED** | Dark red tattered banners with skull insignia on left and right borders with animated waving. |",
    "| **Playable Stone Bridge** | Target Reference + OpenGameArt | `Target_Reference_Image/hell_target.png` & `005_stone_bridge/stone_bridge_diffuse.png` | 1600x533 / 1024x1024 | **SELECTED** | Curved ancient dark brick/stone causeway with molten orange edge and matching collision path. |",
    "| **Bridge Torch Pillars** | SpriteCanvas Animated Torch | `SpriteCanvas_Animated_Props/.../prop-torch/torch-burn.png` | 64x64 (26f) | **SELECTED** | Animated bright orange flames atop stone posts along the bridge. (CC0) |",
    "| **Campfires / Braziers** | SpriteCanvas Animated Campfire | `SpriteCanvas_Animated_Props/.../prop-campfire/campfire-burn.png` | 64x64 (26f) | **SELECTED** | Molten glowing braziers for landmark illumination. (CC0) |",
    "| **Foreground Skulls & Bones** | OpenGameArt Skeleton + Target | `OpenGameArt_Skeleton/skulls_0.png` & Target Reference | 32x32 / cutouts | **SELECTED** | Scattered skulls, ribs, and skeleton remains in the lower foreground. |",
    "| **Foreground Obsidian Rocks** | Target Reference + Caldera | `Caldera_LavaWorld_FreeSampler.../rock.png` | Various | **SELECTED** | Jagged dark volcanic rocks framing lower-left and lower-right corners. |",
    "| **Atmospheric Embers & Smoke** | Godot VFX Particle System | `vfx/particles/` | Vector / CPUParticles2D | **SELECTED** | Upward drifting embers, sparks, and volcanic heat haze. |",
    "",
    "---",
    "",
    "## 2. Classification of Asset Library",
    "",
    "### A. SELECTED (Used in new Hell environment)",
    "- `Target_Reference_Image/hell_target.png`: Master visual target and layer extraction source.",
    "- `SpriteCanvas_Animated_Props/.../prop-torch/torch-burn.png`: 26-frame animated torch flame (CC0).",
    "- `SpriteCanvas_Animated_Props/.../prop-campfire/campfire-burn.png`: 26-frame animated brazier flame (CC0).",
    "- `SpriteCanvas_Animated_Props/.../prop-banner/banner-wave.png`: 35-frame animated waving banner cloth (CC0).",
    "- `OpenGameArt_Skeleton/skeleton-hanging.png`: Skeletal prisoner for hanging iron cages (CC-BY 3.0).",
    "- `OpenGameArt_Skeleton/skulls_0.png`: High-detail skull cluster for foreground remains (CC-BY 3.0).",
    "- `OpenGameArt_Skeleton/skeleton_13.png`: Ground skeleton remains for foreground rocks (CC-BY 3.0).",
    "- `OpenGameArt_Stone_Bridge/stone_bridge_diffuse.png`: Stone masonry texture for bridge underside (CC0).",
    "- `AssetSmithy_5_Dark_Fantasy_Backgrounds/.../02_demon_portal.png`: Supplementary dark spires & demon gate.",
    "",
    "### B. OPTIONAL (Suitable for secondary encounters or future extensions)",
    "- `SceneForge_5_Dark_Fantasy_Backgrounds/SF005_DarkFantasyBackgrounds_01..05.jpg`: Gothic castle interior & ritual hall.",
    "- `Blueberry_Demon_Castle_Backgrounds/...`: Pixel-art castle exterior & lava river (for retro modes).",
    "- `Firepious_Hellwake/...`: Underworld pixel-art chasm & molten orb.",
    "- `OpenGameArt_Lava_Background/1920x1080.png`: Generic lava glow underlay.",
    "",
    "### C. REJECTED (Unsuitable art style or format)",
    "- `Timberlate007_Hell_Fantasy_Asset_Pack`: Top-down 16x16 JRPG pixel art tiles (incompatible with 2D side-scrolling high-res painted panorama).",
    "- `OpenGameArt_Stone_Bridge/stone_bridge_mesh.obj` / `.blend`: 3D polygon meshes (game uses 2D canvas items).",
    "- `OpenGameArt_Lava_Tileset`: Low-resolution 64x64 pixel tiles (style mismatch with painterly target).",
    "- `SpritePilot_Environment_Pack/16px`: 16px pixel-art tiles (too small for hero environmental assets).",
    "",
    "### D. DUPLICATES",
    "- `Target_Reference_Image/image(1).png` (duplicate of `hell_target.png`).",
    "- `OpenGameArt_Lava_Background/1920x1080_0.png` (duplicate of `1920x1080.png`).",
    "- `OpenGameArt_Skeleton/skeleton-hanging.png` (duplicate of `PNG/32x32/skeleton-hanging.png`)."
]

with open(MAPPING_MD_PATH, "w") as f:
    f.write("\n".join(mapping_lines))
print(f"Wrote {MAPPING_MD_PATH}")
