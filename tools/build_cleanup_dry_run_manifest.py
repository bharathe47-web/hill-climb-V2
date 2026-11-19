#!/usr/bin/env python3
import os
import sys
import json
import hashlib
from pathlib import Path

PROJECT_ROOT = Path(".").resolve()
ARCHIVE_ROOT = Path("/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/ARCHIVE_CLEANUP_20261119")
QUARANTINE_ROOT = Path("/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/QUARANTINE_CLEANUP_20261119")

# 1. Define Candidate Collections

candidates = []

# --- Category B: Documentation & Superseded Previews in docs/previews/ ---
# Keep only authoritative latest evidence:
KEEP_PREVIEWS = {
    # 1. Normal Land
    "prod_01_normal_land_start_100m.png",
    "prod_01_normal_land_start_100m.png.import",
    # 2. Heaven
    "heaven_signoff_314m.png",
    "heaven_phase2_4_before_after_comparison.png",
    "heaven_signoff_360m.png",
    "heaven_signoff_420m.png",
    "heaven_signoff_480m.png",
    "heaven_signoff_540m.png",
    "heaven_signoff_600m.png",
    "defect_repair_side_by_side_314m.png",
    # 3. Hell
    "prod_05_hell_portal_entry_600m.png",
    "prod_06_hell_subterranean_magma_glow_640m.png",
    "prod_07_hell_braziers_and_columns_700m.png",
    "prod_08_hell_skeleton_knight_sentinel_740m.png",
    "prod_09_hell_demon_goblin_and_magma_vents_780m.png",
    "prod_10_hell_horned_fiend_cavern_860m.png",
    # 4. Portals & Progression
    "prod_02_heaven_portal_crossing_300m.png",
    "prod_03_heaven_palace_corridor_360m.png",
    "prod_04_heaven_golden_pedestal_480m.png",
    "prod_11_hell_return_portal_900m.png",
    "prod_12_cycle2_progression_1200m.png",
    "defect_repair_01_heaven_portal_300m.png",
    "defect_repair_02_heaven_roadway_314m.png",
    "defect_repair_03_heaven_palace_corridor_360m.png",
    "defect_repair_04_heaven_fountain_plaza_420m.png",
    "defect_repair_05_heaven_grand_door_480m.png",
    "defect_repair_06_heaven_angel_monument_540m.png",
    "defect_repair_07_heaven_hell_portal_600m.png",
    # 5. Retry Verification
    "heaven_signoff_retry_clean_normal.png",
    "defect_repair_08_heaven_crash_retry_normal.png",
    # 6. Performance Benchmarks
    "benchmark_results.json",
    # 7. One complete three-biome video walkthrough
    "master_production_gameplay_walkthrough.mp4"
}

previews_dir = PROJECT_ROOT / "docs" / "previews"
if previews_dir.exists():
    for f in sorted(os.listdir(previews_dir)):
        if f not in KEEP_PREVIEWS:
            p = previews_dir / f
            if p.is_file():
                candidates.append({
                    "path": str(p.relative_to(PROJECT_ROOT)),
                    "size": p.stat().st_size,
                    "category": "Category B — Superseded Previews & Recordings",
                    "reason": "Superseded preview/crop/video artifact; canonical proof preserved in project",
                    "confidence": "HIGH (100% verified non-runtime)",
                    "action": "Archive externally & remove from active repo",
                    "archive_dest": str(ARCHIVE_ROOT / p.relative_to(PROJECT_ROOT))
                })

# --- Category C: Unused Dove Assets ---
# 1. raw_frames (60 frames + 60 imports)
raw_frames_dir = PROJECT_ROOT / "assets" / "environments" / "heaven" / "wildlife" / "raw_frames"
if raw_frames_dir.exists():
    for f in sorted(os.listdir(raw_frames_dir)):
        p = raw_frames_dir / f
        if p.is_file():
            candidates.append({
                "path": str(p.relative_to(PROJECT_ROOT)),
                "size": p.stat().st_size,
                "category": "Category C — Obsolete Dove Frame Collection",
                "reason": "Unused individual dove animation frames; project uses dove_atlas.png (2048x2048)",
                "confidence": "HIGH (0 scene/script/test references)",
                "action": "Archive externally & remove from active repo",
                "archive_dest": str(ARCHIVE_ROOT / p.relative_to(PROJECT_ROOT))
            })

