class_name LandmarkCatalogueData
extends RefCounted

## LandmarkCatalogueData: Authoritative historical, geographical, and cultural repository
## for all 44 famous Indian attractions placed across the six state routes.
## Powers the dedicated bottom information card during active gameplay.

static func get_landmark_info(landmark_id: String, state_id: String = "") -> Dictionary:
	var catalog := _get_master_catalog()
	if catalog.has(landmark_id):
		var info: Dictionary = catalog[landmark_id].duplicate()
		if state_id != "" and not info.has("state_id"):
			info["state_id"] = state_id
		return info
	
	# Fallback if unknown ID
	return {
		"id": landmark_id,
		"name": "Historical Landmark",
		"state": state_id.capitalize().replace("_", " "),
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
			"name": "Thirumalai Nayak Palace",
			"state": "Tamil Nadu",
			"location": "Madurai Royal Palace",
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
		# 3. KERALA (6 LANDMARKS)
		# =========================================================================
		"LOC-KL-01": {
			"id": "LOC-KL-01",
			"name": "Fort Kochi Chinese Fishing Nets",
			"state": "Kerala",
			"location": "Kochi Harbor Waterfront, Kerala",
			"description": "Iconic cantilevered shore-operated fishing nets (Cheena Vala) lining the picturesque entrance to Kochi Harbor.",
			"why_famous": "Introduced to the Malabar Coast in the 14th century by Chinese trader Zheng He's fleet from Kublai Khan's imperial court.",
			"fact": "Each massive 20-metre net mechanism is perfectly counterweighted by suspended stone boulders, requiring a coordinated team of six fishermen to haul."
		},
		"LOC-KL-02": {
			"id": "LOC-KL-02",
			"name": "Mattancherry Dutch Palace",
			"state": "Kerala",
			"location": "Jew Town, Kochi, Kerala",
			"description": "A historic wooden quadrangular palace constructed in the indigenous Kerala architectural style featuring sloped gabled roofs.",
			"why_famous": "Built by the Portuguese in 1555 as a goodwill gift to the Raja of Kochi and later renovated by the Dutch East India Company.",
			"fact": "Houses some of the finest traditional tempera murals in India, depicting scenes from the Ramayana in vivid organic vegetable pigments."
		},
		"LOC-KL-06": {
			"id": "LOC-KL-06",
			"name": "Alleppey Backwater Houseboat Wharf",
			"state": "Kerala",
			"location": "Vembanad Lake, Alappuzha, Kerala",
			"description": "The scenic canal gateway where traditional Kettuvallam houseboats cruise along palm-fringed backwater lagoons.",
			"why_famous": "World-famous 'Venice of the East' ecosystem where interconnected lakes, rivers, and canals weave through paddy fields below sea level.",
			"fact": "Traditional Kettuvallam boats are crafted entirely from anjili wood tied together with coir ropes without a single iron nail used in construction."
		},
		"LOC-KL-09": {
			"id": "LOC-KL-09",
			"name": "Bekal Fort Coastal Bastion",
			"state": "Kerala",
			"location": "Kasaragod Ramparts, North Kerala",
			"description": "The largest and best-preserved fort in Kerala, sprawling over 40 coastal acres overlooking the Arabian Sea.",
			"why_famous": "Features a keyhole-shaped rampart silhouette rising directly from the waves, with a tall central observation tower commanding the coastline.",
			"fact": "Unlike many Indian forts, Bekal was built purely as a maritime military defense post rather than an administrative seat or royal residence."
		},
		"LOC-KL-11": {
			"id": "LOC-KL-11",
			"name": "Athirappilly Waterfalls Viewpoint",
			"state": "Kerala",
			"location": "Chalakudy River Gorge, Kerala",
			"description": "A thundering 80-foot waterfall cascading over wide rocky cliffs, famously known as the 'Niagara of South India'.",
			"why_famous": "The largest waterfall in Kerala, surrounded by dense tropical rainforests of the Sholayar ranges and teeming with rare endemic wildlife.",
			"fact": "The only location in the Western Ghats where four endangered species of South Indian hornbills can be observed nesting in a single habitat."
		},
		"LOC-KL-14": {
			"id": "LOC-KL-14",
			"name": "Padmanabhaswamy Temple Gopuram",
			"state": "Kerala",
			"location": "Thiruvananthapuram Heritage City",
			"description": "An awe-inspiring 16th-century temple blending Chera and Dravidian styles with an iconic 100-foot seven-tier gopuram.",
			"why_famous": "Revered as the wealthiest religious institution in human history, dedicated to Lord Vishnu reclining in the divine Anantha Shayanam posture.",
			"fact": "The inner sanctum image of Lord Padmanabha is composed of 12,008 sacred Shaligram stones transported from Nepal's Gandaki River on elephants."
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
			"description": "A magnificent cluster of five connected five-storey merchant mansions carved entirely from golden-yellow Jurassic limestone.",
			"why_famous": "The largest and most ornate haveli in Jaisalmer, celebrated for its lacelike stone filigree balconies, jharokhas, and painted murals.",
			"fact": "Built over 50 years by wealthy merchant Guman Chand Patwa for his five sons, serving as a hub for Silk Road brocade and opium trade."
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
		# 6. TELANGANA (6 LANDMARKS)
		# =========================================================================
		"LOC-TG-01": {
			"id": "LOC-TG-01",
			"name": "Iconic Charminar 4-Minaret Monument",
			"state": "Telangana",
			"location": "Old City, Hyderabad, Telangana",
			"description": "The definitive symbol of Hyderabad, constructed in 1591 CE by Muhammad Quli Qutb Shah.",
			"why_famous": "A masterwork of Indo-Islamic architecture boasting four grand 48.7-metre minarets and four monumental celebratory arches.",
			"fact": "Built from granite, limestone, and pulverized marble paste to commemorate the eradication of a devastating plague from the historic city."
		},
		"LOC-TG-02": {
			"id": "LOC-TG-02",
			"name": "Chowmahalla Palace Courtyard",
			"state": "Telangana",
			"location": "Khilwat, Hyderabad, Telangana",
			"description": "The opulent 18th-century official palace seat of the Asaf Jahi dynasty (the Nizams of Hyderabad).",
			"why_famous": "Renowned for the Khilwat Mubarak grand durbar hall, illuminated by 19 colossal crystal chandeliers crafted in Belgium.",
			"fact": "Features an exquisite collection of vintage royal automobiles, including a pristine canary-yellow 1912 Rolls-Royce Silver Ghost."
		},
		"LOC-TG-03": {
			"id": "LOC-TG-03",
			"name": "Golconda Fort Bastion",
			"state": "Telangana",
			"location": "Golconda Citadel, Hyderabad",
			"description": "A colossal medieval citadel complex constructed on a 400-foot high granite granite hill with 10-kilometre outer walls.",
			"why_famous": "The historic capital of the Qutb Shahi kings and the world's most famous diamond trading center, origin of the Koh-i-Noor and Hope diamonds.",
			"fact": "Engineered with astonishing acoustic marvels: a single handclap beneath the entrance Fateh Darwaza dome echoes clearly at the Bala Hissar pavilion 1 km away."
		},
		"LOC-TG-06": {
			"id": "LOC-TG-06",
			"name": "Hussain Sagar Monolithic Buddha",
			"state": "Telangana",
			"location": "Hussain Sagar Lake, Hyderabad",
			"description": "A magnificent 18-metre monolithic white granite statue of Gautama Buddha standing on the Gibraltar Rock in Hussain Sagar Lake.",
			"why_famous": "The world's tallest single-rock monolithic statue of the Buddha, weighing over 450 tons and hand-carved from a single quarry block.",
			"fact": "Carved by 200 master sculptors in Raigir over five years, transported on a massive 192-wheel trailer, and raised on a lotus pedestal in 1992."
		},
		"LOC-TG-08": {
			"id": "LOC-TG-08",
			"name": "Birla Mandir White Marble Temple",
			"state": "Telangana",
			"location": "Naubat Pahad Hilltop, Hyderabad",
			"description": "A radiant Hindu temple built atop the 280-foot high Naubat Pahad hill overlooking the urban expanse of Hyderabad.",
			"why_famous": "Constructed from 2,000 tons of pure white Rajasthani Makrana marble, synthesizing Utkal and South Indian temple designs.",
			"fact": "The temple intentionally has no traditional bells, creating a completely serene atmosphere dedicated purely to silent meditation."
		},
		"LOC-TG-14": {
			"id": "LOC-TG-14",
			"name": "Ramappa Temple (Rudreshwara)",
			"state": "Telangana",
			"location": "Palampet, Mulugu, Telangana",
			"description": "A 13th-century Kakatiya temple and UNESCO World Heritage site standing on a 6-foot star-shaped platform.",
			"why_famous": "Celebrated for its exquisite carved black basalt bracket figures depicting slender celestial dancers and musicians in dynamic poses.",
			"fact": "Built with revolutionary 'floating bricks' so light and porous that they actually float on water, protecting the shikhara tower from earthquakes."
		}
	}
