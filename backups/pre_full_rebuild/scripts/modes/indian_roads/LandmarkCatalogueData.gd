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
		# 1. TAMIL NADU (12 LANDMARKS)
		# =========================================================================
		"LOC-TN-03": {
			"id": "LOC-TN-03",
			"name": "Gandhi Memorial Mandapam",
			"state": "Tamil Nadu",
			"location": "Kanyakumari Coast, Tamil Nadu",
			"description": "An elegant pink coastal memorial built in the Orissan architectural tradition along the sea shore.",
			"why_famous": "Built on the sacred site where Mahatma Gandhi's ashes were kept for public homage prior to sea immersion in 1948.",
			"fact": "Engineered so that on October 2nd (Gandhi's birthday), the first rays of sunlight fall precisely through a ceiling aperture onto the exact ash spot."
		},
		"LOC-TN-04": {
			"id": "LOC-TN-04",
			"name": "Kumari Amman Temple",
			"state": "Tamil Nadu",
			"location": "Cape Comorin Shore, Tamil Nadu",
			"description": "Ancient 3,000-year-old coastal sanctuary dedicated to Goddess Devi Kanya Kumari at India's southern tip.",
			"why_famous": "Famed for the deity's legendary ruby nose ring, whose brilliant luminescence guided mariners navigating the hazardous cape waters.",
			"fact": "The main sea-facing portal remains locked year-round to prevent ships from mistaking the sparkling gem for a coastal lighthouse."
		},
		"LOC-TN-05": {
			"id": "LOC-TN-05",
			"name": "Kanyakumari Glass Bridge",
			"state": "Tamil Nadu",
			"location": "Laccadive Sea Promenade, Tamil Nadu",
			"description": "A striking modern skywalk bridge projecting out over the crashing waves of the southern sea.",
			"why_famous": "Offers an unhindered transparent panoramic platform overlooking the confluence of the Indian Ocean, Arabian Sea, and Bay of Bengal.",
			"fact": "Built with high-tensile structural steel box girders and multi-layered tempered laminated glass engineered against extreme marine typhoons."
		},
		"LOC-TN-02": {
			"id": "LOC-TN-02",
			"name": "Vivekananda Rock Memorial",
			"state": "Tamil Nadu",
			"location": "Indian Ocean Island, Kanyakumari",
			"description": "Majestic granite rock memorial situated 500 metres offshore on two adjacent sea rock islands.",
			"why_famous": "The sacred meditation retreat where Swami Vivekananda attained spiritual enlightenment and his universal message of harmony in 1892.",
			"fact": "Features the Dhyana Mandapam meditation hall designed with a unique synthesis of temple architectural motifs from across India."
		},
		"LOC-TN-01": {
			"id": "LOC-TN-01",
			"name": "Thiruvalluvar Statue",
			"state": "Tamil Nadu",
			"location": "Kanyakumari Offshore Rock, Tamil Nadu",
			"description": "A monumental 133-foot carved granite colossus honouring the ancient Tamil philosopher-poet Valluvar.",
			"why_famous": "Its 133-foot height directly corresponds to the 133 chapters of the Tirukkural, one of humanity's greatest ethical treatises on virtue and truth.",
			"fact": "Sculpted by 500 master artisans from over 7,000 tons of solid stone, designed with an internal hollow core to withstand high-energy oceanic tsunamis."
		},
		"LOC-TN-06": {
			"id": "LOC-TN-06",
			"name": "Vattakottai Coastal Fort",
			"state": "Tamil Nadu",
			"location": "Coastal Ramparts, Kanyakumari",
			"description": "An 18th-century circular granite seaside fortification built under the reign of the Travancore Kingdom.",
			"why_famous": "Served as a key coastal defense bastion guarding the sea lanes around Cape Comorin with gun mounts and stone battlements.",
			"fact": "Constructed with massive natural black granite blocks; one side directly overlooks the rolling blue waves while the other frames the Western Ghats."
		},
		"LOC-TN-07": {
			"id": "LOC-TN-07",
			"name": "Kamarajar Memorial Mandapam",
			"state": "Tamil Nadu",
			"location": "Shoreline Park, Kanyakumari",
			"description": "A grand seaside memorial complex dedicated to K. Kamaraj, the revered statesman and former Chief Minister of Tamil Nadu.",
			"why_famous": "Celebrates the 'Kingmaker' who spearheaded free education and introduced the revolutionary midday meal scheme across the state.",
			"fact": "Houses extensive photographic archives and personal artifacts documenting the transformative socio-educational renaissance of South India."
		},
		"LOC-TN-14": {
			"id": "LOC-TN-14",
			"name": "Meenakshi Amman Temple",
			"state": "Tamil Nadu",
			"location": "Madurai Temple City, Tamil Nadu",
			"description": "A world-renowned historic Dravidian temple complex dominating the cultural heart of Madurai.",
			"why_famous": "Renowned for its 14 soaring sculptured gopurams (gateway towers), sacred Golden Lotus Tank, and legendary Hall of a Thousand Pillars.",
			"fact": "The colossal southern tower reaches a height of 52 metres and is adorned with over 1,500 intricately painted stucco sculptures of deities and mythical beasts."
		},
		"LOC-TN-15": {
			"id": "LOC-TN-15",
			"name": "Thirumalai Nayakkar Mahal",
			"state": "Tamil Nadu",
			"location": "Madurai Royal Palace, Tamil Nadu",
			"description": "A magnificent 17th-century palace built in 1636 CE by King Thirumalai Nayak of the Nayaka dynasty.",
			"why_famous": "Celebrated as an architectural triumph synthesizing classical Italian Renaissance colonnades with indigenous Dravidian arches and vaults.",
			"fact": "The giant cylindrical stucco pillars in the Swarga Vilasam durbar hall measure 12 metres in height and 4 metres in circumference."
		},
		"LOC-TN-16": {
			"id": "LOC-TN-16",
			"name": "NH44 Highway Junction Dhaba",
			"state": "Tamil Nadu",
			"location": "Tamil Countryside Corridor",
			"description": "A bustling highway pitstop and traditional roadside tea dhaba along India's longest national highway NH44.",
			"why_famous": "The lifeline of South Indian long-distance road trips, serving freshly brewed frothy filter coffee, piping-hot medu vadas, and masala dosas.",
			"fact": "NH44 runs 4,112 kilometres continuously from Srinagar in Kashmir all the way to Kanyakumari at the southern tip of India."
		},
		"LOC-TN-17": {
			"id": "LOC-TN-17",
			"name": "Kapaleeshwarar Temple",
			"state": "Tamil Nadu",
			"location": "Mylapore, Chennai, Tamil Nadu",
			"description": "A landmark 7th-century Dravidian temple complex dedicated to Lord Shiva situated in historic Mylapore.",
			"why_famous": "Showcases authentic classical Pallava-Chola architecture, a resplendent rainbow gopuram, and a vast sacred water tank surrounded by historic streets.",
			"fact": "Home to the famous annual Arupathimoovar festival where 63 bronze statues of Nayanmar saints are carried in a grand coastal procession."
		},
		"LOC-TN-22": {
			"id": "LOC-TN-22",
			"name": "Marina Beach Lighthouse",
			"state": "Tamil Nadu",
			"location": "Marina Beach, Chennai, Tamil Nadu",
			"description": "A towering 46-metre triangular concrete beacon standing proudly beside the Bay of Bengal surf.",
			"why_famous": "One of the only lighthouses in India fitted with an express observation elevator, offering panoramic views over the world's second-longest urban beach.",
			"fact": "Equipped with a powerful modern solar-powered metal-halide optic that projects navigational beam signals over 28 nautical miles out to sea."
		},

		# =========================================================================
		# 2. GOA (9 LANDMARKS)
		# =========================================================================
		"LOC-GA-02": {
			"id": "LOC-GA-02",
			"name": "Fontainhas Latin Quarter",
			"state": "Goa",
			"location": "Panaji Heritage Quarter, Goa",
			"description": "Asia's only surviving Mediterranean Latin quarter, nestled along the base of the Altinho hillside in Panaji.",
			"why_famous": "Famed for its narrow cobblestone alleys lined with 18th-century Portuguese colonial homes painted in vibrant ochre yellow, azure blue, and terracotta red.",
			"fact": "By municipal law dating back centuries, all houses in Fontainhas must be repainted annually immediately following the monsoon season."
		},
		"LOC-GA-01": {
			"id": "LOC-GA-01",
			"name": "Our Lady of Immaculate Conception",
			"state": "Goa",
			"location": "Panaji Church Square, Goa",
			"description": "An iconic brilliant-white colonial Baroque church built on a high terraced bluff above central Panaji in 1541.",
			"why_famous": "Instantly recognizable by its grand symmetrical zigzag staircases and towering crown pediment overlooking the city square.",
			"fact": "Houses the second-largest church bell in Goa, cast in bronze and originally brought over from the Augustinian monastery in Old Goa."
		},
		"LOC-GA-11": {
			"id": "LOC-GA-11",
			"name": "Calangute Beach Road Promenade",
			"state": "Goa",
			"location": "Bardez Coastal Strip, North Goa",
			"description": "The bustling beach avenue leading directly into the golden sands of Calangute, the 'Queen of Beaches'.",
			"why_famous": "The historic epicenter of Goa's coastal tourism culture since the 1960s, lined with wooden beach shacks, seafood eateries, and coconut groves.",
			"fact": "Originally discovered as a peaceful haven by international travelers, it now forms Goa's most celebrated coastal lifestyle promenade."
		},
		"LOC-GA-09": {
			"id": "LOC-GA-09",
			"name": "Fort Aguada & 1864 Lighthouse",
			"state": "Goa",
			"location": "Sinquerim Coastal Bluff, North Goa",
			"description": "A massive 17th-century Portuguese laterite sea fortress commanding the mouth of the Mandovi River.",
			"why_famous": "Served as the primary strategic bastion guarding Portuguese Goa against Maratha and Dutch fleets, housing an enormous 2.3-million-gallon freshwater cistern.",
			"fact": "Features a 4-story circular stone lighthouse constructed in 1864, which is the oldest lighthouse of its kind across the entire Asian continent."
		},
		"LOC-GA-14": {
			"id": "LOC-GA-14",
			"name": "Chapora Red Laterite Fort",
			"state": "Goa",
			"location": "Vagator Hilltop, North Goa",
			"description": "Atmospheric red laterite ramparts perched atop a dramatic coastal ridge high above the Chapora River estuary.",
			"why_famous": "Famed for sweeping 360-degree sunset vistas across Vagator Beach and featured prominently in modern Indian cinema.",
			"fact": "Built by Adil Shah of Bijapur and later rebuilt by the Portuguese in 1717 with subterranean escape tunnels leading to the river shore."
		},
		"LOC-GA-16": {
			"id": "LOC-GA-16",
			"name": "Se Cathedral",
			"state": "Goa",
			"location": "Old Goa UNESCO Heritage Site",
			"description": "One of the largest cathedrals in all of Asia, built in the imposing Portuguese-Manueline architectural style.",
			"why_famous": "Dedicated to St. Catherine of Alexandria and renowned for its majestic Tuscan exterior and richly gilded interior Corinthian chapels.",
			"fact": "Houses the legendary 'Golden Bell' (Sino de Ouro), celebrated across the world for its rich, melodious tone that can be heard across the river valley."
		},
		"LOC-GA-17": {
			"id": "LOC-GA-17",
			"name": "Church of St Francis of Assisi",
			"state": "Goa",
			"location": "Old Goa UNESCO Heritage Site",
			"description": "A handsome church built in 1661 featuring a decorative Manueline entrance portal saved from an earlier 1517 structure.",
			"why_famous": "Renowned for its remarkable woodcarvings, biblical fresco panels, and gilded floral reredos behind the high altar.",
			"fact": "The adjacent convent now serves as the Archaeological Museum of Goa, displaying exquisite colonial stone sculptures and royal portraits."
		},
		"LOC-GA-15": {
			"id": "LOC-GA-15",
			"name": "Basilica of Bom Jesus",
			"state": "Goa",
			"location": "Old Goa UNESCO Heritage Site",
			"description": "A globally renowned UNESCO World Heritage site and India's finest example of unplastered Renaissance Baroque architecture.",
			"why_famous": "Preserves the sacred mortal relics of St. Francis Xavier in an ornate Florentine silver-and-marble mausoleum.",
			"fact": "Every ten years, the sacred relics are brought down for solemn public veneration during a worldwide exposition drawing millions of pilgrims."
		},
		"LOC-GA-22": {
			"id": "LOC-GA-22",
			"name": "Holy Spirit Church",
			"state": "Goa",
			"location": "Margao Heritage Square, South Goa",
			"description": "An imposing 17th-century Baroque church anchoring the historic Old Market square of South Goa's cultural capital.",
			"why_famous": "Celebrated for its monumental pure-white stucco facade, gilded reredos, and peaceful tree-lined avenue of grand Portuguese mansions.",
			"fact": "Rebuilt in 1675 on a site originally consecrated in 1564, it remains the focal point for Margao's vibrant annual Feast of Pentecost celebrations."
		},

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
