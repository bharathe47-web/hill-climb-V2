import subprocess

bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]

# Current configs
configs = {
    "car_14": {"rx": 187.0, "ry": 349.5, "fx": 643.0, "fy": 349.5},
    "car_15": {"rx": 132.5, "ry": 322.0, "fx": 776.0, "fy": 322.0},
    "car_16": {"rx": 124.5, "ry": 336.5, "fx": 565.5, "fy": 336.5},
    "car_17": {"rx": 129.5, "ry": 370.5, "fx": 674.5, "fy": 370.5},
    "car_24": {"rx": 144.5, "ry": 469.0, "fx": 687.0, "fy": 469.0},
    "car_25": {"rx": 163.5, "ry": 275.0, "fx": 690.5, "fy": 275.0},
}

for b in bikes:
    print(f"==================== {b} ====================")
    fx = configs[b]["fx"]
    fy = configs[b]["fy"]
    rx = configs[b]["rx"]
    ry = configs[b]["ry"]
    print(f"Current Config -> Front: ({fx}, {fy}), Rear: ({rx}, {ry})")
    
    # Let's inspect a 100x100 grid around (fx, fy) and around (rx, ry)
    # Using magick txt
    # Crop front
    crop_f = f"120x120+{int(fx-60)}+{int(fy-60)}"
    cmd = f"magick assets/vehicles/garage/{b}/body.png -crop {crop_f} txt:-"
    proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, text=True)
    lines = proc.stdout.readlines()
    
    # Downsample by 4 to print a 30x30 ascii grid
    grid = [[" " for _ in range(30)] for _ in range(30)]
    for line in lines[1:]:
        xy, rest = line.split(":", 1)
        x_str, y_str = xy.split(",")
        x, y = int(x_str), int(y_str)
        # local within crop:
        gx = x // 4
        gy = y // 4
        if "none" not in rest and ",0)" not in rest and ",0.0" not in rest:
            if 0 <= gx < 30 and 0 <= gy < 30:
                grid[gy][gx] = "#"
    
    # Mark the center (15, 15) which corresponds to (fx, fy)
    if grid[15][15] == " ":
        grid[15][15] = "+"
    else:
        grid[15][15] = "@"
        
    print(f"--- FRONT FORK REGION (center +/@ is current fx={fx}, fy={fy}) ---")
    for row in grid:
        print("".join(row))
