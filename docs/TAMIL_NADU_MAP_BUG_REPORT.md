# TAMIL NADU ROUTE MAP BUG AUDIT & MATHEMATICAL FIX REPORT
**Project:** Hill Climb V2 — Indian Roads Mode  
**Engine:** Godot 4.7 (`v4.7.2.stable.arch_linux.ed1daf0bf`)  
**Branch:** `feature/joel-roads-obstacles`  
**Author:** Joel (Senior Gameplay Engineer & UI/UX Specialist)  
**Date:** November 18, 2026  
**Status:** **VERIFIED COMPLETE (100% PASS)**

---

## 1. Defect Overview

The user reported that the in-game tourism route map for Tamil Nadu had several critical issues:
1. The route progression line and waypoint pins did not accurately match the geographical shape of Tamil Nadu.
2. Waypoint markers jumped or drifted away from their true locations as the vehicle drove forward.
3. Key milestones (such as the Thiruvalluvar Statue and Kanyakumari Glass Bridge) were incorrectly aligned or omitted from the map's geometry list.
4. The route map canvas did not account for aspect ratio letterboxing within the `TextureRect`, distorting coordinates across different screen sizes.

---

## 2. Root Cause Analysis

### 2.1 The Aspect-Ratio Pillarboxing Disconnect
The `StateMapRect` is configured with:
```gdscript
expand_mode = 1 (EXPAND_IGNORE_SIZE)
stretch_mode = 5 (STRETCH_KEEP_ASPECT_CENTERED)
```
The Tamil Nadu state SVG ([tamil_nadu_state_map.svg](file:///home/joel/Documents/game/hill-climb-V2/assets/indian_locations/tamil_nadu_state_map.svg)) has intrinsic dimensions of $1500 \times 1615$ pixels (aspect ratio $\approx 0.928$).

However, the overlay drawing canvas (`_route_canvas`) was attached to fill the entire container bounds:
```gdscript
_route_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
```
When rendering on a 16:9 display, the container size is $340 \times 440$. The map graphic is scaled down to $340 \times 366$ and centered vertically with a 37px top/bottom pillarbox margin. 

The previous code mapped normalized coordinates directly onto `_route_canvas.size`:
```gdscript
# PREVIOUS BUGGY CODE:
screen_points.append(Vector2(norm_pos.x * canvas_sz.x, norm_pos.y * canvas_sz.y))
```
Because it ignored the vertical offset and scaling of the actual texture, every point on the map was shifted downward by $\approx 37\text{px}$, causing the southern tip (Kanyakumari) to draw completely outside the state boundary into the dark modal background.

### 2.2 Polyline Pixel Length vs Metric Distance Distortion
Previously, player progression along the route line was calculated by:
```gdscript
# PREVIOUS BUGGY CODE:
var target_pixel_dist := total_poly_len * progress_t
# where progress_t = current_dist_m / total_m
```
This assumed that the pixel length between every point on the 2D map was directly proportional to the highway road distance in the driving game. In reality:
- Kanyakumari to Glass Bridge is only $270\text{m}$, but spanned 60 pixels.
- Glass Bridge to Thiruvalluvar Statue is $145\text{m}$, but spanned 30 pixels.
- Thiruvalluvar to Madurai Checkpoint is $185\text{m}$, but spanned 110 pixels.

Because the pixel distance ratio did not equal the meter distance ratio, the player pin moved at non-linear, unpredictable speeds and did not land on the waypoint pins when the player arrived at the actual in-game milestones!

### 2.3 Inconsistent Stop Definitions
In [RouteRegistry.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/modes/indian_roads/RouteRegistry.gd#L116), the official Tamil Nadu route stops are:
1. `Kanyakumari` ($0\text{m}$)
2. `Kanyakumari Glass Bridge` ($270\text{m}$)
3. `Thiruvalluvar Statue` ($415\text{m}$)
4. `Madurai Checkpoint` ($600\text{m}$)
5. `NH44 Highway Junction` ($850\text{m}$)
6. `Chennai Marina Beach` ($1100\text{m}$)

In contrast, the previous `STATE_ROUTE_GEOMETRY["tamil_nadu"]` contained placeholder stops:
`["Kanyakumari", "Glass Bridge", "Madurai CP", "Trichy", "Chengalpattu", "Chennai"]`
`Thiruvalluvar Statue` was omitted, and `Trichy` and `Chengalpattu` did not correspond to any registered game waypoint, causing a complete mismatch between the left map panel and the right waypoint milestone list.

---

## 3. Mathematical & Architectural Solution

### 3.1 Dynamic Aspect-Fitted Bounding Box Computation
In [RouteMapOverlay.gd](file:///home/joel/Documents/game/hill-climb-V2/scripts/modes/indian_roads/RouteMapOverlay.gd#L164), we calculate the exact geometry rect of the visible SVG graphic within the `TextureRect`:
```gdscript
var map_rect := Rect2(Vector2.ZERO, canvas_sz)
if is_instance_valid(state_map_rect) and state_map_rect.texture:
    var tex_sz := state_map_rect.texture.get_size()
    if tex_sz.x > 0.0 and tex_sz.y > 0.0:
        var scale_f := minf(canvas_sz.x / tex_sz.x, canvas_sz.y / tex_sz.y)
        var fitted_sz := tex_sz * scale_f
        var fitted_pos := (canvas_sz - fitted_sz) * 0.5
        map_rect = Rect2(fitted_pos, fitted_sz)

var screen_points := PackedVector2Array()
for item in geom_list:
    var norm_pos: Vector2 = item["pos"]
    screen_points.append(map_rect.position + Vector2(norm_pos.x * map_rect.size.x, norm_pos.y * map_rect.size.y))
```
This mathematically guarantees that normalized coordinates $[0.0, 1.0]$ map precisely to the visible contours of the state map image regardless of viewport aspect ratio.

### 3.2 Distance-Anchored Piecewise Interpolation
Each route stop now explicitly carries its real highway coordinate (`dist_m`):
```gdscript
const STATE_ROUTE_GEOMETRY := {
    "tamil_nadu": [
        {"pos": Vector2(0.42, 0.94), "dist_m": 0.0, "label": "Kanyakumari"},
        {"pos": Vector2(0.44, 0.88), "dist_m": 270.0, "label": "Glass Bridge"},
        {"pos": Vector2(0.43, 0.80), "dist_m": 415.0, "label": "Thiruvalluvar"},
        {"pos": Vector2(0.46, 0.60), "dist_m": 600.0, "label": "Madurai CP"},
        {"pos": Vector2(0.58, 0.38), "dist_m": 850.0, "label": "NH44 Highway"},
        {"pos": Vector2(0.78, 0.16), "dist_m": 1100.0, "label": "Chennai"}
    ],
    ...
}
```
The active segment and player position are computed based on actual driving progress:
```gdscript
var total_m := maxf(_active_route.total_distance_m, 1.0)
var player_screen_pos := screen_points[0]
var active_seg_idx := 0

for k in range(geom_list.size() - 1):
    var d0: float = geom_list[k].get("dist_m", float(k) / float(geom_list.size() - 1) * total_m)
    var d1: float = geom_list[k + 1].get("dist_m", float(k + 1) / float(geom_list.size() - 1) * total_m)
    if _current_dist_m <= d1 or k == geom_list.size() - 2:
        active_seg_idx = k
        var seg_t := clampf((_current_dist_m - d0) / maxf(d1 - d0, 0.001), 0.0, 1.0)
        player_screen_pos = screen_points[k].lerp(screen_points[k + 1], seg_t)
        break
```
Results:
- When distance is $0\text{m}$, marker is positioned exactly on Kanyakumari.
- When distance is $270\text{m}$, marker is positioned exactly on the Glass Bridge pin.
- When distance is $415\text{m}$, marker is positioned exactly on Thiruvalluvar Statue.
- When distance is $600\text{m}$, marker is positioned exactly on Madurai Checkpoint.
- Between waypoints, marker moves smoothly and monotonically along the polyline.
- The completed progress line (bright lime green) fills in precisely behind the player marker.

---

## 4. Visual Evidence

Captured live in-engine with `DISPLAY=:0` on OpenGL3:
- **Screenshot Artifact:** [tn_fix_4_route_map_overlay_fixed.png](file:///home/joel/.gemini/antigravity-cli/brain/66204f88-eb3e-4a10-bde0-47fcf7dbeb50/tn_fix_4_route_map_overlay_fixed.png)
  - Shows Tamil Nadu SVG graphic perfectly aligned with zero pillarbox drift.
  - All 6 waypoints clearly labelled with distinct color-coded pins:
    - Green start pin at Kanyakumari.
    - Cyan milestone pins at Glass Bridge and Thiruvalluvar Statue.
    - Gold checkpoint pin at Madurai CP.
    - Red destination pin at Chennai Marina Beach.
  - Live player target pin `YOU (415m)` accurately positioned at the Thiruvalluvar milestone.
  - Right-hand panel displays matching waypoint progression with distance badges and checkmark badges.

---

## 5. Verification Checklist

- [x] State outline matches Tamil Nadu geography (Kanyakumari south, Madurai central, Chennai northeast).
- [x] Aspect-fitted bounding box prevents coordinate drift on any window resolution.
- [x] All 6 waypoint stops synchronized between RouteRegistry and RouteMapOverlay.
- [x] Player marker tracks real-time vehicle progress without jumping or warping.
- [x] Modal opens and closes cleanly without disturbing gameplay physics or freezing the tree.
- [x] Automated test `tests/test_tamil_nadu_statue_map_fix.gd` passed with 100% success.
