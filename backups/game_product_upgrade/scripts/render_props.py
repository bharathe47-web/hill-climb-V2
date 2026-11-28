import os, subprocess, shutil

# 1. NH44 Highway Sign (512 x 640)
svg_sign = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 640" width="512" height="640">
  <defs>
    <filter id="shadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="6" stdDeviation="4" flood-color="#000" flood-opacity="0.35"/>
    </filter>
    <linearGradient id="pole" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#4a5568"/>
      <stop offset="50%" stop-color="#cbd5e1"/>
      <stop offset="100%" stop-color="#334155"/>
    </linearGradient>
    <linearGradient id="signBg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="100%" stop-color="#0369a1"/>
    </linearGradient>
    <linearGradient id="nhPlate" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#fef08a"/>
      <stop offset="100%" stop-color="#eab308"/>
    </linearGradient>
  </defs>
  <!-- Steel Pole -->
  <rect x="238" y="240" width="36" height="390" fill="url(#pole)" rx="4"/>
  <rect x="226" y="620" width="60" height="16" fill="#1e293b" rx="3"/>
  <!-- Main Signboard -->
  <g filter="url(#shadow)">
    <rect x="36" y="30" width="440" height="280" rx="16" fill="#0f172a" stroke="#ffffff" stroke-width="6"/>
    <rect x="44" y="38" width="424" height="264" rx="12" fill="url(#signBg)"/>
    <!-- Yellow NH Crest -->
    <rect x="186" y="56" width="140" height="74" rx="10" fill="url(#nhPlate)" stroke="#ffffff" stroke-width="3"/>
    <text x="256" y="90" font-family="Arial, sans-serif" font-weight="900" font-size="24" fill="#0f172a" text-anchor="middle">NATIONAL HIGHWAY</text>
    <text x="256" y="122" font-family="Arial, sans-serif" font-weight="900" font-size="34" fill="#0f172a" text-anchor="middle">NH 44</text>
    <!-- Route Information -->
    <line x1="60" y1="148" x2="452" y2="148" stroke="#ffffff" stroke-width="3" stroke-dasharray="8 6"/>
    <text x="70" y="195" font-family="Arial, sans-serif" font-weight="800" font-size="28" fill="#ffffff">MADURAI</text>
    <text x="442" y="195" font-family="Arial, sans-serif" font-weight="800" font-size="28" fill="#facc15" text-anchor="end">750 m</text>
    <text x="70" y="245" font-family="Arial, sans-serif" font-weight="800" font-size="28" fill="#ffffff">CHENNAI</text>
    <text x="442" y="245" font-family="Arial, sans-serif" font-weight="800" font-size="28" fill="#facc15" text-anchor="end">1800 m</text>
    <text x="256" y="285" font-family="Arial, sans-serif" font-weight="bold" font-size="18" fill="#93c5fd" text-anchor="middle">SPEED LIMIT 80 km/h</text>
  </g>
