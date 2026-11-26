import subprocess, os

# Let's inspect some frames from /tmp/screencast_frames/
# We can use tesseract or check what OCR is available, or use godot to inspect colors/regions
res = subprocess.run(["which", "tesseract"], capture_output=True, text=True)
has_tesseract = (res.returncode == 0)
print("Has tesseract:", has_tesseract)

# Let's see file sizes and sample frames
frames = sorted(os.listdir("/tmp/screencast_frames"))
print(f"Total extracted frames: {len(frames)}")

# Sample every 10 frames
for i in range(1, 115, 10):
    fname = f"/tmp/screencast_frames/frame_{i:03d}.png"
    if os.path.exists(fname):
        print(f"Frame at {i}s: {fname} (size: {os.path.getsize(fname)} bytes)")
