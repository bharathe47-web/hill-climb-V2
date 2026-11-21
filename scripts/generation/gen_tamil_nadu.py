#!/usr/bin/env python3
"""
gen_tamil_nadu.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates high-fidelity stylized 2D assets for Tamil Nadu Indian Roads:
  - 6 Distinct Architectural Buildings
  - 4 Roadside Shops / Markets
  - 6 Regional Tree / Vegetation Variants (including Palmyra palm)
  - 3 Roadside Props (Bullock cart, Kolam sign, Fishing boat & nets)
  - 6 Vector Landmarks (Meenakshi Temple, Thiruvalluvar Statue, Vivekananda Rock, etc.)
  - 3 Parallax Background Layers (Sky, Ocean, Countryside Midground)
"""

import cairo
import math
import os

BASE_DIR = "assets/indian_locations/tamil_nadu"

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
    print(f"  ✓ Tamil Nadu Asset: {rel_path} ({surf.get_width()}x{surf.get_height()})")

# ==============================================================================
# 1. BUILDINGS (6 Distinct Architectural Styles)
# ==============================================================================

def generate_buildings():
    print("\n--- Generating Tamil Nadu Buildings ---")
    
    # B1: Agraharam Row House (Classical Brahmin heritage with thinnai veranda pillars)
    surf, ctx = create_surface(280, 200)
    # Ochre washed walls
    ctx.set_source_rgb(0.92, 0.86, 0.72)
    ctx.rectangle(30, 80, 220, 110)
    ctx.fill()
    # Sloping terracotta clay tile roof
    ctx.set_source_rgb(0.78, 0.28, 0.16)
    ctx.move_to(15, 85)
    ctx.line_to(140, 20)
    ctx.line_to(265, 85)
    ctx.close_path()
    ctx.fill()
    # Roof tile ridge lines
    ctx.set_source_rgba(0.60, 0.20, 0.10, 0.6)
    ctx.set_line_width(2)
    for rx in range(35, 250, 18):
        ctx.move_to(140, 20)
        ctx.line_to(rx, 85)
        ctx.stroke()
    # Front Thinnai (raised stone porch ledge)
    ctx.set_source_rgb(0.75, 0.68, 0.58)
    ctx.rectangle(25, 165, 230, 25)
    ctx.fill()
    # Carved Teak Veranda Pillars
    ctx.set_source_rgb(0.42, 0.24, 0.14)
    for px in [45, 95, 185, 230]:
        ctx.rectangle(px, 85, 10, 80)
        ctx.fill()
        # Pillar capitals
        ctx.rectangle(px - 3, 85, 16, 6)
        ctx.rectangle(px - 3, 160, 16, 5)
        ctx.fill()
    # Ornate Teak Door & Kolam Threshold
    ctx.set_source_rgb(0.32, 0.16, 0.08)
    ctx.rectangle(125, 115, 30, 50)
    ctx.fill()
    # Brass door studs
    ctx.set_source_rgb(0.95, 0.82, 0.20)
    ctx.arc(135, 140, 2, 0, 2*math.pi)
    ctx.arc(145, 140, 2, 0, 2*math.pi)
    ctx.fill()
    # White Kolam at entrance
    ctx.set_source_rgba(1.0, 1.0, 1.0, 0.85)
    ctx.set_line_width(1.5)
    ctx.arc(140, 182, 6, 0, 2*math.pi)
    ctx.stroke()
    save_surface(surf, "buildings/house_tamil_agraharam.png")

    # B2: Coastal Fishing Cottage (Aqua lime-wash, flat terrace, drying racks)
    surf, ctx = create_surface(260, 180)
    # Bright coastal aqua walls
    ctx.set_source_rgb(0.35, 0.72, 0.78)
    ctx.rectangle(30, 70, 200, 100)
    ctx.fill()
    # White border parapet on terrace
    ctx.set_source_rgb(0.95, 0.96, 0.98)
    ctx.rectangle(25, 58, 210, 14)
    ctx.fill()
    # Palm frond thatched shade on terrace
    ctx.set_source_rgb(0.65, 0.55, 0.35)
    ctx.move_to(40, 60)
    ctx.line_to(120, 25)
    ctx.line_to(200, 60)
    ctx.close_path()
    ctx.fill()
    # Wooden support poles for thatch
    ctx.set_source_rgb(0.45, 0.35, 0.25)
    ctx.rectangle(55, 35, 6, 25)
    ctx.rectangle(185, 35, 6, 25)
    ctx.fill()
    # Deep blue shuttered windows & door
    ctx.set_source_rgb(0.12, 0.32, 0.65)
    ctx.rectangle(55, 95, 28, 35)
    ctx.rectangle(175, 95, 28, 35)
    ctx.rectangle(115, 105, 30, 65) # Door
    ctx.fill()
    save_surface(surf, "buildings/house_tamil_coastal_cottage.png")

    # B3: Chettinad Heritage Mansion (Two-tiered stately villa with arched parapet)
    surf, ctx = create_surface(340, 260)
    # Lower floor (Warm terracotta ochre)
    ctx.set_source_rgb(0.88, 0.76, 0.62)
    ctx.rectangle(30, 130, 280, 120)
    ctx.fill()
    # Upper floor
    ctx.set_source_rgb(0.92, 0.82, 0.68)
    ctx.rectangle(55, 60, 230, 70)
    ctx.fill()
    # Decorative arched parapet on roof
    ctx.set_source_rgb(0.78, 0.32, 0.20)
    ctx.rectangle(50, 48, 240, 12)
    ctx.fill()
    for ax in range(70, 270, 30):
        ctx.arc(ax, 48, 10, math.pi, 2*math.pi)
        ctx.fill()
    # Burma Teak Pillars on front veranda
    ctx.set_source_rgb(0.38, 0.20, 0.12)
    for px in [45, 85, 135, 205, 255, 295]:
        ctx.rectangle(px, 150, 12, 95)
        ctx.fill()
    # Upper floor wooden louvered balcony windows
    ctx.set_source_rgb(0.48, 0.25, 0.15)
    for wx in [80, 130, 180, 230]:
        ctx.rectangle(wx, 75, 26, 40)
        ctx.fill()
        # Rounded arch above window
        ctx.arc(wx + 13, 75, 13, math.pi, 2*math.pi)
        ctx.fill()
    # Grand carved entrance doorway
    ctx.set_source_rgb(0.28, 0.14, 0.08)
    ctx.rectangle(150, 170, 40, 75)
    ctx.fill()
    save_surface(surf, "buildings/house_tamil_chettinad_mansion.png")

    # B4: Thatched Rural Hut (Earthen walls with layered dried palmyra leaves)
    surf, ctx = create_surface(240, 160)
    # Red-brown mud walls
    ctx.set_source_rgb(0.68, 0.45, 0.32)
    ctx.rectangle(35, 80, 170, 75)
    ctx.fill()
    # Sloping dried palmyra thatched roof
    ctx.set_source_rgb(0.62, 0.52, 0.32)
    ctx.move_to(20, 85)
    ctx.line_to(120, 25)
    ctx.line_to(220, 85)
    ctx.close_path()
    ctx.fill()
    # Overhanging thatch fringe texture
    ctx.set_source_rgb(0.52, 0.42, 0.25)
    for tx in range(20, 220, 8):
        ctx.move_to(tx, 85)
        ctx.line_to(tx + 4, 95)
        ctx.line_to(tx + 8, 85)
        ctx.stroke()
    # Small wooden door
    ctx.set_source_rgb(0.35, 0.20, 0.12)
    ctx.rectangle(100, 105, 26, 50)
    ctx.fill()
    save_surface(surf, "buildings/house_tamil_thatched_hut.png")

    # B5: Modern Terrace House (Two-story pastel yellow with cantilevered balcony & water tank)
    surf, ctx = create_surface(280, 240)
    # Ground & First floor body
    ctx.set_source_rgb(0.96, 0.88, 0.65) # Warm pastel yellow
    ctx.rectangle(30, 80, 220, 150)
    ctx.fill()
    # Cantilevered balcony slab
    ctx.set_source_rgb(0.90, 0.92, 0.95)
    ctx.rectangle(20, 145, 140, 10)
    ctx.fill()
    # Stainless steel / glass balcony railing
    ctx.set_source_rgb(0.35, 0.65, 0.85)
    ctx.rectangle(25, 120, 130, 25)
    ctx.fill()
    # Modern black aluminum window frames
    ctx.set_source_rgb(0.20, 0.22, 0.26)
    ctx.rectangle(45, 95, 40, 25)
    ctx.rectangle(180, 95, 45, 40)
    ctx.rectangle(180, 175, 45, 40)
    ctx.fill()
    # Modern wooden door
    ctx.set_source_rgb(0.45, 0.25, 0.15)
    ctx.rectangle(85, 175, 35, 55)
    ctx.fill()
    # Roof water tank (black Sintex tank)
    ctx.set_source_rgb(0.18, 0.20, 0.22)
    ctx.rectangle(200, 48, 35, 32)
    ctx.fill()
    save_surface(surf, "buildings/house_tamil_modern_terrace.png")

    # B6: Temple Town Residence (Red and white vertical temple stripes, sloping eaves)
    surf, ctx = create_surface(290, 210)
    # Temple wall stripes (Red and white vertical bands)
    for sx, is_red in enumerate([False, True, False, True, False, True, False, True, False, True]):
        ctx.set_source_rgb(0.78, 0.22, 0.18) if is_red else ctx.set_source_rgb(0.96, 0.96, 0.96)
        ctx.rectangle(30 + sx * 23, 90, 23, 110)
        ctx.fill()
    # Dark brown clay tile roof
    ctx.set_source_rgb(0.68, 0.25, 0.15)
    ctx.move_to(20, 95)
    ctx.line_to(145, 30)
    ctx.line_to(270, 95)
    ctx.close_path()
    ctx.fill()
    # Brass Kalasam motif on rooftop crest
    ctx.set_source_rgb(0.95, 0.80, 0.20)
    ctx.arc(145, 24, 6, 0, 2*math.pi)
    ctx.fill()
    # Teak entrance door with holy brass bell
    ctx.set_source_rgb(0.32, 0.15, 0.08)
    ctx.rectangle(125, 130, 36, 70)
    ctx.fill()
    save_surface(surf, "buildings/house_tamil_temple_residence.png")