</svg>"""

# 2. Authentic Indian NH Milestone (512 x 680)
svg_milestone = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 680" width="512" height="680">
  <defs>
    <filter id="mShadow" x="-10%" y="-5%" width="120%" height="110%">
      <feDropShadow dx="4" dy="8" stdDeviation="6" flood-color="#000" flood-opacity="0.3"/>
    </filter>
    <linearGradient id="stoneBody" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#e2e8f0"/>
      <stop offset="40%" stop-color="#ffffff"/>
      <stop offset="100%" stop-color="#cbd5e1"/>
    </linearGradient>
    <linearGradient id="nhYellowDome" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#ca8a04"/>
      <stop offset="35%" stop-color="#facc15"/>
      <stop offset="100%" stop-color="#a16207"/>
    </linearGradient>
  </defs>
  <!-- Chiseled Plinth Base -->
  <polygon points="60,650 452,650 432,600 80,600" fill="#64748b"/>
  <!-- Milestone Body -->
  <g filter="url(#mShadow)">
    <!-- White Concrete Pillar -->
    <path d="M 96,600 L 96,220 Q 96,60 256,60 Q 416,60 416,220 L 416,600 Z" fill="url(#stoneBody)" stroke="#94a3b8" stroke-width="4"/>
    <!-- Yellow Semicircular Dome (Official IRC NH color standard) -->
    <path d="M 96,220 Q 96,60 256,60 Q 416,60 416,220 Z" fill="url(#nhYellowDome)"/>
    <!-- Black NH Designation on Dome -->
    <text x="256" y="145" font-family="Arial, sans-serif" font-weight="900" font-size="34" fill="#0f172a" text-anchor="middle">NH</text>
    <text x="256" y="195" font-family="Arial, sans-serif" font-weight="900" font-size="44" fill="#0f172a" text-anchor="middle">44</text>
    <!-- Dividing Ring -->
    <line x1="96" y1="220" x2="416" y2="220" stroke="#0f172a" stroke-width="6"/>
    <!-- Milestone Lettering -->
    <text x="256" y="280" font-family="Arial, sans-serif" font-weight="900" font-size="36" fill="#0f172a" text-anchor="middle">CHENNAI</text>
    <text x="256" y="350" font-family="Arial, sans-serif" font-weight="900" font-size="54" fill="#0f172a" text-anchor="middle">18</text>
    <line x1="140" y1="390" x2="372" y2="390" stroke="#94a3b8" stroke-width="3"/>
    <text x="256" y="445" font-family="Arial, sans-serif" font-weight="900" font-size="32" fill="#334155" text-anchor="middle">MADURAI</text>
    <text x="256" y="505" font-family="Arial, sans-serif" font-weight="900" font-size="46" fill="#334155" text-anchor="middle">7.5</text>
    <text x="256" y="565" font-family="Arial, sans-serif" font-weight="bold" font-size="22" fill="#64748b" text-anchor="middle">KANYAKUMARI</text>
  </g>
</svg>"""

# 3. Heavy Construction Hazard Barricade (640 x 240)
svg_barricade = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 240" width="640" height="240">
  <defs>
    <filter id="bShadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="5" stdDeviation="4" flood-color="#000" flood-opacity="0.3"/>
    </filter>
    <pattern id="stripes" width="40" height="40" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
      <rect width="20" height="40" fill="#facc15"/>
      <rect x="20" width="20" height="40" fill="#1e293b"/>
    </pattern>
    <linearGradient id="leg" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#475569"/>
      <stop offset="50%" stop-color="#94a3b8"/>
      <stop offset="100%" stop-color="#334155"/>
    </linearGradient>
  </defs>
  <!-- A-Frame Legs -->
  <polygon points="60,230 90,230 115,50 85,50" fill="url(#leg)"/>
  <polygon points="140,230 110,230 85,50 115,50" fill="url(#leg)"/>
  <polygon points="500,230 530,230 555,50 525,50" fill="url(#leg)"/>
  <polygon points="580,230 550,230 525,50 555,50" fill="url(#leg)"/>
  <rect x="50" y="222" width="100" height="12" fill="#1e293b" rx="3"/>
  <rect x="490" y="222" width="100" height="12" fill="#1e293b" rx="3"/>
  <!-- Cross Barrels with Hazard Pattern -->
  <g filter="url(#bShadow)">
    <!-- Top Hazard Rail -->
    <rect x="20" y="45" width="600" height="55" rx="6" fill="url(#stripes)" stroke="#0f172a" stroke-width="4"/>
    <!-- Bottom Hazard Rail -->
    <rect x="20" y="125" width="600" height="55" rx="6" fill="url(#stripes)" stroke="#0f172a" stroke-width="4"/>
    <!-- Warning Light Flasher on Top -->
    <circle cx="320" cy="22" r="18" fill="#ea580c" stroke="#fed7aa" stroke-width="3"/>
    <circle cx="320" cy="22" r="8" fill="#fef08a"/>
    <rect x="310" y="38" width="20" height="8" fill="#334155"/>
  </g>
