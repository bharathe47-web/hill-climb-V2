import subprocess

bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]

# Let's inspect each bike's body image to find:
# 1. Front fork stanchion line and bottom end (axle point)
# 2. Rear swingarm and axle point

for b in bikes:
    print(f"\n=======================================================")
    print(f"MEASURING AXLE POINTS FOR {b}")
    print(f"=======================================================")
    
    # We can use magick to create an image showing the fork with coordinates
    # Let's find the dimensions
    dim = subprocess.check_output(["magick", "identify", "-format", "%w %h", f"assets/vehicles/garage/{b}/body.png"]).decode().split()
    w, h = int(dim[0]), int(dim[1])
    pivot_x = w / 2.0
    pivot_y = h / 2.0
    print(f"Image size: {w}x{h}, Pivot: ({pivot_x}, {pivot_y})")
    
    # Let's crop the front-lower area and rear-lower area and analyze
