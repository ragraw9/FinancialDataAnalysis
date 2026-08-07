# Park Explorer — Design Spec & Content Architecture

**Version:** 1.0 (Yellowstone)
**Status:** Spec only — not a build request
**Scope note:** Real data sourcing (NPS API, USGS elevation, wildlife databases) is explicitly out of scope for this pass. Every screen below names the *kind* of data it needs so the shell isn't designed in a way real data can't later fill.
**Reference:** `reference-landing-mockup.png` (in this folder) — the existing landing page mockup, risograph / WPA travel-poster style. It is the canonical aesthetic reference and the Level 0 entry point. It is not redesigned here; its visual language is extended downward.

---

## 1. Product spine

Four levels. Each has one job. No level does another level's job.

| Level | Screen | Job | Data character |
|---|---|---|---|
| 0 | Landing | Search + park identity. Entry only. | Static (exists) |
| 1 | Park Overview | Geographic hub — orient the user, route them to a region | Park geometry, region boundaries, road network |
| 2 | Region View | Show what's *in* a region; let the user pick a trail/spot | Trail metadata, POI list, wildlife/vegetation tags |
| 3 | Detail View | Sell and inform one specific trail or viewpoint | Per-trail stats, elevation profile, seasonal notes |

The failure mode this architecture prevents: fragmenting into 7 disconnected top-level tabs (Trails / Wildlife / Topo / Vegetation / …). Topography, terrain, and vegetation are **layers and tags within levels**, never top-level sections. This is the key architectural decision of the product.

---

## 2. Level 0 — Landing (exists)

Not respecced. Defined by the reference mockup. Two things it contributes downstream:

1. **Aesthetic template** — see §7. The "EXPLORE" button, the postage-stamp badge, the "TRY THESE" / "EST. MARCH 1, 1872" small-caps labels are the templates for all UI chrome below.
2. **Exit interaction** — selecting a park (search or "TRY THESE" chip) transitions to Level 1. Transition should read as *travel*: e.g., the poster hero recedes and the map unfurls (see §6, Transitions).

