class_name LandmarkCatalogueData
extends RefCounted

const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

## LandmarkCatalogueData: Authoritative historical, geographical, and cultural repository
## for all famous Indian attractions placed across the six state routes.
## Powers the dedicated bottom information card during active gameplay.

static func _infer_state_id(landmark_id: String, state_id: String, state_label: String) -> String:
	if state_id != "":
		return state_id
	if landmark_id.begins_with("LOC-TG-") or landmark_id.begins_with("tel_") or state_label.to_lower() == "telangana":
		return "telangana"
	if landmark_id.begins_with("LOC-TN-") or state_label.to_lower() == "tamil nadu":
		return "tamil_nadu"
	if landmark_id.begins_with("GOA-") or state_label.to_lower() == "goa":
		return "goa"
	if landmark_id.begins_with("LOC-KL-") or state_label.to_lower() == "kerala":
		return "kerala"
	if landmark_id.begins_with("LOC-RJ-") or state_label.to_lower() == "rajasthan":
		return "rajasthan"
	if landmark_id.begins_with("LOC-GJ-") or state_label.to_lower() == "gujarat":
		return "gujarat"
	return ""

static func get_landmark_info(landmark_id: String, state_id: String = "") -> Dictionary:
	var catalog := _get_master_catalog()
	if catalog.has(landmark_id):
		var info: Dictionary = catalog[landmark_id].duplicate()
		var resolved_sid := _infer_state_id(landmark_id, state_id if state_id != "" else str(info.get("state_id", "")), str(info.get("state", "")))
		if resolved_sid != "":
			info["state_id"] = resolved_sid
			var city_name := RouteRegistry.get_city_display_name(resolved_sid)
			if city_name != "":
				info["city_display_name"] = city_name
			info["discovery_region"] = RouteRegistry.get_discovery_region_display_name(resolved_sid, str(info.get("state", "")))
		return info

	# Fallback if unknown ID
	var fallback_sid := _infer_state_id(landmark_id, state_id, "")
	var fallback_state := RouteRegistry.get_state_display_name(fallback_sid) if fallback_sid != "" else state_id.capitalize().replace("_", " ")
	return {
		"id": landmark_id,
		"state_id": fallback_sid,
		"name": "Historical Landmark",
		"state": fallback_state,
		"city_display_name": RouteRegistry.get_city_display_name(fallback_sid),
		"discovery_region": RouteRegistry.get_discovery_region_display_name(fallback_sid, fallback_state),
		"location": "Indian Highway",
		"description": "An authentic regional heritage attraction and milestone along the scenic driving route.",
		"why_famous": "Represents the rich architectural and cultural tapestry of India.",
		"fact": "Preserved as part of the state's cultural heritage corridor."
	}

