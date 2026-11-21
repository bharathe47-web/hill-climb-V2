import subprocess

# Let us generate an annotated image for each bike
bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]

configs = {
    "car_14": {"rx": 187.0, "ry": 349.5, "fx": 643.0, "fy": 349.5, "wr": 128.0},
    "car_15": {"rx": 132.5, "ry": 322.0, "fx": 776.0, "fy": 322.0, "wr": 132.5},
    "car_16": {"rx": 124.5, "ry": 336.5, "fx": 565.5, "fy": 336.5, "wr": 137.5},
    "car_17": {"rx": 129.5, "ry": 370.5, "fx": 674.5, "fy": 370.5, "wr": 127.5},
    "car_24": {"rx": 144.5, "ry": 469.0, "fx": 687.0, "fy": 469.0, "wr": 108.5},
    "car_25": {"rx": 163.5, "ry": 275.0, "fx": 690.5, "fy": 275.0, "wr": 120.5},
}

for b in bikes:
    p_body = f"assets/vehicles/garage/{b}/body.png"
    p_wheel = f"assets/vehicles/garage/{b}/wheel.png"
    cfg = configs[b]
    rx, ry, fx, fy, wr = cfg["rx"], cfg["ry"], cfg["fx"], cfg["fy"], cfg["wr"]
    
    # Let's draw:
    # 1) circle at (rx, ry) radius wr
    # 2) circle at (fx, fy) radius wr
    # 3) dot at (rx, ry)
    # 4) dot at (fx, fy)
    cmd = [
        "magick", p_body,
        "-stroke", "green", "-strokewidth", "3", "-fill", "none",
        "-draw", f"circle {rx},{ry} {rx+wr},{ry}",
        "-draw", f"circle {fx},{fy} {fx+wr},{fy}",
        "-stroke", "red", "-fill", "red",
        "-draw", f"circle {rx},{ry} {rx+4},{ry}",
        "-draw", f"circle {fx},{fy} {fx+4},{fy}",
        f"annotated_{b}.png"
    ]
    subprocess.run(cmd)
    print(f"Generated annotated_{b}.png")
