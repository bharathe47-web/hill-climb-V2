# Python script to locate the exact centers of the axle markers in each crop
import subprocess

def find_feature_center(bike, part, crop_x0, crop_y0, crop_w, crop_h, target_type):
    # Read cropped pixel data
    cmd = f"magick assets/vehicles/garage/{bike}/body.png -crop {crop_w}x{crop_h}+{crop_x0}+{crop_y0} txt:-"
    out = subprocess.check_output(cmd.split(), text=True)
    
    # Store pixels
    pixels = {}
    for line in out.splitlines():
        if line.startswith("#"): continue
        xy, rest = line.split(":", 1)
        lx, ly = [int(v) for v in xy.split(",")]
        # Extract RGB
        if "none" in rest: continue
        # Parse (r,g,b,a)
        start = rest.find("(")
        end = rest.find(")")
        vals = [float(v) for v in rest[start+1:end].split(",")[:3]]
        pixels[(lx, ly)] = vals

    # For car_14 front: look for the round lighter grey circle inside the black clamp
    # For car_14 rear: look for the black hole in the center of the hexagonal nut
    # For car_15 front: look for the center of the round eyelet at the tip of the chrome fork
    # For car_16 front: look for the round hole/circle at the tip of the fork
    # For car_16 rear: look for the black hole in the center of the hexagonal nut
    # For car_17 front: look for the rounded bottom center of the fork stanchion
    # For car_17 rear: look for the black hole in the nut
    # For car_24 front: look for the axle cylinder end
    # For car_25 front: look for the silver axle cylinder center
    # For car_25 rear: look for the round axle boss circle center
    return pixels

# Let us find exact pixel coordinates for each bike
print("Measuring exact axle coordinates...")
