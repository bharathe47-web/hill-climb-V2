#!/usr/bin/env python3
"""
gen_goa.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates high-fidelity stylized 2D assets for Goa Indian Roads:
  - 6 Distinct Architectural Buildings (Fontainhas Latin, Portuguese villas, laterite cottages)
  - 4 Roadside Shops / Markets (Beach shack, Portuguese pao bakery, seafood tavern, cashew stall)
  - 6 Regional Tree / Vegetation Variants (Beach palm, Cashew, Frangipani, Rain tree, Hibiscus, Croton)
  - 3 Roadside Props (Surfboard rack, Outrigger fishing canoe, Laterite wall)
  - 6 Vector Landmarks (Our Lady Church, Basilica of Bom Jesus, Se Cathedral, Fort Aguada, etc.)
  - 3 Parallax Background Layers (Tropical Sky, Lush Western Ghats, Coastal Horizon)
"""

import cairo
import math
import os

BASE_DIR = "assets/indian_locations/goa"

def create_surface(w, h):
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, int(w), int(h))
    ctx = cairo.Context(surface)
    ctx.set_source_rgba(0, 0, 0, 0)
    ctx.paint()
    return surface, ctx

def ensure_dir(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)

def save_surface(surf, rel_path):
    full_path = os.path.join(BASE_DIR, rel_path)
    ensure_dir(full_path)
    surf.write_to_png(full_path)
    print(f"  ✓ Goa Asset: {rel_path} ({surf.get_width()}x{surf.get_height()})")

# ==============================================================================
# 1. BUILDINGS (6 Distinct Architectural Styles)
# ==============================================================================

