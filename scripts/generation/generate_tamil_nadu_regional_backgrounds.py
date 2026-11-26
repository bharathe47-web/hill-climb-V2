import os
import subprocess

OUT_DIR = "assets/indian_locations/tamil_nadu/backgrounds"
os.makedirs(f"{OUT_DIR}/distant_landscape", exist_ok=True)
os.makedirs(f"{OUT_DIR}/midground", exist_ok=True)

# 1. Zone 1 (0-150m): Cape Comorin Seascape & Ocean Horizon (1920x720)
svg_bg_01 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky01" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="45%" stop-color="#38bdf8"/>
      <stop offset="85%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#fed7aa"/>
    </linearGradient>
    <linearGradient id="oceanFar" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0369a1"/>
      <stop offset="100%" stop-color="#0284c7"/>
    </linearGradient>
    <linearGradient id="oceanMid" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="100%" stop-color="#0ea5e9"/>
    </linearGradient>
    <linearGradient id="surfGradient" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#e0f2fe" stop-opacity="0.9"/>
      <stop offset="100%" stop-color="#ffffff" stop-opacity="0.4"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky01)"/>
  <!-- Morning Coastal Sun Glow -->
  <circle cx="1520" cy="240" r="110" fill="#fef08a" opacity="0.35"/>
  <circle cx="1520" cy="240" r="70" fill="#ffffff" opacity="0.6"/>
  <!-- Soft Cirrus Clouds -->
  <path d="M 120,120 Q 280,105 440,118 Q 320,135 120,120 Z" fill="#ffffff" opacity="0.45"/>
  <path d="M 780,160 Q 940,145 1120,158 Q 960,175 780,160 Z" fill="#ffffff" opacity="0.4"/>
  <path d="M 1320,110 Q 1480,95 1660,108 Q 1500,125 1320,110 Z" fill="#ffffff" opacity="0.35"/>
  <!-- Distant Ocean Horizon Line -->
  <rect x="0" y="340" width="1920" height="110" fill="url(#oceanFar)"/>
  <!-- Mid Ocean Swells -->
  <path d="M 0,420 Q 320,405 640,418 T 1280,412 T 1920,420 L 1920,720 L 0,720 Z" fill="url(#oceanMid)"/>
  <!-- Whitecaps & Surf Line -->
  <path d="M 0,448 Q 240,442 480,446 T 960,443 T 1440,447 T 1920,445" stroke="#ffffff" stroke-width="3" stroke-dasharray="45 25" opacity="0.75" fill="none"/>
  <!-- Distant Offshore Granite Islets Silhouettes -->
  <path d="M 380,425 Q 430,385 490,425 Z" fill="#1e293b" opacity="0.7"/>
  <path d="M 470,425 Q 510,395 560,425 Z" fill="#334155" opacity="0.6"/>
  <path d="M 1420,425 Q 1470,390 1530,425 Z" fill="#1e293b" opacity="0.65"/>
  <!-- Coastal Dunes & Gentle Sea Foam Shore -->
  <path d="M 0,470 Q 360,440 720,460 T 1440,450 T 1920,465 L 1920,720 L 0,720 Z" fill="#fcd34d" opacity="0.45"/>
  <path d="M 0,520 Q 400,485 800,510 T 1600,495 T 1920,515 L 1920,720 L 0,720 Z" fill="#15803d" opacity="0.65"/>
