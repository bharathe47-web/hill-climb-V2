import os
import subprocess

OUT_DIR = "assets/indian_locations/tamil_nadu/backgrounds/midground"
os.makedirs(OUT_DIR, exist_ok=True)

def create_mid(name, svg_content):
    svg_path = f"{OUT_DIR}/{name}.svg"
    png_path = f"{OUT_DIR}/{name}.png"
    with open(svg_path, "w") as fp:
        fp.write(svg_content.strip())
    res = subprocess.run(["ffmpeg", "-y", "-i", svg_path, png_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if res.returncode == 0:
        print(f"Generated {png_path} ({os.path.getsize(png_path)} bytes)")
    else:
        print(f"Error generating {png_path}")

# Mid 1: Coastal Groves & Dunes (Kanyakumari)
svg_mid_01 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <path d="M 0,220 Q 340,185 680,205 T 1360,195 T 1920,210 L 1920,360 L 0,360 Z" fill="#ca8a04" opacity="0.6"/>
  <!-- Curved Coastal Coconut Palms -->
  <g fill="#15803d">
    <path d="M 180,210 Q 200,110 250,80 Q 220,120 200,210 Z" fill="#78350f"/>
    <circle cx="255" cy="75" r="28"/>
    <path d="M 540,215 Q 520,115 470,85 Q 500,125 520,215 Z" fill="#78350f"/>
    <circle cx="465" cy="80" r="26"/>
    <path d="M 1080,210 Q 1100,110 1150,80 Q 1120,120 1100,210 Z" fill="#78350f"/>
    <circle cx="1155" cy="75" r="28"/>
    <path d="M 1520,215 Q 1500,115 1450,85 Q 1480,125 1500,215 Z" fill="#78350f"/>
    <circle cx="1445" cy="80" r="26"/>
  </g>
  <path d="M 0,270 Q 360,240 720,260 T 1440,250 T 1920,265 L 1920,360 L 0,360 Z" fill="#15803d"/>
</svg>"""

# Mid 2: Countryside Greenery & Village Huts (Nagercoil, Tirunelveli)
svg_mid_02 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <path d="M 0,210 Q 380,175 760,195 T 1520,185 T 1920,205 L 1920,360 L 0,360 Z" fill="#16a34a" opacity="0.75"/>
  <!-- Village huts & banana groves -->
  <g fill="#b45309">
    <rect x="380" y="180" width="35" height="25"/>
    <polygon points="375,180 397,160 420,180" fill="#991b1b"/>
    <rect x="1180" y="185" width="40" height="25"/>
    <polygon points="1175,185 1200,165 1225,185" fill="#991b1b"/>
  </g>
  <!-- Banana canopies -->
  <g fill="#22c55e">
    <circle cx="340" cy="185" r="22"/>
    <circle cx="450" cy="180" r="25"/>
    <circle cx="1140" cy="185" r="22"/>
    <circle cx="1260" cy="180" r="26"/>
  </g>
  <path d="M 0,260 Q 320,230 640,250 T 1280,240 T 1920,255 L 1920,360 L 0,360 Z" fill="#15803d"/>
</svg>"""

# Mid 3: Palmyra Scrub & Red Soil (Kovilpatti, Virudhunagar)
svg_mid_03 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <path d="M 0,215 Q 380,180 760,200 T 1520,190 T 1920,210 L 1920,360 L 0,360 Z" fill="#9a3412" opacity="0.8"/>
  <!-- Iconic tall fan-topped Palmyra Palms -->
  <g fill="#451a03">
    <rect x="240" y="70" width="6" height="150" rx="3"/>
    <circle cx="243" cy="65" r="22"/>
    <rect x="680" y="60" width="6" height="160" rx="3"/>
    <circle cx="683" cy="55" r="24"/>
    <rect x="1140" y="75" width="6" height="145" rx="3"/>
    <circle cx="1143" cy="70" r="20"/>
    <rect x="1580" y="65" width="6" height="155" rx="3"/>
    <circle cx="1583" cy="60" r="23"/>
  </g>
  <path d="M 0,265 Q 320,235 640,255 T 1280,245 T 1920,260 L 1920,360 L 0,360 Z" fill="#78350f"/>
</svg>"""

# Mid 4: Granite Boulders & Acacia (Madurai, Melur, Trichy)
svg_mid_04 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <!-- Rounded Granite Boulders -->
  <ellipse cx="280" cy="210" rx="90" ry="50" fill="#64748b"/>
  <ellipse cx="380" cy="225" rx="70" ry="40" fill="#475569"/>
  <ellipse cx="920" cy="200" rx="110" ry="60" fill="#64748b"/>
  <ellipse cx="1040" cy="220" rx="80" ry="45" fill="#475569"/>
  <ellipse cx="1560" cy="205" rx="95" ry="55" fill="#64748b"/>
  <path d="M 0,235 Q 340,205 680,225 T 1360,215 T 1920,230 L 1920,360 L 0,360 Z" fill="#52525b" opacity="0.85"/>
  <path d="M 0,280 Q 300,255 600,270 T 1200,260 T 1800,275 L 1920,270 L 1920,360 L 0,360 Z" fill="#27272a"/>
</svg>"""

# Mid 5: Paddy Terraces & Banyan Trees (Perambalur, Villupuram, Tindivanam, Chengalpattu)
svg_mid_05 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <path d="M 0,210 Q 360,180 720,200 T 1440,190 T 1920,205 L 1920,360 L 0,360 Z" fill="#16a34a" opacity="0.8"/>
  <!-- Sprawling Banyan Trees -->
  <g fill="#14532d">
    <ellipse cx="320" cy="140" rx="75" ry="45"/>
    <rect x="315" y="155" width="10" height="70" rx="3"/>
    <ellipse cx="980" cy="130" rx="85" ry="50"/>
    <rect x="975" y="145" width="12" height="75" rx="4"/>
    <ellipse cx="1620" cy="135" rx="80" ry="48"/>
    <rect x="1615" y="150" width="11" height="70" rx="3"/>
  </g>
  <path d="M 0,260 Q 320,230 640,250 T 1280,240 T 1920,255 L 1920,360 L 0,360 Z" fill="#15803d"/>
</svg>"""

# Mid 6: Urban Suburb & Highway Viaduct (Chennai)
svg_mid_06 = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 360" width="1920" height="360">
  <path d="M 0,220 Q 340,190 680,210 T 1360,200 T 1920,215 L 1920,360 L 0,360 Z" fill="#334155" opacity="0.85"/>
  <!-- Suburban buildings & modern streetlight poles -->
  <g fill="#1e293b">
    <rect x="160" y="140" width="50" height="90"/>
    <rect x="230" y="120" width="70" height="110"/>
    <rect x="740" y="130" width="60" height="100"/>
    <rect x="820" y="110" width="80" height="120"/>
    <rect x="1340" y="135" width="65" height="95"/>
    <rect x="1430" y="115" width="75" height="115"/>
  </g>
  <!-- Viaduct piers -->
  <g fill="#475569">
    <rect x="420" y="160" width="20" height="80"/>
    <rect x="580" y="160" width="20" height="80"/>
    <rect x="1060" y="160" width="20" height="80"/>
    <rect x="1220" y="160" width="20" height="80"/>
    <rect x="1680" y="160" width="20" height="80"/>
    <rect x="1840" y="160" width="20" height="80"/>
  </g>
  <!-- Streetlight poles -->
  <g stroke="#94a3b8" stroke-width="2.5" fill="none">
    <path d="M 290,220 L 290,140 Q 290,130 305,130"/>
    <path d="M 870,220 L 870,135 Q 870,125 885,125"/>
    <path d="M 1480,220 L 1480,138 Q 1480,128 1495,128"/>
  </g>
  <path d="M 0,265 Q 360,240 720,255 T 1440,245 T 1920,260 L 1920,360 L 0,360 Z" fill="#0f172a"/>
</svg>"""

create_mid("tamil_nadu_mid_01_coastal_groves", svg_mid_01)
create_mid("tamil_nadu_mid_02_countryside_green", svg_mid_02)
create_mid("tamil_nadu_mid_03_palmyra_scrub", svg_mid_03)
create_mid("tamil_nadu_mid_04_granite_boulders", svg_mid_04)
create_mid("tamil_nadu_mid_05_paddy_terraces", svg_mid_05)
create_mid("tamil_nadu_mid_06_urban_corridor", svg_mid_06)

print("All Tamil Nadu midgrounds generated successfully!")