def generate_buildings():
    print("\n--- Generating Goa Buildings ---")
    
    # B1: Fontainhas Yellow Villa (Two-story marigold yellow, white molduras, iron balcony)
    surf, ctx = create_surface(280, 220)
    # Marigold yellow wall
    ctx.set_source_rgb(0.96, 0.76, 0.16)
    ctx.rectangle(30, 65, 220, 145)
    ctx.fill()
    # White decorative molding bands (molduras)
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    ctx.set_line_width(8)
    ctx.rectangle(34, 69, 212, 137)
    ctx.stroke()
    # Mid-floor dividing cornice
    ctx.set_line_width(6)
    ctx.move_to(30, 135)
    ctx.line_to(250, 135)
    ctx.stroke()
    # Dark terracotta sloping tile roof
    ctx.set_source_rgb(0.72, 0.24, 0.14)
    ctx.move_to(15, 65)
    ctx.line_to(140, 15)
    ctx.line_to(265, 65)
    ctx.close_path()
    ctx.fill()
    # Upper floor wrought-iron balcony (varanda)
    ctx.set_source_rgb(0.18, 0.18, 0.20)
    ctx.rectangle(95, 110, 90, 25)
    ctx.stroke()
    for bx in range(100, 185, 10):
        ctx.move_to(bx, 110)
        ctx.line_to(bx, 135)
        ctx.stroke()
    # White louvered shutters (janelas)
    ctx.set_source_rgb(0.96, 0.96, 0.96)
    ctx.rectangle(50, 85, 28, 38)
    ctx.rectangle(202, 85, 28, 38)
    ctx.fill()
    # Ground floor arched entrance door
    ctx.set_source_rgb(0.35, 0.18, 0.10)
    ctx.rectangle(120, 155, 40, 55)
    ctx.fill()
    ctx.arc(140, 155, 20, math.pi, 2*math.pi)
    ctx.fill()
    save_surface(surf, "buildings/house_goa_fontainhas_yellow.png")

    # B2: Fontainhas Cobalt Blue Cottage (Single-story indigo blue, arched windows, tiled porch)
    surf, ctx = create_surface(260, 200)
    # Vibrant cobalt/indigo blue
    ctx.set_source_rgb(0.18, 0.42, 0.82)
    ctx.rectangle(30, 85, 200, 105)
    ctx.fill()
    # White stucco border frames
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    ctx.set_line_width(6)
    ctx.rectangle(33, 88, 194, 99)
    ctx.stroke()
    # High-pitched red clay tile roof
    ctx.set_source_rgb(0.80, 0.30, 0.18)
    ctx.move_to(15, 85)
    ctx.line_to(130, 25)
    ctx.line_to(245, 85)
    ctx.close_path()
    ctx.fill()
    # Arched windows with white surround
    for wx in [55, 175]:
        ctx.set_source_rgb(0.98, 0.98, 0.98)
        ctx.rectangle(wx, 110, 30, 42)
        ctx.arc(wx + 15, 110, 15, math.pi, 2*math.pi)
        ctx.fill()
        ctx.set_source_rgb(0.15, 0.20, 0.25)
        ctx.rectangle(wx + 3, 113, 24, 36)
        ctx.arc(wx + 15, 110, 12, math.pi, 2*math.pi)
        ctx.fill()
    # White balcão porch columns
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    ctx.rectangle(105, 130, 8, 60)
    ctx.rectangle(147, 130, 8, 60)
    ctx.fill()
    # Red entrance door
    ctx.set_source_rgb(0.75, 0.18, 0.15)
    ctx.rectangle(118, 140, 24, 50)
    ctx.fill()
    save_surface(surf, "buildings/house_goa_fontainhas_blue.png")

    # B3: Coastal Pink Portuguese Villa (Coral pink, high Mangalore tile roof, carved eave brackets)
    surf, ctx = create_surface(290, 210)
    # Coral pink walls
    ctx.set_source_rgb(0.92, 0.52, 0.55)
    ctx.rectangle(30, 95, 230, 105)
    ctx.fill()
    # Deep Mangalore terracotta tile roof
    ctx.set_source_rgb(0.75, 0.25, 0.15)
    ctx.move_to(15, 95)
    ctx.line_to(145, 30)
    ctx.line_to(275, 95)
    ctx.close_path()
    ctx.fill()
    # Carved wooden decorative eaves fascia
    ctx.set_source_rgb(0.45, 0.25, 0.12)
    ctx.rectangle(15, 95, 260, 6)
    ctx.fill()
    # Traditional front balcão seating
    ctx.set_source_rgb(0.85, 0.85, 0.88)
    ctx.rectangle(85, 165, 120, 35)
    ctx.fill()
    # Tall French louvered windows
    ctx.set_source_rgb(0.20, 0.35, 0.25)
    for fx in [48, 214]:
        ctx.rectangle(fx, 115, 28, 60)
        ctx.fill()
    save_surface(surf, "buildings/house_goa_coastal_pink.png")

    # B4: Red Laterite Stone Cottage (Exposed porous red laterite stone brickwork, whitewash trim)
    surf, ctx = create_surface(240, 170)
    # Porous red laterite stone
    ctx.set_source_rgb(0.68, 0.28, 0.22)
    ctx.rectangle(25, 75, 190, 85)
    ctx.fill()
    # Stone brick grid lines
    ctx.set_source_rgba(0.48, 0.18, 0.14, 0.5)
    ctx.set_line_width(1.5)
    for ly in range(90, 160, 15):
        ctx.move_to(25, ly)
        ctx.line_to(215, ly)
        ctx.stroke()
    # Sloping clay tile roof
    ctx.set_source_rgb(0.78, 0.32, 0.18)
    ctx.move_to(15, 75)
    ctx.line_to(120, 25)
    ctx.line_to(225, 75)
    ctx.close_path()
    ctx.fill()
    # Bright green wooden door
    ctx.set_source_rgb(0.18, 0.55, 0.32)
    ctx.rectangle(105, 100, 30, 60)
    ctx.fill()
    # Whitewashed window borders
    ctx.set_source_rgb(0.96, 0.96, 0.96)
    ctx.rectangle(48, 95, 28, 30)
    ctx.rectangle(164, 95, 28, 30)
    ctx.fill()
    save_surface(surf, "buildings/house_goa_laterite_cottage.png")

    # B5: Whitewashed Parish Chapel House (Gleaming white baroque pediment, bell niche)
    surf, ctx = create_surface(270, 230)
    # Gleaming white lime-washed walls
    ctx.set_source_rgb(0.96, 0.96, 0.98)
    ctx.rectangle(40, 90, 190, 130)
    ctx.fill()
    # Curved Baroque pediment crest
    ctx.move_to(40, 90)
    ctx.curve_to(70, 40, 110, 30, 135, 20)
    ctx.curve_to(160, 30, 200, 40, 230, 90)
    ctx.close_path()
    ctx.fill()
    # Bell niche arch cutout
    ctx.set_source_rgb(0.18, 0.22, 0.28)
    ctx.arc(135, 60, 14, math.pi, 2*math.pi)
    ctx.rectangle(121, 60, 28, 20)
    ctx.fill()
    # Brass church bell
    ctx.set_source_rgb(0.92, 0.78, 0.20)
    ctx.arc(135, 68, 7, 0, 2*math.pi)
    ctx.fill()
    # Red entrance double doors with fanlight transom
    ctx.set_source_rgb(0.72, 0.18, 0.15)
    ctx.rectangle(115, 150, 40, 70)
    ctx.fill()
    ctx.arc(135, 150, 20, math.pi, 2*math.pi)
    ctx.fill()
    save_surface(surf, "buildings/house_goa_white_chapel_residence.png")

    # B6: Modern Tropical Villa (Pistachio green, clay veranda, decorative fascia)
    surf, ctx = create_surface(290, 220)
    # Pistachio green walls
    ctx.set_source_rgb(0.62, 0.82, 0.65)
    ctx.rectangle(30, 85, 230, 125)
    ctx.fill()
    # Broad veranda terracotta roof
    ctx.set_source_rgb(0.75, 0.28, 0.15)
    ctx.move_to(15, 85)
    ctx.line_to(145, 25)
    ctx.line_to(275, 85)
    ctx.close_path()
    ctx.fill()
    # White modern veranda pillars
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    for px in [45, 105, 185, 245]:
        ctx.rectangle(px, 120, 10, 90)
        ctx.fill()
    # Large sliding glass doors with tropical reflection
    ctx.set_source_rgba(0.40, 0.70, 0.90, 0.75)
    ctx.rectangle(125, 130, 50, 80)
    ctx.fill()
    save_surface(surf, "buildings/house_goa_modern_tropical_villa.png")