</svg>"""

# 2. Zone 2 (150-350m): Western Ghats Mountain Horizon (1920x720)
svg_bg_02 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky02" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="55%" stop-color="#7dd3fc"/>
      <stop offset="100%" stop-color="#e0f2fe"/>
    </linearGradient>
    <linearGradient id="ghatsFar" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#312e81"/>
      <stop offset="100%" stop-color="#4338ca"/>
    </linearGradient>
    <linearGradient id="ghatsMid" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#1e1b4b"/>
      <stop offset="100%" stop-color="#2e1065"/>
    </linearGradient>
    <linearGradient id="hillsGreen" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#15803d"/>
      <stop offset="100%" stop-color="#14532d"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky02)"/>
  <!-- High Altitude Clouds -->
  <ellipse cx="480" cy="140" rx="190" ry="38" fill="#ffffff" opacity="0.65"/>
  <ellipse cx="540" cy="120" rx="140" ry="42" fill="#ffffff" opacity="0.75"/>
  <ellipse cx="1480" cy="130" rx="220" ry="42" fill="#ffffff" opacity="0.6"/>
  <ellipse cx="1550" cy="110" rx="160" ry="46" fill="#ffffff" opacity="0.7"/>
  <!-- Far Agasthiyarmalai Peak Silhouettes (Majestic Jagged Ridge) -->
  <path d="M 0,380 L 140,300 L 290,345 L 450,260 L 620,335 L 810,240 L 980,315 L 1180,225 L 1360,310 L 1540,250 L 1730,325 L 1920,270 L 1920,720 L 0,720 Z" fill="url(#ghatsFar)" opacity="0.6"/>
  <!-- Mid Mountain Range with Mist Layers -->
  <path d="M 0,420 L 180,360 L 370,410 L 580,330 L 790,395 L 1020,320 L 1240,385 L 1460,310 L 1680,375 L 1920,330 L 1920,720 L 0,720 Z" fill="url(#ghatsMid)" opacity="0.8"/>
  <!-- Verdant Foothills with Thamirabarani Basin Contours -->
  <path d="M 0,490 Q 320,440 640,470 T 1280,450 T 1920,480 L 1920,720 L 0,720 Z" fill="url(#hillsGreen)" opacity="0.9"/>
  <path d="M 0,550 Q 280,515 560,535 T 1120,520 T 1680,540 T 1920,530 L 1920,720 L 0,720 Z" fill="#166534"/>
</svg>"""

# 3. Zone 3 (350-550m): Palmyra Belt & Red Soil Plains (Kovilpatti to Madurai) (1920x720)
svg_bg_03 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky03" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="50%" stop-color="#38bdf8"/>
      <stop offset="85%" stop-color="#fed7aa"/>
      <stop offset="100%" stop-color="#ffedd5"/>
    </linearGradient>
    <linearGradient id="redSoilFar" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#9a3412"/>
      <stop offset="100%" stop-color="#7c2d12"/>
    </linearGradient>
    <linearGradient id="redSoilMid" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#c2410c"/>
      <stop offset="100%" stop-color="#9a3412"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky03)"/>
  <!-- Brilliant Afternoon Sun -->
  <circle cx="960" cy="180" r="95" fill="#fef08a" opacity="0.4"/>
  <circle cx="960" cy="180" r="60" fill="#ffffff" opacity="0.75"/>
  <!-- Billowing cumulus puffs -->
  <ellipse cx="260" cy="170" rx="140" ry="32" fill="#ffffff" opacity="0.6"/>
  <ellipse cx="1660" cy="160" rx="160" ry="34" fill="#ffffff" opacity="0.6"/>
  <!-- Distant Low Red-Granite Ridges -->
  <path d="M 0,390 Q 240,340 480,375 T 960,350 T 1440,380 T 1920,360 L 1920,720 L 0,720 Z" fill="#64748b" opacity="0.45"/>
  <!-- Middle Red Soil Tableland -->
  <path d="M 0,440 Q 320,390 640,425 T 1280,410 T 1920,430 L 1920,720 L 0,720 Z" fill="url(#redSoilFar)" opacity="0.75"/>
  <!-- Palmyra Palm Horizon Silhouettes -->
  <!-- Repeating iconic Palmyra palm fans along the horizon -->
  <g fill="#451a03" opacity="0.85">
    <path d="M 120,440 L 123,380 L 126,440 Z"/>
    <circle cx="123" cy="378" r="14"/>
    <path d="M 280,435 L 283,370 L 286,435 Z"/>
    <circle cx="283" cy="368" r="16"/>
    <path d="M 450,445 L 453,385 L 456,445 Z"/>
    <circle cx="453" cy="383" r="15"/>
    <path d="M 720,430 L 723,365 L 726,430 Z"/>
    <circle cx="723" cy="363" r="17"/>
    <path d="M 1040,438 L 1043,375 L 1046,438 Z"/>
    <circle cx="1043" cy="373" r="15"/>
    <path d="M 1340,435 L 1343,370 L 1346,435 Z"/>
    <circle cx="1343" cy="368" r="16"/>
    <path d="M 1680,442 L 1683,380 L 1686,442 Z"/>
    <circle cx="1683" cy="378" r="15"/>
    <path d="M 1840,436 L 1843,372 L 1846,436 Z"/>
    <circle cx="1843" cy="370" r="16"/>
  </g>
  <!-- Foreground Terracotta Red Laterite Horizon -->
  <path d="M 0,510 Q 380,470 760,495 T 1520,480 T 1920,505 L 1920,720 L 0,720 Z" fill="url(#redSoilMid)"/>
  <path d="M 0,570 Q 280,540 560,555 T 1120,545 T 1680,560 T 1920,550 L 1920,720 L 0,720 Z" fill="#78350f"/>
