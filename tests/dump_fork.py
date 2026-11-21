import subprocess

# Let's inspect the fork end in high resolution
# We will print out the exact RGB/alpha of pixels in the fork tip region
def dump_region(bike, x_range, y_range):
    cmd = f"magick assets/vehicles/garage/{bike}/body.png -crop {x_range[1]-x_range[0]}x{y_range[1]-y_range[0]}+{x_range[0]}+{y_range[0]} txt:-"
    proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, text=True)
    grid = {}
    for line in proc.stdout:
        if line.startswith("#"): continue
        xy, rest = line.split(":", 1)
        x_str, y_str = xy.split(",")
        lx, ly = int(x_str), int(y_str)
        gx = x_range[0] + lx
        gy = y_range[0] + ly
        if "none" not in rest and ",0)" not in rest and ",0.0" not in rest:
            grid[(gx, gy)] = 1
        else:
            grid[(gx, gy)] = 0
            
    print(f"Region X={x_range}, Y={y_range} for {bike}:")
    for y in range(y_range[0], y_range[1], 2):
        row = []
        for x in range(x_range[0], x_range[1], 2):
            row.append("#" if grid.get((x, y), 0) else ".")
        print(f"{y:3d} " + "".join(row))

# Let's inspect car_14 fork tip:
# We know fork tip is around x=600..620, y=410..422, but wait! Does the fork go from upper-left to lower-right?
# Let's see where the fork tube is!
dump_region("car_14", (550, 650), (320, 422))
