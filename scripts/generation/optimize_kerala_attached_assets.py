#!/usr/bin/env python3
"""
Preserve original attached Kerala landmark PNGs in nigra/ ("nigga/") untouched,
and generate trimmed, ground-flush, resolution-optimized transparent PNGs into
assets/indian_locations/kerala/v3/attached_landmarks/.
"""

import glob
import math
import os
import cairo

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SRC_DIR = os.path.join(ROOT, "nigga")
DST_DIR = os.path.join(ROOT, "assets", "indian_locations", "kerala", "v3", "attached_landmarks")
MAX_DIM = 380


def optimize_png(src_path: str, dst_path: str) -> tuple:
    src = cairo.ImageSurface.create_from_png(src_path)
    w, h = src.get_width(), src.get_height()
    data = src.get_data()
    stride = src.get_stride()

    min_x, min_y, max_x, max_y = w, h, -1, -1
    for y in range(h):
        row = y * stride
        for x in range(w):
            if data[row + x * 4 + 3] > 6:
                if x < min_x:
                    min_x = x
                if x > max_x:
                    max_x = x
                if y < min_y:
                    min_y = y
                if y > max_y:
                    max_y = y

    if max_x < min_x or max_y < min_y:
        min_x, min_y, max_x, max_y = 0, 0, w - 1, h - 1

    # Add clean 4px horizontal/top/bottom padding so outline & ground shadow stay crisp and flush
    x0 = max(0, min_x - 4)
    y0 = max(0, min_y - 4)
    x1 = min(w - 1, max_x + 4)
    y1 = min(h - 1, max_y + 3)

    cw = x1 - x0 + 1
    ch = y1 - y0 + 1

    scale = min(1.0, float(MAX_DIM) / float(max(cw, ch)))
    out_w = max(1, int(round(cw * scale)))
    out_h = max(1, int(round(ch * scale)))

    out_surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, out_w, out_h)
    ctx = cairo.Context(out_surf)
    ctx.set_operator(cairo.OPERATOR_SOURCE)
    ctx.set_source_rgba(0, 0, 0, 0)
    ctx.paint()

    ctx.set_operator(cairo.OPERATOR_OVER)
    ctx.scale(scale, scale)
    ctx.set_source_surface(src, -x0, -y0)
    ctx.get_source().set_filter(cairo.FILTER_BEST)
    ctx.paint()

    out_surf.write_to_png(dst_path)
    return (w, h), (cw, ch), (out_w, out_h)


def main():
    os.makedirs(DST_DIR, exist_ok=True)
    for src_path in sorted(glob.glob(os.path.join(SRC_DIR, "*.png"))):
        fname = os.path.basename(src_path)
        dst_path = os.path.join(DST_DIR, fname)
        orig_sz, crop_sz, out_sz = optimize_png(src_path, dst_path)
        orig_kb = os.path.getsize(src_path) / 1024.0
        new_kb = os.path.getsize(dst_path) / 1024.0
        print(f"Optimized {fname:32s}: orig={orig_sz} ({orig_kb:.1f}KB) -> crop={crop_sz} -> out={out_sz} ({new_kb:.1f}KB)")


if __name__ == "__main__":
    main()