</svg>"""

# 4. Highway Jersey Concrete Crash Barrier (800 x 240)
svg_guardrail = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 240" width="800" height="240">
  <defs>
    <filter id="gShadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="6" stdDeviation="5" flood-color="#000" flood-opacity="0.35"/>
    </filter>
    <linearGradient id="concrete" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#94a3b8"/>
      <stop offset="15%" stop-color="#cbd5e1"/>
      <stop offset="70%" stop-color="#94a3b8"/>
      <stop offset="100%" stop-color="#64748b"/>
    </linearGradient>
  </defs>
  <g filter="url(#gShadow)">
    <!-- Segment 1 -->
    <polygon points="20,230 380,230 365,150 350,50 50,50 35,150" fill="url(#concrete)" stroke="#475569" stroke-width="3"/>
    <!-- Top Cap -->
    <rect x="50" y="45" width="300" height="15" fill="#e2e8f0" rx="3"/>
    <!-- Expansion Joint -->
    <rect x="375" y="40" width="10" height="195" fill="#334155"/>
    <!-- Segment 2 -->
    <polygon points="400,230 780,230 765,150 750,50 430,50 415,150" fill="url(#concrete)" stroke="#475569" stroke-width="3"/>
    <!-- Top Cap -->
    <rect x="430" y="45" width="320" height="15" fill="#e2e8f0" rx="3"/>
    <!-- Reflective Delineators (Red/White highway reflectors) -->
    <rect x="185" y="100" width="30" height="40" rx="4" fill="#dc2626" stroke="#fef2f2" stroke-width="2"/>
    <rect x="585" y="100" width="30" height="40" rx="4" fill="#facc15" stroke="#fef9c3" stroke-width="2"/>
  </g>
</svg>"""

# 5. Highway FASTag Toll Plaza Booth (720 x 600)
svg_toll = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 600" width="720" height="600">
  <defs>
    <filter id="tShadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="6" stdDeviation="6" flood-color="#000" flood-opacity="0.3"/>
    </filter>
    <linearGradient id="boothWall" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="40%" stop-color="#38bdf8"/>
      <stop offset="100%" stop-color="#0369a1"/>
    </linearGradient>
    <linearGradient id="canopy" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#f59e0b"/>
      <stop offset="100%" stop-color="#d97706"/>
    </linearGradient>
  </defs>
  <g filter="url(#tShadow)">
    <!-- Canopy Roof -->
    <polygon points="80,140 640,140 610,60 110,60" fill="url(#canopy)" stroke="#b45309" stroke-width="4"/>
    <rect x="180" y="80" width="360" height="40" rx="8" fill="#1e293b"/>
    <text x="360" y="108" font-family="Arial, sans-serif" font-weight="900" font-size="24" fill="#facc15" text-anchor="middle">FASTag TOLL PLAZA</text>
    <!-- Support Steel Columns -->
    <rect x="140" y="140" width="28" height="450" fill="#64748b"/>
    <rect x="552" y="140" width="28" height="450" fill="#64748b"/>
    <!-- Concrete Island Base -->
    <rect x="220" y="550" width="280" height="45" rx="6" fill="#475569" stroke="#cbd5e1" stroke-width="3"/>
    <!-- Toll Cabin Kiosk -->
    <rect x="250" y="240" width="220" height="310" rx="12" fill="url(#boothWall)" stroke="#075985" stroke-width="4"/>
    <!-- Operator Window -->
    <rect x="270" y="280" width="180" height="140" rx="8" fill="#e0f2fe" stroke="#0284c7" stroke-width="3"/>
    <circle cx="360" cy="340" r="28" fill="#0284c7" opacity="0.3"/>
    <!-- Countertop -->
    <rect x="240" y="420" width="240" height="18" rx="4" fill="#334155"/>
    <!-- Electronic Toll Gate Boom Barrier -->
    <rect x="470" y="440" width="220" height="14" rx="4" fill="#dc2626" stroke="#ffffff" stroke-width="3" stroke-dasharray="25 15"/>
    <!-- Lane Status Light -->
    <circle cx="360" cy="180" r="16" fill="#16a34a" stroke="#86efac" stroke-width="3"/>
  </g>