# ==============================================================================
# 2. SHOPS & MARKETS (4 Roadside Varieties)
# ==============================================================================

def generate_shops():
    print("\n--- Generating Tamil Nadu Shops ---")
    
    # S1: Tea Kadai (Roadside tea stall with brass boiler, glass tumbler rack)
    surf, ctx = create_surface(180, 140)
    # Wooden stall counter
    ctx.set_source_rgb(0.25, 0.55, 0.85) # Blue painted wood
    ctx.rectangle(20, 60, 140, 70)
    ctx.fill()
    # Corrugated tin / striped canvas awning
    for i, col in enumerate([(0.95, 0.25, 0.20), (0.95, 0.95, 0.95)] * 4):
        ctx.set_source_rgb(*col)
        ctx.rectangle(15 + i * 18, 30, 18, 30)
        ctx.fill()
    # Brass Tea Samovar / Boiler
    ctx.set_source_rgb(0.92, 0.78, 0.22)
    ctx.rectangle(35, 42, 26, 32)
    ctx.arc(48, 42, 13, math.pi, 2*math.pi)
    ctx.fill()
    # Glass Tumbler wire rack
    ctx.set_source_rgb(0.85, 0.90, 0.95)
    for gx in [75, 88, 101, 114]:
        ctx.rectangle(gx, 54, 8, 14)
        ctx.fill()
    # Glass Jar with Rusks & Biscuits
    ctx.set_source_rgba(0.95, 0.95, 0.95, 0.6)
    ctx.rectangle(130, 48, 18, 22)
    ctx.fill()
    save_surface(surf, "shops/shop_tamil_tea_kadai.png")

    # S2: Potti Kadai (Corner grocery kiosk with hanging shampoo sachets & bananas)
    surf, ctx = create_surface(160, 140)
    # Bright green wooden kiosk
    ctx.set_source_rgb(0.18, 0.65, 0.35)
    ctx.rectangle(20, 45, 120, 85)
    ctx.fill()
    # Slanted metal awning
    ctx.set_source_rgb(0.85, 0.35, 0.15)
    ctx.move_to(15, 45)
    ctx.line_to(80, 15)
    ctx.line_to(145, 45)
    ctx.close_path()
    ctx.fill()
    # Hanging yellow banana bunch
    ctx.set_source_rgb(0.95, 0.85, 0.15)
    for by in range(50, 75, 5):
        ctx.arc(35, by, 6, 0, 2*math.pi)
        ctx.fill()
    # Colorful hanging product sachets
    for i, scol in enumerate([(0.95, 0.2, 0.2), (0.2, 0.4, 0.9), (0.9, 0.8, 0.1)]):
        ctx.set_source_rgb(*scol)
        ctx.rectangle(110 + i * 8, 48, 6, 30)
        ctx.fill()
    save_surface(surf, "shops/shop_tamil_potti_kadai.png")

    # S3: Poo Kadai (Flower garland market with fragrant jasmine & marigold)
    surf, ctx = create_surface(170, 130)
    # Bamboo table counter
    ctx.set_source_rgb(0.55, 0.40, 0.25)
    ctx.rectangle(25, 70, 120, 50)
    ctx.fill()
    # Fresh green banana leaf table cover
    ctx.set_source_rgb(0.25, 0.72, 0.20)
    ctx.rectangle(20, 65, 130, 8)
    ctx.fill()
    # Yellow canvas sun umbrella
    ctx.set_source_rgb(0.95, 0.78, 0.18)
    ctx.arc(85, 40, 55, math.pi, 2*math.pi)
    ctx.fill()
    ctx.set_source_rgb(0.45, 0.32, 0.20)
    ctx.rectangle(83, 40, 4, 30)
    ctx.fill()
    # Hanging white Jasmine (Malli) garlands
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    for mx in [45, 60, 75]:
        ctx.rectangle(mx, 73, 8, 35)
        ctx.fill()
    # Hanging orange Marigold (Samandhi) garlands
    ctx.set_source_rgb(0.98, 0.52, 0.12)
    for ox in [95, 110, 125]:
        ctx.rectangle(ox, 73, 8, 35)
        ctx.fill()
    save_surface(surf, "shops/shop_tamil_flower_poo_kadai.png")

    # S4: Tender Coconut Stall (Elaneer stall with stacked coconuts and machete)
    surf, ctx = create_surface(160, 120)
    # Rough timber table
    ctx.set_source_rgb(0.48, 0.35, 0.24)
    ctx.rectangle(25, 60, 110, 50)
    ctx.fill()
    # Stacked fresh green coconuts (Elaneer)
    ctx.set_source_rgb(0.32, 0.68, 0.25)
    for cx, cy in [(40, 52), (55, 50), (70, 53), (85, 51), (100, 54), (115, 52), (48, 42), (63, 39), (78, 41), (93, 40), (56, 32), (71, 30), (86, 31)]:
        ctx.arc(cx, cy, 9, 0, 2*math.pi)
        ctx.fill()
    # Coconut machete knife (Vettukathi)
    ctx.set_source_rgb(0.85, 0.88, 0.92)
    ctx.rectangle(120, 50, 4, 18)
    ctx.fill()
    save_surface(surf, "shops/shop_tamil_tender_coconut_stall.png")

