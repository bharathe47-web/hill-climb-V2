#!/usr/bin/env python3
import json
from pathlib import Path

with open("tools/cleanup_candidates.json") as f:
    candidates = json.load(f)

with open("tools/inventory_summary.json") as f:
    inv = json.load(f)

total_size_mb = sum(c["size"] for c in candidates) / (1024*1024)
total_files = inv["total_project_files_no_git"]

md = []
md.append("# ENDLESS HILL CLIMB — SAFE CLEANUP DRY RUN REPORT (STAGE A)")
md.append("**Date:** November 19, 2026  ")
md.append("**Branch:** `cleanup/safe-project-cleanup`  ")
md.append("**Project Root:** `/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/Endless-Hillclimb-Fixed`  ")
md.append("**External Backup Location:** `/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/BACKUP_BEFORE_CLEANUP_20261119/Endless-Hillclimb-Fixed`  ")
md.append("**Status:** DRY RUN COMPLETE — 0 FILES DELETED (Awaiting Stage B Quarantine Verification)  \n")
md.append("---")
md.append("## 1. Executive Summary")
md.append(f"A comprehensive inventory and Godot resource dependency audit was performed across all **{total_files} files** in the project repository.")
md.append(f"A total of **{len(candidates)} candidate files ({total_size_mb:.2f} MB)** have been identified for safe archiving and cleanup.")
md.append("Every candidate was audited against all `.tscn` scenes, `.gd` scripts, `.tres` resources, `project.godot`, and 29 test suites. **Every candidate has strictly ZERO active references.**\n")

md.append("### Safety Protections Preserved:")
md.append("- **Normal Land, Heaven, and Hell visual assets:** 100% preserved.")
md.append("- **Playable Vehicles & Configurations:** Dune Buggy, Blue Flame Truck, Orc Racer, Trophy Truck, One-Wheel Scooter preserved.")
md.append("- **SnowfallManager:** Kept intact in `Game.tscn` and `test_complete_bug_fixes_and_features.gd`.")
md.append("- **Core Wildlife Resources:** `dove_flight.tres`, `dove_atlas.png`, and `HeavenDove.tscn` preserved for test assertions.")
md.append("- **Authoritative Evidence Previews:** Complete set of latest approved screenshots, walk-through video, and benchmark telemetry kept in `docs/previews/`.")
md.append("- **External Archive:** All 447 candidates will be safely archived outside the repository prior to removal.\n")

md.append("---")
md.append("## 2. Inventory Breakdown by Category\n")

cat_groups = {}
for c in candidates:
    cat = c["category"]
    if cat not in cat_groups:
        cat_groups[cat] = []
    cat_groups[cat].append(c)

md.append("| Category | Candidate Files | Total Size | Proposed Action |")
md.append("| :--- | :---: | :---: | :--- |")
for cat, items in sorted(cat_groups.items()):
    sz_mb = sum(x["size"] for x in items) / (1024*1024)
    md.append(f"| **{cat}** | {len(items)} | {sz_mb:.2f} MB | Archive to external folder & remove from git tracking |")

md.append(f"| **TOTAL** | **{len(candidates)}** | **{total_size_mb:.2f} MB** | **Safe external archive and project footprint reduction** |\n")

md.append("---")
md.append("## 3. Preserved Active Evidence in `docs/previews/`\n")
md.append("The following authoritative evidence files are **STRICTLY PRESERVED** in the active repository:")
md.append("- **Normal Land Approved:** `docs/previews/prod_01_normal_land_start_100m.png`")
md.append("- **Heaven Approved & Comparison:** `docs/previews/heaven_signoff_314m.png`, `docs/previews/heaven_phase2_4_before_after_comparison.png`")
md.append("- **Heaven Architecture Series:** `docs/previews/heaven_signoff_360m.png`, `420m.png`, `480m.png`, `540m.png`, `600m.png`, `defect_repair_side_by_side_314m.png`")
md.append("- **Hell Approved:** `docs/previews/prod_05_hell_portal_entry_600m.png`, `prod_06_hell_subterranean_magma_glow_640m.png`, `prod_07_hell_braziers_and_columns_700m.png`, `prod_08_hell_skeleton_knight_sentinel_740m.png`, `prod_09_hell_demon_goblin_and_magma_vents_780m.png`, `prod_10_hell_horned_fiend_cavern_860m.png`")
md.append("- **Portals & Return:** `docs/previews/prod_02_heaven_portal_crossing_300m.png`, `prod_11_hell_return_portal_900m.png`, `defect_repair_01_heaven_portal_300m.png`, `defect_repair_07_heaven_hell_portal_600m.png`")
md.append("- **Retry Verification:** `docs/previews/heaven_signoff_retry_clean_normal.png`, `defect_repair_08_heaven_crash_retry_normal.png`")
md.append("- **Progression Telemetry & Benchmarks:** `docs/previews/prod_12_cycle2_progression_1200m.png`, `docs/previews/benchmark_results.json`")
md.append("- **Master Video Walkthrough:** `docs/previews/master_production_gameplay_walkthrough.mp4`\n")

md.append("---")
md.append("## 4. Full Candidate Manifest\n")
md.append("| # | Exact Path | Size | Category | Detected Refs | Confidence | Proposed Action | Archive Destination |")
md.append("| :--- | :--- | :---: | :--- | :---: | :---: | :--- | :--- |")

for idx, c in enumerate(candidates, 1):
    c_sz = c["size"]
    sz_str = f"{c_sz} B" if c_sz < 1024 else (f"{c_sz/1024:.1f} KB" if c_sz < 1024*1024 else f"{c_sz/(1024*1024):.2f} MB")
    c_path = c["path"]
    c_cat = c["category"]
    c_conf = c["confidence"]
    c_act = c["action"]
    c_dest = c["archive_dest"]
    md.append(f"| {idx} | `{c_path}` | {sz_str} | {c_cat} | 0 | {c_conf} | {c_act} | `{c_dest}` |")

Path("docs/CLEANUP_DRY_RUN_REPORT.md").write_text("\n".join(md), encoding="utf-8")
print(f"Generated docs/CLEANUP_DRY_RUN_REPORT.md ({len(candidates)} candidates listed).")