</svg>"""

# 6. Roadside Punjabi Dhaba Stall (800 x 500)
svg_dhaba = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 500" width="800" height="500">
  <defs>
    <filter id="dShadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="6" stdDeviation="5" flood-color="#000" flood-opacity="0.35"/>
    </filter>
    <linearGradient id="thatch" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#b45309"/>
      <stop offset="50%" stop-color="#d97706"/>
      <stop offset="100%" stop-color="#92400e"/>
    </linearGradient>
    <linearGradient id="brick" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#991b1b"/>
      <stop offset="50%" stop-color="#b91c1c"/>
      <stop offset="100%" stop-color="#7f1d1d"/>
    </linearGradient>
  </defs>
  <g filter="url(#dShadow)">
    <!-- Wooden Support Posts -->
    <rect x="80" y="160" width="24" height="330" fill="#78350f" rx="3"/>
    <rect x="360" y="160" width="24" height="330" fill="#78350f" rx="3"/>
    <rect x="680" y="160" width="24" height="330" fill="#78350f" rx="3"/>
    <!-- Brick Counter Wall -->
    <rect x="80" y="320" width="624" height="170" fill="url(#brick)" rx="6" stroke="#450a0a" stroke-width="4"/>
    <!-- Thatched Awning Roof -->
    <polygon points="40,200 760,200 680,90 120,90" fill="url(#thatch)" stroke="#78350f" stroke-width="4"/>
    <!-- Dhaba Signboard -->
    <rect x="180" y="40" width="440" height="70" rx="10" fill="#facc15" stroke="#78350f" stroke-width="4"/>
    <text x="400" y="86" font-family="Arial, sans-serif" font-weight="900" font-size="28" fill="#7f1d1d" text-anchor="middle">★ NH44 HIGHWAY DHABA ★</text>
    <!-- Colorful Bunting Flags -->
    <polygon points="80,200 120,240 160,200" fill="#ef4444"/>
    <polygon points="160,200 200,240 240,200" fill="#3b82f6"/>
    <polygon points="240,200 280,240 320,200" fill="#10b981"/>
    <polygon points="320,200 360,240 400,200" fill="#f59e0b"/>
    <polygon points="400,200 440,240 480,200" fill="#8b5cf6"/>
    <polygon points="480,200 520,240 560,200" fill="#ec4899"/>
    <polygon points="560,200 600,240 640,200" fill="#ef4444"/>
    <polygon points="640,200 680,240 720,200" fill="#3b82f6"/>
    <!-- Charpai (Woven Cot) in Foreground -->
    <rect x="140" y="420" width="180" height="25" rx="4" fill="#a16207" stroke="#451a03" stroke-width="3"/>
    <rect x="150" y="445" width="12" height="45" fill="#451a03"/>
    <rect x="298" y="445" width="12" height="45" fill="#451a03"/>
    <!-- Clay Tandoor Oven -->
    <ellipse cx="580" cy="380" rx="55" ry="70" fill="#92400e" stroke="#451a03" stroke-width="4"/>
    <ellipse cx="580" cy="320" rx="35" ry="15" fill="#1c1917"/>
  </g>
</svg>"""

# 7. Roadside Chai Tea Stall (600 x 500)
svg_chai = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 500" width="600" height="500">
  <defs>
    <filter id="cShadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="6" stdDeviation="4" flood-color="#000" flood-opacity="0.3"/>
    </filter>
    <linearGradient id="tarp" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="100%" stop-color="#0369a1"/>
    </linearGradient>
    <linearGradient id="brass" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#ca8a04"/>
      <stop offset="50%" stop-color="#fef08a"/>
      <stop offset="100%" stop-color="#a16207"/>
    </linearGradient>
  </defs>
  <g filter="url(#cShadow)">
    <!-- Wooden Bamboo Poles -->
    <rect x="60" y="140" width="18" height="350" fill="#78350f" rx="3"/>
    <rect x="522" y="140" width="18" height="350" fill="#78350f" rx="3"/>
    <!-- Blue Tarpaulin Slanted Canopy -->
    <polygon points="40,160 560,160 510,70 90,70" fill="url(#tarp)" stroke="#0c4a6e" stroke-width="3"/>
    <!-- Chai Sign -->
    <rect x="180" y="95" width="240" height="50" rx="8" fill="#fef08a" stroke="#ca8a04" stroke-width="3"/>
    <text x="300" y="130" font-family="Arial, sans-serif" font-weight="900" font-size="26" fill="#991b1b" text-anchor="middle">☕ GARAM CHAI</text>
    <!-- Counter Table -->
    <rect x="80" y="300" width="440" height="180" rx="6" fill="#92400e" stroke="#451a03" stroke-width="4"/>
    <rect x="70" y="290" width="460" height="20" rx="4" fill="#a16207" stroke="#451a03" stroke-width="2"/>
    <!-- Authentic Brass Chai Samovar / Kettle -->
    <ellipse cx="220" cy="240" rx="45" ry="50" fill="url(#brass)" stroke="#713f12" stroke-width="3"/>
    <rect x="205" y="180" width="30" height="20" rx="3" fill="#ca8a04"/>
    <path d="M 175,230 Q 150,210 170,195" fill="none" stroke="#713f12" stroke-width="8" stroke-linecap="round"/>
    <!-- Glass Tumbler Caddy -->
    <rect x="340" y="250" width="130" height="40" rx="4" fill="#64748b" stroke="#334155" stroke-width="2"/>
    <rect x="350" y="230" width="22" height="30" fill="#bae6fd" opacity="0.8" rx="2" stroke="#0284c7"/>
    <rect x="380" y="230" width="22" height="30" fill="#bae6fd" opacity="0.8" rx="2" stroke="#0284c7"/>
    <rect x="410" y="230" width="22" height="30" fill="#bae6fd" opacity="0.8" rx="2" stroke="#0284c7"/>
    <rect x="440" y="230" width="22" height="30" fill="#bae6fd" opacity="0.8" rx="2" stroke="#0284c7"/>
  </g>
