import subprocess

bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]

for b in bikes:
    p_img = f"assets/vehicles/garage/{b}/{b}.png"
    p_wheel = f"assets/vehicles/garage/{b}/wheel.png"
    
    # Read image dimensions
    dim_img = subprocess.check_output(["magick", "identify", "-format", "%w %h", p_img]).decode().split()
    iw, ih = int(dim_img[0]), int(dim_img[1])
    
    dim_w = subprocess.check_output(["magick", "identify", "-format", "%w %h", p_wheel]).decode().split()
    ww, wh = int(dim_w[0]), int(dim_w[1])
    wr_x = ww / 2.0
    wr_y = wh / 2.0
    
    # Split car_xx.png into left half (rear) and right half (front)
    half_w = iw // 2
    subprocess.run(["magick", p_img, "-crop", f"{half_w}x{ih}+0+0", f"rear_half_{b}.png"])
    subprocess.run(["magick", p_img, "-crop", f"{iw - half_w}x{ih}+{half_w}+0", f"front_half_{b}.png"])
    
    # Match rear wheel
    cmd_r = ["magick", "compare", "-metric", "RMSE", "-subimage-search", f"rear_half_{b}.png", p_wheel, "match_r.png"]
    proc_r = subprocess.run(cmd_r, capture_output=True, text=True)
    # Output: "... @ rx,ry ..."
    err_r = proc_r.stderr.strip()
    idx_at_r = err_r.find("@")
    coord_r = err_r[idx_at_r+2:].split()[0].split(",")
    rx_tl, ry_tl = int(coord_r[0]), int(coord_r[1])
    r_cx = rx_tl + wr_x
    r_cy = ry_tl + wr_y
    
    # Match front wheel
    cmd_f = ["magick", "compare", "-metric", "RMSE", "-subimage-search", f"front_half_{b}.png", p_wheel, "match_f.png"]
    proc_f = subprocess.run(cmd_f, capture_output=True, text=True)
    err_f = proc_f.stderr.strip()
    idx_at_f = err_f.find("@")
    coord_f = err_f[idx_at_f+2:].split()[0].split(",")
    fx_tl, fy_tl = int(coord_f[0]), int(coord_f[1])
    f_cx = half_w + fx_tl + wr_x
    f_cy = fy_tl + wr_y
    
    pivot_x = iw / 2.0
    pivot_y = ih / 2.0
    
    r_off_x = round(r_cx - pivot_x, 1)
    r_off_y = round(r_cy - pivot_y, 1)
    f_off_x = round(f_cx - pivot_x, 1)
    f_off_y = round(f_cy - pivot_y, 1)
    
    print(f"BIKE {b} ({iw}x{ih}, pivot: {pivot_x}, {pivot_y}):")
    print(f"  Rear wheel center in image: ({r_cx:.1f}, {r_cy:.1f}) -> offset: ({r_off_x}, {r_off_y})")
    print(f"  Front wheel center in image: ({f_cx:.1f}, {f_cy:.1f}) -> offset: ({f_off_x}, {f_off_y})")
    print(f"  Wheel radius: {(ww+wh)/4.0:.1f} (size: {ww}x{wh})")
