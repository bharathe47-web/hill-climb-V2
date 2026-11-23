#!/usr/bin/env python3
import os
import sys
import json
import hashlib
from pathlib import Path

SOURCE_DIR = Path("/home/daniel/Pictures/Assets For Hell")
DOCS_DIR = Path("/home/daniel/Documents/Endless-Hillclimb-Fixed/docs/hell_redesign")
DOCS_DIR.mkdir(parents=True, exist_ok=True)

def get_file_hash(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

def get_image_dimensions(path):
    ext = path.suffix.lower()
    try:
        with open(path, "rb") as f:
            data = f.read(64)
            if ext == ".png" and data.startswith(b"\x89PNG\r\n\x1a\n"):
                w = int.from_bytes(data[16:20], "big")
                h = int.from_bytes(data[20:24], "big")
                return w, h, "PNG"
            elif ext in [".jpg", ".jpeg"]:
                f.seek(0)
                full = f.read()
                # Scan for SOF markers
                idx = 0
                while idx < len(full) - 9:
                    if full[idx] == 0xFF and full[idx+1] in [0xC0, 0xC1, 0xC2, 0xC3]:
                        h = int.from_bytes(full[idx+5:idx+7], "big")
                        w = int.from_bytes(full[idx+7:idx+9], "big")
                        return w, h, "JPEG"
                    idx += 1
    except Exception as e:
        pass
    return None, None, ext[1:].upper()

def main():
    print("Scanning:", SOURCE_DIR)
    all_files = []
    folders = set()
    hashes = {}
    duplicates = []
    
    for root, dirs, files in os.walk(SOURCE_DIR):
        for d in dirs:
            folders.add(str(Path(root) / d))
        for f in files:
            p = Path(root) / f
            all_files.append(p)

    print(f"Total files: {len(all_files)}, Total folders: {len(folders)}")

    records = []
    category_counts = {
        "A_background": 0,
        "B_fortress": 0,
        "C_lava_fire": 0,
        "D_decorations": 0,
        "E_terrain": 0,
        "F_characters": 0,
        "archives": 0,
        "models": 0,
        "audio": 0,
        "docs_data": 0
    }

    for p in sorted(all_files):
        rel = p.relative_to(SOURCE_DIR)
        ext = p.suffix.lower()
        size = p.stat().st_size
        fhash = get_file_hash(p)
        
        is_dup = False
        if fhash in hashes:
            is_dup = True
            duplicates.append((str(rel), hashes[fhash]))
        else:
            hashes[fhash] = str(rel)

        w, h, fmt = get_image_dimensions(p)
        aspect = f"{w/h:.2f}" if (w and h and h > 0) else "N/A"
        dims = f"{w}x{h}" if (w and h) else "N/A"

        # Categorize
        rel_str = str(rel).lower()
        fn_str = p.name.lower()
        
        cat = "docs_data"
        if ext in [".png", ".jpg", ".jpeg", ".webp", ".bmp"]:
            if "background" in rel_str or "sky" in rel_str or "hellwake" in rel_str or "sceneforge" in rel_str or "assetsmithy" in rel_str or "target" in rel_str:
                if "fortress" in fn_str or "castle" in fn_str or "portal" in fn_str:
                    cat = "B_fortress"
                else:
                    cat = "A_background"
            elif "lava" in rel_str or "fire" in rel_str or "flame" in rel_str or "torch" in fn_str or "campfire" in fn_str or "caldera" in rel_str:
                cat = "C_lava_fire"
            elif "skeleton" in rel_str or "enemy" in rel_str or "heros" in rel_str or "dragon" in rel_str:
                cat = "F_characters"
            elif "bridge" in rel_str or "tile" in rel_str or "terrain" in rel_str or "ground" in rel_str or "stone" in rel_str or "rock" in rel_str:
                cat = "E_terrain"
            else:
                cat = "D_decorations"
        elif ext in [".zip", ".rar"]:
            cat = "archives"
        elif ext in [".obj", ".blend", ".gltf", ".glb"]:
            cat = "models"
        elif ext in [".ogg", ".wav", ".mp3"]:
            cat = "audio"

        category_counts[cat] += 1

        records.append({
            "rel_path": str(rel),
            "filename": p.name,
            "format": fmt,
            "size_bytes": size,
            "dimensions": dims,
            "aspect": aspect,
            "category": cat,
            "is_duplicate": is_dup,
            "sha256": fhash
        })

    out_json = DOCS_DIR / "audit_manifest.json"
    with open(out_json, "w") as f:
        json.dump({"total_files": len(all_files), "folders": sorted(list(folders)), "category_counts": category_counts, "records": records, "duplicates": duplicates}, f, indent=2)

    print(f"Wrote audit json to {out_json}")
    print(f"Category counts: {category_counts}")
    print(f"Duplicates count: {len(duplicates)}")

if __name__ == "__main__":
    main()