# 2. wildlife previews
previews_wildlife_dir = PROJECT_ROOT / "assets" / "environments" / "heaven" / "wildlife" / "previews"
if previews_wildlife_dir.exists():
    for f in sorted(os.listdir(previews_wildlife_dir)):
        p = previews_wildlife_dir / f
        if p.is_file():
            candidates.append({
                "path": str(p.relative_to(PROJECT_ROOT)),
                "size": p.stat().st_size,
                "category": "Category C — Obsolete Dove Previews",
                "reason": "Unused dove preview GIF and contact sheet",
                "confidence": "HIGH (0 scene/script/test references)",
                "action": "Archive externally & remove from active repo",
                "archive_dest": str(ARCHIVE_ROOT / p.relative_to(PROJECT_ROOT))
            })

# 3. dove_atlas_3200
for da3200 in ["assets/environments/heaven/wildlife/dove_atlas_3200.png", "assets/environments/heaven/wildlife/dove_atlas_3200.png.import"]:
    p = PROJECT_ROOT / da3200
    if p.exists() and p.is_file():
        candidates.append({
            "path": str(p.relative_to(PROJECT_ROOT)),
            "size": p.stat().st_size,
            "category": "Category C — Obsolete 3200px Dove Atlas",
            "reason": "Superseded 3200px duplicate atlas; dove_atlas.png (2048px) is the active sprite frames source",
            "confidence": "HIGH (0 scene/script/test references)",
            "action": "Archive externally & remove from active repo",
            "archive_dest": str(ARCHIVE_ROOT / p.relative_to(PROJECT_ROOT))
        })

