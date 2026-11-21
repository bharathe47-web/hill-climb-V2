import subprocess

bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]

for b in bikes:
    p_alpha = f"{b}_alpha.pgm"
    with open(p_alpha, "rb") as f:
        magic = f.readline().strip()
        dims = f.readline().strip().split()
        maxv = f.readline().strip()
        alpha_data = f.read()
    w, h = int(dims[0]), int(dims[1])
    
    def get_alpha(x, y):
        if 0 <= x < w and 0 <= y < h:
            return alpha_data[y * w + x]
        return 0

    print(f"\n==================== FORK PROFILE {b} ({w}x{h}) ====================")
    # The fork tube runs through the front-right of the bike
    # Let's inspect rows every 10 pixels from y = int(h*0.4) to h-1
    for y in range(int(h * 0.4), h, 8):
        # find rightmost segment
        segments = []
        in_seg = False
        seg_start = 0
        for x in range(int(w * 0.4), w):
            if get_alpha(x, y) > 100:
                if not in_seg:
                    in_seg = True
                    seg_start = x
            else:
                if in_seg:
                    in_seg = False
                    segments.append((seg_start, x - 1))
        if in_seg:
            segments.append((seg_start, w - 1))
        if segments:
            # rightmost
            rx0, rx1 = segments[-1]
            print(f"  y={y:3d}: rightmost=[{rx0:3d}..{rx1:3d}], w={rx1-rx0+1:3d}, cx={(rx0+rx1)/2.0:5.1f}")
