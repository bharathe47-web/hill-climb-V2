import subprocess

# Let us find the exact wheel centers and radii from car_xx.png
bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]

for b in bikes:
    p_img = f"assets/vehicles/garage/{b}/{b}.png"
    p_wheel = f"assets/vehicles/garage/{b}/wheel.png"
    
    # Read wheel size
    dim_w = subprocess.check_output(["magick", "identify", "-format", "%w %h", p_wheel]).decode().split()
    ww, wh = int(dim_w[0]), int(dim_w[1])
    wheel_radius = (ww + wh) / 4.0
    
    # We will use template matching / normalized cross-correlation or circular Hough/edge detection
    # Even simpler: in car_xx.png, where is the wheel?
    # Let's find using magick compare / subimage-search!
    # magick car_xx.png wheel.png -subimage-search -metric RMSE match.png
    cmd = ["magick", "compare", "-metric", "RMSE", "-subimage-search", p_img, p_wheel, "match.png"]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    # Output gives error and location e.g. "1234 (0.01) @ 512,180"
    print(f"{b} (wheel radius {wheel_radius:.1f}):", proc.stderr.strip())