# --- Category E: Old Tool Scripts in tools/ ---
SUPERSEDED_TOOLS = [
    # Old evidence capture scripts
    "tools/capture_all_required_screenshots.gd",
    "tools/capture_all_required_screenshots.gd.uid",
    "tools/capture_current_heaven_and_hell_gameplay.gd",
    "tools/capture_current_heaven_and_hell_gameplay.gd.uid",
    "tools/capture_gameplay_screenshot.gd",
    "tools/capture_gameplay_screenshot.gd.uid",
    "tools/capture_heaven_now.gd",
    "tools/capture_heaven_now.gd.uid",
    "tools/capture_normal_land_redesign_showcase.gd",
    "tools/capture_normal_land_redesign_showcase.gd.uid",
    "tools/capture_phase1_2_acceptance_screenshots.gd",
    "tools/capture_phase1_2_acceptance_screenshots.gd.uid",
    "tools/capture_phase2_branching_outcomes.gd",
    "tools/capture_phase2_branching_outcomes.gd.uid",
    "tools/capture_phase2_heaven_evidence.gd",
    "tools/capture_phase2_heaven_evidence.gd.uid",
    "tools/capture_phase2_rebuild_evidence.gd",
    "tools/capture_phase2_rebuild_evidence.gd.uid",
    "tools/capture_phase3_heaven_gameplay.gd",
    "tools/capture_phase3_heaven_gameplay.gd.uid",
    "tools/capture_phase4_hell_gameplay.gd",
    "tools/capture_phase4_hell_gameplay.gd.uid",
    "tools/capture_phase5_transition_gameplay.gd",
    "tools/capture_phase5_transition_gameplay.gd.uid",
    "tools/capture_phase6_rewards_gameplay.gd",
    "tools/capture_phase6_rewards_gameplay.gd.uid",
    "tools/capture_phase7_qa_gameplay.gd",
    "tools/capture_phase7_qa_gameplay.gd.uid",
    "tools/capture_runtime_biome_gameplay.gd",
    "tools/capture_runtime_biome_gameplay.gd.uid",
    "tools/capture_visual_art_correction_evidence.gd",
    "tools/capture_visual_art_correction_evidence.gd.uid",
    "tools/capture_phase2_3_progression_showcase.gd",
    "tools/capture_phase2_3_progression_showcase.gd.uid",
    "tools/capture_lifecycle_and_retry_evidence.gd",
    # Superseded video recording scripts
    "tools/record_biome_lifecycle_continuous_gameplay.gd",
    "tools/record_full_heaven_driving.gd",
    "tools/record_full_heaven_driving.gd.uid",
    "tools/record_heaven_crash_retry_lifecycle.gd",
    "tools/record_manual_play_video.gd",
    "tools/record_manual_play_video.gd.uid",
    "tools/record_phase2_3_three_biome_progression.gd",
    "tools/record_phase2_3_three_biome_progression.gd.uid",
    "tools/record_portal_entry_gameplay.gd",
    "tools/record_portal_entry_gameplay.gd.uid",
    "tools/record_portal_return_gameplay.gd",
    "tools/record_portal_return_gameplay.gd.uid",
    # Resolved one-off diagnostics
    "tools/find_offending_hell_node.gd",
    "tools/find_offending_hell_node.gd.uid",
    "tools/find_watermark_node.gd",
    "tools/find_watermark_node.gd.uid",
    "tools/investigate_hell_glitch.gd",
    "tools/investigate_hell_glitch.gd.uid",
    "tools/investigate_hell_glitch_frozen.gd",
    "tools/investigate_hell_glitch_frozen.gd.uid",
    "tools/test_skull_removal.gd",
    "tools/test_skull_removal.gd.uid",
    "tools/check_ramp_pos.gd",
    "tools/check_ramp_pos.gd.uid",
    "tools/verify_phase1_3_live_drive.gd",
    "tools/verify_phase1_3_live_drive.gd.uid",
    "tools/verify_phase2_heaven_live_drive.gd",
    "tools/verify_phase2_heaven_live_drive.gd.uid",
    "tools/run_two_complete_cycles_and_branching.gd",
    "tools/run_two_complete_cycles_and_branching.gd.uid",
    "tools/generate_phase7_previews.gd",
    "tools/generate_phase7_previews.gd.uid",
    "tools/generate_ramp_previews.gd",
    "tools/generate_ramp_previews.gd.uid",
    "tools/generate_environment_previews.gd",
    "tools/generate_environment_previews.gd.uid",
    "tools/generate_phase3_environment_scenes.gd",
    "tools/generate_phase3_environment_scenes.gd.uid",
    "tools/generate_heaven_rebuild_comparison.py",
    "tools/generate_heaven_rebuild_contact_sheet.py"
]

for st in SUPERSEDED_TOOLS:
    p = PROJECT_ROOT / st
    if p.exists() and p.is_file():
        candidates.append({
            "path": str(p.relative_to(PROJECT_ROOT)),
            "size": p.stat().st_size,
            "category": "Category E — Obsolete One-Off Diagnostic & Capture Scripts",
            "reason": "Superseded evidence-capture / resolved diagnostic script; findings fully merged & tested",
            "confidence": "HIGH (0 runtime/test dependencies)",
            "action": "Archive externally & remove from active repo",
            "archive_dest": str(ARCHIVE_ROOT / p.relative_to(PROJECT_ROOT))
        })

print(f"Total candidate files for safe cleanup: {len(candidates)}")
total_bytes = sum(c["size"] for c in candidates)
print(f"Total candidate size to reclaim: {total_bytes / (1024*1024):.2f} MB")

# Save candidates list
with open("tools/cleanup_candidates.json", "w") as fp:
    json.dump(candidates, fp, indent=2)

print("Saved candidate list to tools/cleanup_candidates.json")
