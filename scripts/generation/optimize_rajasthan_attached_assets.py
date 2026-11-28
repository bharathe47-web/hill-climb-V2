#!/usr/bin/env python3
"""
Preserve original 2048px Rajasthan 2D assets inside 'Rajasthan_2D_Assets(1)/Rajasthan_2D_Assets/'
and export cropped, ground-flush (4px bottom margin), mobile-optimized RGBA PNG copies into
assets/indian_locations/rajasthan/v3/landmarks/.
"""

import glob
import os
import cairo

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SRC_DIR = os.path.join(ROOT, "Rajasthan_2D_Assets(1)", "Rajasthan_2D_Assets")
DST_DIR = os.path.join(ROOT, "assets", "indian_locations", "rajasthan", "v3", "landmarks")
MAX_DIM = 460


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

    # Add tiny padding in source space before scaling; target bottom pad ends up ~3-4px
    src_pad_side = 12
    cw = (max_x - min_x + 1) + src_pad_side * 2
    ch = (max_y - min_y + 1) + src_pad_side * 2

    scale = min(1.0, float(MAX_DIM) / float(max(cw, ch)))
    out_w = max(1, int(round(cw * scale)))
    out_h = max(1, int(round(ch * scale)))

    x0 = min_x - src_pad_side
    y0 = min_y - src_pad_side

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
    return (w, h), (out_w, out_h)


def main():
    os.makedirs(DST_DIR, exist_ok=True)
    for src_path in sorted(glob.glob(os.path.join(SRC_DIR, "*", "*.png"))):
        if "PREVIEW" in src_path:
            continue
        fname = os.path.basename(src_path)
        dst_path = os.path.join(DST_DIR, fname)
        orig_sz, out_sz = optimize_png(src_path, dst_path)
        orig_kb = os.path.getsize(src_path) / 1024.0
        new_kb = os.path.getsize(dst_path) / 1024.0
        print(f"Optimized {fname:28s}: {orig_sz} ({orig_kb:.1f}KB) -> {out_sz} ({new_kb:.1f}KB)")


if __name__ == "__main__":
    main()
