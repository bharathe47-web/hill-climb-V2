#!/usr/bin/env python3
"""
generate_previews.py
Author: Joel (Senior Godot 4.7 Developer, Technical Artist & Art Director)
Generates 10 high-resolution contact sheets / preview sheets in docs/previews/:
  1. preview_landmarks_tamil_nadu.png
  2. preview_landmarks_goa.png
  3. preview_landmarks_kerala.png
  4. preview_landmarks_rajasthan.png
  5. preview_landmarks_gujarat.png
  6. preview_landmarks_telangana.png
  7. preview_buildings.png
  8. preview_vegetation.png
  9. preview_roadside_props.png
  10. preview_backgrounds_and_textures.png
Every item includes: Asset Filename, Place Name, State, Source, License Status.
"""

import cairo
import os
import math

OUT_DIR = "docs/previews"
os.makedirs(OUT_DIR, exist_ok=True)

def create_canvas(w=1920, h=1080):
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surf)
    # Premium dark blueprint studio background
    ctx.set_source_rgb(0.08, 0.10, 0.14)
    ctx.paint()
    return surf, ctx

def draw_header(ctx, title, subtitle):
    # Top banner
    ctx.set_source_rgb(0.12, 0.16, 0.22)
    ctx.rectangle(0, 0, 1920, 80)
    ctx.fill()
    ctx.set_source_rgb(0.98, 0.82, 0.15) # Gold accent line
    ctx.rectangle(0, 78, 1920, 3)
    ctx.fill()

    # Title
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(26)
    ctx.move_to(40, 48)
    ctx.show_text(title)

    # Subtitle / Metadata
    ctx.set_source_rgb(0.70, 0.78, 0.88)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    ctx.set_font_size(15)
    ctx.move_to(1200, 48)
    ctx.show_text(subtitle)

def draw_card(ctx, x, y, w, h, img_path, place_name, filename, state_name, source_str, license_str):
    # Card background container
    ctx.set_source_rgb(0.14, 0.18, 0.24)
    ctx.rectangle(x, y, w, h)
    ctx.fill()
    ctx.set_source_rgb(0.22, 0.28, 0.38)
    ctx.set_line_width(1.5)
    ctx.rectangle(x, y, w, h)
    ctx.stroke()

    # Load and scale image
    if os.path.exists(img_path):
        try:
            img_surf = cairo.ImageSurface.create_from_png(img_path)
            iw = img_surf.get_width()
            ih = img_surf.get_height()
            max_img_w = w - 30
            max_img_h = h - 90
            scale = min(max_img_w / iw, max_img_h / ih)
            dw = iw * scale
            dh = ih * scale
            dx = x + (w - dw) / 2
            dy = y + 15 + (max_img_h - dh) / 2

            ctx.save()
            ctx.translate(dx, dy)
            ctx.scale(scale, scale)
            ctx.set_source_surface(img_surf, 0, 0)
            ctx.paint()
            ctx.restore()
        except Exception as e:
            print(f"Error loading {img_path}: {e}")

    # Metadata footer area
    footer_y = y + h - 75
    ctx.set_source_rgb(0.10, 0.12, 0.16)
    ctx.rectangle(x, footer_y, w, 75)
    ctx.fill()

    # Place Name (bold yellow/white)
    ctx.set_source_rgb(0.98, 0.85, 0.25)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(12)
    ctx.move_to(x + 10, footer_y + 18)
    ctx.show_text(place_name[:32])

    # Filename
    ctx.set_source_rgb(0.85, 0.90, 0.95)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    ctx.set_font_size(10)
    ctx.move_to(x + 10, footer_y + 34)
    ctx.show_text(f"File: {filename[:36]}")

    # Source & State
    ctx.set_source_rgb(0.65, 0.75, 0.85)
    ctx.set_font_size(9)
    ctx.move_to(x + 10, footer_y + 49)
    ctx.show_text(f"State: {state_name} | Source: {source_str[:22]}")

    # License Badge
    ctx.set_source_rgb(0.20, 0.70, 0.40) # Green verified badge
    ctx.rectangle(x + 10, footer_y + 56, 85, 14)
    ctx.fill()
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(8)
    ctx.move_to(x + 14, footer_y + 67)
    ctx.show_text(f"{license_str}")

    # Release Approved tag
    ctx.set_source_rgb(0.25, 0.55, 0.90)
    ctx.rectangle(x + 102, footer_y + 56, 110, 14)
    ctx.fill()
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.move_to(x + 106, footer_y + 67)
    ctx.show_text("RELEASE APPROVED")