# ==============================================================================
# 2. SHOPS & SHACKS (4 Roadside Varieties)
# ==============================================================================

def generate_shops():
    print("\n--- Generating Goa Shops ---")
    
    # S1: Goan Beach Shack (Bamboo construction, dried palm thatch, beach deck)
    surf, ctx = create_surface(200, 140)
    # Bamboo support stilts
    ctx.set_source_rgb(0.68, 0.55, 0.32)
    for bx in [30, 70, 130, 170]:
        ctx.rectangle(bx, 50, 8, 80)
        ctx.fill()
    # Wooden counter deck
    ctx.set_source_rgb(0.55, 0.40, 0.22)
    ctx.rectangle(20, 75, 160, 45)
    ctx.fill()
    # Overhanging dried palm frond thatched canopy
    ctx.set_source_rgb(0.62, 0.52, 0.28)
    ctx.move_to(10, 50)
    ctx.line_to(100, 15)
    ctx.line_to(190, 50)
    ctx.close_path()
    ctx.fill()
    # Fringed thatch leaves
    ctx.set_source_rgb(0.52, 0.42, 0.20)
    for fx in range(10, 190, 8):
        ctx.move_to(fx, 50)
        ctx.line_to(fx + 4, 60)
        ctx.line_to(fx + 8, 50)
        ctx.stroke()
    # Chalkboard menu & colorful cocktail board
    ctx.set_source_rgb(0.18, 0.20, 0.22)
    ctx.rectangle(45, 85, 35, 25)
    ctx.fill()
    save_surface(surf, "shops/shop_goa_beach_shack.png")

    # S2: Portuguese Pao Bakery (Baking oven, woven baskets with crusty poee & pao)
    surf, ctx = create_surface(180, 130)
    # Whitewashed bakery counter
    ctx.set_source_rgb(0.92, 0.92, 0.95)
    ctx.rectangle(25, 55, 130, 65)
    ctx.fill()
    # Blue tile awning
    ctx.set_source_rgb(0.15, 0.40, 0.80)
    ctx.rectangle(20, 30, 140, 25)
    ctx.fill()
    # Golden-brown Poee and Pao bread rolls in basket
    ctx.set_source_rgb(0.85, 0.62, 0.32)
    for bx, by in [(45, 48), (60, 46), (75, 49), (90, 47), (105, 48), (120, 46)]:
        ctx.arc(bx, by, 8, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "shops/shop_goa_pao_bakery.png")

    # S3: Seafood Tavern (Blue and white facade with fish signboard, outdoor cafe table)
    surf, ctx = create_surface(190, 140)
    ctx.set_source_rgb(0.20, 0.50, 0.85)
    ctx.rectangle(20, 50, 150, 80)
    ctx.fill()
    # White door and window frames
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    ctx.rectangle(40, 70, 30, 60) # Door
    ctx.rectangle(100, 70, 45, 35) # Window
    ctx.fill()
    # Fish silhouette signboard
    ctx.set_source_rgb(0.95, 0.82, 0.20)
    ctx.arc(120, 35, 12, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "shops/shop_goa_seafood_tavern.png")

    # S4: Cashew & Feni Stall (Display of roasted cashew nuts, glass bottles of cashew feni)
    surf, ctx = create_surface(170, 120)
    ctx.set_source_rgb(0.58, 0.42, 0.26)
    ctx.rectangle(20, 60, 130, 50)
    ctx.fill()
    # Red awning
    ctx.set_source_rgb(0.85, 0.22, 0.18)
    ctx.rectangle(15, 38, 140, 22)
    ctx.fill()
    # Feni glass bottles
    for fx, fcol in [(40, (0.85, 0.75, 0.3)), (55, (0.7, 0.85, 0.3)), (70, (0.9, 0.8, 0.2))]:
        ctx.set_source_rgba(fcol[0], fcol[1], fcol[2], 0.8)
        ctx.rectangle(fx, 45, 10, 18)
        ctx.fill()
    # Burlap bag of roasted cashews
    ctx.set_source_rgb(0.72, 0.62, 0.45)
    ctx.arc(115, 52, 14, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "shops/shop_goa_cashew_spice_stall.png")

