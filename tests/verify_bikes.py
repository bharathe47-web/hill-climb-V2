import subprocess

measured = {
    "car_14": {"rx": 177.0, "ry": 345.0, "fx": 737.0, "fy": 358.0, "wr": 128.0},
    "car_15": {"rx": 132.0, "ry": 262.5, "fx": 899.0, "fy": 337.0, "wr": 132.5},
    "car_16": {"rx": 123.0, "ry": 354.0, "fx": 636.5, "fy": 336.5, "wr": 137.5},
    "car_17": {"rx": 141.5, "ry": 382.5, "fx": 747.5, "fy": 371.0, "wr": 127.5},
    "car_24": {"rx": 146.0, "ry": 401.5, "fx": 773.5, "fy": 459.5, "wr": 108.5},
    "car_25": {"rx": 199.0, "ry": 284.0, "fx": 776.0, "fy": 279.0, "wr": 120.5},
}

for b, m in measured.items():
    p_body = f"assets/vehicles/garage/{b}/body.png"
    rx, ry, fx, fy, wr = m["rx"], m["ry"], m["fx"], m["fy"], m["wr"]
    cmd = [
        "magick", p_body,
        "-stroke", "green", "-strokewidth", "3", "-fill", "none",
        "-draw", f"circle {rx},{ry} {rx+wr},{ry}",
        "-draw", f"circle {fx},{fy} {fx+wr},{fy}",
        "-stroke", "red", "-fill", "red",
        "-draw", f"circle {rx},{ry} {rx+4},{ry}",
        "-draw", f"circle {fx},{fy} {fx+4},{fy}",
        f"verified_{b}.png"
    ]
    subprocess.run(cmd)
    print(f"Generated verified_{b}.png")
