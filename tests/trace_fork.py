import subprocess

bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]

for b in bikes:
    # Extract alpha
    p_body = f"assets/vehicles/garage/{b}/body.png"
    p_alpha = f"{b}_alpha.pgm"
    p_rgb = f"{b}_rgb.ppm"
    subprocess.run(["magick", p_body, "-alpha", "extract", p_alpha])
    subprocess.run(["magick", p_body, p_rgb])
    
    with open(p_alpha, "rb") as f:
        magic = f.readline().strip()
        dims = f.readline().strip().split()
        maxv = f.readline().strip()
        alpha_data = f.read()
    w, h = int(dims[0]), int(dims[1])
    
    with open(p_rgb, "rb") as f:
        f.readline(); f.readline(); f.readline()
        rgb_data = f.read()
        
    def get_alpha(x, y):
        if 0 <= x < w and 0 <= y < h:
            return alpha_data[y * w + x]
        return 0

    def get_rgb(x, y):
        if 0 <= x < w and 0 <= y < h:
            idx = (y * w + x) * 3
            return (rgb_data[idx], rgb_data[idx+1], rgb_data[idx+2])
        return (0, 0, 0)

    print(f"\n==================== BIKE {b} ({w}x{h}) ====================")
    # Search for fork tube in the front half: x in [w*0.5, w-1]
    # At each Y from y = int(h*0.5) to h-1, find continuous segments of opaque pixels (alpha > 128)
    # The fork tube is the forward-most narrow segment!
    fork_points = [] # (y, center_x, width)
    for y in range(int(h * 0.4), h):
        # find segments
        segments = []
        in_seg = False
        seg_start = 0
        for x in range(int(w * 0.5), w):
            a = get_alpha(x, y)
            if a > 100:
                if not in_seg:
                    in_seg = True
                    seg_start = x
            else:
                if in_seg:
                    in_seg = False
                    segments.append((seg_start, x - 1))
        if in_seg:
            segments.append((seg_start, w - 1))
            
        # The fork is the rightmost segment (or rightmost narrow segment)
        if segments:
            # check the rightmost segment
            rx0, rx1 = segments[-1]
            seg_w = rx1 - rx0 + 1
            cx = (rx0 + rx1) / 2.0
            fork_points.append((y, cx, seg_w, rx0, rx1))
            
    # Print the bottom-most fork points
    print("Bottom 25 rows of rightmost front structure (fork):")
    for y, cx, seg_w, rx0, rx1 in fork_points[-25:]:
        print(f"  Y={y:3d}: fork_x=[{rx0:3d}..{rx1:3d}], width={seg_w:2d}, center_x={cx:5.1f}")
