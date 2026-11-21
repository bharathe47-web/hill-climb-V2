import subprocess

bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]

for b in bikes:
    print(f"\n==================== DETAILED MEASUREMENT FOR {b} ====================")
    # Get image dimensions
    dim = subprocess.check_output(["magick", "identify", "-format", "%w %h", f"assets/vehicles/garage/{b}/body.png"]).decode().split()
    w, h = int(dim[0]), int(dim[1])
    
    # We will read all non-transparent pixels
    cmd = f"magick assets/vehicles/garage/{b}/body.png txt:-"
    proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, text=True)
    header = proc.stdout.readline()
    
    pixels = {}
    for line in proc.stdout:
        if line.startswith("#"): continue
        xy, rest = line.split(":", 1)
        x_str, y_str = xy.split(",")
        x, y = int(x_str), int(y_str)
        if "none" not in rest and ",0)" not in rest and ",0.0" not in rest:
            pixels[(x, y)] = rest.strip()
            
    print(f"Loaded {len(pixels)} non-transparent pixels for {b} ({w}x{h})")
    
    # Let us analyze the front fork:
    # A fork is a slanted strut going down to the front wheel axle dropout/tip.
    # Let us inspect the lowest part of the fork.
    # Where does the fork terminate?
    # Let us find all pixels in the front bottom region: x in [w*0.5, w], y in [h*0.5, h]
    front_pixels = [(x, y) for (x, y) in pixels if x > w * 0.5 and y > h * 0.5]
    
    # In this region, what are the pixels with the highest Y (lowest vertically)?
    # Group by Y
    y_to_x = {}
    for x, y in front_pixels:
        y_to_x.setdefault(y, []).append(x)
        
    sorted_y = sorted(y_to_x.keys(), reverse=True)
    print("Lowest 20 Y rows in front region:")
    for y in sorted_y[:20]:
        xs = y_to_x[y]
        print(f"  Y={y:3d}: count={len(xs):2d}, x in [{min(xs):3d}, {max(xs):3d}], center_x={(min(xs)+max(xs))/2.0:5.1f}")