</svg>"""

# 4. Zone 4 (550-750m): Melur Granite Hills & Samanar Malai (1920x720)
svg_bg_04 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky04" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="60%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#f1f5f9"/>
    </linearGradient>
    <linearGradient id="graniteFar" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#475569"/>
      <stop offset="100%" stop-color="#334155"/>
    </linearGradient>
    <linearGradient id="graniteTor" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#64748b"/>
      <stop offset="100%" stop-color="#475569"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky04)"/>
  <!-- Cirrus and cumulus clouds -->
  <ellipse cx="620" cy="150" rx="170" ry="35" fill="#ffffff" opacity="0.7"/>
  <ellipse cx="1380" cy="130" rx="200" ry="40" fill="#ffffff" opacity="0.65"/>
  <!-- Distant Weathered Granite Monoliths & Tors -->
  <path d="M 0,390 Q 160,280 340,360 Q 480,310 660,370 Q 860,260 1060,350 Q 1240,290 1440,360 Q 1660,270 1860,350 L 1920,360 L 1920,720 L 0,720 Z" fill="url(#graniteFar)" opacity="0.6"/>
  <!-- Mid Granite Boulder Hills & Rocky Outcrops -->
  <path d="M 0,440 Q 220,350 460,420 Q 700,340 940,410 Q 1180,330 1420,415 Q 1680,345 1920,420 L 1920,720 L 0,720 Z" fill="url(#graniteTor)" opacity="0.85"/>
  <!-- Dry Deciduous Scrub & Rocky Footings -->
  <path d="M 0,510 Q 320,465 640,490 T 1280,475 T 1920,500 L 1920,720 L 0,720 Z" fill="#3f3f46" opacity="0.9"/>
  <path d="M 0,570 Q 380,535 760,555 T 1520,540 T 1920,560 L 1920,720 L 0,720 Z" fill="#1c1917"/>
</svg>"""

