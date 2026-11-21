import subprocess

# 1. Thar Desert (Rajasthan) - 1920 x 720
svg_rajasthan = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="dSky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#fdba74"/>
      <stop offset="45%" stop-color="#fed7aa"/>
      <stop offset="100%" stop-color="#ffedd5"/>
    </linearGradient>
    <linearGradient id="farDune" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ea580c"/>
      <stop offset="100%" stop-color="#c2410c"/>
    </linearGradient>
    <linearGradient id="midDune" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#f59e0b"/>
      <stop offset="100%" stop-color="#d97706"/>
    </linearGradient>
    <linearGradient id="nearDune" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#fbbf24"/>
      <stop offset="100%" stop-color="#f59e0b"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#dSky)"/>
  <!-- Distant Desert Sun -->
  <circle cx="1400" cy="220" r="85" fill="#fef08a" opacity="0.85"/>
  <circle cx="1400" cy="220" r="110" fill="#fde047" opacity="0.3"/>
  <!-- Far Sand Dunes -->
  <path d="M 0,380 Q 320,290 640,360 T 1280,330 T 1920,370 L 1920,720 L 0,720 Z" fill="url(#farDune)" opacity="0.7"/>
  <!-- Mid Sand Dunes -->
  <path d="M 0,440 Q 400,360 800,430 T 1600,410 T 1920,450 L 1920,720 L 0,720 Z" fill="url(#midDune)" opacity="0.85"/>
  <!-- Near Rolling Dunes & Arid Shrubs -->
  <path d="M 0,510 Q 350,440 700,500 T 1400,480 T 1920,520 L 1920,720 L 0,720 Z" fill="url(#nearDune)"/>
</svg>"""

# 2. Rann of Kutch (Gujarat) - 1920 x 720
svg_gujarat = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="gSky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#93c5fd"/>
      <stop offset="60%" stop-color="#e0f2fe"/>
      <stop offset="100%" stop-color="#f8fafc"/>
    </linearGradient>
    <linearGradient id="saltFar" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#cbd5e1"/>
      <stop offset="100%" stop-color="#e2e8f0"/>
    </linearGradient>
    <linearGradient id="saltWhite" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#f8fafc"/>
      <stop offset="50%" stop-color="#ffffff"/>
      <stop offset="100%" stop-color="#f1f5f9"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#gSky)"/>
  <!-- Shimmering Salt Mirage Line -->
  <rect x="0" y="380" width="1920" height="40" fill="#bae6fd" opacity="0.4"/>
  <!-- Far Salt Bed Flat -->
  <path d="M 0,400 Q 480,395 960,400 T 1920,400 L 1920,720 L 0,720 Z" fill="url(#saltFar)"/>
  <!-- White Desert Crystal Expanse -->
  <path d="M 0,460 Q 320,450 640,460 T 1280,455 T 1920,460 L 1920,720 L 0,720 Z" fill="url(#saltWhite)"/>
  <!-- Salt Ridge Formations -->
  <path d="M 0,540 Q 400,525 800,535 T 1600,530 T 1920,540 L 1920,720 L 0,720 Z" fill="#e2e8f0" opacity="0.7"/>
</svg>"""

# 3. Deccan Plateau (Telangana) - 1920 x 720
svg_telangana = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="tSky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#38bdf8"/>
      <stop offset="50%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#f0f9ff"/>
    </linearGradient>
    <linearGradient id="farHills" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#475569"/>
      <stop offset="100%" stop-color="#334155"/>
    </linearGradient>
    <linearGradient id="graniteTor" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#64748b"/>
      <stop offset="100%" stop-color="#475569"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#tSky)"/>
  <!-- Distant Deccan Ridge -->
  <path d="M 0,340 L 180,300 L 320,330 L 460,280 L 680,350 L 920,290 L 1150,330 L 1380,270 L 1600,340 L 1780,300 L 1920,330 L 1920,720 L 0,720 Z" fill="url(#farHills)" opacity="0.65"/>
  <!-- Granite Boulder Hills & Formations -->
  <path d="M 0,420 Q 200,360 400,410 T 800,380 T 1200,420 T 1600,370 T 1920,410 L 1920,720 L 0,720 Z" fill="url(#graniteTor)" opacity="0.85"/>
  <!-- Fore-plateau Plateau Crags -->
  <path d="M 0,490 Q 280,440 560,480 T 1120,460 T 1680,490 T 1920,480 L 1920,720 L 0,720 Z" fill="#334155"/>
