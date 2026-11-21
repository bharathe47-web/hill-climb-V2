import subprocess

bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]

for b in bikes:
    # Read edges
    cmd = f"magick edges_{b}.png txt:-"
    proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, text=True)
    header = proc.stdout.readline()
    
    edge_pts = []
    dim = subprocess.check_output(["magick", "identify", "-format", "%w %h", f"assets/vehicles/garage/{b}/body.png"]).decode().split()
    w, h = int(dim[0]), int(dim[1])
    for line in proc.stdout:
        if line.startswith("#"): continue
        xy, rest = line.split(":", 1)
        if "(0,0,0" in rest or "none" in rest or "black" in rest: continue
        x, y = [int(v) for v in xy.split(",")]
        edge_pts.append((x, y))
        
    print(f"\n==================== BIKE {b} ({w}x{h}) ====================")
    
    # Front fork edges: x in [w*0.5, w], y in [h*0.4, h]
    front_edges = [(x, y) for (x, y) in edge_pts if x > w * 0.5 and y > h * 0.4]
    # Rear swingarm edges: x in [0, w*0.4], y in [h*0.4, h]
    rear_edges = [(x, y) for (x, y) in edge_pts if x < w * 0.4 and y > h * 0.4]
    
    # Sort front edges by Y
    front_by_y = {}
    for x, y in front_edges:
        front_by_y.setdefault(y, []).append(x)
        
    rear_by_y = {}
    for x, y in rear_edges:
        rear_by_y.setdefault(y, []).append(x)
        
    # Find the bottom of the fork:
    # Look at the bottom 15 rows with edge points in the front
    sorted_fy = sorted(front_by_y.keys(), reverse=True)
    print("Front fork bottom edges:")
    for y in sorted_fy[:12]:
        xs = sorted(front_by_y[y])
        print(f"  y={y:3d}: xs={xs}")
        
    # Also find rear axle: in the rear, look at the furthest left points (smallest x)
    rear_by_x = {}
    for x, y in rear_edges:
        rear_by_x.setdefault(x, []).append(y)
    sorted_rx = sorted(rear_by_x.keys())
    print("Rear swingarm rear-most edges (smallest X):")
    for x in sorted_rx[:12]:
        ys = sorted(rear_by_x[x])
        print(f"  x={x:3d}: ys={ys}")
