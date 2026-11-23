#!/usr/bin/env python3
import os
import sys
import glob
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path

PROJECT_ROOT = Path(".").resolve()

print(f"Scanning project root: {PROJECT_ROOT}")

# 1. Collect all files (including hidden, but tracking .git separately)
all_files = []
for root, dirs, files in os.walk(PROJECT_ROOT):
    for f in files:
        full_path = Path(root) / f
        rel_path = full_path.relative_to(PROJECT_ROOT)
        all_files.append(rel_path)

print(f"Total files in filesystem (including .git, .godot): {len(all_files)}")

# Separate files: non-git files
project_files = [f for f in all_files if not str(f).startswith(".git/")]
print(f"Total project files (excluding .git): {len(project_files)}")

# 2. File counts by extension and directory
ext_counts = defaultdict(int)
ext_sizes = defaultdict(int)
dir_sizes = defaultdict(int)
dir_file_counts = defaultdict(int)

file_hashes = defaultdict(list)
filename_map = defaultdict(list)

large_images = [] # > 1MB or > 500KB
large_audio = []  # > 500KB
video_files = []

for rel in project_files:
    full = PROJECT_ROOT / rel
    size = full.stat().st_size
    ext = rel.suffix.lower() if rel.suffix else "[no_ext]"
    
    ext_counts[ext] += 1
    ext_sizes[ext] += size
    
    # Top-level directory (or root)
    parts = rel.parts
    top_dir = parts[0] if len(parts) > 1 else "[root]"
    dir_sizes[top_dir] += size
    dir_file_counts[top_dir] += 1
    
    filename_map[rel.name].append(str(rel))
    
    # Track media
    if ext in [".png", ".jpg", ".jpeg", ".webp", ".svg"]:
        if size > 500 * 1024:
            large_images.append((str(rel), size))
    elif ext in [".wav", ".ogg", ".mp3"]:
        if size > 500 * 1024:
            large_audio.append((str(rel), size))
    elif ext in [".mp4", ".mov", ".avi", ".webm", ".mkv"]:
        video_files.append((str(rel), size))

    # SHA-256 for non-huge files (or all non-.godot files)
    if not str(rel).startswith(".godot/"):
        try:
            with open(full, "rb") as fp:
                h = hashlib.sha256(fp.read()).hexdigest()
                file_hashes[h].append((str(rel), size))
        except Exception as e:
            pass

# Find duplicate files by SHA-256
sha_duplicates = {h: items for h, items in file_hashes.items() if len(items) > 1}

# Find duplicate filenames
name_duplicates = {name: paths for name, paths in filename_map.items() if len(paths) > 1 and not name.endswith(".import") and not name.endswith(".uid")}

# 3. Godot Resource Dependency Index
# Read all scenes (.tscn), scripts (.gd), resources (.tres, .res), project.godot, etc.
text_source_extensions = [".tscn", ".gd", ".tres", ".res", ".godot", ".cfg", ".json", ".py", ".md", ".sh", ".gdshader"]

dependency_graph = defaultdict(set) # referenced_res -> set of referencing files
all_text_content = {}

for rel in project_files:
    ext = rel.suffix.lower()
    if ext in text_source_extensions and not str(rel).startswith(".godot/"):
        full = PROJECT_ROOT / rel
        try:
            with open(full, "r", encoding="utf-8", errors="ignore") as fp:
                all_text_content[str(rel)] = fp.read()
        except Exception as e:
            pass

print(f"Loaded {len(all_text_content)} text source files for dependency analysis.")

# Search patterns in text source files
# 1. "res://..."
res_pattern = re.compile(r'res://([a-zA-Z0-9_\-/\. ]+)')
# 2. "uid://..."
uid_pattern = re.compile(r'uid://([a-zA-Z0-9]+)')
# 3. Relative or filename strings in preload/load:
load_pattern = re.compile(r'(?:preload|load|ResourceLoader\.load|load_threaded_request)\s*\(\s*["\']([^"\']+)["\']')

# Map UID to path from .uid files and .tscn/.tres
uid_to_path = {}
path_to_uid = {}

for rel in project_files:
    if str(rel).endswith(".uid"):
        target_file = str(rel)[:-4] # strip .uid
        full = PROJECT_ROOT / rel
        try:
            with open(full, "r") as fp:
                u = fp.read().strip()
                uid_to_path[u] = target_file
                path_to_uid[target_file] = u
        except:
            pass

# Scan references
for source_path, content in all_text_content.items():
    # Find all res:// matches
    for m in res_pattern.finditer(content):
        ref_rel = m.group(1).strip()
        dependency_graph[ref_rel].add(source_path)
    
    # Find all load/preload matches
    for m in load_pattern.finditer(content):
        ref = m.group(1).strip()
        if ref.startswith("res://"):
            ref_rel = ref[6:]
            dependency_graph[ref_rel].add(source_path)
        else:
            dependency_graph[ref].add(source_path)
            
    # Find UID matches
    for m in uid_pattern.finditer(content):
        u = "uid://" + m.group(1)
        if u in uid_to_path:
            p = uid_to_path[u]
            dependency_graph[p].add(source_path)

# Special check for dove assets
dove_assets = [str(f) for f in project_files if "dove" in str(f).lower()]
dove_references = {}
for da in dove_assets:
    # search da or basename in all content
    base = Path(da).name
    stem = Path(da).stem
    refs = set()
    for s_path, c in all_text_content.items():
        if da in c or (base in c and not s_path.endswith(da)):
            refs.add(s_path)
    dove_references[da] = refs

# Special check for snowfall assets
snow_assets = [str(f) for f in project_files if "snow" in str(f).lower()]
snow_references = {}
for sa in snow_assets:
    base = Path(sa).name
    refs = set()
    for s_path, c in all_text_content.items():
        if sa in c or (base in c and not s_path.endswith(sa)):
            refs.add(s_path)
    snow_references[sa] = refs

# Output summary data
output_data = {
    "total_project_files_no_git": len(project_files),
    "ext_counts": dict(sorted(ext_counts.items(), key=lambda x: x[1], reverse=True)),
    "ext_sizes": dict(sorted(ext_sizes.items(), key=lambda x: x[1], reverse=True)),
    "dir_sizes": dict(sorted(dir_sizes.items(), key=lambda x: x[1], reverse=True)),
    "dir_file_counts": dict(sorted(dir_file_counts.items(), key=lambda x: x[1], reverse=True)),
    "sha_duplicates_count": len(sha_duplicates),
    "sha_duplicates": {h: items for h, items in list(sha_duplicates.items())[:50]},
    "name_duplicates_count": len(name_duplicates),
    "large_images": large_images,
    "large_audio": large_audio,
    "video_files": video_files,
    "dove_assets": dove_assets,
    "dove_references": {k: list(v) for k, v in dove_references.items() if v},
    "snow_assets": snow_assets,
    "snow_references": {k: list(v) for k, v in snow_references.items() if v}
}

with open("tools/inventory_summary.json", "w") as fp:
    json.dump(output_data, fp, indent=2)

print("\nInventory summary written to tools/inventory_summary.json")