</svg>"""

# 8. Speed Limit Sign (512 x 640)
svg_speed_limit = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 640" width="512" height="640">
  <defs>
    <filter id="slShadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="6" stdDeviation="5" flood-color="#000" flood-opacity="0.35"/>
    </filter>
    <linearGradient id="slPole" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#475569"/>
      <stop offset="50%" stop-color="#94a3b8"/>
      <stop offset="100%" stop-color="#334155"/>
    </linearGradient>
  </defs>
  <!-- Steel Pole -->
  <rect x="240" y="260" width="32" height="370" fill="url(#slPole)" rx="4"/>
  <rect x="226" y="620" width="60" height="16" fill="#1e293b" rx="3"/>
  <!-- Circular Speed Limit Sign (IRC standard) -->
  <g filter="url(#slShadow)">
    <circle cx="256" cy="180" r="160" fill="#dc2626" stroke="#991b1b" stroke-width="4"/>
    <circle cx="256" cy="180" r="126" fill="#f8fafc"/>
    <text x="256" y="215" font-family="Arial, sans-serif" font-weight="900" font-size="110" fill="#0f172a" text-anchor="middle">80</text>
    <text x="256" y="260" font-family="Arial, sans-serif" font-weight="800" font-size="22" fill="#475569" text-anchor="middle">km/h</text>
  </g>
</svg>"""

# 9. Cautionary Curve Ahead Sign (512 x 640)
svg_curve_ahead = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 640" width="512" height="640">
  <defs>
    <filter id="caShadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="6" stdDeviation="5" flood-color="#000" flood-opacity="0.35"/>
    </filter>
    <linearGradient id="caPole" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#475569"/>
      <stop offset="50%" stop-color="#94a3b8"/>
      <stop offset="100%" stop-color="#334155"/>
    </linearGradient>
  </defs>
  <!-- Steel Pole -->
  <rect x="240" y="280" width="32" height="350" fill="url(#caPole)" rx="4"/>
  <rect x="226" y="620" width="60" height="16" fill="#1e293b" rx="3"/>
  <!-- Cautionary Triangle (IRC standard) -->
  <g filter="url(#caShadow)">
    <polygon points="256,30 440,310 72,310" fill="#dc2626" stroke="#991b1b" stroke-width="4" stroke-linejoin="round"/>
    <polygon points="256,66 408,294 104,294" fill="#facc15" stroke-linejoin="round"/>
    <!-- Curve Symbol -->
    <path d="M 220,260 L 220,210 Q 220,165 270,165 Q 310,165 310,135 L 310,120 M 285,135 L 310,105 L 335,135" fill="none" stroke="#0f172a" stroke-width="22" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