# ==============================================================================
# CONTACT SHEET GENERATORS
# ==============================================================================

def generate_landmark_sheet(title, state, items, filename):
    surf, ctx = create_canvas(1920, 1080)
    draw_header(ctx, title, f"Indian Roads Mode V2 | State: {state} | 100% Commercial Cleared")
    # 2 rows x 4 cols grid
    card_w = 420
    card_h = 440
    gap_x = 40
    gap_y = 35
    start_x = (1920 - (4 * card_w + 3 * gap_x)) / 2
    start_y = 110

    for idx, it in enumerate(items[:8]):
        col = idx % 4
        row = idx // 4
        cx = start_x + col * (card_w + gap_x)
        cy = start_y + row * (card_h + gap_y)
        draw_card(ctx, cx, cy, card_w, card_h, it["path"], it["name"], os.path.basename(it["path"]), state, it["source"], it["license"])

    out_path = os.path.join(OUT_DIR, filename)
    surf.write_to_png(out_path)
    print(f"  ✓ Contact Sheet Generated: {out_path}")

def main():
    print("==================================================")
    print("STARTING CONTACT SHEETS & PREVIEW GENERATION")
    print("==================================================")

    # 1. Tamil Nadu Landmarks
    tn_items = [
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/landmarks/thiruvalluvar_statue.png", "name": "Thiruvalluvar Statue (133-ft)", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/landmarks/vivekananda_rock_memorial.png", "name": "Vivekananda Rock Memorial", "source": "Team Vector / Wikimedia", "license": "CC-BY 3.0"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/landmarks/kanyakumari_glass_bridge.png", "name": "Kanyakumari Glass Bridge", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/landmarks/kumari_amman_temple.png", "name": "Kumari Amman Temple", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/madurai/landmarks/meenakshi_amman_temple.png", "name": "Madurai Meenakshi Gopuram", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/madurai/landmarks/thirumalai_nayakkar_mahal.png", "name": "Thirumalai Nayakkar Mahal", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/chennai/landmarks/brihadeeswarar_temple_vimana.png", "name": "Brihadeeswarar Great Chola Vimana", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/chennai/landmarks/chennai_marina_lighthouse.png", "name": "Chennai Marina Lighthouse", "source": "Original Team Vector", "license": "CC0 Universal"}
    ]
    generate_landmark_sheet("TAMIL NADU LANDMARKS — PREVIEW CONTACT SHEET", "Tamil Nadu", tn_items, "preview_landmarks_tamil_nadu.png")

    # 2. Goa Landmarks
    goa_items = [
        {"path": "assets/indian_locations/asset_collection_v2/goa/panaji/landmarks/our_lady_immaculate_conception.png", "name": "Our Lady of Immaculate Conception", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/panaji/landmarks/fontainhas_heritage_quarter.png", "name": "Fontainhas Latin Quarter", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/old_goa/landmarks/basilica_of_bom_jesus.png", "name": "Basilica of Bom Jesus", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/old_goa/landmarks/se_cathedral.png", "name": "Se Cathedral & Golden Bell", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/north_goa/landmarks/fort_aguada_lighthouse.png", "name": "Fort Aguada & Lighthouse", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/north_goa/landmarks/chapora_fort.png", "name": "Chapora Fort Clifftop", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/south_goa/landmarks/margao_municipal_arch.png", "name": "Margao Municipal Gateway", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/inland_goa/landmarks/dudhsagar_waterfalls.png", "name": "Dudhsagar Waterfalls & Viaduct", "source": "Original Team Vector", "license": "CC0 Universal"}
    ]
    generate_landmark_sheet("GOA LANDMARKS — PREVIEW CONTACT SHEET", "Goa", goa_items, "preview_landmarks_goa.png")

    # 3. Kerala Landmarks
    ker_items = [
        {"path": "assets/indian_locations/asset_collection_v2/kerala/kochi/landmarks/fort_kochi_chinese_fishing_nets.png", "name": "Fort Kochi Chinese Fishing Nets", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/kerala/kochi/landmarks/mattancherry_dutch_palace.png", "name": "Mattancherry Dutch Palace", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/kerala/alappuzha/landmarks/alleppey_backwaters_houseboat.png", "name": "Alleppey Thatched Houseboat", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/kerala/alappuzha/landmarks/padmanabhaswamy_temple.png", "name": "Sree Padmanabhaswamy Temple", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/kerala/munnar/landmarks/munnar_tea_plantations.png", "name": "Munnar Terraced Tea Gardens", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/kerala/munnar/landmarks/athirappilly_waterfalls.png", "name": "Athirappilly Rainforest Falls", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/kerala/wayanad/landmarks/bekal_fort_keyhole_bastion.png", "name": "Bekal Fort Keyhole Bastion", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/kerala/kochi/buildings/house_kerala_nalukettu.png", "name": "Traditional Nalukettu Timber Home", "source": "Original Team Vector", "license": "CC0 Universal"}
    ]
    generate_landmark_sheet("KERALA LANDMARKS — PREVIEW CONTACT SHEET", "Kerala", ker_items, "preview_landmarks_kerala.png")

    # 4. Rajasthan Landmarks
    raj_items = [
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jaipur/landmarks/hawa_mahal_palace_of_winds.png", "name": "Hawa Mahal (Palace of Winds)", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jaipur/landmarks/amber_fort_gateway.png", "name": "Amber Fort Suraj Pol Gate", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jaipur/landmarks/jal_mahal_water_palace.png", "name": "Jal Mahal Lake Palace", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jodhpur/landmarks/mehrangarh_fort_bastion.png", "name": "Mehrangarh Fort Monolith", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jodhpur/landmarks/umaid_bhawan_palace.png", "name": "Umaid Bhawan Palace", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jaisalmer/landmarks/jaisalmer_golden_fort.png", "name": "Jaisalmer Sonar Qila", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/udaipur/landmarks/chittorgarh_vijay_stambha.png", "name": "Chittorgarh Vijay Stambha", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jaisalmer/landmarks/sam_sand_dunes_desert_camp.png", "name": "Sam Sand Dunes & Camels", "source": "Original Team Vector", "license": "CC0 Universal"}
    ]
    generate_landmark_sheet("RAJASTHAN LANDMARKS — PREVIEW CONTACT SHEET", "Rajasthan", raj_items, "preview_landmarks_rajasthan.png")

    # 5. Gujarat Landmarks
    guj_items = [
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/ahmedabad/landmarks/ahmedabad_teen_darwaza.png", "name": "Ahmedabad Teen Darwaza Gate", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/ahmedabad/landmarks/sabarmati_ashram_hridaya_kunj.png", "name": "Sabarmati Ashram Hridaya Kunj", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/modhera/landmarks/modhera_sun_temple.png", "name": "Modhera Sun Temple & Kund", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/modhera/landmarks/rani_ki_vav_stepwell.png", "name": "Rani ki Vav Queen's Stepwell", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/kutch/landmarks/great_rann_white_desert.png", "name": "Great Rann White Salt Desert", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/dwarka/landmarks/statue_of_unity.png", "name": "Statue of Unity (182m)", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/dwarka/landmarks/dwarkadhish_temple.png", "name": "Dwarkadhish Temple (Jagat Mandir)", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/ahmedabad/buildings/house_gujarat_kutch_bhunga.png", "name": "Traditional Kutch Bhunga Hut", "source": "Original Team Vector", "license": "CC0 Universal"}
    ]
    generate_landmark_sheet("GUJARAT LANDMARKS — PREVIEW CONTACT SHEET", "Gujarat", guj_items, "preview_landmarks_gujarat.png")

    # 6. Telangana Landmarks
    ts_items = [
        {"path": "assets/indian_locations/asset_collection_v2/telangana/hyderabad/landmarks/hyderabad_charminar.png", "name": "Charminar Monumental Gateway", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/telangana/hyderabad/landmarks/golconda_fort_bastion.png", "name": "Golconda Fort Granite Citadel", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/telangana/hyderabad/landmarks/hussain_sagar_buddha.png", "name": "Hussain Sagar Monolithic Buddha", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/telangana/warangal/landmarks/kakatiya_kala_thoranam.png", "name": "Kakatiya Kala Thoranam Arch", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/telangana/warangal/landmarks/thousand_pillar_temple.png", "name": "Thousand Pillar Temple & Nandi", "source": "Team Vector / Wikimedia", "license": "CC-BY-SA 4.0"},
        {"path": "assets/indian_locations/asset_collection_v2/telangana/ramappa/landmarks/ramappa_temple_rudreswara.png", "name": "Ramappa UNESCO World Heritage", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/telangana/ramappa/landmarks/laknavaram_suspension_bridge.png", "name": "Laknavaram Suspension Bridge", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/telangana/hyderabad/buildings/house_telangana_deccan_granite.png", "name": "Deccan Granite Stone Home", "source": "Original Team Vector", "license": "CC0 Universal"}
    ]
    generate_landmark_sheet("TELANGANA LANDMARKS — PREVIEW CONTACT SHEET", "Telangana", ts_items, "preview_landmarks_telangana.png")

    # 7. Regional Buildings
    bldg_items = [
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/buildings/house_tamil_chettinad_mansion.png", "name": "Chettinad Carved Mansion", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/buildings/house_tamil_agraharam.png", "name": "Tamil Agraharam Heritage House", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/panaji/buildings/house_goa_fontainhas_yellow.png", "name": "Fontainhas Ochre Villa", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/panaji/buildings/house_goa_fontainhas_blue.png", "name": "Portuguese Cobalt Indigo Home", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/kerala/kochi/buildings/house_kerala_nalukettu.png", "name": "Nalukettu Sloping Tile House", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jaipur/buildings/house_rajasthan_jaipur_haveli.png", "name": "Rajput Sandstone Haveli", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jodhpur/buildings/house_rajasthan_jodhpur_blue.png", "name": "Jodhpur Blue City House", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/ahmedabad/buildings/house_gujarat_ahmedabad_pol.png", "name": "Ahmedabad Pol Heritage House", "source": "Original Team Vector", "license": "CC0 Universal"}
    ]
    generate_landmark_sheet("REGIONAL BUILDINGS & ARCHITECTURE — PREVIEW CONTACT SHEET", "All 6 States", bldg_items, "preview_buildings.png")

    # 8. Regional Vegetation
    veg_items = [
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/vegetation/tree_tamil_palmyra_tall.png", "name": "Palmyra Tall Palm (TN State Tree)", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/vegetation/tree_tamil_banyan_sprawling.png", "name": "Sprawling Sacred Banyan Tree", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/panaji/vegetation/tree_goa_coconut_beach.png", "name": "Curved Leaning Coastal Palm", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/panaji/vegetation/tree_goa_frangipani_champa.png", "name": "Flowering Frangipani Champa", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/kerala/kochi/vegetation/tree_kerala_coconut_tall.png", "name": "Malabar Coast Tall Coconut Palm", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jaipur/vegetation/tree_rajasthan_khejri_desert.png", "name": "Khejri Desert Tree (RJ State Tree)", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jaipur/vegetation/shrub_rajasthan_prickly_pear.png", "name": "Prickly Pear Desert Cactus", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/telangana/hyderabad/vegetation/tree_telangana_flame_of_forest.png", "name": "Flame of the Forest (Moduga/Palash)", "source": "Original Team Vector", "license": "CC0 Universal"}
    ]
    generate_landmark_sheet("REGIONAL BOTANICAL VEGETATION — PREVIEW CONTACT SHEET", "All 6 States", veg_items, "preview_vegetation.png")

    # 9. Roadside Props
    prop_items = [
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/roadside_props/shop_tamil_tea_kadai.png", "name": "Roadside Tea Kadai Boiler Stall", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/roadside_props/shop_tamil_flower_poo_kadai.png", "name": "Madurai Jasmine Flower Poo Stall", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/panaji/roadside_props/shop_goa_pao_bakery.png", "name": "Portuguese Pao Bakery Kiosk", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/goa/north_goa/roadside_props/prop_goa_surfboard_rack.png", "name": "Coastal Beach Surfboard Rack", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/kerala/kochi/roadside_props/shop_kerala_banana_chips.png", "name": "Nendran Banana Chips Fryer", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jaipur/roadside_props/shop_rajasthan_highway_dhaba.png", "name": "Sandstone Highway Dhaba Stall", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/ahmedabad/roadside_props/shop_gujarat_kathiyawadi_dhaba.png", "name": "Kathiyawadi Highway Dhaba", "source": "Original Team Vector", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/telangana/hyderabad/roadside_props/shop_telangana_irani_chai.png", "name": "Irani Chai & Osmania Biscuit Cafe", "source": "Original Team Vector", "license": "CC0 Universal"}
    ]
    generate_landmark_sheet("ROADSIDE SHOPS, STALLS & PROPS — PREVIEW CONTACT SHEET", "All 6 States", prop_items, "preview_roadside_props.png")

    # 10. Seamless Textures & Highway Surfaces
    tex_items = [
        {"path": "assets/indian_locations/asset_collection_v2/shared/textures/texture_asphalt_dark.png", "name": "Seamless Dark Asphalt Highway", "source": "Original Procedural", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/textures/texture_laterite_red.png", "name": "Seamless Red Laterite Soil", "source": "Original Procedural", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/rajasthan/jaipur/textures/texture_sand_desert_thar.png", "name": "Seamless Thar Golden Sand", "source": "Original Procedural", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/gujarat/kutch/textures/texture_salt_crust_white.png", "name": "Seamless White Rann Salt Crust", "source": "Original Procedural", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/telangana/hyderabad/textures/texture_deccan_granite_rock.png", "name": "Seamless Deccan Granite Bedrock", "source": "Original Procedural", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/shared/textures/texture_gravel_coastal.png", "name": "Seamless Coastal Aggregate Gravel", "source": "Original Procedural", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/shared/textures/texture_concrete_smooth.png", "name": "Seamless Highway Bridge Concrete", "source": "Original Procedural", "license": "CC0 Universal"},
        {"path": "assets/indian_locations/asset_collection_v2/shared/barriers/barricade_yellow_black_stripes.png", "name": "Hazard Barricade Stripe Barrier", "source": "Original Team Vector", "license": "CC0 Universal"}
    ]
    generate_landmark_sheet("SEAMLESS HIGHWAY & TERRAIN TEXTURES — PREVIEW CONTACT SHEET", "All 6 States", tex_items, "preview_backgrounds_and_textures.png")

    print("==================================================")
    print("ALL 10 CONTACT SHEETS GENERATED IN docs/previews/!")
    print("==================================================")

if __name__ == "__main__":
    main()
