#!/usr/bin/env python3
import os
import sys
import json
import shutil
from pathlib import Path

PROJECT_ROOT = Path(".").resolve()
ARCHIVE_ROOT = Path("/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/ARCHIVE_CLEANUP_20261119")
QUARANTINE_ROOT = Path("/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/QUARANTINE_CLEANUP_20261119")

with open("tools/cleanup_candidates.json") as f:
    candidates = json.load(f)

print(f"Executing STAGE B: Moving {len(candidates)} candidates into Quarantine & Archive...")

archived_count = 0
quarantined_count = 0

for c in candidates:
    rel_path = Path(c["path"])
    src_file = PROJECT_ROOT / rel_path
    
    if not src_file.exists():
        continue
        
    arch_dest = ARCHIVE_ROOT / rel_path
    quar_dest = QUARANTINE_ROOT / rel_path
    
    arch_dest.parent.mkdir(parents=True, exist_ok=True)
    quar_dest.parent.mkdir(parents=True, exist_ok=True)
    
    # 1. Copy to permanent archive
    shutil.copy2(src_file, arch_dest)
    archived_count += 1
    
    # 2. Move to quarantine (removes from active project)
    shutil.move(src_file, quar_dest)
    quarantined_count += 1

print(f"Successfully archived: {archived_count} files to {ARCHIVE_ROOT}")
print(f"Successfully quarantined: {quarantined_count} files to {QUARANTINE_ROOT}")

# Also check for empty directories left behind (e.g. raw_frames, previews in wildlife)
for check_dir in [
    PROJECT_ROOT / "assets" / "environments" / "heaven" / "wildlife" / "raw_frames",
    PROJECT_ROOT / "assets" / "environments" / "heaven" / "wildlife" / "previews"
]:
    if check_dir.exists() and not os.listdir(check_dir):
        print(f"Removing empty directory: {check_dir.relative_to(PROJECT_ROOT)}")
        check_dir.rmdir()

print("STAGE B Quarantine move complete.")