</svg>"""

# 10. Cautionary Speed Breaker Sign (512 x 640)
svg_speed_breaker = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 640" width="512" height="640">
  <defs>
    <filter id="sbShadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="6" stdDeviation="5" flood-color="#000" flood-opacity="0.35"/>
    </filter>
    <linearGradient id="sbPole" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#475569"/>
      <stop offset="50%" stop-color="#94a3b8"/>
      <stop offset="100%" stop-color="#334155"/>
    </linearGradient>
  </defs>
  <!-- Steel Pole -->
  <rect x="240" y="280" width="32" height="350" fill="url(#sbPole)" rx="4"/>
  <rect x="226" y="620" width="60" height="16" fill="#1e293b" rx="3"/>
  <!-- Cautionary Triangle (IRC standard) -->
  <g filter="url(#sbShadow)">
    <polygon points="256,30 440,310 72,310" fill="#dc2626" stroke="#991b1b" stroke-width="4" stroke-linejoin="round"/>
    <polygon points="256,66 408,294 104,294" fill="#facc15" stroke-linejoin="round"/>
    <!-- Double Hump Speed Breaker Symbol -->
    <path d="M 150,235 L 180,235 Q 205,190 230,235 Q 255,190 280,235 L 360,235" fill="none" stroke="#0f172a" stroke-width="20" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
</svg>"""

# 11. Highway Traffic Cone (512 x 512)
svg_traffic_cone = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <defs>
    <filter id="coneShadow" x="-10%" y="-5%" width="120%" height="110%">
      <feDropShadow dx="0" dy="8" stdDeviation="6" flood-color="#000" flood-opacity="0.35"/>
    </filter>
    <linearGradient id="orangeGrad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#ea580c"/>
      <stop offset="35%" stop-color="#fb923c"/>
      <stop offset="100%" stop-color="#c2410c"/>
    </linearGradient>
    <linearGradient id="whiteReflect" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#cbd5e1"/>
      <stop offset="35%" stop-color="#ffffff"/>
      <stop offset="100%" stop-color="#94a3b8"/>
    </linearGradient>
    <linearGradient id="coneBase" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#334155"/>
      <stop offset="100%" stop-color="#0f172a"/>
    </linearGradient>
  </defs>
  <g filter="url(#coneShadow)">
    <!-- Heavy Rubber Base Plinth -->
    <polygon points="64,480 448,480 416,420 96,420" fill="url(#coneBase)"/>
    <!-- Conical Body Base Outer -->
    <polygon points="216,60 296,60 380,430 132,430" fill="url(#orangeGrad)"/>
    <!-- Top Tip Cap -->
    <ellipse cx="256" cy="60" rx="40" ry="12" fill="#ea580c"/>
    <ellipse cx="256" cy="56" rx="20" ry="6" fill="#1e293b"/>
    <!-- Reflective Band 1 (Top) -->
    <polygon points="200,160 312,160 326,220 186,220" fill="url(#whiteReflect)"/>
    <!-- Reflective Band 2 (Bottom) -->
    <polygon points="172,270 340,270 358,340 154,340" fill="url(#whiteReflect)"/>
  </g>
</svg>"""

# 12. Checkpoint Boom Gate (800 x 400)
svg_checkpoint_gate = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 400" width="800" height="400">
  <defs>
    <filter id="gateShadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="6" stdDeviation="5" flood-color="#000" flood-opacity="0.35"/>
    </filter>
    <pattern id="barrierStripes" width="40" height="40" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
      <rect width="20" height="40" fill="#dc2626"/>
      <rect x="20" width="20" height="40" fill="#ffffff"/>
    </pattern>
    <linearGradient id="housing" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="40%" stop-color="#38bdf8"/>
      <stop offset="100%" stop-color="#0369a1"/>
    </linearGradient>
  </defs>
  <g filter="url(#gateShadow)">
    <!-- Left Stanchion Housing Base -->
    <rect x="40" y="340" width="120" height="50" rx="8" fill="#334155" stroke="#1e293b" stroke-width="3"/>
    <!-- Left Stanchion Automatic Boom Gate Pillar -->
    <rect x="60" y="140" width="80" height="205" rx="10" fill="url(#housing)" stroke="#0284c7" stroke-width="4"/>
    <circle cx="100" cy="190" r="22" fill="#0f172a" stroke="#cbd5e1" stroke-width="4"/>
    <circle cx="100" cy="120" r="14" fill="#facc15" stroke="#eab308" stroke-width="3"/>
    <!-- Boom Barrier Gate Arm -->
    <rect x="90" y="178" width="670" height="24" rx="4" fill="url(#barrierStripes)" stroke="#1e293b" stroke-width="3"/>
    <!-- Right Stop Fork Post -->
    <rect x="710" y="240" width="40" height="150" fill="#64748b" rx="4"/>
    <rect x="690" y="220" width="80" height="24" rx="4" fill="#334155"/>
    <rect x="690" y="380" width="80" height="15" fill="#1e293b" rx="3"/>
    <!-- Red Stop Sign Disc in Middle of Barrier -->
    <circle cx="440" cy="190" r="38" fill="#dc2626" stroke="#ffffff" stroke-width="4"/>
    <text x="440" y="198" font-family="Arial, sans-serif" font-weight="900" font-size="20" fill="#ffffff" text-anchor="middle">STOP</text>
  </g>
</svg>"""

