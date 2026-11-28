import os
import subprocess

OUT_DIR = "assets/indian_locations/tamil_nadu/backgrounds"
os.makedirs(f"{OUT_DIR}/distant_landscape", exist_ok=True)
os.makedirs(f"{OUT_DIR}/midground", exist_ok=True)

# Helper function to generate SVG & PNG
def create_asset(name, svg_content, subfolder):
    svg_path = f"{OUT_DIR}/{subfolder}/{name}.svg"
    png_path = f"{OUT_DIR}/{subfolder}/{name}.png"
    with open(svg_path, "w") as fp:
        fp.write(svg_content.strip())
    res = subprocess.run(["ffmpeg", "-y", "-i", svg_path, png_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if res.returncode == 0:
        print(f"Generated {png_path} ({os.path.getsize(png_path)} bytes)")
    else:
        print(f"Error generating {png_path}")

# =============================================================================
# 1. KANYAKUMARI (0 - 60m): Cape Comorin Seascape & Triveni Sangam Ocean
# =============================================================================
svg_01 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky01" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="50%" stop-color="#38bdf8"/>
      <stop offset="85%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#fef08a"/>
    </linearGradient>
    <linearGradient id="ocean01" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0369a1"/>
      <stop offset="45%" stop-color="#0284c7"/>
      <stop offset="100%" stop-color="#0ea5e9"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky01)"/>
  <!-- Morning Coastal Sun -->
  <circle cx="1520" cy="220" r="90" fill="#fef08a" opacity="0.4"/>
  <circle cx="1520" cy="220" r="55" fill="#ffffff" opacity="0.75"/>
  <!-- Cirrus Clouds -->
  <path d="M 120,110 Q 280,95 440,108 Q 320,125 120,110 Z" fill="#ffffff" opacity="0.55"/>
  <path d="M 780,150 Q 940,135 1120,148 Q 960,165 780,150 Z" fill="#ffffff" opacity="0.5"/>
  <!-- Vast Ocean Horizon -->
  <rect x="0" y="320" width="1920" height="400" fill="url(#ocean01)"/>
  <!-- Ocean swell waves -->
  <path d="M 0,400 Q 320,385 640,398 T 1280,392 T 1920,400 L 1920,720 L 0,720 Z" fill="#0284c7" opacity="0.8"/>
  <path d="M 0,430 Q 240,422 480,428 T 960,424 T 1440,429 T 1920,425" stroke="#ffffff" stroke-width="3" stroke-dasharray="45 25" opacity="0.8" fill="none"/>
  <!-- Offshore Rock Silhouettes: Vivekananda & Thiruvalluvar pedestal on the ocean -->
  <path d="M 380,395 Q 430,355 490,395 Z" fill="#1e293b" opacity="0.75"/>
  <path d="M 470,395 Q 510,365 560,395 Z" fill="#334155" opacity="0.65"/>
  <path d="M 1420,395 Q 1470,360 1530,395 Z" fill="#1e293b" opacity="0.7"/>
  <!-- Coastal Shore Dunes -->
  <path d="M 0,460 Q 360,430 720,450 T 1440,440 T 1920,455 L 1920,720 L 0,720 Z" fill="#fcd34d" opacity="0.5"/>
  <path d="M 0,510 Q 400,475 800,500 T 1600,485 T 1920,505 L 1920,720 L 0,720 Z" fill="#15803d" opacity="0.7"/>
</svg>"""

# =============================================================================
# 2. NAGERCOIL (60 - 150m): Western Ghats Foothills & Emerald Green Countryside
# =============================================================================
svg_02 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky02" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="60%" stop-color="#7dd3fc"/>
      <stop offset="100%" stop-color="#e0f2fe"/>
    </linearGradient>
    <linearGradient id="ghats02" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#312e81"/>
      <stop offset="100%" stop-color="#4338ca"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky02)"/>
  <!-- Agasthiyamalai Mountain Peaks -->
  <path d="M 0,340 L 140,260 L 290,305 L 450,220 L 620,295 L 810,200 L 980,275 L 1180,185 L 1360,270 L 1540,210 L 1730,285 L 1920,230 L 1920,720 L 0,720 Z" fill="url(#ghats02)" opacity="0.65"/>
  <!-- Middle Hills with Forest Canopy -->
  <path d="M 0,380 L 180,320 L 370,370 L 580,290 L 790,355 L 1020,280 L 1240,345 L 1460,270 L 1680,335 L 1920,290 L 1920,720 L 0,720 Z" fill="#1e1b4b" opacity="0.75"/>
  <!-- Lush Green Foothills & Banana/Coconut Valleys -->
  <path d="M 0,440 Q 320,390 640,420 T 1280,410 T 1920,430 L 1920,720 L 0,720 Z" fill="#15803d" opacity="0.85"/>
  <path d="M 0,500 Q 360,460 720,485 T 1440,475 T 1920,490 L 1920,720 L 0,720 Z" fill="#166534"/>
</svg>"""

# =============================================================================
# 3. TIRUNELVELI (150 - 250m): Thamirabarani Basin & Southern Red Laterite
# =============================================================================
svg_03 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky03" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="65%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#fed7aa"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky03)"/>
  <!-- Distant Kalakkad Rocky Ridges -->
  <path d="M 0,360 L 220,310 L 460,350 L 720,280 L 980,340 L 1240,290 L 1520,330 L 1760,270 L 1920,320 L 1920,720 L 0,720 Z" fill="#475569" opacity="0.6"/>
  <!-- Thamirabarani River Valley Green Strip -->
  <path d="M 0,420 Q 380,380 760,405 T 1520,395 T 1920,415 L 1920,720 L 0,720 Z" fill="#15803d" opacity="0.75"/>
  <!-- Red Laterite Soil & Palmyra Countryside -->
  <path d="M 0,475 Q 340,440 680,460 T 1360,450 T 1920,465 L 1920,720 L 0,720 Z" fill="#c2410c" opacity="0.85"/>
  <path d="M 0,525 Q 380,495 760,515 T 1520,505 T 1920,520 L 1920,720 L 0,720 Z" fill="#9a3412"/>
</svg>"""

# =============================================================================
# 4. KOVILPATTI (250 - 350m): Semi-Arid Red Plains & Low Acacia Scrub
# =============================================================================
svg_04 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky04" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="50%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#fed7aa"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky04)"/>
  <!-- Hot afternoon sun -->
  <circle cx="960" cy="180" r="70" fill="#fef08a" opacity="0.5"/>
  <!-- Distant isolated rocky knolls -->
  <path d="M 180,380 Q 280,330 380,380 Z" fill="#64748b" opacity="0.6"/>
  <path d="M 820,385 Q 940,325 1060,385 Z" fill="#64748b" opacity="0.55"/>
  <path d="M 1480,380 Q 1580,335 1680,380 Z" fill="#64748b" opacity="0.6"/>
  <!-- Open dry farming plains (Peanut & sesame fields) -->
  <path d="M 0,430 Q 360,400 720,420 T 1440,410 T 1920,425 L 1920,720 L 0,720 Z" fill="#ca8a04" opacity="0.75"/>
  <path d="M 0,480 Q 320,450 640,470 T 1280,460 T 1920,475 L 1920,720 L 0,720 Z" fill="#b45309" opacity="0.85"/>
  <path d="M 0,530 Q 380,505 760,520 T 1520,510 T 1920,525 L 1920,720 L 0,720 Z" fill="#854d0e"/>
</svg>"""

# =============================================================================
# 5. VIRUDHUNAGAR (350 - 450m): Rural Agrarian Landscape & Cotton Fields
# =============================================================================
svg_05 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky05" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="60%" stop-color="#7dd3fc"/>
      <stop offset="100%" stop-color="#fed7aa"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky05)"/>
  <!-- Low distant rolling ridges -->
  <path d="M 0,390 Q 340,360 680,380 T 1360,370 T 1920,385 L 1920,720 L 0,720 Z" fill="#64748b" opacity="0.5"/>
  <!-- Vast agrarian cotton & oilseed fields -->
  <path d="M 0,440 Q 360,410 720,430 T 1440,420 T 1920,435 L 1920,720 L 0,720 Z" fill="#84cc16" opacity="0.7"/>
  <!-- Village rooflines on horizon -->
  <g fill="#991b1b" opacity="0.6">
    <rect x="340" y="420" width="25" height="15"/>
    <polygon points="335,420 352,408 370,420"/>
    <rect x="980" y="415" width="30" height="18"/>
    <polygon points="975,415 995,402 1015,415"/>
    <rect x="1540" y="422" width="22" height="14"/>
    <polygon points="1535,422 1551,410 1567,422"/>
  </g>
  <path d="M 0,490 Q 320,465 640,480 T 1280,470 T 1920,485 L 1920,720 L 0,720 Z" fill="#65a30d" opacity="0.85"/>
  <path d="M 0,535 Q 380,510 760,525 T 1520,515 T 1920,530 L 1920,720 L 0,720 Z" fill="#4d7c0f"/>
