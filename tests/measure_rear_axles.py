import subprocess

bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]

for b in bikes:
    dim = subprocess.check_output(["magick", "identify", "-format", "%w %h", f"assets/vehicles/garage/{b}/body.png"]).decode().split()
    w, h = int(dim[0]), int(dim[1])
    
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
            
    # Rear region: x < w * 0.45, y > h * 0.45
    rear_pixels = [(x, y) for (x, y) in pixels if x < w * 0.45 and y > h * 0.45]
    y_to_x_rear = {}
    for x, y in rear_pixels:
        y_to_x_rear.setdefault(y, []).append(x)
        
    print(f"\n==================== REAR MEASUREMENT FOR {b} ({w}x{h}) ====================")
    # Check lowest Y or furthest left X
    # In rear swingarm: the rear axle is at the rear dropouts (near the rear-most / lowest point of swingarm)
    # Let's inspect lowest Y in rear:
    for y in sorted(y_to_x_rear.keys(), reverse=True)[:15]:
        xs = y_to_x_rear[y]
        print(f"  Rear Y={y:3d}: count={len(xs):2d}, x in [{min(xs):3d}, {max(xs):3d}], center_x={(min(xs)+max(xs))/2.0:5.1f}")
        
    # Also let's check furthest left X in rear:
    x_to_y_rear = {}
    for x, y in rear_pixels:
        x_to_y_rear.setdefault(x, []).append(y)
    for x in sorted(x_to_y_rear.keys())[:15]:
        ys = x_to_y_rear[x]
        print(f"  Rear X={x:3d}: count={len(ys):2d}, y in [{min(ys):3d}, {max(ys):3d}], center_y={(min(ys)+max(ys))/2.0:5.1f}")