# 13. Checkpoint Banner (1200 x 200)
svg_checkpoint_banner = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 200" width="1200" height="200">
  <defs>
    <filter id="banShadow" x="-3%" y="-5%" width="106%" height="110%">
      <feDropShadow dx="0" dy="6" stdDeviation="5" flood-color="#000" flood-opacity="0.4"/>
    </filter>
    <linearGradient id="banBg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0f172a"/>
      <stop offset="100%" stop-color="#1e293b"/>
    </linearGradient>
    <pattern id="banChevron" width="30" height="30" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
      <rect width="15" height="30" fill="#facc15"/>
      <rect x="15" width="15" height="30" fill="#0f172a"/>
    </pattern>
  </defs>
  <g filter="url(#banShadow)">
    <!-- Top & Bottom Warning Hazard Strip -->
    <rect x="10" y="10" width="1180" height="18" fill="url(#banChevron)" rx="4"/>
    <rect x="10" y="172" width="1180" height="18" fill="url(#banChevron)" rx="4"/>
    <!-- Main Sign Body -->
    <rect x="10" y="28" width="1180" height="144" fill="url(#banBg)" stroke="#facc15" stroke-width="4"/>
    <!-- Emblems & Titles -->
    <rect x="30" y="46" width="108" height="108" rx="10" fill="#0284c7" stroke="#ffffff" stroke-width="3"/>
    <text x="84" y="94" font-family="Arial, sans-serif" font-weight="900" font-size="22" fill="#ffffff" text-anchor="middle">NHAI</text>
    <text x="84" y="124" font-family="Arial, sans-serif" font-weight="800" font-size="16" fill="#facc15" text-anchor="middle">TOLL</text>
    <rect x="1062" y="46" width="108" height="108" rx="10" fill="#dc2626" stroke="#ffffff" stroke-width="3"/>
    <text x="1116" y="94" font-family="Arial, sans-serif" font-weight="900" font-size="22" fill="#ffffff" text-anchor="middle">POLICE</text>
    <text x="1116" y="124" font-family="Arial, sans-serif" font-weight="800" font-size="16" fill="#fef08a" text-anchor="middle">CHECK</text>
    <!-- Text Headers -->
    <text x="600" y="82" font-family="Arial, sans-serif" font-weight="900" font-size="38" fill="#facc15" text-anchor="middle" letter-spacing="2">NATIONAL HIGHWAY TOLL PLAZA</text>
    <text x="600" y="132" font-family="Arial, sans-serif" font-weight="800" font-size="28" fill="#ffffff" text-anchor="middle" letter-spacing="1">SLOW DOWN — STOP &amp; VERIFY</text>
  </g>
