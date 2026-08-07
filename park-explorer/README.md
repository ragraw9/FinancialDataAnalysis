# Park Explorer (v1: Yellowstone)

A single-park deep-dive experience in a vintage risograph / WPA travel-poster style.

- **[`DESIGN_SPEC.md`](DESIGN_SPEC.md)** — information architecture and design system spec (the source of truth)
- **[`reference-landing-mockup.png`](reference-landing-mockup.png)** — the landing-page mockup that defines the aesthetic system
- **[`prototype/index.html`](prototype/index.html)** — clickable prototype of all four levels with placeholder data

## Running the prototype

Open `prototype/index.html` in a browser. No build step, no server, no dependencies — it's a single self-contained file.

The four levels are hash-routed (`#/park`, `#/region/lamar`, `#/region/lamar/lamar-river`), so browser back/forward works and every screen is linkable. Placeholder data lives in one `REGIONS` object at the top of the script, shaped to match the data contracts named in the spec — a future data pass replaces values, not structure.
