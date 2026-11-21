#!/usr/bin/env python3
import os
import shutil
from pathlib import Path

PROJECT_ROOT = Path("/home/daniel/Documents/Endless-Hillclimb-Fixed")
HELL_ASSET_DIR = PROJECT_ROOT / "assets/environments/hell"
QUARANTINE_DIR = PROJECT_ROOT / "quarantine/old_hell_assets_20261120"

def main():
    print("Quarantining old Hell visual assets...")
    QUARANTINE_DIR.mkdir(parents=True, exist_ok=True)

    # 1. Move old visual subdirectories to quarantine
    for sub in ["backgrounds", "characters", "terrain", "decorations", "vfx"]:
        p = HELL_ASSET_DIR / sub
        if p.exists():
            dest = QUARANTINE_DIR / sub
            if dest.exists():
                shutil.rmtree(dest)
            shutil.move(str(p), str(dest))
            print(f"  Moved {sub} -> {dest}")

    # Remove MANIFEST.json if present
    old_manifest = HELL_ASSET_DIR / "MANIFEST.json"
    if old_manifest.exists():
        shutil.move(str(old_manifest), str(QUARANTINE_DIR / "MANIFEST.json"))

    # 2. Preserve audio streams
    audio_src = HELL_ASSET_DIR / "audio"
    audio_src.mkdir(parents=True, exist_ok=True)
    (audio_src / "ambience").mkdir(parents=True, exist_ok=True)

    # 3. Create clean new directory structure
    new_dirs = [
        "background/sky",
        "background/clouds",
        "background/blood_moon",
        "background/distant_mountains",
        "background/fortress",
        "midground/volcanic_cliffs",
        "midground/lavafalls",
        "midground/lava_rivers",
        "midground/fortress_details",
        "architecture/hell_bridge",
        "architecture/stone_terrain",
        "architecture/banners",
        "architecture/chains",
        "architecture/cages",
        "architecture/braziers",
        "architecture/torches",
        "foreground/rocks",
        "foreground/skulls",
        "foreground/skeletons",
        "foreground/bones",
        "foreground/decorations",
        "vfx/fire",
        "vfx/smoke",
        "vfx/embers",
        "vfx/lava",
        "vfx/particles",
        "props/environment_props",
        "audio/ambience",
        "audio/fire",
        "audio/lava",
        "audio/environment"
    ]

    for d in new_dirs:
        (HELL_ASSET_DIR / d).mkdir(parents=True, exist_ok=True)

    print("[✓] Clean new Hell directory structure created successfully.")

if __name__ == "__main__":
    main()