</svg>"""

# =============================================================================
# 6. MADURAI (450 - 550m): Heritage City Skyline & Ancient Gopuram Silhouettes
# =============================================================================
svg_06 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky06" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0369a1"/>
      <stop offset="50%" stop-color="#38bdf8"/>
      <stop offset="85%" stop-color="#fed7aa"/>
      <stop offset="100%" stop-color="#fbcfe8"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky06)"/>
  <!-- Distant Yanaimalai Elephant Rock Silhouette -->
  <path d="M 1200,340 Q 1350,290 1550,310 Q 1650,330 1750,360 L 1750,420 L 1200,420 Z" fill="#475569" opacity="0.55"/>
  <!-- Madurai Historic Cityscape & Gopuram Silhouettes on Horizon -->
  <g fill="#4338ca" opacity="0.6">
    <!-- North Gopuram silhouette -->
    <polygon points="380,360 395,270 415,270 430,360"/>
    <polygon points="398,270 405,255 412,270"/>
    <!-- West Gopuram silhouette -->
    <polygon points="460,365 478,250 502,250 520,365"/>
    <polygon points="482,250 490,230 498,250"/>
    <!-- South Gopuram silhouette (Famous soaring tower) -->
    <polygon points="560,370 580,235 610,235 630,370"/>
    <polygon points="585,235 595,215 605,235"/>
    <!-- East Gopuram silhouette -->
    <polygon points="670,365 688,260 712,260 730,365"/>
    <polygon points="692,260 700,242 708,260"/>
    <!-- Historic City Rooflines & Nayak Mandapam Arches -->
    <rect x="320" y="360" width="460" height="30"/>
    <rect x="880" y="365" width="220" height="25"/>
    <polygon points="920,365 932,310 948,310 960,365"/>
  </g>
  <!-- Vaigai River Basin Green Ribbon -->
  <path d="M 0,420 Q 340,385 680,405 T 1360,395 T 1920,415 L 1920,720 L 0,720 Z" fill="#15803d" opacity="0.75"/>
  <!-- Fertile Madurai Soil -->
  <path d="M 0,475 Q 360,445 720,465 T 1440,455 T 1920,470 L 1920,720 L 0,720 Z" fill="#166534" opacity="0.9"/>
  <path d="M 0,525 Q 380,500 760,515 T 1520,505 T 1920,520 L 1920,720 L 0,720 Z" fill="#14532d"/>
</svg>"""