**Known tension to flag for the illustrator/generator:** the landing hero mountain is geographically fictional. That is acceptable at Level 0 (it's a poster, not a map). It is **not** acceptable at Levels 1–2 — see the map constraint in §3.

---

## 3. Level 1 — Park Overview (the hub)

### Job
An aerial, geographically accurate but stylized map of Yellowstone. This is a **nav map, not decoration**. The user's only meaningful action here is choosing a region.

### The map constraint (hard requirement — flag to illustrator/generator)

The shapes must correspond to real Yellowstone geography:

- The **Grand Loop Road** figure-eight must be topologically correct (Mammoth at the top of the upper loop, Old Faithful on the lower-left of the lower loop, Canyon at the junction area, Lake on the lower-right).
- **Yellowstone Lake** must sit in its real position (southeast quadrant) at roughly correct relative scale.
- **Relative distances** between regions must be plausible — Lamar Valley reads as far northeast, Mammoth-to-Old-Faithful reads as a long drive, not adjacent tiles.
- Entrances (North, Northeast, East, South, West) shown as small road stubs at the correct edges — they anchor the geography for anyone who's driven in.

Rendering is stylized (ink outlines, flat color fields, halftone texture — §7), but a viewer who knows the park must be able to orient in under a second. **A geographically fictional "pretty mountain" composition fails as navigation.** If the map is generated rather than hand-drawn, generate over a real basemap trace, then stylize — never compose freeform.

### Regions (the six hotspots)

| Region | Suggested accent color* | Real-geography anchor |
|---|---|---|
| Mammoth Hot Springs | Terracotta / travertine cream | Top of upper loop, near North Entrance |
| Old Faithful / Upper Geyser Basin | Burnt orange | Lower-left of lower loop, Firehole River corridor |
| Lamar Valley | Golden ochre | Far northeast, along the Lamar River road |
| Grand Canyon of the Yellowstone | Rust red / canyon pink | East side of the loop junction |
| Yellowstone Lake | Deep blue | Southeast quadrant |
| Tower–Roosevelt / Northeast | Forest green | Northeast section of upper loop |

\* Accent colors are drawn from the master palette (§7.2) plus region-local tints; the point of the column is the *system* (one consistent accent per region, used everywhere — see §7.5), not these exact hues. Final hues are the designer's call, validated for distinguishability including for color-vision deficiency.

### Content requirements

- Park name lockup (small — the landing already did identity; don't repeat the hero)
- The illustrated map with 6 tappable region hotspots
- Per-hotspot label: region name in small-caps label style + region stamp icon
- Optional thin footer strip: park-wide facts styled as ephemera ("EST. MARCH 1, 1872", acreage, designation) — decoration budget, not navigation
- **Open question (do not resolve here):** whether a "top spots across the whole park" cross-region rail belongs on this screen — see §8.2

### Data needed (name it, don't source it)

- Region boundary polygons or hotspot hit-areas registered against the stylized map (a mapping from stylized coordinates → real region identity)
- Road network geometry (Grand Loop + entrance roads) for the illustrator's trace
- Per-region: name, stamp icon asset, accent color token, one-line teaser ("Wolves at dawn" for Lamar)

### Interaction

- **Tap/click a hotspot** → Level 2 Region View for that region.
- **Hover (desktop):** hotspot lifts slightly (paper-tag shadow deepens), region label and teaser line appear as a swing-tag; region tints toward its accent color while the rest of the map desaturates ~15%. Nothing moves position — the map is stable ground.
- **Focus/keyboard:** hotspots are tabbable in geographic reading order (north to south); focus state mirrors hover state.
- No pan/zoom at this level. The whole park fits the frame. Panning would break the "one glance, one choice" job.

---

## 4. Level 2 — Region View

### Job
Answer "what's in Mammoth?" / "what's in Lamar Valley?" and get the user to a specific trail or viewpoint. The map stays primary; a list is a secondary *view of the same data*, not a different screen.

### Layout (desktop-first, pending §8.3)

- **Map canvas (dominant, ~65–70% width):** illustrated region map, same geographic-fidelity rules as Level 1 but zoomed to region scale. Trails drawn as dashed ink paths, viewpoints as stamp-style markers, trailheads as small road-junction glyphs. All markers are tappable hotspots — **the same interaction pattern the user learned at Level 1, one level down.** Do not switch to a list-first pattern here.
- **Side panel (~30–35% width):** the region's contents as paper-tag cards (see below). Selecting a card highlights its marker on the map and vice versa — one selection model, two representations.
- **Region header:** region name (bold serif display), region stamp icon, accent color band, breadcrumb back to Park Overview styled as a small map-corner fold or "return to map" ticket stub.

### Content requirements (per region)

1. **Trail list** — each entry: name, distance, difficulty, estimated time. Rendered as paper tags with the region accent color; difficulty as a stamp glyph (single boot / double boot / crossed ice axes or similar — designer's pick, but glyph + word, never color alone).
2. **Top spots / viewpoints** — name + one-line hook + marker on map. Same card anatomy as trails minus the stats row.
3. **Wildlife tags** — *tags, not a field guide.* Small-caps chips: "BISON", "WOLVES", "ELK", optionally with a seasonal qualifier ("SPRING"). Tapping a tag does nothing in v1 beyond a tooltip-scale note; wildlife is context, not a destination. Graceful-degradation behavior is an open question — §8.1.
4. **Vegetation / biome character** — one to three chips describing zone character: "GEOTHERMAL-ADAPTED", "HIGH ALPINE MEADOW", "LODGEPOLE FOREST", "SAGEBRUSH STEPPE". Same chip anatomy as wildlife, different chip color family so the two tag types are scannable apart.
5. **Map layer toggle** — a three-state control styled as a physical artifact (luggage-tag flip switch or rubber-stamp selector):
   - **Base** — illustrated map (default)
   - **Topo** — contour overlay in a single ink color over the base illustration; base colors mute to parchment
   - **Trails** — trail paths emphasized, everything else recedes; difficulty color-coded on the paths themselves
   Layers are *overlays on one map*, not separate screens. State persists while the user stays within the region.

**Architectural rule, restated because it's the load-bearing one:** topography, terrain, and vegetation are toggleable layers or contextual tags *at this level*. They are never promoted to top-level navigation.

### Data needed

- Per-region trail records: name, distance, difficulty class, estimated time, trailhead coordinate, path geometry (for the trail overlay)
- Viewpoint/POI records: name, coordinate, one-line description, type (geothermal / waterfall / overlook / historic)
- Contour data at region scale (for the topo overlay trace — simplified, not survey-grade)
- Wildlife likelihood tags per region, ideally with a seasonality dimension (species × season → likelihood bucket)
- Biome/vegetation classification tags per region

### Interaction

- Tap trail path or viewpoint marker → Level 3 Detail View
- Tap card in side panel → same destination; hover/focus on either highlights both (marker pulses its accent, card lifts)
- Layer toggle: instant crossfade (~200ms), no reflow of markers — markers must sit at identical coordinates in all three layers
- Back: breadcrumb to Level 1; browser back must mirror it (levels are real navigable locations with URLs, not modal states)
- **Accessibility view:** the side panel *is* the accessible equivalent of the map — everything tappable on the map must exist as a card. A "list only" mode (hide map, full-width cards) is a user setting, not a separate screen.

---

## 5. Level 3 — Detail View (one trail or viewpoint)

### Job
Everything needed to decide "am I doing this hike?" on one poster-like sheet. This is the level that most rewards the aesthetic — it should feel like a collectible trail card.

### Layout

A single card/sheet composition, styled as a vintage trail brochure page: region accent color banding, stamp iconography, halftone texture. Desktop: centered sheet over a dimmed region map. Mobile: full-screen sheet.

### Content requirements

1. **Header:** trail/viewpoint name (bold serif display), region stamp + accent color, type label in small-caps ("GEYSER BASIN TRAIL", "SCENIC OVERLOOK")
2. **Stats row** — styled like a ticket's fine print, small-caps labels with sans values:
   - Distance
   - Difficulty (glyph + word)
   - Estimated time
   - Trailhead location (named junction / parking area, plus "on the map" affordance jumping back to the Level 2 map with this marker focused)
3. **Elevation profile** — a *simple line*, drawn in the ink-outline style (single stroke, subtle halftone fill below the line), with only min/max elevation and total gain labeled. Explicitly **not** a full topo render; the topo overlay lives at Level 2.
4. **"What you'll see"** — 2–4 illustrated chips or a short illustrated strip: geothermal feature, waterfall, wildlife corridor, canyon rim, etc. Each is icon + label, matching the stamp-icon family.
5. **Best season / time of day** — one line, small-caps ("BEST: JUNE–SEPT · GO AT DAWN"), optionally a tiny sun/season dial illustration
6. **Insider tips (one or two)** — callouts styled as the poster/stamp aesthetic: a rubber-stamped note ("RANGER'S NOTE"), a taped-on scrap of paper, or a postmark-framed aside. Voice: specific and confident ("The crowd leaves by 4pm; the light gets good at 6."). Maximum two — three tips is a listicle, not an artifact.

### Data needed

- Per-trail: name, type, region id, distance, difficulty, estimated time, trailhead name + coordinate
- Elevation series (simplified polyline — e.g., ≤50 sample points; source resolution is a data-pass problem, the shell only needs the polyline)
- Feature tags for "what you'll see"
- Seasonal recommendation fields (best months, best time of day)
- Editorial tip copy (this is authored content, not API data — flag as a content-ops dependency)

### Interaction

- Back to Region View (sheet dismisses; region map is exactly where the user left it, layer toggle state intact)
- "On the map" jump from trailhead stat → Level 2 with marker focused
- No further drill-down. Level 3 is a leaf. Resist adding photo galleries, reviews, comments — different product.

---

## 6. Interaction model — summary

**One pattern, learned once:** *tap the map.* Level 1 teaches it; Level 2 repeats it one scale down. Lists never replace the map; they mirror it.

| | Level 1 | Level 2 | Level 3 |
|---|---|---|---|
| Primary surface | Illustrated park map | Illustrated region map | Static sheet |
| Tap targets | 6 region hotspots | Trail paths, viewpoint markers, cards | Back, "on the map" |
| Secondary view | — | Side-panel card list (same data) | — |
| Layers | none | base / topo / trails | none |
| Zoom/pan | none | none in v1 (region fits frame) | — |

**Transitions:** each descent should read as *going closer* — a zoom-and-settle into the tapped region (Level 1→2), a sheet sliding over the map (Level 2→3). Ascent reverses the same motion. Duration ~300ms, eased; the map never teleports.

**Navigation state:** every level + region + detail is URL-addressable. Browser back = in-app back. Layer toggle state is per-region session state, not URL state.

---

## 7. Aesthetic system (extended from the reference image)

### 7.1 Style

Risograph / vintage national-park poster throughout:

- Bold flat color fields; no gradients except halftone-simulated shading
- Visible halftone / print-grain texture on large fills (subtle — texture is seasoning, never noise over text)
- Thick, confident ink outlines on illustrated elements; slight intentional misregistration between outline and fill is welcome (riso charm), **except on maps** where hotspot legibility wins
- Limited palette, printed-on-parchment ground

### 7.2 Master palette (as printed in the reference)

| Token | Sampled from reference | Role |
|---|---|---|
| Cobalt blue | Sky field behind the headline | Dominant ground on hero surfaces; water at map scale reads one step deeper |
| Kelly / forest green | Hillsides, conifers | Vegetation fields, one region accent |
| Cream / parchment | Headline fill, input field, chips, info card, footer band | Paper color for every card, chip, and panel — and the page ground at Levels 2–3 |
| Vermilion / burnt orange | "EXPLORE" button, "EST." line, "WILD & WORTH PROTECTING" stamp | Primary accent, CTAs, rubber-stamp ink, one region accent |
| Near-black ink | All outlines, headline texture, body text | Outlines, type, hatching |

Note the reference's hierarchy: at Level 0 the *blue* is the ground and cream objects sit on it. Levels 1–2 invert this — parchment becomes the ground (it's a map/document) and blue returns as water and accents. Region accents (§3) are derived from this palette plus a small number of extensions (terracotta, ochre, rust); total distinct hues on any one screen stays ≤6.

### 7.3 Typography (three voices, all present in the reference)

- **Display:** bold soft-serif with rough print texture (the "Park Explorer" headline face) — screen titles, region names, trail names, and the search-input face ("Yellowstone")
- **Utility/body accent:** **monospace** — the reference's tagline ("Generate a miniature park diorama…") is set in mono, not a clean sans. Carry this downward as the voice for descriptions, stats values, coordinates, and data readouts; mono reinforces the "field document / typewritten label" feel
- **Labels/metadata:** bold condensed sans in all-caps with letterspacing (the "TRY THESE", "YOSEMITE" chips, "EST. MARCH 1, 1872", footer feature labels) — tags, chips, stat labels, card titles, breadcrumbs
- No fourth style. If something doesn't fit these three, the design has a hierarchy problem, not a font shortage.

### 7.4 UI chrome as artifact

Buttons, cards, and info panels are styled as physical objects, never flat modern UI. The reference already supplies the component templates:

- **Buttons** — the "EXPLORE" button: vermilion plate, black keyline, **hard offset drop shadow** (solid, un-blurred, offset down-right — a print artifact, not an elevation blur). Pressed state = shadow collapses (plate moves onto its shadow), not a color swap
- **Chips** — the "YOSEMITE / ZION / BANFF…" park chips: cream rounded-rects, black keyline, condensed all-caps, same hard offset shadow. This is the template for wildlife/vegetation tags and difficulty chips at Levels 2–3
- **Cards/panels** — the "YELLOWSTONE NATIONAL PARK" info card: cream panel, black keyline, condensed-caps title, orange small-caps metadata line, mono/sans body, plus an inline spot illustration (the geyser) and an overlapping circular rubber stamp. This is the template for trail cards and the Level 3 sheet
- **Badges/icons** — the perforated postage-stamp badge (top-right "EXPLORE — AMERICA'S NATIONAL PARKS"): region stamps, difficulty stamps, "what you'll see" chips all share this frame family
- **Rubber stamps** — the circular "WILD & WORTH PROTECTING" mark: the template for insider-tip callouts and seasonal notes; always slightly rotated, ink-textured, overlapping the edge of its host card
- **Toggles** — physical metaphors (flip tag, rubber-stamp selector) built from the same keyline + offset-shadow anatomy
- Shadows are always the hard-offset print style seen in the reference — never soft blurs, never material-design elevation ramps

### 7.5 Map style constraint (repeated because it's a rule, not a preference)

The Park Overview and Region maps are **functional maps first, illustration second.** Real topology, real relative scale, real trail/road paths — rendered in the ink-and-color style. The decorative-hero approach of the landing mountain is banned from Levels 1–2. Practical test for any map candidate: can someone who has visited Yellowstone point to Old Faithful without reading a label? If no, reject.

### 7.6 Region color coding

Each region owns one accent color, used consistently in: its Level 1 hotspot, its Level 2 header band and cards, its Level 3 sheet banding, and its stamp icon. Goal: the user knows "which region am I in" from color alone, independent of text. Constraints: colors must survive on parchment ground, remain distinguishable under common color-vision deficiencies, and never carry meaning *alone* (always paired with the stamp icon + label).

---

## 8. Open questions (flagged, deliberately unresolved)

1. **Sparse/seasonal wildlife data degradation.** How do wildlife tags behave when real data is sparse or seasonal? Options to evaluate in the data pass: seasonal qualifiers on chips ("BISON — SPRING"), confidence buckets ("SIGHTINGS COMMON / OCCASIONAL"), or omission below a threshold. The chip anatomy in §4 must accommodate an optional qualifier line either way — that's the shell requirement; the policy is unresolved.
2. **Cross-region "top spots" at Level 1.** Is a park-wide highlights rail on the Park Overview needed, or is it redundant with browsing by region? It risks competing with the map for the screen's one job. Decide after observing whether test users stall at Level 1.
3. **Primary surface: mobile vs. desktop.** The reference image reads as desktop/wide. Confirm before speccing touch-target sizes for map hotspots (the Level 2 trail-path taps especially — dashed ink paths are thin targets and will need generous invisible hit areas on touch). Layout in §4 assumes desktop-first; the mobile adaptation (map top, cards as a bottom sheet) is sketched but not specced.

---

## 9. Handoff checklist

For a designer or future build session picking this up:

- [ ] Obtain/produce the geographic base traces (park outline, Grand Loop Road, lake, region boundaries) before any map illustration begins — §3 constraint
- [ ] Define the 6 region accent tokens + stamp icons as a set (they appear at all three levels)
- [ ] Resolve §8.3 (primary surface) before sizing hotspots
- [ ] Build the paper-tag card and stamp-chip components once; both Level 2 and Level 3 compose from them
- [ ] Data contract stubs for: region records, trail records, POI records, elevation polylines, wildlife/vegetation tags (shapes named in §§3–5)
- [ ] Editorial pipeline for insider tips (authored content, not API-fillable)