# 5. Zone 5 (750-950m): Cauvery Delta Basin & Perambalur Agricultural Horizon (1920x720)
svg_bg_05 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky05" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="55%" stop-color="#7dd3fc"/>
      <stop offset="100%" stop-color="#dcfce7"/>
    </linearGradient>
    <linearGradient id="paddyFar" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#15803d"/>
      <stop offset="100%" stop-color="#166534"/>
    </linearGradient>
    <linearGradient id="paddyMid" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#22c55e"/>
      <stop offset="100%" stop-color="#15803d"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky05)"/>
  <!-- Fluffy Agricultural Clouds -->
  <ellipse cx="380" cy="150" rx="180" ry="40" fill="#ffffff" opacity="0.75"/>
  <ellipse cx="440" cy="130" rx="130" ry="45" fill="#ffffff" opacity="0.85"/>
  <ellipse cx="1280" cy="160" rx="210" ry="42" fill="#ffffff" opacity="0.7"/>
  <ellipse cx="1360" cy="135" rx="150" ry="48" fill="#ffffff" opacity="0.8"/>
  <!-- Distant Trichy Rockfort Silhouette & Low Blue Ridge -->
  <path d="M 0,390 Q 300,340 600,370 T 1200,350 T 1800,375 L 1920,380 L 1920,720 L 0,720 Z" fill="#60a5fa" opacity="0.45"/>
  <!-- Distant Rockfort Outcrop Silhouette in Distance -->
  <path d="M 720,360 L 750,290 L 780,275 L 810,290 L 840,360 Z" fill="#3b82f6" opacity="0.5"/>
  <!-- Far Emerald Paddy Terraces -->
  <path d="M 0,440 Q 360,395 720,425 T 1440,410 T 1920,430 L 1920,720 L 0,720 Z" fill="url(#paddyFar)" opacity="0.8"/>
  <!-- Mid Fertile River Fields & Tamarind Tree Horizons -->
  <path d="M 0,500 Q 280,465 560,485 T 1120,470 T 1680,490 T 1920,485 L 1920,720 L 0,720 Z" fill="url(#paddyMid)" opacity="0.9"/>
  <!-- Foreground Alluvial Riverbanks -->
  <path d="M 0,560 Q 380,530 760,545 T 1520,535 T 1920,555 L 1920,720 L 0,720 Z" fill="#14532d"/>
</svg>"""

# 6. Zone 6 (950-1200m): Coromandel Coast & Chennai Approach (1920x720)
svg_bg_06 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="sky06" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="50%" stop-color="#38bdf8"/>
      <stop offset="85%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#e0f2fe"/>
    </linearGradient>
    <linearGradient id="seaCoast" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0369a1"/>
      <stop offset="100%" stop-color="#0284c7"/>
    </linearGradient>
    <linearGradient id="sandCoast" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#fef08a"/>
      <stop offset="100%" stop-color="#fde047"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#sky06)"/>
  <!-- Coastal Marine Sky Clouds -->
  <path d="M 180,130 Q 340,115 500,128 Q 360,145 180,130 Z" fill="#ffffff" opacity="0.7"/>
  <path d="M 860,140 Q 1020,125 1200,138 Q 1040,155 860,140 Z" fill="#ffffff" opacity="0.65"/>
  <path d="M 1480,120 Q 1640,105 1820,118 Q 1660,135 1480,120 Z" fill="#ffffff" opacity="0.75"/>
  <!-- Bay of Bengal Azure Seascape Horizon -->
  <rect x="0" y="350" width="1920" height="110" fill="url(#seaCoast)"/>
  <path d="M 0,460 L 1920,460" stroke="#ffffff" stroke-width="2.5" stroke-dasharray="40 20" opacity="0.7"/>
  <!-- Chennai Distant Skyline & Harbor Silhouettes on Horizon -->
  <path d="M 640,350 L 640,320 L 660,320 L 660,350 Z" fill="#1e293b" opacity="0.55"/>
  <path d="M 670,350 L 670,305 L 705,305 L 705,350 Z" fill="#334155" opacity="0.6"/>
  <path d="M 715,350 L 715,330 L 735,330 L 735,350 Z" fill="#1e293b" opacity="0.55"/>
  <!-- Marina Lighthouse Silhouette -->
  <path d="M 1360,350 L 1366,280 L 1374,280 L 1380,350 Z" fill="#0f172a" opacity="0.65"/>
  <!-- Casuarina Coastal Grove Belts -->
  <path d="M 0,460 Q 280,425 560,445 T 1120,435 T 1680,450 T 1920,440 L 1920,720 L 0,720 Z" fill="#15803d" opacity="0.75"/>
  <!-- Marina Beach Golden Sand Verge -->
  <path d="M 0,520 Q 360,485 720,505 T 1440,495 T 1920,515 L 1920,720 L 0,720 Z" fill="#eab308" opacity="0.65"/>
  <path d="M 0,580 Q 300,550 600,565 T 1200,555 T 1800,570 L 1920,565 L 1920,720 L 0,720 Z" fill="#ca8a04"/>
</svg>"""