# =============================================================================
# 7. MELUR (550 - 650m): Rugged Granite Tor Outcrops & Rocky Hills
# =============================================================================
svg_07 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky07" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="60%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#e2e8f0"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky07)"/>
  <!-- Massive Granite Monoliths & Quarry Hills -->
  <ellipse cx="320" cy="380" rx="260" ry="140" fill="#475569" opacity="0.7"/>
  <ellipse cx="880" cy="350" rx="340" ry="170" fill="#334155" opacity="0.75"/>
  <ellipse cx="1520" cy="370" rx="280" ry="150" fill="#475569" opacity="0.7"/>
  <!-- Secondary Granite Boulders -->
  <ellipse cx="620" cy="420" rx="140" ry="70" fill="#64748b" opacity="0.8"/>
  <ellipse cx="1220" cy="410" rx="160" ry="80" fill="#64748b" opacity="0.8"/>
  <!-- Scrub & Granite Gravel Plains -->
  <path d="M 0,460 Q 340,430 680,450 T 1360,440 T 1920,455 L 1920,720 L 0,720 Z" fill="#71717a" opacity="0.8"/>
  <path d="M 0,515 Q 380,490 760,505 T 1520,495 T 1920,510 L 1920,720 L 0,720 Z" fill="#52525b"/>
