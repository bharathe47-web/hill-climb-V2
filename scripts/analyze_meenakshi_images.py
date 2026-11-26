import subprocess

files = [
    "/home/joel/Downloads/Pasted image.png",
    "/home/joel/Downloads/meenakshi_tower_source_2.jpg.jpeg",
    "Tamil_Nadu_2D_Assets (2)/Temples/unnamed.png",
    "assets/indian_locations/tamil_nadu/landmarks/tamil_nadu_meenakshi_gopuram_vector.png",
    "assets/indian_locations/tamil_nadu_madurai_meenakshi_temple.png"
]

for f in files:
    res = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "stream=width,height,codec_name", "-of", "csv=p=0", f], capture_output=True, text=True)
    print(f"{f}: {res.stdout.strip()}")
