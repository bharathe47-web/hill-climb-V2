# Six-State Landmark Info & Wheel Fix Verification Matrix

**Project:** Hill Climb V2 — Indian Roads  
**Engine:** Godot 4.7 (v4.7.2.stable.arch_linux.ed1daf0bf)  
**Author / Lead:** Joel (Senior Godot Developer, Technical Artist & QA Lead)  
**Date:** November 21, 2026  
**Document:** `docs/SIX_STATE_LANDMARK_INFO_TEST_MATRIX.md`  
**Git Branch:** `feature/joel-roads-obstacles`  
**Status:** **100% VERIFIED ACROSS ALL 6 STATES**

---

## 1. Verification Protocol & Acceptance Criteria

Every state route in the Indian Roads mode has been audited against four strict criteria:
1. **Landmark Data Completeness:** All regional monuments possess validated historical descriptions, locations, and cultural facts in `LandmarkCatalogueData.gd`.
2. **Bottom Card UI Presentation:** The non-intrusive card triggers upon passing the monument, displays text without truncation, and dismisses automatically after 6.5s or instantly upon pressing `[✕]`.
3. **Touch Safe Margins:** Bottom info card ($580 \times 160\text{ px}$) remains centered ($X \in [350, 930]$), maintaining $> 180\text{ px}$ horizontal clearance from both the Left touch controls (Brake/Nitro) and Right touch control (Gas).
4. **Decoupled Progression:** Milestone progression (top HUD Next Checkpoint counter) remains completely decoupled from optional tourist attraction triggers.
5. **Wheel Alignment Stability:** Wheels remain attached within $\le 3.5\text{ px}$ under full throttle, Nitro, jumps, and rollover recoveries throughout the route.

---

## 2. State-by-State Verification Matrix

### 2.1 Tamil Nadu (Hero Route)
- **Route:** Kanyakumari $\to$ Chennai ($1,100\text{ m}$)
- **Terrain:** Coastal shoreline, rolling red earth hills, Madurai plains, urban highway.
- **Landmarks Catalogued (12):**
  - `LOC-TN-03`: Gandhi Memorial Mandapam ($90\text{ m}$)
  - `LOC-TN-04`: Kumari Amman Temple ($160\text{ m}$)
  - `LOC-TN-05`: Kanyakumari Glass Bridge ($270\text{ m}$)
  - `LOC-TN-02`: Vivekananda Rock Memorial ($340\text{ m}$)
  - `LOC-TN-01`: Thiruvalluvar Statue ($415\text{ m}$)
  - `LOC-TN-06`: Vattakottai Coastal Fort ($510\text{ m}$)
  - `LOC-TN-07`: Kamarajar Memorial Mandapam ($570\text{ m}$)
  - `LOC-TN-14`: Meenakshi Amman Temple ($680\text{ m}$)
  - `LOC-TN-15`: Thirumalai Nayakkar Mahal ($760\text{ m}$)
  - `LOC-TN-16`: NH44 Highway Junction Dhaba ($850\text{ m}$)
  - `LOC-TN-17`: Kapaleeshwarar Temple ($980\text{ m}$)
  - `LOC-TN-22`: Marina Beach Lighthouse ($1,080\text{ m}$)
- **Bottom Panel Verification:** **PASS** (Clearance: Left $190\text{ px}$, Right $190\text{ px}$, Top $>410\text{ px}$).
- **Milestone Decoupling:** **PASS** (Passing Thiruvalluvar at $415\text{ m}$ correctly advances HUD to `NEXT: MADURAI CHECKPOINT (185m)`).
- **Screenshot Evidence:**
  - [01_tamil_nadu_bottom_info_panel.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/landmark_info_and_wheel_fix/01_tamil_nadu_bottom_info_panel.png)
  - [02_vattakottai_fort_bottom_panel.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/landmark_info_and_wheel_fix/02_vattakottai_fort_bottom_panel.png)
  - [03_thiruvalluvar_statue_bottom_panel.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/landmark_info_and_wheel_fix/03_thiruvalluvar_statue_bottom_panel.png)
  - [04_meenakshi_temple_bottom_panel.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/landmark_info_and_wheel_fix/04_meenakshi_temple_bottom_panel.png)

---

### 2.2 Goa
- **Route:** Panaji $\to$ Margao ($950\text{ m}$)
- **Terrain:** Coastal Mandovi riverfront, Portuguese Latin quarters, palm groves, rolling coastal highways.
- **Landmarks Catalogued (9):**
  - `LOC-GA-02`: Fontainhas Latin Quarter ($110\text{ m}$)
  - `LOC-GA-01`: Our Lady of Immaculate Conception ($220\text{ m}$)
  - `LOC-GA-11`: Calangute Beach Road Promenade ($340\text{ m}$)
  - `LOC-GA-09`: Fort Aguada & 1864 Lighthouse ($460\text{ m}$)
  - `LOC-GA-14`: Chapora Red Laterite Fort ($580\text{ m}$)
  - `LOC-GA-16`: Se Cathedral ($690\text{ m}$)
  - `LOC-GA-17`: Church of St Francis of Assisi ($770\text{ m}$)
  - `LOC-GA-15`: Basilica of Bom Jesus ($840\text{ m}$)
  - `LOC-GA-22`: Holy Spirit Church ($920\text{ m}$)