</svg>"""

# =============================================================================
# 8. TIRUCHIRAPPALLI (650 - 750m): Iconic 83m Rockfort Hill & Cauvery Valley
# =============================================================================
svg_08 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky08" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="55%" stop-color="#7dd3fc"/>
      <stop offset="100%" stop-color="#fef08a"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky08)"/>
  <!-- THE ICONIC TRICHY ROCKFORT: 83m sheer monolithic rock rising over Cauvery plain -->
  <g fill="#334155">
    <!-- Sheer prehistoric rock monolith (1 billion years old) -->
    <path d="M 720,420 L 750,220 L 780,180 L 860,180 L 890,230 L 920,420 Z" opacity="0.85"/>
    <!-- Ucchi Pillayar Temple Crown perched on top -->
    <rect x="790" y="155" width="60" height="25" fill="#f8fafc" opacity="0.9"/>
    <polygon points="785,155 820,130 855,155" fill="#e2e8f0"/>
    <rect x="816" y="118" width="8" height="12" fill="#f59e0b"/>
    <!-- Main Thayumanaswamy rock-cut temple carved into mid-cliff -->
    <rect x="760" y="270" width="40" height="30" fill="#1e293b"/>
    <polygon points="755,270 780,250 805,270" fill="#cbd5e1"/>
  </g>
  <!-- Lush Cauvery River Basin & Srirangam Island Greenery -->
  <path d="M 0,420 Q 360,380 720,405 T 1440,395 T 1920,415 L 1920,720 L 0,720 Z" fill="#15803d" opacity="0.75"/>
  <path d="M 0,480 Q 320,450 640,470 T 1280,460 T 1920,475 L 1920,720 L 0,720 Z" fill="#166534" opacity="0.9"/>
  <path d="M 0,530 Q 380,505 760,520 T 1520,510 T 1920,525 L 1920,720 L 0,720 Z" fill="#14532d"/>
</svg>"""

# =============================================================================
# 9. PERAMBALUR (750 - 850m): Open Agricultural Countryside & Vast Farmlands
# =============================================================================
svg_09 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky09" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="60%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#fed7aa"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky09)"/>
  <!-- Vast open horizon with fluffy cumulus clouds -->
  <ellipse cx="440" cy="140" rx="140" ry="35" fill="#ffffff" opacity="0.65"/>
  <ellipse cx="1320" cy="160" rx="160" ry="38" fill="#ffffff" opacity="0.6"/>
  <!-- Low distant undulations -->
  <path d="M 0,385 Q 360,355 720,375 T 1440,365 T 1920,380 L 1920,720 L 0,720 Z" fill="#64748b" opacity="0.45"/>
  <!-- Golden & emerald patchwork farm plains -->
  <path d="M 0,435 Q 340,405 680,425 T 1360,415 T 1920,430 L 1920,720 L 0,720 Z" fill="#eab308" opacity="0.7"/>
  <path d="M 0,485 Q 320,460 640,475 T 1280,465 T 1920,480 L 1920,720 L 0,720 Z" fill="#84cc16" opacity="0.85"/>
  <path d="M 0,535 Q 380,510 760,525 T 1520,515 T 1920,530 L 1920,720 L 0,720 Z" fill="#65a30d"/>
</svg>"""

# =============================================================================
# 10. VILLUPURAM (850 - 950m): Rural GST Highway & Sugarcane Fields
# =============================================================================
svg_10 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky10" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="65%" stop-color="#7dd3fc"/>
      <stop offset="100%" stop-color="#fed7aa"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky10)"/>
  <!-- Distant Gingee Fort-style granite peaks on far horizon -->
  <path d="M 280,380 L 330,310 L 380,310 L 430,380 Z" fill="#475569" opacity="0.6"/>
  <path d="M 370,380 L 410,290 L 450,290 L 490,380 Z" fill="#334155" opacity="0.65"/>
  <path d="M 1340,380 L 1400,315 L 1460,380 Z" fill="#475569" opacity="0.55"/>
  <!-- Verdant sugarcane and paddy tracts -->
  <path d="M 0,430 Q 360,400 720,420 T 1440,410 T 1920,425 L 1920,720 L 0,720 Z" fill="#22c55e" opacity="0.75"/>
  <path d="M 0,480 Q 320,455 640,470 T 1280,460 T 1920,475 L 1920,720 L 0,720 Z" fill="#16a34a" opacity="0.85"/>
  <path d="M 0,530 Q 380,505 760,520 T 1520,510 T 1920,525 L 1920,720 L 0,720 Z" fill="#15803d"/>
</svg>"""

