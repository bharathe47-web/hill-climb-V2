class_name RoadsideLandmarkRegistry
extends RefCounted

## RoadsideLandmarkRegistry: Authoritative catalog of roadside famous attractions along Indian Roads.
## Positions real temples, forts, palaces, towers, bridges, and natural monuments
## along the player's continuous highway journey.

static func get_landmarks_for_state(state_id: String) -> Array[Dictionary]:
	match state_id:
		"tamil_nadu":
			return [
				{
					"id": "LOC-TN-03",
					"name": "Kanyakumari Sunrise Point",
					"district": "Triveni Sangam Coast",
					"category": "coastal_attraction",
					"asset": "res://assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/landmarks/gandhi_memorial_mandapam.png",
					"distance_m": 140.0,
					"target_height": 180.0,
					"show_sign": true
				},
				{
					"id": "LOC-TN-01",
					"name": "Thiruvalluvar Statue",
					"district": "Kanyakumari Shore",
					"category": "tall_tower",
					"asset": "res://assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/landmarks/thiruvalluvar_statue.png",
					"distance_m": 350.0,
					"target_height": 330.0,
					"show_sign": true
				},
				{
					"id": "LOC-TN-02",
					"name": "Vivekananda Rock Memorial",
					"district": "Kanyakumari Ocean",
					"category": "medium_monument",
					"asset": "res://assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/landmarks/vivekananda_rock_memorial.png",
					"distance_m": 540.0,
					"target_height": 230.0,
					"show_sign": true
				},
				{
					"id": "LOC-TN-08",
					"name": "Suchindram Temple",
					"district": "Kanyakumari District",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/landmarks/kumari_amman_temple.png",
					"distance_m": 750.0,
					"target_height": 310.0,
					"show_sign": true
				},
				{
					"id": "LOC-TN-10",
					"name": "Padmanabhapuram Palace",
					"district": "Thuckalay Royal Seat",
					"category": "palace",
					"asset": "res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/padmanabhapuram_palace/padmanabhapuram_palace.png",
					"distance_m": 950.0,
					"target_height": 220.0,
					"show_sign": true
				},
				{
					"id": "LOC-TN-11",
					"name": "Mathoor Hanging Aqueduct",
					"district": "Aruvikkarai Valley",
					"category": "bridge",
					"asset": "res://assets/indian_locations/asset_collection_v2/tamil_nadu/kanyakumari/landmarks/mathoor_aqueduct.png",
					"distance_m": 1150.0,
					"target_height": 210.0,
					"show_sign": true
				},
				{
					"id": "LOC-TN-15",
					"name": "Thirumalai Nayakkar Mahal",
					"district": "Madurai Palace Corridor",
					"category": "large_fort",
					"asset": "res://assets/indian_locations/asset_collection_v2/tamil_nadu/madurai/landmarks/thirumalai_nayakkar_mahal.png",
					"distance_m": 1320.0,
					"target_height": 230.0,
					"show_sign": true
				},
				{
					"id": "LOC-TN-14",
					"name": "Meenakshi Amman Temple",
					"district": "Madurai Heritage Heart",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/asset_collection_v2/tamil_nadu/madurai/landmarks/meenakshi_amman_temple.png",
					"distance_m": 1480.0,
					"target_height": 330.0,
					"show_sign": true
				},
				{
					"id": "LOC-TN-22",
					"name": "Marina Lighthouse",
					"district": "Marina Beach, Chennai",
					"category": "tall_tower",
					"asset": "res://assets/indian_locations/asset_collection_v2/tamil_nadu/chennai/landmarks/chennai_marina_lighthouse.png",
					"distance_m": 1650.0,
					"target_height": 300.0,
					"show_sign": true
				},
				{
					"id": "LOC-TN-25",
					"name": "San Thome Basilica",
					"district": "Chennai Coastal Avenue",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/asset_collection_v2/tamil_nadu/chennai/landmarks/san_thome_basilica.png",
					"distance_m": 1800.0,
					"target_height": 280.0,
					"show_sign": true
				}
			]

		"goa":
			return [
				{
					"id": "LOC-GA-02",
					"name": "Fontainhas Latin Quarter",
					"district": "Panaji Heritage Quarter",
					"category": "medium_monument",
					"asset": "res://assets/indian_locations/asset_collection_v2/goa/panaji/landmarks/fontainhas_heritage_quarter.png",
					"distance_m": 130.0,
					"target_height": 190.0,
					"show_sign": true
				},
				{
					"id": "LOC-GA-01",
					"name": "Our Lady of Conception",
					"district": "Panaji Church Square",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/asset_collection_v2/goa/panaji/landmarks/our_lady_immaculate_conception.png",
					"distance_m": 320.0,
					"target_height": 300.0,
					"show_sign": true
				},
				{
					"id": "LOC-GA-03",
					"name": "Mandovi Riverfront",
					"district": "Panaji River Boulevard",
					"category": "coastal_attraction",
					"asset": "res://assets/indian_locations/goa/panaji/mandovi_riverfront.png",
					"distance_m": 520.0,
					"target_height": 210.0,
					"show_sign": true
				},
				{
					"id": "LOC-GA-08",
					"name": "Reis Magos Fort",
					"district": "Verem / Mandovi",
					"category": "large_fort",
					"asset": "res://assets/indian_locations/goa/north_goa/reis_magos_fort.png",
					"distance_m": 720.0,
					"target_height": 220.0,
					"show_sign": true
				},
				{
					"id": "LOC-GA-09",
					"name": "Fort Aguada & Lighthouse",
					"district": "Sinquerim Coastal Bluff",
					"category": "tall_tower",
					"asset": "res://assets/indian_locations/asset_collection_v2/goa/north_goa/landmarks/fort_aguada_lighthouse.png",
					"distance_m": 920.0,
					"target_height": 280.0,
					"show_sign": true
				},
				{
					"id": "LOC-GA-11",
					"name": "Calangute Beach Coast",
					"district": "Bardez Beach Highway",
					"category": "coastal_attraction",
					"asset": "res://assets/indian_locations/asset_collection_v2/goa/north_goa/landmarks/calangute_beach_promenade.png",
					"distance_m": 1120.0,
					"target_height": 200.0,
					"show_sign": true
				},
				{
					"id": "LOC-GA-14",
					"name": "Chapora Fort Bastion",
					"district": "Vagator Hilltop",
					"category": "large_fort",
					"asset": "res://assets/indian_locations/asset_collection_v2/goa/north_goa/landmarks/chapora_fort.png",
					"distance_m": 1200.0,
					"target_height": 230.0,
					"show_sign": true
				},
				{
					"id": "LOC-GA-15",
					"name": "Basilica of Bom Jesus",
					"district": "Old Goa UNESCO Heritage",
					"category": "medium_monument",
					"asset": "res://assets/indian_locations/asset_collection_v2/goa/old_goa/landmarks/basilica_of_bom_jesus.png",
					"distance_m": 1280.0,
					"target_height": 290.0,
					"show_sign": true
				},
				{
					"id": "LOC-GA-16",
					"name": "Se Cathedral",
					"district": "Old Goa Cathedral Square",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/asset_collection_v2/goa/old_goa/landmarks/se_cathedral.png",
					"distance_m": 1420.0,
					"target_height": 310.0,
					"show_sign": true
				},
				{
					"id": "LOC-GA-22",
					"name": "Dudhsagar Waterfalls",
					"district": "Mollem Ghats Foothills",
					"category": "natural_attraction",
					"asset": "res://assets/indian_locations/asset_collection_v2/goa/inland_goa/landmarks/dudhsagar_waterfalls.png",
					"distance_m": 1520.0,
					"target_height": 300.0,
					"show_sign": true
				},
				{
					"id": "LOC-GA-25",
					"name": "Holy Spirit Church",
					"district": "Margao Municipal Square",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/asset_collection_v2/goa/south_goa/landmarks/margao_municipal_arch.png",
					"distance_m": 1600.0,
					"target_height": 270.0,
					"show_sign": true
				}
			]

		"kerala":
			return [
				{
					"id": "LOC-KL-09",
					"name": "Chinese Fishing Nets",
					"district": "Fort Kochi Coast",
					"category": "coastal_attraction",
					"asset": "res://assets/indian_locations/asset_collection_v2/kerala/kochi/landmarks/fort_kochi_chinese_fishing_nets.png",
					"distance_m": 160.0,
					"target_height": 240.0,
					"show_sign": true
				},
				{
					"id": "LOC-KL-10",
					"name": "Mattancherry Palace",
					"district": "Kochi Heritage Quarter",
					"category": "palace",
					"asset": "res://assets/indian_locations/asset_collection_v2/kerala/kochi/landmarks/mattancherry_dutch_palace.png",
					"distance_m": 380.0,
					"target_height": 210.0,
					"show_sign": true
				},
				{
					"id": "LOC-KL-01",
					"name": "Alleppey Backwaters",
					"district": "Alappuzha Punnamada",
					"category": "natural_attraction",
					"asset": "res://assets/indian_locations/asset_collection_v2/kerala/alappuzha/landmarks/alleppey_backwaters_houseboat.png",
					"distance_m": 600.0,
					"target_height": 230.0,
					"show_sign": true
				},
				{
					"id": "LOC-KL-14",
					"name": "Athirappilly Waterfalls",
					"district": "Chalakudy River Gorge",
					"category": "natural_attraction",
					"asset": "res://assets/indian_locations/asset_collection_v2/kerala/munnar/landmarks/athirappilly_waterfalls.png",
					"distance_m": 1000.0,
					"target_height": 270.0,
					"show_sign": true
				},
				{
					"id": "LOC-KL-04",
					"name": "Munnar Tea Plantations",
					"district": "Idukki High Ranges",
					"category": "natural_attraction",
					"asset": "res://assets/indian_locations/asset_collection_v2/kerala/munnar/landmarks/munnar_tea_plantations.png",
					"distance_m": 1350.0,
					"target_height": 240.0,
					"show_sign": true
				},
				{
					"id": "LOC-KL-17",
					"name": "Bekal Fort Bastion",
					"district": "Kasaragod Arabian Sea",
					"category": "large_fort",
					"asset": "res://assets/indian_locations/asset_collection_v2/kerala/wayanad/landmarks/bekal_fort_keyhole_bastion.png",
					"distance_m": 1600.0,
					"target_height": 220.0,
					"show_sign": true
				},
				{
					"id": "LOC-KL-25",
					"name": "Padmanabhaswamy Temple",
					"district": "Thiruvananthapuram",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/asset_collection_v2/kerala/alappuzha/landmarks/padmanabhaswamy_temple.png",
					"distance_m": 1850.0,
					"target_height": 330.0,
					"show_sign": true
				}
			]

		"rajasthan":
			return [
				{
					"id": "LOC-RJ-02",
					"name": "Hawa Mahal",
					"district": "Pink City, Jaipur",
					"category": "tall_tower",
					"asset": "res://assets/indian_locations/asset_collection_v2/rajasthan/jaipur/landmarks/hawa_mahal_palace_of_winds.png",
					"distance_m": 180.0,
					"target_height": 330.0,
					"show_sign": true
				},
				{
					"id": "LOC-RJ-03",
					"name": "Jal Mahal Palace",
					"district": "Man Sagar Lake, Jaipur",
					"category": "palace",
					"asset": "res://assets/indian_locations/asset_collection_v2/rajasthan/jaipur/landmarks/jal_mahal_water_palace.png",
					"distance_m": 440.0,
					"target_height": 210.0,
					"show_sign": true
				},
				{
					"id": "LOC-RJ-01",
					"name": "Amber Fort Gateway",
					"district": "Amer, Aravalli Ridge",
					"category": "large_fort",
					"asset": "res://assets/indian_locations/asset_collection_v2/rajasthan/jaipur/landmarks/amber_fort_gateway.png",
					"distance_m": 700.0,
					"target_height": 270.0,
					"show_sign": true
				},
				{
					"id": "LOC-RJ-10",
					"name": "Mehrangarh Fort",
					"district": "Jodhpur Blue City",
					"category": "large_fort",
					"asset": "res://assets/indian_locations/asset_collection_v2/rajasthan/jodhpur/landmarks/mehrangarh_fort_bastion.png",
					"distance_m": 1000.0,
					"target_height": 280.0,
					"show_sign": true
				},
				{
					"id": "LOC-RJ-12",
					"name": "Umaid Bhawan Palace",
					"district": "Jodhpur Marble Ridge",
					"category": "medium_monument",
					"asset": "res://assets/indian_locations/asset_collection_v2/rajasthan/jodhpur/landmarks/umaid_bhawan_palace.png",
					"distance_m": 1280.0,
					"target_height": 260.0,
					"show_sign": true
				},
				{
					"id": "LOC-RJ-19",
					"name": "Chittorgarh Vijay Stambha",
					"district": "Chittorgarh Fort Ridge",
					"category": "tall_tower",
					"asset": "res://assets/indian_locations/asset_collection_v2/rajasthan/udaipur/landmarks/chittorgarh_vijay_stambha.png",
					"distance_m": 1450.0,
					"target_height": 290.0,
					"show_sign": true
				},
				{
					"id": "LOC-RJ-18",
					"name": "Sam Sand Dunes",
					"district": "Thar Desert Oasis",
					"category": "natural_attraction",
					"asset": "res://assets/indian_locations/asset_collection_v2/rajasthan/jaisalmer/landmarks/sam_sand_dunes_desert_camp.png",
					"distance_m": 1650.0,
					"target_height": 250.0,
					"show_sign": true
				},
				{
					"id": "LOC-RJ-15",
					"name": "Jaisalmer Golden Fort",
					"district": "Thar Desert Living Fort",
					"category": "large_fort",
					"asset": "res://assets/indian_locations/asset_collection_v2/rajasthan/jaisalmer/landmarks/jaisalmer_golden_fort.png",
					"distance_m": 1850.0,
					"target_height": 290.0,
					"show_sign": true
				}
			]

		"gujarat":
			return [
				{
					"id": "LOC-GJ-04",
					"name": "Sabarmati Ashram",
					"district": "Ahmedabad Riverfront",
					"category": "medium_monument",
					"asset": "res://assets/indian_locations/asset_collection_v2/gujarat/ahmedabad/landmarks/sabarmati_ashram_hridaya_kunj.png",
					"distance_m": 180.0,
					"target_height": 190.0,
					"show_sign": true
				},
				{
					"id": "LOC-GJ-10",
					"name": "Teen Darwaza",
					"district": "Ahmedabad Old City",
					"category": "medium_monument",
					"asset": "res://assets/indian_locations/asset_collection_v2/gujarat/ahmedabad/landmarks/ahmedabad_teen_darwaza.png",
					"distance_m": 350.0,
					"target_height": 220.0,
					"show_sign": true
				},
				{
					"id": "LOC-GJ-08",
					"name": "Modhera Sun Temple",
					"district": "Mehsana Surya Kund",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/asset_collection_v2/gujarat/modhera/landmarks/modhera_sun_temple.png",
					"distance_m": 680.0,
					"target_height": 270.0,
					"show_sign": true
				},
				{
					"id": "LOC-GJ-12",
					"name": "Rani Ki Vav Stepwell",
					"district": "Patan Subterranean",
					"category": "medium_monument",
					"asset": "res://assets/indian_locations/asset_collection_v2/gujarat/modhera/landmarks/rani_ki_vav_stepwell.png",
					"distance_m": 900.0,
					"target_height": 240.0,
					"show_sign": true
				},
				{
					"id": "LOC-GJ-01",
					"name": "Saurashtra Highway Oasis",
					"district": "NH27 Saurashtra Corridor",
					"category": "coastal_attraction",
					"asset": "res://assets/indian_locations/gujarat/saurashtra_rann_oasis.png",
					"distance_m": 1100.0,
					"target_height": 190.0,
					"show_sign": true
				},
				{
					"id": "LOC-GJ-02",
					"name": "Flamingo Sanctuary",
					"district": "Kutch Wetland Reserve",
					"category": "natural_attraction",
					"asset": "res://assets/indian_locations/gujarat/flamingo_sanctuary_pass.png",
					"distance_m": 1350.0,
					"target_height": 220.0,
					"show_sign": true
				},
				{
					"id": "LOC-GJ-03",
					"name": "White Desert of Kutch",
					"district": "Great Rann Salt Crust",
					"category": "natural_attraction",
					"asset": "res://assets/indian_locations/asset_collection_v2/gujarat/kutch/landmarks/great_rann_white_desert.png",
					"distance_m": 1550.0,
					"target_height": 210.0,
					"show_sign": true
				},
				{
					"id": "LOC-GJ-21",
					"name": "Dwarkadhish Temple",
					"district": "Dwarka Coastal Shore",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/asset_collection_v2/gujarat/dwarka/landmarks/dwarkadhish_temple.png",
					"distance_m": 1750.0,
					"target_height": 310.0,
					"show_sign": true
				},
				{
					"id": "LOC-GJ-24",
					"name": "Statue of Unity",
					"district": "Kevadia, Narmada River",
					"category": "tall_tower",
					"asset": "res://assets/indian_locations/asset_collection_v2/gujarat/dwarka/landmarks/statue_of_unity.png",
					"distance_m": 1920.0,
					"target_height": 340.0,
					"show_sign": true
				}
			]

		"telangana":
			return [
				{
					"id": "LOC-TS-04",
					"name": "Charminar Monument",
					"district": "Old Hyderabad City",
					"category": "tall_tower",
					"asset": "res://assets/indian_locations/asset_collection_v2/telangana/hyderabad/landmarks/hyderabad_charminar.png",
					"distance_m": 180.0,
					"target_height": 330.0,
					"show_sign": true
				},
				{
					"id": "LOC-TS-06",
					"name": "Chowmahalla Palace",
					"district": "Hyderabad Nizam Seat",
					"category": "palace",
					"asset": "res://assets/indian_locations/telangana/landmarks/chowmahalla_palace.png",
					"distance_m": 420.0,
					"target_height": 220.0,
					"show_sign": true
				},
				{
					"id": "LOC-TS-01",
					"name": "Golconda Fort Bastion",
					"district": "Western Hyderabad Citadel",
					"category": "large_fort",
					"asset": "res://assets/indian_locations/asset_collection_v2/telangana/hyderabad/landmarks/golconda_fort_bastion.png",
					"distance_m": 680.0,
					"target_height": 280.0,
					"show_sign": true
				},
				{
					"id": "LOC-TS-08",
					"name": "Hussain Sagar Buddha",
					"district": "Tank Bund Gibraltar Rock",
					"category": "tall_tower",
					"asset": "res://assets/indian_locations/asset_collection_v2/telangana/hyderabad/landmarks/hussain_sagar_buddha.png",
					"distance_m": 920.0,
					"target_height": 310.0,
					"show_sign": true
				},
				{
					"id": "LOC-TS-09",
					"name": "Birla Mandir Temple",
					"district": "Naubat Pahad Granite Hill",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/telangana/landmarks/birla_mandir.png",
					"distance_m": 1150.0,
					"target_height": 280.0,
					"show_sign": true
				},
				{
					"id": "LOC-TS-02",
					"name": "Kakatiya Kala Thoranam",
					"district": "Warangal Fort Gateway",
					"category": "medium_monument",
					"asset": "res://assets/indian_locations/asset_collection_v2/telangana/warangal/landmarks/kakatiya_kala_thoranam.png",
					"distance_m": 1360.0,
					"target_height": 250.0,
					"show_sign": true
				},
				{
					"id": "LOC-TS-03",
					"name": "Thousand Pillar Temple",
					"district": "Hanamkonda, Warangal",
					"category": "medium_monument",
					"asset": "res://assets/indian_locations/asset_collection_v2/telangana/warangal/landmarks/thousand_pillar_temple.png",
					"distance_m": 1550.0,
					"target_height": 240.0,
					"show_sign": true
				},
				{
					"id": "LOC-TS-18",
					"name": "Laknavaram Suspension Bridge",
					"district": "Mulugu Green Islands",
					"category": "bridge",
					"asset": "res://assets/indian_locations/asset_collection_v2/telangana/ramappa/landmarks/laknavaram_suspension_bridge.png",
					"distance_m": 1680.0,
					"target_height": 220.0,
					"show_sign": true
				},
				{
					"id": "LOC-TS-15",
					"name": "Ramappa Temple",
					"district": "Palampet UNESCO Heritage",
					"category": "tall_temple",
					"asset": "res://assets/indian_locations/asset_collection_v2/telangana/ramappa/landmarks/ramappa_temple_rudreswara.png",
					"distance_m": 1780.0,
					"target_height": 290.0,
					"show_sign": true
				}
			]

		_:
			return []

		_:
			return []
