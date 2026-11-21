#!/usr/bin/env python3
"""
build_asset_collection_v2.py
Author: Joel (Senior Godot 4.7 Developer, Technical Artist & Art Director)
Master orchestration script to generate the complete Six-State Asset Collection V2:
  1. Tamil Nadu (Kanyakumari, Madurai, Chennai)
  2. Goa (Panaji, Old Goa, North Goa, South Goa, Inland Goa)
  3. Kerala (Kochi, Alappuzha, Munnar, Wayanad)
  4. Rajasthan (Jaipur, Jodhpur, Udaipur, Jaisalmer)
  5. Gujarat (Ahmedabad, Modhera, Kutch, Dwarka)
  6. Telangana (Hyderabad, Warangal, Ramappa)
  7. Shared (Road props, barriers, signs, generic vegetation, textures)
"""

import os
import sys
import subprocess

def run_script(script_name):
    cmd = [sys.executable, os.path.join("scripts/generation", script_name)]
    print(f"\n>>> Running {script_name} <<<")
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"Error running {script_name}:\n{res.stderr}")
        sys.exit(1)
    else:
        print(res.stdout.strip())

def main():
    print("=================================================================")
    print("--- BUILDING MASTER INDIAN ROADS ASSET COLLECTION V2 ---")
    print("=================================================================")

    scripts = [
        "gen_v2_tamil_nadu.py",
        "gen_v2_goa.py",
        "gen_v2_kerala.py",
        "gen_v2_rajasthan.py",
        "gen_v2_gujarat.py",
        "gen_v2_telangana.py",
        "gen_v2_shared.py"
    ]

    for s in scripts:
        run_script(s)

    # Count generated files
    base = "assets/indian_locations/asset_collection_v2"
    total_files = 0
    total_pngs = 0
    for root, dirs, files in os.walk(base):
        for f in files:
            total_files += 1
            if f.endswith(".png"):
                total_pngs += 1

    print("\n=================================================================")
    print(f"ASSET COLLECTION V2 COMPLETE: {total_pngs} PNGs across {total_files} total files!")
    print(f"Root Directory: {base}")
    print("=================================================================")

if __name__ == "__main__":
    main()