# =============================================================================
# 11. TINDIVANAM (950 - 1050m): Tamarind Corridor Highway & Farmland
# =============================================================================
svg_11 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky11" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="55%" stop-color="#38bdf8"/>
      <stop offset="100%" stop-color="#e0f2fe"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky11)"/>
  <!-- Expansive rural sky with scattered clouds -->
  <ellipse cx="680" cy="140" rx="180" ry="36" fill="#ffffff" opacity="0.6"/>
  <ellipse cx="1480" cy="120" rx="140" ry="32" fill="#ffffff" opacity="0.65"/>
  <!-- Distant tree lines & gentle low ridges -->
  <path d="M 0,390 Q 340,360 680,380 T 1360,370 T 1920,385 L 1920,720 L 0,720 Z" fill="#15803d" opacity="0.6"/>
  <!-- Famous Tamarind and Mango highway farmland -->
  <path d="M 0,440 Q 360,410 720,430 T 1440,420 T 1920,435 L 1920,720 L 0,720 Z" fill="#65a30d" opacity="0.75"/>
  <path d="M 0,490 Q 320,465 640,480 T 1280,470 T 1920,485 L 1920,720 L 0,720 Z" fill="#4d7c0f" opacity="0.9"/>
  <path d="M 0,535 Q 380,510 760,525 T 1520,515 T 1920,530 L 1920,720 L 0,720 Z" fill="#3f6212"/>
</svg>"""

# =============================================================================
# 12. CHENGALPATTU (1050 - 1150m): Palar River Wetlands & Lake Landscape
# =============================================================================
svg_12 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky12" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="60%" stop-color="#7dd3fc"/>
      <stop offset="100%" stop-color="#bae6fd"/>
    </linearGradient>
    <linearGradient id="lakeWater" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="100%" stop-color="#38bdf8"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky12)"/>
  <!-- Low distant hills around Chengalpattu lake basin -->
  <path d="M 0,380 Q 280,340 560,370 T 1120,355 T 1680,375 L 1920,370 L 1920,720 L 0,720 Z" fill="#475569" opacity="0.5"/>
  <!-- Vast Kolavai Lake water body reflecting sky -->
  <path d="M 0,410 Q 340,385 680,400 T 1360,395 T 1920,405 L 1920,470 L 0,470 Z" fill="url(#lakeWater)" opacity="0.85"/>
  <!-- Water highlights -->
  <path d="M 120,435 Q 240,430 360,433 M 780,425 Q 920,420 1060,423 M 1420,430 Q 1580,425 1740,428" stroke="#ffffff" stroke-width="2" opacity="0.75" fill="none"/>
  <!-- Wetland reeds, lotus fringes & green riparian banks -->
  <path d="M 0,470 Q 360,440 720,460 T 1440,450 T 1920,465 L 1920,720 L 0,720 Z" fill="#059669" opacity="0.8"/>
  <path d="M 0,520 Q 380,495 760,510 T 1520,500 T 1920,515 L 1920,720 L 0,720 Z" fill="#047857"/>
</svg>"""