- **Bottom Panel Verification:** **PASS** (Correctly styles Portuguese colonial heritage info).
- **Milestone Decoupling:** **PASS** (Next checkpoint progression uninterrupted).
- **Screenshot Evidence:**
  - [05_other_state_goa_fontainhas.png](file:///home/joel/Documents/game/hill-climb-V2/docs/screenshots/landmark_info_and_wheel_fix/05_other_state_goa_fontainhas.png)

---

### 2.3 Kerala
- **Route:** Kochi $\to$ Munnar ($1,050\text{ m}$)
- **Terrain:** Backwater lagoons, coconut plantations, winding Western Ghats rainforest ascents.
- **Landmarks Catalogued (6):**
  - `LOC-KL-01`: Fort Kochi Chinese Fishing Nets ($120\text{ m}$)
  - `LOC-KL-02`: Mattancherry Dutch Palace ($280\text{ m}$)
  - `LOC-KL-06`: Alleppey Backwater Houseboat Wharf ($450\text{ m}$)
  - `LOC-KL-09`: Bekal Fort Coastal Bastion ($640\text{ m}$)
  - `LOC-KL-11`: Athirappilly Waterfalls Viewpoint ($820\text{ m}$)
  - `LOC-KL-14`: Padmanabhaswamy Temple Gopuram ($980\text{ m}$)
- **Bottom Panel Verification:** **PASS** (Malayalam coastal and highland cultural details verified).
- **Milestone Decoupling:** **PASS** (`NEXT: ALLEPPEY BACKWATERS (280m)` tracking verified).

---

### 2.4 Rajasthan
- **Route:** Jaipur $\to$ Jaisalmer ($1,200\text{ m}$)
- **Terrain:** Pink sandstone city avenues, Aravalli rocky passes, golden sand dunes.
- **Landmarks Catalogued (6):**
  - `LOC-RJ-01`: Hawa Mahal (Palace of Winds) ($150\text{ m}$)
  - `LOC-RJ-02`: Jal Mahal Water Palace ($300\text{ m}$)
  - `LOC-RJ-03`: Amber Fort Ramparts & Gateway ($490\text{ m}$)
  - `LOC-RJ-08`: Jaswant Thada Marble Cenotaph ($680\text{ m}$)
  - `LOC-RJ-11`: Mehrangarh Fort Cliff Bastion ($890\text{ m}$)
  - `LOC-RJ-15`: Patwon Ki Haveli Jharokhas ($1,100\text{ m}$)
- **Bottom Panel Verification:** **PASS** (Rajput architectural details and Venturi trivia displayed).
- **Milestone Decoupling:** **PASS** (`NEXT: AMBER FORT GATEWAY (300m)` tracking verified).

---

### 2.5 Gujarat
- **Route:** Ahmedabad $\to$ Rann of Kutch ($1,150\text{ m}$)
- **Terrain:** Riverfront urban roads, Saurashtra highway dhabas, white salt desert expanse.
- **Landmarks Catalogued (5):**
  - `LOC-GJ-01`: Sabarmati Ashram Hriday Kunj ($140\text{ m}$)
  - `LOC-GJ-02`: Adalaj Stepwell (Vav) ($320\text{ m}$)
  - `LOC-GJ-07`: Modhera Sun Temple Surya Kund ($540\text{ m}$)
  - `LOC-GJ-11`: Somnath Temple Jyotirlinga Shrine ($780\text{ m}$)
  - `LOC-GJ-16`: Statue of Unity Grand Colossus ($1,020\text{ m}$)
- **Bottom Panel Verification:** **PASS** (Gandhian history and Solanki architecture lore verified).
- **Milestone Decoupling:** **PASS** (`NEXT: SAURASHTRA HIGHWAY DHABA (300m)` tracking verified).

---

### 2.6 Telangana
- **Route:** Hyderabad $\to$ Warangal ($1,000\text{ m}$)
- **Terrain:** Historic Deccan plateau streets, granite boulder hills, rural Kakatiya plains.
- **Landmarks Catalogued (6):**
  - `LOC-TG-01`: Iconic Charminar 4-Minaret Monument ($130\text{ m}$)
  - `LOC-TG-02`: Chowmahalla Palace Courtyard ($260\text{ m}$)
  - `LOC-TG-03`: Golconda Fort Bastion ($440\text{ m}$)
  - `LOC-TG-06`: Hussain Sagar Monolithic Buddha ($620\text{ m}$)
  - `LOC-TG-08`: Birla Mandir White Marble Temple ($790\text{ m}$)
  - `LOC-TG-14`: Ramappa Temple (Rudreshwara) ($940\text{ m}$)
- **Bottom Panel Verification:** **PASS** (Qutb Shahi, Nizam, and Kakatiya heritage text verified).
- **Milestone Decoupling:** **PASS** (`NEXT: GOLCONDA FORT BASTION (260m)` tracking verified).

---

## 3. Comprehensive Summary Statistics

- **Total States Verified:** 6 / 6 ($100\%$)
- **Total Landmarks Catalogued & Integrated:** 44 / 44 ($100\%$)
- **Automated Regression Suite Pass Rate:** $100\%$ (`test_landmark_info_and_wheel_fix.gd`, `test_all_six_indian_roads_states.gd`, `test_glass_bridge_traversal.gd`, `test_indian_roads_visual_upgrade_v2.gd`)
- **Zero Input Blockers:** Verified safe touch buffers across all screen sizes.
- **Zero Wheel Displacements:** Wheel detachment eliminated across all states and driving actions.