# ----------------- MIDGROUND PANORAMAS (1920x360) -----------------

# Mid 1: Coastal Coconut Palms & Catamarans (1920x360)
svg_mid_01 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <!-- Coastal dunes and palm grove belt with clear sky transparency -->
  <path d="M 0,220 Q 320,180 640,205 T 1280,195 T 1920,215 L 1920,360 L 0,360 Z" fill="#15803d" opacity="0.75"/>
  <!-- Curving coconut palm crowns -->
  <g fill="#166534">
    <path d="M 180,210 Q 200,120 250,90 Q 220,130 200,210 Z"/>
    <circle cx="255" cy="85" r="28" fill="#15803d"/>
    <path d="M 520,200 Q 540,110 590,80 Q 560,120 540,200 Z"/>
    <circle cx="595" cy="75" r="26" fill="#15803d"/>
    <path d="M 980,205 Q 1000,115 1050,85 Q 1020,125 1000,205 Z"/>
    <circle cx="1055" cy="80" r="28" fill="#15803d"/>
    <path d="M 1420,195 Q 1440,105 1490,75 Q 1460,115 1440,195 Z"/>
    <circle cx="1495" cy="70" r="26" fill="#15803d"/>
    <path d="M 1780,215 Q 1800,125 1850,95 Q 1820,135 1800,215 Z"/>
    <circle cx="1855" cy="90" r="28" fill="#15803d"/>
  </g>
  <path d="M 0,270 Q 360,240 720,260 T 1440,250 T 1920,265 L 1920,360 L 0,360 Z" fill="#14532d"/>
</svg>"""

# Mid 2: Thamirabarani River & Red Laterite Plains (1920x360)
svg_mid_02 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <path d="M 0,210 Q 380,175 760,195 T 1520,185 T 1920,205 L 1920,360 L 0,360 Z" fill="#9a3412" opacity="0.8"/>
  <!-- Tall Palmyra Palm silhouettes -->
  <g fill="#451a03">
    <rect x="240" y="90" width="6" height="130" rx="3"/>
    <circle cx="243" cy="85" r="22"/>
    <rect x="680" y="80" width="6" height="140" rx="3"/>
    <circle cx="683" cy="75" r="24"/>
    <rect x="1140" y="95" width="6" height="125" rx="3"/>
    <circle cx="1143" cy="90" r="20"/>
    <rect x="1580" y="85" width="6" height="135" rx="3"/>
    <circle cx="1583" cy="80" r="23"/>
  </g>
  <path d="M 0,265 Q 320,235 640,255 T 1280,245 T 1920,260 L 1920,360 L 0,360 Z" fill="#78350f"/>
</svg>"""

# Mid 3: Melur Granite Boulders & Acacia Scrub (1920x360)
svg_mid_03 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <!-- Rounded Granite Boulders -->
  <ellipse cx="280" cy="220" rx="90" ry="50" fill="#64748b"/>
  <ellipse cx="380" cy="235" rx="70" ry="40" fill="#475569"/>
  <ellipse cx="920" cy="210" rx="110" ry="60" fill="#64748b"/>
  <ellipse cx="1040" cy="230" rx="80" ry="45" fill="#475569"/>
  <ellipse cx="1560" cy="215" rx="95" ry="55" fill="#64748b"/>
  <!-- Ground contour -->
  <path d="M 0,235 Q 340,205 680,225 T 1360,215 T 1920,230 L 1920,360 L 0,360 Z" fill="#52525b" opacity="0.85"/>
  <path d="M 0,280 Q 300,255 600,270 T 1200,260 T 1800,275 L 1920,270 L 1920,360 L 0,360 Z" fill="#27272a"/>