</svg>"""

# 14. Finish & Destination Victory Arch (1200 x 720)
svg_finish_arch = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 720" width="1200" height="720">
  <defs>
    <filter id="archShadow" x="-5%" y="-5%" width="110%" height="110%">
      <feDropShadow dx="0" dy="8" stdDeviation="6" flood-color="#000" flood-opacity="0.35"/>
    </filter>
    <linearGradient id="pillar" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#d97706"/>
      <stop offset="30%" stop-color="#fef08a"/>
      <stop offset="70%" stop-color="#f59e0b"/>
      <stop offset="100%" stop-color="#b45309"/>
    </linearGradient>
    <linearGradient id="archTruss" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#1e293b"/>
      <stop offset="100%" stop-color="#0f172a"/>
    </linearGradient>
    <linearGradient id="tricolorOrange" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#ea580c"/>
      <stop offset="100%" stop-color="#f97316"/>
    </linearGradient>
    <linearGradient id="tricolorGreen" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#15803d"/>
      <stop offset="100%" stop-color="#22c55e"/>
    </linearGradient>
  </defs>
  <g filter="url(#archShadow)">
    <!-- Left Column Base & Pillar -->
    <rect x="80" y="660" width="160" height="50" rx="8" fill="#334155" stroke="#1e293b" stroke-width="4"/>
    <rect x="100" y="160" width="120" height="505" fill="url(#pillar)" stroke="#92400e" stroke-width="4"/>
    <rect x="80" y="140" width="160" height="30" rx="6" fill="#facc15" stroke="#92400e" stroke-width="3"/>
    <!-- Right Column Base & Pillar -->
    <rect x="960" y="660" width="160" height="50" rx="8" fill="#334155" stroke="#1e293b" stroke-width="4"/>
    <rect x="980" y="160" width="120" height="505" fill="url(#pillar)" stroke="#92400e" stroke-width="4"/>
    <rect x="960" y="140" width="160" height="30" rx="6" fill="#facc15" stroke="#92400e" stroke-width="3"/>
    <!-- Overhead Grand Arch Span Structure -->
    <rect x="60" y="60" width="1080" height="100" rx="14" fill="url(#archTruss)" stroke="#facc15" stroke-width="6"/>
    <!-- Tricolor Ribbon Accents -->
    <rect x="80" y="70" width="1040" height="12" fill="url(#tricolorOrange)" rx="2"/>
    <rect x="80" y="82" width="1040" height="10" fill="#ffffff" rx="1"/>
    <rect x="80" y="92" width="1040" height="12" fill="url(#tricolorGreen)" rx="2"/>
    <!-- Banner Header -->
    <text x="600" y="140" font-family="Arial, sans-serif" font-weight="900" font-size="34" fill="#fef08a" text-anchor="middle" letter-spacing="3">★ DESTINATION REACHED — VICTORY ★</text>
    <!-- Checkerboard Finish Bunting Across the Arch -->
    <g transform="translate(240, 160)">
      <rect x="0" y="0" width="720" height="20" fill="#ffffff" stroke="#1e293b" stroke-width="2"/>
      <rect x="0" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="60" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="120" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="180" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="240" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="300" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="360" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="420" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="480" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="540" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="600" y="0" width="30" height="20" fill="#1e293b"/>
      <rect x="660" y="0" width="30" height="20" fill="#1e293b"/>
    </g>
  </g>
</svg>"""

items = [
    ("replacement_road_sign_nh44", "indian_road_sign_nh44", svg_sign),
    ("replacement_roadside_milestone_km", "indian_roadside_milestone_km", svg_milestone),
    ("replacement_road_barricade_yellow_black", "indian_road_barricade_yellow_black", svg_barricade),
    ("replacement_guardrail_concrete", "indian_guardrail_concrete", svg_guardrail),
    ("replacement_checkpoint_toll_booth", "indian_checkpoint_toll_booth", svg_toll),
    ("replacement_roadside_dhaba_stall", "indian_roadside_dhaba_stall", svg_dhaba),
    ("replacement_roadside_tea_stall", "indian_roadside_tea_stall", svg_chai),
    ("replacement_road_sign_speed_limit", "indian_road_sign_speed_limit", svg_speed_limit),
    ("replacement_road_sign_curve_ahead", "indian_road_sign_curve_ahead", svg_curve_ahead),
    ("replacement_road_sign_speed_breaker", "indian_road_sign_speed_breaker", svg_speed_breaker),
    ("replacement_traffic_cone", "indian_traffic_cone", svg_traffic_cone),
    ("replacement_checkpoint_gate", "indian_checkpoint_gate", svg_checkpoint_gate),
    ("replacement_checkpoint_banner", "indian_checkpoint_banner", svg_checkpoint_banner),
    ("replacement_finish_arch", "indian_finish_arch", svg_finish_arch)
]

for rep_name, prod_name, svg in items:
    svg_path = f"assets/indian_roads_replacements/{rep_name}.svg"
    png_path = f"assets/indian_roads_replacements/{rep_name}.png"
    prod_png_path = f"assets/indian_roads/{prod_name}.png"
    with open(svg_path, "w") as fp:
        fp.write(svg)
    subprocess.run(["ffmpeg", "-y", "-i", svg_path, png_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    shutil.copyfile(png_path, prod_png_path)
    print(f"Rendered & Deployed: {prod_name}.png")