static func _get_master_catalog() -> Dictionary:
	return {
		# =========================================================================
		# 1. TAMIL NADU (13 LOCATIONS & AUTHENTIC LANDMARKS)
		# =========================================================================
		"tn_01_kanyakumari": {
			"id": "tn_01_kanyakumari",
			"name": "Kanyakumari Coast",
			"state": "Tamil Nadu",
			"location": "Cape Comorin Coast",
			"description": "Southernmost tip of India where three seas merge at Triveni Sangam.",
			"why_famous": "Home to the monumental Thiruvalluvar Statue and Vivekananda Memorial.",
			"fact": "Where the Arabian Sea, Indian Ocean, and Bay of Bengal meet."
		},
		"LOC-TN-01": {
			"id": "LOC-TN-01",
			"name": "Thiruvalluvar Statue",
			"state": "Tamil Nadu",
			"location": "Kanyakumari Offshore Rock",
			"description": "133-ft carved granite colossus honouring ancient philosopher Valluvar.",
			"why_famous": "Height corresponds to 133 chapters of the immortal Tirukkural.",
			"fact": "Carved by 500 artisans from over 7,000 tons of solid stone."
		},
		"LOC-TN-02": {
			"id": "LOC-TN-02",
			"name": "Vivekananda Rock Memorial",
			"state": "Tamil Nadu",
			"location": "Indian Ocean Island, Kanyakumari",
			"description": "Sacred granite sea memorial situated 500m offshore on rock islands.",
			"why_famous": "Meditation retreat where Swami Vivekananda attained enlightenment in 1892.",
			"fact": "Features the sacred Dhyana Mandapam meditation hall."
		},
		"tn_02_nagercoil": {
			"id": "tn_02_nagercoil",
			"name": "Nagercoil & Palace",
			"state": "Tamil Nadu",
			"location": "Nagercoil Foothills",
			"description": "Gateway nestled at Western Ghats foothills among lush coconut groves.",
			"why_famous": "Home to 16th-century wooden Padmanabhapuram Palace and waterfalls.",
			"fact": "Famed for traditional Travancore wooden architecture."
		},
		"LOC-TN-03": {
			"id": "LOC-TN-03",
			"name": "Padmanabhapuram Palace",
			"state": "Tamil Nadu",
			"location": "Nagercoil Foothills",
			"description": "Exquisite 16th-century royal wooden palace of the Venad kingdom.",
			"why_famous": "Masterpiece of gabled teakwood roofs and rosewood ceilings.",
			"fact": "Constructed without a single iron nail using antique joinery."
		},
		"LOC-TN-04": {
			"id": "LOC-TN-04",
			"name": "Thirparappu Waterfalls",
			"state": "Tamil Nadu",
			"location": "Kodayar River Basin",
			"description": "Scenic 50-ft cascading waterfall plunging over a natural rocky bed.",
			"why_famous": "Perennial forest waters flowing beside an ancient Shiva temple.",
			"fact": "Flows uninterrupted for seven months fed by monsoons."
		},
		"tn_03_tirunelveli": {
			"id": "tn_03_tirunelveli",
			"name": "Tirunelveli Checkpoint",
			"state": "Tamil Nadu",
			"location": "Thamirabarani Basin",
			"description": "Ancient city on the Thamirabarani River, famed for heritage and sweet halwa.",
			"why_famous": "Home of Nellaiappar Temple with its famous musical stone pillars.",
			"fact": "A major southern cultural and highway crossroads."
		},
		"LOC-TN-05": {
			"id": "LOC-TN-05",
			"name": "Nellaiappar Temple Gopuram",
			"state": "Tamil Nadu",
			"location": "Tirunelveli Town",
			"description": "Colossal 8th-century Dravidian temple sanctum with towering Rajagopurams.",
			"why_famous": "Mani Mandapam musical pillars produce musical swaras when tapped.",
			"fact": "Spans 14 acres built across centuries by Pandyan and Nayak kings."
		},
		"LOC-TN-06": {
			"id": "LOC-TN-06",
			"name": "Courtallam Waterfalls",
			"state": "Tamil Nadu",
			"location": "Western Ghats, Tenkasi",
			"description": "Celebrated 'Spa of South India' cascading over mineral-rich rocks.",
			"why_famous": "Forest waters pass through dense medicinal herbs with therapeutic qualities.",
			"fact": "Praised in ancient Sangam literature as Honey Falls."
		},
		"tn_04_kovilpatti": {
			"id": "tn_04_kovilpatti",
			"name": "Kovilpatti Junction",
			"state": "Tamil Nadu",
			"location": "Kovilpatti Palmyra Belt",
			"description": "Vibrant industrial and sweet-making hub along the southern highway.",
			"why_famous": "GI-tagged Kadalai Mittai groundnut candy and match industries.",
			"fact": "Made with organic jaggery and Thamirabarani river water."
		},
		"LOC-TN-07": {
			"id": "LOC-TN-07",
			"name": "Kovilpatti Sweet Corridor",
			"state": "Tamil Nadu",
			"location": "Kovilpatti Palmyra Belt",
			"description": "Famous roadside confectionery stalls and traditional workshops.",
			"why_famous": "Authentic handmade peanut brittle cooked in bell-metal cauldrons.",
			"fact": "Black cotton soil produces especially flavorful groundnuts."
		},
		"tn_05_virudhunagar": {
			"id": "tn_05_virudhunagar",
			"name": "Virudhunagar Gateway",
			"state": "Tamil Nadu",
			"location": "Virudhunagar District",
			"description": "Historic trade corridor and gateway to sacred Srivilliputhur.",
			"why_famous": "Birthplace of Andal and home to the official Tamil Nadu emblem temple.",
			"fact": "Key junction connecting Madurai with southern districts."
		},
		"LOC-TN-08": {
			"id": "LOC-TN-08",
			"name": "Srivilliputhur Andal Temple",
			"state": "Tamil Nadu",
			"location": "Srivilliputhur",
			"description": "Majestic 11-tiered Dravidian gopuram rising 59m into the skyline.",
			"why_famous": "The iconic temple tower depicted on the official Tamil Nadu emblem.",
			"fact": "One of the tallest gopurams in India, built in 1949 as state seal."
		},
		"tn_06_madurai": {
			"id": "tn_06_madurai",
			"name": "Madurai City Checkpoint",
			"state": "Tamil Nadu",
			"location": "Madurai, Vaigai River",
			"description": "Ancient 2,500-year-old Temple City on the fertile Vaigai River.",
			"why_famous": "Home to world-famous Meenakshi Amman Temple and royal palaces.",
			"fact": "One of the oldest continuously inhabited cities on Earth."
		},
		"LOC-TN-09": {
			"id": "LOC-TN-09",
			"name": "Meenakshi Amman Temple",
			"state": "Tamil Nadu",
			"location": "Madurai, Tamil Nadu",
			"description": "Historic Hindu temple located on the southern bank of the Vaigai River, Madurai, known for its towering, brightly sculpted gopurams.",
			"why_famous": "Ancient temple city centerpiece with 14 magnificent, brightly sculpted gopuram towers.",
			"fact": "Famous Hall of Thousand Pillars contains 985 carved stone pillars."
		},
		"LOC-TN-10": {
			"id": "LOC-TN-10",
			"name": "Thirumalai Nayakkar Mahal",
			"state": "Tamil Nadu",
			"location": "Madurai, Tamil Nadu",
			"description": "Grand 17th-century palace blending Dravidian and Italian Renaissance styles.",
			"why_famous": "Colossal 82-ft stucco pillars and majestic domed audience hall.",
			"fact": "Constructed in 1636 AD by King Thirumalai Nayak."
		},
		"tn_07_melur": {
			"id": "tn_07_melur",
			"name": "Melur Transition",
			"state": "Tamil Nadu",
			"location": "Melur Granite Belt",
			"description": "Scenic agricultural zone flanked by rugged granite outcroppings.",
			"why_famous": "Historic 2,000-year-old rock-cut Jain caves of Samanar Hills.",
			"fact": "Brahmi stone inscriptions detail ancient South Indian monastic history."
		},
		"LOC-TN-11": {
			"id": "LOC-TN-11",
			"name": "Samanar Hills",
			"state": "Tamil Nadu",
			"location": "Melur Granite Belt",
			"description": "Dramatic rocky hill outcrop honeycombed with natural meditation caves.",
			"why_famous": "Bas-relief carvings of Tirthankaras dating to 1st century BCE.",
			"fact": "Protected national archaeological monument of India."
		},
		"tn_08_tiruchirappalli": {
			"id": "tn_08_tiruchirappalli",
			"name": "Tiruchirappalli Checkpoint",
			"state": "Tamil Nadu",
			"location": "Cauvery River Basin",
			"description": "Historic fortress and island temple city on the sacred Cauvery River.",
			"why_famous": "Billion-year-old Rockfort fortress and Sri Ranganathaswamy sanctuary.",
			"fact": "Crucial central Tamil Nadu transport and heritage hub."
		},
		"LOC-TN-12": {
			"id": "LOC-TN-12",
			"name": "Tiruchirappalli Rockfort",
			"state": "Tamil Nadu",
			"location": "Rockfort Hill, Trichy",
			"description": "83-metre monolithic quartz rock fort crowned by Ucchi Pillayar Temple.",
			"why_famous": "3.8-billion-year-old natural fortress with 6th-century cave temples.",
			"fact": "437 steps carved directly into the rock lead to the summit."
		},
		"LOC-TN-13": {
			"id": "LOC-TN-13",
			"name": "Srirangam Ranganathaswamy Temple",
			"state": "Tamil Nadu",
			"location": "Srirangam Island, Trichy",
			"description": "Colossal 156-acre island temple complex enclosed by 21 Rajagopurams.",
			"why_famous": "Tallest temple tower in Asia (73m) and UNESCO Award of Merit winner.",
			"fact": "Largest functioning Hindu temple complex in the world."
		},
		"tn_09_perambalur": {
			"id": "tn_09_perambalur",
			"name": "Perambalur Highway",
			"state": "Tamil Nadu",
			"location": "Perambalur Basin",
			"description": "Fast expressway corridor through fertile agricultural maize plains.",
			"why_famous": "Gateway to Cretaceous ammonite fossil wood beds and highway temples.",
			"fact": "Fossil beds date back 120 million years to dinosaur-era sea."
		},
		"LOC-TN-14": {
			"id": "LOC-TN-14",
			"name": "Perambalur Temple Gopuram",
			"state": "Tamil Nadu",
			"location": "Perambalur Agricultural Corridor",
			"description": "Ornate roadside Dravidian gopuram presiding over the agricultural highway.",
			"why_famous": "Traditional sacred architectural gateway along the central highway.",
			"fact": "Marks the transition from Cauvery basin into northern Tamil Nadu."
		},
		"tn_10_villupuram": {
			"id": "tn_10_villupuram",
			"name": "Villupuram Checkpoint",
			"state": "Tamil Nadu",
			"location": "Grand Southern Trunk Road",
			"description": "Bustling transit crossroads connecting central and northern Tamil Nadu.",
			"why_famous": "Gateway to Gingee Fort and Grand Southern Trunk Road corridor.",
			"fact": "Major rail and road crossroads of northern Tamil Nadu."
		},
		"LOC-TN-15": {
			"id": "LOC-TN-15",
			"name": "Villupuram Whitewashed Gopuram",
			"state": "Tamil Nadu",
			"location": "Villupuram Highway Junction",
			"description": "Multi-tiered whitewashed Dravidian temple tower standing beside NH45.",
			"why_famous": "Traditional lime-coated gopuram landmark providing roadside beauty.",
			"fact": "Whitewashing with shell-lime protects stone mortar from monsoon heat."
		},
		"tn_11_tindivanam": {
			"id": "tn_11_tindivanam",
			"name": "Tindivanam Junction",
			"state": "Tamil Nadu",
			"location": "Tindivanam Highway Belt",
			"description": "Historic crossroads town historically named for its sacred tamarind groves.",
			"why_famous": "Key highway bifurcation point connecting Chennai with Puducherry.",
			"fact": "Popular highway refreshment corridor for long-distance drivers."
		},
		"LOC-TN-16": {
			"id": "LOC-TN-16",
			"name": "Tindivanam Highway Corridor",
			"state": "Tamil Nadu",
			"location": "Tindivanam Junction",
			"description": "Famous roadside stopover for fresh tender coconut and South Indian snacks.",
			"why_famous": "Vital midpoint halt for commuters along Grand Southern Trunk Road.",
			"fact": "Branches eastward towards the French coastal boulevards of Puducherry."
		},
		"tn_12_chengalpattu": {
			"id": "tn_12_chengalpattu",
			"name": "Chengalpattu Checkpoint",
			"state": "Tamil Nadu",
			"location": "Chengalpattu Gateway",
			"description": "Lakeside suburban toll gateway leading into Chennai metropolitan zone.",
			"why_famous": "Detour gateway to UNESCO World Heritage site Mahabalipuram.",
			"fact": "Ancient Pallava port gateway with 1,300-year-old rock temples."
		},
		"LOC-TN-17": {
			"id": "LOC-TN-17",
			"name": "Mahabalipuram Shore Temple",
			"state": "Tamil Nadu",
			"location": "Coromandel Coast, Chengalpattu",
			"description": "8th-century structural stone temple built by Pallava kings on the beach.",
			"why_famous": "UNESCO World Heritage Site with twin pyramidal spires facing the surf.",
			"fact": "Built of carved granite blocks that have withstood waves for 13 centuries."
		},
		"tn_13_chennai": {
			"id": "tn_13_chennai",
			"name": "Chennai Victory Finish",
			"state": "Tamil Nadu",
			"location": "Chennai, Bay of Bengal Coast",
			"description": "Vibrant capital of Tamil Nadu on Coromandel Coast and journey finale.",
			"why_famous": "Marina Beach, historic Fort St. George, and San Thome Basilica.",
			"fact": "Southern terminal of the complete 1,200m Tamil Nadu road journey."
		},
		"LOC-TN-18": {
			"id": "LOC-TN-18",
			"name": "San Thome Basilica",
			"state": "Tamil Nadu",
			"location": "Santhome, Chennai Coast",
			"description": "155-ft Neo-Gothic white spire basilica built over tomb of St. Thomas.",
			"why_famous": "One of only three churches in the world built over an apostle's tomb.",
			"fact": "Features stained-glass windows imported from Munich, Germany."
		},
		"LOC-TN-19": {
			"id": "LOC-TN-19",
			"name": "Fort St. George",
			"state": "Tamil Nadu",
			"location": "Coromandel Coast, Chennai",
			"description": "First English colonial citadel in India, founded in 1644 on the coast.",
			"why_famous": "Houses the Tamil Nadu Legislative Assembly and historic Fort Museum.",
			"fact": "Contains St. Mary's Church (1680), the oldest British building in Asia."
		},
		"LOC-TN-20": {
			"id": "LOC-TN-20",
			"name": "Marina Beach Lighthouse",
			"state": "Tamil Nadu",
			"location": "Marina Beach, Chennai",
			"description": "46-metre modern triangular lighthouse overlooking the golden sands.",
			"why_famous": "Grand finish landmark marking successful completion of Tamil Nadu journey.",
			"fact": "Marina Beach is the world's second-longest natural urban beach (13 km)."
		},
		"LOC-TN-21": {
			"id": "LOC-TN-21",
			"name": "Brihadeeswarar Temple",
			"state": "Tamil Nadu",
			"location": "Thanjavur, Tamil Nadu",
			"description": "Monumental 11th-century Chola Shiva temple built by Emperor Rajaraja Chola I in 1010 CE.",
			"why_famous": "UNESCO World Heritage Site famed for its 66-metre granite pyramidal vimana and colossal monolithic Nandi pavilion.",
			"fact": "Constructed entirely from carved interlocking granite blocks without mortar across the fertile Cauvery delta."
		},
		"LOC-TN-22": {
			"id": "LOC-TN-22",
			"name": "Kapaleeshwarar Temple",
			"state": "Tamil Nadu",
			"location": "Mylapore, Chennai, Tamil Nadu",
			"description": "Historic Dravidian temple dedicated to Lord Shiva in the vibrant heritage quarter of Mylapore, Chennai.",
			"why_famous": "Celebrated for its soaring polychrome gopuram, sacred temple tank, and classical Tamil cultural traditions.",
			"fact": "Rebuilt in classic Vijayanagara-Dravidian architectural style around its picturesque stepped Pushkarini tank."
		},

		# 2. GOA (11 LANDMARKS - GOA-01..GOA-11)
		# =========================================================================
		"GOA-01": {
			"id": "GOA-01",
			"name": "Basilica of Bom Jesus",
			"state": "Goa",
			"location": "Old Goa UNESCO Heritage Site",
			"description": "A world-renowned UNESCO World Heritage basilica and one of India's finest examples of Baroque architecture, with its unplastered laterite facade standing proudly in Old Goa.",
			"why_famous": "Preserves the sacred mortal relics of St. Francis Xavier and draws pilgrims from around the world.",
			"fact": "Every ten years, the relics are exposed for public veneration during a major exposition in Old Goa."
		},
		"GOA-02": {
			"id": "GOA-02",
			"name": "Se Cathedral",
			"state": "Goa",
			"location": "Old Goa UNESCO Heritage Site",
			"description": "One of the largest churches in Asia, built in Portuguese-Manueline style with a majestic white facade and towering presence.",
			"why_famous": "Dedicated to St. Catherine of Alexandria and celebrated for its grand scale and historic Golden Bell.",
			"fact": "The cathedral's Golden Bell was famed for its rich tone that carried across the surrounding countryside."
		},
		"GOA-03": {
			"id": "GOA-03",
			"name": "St. Anthony Church",
			"state": "Goa",
			"location": "Cabo de Rama, South Goa",
			"description": "A serene coastal church near the Cabo de Rama region, reflecting Goa's Portuguese-era spiritual heritage against a tropical seaside backdrop.",
			"why_famous": "Known for its peaceful setting and connection to the historic Cabo de Rama coastal landscape.",
			"fact": "Cabo de Rama is named in local legend after Lord Rama, and the area blends natural coastal beauty with centuries of Goan history."
		},
		"GOA-04": {
			"id": "GOA-04",
			"name": "Shri Mangueshi Temple",
			"state": "Goa",
			"location": "Priol, Ponda, Goa",
			"description": "One of Goa's most prominent Hindu temples, dedicated to Lord Manguesh, with an elegant white tower, domes, and a tranquil temple tank setting.",
			"why_famous": "A major spiritual landmark of Goa, known for its distinctive Goan temple architecture and deep cultural significance.",
			"fact": "The temple's seven-storey deepstambha (lamp tower) is a striking feature of traditional Goan temple design."
		},
		"GOA-05": {
			"id": "GOA-05",
			"name": "Chapora Fort",
			"state": "Goa",
			"location": "Vagator, North Goa",
			"description": "A rugged laterite fort perched above the Chapora River and Vagator coastline, offering dramatic views over the Arabian Sea.",
			"why_famous": "Famous for its sweeping coastal vistas, red laterite ramparts, and iconic sunset viewpoint.",
			"fact": "The fort was rebuilt by the Portuguese in 1717 and features steep slopes that once formed a natural defence."
		},
		"GOA-06": {
			"id": "GOA-06",
			"name": "Fort Aguada Lighthouse",
			"state": "Goa",
			"location": "Sinquerim, North Goa",
			"description": "A historic Portuguese fort and lighthouse complex overlooking the mouth of the Mandovi River and the Arabian Sea.",
			"why_famous": "One of Goa's best-preserved coastal forts, known for its lighthouse, bastions, and strategic maritime history.",
			"fact": "The Aguada lighthouse, built in 1864, is among the oldest lighthouses of its kind in Asia."
		},
		"GOA-07": {
			"id": "GOA-07",
			"name": "Reis Magos Fort",
			"state": "Goa",
			"location": "Reis Magos, Bardez, Goa",
			"description": "A beautifully restored laterite fort on the northern bank of the Mandovi River, offering panoramic views across the water toward Panaji.",
			"why_famous": "One of Goa's oldest forts, admired for its restoration, coastal setting, and historical role in defending the Mandovi estuary.",
			"fact": "The fort was originally constructed in 1551 and later served as a prison before being carefully restored."
		},
		"GOA-08": {
			"id": "GOA-08",
			"name": "St. Augustine Tower",
			"state": "Goa",
			"location": "Old Goa UNESCO Heritage Site",
			"description": "The towering laterite ruin of the Church of St. Augustine, a hauntingly beautiful remnant of one of Old Goa's grandest 17th-century complexes.",
			"why_famous": "The lone 46-metre tower is an iconic Old Goa landmark and a powerful symbol of the city's layered history.",
			"fact": "The tower was once part of a massive Augustinian church complex that collapsed over centuries after abandonment."
		},
		"GOA-09": {
			"id": "GOA-09",
			"name": "Fontainhas",
			"state": "Goa",
			"location": "Panjim Latin Quarter, Goa",
			"description": "Asia's oldest Latin quarter, known for narrow streets, colourful Portuguese-style houses, tiled roofs, and old-world Goan charm.",
			"why_famous": "A living heritage neighbourhood celebrated for its vibrant facades, art galleries, bakeries, and Indo-Portuguese culture.",
			"fact": "Fontainhas is named after the 'little fountain' at the foot of the Altinho hill in Panaji."
		},
		"GOA-10": {
			"id": "GOA-10",
			"name": "Dudhsagar Falls",
			"state": "Goa",
			"location": "Mollem, Western Ghats, Goa",
			"description": "A spectacular four-tiered waterfall cascading through lush Western Ghats forest, one of India's tallest and most dramatic natural attractions.",
			"why_famous": "Its milky-white cascade, forest setting, and railway bridge backdrop make it one of Goa's most iconic scenic destinations.",
			"fact": "The name 'Dudhsagar' means 'Sea of Milk', inspired by the waterfall's powerful white torrents."
		},
		"GOA-11": {
			"id": "GOA-11",
			"name": "Palolem Beach",
			"state": "Goa",
			"location": "Canacona, South Goa",
			"description": "A picturesque crescent-shaped beach in South Goa, lined with palm trees, calm waters, and colourful beach huts.",
			"why_famous": "Renowned for its scenic natural bay, relaxed tropical atmosphere, and postcard-perfect shoreline.",
			"fact": "Palolem's curved bay and gentle waters make it one of the most photographed beaches in South Goa."
		},
		"GOA-12": {
			"id": "GOA-12",
			"name": "Cabo de Rama Fort",
			"state": "Goa",
			"location": "Canacona Cliffs, South Goa",
			"description": "An ancient red-laterite cliffside fortress overlooking the Arabian Sea, blending Hindu and Portuguese coastal history.",
			"why_famous": "Celebrated for dramatic cliff drops, palm-lined ramparts, and panoramic views of South Goa's crescent bays.",
			"fact": "Named after Lord Rama, the fort predates Portuguese arrival and offers sweeping ocean vistas."
		},
		"GOA-13": {
			"id": "GOA-13",
			"name": "Panaji Immaculate Church",
			"state": "Goa",
			"location": "Panaji Square, Central Goa",
			"description": "The iconic gleaming white Portuguese Baroque church of Our Lady of the Immaculate Conception rising above symmetrical zigzag staircases.",
			"why_famous": "Panaji's beloved architectural centerpiece since 1619, welcoming travelers into Central Goa.",
			"fact": "Its massive church bell was salvaged from the ruined St. Augustine complex in Old Goa."
		},
		"goa_mandovi_cp": {
			"id": "goa_mandovi_cp",
			"name": "Central Goa: Panaji",
			"state": "Goa",
			"location": "Mandovi River Crossing, Central Goa",
			"description": "Crossing into Panaji and Old Goa — the historic Indo-Portuguese capital along the Mandovi River.",
			"why_famous": "Connects North Goa's beaches with Fontainhas Latin Quarter and Old Goa's UNESCO cathedrals.",
			"fact": "Panaji's riverside promenade is lined with colonial mansions and swaying palms."
		},
		"goa_east_cp": {
			"id": "goa_east_cp",
			"name": "East Goa: Western Ghats",
			"state": "Goa",
			"location": "Ponda & Mollem Forest Corridor",
			"description": "Entering Goa's lush green interior foothills, ancient temples, forest bridges, and Western Ghats cascades.",
			"why_famous": "Home to Shri Mangueshi Temple, Mollem forests, and the roaring Dudhsagar Falls.",
			"fact": "East Goa's biodiversity belongs to the UNESCO-recognized Western Ghats mountain range."
		},
		"goa_south_cp": {
			"id": "goa_south_cp",
			"name": "South Goa Coast",
			"state": "Goa",
			"location": "Cabo de Rama & Canacona, South Goa",
			"description": "Arriving at South Goa's serene coconut plantations, coastal cliffs, and untouched crescent bays.",
			"why_famous": "Famed for Cabo de Rama Fort, St. Anthony Church, and idyllic Palolem Beach.",
			"fact": "South Goa's coastline preserves quiet fishing villages and expansive palm groves."
		},
		"goa_destination": {
			"id": "goa_destination",
			"name": "South Goa Victory Arch",
			"state": "Goa",
			"location": "Palolem & Margao, South Goa",
			"description": "Grand coastal finish arch celebrating your journey across North, Central, East, and South Goa!",
			"why_famous": "Marks complete exploration of Goa's forts, heritage churches, waterfalls, and beaches.",
			"fact": "Goa spans 105 km of Arabian Sea coastline backed by the emerald Western Ghats."
		},
		# Backward-compatible aliases for legacy Goa IDs
		"LOC-GA-01": {"id": "GOA-06", "name": "Fort Aguada Lighthouse", "state": "Goa", "location": "Sinquerim, North Goa", "description": "A historic Portuguese fort and lighthouse complex overlooking the mouth of the Mandovi River and the Arabian Sea.", "why_famous": "One of Goa's best-preserved coastal forts, known for its lighthouse and maritime history.", "fact": "The Aguada lighthouse, built in 1864, is among the oldest lighthouses of its kind in Asia."},
		"LOC-GA-02": {"id": "GOA-09", "name": "Fontainhas", "state": "Goa", "location": "Panjim Latin Quarter, Goa", "description": "Asia's oldest Latin quarter, known for narrow streets, colourful Portuguese-style houses, and old-world Goan charm.", "why_famous": "A living heritage neighbourhood celebrated for vibrant facades and Indo-Portuguese culture.", "fact": "Fontainhas is named after the 'little fountain' at the foot of the Altinho hill in Panaji."},
		"LOC-GA-09": {"id": "GOA-06", "name": "Fort Aguada Lighthouse", "state": "Goa", "location": "Sinquerim, North Goa", "description": "A historic Portuguese fort and lighthouse complex overlooking the mouth of the Mandovi River and the Arabian Sea.", "why_famous": "One of Goa's best-preserved coastal forts, known for its lighthouse and maritime history.", "fact": "The Aguada lighthouse, built in 1864, is among the oldest lighthouses of its kind in Asia."},
		"LOC-GA-11": {"id": "GOA-11", "name": "Palolem Beach", "state": "Goa", "location": "Canacona, South Goa", "description": "A picturesque crescent-shaped beach in South Goa, lined with palm trees, calm waters, and colourful beach huts.", "why_famous": "Renowned for its scenic natural bay and relaxed tropical atmosphere.", "fact": "Palolem's curved bay and gentle waters make it one of the most photographed beaches in South Goa."},
		"LOC-GA-14": {"id": "GOA-05", "name": "Chapora Fort", "state": "Goa", "location": "Vagator, North Goa", "description": "A rugged laterite fort perched above the Chapora River and Vagator coastline.", "why_famous": "Famous for sweeping coastal vistas and red laterite ramparts.", "fact": "The fort was rebuilt by the Portuguese in 1717."},
		"LOC-GA-15": {"id": "GOA-01", "name": "Basilica of Bom Jesus", "state": "Goa", "location": "Old Goa UNESCO Heritage Site", "description": "A world-renowned UNESCO World Heritage basilica and one of India's finest examples of Baroque architecture.", "why_famous": "Preserves the sacred mortal relics of St. Francis Xavier.", "fact": "Every ten years, the relics are exposed for public veneration during a major exposition."},
		"LOC-GA-16": {"id": "GOA-02", "name": "Se Cathedral", "state": "Goa", "location": "Old Goa UNESCO Heritage Site", "description": "One of the largest churches in Asia, built in Portuguese-Manueline style.", "why_famous": "Dedicated to St. Catherine of Alexandria and celebrated for its grand scale.", "fact": "The cathedral's Golden Bell was famed for its rich tone."},
		"LOC-GA-17": {"id": "GOA-08", "name": "St. Augustine Tower", "state": "Goa", "location": "Old Goa UNESCO Heritage Site", "description": "The towering laterite ruin of the Church of St. Augustine, an iconic remnant of Old Goa.", "why_famous": "The lone 46-metre tower is a powerful symbol of Old Goa's layered history.", "fact": "The tower was once part of a massive Augustinian church complex."},
		"LOC-GA-22": {"id": "GOA-03", "name": "St. Anthony Church", "state": "Goa", "location": "Cabo de Rama, South Goa", "description": "A serene coastal church near the Cabo de Rama region, reflecting Goa's Portuguese-era spiritual heritage.", "why_famous": "Known for its peaceful setting and connection to the Cabo de Rama coastal landscape.", "fact": "Cabo de Rama blends natural coastal beauty with centuries of Goan history."},

		# =========================================================================
		# 3. KERALA (KOCHI TO MUNNAR — 11 LANDMARKS + WAYPOINT ENTRIES)
		# =========================================================================
		"LOC-KL-01": {
			"id": "LOC-KL-01",
			"name": "Fort Kochi Chinese Fishing Nets",
			"state": "Kerala",
			"location": "Fort Kochi Harbor Waterfront, Kerala",
			"description": "Iconic cantilevered shore-operated fishing nets (Cheena Vala) overlooking the Arabian Sea entrance to Kochi Harbour.",
			"why_famous": "Traditional 14th-century wooden balanced nets operating against shimmering coastal tides and fishing boats.",
			"fact": "Each 20-metre teak-and-bamboo cantilever is counterweighted by suspended stones and hauled by teams of six fishermen."
		},
		"LOC-KL-02": {
			"id": "LOC-KL-02",
			"name": "Mattancherry Dutch Palace",
			"state": "Kerala",
			"location": "Mattancherry, Kochi, Kerala",
			"description": "Historic two-storey quadrangular palace blending indigenous Kerala sloped-roof timber architecture with European colonial courtyard stonework.",
			"why_famous": "Built by the Portuguese in 1555 for the Raja of Kochi and celebrated for its ornate wooden ceilings and royal murals.",
			"fact": "Its walls preserve vivid 17th-century natural pigment murals depicting the Ramayana and royal Kochi court heritage."
		},
		"LOC-KL-03": {
			"id": "LOC-KL-03",
			"name": "Santa Cruz Basilica & St. Francis Church",
			"state": "Kerala",
			"location": "Fort Kochi Heritage Zone, Kerala",
			"description": "Historic Indo-European heritage basilica with twin whitewashed spires, Gothic arches, and red-tiled colonnades framed by tropical palms.",
			"why_famous": "Represents centuries of Fort Kochi architectural heritage alongside St. Francis Church, the oldest European church in India (1503).",
			"fact": "Vasco da Gama was originally interred at St. Francis Church in 1524 before his remains were carried back to Lisbon."
		},
		"LOC-KL-04": {
			"id": "LOC-KL-04",
			"name": "Chottanikkara Bhagavathy Temple",
			"state": "Kerala",
			"location": "Chottanikkara, Ernakulam, Kerala",
			"description": "Sacred Kerala sanctuary renowned for its tiered copper-plated gabled roof, traditional deepastambham lamp tower, and serene compound.",
			"why_famous": "One of Kerala's most revered Mother Goddess shrines where devotees gather beneath towering oil lamps and traditional gopurams.",
			"fact": "Daily rituals worship the deity in three distinct forms: Saraswati at dawn, Lakshmi at noon, and Durga by evening."
		},
		"LOC-KL-05": {
			"id": "LOC-KL-05",
			"name": "Sree Poornathrayeesa Temple",
			"state": "Kerala",
			"location": "Tripunithura — Muvattupuzha Road, Kerala",
			"description": "Grand royal temple featuring gleaming golden ceremonial flagstaff, sculpted stone courtyard pillars, and Kerala sloped-tile sanctum roofs.",
			"why_famous": "Historically the patron temple of the Kochi royal family, famed for festive Vrischikotsavam caparisoned elephant processions.",
			"fact": "Its classic Chera-style brass roofed sreekovil and mandapam reflect timeless Kerala temple craftsmanship."
		},
		"LOC-KL-06": {
			"id": "LOC-KL-06",
			"name": "Aluva Mahadeva River Temple",
			"state": "Kerala",
			"location": "Periyar Riverbanks, Kerala",
			"description": "Revered riverside Shiva shrine set along broad sandy banks of the Periyar River at the foothills rising toward Kothamangalam.",
			"why_famous": "Iconic spiritual landmark where massive Aluva Shivaratri riverfront gatherings illuminate the Periyar valley.",
			"fact": "Unlike walled temples, the sacred Manappuram shrine rises gracefully from the open Periyar river sandbank."
		},
		"LOC-KL-07": {
			"id": "LOC-KL-07",
			"name": "St. George Forane Church",
			"state": "Kerala",
			"location": "Kothamangalam Heritage Highway, Kerala",
			"description": "Imposing whitewashed Kerala church with arched belfry, cross-topped dome, and pillared portico standing before lush bamboo and foothill forest.",
			"why_famous": "A celebrated landmark along the eastern gateway toward the Western Ghats and High Range.",
			"fact": "Stands near the historic route connecting Kochi's plains to the Munnar spice and tea highlands."
		},
		"LOC-KL-08": {
			"id": "LOC-KL-08",
			"name": "Valara Waterfalls",
			"state": "Kerala",
			"location": "Neriamangalam — Adimali Forest, NH-85",
			"description": "Roaring multi-tiered cascade plunging through dense evergreen shola forests along the Kochi–Munnar hill highway.",
			"why_famous": "Fed by the Deviyar River between Neriamangalam and Adimali, famed for misty canyon spray and emerald cliffside foliage.",
			"fact": "Valara tumbles down more than 1,000 feet through steep wooded rocky ledges bordering lush rainforest."
		},
		"LOC-KL-09": {
			"id": "LOC-KL-09",
			"name": "Cheeyappara Stepped Waterfalls",
			"state": "Kerala",
			"location": "Between Neriamangalam & Adimali, Idukki",
			"description": "Spectacular seven-step cascading waterfall tumbling cleanly across wide stepped dark granite shelves surrounded by Western Ghats forest.",
			"why_famous": "One of Kerala's finest roadside natural wonders on the climb from Neriamangalam Bridge up toward Adimali and Munnar.",
			"fact": "Its distinctive terraced basalt rock steps slow the roaring white water into seven shimmering veil tiers."
		},
		"LOC-KL-10": {
			"id": "LOC-KL-10",
			"name": "Adimali Cardamom & Spice Gardens",
			"state": "Kerala",
			"location": "Adimali, Idukki District, Kerala",
			"description": "Fragrant hillside spice estate terraced with green cardamom clumps, black pepper vines climbing shade trees, and timber plantation quarters.",
			"why_famous": "Adimali is Kerala's celebrated Spice Capital Gateway welcoming high-range travellers en route to Pallivasal and Munnar.",
			"fact": "Idukki's cool misty slopes around Adimali produce world-prized green cardamom known as the Queen of Spices."
		},
		"LOC-KL-11": {
			"id": "LOC-KL-11",
			"name": "Munnar Colonial Tea Factory & Estate",
			"state": "Kerala",
			"location": "Kannan Devan Hills, Munnar, Kerala",
			"description": "Heritage red-roofed high-range tea factory perched amidst sculptural emerald tea bush terraces, silver-bark eucalyptus trees, and drifting valley mist.",
			"why_famous": "Iconic symbol of Munnar's 19th-century high-altitude tea heritage nestled beneath the cloud-kissed Western Ghats peaks.",
			"fact": "Munnar means 'Three Rivers' (Mudrapuzha, Nallathanni, and Kundala) meeting at 1,600 metres in the Kannan Devan Hills."
		},
		"ker_muvattupuzha_cp": {
			"id": "ker_muvattupuzha_cp",
			"name": "Muvattupuzha Midland Checkpost",
			"state": "Kerala",
			"location": "Muvattupuzha Three-River Valley",
			"description": "Crossing from coastal Kochi into Muvattupuzha's lush green rubber estates, banana groves, paddy fields, and traditional Tharavadu villages.",
			"why_famous": "Named after the confluence of Kothayar, Kaliyar, and Thodupuzha rivers feeding central Kerala's fertile midlands.",
			"fact": "Gateway town linking Ernakulam's harbour plains with the misty foothills of Kothamangalam and Idukki."
		},
		"ker_neriamangalam_cp": {
			"id": "ker_neriamangalam_cp",
			"name": "Neriamangalam — Periyar Arch Bridge",
			"state": "Kerala",
			"location": "Periyar River Gorge, NH-85",
			"description": "Entering Neriamangalam's emerald rainforest corridor ahead of the historic arched stone-and-concrete bridge spanning the roaring Periyar River.",
			"why_famous": "Celebrated as the Gateway to Idukki High Ranges and known for rich monsoon biodiversity and misty river cliffs.",
			"fact": "Opened in 1935, Neriamangalam Bridge connected Kochi's low country directly to the High Range hills of Munnar."
		},
		"ker_adimali_cp": {
			"id": "ker_adimali_cp",
			"name": "Adimali High Range Gate",
			"state": "Kerala",
			"location": "Adimali Spice Highlands, Idukki",
			"description": "Emerging above Valara and Cheeyappara Waterfalls into Adimali's cool cardamom hills before Pallivasal's curved tea slopes.",
			"why_famous": "Major hill-station hub of Idukki famous for organic black pepper, cinnamon, nutmeg, and cardamom estates.",
			"fact": "Beyond Adimali, air turns noticeably cooler as the winding road climbs toward Pallivasal and Munnar."
		},
		"ker_destination": {
			"id": "ker_destination",
			"name": "Munnar Anamudi Valley Finish Arch",
			"state": "Kerala",
			"location": "Munnar Hill Station, Western Ghats",
			"description": "Grand Munnar finish arch framed by rolling green tea terraces, drifting mountain clouds, and eucalyptus groves.",
			"why_famous": "Completes the complete 1,800m Kochi-to-Munnar expedition from Arabian Sea harbour to South India's misty tea capital.",
			"fact": "Near Munnar stands Anamudi Peak (2,695 m), the highest mountain peak in the Western Ghats and South India."
		},
		"LOC-KL-12": {
			"id": "LOC-KL-12",
			"name": "Paradesi Synagogue & Clock Tower",
			"state": "Kerala",
			"location": "Jew Town, Mattancherry, Kochi",
			"description": "The oldest active synagogue in the Commonwealth (1568), crowned by a whitewashed four-faced clock tower with red terracotta roof tiles.",
			"why_famous": "Celebrated for hand-painted 18th-century Cantonese porcelain floor tiles, Belgian chandeliers, and historic Spice Coast Jewish heritage.",
			"fact": "The clock tower displays dials in Hebrew, Malayalam, Roman, and Arabic numerals overlooking Jew Town's spice lanes."
		},
		"LOC-KL-13": {
			"id": "LOC-KL-13",
			"name": "St. Francis CSI Church",
			"state": "Kerala",
			"location": "Fort Kochi Heritage Square, Kerala",
			"description": "Originally built in 1503, India's oldest European church featuring a classic stepped whitewashed facade and pitched red tiled roof.",
			"why_famous": "Witnessed Portuguese, Dutch, and British eras along the Malabar Coast and housed the original burial tomb of Vasco da Gama.",
			"fact": "High inside the sanctuary nave hang traditional hand-pulled punkah ceiling fans operated for centuries by ropes from outside."
		},
		"LOC-KL-15": {
			"id": "LOC-KL-15",
			"name": "Hill Palace Museum",
			"state": "Kerala",
			"location": "Tripunithura — Muvattupuzha Corridor",
			"description": "Grand neo-classical colonnaded white-and-ochre royal estate set atop green hillocks as the 19th-century administrative palace of the Cochin Maharajas.",
			"why_famous": "Kerala's largest archaeological museum complex sprawling across 54 terraced acres with heritage pavilions and royal galleries.",
			"fact": "Built in 1865 with 49 buildings combining traditional Kerala courtyard timber work with airy arched colonial verandahs."
		},
		"LOC-KL-16": {
			"id": "LOC-KL-16",
			"name": "Kerala Temple Padippura Gateway",
			"state": "Kerala",
			"location": "Muvattupuzha — Kothamangalam Highway",
			"description": "Traditional two-tiered Kerala red-tiled temple gateway arched above carved timber columns and festive ceremonial murals.",
			"why_famous": "Architectural threshold welcoming travellers into ancient midland and foothill temple precincts along the route to Kothamangalam.",
			"fact": "Sloped double-eave terracotta roofs shield carved teak doors and oil lamps from heavy Western Ghats monsoon rains."
		},
		"LOC-KL-17": {
			"id": "LOC-KL-17",
			"name": "Mar Thoma Syrian Heritage Church",
			"state": "Kerala",
			"location": "Kothamangalam — Muvattupuzha Valley",
			"description": "Iconic whitewashed Syrian Christian heritage church featuring a curved Baroque gable facade, crimson tiled transepts, and an ancient granite churchyard cross.",
			"why_famous": "Preserves the deep roots of Kerala's St. Thomas Christian traditions and Kothamangalam's centuries-old cathedral craftsmanship.",
			"fact": "Tall monolithic stone crosses standing before historic Kerala churches symbolize unbroken faith across twenty centuries."
		},
		"LOC-KL-14": {
			"id": "LOC-KL-11",
			"name": "Munnar Colonial Tea Factory & Estate",
			"state": "Kerala",
			"location": "Kannan Devan Hills, Munnar, Kerala",
			"description": "Heritage red-roofed high-range tea factory perched amidst sculptural emerald tea terraces and drifting valley mist.",
			"why_famous": "Iconic symbol of Munnar's high-altitude tea heritage nestled in the Western Ghats.",
			"fact": "Munnar sits at 1,600 metres elevation where three mountain streams meet."
		},

		# =========================================================================
		# 4. RAJASTHAN (6 LANDMARKS)
		# =========================================================================
		"LOC-RJ-01": {
			"id": "LOC-RJ-01",
			"name": "Hawa Mahal (Palace of Winds)",
			"state": "Rajasthan",
			"location": "Badi Choupad, Jaipur, Rajasthan",
			"description": "A five-storey pink-and-red sandstone palace shaped like the crown of Lord Krishna, built in 1799 by Maharaja Sawai Pratap Singh.",
			"why_famous": "Features an exquisite honeycomb facade adorned with 953 miniature carved jharokha stone casements.",
			"fact": "Engineered with the Venturi effect: cool breezes flow continuously through the latticework, air-conditioning the chambers during desert summers."
		},
		"LOC-RJ-02": {
			"id": "LOC-RJ-02",
			"name": "Jal Mahal Water Palace",
			"state": "Rajasthan",
			"location": "Man Sagar Lake, Jaipur, Rajasthan",
			"description": "A romantic Rajput-Mughal pleasure palace appearing to float serenely on the surface of Man Sagar Lake.",
			"why_famous": "A structural triumph built in pink sandstone, framed by the rugged purple ridgelines of the Aravalli Hills.",
			"fact": "Though only a single pavilion storey appears above the lake surface, the palace actually has four underwater storeys submerged beneath the water."
		},
		"LOC-RJ-03": {
			"id": "LOC-RJ-03",
			"name": "Amber Fort Ramparts & Gateway",
			"state": "Rajasthan",
			"location": "Amer Valley Citadel, Jaipur",
			"description": "An immense hilltop citadel constructed in 1592 by Raja Man Singh I from yellow and pink sandstone.",
			"why_famous": "Renowned for the opulent Sheesh Mahal (Mirror Palace), where a single candle flame illuminates the entire hall across thousands of convex mirrors.",
			"fact": "Connected by subterranean security tunnels to Jaigarh Fort high above, designed as an impenetrable retreat during foreign sieges."
		},
		"LOC-RJ-08": {
			"id": "LOC-RJ-08",
			"name": "Jaswant Thada Marble Cenotaph",
			"state": "Rajasthan",
			"location": "Jodhpur Royal Grounds, Rajasthan",
			"description": "An exquisite 19th-century royal cenotaph constructed from pure, intricately carved white Makrana marble.",
			"why_famous": "Known as the 'Taj Mahal of Marwar', serving as the official memorial shrine for the Rathore rulers of Jodhpur.",
			"fact": "The marble sheets are carved so finely (under 1.5 cm thick) that they become translucent, glowing with a soft golden hue under the morning desert sun."
		},
		"LOC-RJ-11": {
			"id": "LOC-RJ-11",
			"name": "Mehrangarh Fort Cliff Bastion",
			"state": "Rajasthan",
			"location": "Jodhpur Ridge, Rajasthan",
			"description": "One of India's most formidable forts, perched atop a sheer 410-foot perpendicular volcanic rocky cliff.",
			"why_famous": "Dominates the skyline above Jodhpur's iconic blue-painted houses with towering walls up to 36 metres high and 21 metres thick.",
			"fact": "English author Rudyard Kipling famously marveled at Mehrangarh, writing that it appeared to be 'the work of giants and spirits rather than men'."
		},
		"LOC-RJ-15": {
			"id": "LOC-RJ-15",
			"name": "Patwon Ki Haveli Jharokhas",
			"state": "Rajasthan",
			"location": "Jaisalmer Golden City, Rajasthan",
			"description": "A magnificent cluster of five connected five-storey merchant mansions carved from golden-yellow sandstone.",
			"why_famous": "The largest haveli cluster in Jaisalmer, celebrated for delicate carved sandstone jharokha balconies and desert architectural artistry.",
			"fact": "Constructed in the early 19th century by wealthy merchant Guman Chand Patwa and his five sons."
		},
		"LOC-RJ-04": {
			"id": "LOC-RJ-04",
			"name": "Jantar Mantar Observatory",
			"state": "Rajasthan",
			"location": "Tripolia Bazar, Jaipur, Rajasthan",
			"description": "An extraordinary 18th-century open-air astronomical observatory built by Maharaja Sawai Jai Singh II featuring towering masonry sundials.",
			"why_famous": "UNESCO World Heritage Site housing the Samrat Yantra, the world's largest stone sundial, measuring solar time to within two seconds.",
			"fact": "Completed in 1734 with nineteen architectural instruments sculpted from local sandstone and marble."
		},
		"LOC-RJ-05": {
			"id": "LOC-RJ-05",
			"name": "Pushkar Sacred Lake & Ghats",
			"state": "Rajasthan",
			"location": "Pushkar Valley, Aravalli Hills (Cultural Highlight)",
			"description": "Tranquil oval desert lake nestled amid rocky Aravalli hills and encircled by 52 whitewashed stone bathing ghats and arched pavilions.",
			"why_famous": "One of India's oldest sacred pilgrimage lakes, famed for serene sunrise reflections and the annual Pushkar Camel Fair.",
			"fact": "Hindu scripture reveres Pushkar as one of the five sacred Tirtha pilgrimage waters of India."
		},
		"LOC-RJ-06": {
			"id": "LOC-RJ-06",
			"name": "Brahma Temple, Pushkar",
			"state": "Rajasthan",
			"location": "Pushkar, Rajasthan (Cultural Highlight)",
			"description": "Distinguished 14th-century marble-and-stone shrine featuring a bright crimson shikhara spire and carved goose-crest pillared hall.",
			"why_famous": "One of the very few surviving ancient temples in the world dedicated primarily to Lord Brahma, creator deity in Hindu tradition.",
			"fact": "Silver coins embedded by devotees line the white marble steps leading into the inner sanctum."
		},
		"LOC-RJ-07": {
			"id": "LOC-RJ-07",
			"name": "Taragarh Aravalli Ridge Fort",
			"state": "Rajasthan",
			"location": "Ajmer — Aravalli Mountain Pass (Regional Highlight)",
			"description": "Terraced Aravalli hillside fortress built from sandstone boulders overlooking dry valleys linking Jaipur toward Western Rajasthan.",
			"why_famous": "Commanding medieval hill citadel constructed in the 12th century across steep defensive stone escarpments.",
			"fact": "Massive rainwater reservoirs carved straight into solid hill bedrock sustained garrisons through long desert droughts."
		},
		"LOC-RJ-09": {
			"id": "LOC-RJ-09",
			"name": "Junagarh Fort Heritage Showcase",
			"state": "Rajasthan",
			"location": "Bikaner Regional Heritage Display (Rajasthan Plains)",
			"description": "Ornate red-and-golden sandstone plains fortress featuring grand courtyards, scalloped balconies, and tranquil reflecting gardens.",
			"why_famous": "Unlike hilltop citadels of Rajasthan, Junagarh was constructed on open desert plains (1589–1594) and was never conquered in battle.",
			"fact": "Showcased along our Thar Desert route as a tribute to northern Rajasthan's architectural heritage."
		},
		"LOC-RJ-10": {
			"id": "LOC-RJ-10",
			"name": "Osian Temples (Sachiya Mata)",
			"state": "Rajasthan",
			"location": "Osian Thar Oasis, North of Jodhpur",
			"description": "Clusters of richly sculpted 8th-to-12th-century sandstone Shikhara shrines rising beside golden Thar desert sand dunes.",
			"why_famous": "Celebrated oasis town nicknamed the 'Khajuraho of Rajasthan' for exquisite medieval Pratihara stone pillars and toranas.",
			"fact": "Sachiya Mata Temple atop a desert sand hill remains an active pilgrimage sanctuary overlooking Osian oasis."
		},
		"LOC-RJ-12": {
			"id": "LOC-RJ-12",
			"name": "Umaid Bhawan Palace",
			"state": "Rajasthan",
			"location": "Chittar Hill, Jodhpur, Rajasthan",
			"description": "Monumental golden-yellow Chittar sandstone palace crowned by a 105-foot Indo-Saracenic central dome set above Jodhpur.",
			"why_famous": "Built between 1929 and 1943 with 347 rooms, making it one of the largest private royal residences in the world.",
			"fact": "Commissioned by Maharaja Umaid Singh as a famine-relief project providing livelihoods across Marwar for fourteen years."
		},
		"LOC-RJ-13": {
			"id": "LOC-RJ-13",
			"name": "Gadisar Lake Chhatris",
					"state": "Rajasthan",
			"location": "Southern Jaisalmer, Rajasthan",
			"description": "Historic rainwater conservation reservoir fringed by carved golden sandstone chhatri pavilions and domed lake shrines.",
			"why_famous": "Excavated originally in the 12th century and enlarged by Maharawal Gadsi Singh in 1367 as Jaisalmer's vital desert water supply.",
			"fact": "Carved sandstone arches frame sunrise vistas beside migrating winter birds resting in the Thar."
		},
		"LOC-RJ-14": {
			"id": "LOC-RJ-14",
			"name": "Sam Sand Dunes & Camel Caravan",
			"state": "Rajasthan",
			"location": "Thar Desert Edge, West of Jaisalmer",
			"description": "Sweeping wind-sculpted crescent barchan sand dunes glowing rich amber and honey gold under the western Thar sunset.",
			"why_famous": "Rajasthan's iconic pure sand-dune desert horizon famed for evening camel caravans and folk music camps.",
			"fact": "Thar winds continually reshape smooth sinuous ridges 30–60 metres high across the Sam dunes."
		},
		"LOC-RJ-16": {
			"id": "LOC-RJ-16",
			"name": "Jaisalmer Fort (Sonar Qila)",
			"state": "Rajasthan",
			"location": "Trikuta Hill, Jaisalmer, Rajasthan",
			"description": "Magnificent golden-sandstone citadel built in 1156 by Rawal Jaisal crowned by 99 rounded defensive bastions.",
			"why_famous": "UNESCO World Heritage Site and one of the very few 'living forts' in the world still home to bustling haveli lanes and families.",
			"fact": "Nicknamed 'Sonar Qila' (The Golden Fort) because its honey-yellow Jurassic sandstone glows like molten gold at dusk."
		},
		"raj_aravalli_cp": {
			"id": "raj_aravalli_cp",
			"name": "Aravalli Foothill Pass",
			"state": "Rajasthan",
			"location": "Aravalli Mountain Corridor, Rajasthan",
			"description": "Leaving Jaipur's Pink City walls behind for dry rocky valleys and ancient Aravalli granite hills toward Pushkar.",
			"why_famous": "The Aravalli Range is India's oldest fold mountain chain framing the eastern edge of the Thar Desert.",
			"fact": "Marks the scenic transition from heritage palaces into Rajasthan's rocky desert foothills."
		},
		"raj_desert_cp": {
			"id": "raj_desert_cp",
			"name": "Thar Expressway Gate",
			"state": "Rajasthan",
			"location": "Central Thar Desert Highway, Rajasthan",
			"description": "Entering open golden sand dunes, traditional Bhunga desert villages, Khejri trees, and Osian oasis temples.",
			"why_famous": "Connects central Marwar plains across shifting Thar desert terrain toward Jodhpur.",
			"fact": "Thar is the world's most populated desert ecosystem, sustaining hardy Khejri trees and camel herds."
		},
		"raj_jodhpur_cp": {
			"id": "raj_jodhpur_cp",
			"name": "Jodhpur Blue City Gate",
			"state": "Rajasthan",
			"location": "Jodhpur Marwar District, Rajasthan",
			"description": "Arriving at Marwar's royal capital beneath Mehrangarh cliff walls, blue houses, Jaswant Thada, and Umaid Bhawan Palace.",
			"why_famous": "Celebrated globally as both the 'Sun City' and 'Blue City' resting on the edge of the Thar Desert.",
			"fact": "From Jodhpur westwards, desert dunes deepen into honey-gold stone approaching Jaisalmer."
		},
		"raj_destination": {
			"id": "raj_destination",
			"name": "Jaisalmer Golden City Victory Arch",
			"state": "Rajasthan",
			"location": "Jaisalmer, Thar Desert Sunset Horizon",
			"description": "Grand golden sandstone arch welcoming travellers across Sam Sand Dunes into historic Sonar Qila, Jaisalmer.",
			"why_famous": "Marks full completion of the 1,200m Rajasthan expedition from Jaipur sunrise to Jaisalmer sunset.",
			"fact": "Carved entirely in Jaisalmer's signature warm yellow sandstone motif."
		},

		# =========================================================================
		# 5. GUJARAT (5 LANDMARKS)
		# =========================================================================
		"LOC-GJ-01": {
			"id": "LOC-GJ-01",
			"name": "Sabarmati Ashram Hriday Kunj",
			"state": "Gujarat",
			"location": "Sabarmati Riverfront, Ahmedabad",
			"description": "The tranquil riverside ashram founded by Mahatma Gandhi in 1917 on the banks of the Sabarmati River.",
			"why_famous": "The spiritual birthplace of India's non-violent freedom struggle and the launchpad for the historic 1930 Dandi Salt March.",
			"fact": "Preserves Gandhi's original spinning charkha wheel, writing desk, and simple living quarters ('Hriday Kunj') exactly as they were in 1930."
		},
		"LOC-GJ-02": {
			"id": "LOC-GJ-02",
			"name": "Adalaj Stepwell (Vav)",
			"state": "Gujarat",
			"location": "Gandhinagar Subterranean, Gujarat",
			"description": "A breathtaking five-storey subterranean stepwell built in 1498 by Queen Rudabai in the Solanki architectural style.",
			"why_famous": "Renowned for its fusion of Hindu and Islamic decorative carvings and intricate octagonal shafts descending deep into the water table.",
			"fact": "The subterranean architecture creates a microclimate inside where the air temperature is consistently 6 degrees cooler than the scorching surface."
		},
		"LOC-GJ-07": {
			"id": "LOC-GJ-07",
			"name": "Modhera Sun Temple Surya Kund",
			"state": "Gujarat",
			"location": "Pushpavati River, Mehsana, Gujarat",
			"description": "A 1,000-year-old architectural masterpiece built in 1026 CE by King Bhima I of the Solanki dynasty dedicated to the Sun God Surya.",
			"why_famous": "Features the grand Surya Kund (sacred stepwell) adorned with 108 miniature carved shrines descending rhythmically into the water.",
			"fact": "Engineered with precise astronomical alignment so that on the equinoxes, the rising sun's first beam directly illuminated the diamond on the deity's crown."
		},
		"LOC-GJ-11": {
			"id": "LOC-GJ-11",
			"name": "Somnath Temple Jyotirlinga Shrine",
			"state": "Gujarat",
			"location": "Prabhas Patan Coast, Saurashtra",
			"description": "A magnificent seashore temple constructed in the traditional Chaulukya (Kailash Mahameru Prasad) architectural style.",
			"why_famous": "Revered as the first ('Prathama') among the twelve holy Jyotirlinga shrines of Lord Shiva across India.",
			"fact": "Features the ancient Baan Stambh (Arrow Pillar), noting that an unobstructed line of sea latitude extends from Somnath all the way to Antarctica."
		},
		"LOC-GJ-16": {
			"id": "LOC-GJ-16",
			"name": "Statue of Unity Grand Colossus",
			"state": "Gujarat",
			"location": "Narmada Riverfront, Gujarat",
			"description": "The world's tallest statue, standing at an astounding height of 182 metres (597 feet) facing the Narmada Dam.",
			"why_famous": "Monumental tribute honouring Sardar Vallabhbhai Patel, the 'Iron Man of India' who unified 562 princely states into the Indian Republic.",
			"fact": "Built using 210,000 cubic metres of cement, 18,500 tonnes of reinforced steel, and clad in 1,700 tonnes of external bronze plates."
		},

		# =========================================================================
		# 6. TELANGANA — HYDERABAD CITY EXPLORER (15 LANDMARKS + ROUTE WAYPOINTS)
		# =========================================================================
		"LOC-TG-01": {
			"id": "LOC-TG-01",
			"name": "Charminar",
			"state": "Telangana",
			"location": "Old City, Hyderabad, Telangana",
			"description": "The iconic 1591 CE monument built by Muhammad Quli Qutb Shah at the historic crossroads of Old Hyderabad.",
			"why_famous": "Celebrated for its four soaring minarets, grand Cassetted arches, and surrounding historic Old City bazaars.",
			"fact": "Constructed in limestone, granite, and pulverized marble, Charminar marks the foundation point of the city of Hyderabad."
		},
		"LOC-TG-02": {
			"id": "LOC-TG-02",
			"name": "Mecca Masjid",
			"state": "Telangana",
			"location": "Old City, Hyderabad, Telangana",
			"description": "One of India's oldest and largest congregational mosques, commissioned in the 17th century beside Charminar.",
			"why_famous": "Built with colossal single-block granite columns and a vast prayer hall welcoming thousands in serene harmony.",
			"fact": "Its central entrance arch incorporates traditional bricks prepared from soil brought from Mecca."
		},
		"LOC-TG-03": {
			"id": "LOC-TG-03",
			"name": "Laad Bazaar",
			"state": "Telangana",
			"location": "Choodi Bazaar, Old City, Hyderabad",
			"description": "A vibrant heritage market lane radiating west from Charminar, famous for traditional lac bangles and bridal craft.",
			"why_famous": "Centuries-old heritage shops preserve Hyderabadi stone-studded bangles, pearls, zardozi textiles, and attar perfumes.",
			"fact": "Historically active since the Qutb Shahi era, Laad Bazaar earned the name 'Choodi Bazaar' for its handcrafted lacquerware."
		},
		"LOC-TG-04": {
			"id": "LOC-TG-04",
			"name": "Chowmahalla Palace",
			"state": "Telangana",
			"location": "Khilwat, Old City, Hyderabad",
			"description": "The 18th-century seat of the Asaf Jahi Nizams, renowned for its four interconnected royal palaces and courtyards.",
			"why_famous": "Features the majestic Khilwat Mubarak coronation hall lit by 19 Belgian crystal chandeliers and serene ornamental fountains.",
			"fact": "Its royal garages display classic vintage automobiles, including a celebrated canary-yellow 1912 Rolls-Royce Silver Ghost."
		},
		"LOC-TG-05": {
			"id": "LOC-TG-05",
			"name": "Salar Jung Museum",
			"state": "Telangana",
			"location": "Dar-ul-Shifa, Musi Southern Bank, Hyderabad",
			"description": "One of India's National Museums, housing the extraordinary art and antiquity collection of Mir Yousuf Ali Khan (Salar Jung III).",
			"why_famous": "Celebrated worldwide for the marble 'Veiled Rebecca', the 19th-century musical clock, and global decorative treasures.",
			"fact": "Houses over 40,000 artworks, rare manuscripts, and royal artifacts gathered across Europe, Asia, and the Middle East."
		},
		"LOC-TG-06": {
			"id": "LOC-TG-06",
			"name": "Telangana State Archaeology Museum",
			"state": "Telangana",
			"location": "Public Gardens, Nampally, Hyderabad",
			"description": "A stately Indo-Saracenic museum complex standing inside Hyderabad's historic Public Gardens.",
			"why_famous": "Preserves rare Deccani sculptures, Nizam galleries, bronzes, ancient coins, and classical Ajanta fresco copies.",
			"fact": "Constructed in 1930 CE under the seventh Nizam, making it the oldest museum building in Hyderabad."
		},
		"LOC-TG-07": {
			"id": "LOC-TG-07",
			"name": "Osmania University",
			"state": "Telangana",
			"location": "Adikmet, Hyderabad",
			"description": "Founded in 1918 CE, crowned by the grand Indo-Saracenic pink-granite Arts College edifice.",
			"why_famous": "The seventh-oldest university in India and a hallmark of Deccani sandstone arches, domes, and collegiate architecture.",
			"fact": "Pioneered higher education with Urdu as a medium alongside modern Arts, Engineering, and Sciences."
		},
		"LOC-TG-08": {
			"id": "LOC-TG-08",
			"name": "Hussain Sagar Lake",
			"state": "Telangana",
			"location": "Tank Bund, Hyderabad",
			"description": "An expansive 16th-century heart-shaped reservoir uniting the twin cities of Hyderabad and Secunderabad.",
			"why_famous": "Built in 1563 CE by Ibrahim Quli Qutb Shah on a tributary of the Musi River to nourish the capital.",
			"fact": "Spanning more than 5 square kilometres, its eastern bund promenade features classical bronze statues of Telangana luminaries."
		},
		"LOC-TG-09": {
			"id": "LOC-TG-09",
			"name": "Buddha Statue of Hussain Sagar",
			"state": "Telangana",
			"location": "Gibraltar Rock, Hussain Sagar, Hyderabad",
			"description": "An 18-metre monolithic white granite statue of Gautama Buddha rising at the center of Hussain Sagar Lake.",
			"why_famous": "One of the world's tallest single-rock statues of the Buddha, resting on an ornate lotus pedestal.",
			"fact": "Hand-carved over five years from a single 450-ton granite block and erected upon Gibraltar Rock in 1992."
		},
		"LOC-TG-10": {
			"id": "LOC-TG-10",
			"name": "Necklace Road",
			"state": "Telangana",
			"location": "Hussain Sagar Waterfront, Hyderabad",
			"description": "A scenic urban waterfront boulevard curving around the western rim of Hussain Sagar like a radiant necklace.",
			"why_famous": "Links Sanjeevaiah Park, Lumbini Park, and NTR Gardens beside tranquil lake waters and evening lights.",
			"fact": "Named for its glowing crescent arc seen from nearby hilltops after dusk across the lakefront."
		},
		"LOC-TG-11": {
			"id": "LOC-TG-11",
			"name": "Birla Mandir",
			"state": "Telangana",
			"location": "Naubat Pahad, Hyderabad",
			"description": "A luminous white Makrana marble temple crowning the 280-foot rocky hillock of Naubat Pahad overlooking Hussain Sagar.",
			"why_famous": "Blends Dravidian, Utkal, and Rajasthani architectural styles with sweeping views of the Hyderabad skyline.",
			"fact": "Built using over 2,000 tons of pure Rajasthani marble and intentionally omits traditional bells for silent serenity."
		},
		"LOC-TG-12": {
			"id": "LOC-TG-12",
			"name": "Qutb Shahi Tombs",
			"state": "Telangana",
			"location": "Ibrahim Bagh, Hyderabad",
			"description": "A serene heritage park near Golconda housing the grand domed mausoleums of the seven Qutb Shahi sultans.",
			"why_famous": "Distinctive bulbous granite domes, pointed arches, and ornamental stucco work chronicle 170 years of Deccani royal art.",
			"fact": "All seven rulers of the dynasty lie nestled within landscaped Mughal-inspired gardens beneath Golconda's walls."
		},
		"LOC-TG-13": {
			"id": "LOC-TG-13",
			"name": "Taramati Baradari",
			"state": "Telangana",
			"location": "Ibrahim Bagh, Near Golconda, Hyderabad",
			"description": "A 17th-century open-air pavilion featuring twelve arched openings designed to catch crosswinds and acoustic echoes.",
			"why_famous": "Legends tell that music sung atop this pavilion carried effortlessly across the valley to Abdullah Qutb Shah at Golconda Fort.",
			"fact": "An architectural triumph of natural cross-ventilation built atop rocky Deccan boulders facing the fortress."
		},
		"LOC-TG-14": {
			"id": "LOC-TG-14",
			"name": "Falaknuma Palace",
			"state": "Telangana",
			"location": "Engine Bowli, Hyderabad",
			"description": "Built 2,000 feet above the city like a radiant mirror in the sky, blending Italian Renaissance and Tudor design.",
			"why_famous": "Celebrated for its scorpion-shaped wings, Venetian chandeliers, stained-glass galleries, and grand marble staircase.",
			"fact": "'Falaknuma' means 'Like the Sky' in Urdu, capturing its hilltop panorama across southern Hyderabad."
		},
		"LOC-TG-15": {
			"id": "LOC-TG-15",
			"name": "Golconda Fort",
			"state": "Telangana",
			"location": "Golconda, Hyderabad, Telangana",
			"description": "Hyderabad's legendary granite hill fortress with concentric fortified walls, bastions, and royal citadel halls.",
			"why_famous": "Historic capital of the Qutb Shahi kingdom and hub of the famed Golconda diamond mines including the Koh-i-Noor.",
			"fact": "Famous for the acoustic Fateh Darwaza arch, where a sharp handclap echoes clear up to the Bala Hissar pavilion."
		},
		"tel_start": {
			"id": "tel_start",
			"name": "Charminar, Old Hyderabad",
			"state": "Telangana",
			"location": "Old City, Hyderabad",
			"description": "Starting gate of the Hyderabad City Explorer expedition beside Charminar and Laad Bazaar.",
			"why_famous": "The ceremonial launchpoint into Hyderabad's royal plazas, palaces, lakes, and fortress hills.",
			"fact": "Marks Km 0 of the 1000m urban heritage drive across Hyderabad."
		},
		"tel_salar_jung": {
			"id": "tel_salar_jung",
			"name": "Salar Jung Museum",
			"state": "Telangana",
			"location": "Dar-ul-Shifa, Hyderabad",
			"description": "Major heritage milestone along the southern banks of the Musi River.",
			"why_famous": "One of the largest one-man art collections in the world, anchoring the City Heritage zone.",
			"fact": "Positioned just before the climb toward Tank Bund and Hussain Sagar Lake."
		},
		"tel_hussain_cp": {
			"id": "tel_hussain_cp",
			"name": "Tank Bund / Necklace Road Toll",
			"state": "Telangana",
			"location": "Hussain Sagar Lakefront, Hyderabad",
			"description": "Scenic lakeside checkpoint overlooking the Hussain Sagar waters and Buddha Statue.",
			"why_famous": "Unites the bustling lakefront promenades of Tank Bund and Necklace Road in the heart of Hyderabad.",
			"fact": "Grants generous checkpoint supplies before ascending westward toward Golconda Heritage."
		},
		"tel_qutb_shahi": {
			"id": "tel_qutb_shahi",
			"name": "Qutb Shahi Tombs",
			"state": "Telangana",
			"location": "Ibrahim Bagh, Hyderabad",
			"description": "Historic domed necropolis approaching the outer fortifications of Golconda Citadel.",
			"why_famous": "Monumental royal tombs framing the western horizon toward Golconda Fort.",
			"fact": "Marks the gateway into the final uphill Golconda climb."
		},
		"tel_destination": {
			"id": "tel_destination",
			"name": "Golconda Fort, Hyderabad",
			"state": "Telangana",
			"location": "Golconda Citadel, Hyderabad",
			"description": "Grand destination arch crowning the Hyderabad City Explorer route atop Golconda's ancient approaches.",
			"why_famous": "Celebrates completing the urban adventure from Charminar through Hussain Sagar to the mighty fort.",
			"fact": "Unlocks full Hyderabad expedition honours upon crossing the Finish Arch."
		}
	}