# =============================================================================
# 13. CHENNAI (1150 - 1300m): Modern Metropolis Urban Skyline & Marina Coast
# =============================================================================
svg_13 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky13" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0f172a"/>
      <stop offset="35%" stop-color="#1e293b"/>
      <stop offset="70%" stop-color="#334155"/>
      <stop offset="100%" stop-color="#f59e0b"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky13)"/>
  <!-- Golden evening glow over Coromandel Coast -->
  <circle cx="1600" cy="280" r="120" fill="#fef08a" opacity="0.3"/>
  <circle cx="1600" cy="280" r="60" fill="#ffffff" opacity="0.6"/>
  <!-- Distant High-Rise Commercial Towers & Modern Urban Skyline -->
  <g fill="#1e293b" opacity="0.85">
    <rect x="180" y="240" width="45" height="180"/>
    <rect x="235" y="210" width="55" height="210"/>
    <polygon points="235,210 262,170 290,210"/>
    <rect x="300" y="260" width="50" height="160"/>
    <rect x="420" y="230" width="65" height="190"/>
    <rect x="495" y="200" width="70" height="220"/>
    <polygon points="495,200 530,165 565,200"/>
    <rect x="575" y="250" width="55" height="170"/>
    <!-- Central Chennai IT Corridor towers -->
    <rect x="740" y="190" width="80" height="230"/>
    <rect x="830" y="220" width="60" height="200"/>
    <rect x="900" y="180" width="90" height="240"/>
    <polygon points="900,180 945,140 990,180"/>
    <rect x="1000" y="230" width="70" height="190"/>
    <!-- Iconic Marina Beach Lighthouse silhouette -->
    <rect x="1140" y="170" width="30" height="250"/>
    <polygon points="1135,170 1155,140 1175,170"/>
    <circle cx="1155" cy="140" r="6" fill="#fef08a"/>
    <rect x="1240" y="240" width="60" height="180"/>
    <rect x="1310" y="210" width="75" height="210"/>
    <rect x="1395" y="250" width="65" height="170"/>
  </g>
  <!-- Modern illuminated window grids on skyline buildings -->
  <g fill="#fef08a" opacity="0.55">
    <circle cx="250" cy="230" r="2"/><circle cx="270" cy="230" r="2"/>
    <circle cx="250" cy="250" r="2"/><circle cx="270" cy="250" r="2"/>
    <circle cx="520" cy="220" r="2.5"/><circle cx="545" cy="220" r="2.5"/>
    <circle cx="520" cy="245" r="2.5"/><circle cx="545" cy="245" r="2.5"/>
    <circle cx="770" cy="210" r="2.5"/><circle cx="800" cy="210" r="2.5"/>
    <circle cx="770" cy="235" r="2.5"/><circle cx="800" cy="235" r="2.5"/>
    <circle cx="930" cy="200" r="2.5"/><circle cx="965" cy="200" r="2.5"/>
    <circle cx="930" cy="225" r="2.5"/><circle cx="965" cy="225" r="2.5"/>
  </g>
  <!-- Kathipara Flyover Cloverleaf Curved Arches & Highway Viaduct -->
  <path d="M 0,420 Q 480,360 960,390 T 1920,380 L 1920,440 L 0,440 Z" fill="#475569" opacity="0.9"/>
  <!-- Coromandel Coastal Marina Beach Shoreline & Port Cranes -->
  <path d="M 0,440 Q 360,410 720,430 T 1440,420 T 1920,435 L 1920,720 L 0,720 Z" fill="#0f172a"/>
  <!-- Streetlights & Marina Beach Promenade Lights -->
  <path d="M 0,430 Q 360,405 720,425 T 1440,415 T 1920,430" stroke="#fef08a" stroke-width="3" stroke-dasharray="15 35" opacity="0.85" fill="none"/>
  <path d="M 0,510 Q 380,485 760,500 T 1520,490 T 1920,505 L 1920,720 L 0,720 Z" fill="#020617"/>
</svg>"""

backgrounds = [
    ("tamil_nadu_bg_01_cape_comorin", svg_01),
    ("tamil_nadu_bg_02_nagercoil", svg_02),
    ("tamil_nadu_bg_03_tirunelveli", svg_03),
    ("tamil_nadu_bg_04_kovilpatti", svg_04),
    ("tamil_nadu_bg_05_virudhunagar", svg_05),
    ("tamil_nadu_bg_06_madurai", svg_06),
    ("tamil_nadu_bg_07_melur", svg_07),
    ("tamil_nadu_bg_08_tiruchirappalli", svg_08),
    ("tamil_nadu_bg_09_perambalur", svg_09),
    ("tamil_nadu_bg_10_villupuram", svg_10),
    ("tamil_nadu_bg_11_tindivanam", svg_11),
    ("tamil_nadu_bg_12_chengalpattu", svg_12),
    ("tamil_nadu_bg_13_chennai", svg_13),
]

for name, svg in backgrounds:
    create_asset(name, svg, "distant_landscape")

print("All 13 Tamil Nadu regional backgrounds generated successfully!")