</svg>"""

# Mid 4: Cauvery Lush Paddy Terraces & Banyan Trees (1920x360)
svg_mid_04 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <path d="M 0,210 Q 360,180 720,200 T 1440,190 T 1920,205 L 1920,360 L 0,360 Z" fill="#16a34a" opacity="0.8"/>
  <!-- Sprawling Banyan Tree Canopies -->
  <g fill="#14532d">
    <ellipse cx="320" cy="150" rx="75" ry="45"/>
    <rect x="315" y="165" width="10" height="60" rx="3"/>
    <ellipse cx="980" cy="140" rx="85" ry="50"/>
    <rect x="975" y="155" width="12" height="65" rx="4"/>
    <ellipse cx="1620" cy="145" rx="80" ry="48"/>
    <rect x="1615" y="160" width="11" height="60" rx="3"/>
  </g>
  <path d="M 0,260 Q 320,230 640,250 T 1280,240 T 1920,255 L 1920,360 L 0,360 Z" fill="#15803d"/>
</svg>"""

# Mid 5: Coromandel Dunes & Casuarina Belts (1920x360)
svg_mid_05 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <path d="M 0,225 Q 340,195 680,215 T 1360,205 T 1920,220 L 1920,360 L 0,360 Z" fill="#15803d" opacity="0.75"/>
  <!-- Casuarina pine-like needle tree silhouettes -->
  <g fill="#166534">
    <polygon points="220,110 205,210 235,210"/>
    <polygon points="245,100 230,210 260,210"/>
    <polygon points="760,105 745,215 775,215"/>
    <polygon points="785,95 770,215 800,215"/>
    <polygon points="1320,110 1305,210 1335,210"/>
    <polygon points="1345,100 1330,210 1360,210"/>
    <polygon points="1740,105 1725,215 1755,215"/>
    <polygon points="1765,95 1750,215 1780,215"/>
  </g>
  <path d="M 0,270 Q 380,245 760,260 T 1520,250 T 1920,265 L 1920,360 L 0,360 Z" fill="#ca8a04"/>
</svg>"""

backgrounds = [
    ("tamil_nadu_bg_01_cape_comorin", svg_bg_01, "distant_landscape"),
    ("tamil_nadu_bg_02_western_ghats", svg_bg_02, "distant_landscape"),
    ("tamil_nadu_bg_03_palmyra_plains", svg_bg_03, "distant_landscape"),
    ("tamil_nadu_bg_04_granite_hills", svg_bg_04, "distant_landscape"),
    ("tamil_nadu_bg_05_cauvery_paddy", svg_bg_05, "distant_landscape"),
    ("tamil_nadu_bg_06_coromandel_coast", svg_bg_06, "distant_landscape"),
    ("tamil_nadu_mid_01_coastal_groves", svg_mid_01, "midground"),
    ("tamil_nadu_mid_02_thamirabarani_plains", svg_mid_02, "midground"),
    ("tamil_nadu_mid_03_palmyra_countryside", svg_mid_03, "midground"),
    ("tamil_nadu_mid_04_granite_boulders", svg_mid_04, "midground"),
    ("tamil_nadu_mid_05_coromandel_suburb", svg_mid_05, "midground"),
]

for name, svg_data, subfolder in backgrounds:
    svg_path = f"{OUT_DIR}/{subfolder}/{name}.svg"
    png_path = f"{OUT_DIR}/{subfolder}/{name}.png"
    with open(svg_path, "w") as fp:
        fp.write(svg_data)
    subprocess.run(["ffmpeg", "-y", "-i", svg_path, png_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Generated {png_path}")

print("All Tamil Nadu regional backgrounds generated successfully!")
