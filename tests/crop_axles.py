import subprocess

# We will locate the exact pixels of the axle circles/dropouts:
# Let us define approximate windows based on the images we just saw:
bike_windows = {
    "car_14": {
        "front": (710, 755, 345, 390), # fork tip
        "rear": (160, 205, 330, 370),  # swingarm nut
    },
    "car_15": {
        "front": (890, 935, 325, 370), # fork tip eyelet
        "rear": (130, 210, 300, 350),  # rear axle
    },
    "car_16": {
        "front": (625, 665, 320, 360), # fork tip clamp
        "rear": (155, 195, 340, 380),  # swingarm nut
    },
    "car_17": {
        "front": (730, 775, 345, 395), # fork tip
        "rear": (140, 180, 355, 395),  # swingarm nut
    },
    "car_24": {
        "front": (755, 795, 440, 485), # fork tip clamp
        "rear": (130, 210, 450, 490),  # rear axle
    },
    "car_25": {
        "front": (750, 790, 255, 300), # fork tip
        "rear": (180, 215, 260, 295),  # round axle boss
    }
}

for b, win in bike_windows.items():
    fx0, fx1, fy0, fy1 = win["front"]
    rx0, rx1, ry0, ry1 = win["rear"]
    
    # Crop front and rear
    subprocess.run(["magick", f"assets/vehicles/garage/{b}/body.png", "-crop", f"{fx1-fx0}x{fy1-fy0}+{fx0}+{fy0}", f"crop_{b}_front.png"])
    subprocess.run(["magick", f"assets/vehicles/garage/{b}/body.png", "-crop", f"{rx1-rx0}x{ry1-ry0}+{rx0}+{ry0}", f"crop_{b}_rear.png"])
    print(f"Cropped {b}: front {fx0}..{fx1}, {fy0}..{fy1} | rear {rx0}..{rx1}, {ry0}..{ry1}")