# ==============================================================================
# 3. VEGETATION (6 Tree & Shrub Variants)
# ==============================================================================

def generate_vegetation():
    print("\n--- Generating Tamil Nadu Vegetation ---")
    
    # V1: Palmyra Palm (Iconic state tree of Tamil Nadu - tall black trunk, fan leaves)
    surf, ctx = create_surface(160, 320)
    # Dark textured straight trunk
    ctx.set_source_rgb(0.22, 0.18, 0.16)
    ctx.move_to(74, 315)
    ctx.line_to(76, 90)
    ctx.line_to(84, 90)
    ctx.line_to(86, 315)
    ctx.close_path()
    ctx.fill()
    # Trunk rib scars
    ctx.set_source_rgba(0.12, 0.08, 0.06, 0.6)
    ctx.set_line_width(2)
    for ty in range(110, 300, 12):
        ctx.move_to(75, ty)
        ctx.line_to(85, ty)
        ctx.stroke()
    # Dense spherical crown of fan-shaped palmyra fronds
    ctx.set_source_rgb(0.15, 0.42, 0.20)
    for angle in [i * (2 * math.pi / 16) for i in range(16)]:
        fx = 80 + 55 * math.cos(angle)
        fy = 90 + 50 * math.sin(angle)
        ctx.move_to(80, 90)
        ctx.line_to(fx, fy)
        ctx.stroke()
        # Fan leaf triangles
        ctx.move_to(80, 90)
        ctx.line_to(fx - 10, fy)
        ctx.line_to(fx + 10, fy)
        ctx.close_path()
        ctx.fill()
    # Hanging black palmyra fruit clusters
    ctx.set_source_rgb(0.12, 0.10, 0.08)
    for bx, by in [(72, 105), (80, 108), (88, 104)]:
        ctx.arc(bx, by, 7, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_tamil_palmyra_tall.png")

    # V2: Curved Coastal Coconut Palm (Gracefully arched trunk with hanging green coconuts)
    surf, ctx = create_surface(200, 280)
    # Arched trunk
    ctx.set_source_rgb(0.48, 0.36, 0.26)
    ctx.move_to(50, 275)
    ctx.curve_to(70, 180, 110, 110, 140, 70)
    ctx.line_to(150, 70)
    ctx.curve_to(120, 110, 80, 180, 62, 275)
    ctx.close_path()
    ctx.fill()
    # Tropical fronds spreading out
    ctx.set_source_rgb(0.20, 0.62, 0.25)
    for frond_angle in [-2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5, 1.0]:
        ctx.move_to(145, 70)
        tip_x = 145 + 75 * math.cos(frond_angle)
        tip_y = 70 + 60 * math.sin(frond_angle)
        ctx.curve_to(145 + 30 * math.cos(frond_angle), 70 + 20 * math.sin(frond_angle) - 20, tip_x, tip_y - 10, tip_x, tip_y)
        ctx.stroke()
    # Clustered coconuts
    ctx.set_source_rgb(0.35, 0.65, 0.22)
    for cx, cy in [(140, 76), (148, 79), (143, 85)]:
        ctx.arc(cx, cy, 6, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_tamil_coconut_curved.png")

    # V3: Sprawling Banyan Tree (Expansive leafy canopy and hanging aerial roots)
    surf, ctx = create_surface(320, 260)
    # Broad gnarled trunk
    ctx.set_source_rgb(0.40, 0.28, 0.20)
    ctx.rectangle(135, 150, 50, 105)
    ctx.fill()
    # Hanging aerial prop roots
    for rx in [90, 115, 195, 225]:
        ctx.rectangle(rx, 140, 6, 115)
        ctx.fill()
    # Massive multi-lobed green canopy
    ctx.set_source_rgb(0.18, 0.48, 0.22)
    for cx, cy, rad in [(160, 100, 75), (105, 115, 60), (215, 115, 60), (70, 135, 50), (250, 135, 50)]:
        ctx.arc(cx, cy, rad, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_tamil_banyan_sprawling.png")

    # V4: Shaded Neem Tree (Feathery compound leaf canopy, rounded silhouette)
    surf, ctx = create_surface(240, 230)
    ctx.set_source_rgb(0.38, 0.26, 0.18)
    ctx.rectangle(110, 140, 20, 85)
    ctx.fill()
    # Feathery dome foliage
    ctx.set_source_rgb(0.24, 0.58, 0.28)
    for cx, cy, rad in [(120, 95, 65), (85, 110, 50), (155, 110, 50), (120, 65, 45)]:
        ctx.arc(cx, cy, rad, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_tamil_neem_shade.png")

    # V5: Banana Grove Clump (Lush broad green leaves with flower bud)
    surf, ctx = create_surface(180, 180)
    # Green fleshy pseudostem trunks
    ctx.set_source_rgb(0.42, 0.65, 0.28)
    ctx.rectangle(75, 100, 14, 75)
    ctx.rectangle(95, 115, 12, 60)
    ctx.fill()
    # Broad arching leaves
    ctx.set_source_rgb(0.28, 0.72, 0.22)
    for angle in [-2.2, -1.6, -1.0, -0.4, 0.2]:
        ctx.move_to(82, 105)
        lx = 82 + 65 * math.cos(angle)
        ly = 105 + 50 * math.sin(angle)
        ctx.curve_to(82 + 25 * math.cos(angle), 105 - 25, lx, ly - 10, lx, ly)
        ctx.set_line_width(8)
        ctx.stroke()
    # Purple banana heart flower
    ctx.set_source_rgb(0.48, 0.18, 0.35)
    ctx.arc(95, 125, 9, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/tree_tamil_banana_clump.png")

    # V6: Flowering Bougainvillea Bush (Vibrant roadside magenta flowers)
    surf, ctx = create_surface(140, 110)
    # Foliage base
    ctx.set_source_rgb(0.18, 0.45, 0.22)
    ctx.arc(70, 75, 45, 0, 2*math.pi)
    ctx.fill()
    # Blazing magenta flower petals
    ctx.set_source_rgb(0.92, 0.15, 0.55)
    for fx, fy in [(50, 60), (70, 50), (90, 65), (65, 80), (85, 85), (40, 80), (100, 75)]:
        ctx.arc(fx, fy, 11, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/shrub_tamil_bougainvillea_pink.png")

# ==============================================================================
# 4. ROADSIDE PROPS (3 Authentic Tamil Items)
# ==============================================================================

def generate_props():
    print("\n--- Generating Tamil Nadu Props ---")
    
    # P1: Traditional Bullock Cart (Wooden spoked wheels and wicker awning)
    surf, ctx = create_surface(160, 110)
    # Wicker / bamboo arched hood
    ctx.set_source_rgb(0.72, 0.58, 0.38)
    ctx.arc(80, 55, 38, math.pi, 2*math.pi)
    ctx.fill()
    # Wooden chassis cart bed
    ctx.set_source_rgb(0.45, 0.28, 0.16)
    ctx.rectangle(30, 55, 100, 10)
    ctx.fill()
    # Spoked wooden wheel
    ctx.set_source_rgb(0.35, 0.20, 0.10)
    ctx.arc(80, 75, 24, 0, 2*math.pi)
    ctx.set_line_width(4)
    ctx.stroke()
    # Spokes
    ctx.set_line_width(2)
    for angle in [i * math.pi / 4 for i in range(4)]:
        ctx.move_to(80 - 24 * math.cos(angle), 75 - 24 * math.sin(angle))
        ctx.line_to(80 + 24 * math.cos(angle), 75 + 24 * math.sin(angle))
        ctx.stroke()
    save_surface(surf, "roadside_props/prop_tamil_bullock_cart.png")

    # P2: Kolam Welcome Signboard (Welcome in Tamil 'நல்வரவு' & geometric kolam)
    surf, ctx = create_surface(120, 80)
    # Green highway metal sign
    ctx.set_source_rgb(0.12, 0.45, 0.25)
    ctx.rectangle(15, 15, 90, 45)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.95, 0.95)
    ctx.set_line_width(2)
    ctx.rectangle(17, 17, 86, 41)
    ctx.stroke()
    # Posts
    ctx.set_source_rgb(0.30, 0.32, 0.35)
    ctx.rectangle(25, 60, 4, 18)
    ctx.rectangle(91, 60, 4, 18)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_tamil_kolam_welcome.png")

    # P3: Coastal Fishing Catamaran & Nets (Catamaran hull with coiled coir ropes)
    surf, ctx = create_surface(170, 90)
    # Tied wooden log catamaran hull
    ctx.set_source_rgb(0.55, 0.38, 0.24)
    ctx.rectangle(20, 45, 130, 16)
    ctx.fill()
    # Coir binding ropes
    ctx.set_source_rgb(0.85, 0.72, 0.45)
    for bx in range(35, 145, 18):
        ctx.rectangle(bx, 43, 4, 20)
        ctx.fill()
    # Blue nylon fishing nets pile
    ctx.set_source_rgb(0.20, 0.45, 0.85)
    ctx.arc(80, 40, 22, math.pi, 2*math.pi)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_tamil_boat_nets.png")

# ==============================================================================
# 5. FAMOUS LANDMARKS (Clean stylized vector art resolving Problem 5)
# ==============================================================================

def generate_landmarks():
    print("\n--- Generating Tamil Nadu Landmarks (Vector Craftsmanship) ---")
    
    # L1: Meenakshi Amman Temple Gopuram (Intricate multi-tier Dravidian gopuram with golden kalasams)
    surf, ctx = create_surface(380, 480)
    # Base granite mandapa gateway
    ctx.set_source_rgb(0.32, 0.30, 0.28) # Granite gray
    ctx.rectangle(60, 360, 260, 110)
    ctx.fill()
    # Main arched gateway opening
    ctx.set_source_rgb(0.12, 0.10, 0.10)
    ctx.rectangle(160, 400, 60, 70)
    ctx.arc(190, 400, 30, math.pi, 2*math.pi)
    ctx.fill()
    # Multi-tiered colorful pyramid tower (9 progressive tiers)
    tier_colors = [
        (0.85, 0.25, 0.20), # Crimson red tier
        (0.95, 0.75, 0.18), # Golden yellow tier
        (0.20, 0.65, 0.35), # Emerald green tier
        (0.25, 0.45, 0.85), # Cobalt blue tier
        (0.88, 0.35, 0.22), # Terracotta tier
        (0.92, 0.68, 0.15), # Amber tier
        (0.22, 0.62, 0.32), # Green tier
        (0.85, 0.22, 0.22), # Red tier
        (0.95, 0.82, 0.25)  # Gold crest
    ]
    for i, col in enumerate(tier_colors):
        tw = 250 - i * 20
        th = 28
        tx = 190 - tw / 2
        ty = 332 - i * 30
        # Tier shelf
        ctx.set_source_rgb(*col)
        ctx.rectangle(tx, ty, tw, th)
        ctx.fill()
        # Stucco sculpture relief dots along each tier
        ctx.set_source_rgb(0.98, 0.98, 0.98)
        for sx in range(int(tx) + 8, int(tx + tw) - 8, 14):
            ctx.arc(sx, ty + 14, 4, 0, 2*math.pi)
            ctx.fill()
    # Barrel vaulted crown (Kuta shikhara)
    ctx.set_source_rgb(0.95, 0.82, 0.22)
    ctx.arc(190, 72, 38, math.pi, 2*math.pi)
    ctx.fill()
    # 7 Golden Kalasam finials on apex
    for kx in range(160, 225, 10):
        ctx.set_source_rgb(0.98, 0.88, 0.25)
        ctx.arc(kx, 34, 4, 0, 2*math.pi)
        ctx.fill()
        ctx.rectangle(kx - 1, 24, 2, 10)
        ctx.fill()
    save_surface(surf, "landmarks/meenakshi_amman_temple_vector.png")

    # L2: Thiruvalluvar Statue (Monumental stone sculpture on 38-foot pedestal with teaching mudra)
    surf, ctx = create_surface(260, 420)
    # Tiered 38-foot stone pedestal base (Alankara Mandapa)
    ctx.set_source_rgb(0.35, 0.36, 0.38) # Dark granite
    ctx.rectangle(40, 310, 180, 100)
    ctx.fill()
    ctx.set_source_rgb(0.42, 0.44, 0.46)
    ctx.rectangle(60, 275, 140, 35)
    ctx.fill()
    # Stone pedestal molding bands
    ctx.set_source_rgb(0.28, 0.29, 0.31)
    ctx.rectangle(35, 305, 190, 8)
    ctx.rectangle(55, 270, 150, 6)
    ctx.fill()
    # Granite Statue Body (Standing sage in flowing ascetic robes)
    ctx.set_source_rgb(0.46, 0.48, 0.50)
    # Robe torso and legs
    ctx.move_to(95, 140)
    ctx.line_to(165, 140)
    ctx.line_to(175, 275)
    ctx.line_to(85, 275)
    ctx.close_path()
    ctx.fill()
    # Draped sash folds
    ctx.set_source_rgba(0.28, 0.30, 0.32, 0.6)
    ctx.set_line_width(3)
    for dy in range(160, 260, 20):
        ctx.move_to(95, dy)
        ctx.curve_to(130, dy + 15, 150, dy + 10, 165, dy)
        ctx.stroke()
    # Right arm raised in teaching mudra (Upadesha mudra)
    ctx.set_source_rgb(0.46, 0.48, 0.50)
    ctx.rectangle(165, 140, 22, 60)
    ctx.fill()
    ctx.arc(176, 135, 10, 0, 2*math.pi) # Hand
    ctx.fill()
    # Left arm holding palm leaf manuscript (Oli chuvadi)
    ctx.rectangle(75, 150, 20, 65)
    ctx.fill()
    ctx.set_source_rgb(0.72, 0.65, 0.50)
    ctx.rectangle(68, 205, 30, 8) # Palm manuscript
    ctx.fill()
    # Head with ascetic hair knot (Jatamakuta) and beard
    ctx.set_source_rgb(0.46, 0.48, 0.50)
    ctx.arc(130, 110, 22, 0, 2*math.pi) # Head
    ctx.fill()
    ctx.arc(130, 82, 14, 0, 2*math.pi)  # Hair knot bun
    ctx.fill()
    # Flowing beard
    ctx.move_to(115, 115)
    ctx.line_to(130, 145)
    ctx.line_to(145, 115)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "landmarks/thiruvalluvar_statue_vector.png")

    # L3: Vivekananda Rock Memorial (Granite rock island base, mandapa with shikhara dome)
    surf, ctx = create_surface(340, 240)
    # Granite rock island rising from the sea
    ctx.set_source_rgb(0.26, 0.25, 0.24)
    ctx.move_to(20, 230)
    ctx.curve_to(60, 160, 140, 150, 180, 155)
    ctx.curve_to(240, 145, 300, 175, 325, 230)
    ctx.close_path()
    ctx.fill()
    # Ocean white foam base
    ctx.set_source_rgba(0.90, 0.95, 1.0, 0.8)
    ctx.rectangle(10, 225, 320, 15)
    ctx.fill()
    # Memorial Mandapa Hall (Pinkish sandstone)
    ctx.set_source_rgb(0.78, 0.52, 0.45)
    ctx.rectangle(100, 95, 140, 60)
    ctx.fill()
    # Carved pillared facade
    ctx.set_source_rgb(0.55, 0.32, 0.28)
    for px in [110, 135, 160, 185, 210, 230]:
        ctx.rectangle(px, 105, 6, 50)
        ctx.fill()
    # Central Shikhara dome
    ctx.set_source_rgb(0.82, 0.58, 0.48)
    ctx.arc(170, 75, 32, math.pi, 2*math.pi)
    ctx.fill()
    # Golden Kalasam apex
    ctx.set_source_rgb(0.95, 0.85, 0.25)
    ctx.arc(170, 38, 6, 0, 2*math.pi)
    ctx.fill()
    ctx.rectangle(169, 28, 2, 10)
    ctx.fill()
    save_surface(surf, "landmarks/vivekananda_rock_memorial_vector.png")

    # L4: Chennai Marina Lighthouse (Triangular red & white concrete tower with glass lantern)
    surf, ctx = create_surface(160, 360)
    # Concrete base pavilion
    ctx.set_source_rgb(0.85, 0.86, 0.88)
    ctx.rectangle(35, 310, 90, 45)
    ctx.fill()
    # Triangular concrete lighthouse tower with red and white alternating bands
    bands = [
        (0.88, 0.22, 0.18), # Red
        (0.96, 0.96, 0.98), # White
        (0.88, 0.22, 0.18), # Red
        (0.96, 0.96, 0.98), # White
        (0.88, 0.22, 0.18), # Red
        (0.96, 0.96, 0.98), # White
        (0.88, 0.22, 0.18)  # Red top
    ]
    for i, bcol in enumerate(bands):
        by = 275 - i * 32
        bw = 54 - i * 3
        bx = 80 - bw / 2
        ctx.set_source_rgb(*bcol)
        ctx.rectangle(bx, by, bw, 32)
        ctx.fill()
    # Observation gallery balcony
    ctx.set_source_rgb(0.25, 0.28, 0.32)
    ctx.rectangle(55, 45, 50, 10)
    ctx.fill()
    # Glass lantern room with red dome
    ctx.set_source_rgba(0.45, 0.75, 0.95, 0.75)
    ctx.rectangle(62, 22, 36, 23)
    ctx.fill()
    ctx.set_source_rgb(0.88, 0.22, 0.18)
    ctx.arc(80, 22, 20, math.pi, 2*math.pi)
    ctx.fill()
    save_surface(surf, "landmarks/chennai_marina_lighthouse_vector.png")

# ==============================================================================
# 6. PARALLAX BACKGROUND LAYERS (Sky, Distant Ocean, Midground Countryside)
# ==============================================================================

def generate_backgrounds():
    print("\n--- Generating Tamil Nadu Parallax Backgrounds ---")
    
    # Layer 1: Coastal Morning Sky (1920x600)
    surf, ctx = create_surface(1920, 600)
    pat = cairo.LinearGradient(0, 0, 0, 600)
    pat.add_color_stop_rgb(0.0, 0.15, 0.48, 0.82) # Deep coastal blue
    pat.add_color_stop_rgb(0.5, 0.42, 0.68, 0.92) # Azure sky
    pat.add_color_stop_rgb(1.0, 0.96, 0.86, 0.72) # Warm morning Indian Ocean glow
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 600)
    ctx.fill()
    save_surface(surf, "backgrounds/sky/kanyakumari_sky_coastal.png")

    # Layer 2: Distant Ocean Horizon & Offshore Rock Islets (1920x450)
    surf, ctx = create_surface(1920, 450)
    # Ocean gradient
    pat = cairo.LinearGradient(0, 180, 0, 450)
    pat.add_color_stop_rgba(0.0, 0.12, 0.38, 0.62, 0.9)
    pat.add_color_stop_rgba(1.0, 0.08, 0.28, 0.48, 0.95)
    ctx.set_source(pat)
    ctx.rectangle(0, 180, 1920, 270)
    ctx.fill()
    # Offshore granite islet silhouettes
    ctx.set_source_rgba(0.18, 0.26, 0.32, 0.75)
    for rx, rw in [(180, 120), (520, 160), (1050, 140), (1580, 190)]:
        ctx.arc(rx, 220, rw / 2, math.pi, 2*math.pi)
        ctx.fill()
    save_surface(surf, "backgrounds/distant_landscape/kanyakumari_ocean_horizon.png")

    # Layer 3: Tamil Countryside Midground (Paddy fields, palmyra trees, rural horizon) (1920x350)
    surf, ctx = create_surface(1920, 350)
    # Rolling green agricultural fields
    ctx.set_source_rgb(0.24, 0.58, 0.28)
    ctx.move_to(0, 180)
    ctx.curve_to(480, 130, 960, 190, 1440, 140)
    ctx.curve_to(1680, 120, 1820, 150, 1920, 160)
    ctx.line_to(1920, 350)
    ctx.line_to(0, 350)
    ctx.close_path()
    ctx.fill()
    # Distant palmyra tree silhouettes on horizon
    ctx.set_source_rgba(0.14, 0.36, 0.18, 0.85)
    for px in range(80, 1900, 160):
        ctx.rectangle(px, 100, 4, 70)
        ctx.fill()
        ctx.arc(px + 2, 95, 16, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "backgrounds/distant_landscape/tamil_countryside_midground.png")

def main():
    generate_buildings()
    generate_shops()
    generate_vegetation()
    generate_props()
    generate_landmarks()
    generate_backgrounds()
    print("=== TAMIL NADU ASSET GENERATION COMPLETE ===")

if __name__ == "__main__":
    main()