</svg>"""

# 4. Tamil Nadu Coastline & Palm Horizon - 1920 x 720
svg_tn_coast = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="tnSky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="50%" stop-color="#38bdf8"/>
      <stop offset="100%" stop-color="#e0f2fe"/>
    </linearGradient>
    <linearGradient id="ocean" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0369a1"/>
      <stop offset="100%" stop-color="#0284c7"/>
    </linearGradient>
    <linearGradient id="palmGreen" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#15803d"/>
      <stop offset="100%" stop-color="#166534"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#tnSky)"/>
  <!-- Ocean Seascape Line -->
  <rect x="0" y="320" width="1920" height="150" fill="url(#ocean)"/>
  <!-- Surf Horizon -->
  <line x1="0" y1="465" x2="1920" y2="465" stroke="#ffffff" stroke-width="3" stroke-dasharray="30 15" opacity="0.7"/>
  <!-- Coastal Coconut Palm Grove Silhouette -->
  <path d="M 0,460 Q 240,430 480,450 T 960,435 T 1440,450 T 1920,440 L 1920,720 L 0,720 Z" fill="url(#palmGreen)" opacity="0.85"/>
  <path d="M 0,520 Q 320,490 640,510 T 1280,500 T 1920,515 L 1920,720 L 0,720 Z" fill="#14532d"/>
</svg>"""

# 5. Rural Plains (Agricultural Fields & Groves) - 1920 x 720
svg_rural_plains = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 720" width="1920" height="720">
  <defs>
    <linearGradient id="rSky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#38bdf8"/>
      <stop offset="55%" stop-color="#bae6fd"/>
      <stop offset="100%" stop-color="#f0fdf4"/>
    </linearGradient>
    <linearGradient id="farField" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#84cc16"/>
      <stop offset="100%" stop-color="#65a30d"/>
    </linearGradient>
    <linearGradient id="midField" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#eab308"/>
      <stop offset="100%" stop-color="#ca8a04"/>
    </linearGradient>
    <linearGradient id="nearField" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#22c55e"/>
      <stop offset="100%" stop-color="#15803d"/>
    </linearGradient>
  </defs>
  <rect width="1920" height="720" fill="url(#rSky)"/>
  <!-- Clouds -->
  <ellipse cx="400" cy="180" rx="140" ry="40" fill="#ffffff" opacity="0.75"/>
  <ellipse cx="460" cy="160" rx="100" ry="45" fill="#ffffff" opacity="0.85"/>
  <ellipse cx="1300" cy="150" rx="180" ry="45" fill="#ffffff" opacity="0.7"/>
  <ellipse cx="1380" cy="130" rx="120" ry="50" fill="#ffffff" opacity="0.8"/>
  <!-- Distant Blue Ridge Hills -->
  <path d="M 0,360 Q 300,310 600,345 T 1200,320 T 1800,350 L 1920,355 L 1920,720 L 0,720 Z" fill="#93c5fd" opacity="0.5"/>
  <!-- Far Agricultural Fields -->
  <path d="M 0,420 Q 380,370 760,405 T 1520,390 T 1920,415 L 1920,720 L 0,720 Z" fill="url(#farField)" opacity="0.8"/>
  <!-- Mid Mustard / Wheat Gold Patches -->
  <path d="M 0,480 Q 280,440 560,470 T 1120,450 T 1680,475 T 1920,470 L 1920,720 L 0,720 Z" fill="url(#midField)" opacity="0.85"/>
  <!-- Lush Green Foreground Plains -->
  <path d="M 0,540 Q 360,500 720,530 T 1440,515 T 1920,535 L 1920,720 L 0,720 Z" fill="url(#nearField)"/>
</svg>"""

backgrounds = [
    ("indian_parallax_thar_desert", svg_rajasthan),
    ("indian_parallax_rann_kutch", svg_gujarat),
    ("indian_parallax_deccan_plateau", svg_telangana),
    ("indian_parallax_tamil_nadu_coast", svg_tn_coast),
    ("indian_parallax_rural_plains", svg_rural_plains)
]

for name, svg_data in backgrounds:
    svg_path = f"assets/indian_roads/{name}.svg"
    png_path = f"assets/indian_roads/{name}.png"
    with open(svg_path, "w") as fp:
        fp.write(svg_data)
    subprocess.run(["ffmpeg", "-y", "-i", svg_path, png_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Generated {name}.png (1920x720 HD)")