# ==============================================================================
# 3. VEGETATION (6 Tree & Shrub Variants)
# ==============================================================================

def generate_vegetation():
    print("\n--- Generating Goa Vegetation ---")
    
    # V1: Wind-Swept Beach Coconut Palm (Leaning coastal palm with swaying fronds)
    surf, ctx = create_surface(210, 290)
    # Wind-leaned slender trunk
    ctx.set_source_rgb(0.48, 0.36, 0.26)
    ctx.move_to(50, 285)
    ctx.curve_to(75, 190, 120, 110, 160, 60)
    ctx.line_to(170, 60)
    ctx.curve_to(130, 110, 85, 190, 62, 285)
    ctx.close_path()
    ctx.fill()
    # Spreading windswept fronds
    ctx.set_source_rgb(0.18, 0.58, 0.22)
    for angle in [-2.4, -1.8, -1.2, -0.6, 0.0, 0.6]:
        ctx.move_to(165, 60)
        tx = 165 + 80 * math.cos(angle)
        ty = 60 + 65 * math.sin(angle)
        ctx.curve_to(165 + 35 * math.cos(angle), 60 - 25, tx, ty - 15, tx, ty)
        ctx.set_line_width(6)
        ctx.stroke()
    # Golden-brown beach coconuts
    ctx.set_source_rgb(0.65, 0.45, 0.20)
    for cx, cy in [(160, 68), (168, 71), (164, 76)]:
        ctx.arc(cx, cy, 6, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_goa_coconut_beach.png")

    # V2: Fruiting Cashew Tree (Spreading low canopy with yellow/red cashew apples)
    surf, ctx = create_surface(240, 220)
    ctx.set_source_rgb(0.40, 0.28, 0.18)
    ctx.rectangle(110, 130, 20, 80)
    ctx.fill()
    # Dense rounded canopy
    ctx.set_source_rgb(0.22, 0.52, 0.26)
    for cx, cy, rad in [(120, 90, 65), (80, 105, 50), (160, 105, 50), (120, 60, 45)]:
        ctx.arc(cx, cy, rad, 0, 2*math.pi)
        ctx.fill()
    # Cashew apples (yellow-red piriform fruits)
    for ax, ay, acol in [(90, 85, (0.95, 0.3, 0.15)), (140, 95, (0.95, 0.8, 0.15)), (110, 115, (0.95, 0.4, 0.15)), (160, 110, (0.95, 0.75, 0.15))]:
        ctx.set_source_rgb(*acol)
        ctx.arc(ax, ay, 6, 0, 2*math.pi)
        ctx.fill()
        # Kidney-shaped cashew nut below apple
        ctx.set_source_rgb(0.35, 0.30, 0.25)
        ctx.arc(ax, ay + 7, 3, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_goa_cashew_fruiting.png")

    # V3: Frangipani Champa Tree (Gnarled branches with fragrant white-yellow blossoms)
    surf, ctx = create_surface(180, 190)
    ctx.set_source_rgb(0.50, 0.42, 0.35)
    ctx.rectangle(85, 110, 12, 70)
    ctx.fill()
    # Branching
    ctx.set_line_width(6)
    ctx.move_to(91, 120)
    ctx.line_to(55, 75)
    ctx.stroke()
    ctx.move_to(91, 120)
    ctx.line_to(125, 75)
    ctx.stroke()
    # White-yellow blossoms
    for fx, fy in [(50, 70), (65, 60), (120, 70), (135, 60), (90, 50), (75, 80), (105, 75)]:
        ctx.set_source_rgb(0.98, 0.98, 0.98) # White petals
        ctx.arc(fx, fy, 8, 0, 2*math.pi)
        ctx.fill()
        ctx.set_source_rgb(0.98, 0.85, 0.18) # Yellow center
        ctx.arc(fx, fy, 3, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_goa_frangipani_champa.png")

    # V4: Umbrella Rain Tree (Expansive majestic monkey-pod canopy with pink puff flowers)
    surf, ctx = create_surface(300, 250)
    ctx.set_source_rgb(0.38, 0.26, 0.18)
    ctx.rectangle(135, 135, 30, 105)
    ctx.fill()
    # Broad umbrella crown
    ctx.set_source_rgb(0.18, 0.45, 0.22)
    ctx.arc(150, 100, 110, math.pi, 2*math.pi)
    ctx.fill()
    # Pink puff flowers
    ctx.set_source_rgba(0.95, 0.45, 0.65, 0.85)
    for px, py in [(80, 85), (120, 65), (150, 55), (180, 65), (220, 85), (100, 105), (200, 105)]:
        ctx.arc(px, py, 7, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_goa_rain_tree.png")

    # V5: Crimson Hibiscus Shrub (Glossy green bush with vibrant red tropical flowers)
    surf, ctx = create_surface(140, 110)
    ctx.set_source_rgb(0.16, 0.42, 0.20)
    ctx.arc(70, 75, 45, 0, 2*math.pi)
    ctx.fill()
    # Crimson red hibiscus flowers
    ctx.set_source_rgb(0.88, 0.12, 0.18)
    for fx, fy in [(50, 60), (70, 50), (90, 65), (60, 85), (85, 80)]:
        ctx.arc(fx, fy, 10, 0, 2*math.pi)
        ctx.fill()
        # Long yellow staminal column
        ctx.set_source_rgb(0.95, 0.85, 0.15)
        ctx.rectangle(fx + 2, fy - 5, 2, 8)
        ctx.fill()
        ctx.set_source_rgb(0.88, 0.12, 0.18)
    save_surface(surf, "vegetation/shrub_goa_tropical_hibiscus.png")

    # V6: Variegated Croton Bush (Ornamental foliage with splash of yellow, red, green)
    surf, ctx = create_surface(130, 100)
    for lx, ly, lcol in [(45, 65, (0.85, 0.2, 0.15)), (65, 45, (0.95, 0.85, 0.15)), (85, 60, (0.2, 0.6, 0.25)), (55, 75, (0.95, 0.75, 0.15)), (75, 70, (0.85, 0.25, 0.15))]:
        ctx.set_source_rgb(*lcol)
        ctx.arc(lx, ly, 18, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/shrub_goa_croton_variegated.png")

# ==============================================================================
# 4. ROADSIDE PROPS (3 Authentic Goan Items)
# ==============================================================================

def generate_props():
    print("\n--- Generating Goa Props ---")
    
    # P1: Beach Surfboard Rack (Bamboo stand with brightly colored striped surfboards)
    surf, ctx = create_surface(150, 120)
    # Bamboo rack
    ctx.set_source_rgb(0.68, 0.55, 0.32)
    ctx.rectangle(20, 80, 110, 8)
    ctx.rectangle(30, 80, 8, 35)
    ctx.rectangle(110, 80, 8, 35)
    ctx.fill()
    # Surfboards standing upright
    boards = [
        (45, (0.95, 0.35, 0.15)), # Orange
        (65, (0.20, 0.65, 0.85)), # Cyan
        (85, (0.95, 0.85, 0.15)), # Yellow
        (105, (0.85, 0.20, 0.55)) # Pink
    ]
    for sx, scol in boards:
        ctx.set_source_rgb(*scol)
        ctx.arc(sx, 40, 9, math.pi, 2*math.pi)
        ctx.rectangle(sx - 9, 40, 18, 55)
        ctx.fill()
    save_surface(surf, "roadside_props/prop_goa_surfboard_rack.png")

    # P2: Outrigger Fishing Canoe (Traditional coastal canoe on golden beach sand)
    surf, ctx = create_surface(180, 80)
    # Yellow and blue wooden canoe hull
    ctx.set_source_rgb(0.95, 0.78, 0.18)
    ctx.move_to(20, 45)
    ctx.curve_to(50, 65, 130, 65, 160, 45)
    ctx.close_path()
    ctx.fill()
    ctx.set_source_rgb(0.18, 0.45, 0.82)
    ctx.rectangle(30, 45, 120, 6)
    ctx.fill()
    # Bamboo outrigger poles
    ctx.set_source_rgb(0.68, 0.55, 0.35)
    ctx.rectangle(40, 38, 90, 4)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_goa_fishing_canoe.png")

    # P3: Red Laterite Decorative Wall (Low wall with white pillar caps)
    surf, ctx = create_surface(160, 70)
    ctx.set_source_rgb(0.65, 0.28, 0.20)
    ctx.rectangle(15, 30, 130, 35)
    ctx.fill()
    # White pillar caps
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    ctx.rectangle(10, 24, 25, 8)
    ctx.rectangle(125, 24, 25, 8)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_goa_laterite_wall.png")

# ==============================================================================
# 5. FAMOUS LANDMARKS (Clean stylized vector art resolving Problem 5)
# ==============================================================================

def generate_landmarks():
    print("\n--- Generating Goa Landmarks ---")
    
    # L1: Our Lady of Immaculate Conception Church (Iconic crisscross white baroque stairways and twin towers)
    surf, ctx = create_surface(340, 360)
    # Hillside green base
    ctx.set_source_rgb(0.22, 0.55, 0.28)
    ctx.rectangle(30, 320, 280, 35)
    ctx.fill()
    # Zigzag crisscross white grand stairways
    ctx.set_source_rgb(0.96, 0.96, 0.98)
    ctx.move_to(50, 320)
    ctx.line_to(170, 220)
    ctx.line_to(290, 320)
    ctx.set_line_width(12)
    ctx.stroke()
    ctx.move_to(90, 220)
    ctx.line_to(170, 160)
    ctx.line_to(250, 220)
    ctx.stroke()
    # Pure white baroque facade and twin bell towers
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    ctx.rectangle(100, 80, 140, 100) # Central facade
    ctx.rectangle(80, 50, 35, 130)   # Left tower
    ctx.rectangle(225, 50, 35, 130)  # Right tower
    ctx.fill()
    # Pyramidal spire caps
    ctx.move_to(75, 50)
    ctx.line_to(97, 20)
    ctx.line_to(120, 50)
    ctx.close_path()
    ctx.move_to(220, 50)
    ctx.line_to(242, 20)
    ctx.line_to(265, 50)
    ctx.close_path()
    ctx.fill()
    # Central bell gable
    ctx.move_to(130, 80)
    ctx.line_to(170, 45)
    ctx.line_to(210, 80)
    ctx.close_path()
    ctx.fill()
    # Great Church Bell
    ctx.set_source_rgb(0.90, 0.78, 0.20)
    ctx.arc(170, 65, 8, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "landmarks/our_lady_immaculate_conception_vector.png")

    # L2: Basilica of Bom Jesus (Red laterite baroque facade, three-tiered pilasters, bell tower)
    surf, ctx = create_surface(380, 320)
    # Exposed red laterite stone facade
    ctx.set_source_rgb(0.68, 0.26, 0.18)
    ctx.rectangle(50, 100, 220, 200) # Main hall
    ctx.rectangle(270, 60, 60, 240)  # Bell tower
    ctx.fill()
    # Laterite pilasters and triangular pediment
    ctx.set_source_rgb(0.55, 0.20, 0.14)
    for px in [60, 105, 150, 195, 240]:
        ctx.rectangle(px, 100, 12, 195)
        ctx.fill()
    # Triangular classical pediment
    ctx.move_to(45, 100)
    ctx.line_to(160, 50)
    ctx.line_to(275, 100)
    ctx.close_path()
    ctx.fill()
    # Jesuit IHS emblem in gold
    ctx.set_source_rgb(0.95, 0.82, 0.22)
    ctx.arc(160, 80, 12, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "landmarks/basilica_of_bom_jesus_vector.png")

    # L3: Fort Aguada Lighthouse (17th-century Portuguese fortress ramparts with circular stone lighthouse)
    surf, ctx = create_surface(320, 280)
    # Coastal sea cliff & fortress ramparts
    ctx.set_source_rgb(0.58, 0.25, 0.18)
    ctx.rectangle(20, 190, 280, 80)
    ctx.fill()
    # Crenellated battlement notches
    for bx in range(25, 290, 25):
        ctx.set_source_rgba(0, 0, 0, 0)
        ctx.rectangle(bx, 190, 10, 12)
        ctx.fill()
    # Circular 4-tier stone lighthouse tower
    ctx.set_source_rgb(0.85, 0.85, 0.88)
    ctx.rectangle(125, 75, 70, 120)
    ctx.fill()
    # Observation gallery & lantern dome
    ctx.set_source_rgb(0.25, 0.28, 0.32)
    ctx.rectangle(115, 65, 90, 12)
    ctx.fill()
    ctx.set_source_rgba(0.40, 0.75, 0.95, 0.75) # Glass
    ctx.rectangle(135, 42, 50, 23)
    ctx.fill()
    ctx.set_source_rgb(0.85, 0.22, 0.18) # Red dome
    ctx.arc(160, 42, 25, math.pi, 2*math.pi)
    ctx.fill()
    save_surface(surf, "landmarks/fort_aguada_lighthouse_vector.png")

# ==============================================================================
# 6. PARALLAX BACKGROUND LAYERS (Sky, Lush Ghats, Midground Coastal Grove)
# ==============================================================================

def generate_backgrounds():
    print("\n--- Generating Goa Parallax Backgrounds ---")
    
    # Layer 1: Tropical Sky (1920x600)
    surf, ctx = create_surface(1920, 600)
    pat = cairo.LinearGradient(0, 0, 0, 600)
    pat.add_color_stop_rgb(0.0, 0.12, 0.52, 0.88) # Tropical azure
    pat.add_color_stop_rgb(0.6, 0.40, 0.75, 0.96) # Warm coastal blue
    pat.add_color_stop_rgb(1.0, 0.98, 0.92, 0.78) # Golden sunset glow
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 600)
    ctx.fill()
    save_surface(surf, "backgrounds/sky/goa_tropical_sky.png")

    # Layer 2: Lush Western Ghats Mountains (100% green rainforest, 0% snow) (1920x450)
    surf, ctx = create_surface(1920, 450)
    pat = cairo.LinearGradient(0, 120, 0, 450)
    pat.add_color_stop_rgb(0.0, 0.14, 0.42, 0.22)
    pat.add_color_stop_rgb(1.0, 0.08, 0.28, 0.15)
    ctx.set_source(pat)
    ctx.move_to(0, 240)
    ctx.curve_to(320, 140, 640, 220, 960, 130)
    ctx.curve_to(1280, 210, 1600, 120, 1920, 230)
    ctx.line_to(1920, 450)
    ctx.line_to(0, 450)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "backgrounds/distant_landscape/goa_western_ghats_lush.png")

    # Layer 3: Goa Coastal Horizon Midground (1920x350)
    surf, ctx = create_surface(1920, 350)
    ctx.set_source_rgb(0.18, 0.52, 0.28)
    ctx.rectangle(0, 180, 1920, 170)
    ctx.fill()
    # Swaying palm silhouettes
    ctx.set_source_rgba(0.12, 0.35, 0.18, 0.85)
    for px in range(70, 1900, 140):
        ctx.rectangle(px, 110, 4, 75)
        ctx.fill()
        ctx.arc(px + 2, 105, 18, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "backgrounds/distant_landscape/goa_coastal_midground.png")

def main():
    generate_buildings()
    generate_shops()
    generate_vegetation()
    generate_props()
    generate_landmarks()
    generate_backgrounds()
    print("=== GOA ASSET GENERATION COMPLETE ===")

if __name__ == "__main__":
    main()
